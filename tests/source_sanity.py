from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist" / "MistUI.lua"
text = DIST.read_text(encoding="utf-8")

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
        i += 1
        continue
    if state == "long_comment":
        if text.startswith("]]", i):
            state = "normal"; i += 2; continue
        i += 1
        continue
    if state == "string":
        if ch == "\\":
            i += 2
            continue
        if ch == quote:
            state = "normal"
        i += 1
        continue
    if state == "long_string":
        if text.startswith("]]", i):
            state = "normal"; i += 2; continue
        i += 1
        continue

    if ch == "-" and nxt == "-":
        if text.startswith("--[[", i):
            state = "long_comment"; i += 4; continue
        state = "line_comment"; i += 2; continue
    if ch in ('"', "'"):
        state = "string"; quote = ch; i += 1; continue
    if text.startswith("[[", i):
        state = "long_string"; i += 2; continue

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
if "\x00" in text:
    print("FAIL: NUL byte in distribution")
    sys.exit(1)
if not text.rstrip().endswith("return Library"):
    print("FAIL: distribution does not end with return Library")
    sys.exit(1)

# Catch CreateWindow runtime-order bugs: table methods are assigned at runtime in Luau
# and cannot be called from the top-level initializer before their definition executes.
import re
window_source = (ROOT / "src" / "03_window_settings.luau.part").read_text(encoding="utf-8").splitlines()
method_defs: dict[str, int] = {}
for line_no, source_line in enumerate(window_source, 1):
    stripped = source_line.strip()
    if stripped.startswith("function self_:"):
        name = stripped.split("function self_:", 1)[1].split("(", 1)[0]
        method_defs.setdefault(name, line_no)

order_errors: list[tuple[int, str, int]] = []
for line_no, source_line in enumerate(window_source, 1):
    # Exactly one indentation level means the call executes directly while CreateWindow runs.
    if not source_line.startswith("    ") or source_line.startswith("        "):
        continue
    if source_line.strip().startswith("function self_:"):
        continue
    for match in re.finditer(r"self_:([A-Za-z_][A-Za-z0-9_]*)\s*\(", source_line):
        name = match.group(1)
        definition_line = method_defs.get(name)
        if definition_line is not None and line_no < definition_line:
            order_errors.append((line_no, name, definition_line))

if order_errors:
    for line_no, name, definition_line in order_errors:
        print(f"FAIL: CreateWindow calls self_:{name} at source line {line_no} before it is defined at {definition_line}")
    sys.exit(1)

print("MistUI source lexical sanity passed")
print("Characters:", len(text), "Lines:", len(text.splitlines()))
