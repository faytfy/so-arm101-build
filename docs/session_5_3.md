# Session 5.3: Advanced Topics & What's Next

## Goal
Explore what's beyond ACT — other policy types, faster training on the PC, and the broader landscape of robot learning.

## Prerequisites
- Sessions 5.1 and 5.2 complete
- Working trained policy (even if imperfect)

---

## Section 1: Other Policy Architectures (TEACH)

### Diffusion Policy
- **How it works:** Instead of directly predicting actions, it starts with random noise and iteratively "denoises" it into a clean action trajectory — inspired by image generation (Stable Diffusion, DALL-E)
- **Pros:** Handles multimodal action distributions better (when there are genuinely multiple good ways to do a task), often smoother trajectories
- **Cons:** Slower inference (~10Hz vs ACT's ~30Hz) because denoising takes multiple passes
- **When to use:** Complex tasks with multiple valid strategies, or when ACT gives jerky results
- **In LeRobot:** `--policy.type=diffusion`

### VLA Models (Vision-Language-Action)
- **How they work:** Large pretrained vision-language models (like GPT-4V) fine-tuned to output robot actions. You can give them natural language instructions: "pick up the red cup"
- **Examples:** OpenVLA, RT-2, pi0
- **Pros:** Language-conditioned (one model, many tasks), leverage massive pretrained knowledge
- **Cons:** Very large (7B+ parameters), need powerful GPU, still early-stage for real hardware
- **The future:** This is where the field is heading — foundation models for robotics

### Comparison table
| | ACT | Diffusion | VLA |
|---|---|---|---|
| Speed | ~30Hz | ~10Hz | ~5Hz |
| Model size | ~50M params | ~100M params | 7B+ params |
| Training data needed | 50+ episodes | 50+ episodes | Pretrained + fine-tune |
| Language control | No | No | Yes |
| Best for | Fast, consistent tasks | Complex, multimodal tasks | Multi-task, language-guided |
| Jetson-friendly | Yes | Marginal | No (need big GPU) |

## Section 2: Faster Training on PC (TEACH)

### Why use the PC (RTX 5060)
- Dedicated VRAM vs Jetson's shared memory → faster memory bandwidth
- Can train ~3-5x faster than Jetson for the same model
- Useful for longer training runs or larger models (Diffusion Policy)

### Workflow
1. Copy dataset from Jetson to PC: `scp -r fay@192.168.5.196:~/.cache/huggingface/lerobot/fay/shark-to-cup ~/data/`
2. Install LeRobot on PC (same conda setup as Jetson)
3. Train on PC with `--policy.device=cuda`
4. Copy trained checkpoint back to Jetson for inference
5. Run inference on Jetson (where the arms are connected)

### The training-inference split
- **Train where you have the best GPU** (PC)
- **Run inference where the robot is** (Jetson)
- This is the standard workflow in robotics labs

## Section 3: The Bigger Picture (TEACH)

### Sim-to-real transfer
- Train in simulation (Isaac Sim, MuJoCo, etc.) → transfer to real robot
- Advantage: unlimited free data, no wear on hardware
- Challenge: the "reality gap" — simulated physics never perfectly matches the real world
- LeRobot has simulation environments for experimentation

### Multi-task learning
- Instead of one policy per task, train a single policy on multiple tasks
- Language-conditioned models make this natural: "pick up the shark", "stack the blocks"
- Requires much more data but produces more capable robots

### The LeRobot ecosystem
- Active open-source community on HuggingFace
- Shared datasets and pretrained models on the Hub
- New robot hardware support being added regularly
- Discord community for help and sharing results

### Where to go from here
1. **New tasks:** Try different objects, more complex sequences (stack, sort, pour)
2. **Diffusion Policy:** Train one on the same dataset, compare to ACT
3. **PC training pipeline:** Set up the RTX 5060 for faster iteration
4. **Sim exploration:** Try LeRobot's simulation environments
5. **Community:** Share your results, try other people's datasets
6. **VLA models:** When you're ready for the frontier — fine-tune OpenVLA

---

## Section 4: Course Wrap-up (DO)

### Reflect on the journey
- Day 1: Boxes of parts → assembled robot arms
- Day 2: Calibration → first teleoperation
- Day 3: Jetson setup → full pipeline on edge hardware
- Day 4: Data collection → training launched
- Day 5: Autonomous robot → iteration → understanding the landscape

### What you've learned
- Servo motors, kinematics, hardware assembly
- Motor bus communication and calibration
- Imitation learning and the data pipeline
- ACT policy architecture
- Edge AI deployment (Jetson, building from source)
- The full teleop → train → deploy loop

### LinkedIn post
- Draft and share your post with video from Session 5.1
- Tag: #LeRobot #HuggingFace #RobotLearning #PhysicsAI

### Checkpoint
- [ ] Explored at least one advanced topic
- [ ] Discussed next steps and future directions
- [ ] LinkedIn post drafted/shared
- [ ] Course complete! 🎉

---

## Session Complete When
- Advanced topics discussed
- Future learning path identified
- LinkedIn post ready
- Celebration earned
