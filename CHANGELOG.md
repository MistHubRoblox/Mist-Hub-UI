# MistUI Changelog

## 4.0.0 Stable - release consolidation

- finalized the player-facing distribution as `dist/MistUI.lua` only
- moved the full QA/Test Lab to `examples/MistUI_TestLab.lua`
- added a compact `examples/example.lua` integration sample
- kept manual window resizing disabled
- retained persistent Linoria/Obsidian-style config files and autoload behavior
- retained the official live `CreateActivity()` API
- added CI checks preventing internal QA labels from leaking into the normal Settings surface
- release policy: bug fixes use 4.0.x; additive compatible features use 4.1.x; breaking API changes wait for v5

## Activity HUD

- Added official `Window:CreateActivity()` live HUD API.
- Supports Auto Boss-style counter/target/status/progress/timer updates without recreating the panel.
- Supports detector/dashboard layouts via `AddSection`, `AddStatus` and `AddRow`.
- Activities are draggable, minimizable, closable, non-modal and cleaned up on `Unload`.
- Added `GetActivities` / `CloseActivities` and Activity counts to diagnostics/leak snapshots.
- Added strict Activity types and runtime smoke coverage.

## Player-facing cleanup

- ConfirmButton no longer inherits ButtonEx's default icon.
- Removed storage/backend status from Configuration UI.
- Removed deprecated getfenv usage and dead JSON transfer helpers.
- Reworded persistence/config errors so players never see backend/API/schema implementation details.
- Development diagnostics remain programmatic/Test-Lab-only and are not shown in normal Settings.

## v4 test-lab / UI cleanup

- removed the manual resize handle; `SetResizable` remains a compatibility no-op and `IsResizable()` returns false
- restored the bottom status bar to the original fixed neutral gray instead of theme-binding it
- added a complete standalone Test Lab covering all 50 public card component constructors plus overlays, notifications, keybind-list behavior, diagnostics and config checks


## v4 UI / Config / Keybind fixes
- Settings dropdowns now render through a dedicated overlay layer so menus are not clipped by scrolling pages or section bounds.
- Removed the title-bar Keybinds icon; the floating keybind list is controlled from Settings > Interface.
- Active keybinds are visually highlighted; inactive keybinds remain gray.
- Config storage no longer silently falls back to volatile session memory. Persistent storage now requires a durable executor storage API.
- Added broader persistent filesystem API detection, including common aliases/namespaces and flat-file fallback when folder APIs are unavailable.
# ColorPicker / Popover hotfix

- ColorPicker popovers are now non-modal and no longer place a full-screen transparent input blocker over the UI.
- Clicking outside closes the picker without freezing the rest of the interface.
- Escape closes the top overlay even when the HEX textbox is focused.
- Clicking the ColorPicker control again closes it normally.
- Popup input connections are disconnected on close.

# Changelog

## 4.0.0-fix1 — Luau scope/lint correction

- fixed 28 out-of-scope `self_` references inside `Library:_AttachCardAPI`; the window receiver is `self` in that method
- made executor storage `Delete` / `MakeDirectory` return `false` when unsupported
- removed an unused `empty` local in the keybind menu
- no v4 feature was removed


## 4.0.0 — Stable / Quality release

- retained config schema 5 for backward compatibility while moving the framework version to 4.0.0
- added capped diagnostic/error history with contextual callback boundaries and traceback capture when available
- added config validation plus begin/commit/rollback/with-transaction APIs; config loads are transactional by default
- added MistUI Doctor health reports for flags, component contracts, keybinds, theme bindings, overlays, storage, schema and callback errors
- added leak snapshots, snapshot comparison and post-unload leak reports
- hardened `Unload` and individual component destruction to clear strong component registries, flag signals and event references
- added opt-in profiler APIs and the Mist Developer Tools debug panel
- added `RunQualitySuite` / `AssertHealthy` non-destructive runtime self-tests
- expanded the common component lifecycle contract with default/reset, visibility, disabled and destroyed-state helpers
- added public-API regression snapshot tooling so stable APIs cannot disappear silently in CI
- added runtime quality/stress/benchmark suites and release checksum tooling
- formalized v4 semantic-versioning/API-freeze policy and compatibility test matrix

## 3.1.0 — Parity and component breadth

