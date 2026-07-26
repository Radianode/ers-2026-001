from pathlib import Path
import yaml
import csv

# ------------------------------------------------------------------
# Project Paths
# ------------------------------------------------------------------

project_root = Path(r"C:\Projects\NILM_Stage5")

metadata_dir = project_root / "datasets" / "ukdale" / "metadata"

output_csv = project_root / "matlab" / "results" / "appliance_mapping.csv"

# ------------------------------------------------------------------
# Parse all buildings
# ------------------------------------------------------------------

rows = []

for yaml_file in sorted(metadata_dir.glob("building*.yaml")):

    building = yaml_file.stem

    with open(yaml_file, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)

    elec = data.get("elec_meters", {})
    appliances = data.get("appliances", [])

    meter_lookup = {}

    for appliance in appliances:

        app_type = appliance.get("type", "")

        instance = appliance.get("instance", "")

        meters = appliance.get("meters", [])

        room = appliance.get("room", "")

        for meter in meters:

            meter_lookup.setdefault(meter, []).append({
                "type": app_type,
                "instance": instance,
                "room": room
            })

    for meter_id in sorted(elec.keys()):

        if meter_id in meter_lookup:

            for app in meter_lookup[meter_id]:

                rows.append([
                    building,
                    meter_id,
                    app["type"],
                    app["instance"],
                    app["room"]
                ])

        else:

            rows.append([
                building,
                meter_id,
                "",
                "",
                ""
            ])

# ------------------------------------------------------------------
# Export CSV
# ------------------------------------------------------------------

output_csv.parent.mkdir(parents=True, exist_ok=True)

with open(output_csv, "w", newline="", encoding="utf-8") as f:

    writer = csv.writer(f)

    writer.writerow([
        "Building",
        "Meter",
        "Appliance",
        "Instance",
        "Room"
    ])

    writer.writerows(rows)

print("------------------------------------------------")
print(f"Rows exported : {len(rows)}")
print(f"Output        : {output_csv}")
print("Done.")