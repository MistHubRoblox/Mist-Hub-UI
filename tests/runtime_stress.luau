-- MistUI v4 lifecycle stress test.
-- Default target: 100 full create/build/inspect/unload cycles.

local RAW_URL = "PASTE_YOUR_RAW_GITHUB_URL_HERE"
local env = getgenv and getgenv() or _G
local MistUI = env.MIST_UI_TEST_LIBRARY
if not MistUI then
    assert(RAW_URL ~= "PASTE_YOUR_RAW_GITHUB_URL_HERE", "Set RAW_URL or MIST_UI_TEST_LIBRARY first")
    MistUI = loadstring(game:HttpGet(RAW_URL))()
end

local CYCLES = env.MIST_UI_STRESS_CYCLES or 100
local CONTROLS = env.MIST_UI_STRESS_CONTROLS or 30
local started = os.clock()

for cycle = 1, CYCLES do
    MistUI:ClearDiagnostics()
    local Window = MistUI:CreateWindow({
        Title = "Mist Stress " .. cycle,
        UseMemoryStorage = true,
        ReplaceExisting = true,
        Responsive = true,
    })
    local Category = Window:CreateCategory({ Id = "stress", Name = "Stress" })
    Category:AddScript({
        Id = "cycle",
        Name = "Cycle",
        Build = function(page)
            local row = page:CreateRow()
            local card = row:AddCard("Controls", nil, { Size = "Full" })
            for i = 1, CONTROLS do
                local id = "stress.control." .. i
                if i % 4 == 0 then
                    card:Add("Slider", { Id = id, Text = "Slider " .. i, Min = 0, Max = 100, Default = i % 100 })
                elseif i % 4 == 1 then
                    card:Add("Toggle", { Id = id, Text = "Toggle " .. i, Default = i % 2 == 0 })
                elseif i % 4 == 2 then
                    card:Add("Input", { Id = id, Text = "Input " .. i, Default = tostring(i) })
                else
                    card:Add("DropdownEx", { Id = id, Text = "Dropdown " .. i, Options = { "A", "B", "C" }, Default = "A" })
                end
            end
        end,
    })
    Window:SelectTab("Cycle")
    task.wait()

    local doctor = Window:Doctor()
    assert(doctor.Healthy == true, "Doctor failed on cycle " .. cycle)
    assert(Window:SaveConfig("stress") == true, "save failed on cycle " .. cycle)
    assert(Window:LoadConfig("stress") == true, "load failed on cycle " .. cycle)
    assert(Window:Unload() == true, "unload failed on cycle " .. cycle)
    local leak = Window:GetLastUnloadReport()
    assert(leak and leak.Clean == true, "positive leak delta on cycle " .. cycle)
    assert(next(MistUI.ComponentsByFlag) == nil, "component registry not empty after cycle " .. cycle)
end

print(string.format("MistUI v4 stress passed: %d cycles x %d controls in %.3fs", CYCLES, CONTROLS, os.clock() - started))
