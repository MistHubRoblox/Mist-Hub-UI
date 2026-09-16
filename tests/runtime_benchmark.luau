-- MistUI v4 benchmark. Records metrics; it intentionally has no universal timing threshold.

local RAW_URL = "PASTE_YOUR_RAW_GITHUB_URL_HERE"
local env = getgenv and getgenv() or _G
local MistUI = env.MIST_UI_TEST_LIBRARY
if not MistUI then
    assert(RAW_URL ~= "PASTE_YOUR_RAW_GITHUB_URL_HERE", "Set RAW_URL or MIST_UI_TEST_LIBRARY first")
    MistUI = loadstring(game:HttpGet(RAW_URL))()
end

local CONTROL_COUNT = env.MIST_UI_BENCH_CONTROLS or 500
local LARGE_OPTIONS = env.MIST_UI_BENCH_OPTIONS or 2000
local bigDropdown, bigList
local createStart = os.clock()
local Window = MistUI:CreateWindow({ Title = "Mist Benchmark", UseMemoryStorage = true, ReplaceExisting = true, Responsive = true })
local Category = Window:CreateCategory({ Id = "benchmark", Name = "Benchmark" })
Category:AddScript({
    Id = "controls",
    Name = "Controls",
    Build = function(page)
        local row = page:CreateRow()
        local card = row:AddCard("Benchmark", nil, { Size = "Full" })
        for i = 1, CONTROL_COUNT do
            card:Add("Toggle", { Id = "bench." .. i, Text = "Control " .. i, Default = false })
        end
        local options = {}
        for i = 1, LARGE_OPTIONS do options[i] = "Option " .. i end
        bigDropdown = card:Add("DropdownEx", { Id = "bench.dropdown", Text = "Large dropdown", Options = options, MaxVisibleDropdownItems = 8, Searchable = true })
        bigList = card:Add("List", { Id = "bench.list", Text = "Large list", Items = options, MaxVisible = 8 })
    end,
})
Window:SelectTab("Controls")
task.wait()
local createElapsed = os.clock() - createStart

bigDropdown:Open()
task.wait()
assert(bigDropdown:GetRenderedRowCount() <= 10, "DropdownEx virtualization rendered too many rows")
assert(bigList:GetRenderedRowCount() <= 10, "AddList virtualization rendered too many rows")
bigDropdown:Close()

local snapshot = Window:CreateLeakSnapshot()
local doctorStart = os.clock()
local doctor = Window:Doctor()
local doctorElapsed = os.clock() - doctorStart

local flagsStart = os.clock()
for i = 1, CONTROL_COUNT do
    Window:SetFlag("bench." .. i, i % 2 == 0, true)
end
local flagsElapsed = os.clock() - flagsStart

print(string.format("MistUI v4 benchmark | controls=%d options=%d build=%.3fs flag_updates=%.3fs doctor=%.3fs instances=%d maid=%d doctor_score=%d dropdown_rows=%d list_rows=%d", CONTROL_COUNT, LARGE_OPTIONS, createElapsed, flagsElapsed, doctorElapsed, snapshot.Instances, snapshot.MaidTasks, doctor.Score, bigDropdown:GetRenderedRowCount(), bigList:GetRenderedRowCount()))
Window:Unload()
local unload = Window:GetLastUnloadReport()
print("Unload clean:", unload and unload.Clean, "potential leak units:", unload and unload.PotentialLeakUnits)
