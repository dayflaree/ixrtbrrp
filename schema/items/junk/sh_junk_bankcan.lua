ITEM.name = "Empty Bank Soda Can"
ITEM.abbreviation = "Empty Bank"
ITEM.description = "An empty can of Bank Soda, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/willardnetworks/food/bobdrinks_goodfella.mdl"
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
