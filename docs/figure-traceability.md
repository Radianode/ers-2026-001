# Figure Traceability

Every figure published in ERS-2026-001 is directly traceable to the engineering workflow used to generate it.

| Publication Figure | Source Script | Supporting Data | Output |
|---|---|---|---|
| Figure 1 – Memory Footprint Comparison | `eq2_memory.m` | FP32 and INT8 models | `Figure_EQ2_MemoryReduction.png` |
| Figure 2 – Model Memory Breakdown | `eq2_memory.m` | Memory measurements | `model_memory_breakdown.png` |
| Figure 3 – FP32 vs INT8 Prediction Scatter | `eq2_generate_figures.m` | FP32 and INT8 predictions | `Figure_EQ2_Scatter.png` |
| Figure 4 – Prediction Overlay | `eq2_generate_figures.m` | FP32 and INT8 predictions | `Figure_EQ2_PredictionOverlay.png` |
| Figure 5 – Accuracy Comparison | `eq2_generate_figures.m` | Engineering metrics | `Figure_EQ2_AccuracyComparison.png` |
| Figure 6 – Error Distribution Histogram | `eq2_generate_figures.m` | Numerical stability results | `Figure_EQ2_ErrorHistogram.png` |
| Figure 7 – Absolute Prediction Error | `eq2_generate_figures.m` | Numerical stability results | `Figure_EQ2_AbsoluteError.png` |

## Supporting Engineering Metrics

The engineering metrics presented in ERS-2026-001 are generated from:

- `eq2_quantization_results.csv`
- `fit_table.csv`
- `memory_summary.csv`

These files provide the quantitative evidence supporting the Engineering Interpretation, Engineering Findings, and Engineering Readiness Outcome presented in the publication.
