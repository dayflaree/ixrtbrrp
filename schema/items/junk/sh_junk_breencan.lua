ITEM.name = "Empty Breen's Water Can"
ITEM.abbreviation = "Empty >B"
ITEM.description = "An empty can of Breen's water, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/props_junk/PopCan01a.mdl"
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
