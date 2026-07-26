from pathlib import Path
import yaml

DATASET_DIR = Path(r"C:\Projects\NILM_Stage5\datasets\ukdale\metadata")

TARGET_KEYWORDS = [
    "ev",
    "electric vehicle",
    "charger",
    "boiler",
    "water heater",
    "immersion",
    "hvac",
    "air conditioner",
    "air conditioning",
    "heat pump",
    "heating"
]

for yaml_file in sorted(DATASET_DIR.glob("building*.yaml")):

    with open(yaml_file, "r", encoding="utf-8") as f:
        metadata = yaml.safe_load(f)

    print(f"\n===== {yaml_file.name} =====")

    appliances = metadata.get("appliances", [])

    for appliance in appliances:

        text = " ".join(
            str(appliance.get(k, "")).lower()
            for k in ["type", "original_name", "description"]
        )

        if any(keyword in text for keyword in TARGET_KEYWORDS):

            print(
                f"Meter(s): {appliance.get('meters')} | "
                f"Type: {appliance.get('type')} | "
                f"Original: {appliance.get('original_name')}"
            )