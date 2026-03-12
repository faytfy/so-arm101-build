# Session 4.1: Understanding AI Policies & Data Collection

## Goal
Understand what a neural network policy is, how imitation learning works, what makes good training data, and plan a task for data collection.

## Prerequisites
- Session 3.3 complete (full pipeline verified on Jetson)
- Both arms + cameras connected to Jetson
- Test recording completed successfully

---

## Section 1: What Is a Policy? (TEACH)

### Concepts
- **Policy = the brain of the robot.** It's a function that takes in observations (joint positions, camera images) and outputs actions (target joint positions).
- **Traditional programming vs learned policies:**
  - Traditional: human writes `if object_at(x,y) → move_to(x,y) → close_gripper()` — brittle, can't handle variation
  - Learned: neural network figures out the mapping from seeing → doing, generalizes to new situations
- **Why neural networks?** They can process raw images and learn patterns humans couldn't hand-code
- **Policy as a mapping:** `observations → actions`
  - Input: current joint angles + camera frames
  - Output: next joint angles (what each motor should do next)
  - Runs in a loop at ~30Hz during inference

### Check understanding
- What are the inputs and outputs of a robot policy?
- Why is a learned policy better than hard-coded rules for manipulation?

## Section 2: Imitation Learning — Learning from Demonstration (TEACH)

### Concepts
- **Imitation learning = learning by watching an expert.** The "expert" is you, teleoperating the arm.
- **The training data:** Each demonstration episode records:
  - Joint angles of the follower arm (what the arm was doing) — at every timestep
  - Camera frames (what the arm was seeing) — at every timestep
  - These are paired: "when the scene looked like THIS, the arm was doing THAT"
- **How training works (high level):**
  1. Collect many demonstrations of the same task
  2. Feed observation→action pairs to a neural network
  3. Network learns patterns: "when I see a cube here, I should move the gripper there"
  4. At inference time, network sees live camera + joints → predicts what to do next
- **Analogy:** Like teaching someone to drive by sitting in the passenger seat while they watch you drive for 100 hours. They learn patterns — "red light → brake", "open road → stay in lane" — without being explicitly programmed.
- **Key insight:** The policy never "understands" the task. It's pattern matching at scale. More diverse, high-quality demonstrations → better pattern matching.

### Check understanding
- What's the difference between the data we record and the actions the policy predicts?
- Why does the policy need camera images and not just joint angles?

## Section 3: ACT — Action Chunking with Transformers (TEACH)

### Concepts
- **ACT** is the specific policy architecture we'll use. It was designed specifically for robotic manipulation.
- **Why "Action Chunking"?**
  - Naive approach: predict one action per timestep → jerky, compounding errors
  - ACT predicts a **chunk** of future actions (e.g., next 100 timesteps) all at once
  - Like a GPS giving you the next 10 turns vs just the next turn — smoother, more committed motion
- **Why Transformers?** Same architecture as ChatGPT but for robot actions:
  - Attends to camera images to find relevant visual features
  - Attends to joint state to know current pose
  - Generates a sequence of future actions
- **Training uses a VAE (Variational Autoencoder):**
  - Problem: same visual scene might have multiple valid actions (approach from left OR right)
  - VAE adds a "style" variable that captures this variation
  - During training: VAE encodes the actual demonstration style
  - During inference: style is sampled randomly → natural variation in execution
- **Don't worry about the math.** What matters:
  - ACT is good at smooth, multi-step manipulation tasks
  - It needs 50+ demonstrations to learn a simple task
  - Training takes ~2-8 hours on a GPU (our Jetson)

### Check understanding
- Why predict a chunk of actions instead of one at a time?
- In your own words, what does ACT take as input and produce as output?

## Section 4: What Makes Good Training Data? (TEACH)

### Concepts
- **Garbage in, garbage out** — the policy can only be as good as the demonstrations
- **Consistency matters most:**
  - Same start position for the object(s) — within a small region
  - Same grasp strategy (always approach from front, not sometimes left/sometimes right)
  - Same arm path (roughly similar trajectories)
  - Same end state (place object in same target location)
- **What kills training data:**
  - Hesitation / jerky movements during teleop (the policy learns the hesitation)
  - Inconsistent strategies (approaching from different angles each time)
  - Failed episodes left in the dataset
  - Too much variation in object placement before the policy has learned the basics
- **Data quantity guidelines:**
  - Minimum: 50 episodes for a simple pick-and-place
  - Sweet spot: 100-200 episodes
  - More is generally better, but quality > quantity
- **Episode length:**
  - Keep episodes short and focused — 15-30 seconds for a simple pick-and-place
  - Pad a few seconds at start (arm at rest) and end (holding final pose)
- **Start simple:**
  - First task should be dead simple: pick up one object, place in one location
  - Master this before attempting anything complex

### Check understanding
- If you record 50 episodes but 10 have jerky hesitations, what should you do?
- Why start with a simple task instead of something ambitious?

## Section 5: Plan Our First Task (DO)

### Choose a task
We need to pick a specific task for data collection in Session 4.2. Good first tasks:
- **Pick up a cube/block and place it in a target zone** (classic, predictable shape)
- **Pick up a ball and drop it in a cup** (slightly harder — round objects roll)
- **Push an object to a marked spot** (even simpler — no grasping needed)

### Requirements
- Find a small object (~2-4 cm) that's easy to grasp — cube, small box, or block
- Mark a "start zone" and "target zone" on the workspace with tape
- Object should be lightweight and have a consistent shape
- Good contrast with the workspace surface (easy for camera to see)

### Steps
1. Discuss task options — what objects do you have available?
2. Choose one task and define it precisely (start position, end position, grasp strategy)
3. Write down the task description (this becomes the `--dataset.task` string)
4. Do a few teleoperation practice runs to develop a consistent strategy
5. Time the task — aim for 15-30 seconds per episode

### Checkpoint
- [ ] Task chosen and precisely defined
- [ ] Object and workspace prepared (start/target zones marked)
- [ ] Practice teleoperation runs completed
- [ ] Task timing confirmed (~15-30s)
- [ ] Task description written (for dataset metadata)

---

## Session Complete When
- All TEACH concepts covered and understood
- Task chosen, workspace prepared, and practice runs done
- Ready for data collection in Session 4.2
