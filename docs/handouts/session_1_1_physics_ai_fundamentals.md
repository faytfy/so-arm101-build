# Session 1.1 Handout: Physics AI Fundamentals

> Coach: Claude (Physics AI Developer)
> Mentee: Fay
> Date: 2025-03-09

---

## 1. What is Physics AI?

### Core Concept

Traditional AI (LLMs, image generators, code assistants) operates entirely in the **digital world** — data in, data out. Physics AI breaks out of that loop into the **physical world** — sensor data in, motor movements out.

### Why the physical world is harder than the digital world

| Challenge | Digital AI | Physics AI |
|-----------|-----------|------------|
| State space | Discrete tokens (finite vocabulary) | Continuous angles/positions (infinite) |
| Reversibility | Delete and retry | Break something and it's broken |
| Timing | Seconds to respond is fine | Milliseconds matter |
| Environment | Deterministic data | Gravity, friction, inertia, collisions |

### Three approaches to robot control

| Approach | How it works | Pros | Cons |
|----------|-------------|------|------|
| **Classical control** | Hand-write rules: "if angle > X, apply torque Y" | Precise, predictable | Brittle, can't adapt to change |
| **Reinforcement learning** | Robot tries random things, gets rewards for success | Can exceed human performance | Needs millions of attempts, hard to define rewards, sim-to-real gap |
| **Imitation learning** | Human demonstrates, robot learns to reproduce | Practical, leverages human skill, no reward design needed | Limited by demonstration quality |

**Our approach: Imitation learning** — the most practical for individual builders.

### Q&A

**Q: When you use Claude to help you code, what does the AI actually interact with?**

> *Fay: It interacts with me providing input using a prompt. Then Claude invokes coding skill or coding agent to help me code. And it's in the cloud so I need internet to connect to it.*

Key insight: The entire loop is digital — text in, text out, all in the cloud. Physics AI replaces that with sensors in, motor movements out, in the real world.

**Q: Why is imitation learning a particularly good fit for a small team or individual builder?**

> *Fay: Imitation learning can leverage the natural tool we have — human hands. Classical control is more challenging as it has specific specs that we need to record or document, and it might make sense for a factory setting which needs very precise specs to make sure there are less defects in manufacturing. Reinforcement learning will require setting up a reward model and can be more dynamic. But I guess our learning can start from simple then move toward there if we want to perform something more complicated.*

Correct on all three points. Additional nuance:
- Classical control works when the environment is perfectly controlled (factory conveyor belt) but can't adapt
- RL needs millions of attempts — impractical on real hardware, and designing reward functions is surprisingly hard
- Imitation learning transfers **existing human skill** to the robot — you already know how to pick things up, you just need to transfer that knowledge
- Advanced systems combine approaches: imitation learning for a baseline, then RL to fine-tune beyond human-level

---

## 2. The SO-ARM101 System

### Core Concept

A 6-DOF (degrees of freedom) robotic arm. Each DOF = one joint = one servo motor.

### Joint mapping to human arm

| Joint | What it does | Human equivalent |
|-------|-------------|-----------------|
| 1 - Shoulder Pan | Rotates whole arm left/right | Turning your shoulder |
| 2 - Shoulder Lift | Raises/lowers upper arm | Lifting your arm up |
| 3 - Elbow Flex | Bends the forearm | Bending your elbow |
| 4 - Wrist Flex | Tilts hand up/down | Flexing your wrist |
| 5 - Wrist Roll | Rotates the hand | Turning a doorknob |
| 6 - Gripper | Opens/closes fingers | Grabbing something |

### Two-arm system

| | Leader Arm | Follower Arm |
|---|-----------|-------------|
| Purpose | Human input device | The actual robot |
| Motors | Gears removed (passive) | Gears intact (powered) |
| What it does | Reads your hand position | Mirrors your movements |
| Power | 5V (just for electronics) | 12V (drives motors under load) |

**Why two arms?** The simplest way to record demonstrations. Your hand movements on the leader are captured as joint angles and replayed on the follower.

### Q&A

**Q: Given that the leader arm only reads your hand position, why do we need motors in the leader at all? Why not simple angle sensors?**

> *Fay: Is it easier to imitate with a physical object?*

Partially right (ergonomics matter), but the main reason is practical: the STS3215 servo has a **position encoder built in**. The motor, gearbox, and position sensor are one integrated package. Using separate angle sensors would mean sourcing, mounting, wiring, and coding for a different component. By using the same servo hardware in both arms, we get the same wiring, same software, same communication protocol — just in a different mode.

---

## 3. How Robot Learning Works

### The full pipeline

