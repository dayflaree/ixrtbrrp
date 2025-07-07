ITEM.name = "Box of Flares"
ITEM.abbreviation = "Flares"
ITEM.description = "A carton box that contains %s signal flares for emergency use or illumination."
ITEM.model = Model("models/items/boxflares.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "rtbr_flare"
ITEM.ammoAmount = 5

// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "flares",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
