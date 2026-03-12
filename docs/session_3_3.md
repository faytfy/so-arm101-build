# Session 3.3: Transfer Arms to Jetson & Verify Full Pipeline

## Goal
Move both arms and cameras to the Jetson AGX Orin and verify the complete pipeline: motor control, calibration, teleoperation, camera feeds, and recording — all running on Jetson.

## Prerequisites
- Session 3.1 complete (Jetson environment ready)
- Session 3.2 complete (cameras tested, recording verified on Mac)
- Both arms assembled, calibrated, and teleoperation verified on Mac
- Jetson accessible via SSH

---

## Section 1: Why Move to Jetson? (TEACH)

### Concepts
- **Why not just stay on Mac?** Mac worked great for assembly and testing, but for real training and deployment, we need:
  - CUDA GPU for policy training (Mac MPS is buggy for robotics ML)
  - Lower USB latency for real-time motor control
  - A single machine running the full pipeline (record → train → deploy)
- **What changes when we move?**
  - USB ports get different names (`/dev/ttyACM*` on Linux vs `/dev/tty.usbmodem*` on Mac)
  - Camera indices may differ — Jetson uses `/dev/video*` paths
  - Calibration files need to exist on Jetson (re-calibrate or copy)
  - Linux USB permissions: need `chmod 666` on device files
- **What stays the same?**
  - LeRobot commands are identical
  - Motor IDs, physical assembly, wiring — all unchanged
  - The learning pipeline concept: calibrate → teleop → record → train → deploy

## Section 2: Physical Transfer & USB Setup (DO)

### Steps
1. **Power down both arms** (unplug power supplies)
2. **Disconnect USB cables from Mac**, keep power cables attached to boards
3. **Move arms to Jetson workspace** — position near Jetson with cameras
4. **Connect USB cables to Jetson** (both arms)
5. **Connect power supplies** (12V → follower, 5V/7.4V → leader)
6. **Mount cameras** in the same positions (top + front)

### Verify USB detection
```bash
# On Jetson (SSH from Mac)
ls /dev/ttyACM*
# Should see two devices (one per arm)
```

### Set Linux USB permissions
```bash
sudo chmod 666 /dev/ttyACM*
```

### Checkpoint
- [ ] Both arms physically connected to Jetson
- [ ] Two `/dev/ttyACM*` devices visible
- [ ] Cameras connected to Jetson USB ports

## Section 3: Calibration on Jetson (DO)

### Why re-calibrate?
Calibration files are machine-local. We could copy them from Mac, but it's better to re-calibrate on Jetson to account for any slight differences in USB timing and to ensure the files are in the right location.

### Steps
```bash
# Activate environment
conda activate lerobot

# Calibrate follower
lerobot-calibrate --robot.type=so101_follower --robot.port=/dev/ttyACM0 --robot.id=follower

# Calibrate leader
lerobot-calibrate --teleop.type=so101_leader --teleop.port=/dev/ttyACM1 --teleop.id=leader
```

**Important:** Use the same `id` values as on Mac (`follower` and `leader`) so config files are consistent.

### Checkpoint
- [ ] Follower calibrated on Jetson
- [ ] Leader calibrated on Jetson

## Section 4: Camera Discovery on Jetson (DO)

### Steps
```bash
# Find cameras
lerobot-find-cameras opencv
```

Map camera indices to physical cameras (top vs front) — indices will likely differ from Mac.

### Checkpoint
- [ ] Camera indices identified on Jetson
- [ ] Cameras mapped to positions (top, front)

## Section 5: Full Pipeline Test — Teleoperation + Recording (DO)

### Test teleoperation first
```bash
python -m lerobot.teleoperate \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACMX \
  --robot.id=follower \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACMY \
  --teleop.id=leader
```

### Test recording with cameras
```bash
python -m lerobot.record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACMX \
  --robot.id=follower \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACMY \
  --teleop.id=leader \
  --cameras.top.type=opencv \
  --cameras.top.index=X \
  --cameras.top.width=640 \
  --cameras.top.height=480 \
  --cameras.top.fps=30 \
  --cameras.front.type=opencv \
  --cameras.front.index=Y \
  --cameras.front.width=640 \
  --cameras.front.height=480 \
  --cameras.front.fps=30 \
  --dataset.repo_id=fay/jetson-test \
  --dataset.num_episodes=1 \
  --dataset.episode_time_s=30
```

### Checkpoint
- [ ] Teleoperation works on Jetson (follower mirrors leader)
- [ ] Recording completes with camera feeds
- [ ] Dataset saved successfully

## Section 6: Troubleshooting Reference (TEACH)

### Common issues when moving to Jetson
- **Permission denied on /dev/ttyACM***: Run `sudo chmod 666 /dev/ttyACM*`
- **Wrong port assignment**: Unplug one arm, check which `/dev/ttyACM*` disappears
- **JointOutOfRangeError**: Usually a loose 3-pin cable, not calibration
- **Camera not found**: Check `ls /dev/video*`, try different indices
- **Rerun visualization**: Won't work headless over SSH — use `--display.type=cv2` or skip display

---

## Session Complete When
- Both arms connected and calibrated on Jetson
- Teleoperation verified on Jetson
- Test recording with cameras completed on Jetson
- Hardware state doc updated with Jetson port info