```
Stage 1: TELEOPERATE     You move leader arm → follower mirrors you
              ↓
Stage 2: RECORD           Camera frames + joint positions saved as an "episode"
              ↓
Stage 3: DATASET          Repeat 50+ times with slight variations
              ↓
Stage 4: TRAIN            Neural network (policy) learns: observation → action
              ↓
Stage 5: INFERENCE        Policy runs autonomously at ~30Hz
                          Camera → Policy → Motor commands → Move → repeat
```

### What the policy learns

- **Input:** Camera image + current joint positions (observation)
- **Output:** Next joint positions to move to (action)
- **Architecture:** ACT (Action Chunking with Transformers) — predicts the next ~100 timesteps at once for smoother motion
- **Training:** Minimizes the difference between predicted actions and your actual demonstrated actions (standard loss function)

### Why 50+ demonstrations?

1 demonstration = memorization of a single trajectory. If the cube moves 2cm, the robot misses.

50+ demonstrations with variation = **generalization**. The policy learns "when I see a cube, move toward it" rather than "replay this exact sequence of positions."

Same principle as LLM training: diverse data teaches understanding, not memorization.

### Q&A

**Q: Why do we need 50+ demonstrations instead of just one perfect one?**

> *Fay: The robot needs to continuously learn through each demonstration to update the parameter. It's like there is a loss function. Each demonstration gives it new input with slight difference so the robot can pick the same stuff up no matter where I place it.*

Correct on both points:
1. **Loss function:** Policy predicts joint positions → compares against your actual actions → adjusts parameters to minimize the error. Standard supervised learning.
2. **Generalization through variation:** Many episodes with the cube in different positions teach the relationship between visual input and motor output, not just a fixed trajectory. This is exactly analogous to why LLMs need diverse training data.

---

## 4. LeRobot Framework

### Core Concept

LeRobot is HuggingFace's **open-source full-stack robotics framework**. It handles every stage from motor control to policy deployment — like a full-stack web framework, but for robotics.

### Pipeline tools

| Pipeline Stage | LeRobot Tool | What it does |
|---|---|---|
| Hardware setup | `lerobot-find-port` | Discovers USB-connected motor board |
| Hardware setup | `lerobot-setup-motors` | Programs unique IDs onto each servo |
| Calibration | `lerobot-calibrate` | Maps each joint's physical range of motion |
| Teleoperation | `lerobot-teleoperate` | Runs leader → follower mirroring |
| Recording | `lerobot-record` | Teleoperation + saves data as episodes |
| Training | `lerobot-train` | Trains a policy on recorded data |
| Inference | `lerobot-eval` | Runs trained policy autonomously |

### What it replaces

Without LeRobot, you'd need to build from scratch:
- Serial communication driver for Feetech motors
- Real-time control loop for teleoperation
- Camera + joint data synchronization and recording
- Dataset formatting
- ACT model implementation in PyTorch
- Inference loop

### Q&A

**Q: How would you describe LeRobot in one sentence?**

> *Fay: LeRobot is like a container which is an environment set up ready for you to start training the robot arm.*

Good instinct on "pre-packaged environment." Refined analogy: LeRobot is more like a **full-stack framework** (React + Express + ORM + deployment, but for robotics) than a container (which is more about isolation). It's a coherent set of tools where each one feeds into the next, covering the entire pipeline from "motors plugged in" to "robot acting autonomously."

**One-liner:** *"LeRobot is an open-source full-stack robotics framework by HuggingFace that handles everything from motor control to AI policy training."*

---

## Key Vocabulary

| Term | Definition |
|------|-----------|
| **DOF** | Degree of freedom — one independent axis of movement |
| **Servo motor** | Motor + gearbox + position encoder + controller in one package |
| **Teleoperation** | Human controls robot remotely (via leader arm in our case) |
| **Episode** | One complete recorded demonstration of a task |
| **Policy** | Neural network that maps observations to actions |
| **ACT** | Action Chunking with Transformers — predicts chunks of future actions |
| **Inference** | Running a trained policy to control the robot autonomously |
| **Imitation learning** | Training a policy from human demonstrations |
| **Daisy chain** | Motors connected in series, sharing one data bus |
| **MPS** | Metal Performance Shaders — Apple Silicon GPU for PyTorch (broken for robot training) |

---

## Environment Quick Reference

```bash
# Activate environment
conda activate lerobot

# Verify setup
python -c "import lerobot; print(lerobot.__version__)"  # 0.5.1
python -c "import torch; print(torch.backends.mps.is_available())"  # True
ffmpeg -encoders | grep svtav1  # should show libsvtav1
```

### Multi-machine setup
| Machine | Role |
|---------|------|
| Mac | Coding, project management, assembly, early motor work |
| Jetson AGX Orin | Robot hub — teleop, data collection, training, deployment |
| PC (RTX 5XXX, Ubuntu) | Fast training (10-50x faster than Jetson) |

**Do NOT train on Mac** — MPS has a gradient explosion bug on real robot data (PyTorch Issue #1066, closed as NOT_PLANNED).
