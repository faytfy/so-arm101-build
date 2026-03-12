# Session 4.1 Handout: Understanding AI Policies & Data Collection

## Concepts Taught

### What Is a Policy?
- A **policy** is the robot's brain — a function that maps observations to actions
- **Inputs:** current joint angles + camera frames
- **Outputs:** target joint angles (what each motor should do next)
- Runs in a loop at ~30Hz during inference
- Learned policies generalize across positions (unlike hard-coded rules) through pattern matching

### Imitation Learning
- **Learning by watching an expert** — the expert is you, teleoperating the arm
- Training data = paired observations and actions at every timestep:
  - "When the scene looked like THIS and joints were HERE, the expert moved to THERE"
- The policy never "understands" the task — it's sophisticated pattern matching at scale
- **Analogy:** Learning to drive by watching an experienced driver for 100 hours

### ACT (Action Chunking with Transformers)
- Policy architecture designed for robotic manipulation
- **Action chunking:** predicts ~100 future actions at once instead of one at a time
  - Prevents compounding errors and jerky motion
  - Like GPS giving you the full route vs one turn at a time
- Uses **Transformers** (same architecture family as ChatGPT) to process images + joint state
- Uses a **VAE** to handle ambiguity (multiple valid actions for the same scene)
- Practical: needs 50+ demos, trains in 2-8 hours on GPU

### What Makes Good Training Data
- **Consistency is king:**
  - Same object start position/orientation
  - Same grasp strategy every time
  - Same arm path (roughly similar trajectories)
  - Smooth, deliberate movements — no hesitation
- **What ruins data:**
  - Jerky movements or hesitation (policy learns to hesitate)
  - Switching strategies between episodes
  - Failed grasps left in dataset
- **Quantity:** 50 minimum, 100-200 sweet spot
- **Quality > quantity** — delete bad episodes rather than keeping them
- **Episode length:** 15-30 seconds for simple pick-and-place

## Q&A

**Q: What are the inputs and outputs of a robot policy?**
A: Inputs are joint angles and camera frames showing where the joints are and where the object is. Outputs are the next joint angles. (Correct)

**Q: Why is a learned policy better than hard-coded rules?**
A: Hard-coded rules require the object to be at an exact position. A learned policy understands how to pick up objects anywhere in the workspace without specific positions. (Correct — it generalizes through pattern matching)

**Q: What's the difference between recorded joint angles and predicted joint angles?**
A: The recorded set is the patterns the model learns from. The predicted set is the inference output after learning from those patterns. (Correct)

**Q: Why does the policy need camera images, not just joint angles?**
A: Joint angles alone don't tell the robot where the object is. With images, the follower can see where the object is relative to the joints and pick it up correctly. (Correct)

**Q: Why predict a chunk of actions instead of one at a time?**
A: Arm movement should be smooth like human motion. Our brain plans the movement, and the arm executes it as a whole. Chunking mimics this — it's more natural than step-by-step and avoids compounding errors. (Correct — great analogy to human motor planning)

**Q: If 10 of 50 episodes have jerky hesitations, what should you do?**
A: Remove them to prevent the model from learning those patterns. (Correct — 40 clean > 50 messy)

**Q: Why start with a simple task?**
A: It helps get familiar with the training process and understand how to perform actions consistently. Consistency is easier when the task is simple. (Correct on both counts)

## Vocabulary
| Term | Definition |
|------|-----------|
| **Policy** | Neural network that maps observations (images + joint angles) to actions (target joint angles) |
| **Imitation learning** | Training approach where the policy learns by watching expert demonstrations |
| **ACT** | Action Chunking with Transformers — policy architecture that predicts chunks of future actions |
| **Action chunking** | Predicting multiple future actions at once instead of one per timestep |
| **Transformer** | Neural network architecture that uses attention to process sequences (images, actions) |
| **VAE** | Variational Autoencoder — adds a style variable to handle ambiguity in demonstrations |
| **Episode** | One complete demonstration of the task from start to finish |
| **Inference** | Running the trained policy live on the robot to generate actions |
| **Observation** | What the policy sees: camera frames + current joint angles |
| **Action** | What the policy outputs: target joint angles for the next timestep(s) |

## Task Plan for Session 4.2
- **Task:** Pick up the baby shark and place it in the green cup
- **Object:** Small baby shark toy, placed in consistent orientation on blue tape start zone
- **Target:** Green toy cup, taped down
- **Episode length:** 15 seconds (~3s rest, ~5s pick-and-place, ~3s hold)
- **Target episodes:** 50
- **Strategy:** Consistent grasp on shark body, same approach angle every time
