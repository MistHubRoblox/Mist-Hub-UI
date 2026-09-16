from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "examples" / "MistUI_TestLab.lua"
text = TARGET.read_text(encoding="utf-8")

stack: list[tuple[str, int]] = []
pairs = {')': '(', ']': '[', '}': '{'}
opens = set(pairs.values())
i = 0
line = 1
state = "normal"
quote = ""

while i < len(text):
    ch = text[i]
    nxt = text[i + 1] if i + 1 < len(text) else ""
    if ch == "\n":
        line += 1

    if state == "line_comment":
        if ch == "\n": state = "normal"
        i += 1; continue
    if state == "long_comment":
        if text.startswith("]]", i): state = "normal"; i += 2; continue
        i += 1; continue
    if state == "string":
        if ch == "\\": i += 2; continue
        if ch == quote: state = "normal"
        i += 1; continue
    if state == "long_string":
        if text.startswith("]]", i): state = "normal"; i += 2; continue
        i += 1; continue

    if ch == "-" and nxt == "-":
        if text.startswith("--[[", i): state = "long_comment"; i += 4; continue
        state = "line_comment"; i += 2; continue
    if ch in ('"', "'"):
        state = "string"; quote = ch; i += 1; continue
    if text.startswith("[[", i): state = "long_string"; i += 2; continue

    if ch in opens:
        stack.append((ch, line))
    elif ch in pairs:
        if not stack or stack[-1][0] != pairs[ch]:
            print(f"FAIL: mismatched delimiter {ch!r} on line {line}")
            sys.exit(1)
        stack.pop()
    i += 1

if state in {"string", "long_string", "long_comment"}:
    print("FAIL: unterminated lexical state:", state)
    sys.exit(1)
if stack:
    print("FAIL: unclosed delimiter(s):", stack[-10:])
    sys.exit(1)
if not text.rstrip().endswith("return Library"):
    print("FAIL: Test Lab must end with return Library")
    sys.exit(1)

required = [
    "Tests", "Basic", "Selectors", "Layout", "Media", "Activity", "Overlays", "System",
    "Run Doctor", "Run Quality Suite", "CreateActivity",
]
missing = [item for item in required if item not in text]
if missing:
    print("FAIL: Test Lab missing expected QA coverage:", missing)
    sys.exit(1)

print("MistUI Test Lab lexical/coverage sanity passed")
print("Lines:", len(text.splitlines()))
