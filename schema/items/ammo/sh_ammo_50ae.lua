ITEM.name = ".50 Action Express"
ITEM.abbreviation = ".50 AE"
ITEM.description = "A carton box that contains %s rounds of .50 Action Express pistol catridges."
ITEM.model = Model("models/Items/357ammo.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "50ae"
ITEM.ammoAmount = 14

ITEM.rarity = "rare"
// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "50ae",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
