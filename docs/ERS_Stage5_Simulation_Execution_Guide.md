# ERS Stage 5 — Simulation Execution Guide
## Meter Collar Edge AI Platform for Residential NILM

**Document type:** Stage 5 execution support (engineer-owned stage)
**Companion to:** ERS AI-Assisted Engineering Research Framework v2.0, Stages 0-4 (approved)
**Governing rule:** All numerical results are produced by the engineer running the tools below. Nothing in this guide is a result. Every assumed input is tagged [ASSUMED] and registered in Section 1.3.

---

## 1. Common setup

### 1.1 Software environment

| Item | Requirement | Used by |
|---|---|---|
| MATLAB | R2023b or later | EQ1, EQ2, EQ3, EQ4, EQ6 |
| Deep Learning Toolbox | required | EQ1, EQ2 |
| Deep Learning Toolbox Model Quantization Library | Add-On (install via Add-On Explorer) | EQ2 |
| Signal Processing Toolbox | required | EQ1 |
| Simulink + Stateflow | required | EQ3, EQ6 |
| Simscape | required | EQ3, EQ4 |
| Partial Differential Equation Toolbox | required | EQ4 |
| Parallel Computing Toolbox | optional (accelerates sweeps and training) | EQ1-EQ4 |
| ns-3 | 3.40 or later, Linux (Ubuntu 22.04/24.04) or WSL2 | EQ5 |
| Python | 3.10+, with h5py, numpy, pandas | dataset preparation |

Verify the MATLAB installation:

```matlab
ver('deep'); ver('signal'); ver('simulink'); ver('pde'); ver('simscape')
```

### 1.2 Datasets

**UK-DALE** (primary for EQ1/EQ2). Download the disaggregated HDF5 release (`ukdale.h5`, approx. 6 GB) from the UK Energy Research Centre data centre (search "UK-DALE UKERC EDC"). Contains whole-house and per-appliance power at 1/6 Hz for five houses, plus 16 kHz aggregate for some houses.

**REDD** (cross-dataset check). Available from the original MIT distribution point (redd.csail.mit.edu); access may require emailing the maintainers. Low-frequency version: mains ~1 Hz, appliance channels ~1/3 Hz.

Directory convention used by all scripts in this guide:

```
ers_stage5/
  data/ukdale/ukdale.h5
  data/redd/low_freq/
  eq1/  eq2/  eq3/  eq4/  eq5/
  runlogs/
  params/assumptions.csv
```

Target appliances (charter A5): EV charger, HVAC (aircon/heat pump channels), water heater (immersion/boiler channels). In UK-DALE, candidate channels: house 1 "boiler", house 2 "kettle" is NOT a target (transient load, excluded), aircon channels are sparse in UK data. **Record which channels you actually select in the run log.** If EV charger coverage is inadequate, record this as an evidence limitation per the Stage 4 plan; do not synthesize EV data.

### 1.3 Assumption register (versioned)

Copy this table to `params/assumptions.csv` and freeze it before the first run. Any change increments the version and is noted in every subsequent run log.

