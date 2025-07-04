ITEM.name = "Empty Plastic Water Bottle"
ITEM.abbreviation = "Empty Water"
ITEM.description = "An empty plastic water bottle, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/illusion/eftcontainers/waterbottle.mdl"
ITEM.category = "Junk"

ITEM.width = 1
ITEM.height = 1
ITEM.skin = 0

ITEM:MakeSalvageable("crafting_plastic", {
    "blackwatch/entropyzero/crafting/plastic/1.wav",
    "blackwatch/entropyzero/crafting/plastic/2.wav",
    "blackwatch/entropyzero/crafting/plastic/3.wav",
    "blackwatch/entropyzero/crafting/plastic/4.wav",
})

ITEM:MakeStackable(6)
