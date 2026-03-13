# Session 5.2: Iterate, Debug & Improve

## Goal
Improve policy performance through targeted data collection and understanding common failure patterns.

## Prerequisites
- Session 5.1 complete (first inference run, performance evaluated)
- Notes on what worked and what failed

---

## Section 1: Debugging Robot Policies (TEACH)

### Concepts
- **Policy debugging is empirical:** Unlike software bugs, you can't step through a neural network. You diagnose by observing behavior and reasoning backward to likely causes.
- **The three levers you can pull:**
  1. **Data** — more episodes, better consistency, targeted at failure cases
  2. **Training** — more steps, different checkpoint selection, hyperparameters
  3. **Environment** — camera positions, lighting, object placement
- **Checkpoint selection:** The "last" checkpoint isn't always the best. Earlier checkpoints sometimes generalize better (less overfitting). Try checkpoints from different training stages.
- **Targeted data collection:** If the arm fails at grasping but succeeds at reaching, record 20 more episodes focusing on consistent grasps. The model learns from the distribution — more examples of the tricky part helps.

### The debugging flowchart
```
Arm doesn't move correctly
├── Doesn't reach the object
│   ├── Camera position changed → fix cameras
│   └── Object in different spot → match training position
├── Reaches but can't grasp
│   ├── Grip inconsistent in data → record more with consistent grip
│   └── Gripper calibration off → re-calibrate
├── Grasps but drops during transport
│   ├── Speed mismatch → check if demos were consistent speed
│   └── Grip force varies → record with firm, consistent grip
└── Misses the target (cup)
    ├── Cup position moved → fix position
    └── Approach angle varies in data → record with consistent angle
```

## Section 2: Improve with More Data (DO)

### If performance needs improvement
```bash
# Record additional targeted episodes (appends to existing dataset)
lerobot-record \
  --robot.type=so101 \
  --robot.cameras='[{type: opencv, key: top, index_or_path: 2, width: 640, height: 480, fps: 30}, {type: opencv, key: front, index_or_path: 0, width: 640, height: 480, fps: 30}]' \
  --teleop.type=so101_leader \
  --dataset.repo_id=fay/shark-to-cup \
  --dataset.root=/home/fay/.cache/huggingface/lerobot/fay/shark-to-cup \
  --dataset.single_task="Pick up the baby shark and place it in the green cup" \
  --dataset.num_episodes=20 \
  --dataset.fps=30 \
  --dataset.episode_time_s=30 \
  --dataset.reset_time_s=10
```

### Re-train with expanded dataset
```bash
lerobot-train \
  --dataset.repo_id=fay/shark-to-cup \
  --dataset.root=/home/fay/.cache/huggingface/lerobot/fay/shark-to-cup \
  --policy.type=act \
  --output_dir=outputs/train/act_shark_to_cup_v2 \
  --job_name=act_shark_to_cup_v2 \
  --policy.device=cuda \
  --policy.push_to_hub=false
```

## Section 3: Try Different Checkpoints (DO)

### List available checkpoints
```bash
ls outputs/train/act_shark_to_cup/checkpoints/
```

### Run inference with an earlier checkpoint
```bash
# Example: try checkpoint at step 60000 instead of last
lerobot-infer \
  --policy.path=outputs/train/act_shark_to_cup/checkpoints/060000/pretrained_model \
  --robot.type=so101 \
  --robot.cameras='[{type: opencv, key: top, index_or_path: 2, width: 640, height: 480, fps: 30}, {type: opencv, key: front, index_or_path: 0, width: 640, height: 480, fps: 30}]' \
  --teleop.type=so101_leader
```

### Checkpoint
- [ ] Identified failure modes from 5.1
- [ ] Tried at least one improvement strategy
- [ ] Compared results before and after
- [ ] Captured best-run video

---

## Session Complete When
- Failure modes from 5.1 investigated
- At least one improvement attempt made (more data, different checkpoint, or environment fix)
- Best performance captured on video
- Ready for advanced topics in Session 5.3