| ID | Parameter | Value / range | Basis | Status |
|---|---|---|---|---|
| AS-01 | NILM result payload size | 256 B | compact per-appliance state+energy message | [ASSUMED] |
| AS-02 | Radio TX active draw | 60-130 mW sweep | sub-GHz FSK transceiver class at +14 dBm | [ASSUMED] |
| AS-03 | Radio RX/idle listen draw | 15-30 mW sweep | same transceiver class | [ASSUMED] |
| AS-04 | AFE + metrology front-end draw | 5-15 mW sweep | energy-metering AFE class | [ASSUMED] |
| AS-05 | MCU sleep floor | 50-500 uW sweep | Cortex-M class deep sleep with RTC | [ASSUMED] |
| AS-06 | Compute active platform power | 8-20 mW | Stage 2 evidence 4.4 (duty-cycled NPU-MCU measurements) | anchored |
| AS-07 | Energy per inference | 251 uJ (sweep 100-1000 uJ) | Stage 2 evidence 4.4 (audio workload; NILM value unknown) | anchored/[ASSUMED sweep] |
| AS-08 | Supply capacity sweep [GAP-6.1] | 50 mW - 2 W, log-spaced | Stage 4 plan | swept variable |
| AS-09 | Enclosure envelope | 170 x 170 x 117 mm (6.7 x 6.7 x 4.6 in) | Stage 2 evidence 4.1 (collar-only dimensions) | anchored |
| AS-10 | Wall material | polycarbonate, k = 0.20 W/mK, t = 3 mm | typical enclosure plastic [GAP-6.2] | [ASSUMED] |
| AS-11 | External film coefficient | 5-15 W/m2K sweep | natural convection range [GAP-6.2] | [ASSUMED] |
| AS-12 | Ambient sweep | -20 C to +50 C | Stage 4 plan | plan value |
| AS-13 | Solar gain boundary case | +15 C effective sol-air increment, on/off | screening-grade boundary case | [ASSUMED] |
| AS-14 | Component thermal limit | 85 C internal air proxy | commercial/industrial component class | [ASSUMED] |
| AS-15 | Wi-SUN PHY | 2-FSK, 50 kbps, sub-GHz | Stage 2 evidence 4.5 (mandatory mode) | anchored |
| AS-16 | Outdoor link range envelope | 100-200 m | Stage 2 evidence 4.5 | anchored |
| AS-17 | Seq2Point input window | 599 samples | common seq2point convention; sweep 299/599 if time allows | [ASSUMED] |
| AS-18 | On/off threshold for F1 | per-appliance, e.g. 20 W water heater/HVAC, 1000 W EV | standard NILM practice; record actual values used | [ASSUMED] |

### 1.4 Run log template

Copy `runlogs/runlog_template.csv` (provided alongside this guide) once per run. Fields: `run_id, date, EQ, tool+version, script+git/hash, assumptions_version, seeds, inputs_summary, outputs_files, deviations, anomalies, engineer_initials`.

---

## 2. EQ1 — Minimum sampling requirement (MATLAB)

**Question:** What minimum sampling rate must S2 provide for acceptable EV/HVAC/water-heater disaggregation?

### 2.1 Data preparation

Step 1. Extract aligned aggregate/appliance pairs from UK-DALE into MAT files. Run this Python snippet once (h5py):

```python
import h5py, numpy as np, pandas as pd
f = h5py.File('data/ukdale/ukdale.h5', 'r')
# Explore structure first: houses are 'building1'..'building5',
# channels under .../elec/meterN. Print keys and match channel labels
# from the UK-DALE metadata to your target appliances.
# Export each selected series to CSV/Parquet with UNIX timestamps.
```

Practical notes: UK-DALE HDF5 follows the NILMTK schema; if navigation is awkward, install NILMTK in a Python venv and use `DataSet('ukdale.h5')` to list appliances and export. Align aggregate and appliance series to a common 1/6 Hz grid with forward-fill limited to 3 samples; longer gaps become NaN and are excluded from windows.

Step 2. In MATLAB, load and build the decimation ladder:

```matlab
% eq1_prepare.m
rates = [1, 1/6, 1/30];          % Hz ladder (1 Hz only if source rate supports it;
                                  % UK-DALE disaggregated is 1/6 Hz -> ladder {1/6, 1/30})
T = readtable('eq1/house1_pairs.csv');   % columns: t, agg_W, app_W
for r = rates
    dt = 1/r;
    tq = (T.t(1):dt:T.t(end))';
    agg = interp1(T.t, T.agg_W, tq, 'previous');
    app = interp1(T.t, T.app_W, tq, 'previous');
    save(sprintf('eq1/pairs_%s.mat', ratename(r)), 'tq','agg','app');
end
```

Record in the run log that REDD (1 Hz mains) is the only source for the 1 Hz rung; UK-DALE contributes 1/6 and 1/30 Hz rungs.

### 2.2 Model definition (fixed reference Seq2Point)

