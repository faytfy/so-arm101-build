# Session 2.2: Connect to Motors, Test & Calibrate Both Arms

## Prerequisites
- Both arms assembled and desk-mounted (Session 1.3)
- Motor IDs programmed (Session 1.2)
- LeRobot installed with Feetech support (Session 1.1)
- See `HARDWARE_STATE.md` for ports and motor details

## Goals
- Understand what calibration is and why it matters
- Verify motor communication on both arms
- Calibrate both follower and leader arms
- Verify calibration by running teleoperation

---

## Section 1: Why Calibration Matters **[TEACH]**

### The Problem
- Each servo motor has a raw encoder position (0–4095 for STS3215, one full rotation)
- But "position 2048" on one motor doesn't mean the same physical angle as "position 2048" on another
- Manufacturing variance, assembly angle, and gear alignment all introduce offsets
- Without calibration, the leader and follower won't agree on what "straight ahead" means

### What Calibration Does
1. **Sets the midpoint (homing offset):** You move the arm to the middle of its range → the software records "this raw position = center"
2. **Records range of motion:** You sweep each joint through its full range → the software records min/max positions
3. **Result:** A mapping from raw encoder values → standardized joint angles that are consistent across arms and even across different robots

### Why This Matters for AI
- Teleoperation: leader and follower must agree on positions for mirroring to work
- Training: neural networks learn from standardized joint values, not raw encoder ticks
- Transfer: a policy trained on one robot can work on another if both are calibrated the same way

### Calibration File
- Saved as JSON in `~/.cache/huggingface/lerobot/calibration/`
- Contains per-joint: `homing_offset`, `range_min`, `range_max`
- Tied to the arm's `id` — use consistent IDs across all commands

---

## Section 2: Verify Motor Communication **[DO]**

### Step 1: Verify ports
Ports can change between sessions. Always check first:
```bash
conda activate lerobot
lerobot-find-port
```
Compare with ports in `HARDWARE_STATE.md`. Update if changed.

### Step 2: Quick connection test
We'll verify both boards can talk to their motors by running calibration (it connects and reads all 6 motors on startup).

---

## Section 3: Calibrate the Follower Arm **[DO]**

### Command
```bash
lerobot-calibrate \
    --robot.type=so101_follower \
    --robot.port=PORT_HERE \
    --robot.id=follower
```

### Physical Steps
1. **Midpoint:** When prompted, move all joints to the middle of their range and press ENTER
   - Shoulder pan: centered (not rotated left or right)
   - Shoulder lift: roughly 45° from vertical
   - Elbow: roughly 90°
   - Wrist flex: centered
   - Wrist roll: centered
   - Gripper: half open
2. **Range of motion:** When prompted, slowly move each joint (one at a time) through its full range while the software records. Do NOT move wrist_roll (it's 360° and hardcoded). Press ENTER when done.

### Important Notes
- Torque is disabled during calibration — the arm will go limp. Support it so it doesn't fall.
- The arm should be powered (12V for follower).

---

## Section 4: Calibrate the Leader Arm **[DO]**

### Command
```bash
lerobot-calibrate \
    --teleop.type=so101_leader \
    --teleop.port=PORT_HERE \
    --teleop.id=leader
```

### Physical Steps
Same two-step process as the follower. The leader is passive (no torque motors), so it will already be limp — just position it and sweep the joints.

---

## Section 5: Verify Calibration — First Teleoperation **[DO]**

### Command
```bash
lerobot-teleoperate \
    --robot.type=so101_follower \
    --robot.port=FOLLOWER_PORT \
    --robot.id=follower \
    --teleop.type=so101_leader \
    --teleop.port=LEADER_PORT \
    --teleop.id=leader
```

### What to Check
- [ ] Follower mirrors leader movements in real-time
- [ ] All 6 joints respond correctly (no reversed directions)
- [ ] Gripper opens/closes correctly
- [ ] No JointOutOfRangeError (if you get one on gripper, check the 3-pin cable)
- [ ] Movements are smooth, not jerky

### Checkpoint
- [ ] Follower calibrated and JSON saved
- [ ] Leader calibrated and JSON saved
- [ ] Teleoperation working — follower mirrors leader
- [ ] `HARDWARE_STATE.md` updated with calibration status

---

## Troubleshooting
- **Port not found:** Unplug/replug USB, run `lerobot-find-port` again
- **Motor not responding:** Check daisy chain cable connections, verify power is on
- **JointOutOfRangeError on gripper:** Likely a loose 3-pin cable — reseat the gripper motor's cable
- **Reversed joint:** Re-calibrate, ensuring the midpoint position is correct
- **"Already calibrated" prompt:** Type `c` + ENTER to re-run calibration
