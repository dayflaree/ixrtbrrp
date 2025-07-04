ITEM.name = "Empty Aluminum Can"
ITEM.abbreviation = "Empty Can"
ITEM.description = "An empty aluminum can with all labels removed, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
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