```matlab
% seq2point architecture — keep IDENTICAL across all rates and both EQ1/EQ2
function lgraph = seq2pointNet(win)
layers = [
    sequenceInputLayer(1,'MinLength',win,'Name','in')
    convolution1dLayer(10,30,'Padding','same')
    reluLayer
    convolution1dLayer(8,30,'Padding','same')
    reluLayer
    convolution1dLayer(6,40,'Padding','same')
    reluLayer
    convolution1dLayer(5,50,'Padding','same')
    reluLayer
    convolution1dLayer(5,50,'Padding','same')
    reluLayer
    flattenLayer
    fullyConnectedLayer(1024)
    reluLayer
    fullyConnectedLayer(1)
    regressionLayer];
lgraph = layerGraph(layers);
end
```

Window: AS-17 (599 samples). Normalize inputs per standard practice (subtract mean, divide by std of training aggregate; record the constants).

### 2.3 Training and evaluation loop

```matlab
% eq1_train_eval.m  — one (rate, appliance) cell per iteration
win = 599; rng(1);                      % seed 1; repeat key cells with seed 2
[Xtr,Ytr,Xval,Yval,Xte,Yte] = makeWindows('eq1/pairs_1_6Hz.mat', win, splitCfg);
opts = trainingOptions('adam', MaxEpochs=30, MiniBatchSize=512, ...
    InitialLearnRate=1e-3, ValidationData={Xval,Yval}, ...
    Shuffle='every-epoch', Verbose=true, Plots='none');
net = trainNetwork(Xtr, Ytr, seq2pointNet(win), opts);
Yp = predict(net, Xte);
% Metrics
mae = mean(abs(Yp - Yte));
on  = Yte > thr; onp = Yp > thr;        % thr per AS-18
f1  = 2*sum(on&onp) / (2*sum(on&onp) + sum(~on&onp) + sum(on&~onp));
save(sprintf('eq1/result_%s_%s.mat',rateTag,appTag), 'mae','f1','thr','win');
```

Cross-dataset validation cell: train on UK-DALE house set, test on REDD equivalents (and vice versa) at the common 1/6 Hz rung after resampling REDD down.

### 2.4 Deliverables to Stage 6

- `eq1/results_matrix.csv`: rows = appliance, columns = rate, cells = F1 and MAE (two files or long format).
- Training curves (PNG) per cell, seeds used, channel selection notes, run logs.

---
## 3. EQ2 — INT8 fit and accuracy loss (MATLAB)

**Question:** Does an INT8 Seq2Point-class model fit NPU-class weight memory, and what accuracy is lost versus FP32?

### 3.1 Baseline and memory accounting

Start from the trained EQ1 network at the EQ1-selected operating rate (the lowest rate whose F1 remains acceptable — that selection is your Stage 6 interpretation, so run EQ2 at the two best candidate rates to keep options open).

```matlab
% eq2_memory.m — parameter count and INT8 weight footprint
info = analyzeNetwork(net);                 % inspect layer-by-layer
numParams = sum(arrayfun(@(l) numel(l.Value), net.Learnables.Value));
bytes_fp32 = numParams*4; bytes_int8 = numParams*1;
fprintf('Params %d  FP32 %.1f KB  INT8 %.1f KB\n', numParams, bytes_fp32/1024, bytes_int8/1024);
```

Compare `bytes_int8` against the swept ceilings {256, 442, 512} KB. If over ceiling, apply magnitude pruning before quantization:

```matlab
% Iterative magnitude pruning (Deep Learning Toolbox)
prunableNet = taylorPrunableDlnetwork(dlnet);   % or use magnitude masks manually
% Prune in 10% steps, fine-tune 5 epochs per step, stop when INT8 size <= ceiling.
% Record accuracy at each step in eq2/pruning_trace.csv
```

### 3.2 Quantization (PTQ, then QAT if PTQ degrades)

```matlab
% eq2_quantize.m — post-training quantization
dq = dlquantizer(net, 'ExecutionEnvironment','MATLAB');
calResults = calibrate(dq, calibrationDatastore);     % ~2000 windows from train set
valResults = validate(dq, validationDatastore, ...
              dlquantizationOptions('MetricFcn', @(x) nilmMetrics(x, Yval, thr)));
qNet = quantizedNetwork(dq);
YpQ = predict(qNet, Xte);
% Recompute F1/MAE exactly as in EQ1 and store delta vs FP32
```

