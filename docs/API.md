# MistUI v4.0 API

MistUI is shipped as a **pure single-file library** in `dist/MistUI.lua`. Loading the file returns the Library table and does not create an application by itself.

## Load

```lua
local MistUI = loadstring(game:HttpGet("RAW_GITHUB_URL/dist/MistUI.lua"))()
local Window = MistUI:CreateWindow({
    Title = "My Interface",
    Responsive = true,
    KeyboardNavigation = true,
    GamepadNavigation = true,
})
```

MistUI intentionally keeps **one active Window per loaded Library instance**. `ReplaceExisting = true` replaces an existing window. Load the raw library again if you need a completely independent second root.

## Recommended structure

```lua
local Main = Window:CreateCategory({ Id = "main", Name = "Main" })

Main:AddScript({
    Id = "general",
    Name = "General",
    Icon = "settings",
    Keybinds = {
        { Id = "general.action", Name = "Quick Action", Default = Enum.KeyCode.K },
    },
    Build = function(page)
        local row = page:CreateRow()
        local card = row:AddCard("General", nil, { Size = "Full" })

        card:Add("Toggle", {
            Id = "general.enabled",
            Text = "Enabled",
            Default = false,
        })
    end,
})
```

Stable `Id`/`Flag` values are the identity used by flags, configuration persistence, dependencies and keybind metadata. Visible labels may change without invalidating saved state.

## Component matrix

`Card:Add(type, config)` is the recommended generic entry point. Legacy `AddX` methods remain available so existing hubs do not have to migrate at once.

| Family | Components |
| --- | --- |
| Core input | `Button`, `Toggle`, `Slider`, `Checkbox`, `Dropdown`, `Textbox`, `NumberBox`, `RangeSlider` |
| Advanced input | `Input`, `DropdownEx`, `MultiDropdown`, `SearchDropdown`, `Keybind`, `ToggleKeybind`, `ColorPicker`, `RadioGroup`, `SegmentedControl`, `Stepper` |
| Actions | `ButtonEx`, `ButtonGroup`, `IconButton`, `ConfirmButton`, `ActionMenu` |
| Status/data | `ProgressBar`, `Status`, `Badge`, `Tag`, `List`, `Table`, `TreeView`, `VirtualList` |
| Content/layout | `Label`, `Divider`, `Separator`, `Paragraph`, `Section`, `DependencyBox`, `CollapsibleSection`, `Tabs`, `Accordion`, `Breadcrumb`, `CodeBox`, `FormattedText`, `Markdown` |
| Media/custom | `Image`, `Avatar`, `Spinner`, `Viewport`, `Video`, `UIPassthrough` |

Compatibility note: `Card:Add("Dropdown", ...)` still routes to the original dropdown implementation. Use `DropdownEx` when you explicitly want the newer extended implementation.

`DropdownEx` adds searchable options, configurable maximum visible rows, null-state support, disabled values, per-value images, display/list/search formatting and optional `SpecialType = "Player" | "Team"` sources without changing the legacy dropdown behavior. `EnablePlayerImages = true` can populate Roblox headshots while the persisted value remains the player's name; `GetResolvedValue()` resolves the live Player/Team object when needed.

`MultiDropdown` supports the same search/disabled/image/formatter/special-source surface plus `DragSelect = true`, so users can paint multiple selections with a mouse drag. `GetResolvedValues()` resolves special values to live objects.

## Base component contract

Registered controls expose the shared contract where applicable: `On`, `OnChanged`, `GetInstance`, `GetContainer`, `IsVisible`, `IsDisabled`, `Show`, `Hide`, `Enable`, `Disable`, `GetFlag` and lifecycle cleanup. Stateful controls expose their relevant `Get`, `Set`, `SetSilent` and config methods.

### Advanced Input

```lua
local input = card:Add("Input", {
    Id = "profile.amount",
    Text = "Amount",
    Placeholder = "0",
    Numeric = true,
    Finished = true,       -- callback on focus loss/Enter instead of every keystroke
    AllowEmpty = false,
    MaxLength = 8,
    Default = "10",
    Callback = function(value, source)
        print(value, source)
    end,
})
```

