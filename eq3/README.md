# EQ3 — Power Budget Assessment

Simulink/Simscape model assessing the power budget of the resource-constrained Edge AI deployment scenario referenced in ERS-2026-001.

## Contents

| Path | Purpose |
|---|---|
| `models/eq3_power_budget.slx` | Simulink power budget model |
| `scripts/init_eq3.m` | Initialization script (parameters/workspace setup) for the Simulink model |
| `figures/` | Output figures from this stage (populated on execution) |
| `outputs/` | Simulation outputs (populated on execution) |

## Reproducing

Requires MATLAB with Simulink and Simscape. Run `scripts/init_eq3.m` to initialize the workspace, then open and run `models/eq3_power_budget.slx`.
