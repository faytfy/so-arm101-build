# SO-ARM101: Learning Physics AI with an AI Tutor

A 5-day hands-on course in robotics AI — from a box of servo motors to autonomous pick-and-place — designed and taught entirely by a foundation model (Claude).

## The Result

https://github.com/user-attachments/assets/autonomous_pick_and_place.mp4

**80% success rate** on autonomous evaluation runs. The robot picks up a toy shark and places it in a green cup — no human control, just a trained neural network reading cameras and sending motor commands at 30Hz.

## What This Is

I'm not a robotics engineer. I work in developer experience and wanted to understand what AI-assisted learning feels like from the inside. I prompted Claude to design a structured course tailored to my level, and this repo is the result — every session guide, handout, troubleshooting log, and evaluation result from the 5-day build.

**The prompt that started it all:**

> "As an experienced physics AI developer, given that we have all the material in place for the SO-101 from LeRobot, please design a 5-day course to educate me the foundation of physics AI while tying that knowledge to the process of building the robot from scratch to inference/evaluation. Please make it an interactive session, and make sure each session can fit into one context window. Structure this folder to help track progress and log everything you need to move forward without me reminding you. Be professional, make your words easy to understand, and concise."

## The Journey

| Day | Sessions | What Happened |
|-----|----------|---------------|
| 1 | 1.1–1.3 | Environment setup, servo motor concepts, assembled both arms |
| 2 | 2.1–2.3 | Calibration, first teleoperation — follower mirrors leader |
| 3 | 3.1–3.3 | Jetson AGX Orin setup, cameras, full pipeline on edge hardware |
| 4 | 4.1–4.3 | Recorded 50 demonstrations, trained ACT policy (100K steps, 5h) |
| 5 | 5.1–5.3 | Autonomous inference, evaluation (80% success), advanced topics |

## Hardware

- **Robot:** SO-ARM101 (leader + follower arms) from the [LeRobot ecosystem](https://github.com/huggingface/lerobot)
- **Motors:** 12x STS3215 Feetech servos (12V high-torque follower, 7.4V leader)
- **Inference:** NVIDIA Jetson AGX Orin (64GB)
- **Training:** Desktop PC with NVIDIA RTX 5060 Ti
- **Cameras:** 2x USB webcams (top + front, 640x480 @ 30fps)

## Software Stack

- [LeRobot](https://github.com/huggingface/lerobot) 0.5.1 — full-stack robotics framework
- [ACT](https://tonyzhaozh.github.io/aloha/) (Action Chunking with Transformers) — the policy architecture
- PyTorch 2.6.0 (Jetson, built from source) / 2.7.0 (PC)
- Python 3.12, conda (miniforge)

## Repo Structure

```
docs/
  session_X_Y.md          # Session guides (teach + do sections)
  handouts/               # Study materials from each session
  COURSE_PROGRESS.md      # Full session log with details
  HARDWARE_STATE.md       # Hardware specs and status
  TROUBLESHOOTING.md      # Issues encountered and solutions
  evaluation_plan.md      # Evaluation framework and scoring
  linkedin_post_draft.md  # Post about the learning experience
scripts/
  run_inference.py        # Autonomous inference with video recording
media/
  autonomous_pick_and_place.mp4  # Best evaluation run
```

## Key Learnings

**On AI-assisted learning:**
- Role-playing in prompts genuinely changes the quality of AI tutoring
- Structured documentation that persists across conversations is essential for multi-session projects
- The AI handles concepts well; the real friction is in toolchains and hardware

**On robotics AI:**
- 50 consistent demonstrations were enough for 80% success with ACT
- Step-by-step evaluation (reach/grasp/transport/place) makes failures actionable
- Environment setup (camera position, mounting stability) matters as much as model quality
- Edge deployment (Jetson) requires building frameworks from source — pre-built packages often lack the right GPU support

**On developer experience:**
- The gap between "I want a robot that does X" and "I have X" is shrinking but the toolchain friction is real
- Things that break: GPU kernel compatibility, CLI argument changes between versions, headless SSH vs interactive tools

## Evaluation Results (100K Checkpoint)

| Episode | Reach | Grasp | Transport | Place | Success |
|---------|-------|-------|-----------|-------|---------|
| 1 | 1 | 1 | 1 | 1 | 1 |
| 2 | 1 | 1 | 1 | 1 | 1 |
| 3 | 1 | 1 | 0 | 0 | 0 |
| 4 | 1 | 1 | 1 | 1 | 1 |
| 5 | 1 | 1 | 1 | 1 | 1 |

**Overall: 4/5 (80%)** | Reach 100% | Grasp 100% | Transport 80% | Place 80%

## License

MIT — do whatever you want with this. If it helps you learn, that's the point.
