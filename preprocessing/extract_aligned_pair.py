from pathlib import Path

import numpy as np
import pandas as pd
import tables
from scipy.io import savemat


DATASET = Path(r"C:\Projects\NILM_Stage5\datasets\ukdale\ukdale.h5")
OUTPUT = Path(r"C:\Projects\NILM_Stage5\data")

OUTPUT.mkdir(parents=True, exist_ok=True)


def read_meter(building, meter):
    node = f"/building{building}/elec/meter{meter}/table"

    with tables.open_file(DATASET, mode="r") as h5:
        table = h5.get_node(node)
        data = table.read()

    timestamps = pd.to_datetime(
        data["index"],
        unit="ns",
        utc=True
    )

    power = data["values_block_0"][:, 0]

    df = pd.DataFrame(
        {
            "power": power
        },
        index=timestamps
    )

    return df.sort_index()


print("Reading aggregate...")
aggregate = read_meter(1, 1)

print("Reading boiler...")
boiler = read_meter(1, 2)

print("Resampling to 6-second grid...")

aggregate = (
    aggregate
    .resample("6s")
    .mean()
    .ffill(limit=3)
)

boiler = (
    boiler
    .resample("6s")
    .mean()
    .ffill(limit=3)
)

aligned = aggregate.join(
    boiler,
    how="inner",
    lsuffix="_aggregate",
    rsuffix="_boiler"
)

aligned = aligned.dropna()

print("\nFirst five aligned samples:")
print(aligned.head())

print("\nDataset information:")
print(aligned.info())

savemat(
    OUTPUT / "building1_boiler_pair.mat",
    {
        "timestamp": aligned.index.astype("int64").to_numpy(),
        "aggregate": aligned["power_aggregate"].to_numpy(dtype=np.float32),
        "target": aligned["power_boiler"].to_numpy(dtype=np.float32)
    }
)

print("\nExport completed successfully.")
print(f"Saved to : {OUTPUT / 'building1_boiler_pair.mat'}")
print(f"Samples  : {len(aligned):,}")