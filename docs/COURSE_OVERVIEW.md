# SO-ARM101 Build Course — 5 Days, 15 Sessions

## What You're Building
The SO-ARM101 is an open-source robotic arm designed by TheRobotStudio, integrated
with HuggingFace's LeRobot framework. You'll build TWO arms:
- **Follower arm** — the robot that performs tasks autonomously
- **Leader arm** — the one YOU move by hand to teach the robot

You'll teach the robot to perform tasks (like picking up objects) by demonstrating
them yourself, then training an AI policy that lets the robot replicate your movements.

## How Each Session Works
- Each session is designed to fit within one Claude conversation
- At the end of each session, we update COURSE_PROGRESS.md and HARDWARE_STATE.md
- When you start a new conversation, Claude reads these files and picks up where we left off
- No context is lost between sessions

## How Claude Gets Latest Docs
Claude Code has two tools for fetching live information:
- **WebFetch** — pulls a specific URL (e.g., GitHub README, API docs)
- **WebSearch** — searches the web for answers to specific questions

These are used automatically when needed. For example:
- Before installing LeRobot, Claude will fetch the latest install instructions
- If a motor won't respond, Claude will search for that specific error
- If an API has changed, Claude will pull the current docs

You don't need to ask Claude to do this — the CLAUDE.md file instructs every
session to check docs proactively when working with external libraries.

---

## Day 1: Foundation & Hardware Assembly
**Goal:** Understand the system, set up your dev environment, assemble the follower arm.

### Session 1.1: Environment Setup & Core Concepts (~45 min)
- What is "physics AI" and how robot learning works
- The LeRobot ecosystem: what it does, why it matters
- Install Python (via pyenv or miniconda), create virtual environment
- Verify your Mac is ready for the project
- Inventory your hardware parts

### Session 1.2: Hardware Assembly — Servos & Base (~60 min)
- How servo motors work (STS3215 protocol, bus communication)
- Set motor IDs using the Feetech debug tool or script
- Assemble the base and first joints of the follower arm
- Wire servos to the bus board

### Session 1.3: Hardware Assembly — Complete Follower Arm (~60 min)
- Complete follower arm assembly (upper arm, wrist, gripper)
- Route cables cleanly
- Physical inspection and range-of-motion check
- Document final hardware state

---

## Day 2: Software & First Connection
**Goal:** Install LeRobot, talk to the motors, calibrate the arm.

### Session 2.1: Install LeRobot & Dependencies (~45 min)
- Clone and install HuggingFace LeRobot
- Install system dependencies (cmake, etc.)
- Understand the LeRobot project structure
- Run a simple test to verify installation

### Session 2.2: Connect to Motors & Test Servos (~45 min)
- Find your USB serial port
- Scan the servo bus — detect all motors
- Send commands to individual motors (move, read position)
- Understand position, speed, torque concepts
- Write a simple test script

### Session 2.3: Calibrate the Arm (~45 min)
- What calibration does and why it matters
- Run the LeRobot calibration procedure
- Save calibration data
- Test calibrated movements
- Verify full range of motion

---

## Day 3: Teleoperation
**Goal:** Build the leader arm, set up teleoperation, practice demonstrations.

### Session 3.1: Build the Leader Arm (~60 min)
- Key differences: leader arm has no motor torque (passive)
- Assemble the leader arm hardware
- Set motor IDs for leader (different from follower)
- Wire and connect the leader arm

### Session 3.2: Teleoperation Setup & First Movements (~45 min)
- Calibrate the leader arm
- Configure teleoperation in LeRobot
- First teleoperation test: move leader, follower mirrors
- Troubleshoot any lag or tracking issues

### Session 3.3: Practice Teleoperation Tasks (~45 min)
- Design a simple task (e.g., pick up a cube, stack blocks)
- Practice smooth, consistent demonstrations
- Tips for good demonstration quality
- Set up camera(s) for data recording

---

## Day 4: Data Collection & Policy Training
**Goal:** Record demonstrations, understand AI policies, train your first model.

### Session 4.1: Understanding AI Policies & Data Collection (~45 min)
- What is imitation learning? (learning from demonstrations)
- ACT (Action Chunking with Transformers) — how it works conceptually
- What data the robot needs: joint positions + camera images
- Data format and storage in LeRobot

### Session 4.2: Record Demonstration Episodes (~45 min)
- Set up the recording pipeline
- Record 20-50 episodes of your task
- Review recorded data quality
- Visualize episodes to check for issues

### Session 4.3: Train Your First Policy (~45 min)
- Configure training parameters
- Launch training (will run for hours — start and monitor)
- Understand training metrics (loss curves)
- While training runs: review what the model is learning

---

## Day 5: Deployment & Beyond
**Goal:** Run your trained policy, iterate, and learn what's next.

### Session 5.1: Run Trained Policy on the Arm (~45 min)
- Load the trained checkpoint
- Run autonomous execution
- Observe and evaluate performance
- Compare to your demonstrations

### Session 5.2: Iterate, Debug & Improve (~45 min)
- Common failure modes and how to fix them
- Collect more data for weak spots
- Fine-tune or retrain
- Camera placement and lighting considerations

### Session 5.3: Advanced Topics & What's Next (~45 min)
- Other policy architectures (Diffusion Policy, VQ-BeT)
- Sim-to-real transfer
- Multi-task learning
- Community resources and projects
- Your roadmap for continued learning

---

## Prerequisites Checklist
- [x] Mac with Apple Silicon (confirmed: arm64)
- [x] SO-ARM101 hardware kit — see `docs/HARDWARE_STATE.md` for full inventory and specs
- [ ] Webcam or phone camera for recording (needed Day 3+)
- [ ] Small objects for tasks — blocks, cups, etc. (needed Day 3+)
