# Course Progress Tracker

## Current Status: IN PROGRESS
## Current Session: 4.2

---

## Day 1: Foundation & Hardware Assembly
- [x] Session 1.1: Environment Setup & Concepts
- [x] Session 1.2: Hardware Assembly — Servos & Wiring
- [x] Session 1.3: Hardware Assembly — Full Arm Build

## Day 2: Calibration & First Movements
- [x] Session 2.1: Install LeRobot & Dependencies (pulled forward to 1.1)
- [x] Session 2.2: Connect to Motors, Test & Calibrate Both Arms
- [x] Session 2.3: First Teleoperation on Mac (merged into 2.2 — teleoperation verified there)

## Day 3: Jetson Setup & Camera
- [x] Session 3.1: Jetson AGX Orin Environment Setup
- [x] Session 3.2: Camera Setup & Recording Test
- [x] Session 3.3: Transfer Arms to Jetson & Verify Full Pipeline

## Day 4: Data Collection & Policy Training
- [x] Session 4.1: Understanding AI Policies & Data Collection
- [x] Session 4.2: Record Demonstration Episodes
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

### Session 3.1 — 2026-03-11
**TEACH:**
- Why we move from Mac to Jetson: CUDA GPU for training, USB latency for real-time control, unified pipeline
- Mac MPS vs NVIDIA CUDA: MPS is incomplete/buggy for robotics ML, CUDA is the standard
- Jetson architecture: ARM + NVIDIA GPU, 64GB unified memory (CPU+GPU share RAM pool), JetPack = batteries-included Linux
- Unified memory tradeoff: bigger models fit (64GB shared) but slower bandwidth than dedicated VRAM

**DO:**
- Found Jetson IP (192.168.5.190), set up SSH key auth from Mac
- Installed miniforge, created `lerobot` conda env with Python 3.12.13
- Installed PyTorch 2.10.0+cu126 — discovery: official PyTorch CUDA wheels now work on Jetson aarch64 (no NVIDIA-specific wheels needed)
- Installed FFmpeg 7.1.1 via conda
- Installed LeRobot 0.5.1 from source with Feetech support
- Verified full stack: CUDA available, GPU = "Orin"

**Handout:** `docs/handouts/session_3_1_jetson_setup.md`

### Session 3.2 — 2026-03-12
**TEACH:**
- Why cameras matter: joint angles alone lack visual context — policy needs to *see* the environment
- Camera frames are observation features: recorded alongside joints, used for training, fed live during inference
- Camera naming must be consistent between recording and inference
- Placement: two cameras (front + top) is the sweet spot, must be fixed in place
- Resolution: 640x480 @ 30fps is standard — higher resolution wastes compute, gets downscaled anyway

**DO:**
- Detected 4 cameras via `lerobot-find-cameras opencv` — indices 0-3
- Identified: index 0 = Lenovo 500 FHD (top), index 1 = Logitech VU0029 (front), index 2 = MacBook FaceTime, index 3 = blank/virtual
- Tested both cameras with teleoperation — feeds visible in rerun, teleoperation smooth
- Completed 2-episode test recording (`fay/test-recording`, task: "Pick up object")
- 1800 frames per episode (60s × 30fps), both camera streams encoded as AV1
- Dataset saved to `~/.cache/huggingface/lerobot/fay/test-recording`

**Handout:** `docs/handouts/session_3_2_camera_setup.md`

### Session 3.3 — 2026-03-12
**TEACH:**
- Why move to Jetson: CUDA for training, lower USB latency, single-machine pipeline
- What changes (USB port names, camera indices, permissions) vs what stays the same (commands, motor IDs, wiring)

