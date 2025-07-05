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

	-- Randomly select a suitcase type
	local suitcaseTypes = {"suitcase", "suitcase_big", "briefcase"}
	local randomSuitcase = suitcaseTypes[math.random(1, #suitcaseTypes)]
	inventory:Add(randomSuitcase, 1)
	inventory:Add("cid", 1, {
		name = character:GetName(),
		id = id
	})
	
	-- Automatically set the citizen class
	character:JoinClass(CLASS_CITIZEN)
end

FACTION_CITIZEN = FACTION.index

FACTION.spawnPoints = {
    ["Train Station"] = {
        canUse = function(character)
            return true
        end,
        spawns = {
            Vector(-2519, -666, 73),
            Vector(-2433, -666, 73),
            Vector(-2347, -666, 73),
            Vector(-2519, -750, 73),
            Vector(-2433, -750, 73),
            Vector(-2347, -750, 73),
            Vector(-2519, -846, 73),
            Vector(-2433, -846, 73),
            Vector(-2347, -846, 73),
            Vector(-2519, -948, 73),
            Vector(-2433, -948, 73),
            Vector(-2347, -948, 73),
            Vector(-2519, -1058, 73),
            Vector(-2433, -1058, 73),
            Vector(-2347, -1058, 73),
            Vector(-2519, -1201, 73),
            Vector(-2433, -1201, 73),
            Vector(-2347, -1201, 73),
            Vector(-2519, -1312, 73),
            Vector(-2433, -1312, 73),
            Vector(-2347, -1312, 73)
        }
    }
}

FACTION.spawnCam = {
    pos = Vector(8065.552734 10012.942383 -271.574524),
    ang = Angle(-0.454838 -104.517334 0.000000),
    modelPos = Vector(5084, 9535, 2648),
    modelAng = Angle(0, 90, 0),
    modelSequence = {"lineidle01", "lineidle02", "lineidle03", "lineidle04", "idle_angry"},
    fov = 40
}
