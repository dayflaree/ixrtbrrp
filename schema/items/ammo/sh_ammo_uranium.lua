ITEM.name = "Uranium"
ITEM.abbreviation = "Uranium"
ITEM.description = "A carton box that contains %s uranium rounds designed for use in specialized weaponry."
ITEM.model = Model("models/transmissions_element120/rotato_small.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "uranium"
ITEM.ammoAmount = 50

// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "uranium",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
