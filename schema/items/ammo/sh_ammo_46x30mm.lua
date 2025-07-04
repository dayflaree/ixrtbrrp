ITEM.name = "4.6x30mm HK"
ITEM.abbreviation = "4.6×30"
ITEM.description = "A carton box that contains %s rounds of 4.6×30mm HK PDW catridges."
ITEM.model = Model("models/Items/357ammo.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "46x30"
ITEM.ammoAmount = 20

ITEM.rarity = "Uncommon"
// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "46x30",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
