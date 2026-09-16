# MistUI v4.0.0 Stable

MistUI is a Roblox/Luau UI framework built for two equal-quality distribution targets:

- **GitHub/source package** — modular build fragments, strict public types, docs, examples, audits and CI.
- **Executor/library build** — one self-contained `dist/MistUI.lua` file with no demo/application bootstrap.

The release is a **pure library**: loading it returns `Library`; it does not create a window until `CreateWindow` is called.

## Quick start

```lua
local MistUI = loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL/dist/MistUI.lua"))()
local Window = MistUI:CreateWindow({
    Title = "My Interface",
    Responsive = true,
})
```

## Why v4.0 Stable

v3.1 closed the major feature/API gaps identified in the Linoria/Obsidian review. v4.0 deliberately shifts focus from adding controls to **reliability, lifecycle cleanup, API stability, diagnostics, testing and release engineering**. Config schema remains at 5 so existing profiles stay compatible.

Highlights:

- integrated `Signal` / `Maid` / `Store` / flag observation architecture
- deterministic config serialization, schema migration and persistent executor-file autoload/config storage; a memory adapter remains available only for custom/testing use
- stable component IDs and lazy-page-safe declarative keybind registration
- keybind modes `Toggle`, `Hold`, `Press`, `Always`, plus modifier chords and mouse buttons
- `Input`, `DropdownEx`, `MultiDropdown`, `ColorPicker`, `Viewport`, `Video`, `UIPassthrough`
- searchable/disabled/image-aware `DropdownEx` plus Player/Team sources and rich `MultiDropdown` drag selection
- command registry and opt-in command palette
- generic dependency bindings plus adoptable visual `DependencyBox` containers
- unified overlay stack for modal, popup, drawer, popover and context menu behavior
- automatic theme bindings, live custom themes and reduced-motion controls
- responsive Compact / Medium / Large breakpoints
- keyboard, gamepad, mouse and touch-aware interaction
- fixed-size windows (manual resize disabled) and draggable mobile toggle
- notifications, undo/redo, virtual lists, component discovery and debugging APIs
- live `CreateActivity()` HUDs with real-time counters, targets, status, progress, timers, sections and detector-style rows
- MistUI Doctor, leak/layout snapshots, profiler, Developer Tools panel and runtime quality suite
- config validation and transactions with rollback on failed config loads
- stable API regression snapshot + deterministic build/checksum validation in CI
- virtualized `DropdownEx`/`MultiDropdown`/`AddList` rows for large option sets; command palette output is capped and `CreateVirtualList` remains pooled
- remote icons are optional; every MistUI-internal icon has a local fallback
- strict development types without sacrificing broad executor compatibility in `dist/`

## Recommended API

Prefer `Card:Add(type, config)` with stable IDs for stateful controls:

```lua
card:Add("Toggle", {
    Id = "general.enabled",
    Text = "Enabled",
    Default = false,
})

card:Add("Keybind", {
    Id = "general.action",
    Text = "Action",
    Default = Enum.KeyCode.K,
    DefaultModifiers = { Enum.KeyCode.LeftControl },
    Mode = "Press",
})
```

Legacy `AddX` APIs remain available. In particular, `Card:Add("Dropdown", ...)` intentionally preserves the legacy dropdown implementation; opt into the expanded behavior with `DropdownEx`.

## Built-in themes

`Default`, `Haunted`, `Destiny`, `Bonanza`, `Olympus`.

## Live Activity HUD

`Window:CreateActivity()` creates a non-modal, draggable live HUD for long-running tasks. The same component can represent an Auto Boss tracker, quest/farm progress, server detector or other real-time status panel.

