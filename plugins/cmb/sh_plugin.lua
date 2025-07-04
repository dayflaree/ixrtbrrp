/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.name = "Combine Framework"
PLUGIN.description = "The main framework for other Combine related plugins."
PLUGIN.author = "Riggs"
PLUGIN.schema = "HL2 RP"

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

CMB = CMB or {}

CMB.Framework = PLUGIN // Globalise the entirety of the plugin for use in other plugins.