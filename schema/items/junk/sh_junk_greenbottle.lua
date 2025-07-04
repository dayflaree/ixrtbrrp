ITEM.name = "Empty Green Glass Bottle"
ITEM.abbreviation = "Empty Bottle"
ITEM.description = "An empty green glass bottle. Quite fragile, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/props_junk/GlassBottle01a.mdl"
ITEM.category = "Junk"

ITEM.width = 1
ITEM.height = 1
ITEM.skin = 0

ITEM:MakeSalvageable("crafting_glass", {
    "physics/glass/glass_bottle_break1.wav",
    "physics/glass/glass_bottle_break2.wav",
})

ITEM:MakeStackable(6)
