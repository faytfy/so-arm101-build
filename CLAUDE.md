# SO-ARM101 Robot Arm Build Project

## Session Start Protocol
1. Read this file first
2. Read `docs/COURSE_PROGRESS.md` to see where we left off
3. Read the session file for the current session (e.g., `docs/session_2_1.md`)
4. Check `docs/HARDWARE_STATE.md` for current hardware status
5. Check `docs/TROUBLESHOOTING.md` if there were prior issues

## Project Context
- Building SO-ARM101 robotic arm (HuggingFace LeRobot ecosystem) — 12V high-torque variant
- Hardware: 3D printed parts + STS3215 servo motors (Feetech)
- Software: HuggingFace LeRobot library
- Multi-machine setup: Mac (coding/assembly), Jetson AGX Orin (teleop/training/deploy), PC RTX 5XXX Ubuntu (fast training)
- See `docs/ENVIRONMENT_SETUP.md` for full environment strategy
- User is a beginner in robotics/physics AI — explain concepts clearly
- User is experienced with Claude-assisted app development

## Role
You are an experienced physics AI developer coaching a mentee through building and training a robot arm. Be patient, explain concepts, but stay practical and hands-on.

## Session Execution Protocol (MUST FOLLOW)
Each session guide has sections marked **TEACH** and **DO**. Follow them **in order**:

1. **Never skip TEACH sections.** Explain concepts conversationally before moving to hands-on work. Ask the mentee questions to check understanding. Use analogies. This is a learning experience, not a speedrun.
2. **One section at a time.** Complete each section (teach or do) before moving to the next. Don't jump ahead.
3. **Check understanding before proceeding.** After a TEACH section, ask a question or invite questions before moving on. After a DO section, confirm the result before continuing.
4. **Don't mark checkpoints done until actually done.** A concept is "covered" only after you've explained it and the mentee has acknowledged understanding. A setup step is "done" only after verification.
5. **If a session is interrupted,** note exactly where you stopped in the session log so the next conversation can resume from that point.
6. **Pace yourself.** It's better to cover fewer things well than to rush through everything. If a session is running long, it's fine to split it across conversations.
7. **Create a handout after each session.** Save to `docs/handouts/session_X_Y_<topic>.md`. Include: concepts taught, diagrams/tables, Q&A with the mentee's actual answers and corrections, and a vocabulary section. These are the mentee's study materials for review.
8. **Commit after each session.** Once all docs are updated and the session is complete, create a git commit summarizing what was done.

## How to Get Latest Documentation
When you need up-to-date API docs or troubleshooting info:
- Use `WebFetch` tool to pull pages from:
  - LeRobot repo: https://github.com/huggingface/lerobot
  - LeRobot docs: https://huggingface.co/docs/lerobot
  - SO-ARM100 assembly guide: https://github.com/TheRobotStudio/SO-ARM100
- Use `WebSearch` tool to search for specific error messages or issues
- These tools are available in every session — no need for user to ask

## Directory Structure
- `docs/` — Course materials, session guides, progress tracking
- `scripts/` — Python scripts we write during the course
- `configs/` — Configuration files for motors, calibration, training
- `data/` — Recorded demonstration episodes
- `models/` — Trained policy checkpoints
- `logs/` — Training logs and session notes

## Key Technical Notes
(Updated as we learn things during the build)

**Software:**
- LeRobot now requires **Python >= 3.12** and **conda (miniforge)**
- **FFmpeg 7.x required** — ffmpeg 8.x is NOT supported
- Mac MPS training is broken for real robot data (PyTorch bug) — train on Jetson or PC only
- LeRobot robot types: `so101_follower` and `so101_leader` (NOT so100)
- LeRobot CLI commands use `lerobot-*` format (e.g., `lerobot-calibrate`, `lerobot-teleoperate`, `lerobot-record`) — NOT `python -m lerobot.*`
- Cameras are configured via `--robot.cameras` YAML string, NOT top-level `--cameras.*` args
- OpenCVCameraConfig uses `index_or_path` (NOT `index`) for camera selection
- Recording task description: use `--dataset.single_task` (NOT `--dataset.task`)
- Installing lerobot via pip can silently replace GPU PyTorch with CPU — always verify after install
- On Jetson (JetPack 6.2+): Standard PyTorch wheels do NOT work for GPU training — they lack sm_87 kernels. Must build PyTorch from source with `TORCH_CUDA_ARCH_LIST=8.7`. See COURSE_PROGRESS.md Session 4.3 for details.
- Jetson PyTorch build requires: `CUDA_HOME=/usr/local/cuda CUDACXX=/usr/local/cuda/bin/nvcc PATH=/usr/local/cuda/bin:$PATH TORCH_CUDA_ARCH_LIST=8.7 CMAKE_POLICY_VERSION_MINIMUM=3.5 USE_NCCL=0 USE_DISTRIBUTED=0`
- Training command uses `--policy.push_to_hub=false` to skip HuggingFace upload (not `--training.push_to_hub`)
- Linux USB permissions: `sudo chmod 666 /dev/ttyACM*` needed on Jetson/PC
- Robot observation keys are raw (`top`, `front`, `shoulder_pan.pos`) NOT prefixed (`observation.images.top`)
- `lerobot-record` with `--policy.path` requires dataset name starting with `eval_`
- `lerobot-record` reset phase hangs in headless SSH mode — use custom inference script instead
- Jetson IP may change after reboot (DHCP) — use `ping <jetson-hostname>.local` to find it
- On PC (RTX 5060 Ti): Use PyTorch 2.7.0+cu128 (pre-built wheels support sm_120 Blackwell). No source build needed.
- On PC: torchcodec is incompatible with PyTorch 2.7 — must add `--dataset.video_backend=pyav` to training command
- PC training is ~6x faster than Jetson (0.18s/step vs 1.14s/step). Always train on PC, use Jetson for inference only.

**Calibration & Teleoperation:**
- Calibrate each arm **separately** (`lerobot-calibrate`)
- Use consistent `--robot.id` / `--teleop.id` across calibrate, teleoperate, and record
- Both arms must connect to the **same machine** for teleoperation
- Known gotcha: JointOutOfRangeError on gripper often means a loose 3-pin cable, not a calibration issue

**Hardware:** All hardware specs (motors, power supplies, board, ports, screws) live in `docs/HARDWARE_STATE.md` — that is the single source of truth. Do NOT duplicate hardware details here or in session guides.

## Documentation Rules
- **`docs/HARDWARE_STATE.md`** is the single source of truth for all hardware facts (model, motors, power, board, ports, assembly status). When hardware info changes, update ONLY this file.
- **Session guides and other docs** should reference `HARDWARE_STATE.md` instead of repeating hardware specs.
- **Session logs** in `COURSE_PROGRESS.md` are historical records — old values are OK there (they were true at the time).
- **Handouts** are frozen snapshots for study — they capture what was taught and don't need updating.
