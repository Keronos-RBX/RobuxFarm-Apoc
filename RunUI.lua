--// RunUI
-- This script builds the UI, hooking each button/toggle/keybind to a function in Functions.lua

-- 1. Load the UI library
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua'))()
local Functions = getgenv().ApocFunctions
local Window = UILib.new("Apocrypha", game.Players.LocalPlayer.UserId, "Buyer")
local Category1 = Window:Category("Main Features", "http://www.roblox.com/asset/?id=8395621517")
local MainSub = Category1:Button("Player & Combat", "http://www.roblox.com/asset/?id=8395747586")
local MainSection = MainSub:Section("Player & Combat Section", "Left")


MainSection:Keybind({
    Title = "Fly",
    Description = "Toggle flight on/off",
    Default = Enum.KeyCode.F,
}, function(key)
    Functions.FlyToggle()  -- or Functions.FlyToggle(key) if you want to pass the key
end)


MainSection:Textbox({
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

    MainSection:Dropdown({
        Title = "Teleport to Player",
        Description = "Select a player to teleport to them",
        Items = players,
        Default = players[1] or "",
    }, function(selectedName)
        Functions.TeleportToPlayer(selectedName)
    end)
end


MainSection:Button({
    Title = "Fix Broken Leg",
    ButtonName = "FIX LEG",
    Description = "Restore your broken leg",
}, function()
    Functions.FixBrokenLeg()
end)


MainSection:Button({
    Title = "Ragdoll",
    ButtonName = "RAGDOLL",
    Description = "Makes your character ragdoll",
}, function()
    Functions.RagdollSelf()
end)


local damageAmount = 10

-- Textbox for damage amount
MainSection:Textbox({
    Title = "Damage Amount",
    Description = "Enter how much damage to apply",
    Default = "10",
}, function(value)
    local num = tonumber(value)
    if num then
        damageAmount = num
    else
        damageAmount = 10
    end
end)

-- Button to apply damage
MainSection:Button({
    Title = "Apply Damage",
    ButtonName = "DAMAGE ME",
    Description = "Damages you by the specified amount",
}, function()
    Functions.DamageSelf(damageAmount)
end)


MainSection:Keybind({
    Title = "Placeholder Keybind",
    Description = "Example future keybind usage",
    Default = Enum.KeyCode.P,
}, function(key)
    Functions.PlaceholderKeybind(key)
end)


MainSection:Toggle({
    Title = "Placeholder Toggle",
    Description = "Example toggle for future features",
    Default = false,
}, function(state)
    Functions.PlaceholderToggle(state)
end)


MainSection:Button({
    Title = "Placeholder Button",
    ButtonName = "DO SOMETHING",
    Description = "Example button for future usage",
}, function()
    Functions.PlaceholderButton()
end)
