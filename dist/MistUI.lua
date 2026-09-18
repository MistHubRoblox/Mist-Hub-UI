--!nocheck
--[[
    ============================================================
    MIST UI LIBRARY v4.0 STABLE
    Runtime-ready single-file distribution.
    ============================================================

    Recommended modern API:

        local Library = loadstring(game:HttpGet("RAW_URL"))()
        local Window = Library:CreateWindow({ Title = "MY HUB" })
        local Main = Window:CreateCategory("Main")

        Main:AddScript("Example", function(page)
            local row = page:CreateRow()
            local card = row:AddCard("Example")

            local toggle = card:Add("Toggle", {
                Id = "example.enabled",
                Text = "Enabled",
                Default = false,
                Callback = function(value) end,
            })
        end)

    Legacy card:AddToggle/AddSlider/etc. methods remain available for
    compatibility. Card:Add(type, config) is the recommended stable API.

    Distribution policy:
      - one active Window per Library instance by design
      - load the raw file again if an independent second UI is required
      - runtime-specific storage is isolated behind StorageAdapter
      - remote icon code is opt-in; internal icons always have local fallbacks

    Development type declarations, tests and documentation are shipped in the
    GitHub source package and are intentionally not embedded in this raw file.
    ============================================================
]]

local Library = {}
Library.__index = Library
Library.Architecture = {
    Distribution = "single-file",
    SourceLayout = "modular-build-fragments",
    Core = "Signal/Maid/Store/ThemeBindings",
    Managers = "Overlay/Keybind/Config/Notifications",
    WindowModel = "single-active-window-per-library-instance",
    Version = 4.0,
}
Library.SupportsMultipleWindows = false
Library.ReleaseBuild = true
Library.Capabilities = {
    ModernComponents = true,
    StableIds = true,
    DeclarativeKeybinds = true,
    ThemeBindings = true,
    AdaptiveBreakpoints = true,
    KeyboardNavigation = true,
    GamepadNavigation = true,
    TouchTooltips = true,
    MemoryStorage = true,
    RuntimeStorage = true,
    OverlayStack = true,
    ColorPicker = true,
    Viewport = true,
    Video = true,
    UIPassthrough = true,
    AdvancedInput = true,
    PressKeybindMode = true,
    CommandRegistry = true,
    ResizableWindows = false,
    KeybindChords = true,
    AdvancedDropdown = true,
    DependencyBoxes = true,
    QualitySuite = true,
    Doctor = true,
    LeakDiagnostics = true,
    Profiler = true,
    DebugPanel = true,
    ConfigTransactions = true,
    ConfigValidation = true,
    ErrorBoundaries = true,
    APIContracts = true,
    VirtualizedLargeLists = true,
    LayoutSnapshots = true,
    ActivityHUD = true,
}


------------------------------------------------------------
-- SERVICES
------------------------------------------------------------
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local GuiService       = game:GetService("GuiService")

local function isTextInputFocused()
    local ok, focused = pcall(function()
        return UserInputService:GetFocusedTextBox()
    end)
    return ok and focused ~= nil
end

local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------
-- TYPOGRAPHY
-- Builder Sans: clean, modern and well suited for compact Roblox UI.
------------------------------------------------------------
local function uiFont(weight)
    return Font.new(
        "rbxasset://fonts/families/BuilderSans.json",
        weight or Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
end

------------------------------------------------------------
-- TEMA (valores exatos extraídos da imagem de referência)
------------------------------------------------------------
local Theme = {
    Background      = Color3.fromHex("#161618"),  -- base geral
    TitleBar        = Color3.fromHex("#18181b"),  -- nível 1
    Sidebar         = Color3.fromHex("#121214"),  -- nível mais escuro
    TabBar          = Color3.fromHex("#18181b"),
    Content         = Color3.fromHex("#19191c"),  -- nível 2
    Field           = Color3.fromHex("#121214"),  -- nível de interação
    FieldHover      = Color3.fromHex("#1a1a1e"),
    Card            = Color3.fromHex("#1e1e22"),  -- nível 3
    CardHover       = Color3.fromHex("#242429"),
    Stroke          = Color3.fromHex("#2a2a2f"),
    StrokeSoft      = Color3.fromHex("#222226"),
    StrokeTabBar    = Color3.fromHex("#2d2d32"),
    SearchStroke    = Color3.fromHex("#202024"),
    SearchStrokeFocus = Color3.fromHex("#4a4a50"),
    Text            = Color3.fromRGB(248, 248, 249),   -- branco (Explorer, tab ativa)
    TextTabInactive = Color3.fromRGB(210, 210, 213),   -- branco (tabs inativas, conforme referência)
    TextDark        = Color3.fromRGB(158, 158, 164),   -- cinza (título, headers SCRIPTS)
    TextDimmer      = Color3.fromRGB(126, 126, 132),   -- cinza mais apagado (ícones)
    Accent          = Color3.fromHex("#f8f8f9"),       -- sublinhado da tab ativa
    Success         = Color3.fromRGB(74, 222, 128),
    Error           = Color3.fromRGB(255, 132, 132),
    Warning         = Color3.fromRGB(250, 204, 21),
    Info            = Color3.fromRGB(200, 200, 200),
    PrimaryText     = Color3.fromRGB(15, 15, 15),      -- text over Accent buttons
    SurfaceTint     = Color3.fromRGB(255, 255, 255),   -- ultra-subtle surface tint
    SettingsBackdrop = Color3.fromRGB(8, 8, 10),       -- Settings frosted backdrop
    ToggleKnobActive = Color3.fromRGB(20, 20, 22), -- active toggle knob
    Font         = uiFont(Enum.FontWeight.Regular),
    FontMedium   = uiFont(Enum.FontWeight.Medium),
    FontSemibold = uiFont(Enum.FontWeight.SemiBold),
    FontBold     = uiFont(Enum.FontWeight.Bold),

    Metrics = {
        WindowRadius = 10,
        CardRadius = 10,
        ControlRadius = 6,
        OverlayRadius = 10,

        ControlHeightSmall = 28,
        ControlHeight = 34,
        ControlHeightLarge = 38,

        SpaceXS = 4,
        SpaceS = 8,
        SpaceM = 12,
        SpaceL = 16,
        SpaceXL = 22,

        IconS = 14,
        IconM = 18,
        IconL = 22,

        TouchTarget = 40,
    },

    Motion = {
        Instant = 0.08,
        Fast = 0.10,
        Normal = 0.18,
        Slow = 0.24,
    },
}

Library.Theme = Theme
Library.Metrics = Theme.Metrics
Library.Motion = Theme.Motion

Library.ThemeColorKeys = Library.ThemeColorKeys or {
    "Background", "TitleBar", "Sidebar", "TabBar", "Content",
    "Field", "FieldHover", "Card", "CardHover", "Stroke", "StrokeSoft",
    "StrokeTabBar", "SearchStroke", "SearchStrokeFocus", "Text",
    "TextTabInactive", "TextDark", "TextDimmer", "Accent", "Success",
    "Error", "Warning", "Info", "PrimaryText", "SurfaceTint",
    "SettingsBackdrop", "ToggleKnobActive",
}
Library.ThemeDerivedFactors = Library.ThemeDerivedFactors or {
    0.72, 0.80, 0.90, 0.92, 0.96, 1.025, 1.04, 1.05, 1.08, 1.12, 1.16, 1.20,
}

function Library:_ThemeShade(color, factor)
    return Color3.new(
        math.clamp(color.R * factor, 0, 1),
        math.clamp(color.G * factor, 0, 1),
        math.clamp(color.B * factor, 0, 1)
    )
end

function Library:_ColorNear(a, b)
    if typeof(a) ~= "Color3" or typeof(b) ~= "Color3" then return false end
    local epsilon = 1 / 510
    return math.abs(a.R - b.R) <= epsilon
        and math.abs(a.G - b.G) <= epsilon
        and math.abs(a.B - b.B) <= epsilon
end

function Library:_ThemeBindingForColor(value, sourceTheme)
    if typeof(value) ~= "Color3" then return nil end
    sourceTheme = sourceTheme or Theme

    for _, key in ipairs(self.ThemeColorKeys) do
        local base = sourceTheme[key]
        if typeof(base) == "Color3" then
            if self:_ColorNear(value, base) then
                return key, nil
            end

            for _, factor in ipairs(self.ThemeDerivedFactors) do
                if self:_ColorNear(value, self:_ThemeShade(base, factor)) then
                    return key, factor
                end
            end
        end
    end

    return nil
end

Library.Flags = Library.Flags or {}
Library.ComponentsByFlag = Library.ComponentsByFlag or {}

------------------------------------------------------------
-- MIST UI FRAMEWORK CORE
------------------------------------------------------------
Library.Version = "4.0.0"
Library.SchemaVersion = 5
Library.DebugEnabled = false
Library.AnimationSettings = Library.AnimationSettings or {
    Enabled = true,
    Speed = 1,
    ReducedMotion = false,
}
Library.Locale = Library.Locale or "en"
Library.Locales = Library.Locales or {
    en = {},
    pt = {},
}
Library.ConfigMigrations = Library.ConfigMigrations or {}
Library.ThemeRegistry = Library.ThemeRegistry or {}
Library.ActiveNotifications = Library.ActiveNotifications or {}
Library._zIndexCounter = Library._zIndexCounter or 250
Library._themeBindings = Library._themeBindings
    or setmetatable({}, { __mode = "k" })

-- Quality/diagnostic state is intentionally lightweight in release builds.
-- Detailed records are capped to prevent debugging itself from becoming a leak.
Library.Diagnostics = Library.Diagnostics or {
    SafeCalls = 0,
    CallbackErrors = 0,
    Warnings = 0,
    Records = {},
    MaxRecords = 100,
}

local function diagnosticCopy(value, seen)
    local luaType = type(value)
    local robloxType = typeof(value)

    -- Diagnostics/default snapshots must never keep strong references to the UI
    -- tree, callbacks, threads or runtime userdata. Keep primitives as-is and
    -- stringify opaque/runtime objects so debug tooling cannot become a leak.
    if robloxType == "Instance" then
        local ok, fullName = pcall(function() return value:GetFullName() end)
        return ok and ("<Instance:" .. tostring(fullName) .. ">")
            or ("<Instance:" .. tostring(value) .. ">")
    end
    if luaType == "function" or luaType == "thread" or luaType == "userdata" then
        return "<" .. luaType .. ":" .. tostring(value) .. ">"
    end
    if luaType ~= "table" then return value end

    seen = seen or {}
    if seen[value] then return "<cycle>" end
    seen[value] = true
    local out = {}
    for k, v in pairs(value) do
        local safeKey = diagnosticCopy(k, seen)
        if type(safeKey) == "table" then safeKey = tostring(k) end
        out[safeKey] = diagnosticCopy(v, seen)
    end
    seen[value] = nil
    return out
end

-- Component defaults/config-facing values need an ordinary deep table copy that
-- preserves Roblox values/Instances. Keep this separate from diagnosticCopy,
-- whose job is specifically to avoid retaining runtime objects in debug logs.
local function componentValueCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local out = {}
    seen[value] = out
    for k, v in pairs(value) do
        out[componentValueCopy(k, seen)] = componentValueCopy(v, seen)
    end
    return out
end

function Library:_RecordDiagnostic(kind, message, context)
    local diagnostics = self.Diagnostics
    kind = tostring(kind or "Info")
    if kind == "Error" then diagnostics.CallbackErrors += 1 end
    if kind == "Warning" then diagnostics.Warnings += 1 end

    local record = {
        Kind = kind,
        Message = tostring(message or ""),
        Context = diagnosticCopy(context or {}),
        Time = os.clock(),
    }

    local traceOk, trace = pcall(function()
        if debug and type(debug.traceback) == "function" then
            return debug.traceback(nil, 3)
        end
        return nil
    end)
    if traceOk and trace then record.Traceback = tostring(trace) end

    table.insert(diagnostics.Records, record)
    local maxRecords = math.max(10, tonumber(diagnostics.MaxRecords) or 100)
    while #diagnostics.Records > maxRecords do
        table.remove(diagnostics.Records, 1)
    end
    return record
end

function Library:GetDiagnostics()
    return diagnosticCopy(self.Diagnostics)
end

function Library:ClearDiagnostics()
    self.Diagnostics.SafeCalls = 0
    self.Diagnostics.CallbackErrors = 0
    self.Diagnostics.Warnings = 0
    table.clear(self.Diagnostics.Records)
    return true
end

function Library:BindTheme(instance, property, token, transform)
    if typeof(instance) ~= "Instance" then
        return nil
    end

    token = tostring(token or "")
    if token == "" or Theme[token] == nil then
        return nil
    end

    local bindings = self._themeBindings[instance]
    if not bindings then
        bindings = {}
        self._themeBindings[instance] = bindings
    end

    bindings[property] = {
        Token = token,
        Transform = transform,
    }

    local value = Theme[token]
    if type(transform) == "function" then
        local ok, transformed = pcall(transform, value, Theme)
        if ok then value = transformed end
    end

    pcall(function()
        instance[property] = value
    end)

    return instance
end

function Library:GetThemeBinding(instance, property)
    local bindings = self._themeBindings[instance]
    return bindings and bindings[property] or nil
end

function Library:_RebindThemeFromCurrentValues(root, sourceTheme)
    for instance, bindings in pairs(self._themeBindings) do
        if instance and instance.Parent then
            local insideRoot = root == nil
                or instance == root
                or instance:IsDescendantOf(root)

            if insideRoot then
                for property, binding in pairs(bindings) do
                    local ok, current = pcall(function()
                        return instance[property]
                    end)

                    if ok and typeof(current) == "Color3" then
                        local token, factor = self:_ThemeBindingForColor(
                            current,
                            sourceTheme
                        )

                        if token then
                            binding.Token = token
                            binding.Transform = factor and function(color)
                                return Library:_ThemeShade(color, factor)
                            end or nil
                        end
                    end
                end
            end
        end
    end
end

function Library:UnbindTheme(instance, property)
    local bindings = self._themeBindings[instance]
    if not bindings then return false end

    if property ~= nil then
        bindings[property] = nil
    else
        self._themeBindings[instance] = nil
    end

    return true
end

function Library:_ApplyThemeBindings(root)
    for instance, bindings in pairs(self._themeBindings) do
        if instance and instance.Parent then
            local insideRoot = root == nil or instance == root or instance:IsDescendantOf(root)

            if insideRoot then
                for property, binding in pairs(bindings) do
                    local value = Theme[binding.Token]

                    if type(binding.Transform) == "function" then
                        local ok, transformed = pcall(
                            binding.Transform,
                            value,
                            Theme
                        )
                        if ok then value = transformed end
                    end

                    pcall(function()
                        instance[property] = value
                    end)
                end
            end
        else
            self._themeBindings[instance] = nil
        end
    end
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _handlers = {}, _destroyed = false }, Signal)
end

function Signal:Connect(callback)
    if self._destroyed or type(callback) ~= "function" then
        return { Disconnect = function() end }
    end

    local connection = { Connected = true }
    self._handlers[connection] = callback

    function connection:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        if self._owner then
            self._owner._handlers[self] = nil
        end
    end
    connection._owner = self
    return connection
end

function Signal:Once(callback)
    local connection
    connection = self:Connect(function(...)
        if connection then connection:Disconnect() end
        callback(...)
    end)
    return connection
end

function Signal:Fire(...)
    if self._destroyed then return end
    for connection, callback in pairs(self._handlers) do
        if connection.Connected then
            local ok, err = pcall(callback, ...)
            if not ok and Library.DebugEnabled then
                warn("[MistUI Signal] " .. tostring(err))
            end
        end
    end
end

function Signal:ConnectionCount()
    local count = 0
    for connection in pairs(self._handlers) do
        if connection.Connected then count += 1 end
    end
    return count
end

function Signal:Destroy()
    self._destroyed = true
    for connection in pairs(self._handlers) do
        connection.Connected = false
        connection._owner = nil
    end
    table.clear(self._handlers)
end

Library.Signal = Signal

Library._flagSignals = Library._flagSignals or {}
Library.FlagChanged = Library.FlagChanged or Signal.new()

function Library:_GetFlagSignal(flag)
    flag = self:_NormalizeFlag(flag)
    if not flag then
        return nil
    end

    self._flagSignals[flag] = self._flagSignals[flag] or Signal.new()
    return self._flagSignals[flag]
end

function Library:ObserveFlag(flag, callback, fireImmediately)
    local signalObject = self:_GetFlagSignal(flag)
    if not signalObject then
        return { Disconnect = function() end }
    end

    local connection = signalObject:Connect(callback)

    if fireImmediately == true then
        Library:SafeCall(callback, self:GetFlag(flag), nil, flag)
    end

    return connection
end

local Store = {}
Store.__index = Store

function Store.new(initial)
    local self = setmetatable({}, Store)
    self._values = {}
    self._signals = {}
    self.Changed = Signal.new()

    for key, value in pairs(initial or {}) do
        self._values[key] = value
    end

    return self
end

function Store:Get(key)
    return self._values[key]
end

function Store:Set(key, value)
    local previous = self._values[key]
    if previous == value then
        return value
    end

    self._values[key] = value
    self._signals[key] = self._signals[key] or Signal.new()
    self._signals[key]:Fire(value, previous, key)
    self.Changed:Fire(key, value, previous)
    return value
end

function Store:Observe(key, callback, fireImmediately)
    self._signals[key] = self._signals[key] or Signal.new()
    local connection = self._signals[key]:Connect(callback)

    if fireImmediately == true then
        callback(self._values[key], nil, key)
    end

    return connection
end

function Store:Snapshot()
    local out = {}
    for key, value in pairs(self._values) do
        out[key] = value
    end
    return out
end

function Store:Destroy()
    for _, signalObject in pairs(self._signals) do
        signalObject:Destroy()
    end
    table.clear(self._signals)
    self.Changed:Destroy()
end

Library.Store = Store

local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Give(taskObject)
    if taskObject ~= nil then
        table.insert(self._tasks, taskObject)
    end
    return taskObject
end

function Maid:Cleanup()
    for i = #self._tasks, 1, -1 do
        local item = self._tasks[i]
        self._tasks[i] = nil
        local kind = typeof(item)
        if kind == "RBXScriptConnection" then
            pcall(function() item:Disconnect() end)
        elseif kind == "Instance" then
            pcall(function() item:Destroy() end)
        elseif type(item) == "function" then
            pcall(item)
        elseif type(item) == "table" then
            if type(item.Destroy) == "function" then
                pcall(function() item:Destroy() end)
            elseif type(item.Disconnect) == "function" then
                pcall(function() item:Disconnect() end)
            elseif type(item.Cleanup) == "function" then
                pcall(function() item:Cleanup() end)
            end
        end
    end
end

function Maid:Count()
    return #self._tasks
end

function Maid:GetTasks()
    local out = {}
    for i, item in ipairs(self._tasks) do out[i] = item end
    return out
end

Maid.Destroy = Maid.Cleanup
Library.Maid = Maid

function Library:_EnsureComponentAPI(component, root)
    if type(component) ~= "table" then
        return component
    end

    root = root or component.Container or component.Instance

    component._events = component._events or {}

    local function event(name)
        name = tostring(name or "")
        component._events[name] = component._events[name] or Signal.new()
        return component._events[name]
    end

    if type(component.On) ~= "function" then
        function component:On(name, callback)
            return event(name):Connect(callback)
        end
    end

    if type(component.Emit) ~= "function" then
        function component:Emit(name, ...)
            event(name):Fire(...)
            return self
        end
    end

    if type(component.OnChanged) ~= "function" then
        function component:OnChanged(callback)
            return self:On("Changed", callback)
        end
    end

    if type(component.GetInstance) ~= "function" then
        function component:GetInstance()
            return self.Instance
        end
    end

    if type(component.GetContainer) ~= "function" then
        function component:GetContainer()
            return self.Container or self.Instance
        end
    end

    if type(component.IsVisible) ~= "function" then
        function component:IsVisible()
            local target = self.Container or self.Instance
            return not target or not target:IsA("GuiObject") or target.Visible
        end
    end

    if type(component.IsDisabled) ~= "function" then
        function component:IsDisabled()
            local target = self.Container or self.Instance
            return target and target:GetAttribute("Disabled") == true or false
        end
    end

    if type(component.Show) ~= "function" and type(component.SetVisible) == "function" then
        function component:Show()
            return self:SetVisible(true)
        end
    end

    if type(component.Hide) ~= "function" and type(component.SetVisible) == "function" then
        function component:Hide()
            return self:SetVisible(false)
        end
    end

    if type(component.Enable) ~= "function" and type(component.SetDisabled) == "function" then
        function component:Enable()
            return self:SetDisabled(false)
        end
    end

    if type(component.Disable) ~= "function" and type(component.SetDisabled) == "function" then
        function component:Disable()
            return self:SetDisabled(true)
        end
    end

    if type(component.GetFlag) ~= "function" then
        function component:GetFlag()
            return self.Flag
        end
    end

    -- Universal visibility/disabled fallbacks make stateless and passthrough
    -- components obey the same lifecycle contract as stateful controls.
    if type(component.SetVisible) ~= "function" and root and root:IsA("GuiObject") then
        function component:SetVisible(value)
            root.Visible = value ~= false
            return self
        end
    end

    if type(component.SetDisabled) ~= "function" and root and root:IsA("GuiObject") then
        function component:SetDisabled(value)
            local disabled = value == true
            root:SetAttribute("Disabled", disabled)
            if root:IsA("GuiButton") then
                pcall(function() root.Interactable = not disabled end)
                root.Active = not disabled
            elseif root:IsA("TextBox") then
                pcall(function() root.TextEditable = not disabled end)
                root.Active = not disabled
            end
            return self
        end
    end

    -- Fallbacks may have been installed above; add the convenience aliases now.
    if type(component.Show) ~= "function" and type(component.SetVisible) == "function" then
        function component:Show() return self:SetVisible(true) end
    end
    if type(component.Hide) ~= "function" and type(component.SetVisible) == "function" then
        function component:Hide() return self:SetVisible(false) end
    end
    if type(component.Enable) ~= "function" and type(component.SetDisabled) == "function" then
        function component:Enable() return self:SetDisabled(false) end
    end
    if type(component.Disable) ~= "function" and type(component.SetDisabled) == "function" then
        function component:Disable() return self:SetDisabled(true) end
    end

    -- Capture a stable default once. Advanced components generally expose
    -- colon-style methods; legacy controls are normalized by registerNormalControl.
    if component._mistDefaultCaptured ~= true then
        component._mistDefaultCaptured = true
        if component.Default ~= nil then
            component._mistDefault = componentValueCopy(component.Default)
        end
    end

    if type(component.GetDefault) ~= "function" then
        function component:GetDefault()
            return componentValueCopy(self._mistDefault ~= nil and self._mistDefault or self.Default)
        end
    end

    if type(component.SetDefault) ~= "function" then
        function component:SetDefault(value)
            self._mistDefault = componentValueCopy(value)
            self.Default = componentValueCopy(value)
            return self
        end
    end

    if type(component.Reset) ~= "function" then
        function component:Reset(fire)
            local value = self._mistDefault ~= nil and componentValueCopy(self._mistDefault) or componentValueCopy(self.Default)
            if value == nil then return self end
            if fire == false and type(self.SetSilent) == "function" then
                self:SetSilent(value)
            elseif type(self.Set) == "function" then
                self:Set(value)
            elseif type(self.SetValue) == "function" then
                self:SetValue(value)
            end
            return self
        end
    end

    if type(component.IsDestroyed) ~= "function" then
        function component:IsDestroyed()
            local target = self.Container or self.Instance
            return self._mistDestroyed == true or (typeof(target) == "Instance" and target.Parent == nil)
        end
    end

    if type(component.DestroyEvents) ~= "function" then
        function component:DestroyEvents()
            for _, signalObject in pairs(self._events or {}) do
                if signalObject and type(signalObject.Destroy) == "function" then
                    signalObject:Destroy()
                end
            end
            table.clear(self._events)
            return self
        end
    end

    return component
end

function Library:GetVersion()
    return self.Version
end

function Library:SetDebugMode(enabled)
    self.DebugEnabled = enabled == true
    return self.DebugEnabled
end

function Library:Debug(...)
    if self.DebugEnabled then
        print("[MistUI]", ...)
    end
end

function Library:SafeCallContext(context, callback, ...)
    self.Diagnostics.SafeCalls += 1
    if type(callback) ~= "function" then
        local message = "callback is not a function"
        self:_RecordDiagnostic("Error", message, context)
        return false, message
    end

    local results = table.pack(pcall(callback, ...))
    if not results[1] then
        local activeWindow = self._activeWindow
        local enriched = diagnosticCopy(context or {})
        if activeWindow then
            enriched.Window = enriched.Window or tostring(activeWindow._title or "MistUI")
            enriched.Tab = enriched.Tab or (activeWindow._activeTab and activeWindow._activeTab.Name or nil)
        end
        local infoOk, source, line, functionName = pcall(function()
            if debug and type(debug.info) == "function" then
                return debug.info(3, "sln")
            end
            return nil, nil, nil
        end)
        if infoOk then
            enriched.Source = enriched.Source or source
            enriched.Line = enriched.Line or line
            enriched.Function = enriched.Function or functionName
        end
        self:_RecordDiagnostic("Error", tostring(results[2]), enriched)
        if self.DebugEnabled then
            warn("[MistUI Callback] " .. tostring(results[2]))
        end
    end
    return table.unpack(results, 1, results.n)
end

function Library:SafeCall(callback, ...)
    return self:SafeCallContext(nil, callback, ...)
end

function Library:Boundary(context, callback)
    assert(type(callback) == "function", "Boundary callback must be a function")
    return function(...)
        return Library:SafeCallContext(context, callback, ...)
    end
end

function Library:SetAnimationsEnabled(enabled)
    self.AnimationSettings.Enabled = enabled ~= false
end

function Library:SetAnimationSpeed(multiplier)
    self.AnimationSettings.Speed = math.max(0.05, tonumber(multiplier) or 1)
end

function Library:SetReducedMotion(enabled)
    self.AnimationSettings.ReducedMotion = enabled == true
end

function Library:RegisterLocale(name, values)
    name = tostring(name or "")
    if name == "" or type(values) ~= "table" then return false end
    self.Locales[name] = values
    return true
end

function Library:SetLocale(name)
    name = tostring(name or "")
    if not self.Locales[name] then return false end
    self.Locale = name
    return true
end

function Library:T(key, fallback)
    local locale = self.Locales[self.Locale] or {}
    local value = locale[key]
    if value == nil then return fallback ~= nil and fallback or tostring(key) end
    return value
end

function Library:CreateMaid()
    return Maid.new()
end

function Library:NextZIndex()
    self._zIndexCounter += 10
    return self._zIndexCounter
end

function Library:RegisterConfigMigration(fromVersion, callback)
    fromVersion = tonumber(fromVersion)
    if not fromVersion or type(callback) ~= "function" then return false end
    self.ConfigMigrations[fromVersion] = callback
    return true
end

function Library:_RunConfigMigrations(data)
    if type(data) ~= "table" then return data end
    local version = tonumber(data.SchemaVersion) or 1
    local guard = 0
    while version < (self.SchemaVersion or 5) and guard < 32 do
        guard += 1
        local migrate = self.ConfigMigrations[version]
        if type(migrate) == "function" then
            local ok, result = pcall(migrate, data)
            if ok and type(result) == "table" then
                data = result
            elseif not ok and self.DebugEnabled then
                warn("[MistUI Migration] " .. tostring(result))
            end
        end
        version += 1
        data.SchemaVersion = version
    end
    return data
end

function Library:_NormalizeFlag(flag)
    if flag == nil then return nil end
    local clean = tostring(flag)
    clean = clean:gsub("^%s+", ""):gsub("%s+$", "")
    if clean == "" then return nil end
    return clean
end

function Library:_RegisterFlagComponent(flag, component)
    flag = self:_NormalizeFlag(flag)
    if not flag or type(component) ~= "table" then return nil end

    component.Flag = flag
    local existing = self.ComponentsByFlag[flag]
    if existing and existing ~= component then
        self:_RecordDiagnostic("Warning", "Duplicate component flag registered: " .. flag, {
            Operation = "RegisterFlag", Flag = flag,
        })
    end
    self.ComponentsByFlag[flag] = component

    -- Configs can be loaded before lazy tabs/cards are built.
    -- Cached config data must therefore override a component's default.
    if self.Flags[flag] ~= nil then
        local setter = component.SetConfigValueSilent
            or component.SetSilent
            or component.SetValueSilent
            or component.SetConfigValue
            or component.Set
            or component.SetValue

        if type(setter) == "function" then
            local ok = pcall(setter, self.Flags[flag])
            if not ok then
                pcall(setter, component, self.Flags[flag])
            end
        end
        return flag
    end

    local getter = component.GetConfigValue or component.Get or component.GetValue
    if type(getter) == "function" then
        local ok, value = pcall(getter)
        if not ok then
            ok, value = pcall(getter, component)
        end
        if ok and value ~= nil then
            self:_UpdateFlagValue(flag, value)
        end
    end

    return flag
end

function Library:_UpdateFlagValue(flag, value)
    flag = self:_NormalizeFlag(flag)
    if not flag then return end

    local previous = self.Flags[flag]
    self.Flags[flag] = value

    if previous ~= value then
        local signalObject = self:_GetFlagSignal(flag)
        if signalObject then
            signalObject:Fire(value, previous, flag)
        end

        if self.FlagChanged then
            self.FlagChanged:Fire(flag, value, previous)
        end

        local activeWindow = self._activeWindow
        if activeWindow and activeWindow._store then
            activeWindow._store:Set(flag, value)
        end
    end
end

function Library:GetFlag(flag)
    flag = self:_NormalizeFlag(flag)
    return flag and self.Flags[flag] or nil
end

function Library:GetFlags()
    local copy = {}
    for k, v in pairs(self.Flags) do
        if type(v) == "table" then
            local sub = {}
            for sk, sv in pairs(v) do
                sub[sk] = sv
            end
            copy[k] = sub
        else
            copy[k] = v
        end
    end
    return copy
end

function Library:SetFlag(flag, value, silent)
    flag = self:_NormalizeFlag(flag)
    if not flag then return false end

    local component = self.ComponentsByFlag[flag]
    if not component then
        self:_UpdateFlagValue(flag, value)
        return false
    end

    local setter = silent
        and (component.SetConfigValueSilent or component.SetSilent or component.SetValueSilent or component.SetValue)
        or (component.SetConfigValue or component.Set or component.SetValue or component.SetSilent)

    if type(setter) == "function" then
        local ok = pcall(setter, value)
        if not ok then
            ok = pcall(setter, component, value)
        end

        if ok then
            self:_UpdateFlagValue(flag, value)
            return true
        end
    end

    self:_UpdateFlagValue(flag, value)
    return false
end

local function serializeConfigValue(value, seen)
    seen = seen or {}

    local valueType = typeof(value)

    if value == nil
        or valueType == "string"
        or valueType == "number"
        or valueType == "boolean" then
        return value
    end

    if valueType == "Color3" then
        return {
            __mist_type = "Color3",
            r = value.R,
            g = value.G,
            b = value.B,
        }
    end

    if valueType == "EnumItem" then
        return {
            __mist_type = "EnumItem",
            enum = tostring(value.EnumType),
            name = value.Name,
        }
    end

    if valueType == "Vector2" then
        return {
            __mist_type = "Vector2",
            x = value.X,
            y = value.Y,
        }
    end

    if valueType == "Vector3" then
        return {
            __mist_type = "Vector3",
            x = value.X,
            y = value.Y,
            z = value.Z,
        }
    end

    if valueType == "UDim" then
        return {
            __mist_type = "UDim",
            scale = value.Scale,
            offset = value.Offset,
        }
    end

    if valueType == "UDim2" then
        return {
            __mist_type = "UDim2",
            xs = value.X.Scale,
            xo = value.X.Offset,
            ys = value.Y.Scale,
            yo = value.Y.Offset,
        }
    end

    if valueType == "table" then
        if seen[value] then
            return nil
        end
        seen[value] = true

        local output = {}
        for k, v in pairs(value) do
            local key = type(k) == "string" and k or tostring(k)
            local serialized = serializeConfigValue(v, seen)
            if serialized ~= nil then
                output[key] = serialized
            end
        end

        seen[value] = nil
        return output
    end

    -- Skip Instances, functions, userdata and unsupported Roblox types
    -- instead of making JSONEncode fail for the entire config.
    return nil
end

local function deserializeConfigValue(value)
    if type(value) ~= "table" then
        return value
    end

    local marker = value.__mist_type

    if marker == "Color3" then
        return Color3.new(
            tonumber(value.r) or 0,
            tonumber(value.g) or 0,
            tonumber(value.b) or 0
        )
    end

    if marker == "EnumItem" then
        local enumName = tostring(value.enum or ""):match("^Enum%.(.+)$")
        if enumName and Enum[enumName] and value.name and Enum[enumName][value.name] then
            return Enum[enumName][value.name]
        end
        return nil
    end

    if marker == "Vector2" then
        return Vector2.new(tonumber(value.x) or 0, tonumber(value.y) or 0)
    end

    if marker == "Vector3" then
        return Vector3.new(
            tonumber(value.x) or 0,
            tonumber(value.y) or 0,
            tonumber(value.z) or 0
        )
    end

    if marker == "UDim" then
        return UDim.new(tonumber(value.scale) or 0, tonumber(value.offset) or 0)
    end

    if marker == "UDim2" then
        return UDim2.new(
            tonumber(value.xs) or 0,
            tonumber(value.xo) or 0,
            tonumber(value.ys) or 0,
            tonumber(value.yo) or 0
        )
    end

    local output = {}
    for k, v in pairs(value) do
        if k ~= "__mist_type" then
            output[k] = deserializeConfigValue(v)
        end
    end
    return output
end

function Library:_CollectFlagValues()
    local data = {}

    -- Include every value written through _UpdateFlagValue too.
    for flag, value in pairs(self.Flags) do
        local serialized = serializeConfigValue(value)
        if serialized ~= nil then
            data[flag] = serialized
        end
    end

    -- Registered components override the cached value with their live value.
    for flag, component in pairs(self.ComponentsByFlag) do
        local getter = component.GetConfigValue or component.Get or component.GetValue
        if type(getter) == "function" then
            local ok, value = pcall(getter, component)
            if ok then
                local serialized = serializeConfigValue(value)
                if serialized ~= nil then
                    data[flag] = serialized
                end
            end
        end
    end

    return data
end

function Library:_ApplyFlagValues(payload)
    if type(payload) ~= "table" then return false end

    for flag, value in pairs(payload) do
        local restored = deserializeConfigValue(value)
        self:SetFlag(flag, restored, true)
    end

    return true
end

Library:RegisterConfigMigration(3, function(data)
    data.Interface = data.Interface or {}

    if data.Interface.FunctionInfo == nil then
        data.Interface.FunctionInfo = true
    end

    data.SchemaVersion = 4
    return data
end)

Library:RegisterConfigMigration(4, function(data)
    data.Interface = data.Interface or {}
    data.Notifications = data.Notifications or {}
    if data.Notifications.PauseOnHover == nil then
        data.Notifications.PauseOnHover = true
    end
    if data.Interface.ReducedMotion == nil then data.Interface.ReducedMotion = false end
    if data.Interface.AnimationSpeed == nil then data.Interface.AnimationSpeed = 1 end
    if data.Interface.Responsive == nil then data.Interface.Responsive = true end
    data.SchemaVersion = 5
    return data
end)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------
local function create(class, props, children)
    local inst = Instance.new(class)
    -- Remove a borda azul padrão do Roblox (BorderSizePixel=1 / BorderColor3
    -- azulado) de QUALQUER GuiObject, antes de aplicar as props do usuário
    -- (assim, se alguém passar BorderSizePixel explicitamente, ainda funciona).
    if inst:IsA("GuiObject") then
        inst.BorderSizePixel = 0
    end

    -- Parent is applied LAST. This guarantees properties such as Selectable=false
    -- are already in place before ScreenGui.DescendantAdded sees the instance.
    -- Without this, focus preparation could attach a selection stroke before the
    -- component had finished applying its intended non-selectable state.
    local requestedParent = props and props.Parent or nil
    for prop, value in pairs(props or {}) do
        if prop ~= "Parent" then
            inst[prop] = value

            if typeof(value) == "Color3" then
                local token, factor = Library:_ThemeBindingForColor(value, Theme)
                if token then
                    Library:BindTheme(
                        inst,
                        prop,
                        token,
                        factor and function(color)
                            return Library:_ThemeShade(color, factor)
                        end or nil
                    )
                end
            end
        end
    end

    for _, child in ipairs(children or {}) do
        if child then
            child.Parent = inst
        end
    end
    if requestedParent then
        inst.Parent = requestedParent
    end
    return inst
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function padding(all, l, t, r, b)
    return create("UIPadding", {
        PaddingLeft   = UDim.new(0, l or all or 0),
        PaddingTop    = UDim.new(0, t or all or 0),
        PaddingRight  = UDim.new(0, r or all or 0),
        PaddingBottom = UDim.new(0, b or all or 0),
    })
end

local function tween(inst, props, time, style, dir)
    local settings = Library.AnimationSettings or {}
    local duration = time or 0.18

    for property, value in pairs(props or {}) do
        if typeof(value) == "Color3" then
            local token, factor = Library:_ThemeBindingForColor(value, Theme)
            if token then
                Library:BindTheme(
                    inst,
                    property,
                    token,
                    factor and function(color)
                        return Library:_ThemeShade(color, factor)
                    end or nil
                )
            else
                Library:UnbindTheme(inst, property)
            end
        end
    end

    if settings.Enabled == false or settings.ReducedMotion == true then
        duration = 0
    else
        duration = duration / math.max(0.05, tonumber(settings.Speed) or 1)
    end

    local info = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

-- Shared motion values come from the design system.
local MOTION = Theme.Motion

local function smoothTween(inst, props, duration, style, direction)
    return tween(
        inst,
        props,
        duration or MOTION.Normal,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
end

local DragController = {}
DragController.__index = DragController

function DragController.new(maid)
    local self = setmetatable({}, DragController)
    self._maid = maid
    self._active = nil

    self._maid:Give(UserInputService.InputChanged:Connect(function(input)
        local active = self._active
        if not active
            or input ~= active.Input
            or active.Target:GetAttribute("DragLocked") == true then
            return
        end

        local delta = input.Position - active.StartInput
        local startPos = active.StartPosition

        active.Target.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end))

    return self
end

function DragController:Attach(handle, target)
    local candidateInput = nil

    self._maid:Give(handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            candidateInput = input
        end
    end))

    self._maid:Give(handle.InputBegan:Connect(function(input)
        if target:GetAttribute("DragLocked") == true then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local activeInput = candidateInput or input

        self._active = {
            Target = target,
            Input = activeInput,
            StartInput = input.Position,
            StartPosition = target.Position,
        }

        local endConnection
        endConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                if self._active and self._active.Target == target then
                    self._active = nil
                end

                if endConnection then
                    endConnection:Disconnect()
                end
            end
        end)

        self._maid:Give(endConnection)
    end))

    return target
end

function DragController:Destroy()
    self._active = nil
end

local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() or CoreGui end)
    if ok and hui then return hui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

------------------------------------------------------------
-- ÍCONES: Lucide real via lucide-roblox (latte-soft), com
-- fallback vetorial DESENHADO (não uma bolinha genérica) caso
-- o HttpGet falhe (runtime sem rede / domínio bloqueado).
-- https://github.com/latte-soft/lucide-roblox
------------------------------------------------------------
Library.UseRemoteIcons = Library.UseRemoteIcons == true
Library.RemoteIconUrls = Library.RemoteIconUrls or {
    "https://github.com/latte-soft/lucide-roblox/releases/latest/download/lucide-roblox.luau",
    "https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/lucide-roblox.luau",
}

local Lucide

function Library:LoadRemoteIcons()
    if Lucide then return true end
    for _, url in ipairs(self.RemoteIconUrls or {}) do
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and result then
            Lucide = result
            self.UseRemoteIcons = true
            return true
        end
    end
    return false
end

function Library:SetRemoteIconsEnabled(enabled)
    self.UseRemoteIcons = enabled == true
    if self.UseRemoteIcons then
        return self:LoadRemoteIcons()
    end
    return true
end

if Library.UseRemoteIcons then
    Library:LoadRemoteIcons()
end

------------------------------------------------------------
-- FALLBACK VETORIAL (usado só se o Lucide não carregar).
-- Desenhado à mão, fino, consistente com o resto da UI — nada
-- de bolinha genérica.
------------------------------------------------------------
local function rect(container, size, pos, cornerRadius, anchor)
    return create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        AnchorPoint = anchor or Vector2.new(0.5, 0.5),
        Position = pos, Size = size, ZIndex = 6, Parent = container,
    }, { corner(cornerRadius or 1) })
end

local FALLBACK_ICONS = {}

FALLBACK_ICONS["x"] = function(container, s, color)
    local a = rect(container, UDim2.new(0, s * 0.7, 0, 1.4), UDim2.new(0.5, 0, 0.5, 0), 1); a.Rotation = 45
    local b = rect(container, UDim2.new(0, s * 0.7, 0, 1.4), UDim2.new(0.5, 0, 0.5, 0), 1); b.Rotation = -45
    a.BackgroundColor3 = color; b.BackgroundColor3 = color
    return { a, b }
end

FALLBACK_ICONS["search"] = function(container, s, color)
    local ring = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.42, 0, 0.42, 0), Size = UDim2.new(0, s * 0.55, 0, s * 0.55),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.4, 0) })
    local handle = rect(container, UDim2.new(0, s * 0.32, 0, 1.4), UDim2.new(0.76, 0, 0.76, 0), 1)
    handle.Rotation = 45
    handle.BackgroundColor3 = color
    return { ring, handle }
end

FALLBACK_ICONS["chevron-right"] = function(container, s, color)
    local a = rect(container, UDim2.new(0, s * 0.13, 0, s * 0.42), UDim2.new(0.5, -s * 0.06, 0.5, -s * 0.16), 1)
    a.Rotation = 28
    local b = rect(container, UDim2.new(0, s * 0.13, 0, s * 0.42), UDim2.new(0.5, -s * 0.06, 0.5, s * 0.16), 1)
    b.Rotation = -28
    a.BackgroundColor3 = color; b.BackgroundColor3 = color
    return { a, b }
end

FALLBACK_ICONS["chevron-left"] = function(container, s, color)
    local parts = FALLBACK_ICONS["chevron-right"](container, s, color)
    for _, p in ipairs(parts) do p.Rotation = -p.Rotation end
    return parts
end


FALLBACK_ICONS["minus"] = function(container, s, color)
    local line = rect(container, UDim2.new(0, s * 0.62, 0, 1.6), UDim2.new(0.5, 0, 0.5, 0), 1)
    line.BackgroundColor3 = color
    return { line }
end

FALLBACK_ICONS["plus"] = function(container, s, color)
    local h = rect(container, UDim2.new(0, s * 0.62, 0, 1.6), UDim2.new(0.5, 0, 0.5, 0), 1)
    local v = rect(container, UDim2.new(0, 1.6, 0, s * 0.62), UDim2.new(0.5, 0, 0.5, 0), 1)
    h.BackgroundColor3 = color
    v.BackgroundColor3 = color
    return { h, v }
end

FALLBACK_ICONS["check"] = function(container, s, color)
    local a = rect(container, UDim2.new(0, s * 0.30, 0, 1.7), UDim2.new(0.42, -s * 0.08, 0.56, 0), 1)
    a.Rotation = 45
    local b = rect(container, UDim2.new(0, s * 0.52, 0, 1.7), UDim2.new(0.56, s * 0.03, 0.49, 0), 1)
    b.Rotation = -45
    a.BackgroundColor3 = color
    b.BackgroundColor3 = color
    return { a, b }
end

FALLBACK_ICONS["file"] = function(container, s, color)
    local outer = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, s * 0.62, 0, s * 0.8),
        ZIndex = 6, Parent = container,
    }, { corner(2), stroke(color, 1.2, 0) })
    local line1 = rect(outer, UDim2.new(0, s * 0.34, 0, 1.2), UDim2.new(0.5, 0, 0.42, 0), 1)
    local line2 = rect(outer, UDim2.new(0, s * 0.34, 0, 1.2), UDim2.new(0.5, 0, 0.62, 0), 1)
    line1.BackgroundColor3 = color; line2.BackgroundColor3 = color
    return { outer, line1, line2 }
end

FALLBACK_ICONS["star"] = function(container, s, color)
    local a = rect(container, UDim2.new(0, s * 0.62, 0, s * 0.62), UDim2.new(0.5, 0, 0.5, 0), 2)
    local b = rect(container, UDim2.new(0, s * 0.62, 0, s * 0.62), UDim2.new(0.5, 0, 0.5, 0), 2); b.Rotation = 45
    a.BackgroundColor3 = color; b.BackgroundColor3 = color
    return { a, b }
end

-- Engrenagem simplificada: anel + núcleo (usada pelo botão de Settings,
-- que antes caía no traço genérico por não ter desenho próprio).
FALLBACK_ICONS["settings"] = function(container, s, color)
    local ring = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, s * 0.64, 0, s * 0.64),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.4, 0) })
    local coreDot = rect(container, UDim2.new(0, s * 0.2, 0, s * 0.2), UDim2.new(0.5, 0, 0.5, 0), 9999)
    coreDot.BackgroundColor3 = color
    local teeth = {}
    for i = 0, 3 do
        local tooth = rect(container, UDim2.new(0, s * 0.14, 0, s * 0.86), UDim2.new(0.5, 0, 0.5, 0), 1)
        tooth.Rotation = i * 45
        tooth.BackgroundColor3 = color
        tooth.ZIndex = 5
        table.insert(teeth, tooth)
    end
    ring.ZIndex = 6
    coreDot.ZIndex = 7
    return { ring, coreDot, teeth[1], teeth[2], teeth[3], teeth[4] }
end

-- User/profile icon fallback.
FALLBACK_ICONS["user"] = function(container, s, color)
    local parts = {}
    local head = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.32, 0), Size = UDim2.new(0, s * 0.34, 0, s * 0.34),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.35, 0) })
    local shoulders = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.73, 0), Size = UDim2.new(0, s * 0.72, 0, s * 0.38),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.35, 0) })
    table.insert(parts, head)
    table.insert(parts, shoulders)
    return parts
end

-- Eye icon fallback.
FALLBACK_ICONS["eye"] = function(container, s, color)
    local outer = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, s * 0.86, 0, s * 0.5),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.3, 0) })
    local pupil = rect(container, UDim2.new(0, s * 0.22, 0, s * 0.22), UDim2.new(0.5, 0, 0.5, 0), 9999)
    pupil.BackgroundColor3 = color
    return { outer, pupil }
end

-- Quadrado vazado: usado no Box (visual).
FALLBACK_ICONS["square"] = function(container, s, color)
    local outline = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, s * 0.6, 0, s * 0.6),
        ZIndex = 6, Parent = container,
    }, { corner(3), stroke(color, 1.4, 0) })
    return { outline }
end

-- Régua: usada em Distance.
FALLBACK_ICONS["ruler"] = function(container, s, color)
    local body_ = rect(container, UDim2.new(0, s * 0.86, 0, s * 0.32), UDim2.new(0.5, 0, 0.5, 0), 2)
    body_.Rotation = -35
    body_.BackgroundColor3 = color
    body_.ZIndex = 6
    return { body_ }
end

-- Gema (diamante): usada em farms de item.
FALLBACK_ICONS["gem"] = function(container, s, color)
    local d = rect(container, UDim2.new(0, s * 0.5, 0, s * 0.5), UDim2.new(0.5, 0, 0.5, 0), 2)
    d.Rotation = 45
    d.BackgroundColor3 = color
    return { d }
end

-- Cifrão ($): usado em farms de moeda. Desenhado como texto porque
-- reproduzir um "$" com retângulos/anéis fica irreconhecível.
FALLBACK_ICONS["dollar"] = function(container, s, color)
    local label = create("TextLabel", {
        Text = "$", FontFace = Theme.FontBold, TextSize = math.floor(s * 0.9),
        TextColor3 = color, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 6, Parent = container,
    })
    return { label }
end

-- Crossed-swords fallback icon.
FALLBACK_ICONS["swords"] = function(container, s, color)
    local a = rect(container, UDim2.new(0, s * 0.85, 0, s * 0.15), UDim2.new(0.5, 0, 0.5, 0), 2)
    a.Rotation = 45
    local b = rect(container, UDim2.new(0, s * 0.85, 0, s * 0.15), UDim2.new(0.5, 0, 0.5, 0), 2)
    b.Rotation = -45
    a.BackgroundColor3 = color; b.BackgroundColor3 = color
    return { a, b }
end

-- Shield icon fallback used by Activity detector sections.
FALLBACK_ICONS["shield"] = function(container, s, color)
    local body = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, s * 0.68, 0, s * 0.78),
        Rotation = 0,
        ZIndex = 6,
        Parent = container,
    }, { corner(4), stroke(color, 1.35, 0) })
    local bottom = rect(container, UDim2.new(0, s * 0.38, 0, s * 0.10), UDim2.new(0.5, 0, 0.80, 0), 2)
    bottom.Rotation = 45
    bottom.BackgroundColor3 = color
    bottom.ZIndex = 7
    return { body, bottom }
end

-- Teclado: usado no menu flutuante de Keybinds.
FALLBACK_ICONS["keyboard"] = function(container, s, color)
    local body_ = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, s * 0.88, 0, s * 0.62),
        ZIndex = 6,
        Parent = container,
    }, { corner(3) })

    local outline = stroke(color, 1.25, 0)
    outline.Parent = body_

    local parts = { outline }

    local keyW = s * 0.12
    local keyH = s * 0.10
    local startX = 0.20

    for row = 0, 1 do
        for col = 0, 3 do
            local key = rect(
                body_,
                UDim2.new(0, keyW, 0, keyH),
                UDim2.new(startX + col * 0.20, 0, 0.30 + row * 0.24, 0),
                1
            )
            key.BackgroundColor3 = color
            table.insert(parts, key)
        end
    end

    local space = rect(
        body_,
        UDim2.new(0, s * 0.40, 0, keyH),
        UDim2.new(0.5, 0, 0.78, 0),
        1
    )
    space.BackgroundColor3 = color
    table.insert(parts, space)

    return parts
end

-- Info em círculo: usado pelo Function Info.
FALLBACK_ICONS["info"] = function(container, s, color)
    local ring = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, s * 0.82, 0, s * 0.82),
        ZIndex = 6,
        Parent = container,
    }, { corner(9999), stroke(color, 1.35, 0) })

    local stem = rect(
        container,
        UDim2.new(0, 1.5, 0, s * 0.28),
        UDim2.new(0.5, 0, 0.58, 0),
        1
    )
    stem.BackgroundColor3 = color
    stem.ZIndex = 7

    local dot = rect(
        container,
        UDim2.new(0, s * 0.10, 0, s * 0.10),
        UDim2.new(0.5, 0, 0.31, 0),
        9999
    )
    dot.BackgroundColor3 = color
    dot.ZIndex = 7

    return { ring, stem, dot }
end

-- Map-pin icon fallback.
FALLBACK_ICONS["triangle-alert"] = function(container, s, color)
    local parts = {}
    local left = rect(container, UDim2.new(0, s * 0.62, 0, 1.5), UDim2.new(0.38, 0, 0.48, 0), 1)
    left.Rotation = -58
    left.BackgroundColor3 = color
    table.insert(parts, left)

    local right = rect(container, UDim2.new(0, s * 0.62, 0, 1.5), UDim2.new(0.62, 0, 0.48, 0), 1)
    right.Rotation = 58
    right.BackgroundColor3 = color
    table.insert(parts, right)

    local base = rect(container, UDim2.new(0, s * 0.64, 0, 1.5), UDim2.new(0.5, 0, 0.76, 0), 1)
    base.BackgroundColor3 = color
    table.insert(parts, base)

    local stem = rect(container, UDim2.new(0, 1.6, 0, s * 0.20), UDim2.new(0.5, 0, 0.48, 0), 1)
    stem.BackgroundColor3 = color
    table.insert(parts, stem)

    local dot = rect(container, UDim2.new(0, 2.2, 0, 2.2), UDim2.new(0.5, 0, 0.64, 0), 2)
    dot.BackgroundColor3 = color
    table.insert(parts, dot)
    return parts
end

FALLBACK_ICONS["map-pin"] = function(container, s, color)
    local head = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.38, 0), Size = UDim2.new(0, s * 0.6, 0, s * 0.6),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.4, 0) })
    local dot = rect(container, UDim2.new(0, s * 0.16, 0, s * 0.16), UDim2.new(0.5, 0, 0.38, 0), 9999)
    dot.BackgroundColor3 = color
    local tip = rect(container, UDim2.new(0, s * 0.3, 0, s * 0.3), UDim2.new(0.5, 0, 0.78, 0), 2)
    tip.Rotation = 45
    tip.BackgroundColor3 = color
    return { head, dot, tip }
end

-- Globo: usado em World.
FALLBACK_ICONS["globe"] = function(container, s, color)
    local outerRing = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, s * 0.86, 0, s * 0.86),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.4, 0) })
    local equator = rect(container, UDim2.new(0, s * 0.86, 0, 1.2), UDim2.new(0.5, 0, 0.5, 0), 1)
    equator.BackgroundColor3 = color
    local meridian = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, s * 0.3, 0, s * 0.86),
        ZIndex = 6, Parent = container,
    }, { corner(9999), stroke(color, 1.2, 0) })
    return { outerRing, equator, meridian }
end

-- Três pontos horizontais: usado em Misc.
FALLBACK_ICONS["more-horizontal"] = function(container, s, color)
    local dots = {}
    for i = -1, 1 do
        local dot = rect(container, UDim2.new(0, s * 0.16, 0, s * 0.16), UDim2.new(0.5, i * s * 0.3, 0.5, 0), 9999)
        dot.BackgroundColor3 = color
        table.insert(dots, dot)
    end
    return dots
end

FALLBACK_ICONS["circle"] = FALLBACK_ICONS["circle"] or function(container, s, color)
    local ring = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, s * 0.72, 0, s * 0.72),
        Parent = container,
    }, { corner(9999), stroke(color, math.max(1, s * 0.10), 0) })
    return { ring }
end

FALLBACK_ICONS["refresh-cw"] = FALLBACK_ICONS["refresh-cw"] or function(container, s, color)
    local parts = {}
    local top = create("Frame", {
        BackgroundColor3 = color,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.36, 0),
        Size = UDim2.new(0, s * 0.62, 0, math.max(1, s * 0.10)),
        Rotation = -18,
        Parent = container,
    }, { corner(2) })
    local bottom = create("Frame", {
        BackgroundColor3 = color,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.64, 0),
        Size = UDim2.new(0, s * 0.62, 0, math.max(1, s * 0.10)),
        Rotation = -18,
        Parent = container,
    }, { corner(2) })
    local a1 = create("TextLabel", {
        Text = "›", FontFace = Theme.FontBold, TextSize = math.floor(s * 0.72),
        TextColor3 = color, BackgroundTransparency = 1,
        Position = UDim2.new(0.56, 0, -0.02, 0), Size = UDim2.new(0.4, 0, 0.55, 0),
        Rotation = -18, Parent = container,
    })
    local a2 = create("TextLabel", {
        Text = "‹", FontFace = Theme.FontBold, TextSize = math.floor(s * 0.72),
        TextColor3 = color, BackgroundTransparency = 1,
        Position = UDim2.new(0.04, 0, 0.48, 0), Size = UDim2.new(0.4, 0, 0.55, 0),
        Rotation = -18, Parent = container,
    })
    table.insert(parts, top); table.insert(parts, bottom); table.insert(parts, a1); table.insert(parts, a2)
    return parts
end

local function fallbackIcon(iconName, container, s, color)
    local factory = FALLBACK_ICONS[iconName]
    if factory then return factory(container, s, color) end
    -- nome sem desenho próprio: um traço neutro (nunca uma bola cheia)
    local a = rect(container, UDim2.new(0, s * 0.5, 0, 1.4), UDim2.new(0.5, 0, 0.5, 0), 1)
    a.BackgroundColor3 = color
    return { a }
end

-- Cria o ícone `iconName` dentro de `container`. Retorna a instância
-- (ImageLabel se veio do Lucide, ou uma tabela de Frames se foi o
-- fallback vetorial) — use setIconColor() pra trocar a cor depois.
local function buildIcon(container, iconName, size, color)
    if Lucide then
        local ok, asset = pcall(function() return Lucide.GetAsset(iconName, math.max(16, math.floor(size))) end)
        if ok and asset then
            local img = create("ImageLabel", {
                Image = asset.Url or ("rbxassetid://" .. tostring(asset.Id)),
                ImageRectOffset = asset.ImageRectOffset,
                ImageRectSize = asset.ImageRectSize,
                BackgroundTransparency = 1,
                ImageColor3 = color,
                Size = UDim2.new(0, size, 0, size),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                ZIndex = 6,
                Parent = container,
            })
            return img
        end
    end
    return fallbackIcon(iconName, container, size, color)
end

-- Helper pra mudar a cor de um ícone (funciona tanto pra ImageLabel do
-- Lucide quanto pra tabela de Frames do fallback vetorial).
local function setIconColor(iconInst, color, time)
    if not iconInst then return end
    if typeof(iconInst) == "table" then
        for _, inst in ipairs(iconInst) do
            if inst:IsA("TextLabel") or inst:IsA("TextButton") then
                tween(inst, { TextColor3 = color }, time or 0.15)
            elseif inst:IsA("Frame") then
                tween(inst, { BackgroundColor3 = color }, time or 0.15)
            else
                tween(inst, { Color = color }, time or 0.15) -- UIStroke
            end
        end
        return
    end
    if iconInst:IsA("ImageLabel") then
        tween(iconInst, { ImageColor3 = color }, time or 0.15)
    else
        tween(iconInst, { BackgroundColor3 = color }, time or 0.15)
    end
end

------------------------------------------------------------
-- BOTÃO GENÉRICO
------------------------------------------------------------
local function getButtonVariant(variant)
    variant = variant or "secondary"

    -- Visual unification:
    -- all buttons use the same dark surface style so Settings
    -- no longer mixes dark buttons with bright/white ones.
    if variant == "danger" then
        return Theme.TitleBar, Theme.Text
    elseif variant == "ghost" then
        return Theme.TitleBar, Theme.Text
    elseif variant == "primary" then
        return Theme.TitleBar, Theme.Text
    end

    return Theme.TitleBar, Theme.Text
end

local function shadeColor(color, factor)
    return Color3.new(
        math.clamp(color.R * factor, 0, 1),
        math.clamp(color.G * factor, 0, 1),
        math.clamp(color.B * factor, 0, 1)
    )
end

local function makeButton(parent, text, variant, w, h, callback)
    callback = callback or function() end
    variant = variant or "secondary"

    local baseBg, baseText = getButtonVariant(variant)
    local height = h or 34

    local btn = create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = baseBg,
        BackgroundTransparency = 0,
        Size = UDim2.new(w and 0 or 1, w or 0, 0, height),
        ZIndex = 3,
        Parent = parent,
    }, { corner(12) })

    local label = create("TextLabel", {
        Text = text,
        FontFace = Theme.FontSemibold,
        TextSize = 13,
        TextColor3 = baseText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
        Parent = btn,
    })

    btn:SetAttribute("MistButtonVariant", variant)

    local buttonScale = create("UIScale", {
        Scale = 1,
        Parent = btn,
    })

    btn.MouseEnter:Connect(function()
        local bg, fg = getButtonVariant(variant)
        smoothTween(label, { TextColor3 = fg }, MOTION.Fast)
        smoothTween(btn, { BackgroundColor3 = shadeColor(bg, 1.045) }, MOTION.Normal)
        smoothTween(buttonScale, { Scale = 1.012 }, MOTION.Normal)
    end)

    btn.MouseLeave:Connect(function()
        local bg, fg = getButtonVariant(variant)
        smoothTween(label, { TextColor3 = fg }, MOTION.Fast)
        smoothTween(btn, { BackgroundColor3 = bg }, MOTION.Normal)
        smoothTween(buttonScale, { Scale = 1 }, MOTION.Normal)
    end)

    btn.MouseButton1Down:Connect(function()
        local bg = select(1, getButtonVariant(variant))
        smoothTween(btn, { BackgroundColor3 = shadeColor(bg, 0.93) }, MOTION.Fast)
        smoothTween(buttonScale, { Scale = 0.985 }, MOTION.Fast)
    end)

    btn.MouseButton1Up:Connect(function()
        local bg = select(1, getButtonVariant(variant))
        smoothTween(btn, { BackgroundColor3 = shadeColor(bg, 1.045) }, MOTION.Fast)
        smoothTween(buttonScale, { Scale = 1.012 }, MOTION.Fast)
    end)

    btn.MouseButton1Click:Connect(function()
        Library:SafeCall(callback)
    end)
    return btn
end

------------------------------------------------------------
-- SHARED UI HELPERS
------------------------------------------------------------
local function colorToHex(color)
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function parseHex(value)
    if type(value) ~= "string" then return nil end
    local hex = value:gsub("%s+", ""):gsub("#", "")
    if #hex == 3 then
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    if #hex ~= 6 or not hex:match("^[%da-fA-F]+$") then return nil end

    local r = tonumber(hex:sub(1,2), 16)
    local g = tonumber(hex:sub(3,4), 16)
    local b = tonumber(hex:sub(5,6), 16)

    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end

local function getOverlaySurfaceColor()
    return shadeColor(Theme.CardHover, 1.16)
end

------------------------------------------------------------
-- RUNTIME GLOBAL RESOLVER
------------------------------------------------------------
local function collectRuntimeEnvironments()
    local environments = {}
    local seen = {}

    local function addEnvironment(env)
        if type(env) == "table" and not seen[env] then
            seen[env] = true
            table.insert(environments, env)
        end
    end

    -- Runtime APIs are commonly injected into the current/getgenv environment
    -- without also being copied into _G. Resolve those environments directly,
    -- so runtime globals remain available across supported environments.
    local okGenv, genv = pcall(function()
        if type(getgenv) == "function" then
            return getgenv()
        end
        return nil
    end)
    if okGenv then addEnvironment(genv) end

    addEnvironment(_G)
    return environments
end

local function getRuntimeGlobal(name)
    for _, env in ipairs(collectRuntimeEnvironments()) do
        local ok, value = pcall(function()
            return env[name]
        end)
        if ok and value ~= nil then return value end
    end
    return nil
end

local function getRuntimeFunction(name)
    local value = getRuntimeGlobal(name)
    if type(value) == "function" then
        return value
    end
    return nil
end

local FILE_API_ALIASES = {
    Write = { "writefile", "write_file", "writeFile" },
    Read = { "readfile", "read_file", "readFile" },
    Exists = { "isfile", "is_file", "fileexists", "file_exists" },
    Delete = { "delfile", "deletefile", "delete_file", "removefile", "remove_file" },
    MakeDirectory = { "makefolder", "make_folder", "mkdir" },
    IsDirectory = { "isfolder", "is_folder", "folderexists", "folder_exists" },
    List = { "listfiles", "list_files" },
}

local FILE_NAMESPACE_ALIASES = {
    Write = { "writefile", "write_file", "write", "save" },
    Read = { "readfile", "read_file", "read", "load" },
    Exists = { "isfile", "is_file", "exists", "file_exists" },
    Delete = { "delfile", "deletefile", "delete_file", "delete", "remove" },
    MakeDirectory = { "makefolder", "make_folder", "mkdir", "createfolder", "create_folder" },
    IsDirectory = { "isfolder", "is_folder", "folder_exists", "directory_exists" },
    List = { "listfiles", "list_files", "list" },
}

local FILE_NAMESPACE_NAMES = { "filesystem", "fs", "FileSystem" }

local function resolveRuntimeFunction(aliases)
    for _, name in ipairs(aliases or {}) do
        local fn = getRuntimeFunction(name)
        if fn then return fn, name end
    end
    return nil, nil
end

local function bindNamespaceFunction(namespace, fn)
    return function(...)
        local direct = table.pack(pcall(fn, ...))
        if direct[1] then
            return table.unpack(direct, 2, direct.n)
        end

        local method = table.pack(pcall(fn, namespace, ...))
        if method[1] then
            return table.unpack(method, 2, method.n)
        end

        error(tostring(direct[2] or method[2] or "filesystem call failed"), 2)
    end
end

local function resolveFilesystemFunction(kind)
    local direct, directName = resolveRuntimeFunction(FILE_API_ALIASES[kind])
    if direct then return direct, directName end

    for _, namespaceName in ipairs(FILE_NAMESPACE_NAMES) do
        local namespace = getRuntimeGlobal(namespaceName)
        if type(namespace) == "table" then
            for _, methodName in ipairs(FILE_NAMESPACE_ALIASES[kind] or {}) do
                local fn = rawget(namespace, methodName)
                if type(fn) == "function" then
                    return bindNamespaceFunction(namespace, fn), namespaceName .. "." .. methodName
                end
            end
        end
    end

    return nil, nil
end

Library.RuntimeAdapterClass = Library.RuntimeAdapterClass or {}
Library.RuntimeAdapterClass.__index = Library.RuntimeAdapterClass

function Library.RuntimeAdapterClass.new()
    return setmetatable({}, Library.RuntimeAdapterClass)
end

function Library.RuntimeAdapterClass:Get(name)
    return getRuntimeGlobal(name)
end

function Library.RuntimeAdapterClass:GetFunction(name)
    return getRuntimeFunction(name)
end

function Library.RuntimeAdapterClass:Has(name)
    return getRuntimeGlobal(name) ~= nil
end

function Library.RuntimeAdapterClass:SetClipboard(value)
    local fn = getRuntimeFunction("setclipboard")
    if not fn then return false, "setclipboard is unavailable" end
    local ok, err = pcall(fn, tostring(value or ""))
    return ok, err
end

function Library.RuntimeAdapterClass:GetClipboard()
    local fn = getRuntimeFunction("getclipboard")
    if not fn then return false, "getclipboard is unavailable" end
    local ok, value = pcall(fn)
    return ok, value
end

Library.RuntimeAdapter = Library.RuntimeAdapter or Library.RuntimeAdapterClass.new()

function Library:GetRuntimeAdapter()
    return self.RuntimeAdapter
end

local RuntimeStorageAdapter = {}
RuntimeStorageAdapter.__index = RuntimeStorageAdapter

function RuntimeStorageAdapter.new()
    local writeFile, writeSource = resolveFilesystemFunction("Write")
    local readFile, readSource = resolveFilesystemFunction("Read")
    local isFile = resolveFilesystemFunction("Exists")
    local deleteFile = resolveFilesystemFunction("Delete")
    local makeFolder = resolveFilesystemFunction("MakeDirectory")
    local isFolder = resolveFilesystemFunction("IsDirectory")
    local listFiles = resolveFilesystemFunction("List")

    return setmetatable({
        WriteFile = writeFile,
        ReadFile = readFile,
        IsFile = isFile,
        DeleteFile = deleteFile,
        MakeFolder = makeFolder,
        IsFolder = isFolder,
        ListFiles = listFiles,
        APIName = writeSource or readSource or "Unavailable",
    }, RuntimeStorageAdapter)
end

function RuntimeStorageAdapter:IsPersistent()
    return self:IsAvailable()
end

function RuntimeStorageAdapter:SupportsDirectories()
    return type(self.MakeFolder) == "function"
end

function RuntimeStorageAdapter:IsAvailable()
    return type(self.WriteFile) == "function"
        and type(self.ReadFile) == "function"
end

function RuntimeStorageAdapter:Write(path, data)
    if type(self.WriteFile) ~= "function" then
        error("writefile is unavailable")
    end
    return self.WriteFile(path, data)
end

function RuntimeStorageAdapter:Read(path)
    if type(self.ReadFile) ~= "function" then
        error("readfile is unavailable")
    end
    return self.ReadFile(path)
end

function RuntimeStorageAdapter:Exists(path)
    if type(self.IsFile) == "function" then
        return self.IsFile(path)
    end
    if type(self.ReadFile) == "function" then
        local ok = pcall(self.ReadFile, path)
        return ok
    end
    return false
end

function RuntimeStorageAdapter:Delete(path)
    if type(self.DeleteFile) == "function" then
        return self.DeleteFile(path)
    end
    return false
end

function RuntimeStorageAdapter:MakeDirectory(path)
    if type(self.MakeFolder) == "function" then
        return self.MakeFolder(path)
    end
    return false
end

function RuntimeStorageAdapter:IsDirectory(path)
    if type(self.IsFolder) ~= "function" then
        return false
    end
    return self.IsFolder(path)
end

function RuntimeStorageAdapter:List(path)
    if type(self.ListFiles) ~= "function" then
        return {}
    end
    return self.ListFiles(path)
end

local MemoryStorageAdapter = {}
MemoryStorageAdapter.__index = MemoryStorageAdapter

function MemoryStorageAdapter.new()
    return setmetatable({
        Files = {},
        Directories = {
            ["MistHub"] = true,
            ["MistHub/Configs"] = true,
        },
    }, MemoryStorageAdapter)
end

function MemoryStorageAdapter:IsAvailable()
    return true
end

function MemoryStorageAdapter:Write(path, data)
    self.Files[path] = tostring(data or "")
    return true
end

function MemoryStorageAdapter:Read(path)
    if self.Files[path] == nil then
        error("file does not exist: " .. tostring(path))
    end
    return self.Files[path]
end

function MemoryStorageAdapter:Exists(path)
    return self.Files[path] ~= nil
end

function MemoryStorageAdapter:Delete(path)
    self.Files[path] = nil
    return true
end

function MemoryStorageAdapter:MakeDirectory(path)
    self.Directories[path] = true
    return true
end

function MemoryStorageAdapter:IsDirectory(path)
    return self.Directories[path] == true
end

function MemoryStorageAdapter:List(path)
    local out = {}
    local prefix = tostring(path or "")
    if prefix ~= "" and prefix:sub(-1) ~= "/" then
        prefix = prefix .. "/"
    end

    for filePath in pairs(self.Files) do
        if filePath:sub(1, #prefix) == prefix then
            table.insert(out, filePath)
        end
    end

    table.sort(out)
    return out
end

Library.StorageAdapters = {
    Runtime = RuntimeStorageAdapter,
    Memory = MemoryStorageAdapter,
}

do
    if Library.StorageAdapter == nil then
        Library.StorageAdapter = RuntimeStorageAdapter.new()
        if not Library.StorageAdapter:IsAvailable() then
            Library.StorageFallbackReason = "No persistent runtime filesystem API was detected"
        end
    end
end

function Library:SetStorageAdapter(adapter)
    if type(adapter) ~= "table" then
        return false
    end

    self.StorageAdapter = adapter
    return true
end

function Library:GetStorageAdapter()
    if not self.StorageAdapter then
        self.StorageAdapter = RuntimeStorageAdapter.new()
        if not self.StorageAdapter:IsAvailable() then
            self.StorageFallbackReason = "No persistent runtime filesystem API was detected"
        end
    end
    return self.StorageAdapter
end

function Library:UseMemoryStorage()
    self.StorageAdapter = MemoryStorageAdapter.new()
    self.StorageFallbackReason = self.StorageFallbackReason or "Memory storage selected"
    return self.StorageAdapter
end

function Library:IsPersistentStorage()
    local adapter = self:GetStorageAdapter()
    if getmetatable(adapter) == RuntimeStorageAdapter then
        return adapter:IsAvailable()
    end
    if type(adapter.IsPersistent) == "function" then
        local ok, result = pcall(adapter.IsPersistent, adapter)
        return ok and result == true
    end
    return false
end

function Library:GetStorageStatus()
    return {
        Name = self:GetStorageAdapterName(),
        Persistent = self:IsPersistentStorage(),
        FallbackReason = self.StorageFallbackReason,
    }
end

function Library:GetStorageAdapterName()
    local adapter = self:GetStorageAdapter()
    if getmetatable(adapter) == MemoryStorageAdapter then
        return "Memory"
    end
    if getmetatable(adapter) == RuntimeStorageAdapter then
        if adapter:IsAvailable() and adapter.APIName and adapter.APIName ~= "Unavailable" then
            return "Runtime · " .. tostring(adapter.APIName)
        end
        return "Runtime"
    end
    return "Custom"
end

------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------
function Library:CreateWindow(config)
    config = config or {}

    if Library._activeWindow
        and Library._activeWindow._screenGui
        and Library._activeWindow._screenGui.Parent then
        if config.ReplaceExisting == true
            and type(Library._activeWindow.Unload) == "function" then
            Library._activeWindow:Unload()
        else
            return Library._activeWindow, "MistUI supports one active Window per Library instance. Pass ReplaceExisting=true or load a second Library instance."
        end
    end

    if type(config.StorageAdapter) == "table" then
        Library:SetStorageAdapter(config.StorageAdapter)
    end

    if config.UseMemoryStorage == true then
        Library:UseMemoryStorage()
    end

    local title = config.Title or "MIST UI"
    local size = config.Size or UDim2.new(0, 980, 0, 660)
    local SIDEBAR_W, TITLEBAR_H, TABBAR_H = 340, 46, 50
    local CORNER_RADIUS = Theme.Metrics.WindowRadius

    local self_ = setmetatable({}, Library)
    local mainScale = nil
    self_.Tabs = {}          -- tabs abertas (ordem)
    self_.Categories = {}
    self_._activeTab = nil
    self_._activeCategory = nil
    self_._maid = Maid.new()
    self_._store = Store.new()
    self_.Store = self_._store

    -- Core lifecycle helper must exist before initialization code uses it.
    -- Luau table methods are assigned at runtime and are not hoisted.
    function self_:Track(item)
        return self_._maid:Give(item)
    end
    self_._components = {}
    self_._componentMeta = {}
    self_._cards = {}
    self_._events = {}
    self_._history = {}
    self_._redoHistory = {}
    self_._navigationHistory = {}
    self_._keybinds = {}
    self_._commands = {}
    self_._activities = {}
    self_._title = tostring(title)
    self_._quality = {
        CreatedAt = os.clock(),
        ConfigTransactions = 0,
        ConfigRollbacks = 0,
        DoctorRuns = 0,
        ProfilerRuns = 0,
    }
    self_._profiler = {
        Enabled = false,
        Samples = {},
        Totals = {},
        Counts = {},
        MaxSamples = 240,
    }
    self_._configTransaction = nil
    self_._responsiveEnabled = false
    self_._resizeLocked = true
    self_._snapEnabled = false
    self_._minSize = Vector2.new(640, 420)
    self_._maxSize = Vector2.new(1600, 1000)
    self_._maximized = false
    self_._restoreSize = nil
    self_._restorePosition = nil
    self_._baseSize = Vector2.new(size.X.Offset > 0 and size.X.Offset or 980, size.Y.Offset > 0 and size.Y.Offset or 660)
    Library._activeWindow = self_

    local dragController = DragController.new(self_._maid)
    self_._dragController = dragController

    local screenGui = create("ScreenGui", {
        Name = "MistHubUI_" .. tostring(math.random(1, 999999)),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = getGuiParent(),
    })
    self_._screenGui = screenGui
    Library._screenGui = screenGui

    function self_:_IsActuallyVisible(gui)
        if not gui or not gui.Parent or not gui:IsA("GuiObject") then return false end
        local current = gui
        while current and current ~= screenGui do
            if current:IsA("GuiObject") and current.Visible == false then
                return false
            end
            current = current.Parent
        end
        return true
    end

    function self_:_PrepareFocusable(gui)
        if not gui:IsA("GuiObject") then return end
        if gui:IsA("GuiButton") or gui:IsA("TextBox") then
            local loweredName = string.lower(gui.Name or "")
            local structural = string.find(loweredName, "overlay", 1, true)
                or string.find(loweredName, "backdrop", 1, true)
                or string.find(loweredName, "blocker", 1, true)
                or string.find(loweredName, "disabled", 1, true)

            if structural then
                gui.Selectable = false
                return
            end

            -- Components can explicitly opt out of selection/focus visuals.
            -- This is important for transient overlay rows (context menus,
            -- command results, modal action buttons) where Roblox's default
            -- selection rectangle looks like an unintended white border.
            if gui.Selectable == false or gui:GetAttribute("MistNoFocus") == true then
                gui.Selectable = false
                local existingStroke = gui:FindFirstChild("MistFocusStroke")
                if existingStroke then existingStroke:Destroy() end
                return
            end

            if gui:GetAttribute("MistNoFocus") ~= true then
                gui.Selectable = true

                if not gui:FindFirstChild("MistFocusStroke") then
                    local focusStroke = create("UIStroke", {
                        Name = "MistFocusStroke",
                        Color = Theme.Accent,
                        Thickness = 1,
                        Transparency = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Parent = gui,
                    })

                    gui.SelectionGained:Connect(function()
                        if self_:_IsActuallyVisible(gui) and gui:GetAttribute("Disabled") ~= true then
                            tween(focusStroke, { Transparency = 0.32 }, MOTION.Fast)
                        end
                    end)
                    gui.SelectionLost:Connect(function()
                        tween(focusStroke, { Transparency = 1 }, MOTION.Fast)
                    end)
                end
            end
        end
    end

    for _, descendant in ipairs(screenGui:GetDescendants()) do
        self_:_PrepareFocusable(descendant)
    end
    self_._maid:Give(screenGui.DescendantAdded:Connect(function(descendant)
        self_:_PrepareFocusable(descendant)
    end))


    Library.NotificationSettings = Library.NotificationSettings or {
        Enabled = true,
        ProgressBar = true,
        Position = "TOP RIGHT",
        Duration = 4,
        MaxVisible = 4,
        PauseOnHover = true,
    }

    Library.InterfaceSettings = Library.InterfaceSettings or {
        SilentLaunch = false,
        SilentMode = false,
        FunctionInfo = true,
    }

    if Library.InterfaceSettings.FunctionInfo == nil then
        Library.InterfaceSettings.FunctionInfo = true
    end

    Library.SocialLinks = Library.SocialLinks or {
        DiscordInvite = "https://discord.gg/yourinvite",
        YoutubeChannel = "https://youtube.com/@yourchannel",
    }

    self_._notificationSettings = Library.NotificationSettings
    self_._interfaceSettings = Library.InterfaceSettings

    local iconTooltip = create("CanvasGroup", {
        Name = "IconTooltip",
        BackgroundColor3 = Theme.CardHover,
        BackgroundTransparency = 0,
        GroupTransparency = 1,
        Visible = false,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 270, 0, 0),
        ZIndex = 350,
        Parent = screenGui,
    }, {
        corner(8),
        stroke(Theme.Accent, 1, 0.24),
        padding(0, 12, 9, 12, 9),
    })

    Library:BindTheme(iconTooltip, "BackgroundColor3", "CardHover")
    for _, child in ipairs(iconTooltip:GetChildren()) do
        if child:IsA("UIStroke") then
            Library:BindTheme(child, "Color", "Accent")
        end
    end

    local iconTooltipLabel = create("TextLabel", {
        Text = "",
        FontFace = Theme.FontMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 351,
        Parent = iconTooltip,
    })

    local tooltipNonce = 0
    local tooltipTarget = nil

    local function positionIconTooltip()
        if not iconTooltip.Visible or not tooltipTarget or not tooltipTarget.Parent then
            return
        end

        local viewport = workspace.CurrentCamera
            and workspace.CurrentCamera.ViewportSize
            or Vector2.new(1920, 1080)

        local targetPosition = tooltipTarget.AbsolutePosition
        local targetSize = tooltipTarget.AbsoluteSize
        local width = iconTooltip.AbsoluteSize.X > 0 and iconTooltip.AbsoluteSize.X or 270
        local height = iconTooltip.AbsoluteSize.Y > 0 and iconTooltip.AbsoluteSize.Y or 42

        local targetCenterX = targetPosition.X + targetSize.X * 0.5
        local x = targetCenterX - width * 0.5
        local y = targetPosition.Y - height - 10

        if y < 8 then
            y = targetPosition.Y + targetSize.Y + 10
        end

        x = math.clamp(x, 8, viewport.X - width - 8)
        y = math.clamp(y, 8, viewport.Y - height - 8)

        iconTooltip.Position = UDim2.new(0, x, 0, y)
    end

    local tooltipFollowConnections = {}
    local tooltipPinned = false

    local function disconnectTooltipFollow()
        for _, connection in ipairs(tooltipFollowConnections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(tooltipFollowConnections)
    end

    local function resolveTooltipText(value)
        if type(value) == "function" then
            local ok, result = pcall(value)
            return ok and tostring(result or "") or ""
        end
        return tostring(value or "")
    end

    local function showTooltip(target, value, pinned)
        if not target or not target.Parent then
            return
        end

        tooltipNonce += 1
        tooltipTarget = target
        tooltipPinned = pinned == true
        iconTooltipLabel.Text = resolveTooltipText(value)
        iconTooltip.Visible = true
        iconTooltip.GroupTransparency = 1

        disconnectTooltipFollow()

        table.insert(
            tooltipFollowConnections,
            target:GetPropertyChangedSignal("AbsolutePosition"):Connect(
                positionIconTooltip
            )
        )

        table.insert(
            tooltipFollowConnections,
            target:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                positionIconTooltip
            )
        )

        task.defer(function()
            if iconTooltip.Visible and tooltipTarget == target then
                positionIconTooltip()
                tween(
                    iconTooltip,
                    { GroupTransparency = 0 },
                    MOTION.Fast,
                    Enum.EasingStyle.Quint
                )
            end
        end)
    end

    local function hideTooltip(force)
        if tooltipPinned and force ~= true then
            return
        end

        tooltipNonce += 1
        local currentNonce = tooltipNonce
        tooltipPinned = false

        tween(
            iconTooltip,
            { GroupTransparency = 1 },
            MOTION.Instant,
            Enum.EasingStyle.Quint
        )

        task.delay(MOTION.Fast, function()
            if tooltipNonce == currentNonce and iconTooltip then
                iconTooltip.Visible = false
                tooltipTarget = nil
                disconnectTooltipFollow()
            end
        end)
    end

    local function attachTooltip(target, value)
        if not target then return end

        self_._maid:Give(target.MouseEnter:Connect(function()
            showTooltip(target, value, false)
        end))

        self_._maid:Give(target.MouseLeave:Connect(function()
            hideTooltip(false)
        end))

        if target:IsA("GuiButton") then
            self_._maid:Give(target.Activated:Connect(function()
                if iconTooltip.Visible
                    and tooltipTarget == target
                    and tooltipPinned then
                    hideTooltip(true)
                else
                    showTooltip(target, value, true)
                end
            end))
        end

        pcall(function()
            target.Selectable = true
        end)

        self_._maid:Give(target.SelectionGained:Connect(function()
            showTooltip(target, value, false)
        end))

        self_._maid:Give(target.SelectionLost:Connect(function()
            hideTooltip(true)
        end))
    end

    self_._functionInfoEnabled = Library.InterfaceSettings.FunctionInfo ~= false
    self_._functionInfoIcons = {}
    local function getFunctionInfoText(controlType, label, customText)
        if customText and tostring(customText) ~= "" then
            return tostring(customText)
        end

        local labelText = tostring(label or controlType or "Function")
        return "More information about " .. labelText .. "."
    end


    local function setFunctionInfoEnabled(enabled)
        enabled = enabled == true
        self_._functionInfoEnabled = enabled
        Library.InterfaceSettings.FunctionInfo = enabled

        for _, infoIcon in ipairs(self_._functionInfoIcons or {}) do
            if infoIcon and infoIcon.Parent then
                infoIcon.Visible = enabled
            end
        end

        if not enabled then
            tooltipNonce += 1
            iconTooltip.Visible = false
            iconTooltip.GroupTransparency = 1
        end
    end

    local function addFunctionInfoIcon(container, controlType, label, customText, mode)
        if not container
            or typeof(container) ~= "Instance"
            or not container:IsA("GuiObject") then
            return nil
        end

        local labelText = tostring(label or "Function")

        local infoButton = create("TextButton", {
            Name = "FunctionInfo",
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 18, 0, 18),
            Visible = self_._functionInfoEnabled,
            ZIndex = math.max(container.ZIndex + 5, 12),
            Parent = container,
        })

        local infoGraphic = buildIcon(
            infoButton,
            "info",
            15,
            Theme.TextDimmer
        )

        local function updateTitlePosition()
            if mode ~= "title" then
                return
            end

            local textWidth = 0
            if container:IsA("TextLabel")
                or container:IsA("TextButton")
                or container:IsA("TextBox") then
                textWidth = container.TextBounds.X
            end

            local maxX = math.max(22, container.AbsoluteSize.X - 20)
            local x = math.clamp(textWidth + 7, 22, maxX)
            infoButton.Position = UDim2.new(0, x, 0.5, 0)
        end

        if mode == "title" then
            container:GetPropertyChangedSignal("TextBounds"):Connect(updateTitlePosition)
            container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTitlePosition)
            task.defer(updateTitlePosition)
        else
            infoButton.Position = UDim2.new(1, -20, 0.5, 0)
            infoButton.AnchorPoint = Vector2.new(1, 0.5)
        end

        infoButton.MouseEnter:Connect(function()
            setIconColor(infoGraphic, Theme.Accent, 0.10)
        end)

        infoButton.MouseLeave:Connect(function()
            setIconColor(infoGraphic, Theme.TextDimmer, 0.10)
        end)

        attachTooltip(
            infoButton,
            function()
                return getFunctionInfoText(
                    controlType,
                    labelText,
                    customText
                )
            end
        )

        table.insert(self_._functionInfoIcons, infoButton)
        return infoButton
    end

    local main = create("Frame", {
        Name = "Main", BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2), Size = size,
        ClipsDescendants = true, ZIndex = 2, Parent = screenGui,
    }, { corner(CORNER_RADIUS), stroke(Theme.StrokeSoft, 1, 0.48) })

    -- "Body" interno: usa CanvasGroup em vez de Frame.
    -- O motivo do vazamento de pixel nos cantos era que ClipsDescendants,
    -- em um Frame comum, NÃO respeita o formato do UICorner — ele só
    -- recorta pelo retângulo (AABB) do objeto. É um comportamento oficial
    -- do engine (Roblox: "we don't clip descendants to the round corner
    -- area"), por isso TitleBar/Sidebar/ContentWrap/BottomStatusBar,
    -- por serem retângulos retos colados na borda, sempre "espetavam"
    -- quadradinhos passando da curva do canto, não importa quantas
    -- camadas de Frame+UICorner+ClipsDescendants você empilhe.
    -- CanvasGroup resolve isso de verdade: ele renderiza todos os
    -- descendentes numa textura única e SÓ ENTÃO aplica o recorte do
    -- UICorner sobre essa textura (igual "overflow: hidden" com
    -- border-radius no CSS). Resultado: os 4 cantos ficam perfeitamente
    -- arredondados e limpos, sem nenhum pixel quadrado vazando.
    local body = create("CanvasGroup", {
        Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true, ZIndex = 2, Parent = main,
    }, { corner(CORNER_RADIUS) })
    local surfaceTint = create("Frame", {
        Name = "SurfaceTint", BackgroundColor3 = Theme.SurfaceTint,
        BackgroundTransparency = 0.992, Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1, Parent = body,
    })

    ------------------------------------------------------------
    -- TITLE BAR
    ------------------------------------------------------------
    local titleBar = create("CanvasGroup", {
        Name = "TitleBar", BackgroundColor3 = Theme.TitleBar, Size = UDim2.new(1, 0, 0, TITLEBAR_H), ZIndex = 4, Parent = body,
    })
    create("Frame", { BackgroundColor3 = Theme.StrokeSoft, BackgroundTransparency = 0.30, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 4, Parent = titleBar })
    dragController:Attach(titleBar, main)

    local titleLabel = create("TextLabel", {
        Text = title, FontFace = Theme.FontBold, TextSize = 18, TextColor3 = Theme.TextDark,
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 300, 1, 0), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5, Parent = titleBar,
    })

    local closeBtn = create("TextButton", {
        Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 32, 0, 32),
        ZIndex = 5, Parent = titleBar,
    }, { corner(10) })
    local closeIcon = buildIcon(closeBtn, "x", 18, Theme.TextDark)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, { BackgroundTransparency = 0.90, BackgroundColor3 = Theme.SurfaceTint }, 0.10)
        setIconColor(closeIcon, Theme.Error, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, { BackgroundTransparency = 1, BackgroundColor3 = Theme.SurfaceTint }, 0.10)
        setIconColor(closeIcon, Theme.TextDark, 0.12)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)

    ------------------------------------------------------------
    -- SIDEBAR (Explorer)
    ------------------------------------------------------------
    local sidebar = create("CanvasGroup", {
        Name = "Sidebar", BackgroundColor3 = Theme.Sidebar, GroupTransparency = 0,
        Position = UDim2.new(0, 0, 0, TITLEBAR_H),
        Size = UDim2.new(0, SIDEBAR_W, 1, -TITLEBAR_H - 28), ZIndex = 3, Parent = body, ClipsDescendants = true,
    })
    create("Frame", { BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 3, Parent = sidebar })

    -- Sidebar tree starts directly at the top.
    -- Category tree: ocupa o resto da sidebar até quase a borda de baixo
    -- (só uma folga pequena de 14px), sem bater na status bar — a sidebar
    -- já reserva espaço pra ela via "1, -TITLEBAR_H - 28" lá em cima.
    local treeList = create("Frame", {
        Name = "Tree", BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16), ZIndex = 4, Parent = sidebar,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    ------------------------------------------------------------
    -- CONTENT (TabBar + Page)
    ------------------------------------------------------------
    local contentWrap = create("CanvasGroup", {
        Name = "ContentWrap",
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Content,
        GroupTransparency = 0,
        Position = UDim2.new(0, SIDEBAR_W, 0, TITLEBAR_H),
        Size = UDim2.new(1, -SIDEBAR_W, 1, -TITLEBAR_H - 28),
        ZIndex = 2,
        Parent = body,
    })

    local tabBar = create("CanvasGroup", {
        Name = "TabBar", BackgroundColor3 = Theme.TabBar, GroupTransparency = 0,
        Size = UDim2.new(1, 0, 0, TABBAR_H), ZIndex = 3, Parent = contentWrap,
    })
    create("Frame", { BackgroundColor3 = Theme.StrokeTabBar, BackgroundTransparency = 0.52, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 3, Parent = tabBar })

    -- SETTINGS BUTTON: icon only, placed at the left end of the title bar.
    local settingsOpen = false
    local settingsBtn = create("TextButton", {
        Name = "SettingsButton",
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.SurfaceTint,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 36),
        ZIndex = 6,
        Parent = titleBar,
    }, { corner(11) })

    local settingsIcon = buildIcon(settingsBtn, "settings", 21, Theme.TextDark)

    ------------------------------------------------------------
    -- KEYBINDS FLOATING MENU
    ------------------------------------------------------------
    local keybindMenuOpen = true

    local keybindsBtn = create("TextButton", {
        Name = "KeybindsButton",
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.SurfaceTint,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 46, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Active = false,
        Selectable = false,
        ZIndex = 6,
        Parent = titleBar,
    }, { corner(11) })

    local keybindsTopIcon = buildIcon(
        keybindsBtn,
        "keyboard",
        20,
        Theme.TextDark
    )

    local keybindMenu = create("CanvasGroup", {
        Name = "KeybindMenu",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.new(
            0.5,
            -size.X.Offset / 2 + 12,
            0.5,
            -size.Y.Offset / 2 + TITLEBAR_H + 10
        ),
        Size = UDim2.new(0, 245, 0, 46),
        Visible = true,
        GroupTransparency = 0,
        ZIndex = 220,
        Parent = screenGui,
    }, {
        corner(10),
        stroke(Theme.StrokeSoft, 1, 0.34),
    })

    local keybindMenuScale = create("UIScale", {
        Scale = 1,
        Parent = keybindMenu,
    })

    local keybindMenuTransitionId = 0
    local keybindMenuRestPosition = keybindMenu.Position

    local keybindHeader = create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.CardHover,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 221,
        Parent = keybindMenu,
    }, {
        corner(10),
    })

    create("Frame", {
        BackgroundColor3 = Theme.StrokeSoft,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 222,
        Parent = keybindHeader,
    })

    local keybindHeaderIconHolder = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        ZIndex = 223,
        Parent = keybindHeader,
    })

    buildIcon(
        keybindHeaderIconHolder,
        "keyboard",
        17,
        Theme.Text
    )

    create("TextLabel", {
        Text = "Keybinds",
        FontFace = Theme.FontSemibold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 37, 0, 0),
        Size = UDim2.new(1, -78, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 223,
        Parent = keybindHeader,
    })

    local keybindCountLabel = create("TextLabel", {
        Text = "0",
        FontFace = Theme.FontSemibold,
        TextSize = 12,
        TextColor3 = Theme.TextDark,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 223,
        Parent = keybindHeader,
    })

    local keybindRows = create("ScrollingFrame", {
        Name = "Rows",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 45),
        Size = UDim2.new(1, -16, 1, -51),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.TextDimmer,
        ZIndex = 221,
        Parent = keybindMenu,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    dragController:Attach(keybindHeader, keybindMenu)

    function self_:_FormatKeybindKey(key, modifiers)
        if typeof(key) ~= "EnumItem" then
            return "NONE"
        end

        local name = key.Name
        local aliases = {
            LeftControl = "LCTRL",
            RightControl = "RCTRL",
            LeftShift = "LSHIFT",
            RightShift = "RSHIFT",
            LeftAlt = "LALT",
            RightAlt = "RALT",
            Space = "SPACE",
            Backspace = "BACK",
            Return = "ENTER",
            Escape = "ESC",
        }

        local main = aliases[name] or string.upper(name)
        if type(modifiers) ~= "table" or #modifiers == 0 then return main end
        local parts = {}
        for _, modifier in ipairs(modifiers) do
            if typeof(modifier) == "EnumItem" then
                table.insert(parts, aliases[modifier.Name] or string.upper(modifier.Name))
            elseif modifier ~= nil then
                table.insert(parts, string.upper(tostring(modifier)))
            end
        end
        table.insert(parts, main)
        return table.concat(parts, "+")
    end

    function self_:_ClearKeybindMenuRows()
        for _, child in ipairs(keybindRows:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
    end

    function self_:RefreshKeybindMenu()
        if not keybindRows or not keybindRows.Parent then
            return self_
        end

        self_:_ClearKeybindMenuRows()

        local entries = {}
        for _, entry in ipairs(self_._keybinds or {}) do
            if entry.Enabled ~= false
                and entry.Key
                and entry.Key ~= Enum.KeyCode.Unknown then
                table.insert(entries, entry)
            end
        end

        keybindCountLabel.Text = tostring(#entries)

        local rowHeight = 30
        local visibleRows = math.min(#entries, 7)
        local totalHeight = 46

        if #entries > 0 then
            totalHeight += visibleRows * rowHeight
            totalHeight += math.max(0, visibleRows - 1) * 4
            totalHeight += 10
        end

        local targetMenuSize = UDim2.new(
            0,
            245,
            0,
            math.clamp(totalHeight, 46, 270)
        )
        if keybindMenu.Visible and keybindMenuOpen then
            tween(keybindMenu, { Size = targetMenuSize }, 0.14, Enum.EasingStyle.Quint)
        else
            keybindMenu.Size = targetMenuSize
        end

        if #entries == 0 then
            create("TextLabel", {
                Text = "No keybinds",
                FontFace = Theme.Font,
                TextSize = 12,
                TextColor3 = Theme.TextDimmer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                LayoutOrder = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 222,
                Parent = keybindRows,
            })
            return self_
        end

        for index, entry in ipairs(entries) do
            local active = entry.Active == true
            local row = create("Frame", {
                BackgroundColor3 = active and Theme.Accent or Theme.Field,
                BackgroundTransparency = active and 0.04 or 0.20,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, rowHeight),
                LayoutOrder = index,
                ZIndex = 222,
                Parent = keybindRows,
            }, {
                corner(6),
            })

            local keyText = self_:_FormatKeybindKey(entry.Key, entry.Modifiers)
            local badgeWidth = math.clamp(#keyText * 6 + 14, 34, 70)

            create("TextLabel", {
                Text = keyText,
                FontFace = Theme.FontSemibold,
                TextSize = 10,
                TextColor3 = active and Theme.Text or Theme.TextDark,
                BackgroundColor3 = active and Theme.PrimaryText or Theme.TitleBar,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 6, 0.5, -10),
                Size = UDim2.new(0, badgeWidth, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 223,
                Parent = row,
            }, {
                corner(5),
                stroke(Theme.StrokeSoft, 1, 0.54),
            })

            create("TextLabel", {
                Text = tostring(entry.Name or "Keybind"),
                FontFace = Theme.FontMedium,
                TextSize = 12,
                TextColor3 = active and Theme.PrimaryText or Theme.TextDark,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, badgeWidth + 14, 0, 0),
                Size = UDim2.new(1, -badgeWidth - 20, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 223,
                Parent = row,
            })
        end

        return self_
    end

    function self_:SetKeybindMenuOpen(open)
        local shouldOpen = open == true
        keybindMenuTransitionId += 1
        local transitionId = keybindMenuTransitionId

        if shouldOpen == keybindMenuOpen and keybindMenu.Visible == shouldOpen then
            return self_
        end

        keybindMenuOpen = shouldOpen

        if keybindMenuOpen then
            self_:RefreshKeybindMenu()

            -- A slightly longer fade/slide makes the floating list feel attached
            -- to the interface instead of popping in/out abruptly.
            keybindMenu.Position = keybindMenuRestPosition + UDim2.new(0, -8, 0, 6)
            keybindMenu.GroupTransparency = 1
            keybindMenuScale.Scale = 0.94
            keybindMenu.Visible = true

            tween(
                keybindMenu,
                {
                    GroupTransparency = 0,
                    Position = keybindMenuRestPosition,
                },
                0.20,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
            tween(
                keybindMenuScale,
                { Scale = 1 },
                0.20,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
        else
            -- Remember the dragged/resting position before animating away.
            if keybindMenu.Visible then
                keybindMenuRestPosition = keybindMenu.Position
            end

            tween(
                keybindMenu,
                {
                    GroupTransparency = 1,
                    Position = keybindMenuRestPosition + UDim2.new(0, -10, 0, 6),
                },
                0.18,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.In
            )
            tween(
                keybindMenuScale,
                { Scale = 0.94 },
                0.18,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.In
            )

            task.delay(0.19, function()
                if transitionId ~= keybindMenuTransitionId then return end
                if not keybindMenuOpen and keybindMenu and keybindMenu.Parent then
                    keybindMenu.Visible = false
                    keybindMenu.Position = keybindMenuRestPosition
                    keybindMenu.GroupTransparency = 0
                    keybindMenuScale.Scale = 1
                end
            end)
        end

        setIconColor(
            keybindsTopIcon,
            keybindMenuOpen and Theme.Text or Theme.TextDark,
            0.10
        )

        return self_
    end

    function self_:GetKeybindMenuOpen()
        return keybindMenuOpen
    end

    keybindsBtn.MouseEnter:Connect(function()
        tween(
            keybindsBtn,
            {
                BackgroundColor3 = Theme.Text,
                BackgroundTransparency = 0.90,
            },
            0.10
        )
        setIconColor(keybindsTopIcon, Theme.Text, 0.10)
    end)

    keybindsBtn.MouseLeave:Connect(function()
        tween(
            keybindsBtn,
            {
                BackgroundColor3 = Theme.Text,
                BackgroundTransparency = 1,
            },
            0.10
        )
        setIconColor(
            keybindsTopIcon,
            keybindMenuOpen and Theme.Text or Theme.TextDark,
            0.10
        )
    end)

    keybindsBtn.MouseButton1Click:Connect(function()
        self_:SetKeybindMenuOpen(not keybindMenuOpen)
    end)

    task.defer(function()
        self_:RefreshKeybindMenu()
    end)

    settingsBtn.MouseEnter:Connect(function()
        tween(settingsBtn, {
            BackgroundColor3 = Theme.Text,
            BackgroundTransparency = 0.90,
        }, 0.10)
        setIconColor(settingsIcon, Theme.Text, 0.10)
    end)

    settingsBtn.MouseLeave:Connect(function()
        tween(settingsBtn, {
            BackgroundColor3 = Theme.Text,
            BackgroundTransparency = 1,
        }, 0.10)
        setIconColor(settingsIcon, settingsOpen and Theme.Text or Theme.TextDark, 0.10)
    end)

    local tabList = create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 0,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ZIndex = 4,
        Parent = tabBar,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local pageHolder = create("CanvasGroup", {
        Name = "PageHolder", BackgroundTransparency = 1, GroupTransparency = 0,
        Position = UDim2.new(0, 0, 0, TABBAR_H),
        Size = UDim2.new(1, 0, 1, -TABBAR_H), ZIndex = 2, Parent = contentWrap,
    })

    self_._main = main
    self_._body = body
    self_._sidebar = sidebar
    self_._sidebarExpanded = true
    self_._tabBar = tabBar
    self_._tabList = tabList
    self_._pageHolder = pageHolder
    self_._treeList = treeList
    self_._titleLabel = titleLabel
    self_._screenGui = screenGui
    self_._keybindMenu = keybindMenu
    self_._keybindsButton = keybindsBtn
    self_._main = main

    ------------------------------------------------------------
    -- SETTINGS
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- BOTTOM STATUS BAR
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- BOTTOM BAR TEXT - EDIT HERE
    ------------------------------------------------------------
    local STATUS_GAME_NAME = "Game Name:"    -- Edit here; keep ":" here
    local STATUS_VERSION   = "v1.0.0"         -- Edit here

    function self_:_BuildStatusText()
        if type(config.StatusText) == "string" and config.StatusText ~= "" then
            return config.StatusText
        end

        return string.format(
            "%s %s",
            tostring(STATUS_GAME_NAME),
            tostring(STATUS_VERSION)
        )
    end

    local bottomStatusBar = create("CanvasGroup", {
        Name = "BottomStatusBar",
        BackgroundColor3 = Color3.fromHex("#121214"),
        BackgroundTransparency = 0.12,
        GroupTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 28),
        ZIndex = 7,
        Parent = body,
    })
    -- Keep the bottom bar on the original neutral gray instead of recoloring it
    -- when an appearance/theme preset changes Sidebar.
    Library:UnbindTheme(bottomStatusBar, "BackgroundColor3")
    bottomStatusBar.BackgroundColor3 = Color3.fromHex("#121214")

    create("Frame", {
        BackgroundColor3 = Theme.StrokeSoft,
        BackgroundTransparency = 0.36,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 8,
        Parent = bottomStatusBar,
    })

    -- Right side: customizable script/game/version status
    local rightInfoHolder = create("Frame", {
        Name = "RightInfoHolder",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 8,
        Parent = bottomStatusBar,
    })

    local statusLabel = create("TextLabel", {
        Name = "ScriptStatus",
        Text = self_:_BuildStatusText(),
        FontFace = Theme.FontSemibold,
        TextSize = 14,
        TextColor3 = Theme.TextDark,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 8,
        Parent = rightInfoHolder,
    })

    function self_:SetStatusText(value)
        config.StatusText = tostring(value or "")
        statusLabel.Text = self_:_BuildStatusText()
        return self_
    end

    function self_:SetScriptInfo(gameName, version)
        if gameName ~= nil then
            local value = tostring(gameName)
            if not value:match(":%s*$") then
                value = value .. ":"
            end
            STATUS_GAME_NAME = value
        end

        if version ~= nil then
            STATUS_VERSION = tostring(version)
        end

        config.StatusText = nil
        statusLabel.Text = self_:_BuildStatusText()
        return self_
    end

    function self_:GetStatusText()
        return statusLabel.Text
    end

    self_._interfaceBlurDepth = 0

    function self_:SetInterfaceBlurred(enabled)
        if enabled == true then
            self_._interfaceBlurDepth += 1
        else
            self_._interfaceBlurDepth = math.max(
                0,
                self_._interfaceBlurDepth - 1
            )
        end

        local blurred = self_._interfaceBlurDepth > 0
        local transparency = blurred and 0.50 or 0

        tween(
            titleBar,
            { GroupTransparency = transparency },
            0.14,
            Enum.EasingStyle.Quint
        )

        tween(
            sidebar,
            { GroupTransparency = transparency },
            0.14,
            Enum.EasingStyle.Quint
        )

        tween(
            contentWrap,
            { GroupTransparency = transparency },
            0.14,
            Enum.EasingStyle.Quint
        )

        tween(
            bottomStatusBar,
            { GroupTransparency = transparency },
            0.14,
            Enum.EasingStyle.Quint
        )

        return self_
    end

    function self_:GetInterfaceBlurred()
        return self_._interfaceBlurDepth > 0
    end

    -- Edit STATUS_GAME_NAME and STATUS_VERSION above.

    -- SETTINGS MODAL
    -- Opens above the current page and softens only the currently open UI tab.
    -- No Lighting BlurEffect is used, so the 3D game itself is never blurred.
    -- SETTINGS MODAL
    -- Centered Settings layout. The interface behind it is softened.
    local SettingsPanel = create("CanvasGroup", {
        Name = "SettingsPanel",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(0, 780, 0, 510),
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 40,
        Parent = main,
    }, {
        corner(11),
        stroke(Theme.StrokeSoft, 1, 0.62),
    })

    -- Strong UI-only softening over the entire interface.
    -- The 3D game is untouched; only the UI behind Settings is softened.
    local fullUIBlurOverlay = create("TextButton", {
        Name = "FullUIBlurOverlay",
        Text = "",
        AutoButtonColor = false,
        Active = true,
        Selectable = false,
        BackgroundColor3 = Theme.TitleBar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, TITLEBAR_H),
        Size = UDim2.new(1, 0, 1, -TITLEBAR_H),
        Visible = false,
        ZIndex = 30,
        Parent = main,
    }, {
        corner(CORNER_RADIUS),
    })

    fullUIBlurOverlay.MouseButton1Click:Connect(function()
        -- Intentionally empty: this layer exists to block interaction
        -- with the UI behind the Settings modal.
    end)

    local SETTINGS_NAV_W = 168

    local settingsNav = create("Frame", {
        Name = "SettingsNav",
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, SETTINGS_NAV_W, 1, 0),
        ZIndex = 21,
        Parent = SettingsPanel,
    })
    create("Frame", {
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.15,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = 22,
        Parent = settingsNav,
    })

    create("TextLabel", {
        Text = "SETTINGS",
        FontFace = Theme.FontSemibold,
        TextSize = 16,
        TextColor3 = Theme.TextDimmer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 14),
        Size = UDim2.new(1, -32, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22,
        Parent = settingsNav,
    })

    local settingsNavList = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 48),
        Size = UDim2.new(1, -20, 0, 132),
        ZIndex = 22,
        Parent = settingsNav,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local settingsContent = create("Frame", {
        Name = "SettingsContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, SETTINGS_NAV_W, 0, 0),
        Size = UDim2.new(1, -SETTINGS_NAV_W, 1, 0),
        ZIndex = 21,
        Parent = SettingsPanel,
    })

    local settingsPageTitle = create("TextLabel", {
        Text = "INTERFACE",
        FontFace = Theme.FontSemibold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 22),
        Size = UDim2.new(1, -48, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22,
        Parent = settingsContent,
    })

    local settingsPagesHolder = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 60),
        Size = UDim2.new(1, -52, 1, -82),
        ZIndex = 21,
        Parent = settingsContent,
    })

    local settingsDropdownLayer = create("Frame", {
        Name = "SettingsDropdownLayer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = false,
        Active = false,
        ZIndex = 95,
        Parent = SettingsPanel,
    })

    local settingsPages = {}
    local settingsNavButtons = {}
    local currentSettingsPage = nil

    local function createSettingsPage(name)
        local page = create("ScrollingFrame", {
            Name = name .. "Page",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 1,
            Visible = false,
            ZIndex = 22,
            Parent = settingsPagesHolder,
        }, {
            create("UIListLayout", {
                Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            create("UIPadding", {
                PaddingRight = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 8),
            }),
        })
        page.MouseEnter:Connect(function()
            tween(page, { ScrollBarImageTransparency = 1 }, 0.12)
        end)
        page.MouseLeave:Connect(function()
            tween(page, { ScrollBarImageTransparency = 0.72 }, 0.12)
        end)
        settingsPages[name] = page
        return page
    end

    local function settingsSection(parent, title, subtitle)
        local holder = create("Frame", {
            BackgroundColor3 = Theme.Card,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 22,
            Parent = parent,
        }, {
            corner(9),
            stroke(Theme.StrokeSoft, 1, 0.68),
            padding(14),
        })

        create("TextLabel", {
            Text = title,
            FontFace = Theme.FontSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 23,
            Parent = holder,
        })

        if subtitle and subtitle ~= "" then
            create("TextLabel", {
                Text = subtitle,
                FontFace = Theme.Font,
                TextSize = 12,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex = 23,
                Parent = holder,
            })
        end

        create("Frame", {
            Name = "SectionDivider",
            BackgroundColor3 = Theme.Stroke,
            BackgroundTransparency = 0.72,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 23,
            Parent = holder,
        })

        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }).Parent = holder

        return holder
    end

    local function settingsLabel(parent, label)
        return create("TextLabel", {
            Text = label,
            FontFace = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.TextDark,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 23,
            Parent = parent,
        })
    end

    local function settingsButton(parent, label, callback, variant)
        local holder = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            ZIndex = 23,
            Parent = parent,
        })
        return makeButton(holder, label, variant or "secondary", nil, 32, callback)
    end

    local function settingsValueRow(parent, label, description, valueText)
        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            ZIndex = 23,
            Parent = parent,
        })
        create("TextLabel", {
            Text = label,
            FontFace = Theme.FontSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 3),
            Size = UDim2.new(0.55, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 24,
            Parent = row,
        })
        create("TextLabel", {
            Text = description or "",
            FontFace = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.TextDark,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 23),
            Size = UDim2.new(0.62, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 24,
            Parent = row,
        })
        local value = create("TextLabel", {
            Text = valueText or "",
            FontFace = Theme.FontSemibold,
            TextSize = 11,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Field,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 150, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 24,
            Parent = row,
        }, { corner(7), stroke(Theme.Stroke, 1, 0.35) })
        return value
    end

    local function settingsToggleRow(parent, label, description, default, onChanged)
        local state = default == true
        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            ZIndex = 23,
            Parent = parent,
        })
        create("TextLabel", {
            Text = label,
            FontFace = Theme.FontSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 3),
            Size = UDim2.new(0.65, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 24,
            Parent = row,
        })
        create("TextLabel", {
            Text = description or "",
            FontFace = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.TextDark,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 23),
            Size = UDim2.new(0.7, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 24,
            Parent = row,
        })

        local toggle = create("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            BackgroundColor3 = state and Theme.Accent or Theme.Field,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 36, 0, 20),
            ZIndex = 24,
            Parent = row,
        }, { corner(9999) })

        local knob = create("Frame", {
            BackgroundColor3 = state and Theme.ToggleKnobActive or Theme.TextDark,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = state and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 25,
            Parent = toggle,
        }, { corner(9999) })

        local knobScale = create("UIScale", {
            Scale = 1,
            Parent = knob,
        })

        local knobMoveTween = nil
        local toggleColorTween = nil
        local knobColorTween = nil

        local function animateState()
            if knobMoveTween then knobMoveTween:Cancel() end
            if toggleColorTween then toggleColorTween:Cancel() end
            if knobColorTween then knobColorTween:Cancel() end

            knobMoveTween = tween(
                knob,
                {
                    Position = state
                        and UDim2.new(1, -10, 0.5, 0)
                        or UDim2.new(0, 10, 0.5, 0),
                },
                0.30,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            )

            toggleColorTween = tween(
                toggle,
                { BackgroundColor3 = state and Theme.Accent or Theme.Field },
                0.24,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            )

            knobColorTween = tween(
                knob,
                { BackgroundColor3 = state and Theme.ToggleKnobActive or Theme.TextDark },
                0.24,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            )

            smoothTween(knobScale, { Scale = 1.10 }, 0.11, Enum.EasingStyle.Sine)
            task.delay(0.10, function()
                if knobScale and knobScale.Parent then
                    smoothTween(knobScale, { Scale = 1 }, 0.20, Enum.EasingStyle.Sine)
                end
            end)
        end

        local function applyState(v, fireCallback)
            state = v == true
            animateState()

            if fireCallback and onChanged then
                pcall(onChanged, state)
            end
        end

        toggle.MouseEnter:Connect(function()
            smoothTween(
                toggle,
                { BackgroundColor3 = state and shadeColor(Theme.Accent, 1.04) or Theme.FieldHover },
                0.22,
                Enum.EasingStyle.Sine
            )
        end)

        toggle.MouseLeave:Connect(function()
            smoothTween(
                toggle,
                { BackgroundColor3 = state and Theme.Accent or Theme.Field },
                0.24,
                Enum.EasingStyle.Sine
            )
        end)

        toggle.MouseButton1Click:Connect(function()
            applyState(not state, true)
        end)

        return {
            Get = function() return state end,
            Set = function(v, fireCallback)
                applyState(v, fireCallback == true)
            end,
        }
    end


    local function settingsDropdownRow(parent, label, description, options, defaultValue, onChanged)
        options = options or {}

        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 52),
            ZIndex = 30,
            Parent = parent,
        })

        create("TextLabel", {
            Text = label,
            FontFace = Theme.FontSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 3),
            Size = UDim2.new(0.58, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 31,
            Parent = row,
        })

        create("TextLabel", {
            Text = description or "",
            FontFace = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.TextDark,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 25),
            Size = UDim2.new(0.58, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 31,
            Parent = row,
        })

        local value = defaultValue ~= nil and defaultValue or options[1]
        local opened = false
        local optionEntries = {}
        local MAX_VISIBLE = 5
        local ROW_HEIGHT = 31

        local button = create("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.TitleBar,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 170, 0, 34),
            ZIndex = 32,
            Parent = row,
        }, {
            corner(12),
            stroke(Theme.StrokeSoft, 1, 0.78),
            create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, shadeColor(Theme.TitleBar, 1.08)),
                    ColorSequenceKeypoint.new(0.52, Theme.TitleBar),
                    ColorSequenceKeypoint.new(1.00, shadeColor(Theme.TitleBar, 0.72)),
                }),
            }),
        })

        local valueLabel = create("TextLabel", {
            Text = tostring(value or "None"),
            FontFace = Theme.FontSemibold,
            TextSize = 12,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -36, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 33,
            Parent = button,
        })

        local arrowHolder = create("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0, 18, 0, 18),
            Rotation = 90,
            ZIndex = 33,
            Parent = button,
        })
        buildIcon(arrowHolder, "chevron-right", 16, Theme.TextDark)

        local menu = create("Frame", {
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 170, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 100,
            Parent = settingsDropdownLayer,
        }, { corner(7), stroke(Theme.StrokeSoft, 1, 0.18) })

        local list = create("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(1, -8, 1, -8),
            CanvasSize = UDim2.new(0, 0, 0, #options * ROW_HEIGHT),
            ScrollBarThickness = #options > MAX_VISIBLE and 3 or 0,
            ScrollBarImageColor3 = Theme.TextDimmer,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 71,
            Parent = menu,
        }, {
            create("UIListLayout", {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        local function updateSelectionVisuals()
            for _, entry in ipairs(optionEntries) do
                local selected = tostring(value) == entry.Name
                entry.Check.Visible = selected
                entry.Button.BackgroundColor3 = selected and Theme.CardHover or Theme.Field
            end
        end

        local function closeMenu()
            if not opened and not menu.Visible then return end
            opened = false
            tween(menu, { Size = UDim2.new(0, math.max(1, button.AbsoluteSize.X), 0, 0) }, 0.10)
            tween(arrowHolder, { Rotation = 90 }, 0.10)
            task.delay(0.11, function()
                if not opened then menu.Visible = false end
            end)
            if self_._openSettingsDropdownCloser == closeMenu then
                self_._openSettingsDropdownCloser = nil
            end
        end

        local function setValue(newValue, fire)
            value = newValue
            valueLabel.Text = tostring(newValue or "None")
            updateSelectionVisuals()
            closeMenu()
            if fire and onChanged then
                pcall(onChanged, newValue)
            end
        end

        for i, option in ipairs(options) do
            local optionName = tostring(option)
            local optionButton = create("TextButton", {
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                BackgroundColor3 = Theme.Field,
                BackgroundTransparency = 0,
                Size = UDim2.new(1, -4, 0, 28),
                LayoutOrder = i,
                ZIndex = 72,
                Parent = list,
            }, { corner(5) })

            create("TextLabel", {
                Text = optionName,
                FontFace = Theme.Font,
                TextSize = 12,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -28, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 73,
                Parent = optionButton,
            })

            local optionCheckHolder = create("Frame", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                ZIndex = 73,
                Parent = optionButton,
            })
            buildIcon(optionCheckHolder, "check", 13, Theme.Text)

            table.insert(optionEntries, {
                Name = optionName,
                Value = option,
                Button = optionButton,
                Check = optionCheckHolder,
            })

            optionButton.MouseEnter:Connect(function()
                tween(optionButton, { BackgroundColor3 = Theme.FieldHover }, 0.08)
            end)
            optionButton.MouseLeave:Connect(function()
                local selected = tostring(value) == optionName
                tween(optionButton, { BackgroundColor3 = selected and Theme.CardHover or Theme.Field }, 0.08)
            end)
            optionButton.MouseButton1Click:Connect(function()
                setValue(option, true)
            end)
        end

        updateSelectionVisuals()

        local function positionMenu(height)
            local layerPos = settingsDropdownLayer.AbsolutePosition
            local layerSize = settingsDropdownLayer.AbsoluteSize
            local buttonPos = button.AbsolutePosition
            local buttonSize = button.AbsoluteSize
            local width = math.max(120, buttonSize.X)
            local x = buttonPos.X - layerPos.X
            local belowY = buttonPos.Y - layerPos.Y + buttonSize.Y + 4
            local aboveY = buttonPos.Y - layerPos.Y - height - 4
            local y = belowY

            if belowY + height > layerSize.Y - 8 and aboveY >= 8 then
                y = aboveY
            else
                y = math.clamp(y, 8, math.max(8, layerSize.Y - height - 8))
            end

            x = math.clamp(x, 8, math.max(8, layerSize.X - width - 8))
            menu.Position = UDim2.fromOffset(x, y)
            return width
        end

        local function openMenu()
            if self_._openSettingsDropdownCloser and self_._openSettingsDropdownCloser ~= closeMenu then
                pcall(self_._openSettingsDropdownCloser)
            end

            opened = true
            menu.Visible = true
            local visibleRows = math.max(1, math.min(#options, MAX_VISIBLE))
            local height = visibleRows * ROW_HEIGHT + 8
            local width = positionMenu(height)
            list.CanvasSize = UDim2.new(0, 0, 0, #options * ROW_HEIGHT)
            tween(menu, { Size = UDim2.new(0, width, 0, height) }, 0.12)
            tween(arrowHolder, { Rotation = -90 }, 0.10)
            self_._openSettingsDropdownCloser = closeMenu
        end

        button.MouseButton1Click:Connect(function()
            if opened then closeMenu() else openMenu() end
        end)

        self_:Track(UserInputService.InputBegan:Connect(function(input)
            if not opened then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then return end

            local point = Vector2.new(input.Position.X, input.Position.Y)
            local function contains(gui)
                if not gui or not gui.Parent then return false end
                local pos = gui.AbsolutePosition
                local size_ = gui.AbsoluteSize
                return point.X >= pos.X and point.X <= pos.X + size_.X
                    and point.Y >= pos.Y and point.Y <= pos.Y + size_.Y
            end

            task.defer(function()
                if opened and not contains(button) and not contains(menu) then closeMenu() end
            end)
        end))

        return {
            Row = row,
            Button = button,
            Menu = menu,
            Get = function() return value end,
            Set = function(v, fire)
                for _, option in ipairs(options) do
                    if tostring(option) == tostring(v) then
                        setValue(option, fire == true)
                        return
                    end
                end
            end,
            Open = openMenu,
            Close = closeMenu,
        }
    end

    local function selectSettingsPage(name)
        if self_._openSettingsDropdownCloser then
            pcall(self_._openSettingsDropdownCloser)
        end
        currentSettingsPage = name
        settingsPageTitle.Text = name

        for pageName, page in pairs(settingsPages) do
            page.Visible = pageName == name
        end

        for btnName, data in pairs(settingsNavButtons) do
            local active = btnName == name
            tween(data.Button, {
                BackgroundTransparency = active and 0.18 or 1,
                BackgroundColor3 = active and Theme.Card or Theme.Sidebar,
            }, 0.12, Enum.EasingStyle.Quint)
            tween(data.Label, {
                TextColor3 = active and Theme.Text or Theme.TextDark,
            }, 0.12, Enum.EasingStyle.Quint)
            tween(data.Accent, {
                BackgroundTransparency = active and 0 or 1,
                Size = active and UDim2.new(0, 2, 0, 20) or UDim2.new(0, 2, 0, 10),
            }, 0.12, Enum.EasingStyle.Quint)
            setIconColor(data.Icon, active and Theme.Text or Theme.TextDimmer, 0.12)
        end
    end

    local navItems = {
        { Name = "Interface", Icon = "monitor" },
        { Name = "Configuration", Icon = "file" },
        { Name = "Socials", Icon = "user" },
    }

    for i, item in ipairs(navItems) do
        local btn = create("TextButton", {
            Text = "",
            AutoButtonColor = false,
        BorderSizePixel = 0,
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 38),
            LayoutOrder = i,
            ZIndex = 23,
            Parent = settingsNavList,
        }, { corner(7) })

        local accent = create("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 6, 0.5, 0),
            Size = UDim2.new(0, 2, 0, 10),
            ZIndex = 24,
            Parent = btn,
        }, { corner(9999) })

        local iconHolder = create("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 24,
            Parent = btn,
        })
        local icon = buildIcon(iconHolder, item.Icon, 16, Theme.TextDimmer)

        local label = create("TextLabel", {
            Text = item.Name,
            FontFace = Theme.FontSemibold,
            TextSize = 13,
            TextColor3 = Theme.TextDark,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 0),
            Size = UDim2.new(1, -46, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 24,
            Parent = btn,
        })

        settingsNavButtons[item.Name] = {
            Button = btn,
            Label = label,
            Icon = icon,
            Accent = accent,
        }

        btn.MouseEnter:Connect(function()
            if currentSettingsPage ~= item.Name then
                tween(btn, { BackgroundTransparency = 0.82, BackgroundColor3 = Theme.CardHover }, 0.1)
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentSettingsPage ~= item.Name then
                tween(btn, { BackgroundTransparency = 1, BackgroundColor3 = Theme.Sidebar }, 0.1)
            end
        end)
        btn.MouseButton1Click:Connect(function()
            selectSettingsPage(item.Name)
        end)
    end

    ------------------------------------------------------------
    -- APPEARANCE
    ------------------------------------------------------------
    local appearancePage = createSettingsPage("Appearance")

    -- Appearance is intentionally only a Custom Theme editor.
    -- Every interface colour used by this script is exposed below.
    local customThemeSection = settingsSection(
        appearancePage,
        "Custom theme",
        "Edit every colour used by the interface. Press Enter after changing a HEX value."
    )

    local themeColorDefinitions = {
        { Key = "Background",        Label = "App background",       Hint = "Main window background." },
        { Key = "TitleBar",          Label = "Titlebar",             Hint = "Top title bar." },
        { Key = "Sidebar",           Label = "Explorer",             Hint = "Main and Settings sidebars." },
        { Key = "TabBar",            Label = "Tab bar",              Hint = "Open-tab strip." },
        { Key = "Content",           Label = "Editor background",    Hint = "Main content area." },
        { Key = "Field",             Label = "Fields",               Hint = "Inputs and inactive controls." },
        { Key = "FieldHover",        Label = "Field hover",          Hint = "Hovered fields and controls." },
        { Key = "Card",              Label = "Menus and cards",      Hint = "Card and panel background." },
        { Key = "CardHover",         Label = "Card hover",           Hint = "Hovered cards and selected navigation." },
        { Key = "Stroke",            Label = "Borders",              Hint = "Primary border colour." },
        { Key = "StrokeSoft",        Label = "Soft borders",         Hint = "Subtle separators." },
        { Key = "StrokeTabBar",      Label = "Tab separators",       Hint = "Tab and status separators." },
        { Key = "SearchStroke",      Label = "Search border",        Hint = "Search field border." },
        { Key = "SearchStrokeFocus", Label = "Search focus",         Hint = "Focused search border." },
        { Key = "Text",              Label = "Primary text",         Hint = "Main bright text." },
        { Key = "TextTabInactive",   Label = "Inactive tab text",    Hint = "Tabs that are not selected." },
        { Key = "TextDark",          Label = "Secondary text",       Hint = "Descriptions and secondary labels." },
        { Key = "TextDimmer",        Label = "Dim text",             Hint = "Muted icons and low-priority labels." },
        { Key = "Accent",            Label = "Accent",               Hint = "Active indicators and primary controls." },
        { Key = "Success",           Label = "Success",              Hint = "Success notifications." },
        { Key = "Error",             Label = "Error",                Hint = "Errors and danger actions." },
        { Key = "Warning",           Label = "Warning",              Hint = "Warning notifications." },
        { Key = "Info",              Label = "Info",                 Hint = "Information notifications." },
        { Key = "PrimaryText",       Label = "Accent button text",   Hint = "Text displayed over accent buttons." },
        { Key = "SurfaceTint",       Label = "Surface tint",         Hint = "Very subtle overlay tint." },
        { Key = "SettingsBackdrop",  Label = "Settings backdrop",    Hint = "Dim layer behind the Settings panel." },
        { Key = "ToggleKnobActive",  Label = "Active toggle knob",   Hint = "Knob colour when a toggle is enabled." },
    }

    -- Best-effort live recolouring. Theme is also updated so every newly-created
    -- control uses the edited colour automatically.
    local function replaceColourInTree(root, oldColor, newColor)
        if not root then return end
        for _, inst in ipairs(root:GetDescendants()) do
            pcall(function()
                if inst:IsA("GuiObject")
                    and not Library:GetThemeBinding(inst, "BackgroundColor3")
                    and inst.BackgroundColor3 == oldColor then
                    inst.BackgroundColor3 = newColor
                end
            end)
            pcall(function()
                if (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox"))
                    and not Library:GetThemeBinding(inst, "TextColor3")
                    and inst.TextColor3 == oldColor then
                    inst.TextColor3 = newColor
                end
            end)
            pcall(function()
                if inst:IsA("TextBox")
                    and not Library:GetThemeBinding(inst, "PlaceholderColor3")
                    and inst.PlaceholderColor3 == oldColor then
                    inst.PlaceholderColor3 = newColor
                end
            end)
            pcall(function()
                if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                    if not Library:GetThemeBinding(inst, "ImageColor3")
                        and inst.ImageColor3 == oldColor then
                        inst.ImageColor3 = newColor
                    end
                end
            end)
            pcall(function()
                if inst:IsA("UIStroke")
                    and not Library:GetThemeBinding(inst, "Color")
                    and inst.Color == oldColor then
                    inst.Color = newColor
                end
            end)
            pcall(function()
                if inst:IsA("ScrollingFrame")
                    and not Library:GetThemeBinding(inst, "ScrollBarImageColor3")
                    and inst.ScrollBarImageColor3 == oldColor then
                    inst.ScrollBarImageColor3 = newColor
                end
            end)

            pcall(function()
                if inst:IsA("UIGradient") then
                    local changed = false
                    local points = {}

                    for _, point in ipairs(inst.Color.Keypoints) do
                        local color = point.Value
                        if color == oldColor then
                            color = newColor
                            changed = true
                        end

                        table.insert(
                            points,
                            ColorSequenceKeypoint.new(point.Time, color)
                        )
                    end

                    if changed then
                        inst.Color = ColorSequence.new(points)
                    end
                end
            end)
        end
    end

    local themeRows = {}
    local savedThemeSnapshot = {}

    local function setThemeColor(key, newColor)
        local oldColor = Theme[key]
        if typeof(oldColor) ~= "Color3" or typeof(newColor) ~= "Color3" then return end

        local oldThemeSnapshot = {}
        for _, token in ipairs(Library.ThemeColorKeys) do
            oldThemeSnapshot[token] = Theme[token]
        end
        Library:_RebindThemeFromCurrentValues(screenGui, oldThemeSnapshot)

        Theme[key] = newColor
        Library:_ApplyThemeBindings(screenGui)
        replaceColourInTree(screenGui, oldColor, newColor)

        if type(Library.RefreshNotificationTheme) == "function" then
            Library:RefreshNotificationTheme()
        end

        if themeRows[key] then
            themeRows[key].Swatch.BackgroundColor3 = newColor
            themeRows[key].Hex.Text = colorToHex(newColor)
        end
    end

    local currentBaseTheme = "Default"
    local baseThemeControl = nil

    local themePresets = {
        ["Default"] = {
            Background = "#18181B",
            TitleBar = "#19191C",
            Sidebar = "#141416",
            TabBar = "#19191C",
            Content = "#1B1B1E",
            Field = "#111113",
            FieldHover = "#171719",
            Card = "#1E1E21",
            CardHover = "#232327",
            Stroke = "#252528",
            StrokeSoft = "#202023",
            StrokeTabBar = "#2A2A2E",
            SearchStroke = "#202024",
            SearchStrokeFocus = "#4A4A50",
            Text = "#F8F8F9",
            TextTabInactive = "#D2D2D5",
            TextDark = "#96969B",
            TextDimmer = "#78787D",
            Accent = "#F8F8F9",
            Success = "#4ADE80",
            Error = "#FF8484",
            Warning = "#FACC15",
            Info = "#C8C8C8",
            PrimaryText = "#0F0F0F",
            SurfaceTint = "#FFFFFF",
            SettingsBackdrop = "#08080A",
            ToggleKnobActive = "#141416",
        },

        ["Haunted"] = {
            Background = "#0D1010",
            TitleBar = "#111515",
            Sidebar = "#0A0D0D",
            TabBar = "#111515",
            Content = "#101414",
            Field = "#080B0B",
            FieldHover = "#151B19",
            Card = "#141A18",
            CardHover = "#1B2420",
            Stroke = "#28352F",
            StrokeSoft = "#1C2722",
            StrokeTabBar = "#304239",
            SearchStroke = "#223129",
            SearchStrokeFocus = "#7C9B72",
            Text = "#E9E4D5",
            TextTabInactive = "#C3BDAE",
            TextDark = "#8E958A",
            TextDimmer = "#697169",
            Accent = "#91B078",
            Success = "#73C991",
            Error = "#F7A0A0",
            Warning = "#C9A75D",
            Info = "#AEB9AD",
            PrimaryText = "#10150F",
            SurfaceTint = "#CBD8C6",
            SettingsBackdrop = "#060808",
            ToggleKnobActive = "#101510",
        },

        ["Destiny"] = {
            Background = "#17101F",
            TitleBar = "#1D1428",
            Sidebar = "#120C19",
            TabBar = "#1D1428",
            Content = "#1A1124",
            Field = "#100B16",
            FieldHover = "#241731",
            Card = "#21152D",
            CardHover = "#2B1B3A",
            Stroke = "#443055",
            StrokeSoft = "#352442",
            StrokeTabBar = "#503765",
            SearchStroke = "#382649",
            SearchStrokeFocus = "#B782D9",
            Text = "#F7EDF9",
            TextTabInactive = "#D7C1DD",
            TextDark = "#A78EAE",
            TextDimmer = "#806E87",
            Accent = "#C08AE3",
            Success = "#6FD49B",
            Error = "#FBA0B3",
            Warning = "#DAB760",
            Info = "#C7B4D3",
            PrimaryText = "#211129",
            SurfaceTint = "#E2C2F2",
            SettingsBackdrop = "#0B0710",
            ToggleKnobActive = "#211129",
        },

        ["Bonanza"] = {
            Background = "#2D1747",
            TitleBar = "#3A1E59",
            Sidebar = "#211034",
            TabBar = "#3A1E59",
            Content = "#321A4D",
            Field = "#241238",
            FieldHover = "#432560",
            Card = "#3A2055",
            CardHover = "#4A2A68",
            Stroke = "#684685",
            StrokeSoft = "#523568",
            StrokeTabBar = "#755092",
            SearchStroke = "#563A70",
            SearchStrokeFocus = "#73D7FF",
            Text = "#FFF9FE",
            TextTabInactive = "#EACDE5",
            TextDark = "#C7A9C5",
            TextDimmer = "#9C809B",
            Accent = "#FF77C8",
            Success = "#70E3A2",
            Error = "#FFA5AC",
            Warning = "#FFD95A",
            Info = "#78D9FF",
            PrimaryText = "#35113A",
            SurfaceTint = "#FFDBF1",
            SettingsBackdrop = "#160A22",
            ToggleKnobActive = "#37143F",
        },

        ["Olympus"] = {
            Background = "#141A26",
            TitleBar = "#182031",
            Sidebar = "#0F141E",
            TabBar = "#182031",
            Content = "#161D2A",
            Field = "#0D121B",
            FieldHover = "#202A3A",
            Card = "#1B2433",
            CardHover = "#263247",
            Stroke = "#3C4B63",
            StrokeSoft = "#2A374B",
            StrokeTabBar = "#4A5C77",
            SearchStroke = "#334258",
            SearchStrokeFocus = "#E6BE68",
            Text = "#FAF7ED",
            TextTabInactive = "#D8D5CA",
            TextDark = "#A4A9AF",
            TextDimmer = "#7A828C",
            Accent = "#E7BE65",
            Success = "#63D397",
            Error = "#FAA0A0",
            Warning = "#F0C96A",
            Info = "#B7C0CB",
            PrimaryText = "#241C0A",
            SurfaceTint = "#F3DC9C",
            SettingsBackdrop = "#080B12",
            ToggleKnobActive = "#241C0A",
        },
    }

    local function applyThemePreset(name, notify)
        local preset = themePresets[name]
        if not preset then return false end

        local oldTheme = {}
        local newTheme = {}

        for _, definition in ipairs(themeColorDefinitions) do
            local key = definition.Key
            oldTheme[key] = Theme[key]

            local parsed = parseHex(preset[key])
            newTheme[key] = parsed or Theme[key]
        end

        -- Map all old colors before mutating Theme. This avoids chained replacements.
        local colorMap = {}
        for _, definition in ipairs(themeColorDefinitions) do
            local key = definition.Key
            if oldTheme[key] and newTheme[key] then
                colorMap[colorToHex(oldTheme[key])] = newTheme[key]
            end
        end

        local derivedMappings = {
            { "CardHover", 1.16 },
            { "CardHover", 1.12 },
            { "Card", 1.025 },
            { "StrokeTabBar", 1.20 },
            { "Accent", 1.04 },
            { "Accent", 1.05 },
            { "TitleBar", 1.08 },
            { "TitleBar", 1.04 },
            { "TitleBar", 0.92 },
            { "TitleBar", 0.72 },
            { "FieldHover", 1.04 },
        }

        for _, item in ipairs(derivedMappings) do
            local key = item[1]
            local factor = item[2]
            local oldColor = oldTheme[key]
            local newColor = newTheme[key]

            if oldColor and newColor then
                colorMap[colorToHex(shadeColor(oldColor, factor))] =
                    shadeColor(newColor, factor)
            end
        end

        Library:_RebindThemeFromCurrentValues(screenGui, oldTheme)

        for key, color in pairs(newTheme) do
            Theme[key] = color
        end

        Library:_ApplyThemeBindings(screenGui)

        for _, inst in ipairs(screenGui:GetDescendants()) do
            pcall(function()
                if inst:IsA("GuiObject") then
                    local mapped = colorMap[colorToHex(inst.BackgroundColor3)]
                    if mapped then inst.BackgroundColor3 = mapped end
                end
            end)

            pcall(function()
                if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                    local mapped = colorMap[colorToHex(inst.TextColor3)]
                    if mapped then inst.TextColor3 = mapped end
                end
            end)

            pcall(function()
                if inst:IsA("TextBox") then
                    local mapped = colorMap[colorToHex(inst.PlaceholderColor3)]
                    if mapped then inst.PlaceholderColor3 = mapped end
                end
            end)

            pcall(function()
                if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                    local mapped = colorMap[colorToHex(inst.ImageColor3)]
                    if mapped then inst.ImageColor3 = mapped end
                end
            end)

            pcall(function()
                if inst:IsA("UIStroke") then
                    local mapped = colorMap[colorToHex(inst.Color)]
                    if mapped then inst.Color = mapped end
                end
            end)

            pcall(function()
                if inst:IsA("ScrollingFrame") then
                    local mapped = colorMap[colorToHex(inst.ScrollBarImageColor3)]
                    if mapped then inst.ScrollBarImageColor3 = mapped end
                end
            end)

            pcall(function()
                if inst:IsA("UIGradient") then
                    local changed = false
                    local points = {}

                    for _, point in ipairs(inst.Color.Keypoints) do
                        local mapped = colorMap[colorToHex(point.Value)]
                        local color = mapped or point.Value

                        if mapped then
                            changed = true
                        end

                        table.insert(
                            points,
                            ColorSequenceKeypoint.new(point.Time, color)
                        )
                    end

                    if changed then
                        inst.Color = ColorSequence.new(points)
                    end
                end
            end)
        end

        -- Refresh generic buttons, including their text color.
        for _, inst in ipairs(screenGui:GetDescendants()) do
            if inst:IsA("TextButton") then
                local variant = inst:GetAttribute("MistButtonVariant")
                if variant then
                    local bg, fg = getButtonVariant(variant)
                    inst.BackgroundColor3 = bg
                    for _, child in ipairs(inst:GetChildren()) do
                        if child:IsA("TextLabel") then
                            child.TextColor3 = fg
                        end
                    end
                end
            end
        end

        -- Refresh top tabs, active underline and scrollbars.
        for _, tab in ipairs(self_.Tabs or {}) do
            if tab._underline then
                tab._underline.BackgroundColor3 = Theme.Accent
            end

            if tab._label then
                tab._label.TextColor3 =
                    (self_._activeTab == tab) and Theme.Text or Theme.TextTabInactive
            end

            local tabPage = rawget(tab, "Page")
            if tabPage and tabPage:IsA("ScrollingFrame") then
                tabPage.ScrollBarImageColor3 = Theme.Accent
            end
        end

        -- Refresh sidebar active indicator + fade.
        for _, category in ipairs(self_.Categories or {}) do
            for _, item in ipairs(category._items or {}) do
                if item._accentBar then
                    item._accentBar.BackgroundColor3 = Theme.Accent
                end

                if item._activeFade then
                    item._activeFade.BackgroundColor3 = Theme.Accent
                end

                if item._label then
                    local active = item._accentBar
                        and item._accentBar.BackgroundTransparency <= 0.01
                    item._label.TextColor3 = active and Theme.Accent or Theme.Text
                end

                if item._icon then
                    local active = item._accentBar
                        and item._accentBar.BackgroundTransparency <= 0.01
                    setIconColor(
                        item._icon,
                        active and Theme.Accent or Theme.TextDark,
                        0
                    )
                end
            end
        end

        surfaceTint.BackgroundColor3 = Theme.SurfaceTint
        if fullUIBlurOverlay then
            fullUIBlurOverlay.BackgroundColor3 = Theme.TitleBar
        end

        currentBaseTheme = name
        if baseThemeControl then
            baseThemeControl.Set(name, false)
        end

        for _, definition in ipairs(themeColorDefinitions) do
            local ref = themeRows[definition.Key]
            if ref then
                ref.Swatch.BackgroundColor3 = Theme[definition.Key]
                ref.Hex.Text = colorToHex(Theme[definition.Key])
            end
        end

        Library:_ApplyThemeBindings(screenGui)

        if type(Library.RefreshNotificationTheme) == "function" then
            Library:RefreshNotificationTheme()
        end

        if notify then
            Library:Notify({
                Title = "Appearance",
                Content = name .. " theme applied.",
                Type = "Success",
            })
        end

        return true
    end

    local function createThemeColorRow(parent, definition)
        local key = definition.Key
        local row = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 58),
            ZIndex = 23,
            Parent = parent,
        })

        create("Frame", {
            BackgroundColor3 = Theme.StrokeSoft,
            BackgroundTransparency = 0.15,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 23,
            Parent = row,
        })

        create("TextLabel", {
            Text = definition.Label,
            FontFace = Theme.FontSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 7),
            Size = UDim2.new(0.48, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 24,
            Parent = row,
        })

        create("TextLabel", {
            Text = definition.Hint or key,
            FontFace = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.TextDark,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 28),
            Size = UDim2.new(0.52, 0, 0, 17),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 24,
            Parent = row,
        })

        local swatch = create("Frame", {
            BackgroundColor3 = Theme[key],
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -174, 0.5, 0),
            Size = UDim2.new(0, 30, 0, 24),
            ZIndex = 24,
            Parent = row,
        }, { corner(5) })

        local hexBox = create("TextBox", {
            Text = colorToHex(Theme[key]),
            PlaceholderText = "#000000",
            FontFace = Theme.FontSemibold,
            TextSize = 11,
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.TextDimmer,
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.TitleBar,
            ClearTextOnFocus = false,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 132, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 24,
            Parent = row,
        }, {
            corner(12),
            stroke(Theme.StrokeSoft, 1, 0.78),
            padding(10),
            create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, shadeColor(Theme.TitleBar, 1.08)),
                    ColorSequenceKeypoint.new(0.52, Theme.TitleBar),
                    ColorSequenceKeypoint.new(1.00, shadeColor(Theme.TitleBar, 0.72)),
                }),
            }),
        })


        local function commit()
            local parsed = parseHex(hexBox.Text)
            if parsed then
                setThemeColor(key, parsed)
            else
                hexBox.Text = colorToHex(Theme[key])
                Library:Notify({
                    Title = "Appearance",
                    Content = "Invalid HEX value for " .. definition.Label .. ".",
                    Type = "Error",
                })
            end
        end

        hexBox.FocusLost:Connect(function(enterPressed)
            if enterPressed or hexBox.Text ~= colorToHex(Theme[key]) then
                commit()
            end
        end)

        themeRows[key] = {
            Row = row,
            Swatch = swatch,
            Hex = hexBox,
        }
        savedThemeSnapshot[key] = colorToHex(Theme[key])
    end

    for _, definition in ipairs(themeColorDefinitions) do
        createThemeColorRow(customThemeSection, definition)
    end

    local saveThemeRow = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        ZIndex = 23,
        Parent = customThemeSection,
    })

    create("TextLabel", {
        Text = "Save",
        FontFace = Theme.FontSemibold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 4),
        Size = UDim2.new(0.42, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = saveThemeRow,
    })
    create("TextLabel", {
        Text = "Name this theme and save the current colours.",
        FontFace = Theme.Font,
        TextSize = 10,
        TextColor3 = Theme.TextDark,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(0.48, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = saveThemeRow,
    })

    local themeNameBox = create("TextBox", {
        Text = "",
        PlaceholderText = "Theme name",
        FontFace = Theme.Font,
        TextSize = 11,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDimmer,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.TitleBar,
        ClearTextOnFocus = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -58, 0.5, 0),
        Size = UDim2.new(0, 166, 0, 32),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = saveThemeRow,
    }, {
        corner(12),
        stroke(Theme.StrokeSoft, 1, 0.78),
        padding(10),
        create("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, shadeColor(Theme.TitleBar, 1.08)),
                ColorSequenceKeypoint.new(0.52, Theme.TitleBar),
                ColorSequenceKeypoint.new(1.00, shadeColor(Theme.TitleBar, 0.72)),
            }),
        }),
    })


    local saveThemeButton = makeButton(saveThemeRow, "Save", "secondary", 50, 30, function()
        local themeName = themeNameBox.Text ~= "" and themeNameBox.Text or "Custom"
        local payload = { Name = themeName, BaseTheme = "Default", Colors = {} }
        for _, definition in ipairs(themeColorDefinitions) do
            payload.Colors[definition.Key] = colorToHex(Theme[definition.Key])
        end

        local ok = false
        local isFolderFn = getRuntimeFunction("isfolder")
        local makeFolderFn = getRuntimeFunction("makefolder")
        local writeFileFn = getRuntimeFunction("writefile")

        if isFolderFn and makeFolderFn and writeFileFn then
            if not isFolderFn("MistHub") then pcall(makeFolderFn, "MistHub") end
            if not isFolderFn("MistHub/Themes") then pcall(makeFolderFn, "MistHub/Themes") end

            local safeName = themeName:gsub("[^%w%-%_ ]", ""):gsub("%s+", "_")
            ok = pcall(function()
                writeFileFn(
                    "MistHub/Themes/" .. safeName .. ".json",
                    game:GetService("HttpService"):JSONEncode(payload)
                )
            end)
        end

        Library:Notify({
            Title = "Appearance",
            Content = ok and ("Theme '" .. themeName .. "' saved.") or "Theme could not be saved permanently.",
            Type = ok and "Success" or "Info",
        })
    end)
    saveThemeButton.AnchorPoint = Vector2.new(1, 0.5)
    saveThemeButton.Position = UDim2.new(1, 0, 0.5, 0)

    local shareThemeRow = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 54),
        ZIndex = 23,
        Parent = customThemeSection,
    })

    create("TextLabel", {
        Text = "Share",
        FontFace = Theme.FontSemibold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 5),
        Size = UDim2.new(0.42, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = shareThemeRow,
    })
    create("TextLabel", {
        Text = "Themes travel as JSON on the clipboard.",
        FontFace = Theme.Font,
        TextSize = 10,
        TextColor3 = Theme.TextDark,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 26),
        Size = UDim2.new(0.48, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = shareThemeRow,
    })

    local shareButtons = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 188, 0, 32),
        ZIndex = 24,
        Parent = shareThemeRow,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local function exportThemeJson()
        local payload = { BaseTheme = currentBaseTheme, Colors = {} }
        for _, definition in ipairs(themeColorDefinitions) do
            payload.Colors[definition.Key] = colorToHex(Theme[definition.Key])
        end
        return game:GetService("HttpService"):JSONEncode(payload)
    end

    local function importThemeJson(json)
        local ok, payload = pcall(function()
            return game:GetService("HttpService"):JSONDecode(json)
        end)
        if not ok or type(payload) ~= "table" or type(payload.Colors) ~= "table" then
            Library:Notify({ Title = "Appearance", Content = "Invalid theme JSON.", Type = "Error" })
            return false
        end
        for _, definition in ipairs(themeColorDefinitions) do
            local value = payload.Colors[definition.Key]
            local parsed = parseHex(value)
            if parsed then setThemeColor(definition.Key, parsed) end
        end
        if payload.BaseTheme and themePresets[payload.BaseTheme] then
            currentBaseTheme = payload.BaseTheme
            if baseThemeControl then baseThemeControl.Set(currentBaseTheme, false) end
        end
        Library:Notify({ Title = "Appearance", Content = "Theme pasted.", Type = "Success" })
        return true
    end

    makeButton(shareButtons, "Copy", "secondary", 56, 30, function()
        local json = exportThemeJson()
        local setClipboardFn = getRuntimeFunction("setclipboard")
        if setClipboardFn then
            pcall(setClipboardFn, json)
            Library:Notify({ Title = "Appearance", Content = "Theme JSON copied.", Type = "Success" })
        else
            Library:Notify({ Title = "Appearance", Content = "Clipboard API is unavailable.", Type = "Warning" })
        end
    end)

    makeButton(shareButtons, "Paste", "secondary", 58, 30, function()
        local getClipboardFn = getRuntimeFunction("getclipboard")
        if getClipboardFn then
            local ok, clipboard = pcall(getClipboardFn)
            if ok and clipboard then importThemeJson(clipboard) end
        else
            Library:Notify({ Title = "Appearance", Content = "Clipboard API is unavailable.", Type = "Warning" })
        end
    end)

    makeButton(shareButtons, "Clear", "secondary", 56, 30, function()
        for _, definition in ipairs(themeColorDefinitions) do
            local original = parseHex(savedThemeSnapshot[definition.Key])
            if original then setThemeColor(definition.Key, original) end
        end
        themeNameBox.Text = ""
        currentBaseTheme = "Default"
        if baseThemeControl then baseThemeControl.Set("Default", false) end
        Library:Notify({ Title = "Appearance", Content = "Theme changes cleared.", Type = "Info" })
    end)

    -- Compatibility objects used by Reset Settings in Configuration.

    ------------------------------------------------------------
    -- INTERFACE
    ------------------------------------------------------------
    local interfacePage = createSettingsPage("Interface")

    local interfaceSection = settingsSection(
        interfacePage,
        "Interface",
        "General interface behaviour and hotkeys."
    )

    baseThemeControl = settingsDropdownRow(
        interfaceSection,
        "Theme",
        "Changes the interface color preset.",
        {
            "Default",
            "Haunted",
            "Destiny",
            "Bonanza",
            "Olympus",
        },
        currentBaseTheme,
        function(value)
            applyThemePreset(value, true)
        end
    )

    local functionInfoToggle = settingsToggleRow(
        interfaceSection,
        "Function info",
        "Shows an info icon beside each function name. Hover it to see what the function does.",
        Library.InterfaceSettings.FunctionInfo ~= false,
        function(value)
            setFunctionInfoEnabled(value)
        end
    )

    local minimizeKey = Enum.KeyCode.Insert

    -- Bind menu removed completely.

    local minimizeKeyRow = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        ZIndex = 23,
        Parent = interfaceSection,
    })

    create("TextLabel", {
        Text = "Minimize keybind",
        FontFace = Theme.FontSemibold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 3),
        Size = UDim2.new(0.62, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = minimizeKeyRow,
    })

    create("TextLabel", {
        Text = "Key used to minimize or restore the interface.",
        FontFace = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextDark,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(0.62, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = minimizeKeyRow,
    })

    local keyButton = create("TextButton", {
        Text = "INSERT",
        FontFace = Theme.FontSemibold,
        TextSize = 11,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.TitleBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 96, 0, 30),
        ZIndex = 24,
        Parent = minimizeKeyRow,
    }, { corner(5) })

    local listeningForMinimizeKey = false
    local minimizeKeyConnection = nil

    keyButton.MouseEnter:Connect(function()
        if not listeningForMinimizeKey then
            tween(keyButton, { BackgroundColor3 = Theme.Field }, 0.10)
        end
    end)

    keyButton.MouseLeave:Connect(function()
        if not listeningForMinimizeKey then
            tween(keyButton, { BackgroundColor3 = Theme.TitleBar }, 0.10)
        end
    end)

    function self_:_GetMinimizeKeyDisplayText()
        return minimizeKey and minimizeKey.Name:upper() or "NONE"
    end

    function self_:_SetMinimizeKeyValue(newKeyCode)
        minimizeKey = newKeyCode
        keyButton.Text = self_:_GetMinimizeKeyDisplayText()
    end

    self_:_SetMinimizeKeyValue(minimizeKey)

    keyButton.MouseButton1Click:Connect(function()
        if listeningForMinimizeKey then return end
        listeningForMinimizeKey = true
        keyButton.Text = "PRESS A KEY"
        tween(keyButton, { BackgroundColor3 = Theme.FieldHover }, 0.10)

        if minimizeKeyConnection then
            minimizeKeyConnection:Disconnect()
            minimizeKeyConnection = nil
        end

        minimizeKeyConnection = self_._maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

            if input.KeyCode == Enum.KeyCode.Escape then
                keyButton.Text = self_:_GetMinimizeKeyDisplayText()
                tween(keyButton, { BackgroundColor3 = Theme.TitleBar }, 0.10)
                listeningForMinimizeKey = false
                minimizeKeyConnection:Disconnect()
                minimizeKeyConnection = nil
                return
            end

            if input.KeyCode == Enum.KeyCode.Backspace then
                self_:_SetMinimizeKeyValue(nil)
                tween(keyButton, { BackgroundColor3 = Theme.TitleBar }, 0.10)
                listeningForMinimizeKey = false
                minimizeKeyConnection:Disconnect()
                minimizeKeyConnection = nil
                return
            end

            self_:_SetMinimizeKeyValue(input.KeyCode)
            tween(keyButton, { BackgroundColor3 = Theme.TitleBar }, 0.10)
            listeningForMinimizeKey = false
            minimizeKeyConnection:Disconnect()
            minimizeKeyConnection = nil
        end))
    end)

    local silentLaunchToggle = settingsToggleRow(
        interfaceSection,
        "Silent launch",
        "Hides the UI when you execute the script.",
        Library.InterfaceSettings.SilentLaunch == true,
        function(value)
            Library.InterfaceSettings.SilentLaunch = value == true
        end
    )

    local silentModeToggle = settingsToggleRow(
        interfaceSection,
        "Silent mode",
        "Hides the notifications from the script.",
        Library.InterfaceSettings.SilentMode == true,
        function(value)
            Library.InterfaceSettings.SilentMode = value == true
        end
    )

    self_._motionSection = settingsSection(
        interfacePage,
        "Accessibility & Motion",
        "Motion, scaling and input accessibility."
    )

    self_._reducedMotionToggle = settingsToggleRow(
        self_._motionSection,
        "Reduced motion",
        "Minimizes interface animation while keeping state changes instant.",
        Library.AnimationSettings.ReducedMotion == true,
        function(value)
            self_:SetReducedMotion(value == true)
        end
    )

    self_._responsiveToggle = settingsToggleRow(
        self_._motionSection,
        "Responsive layout",
        "Adapts sidebar width and card layout to the viewport.",
        true,
        function(value)
            self_:EnableResponsive(value ~= false)
        end
    )

    self_._animationSpeedControl = settingsDropdownRow(
        self_._motionSection,
        "Animation speed",
        "Changes the speed multiplier used by interface animations.",
        { "0.5x", "0.75x", "1x", "1.25x", "1.5x", "2x" },
        tostring(Library.AnimationSettings.Speed or 1) .. "x",
        function(value)
            local speed = tonumber(tostring(value):gsub("x", ""))
            if speed then self_:SetAnimationSpeed(speed) end
        end
    )

    local keybindSection = settingsSection(
        interfacePage,
        "Keybinds",
        "Controls for the floating keybind list."
    )

    self_._keybindListToggle = settingsToggleRow(
        keybindSection,
        "Show keybind list",
        "Shows the floating list of assigned keybinds.",
        self_:GetKeybindMenuOpen(),
        function(value)
            self_:SetKeybindMenuOpen(value == true)
        end
    )

    self_._keybindLockToggle = settingsToggleRow(
        keybindSection,
        "Lock keybind list",
        "Prevents the floating keybind list from being dragged.",
        false,
        function(value)
            if self_._keybindMenu then
                self_._keybindMenu:SetAttribute(
                    "DragLocked",
                    value == true
                )
            end
        end
    )

    local notificationSection = settingsSection(
        interfacePage,
        "Notifications",
        "Customize how notifications are shown."
    )

    self_._notificationEnabledControl = settingsToggleRow(
        notificationSection,
        "Notifications",
        "Enables or disables library notifications.",
        Library.NotificationSettings.Enabled ~= false,
        function(value)
            Library.NotificationSettings.Enabled = value == true
        end
    )

    self_._notificationProgressControl = settingsToggleRow(
        notificationSection,
        "Progress bar",
        "Shows the remaining notification lifetime.",
        Library.NotificationSettings.ProgressBar ~= false,
        function(value)
            Library.NotificationSettings.ProgressBar = value == true
        end
    )

    self_._notificationPauseControl = settingsToggleRow(
        notificationSection,
        "Pause on hover",
        "Pauses a notification timer while the pointer is over it.",
        Library.NotificationSettings.PauseOnHover ~= false,
        function(value)
            Library.NotificationSettings.PauseOnHover = value == true
        end
    )

    self_._notificationPositionControl = settingsDropdownRow(
        notificationSection,
        "Position",
        "Chooses where notifications appear.",
        {
            "TOP RIGHT",
            "TOP LEFT",
            "BOTTOM RIGHT",
            "BOTTOM LEFT",
        },
        Library.NotificationSettings.Position or "TOP RIGHT",
        function(value)
            Library.NotificationSettings.Position = tostring(value)
        end
    )

    self_._notificationDurationControl = settingsDropdownRow(
        notificationSection,
        "Duration",
        "Default notification lifetime.",
        { "2s", "3s", "4s", "5s", "6s", "8s", "10s" },
        tostring(Library.NotificationSettings.Duration or 4) .. "s",
        function(value)
            local duration = tonumber(
                tostring(value):gsub("s", "")
            )
            if duration then
                Library.NotificationSettings.Duration = duration
            end
        end
    )

    self_._notificationMaxControl = settingsDropdownRow(
        notificationSection,
        "Max visible",
        "Maximum number of notifications visible together.",
        { "1", "2", "3", "4", "5", "6", "7", "8" },
        tostring(Library.NotificationSettings.MaxVisible or 4),
        function(value)
            local amount = tonumber(value)
            if amount then
                Library.NotificationSettings.MaxVisible =
                    math.clamp(math.floor(amount), 1, 8)
            end
        end
    )

    settingsButton(interfaceSection, "Unload Interface", function()
        if type(self_.Unload) == "function" then
            self_:Unload()
        elseif type(self_.Destroy) == "function" then
            self_:Destroy()
        end
    end, "secondary")

    ------------------------------------------------------------
    -- SOCIALS
    ------------------------------------------------------------
    local socialsPage = createSettingsPage("Socials")

    local socialsSection = settingsSection(
        socialsPage,
        "Socials",
        "Quick links for your community."
    )

    local function copySocialLink(kind, value)
        local setClipboardFn = getRuntimeFunction("setclipboard")
        if setClipboardFn then
            local ok = pcall(setClipboardFn, tostring(value))
            Library:Notify({
                Title = "Socials",
                Content = ok and (kind .. " copied.") or ("Could not copy " .. kind .. "."),
                Type = ok and "Success" or "Error",
            })
        else
            Library:Notify({
                Title = "Socials",
                Content = "Clipboard API is unavailable.",
                Type = "Warning",
            })
        end
    end

    settingsButton(socialsSection, "Copy Discord Invite", function()
        copySocialLink("Discord invite", Library.SocialLinks.DiscordInvite)
    end, "primary")

    settingsButton(socialsSection, "Copy Youtube Channel Link", function()
        copySocialLink("Youtube channel link", Library.SocialLinks.YoutubeChannel)
    end, "secondary")

    ------------------------------------------------------------
    -- CONFIGURATION
    ------------------------------------------------------------
    local configurationPage = createSettingsPage("Configuration")

    -- Persistent filesystem-based config storage.
    -- No memory fallback and no config index file: configs are real files
    -- under <folder>/settings and the list is built with listfiles().
    Library.ConfigFolder = Library.ConfigFolder or "MistHub"
    Library.ConfigSubFolder = Library.ConfigSubFolder

    local fsWriteFile = getRuntimeFunction("writefile")
    local fsReadFile = getRuntimeFunction("readfile")
    local fsIsFile = getRuntimeFunction("isfile")
    local fsDeleteFile = getRuntimeFunction("delfile")
        or getRuntimeFunction("deletefile")
    local fsMakeFolder = getRuntimeFunction("makefolder")
    local fsIsFolder = getRuntimeFunction("isfolder")
    local fsListFiles = getRuntimeFunction("listfiles")

    local function canUseFileAPI()
        return type(fsWriteFile) == "function"
            and type(fsReadFile) == "function"
            and type(fsIsFile) == "function"
            and type(fsMakeFolder) == "function"
            and type(fsIsFolder) == "function"
            and type(fsListFiles) == "function"
    end

    local function sanitizeFolderPart(value)
        local clean = tostring(value or "")
        clean = clean:gsub("\\", "/")
        clean = clean:gsub("^/+", ""):gsub("/+$", "")
        clean = clean:gsub('[<>:"|%?%*%z]', "")
        return clean
    end

    local function currentSettingsFolder()
        local root = sanitizeFolderPart(Library.ConfigFolder or "MistHub")
        if root == "" then root = "MistHub" end

        local base = root .. "/settings"
        local sub = sanitizeFolderPart(Library.ConfigSubFolder)
        if sub ~= "" then
            base = base .. "/" .. sub
        end
        return base
    end

    local configsFolder = currentSettingsFolder()
    local autoloadPath = configsFolder .. "/autoload.txt"

    local function splitFolderPath(path)
        local out = {}
        local current = ""
        for part in string.gmatch(tostring(path or ""), "[^/]+") do
            current = current == "" and part or (current .. "/" .. part)
            table.insert(out, current)
        end
        return out
    end

    local function ensureConfigFolders()
        if not canUseFileAPI() then
            return false, "Saving configs is not supported in this environment."
        end

        configsFolder = currentSettingsFolder()
        autoloadPath = configsFolder .. "/autoload.txt"

        for _, path in ipairs(splitFolderPath(configsFolder)) do
            local existsOk, exists = pcall(fsIsFolder, path)
            if not (existsOk and exists == true) then
                local makeOk, makeError = pcall(fsMakeFolder, path)
                if not makeOk then
                    return false, tostring(makeError or ("Could not create folder " .. path))
                end
            end
        end

        return true
    end

    local function sanitizeConfigName(name)
        local clean = tostring(name or "")
        clean = clean:gsub("[^%w%-%_ ]", "")
        clean = clean:gsub("%s+", "_")
        if clean == "" then clean = "Default" end
        if string.lower(clean) == "autoload" then clean = "Default" end
        return clean
    end

    local function configPathFromName(name)
        configsFolder = currentSettingsFolder()
        autoloadPath = configsFolder .. "/autoload.txt"
        return configsFolder .. "/" .. sanitizeConfigName(name) .. ".json"
    end

    local configSection = settingsSection(
        configurationPage,
        "Config",
        nil
    )

    settingsLabel(configSection, "Config Name")

    local configNameBox = create("TextBox", {
        PlaceholderText = "Config name",
        Text = "Default",
        FontFace = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDark,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.TitleBar,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, 34),
        ZIndex = 23,
        Parent = configSection,
    }, {
        corner(12),
        stroke(Theme.StrokeSoft, 1, 0.78),
        padding(12),
    })


    -- Keep this textbox readable even after focus/theme interactions.
    configNameBox.TextColor3 = Theme.Text
    configNameBox.PlaceholderColor3 = Theme.TextDark

    configNameBox.Focused:Connect(function()
        configNameBox.TextColor3 = Theme.Text
        configNameBox.PlaceholderColor3 = Theme.TextDark
    end)

    configNameBox.FocusLost:Connect(function()
        configNameBox.TextColor3 = Theme.Text
        configNameBox.PlaceholderColor3 = Theme.TextDark
    end)

    configNameBox:GetPropertyChangedSignal("Text"):Connect(function()
        configNameBox.TextColor3 = Theme.Text
    end)

    local selectedConfig = "Default"
    local configDropdownValue = nil
    local configDropdownMenu = nil
    local configDropdownArrow = nil
    local currentAutoloadValue = nil
    local currentConfigNames = {}

    local function setSelectedConfig(name, syncNameBox)
        name = sanitizeConfigName(name)
        selectedConfig = name
        if syncNameBox ~= false then
            configNameBox.Text = name
        end
        configNameBox.TextColor3 = Theme.Text
        configNameBox.PlaceholderColor3 = Theme.TextDark
        if configDropdownValue then
            configDropdownValue.Text = name
        end
    end

    -- Configs are listed directly from the settings folder.
    -- Keep compatibility no-ops for older internal callers; no index file is written.
    local function addConfigToIndex(_name)
        return true
    end

    local function removeConfigFromIndex(_name)
        return true
    end

    local function readConfigNames()
        local names = {}
        local seen = {}

        if not canUseFileAPI() then
            return names
        end

        local foldersOk = ensureConfigFolders()
        if not foldersOk then
            return names
        end

        local ok, files = pcall(fsListFiles, configsFolder)
        if not ok or type(files) ~= "table" then
            return names
        end

        for _, filePath in ipairs(files) do
            local normalized = tostring(filePath):gsub("\\", "/")
            local name = normalized:match("([^/]+)%.json$")
            if name and string.lower(name) ~= "autoload" then
                name = sanitizeConfigName(name)
                if name ~= "" and not seen[name] then
                    seen[name] = true
                    table.insert(names, name)
                end
            end
        end

        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return names
    end

    local configsRow = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        ZIndex = 23,
        Parent = configSection,
    })

    create("TextLabel", {
        Text = "Selected Config",
        FontFace = Theme.FontSemibold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(0.40, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 24,
        Parent = configsRow,
    })

    local dropdownButton = create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.TitleBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -38, 0.5, 0),
        Size = UDim2.new(0, 180, 0, 34),
        ZIndex = 24,
        Parent = configsRow,
    }, {
        corner(12),
        stroke(Theme.StrokeSoft, 1, 0.78),
        padding(10),
    })

    configDropdownValue = create("TextLabel", {
        Text = "Default",
        FontFace = Theme.FontSemibold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 25,
        Parent = dropdownButton,
    })

    local dropdownArrowHolder = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Rotation = 90,
        ZIndex = 25,
        Parent = dropdownButton,
    })
    configDropdownArrow = dropdownArrowHolder
    buildIcon(dropdownArrowHolder, "chevron-right", 16, Theme.TextDark)

    local refreshConfigsButton = create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.TitleBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 34, 0, 34),
        ZIndex = 24,
        Parent = configsRow,
    }, { corner(12) })

    local refreshConfigsIcon = buildIcon(refreshConfigsButton, "refresh-cw", 15, Theme.TextDark)

    configDropdownMenu = create("Frame", {
        Name = "ConfigDropdownMenu",
        BackgroundColor3 = Theme.TitleBar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 212, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 80,
        Parent = SettingsPanel,
    }, { corner(12), stroke(Theme.StrokeSoft, 1, 0.78) })

    local configDropdownList = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 1,
        ZIndex = 81,
        Parent = configDropdownMenu,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    configDropdownList.MouseEnter:Connect(function()
        tween(configDropdownList, { ScrollBarImageTransparency = 1 }, 0.10)
    end)

    configDropdownList.MouseLeave:Connect(function()
        tween(configDropdownList, { ScrollBarImageTransparency = 1 }, 0.10)
    end)

    local configDropdownOpen = false
    local configDropdownRows = {}

    function self_:_ClearConfigDropdown()
        for _, row in ipairs(configDropdownRows) do
            if row and row.Parent then
                row:Destroy()
            end
        end
        table.clear(configDropdownRows)
    end

    function self_:_CloseConfigDropdown()
        configDropdownOpen = false
        if configDropdownArrow then
            tween(configDropdownArrow, { Rotation = 90 }, 0.10)
        end
        tween(configDropdownMenu, { Size = UDim2.new(0, 212, 0, 0) }, 0.10)
        task.delay(0.11, function()
            if not configDropdownOpen then
                configDropdownMenu.Visible = false
            end
        end)
    end

    function self_:_RefreshConfigDropdown()
        self_:_ClearConfigDropdown()
        currentConfigNames = readConfigNames()

        for i, name in ipairs(currentConfigNames) do
            -- Keep an immutable copy for this exact row. This prevents a
            -- dropdown callback from ever resolving to another iteration's
            -- config name.
            local optionName = tostring(name)
            local isSelected = sanitizeConfigName(optionName) == sanitizeConfigName(selectedConfig)

            local optionButton = create("TextButton", {
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0,
                BackgroundColor3 = isSelected and Theme.CardHover or Theme.Field,
                Size = UDim2.new(1, 0, 0, 31),
                LayoutOrder = i,
                ZIndex = 82,
                Parent = configDropdownList,
            }, { corner(6) })

            optionButton:SetAttribute("ConfigName", optionName)

            local optionLabel = create("TextLabel", {
                Text = optionName,
                FontFace = Theme.Font,
                TextSize = 12,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -34, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 83,
                Parent = optionButton,
            })
            optionLabel.Text = optionName

            local optionCheckHolder = create("Frame", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -9, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                ZIndex = 83,
                Parent = optionButton,
            })
            buildIcon(optionCheckHolder, "check", 13, Theme.Text)
            optionCheckHolder.Visible = isSelected

            optionButton.MouseEnter:Connect(function()
                tween(optionButton, { BackgroundColor3 = isSelected and shadeColor(Theme.FieldHover, 1.04) or Theme.FieldHover }, 0.10)
            end)

            optionButton.MouseLeave:Connect(function()
                tween(optionButton, { BackgroundColor3 = isSelected and Theme.FieldHover or Theme.TitleBar }, 0.10)
            end)

            optionButton.MouseButton1Click:Connect(function()
                local exactName = optionButton:GetAttribute("ConfigName")
                if type(exactName) == "string" and exactName ~= "" then
                    setSelectedConfig(exactName, true)
                end
                self_:_CloseConfigDropdown()
            end)

            table.insert(configDropdownRows, optionButton)
        end

        local foundSelected = false
        for _, name in ipairs(currentConfigNames) do
            if name == selectedConfig then
                foundSelected = true
                break
            end
        end
        if not foundSelected then
            setSelectedConfig(currentConfigNames[1] or "Default", true)
        else
            setSelectedConfig(selectedConfig, true)
        end
    end

    function self_:_PositionConfigDropdown()
        if not configDropdownMenu or not dropdownButton then return end

        local buttonPos = dropdownButton.AbsolutePosition
        local buttonSize = dropdownButton.AbsoluteSize
        local panelPos = SettingsPanel.AbsolutePosition

        local localX = buttonPos.X - panelPos.X
        local localY = buttonPos.Y - panelPos.Y + buttonSize.Y + 5

        configDropdownMenu.Position = UDim2.new(0, localX, 0, localY)
        configDropdownMenu.Size = UDim2.new(0, math.max(180, buttonSize.X), 0, configDropdownMenu.Size.Y.Offset)
    end

    dropdownButton.MouseButton1Click:Connect(function()
        configDropdownOpen = not configDropdownOpen

        if configDropdownOpen then
            self_:_RefreshConfigDropdown()
            self_:_PositionConfigDropdown()

            configDropdownMenu.Visible = true

            if configDropdownArrow then
                tween(configDropdownArrow, { Rotation = -90 }, 0.10)
            end

            local itemCount = math.max(1, #currentConfigNames)
            local targetHeight = math.min((itemCount * 31) + 8, 194)

            tween(configDropdownMenu, {
                Size = UDim2.new(0, math.max(180, dropdownButton.AbsoluteSize.X), 0, targetHeight),
            }, 0.12, Enum.EasingStyle.Quint)
        else
            self_:_CloseConfigDropdown()
        end
    end)

    dropdownButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if configDropdownOpen then
            self_:_PositionConfigDropdown()
        end
    end)

    dropdownButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if configDropdownOpen then
            self_:_PositionConfigDropdown()
        end
    end)

    refreshConfigsButton.MouseEnter:Connect(function()
        tween(refreshConfigsButton, { BackgroundColor3 = shadeColor(Theme.TitleBar, 1.04) }, 0.10)
        setIconColor(refreshConfigsIcon, Theme.Text, 0.10)
    end)

    refreshConfigsButton.MouseLeave:Connect(function()
        tween(refreshConfigsButton, { BackgroundColor3 = Theme.TitleBar }, 0.10)
        setIconColor(refreshConfigsIcon, Theme.TextDark, 0.10)
    end)

    refreshConfigsButton.MouseButton1Down:Connect(function()
        tween(refreshConfigsButton, { BackgroundColor3 = shadeColor(Theme.TitleBar, 0.92) }, 0.06)
    end)

    refreshConfigsButton.MouseButton1Click:Connect(function()
        self_:_RefreshConfigDropdown()
        Library:Notify({
            Title = "Configuration",
            Content = "Config list refreshed.",
            Type = "Info",
        })
    end)

    local HttpService = game:GetService("HttpService")

    local function encodeConfigPayload(payload)
        local ok, result = pcall(function()
            return HttpService:JSONEncode(payload)
        end)

        if not ok then
            return false, tostring(result)
        end

        return true, result
    end

    local function writeConfigFile(path, payload)
        if type(fsWriteFile) ~= "function" then
            return false, "writefile is unavailable"
        end

        ensureConfigFolders()

        local encodeOk, encodedOrError = encodeConfigPayload(payload)
        if not encodeOk then
            return false, "JSON encode failed: " .. tostring(encodedOrError)
        end

        local writeOk, writeError = pcall(fsWriteFile, path, encodedOrError)
        if not writeOk then
            return false, "writefile failed: " .. tostring(writeError)
        end

        if type(fsIsFile) == "function" then
            local verifyOk, exists = pcall(fsIsFile, path)
            if verifyOk and not exists then
                return false, "file was not created"
            end
        end

        return true
    end

    local function readConfigFile(path)
        if type(fsReadFile) ~= "function" then
            return false, "readfile is unavailable"
        end

        local readOk, rawOrError = pcall(fsReadFile, path)
        if not readOk then
            return false, "readfile failed: " .. tostring(rawOrError)
        end

        local decodeOk, decodedOrError = pcall(function()
            return HttpService:JSONDecode(rawOrError)
        end)

        if not decodeOk then
            return false, "JSON decode failed: " .. tostring(decodedOrError)
        end

        return true, decodedOrError
    end

    local buildConfigPayload

    buildConfigPayload = function()
        local customTheme = {}
        if themeColorDefinitions then
            for _, definition in ipairs(themeColorDefinitions) do
                if Theme[definition.Key] then
                    customTheme[definition.Key] = colorToHex(Theme[definition.Key])
                end
            end
        end

        local categoryStates = {}
        for _, category in ipairs(self_.Categories or {}) do
            if category.Name then
                categoryStates[category.Name] = category._expanded == true
            end
        end

        local activeTabData = nil
        if self_._activeTab then
            activeTabData = {
                Name = self_._activeTab.Name,
                OwnerKey = self_._activeTab.OwnerKey,
            }
        end

        return {
            SchemaVersion = Library.SchemaVersion or 5,
            Interface = {
                MinimizeKey = minimizeKey and minimizeKey.Name or "NONE",
                SilentLaunch = Library.InterfaceSettings.SilentLaunch == true,
                SilentMode = Library.InterfaceSettings.SilentMode == true,
                FunctionInfo = Library.InterfaceSettings.FunctionInfo ~= false,
                ReducedMotion = Library.AnimationSettings.ReducedMotion == true,
                AnimationSpeed = Library.AnimationSettings.Speed or 1,
                Responsive = self_._responsiveEnabled ~= false,
                KeybindMenu = {
                    Open = self_:GetKeybindMenuOpen(),
                    Locked = self_._keybindMenu and self_._keybindMenu:GetAttribute("DragLocked") == true or false,
                    Position = self_._keybindMenu and {
                        XScale = self_._keybindMenu.Position.X.Scale,
                        XOffset = self_._keybindMenu.Position.X.Offset,
                        YScale = self_._keybindMenu.Position.Y.Scale,
                        YOffset = self_._keybindMenu.Position.Y.Offset,
                    } or nil,
                },
                WindowPosition = {
                    XScale = main.Position.X.Scale,
                    XOffset = main.Position.X.Offset,
                    YScale = main.Position.Y.Scale,
                    YOffset = main.Position.Y.Offset,
                },
                WindowSize = {
                    XScale = main.Size.X.Scale,
                    XOffset = main.Size.X.Offset,
                    YScale = main.Size.Y.Scale,
                    YOffset = main.Size.Y.Offset,
                },
                WindowScale = mainScale and mainScale.Scale or 1,
                ActiveTab = activeTabData,
                Categories = categoryStates,
                SettingsPage = currentSettingsPage,
            },
            MinimizeKey = minimizeKey and minimizeKey.Name or "NONE",
            BaseTheme = currentBaseTheme,
            CustomTheme = customTheme,
            Notifications = {
                Enabled = Library.NotificationSettings.Enabled,
                ProgressBar = Library.NotificationSettings.ProgressBar,
                Position = Library.NotificationSettings.Position,
                Duration = Library.NotificationSettings.Duration,
                MaxVisible = Library.NotificationSettings.MaxVisible,
                PauseOnHover = Library.NotificationSettings.PauseOnHover,
            },
            Flags = Library:_CollectFlagValues(),
        }
    end


    local function applyConfigPayload(data)
        if type(data) ~= "table" then return false end
        data = Library:_RunConfigMigrations(data)

        local interfaceData = type(data.Interface) == "table" and data.Interface or nil

        local loadedMinimizeKey = interfaceData and interfaceData.MinimizeKey or data.MinimizeKey
        if loadedMinimizeKey == "NONE" then
            self_:_SetMinimizeKeyValue(nil)
        elseif loadedMinimizeKey and Enum.KeyCode[loadedMinimizeKey] then
            self_:_SetMinimizeKeyValue(Enum.KeyCode[loadedMinimizeKey])
        end

        if interfaceData then
            if interfaceData.SilentLaunch ~= nil then
                Library.InterfaceSettings.SilentLaunch = interfaceData.SilentLaunch == true
                silentLaunchToggle.Set(Library.InterfaceSettings.SilentLaunch)
            end
            if interfaceData.SilentMode ~= nil then
                Library.InterfaceSettings.SilentMode = interfaceData.SilentMode == true
                silentModeToggle.Set(Library.InterfaceSettings.SilentMode)
            end
            if interfaceData.FunctionInfo ~= nil then
                setFunctionInfoEnabled(interfaceData.FunctionInfo ~= false)
                functionInfoToggle.Set(Library.InterfaceSettings.FunctionInfo, false)
            end

            if interfaceData.ReducedMotion ~= nil then
                self_:SetReducedMotion(interfaceData.ReducedMotion == true)
                if self_._reducedMotionToggle then
                    self_._reducedMotionToggle.Set(Library.AnimationSettings.ReducedMotion, false)
                end
            end

            if tonumber(interfaceData.AnimationSpeed) then
                self_:SetAnimationSpeed(tonumber(interfaceData.AnimationSpeed))
                if self_._animationSpeedControl then
                    self_._animationSpeedControl.Set(tostring(Library.AnimationSettings.Speed) .. "x", false)
                end
            end

            if interfaceData.Responsive ~= nil then
                self_:EnableResponsive(interfaceData.Responsive ~= false)
                if self_._responsiveToggle then
                    self_._responsiveToggle.Set(self_._responsiveEnabled ~= false, false)
                end
            end

            if type(interfaceData.KeybindMenu) == "table" then
                local keybindData = interfaceData.KeybindMenu
                if keybindData.Open ~= nil then
                    self_:SetKeybindMenuOpen(keybindData.Open == true)
                    if self_._keybindListToggle then
                        self_._keybindListToggle.Set(self_:GetKeybindMenuOpen(), false)
                    end
                end
                if self_._keybindMenu and keybindData.Locked ~= nil then
                    self_._keybindMenu:SetAttribute("DragLocked", keybindData.Locked == true)
                    if self_._keybindLockToggle then
                        self_._keybindLockToggle.Set(keybindData.Locked == true, false)
                    end
                end
                if self_._keybindMenu and type(keybindData.Position) == "table" then
                    local kp = keybindData.Position
                    self_._keybindMenu.Position = UDim2.new(
                        tonumber(kp.XScale) or self_._keybindMenu.Position.X.Scale,
                        tonumber(kp.XOffset) or self_._keybindMenu.Position.X.Offset,
                        tonumber(kp.YScale) or self_._keybindMenu.Position.Y.Scale,
                        tonumber(kp.YOffset) or self_._keybindMenu.Position.Y.Offset
                    )
                end
            end

            if type(interfaceData.WindowPosition) == "table" then
                local p = interfaceData.WindowPosition
                main.Position = UDim2.new(
                    tonumber(p.XScale) or main.Position.X.Scale,
                    tonumber(p.XOffset) or main.Position.X.Offset,
                    tonumber(p.YScale) or main.Position.Y.Scale,
                    tonumber(p.YOffset) or main.Position.Y.Offset
                )
            end

            if type(interfaceData.WindowSize) == "table" then
                local s = interfaceData.WindowSize
                main.Size = UDim2.new(
                    tonumber(s.XScale) or main.Size.X.Scale,
                    tonumber(s.XOffset) or main.Size.X.Offset,
                    tonumber(s.YScale) or main.Size.Y.Scale,
                    tonumber(s.YOffset) or main.Size.Y.Offset
                )
                size = main.Size
            end
            local loadedWindowScale = interfaceData.WindowScale
            if type(loadedWindowScale) == "number" and mainScale then
                mainScale.Scale = math.clamp(loadedWindowScale, 0.5, 1.5)
            end

            if type(interfaceData.Categories) == "table" then
                for _, category in ipairs(self_.Categories or {}) do
                    if category.Name
                        and interfaceData.Categories[category.Name] ~= nil
                        and category.SetExpanded then
                        category.SetExpanded(interfaceData.Categories[category.Name] == true)
                    end
                end
            end

            if interfaceData.SettingsPage then
                pcall(selectSettingsPage, tostring(interfaceData.SettingsPage))
            end

            if type(interfaceData.ActiveTab) == "table" then
                local wantedName = tostring(interfaceData.ActiveTab.Name or "")
                local wantedOwner = tostring(interfaceData.ActiveTab.OwnerKey or "")

                task.defer(function()
                    local target = nil

                    for _, tab in ipairs(self_.Tabs or {}) do
                        if tab.Name == wantedName
                            and (wantedOwner == "" or tostring(tab.OwnerKey or "") == wantedOwner) then
                            target = tab
                            break
                        end
                    end

                    if not target and wantedOwner ~= "" then
                        for _, category in ipairs(self_.Categories or {}) do
                            for _, item in ipairs(category._items or {}) do
                                if tostring(item._name or "") == wantedOwner
                                    and type(item._open) == "function" then
                                    pcall(item._open)
                                    break
                                end
                            end
                        end

                        for _, tab in ipairs(self_.Tabs or {}) do
                            if tab.Name == wantedName
                                and tostring(tab.OwnerKey or "") == wantedOwner then
                                target = tab
                                break
                            end
                        end
                    end

                    if target and self_._selectTab then
                        self_._selectTab(target)
                    end
                end)
            end
        end

        if data.BaseTheme and themePresets[data.BaseTheme] then
            applyThemePreset(data.BaseTheme, false)
        end

        if type(data.CustomTheme) == "table" and themeColorDefinitions then
            for _, definition in ipairs(themeColorDefinitions) do
                local parsed = parseHex(data.CustomTheme[definition.Key])
                if parsed then setThemeColor(definition.Key, parsed) end
            end
        end

        if type(data.Notifications) == "table" then
            local n = data.Notifications
            if n.Enabled ~= nil then Library.NotificationSettings.Enabled = n.Enabled == true end
            if n.ProgressBar ~= nil then Library.NotificationSettings.ProgressBar = n.ProgressBar == true end
            if n.Position then Library.NotificationSettings.Position = tostring(n.Position) end
            if tonumber(n.Duration) then Library.NotificationSettings.Duration = tonumber(n.Duration) end
            if tonumber(n.MaxVisible) then Library.NotificationSettings.MaxVisible = tonumber(n.MaxVisible) end
            if n.PauseOnHover ~= nil then Library.NotificationSettings.PauseOnHover = n.PauseOnHover == true end

            if self_._notificationEnabledControl then self_._notificationEnabledControl.Set(Library.NotificationSettings.Enabled, false) end
            if self_._notificationProgressControl then self_._notificationProgressControl.Set(Library.NotificationSettings.ProgressBar, false) end
            if self_._notificationPauseControl then self_._notificationPauseControl.Set(Library.NotificationSettings.PauseOnHover, false) end
            if self_._notificationPositionControl then self_._notificationPositionControl.Set(Library.NotificationSettings.Position, false) end
            if self_._notificationDurationControl then self_._notificationDurationControl.Set(tostring(Library.NotificationSettings.Duration) .. "s", false) end
            if self_._notificationMaxControl then self_._notificationMaxControl.Set(tostring(Library.NotificationSettings.MaxVisible), false) end
        end

        if type(data.Flags) == "table" then
            Library:_ApplyFlagValues(data.Flags)
        end

        return true
    end

    local function readAutoloadConfigName()
        if canUseFileAPI() then
            local ok, name = pcall(fsReadFile, autoloadPath)
            if ok and name and name ~= "" then
                return sanitizeConfigName(name)
            end
        end
        return "NONE"
    end


    local function configExists(name)
        name = sanitizeConfigName(name)
        local path = configPathFromName(name)

        if type(fsIsFile) == "function" then
            local ok, exists = pcall(fsIsFile, path)
            return ok and exists == true
        end

        for _, existingName in ipairs(readConfigNames()) do
            if tostring(existingName) == name then
                return true
            end
        end

        return false
    end


    local actionsSection = settingsSection(
        configurationPage,
        "Actions",
        nil
    )

    settingsButton(actionsSection, "Create Config", function()
        if not canUseFileAPI() then
            Library:Notify({ Title = "Configuration", Content = "Saving configs is not supported in this environment.", Type = "Warning" })
            return
        end

        ensureConfigFolders()
        local name = sanitizeConfigName(configNameBox.Text)
        local path = configPathFromName(name)

        if type(fsIsFile) == "function" then
            local okExists, exists = pcall(fsIsFile, path)
            if okExists and exists then
                Library:Notify({
                    Title = "Configuration",
                    Content = "A config with this name already exists.",
                    Type = "Warning",
                })
                return
            end
        end

        local ok, err = writeConfigFile(path, buildConfigPayload())

        if ok then
            addConfigToIndex(name)
            setSelectedConfig(name, true)
            self_:_RefreshConfigDropdown()
        end

        Library:Notify({
            Title = "Configuration",
            Content = ok and ("Created " .. name .. ".") or ("Could not create config: " .. tostring(err)),
            Type = ok and "Success" or "Error",
        })
    end, "primary")

    settingsButton(actionsSection, "Overwrite Config", function()
        if not canUseFileAPI() then
            Library:Notify({ Title = "Configuration", Content = "Saving configs is not supported in this environment.", Type = "Warning" })
            return
        end

        ensureConfigFolders()
        local name = sanitizeConfigName(selectedConfig ~= "" and selectedConfig or configNameBox.Text)
        local payload = buildConfigPayload()
        local ok, err = writeConfigFile(configPathFromName(name), payload)

        if ok then
            addConfigToIndex(name)
            setSelectedConfig(name, true)
            self_:_RefreshConfigDropdown()
        end

        Library:Notify({
            Title = "Configuration",
            Content = ok and ("Updated " .. name .. ".") or ("Could not update config: " .. tostring(err)),
            Type = ok and "Success" or "Error",
        })
    end, "secondary")

    settingsButton(actionsSection, "Load Config", function()
        if not canUseFileAPI() then
            Library:Notify({ Title = "Configuration", Content = "Saving configs is not supported in this environment.", Type = "Warning" })
            return
        end
        local name = sanitizeConfigName(selectedConfig ~= "" and selectedConfig or configNameBox.Text)
        local ok, dataOrError = readConfigFile(configPathFromName(name))

        if ok and applyConfigPayload(dataOrError) then
            setSelectedConfig(name, true)
            self_:_RefreshConfigDropdown()
            Library:Notify({ Title = "Configuration", Content = "Loaded " .. name .. ".", Type = "Success" })
        else
            Library:Notify({
                Title = "Configuration",
                Content = "Could not load config: " .. tostring(dataOrError),
                Type = "Error",
            })
        end
    end, "primary")

    settingsButton(actionsSection, "Set as Autoload", function()
        if not canUseFileAPI() then
            Library:Notify({ Title = "Configuration", Content = "Saving configs is not supported in this environment.", Type = "Warning" })
            return
        end
        ensureConfigFolders()
        local name = sanitizeConfigName(selectedConfig)
        local ok = pcall(function()
            fsWriteFile(autoloadPath, name)
        end)

        if ok and currentAutoloadValue then
            currentAutoloadValue.Text = name
        end

        Library:Notify({
            Title = "Configuration",
            Content = ok and ("Autoload set to " .. name .. ".") or "Could not set autoload.",
            Type = ok and "Success" or "Error",
        })
    end, "secondary")

    -- Import/Export JSON UI intentionally removed. Configs are managed
    -- exclusively through persistent files.

    local manageSection = settingsSection(
        configurationPage,
        "Manage",
        nil
    )



    currentAutoloadValue = settingsValueRow(
        manageSection,
        "Current Autoload",
        "",
        readAutoloadConfigName()
    )

    settingsButton(manageSection, "Delete Autoload", function()
        local ok = false
        if type(fsDeleteFile) == "function" then
            ok = pcall(fsDeleteFile, autoloadPath)
        elseif canUseFileAPI() then
            ok = pcall(function()
                fsWriteFile(autoloadPath, "")
            end)
        end

        if ok and currentAutoloadValue then
            currentAutoloadValue.Text = "NONE"
        end

        Library:Notify({
            Title = "Configuration",
            Content = ok and "Deleted autoload." or "Could not delete autoload.",
            Type = ok and "Info" or "Warning",
        })
    end, "secondary")

    settingsButton(manageSection, "Delete Config", function()
        if type(fsDeleteFile) ~= "function" then
            Library:Notify({ Title = "Configuration", Content = "This config could not be deleted in this environment.", Type = "Warning" })
            return
        end

            local name = sanitizeConfigName(selectedConfig)
            local path = configPathFromName(name)
            local deletedIndex = nil
            for i, configName in ipairs(currentConfigNames) do
                if tostring(configName) == name then
                    deletedIndex = i
                    break
                end
            end

            if type(fsIsFile) == "function" then
                local existsOk, exists = pcall(fsIsFile, path)
                if not existsOk or not exists then
                    self_:_RefreshConfigDropdown()
                    Library:Notify({
                        Title = "Configuration",
                        Content = "Selected config no longer exists.",
                        Type = "Warning",
                    })
                    return
                end
            else
                local found = false
                for _, configName in ipairs(readConfigNames()) do
                    if tostring(configName) == name then
                        found = true
                        break
                    end
                end
                if not found then
                    self_:_RefreshConfigDropdown()
                    Library:Notify({
                        Title = "Configuration",
                        Content = "Selected config no longer exists.",
                        Type = "Warning",
                    })
                    return
                end
            end

            local ok = pcall(function()
                fsDeleteFile(path)
            end)

            if ok then
                removeConfigFromIndex(name)
                currentConfigNames = readConfigNames()
                local nextName = "Default"
                if #currentConfigNames > 0 then
                    local targetIndex = math.clamp(deletedIndex or 1, 1, #currentConfigNames)
                    nextName = currentConfigNames[targetIndex]
                end
                selectedConfig = sanitizeConfigName(nextName)
                self_:_RefreshConfigDropdown()
                setSelectedConfig(selectedConfig, true)

                if currentAutoloadValue and readAutoloadConfigName() == name then
                    if type(fsDeleteFile) == "function" then
                        pcall(fsDeleteFile, autoloadPath)
                    elseif canUseFileAPI() then
                        pcall(function()
                            fsWriteFile(autoloadPath, "")
                        end)
                    end
                    currentAutoloadValue.Text = "NONE"
                end
            end

            Library:Notify({
                Title = "Configuration",
                Content = ok and ("Deleted " .. name .. ".") or "Could not delete config.",
                Type = ok and "Success" or "Error",
            })
    end, "danger")

    self_:_RefreshConfigDropdown()

    ------------------------------------------------------------
    -- CONFIG VALIDATION / TRANSACTIONS
    ------------------------------------------------------------
    function self_:ValidateConfigData(data)
        local errors = {}
        local warnings = {}
        if type(data) ~= "table" then
            table.insert(errors, "Config root must be a table.")
        else
            local schema = tonumber(data.SchemaVersion) or 1
            if schema > (Library.SchemaVersion or 5) then
                table.insert(errors, "This config was created by a newer version and cannot be loaded here.")
            elseif schema < 1 then
                table.insert(errors, "This config is invalid.")
            end
            if data.Flags ~= nil and type(data.Flags) ~= "table" then
                table.insert(errors, "Flags must be a table.")
            end
            if data.Interface ~= nil and type(data.Interface) ~= "table" then
                table.insert(errors, "Interface must be a table.")
            end
            if data.Notifications ~= nil and type(data.Notifications) ~= "table" then
                table.insert(errors, "Notifications must be a table.")
            end
            if data.SchemaVersion == nil then
                table.insert(warnings, "Legacy config detected; compatibility mode will be used.")
            end
        end
        return #errors == 0, { Errors = errors, Warnings = warnings }
    end

    function self_:BeginConfigTransaction(label)
        if self_._configTransaction then
            return false, "A config transaction is already active."
        end
        self_._configTransaction = {
            Label = tostring(label or "Config transaction"),
            StartedAt = os.clock(),
            Snapshot = buildConfigPayload(),
        }
        self_._quality.ConfigTransactions += 1
        self_:Emit("ConfigTransactionStarted", self_._configTransaction.Label)
        return true, self_._configTransaction
    end

    function self_:CommitConfigTransaction()
        local transaction = self_._configTransaction
        if not transaction then return false, "No config transaction is active." end
        self_._configTransaction = nil
        self_:Emit("ConfigTransactionCommitted", transaction.Label, os.clock() - transaction.StartedAt)
        return true
    end

    function self_:RollbackConfigTransaction(reason)
        local transaction = self_._configTransaction
        if not transaction then return false, "No config transaction is active." end
        self_._configTransaction = nil
        local snapshotFlags = type(transaction.Snapshot.Flags) == "table" and transaction.Snapshot.Flags or {}
        for flag in pairs(Library.Flags) do
            if snapshotFlags[flag] == nil then
                Library.Flags[flag] = nil
            end
        end
        local ok, result = pcall(applyConfigPayload, transaction.Snapshot)
        self_._quality.ConfigRollbacks += 1
        self_:Emit("ConfigTransactionRolledBack", transaction.Label, tostring(reason or "rollback"))
        if not ok or result ~= true then
            Library:_RecordDiagnostic("Error", ok and "Rollback could not reapply snapshot." or result, {
                Operation = "ConfigRollback", Label = transaction.Label,
            })
            return false, tostring(result or "Rollback failed.")
        end
        return true
    end

    function self_:WithConfigTransaction(label, callback)
        if type(label) == "function" and callback == nil then
            callback, label = label, "Config transaction"
        end
        if type(callback) ~= "function" then return false, "callback is not a function" end
        local begun, err = self_:BeginConfigTransaction(label)
        if not begun then return false, err end
        local results = table.pack(pcall(callback))
        if results[1] then
            self_:CommitConfigTransaction()
            return true, table.unpack(results, 2, results.n)
        end
        self_:RollbackConfigTransaction(results[2])
        Library:_RecordDiagnostic("Error", tostring(results[2]), { Operation = "ConfigTransaction", Label = tostring(label) })
        return false, tostring(results[2])
    end

    ------------------------------------------------------------
    -- PUBLIC CONFIG API
    ------------------------------------------------------------
    function self_:SaveConfig(name)
        if not canUseFileAPI() then
            return false, "Saving configs is not supported in this environment."
        end

        local configName = sanitizeConfigName(name or selectedConfig or configNameBox.Text)
        local ok, err = writeConfigFile(configPathFromName(configName), buildConfigPayload())

        if ok then
            addConfigToIndex(configName)
            setSelectedConfig(configName, true)
            self_:_RefreshConfigDropdown()
        end

        return ok, err
    end

    function self_:LoadConfig(name)
        if not canUseFileAPI() then
            return false, "Saving configs is not supported in this environment."
        end

        local configName = sanitizeConfigName(name or selectedConfig or configNameBox.Text)
        local ok, dataOrError = readConfigFile(configPathFromName(configName))
        if not ok then
            return false, tostring(dataOrError or "Could not read config.")
        end

        local valid, validation = self_:ValidateConfigData(dataOrError)
        if not valid then
            return false, table.concat(validation.Errors or {}, " ")
        end

        local begun, beginError = self_:BeginConfigTransaction("LoadConfig:" .. configName)
        if not begun then return false, beginError end
        local applyOk, applied = pcall(applyConfigPayload, dataOrError)
        if not applyOk or applied ~= true then
            self_:RollbackConfigTransaction(applyOk and "Could not apply config." or applied)
            return false, tostring(applyOk and "Could not apply config." or applied)
        end

        self_:CommitConfigTransaction()
        setSelectedConfig(configName, true)
        self_:_RefreshConfigDropdown()
        return true, "Loaded " .. configName .. "."
    end

    function self_:DeleteConfig(name)
        if type(fsDeleteFile) ~= "function" then
            return false, "This config could not be deleted in this environment."
        end

        local configName = sanitizeConfigName(name or selectedConfig or configNameBox.Text)
        local path = configPathFromName(configName)

        if type(fsIsFile) == "function" then
            local existsOk, exists = pcall(fsIsFile, path)
            if not existsOk or not exists then
                return false, "Config does not exist."
            end
        end

        local ok, err = pcall(fsDeleteFile, path)
        if not ok then
            return false, tostring(err)
        end

        removeConfigFromIndex(configName)
        currentConfigNames = readConfigNames()

        if selectedConfig == configName then
            setSelectedConfig(currentConfigNames[1] or "Default", true)
        end

        if readAutoloadConfigName() == configName then
            if type(fsDeleteFile) == "function" then
                pcall(fsDeleteFile, autoloadPath)
            elseif canUseFileAPI() then
                pcall(fsWriteFile, autoloadPath, "")
            end
            if currentAutoloadValue then
                currentAutoloadValue.Text = "NONE"
            end
        end

        self_:_RefreshConfigDropdown()
        return true
    end

    function self_:GetConfigs()
        local out = {}
        for i, configName in ipairs(readConfigNames()) do
            out[i] = configName
        end
        return out
    end

    function self_:SetAutoload(name)
        if not canUseFileAPI() then
            return false, "Saving configs is not supported in this environment."
        end

        ensureConfigFolders()

        if name == nil or tostring(name):upper() == "NONE" or tostring(name) == "" then
            local ok = false
            if type(fsDeleteFile) == "function" then
                ok = pcall(fsDeleteFile, autoloadPath)
            else
                ok = pcall(fsWriteFile, autoloadPath, "")
            end

            if ok and currentAutoloadValue then
                currentAutoloadValue.Text = "NONE"
            end

            return ok
        end

        local configName = sanitizeConfigName(name)
        if not configExists(configName) then
            return false, "Config does not exist."
        end

        local ok, err = pcall(fsWriteFile, autoloadPath, configName)
        if ok and currentAutoloadValue then
            currentAutoloadValue.Text = configName
        end

        return ok, err
    end

    function self_:GetAutoload()
        return readAutoloadConfigName()
    end

    function self_:ConfigExists(name)
        return configExists(name)
    end

    function self_:GetConfigData(name)
        local configName = sanitizeConfigName(name or selectedConfig or configNameBox.Text)
        return readConfigFile(configPathFromName(configName))
    end

    function self_:ApplyConfigData(data, transactional)
        local valid, validation = self_:ValidateConfigData(data)
        if not valid then return false, validation end
        data = Library:_RunConfigMigrations(data)
        if transactional == false then
            return applyConfigPayload(data)
        end
        local begun, beginError = self_:BeginConfigTransaction("ApplyConfigData")
        if not begun then return false, beginError end
        local ok, result = pcall(applyConfigPayload, data)
        if not ok or result ~= true then
            self_:RollbackConfigTransaction(ok and "Could not apply config." or result)
            return false, tostring(ok and "Could not apply config." or result)
        end
        self_:CommitConfigTransaction()
        return true
    end

    function self_:SaveFlagsConfig(name, flags)
        local wanted = {}
        if type(flags) == "table" then
            for _, flag in ipairs(flags) do
                wanted[tostring(flag)] = Library:GetFlag(flag)
            end
        end
        local payload = buildConfigPayload()
        payload.Flags = wanted
        local configName = sanitizeConfigName(name or "Partial")
        local ok, err = writeConfigFile(configPathFromName(configName), payload)
        if ok then addConfigToIndex(configName); self_:_RefreshConfigDropdown() end
        return ok, err
    end

    self_.SaveProfile = self_.SaveConfig
    self_.LoadProfile = self_.LoadConfig
    self_.DeleteProfile = self_.DeleteConfig

    -- Apply autoload after the UI and settings controls have been created.
    task.defer(function()
        if not canUseFileAPI() then
            return
        end

        local autoloadName = readAutoloadConfigName()
        if autoloadName == "NONE" or autoloadName == "" then
            return
        end

        local ok, dataOrError = readConfigFile(configPathFromName(autoloadName))
        if ok and applyConfigPayload(dataOrError) then
            setSelectedConfig(autoloadName, true)
            self_:_RefreshConfigDropdown()

            if currentAutoloadValue then
                currentAutoloadValue.Text = autoloadName
            end
        end
    end)
    selectSettingsPage("Interface")

    local function setSettingsOpen(open)
        settingsOpen = open == true

        if settingsOpen then
            fullUIBlurOverlay.Visible = true
            fullUIBlurOverlay.BackgroundTransparency = 1

            -- Make Settings modal: cover only the UI below the title bar with
            -- the exact title-bar color, keep it solid, and block interaction behind it.
            tween(tabBar, { GroupTransparency = 0.58 }, 0.16, Enum.EasingStyle.Quint)
            tween(sidebar, { GroupTransparency = 0.58 }, 0.16, Enum.EasingStyle.Quint)
            tween(pageHolder, { GroupTransparency = 0.58 }, 0.16, Enum.EasingStyle.Quint)
            tween(bottomStatusBar, { GroupTransparency = 0.58 }, 0.16, Enum.EasingStyle.Quint)

            tween(fullUIBlurOverlay, {
                BackgroundTransparency = 0,
            }, 0.16, Enum.EasingStyle.Quint)

            SettingsPanel.Visible = true
            SettingsPanel.GroupTransparency = 1
            SettingsPanel.Position = UDim2.new(0.5, 0, 0.5, 10)

            tween(SettingsPanel, {
                GroupTransparency = 0,
                Position = UDim2.new(0.5, 0, 0.5, 0),
            }, 0.18, Enum.EasingStyle.Quint)

            setIconColor(settingsIcon, Theme.Text, 0.10)
            settingsBtn.BackgroundTransparency = 0.88
        else
            tween(SettingsPanel, {
                GroupTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 10),
            }, 0.14, Enum.EasingStyle.Quint)

            tween(tabBar, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quint)
            tween(sidebar, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quint)
            tween(pageHolder, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quint)
            tween(bottomStatusBar, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quint)

            tween(fullUIBlurOverlay, {
                BackgroundTransparency = 1,
            }, 0.14, Enum.EasingStyle.Quint)

            task.delay(0.15, function()
                if not settingsOpen then
                    SettingsPanel.Visible = false
                    fullUIBlurOverlay.Visible = false
                end
            end)

            setIconColor(settingsIcon, Theme.TextDark, 0.10)
            settingsBtn.BackgroundTransparency = 1
        end
    end

    settingsBtn.MouseButton1Click:Connect(function()
        setSettingsOpen(not settingsOpen)
    end)

    self_:Track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed or isTextInputFocused() then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and minimizeKey and input.KeyCode == minimizeKey then
            if screenGui.Enabled and settingsOpen then
                setSettingsOpen(false)
            end
            screenGui.Enabled = not screenGui.Enabled
        end
    end))

    if Library.InterfaceSettings.SilentLaunch == true then
        task.defer(function()
            if screenGui and screenGui.Parent then
                screenGui.Enabled = false
            end
        end)
    end

    ------------------------------------------------------------
    -- TAB MANAGEMENT
    ------------------------------------------------------------

    -- Highlights the sidebar item for the active tab
    -- (visual feedback for the currently open tab): barra de destaque à
    -- esquerda, fundo levemente tintado, ícone e texto na cor de destaque.
    local function highlightActiveItem(activeName)
        for _, cat in ipairs(self_.Categories) do
            for _, item in ipairs(cat._items) do
                local isActive = false
                if activeName ~= nil then
                    for _, n in ipairs(item._matchNames or {}) do
                        if n == activeName then
                            isActive = true
                            break
                        end
                    end
                end
                -- Keep the row transparent; selected state uses a fade overlay.
                tween(item._row, { BackgroundTransparency = 1 }, 0.12)

                if item._activeFade then
                    if isActive then
                        item._activeFade.Visible = true
                        item._activeFade.BackgroundTransparency = 1
                        tween(item._activeFade, { BackgroundTransparency = 0.76 }, 0.18)
                    else
                        tween(item._activeFade, { BackgroundTransparency = 1 }, 0.14)
                        task.delay(0.15, function()
                            if item._activeFade and item._activeFade.BackgroundTransparency >= 0.99 then
                                item._activeFade.Visible = false
                            end
                        end)
                    end
                end

                tween(item._accentBar, { BackgroundTransparency = isActive and 0 or 1 }, 0.12)
                tween(item._label, { TextColor3 = isActive and Theme.Accent or Theme.Text }, 0.12)
                setIconColor(item._icon, isActive and Theme.Accent or Theme.TextDark, 0.12)
            end
        end
    end

    local function selectTab(tab)
        if not tab or tab.Disabled == true then return end
        if self_._activeTab and self_._activeTab ~= tab then
            table.insert(self_._navigationHistory, self_._activeTab.Name)
            if #self_._navigationHistory > 30 then table.remove(self_._navigationHistory, 1) end
        end
        for _, t in ipairs(self_.Tabs) do
            t.Page.Visible = false
            tween(t._underline, { BackgroundTransparency = 1 }, 0.12)
            tween(t._label, { TextColor3 = Theme.TextTabInactive }, 0.12)
        end
        local activePage = rawget(tab, "Page")
        if activePage then
            activePage.Visible = true
            activePage.Position = UDim2.new(0, 5, 0, 0)
            tween(activePage, { Position = UDim2.new(0, 0, 0, 0) }, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
        tween(tab._underline, { BackgroundTransparency = 0 }, 0.12)
        tween(tab._label, { TextColor3 = Theme.Text }, 0.12)
        self_._activeTab = tab
        highlightActiveItem(tab.Name)
    end
    self_._selectTab = selectTab

    -- A tab mais à esquerda (menor _order, ou seja, a que vem primeiro na
    -- sidebar) nunca mostra o divisor antes dela; todas as outras mostram.
    -- Chamado sempre que uma tab é aberta ou fechada, já que a ordem
    -- exibida segue a sidebar e não a ordem de clique.
    local function refreshDividers()
        local minOrder = math.huge
        local visibleCount = 0

        for _, t in ipairs(self_.Tabs) do
            local visible = t._btn and t._btn.Visible == true
            if visible then
                visibleCount += 1
                if t._order and t._order < minOrder then
                    minOrder = t._order
                end
            end
        end

        for _, t in ipairs(self_.Tabs) do
            if t._dividerBefore then
                local visible = t._btn and t._btn.Visible == true
                t._dividerBefore.Visible = visible
                    and visibleCount > 1
                    and t._order ~= minOrder
            end
        end
    end
    self_._refreshDividers = refreshDividers

    local function closeTab(tab)
        local idx
        for i, t in ipairs(self_.Tabs) do
            if t == tab then
                idx = i
                break
            end
        end
        if not idx then return end
        table.remove(self_.Tabs, idx)

        for _, connection in ipairs(tab._keybindConnections or {}) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        tab._keybindConnections = {}

        tab._btn:Destroy()
        local closingPage = rawget(tab, "Page")
        if closingPage then
            closingPage:Destroy()
            rawset(tab, "Page", nil)
        end
        if tab._dividerBefore then tab._dividerBefore:Destroy() end
        refreshDividers()
        if self_._activeTab == tab then
            self_._activeTab = nil
            local nextTab = self_.Tabs[idx] or self_.Tabs[idx - 1]
            if nextTab then
                selectTab(nextTab)
            else
                highlightActiveItem(nil)
                self_._activeCategory = nil
            end
        end
    end
    self_._closeTab = closeTab

    ------------------------------------------------------------
    -- PUBLIC WINDOW / TAB API
    ------------------------------------------------------------
    function self_:SetAnimationsEnabled(enabled)
        Library:SetAnimationsEnabled(enabled)
        return self_
    end

    function self_:SetAnimationSpeed(multiplier)
        Library:SetAnimationSpeed(multiplier)
        return self_
    end

    function self_:SetReducedMotion(enabled)
        Library:SetReducedMotion(enabled)
        return self_
    end

    function self_:SetVisible(visible)
        screenGui.Enabled = visible ~= false
        return self_
    end

    function self_:IsVisible()
        return screenGui.Enabled == true
    end

    function self_:Minimize()
        screenGui.Enabled = false
        return self_
    end

    function self_:Restore()
        screenGui.Enabled = true
        return self_
    end

    function self_:Toggle()
        screenGui.Enabled = not screenGui.Enabled
        return screenGui.Enabled
    end

    function self_:SetTitle(newTitle)
        title = tostring(newTitle or "")
        self_._title = title
        titleLabel.Text = title
        return self_
    end

    function self_:GetTitle()
        return title
    end


    function self_:SetLocale(name)
        return Library:SetLocale(name)
    end

    function self_:Translate(key, fallback)
        return Library:T(key, fallback)
    end

    function self_:SetSize(newSize, animated)
        if typeof(newSize) ~= "UDim2" then
            return false
        end

        size = newSize
        if animated == true then
            smoothTween(main, { Size = newSize }, 0.18)
        else
            main.Size = newSize
        end
        return true
    end

    function self_:SetPosition(newPosition, animated)
        if typeof(newPosition) ~= "UDim2" then
            return false
        end

        if animated == true then
            smoothTween(main, { Position = newPosition }, 0.18)
        else
            main.Position = newPosition
        end
        return true
    end

    function self_:Center(animated)
        local absolute = main.AbsoluteSize
        local width = absolute.X > 0 and absolute.X or main.Size.X.Offset
        local height = absolute.Y > 0 and absolute.Y or main.Size.Y.Offset
        local target = UDim2.new(0.5, -math.floor(width / 2), 0.5, -math.floor(height / 2))
        return self_:SetPosition(target, animated)
    end

    function self_:SelectTab(name)
        name = tostring(name or "")
        if name == "" then return nil end

        for _, tab in ipairs(self_.Tabs) do
            if tab.Name == name then
                if tab.Category then
                    self_:_EnforceSingleSidebarItem(
                        tab.Category,
                        tab.OwnerKey
                    )
                end
                selectTab(tab)
                return tab
            end
        end

        -- If the tab has not been created yet, try to open it from the sidebar.
        for _, category in ipairs(self_.Categories) do
            for _, item in ipairs(category._items or {}) do
                for _, matchName in ipairs(item._matchNames or {}) do
                    if tostring(matchName) == name and type(item._open) == "function" then
                        item._open()
                        for _, tab in ipairs(self_.Tabs) do
                            if tab.Name == name then
                                selectTab(tab)
                                return tab
                            end
                        end
                    end
                end
            end
        end

        return nil
    end

    function self_:CloseTab(name)
        name = tostring(name or "")
        for _, tab in ipairs(self_.Tabs) do
            if tab.Name == name then
                if tab.Pinned then return false end
                closeTab(tab)
                return true
            end
        end
        return false
    end

    function self_:GetActiveTab()
        return self_._activeTab
    end

    function self_:GetTabs()
        local out = {}
        for i, tab in ipairs(self_.Tabs or {}) do out[i] = tab end
        return out
    end

    function self_:NextTab()
        if #self_.Tabs == 0 then return nil end
        local currentIndex = table.find(self_.Tabs, self_._activeTab) or 0
        for offset = 1, #self_.Tabs do
            local index = ((currentIndex + offset - 1) % #self_.Tabs) + 1
            local tab = self_.Tabs[index]
            if tab._btn.Visible and tab.Disabled ~= true then selectTab(tab); return tab end
        end
        return nil
    end

    function self_:PreviousTab()
        if #self_.Tabs == 0 then return nil end
        local currentIndex = table.find(self_.Tabs, self_._activeTab) or 1
        for offset = 1, #self_.Tabs do
            local index = ((currentIndex - offset - 1) % #self_.Tabs) + 1
            local tab = self_.Tabs[index]
            if tab._btn.Visible and tab.Disabled ~= true then selectTab(tab); return tab end
        end
        return nil
    end

    function self_:NavigateBack()
        local name = table.remove(self_._navigationHistory)
        if not name then return nil end
        return self_:SelectTab(name)
    end

    function self_:BindDependency(source, targets, predicate, mode)
        local dependency = {
            Source = source,
            Targets = type(targets) == "table" and targets or { targets },
            Predicate = type(predicate) == "function" and predicate or function(value)
                return value == true
            end,
            Mode = tostring(mode or "Disabled"),
        }

        -- A single component API is also a table, so distinguish it from
        -- an array of target components.
        if type(targets) == "table"
            and (targets.SetVisible or targets.SetDisabled or targets.Container or targets.Instance or targets.Get) then
            dependency.Targets = { targets }
        end

        local lastState = nil
        local connection = nil
        local fallbackConnection = nil

        local function readSource()
            if type(source) == "function" then
                local ok, value = pcall(source)
                return ok and value or nil
            end

            if type(source) == "string" then
                return Library:GetFlag(source)
            end

            if type(source) == "table" and type(source.Get) == "function" then
                local ok, value = pcall(source.Get)
                return ok and value or nil
            end

            return source
        end

        local function applyTarget(target, enabled)
            if target == nil then return end

            local dependencyMode = string.lower(dependency.Mode)

            if dependencyMode == "visible" or dependencyMode == "visibility" then
                if type(target) == "table" and type(target.SetVisible) == "function" then
                    target:SetVisible(enabled)
                elseif typeof(target) == "Instance" and target:IsA("GuiObject") then
                    target.Visible = enabled
                elseif type(target) == "table" and target.Container and target.Container:IsA("GuiObject") then
                    target.Container.Visible = enabled
                end
                return
            end

            -- Default mode: keep the control visible and disable it when the
            -- dependency is false.
            if type(target) == "table" and type(target.SetDisabled) == "function" then
                target:SetDisabled(not enabled)
            elseif type(target) == "table" and target.Container and target.Container:IsA("GuiObject") then
                target.Container.Active = enabled
                target.Container:SetAttribute("DependencyDisabled", not enabled)
            elseif typeof(target) == "Instance" and target:IsA("GuiObject") then
                target.Active = enabled
                target:SetAttribute("DependencyDisabled", not enabled)
            end
        end

        function dependency:Refresh()
            local value = readSource()
            local ok, enabled = pcall(dependency.Predicate, value)
            enabled = ok and enabled == true

            if lastState == enabled then
                return enabled
            end

            lastState = enabled
            for _, target in ipairs(dependency.Targets) do
                applyTarget(target, enabled)
            end

            return enabled
        end

        function dependency:Destroy()
            if connection then
                connection:Disconnect()
                connection = nil
            end

            if fallbackConnection then
                fallbackConnection:Disconnect()
                fallbackConnection = nil
            end
        end

        if type(source) == "string" then
            connection = Library:ObserveFlag(
                source,
                function()
                    dependency:Refresh()
                end
            )
        elseif type(source) == "table" and type(source.OnChanged) == "function" then
            connection = source:OnChanged(function()
                dependency:Refresh()
            end)
        elseif type(source) == "table" and type(source.On) == "function" then
            connection = source:On("Changed", function()
                dependency:Refresh()
            end)
        elseif type(source) == "function" then
            -- Function predicates have no event source. Use a low-frequency
            -- compatibility fallback only for this case.
            local accumulator = 0
            fallbackConnection = RunService.Heartbeat:Connect(function(dt)
                accumulator += dt
                if accumulator >= 0.25 then
                    accumulator = 0
                    dependency:Refresh()
                end
            end)
        end

        if connection then
            self_:Track(connection)
        end

        if fallbackConnection then
            self_:Track(fallbackConnection)
        end

        dependency:Refresh()
        return dependency
    end

    ------------------------------------------------------------
    -- FRAMEWORK REGISTRY / EVENTS / HISTORY
    ------------------------------------------------------------
    function self_:Connect(signalObject, callback)
        if not signalObject or type(signalObject.Connect) ~= "function" then return nil end
        return self_:Track(signalObject:Connect(function(...)
            Library:SafeCall(callback, ...)
        end))
    end

    function self_:On(eventName, callback)
        eventName = tostring(eventName or "")
        if eventName == "" then return nil end
        self_._events[eventName] = self_._events[eventName] or Signal.new()
        return self_._events[eventName]:Connect(callback)
    end

    function self_:Emit(eventName, ...)
        local signalObject = self_._events[tostring(eventName or "")]
        if signalObject then signalObject:Fire(...) end
    end

    function self_:_RegisterComponent(component, meta)
        if type(component) ~= "table" then return component end
        if not table.find(self_._components, component) then
            table.insert(self_._components, component)
        end
        self_._componentMeta[component] = meta or self_._componentMeta[component] or {}
        local componentMeta = self_._componentMeta[component]
        componentMeta.Id = componentMeta.Id
        component.Metadata = componentMeta
        component.Changed = component.Changed or Signal.new()
        Library:_EnsureComponentAPI(
            component,
            component.Container or component.Instance
        )
        if component._mistDefault == nil and component.Default ~= nil then
            component._mistDefault = componentValueCopy(component.Default)
        end

        if component._mistDestroyWrapped ~= true then
            component._mistDestroyWrapped = true
            local originalDestroy = component.Destroy
            component.Destroy = function(target)
                target = target == component and target or component
                if target._mistDestroyed == true then return true end
                target._mistDestroyed = true

                local flag = Library:_NormalizeFlag(target.Flag)
                if flag and Library.ComponentsByFlag[flag] == target then
                    Library.ComponentsByFlag[flag] = nil
                    local flagSignal = Library._flagSignals and Library._flagSignals[flag]
                    if flagSignal and type(flagSignal.Destroy) == "function" then
                        pcall(function() flagSignal:Destroy() end)
                    end
                    if Library._flagSignals then Library._flagSignals[flag] = nil end
                end

                if type(target.DestroyEvents) == "function" then
                    pcall(function() target:DestroyEvents() end)
                end
                if target.Changed and type(target.Changed.Destroy) == "function" then
                    pcall(function() target.Changed:Destroy() end)
                end

                for i = #self_._components, 1, -1 do
                    if self_._components[i] == target then table.remove(self_._components, i) end
                end
                self_._componentMeta[target] = nil
                for _, cardApi in ipairs(self_._cards or {}) do
                    if type(cardApi) == "table" and type(cardApi.Components) == "table" then
                        for i = #cardApi.Components, 1, -1 do
                            if cardApi.Components[i] == target then table.remove(cardApi.Components, i) end
                        end
                    end
                end

                if type(originalDestroy) == "function" then
                    local ok, err = pcall(originalDestroy, target)
                    if not ok then
                        Library:_RecordDiagnostic("Error", tostring(err), { Operation = "ComponentDestroy", Flag = flag, Name = componentMeta.Name })
                        return false, err
                    end
                else
                    local instance = target.Container or target.Instance
                    if typeof(instance) == "Instance" and instance.Parent then instance:Destroy() end
                end
                return true
            end
        end
        return component
    end

    function self_:GetComponent(flagOrName)
        local key = tostring(flagOrName or "")
        if key == "" then return nil end
        if Library.ComponentsByFlag[key] then return Library.ComponentsByFlag[key] end
        for _, component in ipairs(self_._components) do
            local meta = self_._componentMeta[component] or {}
            if tostring(meta.Name or "") == key or tostring(component.Flag or "") == key then
                return component
            end
        end
        return nil
    end

    function self_:FindComponent(query)
        query = string.lower(tostring(query or ""))
        if query == "" then return nil end
        for _, component in ipairs(self_._components) do
            local meta = self_._componentMeta[component] or {}
            local haystack = string.lower(table.concat({
                tostring(meta.Name or ""),
                tostring(meta.Type or ""),
                tostring(meta.Card or ""),
                tostring(meta.Page or ""),
                tostring(component.Flag or ""),
            }, " "))
            if string.find(haystack, query, 1, true) then
                return component, meta
            end
        end
        return nil
    end

    function self_:GetComponents()
        local copy = {}
        for i, component in ipairs(self_._components) do copy[i] = component end
        return copy
    end

    function self_:GetCards()
        local copy = {}
        for i, cardApi in ipairs(self_._cards) do copy[i] = cardApi end
        return copy
    end

    function self_:GetCategories()
        local copy = {}
        for i, category in ipairs(self_.Categories or {}) do copy[i] = category end
        return copy
    end

    local function fuzzyScore(value, query)
        value = string.lower(tostring(value or ""))
        query = string.lower(tostring(query or ""))

        if query == "" or value == "" then
            return nil
        end

        if value == query then
            return 10000
        end

        if value:sub(1, #query) == query then
            return 8000 - (#value - #query)
        end

        local substringStart = string.find(value, query, 1, true)
        if substringStart then
            return 6000 - substringStart * 4 - (#value - #query)
        end

        local score = 0
        local cursor = 1
        local streak = 0

        for i = 1, #query do
            local character = query:sub(i, i)
            local found = string.find(value, character, cursor, true)

            if not found then
                return nil
            end

            if found == cursor then
                streak += 1
                score += 40 + streak * 8
            else
                streak = 0
                score += 12
            end

            score -= math.max(0, found - cursor)
            cursor = found + 1
        end

        return 3000 + score - #value
    end

    function self_:Search(query)
        query = string.lower(tostring(query or ""))
        local results = {}
        if query == "" then return results end

        local function addResult(resultType, name, value, extraLabels, extra)
            name = tostring(name or "")
            if name == "" then return end

            local bestScore = fuzzyScore(name, query)

            for _, label in ipairs(extraLabels or {}) do
                local score = fuzzyScore(label, query)
                if score and (not bestScore or score > bestScore) then
                    bestScore = score - 100
                end
            end

            if not bestScore then
                return
            end

            local result = {
                Type = resultType,
                Name = name,
                Value = value,
                Score = bestScore,
            }

            for key, extraValue in pairs(extra or {}) do
                result[key] = extraValue
            end

            table.insert(results, result)
        end

        for _, category in ipairs(self_.Categories or {}) do
            addResult("Category", category.Name, category)

            for _, item in ipairs(category._items or {}) do
                addResult(
                    "Sidebar",
                    item._name,
                    item,
                    { category.Name }
                )
            end
        end

        for _, tab in ipairs(self_.Tabs or {}) do
            addResult(
                "Tab",
                tab.Name,
                tab,
                {
                    tab.Category and tab.Category.Name or "",
                }
            )
        end

        for _, component in ipairs(self_._components) do
            local meta = self_._componentMeta[component] or {}
            local publicName = tostring(meta.Name or "")
            local rawFlag = tostring(component.Flag or "")

            local looksInternal =
                publicName == ""
                or publicName == rawFlag
                or string.sub(publicName, 1, 8) == "Control."
                or string.sub(publicName, 1, 7) == "UITest."

            if not looksInternal then
                addResult(
                    "Component",
                    publicName,
                    component,
                    {
                        meta.Card,
                        meta.Page,
                        meta.Type,
                    },
                    {
                        Page = tostring(meta.Page or ""),
                    }
                )
            end
        end

        table.sort(results, function(a, b)
            if a.Score == b.Score then
                return tostring(a.Name) < tostring(b.Name)
            end
            return a.Score > b.Score
        end)

        return results
    end

    function self_:SearchSidebar(query)
        query = string.lower(tostring(query or ""))
        for _, category in ipairs(self_.Categories or {}) do
            local categoryMatch = query == ""
                or fuzzyScore(category.Name, query) ~= nil
            local anyItem = false
            for _, item in ipairs(category._items or {}) do
                local match = categoryMatch
                    or query == ""
                    or fuzzyScore(item._name, query) ~= nil
                item._row.Visible = match
                anyItem = anyItem or match
            end
            category._row.Visible = categoryMatch or anyItem
            category._itemsHolder.Visible = (categoryMatch or anyItem) and category._expanded
        end
        return self_
    end

    function self_:Snapshot(label)
        local snapshot = {
            Label = tostring(label or "Snapshot"),
            Flags = Library:GetFlags(),
            Time = os.clock(),
        }
        table.insert(self_._history, snapshot)
        if #self_._history > 50 then table.remove(self_._history, 1) end
        table.clear(self_._redoHistory)
        return snapshot
    end

    function self_:Undo()
        local snapshot = table.remove(self_._history)
        if not snapshot then
            return false, "Nothing to undo."
        end

        table.insert(self_._redoHistory, {
            Flags = Library:GetFlags(),
            Label = snapshot.Label or "Redo",
        })

        local ok = pcall(function()
            Library:_ApplyFlagValues(snapshot.Flags or {})
        end)

        if not ok then
            return false, "Could not restore the snapshot."
        end

        self_:Emit("Undo", snapshot)
        return true, snapshot.Label or "Snapshot restored."
    end

    function self_:Redo()
        local snapshot = table.remove(self_._redoHistory)
        if not snapshot then
            return false, "Nothing to redo."
        end

        table.insert(self_._history, {
            Flags = Library:GetFlags(),
            Label = snapshot.Label or "Undo",
        })

        local ok = pcall(function()
            Library:_ApplyFlagValues(snapshot.Flags or {})
        end)

        if not ok then
            return false, "Could not reapply the snapshot."
        end

        self_:Emit("Redo", snapshot)
        return true, snapshot.Label or "Snapshot reapplied."
    end

    function self_:ResetFlags()
        local resetCount = 0
        local failedCount = 0

        for _, component in ipairs(self_._components) do
            if type(component.Reset) == "function" then
                local ok = pcall(function()
                    component:Reset()
                end)

                if ok then
                    resetCount += 1
                else
                    failedCount += 1
                end
            end
        end

        if failedCount > 0 then
            return false, string.format(
                "Reset %d components; %d failed.",
                resetCount,
                failedCount
            )
        end

        return true, string.format("Reset %d components.", resetCount)
    end

    ------------------------------------------------------------
    -- KEYBIND MANAGER
    ------------------------------------------------------------
    function self_:RegisterKeybind(name, key, callback, owner, id, modifiers)
        name = tostring(name or "Keybind")

        local context = self_._keybindRegisterContext
        local stableId = id

        if stableId == nil or tostring(stableId) == "" then
            if owner ~= nil and tostring(owner) ~= "" then
                stableId = "owner:" .. tostring(owner) .. "::" .. name
            elseif context ~= nil and tostring(context) ~= "" then
                stableId = tostring(context) .. "::" .. name
            else
                stableId = "global::" .. name
            end
        end

        for _, existing in ipairs(self_._keybinds) do
            if existing.Id == stableId then
                existing.Name = name
                existing.Callback = callback or existing.Callback
                existing.Owner = owner or existing.Owner
                existing.Enabled = true
                if type(modifiers) == "table" then existing.Modifiers = modifiers end

                if existing.Key == nil or existing.Key == Enum.KeyCode.Unknown then
                    existing.Key = key or Enum.KeyCode.Unknown
                end

                if type(self_.RefreshKeybindMenu) == "function" then
                    self_:RefreshKeybindMenu()
                end

                return existing
            end
        end

        local entry = {
            Id = stableId,
            Name = name,
            Key = key or Enum.KeyCode.Unknown,
            Callback = callback,
            Owner = owner,
            Enabled = true,
            Active = false,
            Mode = nil,
            Modifiers = type(modifiers) == "table" and modifiers or {},
        }

        function entry:SetKey(newKey)
            self.Key = newKey or Enum.KeyCode.Unknown

            if type(self_.RefreshKeybindMenu) == "function" then
                self_:RefreshKeybindMenu()
            end

            return self
        end

        function entry:SetModifiers(newModifiers)
            self.Modifiers = type(newModifiers) == "table" and newModifiers or {}
            if type(self_.RefreshKeybindMenu) == "function" then self_:RefreshKeybindMenu() end
            return self
        end

        function entry:SetActive(active)
            local nextActive = active == true
            if self.Active == nextActive then return self end
            self.Active = nextActive
            if type(self_.RefreshKeybindMenu) == "function" then self_:RefreshKeybindMenu() end
            return self
        end

        function entry:SetMode(mode)
            local nextMode = mode ~= nil and tostring(mode) or nil
            if self.Mode == nextMode then return self end
            self.Mode = nextMode
            if type(self_.RefreshKeybindMenu) == "function" then self_:RefreshKeybindMenu() end
            return self
        end

        table.insert(self_._keybinds, entry)

        if type(self_.RefreshKeybindMenu) == "function" then
            self_:RefreshKeybindMenu()
        end

        return entry
    end

    function self_:GetKeybinds()
        local out = {}
        for i, entry in ipairs(self_._keybinds) do out[i] = entry end
        return out
    end

    function self_:RegisterKeybindDefinition(definition, owner)
        if type(definition) ~= "table" then
            return nil
        end

        local name = definition.Name
            or definition.Text
            or definition.Label
            or definition.Id
            or definition.Flag
            or "Keybind"
        local id = definition.Id or definition.Flag
        local key = definition.Default
            or definition.Key
            or definition.DefaultKey
            or Enum.KeyCode.Unknown

        if type(key) == "string" then
            key = Enum.KeyCode[key] or Enum.UserInputType[key] or Enum.KeyCode.Unknown
        end

        local modifiers = {}
        for _, modifier in ipairs(definition.DefaultModifiers or definition.Modifiers or {}) do
            if typeof(modifier) == "EnumItem" then
                table.insert(modifiers, modifier)
            elseif type(modifier) == "string" and Enum.KeyCode[modifier] then
                table.insert(modifiers, Enum.KeyCode[modifier])
            end
        end

        return self_:RegisterKeybind(
            name,
            key,
            definition.Callback,
            owner or definition.Owner,
            id,
            modifiers
        )
    end

    function self_:RegisterKeybindDefinitions(definitions, owner)
        local registered = {}
        for _, definition in ipairs(definitions or {}) do
            local entry = self_:RegisterKeybindDefinition(definition, owner)
            if entry then
                table.insert(registered, entry)
            end
        end
        return registered
    end


    function self_:_TrackKeybindConnection(connection)
        if not connection then
            return connection
        end

        local tab = self_._buildingTab
        if tab then
            tab._keybindConnections = tab._keybindConnections or {}
            table.insert(tab._keybindConnections, connection)
        end

        return connection
    end

    function self_:ClearKeybind(name)
        name = tostring(name or "")
        for i = #self_._keybinds, 1, -1 do
            if self_._keybinds[i].Name == name then
                table.remove(self_._keybinds, i)

                if type(self_.RefreshKeybindMenu) == "function" then
                    self_:RefreshKeybindMenu()
                end

                return true
            end
        end
        return false
    end

    function self_:GetKeybindConflicts(key)
        local out = {}
        for _, entry in ipairs(self_._keybinds) do
            if entry.Enabled ~= false and entry.Key == key then
                table.insert(out, entry)
            end
        end
        return out
    end


    function self_:GetAllKeybindConflicts()
        local byKey = {}
        for _, entry in ipairs(self_._keybinds) do
            if entry.Enabled ~= false and entry.Key and entry.Key ~= Enum.KeyCode.Unknown then
                byKey[entry.Key] = byKey[entry.Key] or {}
                table.insert(byKey[entry.Key], entry)
            end
        end
        local conflicts = {}
        for key, entries in pairs(byKey) do
            if #entries > 1 then conflicts[key] = entries end
        end
        return conflicts
    end

    function self_:ClearAllKeybinds()
        for _, entry in ipairs(self_._keybinds) do
            entry.Key = Enum.KeyCode.Unknown
        end

        if type(self_.RefreshKeybindMenu) == "function" then
            self_:RefreshKeybindMenu()
        end

        return self_
    end

    ------------------------------------------------------------
    -- ADVANCED DEPENDENCIES
    ------------------------------------------------------------
    function self_:BindConditions(conditions, targets, mode, logic)
        conditions = conditions or {}
        logic = string.upper(tostring(logic or "AND"))
        local function predicate()
            local matched = logic == "AND"
            for _, condition in ipairs(conditions) do
                local source = condition.Source or condition.Flag or condition[1]
                local expected = condition.Value
                local invert = condition.Invert == true
                local value
                if type(source) == "string" then
                    value = Library:GetFlag(source)
                elseif type(source) == "table" and type(source.Get) == "function" then
                    local ok, result = pcall(source.Get)
                    value = ok and result or nil
                elseif type(source) == "function" then
                    local ok, result = pcall(source)
                    value = ok and result or nil
                else
                    value = source
                end
                local current = expected == nil and value == true or value == expected
                if invert then current = not current end
                if logic == "OR" then
                    matched = matched or current
                else
                    matched = matched and current
                end
            end
            return matched
        end
        return self_:BindDependency(predicate, targets, function(v) return v == true end, mode)
    end

    function self_:ShowWhen(source, targets, predicate)
        return self_:BindDependency(source, targets, predicate, "Visible")
    end

    function self_:DisableWhen(source, targets, predicate)
        return self_:BindDependency(source, targets, function(value)
            local result = type(predicate) == "function" and predicate(value) or value == true
            return not result
        end, "Disabled")
    end

    ------------------------------------------------------------
    -- WINDOW SIZE / SCALE / RESPONSIVE / SNAP
    ------------------------------------------------------------
    mainScale = create("UIScale", { Scale = 1, Parent = main })
    self_._mainScale = mainScale

    -- Manual window resizing intentionally disabled.
    -- Keep the compatibility methods as no-ops so older hubs do not crash,
    -- but there is no resize grip and CreateWindow({Resizable=true}) is ignored.
    self_._resizeHandle = nil
    self_._resizeLocked = true

    function self_:SetResizable(_enabled)
        self_._resizeLocked = true
        return self_
    end

    function self_:IsResizable()
        return false
    end

    function self_:SetScale(scale)
        mainScale.Scale = math.clamp(tonumber(scale) or 1, 0.5, 1.5)
        return self_
    end

    function self_:GetScale()
        return mainScale.Scale
    end

    function self_:SetMinMaxSize(minSize, maxSize)
        if typeof(minSize) == "Vector2" then self_._minSize = minSize end
        if typeof(maxSize) == "Vector2" then self_._maxSize = maxSize end
        return self_
    end

    function self_:LockDrag(locked)
        main:SetAttribute("DragLocked", locked == true)
        return self_
    end

    function self_:LockResize(_locked)
        self_._resizeLocked = true
        return self_
    end

    function self_:Maximize()
        if self_._maximized then return self_ end
        self_._restoreSize = main.Size
        self_._restorePosition = main.Position
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        main.Position = UDim2.new(0, 12, 0, 12)
        main.Size = UDim2.new(0, math.max(self_._minSize.X, viewport.X - 24), 0, math.max(self_._minSize.Y, viewport.Y - 24))
        self_._maximized = true
        self_:Emit("Maximized")
        return self_
    end

    function self_:RestoreWindow()
        if self_._maximized then
            if self_._restoreSize then main.Size = self_._restoreSize end
            if self_._restorePosition then main.Position = self_._restorePosition end
            self_._maximized = false
            self_:Emit("RestoredWindow")
        end
        return self_
    end

    function self_:ToggleMaximize()
        if self_._maximized then return self_:RestoreWindow() end
        return self_:Maximize()
    end

    function self_:SnapToEdge(edge, margin)
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local absolute = main.AbsoluteSize
        margin = tonumber(margin) or 8
        edge = string.lower(tostring(edge or "nearest"))

        if edge == "nearest" then
            local center = main.AbsolutePosition + absolute / 2
            local distances = {
                left = center.X,
                right = viewport.X - center.X,
                top = center.Y,
                bottom = viewport.Y - center.Y,
            }
            local best, bestValue = "left", math.huge
            for name, value in pairs(distances) do
                if value < bestValue then best, bestValue = name, value end
            end
            edge = best
        end

        local x = main.Position.X.Offset
        local y = main.Position.Y.Offset
        if edge == "left" then
            main.Position = UDim2.new(0, margin, main.Position.Y.Scale, y)
        elseif edge == "right" then
            main.Position = UDim2.new(0, viewport.X - absolute.X - margin, main.Position.Y.Scale, y)
        elseif edge == "top" then
            main.Position = UDim2.new(main.Position.X.Scale, x, 0, margin)
        elseif edge == "bottom" then
            main.Position = UDim2.new(main.Position.X.Scale, x, 0, viewport.Y - absolute.Y - margin)
        end
        return self_
    end

    function self_:EnableSnap(enabled)
        self_._snapEnabled = enabled ~= false
        return self_
    end

    self_:Track(UserInputService.InputEnded:Connect(function(input)
        if self_._snapEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
            local pos = main.AbsolutePosition
            local abs = main.AbsoluteSize
            local threshold = 24
            if pos.X <= threshold then self_:SnapToEdge("left")
            elseif viewport.X - (pos.X + abs.X) <= threshold then self_:SnapToEdge("right")
            elseif pos.Y <= threshold then self_:SnapToEdge("top")
            elseif viewport.Y - (pos.Y + abs.Y) <= threshold then self_:SnapToEdge("bottom") end
        end
    end))

    function self_:SetTransparency(alpha)
        alpha = math.clamp(tonumber(alpha) or 0, 0, 0.85)
        body.GroupTransparency = alpha
        return self_
    end

    function self_:_ApplyBreakpointLayout(breakpoint)
        local sidebarWidth
        if breakpoint == "Compact" then
            sidebarWidth = 220
        elseif breakpoint == "Medium" then
            sidebarWidth = 280
        else
            sidebarWidth = SIDEBAR_W
        end

        sidebar.Size = UDim2.new(0, sidebarWidth, 1, -TITLEBAR_H - 28)
        contentWrap.Position = UDim2.new(0, sidebarWidth, 0, TITLEBAR_H)
        contentWrap.Size = UDim2.new(1, -sidebarWidth, 1, -TITLEBAR_H - 28)

        titleLabel.TextSize = breakpoint == "Compact" and 16 or 18

        if self_._keybindMenu then
            self_._keybindMenu.Visible = breakpoint ~= "Compact"
                and self_:GetKeybindMenuOpen()
                or false
        end

        for _, cardApi in ipairs(self_._cards or {}) do
            if type(cardApi.ApplyBreakpoint) == "function" then
                cardApi:ApplyBreakpoint(breakpoint)
            end
        end
    end

    function self_:EnableResponsive(enabled)
        self_._responsiveEnabled = enabled ~= false

        local function refreshScale()
            if not self_._responsiveEnabled then return end

            local camera = workspace.CurrentCamera
            local viewport = camera
                and camera.ViewportSize
                or Vector2.new(1280, 720)

            local breakpoint
            if viewport.X < 760 then
                breakpoint = "Compact"
            elseif viewport.X < 1050 then
                breakpoint = "Medium"
            else
                breakpoint = "Large"
            end

            if self_._breakpoint ~= breakpoint then
                local previous = self_._breakpoint
                self_._breakpoint = breakpoint
                self_:_ApplyBreakpointLayout(breakpoint)
                self_:Emit("BreakpointChanged", breakpoint, previous)
            end

            local margin = breakpoint == "Compact" and 16 or 30
            local target = math.min(
                1,
                (viewport.X - margin) / math.max(self_._baseSize.X, 1),
                (viewport.Y - margin) / math.max(self_._baseSize.Y, 1)
            )

            local minimumScale = breakpoint == "Compact" and 0.66 or 0.72
            mainScale.Scale = math.clamp(target, minimumScale, 1)
        end

        local function bindCamera()
            if self_._responsiveConnection then
                self_._responsiveConnection:Disconnect()
                self_._responsiveConnection = nil
            end

            local camera = workspace.CurrentCamera
            if camera then
                self_._responsiveConnection =
                    camera:GetPropertyChangedSignal("ViewportSize"):Connect(
                        refreshScale
                    )
                self_:Track(self_._responsiveConnection)
            end

            refreshScale()
        end

        if not self_._responsiveCameraConnection then
            self_._responsiveCameraConnection =
                workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(
                    bindCamera
                )
            self_:Track(self_._responsiveCameraConnection)
        end

        if self_._responsiveEnabled then
            bindCamera()
        elseif self_._responsiveConnection then
            self_._responsiveConnection:Disconnect()
            self_._responsiveConnection = nil
            mainScale.Scale = 1
        end

        return self_
    end

    function self_:GetBreakpoint()
        return self_._breakpoint or "Large"
    end

    ------------------------------------------------------------
    -- KEYBOARD / GAMEPAD NAVIGATION
    ------------------------------------------------------------
    function self_:SetKeyboardNavigationEnabled(enabled)
        self_._keyboardNavigation = enabled ~= false
        return self_
    end

    function self_:SetGamepadNavigationEnabled(enabled)
        self_._gamepadNavigation = enabled ~= false
        pcall(function() GuiService.AutoSelectGuiEnabled = self_._gamepadNavigation end)
        return self_
    end

    function self_:_GetFocusableComponents()
        local result = {}
        for _, instance in ipairs(screenGui:GetDescendants()) do
            if instance:IsA("GuiObject")
                and instance.Selectable == true
                and self_:_IsActuallyVisible(instance)
                and instance:GetAttribute("Disabled") ~= true
                and instance:GetAttribute("DependencyDisabled") ~= true then
                table.insert(result, instance)
            end
        end

        table.sort(result, function(a, b)
            local ay, by = a.AbsolutePosition.Y, b.AbsolutePosition.Y
            if math.abs(ay - by) > 4 then return ay < by end
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)

        return result
    end

    function self_:FocusNext()
        local focusable = self_:_GetFocusableComponents()
        if #focusable == 0 then return nil end
        local current = GuiService.SelectedObject
        local index = table.find(focusable, current) or 0
        index = (index % #focusable) + 1
        GuiService.SelectedObject = focusable[index]
        return focusable[index]
    end

    function self_:FocusPrevious()
        local focusable = self_:_GetFocusableComponents()
        if #focusable == 0 then return nil end
        local current = GuiService.SelectedObject
        local index = table.find(focusable, current) or 1
        index -= 1
        if index < 1 then index = #focusable end
        GuiService.SelectedObject = focusable[index]
        return focusable[index]
    end

    self_:Track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed or isTextInputFocused() or not self_._keyboardNavigation then return end
        if input.KeyCode == Enum.KeyCode.Tab then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                self_:FocusPrevious()
            else
                self_:FocusNext()
            end
        end
    end))

    ------------------------------------------------------------
    -- OVERLAYS / POPUPS / DRAWERS / CONTEXT MENUS
    ------------------------------------------------------------
    local OverlayManager = {
        Stack = {},
    }

    function OverlayManager:Push(api, options)
        options = options or {}

        api._previousSelection = GuiService.SelectedObject
        api._overlayOptions = options

        table.insert(self.Stack, api)

        task.defer(function()
            if options.AutoFocus == false then
                return
            end
            if not api.Panel or not api.Panel.Parent then
                return
            end

            local selected = nil
            for _, descendant in ipairs(api.Panel:GetDescendants()) do
                if descendant:IsA("GuiButton")
                    and descendant.Visible
                    and descendant.Selectable ~= false then
                    selected = descendant
                    break
                end
            end

            if selected then
                pcall(function()
                    GuiService.SelectedObject = selected
                end)
            end
        end)
    end

    function OverlayManager:Remove(api)
        local index = table.find(self.Stack, api)
        if index then
            table.remove(self.Stack, index)
        end

        if api._previousSelection
            and api._previousSelection.Parent then
            pcall(function()
                GuiService.SelectedObject = api._previousSelection
            end)
        end
    end

    function OverlayManager:CloseTop()
        local top = self.Stack[#self.Stack]
        if top and type(top.Close) == "function" then
            top:Close()
            return true
        end
        return false
    end

    self_._overlayManager = OverlayManager

    self_:Track(UserInputService.InputBegan:Connect(function(input, processed)
        -- Escape must always be able to dismiss the top overlay, even while
        -- a TextBox inside it (for example the ColorPicker HEX field) is focused.
        if input.KeyCode == Enum.KeyCode.Escape then
            local focused = UserInputService:GetFocusedTextBox()
            if focused then
                pcall(function() focused:ReleaseFocus() end)
            end
            OverlayManager:CloseTop()
            return
        end

        if processed or isTextInputFocused() then
            return
        end
    end))

    function self_:_GetOverlayStrokeColor()
        return shadeColor(Theme.StrokeTabBar, 1.20)
    end

    local function createOverlayPanel(options)
        options = options or {}
        local z = Library:NextZIndex()

        -- Root is intentionally non-interactive. Modal input blocking is handled
        -- only by BackdropButton, which is a sibling behind the panel. This avoids
        -- the old bug where a full-screen TextButton parent could remain behind and
        -- freeze the whole UI after a popup/drawer failed to close.
        local overlayRoot = create("Frame", {
            Name = "OverlayRoot",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = false,
            Selectable = false,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = z,
            Parent = main,
        })

        local backdropVisual = nil
        local backdropButton = nil
        local backdropTargetTransparency = tonumber(options.BackdropTransparency) or 0.76

        if options.Backdrop == true then
            backdropVisual = create("Frame", {
                Name = "BackdropVisual",
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = z,
                Parent = overlayRoot,
            })

            backdropButton = create("TextButton", {
                Name = "BackdropButton",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Active = true,
                Selectable = false,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = z + 1,
                Parent = overlayRoot,
            })
        end

        local restPosition = options.Position or UDim2.new(0.5, 0, 0.5, 0)
        local transition = tostring(options.Transition or "scale")
        local hiddenPosition = restPosition + UDim2.new(0, 0, 0, 8)
        if transition == "drawer-left" then
            hiddenPosition = restPosition - UDim2.new(0, (options.Size and options.Size.X.Offset or 320) + 18, 0, 0)
        elseif transition == "drawer-right" then
            hiddenPosition = restPosition + UDim2.new(0, (options.Size and options.Size.X.Offset or 320) + 18, 0, 0)
        end

        local panel = create("CanvasGroup", {
            BackgroundColor3 = options.Color or getOverlaySurfaceColor(),
            BackgroundTransparency = 0,
            GroupTransparency = 1,
            BorderSizePixel = 0,
            Active = true,
            AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5),
            Position = hiddenPosition,
            Size = options.Size or UDim2.new(0, 360, 0, 220),
            ZIndex = z + 2,
            Parent = overlayRoot,
        }, {
            corner(options.Radius or Theme.Metrics.OverlayRadius),
            stroke(self_:_GetOverlayStrokeColor(), 1, 0.22),
            padding(options.Padding or 14),
            create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),
        })

        local panelScale = create("UIScale", {
            Scale = transition == "scale" and 0.965 or 1,
            Parent = panel,
        })

        local api = {
            Overlay = overlayRoot,
            Backdrop = backdropButton,
            BackdropVisual = backdropVisual,
            Panel = panel,
            Closed = Signal.new(),
            TitleLabel = nil,
            _order = 0,
        }

        function api:SetTitle(value)
            if not api.TitleLabel then
                api.TitleLabel = create("TextLabel", {
                    Text = tostring(value or ""),
                    FontFace = Theme.FontBold,
                    TextSize = 16,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    LayoutOrder = -100,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = z + 3,
                    Parent = panel,
                })
            else
                api.TitleLabel.Text = tostring(value or "")
            end
            return api
        end

        function api:AddText(value)
            api._order += 1
            return create("TextLabel", {
                Text = tostring(value or ""),
                FontFace = Theme.Font,
                TextSize = 13,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                LayoutOrder = api._order,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = z + 3,
                Parent = panel,
            })
        end

        function api:AddButton(textValue, callback, variant)
            api._order += 1
            local isPrimary = string.lower(tostring(variant or "")) == "primary"
            local button = create("TextButton", {
                Text = tostring(textValue or "Button"),
                FontFace = Theme.FontSemibold,
                TextSize = 13,
                TextColor3 = isPrimary and Theme.PrimaryText or Theme.Text,
                AutoButtonColor = false,
                Selectable = false,
                BackgroundColor3 = isPrimary and Theme.Accent or Theme.Field,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 34),
                LayoutOrder = api._order,
                ZIndex = z + 3,
                Parent = panel,
            }, { corner(7) })

            button.MouseEnter:Connect(function()
                if not isPrimary then
                    smoothTween(button, { BackgroundColor3 = Theme.FieldHover }, 0.12)
                end
            end)
            button.MouseLeave:Connect(function()
                if not isPrimary then
                    smoothTween(button, { BackgroundColor3 = Theme.Field }, 0.14)
                end
            end)
            button.MouseButton1Click:Connect(function()
                Library:SafeCall(callback or function() end, api)
            end)
            return button
        end

        local closed = false
        local closeTransitionId = 0

        function api:Close(immediate)
            if closed then return api end
            closed = true
            closeTransitionId += 1
            local transitionId = closeTransitionId

            -- Stop blocking input immediately; visuals can finish fading safely.
            if backdropButton then
                backdropButton.Visible = false
                backdropButton.Active = false
            end

            OverlayManager:Remove(api)

            local function finish()
                if transitionId ~= closeTransitionId then return end
                if overlayRoot and overlayRoot.Parent then overlayRoot:Destroy() end
                api.Closed:Fire()
                api.Closed:Destroy()
            end

            if immediate == true then
                finish()
                return api
            end

            tween(panel, {
                GroupTransparency = 1,
                Position = hiddenPosition,
            }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            if transition == "scale" then
                tween(panelScale, { Scale = 0.95 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            end
            if backdropVisual then
                tween(backdropVisual, { BackgroundTransparency = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            end

            task.delay(0.19, finish)
            return api
        end

        api.Destroy = api.Close

        OverlayManager:Push(api, options)

        if backdropButton and options.CloseOnBackdrop == true then
            backdropButton.MouseButton1Click:Connect(function()
                api:Close()
            end)
        end

        if backdropVisual then
            tween(backdropVisual, {
                BackgroundTransparency = backdropTargetTransparency,
            }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
        tween(panel, {
            GroupTransparency = 0,
            Position = restPosition,
        }, 0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if transition == "scale" then
            tween(panelScale, { Scale = 1 }, 0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end

        return api
    end

    function self_:CreatePopup(options)
        options = options or {}
        options.Backdrop = options.Backdrop == true
        options.Transition = options.Transition or "scale"
        options.Color = options.Color or getOverlaySurfaceColor()
        local popup = createOverlayPanel(options)

        -- Popups are non-modal by default. Clicking elsewhere dismisses them
        -- without intercepting the underlying UI.
        if options.CloseOnOutside ~= false and options.Backdrop ~= true then
            local outsideConnection
            outsideConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1
                    and input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end
                local panel = popup.Panel
                if not panel or not panel.Parent then return end
                local p = Vector2.new(input.Position.X, input.Position.Y)
                local pos = panel.AbsolutePosition
                local size_ = panel.AbsoluteSize
                local inside = p.X >= pos.X and p.X <= pos.X + size_.X
                    and p.Y >= pos.Y and p.Y <= pos.Y + size_.Y
                if not inside then popup:Close() end
            end)
            self_:Track(outsideConnection)
            popup.Closed:Connect(function()
                if outsideConnection then outsideConnection:Disconnect(); outsideConnection = nil end
            end)
        end

        return popup
    end

    function self_:CreateModal(options)
        options = options or {}
        options.Backdrop = options.Backdrop ~= false
        options.Transition = options.Transition or "scale"
        options.Color = options.Color or getOverlaySurfaceColor()
        return createOverlayPanel(options)
    end

    function self_:CreateDrawer(options)
        options = options or {}
        local side = string.lower(tostring(options.Side or "right"))
        local width = tonumber(options.Width) or 320
        options.Backdrop = options.Backdrop ~= false
        if options.CloseOnBackdrop == nil then options.CloseOnBackdrop = true end
        options.Size = UDim2.new(0, width, 1, 0)
        options.AnchorPoint = side == "left" and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
        options.Position = side == "left" and UDim2.new(0, 0, 0.5, 0) or UDim2.new(1, 0, 0.5, 0)
        options.Transition = side == "left" and "drawer-left" or "drawer-right"
        options.Radius = 0
        options.Color = options.Color or getOverlaySurfaceColor()
        return createOverlayPanel(options)
    end

    function self_:CreatePopover(target, options)
        options = options or {}

        -- Popovers are intentionally NON-MODAL. Older builds used a full-size
        -- transparent TextButton as the parent, which intercepted every click and
        -- made the rest of the interface feel frozen while a ColorPicker was open.
        local z = Library:NextZIndex()
        local panel = create("CanvasGroup", {
            BackgroundColor3 = options.Color or getOverlaySurfaceColor(),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Size = options.Size or UDim2.new(0, 240, 0, 160),
            ZIndex = z + 1,
            Parent = main,
        }, {
            corner(options.Radius or Theme.Metrics.OverlayRadius),
            stroke(self_:_GetOverlayStrokeColor(), 1, 0.22),
            padding(options.Padding or 12),
            create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),
        })

        local api = {
            Overlay = nil,
            Panel = panel,
            Closed = Signal.new(),
            TitleLabel = nil,
            _order = 0,
        }

        function api:SetTitle(value)
            if not api.TitleLabel then
                api.TitleLabel = create("TextLabel", {
                    Text = tostring(value or ""),
                    FontFace = Theme.FontBold,
                    TextSize = 16,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    LayoutOrder = -100,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = z + 2,
                    Parent = panel,
                })
            else
                api.TitleLabel.Text = tostring(value or "")
            end
            return api
        end

        function api:AddText(value)
            api._order += 1
            return create("TextLabel", {
                Text = tostring(value or ""),
                FontFace = Theme.Font,
                TextSize = 13,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                LayoutOrder = api._order,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = z + 2,
                Parent = panel,
            })
        end

        local closed = false
        local outsideConnection = nil

        local function pointInside(guiObject, position)
            if not guiObject or not guiObject.Parent or not guiObject:IsA("GuiObject") then
                return false
            end
            local absolutePosition = guiObject.AbsolutePosition
            local absoluteSize = guiObject.AbsoluteSize
            return position.X >= absolutePosition.X
                and position.Y >= absolutePosition.Y
                and position.X <= absolutePosition.X + absoluteSize.X
                and position.Y <= absolutePosition.Y + absoluteSize.Y
        end

        function api:Close()
            if closed then return end
            closed = true

            if outsideConnection then
                outsideConnection:Disconnect()
                outsideConnection = nil
            end

            OverlayManager:Remove(api)

            if panel and panel.Parent then
                panel:Destroy()
            end

            api.Closed:Fire()
            api.Closed:Destroy()
        end

        OverlayManager:Push(api, { Backdrop = false, Popover = true })

        if typeof(target) == "Instance" and target:IsA("GuiObject") then
            task.defer(function()
                if closed or not panel or not panel.Parent or not target.Parent then return end

                local mainPos = main.AbsolutePosition
                local mainSize = main.AbsoluteSize
                local targetPos = target.AbsolutePosition
                local targetSize = target.AbsoluteSize
                local panelSize = panel.AbsoluteSize

                local x = targetPos.X - mainPos.X
                local y = targetPos.Y - mainPos.Y + targetSize.Y + 6

                -- Prefer opening upward if there is not enough room below.
                if y + panelSize.Y > mainSize.Y - 8 then
                    y = targetPos.Y - mainPos.Y - panelSize.Y - 6
                end

                x = math.clamp(x, 8, math.max(8, mainSize.X - panelSize.X - 8))
                y = math.clamp(y, 8, math.max(8, mainSize.Y - panelSize.Y - 8))

                panel.Position = UDim2.new(0, x, 0, y)
            end)
        end

        if options.CloseOnBackdrop ~= false then
            outsideConnection = self_:Track(UserInputService.InputBegan:Connect(function(inputObject)
                if closed then return end
                local inputType = inputObject.UserInputType
                if inputType ~= Enum.UserInputType.MouseButton1
                    and inputType ~= Enum.UserInputType.Touch then
                    return
                end

                local position = inputObject.Position
                if pointInside(panel, position) then return end
                if typeof(target) == "Instance" and target:IsA("GuiObject") and pointInside(target, position) then
                    return
                end

                api:Close()
            end))
        end

        return api
    end

    ------------------------------------------------------------
    -- ACTIVITY HUD
    -- Long-lived, non-modal live panels for tasks such as Auto Boss,
    -- quest trackers, detectors and farm/status dashboards.
    ------------------------------------------------------------
    function self_:CreateActivity(config)
        config = type(config) == "table" and config or { Title = tostring(config or "Activity") }
        self_._activities = self_._activities or {}

        local z = Library:NextZIndex() + 40
        local width = math.clamp(tonumber(config.Width) or 340, 260, 520)
        local activityIndex = #self_._activities + 1
        local alive = true
        local minimized = config.Minimized == true
        local autoTimerRunning = false
        local autoTimerStartedAt = nil
        local autoTimerOffset = 0
        local summaryCreated = false
        local sectionOrder = 0

        local function activityColor(kind)
            kind = string.lower(tostring(kind or "neutral"))
            if kind == "success" or kind == "clear" then return Theme.Success end
            if kind == "warning" or kind == "detected" then return Theme.Warning end
            if kind == "danger" or kind == "error" then return Theme.Error end
            if kind == "info" then return Theme.Info end
            if kind == "accent" or kind == "primary" then return Theme.Accent end
            return Theme.TextDark
        end

        local panel = create("CanvasGroup", {
            Name = "MistActivity",
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            AnchorPoint = config.AnchorPoint or Vector2.new(1, 0),
            Position = config.Position or UDim2.new(1, -24, 0, 72 + ((activityIndex - 1) * 14)),
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(0, width, 0, 0),
            GroupTransparency = 1,
            ZIndex = z,
            Parent = screenGui,
        }, {
            corner(config.Radius or 13),
            stroke(Theme.StrokeSoft, 1, 0.34),
            padding(14),
            create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),
        })
        local panelScale = create("UIScale", { Scale = 0.975, Parent = panel })

        local header = create("Frame", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            LayoutOrder = -1000,
            Active = true,
            ZIndex = z + 1,
            Parent = panel,
        })

        local iconHolder = create("Frame", {
            Name = "Icon",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 18, 0, 18),
            ZIndex = z + 2,
            Parent = header,
        })
        local currentIcon = tostring(config.Icon or "info")
        local iconInstance = buildIcon(iconHolder, currentIcon, 17, Theme.Text)

        local titleLabel = create("TextLabel", {
            Name = "Title",
            Text = tostring(config.Title or "Activity"),
            FontFace = Theme.FontSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 27, 0, 0),
            Size = UDim2.new(1, -78, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = z + 2,
            Parent = header,
        })

        local minimizeButton = create("TextButton", {
            Name = "Minimize",
            Text = "",
            AutoButtonColor = false,
            Selectable = false,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -28, 0.5, 0),
            Size = UDim2.new(0, 24, 0, 24),
            Visible = config.Minimizable ~= false,
            ZIndex = z + 3,
            Parent = header,
        })
        minimizeButton:SetAttribute("MistNoFocus", true)
        local minimizeIconHolder = create("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            ZIndex = z + 4,
            Parent = minimizeButton,
        })
        local minimizeIcon = buildIcon(minimizeIconHolder, "chevron-right", 14, Theme.TextDark)
        minimizeIconHolder.Rotation = minimized and 90 or -90

        local closeButton = create("TextButton", {
            Name = "Close",
            Text = "",
            AutoButtonColor = false,
            Selectable = false,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 24, 0, 24),
            Visible = config.Closable ~= false,
            ZIndex = z + 3,
            Parent = header,
        })
        closeButton:SetAttribute("MistNoFocus", true)
        local closeIconHolder = create("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 15, 0, 15),
            ZIndex = z + 4,
            Parent = closeButton,
        })
        local closeIcon = buildIcon(closeIconHolder, "x", 15, Theme.TextDark)

        local content = create("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = 0,
            Visible = not minimized,
            ZIndex = z + 1,
            Parent = panel,
        }, {
            create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),
        })

        local api = {
            Type = "Activity",
            Instance = panel,
            Panel = panel,
            Header = header,
            Content = content,
            Closed = Signal.new(),
            Sections = {},
        }

        local summary = nil
        local function ensureSummary()
            if summaryCreated then return summary end
            summaryCreated = true

            local holder = create("Frame", {
                Name = "Summary",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                LayoutOrder = -500,
                ZIndex = z + 1,
                Parent = content,
            }, {
                create("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),
            })

            local stats = create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                LayoutOrder = 1,
                ZIndex = z + 2,
                Parent = holder,
            })
            local statsLeft = create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -72, 1, 0),
                ZIndex = z + 3,
                Parent = stats,
            }, {
                create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 9),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),
            })
            local statsLabel = create("TextLabel", {
                Text = tostring(config.CounterLabel or "Progress"),
                FontFace = Theme.Font,
                TextSize = 11,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 1, 0),
                LayoutOrder = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = z + 4,
                Parent = statsLeft,
            })
            local counterLabel = create("TextLabel", {
                Text = "",
                FontFace = Theme.FontSemibold,
                TextSize = 11,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 1, 0),
                LayoutOrder = 2,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = z + 4,
                Parent = statsLeft,
            })
            local timeLabel = create("TextLabel", {
                Text = tostring(config.Time or ""),
                FontFace = Theme.Font,
                TextSize = 11,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0, 62, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = z + 3,
                Parent = stats,
            })

            local targetRow = create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                LayoutOrder = 2,
                Visible = false,
                ZIndex = z + 2,
                Parent = holder,
            })
            local targetKey = create("TextLabel", {
                Text = tostring(config.TargetLabel or "Target"),
                FontFace = Theme.Font,
                TextSize = 11,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = z + 3,
                Parent = targetRow,
            })
            local targetValue = create("TextLabel", {
                Text = "",
                FontFace = Theme.FontSemibold,
                TextSize = 11,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 52, 0, 0),
                Size = UDim2.new(1, -52, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = z + 3,
                Parent = targetRow,
            })

            local statusLabel = create("TextLabel", {
                Text = "",
                FontFace = Theme.Font,
                TextSize = 11,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                LayoutOrder = 3,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Visible = false,
                ZIndex = z + 3,
                Parent = holder,
            })

            local progressHolder = create("Frame", {
                BackgroundColor3 = Theme.Field,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20),
                LayoutOrder = 4,
                Visible = false,
                ClipsDescendants = true,
                ZIndex = z + 2,
                Parent = holder,
            }, { corner(7) })
            local progressFill = create("Frame", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = z + 3,
                Parent = progressHolder,
            }, { corner(7) })
            local progressText = create("TextLabel", {
                Text = "0%",
                FontFace = Theme.FontSemibold,
                TextSize = 10,
                TextColor3 = Theme.PrimaryText,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = z + 4,
                Parent = progressHolder,
            })

            summary = {
                Holder = holder,
                StatsRow = stats,
                StatsLeft = statsLeft,
                StatsLabel = statsLabel,
                CounterLabel = counterLabel,
                TimeLabel = timeLabel,
                TargetRow = targetRow,
                TargetKey = targetKey,
                TargetValue = targetValue,
                StatusLabel = statusLabel,
                ProgressHolder = progressHolder,
                ProgressFill = progressFill,
                ProgressText = progressText,
            }
            return summary
        end

        function api:SetTitle(value)
            titleLabel.Text = tostring(value or "Activity")
            return api
        end

        function api:SetIcon(iconName)
            currentIcon = tostring(iconName or "info")
            for _, child in ipairs(iconHolder:GetChildren()) do child:Destroy() end
            iconInstance = buildIcon(iconHolder, currentIcon, 17, Theme.Text)
            return api
        end

        function api:SetCounter(current, total, label)
            local s = ensureSummary()
            if label ~= nil then s.StatsLabel.Text = tostring(label) end
            if total ~= nil then
                s.CounterLabel.Text = tostring(current or 0) .. " / " .. tostring(total)
            else
                s.CounterLabel.Text = tostring(current or "")
            end
            return api
        end

        function api:SetTarget(value, label)
            local s = ensureSummary()
            if label ~= nil then s.TargetKey.Text = tostring(label) end
            local hasValue = value ~= nil and tostring(value) ~= ""
            s.TargetRow.Visible = hasValue
            s.TargetValue.Text = hasValue and tostring(value) or ""
            return api
        end

        function api:SetStatus(value, kind)
            local s = ensureSummary()
            local text = tostring(value or "")
            s.StatusLabel.Text = text
            s.StatusLabel.Visible = text ~= ""
            s.StatusLabel.TextColor3 = kind and activityColor(kind) or Theme.TextDark
            return api
        end

        function api:SetTime(value)
            local s = ensureSummary()
            autoTimerRunning = false
            s.TimeLabel.Text = tostring(value or "")
            return api
        end

        function api:StartTimer(offsetSeconds)
            local s = ensureSummary()
            autoTimerOffset = math.max(0, tonumber(offsetSeconds) or 0)
            autoTimerStartedAt = os.clock()
            autoTimerRunning = true
            s.TimeLabel.Text = "0:00"
            return api
        end

        function api:StopTimer()
            autoTimerRunning = false
            return api
        end

        function api:SetProgress(value, label, kind)
            local s = ensureSummary()
            local numeric = tonumber(value) or 0
            if numeric > 1 then numeric = numeric / 100 end
            numeric = math.clamp(numeric, 0, 1)
            s.ProgressHolder.Visible = true
            s.ProgressFill.BackgroundColor3 = kind and activityColor(kind) or Theme.Accent
            smoothTween(s.ProgressFill, { Size = UDim2.new(numeric, 0, 1, 0) }, 0.16)
            s.ProgressText.Text = label ~= nil and tostring(label) or (tostring(math.floor(numeric * 100 + 0.5)) .. "%")
            return api
        end

        function api:HideProgress()
            local s = ensureSummary()
            s.ProgressHolder.Visible = false
            return api
        end

        local function makeRow(parent, rowConfig)
            rowConfig = type(rowConfig) == "table" and rowConfig or { Title = tostring(rowConfig or "Row") }
            local rowKind = rowConfig.Status or rowConfig.Kind or "neutral"
            local hasDescription = rowConfig.Description ~= nil and tostring(rowConfig.Description) ~= ""
            local rowHeight = hasDescription and 38 or 26
            local row = create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, rowHeight),
                ZIndex = z + 2,
                Parent = parent,
            })

            local dot = create("Frame", {
                BackgroundColor3 = activityColor(rowKind),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 1, 0, hasDescription and 10 or math.floor(rowHeight / 2)),
                Size = UDim2.new(0, 6, 0, 6),
                ZIndex = z + 3,
                Parent = row,
            }, { corner(9999) })

            local rowTitle = create("TextLabel", {
                Text = tostring(rowConfig.Title or rowConfig.Text or "Row"),
                FontFace = Theme.FontSemibold,
                TextSize = 12,
                TextColor3 = rowConfig.StatusColorTitle == true and activityColor(rowKind) or Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -80, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = z + 3,
                Parent = row,
            })

            local valueLabel = create("TextLabel", {
                Text = tostring(rowConfig.Value or ""),
                FontFace = Theme.Font,
                TextSize = 11,
                TextColor3 = Theme.TextDark,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0, 72, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Right,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = z + 3,
                Parent = row,
            })

            local description = create("TextLabel", {
                Text = tostring(rowConfig.Description or ""),
                FontFace = Theme.Font,
                TextSize = 10,
                TextColor3 = Theme.TextDimmer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 19),
                Size = UDim2.new(1, -14, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Visible = hasDescription,
                ZIndex = z + 3,
                Parent = row,
            })

            local rowApi = {
                Instance = row,
                Container = row,
            }
            function rowApi:SetTitle(v) rowTitle.Text = tostring(v or ""); return rowApi end
            function rowApi:SetDescription(v)
                local value = tostring(v or "")
                description.Text = value
                description.Visible = value ~= ""
                local expanded = value ~= ""
                row.Size = UDim2.new(1, 0, 0, expanded and 38 or 26)
                dot.Position = UDim2.new(0, 1, 0, expanded and 10 or 13)
                return rowApi
            end
            function rowApi:SetValue(v) valueLabel.Text = tostring(v or ""); return rowApi end
            function rowApi:SetStatus(kind)
                rowKind = kind or "neutral"
                dot.BackgroundColor3 = activityColor(rowKind)
                if rowConfig.StatusColorTitle == true then rowTitle.TextColor3 = activityColor(rowKind) end
                return rowApi
            end
            function rowApi:SetVisible(v) row.Visible = v ~= false; return rowApi end
            function rowApi:Destroy() if row and row.Parent then row:Destroy() end end
            return rowApi
        end

        function api:AddSection(sectionConfig)
            sectionConfig = type(sectionConfig) == "table" and sectionConfig or { Title = tostring(sectionConfig or "Section") }
            sectionOrder += 1
            local section = create("Frame", {
                Name = "Section",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                LayoutOrder = tonumber(sectionConfig.Order) or sectionOrder,
                ZIndex = z + 1,
                Parent = content,
            }, {
                create("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),
            })

            local sectionHeader = create("Frame", {
                BackgroundColor3 = sectionConfig.BackgroundColor or Theme.Field,
                BackgroundTransparency = sectionConfig.BackgroundTransparency ~= nil and sectionConfig.BackgroundTransparency or 0.12,
                Size = UDim2.new(1, 0, 0, 32),
                LayoutOrder = -100,
                ZIndex = z + 2,
                Parent = section,
            }, { corner(7) })

            local sectionIconHolder = create("Frame", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 9, 0.5, 0),
                Size = UDim2.new(0, 15, 0, 15),
                Visible = sectionConfig.Icon ~= nil,
                ZIndex = z + 3,
                Parent = sectionHeader,
            })
            if sectionConfig.Icon then buildIcon(sectionIconHolder, tostring(sectionConfig.Icon), 15, Theme.TextDark) end

            local sectionTitle = create("TextLabel", {
                Text = tostring(sectionConfig.Title or sectionConfig.Text or "Section"),
                FontFace = Theme.FontSemibold,
                TextSize = 12,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, sectionConfig.Icon and 31 or 10, 0, 0),
                Size = UDim2.new(1, sectionConfig.Icon and -72 or -51, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = z + 3,
                Parent = sectionHeader,
            })
            local sectionCounter = create("TextLabel", {
                Text = sectionConfig.Counter ~= nil and tostring(sectionConfig.Counter) or "",
                FontFace = Theme.FontSemibold,
                TextSize = 12,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -9, 0, 0),
                Size = UDim2.new(0, 52, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = z + 3,
                Parent = sectionHeader,
            })

            local rowsHolder = create("Frame", {
                Name = "Rows",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                LayoutOrder = 0,
                ZIndex = z + 2,
                Parent = section,
            }, {
                create("UIListLayout", {
                    Padding = UDim.new(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),
            })

            local sectionApi = {
                Instance = section,
                Header = sectionHeader,
                Rows = rowsHolder,
                Items = {},
            }
            function sectionApi:SetTitle(v) sectionTitle.Text = tostring(v or "Section"); return sectionApi end
            function sectionApi:SetCounter(v) sectionCounter.Text = v == nil and "" or tostring(v); return sectionApi end
            function sectionApi:SetVisible(v) section.Visible = v ~= false; return sectionApi end
            function sectionApi:AddRow(rowConfig)
                local item = makeRow(rowsHolder, rowConfig)
                table.insert(sectionApi.Items, item)
                return item
            end
            function sectionApi:AddStatus(rowConfig)
                rowConfig = type(rowConfig) == "table" and rowConfig or { Title = tostring(rowConfig or "Status") }
                rowConfig.StatusColorTitle = rowConfig.StatusColorTitle ~= false
                local item = makeRow(rowsHolder, rowConfig)
                table.insert(sectionApi.Items, item)
                return item
            end
            function sectionApi:Clear()
                for _, item in ipairs(sectionApi.Items) do
                    if item and type(item.Destroy) == "function" then pcall(function() item:Destroy() end) end
                end
                table.clear(sectionApi.Items)
                return sectionApi
            end
            function sectionApi:Destroy()
                sectionApi:Clear()
                if section and section.Parent then section:Destroy() end
            end

            table.insert(api.Sections, sectionApi)
            return sectionApi
        end

        function api:SetMinimized(value)
            minimized = value == true
            content.Visible = not minimized
            for _, child in ipairs(minimizeIconHolder:GetChildren()) do child:Destroy() end
            minimizeIcon = buildIcon(minimizeIconHolder, "chevron-right", 14, Theme.TextDark)
            minimizeIconHolder.Rotation = minimized and 90 or -90
            return api
        end
        function api:ToggleMinimized() return api:SetMinimized(not minimized) end
        function api:IsMinimized() return minimized end
        function api:SetVisible(value) panel.Visible = value ~= false; return api end
        function api:Show() return api:SetVisible(true) end
        function api:Hide() return api:SetVisible(false) end
        function api:SetPosition(position) if typeof(position) == "UDim2" then panel.Position = position end; return api end
        function api:GetPosition() return panel.Position end

        local closed = false
        function api:Close(immediate)
            if closed then return api end
            closed = true
            alive = false
            autoTimerRunning = false
            for i = #self_._activities, 1, -1 do
                if self_._activities[i] == api then table.remove(self_._activities, i); break end
            end
            local function finish()
                if panel and panel.Parent then panel:Destroy() end
                api.Closed:Fire()
                api.Closed:Destroy()
            end
            if immediate == true then finish(); return api end
            tween(panel, { GroupTransparency = 1, Position = panel.Position + UDim2.new(0, 10, 0, -2) }, 0.17, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tween(panelScale, { Scale = 0.97 }, 0.17, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.18, finish)
            return api
        end
        api.Destroy = api.Close

        closeButton.MouseEnter:Connect(function() if closeIcon then setIconColor(closeIcon, Theme.Text, 0.10) end end)
        closeButton.MouseLeave:Connect(function() if closeIcon then setIconColor(closeIcon, Theme.TextDark, 0.12) end end)
        closeButton.MouseButton1Click:Connect(function() api:Close() end)
        minimizeButton.MouseButton1Click:Connect(function() api:ToggleMinimized() end)

        dragController:Attach(header, panel)

        self_:Track(function()
            if not closed then api:Close(true) end
        end)

        table.insert(self_._activities, api)

        task.spawn(function()
            while alive and panel.Parent do
                if autoTimerRunning and autoTimerStartedAt then
                    local elapsed = math.max(0, autoTimerOffset + (os.clock() - autoTimerStartedAt))
                    local minutes = math.floor(elapsed / 60)
                    local seconds = math.floor(elapsed % 60)
                    local s = ensureSummary()
                    s.TimeLabel.Text = string.format("%d:%02d", minutes, seconds)
                end
                task.wait(0.25)
            end
        end)

        panel.Position = panel.Position + UDim2.new(0, 12, 0, 0)
        tween(panel, { GroupTransparency = 0, Position = panel.Position - UDim2.new(0, 12, 0, 0) }, 0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(panelScale, { Scale = 1 }, 0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        if config.Counter ~= nil or config.Total ~= nil then api:SetCounter(config.Counter or 0, config.Total, config.CounterLabel) end
        if config.Target ~= nil then api:SetTarget(config.Target, config.TargetLabel) end
        if config.Status ~= nil then api:SetStatus(config.Status, config.StatusType) end
        if config.Progress ~= nil then api:SetProgress(config.Progress, config.ProgressText, config.ProgressType) end
        if config.AutoTimer == true then api:StartTimer(config.TimerOffset) elseif config.Time ~= nil then api:SetTime(config.Time) end

        return api
    end

    function self_:GetActivities()
        local out = {}
        for i, activity in ipairs(self_._activities or {}) do out[i] = activity end
        return out
    end

    function self_:CloseActivities(immediate)
        local copy = self_:GetActivities()
        for _, activity in ipairs(copy) do
            if activity and type(activity.Close) == "function" then pcall(function() activity:Close(immediate == true) end) end
        end
        return self_
    end

    function self_:CreateContextMenu(items, position)
        items = items or {}
        local z = Library:NextZIndex()
        local longest = 0
        for _, item in ipairs(items) do
            local cfg = type(item) == "table" and item or { Text = tostring(item) }
            longest = math.max(longest, #tostring(cfg.Text or cfg.Name or "Action"))
        end
        local menuWidth = math.clamp(longest * 7 + 42, 164, 236)
        local rowHeight = 32
        local menuHeight = math.max(10, #items * rowHeight + 10)

        local menu = create("CanvasGroup", {
            Name = "ContextMenu",
            BackgroundColor3 = getOverlaySurfaceColor(),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, menuWidth, 0, menuHeight),
            GroupTransparency = 1,
            Active = true,
            ZIndex = z,
            Parent = main,
        }, {
            corner(9),
            stroke(self_:_GetOverlayStrokeColor(), 1, 0.34),
            padding(5),
            create("UIListLayout", {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        local menuScale = create("UIScale", { Scale = 0.975, Parent = menu })

        local api = {
            Panel = menu,
            Anchor = typeof(position) == "Instance" and position or nil,
        }
        local contextMaid = Maid.new()
        self_:Track(contextMaid)
        local closed = false

        local function close(immediate)
            if closed then return end
            closed = true
            menu.Active = false
            OverlayManager:Remove(api)
            contextMaid:Cleanup()
            if not menu or not menu.Parent then return end
            if immediate == true then
                menu:Destroy()
                return
            end
            tween(menu, { GroupTransparency = 1 }, 0.11, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tween(menuScale, { Scale = 0.97 }, 0.11, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.12, function()
                if menu and menu.Parent then menu:Destroy() end
            end)
        end

        local function placeMenu()
            if not menu or not menu.Parent or not main or not main.Parent then return end
            local mainPos = main.AbsolutePosition
            local mainSize = main.AbsoluteSize
            local menuSize = menu.AbsoluteSize
            local x, y

            if typeof(position) == "Instance" and position:IsA("GuiObject") and position.Parent then
                local targetPos = position.AbsolutePosition
                local targetSize = position.AbsoluteSize
                x = targetPos.X - mainPos.X + targetSize.X - menuSize.X
                y = targetPos.Y - mainPos.Y + targetSize.Y + 5
                if y + menuSize.Y > mainSize.Y - 8 then
                    y = targetPos.Y - mainPos.Y - menuSize.Y - 5
                end
            elseif typeof(position) == "UDim2" then
                x = position.X.Scale * mainSize.X + position.X.Offset
                y = position.Y.Scale * mainSize.Y + position.Y.Offset
            else
                local mouse = UserInputService:GetMouseLocation()
                x = mouse.X - mainPos.X
                y = mouse.Y - mainPos.Y
            end

            x = math.clamp(x or 8, 8, math.max(8, mainSize.X - menuSize.X - 8))
            y = math.clamp(y or 8, 8, math.max(8, mainSize.Y - menuSize.Y - 8))
            menu.Position = UDim2.new(0, math.floor(x), 0, math.floor(y))
        end

        for i, item in ipairs(items) do
            local cfg = type(item) == "table" and item or { Text = tostring(item) }
            local disabled = cfg.Disabled == true
            local destructive = cfg.Danger == true or cfg.Destructive == true or string.lower(tostring(cfg.Variant or "")) == "danger"
            local row = create("TextButton", {
                Name = "ContextMenuRow",
                Text = "",
                AutoButtonColor = false,
                Selectable = false,
                Active = not disabled,
                BackgroundColor3 = Theme.Field,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, rowHeight - 2),
                LayoutOrder = i,
                ZIndex = z + 1,
                Parent = menu,
            }, { corner(6) })

            local iconOffset = 10
            if cfg.Icon then
                local iconHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 9, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = z + 2,
                    Parent = row,
                })
                buildIcon(iconHolder, tostring(cfg.Icon), 14, destructive and Theme.Error or (disabled and Theme.TextDimmer or Theme.TextDark))
                iconOffset = 31
            end

            create("TextLabel", {
                Text = tostring(cfg.Text or cfg.Name or "Action"),
                FontFace = Theme.Font,
                TextSize = 12,
                TextColor3 = destructive and Theme.Error or (disabled and Theme.TextDimmer or Theme.Text),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, iconOffset, 0, 0),
                Size = UDim2.new(1, -iconOffset - 8, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = z + 2,
                Parent = row,
            })

            if not disabled then
                row.MouseEnter:Connect(function()
                    smoothTween(row, { BackgroundTransparency = 0, BackgroundColor3 = Theme.FieldHover }, 0.10)
                end)
                row.MouseLeave:Connect(function()
                    smoothTween(row, { BackgroundTransparency = 1 }, 0.12)
                end)
                row.MouseButton1Click:Connect(function()
                    Library:SafeCall(cfg.Callback or cfg.OnClick or function() end)
                    if cfg.CloseOnClick ~= false then close() end
                end)
            end
        end

        function api:Reposition()
            placeMenu()
            return api
        end
        function api:Close(immediate)
            close(immediate)
        end

        OverlayManager:Push(api, { Backdrop = false, AutoFocus = false })

        contextMaid:Give(UserInputService.InputBegan:Connect(function(input)
            if not menu or not menu.Parent then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local point = input.Position
            local pos = menu.AbsolutePosition
            local size = menu.AbsoluteSize
            local inside = point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
            if not inside then close() end
        end))

        task.defer(function()
            placeMenu()
            tween(menu, { GroupTransparency = 0 }, 0.13, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            tween(menuScale, { Scale = 1 }, 0.13, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end)

        local mainMoveConnection
        local mainSizeConnection
        local anchorMoveConnection
        local anchorSizeConnection
        mainMoveConnection = contextMaid:Give(main:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if menu and menu.Parent then placeMenu() elseif mainMoveConnection then mainMoveConnection:Disconnect() end
        end))
        mainSizeConnection = contextMaid:Give(main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if menu and menu.Parent then placeMenu() elseif mainSizeConnection then mainSizeConnection:Disconnect() end
        end))
        if typeof(position) == "Instance" and position:IsA("GuiObject") then
            anchorMoveConnection = contextMaid:Give(position:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                if menu and menu.Parent and position.Parent then placeMenu() elseif anchorMoveConnection then anchorMoveConnection:Disconnect() end
            end))
            anchorSizeConnection = contextMaid:Give(position:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if menu and menu.Parent and position.Parent then placeMenu() elseif anchorSizeConnection then anchorSizeConnection:Disconnect() end
            end))
        end
        return api
    end

    self_.CreateActionMenu = self_.CreateContextMenu

    ------------------------------------------------------------
    -- Mantém apenas UM item da sidebar aberto por vez.
    -- Mantém apenas UM item da sidebar aberto por vez.
    -- Only one sidebar item/group is kept open at a time.
    -- Sub-tabs from the same group share an OwnerKey and stay together.
    function self_:_EnforceSingleSidebarItem(category, ownerKey)
        -- Sidebar pages are lazy-built once and then cached. Switching
        -- groups only changes visibility, avoiding repeated component,
        -- icon, layout and event construction on every click.
        for _, t in ipairs(self_.Tabs) do
            local sameOwner = t.Category == category
                and t.OwnerKey == ownerKey

            if t._btn and t._btn.Parent then
                t._btn.Visible = sameOwner
            end

            if t._dividerBefore and t._dividerBefore.Parent then
                t._dividerBefore.Visible = false
            end

            local tabPage = rawget(t, "Page")
            if tabPage then
                tabPage.Visible = sameOwner and self_._activeTab == t
            end
        end

        self_._activeCategory = category
        refreshDividers()
    end

    -- Creates (or focuses) a tab from a sidebar item.
    -- 'category' is the owner of the tab (Visual, Farm, etc.) — this
    -- keeps tabs from different categories from being mixed
    -- in the bar; each category gets its own block with a divider.
    -- 'order' é a posição do item na sidebar (1, 2, 3...): a tab SEMPRE
    -- é posicionada na topbar de acordo com esse número, e não pela
    -- ordem em que foi clicada/aberta — assim os itens agrupados na
    -- sidebar sempre aparecem na ordem definida na topbar, não
    -- importa em que ordem o usuário clique nelas.
    function self_:_OpenTab(name, iconBuilder, contentBuilder, category, order, ownerKey)
        ownerKey = ownerKey or name

        -- Antes de focar/criar a tab, fecha qualquer outro item da sidebar.
        -- As sub-tabs de um mesmo grupo compartilham o mesmo OwnerKey, então
        -- Sub-tabs from the same group stay together; unrelated groups close.
        if category then self_:_EnforceSingleSidebarItem(category, ownerKey) end

        for _, t in ipairs(self_.Tabs) do
            if t.Name == name and t.OwnerKey == ownerKey then
                selectTab(t)
                return t
            end
        end

        -- Usa uma escala maior para preservar a ordem fracionária das sub-tabs
        -- e deixa o divisor exatamente uma posição antes da tab correspondente.
        local layoutOrder = math.floor((order or 1) * 100 + 0.5)

        -- Divisor à esquerda da tab. É sempre criado; refreshDividers()
        -- decide depois se ele fica visível (só a tab mais à esquerda,
        -- ou seja, a de menor 'order', não mostra divisor).
        local dividerBefore = create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0, 13, 1, 0),
            LayoutOrder = layoutOrder - 1, Visible = false, ZIndex = 4, Parent = tabList,
        })
        create("Frame", {
            BackgroundColor3 = Theme.StrokeTabBar, BackgroundTransparency = 0.42, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 1, 0, 18),
            ZIndex = 4, Parent = dividerBefore,
        })

        -- Use an explicit width for top tabs. Nested AutomaticSize chains can resolve
        -- to 0 px on some runtime/Roblox builds, which makes tabs exist but render
        -- invisibly. The width is deterministic and the strip scrolls horizontally.
        local visibleNameLength = utf8.len(name) or #name
        local tabWidth = math.clamp(52 + visibleNameLength * 8 + (iconBuilder and 20 or 0), 84, 220)

        local btn = create("TextButton", {
            Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 1,
            Size = UDim2.new(0, tabWidth, 1, 0),
            LayoutOrder = layoutOrder, ZIndex = 4, Parent = tabList,
        })
        local inner = create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -28, 1, 0),
            Parent = btn,
        }, {
            create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
        })

        local tabIconHolder = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 16),
            Visible = false,
            LayoutOrder = 1,
            ZIndex = 5,
            Parent = inner,
        })

        local label = create("TextLabel", {
            Text = name, FontFace = Theme.FontSemibold, TextSize = 16, TextColor3 = Theme.TextTabInactive,
            BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = 2, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = inner,
        })

        local underline = create("Frame", {
            BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -2), Size = UDim2.new(0.72, 0, 0, 2), ZIndex = 5, Parent = btn,
        }, { corner(9999) })

        local tab = {
            Name = name,
            _btn = btn,
            _label = label,
            _underline = underline,
            _iconHolder = tabIconHolder,
            _icon = nil,
            Category = category,
            OwnerKey = ownerKey,
            _dividerBefore = dividerBefore,
            _order = order or 1,
            Disabled = false,
            Pinned = false,
        }

        function tab:Rename(newName)
            newName = tostring(newName or "")
            if newName == "" then return tab end
            tab.Name = newName
            label.Text = newName
            local tabPage = rawget(tab, "Page")
            if tabPage then tabPage.Name = newName .. "_Page" end
            return tab
        end
        tab.SetName = tab.Rename

        function tab:SetIcon(iconName)
            for _, child in ipairs(tabIconHolder:GetChildren()) do child:Destroy() end
            if iconName == nil or tostring(iconName) == "" then
                tabIconHolder.Visible = false
                tabIconHolder.Size = UDim2.new(0, 0, 0, 16)
                tab._icon = nil
            else
                tabIconHolder.Visible = true
                tabIconHolder.Size = UDim2.new(0, 16, 0, 16)
                tab._icon = buildIcon(tabIconHolder, tostring(iconName), 15, Theme.TextDark)
            end
            return tab
        end

        function tab:SetVisible(visible)
            visible = visible ~= false
            btn.Visible = visible
            dividerBefore.Visible = visible and dividerBefore.Visible or false
            if not visible and self_._activeTab == tab then
                local nextTab = nil
                for _, candidate in ipairs(self_.Tabs) do
                    if candidate ~= tab
                        and candidate._btn.Visible
                        and candidate.Disabled ~= true then
                        nextTab = candidate
                        break
                    end
                end
                if nextTab then selectTab(nextTab) end
            end
            return tab
        end

        function tab:SetDisabled(disabled)
            tab.Disabled = disabled == true
            label.TextTransparency = tab.Disabled and 0.45 or 0
            if tab._icon then setIconColor(tab._icon, tab.Disabled and Theme.TextDimmer or Theme.TextDark, 0.1) end
            return tab
        end

        function tab:SetPinned(pinned)
            tab.Pinned = pinned == true
            return tab
        end

        function tab:IsPinned()
            return tab.Pinned == true
        end

        function tab:Select()
            selectTab(tab)
            return tab
        end

        function tab:Close()
            if tab.Pinned then return false end
            closeTab(tab)
            return true
        end

        btn.MouseEnter:Connect(function()
            if self_._activeTab ~= tab then tween(btn, { BackgroundTransparency = 0.96 }, 0.1) end
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundTransparency = 1 }, 0.1)
        end)
        btn.MouseButton1Click:Connect(function()
            if tab.Disabled ~= true then selectTab(tab) end
        end)

        local page = create("ScrollingFrame", {
            Name = name .. "_Page", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0, ScrollBarImageColor3 = Theme.Accent, ScrollBarImageTransparency = 1,
            Visible = false, ZIndex = 2, Parent = pageHolder,
        }, {
            padding(22),
            create("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder }),
        })
        rawset(tab, "Page", page)
        if iconBuilder then
            tabIconHolder.Visible = true
            tabIconHolder.Size = UDim2.new(0, 16, 0, 16)
            local okIcon, built = pcall(iconBuilder, tabIconHolder, 15, Theme.TextDark)
            if okIcon then tab._icon = built end
        end
        page.MouseEnter:Connect(function() tween(page, { ScrollBarImageTransparency = 1 }, 0.12) end)
        page.MouseLeave:Connect(function() tween(page, { ScrollBarImageTransparency = 1 }, 0.12) end)

        table.insert(self_.Tabs, tab)
        refreshDividers()
        self_:_AttachCardAPI(tab, page)

        if contentBuilder then
            local previousContext = self_._keybindRegisterContext
            local previousBuildingTab = self_._buildingTab

            self_._keybindRegisterContext =
                "tab:" .. tostring(ownerKey) .. "::" .. tostring(name)
            self_._buildingTab = tab

            local ok, err = pcall(contentBuilder, tab)

            self_._keybindRegisterContext = previousContext
            self_._buildingTab = previousBuildingTab

            if not ok then
                tab.BuildError = tostring(err)

                create("Frame", {
                    BackgroundColor3 = Theme.Error,
                    BackgroundTransparency = 0.90,
                    Size = UDim2.new(1, 0, 0, 86),
                    LayoutOrder = -1000,
                    ZIndex = 4,
                    Parent = page,
                }, {
                    corner(Theme.Metrics.CardRadius),
                    stroke(Theme.Error, 1, 0.36),
                    padding(Theme.Metrics.SpaceM),
                    create("UIListLayout", {
                        Padding = UDim.new(0, Theme.Metrics.SpaceS),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                    create("TextLabel", {
                        Text = "This page could not be built.",
                        FontFace = Theme.FontSemibold,
                        TextSize = 14,
                        TextColor3 = Theme.Text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        LayoutOrder = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                    create("TextLabel", {
                        Text = tab.BuildError,
                        FontFace = Theme.Font,
                        TextSize = 12,
                        TextColor3 = Theme.TextDark,
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        LayoutOrder = 2,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                    }),
                })

                warn("[MistUI Tab Build] " .. tab.BuildError)
            end
        end

        selectTab(tab)
        return tab
    end

    -- Public direct top-tab API. This bypasses lazy sidebar opening and is
    -- useful for hubs that want their primary sections visible immediately.
    function self_:CreateTopTab(config)
        config = type(config) == "table" and config or { Name = tostring(config or "Tab") }
        local name = tostring(config.Name or config.Text or config.Id or "Tab")
        local iconName = config.Icon
        local builder = config.Build or config.Callback
        local category = config.Category
        local order = tonumber(config.Order) or (#self_.Tabs + 1)
        local ownerKey = config.OwnerKey or config.Group or "__direct_top_tabs"
        return self_:_OpenTab(
            name,
            iconName and function(holder, size, color)
                return buildIcon(holder, tostring(iconName), size, color)
            end or nil,
            builder,
            category,
            order,
            ownerKey
        )
    end

    ------------------------------------------------------------
    -- CREATE CATEGORY (SCRIPTS / AUTO EXECUTE / etc.)
    ------------------------------------------------------------
    function self_:CreateCategory(name)
        local categoryConfig = nil
        if type(name) == "table" then
            categoryConfig = name
            name = categoryConfig.Name or categoryConfig.Text or "Category"
        end
        name = tostring(name or "Category")

        local catRow = create("TextButton", {
            Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 44), ZIndex = 4, Parent = treeList,
        })

        -- The chevron is its own button (not just decoration). Because it sits
        -- above catRow with a higher ZIndex, its clicks are captured
        -- only by it and do not pass through to the catRow below — this separates
        -- the two behaviors:
        --   • click the chevron -> expand/collapse the list
        --   • click the rest of the row (category name) -> open ALL tabs
        local chevronBtn = create("TextButton", {
            Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0.5, 0),
            Size = UDim2.new(0, 34, 0, 34), ZIndex = 6, Parent = catRow,
        })
        local chevronHolder = create("Frame", {
            BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 24, 0, 24),
            ZIndex = 6, Parent = chevronBtn,
        })
        local chevronIcon = buildIcon(chevronHolder, "chevron-right", 24, Theme.TextDark)

        local categoryIconHolder = create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 38, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Visible = false,
            ZIndex = 5,
            Parent = catRow,
        })

        local categoryLabel = create("TextLabel", {
            Text = name:upper(), FontFace = Theme.FontSemibold, TextSize = 16, TextColor3 = Theme.TextDark,
            BackgroundTransparency = 1, Position = UDim2.new(0, 42, 0, 0), Size = UDim2.new(1, -48, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = catRow,
        })

        local itemsHolder = create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true, Visible = false, ZIndex = 4, Parent = treeList,
        }, {
            create("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }),
        })

        local category = {
            Name = name,
            Id = categoryConfig and (categoryConfig.Id or categoryConfig.Flag) or name,
            Description = categoryConfig and categoryConfig.Description or nil,
            _row = catRow,
            _chevron = chevronHolder,
            _itemsHolder = itemsHolder,
            _items = {},
            _expanded = false,
        }

        local categoryExpanded = false

        local function setCategoryExpanded(expanded)
            categoryExpanded = expanded == true
            category._expanded = categoryExpanded
            itemsHolder.Visible = categoryExpanded
            tween(chevronHolder, { Rotation = categoryExpanded and 90 or 0 }, 0.15)
        end

        function category.SetExpanded(a, b)
            -- Supports both category.SetExpanded(true) and category:SetExpanded(true).
            local expanded = (b == nil) and a or b
            setCategoryExpanded(expanded == true)
            return category
        end

        function category:Expand()
            setCategoryExpanded(true)
            return category
        end

        function category:Collapse()
            setCategoryExpanded(false)
            return category
        end

        function category:Toggle()
            local nextState = not categoryExpanded
            setCategoryExpanded(nextState)
            return nextState
        end

        function category:IsExpanded()
            return categoryExpanded
        end

        function category:Rename(newName)
            newName = tostring(newName or "")
            if newName ~= "" then
                category.Name = newName
                categoryLabel.Text = newName:upper()
            end
            return category
        end

        function category:SetIcon(iconName)
            for _, child in ipairs(categoryIconHolder:GetChildren()) do child:Destroy() end
            if iconName == nil or tostring(iconName) == "" then
                categoryIconHolder.Visible = false
                categoryLabel.Position = UDim2.new(0, 42, 0, 0)
                categoryLabel.Size = UDim2.new(1, -48, 1, 0)
            else
                categoryIconHolder.Visible = true
                buildIcon(categoryIconHolder, tostring(iconName), 15, Theme.TextDark)
                categoryLabel.Position = UDim2.new(0, 62, 0, 0)
                categoryLabel.Size = UDim2.new(1, -68, 1, 0)
            end
            return category
        end

        function category:SetVisible(visible)
            visible = visible ~= false
            catRow.Visible = visible
            itemsHolder.Visible = visible and category._expanded
            return category
        end

        function category:SetDisabled(disabled)
            category.Disabled = disabled == true
            categoryLabel.TextTransparency = category.Disabled and 0.5 or 0
            catRow.Active = not category.Disabled
            return category
        end

        function category:SetOrder(order)
            catRow.LayoutOrder = tonumber(order) or catRow.LayoutOrder
            itemsHolder.LayoutOrder = catRow.LayoutOrder + 1
            return category
        end

        function category:SetItemOrder(itemName, order)
            for _, item in ipairs(category._items or {}) do
                if tostring(item._name) == tostring(itemName) then
                    item._order = tonumber(order) or item._order
                    item._row.LayoutOrder = item._order
                    return true
                end
            end
            return false
        end

        function category:PinItem(itemName, pinned)
            for _, item in ipairs(category._items or {}) do
                if tostring(item._name) == tostring(itemName) then
                    item._pinned = pinned ~= false
                    item._row.LayoutOrder = item._pinned and -1000 or (item._order or 1)
                    return true
                end
            end
            return false
        end

        function category:Search(query)
            query = string.lower(tostring(query or ""))
            for _, item in ipairs(category._items or {}) do
                item._row.Visible = query == "" or string.find(string.lower(tostring(item._name or "")), query, 1, true) ~= nil
            end
            return category
        end

        -- Expande/colapsa a lista de scripts (pra você escolher qual tab abrir)
        local function toggle()
            setCategoryExpanded(not category._expanded)
        end
        chevronBtn.MouseButton1Click:Connect(toggle)

        -- Clicar no nome da categoria abre TODAS as tabs (scripts) que ela contém
        local function openAllInCategory()
            local firstTab
            for _, item in ipairs(category._items) do
                local t = item._open()
                if not firstTab then firstTab = t end
            end
            if firstTab then selectTab(firstTab) end
        end
        catRow.MouseButton1Click:Connect(function()
            if category.Disabled ~= true then openAllInCategory() end
        end)
        -- Highlight the category name and chevron on hover; no white rectangle.
        catRow.MouseEnter:Connect(function()
            tween(categoryLabel, { TextColor3 = Theme.Text }, 0.1)
            setIconColor(chevronIcon, Theme.Text, 0.1)
        end)
        catRow.MouseLeave:Connect(function()
            tween(categoryLabel, { TextColor3 = Theme.TextDark }, 0.1)
            setIconColor(chevronIcon, Theme.TextDark, 0.1)
        end)

        -- Category starts expanded by default
        toggle()

        -- Adds a script item (clickable item that opens a Tab).
        -- 'iconName' é opcional (padrão "file") — permite um ícone
        -- diferente por script, tanto na sidebar quanto na tab aberta.
        function category:AddScript(scriptName, contentBuilder, iconName)
            local scriptConfig = nil
            if type(scriptName) == "table" then
                scriptConfig = scriptName
                scriptName = scriptConfig.Name or scriptConfig.Text or "Page"
                contentBuilder = scriptConfig.Build
                    or scriptConfig.Callback
                    or scriptConfig.Content
                iconName = scriptConfig.Icon or iconName
                self_:RegisterKeybindDefinitions(
                    scriptConfig.Keybinds,
                    scriptConfig.Id or scriptName
                )
            end

            iconName = iconName or "file"
            -- Posição deste item na sidebar (1º, 2º, 3º...). Usada como
            -- LayoutOrder aqui embaixo e também repassada para _OpenTab,
            -- para a tab correspondente sempre nascer na mesma posição
            -- relativa lá na topbar — não importa a ordem de clique.
            local sidebarOrder = #category._items + 1
            local itemBtn = create("TextButton", {
                Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36), LayoutOrder = sidebarOrder, ZIndex = 4, Parent = itemsHolder,
            }, { corner(8) })
            -- Fundo selecionado com fade da esquerda para a direita.
            local activeFade = create("Frame", {
                Name = "ActiveFade",
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.86,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
                ZIndex = 4,
                Parent = itemBtn,
            }, {
                corner(7),
                create("UIGradient", {
                    Rotation = 0,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0.00, 0.30),
                        NumberSequenceKeypoint.new(0.18, 0.42),
                        NumberSequenceKeypoint.new(0.42, 0.62),
                        NumberSequenceKeypoint.new(0.68, 0.82),
                        NumberSequenceKeypoint.new(0.88, 0.96),
                        NumberSequenceKeypoint.new(1.00, 1.00),
                    }),
                }),
            })
            -- Barra de destaque à esquerda, só aparece quando o item está ativo.
            local accentBar = create("Frame", {
                BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0, 3, 0.58, 0), ZIndex = 6, Parent = itemBtn,
            }, { corner(9999) })
            local iconHolder = create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 34, 0.5, 0), Size = UDim2.new(0, 20, 0, 20), ZIndex = 5, Parent = itemBtn })
            local itemIcon = buildIcon(iconHolder, iconName, 20, Theme.TextDark)
            local itemLabel = create("TextLabel", {
                Text = scriptName, FontFace = Theme.FontMedium, TextSize = 16, TextColor3 = Theme.Text,
                BackgroundTransparency = 1, Position = UDim2.new(0, 62, 0, 0), Size = UDim2.new(1, -70, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = itemBtn,
            })
            itemBtn.MouseEnter:Connect(function()
                if accentBar.BackgroundTransparency ~= 0 then
                    itemBtn.BackgroundColor3 = Theme.CardHover
                    tween(itemBtn, { BackgroundTransparency = 0.92 }, 0.12, Enum.EasingStyle.Quint)
                    tween(itemLabel, { TextColor3 = Theme.Text }, 0.12)
                    setIconColor(itemIcon, Theme.Text, 0.12)
                end
            end)
            itemBtn.MouseLeave:Connect(function()
                if accentBar.BackgroundTransparency ~= 0 then
                    tween(itemBtn, { BackgroundTransparency = 1 }, 0.12)
                    tween(itemLabel, { TextColor3 = Theme.Text }, 0.12)
                    setIconColor(itemIcon, Theme.TextDark, 0.12)
                end
            end)
            local function openThisTab()
                return self_:_OpenTab(scriptName, function(holder, s, color) buildIcon(holder, iconName, s, color) end, contentBuilder, category, sidebarOrder, scriptName)
            end
            itemBtn.MouseButton1Click:Connect(openThisTab)

            table.insert(category._items, {
                _row = itemBtn,
                _name = scriptName,
                _open = openThisTab,
                _order = sidebarOrder,
                _accentBar = accentBar,
                _activeFade = activeFade,
                _icon = itemIcon,
                _label = itemLabel,
                _matchNames = { scriptName },
                Id = scriptConfig and (scriptConfig.Id or scriptConfig.Flag) or scriptName,
                Description = scriptConfig and scriptConfig.Description or nil,
            })
            return itemBtn
        end

        -- Adds a GROUP item to the sidebar: a single row (icon + name) that,
        -- when clicked, opens SEVERAL tabs at once in the topbar.
        -- Example: category:AddGroup("Visuals", "eye", {
        --     { Name = "Players", Build = function(tab) ... end },
        --     { Name = "NPCs",    Build = function(tab) ... end },
        -- })
        -- Clicking the group opens its sub-tabs together in the top bar.
        function category:AddGroup(groupName, iconName, subScripts)
            iconName = iconName or "file"
            local sidebarOrder = #category._items + 1
            local itemBtn = create("TextButton", {
                Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36), LayoutOrder = sidebarOrder, ZIndex = 4, Parent = itemsHolder,
            }, { corner(8) })
            local activeFade = create("Frame", {
                Name = "ActiveFade",
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.78,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
                ZIndex = 4,
                Parent = itemBtn,
            }, {
                corner(8),
                create("UIGradient", {
                    Rotation = 0,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0.00, 0.18),
                        NumberSequenceKeypoint.new(0.18, 0.28),
                        NumberSequenceKeypoint.new(0.42, 0.52),
                        NumberSequenceKeypoint.new(0.68, 0.78),
                        NumberSequenceKeypoint.new(0.88, 0.96),
                        NumberSequenceKeypoint.new(1.00, 1.00),
                    }),
                }),
            })
            local accentBar = create("Frame", {
                BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0, 3, 0.58, 0), ZIndex = 6, Parent = itemBtn,
            }, { corner(9999) })
            local iconHolder = create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 34, 0.5, 0), Size = UDim2.new(0, 20, 0, 20), ZIndex = 5, Parent = itemBtn })
            local itemIcon = buildIcon(iconHolder, iconName, 20, Theme.TextDark)
            local itemLabel = create("TextLabel", {
                Text = groupName, FontFace = Theme.FontMedium, TextSize = 16, TextColor3 = Theme.Text,
                BackgroundTransparency = 1, Position = UDim2.new(0, 62, 0, 0), Size = UDim2.new(1, -70, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = itemBtn,
            })
            itemBtn.MouseEnter:Connect(function()
                if accentBar.BackgroundTransparency ~= 0 then
                    itemBtn.BackgroundColor3 = Theme.CardHover
                    tween(itemBtn, { BackgroundTransparency = 0.88 }, 0.12, Enum.EasingStyle.Quint)
                    tween(itemLabel, { TextColor3 = Theme.Text }, 0.12)
                    setIconColor(itemIcon, Theme.Text, 0.12)
                end
            end)
            itemBtn.MouseLeave:Connect(function()
                if accentBar.BackgroundTransparency ~= 0 then
                    tween(itemBtn, { BackgroundTransparency = 1 }, 0.12)
                    tween(itemLabel, { TextColor3 = Theme.Text }, 0.12)
                    setIconColor(itemIcon, Theme.TextDark, 0.12)
                end
            end)

            local matchNames = {}
            for _, sub in ipairs(subScripts) do
                table.insert(matchNames, sub.Name)
                self_:RegisterKeybindDefinitions(
                    sub.Keybinds,
                    sub.Id or sub.Name or groupName
                )
            end

            local function openGroup()
                -- Fecha o item anterior inteiro antes de montar o novo grupo.
                -- Switching to another sidebar group closes the previous group.
                self_:_EnforceSingleSidebarItem(category, groupName)

                local firstTab
                for i, sub in ipairs(subScripts) do
                    -- ordens fracionárias: mantém as sub-tabs juntas e na
                    -- ordem certa, sem colidir com outros itens da sidebar.
                    local subOrder = sidebarOrder + (i - 1) * 0.1
                    local t = self_:_OpenTab(sub.Name, function(holder, s, color)
                        buildIcon(holder, sub.Icon or iconName, s, color)
                    end, sub.Build, category, subOrder, groupName)
                    if not firstTab then firstTab = t end
                end
                if firstTab then selectTab(firstTab) end
            end
            itemBtn.MouseButton1Click:Connect(openGroup)

            table.insert(category._items, {
                _row = itemBtn, _name = groupName, _open = openGroup, _order = sidebarOrder,
                _accentBar = accentBar, _activeFade = activeFade, _icon = itemIcon, _label = itemLabel, _matchNames = matchNames,
            })
            return itemBtn
        end

        -- Honor declarative category icons from CreateCategory({ Icon = "..." }).
        if categoryConfig and categoryConfig.Icon ~= nil then
            category:SetIcon(categoryConfig.Icon)
        end

        table.insert(self_.Categories, category)
        return category
    end


    function self_:AttachTooltip(target, tooltipText)
        attachTooltip(target, tooltipText)
        return target
    end

    function self_:AttachFunctionInfo(target, controlType, label, description, mode)
        return addFunctionInfoIcon(
            target,
            controlType,
            label,
            description,
            mode
        )
    end

    function self_:SetFunctionInfoEnabled(enabled)
        setFunctionInfoEnabled(enabled)

        if functionInfoToggle then
            functionInfoToggle.Set(enabled == true, false)
        end

        return self_
    end

    function self_:GetFunctionInfoEnabled()
        return self_._functionInfoEnabled == true
    end

    function self_:GetStore()
        return self_._store
    end

    function self_:ObserveFlag(flag, callback, fireImmediately)
        return self_:Track(
            Library:ObserveFlag(flag, callback, fireImmediately)
        )
    end

    function self_:GetFlag(flag)
        return Library:GetFlag(flag)
    end

    function self_:DismissNotification(id, immediate)
        return Library:DismissNotification(id, immediate)
    end

    function self_:DismissLatestNotification(immediate)
        return Library:DismissLatestNotification(immediate)
    end

    function self_:ClearNotifications()
        return Library:ClearNotifications()
    end

    function self_:SetNotificationSettings(settings)
        return Library:SetNotificationSettings(settings)
    end

    function self_:GetNotificationSettings()
        return Library:GetNotificationSettings()
    end

    function self_:UpdateNotification(id, changes)
        return Library:UpdateNotification(id, changes)
    end

    function self_:GetFlags()
        return Library:GetFlags()
    end

    function self_:SetFlag(flag, value, silent)
        return Library:SetFlag(flag, value, silent)
    end

    ------------------------------------------------------------
    -- QUALITY / PROFILER / DOCTOR / LEAK DIAGNOSTICS
    ------------------------------------------------------------
    local function countDictionary(tbl)
        local count = 0
        for _ in pairs(tbl or {}) do count += 1 end
        return count
    end

    function self_:SetProfilerEnabled(enabled)
        self_._profiler.Enabled = enabled == true
        return self_
    end

    function self_:IsProfilerEnabled()
        return self_._profiler.Enabled == true
    end

    function self_:Profile(name, callback, ...)
        if type(callback) ~= "function" then return false, "callback is not a function" end
        name = tostring(name or "Profile")
        local started = os.clock()
        local results = table.pack(pcall(callback, ...))
        local elapsed = os.clock() - started
        local profiler = self_._profiler
        profiler.Totals[name] = (profiler.Totals[name] or 0) + elapsed
        profiler.Counts[name] = (profiler.Counts[name] or 0) + 1
        self_._quality.ProfilerRuns += 1
        if profiler.Enabled then
            table.insert(profiler.Samples, { Name = name, Duration = elapsed, Time = os.clock() })
            while #profiler.Samples > profiler.MaxSamples do table.remove(profiler.Samples, 1) end
        end
        if not results[1] then
            Library:_RecordDiagnostic("Error", tostring(results[2]), { Operation = "Profile", Profile = name })
        end
        return table.unpack(results, 1, results.n)
    end

    function self_:GetProfilerSnapshot()
        local entries = {}
        for name, total in pairs(self_._profiler.Totals) do
            local count = self_._profiler.Counts[name] or 0
            table.insert(entries, {
                Name = name,
                Count = count,
                Total = total,
                Average = count > 0 and total / count or 0,
            })
        end
        table.sort(entries, function(a, b) return a.Total > b.Total end)
        local samples = {}
        for i, sample in ipairs(self_._profiler.Samples) do samples[i] = diagnosticCopy(sample) end
        return { Enabled = self_._profiler.Enabled, Entries = entries, Samples = samples }
    end

    function self_:ClearProfiler()
        table.clear(self_._profiler.Samples)
        table.clear(self_._profiler.Totals)
        table.clear(self_._profiler.Counts)
        return self_
    end

    function self_:CreateLeakSnapshot()
        local descendants = 0
        if self_._screenGui and self_._screenGui.Parent then
            descendants = #self_._screenGui:GetDescendants() + 1
        end
        local themeBindings = 0
        for instance in pairs(Library._themeBindings or {}) do
            if instance and instance.Parent then themeBindings += 1 end
        end
        return {
            Time = os.clock(),
            Instances = descendants,
            MaidTasks = self_._maid and self_._maid:Count() or 0,
            Components = #self_._components,
            Cards = #self_._cards,
            Tabs = #self_.Tabs,
            Categories = #self_.Categories,
            Keybinds = #self_._keybinds,
            Commands = countDictionary(self_._commands),
            Activities = #(self_._activities or {}),
            Overlays = self_._overlayManager and #(self_._overlayManager.Stack or {}) or 0,
            ThemeBindings = themeBindings,
            RegisteredFlagComponents = countDictionary(Library.ComponentsByFlag),
            ActiveNotifications = countDictionary(Library.ActiveNotifications),
        }
    end

    function self_:CompareLeakSnapshots(before, after)
        before = before or {}
        after = after or self_:CreateLeakSnapshot()
        local keys = { "Instances", "MaidTasks", "Components", "Cards", "Tabs", "Categories", "Keybinds", "Commands", "Activities", "Overlays", "ThemeBindings", "RegisteredFlagComponents", "ActiveNotifications" }
        local delta = {}
        local positive = 0
        for _, key in ipairs(keys) do
            delta[key] = (tonumber(after[key]) or 0) - (tonumber(before[key]) or 0)
            if delta[key] > 0 then positive += delta[key] end
        end
        return { Before = diagnosticCopy(before), After = diagnosticCopy(after), Delta = delta, PotentialLeakUnits = positive, Clean = positive == 0 }
    end

    function self_:CaptureLayoutSnapshot()
        local snapshot = {}
        local function siblingIndex(instance)
            local parent = instance.Parent
            if not parent then return 1 end
            local index = 0
            for _, sibling in ipairs(parent:GetChildren()) do
                if sibling.Name == instance.Name and sibling.ClassName == instance.ClassName then
                    index += 1
                end
                if sibling == instance then return math.max(index, 1) end
            end
            return math.max(index, 1)
        end
        local function pathFor(instance)
            local parts = {}
            local current = instance
            while current and current ~= screenGui do
                table.insert(parts, 1, tostring(current.Name) .. "<" .. current.ClassName .. ">#" .. tostring(siblingIndex(current)))
                current = current.Parent
            end
            return table.concat(parts, "/")
        end
        for _, instance in ipairs(screenGui:GetDescendants()) do
            if instance:IsA("GuiObject") then
                local item = {
                    Path = pathFor(instance),
                    ClassName = instance.ClassName,
                    Visible = self_:_IsActuallyVisible(instance),
                    X = math.floor(instance.AbsolutePosition.X + 0.5),
                    Y = math.floor(instance.AbsolutePosition.Y + 0.5),
                    Width = math.floor(instance.AbsoluteSize.X + 0.5),
                    Height = math.floor(instance.AbsoluteSize.Y + 0.5),
                    ZIndex = instance.ZIndex,
                }
                if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
                    item.Text = instance.Text
                end
                table.insert(snapshot, item)
            end
        end
        table.sort(snapshot, function(a, b) return a.Path < b.Path end)
        return snapshot
    end

    function self_:CompareLayoutSnapshots(before, after, tolerance)
        before = before or {}
        after = after or self_:CaptureLayoutSnapshot()
        tolerance = math.max(0, tonumber(tolerance) or 1)
        local beforeMap, afterMap = {}, {}
        for _, item in ipairs(before) do beforeMap[item.Path] = item end
        for _, item in ipairs(after) do afterMap[item.Path] = item end
        local added, removed, changed = {}, {}, {}
        for path, item in pairs(beforeMap) do
            local nextItem = afterMap[path]
            if not nextItem then
                table.insert(removed, path)
            else
                local geometryChanged = math.abs((item.X or 0) - (nextItem.X or 0)) > tolerance
                    or math.abs((item.Y or 0) - (nextItem.Y or 0)) > tolerance
                    or math.abs((item.Width or 0) - (nextItem.Width or 0)) > tolerance
                    or math.abs((item.Height or 0) - (nextItem.Height or 0)) > tolerance
                local propertyChanged = item.Visible ~= nextItem.Visible or item.Text ~= nextItem.Text or item.ZIndex ~= nextItem.ZIndex
                if geometryChanged or propertyChanged then
                    table.insert(changed, { Path = path, Before = item, After = nextItem })
                end
            end
        end
        for path in pairs(afterMap) do if not beforeMap[path] then table.insert(added, path) end end
        table.sort(added); table.sort(removed); table.sort(changed, function(a,b) return a.Path < b.Path end)
        return {
            Equal = #added == 0 and #removed == 0 and #changed == 0,
            Added = added, Removed = removed, Changed = changed,
            BeforeCount = #before, AfterCount = #after, Tolerance = tolerance,
        }
    end

    function self_:Doctor(options)
        options = options or {}
        local checks, errors, warnings = {}, {}, {}
        local function add(name, ok, message, severity)
            table.insert(checks, { Name = name, Ok = ok == true, Message = message })
            if ok then return end
            if severity == "error" then table.insert(errors, message) else table.insert(warnings, message) end
        end

        local seenFlags = {}
        local duplicateFlags = {}
        local missingIds = 0
        local apiIssues = 0
        for _, component in ipairs(self_._components) do
            local flag = Library:_NormalizeFlag(component.Flag)
            local meta = self_._componentMeta[component] or {}
            if flag then
                if seenFlags[flag] and seenFlags[flag] ~= component then duplicateFlags[flag] = true end
                seenFlags[flag] = component
            end
            local kind = tostring(meta.Type or component.Type or "")
            local stateful = type(component.Get) == "function" or type(component.GetValue) == "function" or type(component.GetConfigValue) == "function"
            local idOptional = kind == "Viewport" or kind == "Video" or kind == "UIPassthrough"
                or kind == "Paragraph" or kind == "Status" or kind == "FormattedText" or kind == "ProgressBar"
            if stateful and meta.Id == nil and not idOptional then
                missingIds += 1
            end
            if stateful and (type(component.Set) ~= "function" and type(component.SetValue) ~= "function" and type(component.SetConfigValue) ~= "function") then
                apiIssues += 1
            end
            if stateful and type(component.SetSilent) ~= "function" and type(component.SetConfigValueSilent) ~= "function" then
                apiIssues += 1
            end
            if stateful and type(component.Reset) ~= "function" then
                apiIssues += 1
            end
            if type(component.SetVisible) ~= "function" or type(component.SetDisabled) ~= "function" or type(component.DestroyEvents) ~= "function" then
                apiIssues += 1
            end
        end
        local duplicateCount = countDictionary(duplicateFlags)
        add("Duplicate flags", duplicateCount == 0, duplicateCount == 0 and "No duplicate flags." or (tostring(duplicateCount) .. " duplicate flag(s)."), "error")
        add("Explicit IDs", missingIds == 0, missingIds == 0 and "Stateful controls use explicit IDs/flags." or (tostring(missingIds) .. " component(s) have no explicit ID/flag."), "warning")
        add("API contract", apiIssues == 0, apiIssues == 0 and "Component lifecycle contract is consistent." or (tostring(apiIssues) .. " component contract issue(s)."), "warning")

        local orphanKeybinds = 0
        for _, keybind in ipairs(self_._keybinds) do
            local instance = keybind and (keybind.Instance or keybind.Container)
            if typeof(instance) == "Instance" and instance.Parent == nil then orphanKeybinds += 1 end
        end
        add("Keybind registry", orphanKeybinds == 0, orphanKeybinds == 0 and "No orphan keybinds." or (tostring(orphanKeybinds) .. " orphan keybind(s)."), "warning")

        local badThemeBindings = 0
        for instance, bindings in pairs(Library._themeBindings or {}) do
            if instance and instance.Parent then
                for _, binding in pairs(bindings or {}) do
                    if not binding.Token or Theme[binding.Token] == nil then badThemeBindings += 1 end
                end
            end
        end
        add("Theme bindings", badThemeBindings == 0, badThemeBindings == 0 and "Theme bindings healthy." or (tostring(badThemeBindings) .. " invalid theme binding(s)."), "error")

        local overlayCount = self_._overlayManager and #(self_._overlayManager.Stack or {}) or 0
        local invalidOverlays = 0
        if self_._overlayManager then
            for _, overlay in ipairs(self_._overlayManager.Stack or {}) do
                local root = overlay and (overlay.Root or overlay.Instance or overlay.Panel)
                if typeof(root) == "Instance" and root.Parent == nil then invalidOverlays += 1 end
            end
        end
        add("Overlay stack", invalidOverlays == 0, invalidOverlays == 0 and ("Overlay stack healthy (" .. tostring(overlayCount) .. " open).") or (tostring(invalidOverlays) .. " invalid overlay(s)."), "error")

        local adapter = Library:GetStorageAdapter()
        local storageOk = type(adapter) == "table"
        if storageOk and type(adapter.IsAvailable) == "function" then
            local ok, available = pcall(adapter.IsAvailable, adapter)
            storageOk = ok and available ~= false
        end
        add(
            "Storage",
            storageOk,
            storageOk and ("Storage adapter available: " .. Library:GetStorageAdapterName())
                or "Persistent runtime storage is unavailable in this runtime.",
            "warning"
        )
        add("Config schema", (Library.SchemaVersion or 0) == 5, "Config schema " .. tostring(Library.SchemaVersion) .. " (v4 keeps schema 5 for backward compatibility).", "error")

        local diagnosticState = Library:GetDiagnostics()
        add("Callback errors", (diagnosticState.CallbackErrors or 0) == 0, (diagnosticState.CallbackErrors or 0) == 0 and "No callback errors recorded." or (tostring(diagnosticState.CallbackErrors) .. " callback error(s) recorded."), "warning")

        local score = math.clamp(100 - #errors * 12 - #warnings * 3, 0, 100)
        self_._quality.DoctorRuns += 1
        local report = {
            Score = score,
            Healthy = #errors == 0,
            Checks = checks,
            Errors = errors,
            Warnings = warnings,
            Snapshot = self_:CreateLeakSnapshot(),
            Diagnostics = diagnosticState,
        }
        if options.Print == true then
            print("[MistUI Doctor] " .. tostring(score) .. "/100")
            for _, check in ipairs(checks) do
                print(check.Ok and "[OK]" or "[!]", check.Name, check.Message)
            end
        end
        return report
    end

    function self_:RunQualitySuite(options)
        options = options or {}
        local tests = {}
        local function test(name, callback)
            local started = os.clock()
            local ok, result, detail = pcall(callback)
            local passed = ok and result ~= false
            table.insert(tests, {
                Name = name,
                Passed = passed,
                Detail = ok and tostring(detail or result or "ok") or tostring(result),
                Duration = os.clock() - started,
            })
            if not passed then
                Library:_RecordDiagnostic("Error", tostring(ok and detail or result), { Operation = "QualitySuite", Test = name })
            end
            return passed
        end

        test("Config validation", function()
            local ok, validation = self_:ValidateConfigData(buildConfigPayload())
            return ok, ok and "valid" or table.concat(validation.Errors or {}, ", ")
        end)

        test("Transaction rollback", function()
            local snapshot = buildConfigPayload()
            local begun, err = self_:BeginConfigTransaction("QualitySuiteRollback")
            if not begun then return false, err end
            Library:_UpdateFlagValue("__mist_quality_probe", true)
            local rolledBack, rollbackError = self_:RollbackConfigTransaction("quality probe")
            local restored = Library.Flags["__mist_quality_probe"] == nil
            return rolledBack and restored, rollbackError or (snapshot and "rollback ok")
        end)

        test("Component contracts", function()
            local issues = 0
            for _, component in ipairs(self_._components) do
                if type(component.SetVisible) ~= "function" or type(component.SetDisabled) ~= "function" or type(component.IsDestroyed) ~= "function" then
                    issues += 1
                end
            end
            return issues == 0, tostring(issues) .. " issue(s)"
        end)

        test("Profiler", function()
            local ok = self_:Profile("quality.noop", function() return true end)
            local snapshot = self_:GetProfilerSnapshot()
            return ok == true and #snapshot.Entries >= 1, "profiler recorded sample"
        end)

        test("Layout snapshot", function()
            local a = self_:CaptureLayoutSnapshot()
            local b = self_:CaptureLayoutSnapshot()
            local comparison = self_:CompareLayoutSnapshots(a, b, 1)
            return comparison.Equal, tostring(#comparison.Changed) .. " changed"
        end)

        test("Doctor", function()
            local doctor = self_:Doctor()
            return doctor.Healthy, "score=" .. tostring(doctor.Score)
        end)

        local passedCount = 0
        for _, item in ipairs(tests) do if item.Passed then passedCount += 1 end end
        local report = {
            Passed = passedCount == #tests,
            PassedCount = passedCount,
            Total = #tests,
            Score = #tests > 0 and math.floor((passedCount / #tests) * 100 + 0.5) or 100,
            Tests = tests,
            Doctor = self_:Doctor(),
            Snapshot = self_:CreateLeakSnapshot(),
        }
        if options.Print == true then
            print("[MistUI Quality Suite] " .. tostring(report.Score) .. "/100")
            for _, item in ipairs(tests) do
                print(item.Passed and "[PASS]" or "[FAIL]", item.Name, item.Detail)
            end
        end
        return report
    end

    function self_:AssertHealthy(minimumScore)
        minimumScore = math.clamp(tonumber(minimumScore) or 90, 0, 100)
        local report = self_:Doctor()
        assert(report.Healthy and report.Score >= minimumScore, "MistUI Doctor failed: " .. tostring(report.Score) .. "/100")
        return report
    end

    function self_:OpenDebugPanel(options)
        options = options or {}
        local modal = self_:CreateModal({
            Size = options.Size or UDim2.new(0, 600, 0, 500),
            Backdrop = true,
            BackdropTransparency = 0.72,
            CloseOnBackdrop = true,
        })
        modal:SetTitle(options.Title or "Mist Developer Tools")

        local status = create("TextLabel", {
            Text = "",
            FontFace = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Field,
            BackgroundTransparency = 0.12,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 1,
            ZIndex = modal.Panel.ZIndex + 1,
            Parent = modal.Panel,
        }, { corner(8), padding(12) })

        local function refresh()
            local state = self_:GetDebugState()
            local doctor = self_:Doctor()
            local topProfile = self_:GetProfilerSnapshot().Entries[1]
            status.Text = table.concat({
                "MistUI " .. tostring(state.Version) .. "   Doctor: " .. tostring(doctor.Score) .. "/100",
                "Instances: " .. tostring(state.Instances) .. "   Maid: " .. tostring(state.MaidTasks) .. "   Components: " .. tostring(state.Components),
                "Tabs: " .. tostring(state.Tabs) .. "   Cards: " .. tostring(state.Cards) .. "   Keybinds: " .. tostring(state.Keybinds) .. "   Overlays: " .. tostring(state.Overlays),
                "Theme bindings: " .. tostring(state.ThemeBindings) .. "   Commands: " .. tostring(state.Commands) .. "   Notifications: " .. tostring(state.ActiveNotifications),
                "Callback errors: " .. tostring(state.CallbackErrors) .. "   Config rollbacks: " .. tostring(self_._quality.ConfigRollbacks),
                topProfile and ("Top profile: " .. topProfile.Name .. string.format(" %.3fms avg", topProfile.Average * 1000)) or "Top profile: no samples",
                #doctor.Warnings > 0 and ("Warnings: " .. table.concat(doctor.Warnings, " | ")) or "Warnings: none",
            }, "\n")
        end

        local buttons = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            LayoutOrder = 2,
            Parent = modal.Panel,
        }, { create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
        local function debugButton(text, order, callback)
            local button = makeButton(buttons, text, "secondary", nil, 32, callback)
            button.Size = UDim2.new(0, 150, 0, 32)
            button.LayoutOrder = order
            return button
        end
        debugButton("Refresh", 1, refresh)
        debugButton("Clear Errors", 2, function() Library:ClearDiagnostics(); refresh() end)
        debugButton("Clear Profiler", 3, function() self_:ClearProfiler(); refresh() end)
        refresh()
        return modal
    end

    function self_:GetDebugState()
        local commandCount = 0
        for _ in pairs(self_._commands) do
            commandCount += 1
        end

        local activeNotificationCount = 0
        for _ in pairs(Library.ActiveNotifications or {}) do
            activeNotificationCount += 1
        end

        local leak = self_:CreateLeakSnapshot()
        local diagnostics = Library:GetDiagnostics()
        return {
            Version = Library.Version,
            SchemaVersion = Library.SchemaVersion,
            Flags = Library:GetFlags(),
            Components = #self_._components,
            Cards = #self_._cards,
            Tabs = #self_.Tabs,
            Categories = #self_.Categories,
            Keybinds = #self_._keybinds,
            Commands = commandCount,
            Activities = #(self_._activities or {}),
            ActiveNotifications = activeNotificationCount,
            Instances = leak.Instances,
            MaidTasks = leak.MaidTasks,
            Overlays = leak.Overlays,
            ThemeBindings = leak.ThemeBindings,
            RegisteredFlagComponents = leak.RegisteredFlagComponents,
            CallbackErrors = diagnostics.CallbackErrors or 0,
            SafeCalls = diagnostics.SafeCalls or 0,
            Quality = diagnosticCopy(self_._quality),
        }
    end

    ------------------------------------------------------------
    -- COMMAND REGISTRY / COMMAND PALETTE
    ------------------------------------------------------------
    function self_:RegisterCommand(command, callback)
        local cfg
        if type(command) == "table" then
            cfg = {}
            for k, v in pairs(command) do cfg[k] = v end
        else
            cfg = {
                Id = tostring(command or "Command"),
                Name = tostring(command or "Command"),
                Callback = callback,
            }
        end

        local name = tostring(cfg.Name or cfg.Text or cfg.Id or "Command")
        local id = tostring(cfg.Id or name):gsub("^%s+", ""):gsub("%s+$", "")
        if id == "" then id = name end

        local keywords = cfg.Keywords or {}
        if type(keywords) == "string" then
            local parsed = {}
            for token in string.gmatch(keywords, "[^,%s]+") do table.insert(parsed, token) end
            keywords = parsed
        elseif type(keywords) ~= "table" then
            keywords = {}
        end

        local entry = self_._commands[id]
        if not entry then
            entry = {
                Id = id,
                Name = name,
                Description = tostring(cfg.Description or cfg.Subtitle or ""),
                Keywords = keywords,
                Callback = cfg.Callback or callback,
                Enabled = cfg.Enabled ~= false,
                Order = tonumber(cfg.Order) or 0,
            }
            self_._commands[id] = entry
        else
            entry.Name = name
            entry.Description = tostring(cfg.Description or cfg.Subtitle or entry.Description or "")
            entry.Keywords = keywords
            entry.Callback = cfg.Callback or callback or entry.Callback
            entry.Enabled = cfg.Enabled ~= false
            entry.Order = tonumber(cfg.Order) or entry.Order or 0
        end

        function entry:Run(...)
            if self.Enabled == false then
                return false, "Command is disabled."
            end
            if type(self.Callback) ~= "function" then
                return false, "Command has no callback."
            end
            return Library:SafeCall(self.Callback, ...)
        end

        function entry:SetEnabled(enabled)
            self.Enabled = enabled ~= false
            return self
        end

        function entry:Destroy()
            if self_._commands[self.Id] == self then
                self_._commands[self.Id] = nil
            end
        end

        return entry
    end

    function self_:UnregisterCommand(id)
        id = tostring(id or "")
        if self_._commands[id] then
            self_._commands[id] = nil
            return true
        end
        return false
    end

    function self_:GetCommands()
        local out = {}
        for _, command in pairs(self_._commands) do
            table.insert(out, command)
        end
        table.sort(out, function(a, b)
            if (a.Order or 0) == (b.Order or 0) then
                return string.lower(a.Name or "") < string.lower(b.Name or "")
            end
            return (a.Order or 0) < (b.Order or 0)
        end)
        return out
    end

    function self_:SearchCommands(query)
        query = string.lower(tostring(query or ""))
        query = query:gsub("^%s+", ""):gsub("%s+$", "")

        local function score(command)
            if command.Enabled == false then return nil end
            if query == "" then return 0 end

            local haystack = string.lower(table.concat({
                tostring(command.Name or ""),
                tostring(command.Description or ""),
                table.concat(command.Keywords or {}, " "),
            }, " "))

            local direct = string.find(haystack, query, 1, true)
            if direct then return 2000 - direct end

            local cursor = 1
            local fuzzy = 0
            for i = 1, #query do
                local ch = query:sub(i, i)
                local found = string.find(haystack, ch, cursor, true)
                if not found then return nil end
                fuzzy += math.max(1, 40 - (found - cursor))
                cursor = found + 1
            end
            return fuzzy
        end

        local results = {}
        for _, command in pairs(self_._commands) do
            local rank = score(command)
            if rank ~= nil then
                table.insert(results, { Command = command, Score = rank })
            end
        end

        table.sort(results, function(a, b)
            if a.Score == b.Score then
                return string.lower(a.Command.Name or "") < string.lower(b.Command.Name or "")
            end
            return a.Score > b.Score
        end)

        local commands = {}
        for i, result in ipairs(results) do commands[i] = result.Command end
        return commands
    end

    function self_:RunCommand(id, ...)
        local command = self_._commands[tostring(id or "")]
        if not command then
            return false, "Unknown command."
        end
        return command:Run(...)
    end

    function self_:OpenCommandPalette(options)
        options = options or {}
        local maxResults = math.max(1, math.floor(tonumber(options.MaxResults) or 6))
        local rowHeight = 46
        local rowGap = 4
        local panelWidth = tonumber(options.Width) or 500

        local modal = self_:CreateModal({
            Size = UDim2.new(0, panelWidth, 0, 190),
            Backdrop = true,
            BackdropTransparency = 0.76,
            CloseOnBackdrop = true,
            AutoFocus = false,
            Radius = 11,
            Padding = 14,
        })
        modal:SetTitle(options.Title or "Command palette")

        local search = create("TextBox", {
            Text = "",
            PlaceholderText = options.Placeholder or "Search commands...",
            ClearTextOnFocus = false,
            Selectable = false,
            FontFace = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.TextDimmer,
            BackgroundColor3 = Theme.Field,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            LayoutOrder = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = modal.Panel.ZIndex + 1,
            Parent = modal.Panel,
        }, { corner(8), padding(11) })

        local list = create("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 48),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.TextDimmer,
            LayoutOrder = 2,
            ZIndex = modal.Panel.ZIndex + 1,
            Parent = modal.Panel,
        }, {
            create("UIListLayout", {
                Padding = UDim.new(0, rowGap),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        local firstCommand = nil
        local function resizePalette(count)
            local visibleCount = math.max(1, math.min(count, maxResults))
            local listHeight = count == 0 and 40 or (visibleCount * rowHeight + math.max(0, visibleCount - 1) * rowGap)
            list.Size = UDim2.new(1, 0, 0, listHeight)
            list.CanvasSize = UDim2.new(0, 0, 0, count * rowHeight + math.max(0, count - 1) * rowGap)
            local panelHeight = math.clamp(102 + listHeight, 148, 402)
            modal.Panel.Size = UDim2.new(0, panelWidth, 0, panelHeight)
        end

        local function rebuild()
            for _, child in ipairs(list:GetChildren()) do
                if not child:IsA("UIListLayout") then child:Destroy() end
            end
            firstCommand = nil
            local results = self_:SearchCommands(search.Text)
            local rendered = math.min(#results, maxResults)

            if rendered == 0 then
                create("TextLabel", {
                    Text = "No commands found",
                    FontFace = Theme.Font,
                    TextSize = 12,
                    TextColor3 = Theme.TextDimmer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    LayoutOrder = 1,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = modal.Panel.ZIndex + 2,
                    Parent = list,
                })
                resizePalette(0)
                return
            end

            for i = 1, rendered do
                local command = results[i]
                if not firstCommand then firstCommand = command end
                local row = create("TextButton", {
                    Name = "CommandPaletteRow",
                    Text = "",
                    AutoButtonColor = false,
                    Selectable = false,
                    BackgroundColor3 = Theme.Field,
                    BackgroundTransparency = 0.18,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -3, 0, rowHeight),
                    LayoutOrder = i,
                    ZIndex = modal.Panel.ZIndex + 2,
                    Parent = list,
                }, { corner(7) })

                create("TextLabel", {
                    Text = tostring(command.Name or command.Id),
                    FontFace = Theme.FontSemibold,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 17),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = row.ZIndex + 1,
                    Parent = row,
                })
                create("TextLabel", {
                    Text = tostring(command.Description or ""),
                    FontFace = Theme.Font,
                    TextSize = 11,
                    TextColor3 = Theme.TextDimmer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 24),
                    Size = UDim2.new(1, -20, 0, 15),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = row.ZIndex + 1,
                    Parent = row,
                })
                row.MouseEnter:Connect(function()
                    smoothTween(row, { BackgroundTransparency = 0, BackgroundColor3 = Theme.FieldHover }, MOTION.Fast)
                end)
                row.MouseLeave:Connect(function()
                    smoothTween(row, { BackgroundTransparency = 0.18, BackgroundColor3 = Theme.Field }, MOTION.Fast)
                end)
                row.MouseButton1Click:Connect(function()
                    command:Run()
                    if options.CloseOnRun ~= false then modal:Close() end
                end)
            end
            resizePalette(rendered)
        end

        search:GetPropertyChangedSignal("Text"):Connect(rebuild)
        search.FocusLost:Connect(function(enterPressed)
            if enterPressed and firstCommand then
                firstCommand:Run()
                if options.CloseOnRun ~= false then modal:Close() end
            end
        end)
        rebuild()
        task.defer(function() pcall(function() search:CaptureFocus() end) end)
        return modal
    end

    function self_:CreateVirtualList(parent, items, rowHeight, renderRow)
        items = items or {}
        rowHeight = math.max(16, tonumber(rowHeight) or 30)
        local scroller = create("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, #items * rowHeight),
            ScrollBarThickness = 0,
            Parent = parent,
        })
        local pool = {}
        local api = { Instance = scroller, Items = items }
        local function refresh()
            local height = math.max(scroller.AbsoluteSize.Y, rowHeight)
            local first = math.max(1, math.floor(scroller.CanvasPosition.Y / rowHeight) + 1)
            local count = math.ceil(height / rowHeight) + 2
            for i = 1, count do
                local itemIndex = first + i - 1
                local row = pool[i]
                if itemIndex <= #items then
                    if not row then
                        row = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,rowHeight), Parent = scroller })
                        pool[i] = row
                    end
                    row.Visible = true
                    row.Position = UDim2.new(0,0,0,(itemIndex-1)*rowHeight)
                    for _, child in ipairs(row:GetChildren()) do child:Destroy() end
                    if type(renderRow) == "function" then Library:SafeCall(renderRow, row, items[itemIndex], itemIndex) end
                elseif row then
                    row.Visible = false
                end
            end
        end
        scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(refresh)
        scroller:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
        function api:SetItems(newItems)
            items = newItems or {}; api.Items = items; scroller.CanvasSize = UDim2.new(0,0,0,#items*rowHeight); refresh(); return api
        end
        function api:Refresh() refresh(); return api end
        refresh()
        return api
    end

    function self_:Unload()
        if self_._destroyed then return true end
        local unloadBefore = self_:CreateLeakSnapshot()
        self_._destroyed = true

        if self_._overlayManager then
            local guard = 0
            while #(self_._overlayManager.Stack or {}) > 0 and guard < 128 do
                guard += 1
                local before = #(self_._overlayManager.Stack or {})
                local ok = pcall(function()
                    self_._overlayManager:CloseTop()
                end)
                local after = #(self_._overlayManager.Stack or {})
                if not ok or after >= before then
                    table.remove(self_._overlayManager.Stack)
                end
            end
        end

        if type(Library.ClearNotifications) == "function" then
            pcall(function()
                Library:ClearNotifications()
            end)
        end

        if type(self_.CloseActivities) == "function" then
            pcall(function() self_:CloseActivities(true) end)
        end

        if self_._store then
            self_._store:Destroy()
            self_._store = nil
        end

        -- Remove global component registry references before destroying instances.
        -- ComponentsByFlag is strong; leaving entries here would retain the entire UI.
        for _, component in ipairs(self_._components or {}) do
            if type(component) == "table" then
                local flag = Library:_NormalizeFlag(component.Flag)
                if flag and Library.ComponentsByFlag[flag] == component then
                    Library.ComponentsByFlag[flag] = nil
                end
                if flag and Library._flagSignals and Library._flagSignals[flag] then
                    pcall(function() Library._flagSignals[flag]:Destroy() end)
                    Library._flagSignals[flag] = nil
                end
                if type(component.DestroyEvents) == "function" then
                    pcall(function() component:DestroyEvents() end)
                end
                if component.Changed and type(component.Changed.Destroy) == "function" then
                    pcall(function() component.Changed:Destroy() end)
                end
                component._mistDestroyed = true
            end
        end

        if self_._maid then
            self_._maid:Cleanup()
        end

        for _, signal in pairs(self_._events or {}) do
            if type(signal) == "table" and type(signal.Destroy) == "function" then
                pcall(function()
                    signal:Destroy()
                end)
            end
        end

        if self_._screenGui and self_._screenGui.Parent then
            self_._screenGui:Destroy()
        end

        if Library._screenGui == self_._screenGui then
            Library._screenGui = nil
        end

        if Library._activeWindow == self_ then
            Library._activeWindow = nil
        end

        table.clear(self_._components)
        table.clear(self_._componentMeta)
        table.clear(self_._cards)
        table.clear(self_._keybinds)
        table.clear(self_._commands)
        table.clear(self_.Tabs)
        table.clear(self_.Categories)
        self_._configTransaction = nil

        local unloadAfter = self_:CreateLeakSnapshot()
        self_._lastUnloadReport = self_:CompareLeakSnapshots(unloadBefore, unloadAfter)
        return true
    end

    function self_:GetLastUnloadReport()
        return self_._lastUnloadReport and diagnosticCopy(self_._lastUnloadReport) or nil
    end

    self_.Destroy = self_.Unload

    function self_:SetTheme(themeLike)
        if type(themeLike) == "string" then
            if themePresets and themePresets[themeLike] then
                applyThemePreset(themeLike, false)
                currentBaseTheme = themeLike
                return true
            end
            return false
        end

        if type(themeLike) == "table" then
            for key, value in pairs(themeLike) do
                local parsed = nil
                if typeof(value) == "Color3" then
                    parsed = value
                elseif type(value) == "string" then
                    parsed = parseHex(value)
                end
                if parsed and Theme[key] ~= nil then
                    setThemeColor(key, parsed)
                end
            end
            return true
        end

        return false
    end

    ------------------------------------------------------------
    -- PUBLIC THEME API
    ------------------------------------------------------------
    function self_:GetThemes()
        local names = {}
        for name in pairs(themePresets or {}) do table.insert(names, name) end
        for name in pairs(Library.ThemeRegistry or {}) do
            if not table.find(names, name) then table.insert(names, name) end
        end
        table.sort(names)
        return names
    end

    function self_:RegisterTheme(name, colors)
        name = tostring(name or "")
        if name == "" or type(colors) ~= "table" then return false end
        local normalized = {}
        for key, value in pairs(colors) do
            if typeof(value) == "Color3" then
                normalized[key] = colorToHex(value)
            elseif type(value) == "string" then
                normalized[key] = value
            end
        end
        Library.ThemeRegistry[name] = normalized
        themePresets[name] = normalized
        return true
    end

    function self_:RemoveTheme(name)
        name = tostring(name or "")
        if name == "Default" then return false end
        Library.ThemeRegistry[name] = nil
        if themePresets then themePresets[name] = nil end
        return true
    end

    function self_:ExportTheme(name)
        name = name or currentBaseTheme
        local payload = { Name = name, BaseTheme = currentBaseTheme, Colors = {} }
        if name and themePresets[name] then
            for key, value in pairs(themePresets[name]) do payload.Colors[key] = value end
        else
            for _, definition in ipairs(themeColorDefinitions or {}) do
                payload.Colors[definition.Key] = colorToHex(Theme[definition.Key])
            end
        end
        return game:GetService("HttpService"):JSONEncode(payload)
    end

    function self_:ImportTheme(json, applyNow)
        local ok, payload = pcall(function()
            return game:GetService("HttpService"):JSONDecode(tostring(json or ""))
        end)
        if not ok or type(payload) ~= "table" or type(payload.Colors) ~= "table" then
            return false, "Invalid theme JSON."
        end
        local name = tostring(payload.Name or "Imported")
        self_:RegisterTheme(name, payload.Colors)
        if applyNow ~= false then
            self_:SetTheme(name)
        end
        return true, name
    end

    function self_:ResetTheme()
        return self_:SetTheme("Default")
    end

    function self_:SetAccent(color)
        return self_:SetTheme({ Accent = color })
    end

    function self_:Confirm(config)
        config = config or {}
        local modal = self_:CreateModal({
            Size = UDim2.new(0, 380, 0, 150),
            Backdrop = true,
            BackdropTransparency = 0.72,
            CloseOnBackdrop = config.CloseOnOverlayClick == true,
            AutoFocus = false,
            Radius = 11,
            Padding = 16,
        })
        modal:SetTitle(config.Title or "Confirm")

        modal:AddText(config.Content or "Are you sure?")

        local actionRow = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            LayoutOrder = 1000,
            ZIndex = modal.Panel.ZIndex + 2,
            Parent = modal.Panel,
        }, {
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        local cancelHolder = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 92, 0, 34),
            LayoutOrder = 1,
            ZIndex = modal.Panel.ZIndex + 2,
            Parent = actionRow,
        })
        local confirmHolder = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 104, 0, 34),
            LayoutOrder = 2,
            ZIndex = modal.Panel.ZIndex + 2,
            Parent = actionRow,
        })

        local cancelButton = makeButton(cancelHolder, config.CancelText or "Cancel", "secondary", 92, 34, function()
            modal:Close()
            if type(config.OnCancel) == "function" then Library:SafeCall(config.OnCancel) end
        end)
        local confirmButton = makeButton(confirmHolder, config.ConfirmText or "Confirm", config.Variant or "danger", 104, 34, function()
            modal:Close()
            if type(config.OnConfirm) == "function" then Library:SafeCall(config.OnConfirm) end
        end)
        cancelButton.Selectable = false
        confirmButton.Selectable = false
        local cancelFocusStroke = cancelButton:FindFirstChild("MistFocusStroke")
        if cancelFocusStroke then cancelFocusStroke:Destroy() end
        local confirmFocusStroke = confirmButton:FindFirstChild("MistFocusStroke")
        if confirmFocusStroke then confirmFocusStroke:Destroy() end

        task.defer(function()
            if not modal.Panel or not modal.Panel.Parent then return end
            local layout = modal.Panel:FindFirstChildOfClass("UIListLayout")
            if layout then
                local height = math.clamp(layout.AbsoluteContentSize.Y + 32, 138, 220)
                modal.Panel.Size = UDim2.new(0, 380, 0, height)
            end
        end)

        modal.ConfirmButton = confirmButton
        modal.CancelButton = cancelButton
        modal.Modal = modal.Panel
        return modal
    end

    ------------------------------------------------------------
    -- OPTIONAL MOBILE / TOUCH TOGGLE
    ------------------------------------------------------------
    function self_:IsTouchDevice()
        return UserInputService.TouchEnabled == true
    end

    function self_:SetMobileToggleEnabled(enabled, options)
        options = options or {}
        enabled = enabled == true

        if not enabled then
            if self_._mobileToggleButton then
                self_._mobileToggleButton:Destroy()
                self_._mobileToggleButton = nil
            end
            return self_
        end

        if self_._mobileToggleButton and self_._mobileToggleButton.Parent then
            return self_
        end

        local side = string.lower(tostring(options.Side or config.MobileToggleSide or "right"))
        local xScale = side == "left" and 0 or 1
        local xOffset = side == "left" and 18 or -18
        local anchorX = side == "left" and 0 or 1

        local button = create("TextButton", {
            Name = "MistMobileToggle",
            Text = tostring(options.Text or "M"),
            FontFace = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(anchorX, 0.5),
            Position = UDim2.new(xScale, xOffset, 0.55, 0),
            Size = UDim2.new(0, 44, 0, 44),
            ZIndex = 10000,
            Parent = screenGui,
        }, { corner(12), stroke(Theme.StrokeTabBar, 1, 0.2) })

        local scale = create("UIScale", { Scale = 1, Parent = button })
        button.MouseEnter:Connect(function()
            smoothTween(button, { BackgroundColor3 = Theme.CardHover }, MOTION.Fast)
            smoothTween(scale, { Scale = 1.04 }, MOTION.Fast)
        end)
        button.MouseLeave:Connect(function()
            smoothTween(button, { BackgroundColor3 = Theme.Card }, MOTION.Fast)
            smoothTween(scale, { Scale = 1 }, MOTION.Fast)
        end)
        button.MouseButton1Click:Connect(function()
            self_:Toggle()
        end)

        dragController:Attach(button, button)
        self_._mobileToggleButton = button
        return self_
    end

    function self_:SetMobileToggleSide(side)
        local button = self_._mobileToggleButton
        if not button then return self_ end
        side = string.lower(tostring(side or "right"))
        if side == "left" then
            button.AnchorPoint = Vector2.new(0, 0.5)
            button.Position = UDim2.new(0, 18, button.Position.Y.Scale, button.Position.Y.Offset)
        else
            button.AnchorPoint = Vector2.new(1, 0.5)
            button.Position = UDim2.new(1, -18, button.Position.Y.Scale, button.Position.Y.Offset)
        end
        return self_
    end

    self_:EnableResponsive(config.Responsive ~= false)
    self_:SetKeyboardNavigationEnabled(config.KeyboardNavigation ~= false)
    self_:SetGamepadNavigationEnabled(config.GamepadNavigation ~= false)
    self_:SetResizable(false)
    if config.MobileToggle == true then
        self_:SetMobileToggleEnabled(true, { Side = config.MobileToggleSide })
    end

    return self_
end


------------------------------------------------------------
-- CARD API (reused for tab content)
------------------------------------------------------------
function Library:_AttachCardAPI(tab, page)
    local window = self
    function tab:CreateRow()
        local row = create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 2, Parent = page,
        }, {
            create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }),
        })

        local rowApi = {
            Frame = row,
            Cards = {},
        }
        tab._rows = tab._rows or {}
        table.insert(tab._rows, rowApi)
        local rowLayout = row:FindFirstChildOfClass("UIListLayout")

        function rowApi:SetSpacing(pixels)
            if rowLayout then rowLayout.Padding = UDim.new(0, tonumber(pixels) or 14) end
            return rowApi
        end

        function rowApi:SetAlignment(alignment)
            if not rowLayout then return rowApi end
            local value = string.lower(tostring(alignment or "left"))
            if value == "center" then rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            elseif value == "right" then rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            else rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left end
            return rowApi
        end

        function rowApi:SetColumns(columns)
            columns = math.max(1, math.floor(tonumber(columns) or 1))
            local paddingPixels = rowLayout and rowLayout.Padding.Offset or 14
            for _, cardApi in ipairs(rowApi.Cards) do
                if cardApi and cardApi.Frame and cardApi.Frame.Parent == row then
                    cardApi:SetWidth(1 / columns)
                    cardApi.Frame.Size = UDim2.new(1 / columns, -paddingPixels, 0, cardApi.Frame.Size.Y.Offset)
                end
            end
            return rowApi
        end

        function rowApi:Reflow()
            local order = 0
            for _, cardApi in ipairs(rowApi.Cards) do
                if cardApi and cardApi.Frame and cardApi.Frame.Parent == row then
                    order += 1
                    cardApi.Frame.LayoutOrder = order
                end
            end
            return rowApi
        end

        function rowApi:Destroy()
            if row and row.Parent then row:Destroy() end
        end

        local cardCount = 0
        local sideCards = {
            Left = nil,
            Right = nil,
        }
        local rightSpacer = nil

        -- AddCard layout examples:
        --
        -- Legacy:
        -- row:AddCard("Example", nil, 0.5)
        --
        -- New:
        -- row:AddCard("Example", nil, { Side = "Left", Size = "Half" })
        -- row:AddCard("Example", nil, { Side = "Right", Size = "Half" })
        -- row:AddCard("Example", nil, { Size = "Full" })
        -- row:AddCard("Example", nil, { Width = 0.70 })
        --
        -- Size values:
        -- "Half" = half-width card
        -- "Full" / "Large" / "Wide" = full-width rectangle
        --
        -- Runtime helpers:
        -- card:SetSide("Left" / "Right")
        -- card:SetSize("Half" / "Full")
        -- card:SetWidth(0.35 to 1)
        local function resolveCardLayout(layout)
            local width = 1
            local side = nil

            if type(layout) == "number" then
                width = math.clamp(layout, 0.10, 1)
            elseif type(layout) == "string" then
                local value = string.lower(layout)

                if value == "left" then
                    side = "Left"
                    width = 0.5
                elseif value == "right" then
                    side = "Right"
                    width = 0.5
                elseif value == "half" or value == "normal" or value == "small" then
                    width = 0.5
                elseif value == "full" or value == "large" or value == "wide" or value == "big" then
                    width = 1
                end
            elseif type(layout) == "table" then
                local requestedSide = layout.Side or layout.side
                if requestedSide ~= nil then
                    requestedSide = string.lower(tostring(requestedSide))
                    if requestedSide == "left" then
                        side = "Left"
                    elseif requestedSide == "right" then
                        side = "Right"
                    end
                end

                local requestedSize = layout.Size or layout.size
                if requestedSize ~= nil then
                    requestedSize = string.lower(tostring(requestedSize))
                    if requestedSize == "half"
                        or requestedSize == "normal"
                        or requestedSize == "small" then
                        width = 0.5
                    elseif requestedSize == "full"
                        or requestedSize == "large"
                        or requestedSize == "wide"
                        or requestedSize == "big" then
                        width = 1
                    end
                end

                local customWidth = tonumber(layout.Width or layout.width)
                if customWidth then
                    width = math.clamp(customWidth, 0.10, 1)
                end

                -- Selecting a side implies a half-width card unless a custom/full
                -- width was explicitly requested.
                if side and requestedSize == nil and customWidth == nil then
                    width = 0.5
                end
            end

            if width >= 0.99 then
                side = nil
                width = 1
            end

            return width, side
        end

        local function ensureRightSpacer()
            if rightSpacer and rightSpacer.Parent then
                return
            end

            rightSpacer = create("Frame", {
                Name = "RightCardSpacer",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -8, 0, 1),
                LayoutOrder = 1,
                ZIndex = 1,
                Parent = row,
            })
        end

        local function removeRightSpacer()
            if rightSpacer then
                rightSpacer:Destroy()
                rightSpacer = nil
            end
        end

        function rowApi:AddCard(title, subtitle, layout)
            cardCount = cardCount + 1

            local widthFraction, requestedSide = resolveCardLayout(layout)
            local layoutOrder = cardCount

            if widthFraction < 0.99 and requestedSide == "Left" then
                layoutOrder = 1
                sideCards.Left = true
                removeRightSpacer()
            elseif widthFraction < 0.99 and requestedSide == "Right" then
                layoutOrder = 2
                sideCards.Right = true

                if not sideCards.Left then
                    ensureRightSpacer()
                end
            end

            local card = create("Frame", {
                BackgroundColor3 = Theme.Card,
                Size = UDim2.new(widthFraction, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = layoutOrder,
                ZIndex = 2,
                Parent = row,
            }, { corner(10), stroke(Theme.StrokeSoft, 1, 0.70), padding(15) })

            create("UIListLayout", { Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder }).Parent = card
            card.MouseEnter:Connect(function()
                smoothTween(card, { BackgroundColor3 = shadeColor(Theme.Card, 1.025) }, 0.22)
            end)
            card.MouseLeave:Connect(function()
                smoothTween(card, { BackgroundColor3 = Theme.Card }, 0.24)
            end)

            local cardTitleLabel = nil
            if title then
                cardTitleLabel = create("TextLabel", {
                    Text = title, FontFace = Theme.FontSemibold, TextSize = 16, TextColor3 = Theme.Text,
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 0,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = card,
                })
            end

            -- Global UI preference:
            -- subtitles are intentionally disabled for all cards,
            -- so no subtitle label or subtitle spacing is created.

            local cardApi = {
                Frame = card,
                Side = requestedSide,
                Width = widthFraction,
                PreferredWidth = widthFraction,
                PreferredSide = requestedSide,
                Row = rowApi,
                Components = {},
            }

            if cardTitleLabel then
                local activeWindow = Library._activeWindow
                if activeWindow
                    and type(activeWindow.AttachFunctionInfo) == "function" then
                    cardApi.InfoIcon = activeWindow:AttachFunctionInfo(
                        cardTitleLabel,
                        "Function",
                        title,
                        subtitle,
                        "title"
                    )
                end
            end

            table.insert(rowApi.Cards, cardApi)
            if Library._activeWindow then
                table.insert(Library._activeWindow._cards, cardApi)
            end

            if self._breakpoint then
                -- ApplyBreakpoint is declared below; defer until the current call stack ends.
                task.defer(function()
                    if cardApi.Frame and cardApi.Frame.Parent and type(cardApi.ApplyBreakpoint) == "function" then
                        cardApi:ApplyBreakpoint(self._breakpoint)
                    end
                end)
            end

            function cardApi:SetWidth(newWidth)
                newWidth = math.clamp(tonumber(newWidth) or widthFraction, 0.10, 1)
                widthFraction = newWidth
                cardApi.Width = newWidth
                if cardApi._responsiveApplying ~= true then
                    cardApi.PreferredWidth = newWidth
                end

                if newWidth >= 0.99 then
                    cardApi.Side = nil
                    if cardApi._responsiveApplying ~= true then
                        requestedSide = nil
                        cardApi.PreferredSide = nil
                    end
                    removeRightSpacer()
                end

                smoothTween(card, {
                    Size = UDim2.new(newWidth, -8, 0, 0),
                }, MOTION.Normal)
            end

            function cardApi:ApplyBreakpoint(breakpoint)
                cardApi._responsiveApplying = true
                if breakpoint == "Compact" then
                    cardApi:SetWidth(1)
                else
                    cardApi:SetWidth(cardApi.PreferredWidth or 1)
                    if (cardApi.PreferredWidth or 1) < 0.99 and cardApi.PreferredSide then
                        cardApi:SetSide(cardApi.PreferredSide)
                    end
                end
                cardApi._responsiveApplying = false
                return cardApi
            end

            function cardApi:SetSize(sizeName)
                local value = string.lower(tostring(sizeName or ""))

                if value == "half" or value == "normal" or value == "small" then
                    cardApi:SetWidth(0.5)
                elseif value == "full" or value == "large" or value == "wide" or value == "big" then
                    cardApi:SetWidth(1)
                end
            end

            function cardApi:SetSide(newSide)
                if widthFraction >= 0.99 then
                    return
                end

                local value = string.lower(tostring(newSide or ""))

                if value == "left" then
                    requestedSide = "Left"
                    cardApi.Side = "Left"
                    if cardApi._responsiveApplying ~= true then cardApi.PreferredSide = "Left" end
                    sideCards.Left = true
                    card.LayoutOrder = 1
                    removeRightSpacer()
                elseif value == "right" then
                    requestedSide = "Right"
                    cardApi.Side = "Right"
                    if cardApi._responsiveApplying ~= true then cardApi.PreferredSide = "Right" end
                    sideCards.Right = true
                    card.LayoutOrder = 2

                    if not sideCards.Left then
                        ensureRightSpacer()
                    end
                end
            end

            function cardApi:SetTitle(newTitle)
                title = tostring(newTitle or "")
                if not cardTitleLabel then
                    cardTitleLabel = create("TextLabel", {
                        Text = title,
                        FontFace = Theme.FontSemibold,
                        TextSize = 16,
                        TextColor3 = Theme.Text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        LayoutOrder = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 2,
                        Parent = card,
                    })
                else
                    cardTitleLabel.Text = title
                end
                return cardApi
            end

            function cardApi:GetTitle()
                return title
            end

            function cardApi:SetVisible(visible)
                card.Visible = visible ~= false
                return cardApi
            end

            function cardApi:Show()
                return cardApi:SetVisible(true)
            end

            function cardApi:Hide()
                return cardApi:SetVisible(false)
            end

            local cardDisableOverlay = nil
            function cardApi:SetDisabled(disabled)
                disabled = disabled == true

                if disabled and not cardDisableOverlay then
                    cardDisableOverlay = create("TextButton", {
                        Name = "CardDisabledOverlay",
                        Text = "",
                        AutoButtonColor = false,
                        BackgroundColor3 = Theme.Background,
                        BackgroundTransparency = 0.80,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 100,
                        Parent = card,
                    }, { corner(10) })
                end

                if cardDisableOverlay then
                    cardDisableOverlay.Visible = disabled
                end

                card:SetAttribute("Disabled", disabled)
                return cardApi
            end

            function cardApi:Enable()
                return cardApi:SetDisabled(false)
            end

            function cardApi:Disable()
                return cardApi:SetDisabled(true)
            end

            function cardApi:Destroy()
                if requestedSide == "Left" then
                    sideCards.Left = nil
                elseif requestedSide == "Right" then
                    sideCards.Right = nil
                end

                if card and card.Parent then
                    card:Destroy()
                end

                if sideCards.Right and not sideCards.Left then
                    ensureRightSpacer()
                else
                    removeRightSpacer()
                end
            end

            function cardApi:SetOrder(orderValue)
                card.LayoutOrder = tonumber(orderValue) or card.LayoutOrder
                return cardApi
            end

            function cardApi:MoveBefore(otherCard)
                if otherCard and otherCard.Frame then
                    card.LayoutOrder = otherCard.Frame.LayoutOrder - 1
                end
                return cardApi
            end

            function cardApi:MoveAfter(otherCard)
                if otherCard and otherCard.Frame then
                    card.LayoutOrder = otherCard.Frame.LayoutOrder + 1
                end
                return cardApi
            end

            function cardApi:SetHeight(height)
                local h = tonumber(height)
                if h then
                    card.AutomaticSize = Enum.AutomaticSize.None
                    card.Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, math.max(24, h))
                else
                    card.AutomaticSize = Enum.AutomaticSize.Y
                end
                return cardApi
            end

            local collapsed = false
            local collapseVisibility = {}
            function cardApi:Collapse()
                if collapsed then return cardApi end
                collapsed = true
                for _, child in ipairs(card:GetChildren()) do
                    if child:IsA("GuiObject") and child ~= cardTitleLabel and child ~= cardDisableOverlay then
                        collapseVisibility[child] = child.Visible
                        child.Visible = false
                    end
                end
                return cardApi
            end

            function cardApi:Expand()
                if not collapsed then return cardApi end
                collapsed = false
                for child, wasVisible in pairs(collapseVisibility) do
                    if child and child.Parent == card then child.Visible = wasVisible end
                end
                table.clear(collapseVisibility)
                return cardApi
            end

            function cardApi:ToggleCollapsed()
                if collapsed then cardApi:Expand() else cardApi:Collapse() end
                return collapsed
            end

            function cardApi:IsCollapsed()
                return collapsed
            end

            local descriptionLabel = nil
            function cardApi:SetDescription(description)
                description = tostring(description or "")
                if description == "" then
                    if descriptionLabel then descriptionLabel:Destroy(); descriptionLabel = nil end
                    return cardApi
                end
                if not descriptionLabel then
                    descriptionLabel = create("TextLabel", {
                        Text = description,
                        FontFace = Theme.Font,
                        TextSize = 12,
                        TextColor3 = Theme.TextDark,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        LayoutOrder = 1,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 2,
                        Parent = card,
                    })
                else
                    descriptionLabel.Text = description
                end
                return cardApi
            end

            local cardIconHolder = nil
            function cardApi:SetIcon(iconName)
                if cardIconHolder then cardIconHolder:Destroy(); cardIconHolder = nil end
                if not iconName or tostring(iconName) == "" then return cardApi end
                cardIconHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 1),
                    Size = UDim2.new(0, 18, 0, 18),
                    ZIndex = 3,
                    Parent = card,
                })
                buildIcon(cardIconHolder, tostring(iconName), 16, Theme.TextDark)
                return cardApi
            end

            function cardApi:MoveToRow(newRow)
                if type(newRow) ~= "table" or not newRow.Frame then return false end
                card.Parent = newRow.Frame
                cardApi.Row = newRow
                if not table.find(newRow.Cards, cardApi) then table.insert(newRow.Cards, cardApi) end
                return true
            end

            function cardApi:GetComponents()
                local out = {}
                for i, component in ipairs(cardApi.Components) do out[i] = component end
                return out
            end

            local order = 10
            local function nextOrder() order = order + 1; return order end

            local function cleanFlagPart(value)
                local s = tostring(value or "Value")
                s = s:gsub("[^%w]+", "_")
                s = s:gsub("^_+", ""):gsub("_+$", "")
                if s == "" then s = "Value" end
                return s
            end

            local pageName = "Page"
            do
                local ancestor = card.Parent
                while ancestor do
                    if ancestor:IsA("ScrollingFrame") then
                        pageName = ancestor.Name:gsub("_Page$", "")
                        break
                    end
                    ancestor = ancestor.Parent
                end
            end

            local cardFlagPrefix = "Control."
                .. cleanFlagPart(pageName)
                .. "."
                .. cleanFlagPart(title or ("Card" .. tostring(cardCount)))

            local automaticFlagCounts = {}
            local explicitFlagOverride = nil

            local function automaticFlag(controlType, controlText)
                if explicitFlagOverride then
                    local flag = Library:_NormalizeFlag(explicitFlagOverride)
                    explicitFlagOverride = nil
                    if flag then return flag end
                end
                local base = cardFlagPrefix
                    .. "."
                    .. cleanFlagPart(controlType)
                    .. "."
                    .. cleanFlagPart(controlText)

                automaticFlagCounts[base] = (automaticFlagCounts[base] or 0) + 1
                if automaticFlagCounts[base] > 1 then
                    return base .. "." .. tostring(automaticFlagCounts[base])
                end
                return base
            end

            local function registerNormalControl(controlType, controlText, api)
                if type(api) == "table" then
                    local flag = automaticFlag(controlType, controlText)
                    api.Flag = flag
                    api.Type = controlType
                    api.Name = controlText

                    local root = api.Container
                    local blocker = nil

                    function api:SetVisible(visible)
                        if root and root:IsA("GuiObject") then
                            root.Visible = visible ~= false
                        end
                        return api
                    end

                    function api:Show()
                        return api:SetVisible(true)
                    end

                    function api:Hide()
                        return api:SetVisible(false)
                    end

                    function api:SetDisabled(disabled)
                        disabled = disabled == true

                        if root and root:IsA("GuiObject") then
                            if not blocker then
                                blocker = create("TextButton", {
                                    Name = "ControlDisabledOverlay",
                                    Text = "",
                                    AutoButtonColor = false,
                                    BackgroundColor3 = Theme.Background,
                                    BackgroundTransparency = 0.76,
                                    BorderSizePixel = 0,
                                    Active = true,
                                    Selectable = false,
                                    Visible = false,
                                    Size = UDim2.new(1, 0, 1, 0),
                                    ZIndex = 500,
                                    Parent = root,
                                }, { corner(6) })
                                pcall(function() blocker.Modal = true end)
                            end

                            blocker.Visible = disabled
                            root:SetAttribute("Disabled", disabled)

                            for _, inst in ipairs(root:GetDescendants()) do
                                if inst ~= blocker then
                                    if inst:IsA("GuiButton") then
                                        pcall(function() inst.Interactable = not disabled end)
                                        inst.Active = not disabled
                                    elseif inst:IsA("TextBox") then
                                        pcall(function() inst.TextEditable = not disabled end)
                                        inst.Active = not disabled
                                    end
                                end
                            end
                        end

                        return api
                    end

                    function api:Enable()
                        return api:SetDisabled(false)
                    end

                    function api:Disable()
                        return api:SetDisabled(true)
                    end

                    function api:Destroy()
                        for _, event in pairs(api._events or {}) do if event and event.Destroy then event:Destroy() end end
                        if root and root.Parent then
                            root:Destroy()
                        end
                    end

                    local getter = api.GetConfigValue or api.Get or api.GetValue
                    if type(getter) == "function" then
                        local okDefault, defaultValue = pcall(getter)
                        if okDefault then api.Default = defaultValue end
                    end

                    if type(api.Reset) ~= "function" then
                        function api:Reset()
                            local setter = api.SetSilent or api.Set
                            if type(setter) == "function" and api.Default ~= nil then
                                local ok = pcall(setter, api.Default)
                                if not ok then pcall(setter, api, api.Default) end
                                if type(api.Emit) == "function" then
                                    api:Emit("Changed", api.Default, "reset")
                                end
                            end
                            return api
                        end
                    end

                    function api:GetDefault()
                        return api.Default
                    end

                    function api:SetDefault(value)
                        api.Default = value
                        return api
                    end

                    function api:IsDefault()
                        if type(getter) ~= "function" then return false end
                        local ok, value = pcall(getter)
                        return ok and value == api.Default
                    end

                    api._events = api._events or {}
                    local function getComponentEvent(name)
                        name = tostring(name or "")
                        api._events[name] = api._events[name] or Signal.new()
                        return api._events[name]
                    end

                    function api:On(eventName, callback)
                        return getComponentEvent(eventName):Connect(callback)
                    end

                    function api:Emit(eventName, ...)
                        getComponentEvent(eventName):Fire(...)
                        return api
                    end

                    function api:OnChanged(callback) return api:On("Changed", callback) end
                    function api:OnClick(callback) return api:On("Click", callback) end
                    function api:OnOpen(callback) return api:On("Open", callback) end
                    function api:OnClose(callback) return api:On("Close", callback) end
                    function api:OnFocus(callback) return api:On("Focus", callback) end
                    function api:OnBlur(callback) return api:On("Blur", callback) end

                    local rawSet = api.Set
                    if type(rawSet) == "function" and not api._setWrapped then
                        api._setWrapped = true
                        api.Set = function(a, b, ...)
                            local value = (a == api) and b or a
                            local results = table.pack(pcall(rawSet, value, ...))
                            local current = type(api.Get) == "function" and api.Get() or value

                            api:Emit("Changed", current, "set")

                            if results[1] then
                                return table.unpack(results, 2, results.n)
                            end

                            if Library.DebugEnabled then
                                warn("[MistUI Set] " .. tostring(results[2]))
                            end

                            return nil
                        end
                    end

                    local rawSetSilent = api.SetSilent
                    if type(rawSetSilent) == "function" and not api._setSilentWrapped then
                        api._setSilentWrapped = true
                        api.SetSilent = function(a, b, ...)
                            local value = (a == api) and b or a
                            local results = table.pack(pcall(rawSetSilent, value, ...))
                            local current = type(api.Get) == "function" and api.Get() or value

                            api:Emit("Changed", current, "silent")

                            if results[1] then
                                return table.unpack(results, 2, results.n)
                            end

                            return nil
                        end
                    end

                    if api.Instance and typeof(api.Instance) == "Instance" then
                        if api.Instance:IsA("GuiButton") then
                            api.Instance.MouseButton1Click:Connect(function() api:Emit("Click") end)
                        elseif api.Instance:IsA("TextBox") then
                            api.Instance.Focused:Connect(function() api:Emit("Focus") end)
                            api.Instance.FocusLost:Connect(function(enterPressed) api:Emit("Blur", enterPressed) end)
                        end
                    end

                    table.insert(cardApi.Components, api)
                    if Library._activeWindow then
                        Library._activeWindow:_RegisterComponent(api, {
                            Name = controlText,
                            Type = controlType,
                            Card = title,
                            Page = pageName,
                            Flag = flag,
                        })
                    end

                    Library:_RegisterFlagComponent(flag, api)
                end
                return api
            end

            function cardApi:AddButton(text, callback, variant)
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                local button = makeButton(
                    holder,
                    text,
                    variant or "secondary",
                    nil,
                    30,
                    callback
                )

                return button
            end

            function cardApi:AddToggle(text, default, callback)
                callback = callback or function() end
                local state = default == true

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -52, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 2,
                    Parent = holder,
                })

                local track = create("Frame", {
                    BackgroundColor3 = state and Theme.Accent or Theme.Field,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 36, 0, 20),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    Parent = holder,
                }, { corner(9999) })

                local knob = create("Frame", {
                    BackgroundColor3 = state and Theme.ToggleKnobActive or Theme.TextDark,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = state and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    Parent = track,
                }, { corner(9999) })

                local clickArea = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 10, 1, 10),
                    Position = UDim2.new(0, -5, 0, -5),
                    ZIndex = 4,
                    Parent = track,
                })

                local knobScale = create("UIScale", {
                    Scale = 1,
                    Parent = knob,
                })

                local knobMoveTween = nil
                local trackColorTween = nil
                local knobColorTween = nil

                local function animateToggleVisual()
                    if knobMoveTween then knobMoveTween:Cancel() end
                    if trackColorTween then trackColorTween:Cancel() end
                    if knobColorTween then knobColorTween:Cancel() end

                    knobMoveTween = tween(
                        knob,
                        {
                            Position = state
                                and UDim2.new(1, -10, 0.5, 0)
                                or UDim2.new(0, 10, 0.5, 0),
                        },
                        0.30,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    )

                    trackColorTween = tween(
                        track,
                        { BackgroundColor3 = state and Theme.Accent or Theme.Field },
                        0.24,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.Out
                    )

                    knobColorTween = tween(
                        knob,
                        { BackgroundColor3 = state and Theme.ToggleKnobActive or Theme.TextDark },
                        0.24,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.Out
                    )

                    smoothTween(knobScale, { Scale = 1.10 }, 0.11, Enum.EasingStyle.Sine)
                    task.delay(0.10, function()
                        if knobScale and knobScale.Parent then
                            smoothTween(knobScale, { Scale = 1 }, 0.20, Enum.EasingStyle.Sine)
                        end
                    end)
                end

                local function setState(v, fire)
                    state = v == true
                    animateToggleVisual()
                    if fire ~= false then Library:SafeCall(callback, state) end
                end

                clickArea.MouseEnter:Connect(function()
                    smoothTween(track, {
                        BackgroundColor3 = state and shadeColor(Theme.Accent, 1.05) or Theme.FieldHover,
                    }, 0.22, Enum.EasingStyle.Sine)
                    smoothTween(knobScale, { Scale = 1.04 }, 0.22, Enum.EasingStyle.Sine)
                end)
                clickArea.MouseLeave:Connect(function()
                    smoothTween(track, {
                        BackgroundColor3 = state and Theme.Accent or Theme.Field,
                    }, 0.24, Enum.EasingStyle.Sine)
                    smoothTween(knobScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Sine)
                end)
                clickArea.MouseButton1Click:Connect(function()
                    setState(not state, true)
                end)

                local api = {
                    Set = function(v) setState(v, true) end,
                    SetSilent = function(v) setState(v, false) end,
                    Get = function() return state end,
                    Container = holder,
                    Instance = clickArea,
                }

                return registerNormalControl("Toggle", text, api)
            end


            function cardApi:AddSlider(text, min, max, default, callback)
                min, max = min or 0, max or 100
                if max == min then max = min + 1 end

                local value = math.clamp(default or min, min, max)
                callback = callback or function() end

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -72, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 2,
                    Parent = holder,
                })

                local valueBox = create("TextLabel", {
                    Text = tostring(value),
                    FontFace = Theme.FontSemibold,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundColor3 = Theme.TitleBar,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, -1),
                    Size = UDim2.new(0, 52, 0, 24),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(8) })

                local track = create("Frame", {
                    BackgroundColor3 = Theme.FieldHover,
                    Position = UDim2.new(0, 0, 0, 34),
                    Size = UDim2.new(1, 0, 0, 8),
                    ZIndex = 2,
                    Parent = holder,
                }, { corner(9999) })

                local fill = create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    ZIndex = 3,
                    Parent = track,
                }, { corner(9999) })

                local knob = create("Frame", {
                    BackgroundColor3 = Theme.Text,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Parent = track,
                }, { corner(9999) })

                local dragBtn = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -6, 0, -9),
                    Size = UDim2.new(1, 12, 1, 18),
                    ZIndex = 5,
                    Parent = track,
                })

                local dragging = false

                local knobScale = create("UIScale", {
                    Scale = 1,
                    Parent = knob,
                })

                local function applyValue(v, fire, instant)
                    value = math.clamp(v, min, max)
                    local rel = (value - min) / (max - min)
                    local fillTarget = UDim2.new(rel, 0, 1, 0)
                    local knobTarget = UDim2.new(rel, 0, 0.5, 0)

                    if instant then
                        fill.Size = fillTarget
                        knob.Position = knobTarget
                    else
                        smoothTween(fill, { Size = fillTarget }, 0.14)
                        smoothTween(knob, { Position = knobTarget }, 0.14)
                    end

                    valueBox.Text = tostring(value)
                    if fire ~= false then Library:SafeCall(callback, value) end
                end

                local function updateFromX(xPos)
                    local width = math.max(track.AbsoluteSize.X, 1)
                    local rel = math.clamp((xPos - track.AbsolutePosition.X) / width, 0, 1)
                    local raw = min + rel * (max - min)
                    applyValue(math.floor(raw + 0.5), true, true)
                end

                dragBtn.MouseEnter:Connect(function()
                    smoothTween(knobScale, { Scale = 1.08 }, 0.14)
                    smoothTween(valueBox, { BackgroundColor3 = Theme.Field }, 0.14)
                end)

                dragBtn.MouseLeave:Connect(function()
                    if not dragging then
                        smoothTween(knobScale, { Scale = 1 }, 0.16)
                        smoothTween(valueBox, { BackgroundColor3 = Theme.TitleBar }, 0.16)
                    end
                end)

                dragBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        smoothTween(knobScale, { Scale = 1.14 }, 0.10)
                        smoothTween(valueBox, { BackgroundColor3 = Theme.Field }, 0.10)
                        updateFromX(input.Position.X)
                    end
                end)

                window:Track(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        smoothTween(knobScale, { Scale = 1 }, 0.16)
                        smoothTween(valueBox, { BackgroundColor3 = Theme.TitleBar }, 0.16)
                    end
                end))

                window:Track(UserInputService.InputChanged:Connect(function(input)
                    if dragging and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    ) then
                        updateFromX(input.Position.X)
                    end
                end))

                local api = {
                    Set = function(v) applyValue(v, true, false) end,
                    SetSilent = function(v) applyValue(v, false, false) end,
                    Get = function() return value end,
                    Container = holder,
                    Instance = dragBtn,
                }

                return registerNormalControl("Slider", text, api)
            end

            function cardApi:AddCheckbox(text, default, callback)
                callback = callback or function() end
                local state = default == true

                local holder = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                local box = create("Frame", {
                    BackgroundColor3 = state and Theme.Accent or Theme.Field,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(6) })

                local checkHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 13, 0, 13),
                    Visible = state,
                    ZIndex = 4,
                    Parent = box,
                })
                buildIcon(checkHolder, "check", 13, Theme.PrimaryText)

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 30, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 3,
                    Parent = holder,
                })

                local boxScale = create("UIScale", {
                    Scale = 1,
                    Parent = box,
                })

                local function setState(v, fire)
                    state = v == true
                    checkHolder.Visible = state
                    smoothTween(box, {
                        BackgroundColor3 = state and Theme.Accent or Theme.Field,
                    }, 0.18)
                    smoothTween(boxScale, { Scale = 1.10 }, 0.08)

                    task.delay(0.07, function()
                        if boxScale and boxScale.Parent then
                            smoothTween(boxScale, { Scale = 1 }, 0.15)
                        end
                    end)

                    if fire ~= false then
                        Library:SafeCall(callback, state)
                    end
                end

                holder.MouseEnter:Connect(function()
                    smoothTween(box, {
                        BackgroundColor3 = state and shadeColor(Theme.Accent, 1.05) or Theme.FieldHover,
                    }, 0.16)
                    smoothTween(boxScale, { Scale = 1.05 }, 0.16)
                end)

                holder.MouseLeave:Connect(function()
                    smoothTween(box, {
                        BackgroundColor3 = state and Theme.Accent or Theme.Field,
                    }, 0.18)
                    smoothTween(boxScale, { Scale = 1 }, 0.18)
                end)

                holder.MouseButton1Click:Connect(function()
                    setState(not state, true)
                end)

                local api = {
                    Set = function(v) setState(v, true) end,
                    SetSilent = function(v) setState(v, false) end,
                    Get = function() return state end,
                    Container = holder,
                    Instance = holder,
                }

                return registerNormalControl("Checkbox", text, api)
            end

            function cardApi:AddDropdown(text, options, default, callback)
                options = options or {}
                callback = callback or function() end
                local value = default ~= nil and default or options[1] or "None"
                local opened = false
                local rows = {}
                local BASE_HEIGHT = 58

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, BASE_HEIGHT),
                    LayoutOrder = nextOrder(),
                    ZIndex = 6,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = holder,
                })

                local button = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.Field,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 32),
                    ZIndex = 7,
                    Parent = holder,
                }, { corner(8) })

                local valueLabel = create("TextLabel", {
                    Text = tostring(value),
                    FontFace = Theme.FontSemibold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 8,
                    Parent = button,
                })

                local arrowHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Rotation = 90,
                    ZIndex = 8,
                    Parent = button,
                })
                buildIcon(arrowHolder, "chevron-right", 14, Theme.TextDark)

                local menu = create("Frame", {
                    BackgroundColor3 = Theme.TitleBar,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 20,
                    Parent = holder,
                }, { corner(8) })

                local list = create("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 1, -10),
                    ZIndex = 21,
                    Parent = menu,
                }, {
                    create("UIListLayout", {
                        Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local function menuHeight()
                    return math.max(39, math.min(#options, 6) * 31 + 10)
                end

                local function clearRows()
                    for _, row_ in ipairs(rows) do
                        if row_ and row_.Parent then row_:Destroy() end
                    end
                    table.clear(rows)
                end

                local function rebuild()
                    clearRows()
                    for i, option in ipairs(options) do
                        local optionText = tostring(option)
                        local selected = tostring(value) == optionText
                        local optionButton = create("TextButton", {
                            Text = optionText,
                            FontFace = Theme.Font,
                            TextSize = 13,
                            TextColor3 = Theme.Text,
                            AutoButtonColor = false,
                            BorderSizePixel = 0,
                            BackgroundColor3 = selected and Theme.CardHover or Theme.Field,
                            Size = UDim2.new(1, 0, 0, 28),
                            LayoutOrder = i,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 22,
                            Parent = list,
                        }, { corner(6), padding(9) })

                        optionButton.MouseEnter:Connect(function()
                            smoothTween(optionButton, { BackgroundColor3 = Theme.FieldHover }, 0.10)
                        end)
                        optionButton.MouseLeave:Connect(function()
                            smoothTween(optionButton, {
                                BackgroundColor3 = tostring(value) == optionText and Theme.CardHover or Theme.Field,
                            }, 0.12)
                        end)
                        optionButton.MouseButton1Click:Connect(function()
                            value = option
                            valueLabel.Text = optionText
                            if callback then Library:SafeCall(callback, option) end
                            rebuild()
                            opened = false
                            smoothTween(menu, { Size = UDim2.new(1, 0, 0, 0) }, 0.14)
                            smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT) }, 0.14)
                            smoothTween(arrowHolder, { Rotation = 90 }, 0.14)
                            task.delay(0.15, function()
                                if not opened and menu then menu.Visible = false end
                            end)
                        end)

                        table.insert(rows, optionButton)
                    end
                end

                local function setOpen(state)
                    state = state == true
                    if state then
                        if Library._openDropdownCloser and Library._openDropdownCloser ~= setOpen then
                            pcall(Library._openDropdownCloser, false)
                        end
                        opened = true
                        rebuild()
                        menu.Visible = true
                        local h = menuHeight()
                        smoothTween(menu, { Size = UDim2.new(1, 0, 0, h) }, 0.16)
                        smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT + h + 6) }, 0.16)
                        smoothTween(arrowHolder, { Rotation = -90 }, 0.16)
                        Library._openDropdownCloser = setOpen
                    else
                        opened = false
                        smoothTween(menu, { Size = UDim2.new(1, 0, 0, 0) }, 0.14)
                        smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT) }, 0.14)
                        smoothTween(arrowHolder, { Rotation = 90 }, 0.14)
                        task.delay(0.15, function()
                            if not opened and menu then menu.Visible = false end
                        end)
                        if Library._openDropdownCloser == setOpen then
                            Library._openDropdownCloser = nil
                        end
                    end
                end

                button.MouseEnter:Connect(function()
                    smoothTween(button, { BackgroundColor3 = Theme.FieldHover }, 0.14)
                end)
                button.MouseLeave:Connect(function()
                    smoothTween(button, { BackgroundColor3 = Theme.Field }, 0.16)
                end)
                button.MouseButton1Click:Connect(function()
                    setOpen(not opened)
                end)

                local api = {
                    Set = function(v)
                        if v ~= nil then
                            value = v
                            valueLabel.Text = tostring(v)
                            rebuild()
                            Library:SafeCall(callback, v)
                        end
                    end,
                    SetSilent = function(v)
                        if v ~= nil then
                            value = v
                            valueLabel.Text = tostring(v)
                            rebuild()
                        end
                    end,
                    Get = function() return value end,
                    SetOptions = function(newOptions, newDefault)
                        options = newOptions or {}
                        value = newDefault ~= nil and newDefault or options[1] or "None"
                        valueLabel.Text = tostring(value)
                        rebuild()
                        if opened then setOpen(true) end
                    end,
                    Container = holder,
                    Instance = button,
                }

                return registerNormalControl("Dropdown", text, api)
            end

            function cardApi:AddKeybind(text, defaultKey, callback)
                callback = callback or function() end
                local key = defaultKey or Enum.KeyCode.Unknown
                local listening = false
                local keybindManagerEntry = Library._activeWindow
                    and Library._activeWindow:RegisterKeybind(
                        text,
                        key,
                        callback,
                        nil
                    )
                    or nil

                if keybindManagerEntry and keybindManagerEntry.Key then
                    key = keybindManagerEntry.Key
                end

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -120, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local keyButton = create("TextButton", {
                    Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper(),
                    FontFace = Theme.FontSemibold,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.TitleBar,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 92, 0, 28),
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(5) })

                local keyScale = create("UIScale", {
                    Scale = 1,
                    Parent = keyButton,
                })

                keyButton.MouseEnter:Connect(function()
                    smoothTween(keyButton, { BackgroundColor3 = Theme.FieldHover }, 0.16)
                    smoothTween(keyScale, { Scale = 1.025 }, 0.16)
                end)

                keyButton.MouseLeave:Connect(function()
                    if not listening then
                        smoothTween(keyButton, { BackgroundColor3 = Theme.TitleBar }, 0.18)
                    end
                    smoothTween(keyScale, { Scale = 1 }, 0.18)
                end)

                keyButton.MouseButton1Down:Connect(function()
                    smoothTween(keyScale, { Scale = 0.975 }, 0.08)
                end)

                keyButton.MouseButton1Up:Connect(function()
                    smoothTween(keyScale, { Scale = 1.025 }, 0.10)
                end)

                -- Actual key listener.
                local keybindInputConnection = window:Track(UserInputService.InputBegan:Connect(function(input, processed)
                    if listening or processed or isTextInputFocused() then return end
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if key == Enum.KeyCode.Unknown then return end
                    if input.KeyCode ~= key then return end

                    if keybindManagerEntry and type(keybindManagerEntry.SetActive) == "function" then
                        keybindManagerEntry:SetActive(true)
                        task.delay(0.14, function()
                            if keybindManagerEntry then keybindManagerEntry:SetActive(false) end
                        end)
                    end
                    Library:SafeCall(callback, key, "input", processed)
                end))

                if Library._activeWindow
                    and type(Library._activeWindow._TrackKeybindConnection) == "function" then
                    Library._activeWindow:_TrackKeybindConnection(
                        keybindInputConnection
                    )
                end

                keyButton.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    keyButton.Text = "PRESS A KEY..."
                    smoothTween(keyButton, { BackgroundColor3 = Theme.FieldHover }, 0.16)

                    local connection
                    connection = window:Track(UserInputService.InputBegan:Connect(function(input, processed)
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

                        key = input.KeyCode
                        if keybindManagerEntry then
                            keybindManagerEntry:SetKey(key)
                        end
                        keyButton.Text = key.Name:upper()
                        smoothTween(keyButton, { BackgroundColor3 = Theme.TitleBar }, 0.18)
                        listening = false
                        connection:Disconnect()

                        -- "bind_changed" distinguishes changing the key from pressing it.
                        Library:SafeCall(callback, key, "bind_changed", processed)
                    end))
                end)

                local api = {
                    Set = function(v)
                        key = v or Enum.KeyCode.Unknown
                        if keybindManagerEntry then
                            keybindManagerEntry:SetKey(key)
                        end
                        keyButton.Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper()
                        Library:SafeCall(callback, key, "bind_changed", false)
                    end,
                    SetSilent = function(v)
                        key = v or Enum.KeyCode.Unknown
                        if keybindManagerEntry then
                            keybindManagerEntry:SetKey(key)
                        end
                        keyButton.Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper()
                    end,
                    Get = function() return key end,
                    Container = holder,
                    Instance = keyButton,
                }

                return registerNormalControl("Keybind", text, api)
            end

            function cardApi:AddTextbox(text, placeholder, default, callback)
                callback = callback or function() end
                local value = tostring(default or "")

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 58),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local input = create("TextBox", {
                    Text = value,
                    PlaceholderText = placeholder or "",
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDimmer,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.TitleBar,
                    ClearTextOnFocus = false,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 34),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 3,
                    Parent = holder,
                }, {
                    corner(10),
                    padding(12),
                })

                local inputScale = create("UIScale", {
                    Scale = 1,
                    Parent = input,
                })

                local function enforceReadableText()
                    input.TextColor3 = Theme.Text
                    input.PlaceholderColor3 = Theme.TextDimmer
                end

                input.Focused:Connect(function()
                    enforceReadableText()
                    smoothTween(input, { BackgroundColor3 = Theme.FieldHover }, 0.16)
                    smoothTween(inputScale, { Scale = 1.006 }, 0.16)
                end)

                input:GetPropertyChangedSignal("Text"):Connect(enforceReadableText)
                input:GetPropertyChangedSignal("TextColor3"):Connect(function()
                    if input.TextColor3 ~= Theme.Text then
                        input.TextColor3 = Theme.Text
                    end
                end)

                input.FocusLost:Connect(function(enterPressed)
                    value = input.Text
                    enforceReadableText()
                    smoothTween(input, { BackgroundColor3 = Theme.TitleBar }, 0.18)
                    smoothTween(inputScale, { Scale = 1 }, 0.18)
                    Library:SafeCall(callback, value, enterPressed)
                end)

                enforceReadableText()

                local api = {
                    Set = function(v)
                        value = tostring(v or "")
                        input.Text = value
                        enforceReadableText()
                        Library:SafeCall(callback, value, false)
                    end,
                    SetSilent = function(v)
                        value = tostring(v or "")
                        input.Text = value
                        enforceReadableText()
                    end,
                    Get = function() return input.Text end,
                    Instance = input,
                    Container = holder,
                }

                return registerNormalControl("Textbox", text, api)
            end

            function cardApi:AddNumberBox(text, min, max, default, step, callback)
                min = tonumber(min) or 0
                max = tonumber(max) or 100
                if max < min then min, max = max, min end
                step = math.abs(tonumber(step) or 1)
                if step == 0 then step = 1 end
                callback = callback or function() end

                local function normalize(v)
                    v = tonumber(v) or min
                    v = math.clamp(v, min, max)
                    local snapped = min + math.floor(((v - min) / step) + 0.5) * step
                    return math.clamp(snapped, min, max)
                end

                local value = normalize(default or min)
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -116, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local input = create("TextBox", {
                    Text = tostring(value),
                    PlaceholderText = tostring(value),
                    FontFace = Theme.FontSemibold,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDimmer,
                    BackgroundColor3 = Theme.TitleBar,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 104, 0, 30),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(8), padding(8) })

                local function apply(v, fire)
                    value = normalize(v)
                    input.Text = tostring(value)
                    if fire ~= false then Library:SafeCall(callback, value) end
                end

                input.FocusLost:Connect(function()
                    apply(input.Text, true)
                end)

                input.Focused:Connect(function()
                    smoothTween(input, { BackgroundColor3 = Theme.FieldHover }, 0.14)
                end)

                input.FocusLost:Connect(function()
                    smoothTween(input, { BackgroundColor3 = Theme.TitleBar }, 0.16)
                end)

                local validator = nil
                local validationError = nil
                local api = {
                    Set = function(v) apply(v, true) end,
                    SetSilent = function(v) apply(v, false) end,
                    Get = function() return value end,
                    Container = holder,
                    Instance = input,
                    Min = min,
                    Max = max,
                    Step = step,
                }

                function api:SetValidator(fn)
                    validator = type(fn) == "function" and fn or nil
                    return api
                end

                function api:Validate()
                    if not validator then return true end
                    local ok, result, message = pcall(validator, value)
                    if not ok then validationError = tostring(result); input.TextColor3 = Theme.Error; return false, validationError end
                    local valid = result ~= false

                    if valid then
                        validationError = nil
                        input.TextColor3 = Theme.Text
                    else
                        validationError = tostring(message or "Invalid value")
                        input.TextColor3 = Theme.Error
                    end

                    return valid, validationError
                end

                function api:GetValidationError() return validationError end

                return registerNormalControl("NumberBox", text, api)
            end

            function cardApi:AddRangeSlider(text, min, max, defaultMin, defaultMax, callback)
                min = tonumber(min) or 0
                max = tonumber(max) or 100
                if max <= min then max = min + 1 end
                callback = callback or function() end

                local low = math.clamp(tonumber(defaultMin) or min, min, max)
                local high = math.clamp(tonumber(defaultMax) or max, min, max)
                if low > high then low, high = high, low end

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 52),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -100, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local valueBox = create("TextLabel", {
                    Text = tostring(low) .. " - " .. tostring(high),
                    FontFace = Theme.FontSemibold,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    BackgroundColor3 = Theme.TitleBar,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, -1),
                    Size = UDim2.new(0, 92, 0, 24),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(8) })

                local track = create("Frame", {
                    BackgroundColor3 = Theme.FieldHover,
                    Position = UDim2.new(0, 0, 0, 35),
                    Size = UDim2.new(1, 0, 0, 8),
                    ZIndex = 2,
                    Parent = holder,
                }, { corner(9999) })

                local fill = create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    ZIndex = 3,
                    Parent = track,
                }, { corner(9999) })

                local lowKnob = create("Frame", {
                    BackgroundColor3 = Theme.Text,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Parent = track,
                }, { corner(9999) })

                local highKnob = create("Frame", {
                    BackgroundColor3 = Theme.Text,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Parent = track,
                }, { corner(9999) })

                local dragArea = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -6, 0, -9),
                    Size = UDim2.new(1, 12, 1, 18),
                    ZIndex = 5,
                    Parent = track,
                })

                local dragging = nil

                local function relOf(v)
                    return (v - min) / (max - min)
                end

                local function syncVisual(fire)
                    low = math.clamp(low, min, max)
                    high = math.clamp(high, min, max)
                    if low > high then low, high = high, low end

                    local lowRel = relOf(low)
                    local highRel = relOf(high)

                    lowKnob.Position = UDim2.new(lowRel, 0, 0.5, 0)
                    highKnob.Position = UDim2.new(highRel, 0, 0.5, 0)
                    fill.Position = UDim2.new(lowRel, 0, 0, 0)
                    fill.Size = UDim2.new(highRel - lowRel, 0, 1, 0)
                    valueBox.Text = tostring(low) .. " - " .. tostring(high)

                    if fire ~= false then Library:SafeCall(callback, low, high) end
                end

                local function valueFromX(x)
                    local width = math.max(track.AbsoluteSize.X, 1)
                    local rel = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
                    return math.floor(min + rel * (max - min) + 0.5)
                end

                local function updateFromX(x)
                    local v = valueFromX(x)
                    if dragging == "low" then
                        low = math.min(v, high)
                    elseif dragging == "high" then
                        high = math.max(v, low)
                    end
                    syncVisual(true)
                end

                dragArea.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        local v = valueFromX(input.Position.X)
                        dragging = math.abs(v - low) <= math.abs(v - high) and "low" or "high"
                        updateFromX(input.Position.X)
                    end
                end)

                window:Track(UserInputService.InputChanged:Connect(function(input)
                    if dragging and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    ) then
                        updateFromX(input.Position.X)
                    end
                end))

                window:Track(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = nil
                    end
                end))

                local function apply(v, maybeHigh, fire)
                    local newLow, newHigh
                    if type(v) == "table" then
                        newLow = tonumber(v.Min or v.min or v[1])
                        newHigh = tonumber(v.Max or v.max or v[2])
                    else
                        newLow = tonumber(v)
                        newHigh = tonumber(maybeHigh)
                    end

                    if newLow ~= nil then low = newLow end
                    if newHigh ~= nil then high = newHigh end
                    syncVisual(fire)
                end

                syncVisual(false)

                local api = {
                    Set = function(v, h) apply(v, h, true) end,
                    SetSilent = function(v, h) apply(v, h, false) end,
                    Get = function() return { Min = low, Max = high } end,
                    Container = holder,
                    Instance = dragArea,
                }

                return registerNormalControl("RangeSlider", text, api)
            end

            function cardApi:AddSearchDropdown(text, options, default, callback)
                options = options or {}
                callback = callback or function() end

                local values = {}
                for _, option in ipairs(options) do
                    table.insert(values, option)
                end

                local value = default ~= nil and default or values[1] or "None"
                local opened = false
                local rows = {}
                local BASE_HEIGHT = 58

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, BASE_HEIGHT),
                    LayoutOrder = nextOrder(),
                    ZIndex = 12,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 12,
                    Parent = holder,
                })

                local button = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme.Field,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 32),
                    ZIndex = 13,
                    Parent = holder,
                }, { corner(8) })

                local valueLabel = create("TextLabel", {
                    Text = tostring(value),
                    FontFace = Theme.FontSemibold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 14,
                    Parent = button,
                })

                local arrowHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Rotation = 90,
                    ZIndex = 14,
                    Parent = button,
                })
                buildIcon(arrowHolder, "chevron-right", 14, Theme.TextDark)

                local menu = create("Frame", {
                    BackgroundColor3 = Theme.TitleBar,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 30,
                    Parent = holder,
                }, { corner(8) })

                local search = create("TextBox", {
                    Text = "",
                    PlaceholderText = "Search...",
                    FontFace = Theme.Font,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDimmer,
                    BackgroundColor3 = Theme.Field,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.new(1, -12, 0, 30),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 31,
                    Parent = menu,
                }, { corner(6), padding(8) })

                local list = create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 6, 0, 42),
                    Size = UDim2.new(1, -12, 1, -48),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 0,
                    ScrollBarImageTransparency = 1,
                    ZIndex = 31,
                    Parent = menu,
                }, {
                    create("UIListLayout", {
                        Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local function clearRows()
                    for _, row_ in ipairs(rows) do
                        if row_ and row_.Parent then row_:Destroy() end
                    end
                    table.clear(rows)
                end

                local function visibleCountForQuery()
                    local query = string.lower(search.Text or "")
                    local count = 0
                    for _, option in ipairs(values) do
                        local optionText = tostring(option)
                        if query == "" or string.find(string.lower(optionText), query, 1, true) then
                            count += 1
                        end
                    end
                    return count
                end

                local function targetMenuHeight()
                    local count = math.min(math.max(visibleCountForQuery(), 1), 6)
                    return 48 + count * 31
                end

                local function setOpen(state)
                    opened = state == true
                    if opened then
                        menu.Visible = true
                        local h = targetMenuHeight()
                        smoothTween(menu, { Size = UDim2.new(1, 0, 0, h) }, 0.15)
                        smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT + h + 6) }, 0.15)
                        smoothTween(arrowHolder, { Rotation = -90 }, 0.15)
                    else
                        smoothTween(menu, { Size = UDim2.new(1, 0, 0, 0) }, 0.14)
                        smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT) }, 0.14)
                        smoothTween(arrowHolder, { Rotation = 90 }, 0.14)
                        task.delay(0.15, function()
                            if not opened and menu then menu.Visible = false end
                        end)
                    end
                end

                local function rebuild()
                    clearRows()
                    local query = string.lower(search.Text or "")

                    for i, option in ipairs(values) do
                        local optionText = tostring(option)
                        if query == "" or string.find(string.lower(optionText), query, 1, true) then
                            local selected = tostring(value) == optionText
                            local row_ = create("TextButton", {
                                Text = optionText,
                                FontFace = Theme.Font,
                                TextSize = 13,
                                TextColor3 = Theme.Text,
                                AutoButtonColor = false,
                                BackgroundColor3 = selected and Theme.CardHover or Theme.Field,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, 0, 0, 28),
                                LayoutOrder = i,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                ZIndex = 32,
                                Parent = list,
                            }, { corner(6), padding(9) })

                            row_.MouseEnter:Connect(function()
                                smoothTween(row_, { BackgroundColor3 = Theme.FieldHover }, 0.10)
                            end)
                            row_.MouseLeave:Connect(function()
                                smoothTween(row_, {
                                    BackgroundColor3 = tostring(value) == optionText and Theme.CardHover or Theme.Field,
                                }, 0.12)
                            end)
                            row_.MouseButton1Click:Connect(function()
                                value = option
                                valueLabel.Text = optionText
                                Library:SafeCall(callback, option)
                                rebuild()
                                setOpen(false)
                            end)

                            table.insert(rows, row_)
                        end
                    end

                    if opened then
                        local h = targetMenuHeight()
                        smoothTween(menu, { Size = UDim2.new(1, 0, 0, h) }, 0.12)
                        smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT + h + 6) }, 0.12)
                    end
                end

                button.MouseButton1Click:Connect(function()
                    if not opened then
                        search.Text = ""
                        rebuild()
                    end
                    setOpen(not opened)
                end)

                search:GetPropertyChangedSignal("Text"):Connect(function()
                    search.TextColor3 = Theme.Text
                    rebuild()
                end)

                local api = {
                    Set = function(v)
                        if v ~= nil then
                            value = v
                            valueLabel.Text = tostring(v)
                            rebuild()
                            Library:SafeCall(callback, v)
                        end
                    end,
                    SetSilent = function(v)
                        if v ~= nil then
                            value = v
                            valueLabel.Text = tostring(v)
                            rebuild()
                        end
                    end,
                    Get = function() return value end,
                    SetOptions = function(newOptions, newDefault)
                        values = {}
                        for _, option in ipairs(newOptions or {}) do
                            table.insert(values, option)
                        end
                        value = newDefault ~= nil and newDefault or values[1] or "None"
                        valueLabel.Text = tostring(value)
                        rebuild()
                    end,
                    Container = holder,
                    Instance = button,
                    SearchBox = search,
                }

                return registerNormalControl("SearchDropdown", text, api)
            end

            function cardApi:AddToggleKeybind(text, defaultEnabled, defaultKey, callback, keybindId)
                callback = callback or function() end
                local enabled = defaultEnabled == true
                local key = defaultKey or Enum.KeyCode.Unknown
                local listening = false
                local keybindManagerEntry = Library._activeWindow
                    and Library._activeWindow:RegisterKeybind(
                        text,
                        key,
                        callback,
                        nil,
                        keybindId
                    )
                    or nil

                if keybindManagerEntry and keybindManagerEntry.Key then
                    key = keybindManagerEntry.Key
                end

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = text,
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -142, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 2,
                    Parent = holder,
                })

                local keyButton = create("TextButton", {
                    Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper(),
                    FontFace = Theme.FontSemibold,
                    TextSize = 11,
                    TextColor3 = Theme.Text,
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme.TitleBar,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -48, 0.5, 0),
                    Size = UDim2.new(0, 82, 0, 28),
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(7) })

                local toggleTrack = create("Frame", {
                    BackgroundColor3 = enabled and Theme.Accent or Theme.Field,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 36, 0, 20),
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(9999) })

                local knob = create("Frame", {
                    BackgroundColor3 = enabled and Theme.ToggleKnobActive or Theme.TextDark,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = enabled and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Parent = toggleTrack,
                }, { corner(9999) })

                local toggleButton = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -5, 0, -5),
                    Size = UDim2.new(1, 10, 1, 10),
                    ZIndex = 5,
                    Parent = toggleTrack,
                })

                local function fire(source)
                    Library:SafeCall(callback, enabled, key, source)
                end

                local function setEnabled(v, shouldFire, source)
                    enabled = v == true
                    smoothTween(toggleTrack, {
                        BackgroundColor3 = enabled and Theme.Accent or Theme.Field,
                    }, 0.20)
                    smoothTween(knob, {
                        Position = enabled and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
                        BackgroundColor3 = enabled and Theme.ToggleKnobActive or Theme.TextDark,
                    }, 0.24)
                    if shouldFire ~= false then fire(source or "toggle") end
                end

                local function setKey(newKey, shouldFire)
                    key = newKey or Enum.KeyCode.Unknown
                    if keybindManagerEntry then
                        keybindManagerEntry:SetKey(key)
                    end
                    keyButton.Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper()
                    if shouldFire ~= false then fire("bind_changed") end
                end

                toggleButton.MouseButton1Click:Connect(function()
                    setEnabled(not enabled, true, "toggle")
                end)

                keyButton.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    keyButton.Text = "PRESS..."
                    local connection
                    connection = window:Track(UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

                        if input.KeyCode == Enum.KeyCode.Escape then
                            keyButton.Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper()
                        elseif input.KeyCode == Enum.KeyCode.Backspace then
                            setKey(Enum.KeyCode.Unknown, true)
                        else
                            setKey(input.KeyCode, true)
                        end

                        listening = false
                        connection:Disconnect()
                    end))
                end)

                local toggleKeybindInputConnection = window:Track(UserInputService.InputBegan:Connect(function(input, processed)
                    if listening or processed or isTextInputFocused() then return end
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if key == Enum.KeyCode.Unknown or input.KeyCode ~= key then return end
                    setEnabled(not enabled, true, "input")
                end))

                if Library._activeWindow
                    and type(Library._activeWindow._TrackKeybindConnection) == "function" then
                    Library._activeWindow:_TrackKeybindConnection(
                        toggleKeybindInputConnection
                    )
                end

                local function apply(v, fireCallbacks)
                    if type(v) == "table" then
                        local newEnabled = v.Enabled
                        if newEnabled == nil then newEnabled = v.enabled end
                        local keyName = v.Key or v.key

                        if newEnabled ~= nil then
                            setEnabled(newEnabled == true, fireCallbacks, "set")
                        end

                        if typeof(keyName) == "EnumItem" then
                            setKey(keyName, fireCallbacks)
                        elseif type(keyName) == "string" and Enum.KeyCode[keyName] then
                            setKey(Enum.KeyCode[keyName], fireCallbacks)
                        end
                    elseif type(v) == "boolean" then
                        setEnabled(v, fireCallbacks, "set")
                    end
                end

                local api = {
                    Set = function(v) apply(v, true) end,
                    SetSilent = function(v) apply(v, false) end,
                    Get = function()
                        return {
                            Enabled = enabled,
                            Key = key.Name,
                        }
                    end,
                    SetEnabled = function(v) setEnabled(v, true, "set") end,
                    GetEnabled = function() return enabled end,
                    SetKey = function(v) setKey(v, true) end,
                    GetKey = function() return key end,
                    Container = holder,
                    Instance = toggleButton,
                    KeyButton = keyButton,
                }

                return registerNormalControl("ToggleKeybind", text, api)
            end

            function cardApi:AddButtonGroup(buttons)
                buttons = buttons or {}
                local count = math.max(1, #buttons)

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                }, {
                    create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local result = {
                    Buttons = {},
                    Container = holder,
                }

                for i, definition in ipairs(buttons) do
                    local cfg = type(definition) == "table" and definition or { Text = tostring(definition) }
                    local slot = create("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1 / count, -((count - 1) * 6) / count, 1, 0),
                        LayoutOrder = i,
                        Parent = holder,
                    })

                    local button = makeButton(
                        slot,
                        cfg.Text or cfg.Name or ("Button " .. tostring(i)),
                        cfg.Variant or "secondary",
                        nil,
                        cfg.Height or 32,
                        cfg.Callback or function() end
                    )

                    table.insert(result.Buttons, button)
                end

                function result:SetVisible(visible)
                    holder.Visible = visible ~= false
                    return result
                end

                function result:Destroy()
                    if holder and holder.Parent then holder:Destroy() end
                end

                return result
            end

            local function statusColor(variant)
                local v = string.lower(tostring(variant or "info"))
                if v == "success" then return Theme.Success end
                if v == "error" or v == "danger" then return Theme.Error end
                if v == "warning" then return Theme.Warning end
                if v == "neutral" then return Theme.TextDark end
                return Theme.Info
            end

            function cardApi:AddStatus(text, value, variant)
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = tostring(text or "Status"),
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -116, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local badge = create("TextLabel", {
                    Text = tostring(value or "Active"),
                    FontFace = Theme.FontSemibold,
                    TextSize = 11,
                    TextColor3 = statusColor(variant),
                    BackgroundColor3 = statusColor(variant),
                    BackgroundTransparency = 0.84,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 100, 0, 24),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(9999) })

                local currentValue = tostring(value or "Active")
                local currentVariant = variant or "info"

                local api = {
                    Container = holder,
                    Instance = badge,
                }

                function api:Set(newValue, newVariant)
                    if newValue ~= nil then currentValue = tostring(newValue) end
                    if newVariant ~= nil then currentVariant = newVariant end
                    local color = statusColor(currentVariant)
                    badge.Text = currentValue
                    badge.TextColor3 = color
                    badge.BackgroundColor3 = color
                    return api
                end

                function api:SetSilent(newValue, newVariant)
                    return api:Set(newValue, newVariant)
                end

                function api:Get()
                    return currentValue, currentVariant
                end

                function api:SetVisible(visible)
                    holder.Visible = visible ~= false
                    return api
                end

                function api:Destroy()
                    if holder and holder.Parent then holder:Destroy() end
                end

                return api
            end

            function cardApi:AddBadge(text, variant)
                local color = statusColor(variant)
                local badge = create("TextLabel", {
                    Text = tostring(text or "Badge"),
                    FontFace = Theme.FontSemibold,
                    TextSize = 11,
                    TextColor3 = color,
                    BackgroundColor3 = color,
                    BackgroundTransparency = 0.84,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2.new(0, 0, 0, 24),
                    LayoutOrder = nextOrder(),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 2,
                    Parent = card,
                }, { corner(9999), padding(10) })

                local currentVariant = variant or "info"
                local api = {
                    Instance = badge,
                    Container = badge,
                }

                function api:SetText(newText)
                    badge.Text = tostring(newText or "")
                    return api
                end

                function api:SetVariant(newVariant)
                    currentVariant = newVariant or currentVariant
                    local newColor = statusColor(currentVariant)
                    badge.TextColor3 = newColor
                    badge.BackgroundColor3 = newColor
                    return api
                end

                function api:SetVisible(visible)
                    badge.Visible = visible ~= false
                    return api
                end

                function api:Destroy()
                    if badge and badge.Parent then badge:Destroy() end
                end

                return api
            end

            function cardApi:AddLabel(text)
                return create("TextLabel", {
                    Text = text, FontFace = Theme.Font, TextSize = 14, TextColor3 = Theme.TextDark,
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = nextOrder(),
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = card,
                })
            end

            ------------------------------------------------------------
            -- ADVANCED / EXTENDED CARD API
            -- Added to keep the original API intact while exposing
            -- more complete library features.
            ------------------------------------------------------------
            local advancedFlagCounts = {}

            local function normalizeExtConfig(config, fallbackText)
                local copy

                if type(config) == "table" then
                    copy = {}
                    for k, v in pairs(config) do copy[k] = v end
                    if not copy.Text and not copy.Name and fallbackText then
                        copy.Text = fallbackText
                    end
                else
                    copy = { Text = tostring(config or fallbackText or "Item") }
                end

                if not Library:_NormalizeFlag(copy.Flag) then
                    local base = cardFlagPrefix
                        .. ".Advanced."
                        .. cleanFlagPart(fallbackText or "Control")
                        .. "."
                        .. cleanFlagPart(copy.Text or copy.Name or fallbackText or "Item")

                    advancedFlagCounts[base] = (advancedFlagCounts[base] or 0) + 1
                    copy.Flag = advancedFlagCounts[base] > 1
                        and (base .. "." .. tostring(advancedFlagCounts[base]))
                        or base
                end

                return copy
            end

            local function registerExtendedFlag(flag, api)
                flag = Library:_NormalizeFlag(flag)
                if type(api) == "table" then
                    api.Flag = flag
                    api._events = api._events or {}
                    local function getExtEvent(name)
                        name = tostring(name or "")
                        api._events[name] = api._events[name] or Signal.new()
                        return api._events[name]
                    end
                    function api:On(eventName, callback) return getExtEvent(eventName):Connect(callback) end
                    function api:Emit(eventName, ...) getExtEvent(eventName):Fire(...); return api end
                    function api:OnChanged(callback) return api:On("Changed", callback) end
                    function api:OnClick(callback) return api:On("Click", callback) end
                    function api:OnOpen(callback) return api:On("Open", callback) end
                    function api:OnClose(callback) return api:On("Close", callback) end
                    function api:OnFocus(callback) return api:On("Focus", callback) end
                    function api:OnBlur(callback) return api:On("Blur", callback) end
                    if api.Instance and typeof(api.Instance)=="Instance" then
                        if api.Instance:IsA("GuiButton") then api.Instance.MouseButton1Click:Connect(function() api:Emit("Click") end)
                        elseif api.Instance:IsA("TextBox") then
                            api.Instance.Focused:Connect(function() api:Emit("Focus") end)
                            api.Instance.FocusLost:Connect(function(e) api:Emit("Blur",e) end)
                        end
                    end
                    table.insert(cardApi.Components, api)
                    if Library._activeWindow then
                        Library._activeWindow:_RegisterComponent(api, {
                            Name = api.Name or (api.Metadata and api.Metadata.Name) or flag or "Advanced Control",
                            Type = api.Type or "Advanced",
                            Card = title,
                            Page = pageName,
                            Flag = flag,
                        })
                    end
                    if flag then Library:_RegisterFlagComponent(flag, api) end
                end
                return api
            end

            local function addBlockerOverlay(root)
                local blocker = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme.Background,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Visible = false,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 100,
                    Parent = root,
                }, { corner(8) })
                return blocker
            end

            local function decorateExtendedApi(root, primaryTarget, api, flag)
                api = api or {}
                local blocker = addBlockerOverlay(root)

                function api:SetVisible(v)
                    root.Visible = v ~= false
                    return api
                end

                function api:Show()
                    return api:SetVisible(true)
                end

                function api:Hide()
                    return api:SetVisible(false)
                end

                function api:SetDisabled(v)
                    local disabled = v == true
                    blocker.Visible = disabled
                    blocker.BackgroundTransparency = disabled and 0.76 or 1
                    blocker.ZIndex = 500
                    blocker.Active = true
                    pcall(function() blocker.Modal = true end)
                    root:SetAttribute("Disabled", disabled)

                    for _, inst in ipairs(root:GetDescendants()) do
                        if inst ~= blocker then
                            if inst:IsA("GuiButton") then
                                pcall(function() inst.Interactable = not disabled end)
                                inst.Active = not disabled
                            elseif inst:IsA("TextBox") then
                                pcall(function() inst.TextEditable = not disabled end)
                                inst.Active = not disabled
                            end
                        end
                    end

                    return api
                end

                function api:Enable()
                    return api:SetDisabled(false)
                end

                function api:Disable()
                    return api:SetDisabled(true)
                end


                function api:SetTooltip(tooltipText)
                    if tooltipText and tooltipText ~= "" then
                        local activeWindow = Library._activeWindow
                        if activeWindow and type(activeWindow.AttachTooltip) == "function" then
                            activeWindow:AttachTooltip(primaryTarget or root, tooltipText)
                        end
                    end
                    return api
                end

                function api:Destroy()
                    if root and root.Parent then
                        root:Destroy()
                    end
                end

                api.Instance = primaryTarget or root
                api.Container = root
                api.Flag = Library:_NormalizeFlag(flag)

                return api
            end

            local function createSimpleLabel(parent, text, size, color, order_)
                return create("TextLabel", {
                    Text = text or "",
                    FontFace = Theme.Font,
                    TextSize = size or 14,
                    TextColor3 = color or Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    LayoutOrder = order_ or 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = parent,
                })
            end

            function cardApi:AddDivider(text_)
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, text_ and 22 or 8),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                local line = create("Frame", {
                    BackgroundColor3 = Theme.Stroke,
                    BackgroundTransparency = 0.35,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    ZIndex = 2,
                    Parent = holder,
                })

                local label = nil
                if text_ and text_ ~= "" then
                    label = create("TextLabel", {
                        Text = tostring(text_),
                        FontFace = Theme.FontSemibold,
                        TextSize = 12,
                        TextColor3 = Theme.TextDimmer,
                        BackgroundColor3 = Theme.Card,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(0, 0, 0, 18),
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 3,
                        Parent = holder,
                    }, { padding(0, 8, 0, 8, 0) })
                end

                return decorateExtendedApi(holder, line, {
                    Line = line,
                    Label = label,
                })
            end

            function cardApi:AddParagraph(title_, content_)
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                }, {
                    create("UIListLayout", {
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local titleLabel = create("TextLabel", {
                    Text = tostring(title_ or ""),
                    FontFace = Theme.FontSemibold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local contentLabel = create("TextLabel", {
                    Text = tostring(content_ or ""),
                    FontFace = Theme.Font,
                    TextSize = 13,
                    TextColor3 = Theme.TextDark,
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    ZIndex = 2,
                    Parent = holder,
                })

                local api = decorateExtendedApi(holder, holder, {
                    Title = titleLabel,
                    Content = contentLabel,
                })
                function api:Set(textTitle, textContent)
                    titleLabel.Text = tostring(textTitle or "")
                    contentLabel.Text = tostring(textContent or "")
                    return api
                end
                function api:SetSilent(textTitle, textContent)
                    return api:Set(textTitle, textContent)
                end
                function api:Get()
                    return { Title = titleLabel.Text, Content = contentLabel.Text }
                end
                return api
            end

            function cardApi:AddSection(title_, subtitle_)
                local holder = create("Frame", {
                    BackgroundColor3 = Theme.Field,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                }, {
                    corner(9),
                    stroke(Theme.StrokeSoft, 1, 0.68),
                    padding(12),
                    create("UIListLayout", {
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local titleLabel = create("TextLabel", {
                    Text = tostring(title_ or "Section"),
                    FontFace = Theme.FontSemibold,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local subtitleLabel = nil
                if subtitle_ and subtitle_ ~= "" then
                    subtitleLabel = create("TextLabel", {
                        Text = tostring(subtitle_),
                        FontFace = Theme.Font,
                        TextSize = 12,
                        TextColor3 = Theme.TextDark,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 2,
                        Parent = holder,
                    })
                end

                local body = create("Frame", {
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    ZIndex = 2,
                    Parent = holder,
                }, {
                    create("UIListLayout", {
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local sectionApi = {
                    Frame = body,
                    Container = holder,
                    Title = titleLabel,
                    Subtitle = subtitleLabel,
                }

                function sectionApi:AddDivider(text__)
                    local line = create("Frame", {
                        BackgroundColor3 = Theme.Stroke,
                        BackgroundTransparency = 0.35,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 1),
                        ZIndex = 2,
                        Parent = body,
                    })
                    if text__ and text__ ~= "" then
                        local wrapper = create("Frame", {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 18),
                            ZIndex = 2,
                            Parent = body,
                        })
                        create("TextLabel", {
                            Text = tostring(text__),
                            FontFace = Theme.FontSemibold,
                            TextSize = 12,
                            TextColor3 = Theme.TextDimmer,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 2,
                            Parent = wrapper,
                        })
                    end
                    return line
                end

                function sectionApi:AddLabel(text__)
                    return createSimpleLabel(body, text__, 13, Theme.TextDark)
                end

                function sectionApi:AddParagraph(paragraphTitle, paragraphText)
                    local paragraph = create("Frame", {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        ZIndex = 2,
                        Parent = body,
                    }, {
                        create("UIListLayout", {
                            Padding = UDim.new(0, 4),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                    })
                    createSimpleLabel(paragraph, paragraphTitle, 13, Theme.Text, 1)
                    local txt = create("TextLabel", {
                        Text = tostring(paragraphText or ""),
                        FontFace = Theme.Font,
                        TextSize = 12,
                        TextColor3 = Theme.TextDark,
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 2,
                        Parent = paragraph,
                    })
                    return txt
                end

                return decorateExtendedApi(holder, holder, sectionApi)
            end

            function cardApi:AddButtonEx(config)
                local cfg = normalizeExtConfig(config, "Button")
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, cfg.Height or 34),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                local btn = makeButton(
                    holder,
                    cfg.Text or cfg.Name or "Button",
                    cfg.Variant or "secondary",
                    nil,
                    cfg.Height or 34,
                    function()
                        if type(cfg.Callback) == "function" then
                            Library:SafeCall(cfg.Callback)
                        end
                    end
                )

                local btnLabel = nil
                for _, child in ipairs(btn:GetChildren()) do
                    if child:IsA("TextLabel") then
                        btnLabel = child
                        break
                    end
                end

                local iconHolder = nil
                local buttonIcon = cfg.Icon
                if buttonIcon == nil then
                    buttonIcon = "star"
                elseif buttonIcon == false then
                    buttonIcon = nil
                end
                if buttonIcon then
                    iconHolder = create("Frame", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 12, 0.5, 0),
                        Size = UDim2.new(0, 16, 0, 16),
                        ZIndex = 5,
                        Parent = btn,
                    })

                    local _, iconColor = getButtonVariant(cfg.Variant or "secondary")

                    if string.lower(tostring(buttonIcon)) == "play" then
                        -- Filled arrow instead of the hollow outline version.
                        create("TextLabel", {
                            Text = "▶",
                            FontFace = Theme.FontBold,
                            TextSize = 13,
                            TextColor3 = iconColor,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            TextXAlignment = Enum.TextXAlignment.Center,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            ZIndex = 6,
                            Parent = iconHolder,
                        })
                    else
                        buildIcon(iconHolder, tostring(buttonIcon), 15, iconColor)
                    end

                    if btnLabel then
                        btnLabel.Position = UDim2.new(0, 36, 0, 0)
                        btnLabel.Size = UDim2.new(1, -48, 1, 0)
                        btnLabel.TextXAlignment = Enum.TextXAlignment.Left
                        btnLabel.TextYAlignment = Enum.TextYAlignment.Center
                    end
                elseif btnLabel then
                    btnLabel.TextYAlignment = Enum.TextYAlignment.Center
                end

                local api = decorateExtendedApi(holder, btn, {
                    Button = btn,
                    IconHolder = iconHolder,
                })

                local originalText = cfg.Text or cfg.Name or "Button"
                local loading = false
                local loadingToken = 0

                function api:SetText(newText)
                    originalText = tostring(newText or "")
                    if btnLabel then
                        btnLabel.Text = loading and "Loading..." or originalText
                    end
                    return api
                end

                function api:SetLoading(value, loadingText)
                    loading = value == true
                    loadingToken += 1
                    local token = loadingToken

                    pcall(function() btn.Interactable = not loading end)
                    btn.Active = not loading

                    if btnLabel then
                        btnLabel.Text = loading and tostring(loadingText or "Loading...") or originalText
                    end

                    if loading then
                        task.spawn(function()
                            local dots = 0
                            while loading and token == loadingToken and btn.Parent do
                                dots = (dots + 1) % 4
                                if btnLabel then
                                    btnLabel.Text = tostring(loadingText or "Loading") .. string.rep(".", dots)
                                end
                                task.wait(0.35)
                            end
                        end)
                    end

                    return api
                end

                function api:IsLoading()
                    return loading
                end

                function api:RunAsync(work, loadingText)
                    if loading or type(work) ~= "function" then return false end
                    api:SetLoading(true, loadingText)
                    task.spawn(function()
                        local ok, result = pcall(work)
                        api:SetLoading(false)
                        if not ok then
                            Library:Notify({
                                Title = "Action",
                                Content = tostring(result),
                                Type = "Error",
                            })
                        end
                    end)
                    return true
                end

                return api
            end


            function cardApi:AddInput(config)
                local cfg = normalizeExtConfig(config, "Input")
                local value = tostring(cfg.Default or cfg.Value or "")
                local finishedOnly = cfg.Finished == true
                local numeric = cfg.Numeric == true
                local allowEmpty = cfg.AllowEmpty ~= false
                local maxLength = tonumber(cfg.MaxLength)
                if maxLength then maxLength = math.max(1, math.floor(maxLength)) end
                local emptyReset = tostring(cfg.EmptyReset ~= nil and cfg.EmptyReset or value)
                local mutating = false
                local api = nil

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 58),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                local label = create("TextLabel", {
                    Text = cfg.Text or cfg.Name or "Input",
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local input = create("TextBox", {
                    Text = value,
                    PlaceholderText = tostring(cfg.Placeholder or ""),
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDimmer,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.Field,
                    ClearTextOnFocus = cfg.ClearTextOnFocus == true,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 34),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(8), padding(11) })

                local function sanitize(text)
                    text = tostring(text or "")
                    if numeric then
                        local sign = text:sub(1, 1) == "-" and "-" or ""
                        local body = text:gsub("[^%d%.]", "")
                        local firstDot = body:find("%.")
                        if firstDot then
                            body = body:sub(1, firstDot) .. body:sub(firstDot + 1):gsub("%.", "")
                        end
                        text = sign .. body
                    end
                    if maxLength and #text > maxLength then
                        text = text:sub(1, maxLength)
                    end
                    return text
                end

                local function publish(fire, source)
                    value = sanitize(input.Text)
                    if input.Text ~= value then
                        mutating = true
                        input.Text = value
                        mutating = false
                    end

                    Library:_UpdateFlagValue(cfg.Flag, value)
                    if fire ~= false and type(cfg.Callback or cfg.OnChanged) == "function" then
                        Library:SafeCall(cfg.Callback or cfg.OnChanged, value, source)
                    end
                    if api and type(api.Emit) == "function" then
                        api:Emit("Changed", value, source or "input")
                    end
                end

                input:GetPropertyChangedSignal("Text"):Connect(function()
                    if mutating then return end
                    local sanitized = sanitize(input.Text)
                    if sanitized ~= input.Text then
                        mutating = true
                        input.Text = sanitized
                        mutating = false
                    end
                    value = sanitized
                    Library:_UpdateFlagValue(cfg.Flag, value)
                    if not finishedOnly then publish(true, "input") end
                end)

                input.Focused:Connect(function()
                    smoothTween(input, { BackgroundColor3 = Theme.FieldHover }, MOTION.Fast)
                end)

                input.FocusLost:Connect(function(enterPressed)
                    if input.Text == "" and not allowEmpty then
                        mutating = true
                        input.Text = emptyReset
                        mutating = false
                    end
                    smoothTween(input, { BackgroundColor3 = Theme.Field }, MOTION.Normal)
                    publish(true, enterPressed and "enter" or "blur")
                end)

                api = decorateExtendedApi(holder, input, {
                    Input = input,
                    Label = label,
                }, cfg.Flag)
                api.Type = "Input"
                api.Name = cfg.Text or cfg.Name or "Input"
                api.Default = value

                function api:Set(v)
                    mutating = true
                    input.Text = sanitize(v)
                    mutating = false
                    publish(true, "set")
                    return api
                end
                function api:SetSilent(v)
                    mutating = true
                    input.Text = sanitize(v)
                    mutating = false
                    publish(false, "set")
                    return api
                end
                function api:Get() return value end
                function api:SetText(text) label.Text = tostring(text or ""); return api end
                function api:SetPlaceholder(text) input.PlaceholderText = tostring(text or ""); return api end
                function api:Focus() input:CaptureFocus(); return api end
                function api:Blur() input:ReleaseFocus(); return api end
                api.GetConfigValue = api.Get
                api.SetConfigValue = api.Set
                api.SetConfigValueSilent = api.SetSilent

                registerExtendedFlag(cfg.Flag, api)
                Library:_UpdateFlagValue(cfg.Flag, value)
                return api
            end

            function cardApi:AddDropdownEx(config)
                local cfg = normalizeExtConfig(config, "Dropdown")
                local options = {}
                for _, option in ipairs(cfg.Options or cfg.Values or {}) do
                    table.insert(options, option)
                end

                local disabledValues = cfg.DisabledValues or {}
                local valueImages = cfg.ValueImages or {}
                local api = nil
                local specialType = string.lower(tostring(cfg.SpecialType or ""))
                local specialObjects = {}
                local teamsService = specialType == "team" and game:GetService("Teams") or nil
                local displayFormatter = cfg.FormatDisplayValue
                local listFormatter = cfg.FormatListValue
                local searchFormatter = cfg.FormatSearchValue
                local searchable = cfg.Searchable == true
                local maxVisible = math.max(1, math.floor(tonumber(cfg.MaxVisibleDropdownItems) or 6))
                local allowNull = cfg.AllowNull == true
                local query = ""

                local function isDisabled(option)
                    if type(disabledValues) ~= "table" then return false end
                    if disabledValues[option] == true or disabledValues[tostring(option)] == true then return true end
                    for _, item in ipairs(disabledValues) do
                        if item == option or tostring(item) == tostring(option) then return true end
                    end
                    return false
                end

                local function imageFor(option)
                    if type(valueImages) ~= "table" then return nil end
                    local image = valueImages[option]
                    if image == nil then image = valueImages[tostring(option)] end
                    if image == nil or tostring(image) == "" then return nil end
                    return tostring(image)
                end

                local function formatValue(formatter, option)
                    if option == nil then return tostring(cfg.NullText or "None") end
                    if type(formatter) == "function" then
                        local ok, result = pcall(formatter, option)
                        if ok and result ~= nil then return tostring(result) end
                    end
                    return tostring(option)
                end

                local function displayText(option)
                    return formatValue(displayFormatter, option)
                end

                local function listText(option)
                    return formatValue(listFormatter or displayFormatter, option)
                end

                local function searchableText(option)
                    return formatValue(searchFormatter or listFormatter or displayFormatter, option)
                end

                local function optionEquals(a, b)
                    return a == b or (a ~= nil and b ~= nil and tostring(a) == tostring(b))
                end

                local function collectSpecialOptions()
                    if specialType ~= "player" and specialType ~= "team" then return nil end
                    local collected = {}
                    table.clear(specialObjects)
                    if specialType == "player" then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if not (cfg.ExcludeLocalPlayer == true and player == LocalPlayer) then
                                table.insert(collected, player.Name)
                                specialObjects[player.Name] = player
                            end
                        end
                    elseif teamsService then
                        for _, team in ipairs(teamsService:GetTeams()) do
                            table.insert(collected, team.Name)
                            specialObjects[team.Name] = team
                        end
                    end
                    table.sort(collected, function(a, b)
                        return string.lower(tostring(a)) < string.lower(tostring(b))
                    end)
                    return collected
                end

                local specialOptions = collectSpecialOptions()
                if specialOptions then options = specialOptions end

                local function queueSpecialImages()
                    if specialType ~= "player" or cfg.EnablePlayerImages ~= true then return end
                    for name, player in pairs(specialObjects) do
                        if typeof(player) == "Instance" and player:IsA("Player") and valueImages[name] == nil then
                            task.spawn(function()
                                local ok, image = pcall(function()
                                    return Players:GetUserThumbnailAsync(
                                        player.UserId,
                                        Enum.ThumbnailType.HeadShot,
                                        Enum.ThumbnailSize.Size48x48
                                    )
                                end)
                                if ok and image and specialObjects[name] == player then
                                    valueImages[name] = image
                                    if api and api.Refresh then api:Refresh() end
                                end
                            end)
                        end
                    end
                end

                local value = cfg.Default
                if value == nil and not allowNull then value = options[1] end

                local opened = false
                local rows = {}
                local BASE_HEIGHT = 58

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, BASE_HEIGHT),
                    LayoutOrder = nextOrder(),
                    ZIndex = 6,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = cfg.Text or cfg.Name or "Dropdown",
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = holder,
                })

                local button = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.Field,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 32),
                    ZIndex = 7,
                    Parent = holder,
                }, { corner(8) })

                local valueIcon = create("ImageLabel", {
                    Image = "",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 9, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Visible = false,
                    ZIndex = 8,
                    Parent = button,
                })

                local valueLabel = create("TextLabel", {
                    Text = value == nil and tostring(cfg.NullText or "None") or displayText(value),
                    FontFace = Theme.FontSemibold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 8,
                    Parent = button,
                })

                local arrowHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Rotation = 90,
                    ZIndex = 8,
                    Parent = button,
                })
                buildIcon(arrowHolder, "chevron-right", 14, Theme.TextDark)

                local menu = create("Frame", {
                    BackgroundColor3 = Theme.TitleBar,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 20,
                    Parent = holder,
                }, { corner(8) })

                local searchBox = nil
                if searchable then
                    searchBox = create("TextBox", {
                        Text = "",
                        PlaceholderText = tostring(cfg.SearchPlaceholder or "Search..."),
                        ClearTextOnFocus = false,
                        FontFace = Theme.Font,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        PlaceholderColor3 = Theme.TextDimmer,
                        BackgroundColor3 = Theme.Field,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 5, 0, 5),
                        Size = UDim2.new(1, -10, 0, 29),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 22,
                        Parent = menu,
                    }, { corner(6), padding(9) })
                end

                local list = create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0, searchable and 39 or 5),
                    Size = UDim2.new(1, -10, 1, searchable and -44 or -10),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.TextDimmer,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    ZIndex = 21,
                    Parent = menu,
                })

                local function filteredOptions()
                    if query == "" then return options end
                    local out = {}
                    local needle = string.lower(query)
                    for _, option in ipairs(options) do
                        if string.find(string.lower(searchableText(option)), needle, 1, true) then
                            table.insert(out, option)
                        end
                    end
                    return out
                end

                local function targetHeight()
                    local count = #filteredOptions()
                    local rowsHeight = math.max(29, math.min(count, maxVisible) * 31)
                    return rowsHeight + 10 + (searchable and 34 or 0)
                end

                local function refreshValueDisplay()
                    valueLabel.Text = value == nil and tostring(cfg.NullText or "None") or displayText(value)
                    local image = value ~= nil and imageFor(value) or nil
                    valueIcon.Visible = image ~= nil
                    valueIcon.Image = image or ""
                    valueLabel.Position = image and UDim2.new(0, 33, 0, 0) or UDim2.new(0, 10, 0, 0)
                    valueLabel.Size = image and UDim2.new(1, -63, 1, 0) or UDim2.new(1, -40, 1, 0)
                end

                local function clearRows()
                    for _, row_ in ipairs(rows) do
                        if row_ and row_.Parent then row_:Destroy() end
                    end
                    table.clear(rows)
                end

                local function resizeOpenMenu()
                    if not opened then return end
                    local h = targetHeight()
                    menu.Size = UDim2.new(1, 0, 0, h)
                    holder.Size = UDim2.new(1, 0, 0, BASE_HEIGHT + h + 6)
                end

                local function closeMenu()
                    opened = false
                    smoothTween(menu, { Size = UDim2.new(1, 0, 0, 0) }, 0.14)
                    smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT) }, 0.14)
                    smoothTween(arrowHolder, { Rotation = 90 }, 0.14)
                    task.delay(0.15, function()
                        if not opened and menu then menu.Visible = false end
                    end)
                    if Library._openDropdownCloser == closeMenu then
                        Library._openDropdownCloser = nil
                    end
                    if api and api.Emit then api:Emit("Close") end
                end

                local function selectValue(v, fire)
                    if v ~= nil and isDisabled(v) then return false end
                    if v == nil and not allowNull then v = options[1] end
                    value = v
                    refreshValueDisplay()
                    Library:_UpdateFlagValue(cfg.Flag, value)
                    local callback = cfg.Callback or cfg.OnChanged
                    if fire ~= false and type(callback) == "function" then
                        Library:SafeCall(callback, value)
                    end
                    if api and type(api.Emit) == "function" then api:Emit("Changed", value) end
                    return true
                end

                local virtualOptions = {}
                local ROW_HEIGHT = 31
                local rebuild

                local function renderRows()
                    clearRows()
                    local firstIndex = math.max(1, math.floor(list.CanvasPosition.Y / ROW_HEIGHT) + 1)
                    local renderCount = math.max(maxVisible + 2, 4)

                    for slot = 1, renderCount do
                        local i = firstIndex + slot - 1
                        local option = virtualOptions[i]
                        if option == nil then break end

                        local optionText = listText(option)
                        local selected = value ~= nil and optionEquals(value, option)
                        local disabled = isDisabled(option)
                        local image = imageFor(option)

                        local row_ = create("TextButton", {
                            Text = "",
                            AutoButtonColor = false,
                            BorderSizePixel = 0,
                            BackgroundColor3 = selected and Theme.CardHover or Theme.Field,
                            BackgroundTransparency = disabled and 0.35 or 0,
                            Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT),
                            Size = UDim2.new(1, -4, 0, 28),
                            ZIndex = 22,
                            Parent = list,
                        }, { corner(6) })

                        if image then
                            create("ImageLabel", {
                                Image = image,
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0, 8, 0.5, -8),
                                Size = UDim2.new(0, 16, 0, 16),
                                ImageTransparency = disabled and 0.45 or 0,
                                ZIndex = 23,
                                Parent = row_,
                            })
                        end

                        create("TextLabel", {
                            Text = optionText,
                            FontFace = Theme.Font,
                            TextSize = 13,
                            TextColor3 = disabled and Theme.TextDimmer or Theme.Text,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, image and 32 or 9, 0, 0),
                            Size = UDim2.new(1, image and -40 or -18, 1, 0),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            ZIndex = 23,
                            Parent = row_,
                        })

                        if not disabled then
                            row_.MouseEnter:Connect(function()
                                smoothTween(row_, { BackgroundColor3 = Theme.FieldHover }, 0.10)
                            end)
                            row_.MouseLeave:Connect(function()
                                smoothTween(row_, {
                                    BackgroundColor3 = value ~= nil and optionEquals(value, option) and Theme.CardHover or Theme.Field,
                                }, 0.12)
                            end)
                            row_.MouseButton1Click:Connect(function()
                                if selectValue(option, true) then
                                    rebuild()
                                    closeMenu()
                                end
                            end)
                        end

                        table.insert(rows, row_)
                    end
                end

                rebuild = function()
                    virtualOptions = filteredOptions()
                    list.CanvasSize = UDim2.new(0, 0, 0, #virtualOptions * ROW_HEIGHT)
                    local maxY = math.max(0, #virtualOptions * ROW_HEIGHT - math.max(list.AbsoluteSize.Y, ROW_HEIGHT))
                    if list.CanvasPosition.Y > maxY then
                        list.CanvasPosition = Vector2.new(list.CanvasPosition.X, maxY)
                    end
                    renderRows()
                    resizeOpenMenu()
                end

                list:GetPropertyChangedSignal("CanvasPosition"):Connect(renderRows)

                local function openMenu()
                    if Library._openDropdownCloser and Library._openDropdownCloser ~= closeMenu then
                        pcall(Library._openDropdownCloser)
                    end
                    opened = true
                    rebuild()
                    menu.Visible = true
                    local h = targetHeight()
                    smoothTween(menu, { Size = UDim2.new(1, 0, 0, h) }, 0.16)
                    smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT + h + 6) }, 0.16)
                    smoothTween(arrowHolder, { Rotation = -90 }, 0.16)
                    Library._openDropdownCloser = closeMenu
                    if searchBox then task.defer(function() pcall(function() searchBox:CaptureFocus() end) end) end
                    if api and api.Emit then api:Emit("Open") end
                end

                if searchBox then
                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        query = searchBox.Text
                        rebuild()
                    end)
                end

                button.MouseButton1Click:Connect(function()
                    if opened then closeMenu() else openMenu() end
                end)

                api = decorateExtendedApi(holder, button, { Menu = menu, SearchBox = searchBox, List = list, Virtualized = true }, cfg.Flag)
                api.Type = "DropdownEx"
                api.Name = cfg.Text or cfg.Name or "Dropdown"

                function api:Set(v)
                    selectValue(v, true)
                    rebuild()
                    return api
                end

                function api:SetSilent(v)
                    selectValue(v, false)
                    rebuild()
                    return api
                end

                function api:Get() return value end

                function api:SetOptions(newOptions, newDefault)
                    options = {}
                    for _, option in ipairs(newOptions or {}) do table.insert(options, option) end
                    value = newDefault
                    if value == nil and not allowNull then value = options[1] end
                    refreshValueDisplay()
                    rebuild()
                    Library:_UpdateFlagValue(cfg.Flag, value)
                    return api
                end

                function api:SetDisabledValues(values)
                    disabledValues = type(values) == "table" and values or {}
                    if value ~= nil and isDisabled(value) then
                        if allowNull then
                            value = nil
                        else
                            value = options[1]
                        end
                        if value ~= nil and isDisabled(value) then
                            for _, option in ipairs(options) do
                                if not isDisabled(option) then value = option; break end
                            end
                        end
                        refreshValueDisplay()
                        Library:_UpdateFlagValue(cfg.Flag, value)
                    end
                    rebuild()
                    return api
                end

                function api:SetValueImages(images)
                    valueImages = type(images) == "table" and images or {}
                    refreshValueDisplay()
                    rebuild()
                    return api
                end

                function api:SetFormatters(display, list, search)
                    displayFormatter = type(display) == "function" and display or nil
                    listFormatter = type(list) == "function" and list or nil
                    searchFormatter = type(search) == "function" and search or nil
                    refreshValueDisplay()
                    rebuild()
                    return api
                end

                function api:Refresh()
                    local special = collectSpecialOptions()
                    if special then
                        local previous = value
                        options = special
                        local found = false
                        for _, option in ipairs(options) do
                            if optionEquals(option, previous) then found = true; break end
                        end
                        if not found then
                            if allowNull then
                                value = nil
                            else
                                value = options[1]
                            end
                        end
                        queueSpecialImages()
                        refreshValueDisplay()
                        Library:_UpdateFlagValue(cfg.Flag, value)
                    end
                    rebuild()
                    return api
                end

                function api:GetResolvedValue()
                    return specialObjects[tostring(value)] or value
                end

                function api:GetSpecialType()
                    return specialType ~= "" and specialType or nil
                end

                function api:SetSearch(text)
                    query = tostring(text or "")
                    if searchBox then searchBox.Text = query else rebuild() end
                    return api
                end

                function api:Open() if not opened then openMenu() end; return api end
                function api:Close() if opened then closeMenu() end; return api end
                function api:IsOpen() return opened end
                function api:GetRenderedRowCount() return #rows end
                function api:GetOptionCount() return #options end

                api.GetValue = api.Get
                api.SetValue = api.Set
                api.SetValueSilent = api.SetSilent
                api.GetConfigValue = api.Get
                api.SetConfigValue = api.Set
                api.SetConfigValueSilent = api.SetSilent

                refreshValueDisplay()
                registerExtendedFlag(cfg.Flag, api)
                Library:_UpdateFlagValue(cfg.Flag, value)

                if specialType == "player" then
                    window:Track(Players.PlayerAdded:Connect(function() api:Refresh() end))
                    window:Track(Players.PlayerRemoving:Connect(function() task.defer(function() api:Refresh() end) end))
                    queueSpecialImages()
                elseif specialType == "team" and teamsService then
                    window:Track(teamsService.ChildAdded:Connect(function() api:Refresh() end))
                    window:Track(teamsService.ChildRemoved:Connect(function() task.defer(function() api:Refresh() end) end))
                end

                return api
            end

            function cardApi:AddMultiDropdown(config)
                local cfg = normalizeExtConfig(config, "Multi Dropdown")
                local options = {}
                for _, option in ipairs(cfg.Options or cfg.Values or {}) do
                    table.insert(options, option)
                end

                local disabledValues = cfg.DisabledValues or {}
                local valueImages = cfg.ValueImages or {}
                local displayFormatter = cfg.FormatDisplayValue
                local listFormatter = cfg.FormatListValue
                local searchFormatter = cfg.FormatSearchValue
                local searchable = cfg.Searchable == true
                local maxVisible = math.max(1, math.floor(tonumber(cfg.MaxVisibleDropdownItems) or 7))
                local dragSelect = cfg.DragSelect == true
                local specialType = string.lower(tostring(cfg.SpecialType or ""))
                local specialObjects = {}
                local teamsService = specialType == "team" and game:GetService("Teams") or nil
                local selectedMap = {}
                local opened = false
                local rows = {}
                local query = ""
                local BASE_HEIGHT = 58
                local api = nil
                local dragState = nil

                local function formatValue(formatter, option)
                    if type(formatter) == "function" then
                        local ok, result = pcall(formatter, option)
                        if ok and result ~= nil then return tostring(result) end
                    end
                    return tostring(option)
                end

                local function displayText(option)
                    return formatValue(displayFormatter, option)
                end

                local function listText(option)
                    return formatValue(listFormatter or displayFormatter, option)
                end

                local function searchableText(option)
                    return formatValue(searchFormatter or listFormatter or displayFormatter, option)
                end

                local function isDisabled(option)
                    if type(disabledValues) ~= "table" then return false end
                    if disabledValues[option] == true or disabledValues[tostring(option)] == true then return true end
                    for _, item in ipairs(disabledValues) do
                        if item == option or tostring(item) == tostring(option) then return true end
                    end
                    return false
                end

                local function imageFor(option)
                    if type(valueImages) ~= "table" then return nil end
                    local image = valueImages[option]
                    if image == nil then image = valueImages[tostring(option)] end
                    if image == nil or tostring(image) == "" then return nil end
                    return tostring(image)
                end

                local function collectSpecialOptions()
                    if specialType ~= "player" and specialType ~= "team" then return nil end
                    local collected = {}
                    table.clear(specialObjects)
                    if specialType == "player" then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if not (cfg.ExcludeLocalPlayer == true and player == LocalPlayer) then
                                table.insert(collected, player.Name)
                                specialObjects[player.Name] = player
                            end
                        end
                    elseif teamsService then
                        for _, team in ipairs(teamsService:GetTeams()) do
                            table.insert(collected, team.Name)
                            specialObjects[team.Name] = team
                        end
                    end
                    table.sort(collected, function(a, b)
                        return string.lower(tostring(a)) < string.lower(tostring(b))
                    end)
                    return collected
                end

                local specialOptions = collectSpecialOptions()
                if specialOptions then options = specialOptions end

                if type(cfg.Default) == "table" then
                    if #cfg.Default > 0 then
                        for _, value_ in ipairs(cfg.Default) do selectedMap[tostring(value_)] = true end
                    else
                        for key, enabled in pairs(cfg.Default) do
                            if enabled == true then selectedMap[tostring(key)] = true end
                        end
                    end
                end

                local function filteredOptions()
                    if query == "" then return options end
                    local out = {}
                    local needle = string.lower(query)
                    for _, option in ipairs(options) do
                        if string.find(string.lower(searchableText(option)), needle, 1, true) then
                            table.insert(out, option)
                        end
                    end
                    return out
                end

                local function getSelectedArray()
                    local out = {}
                    for _, option in ipairs(options) do
                        if selectedMap[tostring(option)] == true and not isDisabled(option) then
                            table.insert(out, option)
                        end
                    end
                    return out
                end

                local function getResolvedValues()
                    local out = {}
                    for _, value_ in ipairs(getSelectedArray()) do
                        table.insert(out, specialObjects[tostring(value_)] or value_)
                    end
                    return out
                end

                local function getSummary()
                    local selected = getSelectedArray()
                    if #selected == 0 then return tostring(cfg.NullText or "None") end
                    local parts = {}
                    local limit = math.max(1, math.floor(tonumber(cfg.SummaryLimit) or 3))
                    for i, item in ipairs(selected) do
                        if i > limit then break end
                        table.insert(parts, displayText(item))
                    end
                    if #selected > limit then table.insert(parts, "+" .. tostring(#selected - limit)) end
                    return table.concat(parts, ", ")
                end

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, BASE_HEIGHT),
                    LayoutOrder = nextOrder(),
                    ZIndex = 6,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = cfg.Text or cfg.Name or "Multi Dropdown",
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = holder,
                })

                local button = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.Field,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 32),
                    ZIndex = 7,
                    Parent = holder,
                }, { corner(8) })

                local valueLabel = create("TextLabel", {
                    Text = getSummary(),
                    FontFace = Theme.FontSemibold,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 8,
                    Parent = button,
                })

                local arrowHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Rotation = 90,
                    ZIndex = 8,
                    Parent = button,
                })
                buildIcon(arrowHolder, "chevron-right", 14, Theme.TextDark)

                local menu = create("Frame", {
                    BackgroundColor3 = Theme.TitleBar,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 20,
                    Parent = holder,
                }, { corner(8) })

                local searchBox = nil
                if searchable then
                    searchBox = create("TextBox", {
                        Text = "",
                        PlaceholderText = tostring(cfg.SearchPlaceholder or "Search..."),
                        ClearTextOnFocus = false,
                        FontFace = Theme.Font,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        PlaceholderColor3 = Theme.TextDimmer,
                        BackgroundColor3 = Theme.Field,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 5, 0, 5),
                        Size = UDim2.new(1, -10, 0, 29),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 22,
                        Parent = menu,
                    }, { corner(6), padding(9) })
                end

                local list = create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0, searchable and 39 or 5),
                    Size = UDim2.new(1, -10, 1, searchable and -44 or -10),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.TextDimmer,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    ZIndex = 21,
                    Parent = menu,
                })

                local function targetHeight()
                    local count = #filteredOptions()
                    local rowsHeight = math.max(30, math.min(count, maxVisible) * 33)
                    return rowsHeight + 10 + (searchable and 34 or 0)
                end

                local function syncLabel(fire, source)
                    local selected = getSelectedArray()
                    valueLabel.Text = getSummary()
                    Library:_UpdateFlagValue(cfg.Flag, selected)
                    local callback = cfg.Callback or cfg.OnChanged
                    if fire ~= false and type(callback) == "function" then
                        Library:SafeCall(callback, selected, source)
                    end
                    if api and type(api.Emit) == "function" then
                        api:Emit("Changed", selected, source or "selection")
                    end
                end

                local function clearRows()
                    for _, row_ in ipairs(rows) do
                        if row_ and row_.Parent then row_:Destroy() end
                    end
                    table.clear(rows)
                end

                local function resizeOpenMenu()
                    if not opened then return end
                    local h = targetHeight()
                    menu.Size = UDim2.new(1, 0, 0, h)
                    holder.Size = UDim2.new(1, 0, 0, BASE_HEIGHT + h + 6)
                end

                local function setOption(option, state, fire, source)
                    if isDisabled(option) then return false end
                    selectedMap[tostring(option)] = state == true
                    syncLabel(fire, source)
                    return true
                end

                local virtualOptions = {}
                local ROW_HEIGHT = 33
                local rebuild

                local function renderRows()
                    clearRows()
                    local firstIndex = math.max(1, math.floor(list.CanvasPosition.Y / ROW_HEIGHT) + 1)
                    local renderCount = math.max(maxVisible + 2, 4)

                    for slot = 1, renderCount do
                        local i = firstIndex + slot - 1
                        local option = virtualOptions[i]
                        if option == nil then break end

                        local optionKey = tostring(option)
                        local checked = selectedMap[optionKey] == true
                        local disabled = isDisabled(option)
                        local image = imageFor(option)

                        local row_ = create("TextButton", {
                            Text = "",
                            AutoButtonColor = false,
                            BorderSizePixel = 0,
                            BackgroundColor3 = checked and Theme.CardHover or Theme.Field,
                            BackgroundTransparency = disabled and 0.35 or 0,
                            Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT),
                            Size = UDim2.new(1, -4, 0, 30),
                            ZIndex = 22,
                            Parent = list,
                        }, { corner(6) })

                        local box = create("Frame", {
                            BackgroundColor3 = checked and Theme.Accent or Theme.FieldHover,
                            BackgroundTransparency = disabled and 0.45 or 0,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 8, 0.5, 0),
                            Size = UDim2.new(0, 15, 0, 15),
                            BorderSizePixel = 0,
                            ZIndex = 23,
                            Parent = row_,
                        }, { corner(5) })

                        local checkHolder = create("Frame", {
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(0, 10, 0, 10),
                            Visible = checked,
                            ZIndex = 24,
                            Parent = box,
                        })
                        buildIcon(checkHolder, "check", 10, Theme.PrimaryText)

                        local textX = 31
                        if image then
                            create("ImageLabel", {
                                Image = image,
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0, 31, 0.5, -8),
                                Size = UDim2.new(0, 16, 0, 16),
                                ImageTransparency = disabled and 0.45 or 0,
                                ZIndex = 23,
                                Parent = row_,
                            })
                            textX = 53
                        end

                        create("TextLabel", {
                            Text = listText(option),
                            FontFace = Theme.Font,
                            TextSize = 12,
                            TextColor3 = disabled and Theme.TextDimmer or Theme.Text,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, textX, 0, 0),
                            Size = UDim2.new(1, -textX - 7, 1, 0),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            ZIndex = 23,
                            Parent = row_,
                        })

                        if not disabled then
                            row_.MouseEnter:Connect(function()
                                if dragSelect and dragState ~= nil then
                                    setOption(option, dragState, true, "drag")
                                    rebuild()
                                    return
                                end
                                smoothTween(row_, { BackgroundColor3 = Theme.FieldHover }, 0.10)
                            end)
                            row_.MouseLeave:Connect(function()
                                smoothTween(row_, {
                                    BackgroundColor3 = selectedMap[optionKey] and Theme.CardHover or Theme.Field,
                                }, 0.12)
                            end)

                            if dragSelect then
                                row_.InputBegan:Connect(function(inputObject)
                                    if inputObject.UserInputType == Enum.UserInputType.MouseButton1
                                        or inputObject.UserInputType == Enum.UserInputType.Touch then
                                        dragState = not (selectedMap[optionKey] == true)
                                        setOption(option, dragState, true, "drag")
                                        rebuild()
                                    end
                                end)
                            else
                                row_.MouseButton1Click:Connect(function()
                                    setOption(option, not (selectedMap[optionKey] == true), true, "click")
                                    rebuild()
                                end)
                            end
                        end

                        table.insert(rows, row_)
                    end
                end

                rebuild = function()
                    virtualOptions = filteredOptions()
                    list.CanvasSize = UDim2.new(0, 0, 0, #virtualOptions * ROW_HEIGHT)
                    local maxY = math.max(0, #virtualOptions * ROW_HEIGHT - math.max(list.AbsoluteSize.Y, ROW_HEIGHT))
                    if list.CanvasPosition.Y > maxY then
                        list.CanvasPosition = Vector2.new(list.CanvasPosition.X, maxY)
                    end
                    renderRows()
                    resizeOpenMenu()
                end

                list:GetPropertyChangedSignal("CanvasPosition"):Connect(renderRows)

                if dragSelect then
                    window:Track(UserInputService.InputEnded:Connect(function(inputObject)
                        if inputObject.UserInputType == Enum.UserInputType.MouseButton1
                            or inputObject.UserInputType == Enum.UserInputType.Touch then
                            dragState = nil
                        end
                    end))
                end

                local function closeMenu()
                    opened = false
                    dragState = nil
                    smoothTween(menu, { Size = UDim2.new(1, 0, 0, 0) }, 0.14)
                    smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT) }, 0.14)
                    smoothTween(arrowHolder, { Rotation = 90 }, 0.14)
                    task.delay(0.15, function()
                        if not opened and menu then menu.Visible = false end
                    end)
                    if Library._openDropdownCloser == closeMenu then
                        Library._openDropdownCloser = nil
                    end
                    if api and api.Emit then api:Emit("Close") end
                end

                local function openMenu()
                    if Library._openDropdownCloser and Library._openDropdownCloser ~= closeMenu then
                        pcall(Library._openDropdownCloser)
                    end
                    opened = true
                    rebuild()
                    menu.Visible = true
                    local h = targetHeight()
                    smoothTween(menu, { Size = UDim2.new(1, 0, 0, h) }, 0.16)
                    smoothTween(holder, { Size = UDim2.new(1, 0, 0, BASE_HEIGHT + h + 6) }, 0.16)
                    smoothTween(arrowHolder, { Rotation = -90 }, 0.16)
                    Library._openDropdownCloser = closeMenu
                    if searchBox then task.defer(function() pcall(function() searchBox:CaptureFocus() end) end) end
                    if api and api.Emit then api:Emit("Open") end
                end

                if searchBox then
                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        query = searchBox.Text
                        rebuild()
                    end)
                end

                button.MouseButton1Click:Connect(function()
                    if opened then closeMenu() else openMenu() end
                end)

                api = decorateExtendedApi(holder, button, { Menu = menu, SearchBox = searchBox, List = list, Virtualized = true }, cfg.Flag)
                api.Type = "MultiDropdown"
                api.Name = cfg.Text or cfg.Name or "Multi Dropdown"

                function api:Set(values)
                    selectedMap = {}
                    if type(values) == "table" then
                        if #values > 0 then
                            for _, value_ in ipairs(values) do selectedMap[tostring(value_)] = true end
                        else
                            for key, enabled in pairs(values) do
                                if enabled == true then selectedMap[tostring(key)] = true end
                            end
                        end
                    end
                    rebuild()
                    syncLabel(true, "set")
                    return api
                end

                function api:SetSilent(values)
                    selectedMap = {}
                    if type(values) == "table" then
                        if #values > 0 then
                            for _, value_ in ipairs(values) do selectedMap[tostring(value_)] = true end
                        else
                            for key, enabled in pairs(values) do
                                if enabled == true then selectedMap[tostring(key)] = true end
                            end
                        end
                    end
                    rebuild()
                    syncLabel(false, "set")
                    return api
                end

                function api:Get() return getSelectedArray() end
                function api:GetResolvedValues() return getResolvedValues() end

                function api:SetOptions(newOptions)
                    options = {}
                    for _, option in ipairs(newOptions or {}) do table.insert(options, option) end
                    for key in pairs(selectedMap) do
                        local found = false
                        for _, option in ipairs(options) do
                            if tostring(option) == key then found = true; break end
                        end
                        if not found then selectedMap[key] = nil end
                    end
                    rebuild()
                    syncLabel(false, "options")
                    return api
                end

                function api:SetDisabledValues(values)
                    disabledValues = type(values) == "table" and values or {}
                    for _, option in ipairs(options) do
                        if isDisabled(option) then selectedMap[tostring(option)] = nil end
                    end
                    rebuild()
                    syncLabel(false, "disabled")
                    return api
                end

                function api:SetValueImages(images)
                    valueImages = type(images) == "table" and images or {}
                    rebuild()
                    return api
                end

                function api:SetFormatters(display, list, search)
                    displayFormatter = type(display) == "function" and display or nil
                    listFormatter = type(list) == "function" and list or nil
                    searchFormatter = type(search) == "function" and search or nil
                    rebuild()
                    syncLabel(false, "format")
                    return api
                end

                function api:SetSearch(text)
                    query = tostring(text or "")
                    if searchBox then searchBox.Text = query else rebuild() end
                    return api
                end

                function api:Refresh()
                    local special = collectSpecialOptions()
                    if special then
                        options = special
                        for key in pairs(selectedMap) do
                            local found = false
                            for _, option in ipairs(options) do
                                if tostring(option) == key then found = true; break end
                            end
                            if not found then selectedMap[key] = nil end
                        end
                        if specialType == "player" and cfg.EnablePlayerImages == true then
                            for name, player in pairs(specialObjects) do
                                if valueImages[name] == nil then
                                    task.spawn(function()
                                        local ok, image = pcall(function()
                                            return Players:GetUserThumbnailAsync(
                                                player.UserId,
                                                Enum.ThumbnailType.HeadShot,
                                                Enum.ThumbnailSize.Size48x48
                                            )
                                        end)
                                        if ok and image and specialObjects[name] == player then
                                            valueImages[name] = image
                                            if api then rebuild() end
                                        end
                                    end)
                                end
                            end
                        end
                    end
                    rebuild()
                    syncLabel(false, "refresh")
                    return api
                end

                function api:Open() if not opened then openMenu() end; return api end
                function api:Close() if opened then closeMenu() end; return api end
                function api:IsOpen() return opened end
                function api:GetRenderedRowCount() return #rows end
                function api:GetOptionCount() return #options end

                api.GetValue = api.Get
                api.SetValue = api.Set
                api.SetValueSilent = api.SetSilent
                api.GetConfigValue = function()
                    local out = {}
                    for i, v in ipairs(getSelectedArray()) do out[i] = v end
                    return out
                end
                api.SetConfigValue = api.Set
                api.SetConfigValueSilent = api.SetSilent

                registerExtendedFlag(cfg.Flag, api)
                syncLabel(false, "init")

                if specialType == "player" then
                    window:Track(Players.PlayerAdded:Connect(function() api:Refresh() end))
                    window:Track(Players.PlayerRemoving:Connect(function() task.defer(function() api:Refresh() end) end))
                    api:Refresh()
                elseif specialType == "team" and teamsService then
                    window:Track(teamsService.ChildAdded:Connect(function() api:Refresh() end))
                    window:Track(teamsService.ChildRemoved:Connect(function() task.defer(function() api:Refresh() end) end))
                end

                return api
            end

            function cardApi:AddKeybindEx(config)
                local cfg = normalizeExtConfig(config, "Keybind")

                local function parseBindable(value)
                    if typeof(value) == "EnumItem" then return value end
                    if type(value) == "string" then
                        return Enum.KeyCode[value] or Enum.UserInputType[value]
                    end
                    return nil
                end

                local modifierNames = {
                    "LeftControl", "RightControl", "LeftShift", "RightShift", "LeftAlt", "RightAlt",
                }
                local modifierLookup = {}
                for _, name in ipairs(modifierNames) do
                    local item = Enum.KeyCode[name]
                    if item then modifierLookup[item] = true end
                end

                local function normalizeModifiers(values)
                    local out, seen = {}, {}
                    if type(values) == "string" then
                        local parsed = {}
                        for token in string.gmatch(values, "[^+,%s]+") do table.insert(parsed, token) end
                        values = parsed
                    end
                    for _, value in ipairs(type(values) == "table" and values or {}) do
                        local item = parseBindable(value)
                        if item and item.EnumType == Enum.KeyCode and modifierLookup[item] and not seen[item] then
                            seen[item] = true
                            table.insert(out, item)
                        end
                    end
                    return out
                end

                local function serializeModifiers(values)
                    local out = {}
                    for i, item in ipairs(values or {}) do out[i] = item.Name end
                    return out
                end

                local function activeModifiers()
                    local out = {}
                    for _, name in ipairs(modifierNames) do
                        local item = Enum.KeyCode[name]
                        if item and UserInputService:IsKeyDown(item) then table.insert(out, item) end
                    end
                    return out
                end

                local key = parseBindable(cfg.Default or cfg.Key or cfg.DefaultKey) or Enum.KeyCode.Unknown
                local modifiers = normalizeModifiers(cfg.DefaultModifiers or cfg.Modifiers)
                local keybindManagerEntry = Library._activeWindow
                    and Library._activeWindow:RegisterKeybind(
                        cfg.Text or cfg.Name or "Keybind",
                        key,
                        cfg.Callback,
                        nil,
                        cfg.Id or cfg.Flag,
                        modifiers
                    )
                    or nil

                if keybindManagerEntry and keybindManagerEntry.Key then
                    key = keybindManagerEntry.Key
                    if type(keybindManagerEntry.Modifiers) == "table" then
                        modifiers = keybindManagerEntry.Modifiers
                    end
                end

                local mode = tostring(cfg.Mode or cfg.DefaultMode or "Toggle")
                if mode ~= "Toggle" and mode ~= "Hold" and mode ~= "Press" and mode ~= "Always" then mode = "Toggle" end
                local state = mode == "Always"
                local listening = false

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = cfg.Text or cfg.Name or "Keybind",
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -220, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local modeButton = create("TextButton", {
                    Text = string.upper(mode),
                    FontFace = Theme.FontSemibold,
                    TextSize = 10,
                    TextColor3 = Theme.Text,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.Field,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -124, 0.5, 0),
                    Size = UDim2.new(0, 82, 0, 28),
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(5) })

                local keyButton = create("TextButton", {
                    Text = "",
                    FontFace = Theme.FontSemibold,
                    TextSize = 11,
                    TextColor3 = Theme.Text,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Theme.TitleBar,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 116, 0, 28),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(5) })

                local function displayBinding()
                    local window = Library._activeWindow
                    if key == Enum.KeyCode.Unknown then return "NONE" end
                    if window and type(window._FormatKeybindKey) == "function" then
                        return window:_FormatKeybindKey(key, modifiers)
                    end
                    local parts = serializeModifiers(modifiers)
                    table.insert(parts, key.Name:upper())
                    return table.concat(parts, "+")
                end
                keyButton.Text = displayBinding()

                local modeCycle = { "Toggle", "Hold", "Press", "Always" }

                local function flagPayload(source)
                    return {
                        Key = key.Name,
                        KeyEnum = key.EnumType == Enum.UserInputType and "UserInputType" or "KeyCode",
                        Modifiers = serializeModifiers(modifiers),
                        Mode = mode,
                        State = state,
                        Source = source,
                    }
                end

                local function fireCallback(source)
                    if keybindManagerEntry and type(keybindManagerEntry.SetActive) == "function" then
                        keybindManagerEntry:SetActive(state)
                    end
                    Library:_UpdateFlagValue(cfg.Flag, flagPayload(source))
                    local callback = cfg.Callback or cfg.OnChanged
                    if type(callback) == "function" then
                        Library:SafeCall(callback, state, key, mode, source, modifiers)
                    end
                end

                local function syncManager()
                    if keybindManagerEntry then
                        keybindManagerEntry:SetKey(key)
                        if type(keybindManagerEntry.SetModifiers) == "function" then
                            keybindManagerEntry:SetModifiers(modifiers)
                        end
                        if type(keybindManagerEntry.SetMode) == "function" then
                            keybindManagerEntry:SetMode(mode)
                        end
                        if type(keybindManagerEntry.SetActive) == "function" then
                            keybindManagerEntry:SetActive(state)
                        end
                    end
                    keyButton.Text = displayBinding()
                end

                local function setMode(newMode, fire)
                    local candidate = tostring(newMode or "Toggle")
                    if candidate ~= "Toggle" and candidate ~= "Hold" and candidate ~= "Press" and candidate ~= "Always" then
                        candidate = "Toggle"
                    end
                    mode = candidate
                    modeButton.Text = mode:upper()
                    if mode == "Always" then
                        state = true
                    elseif mode == "Hold" or mode == "Press" then
                        state = false
                    end
                    if fire ~= false then fireCallback("mode")
                    else Library:_UpdateFlagValue(cfg.Flag, flagPayload("mode")) end
                end

                local function inputMatches(input)
                    if typeof(key) ~= "EnumItem" or key == Enum.KeyCode.Unknown then return false end
                    if key.EnumType == Enum.KeyCode then
                        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key
                    end
                    if key.EnumType == Enum.UserInputType then
                        return input.UserInputType == key
                    end
                    return false
                end

                local function modifiersSatisfied()
                    for _, modifier in ipairs(modifiers) do
                        if not UserInputService:IsKeyDown(modifier) then return false end
                    end
                    return true
                end

                local inputBeganConn, inputEndedConn
                inputBeganConn = window:Track(UserInputService.InputBegan:Connect(function(input, processed)
                    if processed or listening or isTextInputFocused() then return end
                    if not inputMatches(input) or not modifiersSatisfied() then return end

                    if mode == "Toggle" then
                        state = not state
                        fireCallback("input")
                    elseif mode == "Hold" then
                        if not state then state = true; fireCallback("input") end
                    elseif mode == "Press" then
                        state = true
                        fireCallback("press")
                        state = false
                        Library:_UpdateFlagValue(cfg.Flag, flagPayload("press_end"))
                        task.delay(0.14, function()
                            if keybindManagerEntry and type(keybindManagerEntry.SetActive) == "function" then
                                keybindManagerEntry:SetActive(false)
                            end
                        end)
                    elseif mode == "Always" then
                        state = true
                        fireCallback("input")
                    end
                end))

                inputEndedConn = window:Track(UserInputService.InputEnded:Connect(function(input)
                    if isTextInputFocused() then return end
                    if mode == "Hold" and inputMatches(input) and state then
                        state = false
                        fireCallback("input_end")
                    end
                end))

                if Library._activeWindow and type(Library._activeWindow._TrackKeybindConnection) == "function" then
                    Library._activeWindow:_TrackKeybindConnection(inputBeganConn)
                    Library._activeWindow:_TrackKeybindConnection(inputEndedConn)
                end

                keyButton.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    keyButton.Text = "PRESS KEY / MOUSE..."
                    tween(keyButton, { BackgroundColor3 = Theme.FieldHover }, 0.10)

                    local connection
                    connection = window:Track(UserInputService.InputBegan:Connect(function(input, processed)
                        if processed then return end
                        local candidate = nil
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if modifierLookup[input.KeyCode] then return end
                            candidate = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.MouseButton2
                            or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            candidate = input.UserInputType
                        end
                        if not candidate then return end

                        key = candidate
                        modifiers = activeModifiers()
                        syncManager()
                        tween(keyButton, { BackgroundColor3 = Theme.TitleBar }, 0.10)
                        listening = false
                        connection:Disconnect()
                        fireCallback("key")
                    end))
                end)

                modeButton.MouseButton1Click:Connect(function()
                    local currentIndex = 1
                    for i, modeName in ipairs(modeCycle) do
                        if modeName == mode then currentIndex = i; break end
                    end
                    setMode(modeCycle[(currentIndex % #modeCycle) + 1], true)
                end)
                setMode(mode, false)

                local api = decorateExtendedApi(holder, holder, {}, cfg.Flag)
                api.Type = "Keybind"
                api.Name = cfg.Text or cfg.Name or "Keybind"

                local function parseKeybindValue(v)
                    local newKey, newMode, newState, newModifiers = nil, nil, nil, nil
                    if typeof(v) == "EnumItem" or type(v) == "string" then
                        newKey = parseBindable(v)
                    elseif type(v) == "table" then
                        newKey = parseBindable(v.Key or v.Value or v[1])
                        if v.Mode ~= nil or v[2] ~= nil then
                            local candidateMode = tostring(v.Mode or v[2])
                            if candidateMode == "Toggle" or candidateMode == "Hold" or candidateMode == "Press" or candidateMode == "Always" then
                                newMode = candidateMode
                            end
                        end
                        if v.State ~= nil then newState = v.State == true end
                        if v.Modifiers ~= nil or v.DefaultModifiers ~= nil or v[3] ~= nil then
                            newModifiers = normalizeModifiers(v.Modifiers or v.DefaultModifiers or v[3])
                        end
                    end
                    return newKey, newMode, newState, newModifiers
                end

                local function applyKeybindValue(v, fire)
                    local newKey, newMode, newState, newModifiers = parseKeybindValue(v)
                    if newKey then key = newKey end
                    if newModifiers then modifiers = newModifiers end
                    if newMode then mode = newMode; modeButton.Text = mode:upper() end
                    if newState ~= nil then state = newState
                    elseif mode == "Always" then state = true
                    elseif mode == "Hold" or mode == "Press" then state = false end
                    syncManager()
                    Library:_UpdateFlagValue(cfg.Flag, flagPayload("set"))
                    local callback = cfg.Callback or cfg.OnChanged
                    if fire ~= false and type(callback) == "function" then
                        Library:SafeCall(callback, state, key, mode, "set", modifiers)
                    end
                end

                function api:Set(v) applyKeybindValue(v, true); return api end
                function api:SetSilent(v) applyKeybindValue(v, false); return api end
                function api:Get() return key end
                function api:GetConfigValue() return flagPayload(nil) end
                api.SetConfigValue = api.Set
                api.SetConfigValueSilent = api.SetSilent
                function api:GetState() return state end
                function api:SetMode(newMode) setMode(newMode, true); return api end
                function api:GetMode() return mode end
                function api:GetModifiers()
                    local out = {}; for i, item in ipairs(modifiers) do out[i] = item end; return out
                end
                function api:SetModifiers(values, fire)
                    modifiers = normalizeModifiers(values)
                    syncManager()
                    if fire ~= false then fireCallback("modifiers")
                    else Library:_UpdateFlagValue(cfg.Flag, flagPayload("modifiers")) end
                    return api
                end
                function api:SetState(newState, fire)
                    state = newState == true
                    if fire ~= false then fireCallback("state")
                    else Library:_UpdateFlagValue(cfg.Flag, flagPayload("state")) end
                    return api
                end
                function api:Destroy()
                    if inputBeganConn then inputBeganConn:Disconnect() end
                    if inputEndedConn then inputEndedConn:Disconnect() end
                    if holder and holder.Parent then holder:Destroy() end
                end

                registerExtendedFlag(cfg.Flag, api)
                syncManager()
                Library:_UpdateFlagValue(cfg.Flag, api:GetConfigValue())
                return api
            end


            function cardApi:AddColorPicker(config)
                local cfg = normalizeExtConfig(config, "Color Picker")

                local function parseColor(inputValue, fallback)
                    if typeof(inputValue) == "Color3" then return inputValue end
                    if type(inputValue) == "table" then
                        if typeof(inputValue.Color) == "Color3" then return inputValue.Color end
                        if inputValue.R and inputValue.G and inputValue.B then
                            local r = tonumber(inputValue.R) or 0
                            local g = tonumber(inputValue.G) or 0
                            local b = tonumber(inputValue.B) or 0
                            if math.max(r, g, b) > 1 then r, g, b = r / 255, g / 255, b / 255 end
                            return Color3.new(
                                math.clamp(r, 0, 1),
                                math.clamp(g, 0, 1),
                                math.clamp(b, 0, 1)
                            )
                        end
                    end
                    if type(inputValue) == "string" then
                        local hex = inputValue:gsub("#", ""):gsub("%s+", "")
                        if #hex == 3 then
                            hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
                        end
                        if #hex == 6 and hex:match("^[%x]+$") then
                            return Color3.fromRGB(
                                tonumber(hex:sub(1,2), 16),
                                tonumber(hex:sub(3,4), 16),
                                tonumber(hex:sub(5,6), 16)
                            )
                        end
                    end
                    return fallback or Color3.new(1, 1, 1)
                end

                local function toHex(color)
                    return string.format(
                        "#%02X%02X%02X",
                        math.floor(color.R * 255 + 0.5),
                        math.floor(color.G * 255 + 0.5),
                        math.floor(color.B * 255 + 0.5)
                    )
                end

                local initialValue = cfg.Default or cfg.Value
                local defaultColor = parseColor(initialValue, Theme.Accent)
                local color = defaultColor
                local initialTransparency = type(initialValue) == "table" and initialValue.Transparency or nil
                local transparency = math.clamp(tonumber(cfg.Transparency ~= nil and cfg.Transparency or initialTransparency) or 0, 0, 1)
                local allowTransparency = cfg.AllowTransparency == true or cfg.Transparency ~= nil
                local hue, sat, val = Color3.toHSV(color)
                local popup = nil
                local popupConnections = {}
                local api = nil

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                local label = create("TextLabel", {
                    Text = cfg.Text or cfg.Name or "Color",
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -148, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local button = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme.Field,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 138, 0, 28),
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(7) })

                local swatch = create("Frame", {
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0.5, -9),
                    Size = UDim2.new(0, 30, 0, 18),
                    ZIndex = 4,
                    Parent = button,
                }, { corner(5), stroke(Theme.StrokeSoft, 1, 0.25) })

                local hexLabel = create("TextLabel", {
                    Text = toHex(color),
                    FontFace = Theme.FontSemibold,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 43, 0, 0),
                    Size = UDim2.new(1, -48, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 4,
                    Parent = button,
                })

                local function disconnectPopupConnections()
                    for _, connection in ipairs(popupConnections) do
                        pcall(function() connection:Disconnect() end)
                    end
                    table.clear(popupConnections)
                end

                local function payload()
                    return {
                        Color = color,
                        Transparency = transparency,
                    }
                end

                local function publish(fire, source)
                    swatch.BackgroundColor3 = color
                    swatch.BackgroundTransparency = transparency
                    hexLabel.Text = toHex(color)
                    Library:_UpdateFlagValue(cfg.Flag, payload())
                    if fire ~= false and type(cfg.Callback or cfg.OnChanged) == "function" then
                        Library:SafeCall(cfg.Callback or cfg.OnChanged, color, transparency, source)
                    end
                    if api and api.Emit then api:Emit("Changed", color, transparency, source) end
                end

                local function closePopup()
                    if popup then
                        local active = popup
                        popup = nil
                        disconnectPopupConnections()
                        pcall(function() active:Close() end)
                    end
                end

                local function openPopup()
                    if popup then closePopup(); return end
                    local activeWindow = Library._activeWindow
                    if not activeWindow or type(activeWindow.CreatePopover) ~= "function" then return end

                    popup = activeWindow:CreatePopover(button, {
                        Size = UDim2.new(0, 258, 0, allowTransparency and 270 or 244),
                        Padding = 12,
                        CloseOnBackdrop = true,
                    })
                    popup:SetTitle(cfg.Title or cfg.Text or cfg.Name or "Color")

                    local bodyHeight = allowTransparency and 205 or 179
                    local body = create("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, bodyHeight),
                        LayoutOrder = 1,
                        ZIndex = popup.Panel.ZIndex + 1,
                        Parent = popup.Panel,
                    })

                    local sv = create("Frame", {
                        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                        BorderSizePixel = 0,
                        Active = true,
                        Size = UDim2.new(1, 0, 0, 116),
                        ZIndex = body.ZIndex + 1,
                        Parent = body,
                    }, { corner(7) })

                    local white = create("Frame", {
                        BackgroundColor3 = Color3.new(1,1,1),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1,0,1,0),
                        ZIndex = sv.ZIndex + 1,
                        Parent = sv,
                    }, {
                        corner(7),
                        create("UIGradient", {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1),
                            }),
                        }),
                    })

                    local black = create("Frame", {
                        BackgroundColor3 = Color3.new(0,0,0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1,0,1,0),
                        ZIndex = white.ZIndex + 1,
                        Parent = sv,
                    }, {
                        corner(7),
                        create("UIGradient", {
                            Rotation = 90,
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(1, 0),
                            }),
                        }),
                    })

                    local svCursor = create("Frame", {
                        BackgroundColor3 = Color3.new(1,1,1),
                        BackgroundTransparency = 0.05,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5,0.5),
                        Size = UDim2.new(0,10,0,10),
                        ZIndex = black.ZIndex + 2,
                        Parent = sv,
                    }, { corner(999), stroke(Color3.new(0,0,0), 1, 0.2) })

                    local hueBar = create("Frame", {
                        BackgroundColor3 = Color3.new(1,1,1),
                        BorderSizePixel = 0,
                        Active = true,
                        Position = UDim2.new(0,0,0,126),
                        Size = UDim2.new(1,0,0,14),
                        ZIndex = body.ZIndex + 1,
                        Parent = body,
                    }, {
                        corner(999),
                        create("UIGradient", {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00,1,1)),
                                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50,1,1)),
                                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                                ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00,1,1)),
                            }),
                        }),
                    })

                    local hueCursor = create("Frame", {
                        BackgroundColor3 = Theme.Text,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5,0.5),
                        Position = UDim2.new(hue,0,0.5,0),
                        Size = UDim2.new(0,4,1,4),
                        ZIndex = hueBar.ZIndex + 2,
                        Parent = hueBar,
                    }, { corner(999), stroke(Theme.Background,1,0.1) })

                    local alphaBar, alphaCursor
                    local fieldY = 151
                    if allowTransparency then
                        alphaBar = create("Frame", {
                            BackgroundColor3 = color,
                            BorderSizePixel = 0,
                            Active = true,
                            Position = UDim2.new(0,0,0,150),
                            Size = UDim2.new(1,0,0,14),
                            ZIndex = body.ZIndex + 1,
                            Parent = body,
                        }, {
                            corner(999),
                            create("UIGradient", {
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0),
                                    NumberSequenceKeypoint.new(1, 1),
                                }),
                            }),
                        })
                        alphaCursor = create("Frame", {
                            BackgroundColor3 = Theme.Text,
                            BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(0.5,0.5),
                            Position = UDim2.new(transparency,0,0.5,0),
                            Size = UDim2.new(0,4,1,4),
                            ZIndex = alphaBar.ZIndex + 2,
                            Parent = alphaBar,
                        }, { corner(999), stroke(Theme.Background,1,0.1) })
                        fieldY = 176
                    end

                    local hexBox = create("TextBox", {
                        Text = toHex(color),
                        PlaceholderText = "#FFFFFF",
                        ClearTextOnFocus = false,
                        FontFace = Theme.FontSemibold,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        PlaceholderColor3 = Theme.TextDimmer,
                        BackgroundColor3 = Theme.Field,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0,0,0,fieldY),
                        Size = UDim2.new(0.58,-4,0,30),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = body.ZIndex + 2,
                        Parent = body,
                    }, { corner(6), padding(9) })

                    local valueText = create("TextLabel", {
                        Text = string.format(
                            "R %d  G %d  B %d",
                            math.floor(color.R*255+0.5),
                            math.floor(color.G*255+0.5),
                            math.floor(color.B*255+0.5)
                        ),
                        FontFace = Theme.Font,
                        TextSize = 10,
                        TextColor3 = Theme.TextDimmer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.58,4,0,fieldY),
                        Size = UDim2.new(0.42,-4,0,30),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        ZIndex = body.ZIndex + 2,
                        Parent = body,
                    })

                    local function renderPopup()
                        if not popup then return end
                        sv.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                        svCursor.Position = UDim2.new(sat,0,1-val,0)
                        hueCursor.Position = UDim2.new(hue,0,0.5,0)
                        if alphaBar then alphaBar.BackgroundColor3 = color end
                        if alphaCursor then alphaCursor.Position = UDim2.new(transparency,0,0.5,0) end
                        hexBox.Text = toHex(color)
                        valueText.Text = string.format(
                            "R %d  G %d  B %d",
                            math.floor(color.R*255+0.5),
                            math.floor(color.G*255+0.5),
                            math.floor(color.B*255+0.5)
                        )
                    end

                    local function applyHSV(source)
                        color = Color3.fromHSV(hue, sat, val)
                        renderPopup()
                        publish(true, source)
                    end

                    local function addDrag(target, handler)
                        local dragging = false
                        table.insert(popupConnections, target.InputBegan:Connect(function(inputObject)
                            if inputObject.UserInputType == Enum.UserInputType.MouseButton1
                                or inputObject.UserInputType == Enum.UserInputType.Touch then
                                dragging = true
                                handler(inputObject.Position)
                            end
                        end))
                        table.insert(popupConnections, UserInputService.InputChanged:Connect(function(inputObject)
                            if not dragging then return end
                            if inputObject.UserInputType == Enum.UserInputType.MouseMovement
                                or inputObject.UserInputType == Enum.UserInputType.Touch then
                                handler(inputObject.Position)
                            end
                        end))
                        table.insert(popupConnections, UserInputService.InputEnded:Connect(function(inputObject)
                            if inputObject.UserInputType == Enum.UserInputType.MouseButton1
                                or inputObject.UserInputType == Enum.UserInputType.Touch then
                                dragging = false
                            end
                        end))
                    end

                    addDrag(sv, function(position)
                        local absolute = sv.AbsolutePosition
                        local size = sv.AbsoluteSize
                        sat = math.clamp((position.X - absolute.X) / math.max(size.X,1), 0, 1)
                        val = 1 - math.clamp((position.Y - absolute.Y) / math.max(size.Y,1), 0, 1)
                        applyHSV("picker")
                    end)

                    addDrag(hueBar, function(position)
                        hue = math.clamp((position.X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X,1), 0, 1)
                        applyHSV("hue")
                    end)

                    if alphaBar then
                        addDrag(alphaBar, function(position)
                            transparency = math.clamp((position.X - alphaBar.AbsolutePosition.X) / math.max(alphaBar.AbsoluteSize.X,1), 0, 1)
                            renderPopup()
                            publish(true, "transparency")
                        end)
                    end

                    table.insert(popupConnections, hexBox.FocusLost:Connect(function(enterPressed)
                        if not enterPressed then renderPopup(); return end
                        local parsed = parseColor(hexBox.Text, color)
                        color = parsed
                        hue, sat, val = Color3.toHSV(color)
                        renderPopup()
                        publish(true, "hex")
                    end))

                    table.insert(popupConnections, popup.Closed:Connect(function()
                        popup = nil
                        disconnectPopupConnections()
                    end))

                    renderPopup()
                end

                button.MouseEnter:Connect(function()
                    smoothTween(button, { BackgroundColor3 = Theme.FieldHover }, MOTION.Fast)
                end)
                button.MouseLeave:Connect(function()
                    smoothTween(button, { BackgroundColor3 = Theme.Field }, MOTION.Fast)
                end)
                button.MouseButton1Click:Connect(openPopup)

                api = decorateExtendedApi(holder, button, {
                    Button = button,
                    Swatch = swatch,
                    Label = label,
                }, cfg.Flag)
                api.Type = "ColorPicker"
                api.Name = cfg.Text or cfg.Name or "Color"
                api.Default = { Color = defaultColor, Transparency = transparency }

                local function applyValue(v, fire, source)
                    if type(v) == "table" and v.Transparency ~= nil then
                        transparency = math.clamp(tonumber(v.Transparency) or transparency, 0, 1)
                    end
                    color = parseColor(v, color)
                    hue, sat, val = Color3.toHSV(color)
                    publish(fire, source or "set")
                end

                function api:Set(v, newTransparency)
                    if newTransparency ~= nil then
                        v = { Color = parseColor(v, color), Transparency = newTransparency }
                    end
                    applyValue(v, true, "set")
                    return api
                end
                function api:SetSilent(v, newTransparency)
                    if newTransparency ~= nil then
                        v = { Color = parseColor(v, color), Transparency = newTransparency }
                    end
                    applyValue(v, false, "set")
                    return api
                end
                function api:SetValueRGB(v, newTransparency)
                    return api:Set(v, newTransparency)
                end
                function api:SetHSVFromRGB(v)
                    local parsed = parseColor(v, color)
                    hue, sat, val = Color3.toHSV(parsed)
                    color = parsed
                    publish(true, "rgb")
                    return api
                end
                function api:SetValue(hsv, newTransparency)
                    if type(hsv) ~= "table" then return api end
                    local h = tonumber(hsv.H or hsv.h or hsv[1]) or hue
                    local s_ = tonumber(hsv.S or hsv.s or hsv[2]) or sat
                    local v_ = tonumber(hsv.V or hsv.v or hsv[3]) or val
                    h, s_, v_ = h % 1, math.clamp(s_, 0, 1), math.clamp(v_, 0, 1)
                    local nextColor = Color3.fromHSV(h, s_, v_)
                    return api:Set(nextColor, newTransparency)
                end
                function api:GetHSV()
                    return { H = hue, S = sat, V = val }
                end
                function api:Get() return color end
                function api:GetColor() return color end
                function api:GetTransparency() return transparency end
                function api:SetTransparency(v, fire)
                    transparency = math.clamp(tonumber(v) or 0, 0, 1)
                    publish(fire ~= false, "transparency")
                    return api
                end
                function api:GetConfigValue() return payload() end
                api.SetConfigValue = api.Set
                api.SetConfigValueSilent = api.SetSilent
                function api:Open() openPopup(); return api end
                function api:Close() closePopup(); return api end
                function api:Destroy()
                    closePopup()
                    if holder and holder.Parent then holder:Destroy() end
                end

                registerExtendedFlag(cfg.Flag, api)
                publish(false, "init")
                return api
            end


            ------------------------------------------------------------
            -- V1 COMPLETE COMPONENT PACK
            ------------------------------------------------------------
            function cardApi:AddProgressBar(text_, defaultValue, maxValue)
                local max = math.max(1, tonumber(maxValue) or 100)
                local value = math.clamp(tonumber(defaultValue) or 0, 0, max)
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })
                local title_ = create("TextLabel", {
                    Text = tostring(text_ or "Progress"), FontFace = Theme.Font, TextSize = 14, TextColor3 = Theme.Text,
                    BackgroundTransparency = 1, Size = UDim2.new(1, -56, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2, Parent = holder,
                })
                local valueLabel = create("TextLabel", {
                    Text = tostring(math.floor((value / max) * 100 + 0.5)) .. "%", FontFace = Theme.FontBold, TextSize = 15, TextColor3 = Theme.Text,
                    BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 64, 0, 20), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 2, Parent = holder,
                })
                local track = create("Frame", {
                    BackgroundColor3 = Theme.Field, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 8),
                    BorderSizePixel = 0, ZIndex = 2, Parent = holder,
                }, { corner(999) })
                local fill = create("Frame", {
                    BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
                    Size = UDim2.new(value / max, 0, 1, 0), ZIndex = 3, Parent = track,
                }, { corner(999) })
                local api = {
                    Container = holder,
                    Instance = track,
                    Max = max,
                }
                function api:Set(v, animated)
                    value = math.clamp(tonumber(v) or value, 0, max)
                    valueLabel.Text = tostring(math.floor((value / max) * 100 + 0.5)) .. "%"
                    local target = UDim2.new(value / max, 0, 1, 0)
                    if animated == false then fill.Size = target else smoothTween(fill, { Size = target }, 0.18) end
                    return api
                end
                function api:SetSilent(v) return api:Set(v, false) end
                function api:Get() return value end
                function api:SetMax(v) max = math.max(1, tonumber(v) or max); api.Max = max; return api:Set(value) end
                function api:SetText(v)
                    title_.Text = tostring(v or "")
                    return api
                end
                return registerNormalControl("ProgressBar", text_, api)
            end

            function cardApi:AddRadioGroup(text_, options, default, callback)
                options = options or {}
                callback = callback or function() end
                local value = default or options[1]
                local holder = create("Frame", {
                    BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = nextOrder(), ZIndex = 2, Parent = card,
                }, { create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
                create("TextLabel", {
                    Text = tostring(text_ or "Options"), FontFace = Theme.FontSemibold, TextSize = 14, TextColor3 = Theme.Text,
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 0,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = holder,
                })
                local rows = {}
                local api = {
                    Container = holder,
                }
                local function refresh(fire)
                    for option, data in pairs(rows) do
                        local active = tostring(option) == tostring(value)
                        data.Dot.BackgroundColor3 = active and Theme.Accent or Theme.FieldHover
                        data.Inner.Visible = active
                    end
                    if fire ~= false then Library:SafeCall(callback, value) end
                end
                local function rebuild()
                    for _, data in pairs(rows) do if data.Row and data.Row.Parent then data.Row:Destroy() end end
                    table.clear(rows)
                    for i, option in ipairs(options) do
                        local row = create("TextButton", {
                            Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 28), LayoutOrder = i, ZIndex = 2, Parent = holder,
                        })
                        local dot = create("Frame", {
                            BackgroundColor3 = Theme.FieldHover, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                            Size = UDim2.new(0, 18, 0, 18), ZIndex = 3, Parent = row,
                        }, { corner(999) })
                        local innerDot = create("Frame", {
                            BackgroundColor3 = Theme.ToggleKnobActive, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(0, 8, 0, 8), Visible = false, ZIndex = 4, Parent = dot,
                        }, { corner(999) })
                        create("TextLabel", {
                            Text = tostring(option), FontFace = Theme.Font, TextSize = 14, TextColor3 = Theme.Text,
                            BackgroundTransparency = 1, Position = UDim2.new(0, 28, 0, 0), Size = UDim2.new(1, -28, 1, 0),
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = row,
                        })
                        row.MouseButton1Click:Connect(function() value = option; refresh(true) end)
                        rows[option] = { Row = row, Dot = dot, Inner = innerDot }
                    end
                    refresh(false)
                end
                function api:Set(v) value = v; refresh(true); return api end
                function api:SetSilent(v) value = v; refresh(false); return api end
                function api:Get() return value end
                function api:SetOptions(newOptions, newDefault) options = newOptions or {}; value = newDefault or options[1]; rebuild(); return api end
                rebuild()
                return registerNormalControl("RadioGroup", text_, api)
            end

            function cardApi:AddSegmentedControl(text_, options, default, callback)
                options = options or {}
                callback = callback or function() end
                local value = default ~= nil and default or options[1]

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 58),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = tostring(text_ or "Mode"),
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2,
                    Parent = holder,
                })

                local segments = create("Frame", {
                    BackgroundColor3 = Theme.Field,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 32),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 2,
                    Parent = holder,
                }, {
                    corner(8),
                    create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local buttons = {}
                local api = {
                    Container = holder,
                    Instance = segments,
                }

                local function refresh(fire)
                    for option, button in pairs(buttons) do
                        local active = tostring(option) == tostring(value)
                        smoothTween(button, {
                            BackgroundTransparency = active and 0 or 1,
                            BackgroundColor3 = Theme.CardHover,
                        }, 0.12)
                    end
                    if fire ~= false then Library:SafeCall(callback, value) end
                end

                local function rebuild()
                    for _, child in ipairs(segments:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    table.clear(buttons)

                    local count = math.max(1, #options)
                    for i, option in ipairs(options) do
                        local button = create("TextButton", {
                            Text = tostring(option),
                            FontFace = Theme.FontSemibold,
                            TextSize = 12,
                            TextColor3 = Theme.Text,
                            AutoButtonColor = false,
                            BackgroundColor3 = Theme.CardHover,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1 / count, 0, 1, 0),
                            LayoutOrder = i,
                            ZIndex = 3,
                            Parent = segments,
                        })

                        button.MouseButton1Click:Connect(function()
                            value = option
                            refresh(true)
                        end)

                        buttons[option] = button
                    end

                    refresh(false)
                end

                function api:Set(v) value = v; refresh(true); return api end
                function api:SetSilent(v) value = v; refresh(false); return api end
                function api:Get() return value end
                function api:SetOptions(newOptions, newDefault)
                    options = newOptions or {}
                    value = newDefault ~= nil and newDefault or options[1]
                    rebuild()
                    return api
                end

                rebuild()
                return registerNormalControl("SegmentedControl", text_, api)
            end

            function cardApi:AddStepper(text_, min, max, default, step, callback)
                min = tonumber(min) or 0
                max = tonumber(max) or 100
                step = math.abs(tonumber(step) or 1)
                callback = callback or function() end
                local value = math.clamp(tonumber(default) or min, min, max)

                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })

                create("TextLabel", {
                    Text = tostring(text_ or "Value"),
                    FontFace = Theme.Font,
                    TextSize = 15,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -150, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 2,
                    Parent = holder,
                })

                local controls = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 140, 0, 30),
                    Parent = holder,
                }, {
                    create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local function makeIconStepButton(iconName, order_)
                    local button = create("TextButton", {
                        Text = "",
                        AutoButtonColor = false,
                        BackgroundColor3 = Theme.TitleBar,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 30, 0, 30),
                        LayoutOrder = order_,
                        ZIndex = 3,
                        Parent = controls,
                    }, { corner(8) })

                    local iconHolder = create("Frame", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 14, 0, 14),
                        ZIndex = 4,
                        Parent = button,
                    })
                    buildIcon(iconHolder, iconName, 13, Theme.Text)

                    button.MouseEnter:Connect(function()
                        smoothTween(button, { BackgroundColor3 = Theme.FieldHover }, 0.12)
                    end)
                    button.MouseLeave:Connect(function()
                        smoothTween(button, { BackgroundColor3 = Theme.TitleBar }, 0.12)
                    end)

                    return button
                end

                local minus = makeIconStepButton("minus", 1)

                local valueLabel = create("TextLabel", {
                    Text = tostring(value),
                    FontFace = Theme.FontSemibold,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundColor3 = Theme.TitleBar,
                    Size = UDim2.new(0, 68, 0, 30),
                    LayoutOrder = 2,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 3,
                    Parent = controls,
                }, { corner(8) })

                local plus = makeIconStepButton("plus", 3)

                local api = {
                    Container = holder,
                    Instance = controls,
                    Min = min,
                    Max = max,
                    Step = step,
                }

                local function set(v, fire)
                    value = math.clamp(tonumber(v) or value, min, max)
                    valueLabel.Text = tostring(value)
                    if fire ~= false then Library:SafeCall(callback, value) end
                end

                minus.MouseButton1Click:Connect(function() set(value - step, true) end)
                plus.MouseButton1Click:Connect(function() set(value + step, true) end)

                function api:Set(v) set(v, true); return api end
                function api:SetSilent(v) set(v, false); return api end
                function api:Get() return value end

                return registerNormalControl("Stepper", text_, api)
            end

            function cardApi:AddIconButton(config)
                local cfg = type(config) == "table" and config or { Icon = tostring(config or "circle") }
                local holder = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,cfg.Height or 34), LayoutOrder = nextOrder(), ZIndex = 2, Parent = card })
                local button = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.Field, BorderSizePixel = 0,
                    Size = UDim2.new(0,cfg.Width or cfg.Height or 34,0,cfg.Height or 34), ZIndex = 3, Parent = holder }, { corner(cfg.Radius or 8) })
                local iconHolder = create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,18,0,18), Parent = button })
                local icon = buildIcon(iconHolder, cfg.Icon or "circle", cfg.IconSize or 16, cfg.Color or Theme.Text)
                button.MouseEnter:Connect(function() smoothTween(button,{BackgroundColor3=Theme.FieldHover},0.12) end)
                button.MouseLeave:Connect(function() smoothTween(button,{BackgroundColor3=Theme.Field},0.12) end)
                button.MouseButton1Click:Connect(function() Library:SafeCall(cfg.Callback or cfg.OnClick or function() end) end)
                local api = { Container=holder, Instance=button, Button=button, Icon=icon }
                function api:SetIcon(name) for _,c in ipairs(iconHolder:GetChildren()) do c:Destroy() end; icon=buildIcon(iconHolder,name or "circle",cfg.IconSize or 16,cfg.Color or Theme.Text); api.Icon=icon; return api end
                return registerExtendedFlag(cfg.Flag, decorateExtendedApi(holder, button, api, cfg.Flag))
            end

            function cardApi:AddImage(config)
                local cfg = type(config)=="table" and config or { Image=tostring(config or "") }
                local height = tonumber(cfg.Height) or 160
                local holder = create("Frame", { BackgroundColor3 = cfg.BackgroundColor or Theme.Field, BackgroundTransparency = cfg.BackgroundTransparency or 0,
                    Size = UDim2.new(1,0,0,height), LayoutOrder = nextOrder(), BorderSizePixel=0, ClipsDescendants=true, Parent=card }, { corner(cfg.Radius or 9) })
                local image = create("ImageLabel", { Image = tostring(cfg.Image or ""), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                    ScaleType = cfg.ScaleType or Enum.ScaleType.Crop, ImageTransparency = tonumber(cfg.Transparency) or 0, Parent=holder })
                local api={Container=holder,Instance=image,Image=image}
                function api:SetImage(v) image.Image=tostring(v or ""); return api end
                function api:SetTransparency(v) image.ImageTransparency=math.clamp(tonumber(v) or 0,0,1); return api end
                function api:SetVisible(v) holder.Visible=v~=false; return api end
                function api:Destroy() holder:Destroy() end
                return api
            end

            function cardApi:AddAvatar(config)
                local cfg=type(config)=="table" and config or { UserId=config }
                local holder=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,cfg.Size or 52),LayoutOrder=nextOrder(),Parent=card})
                local size_=tonumber(cfg.Size) or 44
                local image=create("ImageLabel",{BackgroundColor3=Theme.Field,BackgroundTransparency=0,Size=UDim2.new(0,size_,0,size_),AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Image="",Parent=holder},{corner(999)})
                local label=create("TextLabel",{Text=tostring(cfg.Text or cfg.Name or ""),FontFace=Theme.FontSemibold,TextSize=14,TextColor3=Theme.Text,BackgroundTransparency=1,
                    Position=UDim2.new(0,size_+10,0,0),Size=UDim2.new(1,-size_-10,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=holder})
                local api={Container=holder,Instance=image,Image=image,Label=label}
                function api:SetUserId(userId)
                    userId=tonumber(userId)
                    if userId then
                        task.spawn(function()
                            local ok,url=pcall(function() return Players:GetUserThumbnailAsync(userId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
                            if ok and image.Parent then image.Image=url end
                        end)
                    end
                    return api
                end
                function api:SetImage(v) image.Image=tostring(v or ""); return api end
                function api:SetText(v) label.Text=tostring(v or ""); return api end
                if cfg.Image then api:SetImage(cfg.Image) elseif cfg.UserId then api:SetUserId(cfg.UserId) end
                return api
            end



            function cardApi:AddViewport(config)
                local cfg = type(config) == "table" and config or { Object = config }
                local height = math.max(80, tonumber(cfg.Height) or 180)
                local holder = create("Frame", {
                    BackgroundColor3 = cfg.BackgroundColor or Theme.Field,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1,0,0,height),
                    LayoutOrder = nextOrder(),
                    ClipsDescendants = true,
                    Parent = card,
                }, { corner(cfg.Radius or 9), stroke(Theme.StrokeSoft,1,0.45) })

                local viewport = create("ViewportFrame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,1,0),
                    Ambient = cfg.Ambient or Color3.fromRGB(170,170,170),
                    LightColor = cfg.LightColor or Color3.new(1,1,1),
                    LightDirection = cfg.LightDirection or Vector3.new(-1,-1,-1),
                    Active = cfg.Interactive == true,
                    Parent = holder,
                })
                local world = Instance.new("WorldModel")
                world.Parent = viewport
                local camera = cfg.Camera or Instance.new("Camera")
                local ownsCamera = cfg.Camera == nil
                local ownedCamera = ownsCamera and camera or nil
                if ownsCamera then camera.Parent = viewport end
                if cfg.FieldOfView ~= nil then
                    camera.FieldOfView = math.clamp(tonumber(cfg.FieldOfView) or camera.FieldOfView, 1, 120)
                end
                viewport.CurrentCamera = camera

                local displayed = nil
                local basePivot = nil
                local originalParent = nil
                local cloned = true
                local interactive = cfg.Interactive == true
                local dragging = false
                local startPosition = nil
                local rotationX, rotationY = 0, 0

                local function clearObject()
                    if displayed then
                        if cloned then
                            pcall(function() displayed:Destroy() end)
                        else
                            pcall(function() displayed.Parent = originalParent end)
                        end
                    end
                    displayed = nil
                    basePivot = nil
                    originalParent = nil
                end

                local function focus()
                    if not displayed or not camera then return end
                    local center, size
                    if displayed:IsA("Model") then
                        local cf, bounds = displayed:GetBoundingBox()
                        center, size = cf.Position, bounds
                    elseif displayed:IsA("BasePart") then
                        center, size = displayed.Position, displayed.Size
                    else
                        return
                    end
                    local radius = math.max(size.X, size.Y, size.Z) * 0.5
                    radius = math.max(radius, 0.5)
                    local distance = radius / math.tan(math.rad(camera.FieldOfView * 0.5))
                    local offset = Vector3.new(0, radius * 0.12, distance * 1.35 + radius)
                    camera.CFrame = CFrame.lookAt(center + offset, center)
                end

                local function setObject(object, cloneValue)
                    clearObject()
                    if typeof(object) ~= "Instance" then return false end
                    cloned = cloneValue ~= false
                    originalParent = object.Parent
                    local ok, result = pcall(function() return cloned and object:Clone() or object end)
                    if not ok or not result then return false end
                    displayed = result
                    displayed.Parent = world
                    if displayed:IsA("Model") then
                        basePivot = displayed:GetPivot()
                    elseif displayed:IsA("BasePart") then
                        basePivot = displayed.CFrame
                    end
                    rotationX, rotationY = 0, 0
                    if cfg.AutoFocus ~= false then focus() end
                    return true
                end

                local function applyRotation()
                    if not displayed or not basePivot then return end
                    local rotated = basePivot * CFrame.Angles(rotationX, rotationY, 0)
                    if displayed:IsA("Model") then displayed:PivotTo(rotated)
                    elseif displayed:IsA("BasePart") then displayed.CFrame = rotated end
                end

                viewport.InputBegan:Connect(function(inputObject)
                    if not interactive then return end
                    if inputObject.UserInputType == Enum.UserInputType.MouseButton1
                        or inputObject.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        startPosition = inputObject.Position
                    end
                end)
                window:Track(UserInputService.InputChanged:Connect(function(inputObject)
                    if not interactive or not dragging or not startPosition then return end
                    if inputObject.UserInputType == Enum.UserInputType.MouseMovement
                        or inputObject.UserInputType == Enum.UserInputType.Touch then
                        local delta = inputObject.Position - startPosition
                        startPosition = inputObject.Position
                        rotationY += delta.X * 0.01
                        rotationX = math.clamp(rotationX + delta.Y * 0.008, -1.2, 1.2)
                        applyRotation()
                    end
                end))
                window:Track(UserInputService.InputEnded:Connect(function(inputObject)
                    if inputObject.UserInputType == Enum.UserInputType.MouseButton1
                        or inputObject.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        startPosition = nil
                    end
                end))

                local api = decorateExtendedApi(holder, viewport, {
                    Viewport = viewport,
                    WorldModel = world,
                    Camera = camera,
                })
                api.Type = "Viewport"
                api.Name = cfg.Text or cfg.Name or "Viewport"
                function api:SetObject(object, cloneValue)
                    local defaultClone = cfg.CloneObject ~= nil and cfg.CloneObject ~= false or cfg.Clone ~= false
                    setObject(object, cloneValue ~= nil and cloneValue or defaultClone)
                    return api
                end
                function api:GetObject() return displayed end
                function api:SetHeight(v) holder.Size = UDim2.new(1,0,0,math.max(80,tonumber(v) or height)); return api end
                function api:Focus() focus(); return api end
                function api:SetCamera(newCamera)
                    if typeof(newCamera) == "Instance" and newCamera:IsA("Camera") then
                        camera = newCamera; viewport.CurrentCamera = camera; api.Camera = camera
                    end
                    return api
                end
                function api:SetInteractive(v) interactive = v == true; viewport.Active = interactive; return api end
                function api:ResetRotation() rotationX, rotationY = 0, 0; applyRotation(); return api end
                function api:Destroy()
                    clearObject()
                    if ownedCamera then pcall(function() ownedCamera:Destroy() end) end
                    if holder and holder.Parent then holder:Destroy() end
                end
                registerExtendedFlag(nil, api)
                local initialObject = cfg.Object or cfg.Model
                if initialObject then
                    local initialClone = cfg.CloneObject ~= nil and cfg.CloneObject ~= false or cfg.Clone ~= false
                    api:SetObject(initialObject, initialClone)
                end
                return api
            end

            function cardApi:AddVideo(config)
                local cfg = type(config) == "table" and config or { Video = tostring(config or "") }
                local height = math.max(60, tonumber(cfg.Height) or 180)
                local holder = create("Frame", {
                    BackgroundColor3 = cfg.BackgroundColor or Theme.Field,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1,0,0,height),
                    LayoutOrder = nextOrder(),
                    ClipsDescendants = true,
                    Parent = card,
                }, { corner(cfg.Radius or 9), stroke(Theme.StrokeSoft,1,0.45) })
                local video = create("VideoFrame", {
                    Video = tostring(cfg.Video or ""),
                    Looped = cfg.Looped == true,
                    Playing = cfg.Playing == true,
                    Volume = math.clamp(tonumber(cfg.Volume) or 1, 0, 1),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,1,0),
                    Parent = holder,
                })
                local api = decorateExtendedApi(holder, video, { VideoFrame = video })
                api.Type = "Video"
                api.Name = cfg.Text or cfg.Name or "Video"
                function api:SetVideo(v) video.Video = tostring(v or ""); return api end
                function api:SetHeight(v) holder.Size = UDim2.new(1,0,0,math.max(60,tonumber(v) or height)); return api end
                function api:SetLooped(v) video.Looped = v == true; return api end
                function api:SetVolume(v) video.Volume = math.clamp(tonumber(v) or 1,0,1); return api end
                function api:SetPlaying(v) video.Playing = v == true; return api end
                function api:Play() video.Playing = true; return api end
                function api:Pause() video.Playing = false; return api end
                registerExtendedFlag(nil, api)
                return api
            end

            function cardApi:AddUIPassthrough(config)
                local cfg = type(config) == "table" and config or { Instance = config }
                local height = math.max(1, tonumber(cfg.Height) or 40)
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,height),
                    LayoutOrder = nextOrder(),
                    ClipsDescendants = cfg.ClipsDescendants ~= false,
                    Parent = card,
                })
                local current = nil
                local originalParent = nil
                local originalPosition = nil
                local originalSize = nil
                local originalAnchorPoint = nil
                local cloned = false

                local function detach()
                    if current then
                        if cloned then
                            pcall(function() current:Destroy() end)
                        else
                            pcall(function()
                                current.Parent = originalParent
                                if originalPosition then current.Position = originalPosition end
                                if originalSize then current.Size = originalSize end
                                if originalAnchorPoint then current.AnchorPoint = originalAnchorPoint end
                            end)
                        end
                    end
                    current, originalParent = nil, nil
                    originalPosition, originalSize, originalAnchorPoint = nil, nil, nil
                    cloned = false
                end

                local function setInstance(instance, cloneValue)
                    detach()
                    if typeof(instance) ~= "Instance" or not instance:IsA("GuiObject") then return false end
                    originalParent = instance.Parent
                    originalPosition = instance.Position
                    originalSize = instance.Size
                    originalAnchorPoint = instance.AnchorPoint
                    cloned = cloneValue == true
                    local ok, result = pcall(function() return cloned and instance:Clone() or instance end)
                    if not ok or not result then return false end
                    current = result
                    current.Parent = holder
                    current.Position = UDim2.new(0,0,0,0)
                    current.Size = UDim2.new(1,0,1,0)
                    return true
                end

                local api = decorateExtendedApi(holder, holder, {})
                api.Type = "UIPassthrough"
                api.Name = cfg.Text or cfg.Name or "UIPassthrough"
                function api:SetInstance(instance, cloneValue) setInstance(instance, cloneValue ~= nil and cloneValue or cfg.Clone == true); api.Instance=current or holder; return api end
                function api:GetInstance() return current end
                function api:SetHeight(v) holder.Size = UDim2.new(1,0,0,math.max(1,tonumber(v) or height)); return api end
                function api:Destroy() detach(); if holder and holder.Parent then holder:Destroy() end end
                registerExtendedFlag(nil, api)
                local initialInstance = cfg.Instance or cfg.Object
                if initialInstance then api:SetInstance(initialInstance, cfg.Clone == true) end
                return api
            end
            function cardApi:AddDependencyBox(config)
                local cfg = type(config) == "table" and config or { Text = config }
                local hasTitle = cfg.Text ~= nil or cfg.Name ~= nil or cfg.Title ~= nil
                local children = {
                    create("UIListLayout", {
                        Padding = UDim.new(0, 7),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                }
                if cfg.Bordered == true then
                    table.insert(children, corner(cfg.Radius or 8))
                    table.insert(children, stroke(Theme.StrokeSoft, 1, 0.4))
                    table.insert(children, padding(cfg.Padding or 8))
                end

                local holder = create("Frame", {
                    BackgroundColor3 = Theme.Field,
                    BackgroundTransparency = cfg.Bordered == true and 0.25 or 1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = nextOrder(),
                    Visible = cfg.Visible ~= false,
                    Parent = card,
                }, children)

                local titleLabel = nil
                if hasTitle then
                    titleLabel = create("TextLabel", {
                        Text = tostring(cfg.Title or cfg.Text or cfg.Name or "Dependency"),
                        FontFace = Theme.FontSemibold,
                        TextSize = 12,
                        TextColor3 = Theme.TextDark,
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 18),
                        LayoutOrder = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = holder,
                    })
                end

                local body = create("Frame", {
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = 1,
                    Parent = holder,
                }, {
                    create("UIListLayout", {
                        Padding = UDim.new(0, 7),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local api = {
                    Type = "DependencyBox",
                    Name = tostring(cfg.Title or cfg.Text or cfg.Name or "DependencyBox"),
                    Container = holder,
                    Instance = holder,
                    Body = body,
                    Components = {},
                }
                local dependency = nil

                local function targetFor(component)
                    if typeof(component) == "Instance" then return component end
                    if type(component) == "table" then
                        return component.Container or component.Instance
                    end
                    return nil
                end

                function api:Adopt(component)
                    local target = targetFor(component)
                    if target and target:IsA("GuiObject") then
                        target.Parent = body
                        table.insert(api.Components, component)
                    end
                    return component
                end

                function api:Add(controlType, childConfig)
                    return api:Adopt(cardApi:Add(controlType, childConfig))
                end

                api.AddControl = api.Add

                function api:GetComponents()
                    local copy = {}
                    for i, component in ipairs(api.Components) do copy[i] = component end
                    return copy
                end

                function api:SetVisible(visible)
                    holder.Visible = visible ~= false
                    return api
                end

                function api:Show() return api:SetVisible(true) end
                function api:Hide() return api:SetVisible(false) end

                function api:SetDisabled(disabled)
                    for _, component in ipairs(api.Components) do
                        if type(component) == "table" and type(component.SetDisabled) == "function" then
                            component:SetDisabled(disabled == true)
                        else
                            local target = targetFor(component)
                            if target and target:IsA("GuiObject") then
                                target.Active = disabled ~= true
                                target:SetAttribute("DependencyDisabled", disabled == true)
                            end
                        end
                    end
                    holder:SetAttribute("Disabled", disabled == true)
                    return api
                end

                function api:Enable() return api:SetDisabled(false) end
                function api:Disable() return api:SetDisabled(true) end

                function api:SetTitle(text)
                    if titleLabel then titleLabel.Text = tostring(text or "") end
                    api.Name = tostring(text or api.Name)
                    return api
                end

                function api:ClearDependency()
                    if dependency and type(dependency.Destroy) == "function" then
                        dependency:Destroy()
                    end
                    dependency = nil
                    return api
                end

                function api:SetupDependencies(conditions, logic)
                    api:ClearDependency()
                    if conditions == nil then return api end

                    if type(conditions) == "string" or type(conditions) == "function"
                        or (type(conditions) == "table" and type(conditions.Get) == "function") then
                        dependency = window:ShowWhen(conditions, api)
                        return api
                    end

                    if type(conditions) == "table" and (conditions.Source ~= nil or conditions.Flag ~= nil) then
                        local source = conditions.Source or conditions.Flag
                        local expected = conditions.Value
                        local invert = conditions.Invert == true
                        dependency = window:BindDependency(source, api, function(value)
                            local matched = expected == nil and value == true or value == expected
                            return invert and not matched or matched
                        end, "Visible")
                        return api
                    end

                    if type(conditions) == "table" then
                        dependency = window:BindConditions(conditions, api, "Visible", logic or cfg.Logic or "AND")
                    end
                    return api
                end

                api.SetDependencies = api.SetupDependencies

                function api:Clear()
                    for i = #api.Components, 1, -1 do
                        local component = api.Components[i]
                        api.Components[i] = nil
                        if type(component) == "table" and type(component.Destroy) == "function" then
                            pcall(function() component:Destroy() end)
                        else
                            local target = targetFor(component)
                            if target then pcall(function() target:Destroy() end) end
                        end
                    end
                    return api
                end

                function api:Destroy()
                    api:ClearDependency()
                    api:Clear()
                    if holder and holder.Parent then holder:Destroy() end
                end

                setmetatable(api, {
                    __index = function(_, key)
                        local factory = cardApi[key]
                        if type(factory) == "function" and string.sub(tostring(key), 1, 3) == "Add"
                            and key ~= "AddDependencyBox" then
                            return function(_, ...)
                                return api:Adopt(factory(cardApi, ...))
                            end
                        end
                        return nil
                    end,
                })

                if cfg.Dependencies ~= nil then
                    api:SetupDependencies(cfg.Dependencies, cfg.Logic)
                elseif cfg.Source ~= nil or cfg.Flag ~= nil then
                    api:SetupDependencies({
                        Source = cfg.Source or cfg.Flag,
                        Value = cfg.Value,
                        Invert = cfg.Invert,
                    }, cfg.Logic)
                end

                return api
            end

            function cardApi:AddSpinner(config)
                local cfg = type(config) == "table" and config or { Text = tostring(config or "Loading") }
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    LayoutOrder = nextOrder(),
                    Parent = card,
                })

                local loader = create("Frame", {
                    Name = "MistLoader",
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.new(0, 28, 0, 28),
                    Parent = holder,
                })

                local dotColor = cfg.Color or Theme.Accent
                local dots = {}
                local radius = 9
                for i = 1, 8 do
                    local angle = ((i - 1) / 8) * math.pi * 2 - math.pi / 2
                    local dot = create("Frame", {
                        Name = "Dot" .. tostring(i),
                        BackgroundColor3 = dotColor,
                        BackgroundTransparency = math.clamp((i - 1) / 8, 0.10, 0.82),
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, math.cos(angle) * radius, 0.5, math.sin(angle) * radius),
                        Size = UDim2.new(0, 4, 0, 4),
                        Parent = loader,
                    }, { corner(9999) })
                    dots[i] = dot
                end

                local label = create("TextLabel", {
                    Text = tostring(cfg.Text or "Loading"),
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 38, 0, 0),
                    Size = UDim2.new(1, -38, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Parent = holder,
                })

                local active = cfg.Active ~= false
                local phase = 0
                local conn = window:Track(RunService.RenderStepped:Connect(function(dt)
                    if not loader.Parent then return end
                    loader.Visible = active
                    if not active then return end
                    phase = (phase + dt * 5.5) % 8
                    for i, dot in ipairs(dots) do
                        if dot and dot.Parent then
                            local distance = (i - 1 - phase) % 8
                            local brightness = 1 - math.min(distance, 8 - distance) / 4
                            dot.BackgroundTransparency = 0.18 + (1 - brightness) * 0.68
                            local scale = 0.85 + brightness * 0.35
                            dot.Size = UDim2.new(0, 4 * scale, 0, 4 * scale)
                        end
                    end
                end))

                local api = { Container = holder, Instance = loader, Dots = dots }
                function api:SetActive(v)
                    active = v ~= false
                    loader.Visible = active
                    return api
                end
                function api:IsActive() return active end
                function api:SetText(v) label.Text = tostring(v or ""); return api end
                function api:SetColor(v)
                    if typeof(v) == "Color3" then
                        dotColor = v
                        for _, dot in ipairs(dots) do
                            if dot and dot.Parent then dot.BackgroundColor3 = v end
                        end
                    end
                    return api
                end
                function api:Destroy()
                    pcall(function() conn:Disconnect() end)
                    if holder and holder.Parent then holder:Destroy() end
                end
                return api
            end

            function cardApi:AddSeparator(text_)
                return cardApi:AddDivider(text_)
            end

            function cardApi:AddCollapsibleSection(title_, expanded)
                local holder=create("Frame",{BackgroundColor3=Theme.Field,BackgroundTransparency=0.35,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=nextOrder(),Parent=card},
                    {corner(9),padding(10),create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})})
                local header=create("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,28),LayoutOrder=0,Parent=holder})
                local titleIconHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 1, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Parent = header,
                })
                buildIcon(titleIconHolder, "file", 14, Theme.TextDark)
                create("TextLabel",{Text=tostring(title_ or "Section"),FontFace=Theme.FontSemibold,TextSize=14,TextColor3=Theme.Text,BackgroundTransparency=1,
                    Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-50,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=header})
                local arrow = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -2, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    Rotation = (expanded == false and 0 or 90),
                    Parent = header,
                })
                buildIcon(arrow, "chevron-right", 14, Theme.TextDark)
                local body_=create("Frame",{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=1,Visible=expanded~=false,Parent=holder},
                    {create("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})})
                local open=expanded~=false
                local api = { Container = holder, Header = header, Body = body_ }
                local childOrder=0
                local function setOpen(v) open=v~=false; body_.Visible=open; smoothTween(arrow,{Rotation=open and 90 or 0},0.14); return api end
                header.MouseButton1Click:Connect(function() setOpen(not open) end)
                function api:SetExpanded(v)
                    return setOpen(v)
                end

                function api:Expand()
                    return setOpen(true)
                end

                function api:Collapse()
                    return setOpen(false)
                end

                function api:Toggle()
                    local nextState = not open
                    return setOpen(nextState)
                end

                function api:IsExpanded()
                    return open
                end
                function api:AddLabel(v) childOrder+=1; return create("TextLabel",{Text=tostring(v or ""),FontFace=Theme.Font,TextSize=13,TextColor3=Theme.TextDark,BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,18),LayoutOrder=childOrder,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=body_}) end
                function api:AddButton(v,cb) childOrder+=1; local frame=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,30),LayoutOrder=childOrder,Parent=body_}); return makeButton(frame,tostring(v or "Button"),"secondary",nil,30,function() Library:SafeCall(cb or function()end) end) end
                return api
            end

            function cardApi:AddTabs(config)
                local cfg = type(config) == "table" and config or { Tabs = config }
                local names = cfg.Tabs or cfg.Options or {}
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = nextOrder(),
                    Parent = card,
                }, {
                    create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
                })
                local nav = create("Frame", {
                    BackgroundColor3 = Theme.Field,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = 0,
                    Parent = holder,
                }, {
                    corner(8),
                    padding(3),
                    create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })
                local pages = create("Frame", {
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = 1,
                    Parent = holder,
                })
                local api = { Container = holder, Pages = {}, Buttons = {}, _buttonOrder = {} }
                local selected = nil

                local function refreshButtonWidths()
                    local count = #api._buttonOrder
                    if count <= 0 then return end
                    for _, btn in ipairs(api._buttonOrder) do
                        btn.Size = UDim2.new(1 / count, 0, 1, 0)
                    end
                end

                function api:AddTab(name)
                    name = tostring(name or ("Tab " .. tostring(#api._buttonOrder + 1)))
                    if api.Pages[name] then return api.Pages[name] end
                    local page_ = create("Frame", {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        Visible = false,
                        Parent = pages,
                    }, {
                        create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
                    })
                    local btn = create("TextButton", {
                        Text = name,
                        FontFace = Theme.FontSemibold,
                        TextSize = 12,
                        TextColor3 = Theme.TextDark,
                        AutoButtonColor = false,
                        Selectable = false,
                        BackgroundColor3 = Theme.CardHover,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        LayoutOrder = #api._buttonOrder + 1,
                        Parent = nav,
                    }, { corner(6) })
                    api.Pages[name] = page_
                    api.Buttons[name] = btn
                    table.insert(api._buttonOrder, btn)
                    refreshButtonWidths()
                    btn.MouseButton1Click:Connect(function() api:Select(name) end)
                    if not selected then api:Select(name) end
                    return page_
                end

                function api:Select(name)
                    if not api.Pages[name] then return false end
                    selected = name
                    for n, p in pairs(api.Pages) do
                        local active = n == name
                        p.Visible = active
                        local btn = api.Buttons[n]
                        btn.BackgroundTransparency = active and 0 or 1
                        btn.TextColor3 = active and Theme.Text or Theme.TextDark
                    end
                    return true
                end
                function api:GetSelected() return selected end
                function api:GetPage(name) return api.Pages[name] end
                for _, name in ipairs(names) do api:AddTab(name) end
                if cfg.Default then api:Select(cfg.Default) end
                return api
            end

            function cardApi:AddAccordion(items)
                items=items or {}
                local holder=create("Frame",{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=nextOrder(),Parent=card},
                    {create("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})})
                local api={Container=holder,Sections={}}
                local opened=nil
                for i,item in ipairs(items) do
                    local cfg=type(item)=="table" and item or {Title=tostring(item)}
                    local sectionHolder=create("Frame",{BackgroundColor3=Theme.Field,BackgroundTransparency=0.35,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=i,Parent=holder},{corner(8),padding(8),create("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})})
                    local header=create("TextButton",{Text=tostring(cfg.Title or cfg.Name or "Section"),FontFace=Theme.FontSemibold,TextSize=13,TextColor3=Theme.Text,AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),LayoutOrder=0,TextXAlignment=Enum.TextXAlignment.Left,Parent=sectionHolder})
                    local body_=create("Frame",{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),Visible=false,LayoutOrder=1,Parent=sectionHolder},{create("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})})
                    if cfg.Content then create("TextLabel",{Text=tostring(cfg.Content),FontFace=Theme.Font,TextSize=12,TextColor3=Theme.TextDark,BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=body_}) end
                    local section={Container=sectionHolder,Body=body_,Header=header}
                    api.Sections[i]=section
                    header.MouseButton1Click:Connect(function()
                        if opened==section then body_.Visible=false; opened=nil else
                            if opened then opened.Body.Visible=false end
                            opened=section; body_.Visible=true
                        end
                    end)
                end
                function api:Open(index) local s=api.Sections[index]; if not s then return false end; if opened then opened.Body.Visible=false end; opened=s; s.Body.Visible=true; return true end
                function api:CloseAll() if opened then opened.Body.Visible=false; opened=nil end end
                return api
            end

            function cardApi:AddList(config)
                local cfg = type(config) == "table" and config or { Items = config }
                local items = cfg.Items or {}
                local selected = cfg.Default
                local callback = cfg.Callback or function() end
                local maxVisible = math.max(1, math.floor(tonumber(cfg.MaxVisible) or 6))
                local ROW_HEIGHT = 30
                local holder = create("Frame", {
                    BackgroundColor3 = Theme.Field,
                    BackgroundTransparency = 0.25,
                    Size = UDim2.new(1, 0, 0, math.min(math.max(#items, 1), maxVisible) * ROW_HEIGHT + 8),
                    LayoutOrder = nextOrder(),
                    ClipsDescendants = true,
                    Parent = card,
                }, { corner(8), padding(4) })
                local list = create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, #items * ROW_HEIGHT),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.TextDimmer,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    Parent = holder,
                })
                local rows = {}
                local api = { Container = holder, Instance = list, List = list, Virtualized = true }

                local function clearRows()
                    for _, row in ipairs(rows) do if row and row.Parent then row:Destroy() end end
                    table.clear(rows)
                end

                local function rebuild()
                    clearRows()
                    list.CanvasSize = UDim2.new(0, 0, 0, #items * ROW_HEIGHT)
                    holder.Size = UDim2.new(1, 0, 0, math.min(math.max(#items, 1), maxVisible) * ROW_HEIGHT + 8)
                    local maxY = math.max(0, #items * ROW_HEIGHT - math.max(list.AbsoluteSize.Y, ROW_HEIGHT))
                    if list.CanvasPosition.Y > maxY then list.CanvasPosition = Vector2.new(list.CanvasPosition.X, maxY) end
                    local first = math.max(1, math.floor(list.CanvasPosition.Y / ROW_HEIGHT) + 1)
                    local renderCount = math.max(maxVisible + 2, 4)
                    for slot = 1, renderCount do
                        local i = first + slot - 1
                        local item = items[i]
                        if item == nil then break end
                        local text = type(item) == "table" and tostring(item.Text or item.Name or i) or tostring(item)
                        local row = create("TextButton", {
                            Text = text,
                            FontFace = Theme.Font,
                            TextSize = 13,
                            TextColor3 = Theme.Text,
                            AutoButtonColor = false,
                            BackgroundColor3 = Theme.CardHover,
                            BackgroundTransparency = selected == item and 0 or 1,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT),
                            Size = UDim2.new(1, -4, 0, 28),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = list,
                        }, { corner(5), padding(8) })
                        row.MouseButton1Click:Connect(function()
                            selected = item
                            rebuild()
                            Library:SafeCallContext({ Component = cfg.Text or "List", Flag = cfg.Flag, Action = "Select" }, callback, item, i)
                        end)
                        table.insert(rows, row)
                    end
                end

                list:GetPropertyChangedSignal("CanvasPosition"):Connect(rebuild)
                function api:SetItems(v) items = v or {}; rebuild(); return api end
                function api:Set(v) selected = v; rebuild(); Library:SafeCallContext({ Component = cfg.Text or "List", Flag = cfg.Flag, Action = "Set" }, callback, v); return api end
                function api:SetSilent(v) selected = v; rebuild(); return api end
                function api:Get() return selected end
                function api:GetRenderedRowCount() return #rows end
                function api:GetItemCount() return #items end
                rebuild()
                return registerNormalControl("List", cfg.Text or "List", api)
            end

            function cardApi:AddTable(config)
                local cfg=type(config)=="table" and config or {}
                local columns=cfg.Columns or {}; local rows=cfg.Rows or {}
                local holder=create("Frame",{BackgroundColor3=Theme.Field,BackgroundTransparency=0.3,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=nextOrder(),Parent=card},{corner(8),padding(6),create("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder})})
                local api={Container=holder,Rows=rows,Columns=columns}
                local rendered={}
                local function render()
                    for _,r in ipairs(rendered) do if r.Parent then r:Destroy() end end; table.clear(rendered)
                    local function makeRow(values,isHeader,order_)
                        local row=create("Frame",{BackgroundColor3=Theme.CardHover,BackgroundTransparency=isHeader and 0.25 or 0.75,Size=UDim2.new(1,0,0,30),LayoutOrder=order_,Parent=holder},{corner(5),create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder})})
                        local count=math.max(1,#columns)
                        for i=1,count do create("TextLabel",{Text=tostring(values[i] or ""),FontFace=isHeader and Theme.FontSemibold or Theme.Font,TextSize=12,TextColor3=isHeader and Theme.Text or Theme.TextDark,BackgroundTransparency=1,Size=UDim2.new(1/count,0,1,0),LayoutOrder=i,TextXAlignment=Enum.TextXAlignment.Left,Parent=row},{padding(6)}) end
                        table.insert(rendered,row)
                    end
                    makeRow(columns,true,0); for i,row in ipairs(rows) do makeRow(row,false,i) end
                end
                function api:SetRows(v) rows=v or {}; api.Rows=rows; render(); return api end
                function api:AddRow(v) table.insert(rows,v or {}); render(); return api end
                function api:Clear() rows={}; api.Rows=rows; render(); return api end
                render(); return api
            end

            function cardApi:AddTreeView(config)
                local cfg=type(config)=="table" and config or {Nodes=config}
                local nodes=cfg.Nodes or {}; local callback=cfg.Callback or function() end
                local holder=create("Frame",{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=nextOrder(),Parent=card},{create("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder})})
                local rendered={}; local api={Container=holder}
                local function clear() for _,r in ipairs(rendered) do if r.Parent then r:Destroy() end end; table.clear(rendered) end
                local function renderNode(node,depth,orderRef)
                    local name=type(node)=="table" and tostring(node.Name or node.Text or "Node") or tostring(node)
                    local children=type(node)=="table" and (node.Children or node.children) or nil
                    orderRef[1]+=1
                    local row=create("TextButton",{Text=string.rep("   ",depth)..(children and "› " or "• ")..name,FontFace=Theme.Font,TextSize=13,TextColor3=Theme.Text,AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),LayoutOrder=orderRef[1],TextXAlignment=Enum.TextXAlignment.Left,Parent=holder})
                    table.insert(rendered,row); local open=false; local childRows={}
                    local function setChildrenVisible(v) for _,r in ipairs(childRows) do r.Visible=v end end
                    row.MouseButton1Click:Connect(function() if children then open=not open; setChildrenVisible(open) end; Library:SafeCall(callback,node) end)
                    if children then
                        for _,child in ipairs(children) do local before=#rendered; renderNode(child,depth+1,orderRef); for i=before+1,#rendered do rendered[i].Visible=false; table.insert(childRows,rendered[i]) end end
                    end
                end
                local function render() clear(); local orderRef={0}; for _,node in ipairs(nodes) do renderNode(node,0,orderRef) end end
                function api:SetNodes(v) nodes=v or {}; render(); return api end
                render(); return api
            end

            function cardApi:AddTag(text_, variant)
                local color=statusColor(variant)
                local tag=create("TextLabel",{Text=tostring(text_ or "Tag"),FontFace=Theme.FontSemibold,TextSize=11,TextColor3=color,BackgroundColor3=color,BackgroundTransparency=0.84,
                    AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,0,24),LayoutOrder=nextOrder(),Parent=card},{corner(999),padding(10)})
                local api={Container=tag,Instance=tag}
                function api:SetText(v) tag.Text=tostring(v or ""); return api end
                function api:SetVariant(v) local c=statusColor(v); tag.TextColor3=c; tag.BackgroundColor3=c; return api end
                function api:Destroy() tag:Destroy() end
                return api
            end
            cardApi.AddChip = cardApi.AddTag

            function cardApi:AddBreadcrumb(items, callback)
                items=items or {}; callback=callback or function() end
                local holder=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,28),LayoutOrder=nextOrder(),Parent=card},{create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})})
                local api={Container=holder}
                local function rebuild()
                    for _,c in ipairs(holder:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
                    for i,item in ipairs(items) do
                        local btn=create("TextButton",{Text=tostring(item),FontFace=Theme.FontSemibold,TextSize=12,TextColor3=i==#items and Theme.Text or Theme.TextDark,AutoButtonColor=false,BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),LayoutOrder=i*2,Parent=holder})
                        btn.MouseButton1Click:Connect(function() Library:SafeCall(callback,item,i) end)
                        if i<#items then create("TextLabel",{Text="/",FontFace=Theme.Font,TextSize=12,TextColor3=Theme.TextDimmer,BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),LayoutOrder=i*2+1,Parent=holder}) end
                    end
                end
                function api:SetItems(v) items=v or {}; rebuild(); return api end
                rebuild(); return api
            end

            function cardApi:AddCodeBox(config)
                local cfg=type(config)=="table" and config or {Text=tostring(config or "")}
                local holder=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,cfg.Height or 140),LayoutOrder=nextOrder(),Parent=card})
                local box=create("TextBox",{Text=tostring(cfg.Text or ""),PlaceholderText=tostring(cfg.Placeholder or "Code..."),Font=Enum.Font.Code,TextSize=13,TextColor3=Theme.Text,PlaceholderColor3=Theme.TextDimmer,
                    BackgroundColor3=Theme.Field,BorderSizePixel=0,ClearTextOnFocus=false,MultiLine=true,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Size=UDim2.new(1,0,1,0),Parent=holder},{corner(8),padding(10)})
                local api={Container=holder,Instance=box}
                function api:Set(v) box.Text=tostring(v or ""); if cfg.Callback then Library:SafeCall(cfg.Callback,box.Text) end; return api end
                function api:SetSilent(v) box.Text=tostring(v or ""); return api end
                function api:Get() return box.Text end
                box.FocusLost:Connect(function(enter) if cfg.Callback then Library:SafeCall(cfg.Callback,box.Text,enter) end end)
                return registerNormalControl("CodeBox",cfg.TextLabel or "Code",api)
            end

            function cardApi:AddFormattedText(text_)
                local function markdownToRich(value)
                    value=tostring(value or "")
                    value=value:gsub("%*%*(.-)%*%*","<b>%1</b>")
                    value=value:gsub("__(.-)__","<u>%1</u>")
                    value=value:gsub("`(.-)`","<font face='rbxasset://fonts/families/RobotoMono.json'>%1</font>")
                    return value
                end
                local label=create("TextLabel",{Text=markdownToRich(text_),RichText=true,FontFace=Theme.Font,TextSize=13,TextColor3=Theme.TextDark,BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=nextOrder(),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=card})
                local api={Container=label,Instance=label}
                function api:Set(v) label.Text=markdownToRich(v); return api end
                function api:SetSilent(v) return api:Set(v) end
                function api:Get() return label.Text end
                return api
            end
            cardApi.AddMarkdown = cardApi.AddFormattedText

            function cardApi:AddActionMenu(config)
                local cfg = type(config) == "table" and config or { Items = config }
                local holder = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, cfg.Height or 32),
                    LayoutOrder = nextOrder(),
                    ZIndex = 2,
                    Parent = card,
                })
                local label = create("TextLabel", {
                    Text = tostring(cfg.Text or cfg.Name or "Actions"),
                    FontFace = Theme.Font,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -42, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = holder,
                })
                local button = create("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    Selectable = false,
                    BackgroundColor3 = Theme.Field,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 34, 0, 28),
                    ZIndex = 3,
                    Parent = holder,
                }, { corner(7) })
                local iconHolder = create("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    ZIndex = 4,
                    Parent = button,
                })
                buildIcon(iconHolder, "more-horizontal", 15, Theme.TextDark)

                button.MouseEnter:Connect(function()
                    smoothTween(button, { BackgroundColor3 = Theme.FieldHover }, 0.12)
                end)
                button.MouseLeave:Connect(function()
                    smoothTween(button, { BackgroundColor3 = Theme.Field }, 0.14)
                end)

                local currentMenu = nil
                button.MouseButton1Click:Connect(function()
                    if currentMenu and currentMenu.Panel and currentMenu.Panel.Parent then
                        currentMenu:Close()
                        currentMenu = nil
                        return
                    end
                    local window = Library._activeWindow
                    if window then
                        currentMenu = window:CreateContextMenu(cfg.Items or {}, button)
                    end
                end)
                local api = { Container = holder, Instance = button, Button = button }
                function api:SetItems(items) cfg.Items = items or {}; return api end
                function api:SetText(v) label.Text = tostring(v or ""); return api end
                function api:Close() if currentMenu then currentMenu:Close(); currentMenu = nil end; return api end
                return api
            end

            function cardApi:AddVirtualList(config)
                local cfg = type(config)=="table" and config or { Items=config }
                local holder=create("Frame",{BackgroundColor3=Theme.Field,BackgroundTransparency=0.25,Size=UDim2.new(1,0,0,cfg.Height or 180),LayoutOrder=nextOrder(),Parent=card},{corner(8),padding(4)})
                local window=Library._activeWindow
                local virtual = window and window:CreateVirtualList(holder,cfg.Items or {},cfg.RowHeight or 30,cfg.RenderRow or function(row,item)
                    create("TextLabel",{Text=tostring(item),FontFace=Theme.Font,TextSize=13,TextColor3=Theme.Text,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=row},{padding(8)})
                end)
                local api={Container=holder,Instance=virtual and virtual.Instance,Virtual=virtual}
                function api:SetItems(items) if virtual then virtual:SetItems(items) end; return api end
                function api:Refresh() if virtual then virtual:Refresh() end; return api end
                return api
            end

            local function normalizeModernResult(result, controlType, cfg)
                local api = result

                if typeof(result) == "Instance" then
                    api = {
                        Instance = result,
                        Container = result,
                    }
                    function api:SetVisible(value)
                        if result:IsA("GuiObject") then result.Visible = value ~= false end
                        return api
                    end
                    function api:SetDisabled(value)
                        local disabled = value == true
                        if result:IsA("GuiButton") then
                            pcall(function() result.Interactable = not disabled end)
                            result.Active = not disabled
                        elseif result:IsA("TextBox") then
                            pcall(function() result.TextEditable = not disabled end)
                            result.Active = not disabled
                        end
                        result:SetAttribute("Disabled", disabled)
                        return api
                    end
                    function api:Destroy()
                        if result and result.Parent then result:Destroy() end
                    end
                end

                if type(api) ~= "table" then
                    api = { Value = api }
                end

                api.Type = api.Type or tostring(controlType or "Component")
                api.Name = api.Name or tostring((cfg and (cfg.Text or cfg.Name)) or api.Type)
                api.Description = cfg and cfg.Description or api.Description
                if cfg then
                    local configuredDefault = cfg.Default ~= nil and cfg.Default or cfg.Value
                    if configuredDefault ~= nil then
                        api.Default = api.Default ~= nil and api.Default or componentValueCopy(configuredDefault)
                        api._mistDefault = api._mistDefault ~= nil and api._mistDefault or componentValueCopy(configuredDefault)
                    end
                end
                Library:_EnsureComponentAPI(api, api.Container or api.Instance)

                if cfg and (cfg.Id or cfg.Flag) and not api.Flag then
                    api.Flag = Library:_NormalizeFlag(cfg.Flag or cfg.Id)
                end

                if not table.find(cardApi.Components, api) then
                    table.insert(cardApi.Components, api)
                end

                if Library._activeWindow then
                    Library._activeWindow:_RegisterComponent(api, {
                        Name = api.Name,
                        Type = api.Type,
                        Card = title,
                        Page = pageName,
                        Flag = api.Flag,
                        Id = cfg and (cfg.Id or cfg.Flag) or api.Flag,
                        Description = api.Description,
                    })
                end

                if api.Flag and (api.Get or api.GetValue or api.GetConfigValue) then
                    Library:_RegisterFlagComponent(api.Flag, api)
                end

                return api
            end

            function cardApi:Add(controlType, config)
                local kind = tostring(controlType or ""):gsub("%s+", "")
                local lower = string.lower(kind)
                local cfg = type(config) == "table" and config or {
                    Text = tostring(config or kind),
                }

                cfg.Flag = cfg.Flag or cfg.Id
                explicitFlagOverride = cfg.Flag

                local result
                if lower == "button" or lower == "buttonex" then
                    result = cardApi:AddButtonEx(cfg)
                elseif lower == "toggle" then
                    result = cardApi:AddToggle(cfg.Text or cfg.Name, cfg.Default == true, cfg.Callback or cfg.OnChanged)
                elseif lower == "slider" then
                    result = cardApi:AddSlider(cfg.Text or cfg.Name, cfg.Min, cfg.Max, cfg.Default, cfg.Callback or cfg.OnChanged)
                elseif lower == "checkbox" then
                    result = cardApi:AddCheckbox(cfg.Text or cfg.Name, cfg.Default == true, cfg.Callback or cfg.OnChanged)
                elseif lower == "dropdown" then
                    result = cardApi:AddDropdown(cfg.Text or cfg.Name, cfg.Options or cfg.Values, cfg.Default, cfg.Callback or cfg.OnChanged)
                elseif lower == "dropdownex" then
                    result = cardApi:AddDropdownEx(cfg)
                elseif lower == "multidropdown" then
                    result = cardApi:AddMultiDropdown(cfg)
                elseif lower == "keybind" or lower == "keybindex" then
                    cfg.Flag = cfg.Flag or cfg.Id
                    result = cardApi:AddKeybindEx(cfg)
                elseif lower == "colorpicker" or lower == "color" then
                    result = cardApi:AddColorPicker(cfg)
                elseif lower == "textbox" then
                    result = cardApi:AddTextbox(cfg.Text or cfg.Name, cfg.Placeholder, cfg.Default, cfg.Callback or cfg.OnChanged)
                elseif lower == "input" or lower == "inputex" or lower == "textboxex" then
                    result = cardApi:AddInput(cfg)
                elseif lower == "numberbox" then
                    result = cardApi:AddNumberBox(cfg.Text or cfg.Name, cfg.Min, cfg.Max, cfg.Default, cfg.Step, cfg.Callback or cfg.OnChanged)
                elseif lower == "rangeslider" then
                    local defaultValue = cfg.Default or {}
                    result = cardApi:AddRangeSlider(cfg.Text or cfg.Name, cfg.Min, cfg.Max, cfg.DefaultMin or defaultValue.Min or defaultValue[1], cfg.DefaultMax or defaultValue.Max or defaultValue[2], cfg.Callback or cfg.OnChanged)
                elseif lower == "searchdropdown" then
                    result = cardApi:AddSearchDropdown(cfg.Text or cfg.Name, cfg.Options or {}, cfg.Default, cfg.Callback or cfg.OnChanged)
                elseif lower == "togglekeybind" then
                    result = cardApi:AddToggleKeybind(
                        cfg.Text or cfg.Name,
                        cfg.Default == true or cfg.Enabled == true,
                        cfg.Key or cfg.DefaultKey,
                        cfg.Callback or cfg.OnChanged,
                        cfg.Id or cfg.Flag
                    )
                elseif lower == "progressbar" then
                    result = cardApi:AddProgressBar(cfg.Text or cfg.Name, cfg.Default or cfg.Value, cfg.Max)
                elseif lower == "radiogroup" then
                    result = cardApi:AddRadioGroup(cfg.Text or cfg.Name, cfg.Options or {}, cfg.Default, cfg.Callback or cfg.OnChanged)
                elseif lower == "segmentedcontrol" then
                    result = cardApi:AddSegmentedControl(cfg.Text or cfg.Name, cfg.Options or {}, cfg.Default, cfg.Callback or cfg.OnChanged)
                elseif lower == "stepper" then
                    result = cardApi:AddStepper(cfg.Text or cfg.Name, cfg.Min, cfg.Max, cfg.Default, cfg.Step, cfg.Callback or cfg.OnChanged)
                elseif lower == "iconbutton" then
                    result = cardApi:AddIconButton(cfg)
                elseif lower == "image" then
                    result = cardApi:AddImage(cfg)
                elseif lower == "viewport" then
                    result = cardApi:AddViewport(cfg)
                elseif lower == "video" then
                    result = cardApi:AddVideo(cfg)
                elseif lower == "uipassthrough" or lower == "passthrough" or lower == "custominstance" then
                    result = cardApi:AddUIPassthrough(cfg)
                elseif lower == "dependencybox" or lower == "dependency" then
                    result = cardApi:AddDependencyBox(cfg)
                elseif lower == "avatar" then
                    result = cardApi:AddAvatar(cfg)
                elseif lower == "spinner" then
                    result = cardApi:AddSpinner(cfg)
                elseif lower == "divider" or lower == "separator" then
                    result = cardApi:AddDivider(cfg.Text or cfg.Name)
                elseif lower == "paragraph" then
                    result = cardApi:AddParagraph(cfg.Title or cfg.Text, cfg.Content or cfg.Description)
                elseif lower == "section" then
                    result = cardApi:AddSection(cfg.Title or cfg.Text, cfg.Subtitle or cfg.Description)
                elseif lower == "collapsiblesection" then
                    result = cardApi:AddCollapsibleSection(cfg.Title or cfg.Text, cfg.Expanded)
                elseif lower == "tabs" then
                    result = cardApi:AddTabs(cfg)
                elseif lower == "accordion" then
                    result = cardApi:AddAccordion(cfg.Items or cfg.Sections or {})
                elseif lower == "list" then
                    result = cardApi:AddList(cfg)
                elseif lower == "table" then
                    result = cardApi:AddTable(cfg)
                elseif lower == "treeview" then
                    result = cardApi:AddTreeView(cfg)
                elseif lower == "tag" or lower == "badge" then
                    result = cardApi:AddTag(cfg.Text or cfg.Name, cfg.Variant)
                elseif lower == "status" then
                    result = cardApi:AddStatus(cfg.Text or cfg.Name, cfg.Value, cfg.Variant)
                elseif lower == "breadcrumb" then
                    result = cardApi:AddBreadcrumb(cfg.Items or {}, cfg.Callback or cfg.OnChanged)
                elseif lower == "codebox" then
                    result = cardApi:AddCodeBox(cfg)
                elseif lower == "formattedtext" or lower == "markdown" then
                    result = cardApi:AddFormattedText(cfg.Text or cfg.Content or "")
                elseif lower == "actionmenu" then
                    result = cardApi:AddActionMenu(cfg)
                elseif lower == "virtuallist" then
                    result = cardApi:AddVirtualList(cfg)
                elseif lower == "confirmbutton" then
                    result = cardApi:AddConfirmButton(cfg)
                elseif lower == "label" then
                    result = cardApi:AddLabel(cfg.Text or cfg.Name or "")
                else
                    explicitFlagOverride = nil
                    error("Unknown MistUI component type: " .. tostring(controlType), 2)
                end

                explicitFlagOverride = nil
                return normalizeModernResult(result, controlType, cfg)
            end

            cardApi.AddControl = cardApi.Add

            function cardApi:AddConfirmButton(config)
                local cfg = normalizeExtConfig(config, "Confirm")
                return cardApi:AddButtonEx({
                    Text = cfg.Text or "Confirm",
                    Variant = cfg.Variant or "danger",
                    Icon = false,
                    Tooltip = cfg.Tooltip,
                    Callback = function()
                        local activeWindow = Library._activeWindow
                        if activeWindow and type(activeWindow.Confirm) == "function" then
                            activeWindow:Confirm({
                                Title = cfg.ModalTitle or (cfg.Text or "Confirm"),
                                Content = cfg.ModalContent or "Are you sure?",
                                ConfirmText = cfg.ConfirmText or "Confirm",
                                CancelText = cfg.CancelText or "Cancel",
                                Variant = cfg.Variant or "danger",
                                OnConfirm = cfg.OnConfirm or cfg.Callback,
                                OnCancel = cfg.OnCancel,
                                CloseOnOverlayClick = cfg.CloseOnOverlayClick,
                            })
                        elseif type(cfg.OnConfirm) == "function" then
                            cfg.OnConfirm()
                        end
                    end,
                })
            end

            return cardApi
        end

        return rowApi
    end
end

------------------------------------------------------------
-- NOTIFICATIONS
-- Original compact notification style with smoother exit animation.
------------------------------------------------------------
local NotifHolder

local function getNotifColor(notifType)
    if notifType == "Success" then
        return Theme.Success
    elseif notifType == "Warning" then
        return Theme.Warning
    elseif notifType == "Error" then
        return Theme.Error
    end

    return Theme.Info
end

local NOTIF_ICONS = {
    Success = "check",
    Info = "info",
    Warning = "triangle-alert",
    Error = "x",
}

local function applyNotifHolderLayout(holder)
    if not holder then return end

    local settings = Library.NotificationSettings or {}
    local position = settings.Position or "TOP RIGHT"
    local layout = holder:FindFirstChildOfClass("UIListLayout")

    if position == "TOP LEFT" then
        holder.AnchorPoint = Vector2.new(0, 0)
        holder.Position = UDim2.new(0, 16, 0, 16)
        if layout then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            layout.VerticalAlignment = Enum.VerticalAlignment.Top
        end
    elseif position == "BOTTOM RIGHT" then
        holder.AnchorPoint = Vector2.new(1, 1)
        holder.Position = UDim2.new(1, -16, 1, -16)
        if layout then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        end
    elseif position == "BOTTOM LEFT" then
        holder.AnchorPoint = Vector2.new(0, 1)
        holder.Position = UDim2.new(0, 16, 1, -16)
        if layout then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        end
    else
        holder.AnchorPoint = Vector2.new(1, 0)
        holder.Position = UDim2.new(1, -16, 0, 16)
        if layout then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            layout.VerticalAlignment = Enum.VerticalAlignment.Top
        end
    end
end

local function ensureNotifHolder(screenGui)
    if NotifHolder and NotifHolder.Parent then
        applyNotifHolderLayout(NotifHolder)
        return NotifHolder
    end

    NotifHolder = create("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 292, 1, -32),
        ZIndex = 50,
        Parent = screenGui,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    applyNotifHolderLayout(NotifHolder)
    return NotifHolder
end

function Library:Notify(config)
    config = config or {}
    if not self._screenGui then return end

    local settings = Library.NotificationSettings or {
        Enabled = true,
        ProgressBar = true,
        Position = "TOP RIGHT",
        Duration = 4,
        MaxVisible = 4,
        PauseOnHover = true,
    }

    if Library.InterfaceSettings and Library.InterfaceSettings.SilentMode and not config.Force then
        return
    end
    if settings.Enabled == false and not config.Force then
        return
    end

    Library.ActiveNotifications = Library.ActiveNotifications or {}

    local groupKey = config.GroupKey and tostring(config.GroupKey) or nil
    if groupKey then
        for id, entry in pairs(Library.ActiveNotifications) do
            if entry.GroupKey == groupKey and entry.Instance and entry.Instance.Parent then
                entry.Count = (entry.Count or 1) + 1
                Library:UpdateNotification(id, {
                    Title = config.Title or entry.Title,
                    Content = config.Content or entry.Content,
                    Count = entry.Count,
                    Duration = config.Duration,
                })
                return entry.Instance, id
            end
        end
    end

    local holder = ensureNotifHolder(self._screenGui)
    applyNotifHolderLayout(holder)

    local maxVisible = math.max(1, tonumber(settings.MaxVisible) or 4)
    local existing = {}
    for _, child in ipairs(holder:GetChildren()) do
        if child:IsA("Frame") or child:IsA("CanvasGroup") then
            existing[#existing + 1] = child
        end
    end
    table.sort(existing, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
    while #existing >= maxVisible do
        local oldest = table.remove(existing, #existing)
        if oldest and oldest.Parent then
            local oldId = oldest:GetAttribute("NotificationId")
            local oldEntry = oldId and Library.ActiveNotifications[tostring(oldId)] or nil
            if oldEntry and oldEntry.Dismiss then
                oldEntry.Dismiss(false)
            else
                if oldId then Library.ActiveNotifications[tostring(oldId)] = nil end
                oldest:Destroy()
            end
        end
    end

    local notifType = config.Type or "Info"
    local color = typeof(config.Color) == "Color3"
        and config.Color
        or getNotifColor(notifType)
    local duration = math.max(0.1, tonumber(config.Duration) or tonumber(settings.Duration) or 4)
    local priority = tonumber(config.Priority) or 0
    local notifId = tostring(config.Id or ("notif_" .. tostring(math.floor(os.clock()*100000)) .. "_" .. tostring(math.random(1000,9999))))
    local hasAction = type(config.OnAction) == "function"
        and tostring(config.ActionText or "") ~= ""
    local closable = config.Closable ~= false

    local cardHeight = hasAction and 108 or 78
    local contentHeight = hasAction and 22 or 28

    local notif = create("CanvasGroup", {
        Name = "Notification",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0,
        GroupTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, cardHeight),
        ClipsDescendants = true,
        LayoutOrder = -priority * 100000 + math.floor(os.clock()*1000),
        ZIndex = 51,
        Parent = holder,
    }, {
        corner(12),
        stroke(Theme.StrokeSoft, 1, 0.38),
    })
    notif:SetAttribute("NotificationId", notifId)
    if groupKey then notif:SetAttribute("GroupKey", groupKey) end

    local iconBubble = create("Frame", {
        Name = "IconBubble",
        BackgroundColor3 = color,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0, 17),
        Size = UDim2.new(0, 34, 0, 34),
        ZIndex = 52,
        Parent = notif,
    }, { corner(9999) })
    local notifIconHolder = create("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = 53,
        Parent = iconBubble,
    })
    local notifIcon = buildIcon(notifIconHolder, tostring(config.Icon or NOTIF_ICONS[notifType] or "info"), 18, color)

    local titleLabel = create("TextLabel", {
        Name = "Title",
        Text = tostring(config.Title or "Notification"),
        FontFace = Theme.FontSemibold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 13),
        Size = UDim2.new(1, closable and -100 or -76, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 52,
        Parent = notif,
    })

    local contentLabel = create("TextLabel", {
        Name = "Content",
        Text = tostring(config.Content or ""),
        FontFace = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextDark,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 34),
        Size = UDim2.new(1, -76, 0, contentHeight),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 52,
        Parent = notif,
    })

    local progressTrack = create("Frame", {
        Name = "ProgressTrack",
        BackgroundColor3 = Theme.Field,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = settings.ProgressBar ~= false,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -7),
        Size = UDim2.new(1, -24, 0, settings.ProgressBar == false and 0 or 3),
        ZIndex = 52,
        Parent = notif,
    }, { corner(9999) })

    local progressFill = create("Frame", {
        Name = "ProgressFill",
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 53,
        Parent = progressTrack,
    }, { corner(9999) })

    local notifScale = create("UIScale", { Scale = 0.985, Parent = notif })
    local alive = true
    local paused = false
    local elapsed = 0
    local closing = false

    local entry = {
        Id = notifId,
        CreatedAt = os.clock(),
        Instance = notif,
        Title = titleLabel.Text,
        Content = contentLabel.Text,
        GroupKey = groupKey,
        Count = 1,
        Duration = duration,
        Elapsed = 0,
        Type = notifType,
        ProgressFill = progressFill,
        ProgressTrack = progressTrack,
        IconBubble = iconBubble,
        IconHolder = notifIconHolder,
        IconVisual = notifIcon,
        TitleLabel = titleLabel,
        ContentLabel = contentLabel,
        Color = color,
    }
    Library.ActiveNotifications[notifId] = entry

    local function dismiss(immediate)
        if closing then return end
        closing = true
        alive = false
        Library.ActiveNotifications[notifId] = nil
        if not notif or not notif.Parent then return end
        if immediate then notif:Destroy(); return end

        -- Fade first, then collapse the row so the remaining notifications glide
        -- into place instead of jumping when this one is destroyed.
        tween(notif, { GroupTransparency = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(notifScale, { Scale = 0.95 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.12, function()
            if notif and notif.Parent then
                tween(notif, { Size = UDim2.new(1, 0, 0, 0) }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
            end
        end)
        task.delay(0.28, function()
            if notif and notif.Parent then notif:Destroy() end
        end)
    end
    entry.Dismiss = dismiss
    entry.ResetTimer = function()
        elapsed = 0
        entry.Elapsed = 0
    end

    if closable then
        local closeButton = create("TextButton", {
            Name = "Close",
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = Theme.SurfaceTint,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 9),
            Size = UDim2.new(0, 26, 0, 26),
            ZIndex = 54,
            Parent = notif,
        }, { corner(7) })
        local closeIcon = buildIcon(closeButton, "x", 15, Theme.TextDark)
        closeButton.MouseEnter:Connect(function()
            tween(closeButton, { BackgroundTransparency = 0.90 }, 0.10)
            setIconColor(closeIcon, Theme.Error, 0.10)
        end)
        closeButton.MouseLeave:Connect(function()
            tween(closeButton, { BackgroundTransparency = 1 }, 0.10)
            setIconColor(closeIcon, Theme.TextDark, 0.10)
        end)
        closeButton.MouseButton1Click:Connect(function() dismiss(false) end)
    end

    if hasAction then
        local actionButton = create("TextButton", {
            Name = "Action",
            Text = tostring(config.ActionText),
            FontFace = Theme.FontSemibold,
            TextSize = 12,
            TextColor3 = color,
            AutoButtonColor = false,
            BackgroundColor3 = color,
            BackgroundTransparency = 0.88,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 64),
            Size = UDim2.new(0, 124, 0, 28),
            ZIndex = 53,
            Parent = notif,
        }, { corner(7) })
        actionButton.MouseEnter:Connect(function()
            tween(actionButton, { BackgroundTransparency = 0.80 }, 0.10)
        end)
        actionButton.MouseLeave:Connect(function()
            tween(actionButton, { BackgroundTransparency = 0.88 }, 0.12)
        end)
        actionButton.MouseButton1Click:Connect(function()
            Library:SafeCall(config.OnAction, notifId)
            if config.CloseOnAction ~= false then dismiss(false) end
        end)
    end

    notif.MouseEnter:Connect(function()
        smoothTween(notif, { BackgroundColor3 = Theme.CardHover }, 0.16)
        local shouldPause = config.PauseOnHover
        if shouldPause == nil then shouldPause = settings.PauseOnHover end
        if shouldPause ~= false then paused = true end
    end)
    notif.MouseLeave:Connect(function()
        smoothTween(notif, { BackgroundColor3 = Theme.Card }, 0.18)
        paused = false
    end)

    notif.GroupTransparency = 1
    notifScale.Scale = 0.95
    tween(notif, { GroupTransparency = 0 }, 0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(notifScale, { Scale = 1 }, 0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    task.spawn(function()
        local last = os.clock()
        while alive and notif.Parent do
            local now = os.clock()
            local dt = now - last
            last = now
            if not paused then
                elapsed += dt
                entry.Elapsed = elapsed
            end
            local activeDuration = duration
            if type(entry.Duration) == "number" then
                activeDuration = entry.Duration
            end
            local alpha = math.clamp(elapsed / math.max(0.1, activeDuration), 0, 1)
            if progressFill and progressFill.Parent then progressFill.Size = UDim2.new(alpha, 0, 1, 0) end
            if alpha >= 1 then break end
            RunService.Heartbeat:Wait()
        end
        if alive and notif.Parent then dismiss(false) end
    end)

    return notif, notifId
end

function Library:UpdateNotification(id, changes)
    id = tostring(id or "")
    local entry = Library.ActiveNotifications and Library.ActiveNotifications[id]
    if not entry or not entry.Instance or not entry.Instance.Parent then return false end
    changes = changes or {}
    if changes.Title ~= nil then entry.Title = tostring(changes.Title); entry.TitleLabel.Text = entry.Title end
    if changes.Content ~= nil then
        entry.Content = tostring(changes.Content)
        entry.ContentLabel.Text = entry.Content
    end

    if changes.Type ~= nil then
        entry.Type = tostring(changes.Type)
        entry.Color = getNotifColor(entry.Type)

        if entry.ProgressFill then
            entry.ProgressFill.BackgroundColor3 = entry.Color
        end

        if entry.IconBubble then
            entry.IconBubble.BackgroundColor3 = entry.Color
        end
        if entry.IconVisual then
            setIconColor(entry.IconVisual, entry.Color, 0.10)
        end
    end

    local changedCount = changes.Count
    if type(changedCount) == "number" and changedCount > 1 then
        entry.TitleLabel.Text = entry.Title .. "  ×" .. tostring(math.floor(changedCount))
    end

    local changedDuration = changes.Duration
    if type(changedDuration) == "number" then
        entry.Duration = math.max(0.1, changedDuration)
        if entry.ResetTimer then entry.ResetTimer() else entry.Elapsed = 0 end
    elseif changes.ResetTimer == true and entry.ResetTimer then
        entry.ResetTimer()
    end
    if changes.Progress ~= nil and entry.ProgressFill then
        entry.ProgressFill.Size = UDim2.new(math.clamp(tonumber(changes.Progress) or 0,0,1),0,1,0)
    end
    return true
end

function Library:RefreshNotificationTheme()
    for _, entry in pairs(Library.ActiveNotifications or {}) do
        if entry and entry.Instance and entry.Instance.Parent then
            local color = getNotifColor(entry.Type or "Info")
            entry.Color = color

            entry.Instance.BackgroundColor3 = Theme.Card

            if entry.TitleLabel then
                entry.TitleLabel.TextColor3 = Theme.Text
            end

            if entry.ContentLabel then
                entry.ContentLabel.TextColor3 = Theme.TextDark
            end

            if entry.ProgressTrack then
                entry.ProgressTrack.BackgroundColor3 = Theme.Field
            end

            if entry.ProgressFill then
                entry.ProgressFill.BackgroundColor3 = color
            end

            if entry.IconBubble then
                entry.IconBubble.BackgroundColor3 = color
            end
        end
    end

    return true
end

function Library:GetLatestNotificationId()
    local latestId = nil
    local latestTime = -math.huge

    for id, entry in pairs(Library.ActiveNotifications or {}) do
        if entry
            and entry.Instance
            and entry.Instance.Parent
            and type(entry.CreatedAt) == "number"
            and entry.CreatedAt > latestTime then
            latestTime = entry.CreatedAt
            latestId = tostring(id)
        end
    end

    return latestId
end

function Library:DismissNotification(id, immediate)
    local wantedId = id ~= nil and tostring(id) or ""

    -- No id or a stale id means "dismiss the newest remaining notification".
    local entry = wantedId ~= ""
        and Library.ActiveNotifications
        and Library.ActiveNotifications[wantedId]
        or nil

    if not entry or not entry.Instance or not entry.Instance.Parent then
        wantedId = Library:GetLatestNotificationId()
        entry = wantedId
            and Library.ActiveNotifications
            and Library.ActiveNotifications[wantedId]
            or nil
    end

    if not entry then
        return false, "No active notifications."
    end

    if entry.Dismiss then
        entry.Dismiss(immediate == true)
        return true, wantedId
    end

    return false, "Notification cannot be dismissed."
end

function Library:DismissLatestNotification(immediate)
    return Library:DismissNotification(nil, immediate)
end


function Library:ClearNotifications()
    Library.ActiveNotifications = Library.ActiveNotifications or {}
    table.clear(Library.ActiveNotifications)
    if not NotifHolder then
        return 0
    end

    local removed = 0
    for _, child in ipairs(NotifHolder:GetChildren()) do
        if child:IsA("Frame") or child:IsA("CanvasGroup") then
            child:Destroy()
            removed += 1
        end
    end

    return removed
end

function Library:SetNotificationSettings(settings)
    settings = settings or {}
    Library.NotificationSettings = Library.NotificationSettings or {
        Enabled = true,
        ProgressBar = true,
        Position = "TOP RIGHT",
        Duration = 4,
        MaxVisible = 4,
        PauseOnHover = true,
    }

    local target = Library.NotificationSettings

    if settings.Enabled ~= nil then
        target.Enabled = settings.Enabled == true
    end

    if settings.ProgressBar ~= nil then
        target.ProgressBar = settings.ProgressBar == true
    end

    if settings.Position ~= nil then
        local position = string.upper(tostring(settings.Position))
        if position == "TOP RIGHT"
            or position == "TOP LEFT"
            or position == "BOTTOM RIGHT"
            or position == "BOTTOM LEFT" then
            target.Position = position
        end
    end

    local notificationDuration = settings.Duration
    if type(notificationDuration) == "number" then
        target.Duration = math.max(0.1, notificationDuration)
    end

    local notificationMaxVisible = settings.MaxVisible
    if type(notificationMaxVisible) == "number" then
        target.MaxVisible = math.max(1, math.floor(notificationMaxVisible))
    end

    if settings.PauseOnHover ~= nil then
        target.PauseOnHover = settings.PauseOnHover == true
    end

    if NotifHolder and NotifHolder.Parent then
        applyNotifHolderLayout(NotifHolder)
    end

    return target
end

function Library:GetNotificationSettings()
    local source = Library.NotificationSettings or {}
    return {
        Enabled = source.Enabled,
        ProgressBar = source.ProgressBar,
        Position = source.Position,
        Duration = source.Duration,
        MaxVisible = source.MaxVisible,
        PauseOnHover = source.PauseOnHover,
    }
end

return Library