`Input` supports `Placeholder`, `Finished`, `Numeric`, `AllowEmpty`, `EmptyReset`, `ClearTextOnFocus` and `MaxLength`.

### KeybindEx

Keybind modes are `Toggle`, `Hold`, `Press` and `Always`.

```lua
local bind = card:Add("Keybind", {
    Id = "movement.action",
    Text = "Action",
    Default = Enum.KeyCode.K,
    DefaultModifiers = { Enum.KeyCode.LeftControl },
    Mode = "Press",
    Callback = function(state, key, mode, source, modifiers)
        -- Ctrl+K fires once and does not leave a latched state behind.
    end,
})
```

Keyboard keys and `MouseButton1/2/3` are supported. `Modifiers` / `DefaultModifiers` accept Ctrl, Shift and Alt variants, so chords such as `Ctrl+K` can be registered without project-side input plumbing.

For lazy pages, declare `Keybinds` in `AddScript({...})` or call `Window:RegisterKeybindDefinition(s)` before the page is opened. This keeps the floating Keybinds list complete and prevents duplicate registration when pages are revisited.

### ColorPicker

```lua
local color = card:Add("ColorPicker", {
    Id = "visual.box.color",
    Text = "Box color",
    Default = Color3.fromRGB(255, 255, 255),
    AllowTransparency = true,
    Transparency = 0.15,
    Callback = function(value, transparency)
        print(value, transparency)
    end,
})
```

Methods include `Set`, `SetSilent`, `SetValueRGB`, `SetHSVFromRGB`, `SetValue`, `GetHSV`, `GetColor`, `GetTransparency`, `SetTransparency`, `Open` and `Close`. Config persistence stores both the `Color3` and transparency value using MistUI's serializer.

### Viewport

`Viewport` embeds a `ViewportFrame` + `WorldModel` with a managed camera. Pass a Model/BasePart using `Object` or `Model`.

```lua
local viewport = card:Add("Viewport", {
    Text = "Preview",
    Object = workspace:FindFirstChild("PreviewModel"),
    Height = 180,
    Interactive = true,
})

viewport:Focus()
viewport:SetInteractive(true)
```

Public methods: `SetObject`, `GetObject`, `SetHeight`, `Focus`, `SetCamera`, `SetInteractive`, `ResetRotation`.

### Video

```lua
local video = card:Add("Video", {
    Video = "rbxassetid://...",
    Height = 180,
    Looped = true,
    Volume = 0.5,
    Playing = false,
})
```

Methods: `SetVideo`, `SetHeight`, `SetLooped`, `SetVolume`, `SetPlaying`, `Play`, `Pause`.

### UIPassthrough

`UIPassthrough` lets a project mount a custom `GuiObject` inside a MistUI card without forking the library.

```lua
card:Add("UIPassthrough", {
    Instance = myCustomFrame,
    Height = 90,
    Clone = false,
})
```

The component tracks the original parent/placement and restores the object when detached when possible.

## Flags, state and observation

```lua
Window:SetFlag("general.enabled", true)
print(Window:GetFlag("general.enabled"))

local connection = Window:ObserveFlag("general.enabled", function(value, previous, flag)
    print(flag, previous, value)
end, true)
```

Useful state APIs include `GetFlag`, `GetFlags`, `SetFlag`, `ObserveFlag`, `GetStore`, `Snapshot`, `Undo`, `Redo` and `ResetFlags`.

## Dependencies and conditional UI

MistUI can bind visibility/disabled state to flags instead of forcing each project to manually wire every dependency. Relevant APIs are `BindDependency`, `BindConditions`, `ShowWhen` and `DisableWhen`.


### DependencyBox

MistUI v4.0 also exposes a visual dependency container while retaining the generic dependency APIs:

