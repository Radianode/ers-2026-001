from pathlib import Path

import pandas as pd
import tables


DATASET = Path(r"C:\Projects\NILM_Stage5\datasets\ukdale\ukdale.h5")
OUTPUT_DIR = Path(r"C:\Projects\NILM_Stage5\eq1")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

OUTPUT_CSV = OUTPUT_DIR / "house1_pairs.csv"


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

    return pd.DataFrame(
        {"power": power},
        index=timestamps
    ).sort_index()


print("Reading aggregate meter...")
aggregate = read_meter(1, 1)

print("Reading boiler meter...")
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

pairs = aggregate.join(
    boiler,
    how="inner",
    lsuffix="_agg",
    rsuffix="_app"
).dropna()

export = pd.DataFrame({
    "t": (pairs.index.view("int64") // 1_000_000_000).astype("int64"),
    "agg_W": pairs["power_agg"].astype("float32"),
    "app_W": pairs["power_app"].astype("float32")
})

print("Writing CSV...")

export.to_csv(
    OUTPUT_CSV,
    index=False
)

print("\nExport complete.")
print(f"File    : {OUTPUT_CSV}")
print(f"Rows    : {len(export):,}")
print(f"Columns : {list(export.columns)}")

print("\nFirst five rows:")
print(export.head())