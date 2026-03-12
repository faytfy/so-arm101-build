# Session 4.2: Record Demonstration Episodes

## Goal
Record 50 high-quality demonstration episodes of the baby shark pick-and-place task on the Jetson.

## Prerequisites
- Session 4.1 complete (concepts understood, task planned, workspace set up)
- Arms + cameras connected to Jetson
- Workspace ready: blue tape start zone, green cup taped down, baby shark

---

## Section 1: Recording Workflow (TEACH)

### Concepts
- **LeRobot recording loop:** each episode records continuously at 30fps until the episode timer ends
- **Between episodes:** you reset the scene (put shark back on start zone) and press Enter to start the next episode
- **Dataset structure:** LeRobot saves joint angles + camera frames as a HuggingFace dataset
- **Episode management:** if an episode goes badly, you can re-record it (LeRobot overwrites the last episode if you choose)
- **Batching:** recording 50 episodes in one session takes ~20-30 minutes including resets

## Section 2: Record Episodes (DO)

### Pre-flight checklist
1. SSH into Jetson, activate conda env
2. `sudo chmod 666 /dev/ttyACM*`
3. Cameras connected and positioned (top + front)
4. Shark on start zone, cup in place
5. Leader arm within comfortable reach

### Recording command
```bash
lerobot-record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM0 \
  --robot.id=follower \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM1 \
  --teleop.id=leader \
  --robot.cameras='{ "top": {"type": "opencv", "index": 2, "width": 640, "height": 480, "fps": 30}, "front": {"type": "opencv", "index": 0, "width": 640, "height": 480, "fps": 30} }' \
  --dataset.repo_id=fay/shark-to-cup \
  --dataset.num_episodes=50 \
  --dataset.episode_time_s=15 \
  --dataset.task="Pick up the baby shark and place it in the green cup"
```

### Per-episode workflow
1. Place shark on blue tape start zone (same orientation every time)
2. Hands on leader arm, ready position
3. Press Enter to start recording
4. Wait ~3 seconds (rest)
5. Pick up shark, place in cup (~5 seconds)
6. Hold final pose ~3 seconds
7. Episode timer ends automatically
8. Reset shark to start zone
9. Repeat

### Quality control
- If an episode went badly (fumbled grasp, inconsistent path), note the episode number
- Stay focused — consistency degrades when you're tired
- Take a break after 25 episodes if needed

### Checkpoint
- [ ] 50 episodes recorded
- [ ] No obvious bad episodes (or bad ones noted for removal)
- [ ] Dataset saved successfully

## Section 3: Verify Dataset (DO)

### Check the dataset
```bash
# Check dataset exists and has correct number of episodes
ls -la ~/.cache/huggingface/lerobot/fay/shark-to-cup/
```

### Checkpoint
- [ ] Dataset contains 50 episodes
- [ ] File sizes look reasonable (camera data should be substantial)

---

## Session Complete When
- 50 episodes recorded with consistent quality
- Dataset saved and verified on Jetson
- Ready for training in Session 4.3
