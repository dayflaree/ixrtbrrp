ITEM.name = "PMG-i4 Civil Protection Gas Mask"
ITEM.abbreviation = "CP PMG-i4"
ITEM.description = "A gas mask redesigned by the Combine Overwatch for the use by Civil Protection units. It appears to not have straps and cannot be worn normally."
ITEM.model = Model("models/blackwatch/entropyzero/characters/civilprotection/items/gasmask1.mdl")
ITEM.category = "Clothing"

ITEM.rarity = "Common"

ITEM.clothingCategory = "outfit_mask"
ITEM.bodyGroups = {
    ["CP_Head"] = 5
}

ITEM.overlay = {
    material = {
        "blackwatch/entropyzero/overlays/metro/metromask",
        "blackwatch/entropyzero/overlays/misc/civilprotectionmxmd"
    },
    color = Color(255, 255, 255)
}

ITEM.iconCam = {
    pos = Vector(-6.26, 381.14, 189.04),
    ang = Angle(26.03, 270.95, 0),
    fov = 1.91
}