```lua
local activity = Window:CreateActivity({
    Title = "Auto Boss",
    Icon = "swords",
    AutoTimer = true,
})

activity:SetCounter(2, 10, "Bosses defeated")
activity:SetTarget("Ancient Guardian")
activity:SetStatus("Fighting boss...", "warning")
activity:SetProgress(0.42)

local detector = activity:AddSection({ Title = "Staff Detector", Icon = "shield" })
local state = detector:AddStatus({
    Title = "Clear",
    Description = "No staff in server",
    Status = "success",
})

state:SetTitle("Staff Detected")
state:SetStatus("danger")
```

Activities remain independent of the main Mist window, update in place, can be minimized/dragged/closed, and never use a modal blocker.

## Repository layout

```text
src/                      ordered source fragments used to build the library
dist/MistUI.lua           player-facing single-file library release
examples/example.lua      small usage example
examples/MistUI_TestLab.lua  development-only full component/overlay test lab
types/                    strict public Luau declarations
tests/                    static audits + runtime suites
docs/                     API, stability and compatibility documentation
tools/                    deterministic build/release tooling
.github/                   CI validation
```

Build and validate locally:

```bash
python tools/build.py
python tools/build.py --check
python tests/static_audit.py
python tests/quality_contract.py
python tools/release.py --check
```

`tests/runtime_smoke.luau`, `tests/runtime_quality.luau`, `tests/runtime_stress.luau` and `tests/runtime_benchmark.luau` are Roblox/executor runtime suites. They are not claimed as passed until actually executed in a target runtime.

## Executor compatibility

`dist/MistUI.lua` intentionally uses `--!nocheck`: executor analyzers vary and commonly report false positives around dynamic Luau/executor APIs. The source package still ships a strict public API contract in `types/MistUI.types.luau`.

## Comparison notes

See [`docs/COMPARISON.md`](docs/COMPARISON.md) for the concrete Linoria/Obsidian review that drove v4.0. The goal is measurable capability and maintainability, not a claim that one visual style is objectively preferable to every other UI library.

## Publishing

No license is chosen automatically. Select a license before publishing the repository if you want others to reuse or redistribute it under explicit terms.


## v4 stability contract

MistUI v4 treats documented public APIs as stable for the entire major version. CI compares the distribution against `tests/public_api_snapshot.json`; removing a frozen public method fails validation. Breaking changes are reserved for a future v5. See `docs/STABILITY.md`.

## Quality tools

```lua
local doctor = Window:Doctor({ Print = true })
local suite = Window:RunQualitySuite({ Print = true })
Window:SetProfilerEnabled(true)
Window:Profile("my-work", function()
    -- work to measure
end)
Window:OpenDebugPanel()
```

`Doctor` is diagnostic, not a substitute for target-runtime testing. The compatibility matrix records only environments that have actually been tested.
### Persistence behavior
MistUI configs are intended to be persistent. The library detects common executor filesystem APIs and uses flat files when directory creation is unavailable. If the runtime exposes no durable storage API at all, MistUI reports persistence as unavailable instead of pretending in-memory storage is permanent. A custom persistent `StorageAdapter` can also be supplied.


### Config persistence
MistUI now follows the same filesystem model used by Linoria/Obsidian-style SaveManagers: configs are persistent JSON files under `MistHub/settings`, the list is discovered with `listfiles`, and autoload is stored in `autoload.txt`. The Settings page no longer exposes JSON import/export or session-only config storage.

## Complete Test Lab

`examples/MistUI_TestLab.lua` is **development/QA only**. It embeds the library and opens a dedicated **Tests** area for Basic controls, Selectors/Keybinds, Layout/Data, Media, Activity, Overlays/Notifications and System diagnostics. It is intentionally separate from `dist/MistUI.lua` so Doctor/profiler/quality controls are never shipped as part of the player's hub UI by accident.

Manual window resizing is intentionally disabled. The bottom status bar is pinned to the original neutral gray (`#121214`) so Appearance/theme changes do not recolor it.

## Release files

For normal use, publish **only `dist/MistUI.lua`** as the raw library. Use `examples/example.lua` as the small integration reference and keep `examples/MistUI_TestLab.lua` for private QA/testing.
