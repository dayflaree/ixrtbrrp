ITEM.name = ".357 Smith & Wesson Magnum"
ITEM.abbreviation = ".357 S&W"
ITEM.description = "A carton box that contains %s rounds of .357 Smith & Wesson Magnum pistol catridges."
ITEM.model = Model("models/Items/357ammo.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "357magnum"
ITEM.ammoAmount = 12

ITEM.rarity = "rare"
// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "357magnum",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
