ITEM.name = "Human Skull"
ITEM.abbreviation = "Skull"
ITEM.description = "A skull of a human being, this has been harvested. Could be crushed for bones."
ITEM.model = "models/gibs/hgibs.mdl"
ITEM.category = "Junk"

ITEM.width = 1
ITEM.height = 1
ITEM.skin = 0

ITEM:MakeSalvageable("crafting_bone", {
    "npc/barnacle/neck_snap1.wav",
    "npc/barnacle/neck_snap2.wav",
})

ITEM:AddContrabandClassification("95Y")
ITEM:MakeIllegal()
ITEM:MakeStackable(1)
