ITEM.name = "11.43x23ACP (.45 ACP)"
ITEM.abbreviation = ".45ACP"
ITEM.description = "A carton box that contains %s rounds of 11.43x23ACP (.45 ACP) pistol catridges."
ITEM.model = Model("models/Items/BoxSRounds.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "45acp"
ITEM.ammoAmount = 20

// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "45acp",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
