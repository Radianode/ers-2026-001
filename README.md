# ERS-2026-001 — INT8 Post-Training Quantization for Seq2Point NILM on Resource-Constrained Edge Platforms

**Radianode Engineering Readiness Series** · Status: Published · [Read the publication (PDF)](docs/ERS-2026-001.pdf)

## Abstract

This Engineering Readiness Assessment evaluates whether INT8 post-training quantization provides a deployment-ready optimisation for a Seq2Point Non-Intrusive Load Monitoring (NILM) model intended for resource-constrained Edge AI platforms. Using the Radianode Validation Process (RVP™), the assessment measures deployment memory, behaviour preservation, prediction accuracy and numerical stability rather than theoretical performance alone. The evidence shows a 75% reduction in deployment memory with model behaviour preserved and no observed deployment-critical instability — meeting the criteria for deployment readiness.

## Repository Purpose

This is a curated engineering reproducibility repository, not a development workspace dump. Every file here either:

1. supports the engineering evidence presented in the publication,
2. enables readers to reproduce that evidence, or
3. documents how the assessment was executed under RVP™.

See [docs/reproducibility.md](docs/reproducibility.md) for the full reproduction guide.

## RVP™ Statement

Every Engineering Readiness Study published by Radianode is executed using the **Radianode Validation Process (RVP™)** — Assess, Simulate, Validate, Deploy. See [docs/RVP-application.md](docs/RVP-application.md) for how each stage was applied to this assessment.

## Engineering Objectives

Evaluate whether INT8 post-training quantization preserves deployment readiness of a Seq2Point NILM model for resource-constrained Edge AI platforms, measured through engineering evidence rather than theoretical model performance.

## Key Results

| Metric | Value |
|---|---|
| Memory Reduction | 75% |
| Correlation Coefficient (FP32 vs INT8) | 0.994 |
| Deployment Status | Ready |

| Detail | Value |
|---|---|
| Framework | MATLAB Deep Learning Toolbox |
| Dataset | UK-DALE |
| Architecture | Seq2Point |
| Optimization | INT8 PTQ |
| Deployment Target | Resource-Constrained Edge AI |

## Repository Structure

```
ers-2026-001/
├── docs/            Publication PDF, reproducibility guide, RVP application, figure traceability
├── datasets/        UK-DALE metadata (raw dataset downloaded separately)
├── preprocessing/    Python scripts: extract, align and quality-check meter channel pairs
├── eq1/             Baseline FP32 Seq2Point model — training, evaluation, figures
├── eq2/             INT8 post-training quantization — quantization, validation, publication figures
├── eq3/             Power budget assessment (Simulink/Simscape)
└── WORKFLOW.md      End-to-end pipeline diagram
```

See [WORKFLOW.md](WORKFLOW.md) for how these stages connect, and [docs/figure-traceability.md](docs/figure-traceability.md) for exactly which script produced each published figure.

## Quick Reproduction Workflow

1. Download UK-DALE (`ukdale.h5`) and place it at `datasets/ukdale/ukdale.h5`.
2. Run the [`preprocessing/`](preprocessing/) scripts to extract and align meter channel pairs.
3. Run [`eq1/`](eq1/) to train/evaluate the baseline Seq2Point model.
4. Run [`eq2/`](eq2/) to quantize, validate, and generate the publication figures.
5. Compare your outputs against [ERS-2026-001](docs/ERS-2026-001.pdf).

Full instructions: [docs/reproducibility.md](docs/reproducibility.md).

## Methodology

The assessment follows the Radianode Validation Process (RVP™): a structured engineering process for reducing technical uncertainty before deployment through independent assessment, simulation-driven engineering, and evidence-based recommendations. See [docs/RVP-application.md](docs/RVP-application.md) and the execution guide at [docs/ERS_Stage5_Simulation_Execution_Guide.md](docs/ERS_Stage5_Simulation_Execution_Guide.md).

## Limitations

- Evaluated on UK-DALE only; results have not been validated against other NILM datasets.
- INT8 post-training quantization was evaluated in a MATLAB simulation environment, not on physical edge hardware.
- The power budget assessment (EQ3) models the deployment scenario; it does not measure a physical device under real operating conditions.

## Future Work

- Hardware-in-the-loop validation on a physical resource-constrained edge device.
- Extension to additional NILM datasets and appliance classes.
- Comparison against quantization-aware training (QAT) as an alternative to post-training quantization.

## Citation

See [CITATION.cff](CITATION.cff), or cite directly:

> Ogunjemilua, O. (2026). *ERS-2026-001: INT8 Post-Training Quantization for Seq2Point NILM on Resource-Constrained Edge Platforms.* Radianode Ltd.

## Authors

**Lead Engineer:** Oluwanifemi Ogunjemilua
**Developed under:** Radianode Ltd
**Website:** [https://radianode.com](https://radianode.com)

## License

Code and documentation in this repository are licensed under the [MIT License](LICENSE). The UK-DALE dataset referenced (not included) is separately licensed under CC BY 4.0 by its original publisher — see [datasets/dataset_structure.md](datasets/dataset_structure.md).

## Contact

[hello@radianode.com](mailto:hello@radianode.com) · [radianode.com/contact](https://radianode.com/contact)
