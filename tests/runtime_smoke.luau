-- MistUI v4.0 runtime smoke test
-- UI framework only. No gameplay logic is executed.

local RAW_URL = "PASTE_YOUR_RAW_GITHUB_URL_HERE"
local env = getgenv and getgenv() or _G
local MistUI = env.MIST_UI_TEST_LIBRARY

if not MistUI then
    assert(RAW_URL ~= "PASTE_YOUR_RAW_GITHUB_URL_HERE", "Set RAW_URL or MIST_UI_TEST_LIBRARY first")
    MistUI = loadstring(game:HttpGet(RAW_URL))()
end

assert(type(MistUI) == "table", "library did not load")
assert(MistUI.Version == "4.0.0", "unexpected MistUI version")
assert(MistUI.SchemaVersion == 5, "unexpected config schema")
assert(MistUI.Capabilities.ColorPicker == true, "ColorPicker capability missing")
assert(MistUI.Capabilities.CommandRegistry == true, "CommandRegistry capability missing")
assert(MistUI.Capabilities.KeybindChords == true, "KeybindChords capability missing")
assert(MistUI.Capabilities.ActivityHUD == true, "ActivityHUD capability missing")

local Window = MistUI:CreateWindow({
    Title = "MistUI v4.0 Smoke Test",
    UseMemoryStorage = true,
    ReplaceExisting = true,
    Responsive = true,
})

assert(Window:IsResizable() == false, "manual resize must remain disabled")

local Main = Window:CreateCategory({ Id = "smoke", Name = "Smoke" })
Main:AddScript({
    Id = "controls",
    Name = "Controls",
    Keybinds = {
        {
            Id = "smoke.key",
            Name = "Smoke Key",
            Default = Enum.KeyCode.K,
            DefaultModifiers = { Enum.KeyCode.LeftControl },
            Mode = "Press",
        },
    },
    Build = function(page)
        local row = page:CreateRow()
        local card = row:AddCard("Controls", nil, { Size = "Full" })

        card:Add("Toggle", { Id = "smoke.toggle", Text = "Toggle", Default = false })
        card:Add("Slider", { Id = "smoke.slider", Text = "Slider", Min = 0, Max = 100, Default = 25 })
        card:Add("Input", { Id = "smoke.input", Text = "Input", Default = "10", Numeric = true })
        card:Add("DropdownEx", {
            Id = "smoke.dropdown",
            Text = "Dropdown",
            Options = { "Alpha", "Beta", "Gamma" },
            Searchable = true,
            DisabledValues = { "Gamma" },
        })
        card:Add("Keybind", {
            Id = "smoke.key",
            Text = "Smoke Key",
            Default = Enum.KeyCode.K,
            DefaultModifiers = { Enum.KeyCode.LeftControl },
            Mode = "Press",
        })
        card:Add("ColorPicker", {
            Id = "smoke.color",
            Text = "Color",
            Default = Color3.fromRGB(255, 255, 255),
            AllowTransparency = true,
        })

        local dependency = card:AddDependencyBox({
            Title = "Dependent",
            Source = "smoke.toggle",
            Bordered = true,
        })
        dependency:Add("Input", { Id = "smoke.dependent", Text = "Dependent input", Default = "ok" })

        local custom = Instance.new("Frame")
        custom.BackgroundTransparency = 1
        card:Add("UIPassthrough", { Instance = custom, Height = 20, Clone = true })
    end,
})

Window:RegisterCommand({
    Id = "smoke.command",
    Name = "Smoke command",
    Keywords = { "test", "validation" },
    Callback = function()
        Window:SetFlag("smoke.command.ran", true)
    end,
})

assert(#Window:SearchCommands("validation") >= 1, "command search failed")
Window:RunCommand("smoke.command")
assert(Window:GetFlag("smoke.command.ran") == true, "command execution failed")

Window:SelectTab("Controls")
assert(Window:SetFlag("smoke.toggle", true) ~= nil, "SetFlag failed")
assert(Window:GetFlag("smoke.toggle") == true, "flag did not update")

assert(Window:SetTheme("Haunted") == true, "Haunted theme failed")
assert(Window:SetTheme("Default") == true, "Default theme failed")

local saved = Window:SaveConfig("smoke")
assert(saved == true, "memory config save failed")
Window:SetFlag("smoke.toggle", false)
local loaded = Window:LoadConfig("smoke")
assert(loaded == true, "memory config load failed")
assert(Window:GetFlag("smoke.toggle") == true, "config did not restore flag")

local _, notificationId = MistUI:Notify({
    Title = "Smoke",
    Content = "MistUI v4.0 notification system is active.",
    Type = "Success",
    Duration = 1,
    Force = true,
})
if notificationId then MistUI:DismissNotification(notificationId, true) end


local activity = Window:CreateActivity({ Title = "Smoke Activity", Icon = "info", AutoTimer = true })
activity:SetCounter(1, 3, "Steps")
activity:SetTarget("Target A")
activity:SetStatus("Running", "info")
activity:SetProgress(0.5)
local activitySection = activity:AddSection({ Title = "Detector", Counter = 1 })
local activityStatus = activitySection:AddStatus({ Title = "Clear", Description = "No issues", Status = "success" })
activityStatus:SetDescription("Healthy")
assert(#Window:GetActivities() == 1, "activity registry failed")
activity:Close(true)
assert(#Window:GetActivities() == 0, "activity cleanup failed")

local validConfig = Window:ValidateConfigData({ SchemaVersion = 5, Flags = {} })
assert(validConfig == true, "config validation failed")
local doctor = Window:Doctor()
assert(doctor.Healthy == true, "Doctor found a hard failure")
local quality = Window:RunQualitySuite()
assert(quality.Passed == true, "quality suite failed")

assert(Window:Unload() == true, "Unload failed")
local unloadReport = Window:GetLastUnloadReport()
assert(unloadReport and unloadReport.Clean == true, "post-unload leak report is not clean")
print("MistUI v4.0 runtime smoke test passed")
