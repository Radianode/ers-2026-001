# Application of the Radianode Validation Process (RVP)

ERS-2026-001 is an implementation of the Radianode Validation Process (RVP) — Radianode's structured methodology for turning engineering evidence into defensible decisions, applied here across four stages: Assess, Simulate, Validate, Decide.

## RVP-01 — Assess

The engineering problem was defined by evaluating whether INT8 post-training quantization preserves deployment readiness for a Seq2Point NILM model under resource-constrained Edge AI conditions. Project scope, evaluation objectives, and deployment constraints were established before implementation.

**Record:** Engineering Baseline — see [Engineering Objectives](../README.md#engineering-objectives) in README.md.

## RVP-02 — Simulate

Representative residential energy data from the UK-DALE dataset was used to execute the engineering evaluation. The assessment examined the effects of INT8 quantization on memory efficiency, prediction behaviour, model accuracy, and numerical stability under controlled conditions.

**Record:** Analysis Record — see [`eq1/`](../eq1/), the baseline FP32 Seq2Point model that this stage's simulated/analysed behaviour is established against.

## RVP-03 — Validate

Objective engineering evidence was collected through repeatable workflows. Quantitative measurements were obtained for memory footprint, behaviour preservation, prediction accuracy, and numerical stability, with supporting figures and engineering metrics generated directly from the implementation.

**Record:** Validation Evidence — see [figure-traceability.md](figure-traceability.md) for every published figure's source script and supporting data.

## RVP-04 — Decide

The collected evidence was evaluated against requirements, assumptions and remaining uncertainty to establish deployment readiness. The Engineering Readiness Assessment documents the resulting findings and provides an evidence-based engineering recommendation regarding the suitability of the optimized model for deployment-oriented Edge AI applications.

**Record:** Readiness Decision — see the [Key Results](../README.md#key-results) table in README.md: **Ready**, one of RVP's four defined readiness outcomes (Ready, Conditional, Further Validation, Not Ready).
