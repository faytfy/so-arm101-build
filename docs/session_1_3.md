# Session 1.3: Hardware Assembly — Full Arm Build

## Session Goals
1. Understand the mechanical structure and how joints create movement
2. Understand why rigid mounting matters for robot arms
3. Assemble both follower and leader arms
4. Mount arms to desk

---

## TEACH: Kinematic Chains — How Joints Create Movement

**Key points to cover:**
- A robot arm is a "kinematic chain" — a series of rigid links connected by joints
- Each joint adds one degree of freedom (DOF) — one axis of rotation
- The SO-ARM101 has 6 joints = 6 DOF, which is the minimum needed to reach any position AND orientation in 3D space
- Joint order matters — each joint's movement affects everything above it:
  - Joint 1 (Shoulder Pan): rotates the entire arm left/right
  - Joint 2 (Shoulder Lift): tilts the whole arm up/down
  - Joint 3 (Elbow Flex): bends the forearm
  - Joint 4 (Wrist Flex): tilts the gripper up/down
  - Joint 5 (Wrist Roll): rotates the gripper
  - Joint 6 (Gripper): open/close
- The "workspace" is the set of all positions the gripper can reach — it's roughly a dome shape in front of the arm
- Joints at the base carry more load (supporting the whole arm) — that's why Joint 1 and 2 need higher torque

**Check understanding:** Ask why Joint 1 (base) needs to be the strongest motor, even though the gripper is the one doing the "work."

- [x] Concept covered and understood

---

## TEACH: Rigid Mounting — Why Stability Matters

**Key points to cover:**
- A robot arm only works precisely if its base doesn't move
- Any wobble in the base gets amplified at the gripper end (lever arm effect)
  - Example: 1mm of play at the base = several mm of error at the gripper tip
- This is why we clamp the base firmly to the desk — not just set it down
- For the leader arm, wobble is less critical (it's just reading positions) but still annoying
- For the follower arm, wobble directly affects task success — especially for precise tasks
- In industrial settings, robot arms are bolted to concrete floors or heavy steel tables
- Our desk clamps are fine for learning, but worth knowing the principle

**Check understanding:** Ask what would happen to pick-and-place accuracy if the base was sitting loose on the desk.

- [x] Concept covered and understood

---

## TEACH: Cable Routing & Reliability

**Key points to cover:**
- The daisy chain cables carry both data AND power to all motors
- If any cable disconnects, every motor downstream goes offline
- Cables pass through moving joints — they flex every time the arm moves
- Common failure point: cables snagging or pulling loose at joints (especially joint 3/elbow on older SO-100)
- SO-ARM101 improvement: cable clips that hold wires in place and prevent disconnection
- Good cable routing = reliable robot. Bad routing = random disconnects during operation
- During teleoperation and recording, a cable disconnect ruins the episode and you have to start over

**Check understanding:** Ask why a cable disconnecting at Joint 2 is worse than one disconnecting at Joint 5.

- [x] Concept covered and understood

---

## DO: Assemble Follower Arm

Following the assembly guide from TheRobotStudio/SO-ARM100 GitHub:
- Install motors in order: Joint 1 (base) through Joint 6 (gripper)
- Each motor gets: motor horns (geared on output side, smooth on bottom), M2x6mm mounting screws, structural M3x6mm screws
- Daisy-chain 3-pin cables as you go
- Route cables through cable clips

- [x] Follower arm fully assembled

---

## DO: Assemble Leader Arm

Same process as follower. Leader uses 7.4V motors with mixed gear ratios.

- [x] Leader arm fully assembled

---

## DO: Mount Arms to Desk

- Use 3D-printed desk clamps (2 per arm)
- Thread 3D-printed thumbscrews to tighten against desk
- Verify arms are stable and don't wobble

- [x] Both arms mounted securely

---

## Session Completion Checklist
- [x] TEACH: Kinematic chains — covered and understood
- [x] TEACH: Rigid mounting — covered and understood
- [x] TEACH: Cable routing — covered and understood
- [x] DO: Follower arm assembled
- [x] DO: Leader arm assembled
- [x] DO: Both arms mounted to desk
- [x] COURSE_PROGRESS.md updated
