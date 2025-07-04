ITEM.name = "12x70 Buckshot (12 gauge)"
ITEM.abbreviation = "12 gauge"
ITEM.description = "A red carton box that contains %s shells of 12/70 7mm buckshot shotgun cartridges."
ITEM.model = Model("models/Items/BoxBuckshot.mdl")

ITEM.width = 1
ITEM.height = 1

ITEM.ammo = "12gauge"
ITEM.ammoAmount = 20

ITEM.rarity = "Rare"
// comment: refer to the documentation for AddAmmoType, https://gmodwiki.com/Structures/AmmoData
game.AddAmmoType({
    name = "12gauge",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE
})
