from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist" / "MistUI.lua"
SNAPSHOT = ROOT / "tests" / "public_api_snapshot.json"


def extract(text: str) -> dict[str, list[str]]:
    patterns = {
        "Library": r"function Library:([A-Za-z0-9_]+)\s*\(",
        "Window": r"function self_:([A-Za-z0-9_]+)\s*\(",
        "Card": r"function cardApi:([A-Za-z0-9_]+)\s*\(",
    }
    result: dict[str, list[str]] = {}
    for surface, pattern in patterns.items():
        names = {name for name in re.findall(pattern, text) if not name.startswith("_")}
        result[surface] = sorted(names)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify the frozen MistUI v4 public API baseline")
    parser.add_argument("--update", action="store_true", help="replace the API snapshot with the current distribution")
    args = parser.parse_args()

    current = extract(DIST.read_text(encoding="utf-8"))
    if args.update:
        SNAPSHOT.write_text(json.dumps(current, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print("Updated", SNAPSHOT)
        return 0

    if not SNAPSHOT.exists():
        print("FAIL: public API snapshot missing; run tests/quality_contract.py --update")
        return 1

    baseline = json.loads(SNAPSHOT.read_text(encoding="utf-8"))
    failed = False
    for surface in ("Library", "Window", "Card"):
        expected = set(baseline.get(surface, []))
        actual = set(current.get(surface, []))
        removed = sorted(expected - actual)
        added = sorted(actual - expected)
        if removed:
            failed = True
            print(f"FAIL: removed frozen {surface} APIs: {', '.join(removed)}")
        if added:
            print(f"INFO: new {surface} APIs not yet frozen: {', '.join(added)}")

    if failed:
        return 1
    print("MistUI v4 public API compatibility contract passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
