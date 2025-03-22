print("Running v1.01 of the .kero UI | patch 0.009")

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1) If an old UILib is still in getgenv, ask it to destroy itself
if getgenv().UILib and getgenv().UILib.DestroyUI then
    getgenv().UILib.DestroyUI(true)
end

-- 2) Clean up leftover "UI-Id" from the old session if it exists
local IdPart = CoreGui:FindFirstChild("UI-Id")
if IdPart then
    IdPart:Destroy()
end

-- Make a new unique ID
local Identifier = Instance.new("Part")
Identifier.Name = "UI-Id"
Identifier.Parent = CoreGui

local uniqueID = HttpService:GenerateGUID(false)
Identifier:SetAttribute("InstanceID", uniqueID)

if Identifier:GetAttribute("InstanceID") ~= uniqueID or nil then
    warn("UI-Id attribute mismatch. Stopping only the new script environment.")
    script:Destroy()
    return
end

getgenv().UIIdentifier = Identifier:GetAttribute("InstanceID")
print("New UI Identifier = ", getgenv().UIIdentifier)

-- If ApocFunctions not loaded, load it (the newly updated Functions.lua)
if not getgenv().ApocFunctions or not next(getgenv().ApocFunctions) then
    getgenv().ApocFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/Functions.lua"))()
end
local Functions = getgenv().ApocFunctions

-- If UILib not loaded, load it
if not getgenv().UILib or not next(getgenv().UILib) then
    getgenv().UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua"))()
end
local UILib = getgenv().UILib

local function CloseEverything()
    -- If we have ApocFunctions loaded, call StopAll
    if getgenv().ApocFunctions and getgenv().ApocFunctions.StopAll then
        getgenv().ApocFunctions.StopAll()
    end
    
    -- Then kill this UI
    if getgenv().UILib and getgenv().UILib.DestroyUI then
        getgenv().UILib.DestroyUI()
    end
end

-- Create the main window using your UI library
local Window = UILib.new("Apocrypha Cheat", LocalPlayer.UserId, "Buyer")

-- Provide a "DestroyUI" method so we can shut down *this* new environment if needed
getgenv().UILib.DestroyUI = function(ignoreDestroy)
    -- 1) Destroy the Window object
    if Window then
        Window:Destroy()
    end
    
    -- 2) Destroy the new "UI-Id" part
    local leftover = CoreGui:FindFirstChild("UI-Id")
    if leftover then
        leftover:Destroy()
    end

    if not ignoreDestroy then
        -- This kills *this* script environment
        script:Destroy()
    end
end

-- Create the main window
local Window = UILib.new("Apocrypha Cheat", LocalPlayer.UserId, "Buyer")

function killAll()
    -- Stop features
    if getgenv().ApocFunctions and getgenv().ApocFunctions.StopAll then
        getgenv().ApocFunctions.StopAll()
    end
    print("test123")
    if Identifier then Identifier:Destroy() end
    
    ----------------------------------------------------------------
    -- IMPORTANT: UNCOMMENT OR ADD THIS LINE SO THE OLD WINDOW CLOSES:
    if Window then Window:Destroy() end
    ----------------------------------------------------------------
    
    script:Destroy()
    error("Ending all current script execution")
end

-- Spawn a looping check every 2 seconds
task.spawn(function()
    while task.wait(2) do
        -- If "UI-Id" is destroyed, kill everything
        if not Identifier.Parent then
            CloseEverything()
            return
        end

        -- If someone changed the attribute on "UI-Id", kill everything
        if Identifier:GetAttribute("InstanceID") ~= uniqueID then
            CloseEverything()
            return
        end
    end
end)

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
    Description = "Toggle flight",
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
    Description = "Toggle walk speed with keybind",
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
    Description = "Toggle noclip",
    Default = Enum.KeyCode.P,
}, function()
    Functions.NoclipToggle()
end)

-- Ragdoll / Fix Leg
MiscSection:Button({
    Title = "Ragdoll Self",
    ButtonName = "Ragdoll",
    Description = "Ragdolls you",
}, function()
    Functions.RagdollSelf()
end)

MiscSection:Button({
    Title = "Fix Broken Leg",
    ButtonName = "Fix",
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
    Default = Enum.KeyCode.Equals,
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
    Title = "UI by HydraLib, Optimizations/Additional Features by Realuid",
    ButtonName = "TY",
    Description = "Give thanks",
}, function()
    print("Thank YOU for supporting this project :)")
end)

