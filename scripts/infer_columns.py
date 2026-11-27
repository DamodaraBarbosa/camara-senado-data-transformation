import json
import sys


def merge(a, b):
    if a is None:
        return b
    if b is None or a == b:
        return a
    if isinstance(a, dict) and isinstance(b, dict):
        return {k: merge(a.get(k), b.get(k)) for k in {**a, **b}}
    if {a if isinstance(a, str) else "", b if isinstance(b, str) else ""} == {"bigint", "double"}:
        return "double"
    return "string"


def infer(value):
    if value is None:
        return None
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "bigint"
    if isinstance(value, float):
        return "double"
    if isinstance(value, dict) and value:
        return {k: infer(v) for k, v in value.items()}
    return "string"


def render(t):
    if isinstance(t, dict):
        return "struct<" + ",".join(f"{k}:{render(v)}" for k, v in t.items()) + ">"
    return t or "string"


columns = {}
with open(sys.argv[1], encoding="utf-8") as f:
    for line in f:
        if line.strip():
            for key, value in json.loads(line).items():
                columns[key] = merge(columns.get(key), infer(value))

for name, kind in columns.items():
    print(f'          - name: "{name}"\n            data_type: "{render(kind)}"')
