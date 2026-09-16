from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist" / "MistUI.lua"
TESTLAB = ROOT / "examples" / "MistUI_TestLab.lua"
EXAMPLE = ROOT / "examples" / "example.lua"

text = DIST.read_text(encoding="utf-8")

# The public distribution must remain a pure library and must not bootstrap demo/test UI.
if not text.rstrip().endswith("return Library"):
    print("FAIL: dist/MistUI.lua is not a pure library return")
    sys.exit(1)

for forbidden in (
    "full test lab ready",
    "full test standalone",
    "Show Live Auto Boss HUD",
    "Run Quality Suite",
    "Reset Test Flags",
):
    if forbidden in text:
        print(f"FAIL: dev/Test Lab text leaked into dist/MistUI.lua: {forbidden!r}")
        sys.exit(1)

# Inspect the normal Settings-construction region only. Internal implementation may still
# contain diagnostic APIs elsewhere; they simply must not be surfaced to ordinary players.
start = text.find("-- SETTINGS MODAL")
end = text.find("-- CONFIG", start + 1)
if end == -1:
    # Config is part of Settings in this build; use the end of the settings function area.
    end = text.find("function self_:CreateTopTab", start + 1)
settings = text[start:end if end != -1 else len(text)]

# Only inspect visible label/button/section arguments, not implementation helper names.
visible_lines = []
for line in settings.splitlines():
    stripped = line.strip()
    if any(token in stripped for token in (
        "settingsSection(", "settingsLabel(", "settingsButton(",
        "settingsValueRow(", "settingsToggleRow(", "settingsDropdownRow(",
        'Text = "', 'Title = "', 'Content = "',
    )):
        visible_lines.append(stripped)
visible = "\n".join(visible_lines).lower()

for term in (
    "doctor", "profiler", "quality suite", "leak", "schema", "debug panel",
    "file api", "storage adapter", "executor file api", "test lab",
):
    if term in visible:
        print(f"FAIL: internal/dev term is visible in normal Settings: {term!r}")
        sys.exit(1)

if not TESTLAB.exists():
    print("FAIL: examples/MistUI_TestLab.lua missing")
    sys.exit(1)
if not EXAMPLE.exists():
    print("FAIL: examples/example.lua missing")
    sys.exit(1)

# Test Lab must remain outside dist so it cannot be mistaken for the player build.
for path in (ROOT / "dist").iterdir():
    if "test" in path.name.lower() or "standalone" in path.name.lower():
        print(f"FAIL: dev/test artifact leaked into dist/: {path.name}")
        sys.exit(1)

print("MistUI player-surface audit passed")
print("Visible internal/dev terms in normal Settings: none")
