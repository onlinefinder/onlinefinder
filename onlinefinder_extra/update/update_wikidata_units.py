#!/usr/bin/env python
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Fetch units from :origin:`olf/engines/wikidata.py` engine.

Output file: :origin:`olf/data/wikidata_units.json` (:origin:`CI Update data
...  <.github/workflows/data-update.yml>`).

"""

import json

from olf.engines import wikidata, set_loggers
from olf.data import data_dir
from olf.wikidata_units import fetch_units

DATA_FILE = data_dir / 'wikidata_units.json'
set_loggers(wikidata, 'wikidata')


if __name__ == '__main__':
    with DATA_FILE.open('w', encoding="utf8") as f:
        json.dump(fetch_units(), f, indent=4, sort_keys=True, ensure_ascii=False)
