local PLUGIN = PLUGIN

PLUGIN.name = "Third Person"
PLUGIN.author = "Riggs"
PLUGIN.description = "Allows players to use a third person camera view."

ix.config.Add("thirdperson", true, "Allow Thirdperson in the server.", nil, {
    category = "server"
})

local function isHidden()
    return !ix.config.Get("thirdperson")
end

ix.option.Add("thirdpersonEnabled", ix.type.bool, false, {
    category = "thirdperson",
    hidden = isHidden,
    OnChanged = function(oldValue, value)
        hook.Run("ThirdPersonToggled", oldValue, value)
    end
})

ix.option.Add("thirdpersonClassic", ix.type.bool, false, {
    category = "thirdperson",
    hidden = isHidden
})

ix.option.Add("thirdpersonVertical", ix.type.number, 0, {
    category = "thirdperson", min = 0, max = 30,
    hidden = isHidden
})

ix.option.Add("thirdpersonHorizontal", ix.type.number, 0, {
    category = "thirdperson", min = -30, max = 30,
    hidden = isHidden
})

ix.option.Add("thirdpersonDistance", ix.type.number, 50, {
    category = "thirdperson", min = 0, max = 100,
    hidden = isHidden
})

ix.util.Include("cl_plugin.lua")
ix.util.Include("cl_hooks.lua")