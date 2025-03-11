--// Functions.lua
-- REPLACES ANY OLD FLY CODE WITH THE INFINITE YIELD–STYLE FLY
-- ADDS Noclip Toggle (Infinite Yield style), plus the rest of your universal functions.

-- We'll store everything in getgenv().ApocFunctions so your UI can call them freely:
getgenv().ApocFunctions = getgenv().ApocFunctions or {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Helper to get root part
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end

--------------------------------------------------------------------------------
-- INFINITE YIELD–STYLE FLY
--------------------------------------------------------------------------------
local FLYING = false
local QEfly = true         -- allows Q/E vertical movement
local iyflyspeed = 1
local vehicleflyspeed = 1

-- We’ll keep references to the connections so we can clean up on toggle off
local flyKeyDown, flyKeyUp

-- sFLY function (Infinite Yield style)
local function sFLY(vfly)
    -- Wait until the local player, character, root, and humanoid exist
    while not (LocalPlayer
        and LocalPlayer.Character
        and getRoot(LocalPlayer.Character)
        and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")) do
        task.wait()
    end

    local char = LocalPlayer.Character
    local root = getRoot(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    -- We'll get the mouse for KeyDown/KeyUp
    local IYMouse = LocalPlayer:GetMouse()
    while not IYMouse do task.wait() end

    -- If we already have existing key connections, disconnect them
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end

    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    -- Actual FLY routine
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

    -- If not "vehicle fly," we set PlatformStand to avoid normal physics
    if not vfly and humanoid then
        humanoid.PlatformStand = true
    end

    -- This loop runs until we turn FLYING off
    task.spawn(function()
        while FLYING and task.wait() do
            -- Adjust speed if movement keys are pressed
            if (CONTROL.F + CONTROL.B) ~= 0
               or (CONTROL.L + CONTROL.R) ~= 0
               or (CONTROL.Q + CONTROL.E) ~= 0
            then
                SPEED = 50
            else
                SPEED = 0
            end

            -- If we have a direction, apply velocity based on camera orientation
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

                lCONTROL = {
                    F = CONTROL.F,
                    B = CONTROL.B,
                    L = CONTROL.L,
                    R = CONTROL.R,
                    Q = CONTROL.Q,
                    E = CONTROL.E
                }
            else
                BV.velocity = Vector3.new(0, 0, 0)
            end

            BG.cframe = workspace.CurrentCamera.CoordinateFrame
        end

        -- Cleanup once FLYING is false
        BG:Destroy()
        BV:Destroy()
        CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        SPEED = 0

        -- Restore physics if needed
        if humanoid and char.Parent then
            humanoid.PlatformStand = false
        end
    end)

    -- KeyDown connection
    flyKeyDown = IYMouse.KeyDown:Connect(function(key)
        key = key:lower()
        if key == "w" then
            CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "s" then
            CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "a" then
            CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "d" then
            CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
        elseif key == "e" and QEfly then
            CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed) * 2
        elseif key == "q" and QEfly then
            CONTROL.E = -((vfly and vehicleflyspeed or iyflyspeed) * 2)
        end

        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Track
        end)
    end)

    -- KeyUp connection
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

-- NOFLY function
local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end

    -- Restore default camera
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end

--------------------------------------------------------------------------------
-- FlyToggle (exposed function)
--------------------------------------------------------------------------------
local M = {}

function M.FlyToggle()
    if FLYING then
        -- Already flying, so turn it off
        NOFLY()
        print("[Functions] Fly disabled (Infinite Yield style).")
    else
        -- Not flying, so start
        sFLY(false) -- pass true if you want "vehicleflyspeed" logic
        print("[Functions] Fly enabled (Infinite Yield style).")
    end
end

--------------------------------------------------------------------------------
-- NOCLIP TOGGLE (Infinite Yield Style)
--------------------------------------------------------------------------------

-- We'll keep a "Clip" boolean to track state, plus a connection for the loop
local Clip = true
local Noclipping

-- Internal function to enable no-clip
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

-- Internal function to disable no-clip
local function StopNoclip()
    Clip = true
    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
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
        warn("[Functions] Could not find that player's root part.")
    end
end

--------------------------------------------------------------------------------
-- FIX BROKEN LEG (Example Implementation)
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

--------------------------------------------------------------------------------
-- Expose M in getgenv().ApocFunctions
--------------------------------------------------------------------------------
for k, v in pairs(M) do
    getgenv().ApocFunctions[k] = v
end

return M
