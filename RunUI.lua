--// RunUI
-- Refined script with organized sections and close/minimize functionality

-- 1. Load the UI library
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua'))()
local Functions = getgenv().ApocFunctions

-- Create main window
local Window = UILib.new("Apocrypha", game.Players.LocalPlayer.UserId, "Buyer")

-- Add close and minimize buttons
local function addWindowControls()
    local mainUI = Window.MainUI
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Image = "rbxassetid://7072725342"
    closeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.ZIndex = 200
    closeButton.Parent = mainUI
    
    local minimizeButton = Instance.new("ImageButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Image = "rbxassetid://7072706663"
    minimizeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -50, 0, 5)
    minimizeButton.ZIndex = 200
    minimizeButton.Parent = mainUI

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        mainUI.Visible = false
    end)
    
    -- Minimize button functionality
    local minimized = false
    local originalSize = mainUI.Size
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        mainUI.Size = minimized and UDim2.new(0.2, 0, 0, 40) or originalSize
    end)
end

addWindowControls()

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
