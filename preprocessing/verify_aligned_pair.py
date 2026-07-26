from pathlib import Path

import numpy as np
import pandas as pd
from scipy.io import loadmat


DATA_FILE = Path(r"C:\Projects\NILM_Stage5\data\building1_boiler_pair.mat")


print("=" * 70)
print("Aligned Dataset Verification")
print("=" * 70)

mat = loadmat(DATA_FILE)

timestamps = mat["timestamp"].flatten()
aggregate = mat["aggregate"].flatten()
target = mat["target"].flatten()

df = pd.DataFrame(
    {
        "aggregate": aggregate,
        "target": target
    },
    index=pd.to_datetime(timestamps, unit="ns", utc=True)
)

print(f"\nSamples              : {len(df):,}")
print(f"Start Time           : {df.index.min()}")
print(f"End Time             : {df.index.max()}")

print("\nTimestamp Checks")
print("-" * 70)
print(f"Monotonic Increasing : {df.index.is_monotonic_increasing}")
print(f"Duplicate Timestamps : {df.index.duplicated().sum():,}")

print("\nMissing Values")
print("-" * 70)
print(df.isna().sum())

print("\nAggregate Statistics (Watts)")
print("-" * 70)
print(df["aggregate"].describe())

print("\nBoiler Statistics (Watts)")
print("-" * 70)
print(df["target"].describe())

print("\nNegative Values")
print("-" * 70)
print(f"Aggregate : {(df['aggregate'] < 0).sum():,}")
print(f"Boiler    : {(df['target'] < 0).sum():,}")

print("\nZero Values")
print("-" * 70)
print(f"Aggregate : {(df['aggregate'] == 0).sum():,}")
print(f"Boiler    : {(df['target'] == 0).sum():,}")

print("\nMemory Usage")
print("-" * 70)
print(f"{df.memory_usage(deep=True).sum() / (1024**2):.2f} MB")

print("\nVerification Complete.")
print("=" * 70)