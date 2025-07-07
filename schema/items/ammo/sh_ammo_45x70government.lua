ITEM.name = ".45-70 Government"
ITEM.abbreviation = ".45-70 GOVT"
ITEM.description = "A carton box that contains %s rounds of .45-70 Government rifle cartridges."
ITEM.model = Model("models/Items/357ammo.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "45x70Govt"
ITEM.ammoAmount = 30

// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "45x70Govt",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
