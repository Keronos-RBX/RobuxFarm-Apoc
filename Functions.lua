--// Functions.lua
-- A module-like script for external injection.
-- It provides the new fly code (sFLY/NOFLY) alongside other universal functions.
-- Store these in getgenv().ApocFunctions so your UI can call them.

getgenv().ApocFunctions = getgenv().ApocFunctions or {}

-- Services/shortcuts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- A simple helper to get the root part
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end

--------------------------------------------------------------------------------
-- FLY CODE (from your provided snippet)
--------------------------------------------------------------------------------

local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1

-- We'll keep references to input connections so we can disconnect them.
local flyKeyDown, flyKeyUp

-- The sFLY function from your snippet (minor modifications to local variables).
local function sFLY(vfly)
    -- Wait until player, character, root, humanoid, and mouse exist
    repeat task.wait() until
        LocalPlayer
        and LocalPlayer.Character
        and getRoot(LocalPlayer.Character)
        and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    -- We can store the mouse here. 
    -- (In Infinite Yield, IYMouse is usually a globally set mouse, but we'll just get the local one.)
    local IYMouse = LocalPlayer:GetMouse()
    repeat task.wait() until IYMouse

    -- If we already have key connections, disconnect them
    if flyKeyDown or flyKeyUp then
        flyKeyDown:Disconnect()
        flyKeyUp:Disconnect()
    end

    local T = getRoot(LocalPlayer.Character)
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        FLYING = true
        local BG = Instance.new("BodyGyro")
        local BV = Instance.new("BodyVelocity")
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.cframe = T.CFrame
        BV.velocity = Vector3.new(0, 0, 0)
        BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            repeat
                task.wait()
                -- If not vehicle fly and we have a humanoid, set PlatformStand to true
                if not vfly and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = true
                end

                -- Adjust speed based on any pressed keys
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = 50
                elseif SPEED ~= 0 then
                    SPEED = 0
                end

                -- If we have a direction to move, apply it
                if (CONTROL.L + CONTROL.R) ~= 0
                   or (CONTROL.F + CONTROL.B) ~= 0
                   or (CONTROL.Q + CONTROL.E) ~= 0
                then
                    BV.velocity = (
                        (workspace.CurrentCamera.CoordinateFrame.LookVector * (CONTROL.F + CONTROL.B))
                        + (
                            (workspace.CurrentCamera.CoordinateFrame
                                * CFrame.new(
                                    CONTROL.L + CONTROL.R,
                                    (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2,
                                    0
                                ).p
                            ) - workspace.CurrentCamera.CoordinateFrame.p
                        )
                    ) * SPEED
                    lCONTROL = {
                        F = CONTROL.F,
                        B = CONTROL.B,
                        L = CONTROL.L,
                        R = CONTROL.R
                    }
                elseif SPEED ~= 0 then
                    -- Continue moving with last direction if needed
                    BV.velocity = (
                        (workspace.CurrentCamera.CoordinateFrame.LookVector * (lCONTROL.F + lCONTROL.B))
                        + (
                            (workspace.CurrentCamera.CoordinateFrame
                                * CFrame.new(
                                    lCONTROL.L + lCONTROL.R,
                                    (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2,
                                    0
                                ).p
                            ) - workspace.CurrentCamera.CoordinateFrame.p
                        )
                    ) * SPEED
                else
                    -- No movement
                    BV.velocity = Vector3.new(0, 0, 0)
                end

                BG.cframe = workspace.CurrentCamera.CoordinateFrame
            until not FLYING

            -- Cleanup after FLY ends
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()

            if LocalPlayer.Character
               and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
            end
        end)
    end

    -- KeyDown connection
    flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
        KEY = KEY:lower()
        if KEY == "w" then
            CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY == "s" then
            CONTROL.B = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY == "a" then
            CONTROL.L = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY == "d" then
            CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
        elseif QEfly and KEY == "e" then
            CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed) * 2
        elseif QEfly and KEY == "q" then
            CONTROL.E = -((vfly and vehicleflyspeed or iyflyspeed) * 2)
        end
        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Track
        end)
    end)

    -- KeyUp connection
    flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
        KEY = KEY:lower()
        if KEY == "w" then
            CONTROL.F = 0
        elseif KEY == "s" then
            CONTROL.B = 0
        elseif KEY == "a" then
            CONTROL.L = 0
        elseif KEY == "d" then
            CONTROL.R = 0
        elseif KEY == "e" then
            CONTROL.Q = 0
        elseif KEY == "q" then
            CONTROL.E = 0
        end
    end)

    -- Finally, launch the FLY loop
    FLY()
end

-- The NOFLY function (from your snippet)
local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then
        flyKeyDown:Disconnect()
        flyKeyUp:Disconnect()
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end

--------------------------------------------------------------------------------
-- FlyToggle (tie it all together)
--------------------------------------------------------------------------------
local M = {}

function M.FlyToggle()
    if FLYING then
        NOFLY()
        print("[Functions] Fly disabled.")
    else
        sFLY(false) -- Pass 'true' if you want the vehicleflyspeed version
        print("[Functions] Fly enabled.")
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
        warn("[Functions] Unable to teleport (no character or root part).")
    end
end

------------------------------------
