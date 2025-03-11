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
-- Global toggles and speeds
--------------------------------------------------------------------------------
local FLYING = false
local QEfly = true           -- Allows Q/E vertical movement
local iyflyspeed = 1         -- Default Fly speed
local vehicleflyspeed = 1

local walkSpeedEnabled = false
local desiredWalkSpeed = 16  -- For toggling WalkSpeed
local defaultWalkSpeed = 16  -- Usually Roblox default
local NoclipConn

-- Connections for fly
local flyKeyDown, flyKeyUp

--------------------------------------------------------------------------------
-- WALKSPEED
--------------------------------------------------------------------------------
local function setHumanoidSpeed(speed)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speed
        end
    end
end

local function enableWalkSpeed(speed)
    walkSpeedEnabled = true
    desiredWalkSpeed = speed or 16
    setHumanoidSpeed(desiredWalkSpeed)
    print("[Functions] WalkSpeed toggled ON (speed:", desiredWalkSpeed, ")")
end

local function disableWalkSpeed()
    walkSpeedEnabled = false
    setHumanoidSpeed(defaultWalkSpeed)
    print("[Functions] WalkSpeed toggled OFF (back to default speed).")
end

--------------------------------------------------------------------------------
-- Fly routines
--------------------------------------------------------------------------------
local function sFLY(vfly)
    -- Wait until character & root exist
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

    -- Disconnect old keybinds
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end

    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    -- Create BodyGyro/BodyVelocity
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

    if not vfly and humanoid then
        humanoid.PlatformStand = true
    end

    task.spawn(function()
        while FLYING and task.wait() do
            if (CONTROL.F + CONTROL.B) ~= 0
               or (CONTROL.L + CONTROL.R) ~= 0
               or (CONTROL.Q + CONTROL.E) ~= 0
            then
                SPEED = 50
            else
                SPEED = 0
            end

            if SPEED ~= 0 then
                BV.velocity =
                    ((workspace.CurrentCamera.CoordinateFrame.LookVector
                        * (CONTROL.F + CONTROL.B))
                     + ((workspace.CurrentCamera.CoordinateFrame
                         * CFrame.new((CONTROL.L + CONTROL.R),
                                      (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2,
                                      0).p)
                       - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED * iyflyspeed
            else
                BV.velocity = Vector3.new(0, 0, 0)
            end
            BG.cframe = workspace.CurrentCamera.CoordinateFrame
        end

        BG:Destroy()
        BV:Destroy()
        if humanoid and char.Parent then
            humanoid.PlatformStand = false
        end
    end)

    -- KeyDown
    flyKeyDown = IYMouse.KeyDown:Connect(function(key)
        key = key:lower()
        if key == "w" then
            CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "s" then
            CONTROL.B = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "a" then
            CONTROL.L = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "d" then
            CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "e" and QEfly then
            CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed) * 2
        elseif key == "q" and QEfly then
            CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed) * 2
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    end)

    -- KeyUp
    flyKeyUp = IYMouse.KeyUp:Connect(function(key)
        key = key:lower()
        if key == "w" then
            CONTROL.F = 0
        elseif key == "s" then
            CONTROL.B = 0
        elseif key == "a" then
            CONTROL.L = 0
        elseif key == "d" then
            CONTROL.R = 0
        elseif key == "e" then
            CONTROL.Q = 0
        elseif key == "q" then
            CONTROL.E = 0
        end
    end)
end

local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end

local function turnOffFly()
    FLYING = false
    -- disconnect any old connections, revert humanoid, etc.
end

local function turnOffWalkSpeed()
    walkSpeedEnabled = false
    -- restore default
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = defaultWalkSpeed
        end
    end
end

local function turnOffNoclip()
    if NoclipConn then
        NoclipConn:Disconnect()
        NoclipConn = nil
    end
    -- restore collisions
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end
--------------------------------------------------------------------------------
-- Exposed Table
--------------------------------------------------------------------------------
local M = {}

--------------------------------------------------------------------------------
-- WALKSPEED TOGGLE & SET
--------------------------------------------------------------------------------
function M.WalkSpeedToggle(inputSpeed)
    -- If already on, turn off
    if walkSpeedEnabled then
        disableWalkSpeed()
    else
        enableWalkSpeed(tonumber(inputSpeed) or 16)
    end
end

function M.SetWalkSpeed(speed)
    enableWalkSpeed(speed or 16)  -- forcibly sets it, leaving the toggle ON
end

--------------------------------------------------------------------------------
-- SET FLY SPEED
--------------------------------------------------------------------------------
function M.SetFlySpeed(newSpeed)
    local num = tonumber(newSpeed) or 1
    iyflyspeed = num
    print("[Functions] Fly speed set to:", num)
end

--------------------------------------------------------------------------------
-- FlyToggle
--------------------------------------------------------------------------------
function M.FlyToggle()
    if FLYING then
        NOFLY()
        print("[Functions] Fly disabled.")
    else
        sFLY(false)
        print("[Functions] Fly enabled (speed multiplier:", iyflyspeed, ").")
    end
end

--------------------------------------------------------------------------------
-- NOCLIP TOGGLE
--------------------------------------------------------------------------------
local Clip = true
local Noclipping

local function StartNoclip()
    Clip = false
    local function NoclipLoop()
        local character = LocalPlayer.Character
        if not Clip and character then
            for _, child in pairs(character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true then
                    child.CanCollide = false
                end
            end
        end
    end
    Noclipping = RunService.Stepped:Connect(NoclipLoop)
    print("[Functions] Noclip Enabled.")
end

local function StopNoclip()
    Clip = true
    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
    end
    local character = LocalPlayer.Character
    if character then
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = true
            end
        end
    end
    print("[Functions] Noclip Disabled.")
end

function M.NoclipToggle()
    if Clip then
        StartNoclip()
    else
        StopNoclip()
    end
end

--------------------------------------------------------------------------------
-- TELEPORT TO COORDINATES
--------------------------------------------------------------------------------
function M.TeleportToCoordinates(vec3)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(vec3)
        print("[Functions] Teleported to:", vec3)
    else
        warn("[Functions] Unable to teleport (no character or root).")
    end
end

--------------------------------------------------------------------------------
-- TELEPORT TO PLAYER
--------------------------------------------------------------------------------
function M.TeleportToPlayer(playerName)
    local targetPlr = Players:FindFirstChild(playerName)
    if targetPlr
       and targetPlr.Character
       and targetPlr.Character:FindFirstChild("HumanoidRootPart")
    then
        local localChar = LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            localChar.HumanoidRootPart.CFrame =
                targetPlr.Character.HumanoidRootPart.CFrame
            print("[Functions] Teleported to player:", playerName)
        end
    else
        warn("[Functions] Could not find that player’s root part.")
    end
end

--------------------------------------------------------------------------------
-- FIX BROKEN LEG (Example)
--------------------------------------------------------------------------------
function M.FixBrokenLeg()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.Health = hum.MaxHealth
        print("[Functions] Broken leg fixed (example).")
    end
end

--------------------------------------------------------------------------------
-- RAGDOLL YOURSELF
--------------------------------------------------------------------------------
function M.RagdollSelf()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            print("[Functions] Character ragdolled.")
        end
    end
end

--------------------------------------------------------------------------------
-- DAMAGE YOURSELF
--------------------------------------------------------------------------------
function M.DamageSelf(amount)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:TakeDamage(amount)
            print("[Functions] Damaged self by:", amount)
        end
    end
end

--------------------------------------------------------------------------------
-- PLACEHOLDER KEYBIND
--------------------------------------------------------------------------------
function M.PlaceholderKeybind(key)
    print("[Functions] Placeholder keybind triggered:", key)
end

--------------------------------------------------------------------------------
-- PLACEHOLDER TOGGLE
--------------------------------------------------------------------------------
function M.PlaceholderToggle(state)
    print("[Functions] Placeholder toggle changed:", state)
end

--------------------------------------------------------------------------------
-- PLACEHOLDER BUTTON
--------------------------------------------------------------------------------
function M.PlaceholderButton()
    print("[Functions] Placeholder button clicked.")
end

function M.StopAll()
    -- turn off flight, walk speed, noclip, etc.
    turnOffFly()
    turnOffWalkSpeed()
    turnOffNoclip()
    -- If you have other features that need to be cleaned up, do them here
    warn("[ApocFunctions] All features forcibly stopped.")
end

--------------------------------------------------------------------------------
-- Expose M in getgenv().ApocFunctions
--------------------------------------------------------------------------------
for k,v in pairs(M) do
    getgenv().ApocFunctions[k] = v
end

return M
