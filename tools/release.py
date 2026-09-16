from __future__ import annotations

import argparse
import hashlib
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist" / "MistUI.lua"
TESTLAB = ROOT / "examples" / "MistUI_TestLab.lua"
EXAMPLE = ROOT / "examples" / "example.lua"
SUMS = ROOT / "dist" / "SHA256SUMS.txt"
RELEASE = ROOT / "release"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expected_sum_line() -> str:
    # dist/ is intentionally player-facing only.
    return f"{digest(DIST)}  MistUI.lua\n"


def package() -> tuple[Path, Path, Path, Path]:
    RELEASE.mkdir(exist_ok=True)
    library = RELEASE / "MistUI.lua"
    testlab = RELEASE / "MistUI_TestLab.lua"
    example = RELEASE / "example.lua"
    library.write_bytes(DIST.read_bytes())
    testlab.write_bytes(TESTLAB.read_bytes())
    example.write_bytes(EXAMPLE.read_bytes())

    archive = RELEASE / "MistUI_v4.0.0_GitHub.zip"
    excluded_parts = {"__pycache__", ".git", "release"}
    files = [
        p for p in ROOT.rglob("*")
        if p.is_file()
        and not any(part in excluded_parts for part in p.relative_to(ROOT).parts)
        and p.suffix != ".pyc"
    ]
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for path in sorted(files, key=lambda p: p.as_posix()):
            rel = Path("MistUI_v4.0.0_Stable") / path.relative_to(ROOT)
            info = zipfile.ZipInfo(rel.as_posix(), date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            zf.writestr(info, path.read_bytes())
    return library, testlab, example, archive


def main() -> int:
    parser = argparse.ArgumentParser(description="MistUI deterministic release helper")
    parser.add_argument("--check", action="store_true", help="verify checked-in library checksum and release layout")
    parser.add_argument("--package", action="store_true", help="create deterministic final artifacts")
    args = parser.parse_args()

    expected = expected_sum_line()
    if args.check:
        if not SUMS.exists() or SUMS.read_text(encoding="utf-8") != expected:
            print("FAIL: dist/SHA256SUMS.txt is stale; run python tools/release.py")
            return 1
        if not TESTLAB.exists() or not EXAMPLE.exists():
            print("FAIL: examples/MistUI_TestLab.lua or examples/example.lua is missing")
            return 1
        forbidden = [p.name for p in (ROOT / "dist").iterdir() if "standalone" in p.name.lower() or "test" in p.name.lower()]
        if forbidden:
            print("FAIL: dev artifacts present in dist/:", forbidden)
            return 1
        print("Release layout/checksum verified:", expected.strip())
        return 0

    SUMS.write_text(expected, encoding="utf-8")
    print("Wrote", SUMS, expected.strip())
    if args.package:
        library, testlab, example, archive = package()
        print("Library:", library, digest(library))
        print("Test Lab:", testlab, digest(testlab))
        print("Example:", example, digest(example))
        print("GitHub zip:", archive, digest(archive))
    return 0


if __name__ == "__main__":
    sys.exit(main())
