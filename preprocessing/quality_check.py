from pathlib import Path

from ukdale import UKDALEReader

project = Path(r"C:\Projects\NILM_Stage5")

reader = UKDALEReader(
    project / "datasets" / "ukdale" / "ukdale.h5"
)

df = reader.read_meter(
    building=1,
    meter=2
)

print("=" * 60)
print("UK-DALE DATA QUALITY REPORT")
print("=" * 60)

print(f"Rows                : {len(df):,}")
print(f"Columns             : {len(df.columns)}")

print("\nTime Range")
print("--------------------------------------")
print(df["timestamp"].min())
print(df["timestamp"].max())

print("\nMissing Values")
print("--------------------------------------")
print(df.isna().sum())

print("\nDuplicate Timestamps")
print("--------------------------------------")
duplicates = df["timestamp"].duplicated().sum()
print(duplicates)

print("\nPower Statistics")
print("--------------------------------------")
print(df["power"].describe())

print("\nNegative Power Samples")
print("--------------------------------------")
print((df["power"] < 0).sum())

print("\nZero Power Samples")
print("--------------------------------------")
print((df["power"] == 0).sum())

print("\nMaximum Power")
print("--------------------------------------")
print(df["power"].max())