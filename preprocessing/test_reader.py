from pathlib import Path

from ukdale import UKDALEReader

project = Path(r"C:\Projects\NILM_Stage5")

reader = UKDALEReader(
    project / "datasets" / "ukdale" / "ukdale.h5"
)

df = reader.read_meter(
    building=1,
    meter=2,
)

print(df.head())

print()

print(df.info())

print()

print(df.describe())