If the FP32-to-INT8 F1 drop exceeds your acceptability threshold (declare it in the run log before running, e.g. 2 points), repeat with quantization-aware training: retrain the pruned network with `dlquantizer` in QAT mode (R2024a+) or emulate by fine-tuning with fake-quantization noise, and record which path was used.

### 3.3 Deliverables to Stage 6

- `eq2/fit_table.csv`: rate x ceiling x {params, INT8 KB, pruning %, F1_fp32, F1_int8, MAE_fp32, MAE_int8}, seeds (run each cell twice, seeds 1 and 2).
- Calibration set description, thresholds declared, run logs.

---

## 4. EQ3 + EQ6 — Power budget and feasibility threshold (Simulink/Simscape)

**Question:** What continuous power must S1 supply across sense-infer-transmit duty cycles, and where is the feasibility threshold over the [GAP-6.1] sweep?

### 4.1 Model architecture

Build `eq3_power.slx` with three parts:

1. **Stateflow chart `DutyCycle`** — states: `Sleep`, `Acquire`, `Infer`, `Transmit`; outputs an integer `mode`. Transitions driven by timers: `Acquire` runs continuously in background (metrology is always-on: model as a constant adder instead of a state if simpler — record choice), `Infer` fires every `T_inf` seconds for duration `t_inf`, `Transmit` fires every `T_tx` seconds for duration `t_tx`.
2. **Power map (MATLAB Function block)** — maps mode to platform power draw:

```matlab
function P = powerMap(mode, p)
% p is a parameter struct loaded from assumptions.csv
P = p.P_sleep + p.P_afe;                 % AS-05 + AS-04 base
switch mode
  case 2, P = P + p.P_compute;           % AS-06 active compute
  case 3, P = P + p.P_txRadio;           % AS-02 transmit
end
```

3. **Energy bookkeeping** — integrate P over the run (`Integrator` block) and also accumulate per-state energy counters. Closure check: sum of per-state energies must equal total integrated energy within 0.1%.

Timing parameters:

```matlab
% t_inf: inference burst duration = N_inf_per_cycle * (E_inf / P_compute)
%   with E_inf per AS-07. For seq2point, N_inf_per_cycle = samples per
%   reporting interval (one forward pass per timepoint) — take this
%   directly from your EQ1 selected rate and reporting cadence.
% t_tx: airtime = (AS-01 payload*8 bits + PHY/MAC overhead [ASSUMED +40%]) / 50 kbps
```

### 4.2 Sweep harness

```matlab
% eq3_sweep.m
supply = logspace(log10(0.05), log10(2), 12);      % AS-08, W
cadence = [1 5 15 60 300 900];                     % s between reports
[S,C] = ndgrid(supply, cadence);
results = table();
for k = 1:numel(S)
    p = loadAssumptions('params/assumptions.csv'); % mid, lo, hi variants
    simIn = Simulink.SimulationInput('eq3_power');
    simIn = simIn.setVariable('T_tx', C(k)).setVariable('P_supply', S(k));
    out = sim(simIn);
    results = [results; summarize(out, S(k), C(k))]; %#ok<AGROW>
end
writetable(results, 'eq3/feasibility_grid.csv');
% Feasible := average power <= supply capacity AND peak handled by
% [ASSUMED] 100 mF-class local storage — record the storage assumption
% you adopt for peak smoothing; sweep it if marginal.
```

Run three assumption variants (lo/mid/hi of AS-02..AS-07) to bracket. EQ6 is answered by the same grid: for each cadence, report the minimum supply capacity at which the configuration is feasible.

### 4.3 Deliverables to Stage 6

- `eq3/feasibility_grid.csv` (all variants), per-state energy shares, the peak-smoothing assumption adopted, run logs.

---

## 5. EQ4 — Thermal behaviour (Simscape lumped + PDE Toolbox)

**Question:** Does dissipation keep the sealed enclosure within limits at ambient extremes with natural convection only?

### 5.1 Level 1 — Simscape lumped network (`eq4_lumped.slx`)

Network topology (Simscape > Foundation Library > Thermal):

```
[Heat Flow Source P(t)] -> (node: die/PCB mass M1)
   -R_cond1-> (node: internal air mass M2)
   -R_conv_int-> (node: wall mass M3)
   -R_cond_wall-> (node: outer surface)
   -R_conv_ext-> [Temperature Source T_ambient]
```

