# Bonus Handout: Edge AI Landscape & Where Robotics Fits

## What Is a Raspberry Pi?

A **tiny, cheap ($35-80) single-board computer** about the size of a credit card. It runs Linux and has USB ports, GPIO pins, and HDMI out.

### Common Uses
- **Industry:** visual quality inspection on factory lines, predictive maintenance on machinery, digital signage, people counting in retail, self-service kiosks, automated greenhouse control
- **Personal:** home security cameras, Pi-hole (network ad blocker), retro gaming (RetroPie), NAS/file server, Home Assistant (smart home hub), OctoPrint (3D printer control), weather stations, learning Linux

### Why Companies Choose Pi
- **Cost:** 100 Pis at $80 = $8K vs 100 Jetsons at $2K = $200K
- **Power:** draws ~5W, runs on a USB power bank
- **"Good enough" AI:** if all you need is "is this screw missing: yes/no?", you don't need a GPU

### Pi vs Jetson Comparison

| | Raspberry Pi 5 | Jetson AGX Orin |
|---|---|---|
| **Price** | ~$80 | ~$2,000 |
| **GPU** | None (tiny integrated graphics) | 2048 CUDA cores |
| **RAM** | 4-8 GB | 64 GB unified |
| **AI capability** | Can *run* tiny pre-trained models | Can *train and run* large models |
| **Use case** | "Is there a cat in this photo?" | "Watch 50 demos, learn to pick up a shark" |

---

## ModelNova Fusion Studio (by embedUR Systems)

A desktop IDE for **perception-class edge AI** (image classification, object detection, small LLMs). It bundles the full pipeline: dataset capture/annotation, model selection, training, quantization, and deployment.

### What It Solves
- Fragmented toolchains (claims to cut 8-12 week workflow to 2-3 weeks)
- Cloud dependency (everything runs locally)
- Model-to-device gap (packages deployable binaries for target hardware)

### Supported Hardware
- Raspberry Pi 4 and 5
- Arm Ethos-U85/U55 NPUs
- Alif Semiconductor boards
- CEVA NeuPro NPU family
- **NOT supported:** NVIDIA Jetson, CUDA-based platforms

### Why It Doesn't Help Our Project
1. **Wrong hardware ecosystem** — targets Arm MCUs/MPUs, not Jetson/CUDA
2. **Wrong AI category** — handles perception models, not robotics/imitation learning
3. **Wouldn't bypass our GPU issue** — the sm_87 CUDA kernel problem is at the PyTorch/hardware layer, below where any IDE operates

---

## Edge AI: Perception vs Physics AI

### Perception AI (where tools like Fusion Studio work)
- **Input:** camera image (standardized)
- **Output:** label ("cat") or bounding box
- **Hardware:** mostly standard (Pi, MCU, any camera)
- **Testing:** run on test images
- **Failure mode:** wrong label — no physical consequence
- **Dataset:** download ImageNet or capture images

### Physics AI / Robotics (where we are)
- **Input:** cameras + joint angles + force sensors (varies per robot)
- **Output:** continuous motor commands at 30Hz
- **Hardware:** every robot is different (DOF, motors, kinematics)
- **Testing:** must test in physical world or expensive simulation
- **Failure mode:** robot crashes into table, breaks itself
- **Dataset:** physically teleoperate for hours

**Key insight:** Robotics can't be abstracted away from hardware the way image classification can. A cat classifier works the same on any device, but a pick-and-place policy trained on our SO-ARM101 won't transfer to a different arm without significant work.

---

## The Physics AI Tool Landscape (No "Fusion Studio" Equivalent Yet)

### LeRobot (what we're using)
- **What it is:** open-source Python **software framework** by HuggingFace
- **Covers:** motor control, teleoperation, data recording, policy training (ACT, Diffusion), inference deployment
- **Supports:** SO-ARM100/101, Koch v1.1, ViperX/WidowX, Aloha (dual-arm), LeKiwi (mobile), and more
- **Limitation:** CLI-only, no GUI, you handle hardware setup yourself
- **Analogy:** the early Linux of robotics AI — powerful but hands-on

### LeRobot as a Software Framework
LeRobot is purely software — no hardware included. Similar to how:
- **React** = framework for web UIs (you bring your own server)
- **Unity** = framework for games (you bring your own art)
- **LeRobot** = framework for teaching robots (you bring your own robot)

What LeRobot provides:

