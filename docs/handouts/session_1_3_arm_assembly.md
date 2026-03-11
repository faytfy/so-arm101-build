# Session 1.3 Handout: Full Arm Build

## Concepts Covered

### 1. Kinematic Chains
- A robot arm is a **kinematic chain**: rigid links connected by rotating joints
- Each joint = 1 degree of freedom (DOF) = 1 axis of rotation
- **6 DOF is the minimum** to reach any position AND orientation in 3D space
- Joint order matters — each joint moves everything above it:

| Joint | Name | What moves |
|---|---|---|
| 1 | Shoulder Pan | Entire arm |
| 2 | Shoulder Lift | Upper arm + everything above |
| 3 | Elbow Flex | Forearm + wrist + gripper |
| 4 | Wrist Flex | Wrist + gripper |
| 5 | Wrist Roll | Gripper rotation |
| 6 | Gripper | Fingers only |

- **Workspace** = the set of all positions the gripper can reach (dome shape)
- Base joints carry the most weight → need the most torque

### 2. Rigid Mounting
- Any wobble at the base gets **amplified** at the gripper tip (lever arm effect)
- 1mm of play at base = several mm of error at gripper
- Inconsistent base movement → inconsistent training data → bad AI policy
- Industrial robots are bolted to concrete; our desk clamps are fine for learning
- **If you get inconsistent results, check the base first**

### 3. Cable Routing & Reliability
- Daisy chain: cables carry both data AND power to all downstream motors
- A break at Joint N kills motors N+1 through 6
- Cables flex at every moving joint → risk of disconnect or snagging
- SO-ARM101 cable clips prevent this (improvement over SO-ARM100)
- Cable disconnect during recording = ruined episode, start over

## Q&A

**Q: Why does Joint 1 need the strongest motor even though the gripper does the "work"?**
A (Fay): "Because it is a support which stabilizes the movement."
Expanded: Joint 1 must rotate the weight of the entire arm (all 5 other motors + all links + payload). The further the weight from the pivot, the more torque needed. That's why base joints are heavy-duty and the tip is kept light.

**Q: What happens if the base is sitting loose on the desk?**
A (Fay): "It will deviate a lot and won't be able to accurately pick the item at the right place or place the item at the right place."
Correct! And worse — the error would be *different every time* because the base shifts differently with each movement, making AI training data inconsistent.

**Q: Why is a cable disconnect at Joint 2 worse than at Joint 5?**
A (Fay): "Because disconnecting at Joint 2 means disconnect to the rest of the joints, whereas if we disconnect from Joint 5 we only lose 5 and 6."
Exactly right — daisy chain tradeoff: simple wiring, but no redundancy.

## Vocabulary
- **Kinematic chain** — series of rigid links connected by joints
- **Degree of freedom (DOF)** — one independent axis of motion (rotation or translation)
- **Workspace** — all positions reachable by the end effector (gripper)
- **Torque** — rotational force (reviewed from session 1.2)
- **Lever arm effect** — small errors at a pivot point amplify with distance
- **Daisy chain** — serial connection where each device links to the next (reviewed from session 1.2)
- **Cable routing** — deliberate path planning for wires through a mechanism
