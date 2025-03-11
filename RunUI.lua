--// RunUI.lua
-- Refined script with organized sections, now with WalkSpeed & Flight Speed inputs
-- REMOVED the local function addWindowControls() since we’ll do it in UI.lua

local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua'))()
local Functions = getgenv().ApocFunctions

-- Create main window
local Window = UILib.new("Apocrypha", game.Players.LocalPlayer.UserId, "Buyer")

-- Create main category
local Category1 = Window:Category("Main Features", "http://www.roblox.com/asset/?id=8395621517")

-- Movement Section
local MovementSub = Category1:Button("Movement", "http://www.roblox.com/asset/?id=8395747586")
local MovementSection = MovementSub:Section("Movement", "Left")

MovementSection:Keybind({
    Title = "Fly",
    Description = "Toggle flight on/off",
    Default = Enum.KeyCode.R,
}, function(key)
    Functions.FlyToggle()
end)

-- 1) Textbox for Flight Speed
MovementSection:Textbox({
    Title = "Flight Speed",
    Description = "Sets the flight speed multiplier",
    Default = "1",
}, function(value)
    local num = tonumber(value) or 1
    Functions.SetFlySpeed(num)
end)

-- 2) WalkSpeed “toggle” approach
local walkSpeedInput = 16  -- store user’s desired speed
MovementSection:Textbox({
    Title = "WalkSpeed Input",
    Description = "Enter your custom walk speed",
    Default = "16",
}, function(value)
    walkSpeedInput = tonumber(value) or 16
end)

MovementSection:Toggle({
    Title = "WalkSpeed Toggle",
    Description = "Toggle custom walk speed on/off",
    Default = false,
}, function(state)
    if state then
        Functions.SetWalkSpeed(walkSpeedInput)
    else
        -- if toggled off, revert to default (16)
        Functions.WalkSpeedToggle()  -- This call toggles it OFF if it was on
    end
end)

MovementSection:Button({
    Title = "Ragdoll",
    ButtonName = "RAGDOLL",
    Description = "Makes your character ragdoll",
}, function()
    Functions.RagdollSelf()
end)

MovementSection:Button({
    Title = "Fix Broken Leg",
    ButtonName = "FIX LEG",
    Description = "Restore your broken leg",
}, function()
    Functions.FixBrokenLeg()
end)

-- Teleportation Section
local TeleportSub = Category1:Button("Teleportation", "http://www.roblox.com/asset/?id=8395747586")
local TeleportSection = TeleportSub:Section("Teleportation", "Right")

TeleportSection:Textbox({
    Title = "Teleport Coordinates",
    Description = "Enter X,Y,Z (comma or space separated)",
    Default = "",
}, function(value)
    local x, y, z = 0, 0, 0
    local separated = {}
    for chunk in string.gmatch(value, "[^%s,]+") do
        table.insert(separated, chunk)
    end
    if #separated >= 3 then
        x = tonumber(separated[1]) or 0
        y = tonumber(separated[2]) or 0
        z = tonumber(separated[3]) or 0
    end
    Functions.TeleportToCoordinates(Vector3.new(x, y, z))
end)

do
    local players = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        table.insert(players, plr.Name)
    end

    TeleportSection:Dropdown({
        Title = "Teleport to Player",
        Description = "Select a player to teleport to them",
        Items = players,
        Default = players[1] or "",
    }, function(selectedName)
        Functions.TeleportToPlayer(selectedName)
    end)
end

-- Combat Section
local CombatSub = Category1:Button("Combat", "http://www.roblox.com/asset/?id=8395747586")
local CombatSection = CombatSub:Section("Combat", "Left")

local damageAmount = 10
CombatSection:Textbox({
    Title = "Damage Amount",
    Description = "Enter how much damage to apply",
    Default = "10",
}, function(value)
    local num = tonumber(value)
    damageAmount = num or 10
end)

CombatSection:Button({
    Title = "Apply Damage",
    ButtonName = "DAMAGE ME",
    Description = "Damages you by the specified amount",
}, function()
    Functions.DamageSelf(damageAmount)
end)

-- Advanced Section
local AdvancedSub = Category1:Button("Advanced", "http://www.roblox.com/asset/?id=8395747586")
local AdvancedSection = AdvancedSub:Section("Advanced Features", "Right")

AdvancedSection:Keybind({
    Title = "Placeholder Keybind",
    Description = "Example future keybind usage",
    Default = Enum.KeyCode.P,
}, function(key)
    Functions.NoclipToggle(key)
end)

AdvancedSection:Toggle({
    Title = "Placeholder Toggle",
    Description = "Example toggle for future features",
    Default = false,
}, function(state)
    Functions.PlaceholderToggle(state)
end)

AdvancedSection:Button({
    Title = "Placeholder Button",
    ButtonName = "DO SOMETHING",
    Description = "Example button for future usage",
}, function()
    Functions.PlaceholderButton()
end)
