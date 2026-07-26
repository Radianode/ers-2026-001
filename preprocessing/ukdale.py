from pathlib import Path

import pandas as pd
import tables


class UKDALEReader:
    """
    High-performance reader for the UK-DALE dataset.
    """

    def __init__(self, h5_path):
        self.h5_path = Path(h5_path)

    def read_meter(self, building, meter):

        node = f"/building{building}/elec/meter{meter}/table"

        with tables.open_file(self.h5_path, mode="r") as h5:

            table = h5.get_node(node)

            # Read the entire table at once
            data = table.read()

        timestamps = pd.to_datetime(
            data["index"],
            unit="ns",
            utc=True
        )

        power = data["values_block_0"][:, 0]

        df = pd.DataFrame({
            "timestamp": timestamps,
            "power": power
        })

        return df