--// RunUI.lua
print("Loading v1.01 of the .kero UI")

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1) If old UI exists, destroy it + call StopAll()
local existing = CoreGui:FindFirstChild("HydraUILib")
                or (LocalPlayer:FindFirstChild("PlayerGui")
                    and LocalPlayer.PlayerGui:FindFirstChild("HydraUILib"))
if existing then
    -- If we have old ApocFunctions with StopAll, call it
    if getgenv().ApocFunctions and getgenv().ApocFunctions.StopAll then
        getgenv().ApocFunctions.StopAll()
    end
    existing:Destroy()
end

-- 2) If ApocFunctions not loaded, load it
if not getgenv().ApocFunctions or not next(getgenv().ApocFunctions) then
    -- For example, if your Functions.lua is on GitHub:
    getgenv().ApocFunctions = loadstring(
        game:HttpGet("https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/Functions.lua")
    )()
end
local Functions = getgenv().ApocFunctions

-- 3) Load the UI library (the updated one that has the fixes)
local UILib = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua")
)()

print("test123")
-- 4) Create the main window
local Window = UILib.new("Apocrypha", LocalPlayer.UserId, "Buyer")

--------------------------------------------------------------------------------
-- “Main Features” Category
--------------------------------------------------------------------------------
local Category1 = Window:Category("Main Features", "http://www.roblox.com/asset/?id=8395621517")

-- Movement subcategory
local MovementSub = Category1:Button("Movement", "rbxassetid://8395747586")
local MovementSection = MovementSub:Section("Movement", "Left")

-- Fly Keybind
MovementSection:Keybind({
    Title = "Fly Keybind",
    Description = "Toggle flight on/off",
    Default = Enum.KeyCode.R,
}, function()
    Functions.FlyToggle()
end)

-- Flight Speed
MovementSection:Slider({
    Title = "Flight Speed",
    Description = "Set flight speed multiplier",
    Min = 0.5,
    Max = 6,
    Default = 1,
}, function(value)
    Functions.SetFlySpeed(value)
end)

-- WalkSpeed input
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

-- WalkSpeed toggle
local walkSpeedToggleObj
walkSpeedToggleObj = MovementSection:Toggle({
    Title = "WalkSpeed Toggle",
    Description = "Toggle custom walk speed on/off",
    Default = false,
}, function(state)
    if state then
        Functions.SetWalkSpeed(walkSpeedValue)
    else
        -- This actually toggles off if it was on, or on if it was off,
        -- but we specifically want to ensure it is OFF:
        Functions.WalkSpeedToggle()
    end
end)

-- WalkSpeed Keybind
MovementSection:Keybind({
    Title = "WalkSpeed Keybind",
    Description = "Toggle walk speed same as above",
    Default = Enum.KeyCode.H,
}, function()
    local current = walkSpeedToggleObj.getValue()
    walkSpeedToggleObj.setValue(not current)
end)

--------------------------------------------------------------------------------
-- Teleportation
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

-- Single-select dropdown for Teleport to Player
local playerDict = {}
for _,plr in ipairs(Players:GetPlayers()) do
    playerDict[plr.Name] = false
end
playerDict[LocalPlayer.Name] = true

TeleportSection:Dropdown({
    Title = "Teleport to Player",
    Description = "Choose a player",
    Options = playerDict,
    Default = LocalPlayer.Name,
    Multi = false,
}, function(updatedDict)
    for name, boolVal in pairs(updatedDict) do
        if boolVal == true then
            Functions.TeleportToPlayer(name)
            break
        end
    end
end)

--------------------------------------------------------------------------------
-- Misc
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

-- Placeholder
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
-- Settings
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
    Window:ToggleMinimize() -- Now works properly
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
