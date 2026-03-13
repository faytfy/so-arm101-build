# Session 5.1: Run Trained Policy on the Arm

## Goal
Deploy the trained ACT policy and watch the robot perform the shark-to-cup task autonomously for the first time.

## Prerequisites
- Session 4.3 complete (trained ACT checkpoint)
- Both arms connected to Jetson
- Workspace set up: shark on blue tape, green cup in position
- Camera positions unchanged from recording

---

## Section 1: What Happens During Inference? (TEACH)

### Concepts
- **Inference loop:** The policy runs at ~30Hz, continuously:
  1. Reads current joint angles from the follower arm
  2. Captures camera frames (front + top)
  3. Feeds observations into the trained neural network
  4. Gets predicted action chunk (next ~100 timesteps of joint angles)
  5. Sends the first few actions to the follower motors
  6. Repeats with fresh observations
- **Action chunking at inference:** The policy predicts 100 future actions but only executes a few before re-predicting — this creates smooth, responsive motion
- **Temporal ensembling:** Overlapping action chunks are blended together for even smoother trajectories
- **Why the leader arm stays connected:** LeRobot expects the full robot config. The leader arm is read but not used during inference — it just needs to be plugged in
- **Environment must match training:** Same camera positions, same lighting, same workspace layout. The policy learned to associate specific visual patterns with actions

### Key differences from teleoperation
| | Teleoperation | Inference |
|---|---|---|
| Control source | Your hand on the leader | Neural network predictions |
| Speed | Your reaction time | 30Hz compute cycle |
| Adaptability | You can improvise | Policy only does what it learned |
| Camera role | Recording for dataset | Live input to policy |

## Section 2: Pre-flight Checks (DO)

### Verify the checkpoint exists
```bash
ls outputs/train/act_shark_to_cup/checkpoints/
```
Should see checkpoint directories (e.g., `last/pretrained_model/`).

### Verify hardware
```bash
# USB permissions
sudo chmod 666 /dev/ttyACM*

# Check both arms respond
python3 -c "from lerobot.common.robot_devices.motors.feetech import FeetechMotorsBus; bus = FeetechMotorsBus(port='/dev/ttyACM0', motors={'test': [1, 'sts3215']}); bus.connect(); print('Follower OK'); bus.disconnect()"
```

### Set up workspace
- [ ] Shark on blue tape starting position
- [ ] Green cup taped down in position
- [ ] Cameras in same positions as during recording
- [ ] Nothing blocking the arm's path
- [ ] Stand clear of the arm's range of motion

## Section 3: Run Inference (DO)

### The command
```bash
lerobot-infer \
  --policy.path=outputs/train/act_shark_to_cup/checkpoints/last/pretrained_model \
  --robot.type=so101 \
  --robot.cameras='[{type: opencv, key: top, index_or_path: 2, width: 640, height: 480, fps: 30}, {type: opencv, key: front, index_or_path: 0, width: 640, height: 480, fps: 30}]' \
  --teleop.type=so101_leader
```

> **Note:** The exact command may need adjustment based on LeRobot version. Check `lerobot-infer --help` if errors occur.

### What to watch for
- The arm should move to roughly the starting position
- It should reach for the shark, grasp it, lift, and place it in the cup
- Motion should be smooth (thanks to action chunking)
- The whole sequence should take roughly the same time as your demonstrations (~5-15s)

### Capture video!
- Film with your phone from a good angle
- Record multiple runs — some will work better than others
- A side-by-side with teleoperation would be great for the LinkedIn post

### Checkpoint
- [ ] Policy loaded successfully
- [ ] Arm moves autonomously
- [ ] Task completed (shark in cup)
- [ ] Video captured for LinkedIn post

## Section 4: Evaluate Performance (TEACH)

### Success criteria
- **Full success:** Shark picked up and placed in cup
- **Partial success:** Shark picked up but dropped/missed cup
- **Failure:** Arm doesn't reach shark, or grasps air

### Common failure modes and causes
| Failure | Likely cause | Fix |
|---|---|---|
| Arm doesn't move to shark | Camera position changed | Re-match camera positions to recording |
| Grips but drops | Inconsistent grip in training data | Record more episodes with consistent grip |
| Misses the cup | Cup position shifted | Put cup back in exact training position |
| Jerky motion | Not enough training steps | Train longer or check loss curve |
| Arm moves but does wrong thing entirely | Too few episodes or too inconsistent | Record more consistent episodes |

### The 80/20 rule of robot learning
- First 50 episodes get you ~80% of the way
- The remaining 20% (reliable, every-time success) takes much more effort: more data, better consistency, hyperparameter tuning
- For a first project, partial success is a genuine achievement

---

## Session Complete When
- Policy runs on the robot
- At least one successful (or partially successful) autonomous run
- Video captured
- Performance evaluated and failure modes identified (if any)
- Ready for iteration in Session 5.2