Element values (compute in an init script, all [ASSUMED]/[GAP-6.2], record each):

```matlab
A_wall = 2*(0.170*0.170) + 4*(0.170*0.117);   % m^2, AS-09 box envelope
R_cond_wall = 0.003 / (0.20 * A_wall);         % AS-10: t/(k*A)
R_conv_ext  = 1 / (h * A_wall);                % AS-11: h in {5,10,15}
R_conv_int  = 1 / (5 * A_pcb);                 % internal still air [ASSUMED h=5]
M1: PCB+module, m*cp ~ 0.15 kg * 900 J/kgK [ASSUMED]
M2: internal air volume * 1.2 kg/m3 * 1005 J/kgK
M3: wall mass from t, A_wall, 1200 kg/m3, 1250 J/kgK [ASSUMED PC]
```

Drive `P(t)` with the dissipation profile exported from the EQ3 run at the operating point under study (worst feasible cadence). Sweep T_ambient per AS-12, add AS-13 solar case as +15 C on the ambient source. Simulate to steady state (run until dT/dt < 0.01 K/min) and capture transient response to a single inference burst.

### 5.2 Level 2 — PDE Toolbox 3D conduction (`eq4_pde.m`)

```matlab
model = createpde('thermal','steadystate');
gm = multicuboid(0.170,0.170,0.117);           % AS-09
model.Geometry = gm;
thermalProperties(model,'ThermalConductivity',0.026);   % internal air proxy
% Wall treated as boundary resistance: combine wall conduction + external
% convection into an effective film coefficient per face:
%   h_eff = 1 / (1/h_ext + t/k_wall)
thermalBC(model,'Face',1:gm.NumFaces,'ConvectionCoefficient',h_eff, ...
          'AmbientTemperature',T_amb);
% Internal heat source: represent the module as a small embedded cuboid
% cell with volumetric heat generation q = P_avg / V_module
internalHeatSource(model, q, 'Cell', moduleCellID);
generateMesh(model,'Hmax',0.01);
R = solve(model);
% Extract: max internal temperature, temperature at module surface,
% field slices for the report.
```

Note the declared simplification: still-air conduction proxy inside (no CFD). Agreement check: Level 1 steady-state internal air temperature vs Level 2 volume-average within a tolerance you declare beforehand (suggest 5 C; record it). Disagreement beyond tolerance triggers the Elmer/OpenFOAM escalation path from Stage 4 — do not tune parameters post hoc to force agreement without logging it.

### 5.3 Deliverables to Stage 6

- `eq4/lumped_steadystate.csv` (T_internal vs ambient x h x power), transient trace PNGs, PDE field images + max/avg temperatures, agreement-check table, run logs.

---

## 6. EQ5 — Backhaul PDR and latency (ns-3)

**Question:** Can Wi-SUN-class backhaul deliver NILM result payloads at acceptable PDR/latency under realistic mesh depth?

### 6.1 Install

```bash
sudo apt update && sudo apt install -y g++ python3 cmake ninja-build git
git clone https://gitlab.com/nsnam/ns-3-dev.git && cd ns-3-dev
git checkout ns-3.42          # or newer release tag
./ns3 configure --enable-examples --enable-tests
./ns3 build
```

### 6.2 Scenario design (declared approximation)

ns-3 mainline models IEEE 802.15.4 via `lr-wpan`; full Wi-SUN FAN (SUN FSK PHY, frequency hopping, FAN routing) is not in mainline. Declared modelling approximation, to be stated verbatim in the run log and the Stage 6 report:

> The 802.15.4g SUN FSK link is approximated by the lr-wpan PHY with data rate parameterization toward 50 kbps and sub-GHz log-distance propagation (exponent 2.7-3.5 [ASSUMED], reference loss set so that PER degrades in the 100-200 m band per AS-16). Multi-hop forwarding uses static routing over 6LoWPAN. Results characterize the technology class, not a certified Wi-SUN stack.

### 6.3 Scenario script skeleton (`scratch/ers-eq5.cc`)

