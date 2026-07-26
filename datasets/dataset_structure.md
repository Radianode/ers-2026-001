# Dataset Structure

## UK-DALE

- **Name:** UK-DALE (UK Domestic Appliance-Level Electricity)
- **Publisher:** UK Energy Research Centre Energy Data Centre (UKERC EDC)
- **Creator:** Jack Kelly, Imperial College London
- **Buildings:** 5 UK homes
- **Sampling:** whole-home and appliance-level power demand, recorded every 6 seconds (plus 16 kHz whole-home for buildings 1, 2 and 5)
- **License:** Creative Commons Attribution 4.0 International (CC BY 4.0)
- **Citation:** Kelly, J. & Knottenbelt, W. *The UK-DALE dataset, domestic appliance-level electricity demand and whole-house demand from five UK homes.* Scientific Data 2:150007 (2015). DOI: [10.1038/sdata.2015.7](https://doi.org/10.1038/sdata.2015.7)

## What's included in this repository

```
datasets/ukdale/
└── metadata/
    ├── dataset.yaml          # dataset-level metadata (source, license, citation)
    ├── meter_devices.yaml    # meter hardware specifications
    ├── building1.yaml        # per-building appliance/meter layout
    ├── building2.yaml
    ├── building3.yaml
    ├── building4.yaml
    └── building5.yaml
```

These metadata files follow the [NILM Metadata schema](https://github.com/nilmtk/nilm_metadata) and are used by the preprocessing scripts to identify and align target channels.

## What's not included

The raw measurement data (`ukdale.h5`, several GB) is not committed to this repository. Download it separately — see [../docs/reproducibility.md](../docs/reproducibility.md) — and place it at:

```
datasets/ukdale/ukdale.h5
```
