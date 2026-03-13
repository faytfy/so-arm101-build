# ACT Policy Evaluation Plan: Shark-to-Cup Pick-and-Place

## Task Definition
**Task:** Pick up the baby shark and place it in the green cup
**Robot:** SO-ARM101 follower arm
**Policy:** ACT (Action Chunking with Transformers)
**Training data:** 50 episodes, 30s each

---

## Evaluation Protocol

### Setup
- Shark placed within a **~15cm zone** marked on the workspace (vary position between trials)
- Green cup in its **fixed taped position** (same as training)
- Cameras in same position/angle as during recording
- Lighting similar to training conditions
- Arm starts from a **neutral rest position** each trial

### Per Checkpoint
- **20 trials** per checkpoint (standard in ACT/Diffusion Policy papers)
- **30 seconds max** per trial (matches training episode length)
- **10-30 second reset** between trials (reposition shark, return arm to rest)
- Record all trials via `lerobot-record` (automatic video capture)

### Shark Position Variation
Vary the shark's starting position across trials to test generalization:

```
Trial 1-5:    Center of training zone (easy — closest to training data)
Trial 6-10:   Left/right within zone (~5cm offset)
Trial 11-15:  Forward/back within zone (~5cm offset)
Trial 16-20:  Corners/edges of zone (hardest — furthest from training avg)
```

---

## Scoring Template

### Per-Trial Scorecard

| Trial | Shark Position | Reach | Grasp | Transport | Place | Success | Failure Note |
|-------|---------------|-------|-------|-----------|-------|---------|-------------|
| 1     | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 2     | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 3     | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 4     | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 5     | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 6     | left          | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 7     | right         | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 8     | left          | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 9     | right         | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 10    | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 11    | forward       | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 12    | back          | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 13    | forward       | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 14    | back          | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 15    | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 16    | front-left    | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 17    | front-right   | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 18    | back-left     | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 19    | back-right    | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |
| 20    | center        | 0/1   | 0/1   | 0/1       | 0/1   | 0/1     |             |

### Subtask Definitions

| Phase | Score 1 if... | Score 0 if... |
|-------|--------------|---------------|
| **Reach** | Gripper moves toward the shark and gets within ~3cm | Arm moves randomly, wrong direction, or doesn't move |
| **Grasp** | Gripper closes on the shark and holds it | Misses the shark, closes too early/late, or drops immediately |
| **Transport** | Shark is lifted and moved toward the cup | Shark is dropped during lift, arm moves wrong direction |
| **Place** | Shark is released inside the cup (or on rim and falls in) | Shark dropped outside cup, placed next to cup, or not released |
| **Success** | All 4 phases = 1 (shark ends up in the cup) | Any phase failed |

### Common Failure Notes
Use these shorthand codes in the "Failure Note" column:

- `NO_MOVE` — arm doesn't move at all
- `WRONG_DIR` — arm moves but in wrong direction
- `MISS_GRASP` — reaches shark but grip misses
- `EARLY_CLOSE` — gripper closes before reaching shark
- `LATE_CLOSE` — gripper reaches shark but doesn't close in time
- `DROP_LIFT` — grasps but drops during lift
- `DROP_TRANSPORT` — drops during transport to cup
- `MISS_CUP` — places near but not in the cup
- `NO_RELEASE` — gets to cup but doesn't open gripper
- `COLLISION` — arm collides with workspace/cup
- `JITTER` — excessive shaking or jerky motion
- `TIMEOUT` — ran out of time (30s)
- `HW_ERROR` — hardware error (motor overload, cable issue)

---

## Summary Scorecard (Per Checkpoint)

```
Checkpoint: _________ (e.g., 020000)
Training loss at checkpoint: _________
Date: _________

SUBTASK SUCCESS RATES:
  Reach:     __/20 = ___%
  Grasp:     __/20 = ___%
  Transport: __/20 = ___%
  Place:     __/20 = ___%

OVERALL SUCCESS RATE: __/20 = ___%

BY POSITION:
  Center (6 trials):     __/6  = ___%
  Left/Right (4 trials): __/4  = ___%
  Fwd/Back (4 trials):   __/4  = ___%
  Corners (4 trials):    __/4  = ___%
  Diagonal (2 trials):   __/2  = ___%

MOST COMMON FAILURE MODE: _________
QUALITATIVE NOTES:
  Motion smoothness (1-5): ___
  Speed vs training demos (slower/similar/faster): ___
  Confidence of grasp (tentative/solid/aggressive): ___
  Any surprising behavior: ___
```

---

## Checkpoint Comparison Table

| Metric | 20K | 40K | 60K | 80K | 100K |
|--------|-----|-----|-----|-----|------|
| Training loss | | | | | |
| Overall success % | | | | | |
| Reach % | | | | | |
| Grasp % | | | | | |
| Transport % | | | | | |
| Place % | | | | | |
| Center success % | | | | | |
| Edge success % | | | | | |
| Top failure mode | | | | | |
| Motion smoothness (1-5) | | | | | |

---

## Decision Framework

After evaluating a checkpoint:

```
Success rate ≥ 85%  →  Great! Use this model. Try harder variations if you want.
Success rate 60-85% →  Decent. Check next checkpoint for improvement.
                       If no improvement, investigate top failure mode.
Success rate 30-60% →  Mediocre. Likely needs more/better training data.
                       Check: are failures concentrated in one subtask?
Success rate < 30%  →  Something is wrong. Check:
                       □ Camera positions match training?
                       □ Lighting similar to training?
                       □ Arm calibration still valid?
                       □ Correct checkpoint path loaded?
                       □ Training data quality (review recordings)
```

### If Grasp Is the Bottleneck
- Record 20 more demos focusing on consistent grip timing
- Try varying shark orientation in new demos

### If Place Is the Bottleneck
- Record 20 more demos focusing on precise cup placement
- Consider using a wider cup for initial success

### If Reach Is the Bottleneck
- Most concerning — policy may not have learned the task at all
- Check camera feeds are working during inference
- Verify the checkpoint loaded correctly

---

## Command Reference

### Run evaluation (20 autonomous trials with video recording)
```bash
lerobot-record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM0 \
  --robot.id=follower \
  --robot.cameras="{ top: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30}, front: {type: opencv, index_or_path: 0, width: 640, height: 480, fps: 30}}" \
  --policy.path=outputs/train/act_shark_to_cup/checkpoints/020000/pretrained_model \
  --dataset.repo_id=fay/eval-shark-20k \
  --dataset.single_task="Pick up baby shark and place in green cup" \
  --dataset.num_episodes=20 \
  --dataset.fps=30
```

### Compare checkpoints (change path and repo_id for each)
```bash
# 40K checkpoint
--policy.path=outputs/train/act_shark_to_cup/checkpoints/040000/pretrained_model
--dataset.repo_id=fay/eval-shark-40k

# 60K checkpoint
--policy.path=outputs/train/act_shark_to_cup/checkpoints/060000/pretrained_model
--dataset.repo_id=fay/eval-shark-60k

# Final (last) checkpoint
--policy.path=outputs/train/act_shark_to_cup/checkpoints/last/pretrained_model
--dataset.repo_id=fay/eval-shark-final
```
