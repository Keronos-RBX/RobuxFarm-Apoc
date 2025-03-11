--// RunUI.lua
-- Updated to: 
--   • Check if an old UI is open. If yes, destroy it + clear ApocFunctions
--   • Then create new UI library instance
--   • Remainder includes your categories/sections as before
--   • "Flight Speed" slider, "Noclip" keybind, "Credits" category, etc.

-- 1) Prevent multiple UIs
local existing = game:GetService("CoreGui"):FindFirstChild("HydraUILib") 
               or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("HydraUILib")
if existing then
    existing:Destroy()
    -- also clear out ApocFunctions so old references won't remain
    if getgenv().ApocFunctions then
        for k in pairs(getgenv().ApocFunctions) do
            getgenv().ApocFunctions[k] = nil
        end
    end
end

-- 2) Load & reference your Functions
local Functions = getgenv().ApocFunctions or {}
if not next(Functions) then
    -- If it's empty, require the Functions now:
    Functions = loadstring(game:HttpGet('https://pastebin.com/raw/...Functions.lua'))() 
    -- ^ Use your real URL or local require
end

-- 3) Load the UI library
local UILib = loadstring(game:HttpGet('https://pastebin.com/raw/...UI.lua'))()
-- ^ again, replace with your actual raw script link or local require

-- 4) Create the main window
local Window = UILib.new("Apocrypha", game.Players.LocalPlayer.UserId, "Buyer")

--------------------------------------------------------------------------------
-- “Main Features” Category
--------------------------------------------------------------------------------

local Category1 = Window:Category("Main Features", "http://www.roblox.com/asset/?id=8395621517")

-- Movement
local MovementSub = Category1:Button("Movement", "http://www.roblox.com/asset/?id=8395747586")
local MovementSection = MovementSub:Section("Movement", "Left")

-- Fly Keybind
MovementSection:Keybind({
    Title = "Fly Keybind",
    Description = "Toggle flight on/off",
    Default = Enum.KeyCode.R,
}, function(_key)
    Functions.FlyToggle()
end)

-- Flight Speed slider (0.5–6)
MovementSection:Slider({
    Title = "Flight Speed",
    Description = "Set flight speed multiplier",
    Min = 0.5,
    Max = 6,
    Default = 1,
}, function(value)
    Functions.SetFlySpeed(value)
end)

-- WalkSpeed logic
local walkSpeedValue = 16
MovementSection:Textbox({
    Title = "WalkSpeed Input",
    Description = "Enter your custom walk speed",
    Default = "16",
}, function(val)
    local num = tonumber(val)
    if num then
        walkSpeedValue = num
    end
end)

local walkSpeedToggleObj
walkSpeedToggleObj = MovementSection:Toggle({
    Title = "WalkSpeed Toggle",
    Description = "Toggle custom walk speed on/off",
    Default = false,
}, function(state)
    if state then
        Functions.SetWalkSpeed(walkSpeedValue)
    else
        Functions.WalkSpeedToggle() -- toggles off
    end
end)

-- optional WalkSpeed Keybind
MovementSection:Keybind({
    Title = "WalkSpeed Keybind",
    Description = "Same as the WalkSpeed toggle",
    Default = Enum.KeyCode.H,
}, function()
    local current = walkSpeedToggleObj.getValue()
    walkSpeedToggleObj.setValue(not current)
end)

-- Teleportation
local TeleportSub = Category1:Button("Teleportation", "http://www.roblox.com/asset/?id=8395747586")
local TeleportSection = TeleportSub:Section("Teleportation", "Right")

TeleportSection:Textbox({
    Title = "Teleport Coordinates",
    Description = "X,Y,Z (comma or space separated)",
    Default = "",
}, function(value)
    local separated = {}
    for chunk in string.gmatch(value, "[^%s,]+") do
        table.insert(separated, chunk)
    end
    if #separated >= 3 then
        local x = tonumber(separated[1]) or 0
        local y = tonumber(separated[2]) or 0
        local z = tonumber(separated[3]) or 0
        Functions.TeleportToCoordinates(Vector3.new(x,y,z))
    end
end)

-- Fill the players list
local players = {}
for _,p in ipairs(game.Players:GetPlayers()) do
    table.insert(players, p.Name)
end

TeleportSection:Dropdown({
    Title = "Teleport to Player",
    Description = "Select a player",
    Options = players,  -- important for it to show
    Default = players[1] or "",
}, function(name)
    Functions.TeleportToPlayer(name)
end)


--------------------------------------------------------------------------------
-- Misc (formerly Advanced)
--------------------------------------------------------------------------------
local MiscSub = Category1:Button("Misc", "http://www.roblox.com/asset/?id=8395747586")
local MiscSection = MiscSub:Section("Misc Features", "Right")

-- Keybind for Noclip
MiscSection:Keybind({
    Title = "Noclip Keybind",
    Description = "Toggle noclip on/off",
    Default = Enum.KeyCode.P,
}, function()
    Functions.NoclipToggle()
end)

MiscSection:Button({
    Title = "Ragdoll Self",
    ButtonName = "RAGDOLL",
    Description = "Makes your character ragdoll",
}, function()
    Functions.RagdollSelf()
end)

MiscSection:Button({
    Title = "Fix Broken Leg",
    ButtonName = "FIX LEG",
    Description = "Restore your broken leg",
}, function()
    Functions.FixBrokenLeg()
end)

MiscSection:Toggle({
    Title = "Placeholder Toggle",
    Description = "Example future toggle",
    Default = false,
}, function(state)
    Functions.PlaceholderToggle(state)
end)

MiscSection:Button({
    Title = "Placeholder Button",
    ButtonName = "DO SOMETHING",
    Description = "Example usage",
}, function()
    Functions.PlaceholderButton()
end)


--------------------------------------------------------------------------------
-- Combat
--------------------------------------------------------------------------------
local CombatSub = Category1:Button("Combat", "http://www.roblox.com/asset/?id=8395747586")
local CombatSection = CombatSub:Section("Combat Tools", "Left")

local damageAmount = 10
CombatSection:Textbox({
    Title = "Damage Amount",
    Description = "Enter how much damage to do to self",
    Default = "10",
}, function(val)
    damageAmount = tonumber(val) or 10
end)

CombatSection:Button({
    Title = "Apply Damage",
    ButtonName = "DAMAGE ME",
    Description = "Damages yourself by the set amount",
}, function()
    Functions.DamageSelf(damageAmount)
end)


--------------------------------------------------------------------------------
-- Credits 
--------------------------------------------------------------------------------
local CreditsCategory = Window:Category("Credits", "http://www.roblox.com/asset/?id=8395621517")
local CreditsSub = CreditsCategory:Button("Credits", "http://www.roblox.com/asset/?id=8395747586")
local CreditsSection = CreditsSub:Section("Acknowledgments", "Left")

CreditsSection:Button({
    Title = "UI by Hydra",
    ButtonName = "Thanks",
    Description = "Thanks to Hydra UI Lib!",
}, function()
    print("[Credits] Hydra UI Lib credit clicked.")
end)
