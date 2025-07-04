ITEM.name = "9x19mm Parabellum"
ITEM.abbreviation = "9×19PARA"
ITEM.description = "A carton box that contains %s rounds of 9×19mm Parabellum pistol catridges."
ITEM.model = Model("models/Items/357ammo.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "9mm"
ITEM.ammoAmount = 20

ITEM.rarity = "Common"
// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "9mm",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
