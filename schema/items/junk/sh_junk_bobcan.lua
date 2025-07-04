ITEM.name = "Empty Bob Soda Can"
ITEM.abbreviation = "Empty Bob"
ITEM.description = "An empty can of Radio Bob, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/willardnetworks/food/bobdrinks_can.mdl"
ITEM.category = "Junk"

ITEM.width = 1
ITEM.height = 1
ITEM.skin = 0

ITEM:MakeSalvageable("crafting_scrap_metal", {
    "blackwatch/entropyzero/crafting/plastic/1.wav",
    "blackwatch/entropyzero/crafting/plastic/2.wav",
    "blackwatch/entropyzero/crafting/plastic/3.wav",
    "blackwatch/entropyzero/crafting/plastic/4.wav",
})

ITEM:MakeStackable(6)