- added advanced `Input` with finished/numeric/length/empty-state controls
- added `ColorPicker` with transparency, RGB/HSV APIs and config persistence
- added `Viewport`, `Video` and `UIPassthrough` media/custom-content components
- added `DropdownEx` search, null state, disabled values, value images, formatters, Player/Team sources and configurable visible count
- upgraded `MultiDropdown` with search, disabled values, images, formatters, special Player/Team sources and drag-select
- added adoptable visual `DependencyBox` containers on top of MistUI's generic dependency system
- expanded keybinds with `Press`, Ctrl/Shift/Alt chords and mouse buttons while retaining Toggle/Hold/Always
- fixed lazy-page keybind registration so the Keybinds panel can be complete without visiting each tab
- added first-class command registry, fuzzy command search and opt-in command palette
- added opt-in draggable mobile toggle and touch-device helper
- added opt-in window resize handle plus `SetResizable` / `IsResizable`
- hardened external-instance ownership/restoration in Viewport and UIPassthrough
- expanded strict public type declarations to cover the real public surface
- made the build deterministic with `tools/build.py --check` and added CI validation

## 3.0.0

- pure library release ending in `return Library`; application/demo code removed
- modern `Card:Add(type, config)` API with stable `Id`/`Flag` support
- declarative keybind definitions for lazy pages
- intentional single-active-window contract
- Theme Binder expansion and automatic color-token binding
- centralized motion and reduced-motion behavior
- adaptive Compact / Medium / Large layout behavior
- keyboard/gamepad focus preparation and visible focus rings
- generic Function Info descriptions; app-specific descriptions removed
- Overlay Manager integration for ContextMenu and Confirm
- stronger Maid ownership for global/service connections
- notification pause-on-hover and settings synchronization
- keybind list state persisted in config
- config schema 5 with migration
- remote icon loading made opt-in and dynamically loadable
- local fallbacks for every icon used internally
- strict public type declarations, static audit, runtime smoke test, API docs

## v4.0 icon/showcase fix
- `CreateCategory({ Icon = ... })` now renders the category icon.
- Added a built-in `user` vector fallback so Player icons do not depend on remote Lucide loading.
- Added `dist/MistUIStandalone.lua`, a direct-run showcase that opens Player/ESP/Combat/Teleport/World/Misc together.

## v4 Test Lab / Dropdown Fix
- Fixed Settings dropdown stacking under later rows/sections when using `ZIndexBehavior.Sibling`.
- Settings dropdowns now elevate their owning section while open.
- Only one Settings dropdown can remain open at a time.
- Settings dropdown selection checks now update immediately.
- Settings dropdowns with more than five entries use a scrolling list.
- Core Dropdown, DropdownEx and MultiDropdown now close the previously open dropdown automatically.
- Added a full `Tests` top tab in the standalone build covering common, advanced, data and media controls.
- Fixed malformed multiline CodeBox sample in the standalone Test Lab.
## v4 config storage fallback hotfix

- Automatically falls back to Memory Storage when executor readfile/writefile are unavailable.
- Create/Save/Load/Import/Export continue working for the current session without File API.
- Configuration Settings now shows whether storage is persistent or session-only.
- Hardened ExecutorStorageAdapter against missing readfile/writefile functions.


## Config persistence rebuild
- Replaced Mist's config storage layer with a Linoria/Obsidian-style filesystem flow.
- Configs now live under `MistHub/settings/<name>.json`.
- Config discovery uses `listfiles()`; no `config_index.json` is used.
- Autoload is stored at `MistHub/settings/autoload.txt`.
- File operations use the executor's standard `writefile/readfile/isfile/isfolder/makefolder/listfiles/delfile` APIs.
- Removed Import Config / Export Config JSON from the Settings UI and public Window API.
- Removed memory/session-only storage as a config fallback.

## v4 cleanup
- Removed deprecated `getfenv()` environment probe.
- Removed obsolete JSON transfer helpers left behind after Import/Export JSON was removed.
- Removed unused `configTransferBox` state.
- Removed safe-transfer pending flag plumbing that was only used by JSON import/export.
## UI polish follow-up

- Tabs now divide the entire navigation width evenly; no empty block remains on the right.
- Confirm was rebuilt as a compact content-sized modal with correctly contained actions.
- Context menus now use adaptive width, subtler surfaces, cleaner hover states, optional icons/destructive states, and animated open/close.
- ActionMenu now uses the shared icon renderer and the polished context-menu surface.
- Command Palette now sizes itself to its result count, removes the large empty region, and uses compact result rows.


## v4 visual polish — focus, loader and icons
- ButtonEx now always has an icon by default and icon color follows the actual button foreground.
- Replaced the old glyph spinner with an animated 8-dot Mist loader.
- CollapsibleSection now uses real Mist icons and a chevron icon instead of the text glyph.
- Overlay buttons (modal/popup/drawer) opt out of Roblox selection outlines.
- Confirm actions no longer show white focus borders.
- Context Menu no longer auto-selects/highlights its first action.
- Command Palette no longer shows white focus/stroke borders on search/results.
- `create()` now parents GUI instances last so explicit `Selectable=false` is respected before focus preparation.
