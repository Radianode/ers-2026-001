# Reproducibility Guide

## Purpose

This repository provides the engineering implementation and supporting artefacts required to reproduce the engineering evidence presented in **ERS-2026-001**.

The assessment was executed using the Radianode Validation Process (RVP) and focuses on the engineering readiness of INT8 post-training quantization for a Seq2Point NILM model intended for deployment on resource-constrained Edge AI platforms.

## Repository Components

- Dataset preparation
- Engineering implementation
- Evaluation workflows
- Figure-generation scripts
- Engineering metrics
- Publication assets

## Dataset

The UK-DALE dataset is not included because of its size.

Download the official dataset and place:

```
ukdale.h5
```

inside

```
datasets/ukdale/
```

The metadata files required by the workflow are already included.

## Execution Sequence

1. Prepare the dataset.
2. Execute preprocessing scripts.
3. Train or load the baseline Seq2Point model (EQ1).
4. Execute INT8 quantization (EQ2).
5. Validate quantization.
6. Generate engineering metrics.
7. Generate publication figures.
8. Compare outputs against ERS-2026-001.

## Expected Outputs

Successful execution reproduces:

- Memory footprint analysis
- Memory breakdown
- Behaviour preservation
- Prediction accuracy
- Numerical stability
- All seven publication figures
- Engineering metrics presented in the publication
