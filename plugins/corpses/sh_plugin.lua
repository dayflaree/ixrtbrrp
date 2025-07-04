local PLUGIN = PLUGIN

PLUGIN.name = "Corpses"
PLUGIN.description = "Adds an inventory to dead player corpses and npcs."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

PLUGIN.factionDrops = {}
PLUGIN.factionInventoryBlacklist = {}
PLUGIN.maxFactionDrops = {}
PLUGIN.factionDropCallbacks = {}

/*
if ( FACTION_CP ) then
    PLUGIN.factionDrops[FACTION_CP] = {
        ["medicals_healthvial"] = 35, // 35% chance
        ["util_combinescrap"] = 90, // 90% chance
    }
end

if ( FACTION_OTA ) then
    PLUGIN.factionDrops[FACTION_OTA] = {
        ["medicals_healthvial"] = 35, // 35% chance
        ["util_combinescrap"] = 90, // 90% chance
    }
end
*/

PLUGIN.npcDrops = {
    /*
    ["npc_metropolice"] = {
        ["medicals_healthvial"] = 50, // 50% chance
        ["util_combinescrap"] = 90, // 90% chance
        ["ammo_pistol"] = 50, // 50% chance
        ["ammo_pistol"] = 10, // 10% chance
    },
    ["npc_combine_s"] = {
        ["medicals_healthvial"] = 35, // 25% chance
        ["util_combinescrap"] = 90, // 90% chance
        ["ammo_smg"] = 50, // 50% chance
        ["ammo_smg"] = 10, // 10% chance
    },
    ["npc_manhack"] = {
        ["util_metalplate"] = 35, // 25% chance
        ["util_combinescrap"] = 90, // 90% chance
    },
    ["npc_cscanner"] = {
        ["util_metalplate"] = 50, // 25% chance
        ["util_combinescrap"] = 90, // 90% chance
    },
    */
}

ix.config.Add("corpseDecayTime", 600, "The time it takes for a corpse to decay.", nil, {
    data = {min = 0, max = 3600},
    category = "Corpses"
})

ix.config.Add("corpseSearchTime", 2, "The time it takes to search a corpse.", nil, {
    data = {min = 0, max = 60},
    category = "Corpses"
})

ix.config.Add("corpseVelocityScale", 1, "The scale of the velocity applied to the corpse when it spawns.", nil, {
    data = {min = 0, max = 10, decimals = 1},
    category = "Corpses"
})

ix.util.Include("sv_hooks.lua")