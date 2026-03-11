# Session 2.2 Handout: Motor Calibration & First Teleoperation

## Key Concepts

### Why Calibrate?
- Each servo encoder reports 0–4095 for one rotation, but "2048" means a different physical angle on every motor
- Assembly variance (how gears mesh) means raw values aren't comparable across motors or arms
- Calibration creates a **shared coordinate system** so leader and follower agree on positions

### Two-Step Calibration Process
1. **Homing offset (midpoint):** Position all joints at the middle of their range → software records "this = center"
2. **Range of motion:** Sweep each joint to both extremes → software records min/max positions
3. Result: standardized joint angles that are consistent across arms

### Why AI Needs This
- **Teleoperation:** Leader says "37% of range" → follower goes to 37% of its range (different raw values, same physical position)
- **Training:** Neural networks learn from standardized values, not raw encoder ticks
- **Transfer:** A calibrated policy can work on another identically calibrated robot

## Commands Reference

### Find ports
```bash
lerobot-find-port
```

### Calibrate follower
```bash
lerobot-calibrate --robot.type=so101_follower --robot.port=PORT --robot.id=follower
```

### Calibrate leader
```bash
lerobot-calibrate --teleop.type=so101_leader --teleop.port=PORT --teleop.id=leader
```

### Teleoperate
```bash
lerobot-teleoperate --robot.type=so101_follower --robot.port=FOLLOWER_PORT --robot.id=follower --teleop.type=so101_leader --teleop.port=LEADER_PORT --teleop.id=leader
```

### Key differences
| | Follower | Leader |
|---|---|---|
| Flag prefix | `--robot.` | `--teleop.` |
| Type | `so101_follower` | `so101_leader` |

## Calibration Files
- Follower: `~/.cache/huggingface/lerobot/calibration/robots/so_follower/{id}.json`
- Leader: `~/.cache/huggingface/lerobot/calibration/teleoperators/so_leader/{id}.json`
- To re-calibrate: run the same command, type `c` when prompted

## Troubleshooting Notes from This Session

| Issue | Cause | Fix |
|---|---|---|
| `ValueError: Negative values are not allowed: -153` | Elbow midpoint set too close to one extreme | Re-calibrate with elbow at true center (90° bend) |
| `ConnectionError: Failed to write 'Lock' on id_=5` | Loose 3-pin cable on wrist roll motor | Reseat cable connections |
| `AVFFrameReceiver` duplicate class warnings | OpenCV and PyAV bundle same FFmpeg lib | Harmless — ignore |
| Narrow range on a joint | Didn't sweep far enough, or physical limit | Sweep both directions; if that's the max range, it's fine |

## Vocabulary
- **Homing offset:** The correction value that maps a motor's raw encoder position to standardized center
- **Range of motion:** The min/max positions a joint can physically reach
- **Teleoperation (teleop):** Controlling the follower arm by moving the leader arm in real-time
- **Calibration file:** JSON storing per-joint offsets and ranges, tied to the arm's ID
- **Daisy chain:** Motors wired in series — a cable break kills all downstream motors

## Q&A from This Session

**Q: Why can't we just say position 2048 = center for every motor?**
A: Because different arms have different understanding of what that raw value means. Calibration aligns them so when the leader says "center," the follower moves to the correct physical position.

**Q: Do leader and follower need matching raw ranges?**
A: No — calibration maps each arm's range independently into standardized values. Different raw ranges are normal.