```lua
local advanced = card:AddDependencyBox({
    Title = "Advanced",
    Bordered = true,
    Source = "general.enabled",
})

advanced:Add("Slider", {
    Id = "advanced.amount",
    Text = "Amount",
    Min = 0, Max = 100, Default = 50,
})

advanced:AddToggle("Extra", false, function(value)
    print(value)
end)
```

`DependencyBox` can adopt existing components, create controls through `Add`/`AddControl` or proxy the normal `AddX` methods. `SetupDependencies` accepts a source or condition array and uses the same flag observation system as `BindDependency` / `BindConditions`.

## Search and discovery

`Window:Search(query)` searches registered components. `SearchSidebar(query)` searches navigation. Registered components can also be queried through `GetComponent`, `FindComponent`, `GetComponents`, `GetCards` and `GetCategories`.

## Commands and command palette

v4.0 adds a first-class command registry. It is opt-in and does **not** add an automatic global hotkey.

```lua
Window:RegisterCommand({
    Id = "config.save",
    Name = "Save configuration",
    Description = "Save the current MistUI state",
    Keywords = { "config", "save" },
    Callback = function()
        Window:SaveConfig("default")
    end,
})

local matches = Window:SearchCommands("save")
Window:RunCommand("config.save")
Window:OpenCommandPalette({ MaxResults = 12, CloseOnRun = true })
```

APIs: `RegisterCommand`, `UnregisterCommand`, `GetCommands`, `SearchCommands`, `RunCommand`, `OpenCommandPalette`.

## Configuration

Schema version remains **5** in v4.0 so existing v3 configs stay compatible.

Persistence APIs include `SaveConfig`, `LoadConfig`, `DeleteConfig`, `GetConfigs`, `ConfigExists`, `GetConfigData`, `ApplyConfigData`, `SaveFlagsConfig`, `SetAutoload` and `GetAutoload`. Configs are stored as persistent files under `MistHub/settings`; JSON import/export UI is not part of the v4 config workflow.

Executor filesystem access is isolated behind the storage adapter. `UseMemoryStorage = true` gives deterministic no-filesystem testing.

## Themes

Built-in presets: `Default`, `Haunted`, `Destiny`, `Bonanza`, `Olympus`.

The Theme Binder tracks token/property relationships so live theme changes do not depend on brittle hard-coded recoloring. Public APIs include `SetTheme`, `GetThemes`, `RegisterTheme`, `RemoveTheme`, `ExportTheme`, `ImportTheme`, `ResetTheme` and `SetAccent`.

## Overlays

MistUI uses a unified overlay stack for modal behavior, z-order and cleanup. APIs include `CreatePopup`, `CreateModal`, `CreateDrawer`, `CreatePopover`, `CreateContextMenu` and `Confirm`.

This is also the foundation used by selectors such as ColorPicker and by app-specific side panels.

## Activity HUD

`Window:CreateActivity(config)` creates a persistent non-modal HUD intended for long-running live tasks. Activity panels can be dragged, minimized, closed and updated without rebuilding the UI.

Convenience state methods:

- `SetCounter(current, total?, label?)`
- `SetTarget(value, label?)`
- `SetStatus(text, kind?)`
- `SetProgress(value, label?, kind?)`
- `StartTimer(offsetSeconds?)`, `StopTimer()`, `SetTime(value)`
- `SetTitle`, `SetIcon`, `SetMinimized`, `Show`, `Hide`, `Close`

Structured detector/dashboard content:

```lua
local activity = Window:CreateActivity({ Title = "Server Detector", Icon = "eye" })
local section = activity:AddSection({ Title = "Chakra Sense", Counter = 1 })
local detected = section:AddStatus({
    Title = "Detected",
    Description = "1 player",
    Status = "warning",
})
local row = section:AddRow({ Title = "Viraviria", Value = "142" })

detected:SetDescription("3 players")
row:SetValue("186")
```

Use `Window:GetActivities()` to inspect active panels and `Window:CloseActivities()` to close them all.

## Notifications

