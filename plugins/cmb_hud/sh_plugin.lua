/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

if ( !CMB ) then
    error("[Helix] The Combine Framework is missing! Please make sure it is installed.")
end

local PLUGIN = PLUGIN

PLUGIN.name = "Combine Framework (HUD)"
PLUGIN.description = "Adds a Combine HUD, with a variety of features such as waypoints, objectives, and more."
PLUGIN.author = "Riggs"
PLUGIN.schema = "HL2 RP"

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")