| Layer | What you get |
|---|---|
| Motor drivers | Code to talk to servos (Feetech, Dynamixel) over serial |
| Calibration | Standardize joint values across robots |
| Teleoperation | Leader-follower mirroring logic |
| Data recording | Capture joints + camera in HuggingFace dataset format |
| Policies | ACT, Diffusion Policy, VLA architectures |
| Training loop | PyTorch training with logging, checkpoints, config |
| Inference | Load model, run on live robot at 30Hz |

**HuggingFace's bet:** standardize the software pipeline so datasets, policies, and benchmarks can be shared across the community — even though hardware varies.

### NVIDIA Isaac (Lab / Sim / ROS)
- **Isaac Sim:** simulate robots in virtual worlds, generate synthetic training data
- **Isaac Lab:** train policies in simulation (reinforcement learning focus)
- **Isaac ROS:** deploy on Jetson with optimized inference
- Enterprise-grade, steep learning curve, heavy hardware requirements

### Google DeepMind Open X-Embodiment / RT-X
- Cross-robot dataset + foundation models trained on many robots
- Goal: train once, deploy on any arm
- Research-stage, not a downloadable product yet

### Emerging Companies
- **Physical Intelligence (pi.ai)** — general-purpose robot foundation models
- **Covariant** (acquired by Amazon) — warehouse manipulation
- **Skild AI** — universal robot foundation model

---

## What the Dream "Fusion Studio for Robotics" Would Need

1. **Sim-to-real pipeline** — design tasks in simulation, auto-generate data, fine-tune on a few real demos
2. **Cross-robot deployment** — train a policy, export to different arm hardware
3. **Integrated dataset tools** — record, annotate, filter, augment demonstrations in one place
4. **One-click training** — pick ACT vs diffusion vs VLA, auto-tune hyperparameters
5. **Safety-aware deployment** — force limits, collision detection, graceful failure

This doesn't exist yet. Give it 2-3 years.

---

## Two Trends to Watch

1. **Vision-Language-Action (VLA) models** — like RT-2, OpenVLA, pi0. Foundation models for robotics: train on many robots, fine-tune on yours. (Covered in Session 5.3)
2. **Sim-to-real transfer** — train in simulation (free, unlimited data), transfer to real robot. NVIDIA Isaac leads here.

---

## Q&A From This Session

**Q: Would ModelNova Fusion Studio help with our project?**
A: No — it targets a completely different segment (perception models on Arm MCUs). It doesn't support Jetson, doesn't handle robotics/imitation learning, and wouldn't bypass our CUDA kernel compatibility issues anyway.

**Q: Would we still encounter the GPU issue even with tools like Fusion Studio?**
A: Yes — the sm_87 kernel issue is at the PyTorch/CUDA hardware layer, below where any IDE tool operates. Any tool that needs GPU compute on Jetson Orin would hit the same problem.

**Q: What is a Raspberry Pi?**
A: A cheap ($35-80) credit-card-sized computer. Great for simple tasks (IoT, basic AI inference, home automation) but far too weak for training or running robotics policies like our 52M parameter ACT model.

**Q: Does LeRobot support hardware beyond arms?**
A: Yes — arms (SO-ARM101, Koch, ViperX, Aloha), mobile manipulators (LeKiwi, Moss), and the community is experimenting with quadrupeds. Any robot that can report joint positions and accept target positions can plug in.

**Q: Is LeRobot a software framework?**
A: Yes — it's a Python library providing the full pipeline from motor control to policy deployment. You bring your own hardware. HuggingFace's strategy is to standardize the software so the community can share datasets, policies, and benchmarks.

---

## Vocabulary

| Term | Definition |
|---|---|
| **Raspberry Pi** | Cheap single-board computer (~$80), runs Linux, used for IoT/simple AI inference |
| **Edge AI** | Running AI models on local devices (not cloud) — covers everything from Pi to Jetson |
| **Perception AI** | AI that interprets sensor data (classify images, detect objects) — no physical action |
| **Physics AI** | AI that controls physical systems (robots, vehicles) — outputs motor commands |
| **Fusion Studio** | ModelNova's IDE for perception-class edge AI on Arm MCUs/MPUs |
| **Quantization** | Compressing a model (e.g., 32-bit to 8-bit weights) so it runs on weaker hardware |
| **NPU** | Neural Processing Unit — dedicated chip for AI inference (like Arm Ethos) |
| **Sim-to-real** | Training a policy in simulation, then transferring it to a physical robot |
| **VLA** | Vision-Language-Action model — foundation model that combines seeing, understanding language, and acting |
| **Software framework** | A library/toolkit that provides structure and tools for building applications (LeRobot for robotics, React for web, Unity for games) |
