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

delta = df["timestamp"].diff().dropna()

print(delta.describe())

print("\nMost common intervals:")
print(delta.value_counts().head(10))