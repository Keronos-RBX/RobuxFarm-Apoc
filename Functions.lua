--// Functions.lua
-- This script sets up an accessible table of functions for your UI to call externally.

-- We store everything in a global table so that any other injected script can easily access it.
getgenv().ApocFunctions = getgenv().ApocFunctions or {}

local M = {}

--------------------------------------------------------------------------
-- FLY IMPLEMENTATION
--------------------------------------------------------------------------
-- We'll create a simple WASD-based flying system using BodyVelocity-like logic
-- inside a RunService.Heartbeat loop. Toggles on/off each time you call FlyToggle().

local flying = false
local flySpeed = 50

local wDown, aDown, sDown, dDown = false, false, false, false
local inputBeganConnection, inputEndedConnection, flyConnection

local function StartFly()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hum then return end

    -- Prevent standard physics from interfering
    hum.PlatformStand = true

    local userInputService = game:GetService("UserInputService")

    local function onInputBegan(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then
                wDown = true
            elseif input.KeyCode == Enum.KeyCode.S then
                sDown = true
            elseif input.KeyCode == Enum.KeyCode.A then
                aDown = true
            elseif input.KeyCode == Enum.KeyCode.D then
                dDown = true
            end
        end
    end

    local function onInputEnded(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then
                wDown = false
            elseif input.KeyCode == Enum.KeyCode.S then
                sDown = false
            elseif input.KeyCode == Enum.KeyCode.A then
                aDown = false
            elseif input.KeyCode == Enum.KeyCode.D then
                dDown = false
            end
        end
    end

    inputBeganConnection = userInputService.InputBegan:Connect(onInputBegan)
    inputEndedConnection = userInputService.InputEnded:Connect(onInputEnded)

    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flying then return end
        if not hrp or not char or not char.Parent then
            -- If character/HRP is gone, stop flying.
            M.FlyToggle()
            return
        end

        local camera = workspace.CurrentCamera
        local moveDir = Vector3.new()

        -- Basic WASD movement relative to camera
        if wDown then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if sDown then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if aDown then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if dDown then
            moveDir = moveDir + camera.CFrame.RightVector
        end

        -- Keep flight primarily horizontal. Remove vertical camera tilt from direction.
        moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)

        -- Set velocity
        hrp.Velocity = moveDir * flySpeed
    end)
end

local function StopFly()
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    -- Disconnect input listeners
    if inputBeganConnection then
        inputBeganConnection:Disconnect()
        inputBeganConnection = nil
    end
    if inputEndedConnection then
        inputEndedConnection:Disconnect()
        inputEndedConnection = nil
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    -- Reset WASD states
    wDown, aDown, sDown, dDown = false, false, false, false
end

function M.FlyToggle()
    flying = not flying
    if flying then
        print("[Functions] Fly enabled.")
        StartFly()
    else
        print("[Functions] Fly disabled.")
        StopFly()
    end
end

--------------------------------------------------------------------------
-- TELEPORT TO COORDINATES
--------------------------------------------------------------------------
function M.TeleportToCoordinates(vec3)
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(vec3)
        print("[Functions] Teleported to:", vec3)
    else
        warn("[Functions] Unable to teleport (no character or HumanoidRootPart).")
    end
end

--------------------------------------------------------------------------
-- TELEPORT TO PLAYER
--------------------------------------------------------------------------
function M.TeleportToPlayer(playerName)
    local plr = game.Players:FindFirstChild(playerName)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local localPlr = game.Players.LocalPlayer
        local localChar = localPlr and localPlr.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local hrp = localChar.HumanoidRootPart
            hrp.CFrame = plr.Character.HumanoidRootPart.CFrame
            print("[Functions] Teleported to player:", playerName)
        end
    else
        warn("[Functions] Could not find target player's HumanoidRootPart or player does not exist.")
    end
end

--------------------------------------------------------------------------
-- FIX BROKEN LEG (Example Implementation)
--------------------------------------------------------------------------
function M.FixBrokenLeg()
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if not char then return end

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        -- Example approach: force Humanoid to 'GetUp' state or restore health
        -- In your custom game, you might do something else (reset a broken-bone variable, etc.)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.Health = hum.MaxHealth
        print("[Functions] Broken leg fixed (example).")
    end
end

--------------------------------------------------------------------------
-- RAGDOLL YOURSELF
--------------------------------------------------------------------------
function M.RagdollSelf()
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            print("[Functions] Character ragdolled.")
        end
    end
end

--------------------------------------------------------------------------
-- DAMAGE YOURSELF
--------------------------------------------------------------------------
function M.DamageSelf(amount)
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:TakeDamage(amount)
            print("[Functions] Damaged self by:", amount)
        end
    end
end

--------------------------------------------------------------------------
-- PLACEHOLDER KEYBIND
--------------------------------------------------------------------------
function M.PlaceholderKeybind(key)
    print("[Functions] Placeholder keybind triggered:", key)
end

--------------------------------------------------------------------------
-- PLACEHOLDER TOGGLE
--------------------------------------------------------------------------
function M.PlaceholderToggle(state)
    print("[Functions] Placeholder toggle changed:", state)
end

--------------------------------------------------------------------------
-- PLACEHOLDER BUTTON
--------------------------------------------------------------------------
function M.PlaceholderButton()
    print("[Functions] Placeholder button clicked.")
end

--------------------------------------------------------------------------

-- Put all these into the global ApocFunctions table so our UI script can call them.
for k,v in pairs(M) do
    getgenv().ApocFunctions[k] = v
end

return M
