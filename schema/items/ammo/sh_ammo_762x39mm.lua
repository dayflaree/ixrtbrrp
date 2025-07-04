ITEM.name = "7.62x39mm SOVIET"
ITEM.abbreviation = "7.62×39"
ITEM.description = "A carton box that contains %s rounds of 7.62×39 SOVIET rifle catridges."
ITEM.model = Model("models/Items/357ammo.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "762x39"
ITEM.ammoAmount = 30

ITEM.rarity = "Rare"
// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "762x39",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
