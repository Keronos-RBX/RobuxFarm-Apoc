--// RunUI.lua
-- Updated to:
--  • Use a Slider (0.5–6) for Flight Speed
--  • Have an optional Walkspeed Keybind that toggles the same function as the Walkspeed toggle
--  • Add a keybind for Noclip
--  • Rename "Advanced" -> "Misc" and move Ragdoll + Fix Broken Leg there
--  • Create a new "Credits" category
--  • Fix the Teleport to Player dropdown by using Options=players

local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua'))()
local Functions = getgenv().ApocFunctions

local Window = UILib.new("Apocrypha", game.Players.LocalPlayer.UserId, "Buyer")

-------------------------------------------------------------------------
-- 1) MAIN FEATURES category
-------------------------------------------------------------------------

local Category1 = Window:Category("Main Features", "http://www.roblox.com/asset/?id=8395621517")

-- Movement Sub
local MovementSub = Category1:Button("Movement", "http://www.roblox.com/asset/?id=8395747586")
local MovementSection = MovementSub:Section("Movement", "Left")

-- Fly toggle (keybind)
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

-- We’ll store the walkspeed toggle object so the keybind can sync with it
local walkSpeedToggleObj
local walkSpeedValue = 16 -- default for user entry

-- A Textbox for the user’s desired walk speed
MovementSection:Textbox({
    Title = "WalkSpeed Input",
    Description = "Enter your custom walk speed",
    Default = "16",
}, function(value)
    local num = tonumber(value)
    if num then
        walkSpeedValue = num
    end
end)

-- The toggle for walk speed on/off
walkSpeedToggleObj = MovementSection:Toggle({
    Title = "WalkSpeed Toggle",
    Description = "Toggle custom walk speed on/off",
    Default = false,
}, function(state)
    if state then
        -- Turn on with the chosen speed
        Functions.SetWalkSpeed(walkSpeedValue)
    else
        -- Turn off
        Functions.WalkSpeedToggle() -- if it's on, that call toggles it off
    end
end)

-- The optional keybind for WalkSpeed toggling
MovementSection:Keybind({
    Title = "WalkSpeed Keybind",
    Description = "Same toggle as the WalkSpeed toggle button",
    Default = Enum.KeyCode.H,
}, function(_key)
    local current = walkSpeedToggleObj.getValue()
    -- flip it
    walkSpeedToggleObj.setValue(not current)
end)


-------------------------------------------------------------------------
-- Teleportation Sub
-------------------------------------------------------------------------

local TeleportSub = Category1:Button("Teleportation", "http://www.roblox.com/asset/?id=8395747586")
local TeleportSection = TeleportSub:Section("Teleportation", "Right")

TeleportSection:Textbox({
    Title = "Teleport Coordinates",
    Description = "Enter X,Y,Z (comma/space separated)",
    Default = "",
}, function(value)
    local separated = {}
    for part in string.gmatch(value, "[^%s,]+") do
        table.insert(separated, part)
    end
    if #separated >= 3 then
        local x = tonumber(separated[1]) or 0
        local y = tonumber(separated[2]) or 0
        local z = tonumber(separated[3]) or 0
        Functions.TeleportToCoordinates(Vector3.new(x,y,z))
    end
end)

-- Build a list of players
local players = {}
for _,p in ipairs(game.Players:GetPlayers()) do
    table.insert(players, p.Name)
end

TeleportSection:Dropdown({
    Title = "Teleport to Player",
    Description = "Select a player to teleport to them",
    Options = players,   -- NOTE: "Options" fixes the prior bug
    Default = players[1] or "",
}, function(selected)
    Functions.TeleportToPlayer(selected)
end)

-------------------------------------------------------------------------
-- 2) MISC Category (renamed from "Advanced")
-------------------------------------------------------------------------

local MiscSub = Category1:Button("Misc", "http://www.roblox.com/asset/?id=8395747586")
local MiscSection = MiscSub:Section("Misc Features", "Right")

-- Keybind for Noclip toggle
MiscSection:Keybind({
    Title = "Noclip Keybind",
    Description = "Toggle noclip on/off",
    Default = Enum.KeyCode.P,
}, function(_key)
    Functions.NoclipToggle()
end)

-- Move Ragdoll & Fix Broken Leg here:
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

-- Example toggles or placeholders if you want
-- (If you want to keep them from original "Advanced")
MiscSection:Toggle({
    Title = "Placeholder Toggle",
    Description = "Example toggle for future usage",
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


-------------------------------------------------------------------------
-- 3) COMBAT Section (if you want it)
-------------------------------------------------------------------------

local CombatSub = Category1:Button("Combat", "http://www.roblox.com/asset/?id=8395747586")
local CombatSection = CombatSub:Section("Combat Tools", "Left")

local damageAmount = 10
CombatSection:Textbox({
    Title = "Damage Amount",
    Description = "How much damage to apply to yourself",
    Default = "10",
}, function(value)
    damageAmount = tonumber(value) or 10
end)

CombatSection:Button({
    Title = "Apply Damage",
    ButtonName = "DAMAGE ME",
    Description = "Damages you by the specified amount",
}, function()
    Functions.DamageSelf(damageAmount)
end)


-------------------------------------------------------------------------
-- 4) CREDITS (new category)
-------------------------------------------------------------------------

local CreditsCategory = Window:Category("Credits", "http://www.roblox.com/asset/?id=8395621517")

local CreditsSub = CreditsCategory:Button("Credits", "http://www.roblox.com/asset/?id=8395747586")
local CreditsSection = CreditsSub:Section("Acknowledgments", "Left")

CreditsSection:Button({
    Title = "UI by Hydra",
    ButtonName = "Thanks",
    Description = "Thanks to Hydra UI Lib creators",
}, function()
    print("absasdasd")
end)

-- Feel free to add more credit lines, placeholders, etc.

