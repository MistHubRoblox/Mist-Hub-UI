from __future__ import annotations

import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist" / "MistUI.lua"
text = DIST.read_text(encoding="utf-8")

errors: list[str] = []

def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)

require(text.rstrip().endswith("return Library"), "dist must end in return Library")
require('Library.Version = "4.0.0"' in text, "version must be 4.0.0")
require("Library.SchemaVersion = 5" in text, "schema must remain 5 for config compatibility")
require("function cardApi:Add(controlType, config)" in text, "modern Card:Add API missing")
require("function Library:BindTheme(" in text, "Theme Binder missing")
require("function Library:_RebindThemeFromCurrentValues(" in text, "automatic theme rebinding missing")
require("function self_:RegisterKeybindDefinition(" in text, "declarative keybind registry missing")
require("function self_:RegisterKeybindDefinitions(" in text, "declarative keybind batch registry missing")
require("function self_:_ApplyBreakpointLayout(" in text, "adaptive breakpoint layout missing")
require("function Library:LoadRemoteIcons()" in text, "remote icon loader missing")

# v3.1 component parity retained in the v4 stable release.
for symbol in (
    "function cardApi:AddInput(",
    "function cardApi:AddColorPicker(",
    "function cardApi:AddViewport(",
    "function cardApi:AddVideo(",
    "function cardApi:AddUIPassthrough(",
    "function cardApi:AddDependencyBox(",
    "function self_:RegisterCommand(",
    "function self_:SearchCommands(",
    "function self_:OpenCommandPalette(",
    "function self_:SetMobileToggleEnabled(",
    "function self_:SetResizable(",
):
    require(symbol in text, f"component feature missing: {symbol}")

require('"Press"' in text and 'modeCycle = { "Toggle", "Hold", "Press", "Always" }' in text,
        "Press keybind mode missing")
require("DefaultModifiers" in text and "MouseButton1" in text,
        "keybind chord/mouse support missing")
require("FormatDisplayValue" in text and "SetDisabledValues" in text and "SetValueImages" in text,
        "advanced DropdownEx surface missing")
require("SpecialType" in text and "EnablePlayerImages" in text and "GetResolvedValues" in text,
        "advanced special/multi dropdown surface missing")
require("DragSelect" in text and "dragState" in text, "multi-dropdown drag selection missing")
require("SetValueRGB" in text and "SetHSVFromRGB" in text and "GetHSV" in text,
        "advanced ColorPicker RGB/HSV surface missing")

# v4 quality/stability surface.
for symbol in (
    "function Library:SafeCallContext(",
    "function Library:Boundary(",
    "function Library:GetDiagnostics(",
    "function self_:ValidateConfigData(",
    "function self_:BeginConfigTransaction(",
    "function self_:RollbackConfigTransaction(",
    "function self_:Doctor(",
    "function self_:RunQualitySuite(",
    "function self_:CreateLeakSnapshot(",
    "function self_:CompareLeakSnapshots(",
    "function self_:SetProfilerEnabled(",
    "function self_:Profile(",
    "function self_:OpenDebugPanel(",
    "function self_:GetLastUnloadReport(",
    "function self_:CaptureLayoutSnapshot(",
    "function self_:CompareLayoutSnapshots(",
):
    require(symbol in text, f"v4 quality feature missing: {symbol}")

for capability in (
    "QualitySuite", "Doctor", "LeakDiagnostics", "Profiler", "DebugPanel",
    "ConfigTransactions", "ConfigValidation", "ErrorBoundaries", "APIContracts",
    "VirtualizedLargeLists", "LayoutSnapshots",
):
    require(f"{capability} = true" in text, f"v4 capability missing: {capability}")

require("ComponentsByFlag is strong" in text, "strong-registry unload cleanup guard missing")
require("This config was created by a newer version and cannot be loaded here." in text, "config validation guard missing")

# Compatibility: the generic Dropdown name must continue to use the legacy implementation.
require('elseif lower == "dropdown" then\n                    result = cardApi:AddDropdown(' in text,
        "Card:Add('Dropdown') compatibility route changed")

require("FUNCTION_INFO_DESCRIPTIONS" not in text, "app-specific Function Info table leaked into library")
require("local ENABLE_UI_TEST" not in text, "development UI leaked into release")
require(text.count("TweenService:Create") == 1, "all motion should pass through the central tween helper")

