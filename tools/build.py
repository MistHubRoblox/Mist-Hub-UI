from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
TARGET = ROOT / "dist" / "MistUI.lua"


def build_text() -> tuple[str, list[Path]]:
    parts = sorted(SRC.glob("*.luau.part"))
    if not parts:
        raise SystemExit("No source fragments found under src/")
    output = "".join(part.read_text(encoding="utf-8") for part in parts)
    return output, parts


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the MistUI single-file distribution")
    parser.add_argument("--check", action="store_true", help="verify dist/MistUI.lua is byte-for-byte reproducible")
    args = parser.parse_args()

    output, parts = build_text()
    data = output.encode("utf-8")

    if args.check:
        if not TARGET.exists():
            print(f"FAIL: {TARGET} does not exist")
            return 1
        current = TARGET.read_bytes()
        if current != data:
            print("FAIL: dist/MistUI.lua is stale; run: python tools/build.py")
            print("expected sha256:", sha256(data))
            print("actual   sha256:", sha256(current))
            return 1
        print(f"Build reproducibility check passed ({len(parts)} fragments).")
        print("SHA-256:", sha256(data))
        return 0

    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_bytes(data)
    print(f"Built {TARGET} from {len(parts)} ordered fragments.")
    print("Lines:", len(output.splitlines()))
    print("SHA-256:", sha256(data))
    return 0


if __name__ == "__main__":
    sys.exit(main())
