# EQ1 — Baseline Seq2Point Model

Trains and evaluates the FP32 baseline Seq2Point CNN used as the reference model for ERS-2026-001's quantization assessment.

## Contents

| File | Purpose |
|---|---|
| `seq2pointNet.m` | Defines the Seq2Point CNN architecture (5 conv blocks + fully connected head, regression output) |
| `makeWindows.m` / `makeMiniBatch.m` / `windowReader.m` | Windowing and mini-batch construction over the aligned meter pairs |
| `normalizeTraining.m` | Input/target normalization used before training |
| `modelLoss.m` | Custom training loss |
| `eq1_train_sampled.m` | Training entry point |
| `eq1_train_eval.m` / `evaluateEQ1.m` | Evaluation of the trained baseline model |
| `eq1_seq2point_sampled.mat` | Trained FP32 baseline network (input to EQ2) |
| `normalization.mat` | Saved normalization parameters, reused at inference/quantization time |
| `eq1_metrics.csv` / `eq1_predictions.csv` / `eq1_results.mat` | Baseline evaluation outputs |
| `plots/` | Baseline training/evaluation figures |

## Reproducing

Requires MATLAB with Deep Learning Toolbox and Signal Processing Toolbox. Run `eq1_train_sampled.m` after preprocessing has produced the aligned meter pairs (see [`../preprocessing/`](../preprocessing/)), then `evaluateEQ1.m` to reproduce the baseline metrics.
