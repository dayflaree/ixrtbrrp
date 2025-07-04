local PLUGIN = PLUGIN

PLUGIN.name = "Project Synapse - User Interface"
PLUGIN.description = "Recreates the user interface from Project Synapse and integrates it into Helix."
PLUGIN.author = "Riggs"
PLUGIN.schema = "HL2 RP"

-- Change the icon paths below to your own custom icons!
PLUGIN.tabIcons = {
    ["config"] = ix.util.GetMaterial("your/custom/path/cogs.png", "smooth mips"),
    ["help"] = ix.util.GetMaterial("your/custom/path/help.png", "smooth mips"),
    ["inv"] = ix.util.GetMaterial("your/custom/path/suitcase.png", "smooth mips"),
    ["menu"] = ix.util.GetMaterial("your/custom/path/menu.png", "smooth mips"),
    ["return"] = ix.util.GetMaterial("your/custom/path/undo.png", "smooth mips"),
    ["scoreboard"] = ix.util.GetMaterial("your/custom/path/group.png", "smooth mips"),
    ["settings"] = ix.util.GetMaterial("your/custom/path/controls.png", "smooth mips"),
    ["you"] = ix.util.GetMaterial("your/custom/path/id.png", "smooth mips")
}

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.util.Include("cl_hooks.lua")

/*
-- Add this to your faction file
-- This is an example of how to set up a faction with spawn points.
FACTION.spawnPoints = {
    ["Location"] = {
        canUse = function(character)
            -- For example, you can check if the character has a specific data value or item
            -- return character:GetInventory():HasItem("pistol")
            return true -- Allow all characters to use this spawn point
        end,
        -- The spawn points for this location.
        -- These are the vectors where players will spawn when they select this location.
        spawns = {
            Vector(-2519, -666, 73),
            Vector(-2433, -666, 73),
            Vector(-2347, -666, 73),
            Vector(-2519, -750, 73),
            Vector(-2433, -750, 73),
            Vector(-2347, -750, 73),
            Vector(-2519, -846, 73),
            Vector(-2433, -846, 73),
            Vector(-2347, -846, 73),
            Vector(-2519, -948, 73),
            Vector(-2433, -948, 73),
            Vector(-2347, -948, 73),
            Vector(-2519, -1058, 73),
            Vector(-2433, -1058, 73),
            Vector(-2347, -1058, 73),
            Vector(-2519, -1201, 73),
            Vector(-2433, -1201, 73),
            Vector(-2347, -1201, 73),
            Vector(-2519, -1312, 73),
            Vector(-2433, -1312, 73),
            Vector(-2347, -1312, 73)
        }
    },
    ["Another Location"] = {
        canUse = function(character)
            -- You can add more complex logic here to determine if the character can use this spawn point
            return true -- Allow all characters to use this spawn point
        end,
        spawns = {
            Vector(-4913, -467, 161),
            Vector(-4797, -467, 161),
            Vector(-4725, -467, 161),
            Vector(-4653, -467, 161),
            Vector(-4519, -467, 161),
            Vector(-4387, -467, 161),
            Vector(-4913, -968, 161),
            Vector(-4797, -968, 161),
            Vector(-4725, -968, 161),
            Vector(-4653, -968, 161),
            Vector(-4519, -968, 161),
            Vector(-4387, -968, 161)
        }
    }
}

-- Add this to your faction file
-- The spawn camera position and angle, as well as the model position, angle, and sequence.
-- This is used to display the character model in the spawn menu, aswell as the camera position and angle during loading characters.
FACTION.spawnCam = {
    pos = Vector(5049, 9595, 2705),
    ang = Angle(0, -45, 0),
    modelPos = Vector(5084, 9535, 2648),
    modelAng = Angle(0, 90, 0),
    modelSequence = {"lineidle01", "lineidle02", "lineidle03", "lineidle04", "idle_angry"},
    fov = 40
}
*/