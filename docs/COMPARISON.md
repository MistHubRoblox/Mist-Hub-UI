# MistUI v4.0 — Linoria / Obsidian comparison

Review date: **2026-09-15**.

This document records the concrete public features that drove MistUI v4.0. It is not a claim that visual taste is objective. The goal is to make MistUI at least competitive on the capabilities developers can measure while keeping its own architecture and API direction.

Public references reviewed:

- LinoriaLib: https://github.com/violin-suzutsuki/LinoriaLib
- Obsidian: https://github.com/deividcomsono/Obsidian
- Obsidian public type declarations: https://github.com/deividcomsono/Obsidian/blob/main/Library.d.luau

## Capability matrix

| Area | Linoria | Obsidian | MistUI v4.0 |
| --- | --- | --- | --- |
| Single-file load | Yes | Yes | Yes; deterministic `dist/MistUI.lua` |
| Source/dev package | Basic repo layout | Repo + large strict declaration file | Modular source fragments + strict types + docs + tests + deterministic builder + CI |
| Save/config | SaveManager addon | SaveManager addon | Integrated storage adapters, schema migrations, autoload, import/export, memory storage |
| Theme management | ThemeManager addon | ThemeManager addon | Integrated Theme Binder, presets, custom theme registry/import/export |
| State observation | Global Toggles/Options pattern | Options/Toggles + callbacks | Flags + per-flag signals + Store + `ObserveFlag` + snapshot/undo/redo |
| Dependencies | Dependency boxes | Dependency boxes/groupboxes | Generic `BindDependency` / `BindConditions` plus adoptable visual `DependencyBox` containers |
| Responsive breakpoints | Traditional fixed menu | Mobile/desktop support | Compact/Medium/Large structural breakpoints + UIScale |
| Keyboard/gamepad | Primarily mouse/keyboard | Broad input support | Keyboard navigation + gamepad navigation + focus rings + touch-aware tooltips |
| Window resizing | Fork-dependent / not core focus | Supported | Opt-in `Resizable`, `SetResizable`, min/max sizing, snap/maximize APIs |
| Mobile toggle | Not a core advertised feature | Supported | Opt-in draggable mobile toggle + side selection + `IsTouchDevice` |
| Keybind modes | Key picker patterns | Always/Toggle/Hold/Press | Toggle/Hold/Press/Always + modifier chords + mouse buttons + lazy declarative registry |
| Keybind list correctness | Standard keybind frame | Keybind frame | Registry can be populated before lazy page build, avoiding duplicate/missing entries |
| Color picker | Yes | Yes | Yes + transparency + RGB/HSV APIs + config serializer |
| Advanced dropdown | Mature dropdown | Search, disabled values, images, formatting and special modes | `DropdownEx`: search, disabled values, images, null state, formatters, Player/Team sources; `MultiDropdown` adds drag-select |
| Viewport | Not a primary advertised control | Yes | Yes; WorldModel/camera, autofocus, clone/reparent safety, interactive rotation |
| Video | Not a primary advertised control | Yes | Yes |
| Custom GUI passthrough | Manual/custom | Yes | Yes; clone/reparent with parent/size/position restoration |
| Overlays | Context/dropdown internals | Dialog/context systems | Unified modal/popup/drawer/popover/context-menu stack |
| Command palette | No first-class public registry | No comparable first-class registry in reviewed API | Integrated command registry, fuzzy search and opt-in command palette |
| Virtualized large lists | No first-class public API reviewed | No first-class public API reviewed | `CreateVirtualList` plus windowed rendering in `DropdownEx`, `MultiDropdown` and `AddList` |
| Config migration | Addon persistence | Addon persistence | Versioned `SchemaVersion` + migration registry |
| Deterministic release check | Not advertised | Not advertised | `tools/build.py --check` enforces source/dist byte identity |
| Automated repository audit | Not advertised | Not advertised | Static structural audit + CI + API-freeze regression + source sanity + target-runtime suites |
| Config transactions | Addon-driven persistence | Addon-driven persistence | Validation + begin/commit/rollback + transactional loads |
| Runtime self-diagnostics | No comparable first-class public API reviewed | No comparable first-class public API reviewed | `Doctor`, capped diagnostics, leak snapshots and post-unload reports |
| Profiling / developer panel | No comparable integrated public panel reviewed | No comparable integrated public panel reviewed | Opt-in profiler + Mist Developer Tools panel |
| Error boundaries | Callback handling varies by callsite | Callback handling varies by callsite | Context-aware `SafeCallContext` / `Boundary` with capped trace records |
| Structural UI regression | Not advertised | Not advertised | Deterministic layout snapshots/comparison with pixel tolerance |
| Public API freeze | Not advertised as a machine-checked contract | Strict declarations aid compatibility | Frozen v4 method snapshot checked in CI; breaking removals require v5 |
| Stress / benchmark harness | Not advertised in reviewed public surface | Not advertised in reviewed public surface | 100-cycle stress suite + 500-control/2,000-option benchmark suite (must be run in target runtime) |

## Where MistUI deliberately differs

MistUI does **not** copy Linoria's or Obsidian's visual style or global `Options` / `Toggles` surface. The recommended identity is a stable `Id`/`Flag`, and project code can observe state without coupling business logic to a specific widget object.

The generic `Dropdown` route remains backward compatible. New dropdown behavior is opt-in through `DropdownEx`; this avoids silently changing existing hubs while still letting new code use the richer implementation.

MistUI also intentionally keeps one active Window per loaded Library instance. This simplifies overlay ownership, global input routing and cleanup. A project that genuinely needs an independent second UI root can load another Library instance.

## Remaining subjective differences

Linoria is smaller and familiar to a large ecosystem, and Obsidian's API conventions may be preferable to developers already invested in them. MistUI v4.0 now covers the major general-purpose controls reviewed here, including Player/Team dropdown sources and visual dependency containers, while emphasizing integrated state/config architecture, reproducible distribution and broad framework primitives. Which naming and visual style feels best is still subjective.

## Runtime verification status

The repository ships Roblox/executor runtime smoke, quality, stress and benchmark suites, but this build environment cannot execute Roblox Luau. Those suites are therefore **authored but not marked as passed** here. `docs/COMPATIBILITY.md` must only be changed to Pass after a real target-runtime run. Static/build/API/checksum results and runtime results are intentionally reported separately.
