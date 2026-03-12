# Session 3.3 Handout: Transfer Arms to Jetson & Verify Full Pipeline

## Key Concepts

### Why Move from Mac to Jetson?
| Factor | Mac | Jetson |
|---|---|---|
| GPU Training | MPS — buggy for robotics ML | CUDA — the standard |
| USB Latency | Fine for testing | Better for real-time control |
| Pipeline | Split (record on Mac, train elsewhere) | Unified (record → train → deploy) |

Think of it as: **Mac = workbench** (great for assembly/testing), **Jetson = production floor** (where the real work happens).

### What Changes When Moving to Linux?
- USB port names: `/dev/ttyACM*` (Linux) vs `/dev/tty.usbmodem*` (Mac)
- Linux permissions: `sudo chmod 666 /dev/ttyACM*` needed after each reboot
- Camera indices may differ — always re-run `lerobot-find-cameras opencv`
- Calibration files are machine-local — re-calibrate on the new machine

### What Stays the Same?
- All LeRobot commands are identical
- Motor IDs, wiring, physical assembly — unchanged
- The pipeline: calibrate → teleop → record → train → deploy

## Port Mapping Reference

### Motor Boards
| Arm | Mac Port | Jetson Port |
|---|---|---|
| Follower | /dev/tty.usbmodem5AAF2626601 | /dev/ttyACM0 |
| Leader | /dev/tty.usbmodem5AAF2625931 | /dev/ttyACM1 |

### Cameras
| Camera | Role | Mac Index | Jetson Path |
|---|---|---|---|
| Logitech VU0029 | front | 1 | /dev/video0 |
| Lenovo 500 FHD | top | 0 | /dev/video2 |

## Essential Commands on Jetson

```bash
# SSH in
ssh fay@192.168.5.196

# Activate environment
conda activate lerobot

# Set USB permissions (needed after reboot)
sudo chmod 666 /dev/ttyACM*

# Find cameras
lerobot-find-cameras opencv

# Calibrate
lerobot-calibrate --robot.type=so101_follower --robot.port=/dev/ttyACM0 --robot.id=follower
lerobot-calibrate --teleop.type=so101_leader --teleop.port=/dev/ttyACM1 --teleop.id=leader

# Teleoperate
lerobot-teleoperate --robot.type=so101_follower --robot.port=/dev/ttyACM0 --robot.id=follower --teleop.type=so101_leader --teleop.port=/dev/ttyACM1 --teleop.id=leader

# Record with cameras
lerobot-record --robot.type=so101_follower --robot.port=/dev/ttyACM0 --robot.id=follower --robot.cameras="{ front: {type: opencv, index_or_path: /dev/video0, width: 640, height: 480, fps: 30}, top: {type: opencv, index_or_path: /dev/video2, width: 640, height: 480, fps: 30}}" --teleop.type=so101_leader --teleop.port=/dev/ttyACM1 --teleop.id=leader --dataset.repo_id=fay/DATASET_NAME --dataset.num_episodes=NUM --dataset.single_task="TASK" --dataset.push_to_hub=false
```

## Troubleshooting

| Problem | Solution |
|---|---|
| Permission denied on /dev/ttyACM* | `sudo chmod 666 /dev/ttyACM*` |
| Don't know which port is which arm | Unplug one, run `ls /dev/ttyACM*`, see which disappears |
| Camera not found | `ls /dev/video*`, try different indices |
| Headless mode (no display over SSH) | Normal — recording works fine without preview |
| Gripper "Overload error" on disconnect | Harmless — recording completed successfully |
| JointOutOfRangeError | Usually a loose 3-pin cable, not calibration |

## Vocabulary
- **Headless mode**: Running without a display/monitor — LeRobot detects this over SSH and skips the camera preview window
- **pynput**: Python library for keyboard input — fails headless, but LeRobot falls back gracefully
- **AV1 (libsvtav1)**: The video codec used to encode camera frames — modern, efficient compression

## What's Next
Day 4 begins! Session 4.1: Understanding AI Policies & Data Collection — you'll learn what a "policy" actually is and how your recorded demonstrations become training data.
