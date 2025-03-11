--// RunUI.lua

-- 1) If old UI exists, destroy it + call StopAll()
local CoreGui = game:GetService("CoreGui")
local existing = CoreGui:FindFirstChild("HydraUILib")
            or (game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                and game.Players.LocalPlayer.PlayerGui:FindFirstChild("HydraUILib"))
if existing then
    -- If we have old ApocFunctions with a StopAll, call it
    if getgenv().ApocFunctions and getgenv().ApocFunctions.StopAll then
        getgenv().ApocFunctions.StopAll()
    end
    existing:Destroy()
end

-- 2) Require or load the ApocFunctions if not already
if not getgenv().ApocFunctions or not next(getgenv().ApocFunctions) then
    -- load or require your actual Functions
    -- For example:
    getgenv().ApocFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/Functions.lua"))()
end
local Functions = getgenv().ApocFunctions

-- 3) Load the UI library
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua"))()

-- 4) Create the main Window
local Window = UILib.new("Apocrypha", game.Players.LocalPlayer.UserId, "Buyer")

--------------------------------------------------------------------------------
-- “Main Features”
--------------------------------------------------------------------------------
local Category1 = Window:Category("Main Features", "http://www.roblox.com/asset/?id=8395621517")

-- Movement sub
local MovementSub = Category1:Button("Movement", "rbxassetid://8395747586")
local MovementSection = MovementSub:Section("Movement", "Left")

-- Fly
MovementSection:Keybind({
    Title = "Fly Keybind",
    Description = "Toggle flight on/off",
    Default = Enum.KeyCode.R,
}, function()
    Functions.FlyToggle()
end)

-- Flight Speed as a Slider 0.5–6
MovementSection:Slider({
    Title = "Flight Speed",
    Description = "Set flight speed multiplier",
    Min = 0.5,
    Max = 6,
    Default = 1,
}, function(value)
    Functions.SetFlySpeed(value)
end)

-- Walkspeed
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
        Functions.WalkSpeedToggle()
    end
end)

MovementSection:Keybind({
    Title = "WalkSpeed Keybind",
    Description = "Toggle walk speed same as above",
    Default = Enum.KeyCode.H,
}, function()
    local current = walkSpeedToggleObj.getValue()
    walkSpeedToggleObj.setValue(not current)
end)

--------------------------------------------------------------------------------
-- Teleportation (Left side now)
--------------------------------------------------------------------------------
local TeleportSub = Category1:Button("Teleportation", "rbxassetid://8395747586")
local TeleportSection = TeleportSub:Section("Teleportation", "Left")

TeleportSection:Textbox({
    Title = "Teleport Coordinates",
    Description = "X,Y,Z (comma or space separated)",
    Default = "",
}, function(value)
    local splitted = {}
    for chunk in string.gmatch(value, "[^%s,]+") do
        table.insert(splitted, chunk)
    end
    if #splitted >= 3 then
        local x = tonumber(splitted[1]) or 0
        local y = tonumber(splitted[2]) or 0
        local z = tonumber(splitted[3]) or 0
        Functions.TeleportToCoordinates(Vector3.new(x,y,z))
    end
end)

-- SINGLE-SELECT dictionary approach for Teleport to Player
local playerDict = {}
for _,plr in ipairs(game.Players:GetPlayers()) do
    playerDict[plr.Name] = false
end
-- Let’s default to localplayer
playerDict[game.Players.LocalPlayer.Name] = true

TeleportSection:Dropdown({
    Title = "Teleport to Player",
    Description = "Choose a player",
    Options = playerDict,
    Default = game.Players.LocalPlayer.Name,
    Multi = false,  -- single select
}, function(updatedDict)
    -- Only one key in updatedDict is true
    for name, boolVal in pairs(updatedDict) do
        if boolVal == true then
            Functions.TeleportToPlayer(name)
            break
        end
    end
end)


--------------------------------------------------------------------------------
-- Misc (Left side)
--------------------------------------------------------------------------------
local MiscSub = Category1:Button("Misc", "rbxassetid://8395747586")
local MiscSection = MiscSub:Section("Misc Features", "Left")

-- Noclip Keybind
MiscSection:Keybind({
    Title = "Noclip Keybind",
    Description = "Toggle noclip on/off",
    Default = Enum.KeyCode.P,
}, function()
    Functions.NoclipToggle()
end)

-- Ragdoll / Fix Leg
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
    Description = "Restore broken leg",
}, function()
    Functions.FixBrokenLeg()
end)

-- Example placeholders
MiscSection:Toggle({
    Title = "Placeholder Toggle",
    Description = "Example usage",
    Default = false,
}, function(state)
    Functions.PlaceholderToggle(state)
end)

MiscSection:Button({
    Title = "Placeholder Button",
    ButtonName = "DO SOMETHING",
    Description = "Example button",
}, function()
    Functions.PlaceholderButton()
end)


--------------------------------------------------------------------------------
-- Combat
--------------------------------------------------------------------------------
local CombatSub = Category1:Button("Combat", "rbxassetid://8395747586")
local CombatSection = CombatSub:Section("Combat Tools", "Left")

local dmgVal = 10
CombatSection:Textbox({
    Title = "Damage Amount",
    Description = "How much to damage yourself",
    Default = "10",
}, function(val)
    dmgVal = tonumber(val) or 10
end)

CombatSection:Button({
    Title = "Apply Damage",
    ButtonName = "DAMAGE ME",
    Description = "Damages you by that amount",
}, function()
    Functions.DamageSelf(dmgVal)
end)


--------------------------------------------------------------------------------
-- Settings (Between Main Features and Credits)
--------------------------------------------------------------------------------
local SettingsCategory = Window:Category("Settings", "rbxassetid://8395621517")
local SettingsSub = SettingsCategory:Button("Settings", "rbxassetid://8395747586")
local SettingsSection = SettingsSub:Section("UI Behavior", "Left")

-- Keybind to toggle Minimize
SettingsSection:Keybind({
    Title = "Minimize UI",
    Description = "Minimize or restore the UI",
    Default = Enum.KeyCode.M,
}, function()
    Window:ToggleMinimize()
end)


--------------------------------------------------------------------------------
-- Credits
--------------------------------------------------------------------------------
local CreditsCategory = Window:Category("Credits", "rbxassetid://8395621517")
local CreditsSub = CreditsCategory:Button("Credits", "rbxassetid://8395747586")
local CreditsSection = CreditsSub:Section("Acknowledgments", "Left")

CreditsSection:Button({
    Title = "UI by Hydra",
    ButtonName = "Thanks",
    Description = "Thank you Hydra UI Lib!",
}, function()
    print("[Credits] Hydra UI Lib clicked!")
end)
