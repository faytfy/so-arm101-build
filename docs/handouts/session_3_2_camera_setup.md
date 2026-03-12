# Session 3.2 Handout: Camera Setup & Recording Test

## Concepts

### Why Cameras Matter
- Joint angles alone tell the robot *what* it did, not *why*
- Camera images are **observation features** — the policy's "eyes"
- Without vision, the robot can't adapt to changes (e.g., object moved 2 inches)

### How Cameras Fit the Pipeline
| Stage | What happens with cameras |
|---|---|
| **Recording** | Camera frames saved alongside joint positions at each timestep |
| **Training** | Policy learns to map images → actions |
| **Inference** | Live camera feed drives the policy's decisions |

### Camera Naming
- Names like `front`, `top` must be **consistent** between recording and inference
- The policy learns "front = this angle" — swap them and it's confused

### Placement Strategy
- Two cameras is the sweet spot: enough info without drowning in data
- `front` — faces the workspace, sees object + gripper
- `top` — bird's-eye view, captures spatial layout
- Cameras must be **fixed in place** — any shift breaks the learned visual features

### Resolution Tradeoffs
- 640x480 @ 30fps is the practical standard
- Training downscales images anyway — 1080p just wastes disk and compute
- Higher resolution = bigger datasets, slower training, minimal benefit

## Our Camera Setup

| Camera | Model | OpenCV Index (Mac) | Role | Resolution |
|---|---|:---:|---|---|
| Lenovo 500 FHD | USB webcam | 0 | `top` (overhead) | 640x480 @ 30fps |
| Logitech VU0029 | USB webcam | 1 | `front` (workspace-facing) | 640x480 @ 30fps |

Note: Mac camera indices can change after reboot. On Jetson we'll use stable `/dev/video` paths.

## Commands Reference

### Detect cameras
```bash
lerobot-find-cameras opencv
```

### Teleoperate with cameras
```bash
lerobot-teleoperate --robot.type=so101_follower --robot.port=PORT --robot.id=follower --robot.cameras="{ front: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30}, top: {type: opencv, index_or_path: 0, width: 640, height: 480, fps: 30}}" --teleop.type=so101_leader --teleop.port=PORT --teleop.id=leader --display_data=true
```

### Record episodes
```bash
lerobot-record --robot.type=so101_follower --robot.port=PORT --robot.id=follower --robot.cameras="{ front: {type: opencv, ...}, top: {type: opencv, ...}}" --teleop.type=so101_leader --teleop.port=PORT --teleop.id=leader --display_data=true --dataset.repo_id=USER/DATASET --dataset.num_episodes=N --dataset.single_task="Task description" --dataset.push_to_hub=false
```

### Camera config options
```yaml
camera_name:
  type: opencv
  index_or_path: 0        # OpenCV index or /dev/video path
  width: 640
  height: 480
  fps: 30
  rotation: 0             # 0, 90, 180, or -90
  fourcc: MJPG            # Optional — helps with frame rate issues
```

## Troubleshooting Quick Reference

| Problem | Solution |
|---|---|
| Camera not detected | Try different USB port; check System Information > USB |
| Low frame rate | Add `fourcc: MJPG`; reduce resolution |
| Image upside down | Add `rotation: 180` |
| Image sideways | Add `rotation: 90` or `-90` |
| "Camera already in use" | Close other apps using camera |
| `FileExistsError` on record | Delete old dataset or add `--resume=true` |

## Vocabulary
- **Observation features**: Data the policy uses as input (camera images, joint positions)
- **AV1 / libsvtav1**: Video codec used by LeRobot to compress recorded camera frames
- **Rerun**: Visualization tool that shows camera feeds + joint data during teleoperation/recording
- **Episode**: One complete demonstration (e.g., one pick-up-and-place sequence)
