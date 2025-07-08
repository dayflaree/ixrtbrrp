FACTION.name = "Citizen"
FACTION.description = "A regular human citizen enslaved by the Combine."
FACTION.color = Color(150, 125, 100, 255)
FACTION.isDefault = true
FACTION.models = {
	"models/zrtbr/humans/group01/female_01.mdl",
	"models/zrtbr/humans/group01/female_02.mdl",
	"models/zrtbr/humans/group01/female_03.mdl",
	"models/zrtbr/humans/group01/female_04.mdl",
	"models/zrtbr/humans/group01/female_06.mdl",
	"models/zrtbr/humans/group01/female_07.mdl",
	"models/zrtbr/humans/group01/male_01.mdl",
	"models/zrtbr/humans/group01/male_02.mdl",
	"models/zrtbr/humans/group01/male_03.mdl",
	"models/zrtbr/humans/group01/male_04.mdl",
	"models/zrtbr/humans/group01/male_05.mdl",
	"models/zrtbr/humans/group01/male_06.mdl",
	"models/zrtbr/humans/group01/male_07.mdl",
	"models/zrtbr/humans/group01/male_08.mdl",
	"models/zrtbr/humans/group01/male_09.mdl"
}

function FACTION:OnCharacterCreated(client, character)
	local id = Schema:ZeroNumber(math.random(1, 99999), 5)
	local inventory = character:GetInventory()

	character:SetData("cid", id)
	inventory:Add("cid", 1, {
		name = character:GetName(),
		id = id
	})

	character:JoinClass(CLASS_CITIZEN)
end

FACTION_CITIZEN = FACTION.index

FACTION.spawnPoints = {
    ["Train Station"] = {
        canUse = function(character)
            return true
        end,
        spawns = {
            Vector(8213.354492, 10424.410156, -226.680939),
            Vector(8212.136719, 10480.503906, -226.154144),
            Vector(8212.227539, 10550.202148, -226.154144),
            Vector(8162.686523, 10550.297852, -226.393738),
            Vector(8145.360352, 10487.794922, -223.311386),
            Vector(8145.592773, 10418.360352, -223.311386),
            Vector(7608.973145, 10508.727539, -224.073044),
            Vector(7662.104004, 10507.812500, -224.073044),
            Vector(7610.401855, 10454.867188, -224.062653),
            Vector(7655.966797, 10454.020508, -224.031799),
            Vector(7609.172363, 10381.345703, -224.031799),
            Vector(7650.589355, 10380.811523, -224.125824),
            Vector(7621.211914, 9775.250000, -223.263016),
            Vector(7663.847656, 9775.455078, -223.263016),
            Vector(7616.336426, 9711.890625, -223.263016),
            Vector(7657.890625, 9711.889648, -223.272247),
            Vector(7617.850098, 9642.005859, -223.272247),
            Vector(7653.137207, 9642.108398, -223.272247),
            Vector(8156.502930, 9678.046875, -224.315292),
            Vector(8114.916992, 9678.050781, -224.315292),
            Vector(8165.800293, 9746.763672, -224.315292),
            Vector(8165.800293, 9746.763672, -224.315292),
            Vector(8165.611816, 9829.329102, -224.315292),
            Vector(8137.934082, 9829.275391, -224.315292),
            Vector(8138.092773, 9759.342773, -224.315292)
        }
    }
}

FACTION.spawnCam = {
    pos = Vector(5049, 9595, 2705),
    ang = Angle(0, -45, 0),
    modelPos = Vector(5084, 9535, 2648),
    modelAng = Angle(0, 90, 0),
    modelSequence = {"lineidle01", "lineidle02", "lineidle03", "lineidle04", "idle_angry"},
    fov = 40
}
