# Changelog

All notable changes to this repository are documented in this file.

## [Unreleased]

### Changed

- Aligned RVP terminology with Radianode's current public definition (radianode.com/system-validation): "RVP™" → "RVP" throughout, and the fourth stage renamed "Deploy" → "Decide" (README.md, WORKFLOW.md, docs/reproducibility.md, docs/RVP-application.md). docs/RVP-application.md additionally now names the record each stage produces (Engineering Baseline, Analysis Record, Validation Evidence, Readiness Decision), cross-referenced to the existing artifacts that already satisfy each one.
- Fixed a text-encoding error in docs/ERS_Stage5_Simulation_Execution_Guide.md where every em dash had been corrupted to "â€”" (cp1252/UTF-8 double-encoding); re-saved as UTF-8 with correct em dashes throughout.

### Removed

- EQ3 (power budget assessment): the model and initialization script were never executed — `figures/` and `outputs/` held no results — so the stage has been removed rather than published as unexecuted scaffolding. References to EQ3 removed from README.md and WORKFLOW.md accordingly.

## [1.0.0] — 2026-07-26

### Added

- Initial public release of the ERS-2026-001 engineering reproducibility repository.
- Preprocessing scripts for UK-DALE meter channel extraction and alignment.
- EQ1: baseline FP32 Seq2Point NILM model, training and evaluation.
- EQ2: INT8 post-training quantization, validation, and all seven publication figures.
- EQ3: power budget assessment model.
- Documentation: reproducibility guide, RVP™ application, figure traceability, and the published PDF.