**DO:**
- Physically transferred both arms and cameras from Mac to Jetson
- USB detection: follower=/dev/ttyACM0, leader=/dev/ttyACM1
- Set Linux USB permissions (`sudo chmod 666 /dev/ttyACM*`)
- Calibrated both arms on Jetson (follower id=follower, leader id=leader)
- Camera discovery: /dev/video0 = Logitech (front), /dev/video2 = Lenovo (top), /dev/video4 = dead device
- Teleoperation verified on Jetson — follower mirrors leader
- Test recording completed: 1 episode, 30s, both cameras, AV1 encoding, dataset saved to `~/.cache/huggingface/lerobot/fay/jetson-test`
- Headless mode (SSH) — no display preview, but recording works fine
- Gripper motor overload error on disconnect — harmless

**Handout:** `docs/handouts/session_3_3_jetson_transfer.md`

### Session 4.1 — 2026-03-12
**TEACH:**
- What a policy is: neural network mapping observations (joint angles + camera frames) → actions (target joint angles), runs at ~30Hz
- Learned policies vs hard-coded rules: pattern matching generalizes, explicit rules are brittle
- Imitation learning: policy learns by watching expert demonstrations — paired observation/action data
- ACT architecture: action chunking (predict ~100 future actions at once) for smooth motion, Transformer-based, VAE for handling ambiguity
- Data quality: consistency is king — same strategy, smooth motion, delete bad episodes, 50+ episodes minimum

**DO:**
- Chose first task: pick up baby shark, place in green cup
- Set up workspace: blue tape start zone for shark, green cup taped down
- Practice teleoperation runs — consistent strategy confirmed, ~5s per pick-and-place
- Episode length set to 15s (with rest/hold padding)

**Handout:** `docs/handouts/session_4_1_policies_and_data.md`

### Session 4.2 — 2026-03-12
**DO:**
- Recorded 50 episodes of "Pick up the baby shark and place it in the green cup"
- Dataset: `fay/shark-to-cup` saved at `~/.cache/huggingface/lerobot/fay/shark-to-cup` on Jetson
- Episode length: 30s, reset time: 10s
- Camera config: top (index_or_path=2), front (index_or_path=0), 640x480@30fps
- Push to hub failed (not logged in) — data is safe locally
- Corrected CLI args: `--dataset.single_task` (not `--dataset.task`), `index_or_path` (not `index`)

### Session 4.3 — 2026-03-12 (IN PROGRESS)
**TEACH:**
- Training loop: batch → predict → compare (loss) → adjust weights → repeat
- Loss should decrease then plateau = model learned what it can
- ACT hyperparameters: batch_size=8, 100k steps, chunk_size=100
- Edge AI build problem: standard PyTorch wheels lack sm_87 kernels for Jetson Orin
- Building PyTorch from source with TORCH_CUDA_ARCH_LIST=8.7
- Top 3 Jetson pain points: framework compatibility, unified memory management, camera latency

**DO (in progress):**
- Training attempt #1 failed: `CUDA error: no kernel image is available for execution on the device`
- Root cause: PyTorch 2.10.0+cu126 wheels only include sm_80 and sm_90, Orin needs sm_87
- Building PyTorch v2.6.0 from source with TORCH_CUDA_ARCH_LIST=8.7 in tmux session `build` on Jetson
- Build fixes applied: added CUDACXX path, CMAKE_POLICY_VERSION_MINIMUM=3.5
- Build progress: ~45% (2679/5941 steps) as of last check, compiling CUDA kernels
- Build log: `/tmp/pytorch_build4.log` on Jetson
- **NEXT STEPS when build completes:**
  1. Find wheel in `/tmp/pytorch/dist/`
  2. `pip install /tmp/pytorch/dist/torch-*.whl`
  3. Verify: `python3 -c "import torch; x = torch.randn(2,2).cuda(); print(x @ x); print('GPU works!')"`
  4. Also install torchvision from source (needs matching torch)
  5. Re-run training: `lerobot-train --dataset.repo_id=fay/shark-to-cup --dataset.root=/home/fay/.cache/huggingface/lerobot/fay/shark-to-cup --policy.type=act --output_dir=outputs/train/act_shark_to_cup --job_name=act_shark_to_cup --policy.device=cuda --policy.push_to_hub=false`

**Handout:** `docs/handouts/bonus_edge_ai_build_process.md`
