-----------------------
-- RunUI.lua (revised)
-----------------------
print("Running v1.01 of the .kero UI | patch 0.008")

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

-- If UILib not loaded, load it
if not getgenv().UILib or not next(getgenv().UILib) then
    getgenv().UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Keronos-RBX/RobuxFarm-Apoc/refs/heads/main/UI.lua"))()
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

--------------------------------------------------------------------------------
-- The rest of your code hooking up categories, subcategories, toggles, etc.
--------------------------------------------------------------------------------

-- Just an example usage of "killAll" that your older script had
-- We rename it to 'CloseEverything' to avoid confusion
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

--------------------------------------------------------------------------------
-- Example of your existing logic:
--------------------------------------------------------------------------------

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

print("Test: UI is up and running")

--------------------------------------------------------------------------------
-- Example for hooking up some keybind to close everything (optional)
--------------------------------------------------------------------------------
-- local someConnection = UserInputService.InputBegan:Connect(function(inp, gp)
--     if not gp and inp.KeyCode == Enum.KeyCode.X then
--         CloseEverything()
--     end
-- end)
-- getgenv().ApocFunctions.RegisterKeybindConnection(someConnection)

--------------------------------------------------------------------------------
-- Continue with your existing Category creation, movement toggles, etc.
--------------------------------------------------------------------------------
-- e.g.:
-- local Functions = getgenv().ApocFunctions
-- local UILib = getgenv().UILib
-- local MovementSub = Window:Category("Main Features", "http://www.roblox.com/asset/?id=8395621517")
-- ...
--------------------------------------------------------------------------------
