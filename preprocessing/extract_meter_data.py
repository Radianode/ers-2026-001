from pathlib import Path
import tables

project_root = Path(r"C:\Projects\NILM_Stage5")

h5_file = project_root / "datasets" / "ukdale" / "ukdale.h5"

with tables.open_file(h5_file, mode="r") as h5:

    table = h5.get_node("/building1/elec/meter2/table")

    print(table)

    print("\nColumn names:")
    print(table.colnames)

    print("\nFirst five rows:\n")

    for row in table.iterrows(stop=5):
        print(row.fetch_all_fields())