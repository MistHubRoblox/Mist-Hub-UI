-- MistUI v4 runtime quality suite.
-- Run inside a target Roblox/runtime runtime. This file is not executed by GitHub CI.

local RAW_URL = "PASTE_YOUR_RAW_GITHUB_URL_HERE"
local env = getgenv and getgenv() or _G
local MistUI = env.MIST_UI_TEST_LIBRARY
if not MistUI then
    assert(RAW_URL ~= "PASTE_YOUR_RAW_GITHUB_URL_HERE", "Set RAW_URL or MIST_UI_TEST_LIBRARY first")
    MistUI = loadstring(game:HttpGet(RAW_URL))()
end

assert(MistUI.Version == "4.0.0")
MistUI:ClearDiagnostics()

local Window = MistUI:CreateWindow({
    Title = "MistUI v4 Quality",
    UseMemoryStorage = true,
    ReplaceExisting = true,
    Responsive = true,
})

local Category = Window:CreateCategory({ Id = "quality", Name = "Quality" })
Category:AddScript({
    Id = "controls",
    Name = "Controls",
    Build = function(page)
        local row = page:CreateRow()
        local card = row:AddCard("Contract", nil, { Size = "Full" })
        card:Add("Toggle", { Id = "quality.toggle", Text = "Toggle", Default = false })
        card:Add("Slider", { Id = "quality.slider", Text = "Slider", Min = 0, Max = 100, Default = 50 })
        card:Add("Input", { Id = "quality.input", Text = "Input", Default = "hello" })
        card:Add("DropdownEx", { Id = "quality.dropdown", Text = "Dropdown", Options = { "A", "B", "C" }, Default = "A", Searchable = true })
        card:Add("ColorPicker", { Id = "quality.color", Text = "Color", Default = Color3.fromRGB(255, 255, 255), AllowTransparency = true })
        card:Add("Keybind", { Id = "quality.key", Text = "Key", Default = Enum.KeyCode.K, Mode = "Press" })
    end,
})
Window:SelectTab("Controls")

task.wait()
local toggle = assert(Window:GetComponent("quality.toggle"), "toggle was not registered")
assert(toggle:Get() == false, "unexpected toggle default")
toggle:Set(true)
assert(toggle:Get() == true, "toggle set failed")
toggle:Reset(false)
assert(toggle:Get() == false, "component Reset failed")
assert(toggle:IsVisible() == true, "visibility contract failed")
assert(toggle:IsDisabled() == false, "disabled contract failed")

Window:SetFlag("quality.toggle", true)
local begun = Window:BeginConfigTransaction("quality rollback")
assert(begun == true, "transaction did not begin")
Window:SetFlag("quality.toggle", false)
Window:SetFlag("quality.ephemeral", true)
assert(Window:RollbackConfigTransaction("test") == true, "transaction rollback failed")
assert(Window:GetFlag("quality.toggle") == true, "rollback did not restore existing flag")
assert(Window:GetFlag("quality.ephemeral") == nil, "rollback did not remove introduced flag")

local safe, err = MistUI:SafeCallContext({ Test = "expected-error" }, function()
    error("intentional quality-test error")
end)
assert(safe == false and err ~= nil, "error boundary did not capture callback failure")
local diagnostics = MistUI:GetDiagnostics()
assert((diagnostics.CallbackErrors or 0) >= 1, "diagnostic error counter did not increment")
MistUI:ClearDiagnostics()

Window:SetProfilerEnabled(true)
local profileOk, profileResult = Window:Profile("quality.profile", function() return "ok" end)
assert(profileOk == true and profileResult == "ok", "profiler wrapper changed callback result")
assert(#Window:GetProfilerSnapshot().Entries >= 1, "profiler did not record entry")

local layoutA = Window:CaptureLayoutSnapshot()
local layoutB = Window:CaptureLayoutSnapshot()
assert(Window:CompareLayoutSnapshots(layoutA, layoutB, 1).Equal == true, "stable layout snapshots differ")

local doctor = Window:Doctor({ Print = true })
assert(doctor.Healthy == true, "Doctor hard failure")
assert(doctor.Score >= 90, "Doctor score below quality threshold")
local suite = Window:RunQualitySuite({ Print = true })
assert(suite.Passed == true, "built-in quality suite failed")

local disposable = toggle
disposable:Destroy()
assert(MistUI.ComponentsByFlag["quality.toggle"] == nil, "destroyed component remained in strong flag registry")

assert(Window:Unload() == true, "Unload failed")
local unload = assert(Window:GetLastUnloadReport(), "unload report missing")
assert(unload.Clean == true, "potential positive leak remained after unload")
print("MistUI v4 runtime quality suite passed")
