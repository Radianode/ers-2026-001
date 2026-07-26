# EQ2 — INT8 Post-Training Quantization

Applies INT8 post-training quantization to the EQ1 baseline model and validates the result against it. This is the core engineering evidence behind ERS-2026-001.

## Contents

| File | Purpose |
|---|---|
| `eq2_prepareNetwork.m` | Prepares the EQ1 network for quantization |
| `eq2_prepareCalibration.m` | Builds the representative calibration dataset (`calibrationData.mat`) |
| `eq2_quantize.m` | Runs the MATLAB `dlquantizer` INT8 post-training quantization workflow |
| `eq2_validate_quantization.m` | Validates the quantized network's behaviour against the FP32 baseline |
| `eq2_memory.m` | Computes deployment memory footprint (FP32 vs INT8) |
| `eq2_generate_figures.m` | Generates all publication figures for ERS-2026-001 (see [`../docs/figure-traceability.md`](../docs/figure-traceability.md)) |
| `calibrationData.mat` | Representative calibration windows used for quantization |
| `eq2_quantized_network.mat` | The resulting INT8 quantized network |
| `models/eq1_seq2point_sampled.mat` | Copy of the EQ1 baseline network this stage depends on |
| `eq2_quantization_results.csv` / `.mat` | Quantization evaluation results |
| `figures/` | The seven publication figures |
| `results/fit_table.csv`, `results/memory_summary.csv` | Supporting engineering metrics referenced in the publication |

## Key Results

| Metric | Value |
|---|---|
| Deployment memory reduction | 75% |
| Behaviour correlation (FP32 vs INT8) | 0.994 |
| Deployment status | Ready |

## Reproducing

Run in order: `eq2_prepareNetwork.m` → `eq2_prepareCalibration.m` → `eq2_quantize.m` → `eq2_validate_quantization.m` → `eq2_memory.m` → `eq2_generate_figures.m`. Requires the EQ1 baseline network as input.
