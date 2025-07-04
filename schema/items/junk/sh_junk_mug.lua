ITEM.name = "Empty Mug"
ITEM.abbreviation = "Mug"
ITEM.description = "An empty mug commonly found in kitchens. While not exactly junk, it is reusable."
ITEM.model = "models/props_junk/garbage_coffeemug001a.mdl"
ITEM.category = "Junk"

ITEM.width = 1
ITEM.height = 1
ITEM.skin = 0

ITEM:MakeSalvageable("crafting_glass", {
    "physics/glass/glass_cup_break1.wav",
    "physics/glass/glass_cup_break2.wav",
})

ITEM.rarity = "Common"

ITEM:MakeStackable(5)
