# Session 3.2: Camera Setup & Recording Test

## Goals
- Understand why cameras matter for robot learning
- Get both USB cameras detected and working
- Test camera feeds with LeRobot
- Do a test recording (teleop + camera) to verify the full pipeline

## Prerequisites
- Session 3.1 complete (Jetson environment ready)
- Both arms assembled, calibrated, connected to Mac (will move to Jetson in 3.3)
- Two USB cameras: Lenovo 500 FHD, Logitech VU0029

---

## 1. Why Cameras Matter for Robot Learning **[TEACH]**

### What the robot "sees"
- In teleoperation-only mode, the robot records joint angles — but no visual context
- A trained policy needs to *see* the environment to make decisions (where is the object? where is the gripper?)
- Camera images become **observation features** — the policy's "eyes"

### How cameras fit into the pipeline
- During **recording**: camera frames are saved alongside joint positions at each timestep
- During **training**: the policy learns to map images → actions
- During **inference**: live camera feeds drive the policy's decisions
- Camera names (e.g., `front`, `top`) must be **consistent** between recording and inference

### Camera placement strategy
- Common setups: `front` (facing the workspace), `top` (bird's-eye), `side`, `wrist`
- More angles = more information, but also more data and slower training
- Two cameras is a sweet spot for most tasks
- Camera position must be **fixed** — if it moves between recording and inference, the policy breaks

### Resolution and frame rate tradeoffs
- Higher resolution = more detail but slower processing and bigger datasets
- 640x480 @ 30fps is the practical standard for training
- 1080p is overkill for most policies — pixels get downscaled during training anyway

**Check understanding before proceeding.**

---

## 2. Detect Your Cameras **[DO]**

### 2a. Plug in both cameras to the Mac

### 2b. Run camera detection
```bash
conda activate lerobot
lerobot-find-cameras opencv
```

### 2c. Note the camera indices
Record which index corresponds to which physical camera.
- Unplug one camera, re-run detection to confirm which is which
- On macOS, camera indices can change after reboot — we'll use stable paths on Jetson later

**Checkpoint:** Both cameras detected with indices identified.

---

## 3. Test Cameras with Teleoperation **[DO]**

### 3a. Run teleoperation with one camera
```bash
lerobot-teleoperate \
    --robot.type=so101_follower \
    --robot.port=/dev/tty.usbmodem5AAF2626601 \
    --robot.id=follower \
    --robot.cameras="{ front: {type: opencv, index_or_path: INDEX, width: 640, height: 480, fps: 30}}" \
    --teleop.type=so101_leader \
    --teleop.port=/dev/tty.usbmodem5AAF2625931 \
    --teleop.id=leader \
    --display_data=true
```
Replace `INDEX` with the actual camera index.

### 3b. Verify the feed
- A `rerun` visualization window should open showing the camera feed + joint data
- Check: is the image right-side-up? Is the frame rate smooth?
- If the image is rotated, we can add `rotation: 90` (or `180`, `-90`) to the camera config

### 3c. Add the second camera
```bash
lerobot-teleoperate \
    --robot.type=so101_follower \
    --robot.port=/dev/tty.usbmodem5AAF2626601 \
    --robot.id=follower \
    --robot.cameras="{ front: {type: opencv, index_or_path: INDEX1, width: 640, height: 480, fps: 30}, top: {type: opencv, index_or_path: INDEX2, width: 640, height: 480, fps: 30}}" \
    --teleop.type=so101_leader \
    --teleop.port=/dev/tty.usbmodem5AAF2625931 \
    --teleop.id=leader \
    --display_data=true
```

### 3d. Position the cameras
- Place one camera facing the workspace (`front`) — captures the object and gripper from the operator's perspective
- Place the other looking down at the workspace (`top`) — captures spatial layout
- Secure them so they won't move (tape, clamp, or weighted base)

**Checkpoint:** Both camera feeds visible in rerun, positioned and stable.

---

## 4. Test Recording **[DO]**

### 4a. Do a short test recording (2 episodes)
```bash
lerobot-record \
    --robot.type=so101_follower \
    --robot.port=/dev/tty.usbmodem5AAF2626601 \
    --robot.id=follower \
    --robot.cameras="{ front: {type: opencv, index_or_path: INDEX1, width: 640, height: 480, fps: 30}, top: {type: opencv, index_or_path: INDEX2, width: 640, height: 480, fps: 30}}" \
    --teleop.type=so101_leader \
    --teleop.port=/dev/tty.usbmodem5AAF2625931 \
    --teleop.id=leader \
    --display_data=true \
    --dataset.repo_id=fay/test-recording \
    --dataset.num_episodes=2 \
    --dataset.single_task="Pick up object" \
    --dataset.push_to_hub=false
```

### 4b. Verify the recording
- Check that episodes were saved (LeRobot will show the save path)
- Confirm the dataset includes both camera streams and joint data

**Checkpoint:** Test recording completed with both cameras. Pipeline verified.

---

## 5. Camera Troubleshooting

| Problem | Solution |
|---|---|
| Camera not detected | Try different USB port; check `System Information > USB` on Mac |
| Low frame rate | Add `fourcc: MJPG` to camera config; reduce resolution |
| Image upside down | Add `rotation: 180` to camera config |
| Image sideways | Add `rotation: 90` or `rotation: -90` |
| "Camera already in use" | Close other apps using the camera (Zoom, FaceTime, etc.) |
| Async read errors | Lower resolution or add `fourcc: MJPG` |

---

## Session Outputs
- [ ] Both cameras detected and indices recorded
- [ ] Camera feeds verified via teleoperation + rerun
- [ ] Cameras positioned and secured for workspace viewing
- [ ] Test recording completed with 2 episodes
- [ ] Hardware state updated with camera info
- [ ] Handout created
