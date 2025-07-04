ITEM.name = "Empty Brown Glass Bottle"
ITEM.abbreviation = "Empty Bottle"
ITEM.description = "An empty brown glass bottle. Quite fragile, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/props/cs_militia/bottle01.mdl"
ITEM.category = "Junk"

ITEM.width = 1
ITEM.height = 1
ITEM.skin = 0

ITEM:MakeSalvageable("crafting_glass", {
    "physics/glass/glass_bottle_break1.wav",
    "physics/glass/glass_bottle_break2.wav",
})

ITEM:MakeStackable(6)
