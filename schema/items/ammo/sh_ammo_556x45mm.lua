ITEM.name = "5.56x45mm NATO"
ITEM.abbreviation = "5.56×45"
ITEM.description = "A carton box that contains %s rounds of 5.56×45mm NATO rifle catridges."
ITEM.model = Model("models/Items/357ammo.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "556x45"
ITEM.ammoAmount = 30

ITEM.rarity = "Rare"
// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "556x45",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
