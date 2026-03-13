# Session 5.1 Handout: Running Trained Policy on the Robot

## Concepts

### The Inference Loop (~30Hz)
1. **Read** current joint angles from follower arm
2. **Capture** camera frames (front + top)
3. **Feed** observations into the ACT neural network
4. **Get** predicted action chunk (~100 future timesteps)
5. **Send** first few actions to motors
6. **Repeat** with fresh observations

### Action Chunking at Inference
- The model predicts 100 steps ahead but only executes a few before re-predicting
- This means constant course-correction based on what the robot actually sees
- Result: smooth, adaptive motion (unlike single-step prediction which is jerky)

### Temporal Ensembling
- Overlapping action chunks are blended together
- Prevents jerky transitions at chunk boundaries

### Teleoperation vs Inference

| | Teleoperation | Inference |
|---|---|---|
| Control source | Your hand on the leader | Neural network |
| Speed | Your reaction time | 30Hz compute cycle |
| Adaptability | You can improvise | Only does what it learned |
| Camera role | Recording for dataset | Live input to policy |

### Environment Must Match Training
- Same camera positions, lighting, workspace layout
- The policy learned specific visual patterns, not abstract concepts
- Moving the cup 6 inches = the arm will still place where the cup *used to be*

## Q&A

**Q: Why predict 100 actions but only execute a few?**
A: Continuous course-correction. The robot keeps checking "where am I, what do I see?" and adjusts. This makes ACT smoother than single-step approaches (jerky) or full-trajectory planning (can't recover from drift).

**Q: What happens if the cup moves?**
A: The arm would likely still reach toward the original position — the model doesn't understand "cup" as a concept. It learned a visual pattern and associated motor movements.

## Technical Notes

### Running Inference on SO-ARM101
- Use custom `run_inference.py` script (based on LeRobot ACT tutorial)
- Key imports: `ACTPolicy`, `SO101Follower`, `build_inference_frame`, `make_robot_action`
- Camera observation keys from robot are `top`/`front` (NOT `observation.images.top`)
- `lerobot-record --policy.path` works but reset phase hangs in headless SSH mode
- Gripper motor (ID 6) throws overload error on disconnect — harmless, catch with try/except

### Pre-flight Checklist
- [ ] Checkpoint copied to Jetson
- [ ] `sudo chmod 666 /dev/ttyACM*` (after every reboot)
- [ ] Both cameras connected and at correct indices
- [ ] Workspace matches training: shark on blue tape, cup taped down, cameras in position
- [ ] Stand clear of arm's range of motion

### Jetson IP
- Can change after reboot (DHCP)
- Find via: `ping fay-desktop.local` (mDNS) or ARP table scan

## Evaluation Results

**Checkpoint:** 100K (final) | **Loss:** 0.045 | **Date:** 2026-03-13

| Episode | Reach | Grasp | Transport | Place | Success | Note |
|---------|-------|-------|-----------|-------|---------|------|
| 1 | 1 | 1 | 1 | 1 | 1 | |
| 2 | 1 | 1 | 1 | 1 | 1 | |
| 3 | 1 | 1 | 0 | 0 | 0 | DROP_LIFT |
| 4 | 1 | 1 | 1 | 1 | 1 | |
| 5 | 1 | 1 | 1 | 1 | 1 | |

**Overall: 4/5 = 80%** | Reach 100% | Grasp 100% | Transport 80% | Place 80%

## Vocabulary
- **Inference:** Running a trained model to make predictions (as opposed to training)
- **Action chunk:** A sequence of predicted future actions (ACT predicts ~100 at once)
- **Temporal ensembling:** Blending overlapping action chunks for smooth motion
- **Pre/post processor:** Normalizes observations before the model and denormalizes actions after
- **Headless mode:** Running without a display (SSH) — cameras still work, just no preview
