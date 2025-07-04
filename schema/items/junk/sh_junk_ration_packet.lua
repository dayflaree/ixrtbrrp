ITEM.name = "Empty Ration Packet"
ITEM.abbreviation = "Empty Ration"
ITEM.description = "A large empty ration packet with one of the ends open, could be useful to crafters or to recycle away like a good person would."
ITEM.model = "models/willardnetworks/rations/wn_new_ration.mdl"
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

ITEM:MakeStackable(5)
