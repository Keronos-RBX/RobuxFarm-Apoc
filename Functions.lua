--// Functions.lua

getgenv().ApocFunctions = {}
local M = {}

-- EXAMPLE FLY FEATURE:
function M.FlyToggle()
    print("[Functions] Fly toggled on/off.")
    -- Your real flight code goes here...
end

-- TP TO COORDINATES:
function M.TeleportToCoordinates(vec3)
    print("[Functions] Teleporting to coordinates:", vec3)
    -- Your real teleportation code here...
end

-- TP TO PLAYER:
function M.TeleportToPlayer(playerName)
    print("[Functions] Teleporting to player:", playerName)
    -- Your real "teleport to player" code here...
end

-- FIX BROKEN LEG:
function M.FixBrokenLeg()
    print("[Functions] Fixing broken leg...")
    -- Your fix-broken-leg code here...
end

-- RAGDOLL YOURSELF:
function M.RagdollSelf()
    print("[Functions] Ragdolling self...")
    -- Your ragdoll code here...
end

-- DAMAGE YOURSELF:
function M.DamageSelf(amount)
    print("[Functions] Damaging self by:", amount)
    -- Your damage application code here...
end

-- PLACEHOLDER KEYBIND:
function M.PlaceholderKeybind(key)
    print("[Functions] Placeholder keybind pressed:", key)
    -- Replace or expand with actual logic
end

-- PLACEHOLDER TOGGLE:
function M.PlaceholderToggle(state)
    print("[Functions] Placeholder toggle state changed:", state)
    -- Replace or expand with actual logic
end

-- PLACEHOLDER BUTTON:
function M.PlaceholderButton()
    print("[Functions] Placeholder button clicked!")
    -- Replace or expand with actual logic
end


for k,v in pairs(M) do
    getgenv().ApocFunctions[k] = v
end

return M
