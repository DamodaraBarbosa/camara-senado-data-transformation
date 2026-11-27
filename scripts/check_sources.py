import json
import sys

import yaml

with open("catalog/raw_tables.json", encoding="utf-8") as f:
    expected = {t["table"] for t in json.load(f)["tables"]}
with open("models/sources/raw.yml", encoding="utf-8") as f:
    raw = next(s for s in yaml.safe_load(f)["sources"] if s["name"] == "raw")
declared = {t["name"] for t in raw["tables"]}

unknown = declared - expected
missing = expected - declared
print("fora do manifesto:", sorted(unknown))
print("sem source:", sorted(missing))
sys.exit(1 if unknown or (missing and "--allow-missing" not in sys.argv) else 0)
