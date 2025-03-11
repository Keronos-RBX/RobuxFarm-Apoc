--// Functions.lua

getgenv().ApocFunctions = getgenv().ApocFunctions or {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- Helper to get a character’s root part
--------------------------------------------------------------------------------
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end

--------------------------------------------------------------------------------
-- INFINITE YIELD–STYLE FLY
--------------------------------------------------------------------------------
local FLYING = false
local QEfly = true           -- Allows Q/E vertical movement
local iyflyspeed = 1
local vehicleflyspeed = 1

-- Connections for fly
local flyKeyDown, flyKeyUp

local function sFLY(vfly)
    while not (LocalPlayer
        and LocalPlayer.Character
        and getRoot(LocalPlayer.Character)
        and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")) do
        task.wait()
    end

    local char = LocalPlayer.Character
    local root = getRoot(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local IYMouse = LocalPlayer:GetMouse()

    while not IYMouse do task.wait() end

    -- If we already have existing key connections, disconnect them
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end

    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    -- Create BodyGyro/BodyVelocity to control flight
    local BG = Instance.new("BodyGyro")
    local BV = Instance.new("BodyVelocity")
    BG.P = 9e4
    BG.Parent = root
    BV.Parent = root
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.cframe = root.CFrame
    BV.velocity = Vector3.new(0, 0, 0)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

    FLYING = true

    -- If not vehicle fly, set PlatformStand
    if not vfly and humanoid then
        humanoid.PlatformStand = true
    end

    -- The main flight loop
    task.spawn(function()
        while FLYING and task.wait() do
            -- If movement keys are pressed, set speed
            if (CONTROL.F + CONTROL.B) ~= 0
               or (CONTROL.L + CONTROL.R) ~= 0
               or (CONTROL.Q + CONTROL.E) ~= 0
            then
                SPEED = 50
            else
                SPEED = 0
            end

            -- Apply velocity in the direction of the camera
            if SPEED ~= 0 then
                BV.velocity =
                    ((workspace.CurrentCamera.CoordinateFrame.LookVector
                        * (CONTROL.F + CONTROL.B))
                    + ((workspace.CurrentCamera.CoordinateFrame
                        * CFrame.new(
                            (CONTROL.L + CONTROL.R),
                            (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2,
                            0
                        ).p)
                    - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
            else
                BV.velocity = Vector3.new(0, 0, 0)
            end

            BG.cframe = workspace.CurrentCamera.CoordinateFrame
        end

        -- Cleanup after flight ends
        BG:Destroy()
        BV:Destroy()
        if humanoid and char.Parent then
            humanoid.PlatformStand = f
