# Session 1.1: Environment Setup & Core Concepts

## Session Goals
1. Understand what we're building and why
2. Learn core concepts: physics AI, servos, bus communication, imitation learning
3. Set up Python environment
4. Inventory hardware parts

---

## TEACH: What is "Physics AI"?

**Key points to cover:**
- Traditional AI operates in the digital world: text (LLMs), images (diffusion models), code (Copilot). The inputs and outputs are data.
- Physics AI operates in the physical world. The inputs are sensor data (cameras, joint encoders). The outputs are physical actions (motor movements).
- Why is the physical world harder?
  - It's continuous (infinite possible positions, not discrete tokens)
  - It's unforgiving (drop a glass, it breaks — no undo)
  - It has physics (gravity, friction, inertia, collisions)
  - Latency matters (react in milliseconds, not seconds)
- Our approach: **imitation learning** — we show the robot what to do by demonstration, then train a neural network to reproduce that behavior.

**Check understanding:** Ask the mentee to explain the difference between traditional AI and physics AI in their own words.

- [x] Concept covered and understood

---

## TEACH: The SO-ARM101 System

**Key points to cover:**
- 6-DOF (degrees of freedom) robotic arm — each DOF is one joint that can rotate
- Joint names (bottom to top): base rotation, shoulder, elbow, wrist flex, wrist rotation, gripper
- Analogy: think of your own arm — shoulder (2 joints), elbow (1), wrist (2), hand (1) = 6 DOF
- Each joint has one servo motor that either:
  - **Drives** the joint (follower arm — the robot)
  - **Reads position** of the joint (leader arm — you move it by hand)
- Two identical arms: leader (human-controlled input device) and follower (robot output)
- Why two arms? This is the simplest way to "record" demonstrations — your hand movements on the leader get mirrored and recorded on the follower

**Check understanding:** Ask which arm has powered motors and which is passive.

- [x] Concept covered and understood

---

## TEACH: How Robot Learning Works (High Level)

**Key points to cover — the full pipeline:**
1. **Teleoperation:** You move the leader arm → follower mirrors in real-time
2. **Recording:** Camera captures what the robot sees + joint encoders capture positions
3. **Dataset:** Many recorded episodes of the same task (e.g., "pick up cube and place in bin")
4. **Training:** A neural network (policy) learns the mapping: observation → action
   - Input: camera image + current joint positions
   - Output: next joint positions to move to
5. **Inference:** The trained policy runs on the robot — camera sees the scene, policy predicts the next move, motors execute it, repeat at ~30Hz
6. **The magic:** The policy generalizes — it can handle slightly different cube positions, lighting, etc.

**Analogy:** Like learning to cook by watching someone. You see what they see (camera), you learn what motions they make (joints), and eventually you can do it yourself even when the ingredients are in slightly different positions.

**Check understanding:** Ask what the inputs and outputs of the trained policy are.

- [x] Concept covered and understood

---

## TEACH: LeRobot Framework

**Key points to cover:**
- Open-source library by HuggingFace — same folks who make Transformers, Diffusers, etc.
- It handles the entire pipeline: motor control → teleoperation → data recording → training → evaluation
- Supports multiple robot platforms (SO-ARM101 is one of several)
- Built on PyTorch
- Key tools we'll use:
  - `lerobot-find-port` — discover USB-connected motor boards
  - `lerobot-setup-motors` — assign motor IDs
  - `lerobot-calibrate` — calibrate joint ranges
  - `lerobot-teleoperate` — run leader-follower teleoperation
  - `lerobot-record` — record demonstration episodes
  - `lerobot-train` — train a policy from recorded data
  - `lerobot-eval` — run a trained policy on the robot

**Check understanding:** Ask what LeRobot replaces — what would you have to build yourself without it?

- [x] Concept covered and understood

---

## DO: Set Up Python Environment

### 1. Install Miniforge (conda)
```bash
brew install miniforge
conda init zsh
```

### 2. Create lerobot environment with Python 3.12
```bash
conda create -y -n lerobot python=3.12
conda activate lerobot
```

### 3. Install FFmpeg (required by LeRobot, must have libsvtav1 encoder)
```bash
conda install ffmpeg=7.1.1 -c conda-forge
```

### 4. Install basic dependencies
```bash
pip install torch numpy cmake
```

### 5. Verify setup
```bash
python -c "import torch; print(f'PyTorch {torch.__version__}, MPS available: {torch.backends.mps.is_available()}')"
ffmpeg -encoders | grep svtav1
```

- [x] Python 3.12.13 installed and working
- [x] Conda environment `lerobot` created
- [x] FFmpeg 7.1.1 with libsvtav1
- [x] PyTorch 2.10.0 installed with MPS support

---

## DO: Install LeRobot

```bash
conda activate lerobot
cd ~/Desktop/robot
git clone https://github.com/huggingface/lerobot.git
cd lerobot
pip install -e ".[feetech]"
```

Verify:
```bash
python -c "import lerobot; print(f'LeRobot {lerobot.__version__}')"
which lerobot-find-port
```

- [x] LeRobot 0.5.1 installed from source
- [x] Feetech motor SDK installed
- [x] CLI tools available (lerobot-find-port, lerobot-setup-motors, etc.)

---

## Hardware Inventory (ALREADY COMPLETED in planning session)
See `docs/HARDWARE_STATE.md` for full inventory and specs.

---

## Session Completion Checklist
- [x] TEACH: Physics AI — covered and understood
- [x] TEACH: SO-ARM101 system — covered and understood
- [x] TEACH: How robot learning works — covered and understood
- [x] TEACH: LeRobot framework — covered and understood
- [x] DO: Python environment set up and verified
- [x] DO: LeRobot installed and verified
- [x] Hardware inventory confirmed
- [x] COURSE_PROGRESS.md updated
