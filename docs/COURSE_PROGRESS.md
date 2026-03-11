# Course Progress Tracker

## Current Status: IN PROGRESS
## Current Session: 2.2 (completed) → ready for 2.3

---

## Day 1: Foundation & Hardware Assembly
- [x] Session 1.1: Environment Setup & Concepts
- [x] Session 1.2: Hardware Assembly — Servos & Wiring
- [x] Session 1.3: Hardware Assembly — Full Arm Build

## Day 2: Calibration & First Movements
- [x] Session 2.1: Install LeRobot & Dependencies (pulled forward to 1.1)
- [x] Session 2.2: Connect to Motors, Test & Calibrate Both Arms
- [ ] Session 2.3: First Teleoperation on Mac

## Day 3: Jetson Setup & Camera
- [ ] Session 3.1: Jetson AGX Orin Environment Setup
- [ ] Session 3.2: Camera Setup & Recording Test
- [ ] Session 3.3: Transfer Arms to Jetson & Verify Full Pipeline

## Day 4: Data Collection & Policy Training
- [ ] Session 4.1: Understanding AI Policies & Data Collection
- [ ] Session 4.2: Record Demonstration Episodes
- [ ] Session 4.3: Train Your First Policy (ACT) on Jetson or PC

## Day 5: Deployment & Next Steps
- [ ] Session 5.1: Run Trained Policy on the Arm
- [ ] Session 5.2: Iterate, Debug & Improve
- [ ] Session 5.3: Advanced Topics (Diffusion Policy, VLA Models, PC Training)

---

## Session Log
### Session 1.1 — 2026-03-09
**DO (completed first — out of order):**
- Installed miniforge, conda env `lerobot` with Python 3.12.13
- Installed FFmpeg 7.1.1, PyTorch 2.10.0 (MPS), NumPy, cmake
- Installed LeRobot 0.5.1 from source with Feetech support (pulled forward from 2.1)
- Researched community environments → `docs/ENVIRONMENT_SETUP.md`
- Sorted 3D parts and motors (pulled forward from 1.2)

**TEACH (completed second — after course structure fix):**
- Physics AI vs traditional AI: continuous, unforgiving, timing-critical physical world
- SO-ARM101: 6-DOF, leader (passive input) + follower (powered output)
- Imitation learning pipeline: teleop → record → train policy → autonomous inference
- LeRobot: full-stack robotics framework (motor control → training → eval)

**Process improvement:** Added Session Execution Protocol to CLAUDE.md — TEACH before DO, check understanding, don't skip sections.

### Session 1.2 — 2026-03-09
**TEACH (all 3 sections completed in order):**
- How servo motors work: DC motor + gearbox + encoder + controller, smart serial commands
- Torque explained: rotational force, gear ratios trade speed for strength
- Bus communication & daisy chain: shared wire, unique IDs, collision if IDs duplicate
- Leader vs follower: follower does work (needs torque), leader is input device (gears removed)
- Driver board: USB-to-serial translator, each arm gets its own board, computer coordinates both
- VR teleoperation discussed (Meta Quest as alternative to leader arm)

**DO:**
- Confirmed model is SO-ARM101 (not SO-ARM100) — updated all docs and LeRobot commands (so101_follower/so101_leader)
- Board: Seeed Studio Bus Servo Driver Board for XIAO V1.0 — works via USB out of the box, no jumper needed
- Power connection: DC pigtail cable (barrel jack to bare wires) into green screw terminal
- Power supplies: 12V/5A (follower), 5V (leader) — labeled
- Programmed all 6 follower motor IDs (C047, 12V, 1:345)
- Programmed all 6 leader motor IDs (C046 x3, C044 x2, C001 x1 — mixed ratios)
- Board ports: follower=/dev/tty.usbmodem5AAF2626601, leader=/dev/tty.usbmodem5AAF2625931

**Handout:** `docs/handouts/session_1_2_servos_and_wiring.md`

### Session 1.3 — 2026-03-10
**DO (completed first — out of order again):**
- Assembled follower arm (6 motors, all joints)
- Assembled leader arm (6 motors, all joints)
- Mounted both arms to desk using 3D-printed clamps with thumbscrews

**TEACH (completed after assembly):**
- Kinematic chains: 6 joints = 6 DOF, each joint moves everything above it, base carries most load
- Rigid mounting: base wobble amplifies at gripper tip, clamping removes variable for consistent AI training
- Cable routing: daisy chain means a break kills all downstream motors, SO-ARM101 cable clips prevent snagging

**Handout:** `docs/handouts/session_1_3_arm_assembly.md`

### Session 2.2 — 2026-03-10
**TEACH:**
- Why calibration matters: raw encoder values differ per motor due to assembly variance
- Two-step calibration: homing offset (midpoint) + range of motion recording
- Calibration creates a shared coordinate system so leader and follower speak the same language
- Calibration files saved as JSON, tied to arm ID — must use consistent IDs across all commands
- Standardized values enable AI policy transfer between robots

**DO:**
- Verified ports unchanged: follower=/dev/tty.usbmodem5AAF2626601, leader=/dev/tty.usbmodem5AAF2625931
- Calibrated follower arm (id=follower) — saved successfully
- Calibrated leader arm (id=leader) — first attempt failed with negative range_min on elbow_flex (-153 ValueError), resolved by repositioning elbow midpoint
- Hit ConnectionError on follower motor 5 (wrist_roll) during re-calibration — resolved by reseating cable
- Ran first teleoperation — follower mirrors leader smoothly on all joints
- AVFFrameReceiver duplicate class warnings noted as harmless (OpenCV + PyAV bundling same FFmpeg lib)

**Handout:** `docs/handouts/session_2_2_calibration.md`
