-- MistUI v4.0.0 Stable - minimal example
-- Replace the URL with the raw URL to dist/MistUI.lua in your repository.
local MistUI = loadstring(game:HttpGet("PASTE_RAW_MISTUI_URL_HERE"))()

local Window = MistUI:CreateWindow({
    Title = "My Hub",
    Responsive = true,
})

local Main = Window:CreateCategory({
    Id = "main",
    Name = "Main",
    Icon = "settings",
})

Main:AddScript({
    Id = "general",
    Name = "General",
    Icon = "settings",
    Build = function(page)
        local row = page:CreateRow()
        local card = row:AddCard("General", nil, { Size = "Full" })

        local enabled = card:Add("Toggle", {
            Id = "general.enabled",
            Text = "Enabled",
            Default = false,
        })

        card:Add("Slider", {
            Id = "general.amount",
            Text = "Amount",
            Min = 0,
            Max = 100,
            Default = 50,
        })

        card:Add("DropdownEx", {
            Id = "general.mode",
            Text = "Mode",
            Options = { "Normal", "Fast", "Precise" },
            Default = "Normal",
            Searchable = true,
        })

        card:Add("Button", {
            Text = "Show notification",
            Icon = "info",
            Callback = function()
                MistUI:Notify({
                    Title = "MistUI",
                    Content = "Everything is working.",
                    Type = "Success",
                    Duration = 3,
                })
            end,
        })

        -- Long-running jobs can use the Activity HUD.
        card:Add("Button", {
            Text = "Activity preview",
            Icon = "swords",
            Callback = function()
                local activity = Window:CreateActivity({
                    Id = "example.activity",
                    Title = "Auto Boss",
                    Icon = "swords",
                    AutoTimer = true,
                })
                activity:SetCounter(2, 10, "Bosses defeated")
                activity:SetTarget("Ancient Guardian")
                activity:SetStatus("Fighting boss...", "warning")
                activity:SetProgress(0.2)
            end,
        })
    end,
})