Notification settings cover enable/disable, progress, pause-on-hover, position, default duration and max visible count. Relevant APIs include `Notify`, `UpdateNotification`, `DismissNotification`, `DismissLatestNotification`, `ClearNotifications`, `SetNotificationSettings` and `GetNotificationSettings`.

## Responsive behavior and accessibility

MistUI provides structural `Compact` / `Medium` / `Large` breakpoints, `UIScale`, keyboard/gamepad focus movement, focus rings, touch-aware tooltips and reduced motion.

```lua
Window:EnableResponsive(true)
Window:SetKeyboardNavigationEnabled(true)
Window:SetGamepadNavigationEnabled(true)
Window:SetScale(1.0)
print(Window:GetBreakpoint())
```

### Optional mobile toggle

```lua
Window:SetMobileToggleEnabled(true, { Side = "Right" })
Window:SetMobileToggleSide("Left")
```

Or set `MobileToggle = true` in `CreateWindow`. The toggle is deliberately opt-in so upgrading MistUI does not add unexpected UI to existing projects. `Window:IsTouchDevice()` is available for project-specific branching.

## Window ergonomics

Manual window resizing is intentionally disabled in the current MistUI v4 build. `SetResizable` remains a compatibility no-op and `IsResizable()` returns `false`.

Window APIs also include `SetVisible`, `Minimize`, `Restore`, `Toggle`, `SetTitle`, `SetSize`, `SetPosition`, `Center`, `SetMinMaxSize`, `LockDrag`, `SetResizable`, `IsResizable`, `LockResize`, `Maximize`, `RestoreWindow`, `ToggleMaximize`, `SnapToEdge`, `EnableSnap` and `SetTransparency`.

## Lifecycle, Doctor and debugging

Use `Window:Track` / `Window:Connect` for project-owned resources that should die with the interface. v4 also deregisters component flags/events on individual `Destroy` and performs a stronger registry cleanup on `Unload`.

```lua
local before = Window:CreateLeakSnapshot()
local report = Window:Doctor({ Print = true })
local suite = Window:RunQualitySuite({ Print = true })

Window:SetProfilerEnabled(true)
Window:Profile("expensive-refresh", function()
    -- measured work
end)
print(Window:GetProfilerSnapshot())

Window:OpenDebugPanel()
```

Quality APIs: `Doctor`, `RunQualitySuite`, `AssertHealthy`, `CreateLeakSnapshot`, `CompareLeakSnapshots`, `CaptureLayoutSnapshot`, `CompareLayoutSnapshots`, `GetLastUnloadReport`, `SetProfilerEnabled`, `Profile`, `GetProfilerSnapshot`, `ClearProfiler`, `OpenDebugPanel`, `GetDebugState`, `GetDiagnostics`, `ClearDiagnostics`, `SafeCallContext` and `Boundary`. Diagnostic records are capped. Layout snapshots provide structural visual-regression checks without pretending that a non-rendering CI environment can capture real screenshots.

### Config validation and transactions

Config loads are transactional by default in v4. The public transaction surface is also available for project code:

```lua
local valid, details = Window:ValidateConfigData(data)

local ok = Window:WithConfigTransaction("bulk update", function()
    Window:SetFlag("feature.enabled", true)
    Window:ApplyConfigData(data, false)
end)
```

APIs: `ValidateConfigData`, `BeginConfigTransaction`, `CommitConfigTransaction`, `RollbackConfigTransaction`, `WithConfigTransaction`, and transactional `ApplyConfigData`. Config `SchemaVersion` remains 5 for compatibility.

## Remote icons

Remote Lucide loading is opt-in. Internal MistUI icons always have local fallbacks, so a blocked GitHub domain does not make the framework unusable.

```lua
MistUI:SetRemoteIconsEnabled(true)
```


## Large-list performance

`DropdownEx`, `MultiDropdown`, and `AddList` use a scroll-window renderer: only the visible rows plus a small buffer are instantiated, while search still operates on the complete option set. `CreateVirtualList` is the general pooled list primitive for application-owned large collections. The command palette renders only its configured `MaxResults` window.