# A release must not instantiate its own application after framework definition.
without_comments = re.sub(r"--\[\[.*?\]\]", "", text, flags=re.S)
without_comments = re.sub(r"--[^\n]*", "", without_comments)
require("local Window = Library:CreateWindow" not in without_comments, "release contains application bootstrap")

# Every currently used internal literal icon must have a local fallback.
used = set(re.findall(r'buildIcon\([^\n]*?"([a-z0-9-]+)"', text))
fallback = set(re.findall(r'FALLBACK_ICONS\["([a-z0-9-]+)"\]', text))
required_internal = used | {
    "check", "chevron-right", "circle", "info", "keyboard",
    "refresh-cw", "settings", "triangle-alert", "x",
}
missing = sorted(required_internal - fallback)
require(not missing, "missing local icon fallback(s): " + ", ".join(missing))

# The checked-in dist must be exactly the deterministic concatenation of src fragments.
parts = sorted((ROOT / "src").glob("*.luau.part"))
expected = "".join(part.read_text(encoding="utf-8") for part in parts)
require(expected == text, "dist is not byte-for-byte reproducible from src fragments")

# Docs/types must expose the new public surface.
types = (ROOT / "types" / "MistUI.types.luau").read_text(encoding="utf-8")
api = (ROOT / "docs" / "API.md").read_text(encoding="utf-8")
for name in (
    "ColorPicker", "Viewport", "Video", "UIPassthrough", "DependencyBox",
    "OpenCommandPalette", "SetMobileToggleEnabled", "SetResizable", "DefaultModifiers", "SpecialType",
    "Doctor", "RunQualitySuite", "CreateLeakSnapshot", "CompareLeakSnapshots", "OpenDebugPanel",
    "ValidateConfigData", "BeginConfigTransaction", "RollbackConfigTransaction", "SafeCallContext",
):
    require(name in types, f"types missing public component surface: {name}")
    require(name in api, f"API docs missing public component surface: {name}")

for type_name in (
    "Diagnostics", "ProfilerSnapshot", "LeakSnapshot", "LeakComparison",
    "LayoutSnapshotItem", "LayoutComparison", "DoctorReport", "QualityReport",
    "AdvancedDropdown", "MultiDropdown", "VirtualListComponent",
):
    require(f"export type {type_name}" in types, f"strict types missing v4 quality type: {type_name}")


# Public type-declaration coverage: every colon-method declared on the main
# Library/Window/Card surfaces should at least be named in the strict contract.
def public_method_names(pattern: str) -> set[str]:
    return {name for name in re.findall(pattern, text) if not name.startswith("_")}

for surface, pattern in (
    ("Library", r"function Library:([A-Za-z0-9_]+)\s*\("),
    ("Window", r"function self_:([A-Za-z0-9_]+)\s*\("),
    ("Card", r"function cardApi:([A-Za-z0-9_]+)\s*\("),
):
    missing_types = sorted(name for name in public_method_names(pattern) if name not in types)
    require(not missing_types, f"types omit public {surface} methods: {', '.join(missing_types)}")

comparison = (ROOT / "docs" / "COMPARISON.md").read_text(encoding="utf-8")
require("Linoria" in comparison and "Obsidian" in comparison, "comparison document missing")
require((ROOT / ".github" / "workflows" / "ci.yml").exists(), "CI workflow missing")
require((ROOT / "tests" / "public_api_snapshot.json").exists(), "public API freeze snapshot missing")
require((ROOT / "tests" / "quality_contract.py").exists(), "API compatibility test missing")
require((ROOT / "tests" / "source_sanity.py").exists(), "source lexical sanity test missing")
require((ROOT / "tests" / "runtime_quality.luau").exists(), "runtime quality suite missing")
require((ROOT / "tests" / "runtime_stress.luau").exists(), "runtime stress suite missing")
require((ROOT / "tests" / "runtime_benchmark.luau").exists(), "runtime benchmark missing")
require((ROOT / "docs" / "STABILITY.md").exists(), "stability policy missing")
require((ROOT / "docs" / "COMPATIBILITY.md").exists(), "compatibility matrix missing")
require((ROOT / "dist" / "SHA256SUMS.txt").exists(), "release checksum manifest missing")

if errors:
    for error in errors:
        print("FAIL:", error)
    sys.exit(1)

print("MistUI static audit passed")
print("Lines:", len(text.splitlines()))
print("SHA-256:", hashlib.sha256(text.encode()).hexdigest())
print("Internal literal icons:", ", ".join(sorted(used)))
