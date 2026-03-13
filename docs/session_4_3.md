# Session 4.3: Train Your First Policy (ACT) on Jetson

## Goal
Train an ACT policy on the 50 recorded episodes using the Jetson's GPU, and understand the training process.

## Prerequisites
- Session 4.2 complete (50 episodes recorded)
- Dataset saved at `~/.cache/huggingface/lerobot/fay/shark-to-cup` on Jetson
- Jetson AGX Orin with CUDA verified

---

## Section 1: What Happens During Training? (TEACH)

### Concepts
- **Training loop:** The network repeatedly:
  1. Samples a batch of observation→action pairs from your dataset
  2. Predicts what actions it thinks should follow those observations
  3. Compares predictions to the actual recorded actions (calculates loss)
  4. Adjusts its weights to reduce the error
  5. Repeat for thousands of steps
- **Loss:** A number measuring how wrong the predictions are. It should decrease over training.
- **Steps vs epochs:**
  - A step = one batch of data processed
  - An epoch = one full pass through the entire dataset
  - We train for ~100,000 steps — that's many epochs over 50 episodes
- **Checkpoints:** The model saves snapshots periodically so you can resume or pick the best one
- **Overfitting risk:** With only 50 episodes, the network could memorize instead of generalize. ACT is designed to handle small datasets well, but this is why data quality matters.

## Section 2: Training Configuration (TEACH)

### Key hyperparameters
- **batch_size:** How many examples to process at once (default 8, reduce if out of memory)
- **num_training_steps:** How long to train (default 100,000 — ~6-8 hours on Jetson AGX Orin)
- **chunk_size:** How many future actions to predict at once (default 100)
- **learning_rate:** How big each weight adjustment is (default works well, don't touch it)

### What to expect
- Training will take **~6-8 hours** on the Jetson AGX Orin for 100k steps
- Loss should decrease steadily, then plateau
- You can monitor with `nvidia-smi` to check GPU usage

## Section 3: Launch Training (DO)

### Pre-flight
```bash
# Verify CUDA is available
python3 -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name())"
```

### Training command
```bash
lerobot-train \
  --dataset.repo_id=fay/shark-to-cup \
  --dataset.root=$HOME/.cache/huggingface/lerobot/fay/shark-to-cup \
  --policy.type=act \
  --output_dir=outputs/train/act_shark_to_cup \
  --job_name=act_shark_to_cup \
  --policy.device=cuda
```

### Monitor training
```bash
# In another SSH session
nvidia-smi  # Check GPU memory usage
```

### If out of memory
Reduce batch size:
```bash
--training.batch_size=4
```

### Checkpoint
- [ ] Training launched successfully
- [ ] Loss is decreasing
- [ ] No out-of-memory errors

## Section 4: Understanding Training Output (TEACH)

### What to look for in the logs
- **Loss decreasing:** Good — the model is learning
- **Loss plateauing:** Normal after a while — the model has learned what it can
- **Loss spiking:** Might indicate a problem, but occasional spikes are normal
- **Training complete:** Model saved to output_dir

---

## Session Complete When
- Training launched and running (or completed)
- Loss is decreasing as expected
- Trained model checkpoint saved
- Ready for deployment in Session 5.1
