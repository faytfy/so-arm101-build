# Troubleshooting Log

## Format
Each issue gets an entry:
```
### Issue: [brief description]
- Session: [when it occurred]
- Symptoms: [what happened]
- Root cause: [what was wrong]
- Fix: [how we solved it]
```

## Issues

### Issue: Negative range_min ValueError during leader calibration
- Session: 2.2
- Symptoms: `ValueError: Negative values are not allowed: -153` when saving leader calibration
- Root cause: Elbow joint midpoint was set too close to one extreme, so sweeping the other direction produced a negative offset
- Fix: Re-calibrate with elbow positioned at true center (roughly 90° bend) before pressing ENTER on the midpoint step

### Issue: ConnectionError on motor 5 (wrist_roll) during follower re-calibration
- Session: 2.2
- Symptoms: `ConnectionError: Failed to write 'Lock' on id_=5 with '1'` — "no status packet"
- Root cause: Loose 3-pin cable on wrist roll motor (daisy chain break)
- Fix: Power off, reseat cable connections on motor 5, power back on

### Issue: FileExistsError when starting lerobot-record
- Session: 3.2
- Symptoms: `FileExistsError: [Errno 17] File exists: '/Users/fay/.cache/huggingface/lerobot/fay/test-recording'`
- Root cause: A previous recording attempt (or aborted run) left a dataset directory behind
- Fix: Either delete the old dataset (`rm -rf ~/.cache/huggingface/lerobot/fay/test-recording`) or add `--resume=true` to continue from where it left off

### Issue: AVFFrameReceiver duplicate class warnings
- Session: 2.2
- Symptoms: `objc: Class AVFFrameReceiver is implemented in both...` warning on every lerobot command
- Root cause: OpenCV (cv2) and PyAV (av) both bundle libavdevice — harmless duplicate
- Fix: None needed — ignore the warning
