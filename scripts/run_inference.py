"""Run ACT policy inference on the SO-ARM101 robot with video recording.

Adapted from lerobot/examples/tutorial/act/act_using_example.py

Usage:
    python3 run_inference.py                    # uses last (100K) checkpoint
    python3 run_inference.py 060000             # uses 60K checkpoint
    python3 run_inference.py 080000             # uses 80K checkpoint
"""

import sys
import time
from pathlib import Path

import cv2
import numpy as np
import torch

from lerobot.cameras.opencv.configuration_opencv import OpenCVCameraConfig
from lerobot.datasets.lerobot_dataset import LeRobotDatasetMetadata
from lerobot.policies.act.modeling_act import ACTPolicy
from lerobot.policies.factory import make_pre_post_processors
from lerobot.policies.utils import build_inference_frame, make_robot_action
from lerobot.robots.so_follower import SO101Follower, SO101FollowerConfig


# === Configuration ===
CHECKPOINT = sys.argv[1] if len(sys.argv) > 1 else "last"
PRETRAINED_PATH = f"outputs/train/act_shark_to_cup/checkpoints/{CHECKPOINT}/pretrained_model"
DATASET_ID = "fay/shark-to-cup"
DATASET_ROOT = "/home/fay/.cache/huggingface/lerobot/fay/shark-to-cup"
DEVICE = torch.device("cuda")

# Robot hardware
FOLLOWER_PORT = "/dev/ttyACM0"
FOLLOWER_ID = "follower"

# Cameras (must match training data exactly)
CAMERA_CONFIG = {
    "top": OpenCVCameraConfig(index_or_path=2, width=640, height=480, fps=30),
    "front": OpenCVCameraConfig(index_or_path=0, width=640, height=480, fps=30),
}

# Inference settings
NUM_EPISODES = 5
EPISODE_DURATION_S = 20  # seconds per episode
FPS = 30

# Recording
OUTPUT_DIR = Path(f"eval_recordings_{CHECKPOINT}")


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Loading ACT policy from checkpoint: {CHECKPOINT}")
    print(f"  Path: {PRETRAINED_PATH}")
    policy = ACTPolicy.from_pretrained(PRETRAINED_PATH)
    policy = policy.to(DEVICE)
    policy.eval()
    print(f"Policy loaded on {DEVICE}")

    print("Loading dataset metadata for normalization stats...")
    dataset_metadata = LeRobotDatasetMetadata(DATASET_ID, root=DATASET_ROOT)
    preprocessor, postprocessor = make_pre_post_processors(
        policy.config,
        pretrained_path=PRETRAINED_PATH,
        dataset_stats=dataset_metadata.stats,
        preprocessor_overrides={"device_processor": {"device": str(DEVICE)}},
    )
    print("Preprocessor/postprocessor ready")

    print("Connecting to robot...")
    robot_cfg = SO101FollowerConfig(
        port=FOLLOWER_PORT,
        id=FOLLOWER_ID,
        cameras=CAMERA_CONFIG,
    )
    robot = SO101Follower(robot_cfg)
    robot.connect()
    print("Robot connected!")

    try:
        for ep in range(NUM_EPISODES):
            input(f"\n{'='*50}\nEpisode {ep + 1}/{NUM_EPISODES}: Press Enter to start (place shark on blue tape)...")

            # Set up video writers for this episode
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            top_path = str(OUTPUT_DIR / f"ep{ep+1}_top.mp4")
            front_path = str(OUTPUT_DIR / f"ep{ep+1}_front.mp4")
            combined_path = str(OUTPUT_DIR / f"ep{ep+1}_combined.mp4")
            top_writer = cv2.VideoWriter(top_path, fourcc, FPS, (640, 480))
            front_writer = cv2.VideoWriter(front_path, fourcc, FPS, (640, 480))
            combined_writer = cv2.VideoWriter(combined_path, fourcc, FPS, (1280, 480))

            print("Running inference (recording cameras)...")
            max_steps = EPISODE_DURATION_S * FPS
            start_time = time.time()

            for step in range(max_steps):
                step_start = time.time()

                # 1. Get observation from robot
                obs = robot.get_observation()

                # 2. Save camera frames (keys are "top"/"front" from robot obs)
                top_frame = obs.get("top")
                if top_frame is None:
                    top_frame = obs.get("observation.images.top")
                if top_frame is not None:
                    if isinstance(top_frame, torch.Tensor):
                        top_frame = top_frame.cpu().numpy()
                    top_bgr = cv2.cvtColor(top_frame, cv2.COLOR_RGB2BGR)
                    top_writer.write(top_bgr)
                else:
                    top_bgr = np.zeros((480, 640, 3), dtype=np.uint8)

                front_frame = obs.get("front")
                if front_frame is None:
                    front_frame = obs.get("observation.images.front")
                if front_frame is not None:
                    if isinstance(front_frame, torch.Tensor):
                        front_frame = front_frame.cpu().numpy()
                    front_bgr = cv2.cvtColor(front_frame, cv2.COLOR_RGB2BGR)
                    front_writer.write(front_bgr)
                else:
                    front_bgr = np.zeros((480, 640, 3), dtype=np.uint8)

                # Combined side-by-side
                combined = np.hstack([top_bgr, front_bgr])
                combined_writer.write(combined)

                # 3. Build inference frame
                obs_frame = build_inference_frame(
                    observation=obs,
                    ds_features=dataset_metadata.features,
                    device=DEVICE,
                )

                # 4. Preprocess
                obs_frame = preprocessor(obs_frame)

                # 5. Get action from policy
                action = policy.select_action(obs_frame)

                # 6. Postprocess
                action = postprocessor(action)

                # 7. Convert to robot action and send
                action = make_robot_action(action, dataset_metadata.features)
                robot.send_action(action)

                # Maintain FPS
                dt = time.time() - step_start
                sleep_time = (1.0 / FPS) - dt
                if sleep_time > 0:
                    time.sleep(sleep_time)

                # Print status every second
                if step % FPS == 0:
                    elapsed = time.time() - start_time
                    print(f"  Step {step}/{max_steps} ({elapsed:.1f}s elapsed)")

            elapsed = time.time() - start_time
            top_writer.release()
            front_writer.release()
            combined_writer.release()
            print(f"Episode {ep + 1} done! ({elapsed:.1f}s)")
            print(f"  Saved: {top_path}, {front_path}, {combined_path}")

    except KeyboardInterrupt:
        print("\nStopped by user")
    finally:
        print("Disconnecting robot...")
        try:
            robot.disconnect()
        except Exception as e:
            print(f"Disconnect error (harmless): {e}")
        print("Done!")
        print(f"\nAll recordings saved to: {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