```cpp
// Nodes: N meters in a line/grid feeding one border router (sink).
// Hops swept 1..5 by geometry. Each meter sends AS-01 (256 B) payload
// every T_report seconds (from EQ3 cadence set) over UDP/6LoWPAN/lr-wpan.
#include "ns3/core-module.h"
#include "ns3/lr-wpan-module.h"
#include "ns3/sixlowpan-module.h"
#include "ns3/internet-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"
#include "ns3/propagation-module.h"
#include "ns3/flow-monitor-module.h"
using namespace ns3;

int main(int argc, char** argv) {
  uint32_t nHops = 3; double dist = 120.0; double Treport = 60.0;
  uint32_t seed = 1;
  CommandLine cmd; cmd.AddValue("nHops","hops",nHops);
  cmd.AddValue("dist","node spacing m",dist);
  cmd.AddValue("Treport","report period s",Treport);
  cmd.AddValue("seed","rng seed",seed);
  cmd.Parse(argc,argv);
  RngSeedManager::SetSeed(seed);

  NodeContainer nodes; nodes.Create(nHops+1);
  MobilityHelper mob; mob.SetPositionAllocator("ns3::GridPositionAllocator",
    "DeltaX", DoubleValue(dist), "GridWidth", UintegerValue(nHops+1));
  mob.Install(nodes);

  LrWpanHelper lr;
  Ptr<LogDistancePropagationLossModel> loss =
      CreateObject<LogDistancePropagationLossModel>();
  loss->SetPathLossExponent(3.0);            // [ASSUMED], sweep 2.7-3.5
  lr.SetChannel(CreateObject<SingleModelSpectrumChannel>());
  // attach loss model to the channel, install devices, assign PAN
  NetDeviceContainer devs = lr.Install(nodes);
  lr.CreateAssociatedPan(devs, 0xbeef);

  InternetStackHelper internet; internet.Install(nodes);
  SixLowPanHelper six; NetDeviceContainer sixDevs = six.Install(devs);
  Ipv6AddressHelper ip; ip.SetBase("2001:db8::", Ipv6Prefix(64));
  Ipv6InterfaceContainer ifs = ip.Assign(sixDevs);
  // Static routes hop-by-hop toward node 0 (sink) — Ipv6StaticRoutingHelper

  // Sink app on node 0, UdpClient on node nHops: 256 B, interval Treport
  // FlowMonitor for PDR + delay
  FlowMonitorHelper fm; Ptr<FlowMonitor> mon = fm.InstallAll();
  Simulator::Stop(Seconds(4*3600));
  Simulator::Run();
  mon->SerializeToXmlFile("eq5/flow_h"+std::to_string(nHops)+
      "_s"+std::to_string(seed)+".xml", true, true);
  Simulator::Destroy();
}
```

Build and sweep:

```bash
./ns3 build
for h in 1 2 3 4 5; do for s in 1 2 3 4 5; do
  ./ns3 run "ers-eq5 --nHops=$h --seed=$s --Treport=60"
done; done
```

Parse FlowMonitor XMLs (Python/pandas) into `eq5/results.csv`: columns hop count, seed, spacing, exponent, PDR, mean/95p delay. Sanity gate before accepting runs: single-hop PDR at 50 m spacing should be near-perfect; if not, the loss model reference is misconfigured — fix before sweeping.

### 6.4 Deliverables to Stage 6

- `eq5/results.csv` across hops x seeds x exponent, the verbatim approximation statement, sanity-gate evidence, run logs.

---

## 7. Execution order and completion checklist

1. EQ1 -> select candidate operating rate(s)
2. EQ2 at those rates -> memory fit + INT8 deltas
3. EQ3/EQ6 -> feasibility grid (uses EQ1 cadence, EQ2-informed inference load)
4. EQ4 -> thermal at worst feasible operating point
5. EQ5 -> backhaul at EQ3 cadences

Completion checklist per EQ: results file(s) present, run log complete, seeds recorded, assumption register version noted, deviations documented, figures exported. Deliver the `eq*/` folders, `runlogs/`, and `params/assumptions.csv` back for Stage 6 Evidence Interpretation.

*End of Stage 5 execution guide. No results are contained in this document.*
