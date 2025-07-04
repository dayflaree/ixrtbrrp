
FACTION.name = "Overwatch Transhuman Arm"
FACTION.description = "A transhuman Overwatch soldier produced by the Combine."
FACTION.color = Color(150, 50, 50, 255)
FACTION.pay = 40
FACTION.models = {"models/zrtbr/combine_soldier.mdl"}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true
FACTION.runSounds = {[0] = "NPC_CombineS.RunFootstepLeft", [1] = "NPC_CombineS.RunFootstepRight"}

function FACTION:GetDefaultName(client)
	return "OTA-ECHO.OWS-" .. Schema:ZeroNumber(math.random(1, 99999), 5), true
end

function FACTION:OnTransferred(character)
	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])
end

function FACTION:OnNameChanged(client, oldValue, value)
	local character = client:GetCharacter()

	if (!Schema:IsCombineRank(oldValue, "OWS") and Schema:IsCombineRank(value, "OWS")) then
		character:JoinClass(CLASS_OWS)
	elseif (!Schema:IsCombineRank(oldValue, "EOW") and Schema:IsCombineRank(value, "EOW")) then
		character:JoinClass(CLASS_EOW)
	end
end

FACTION_OTA = FACTION.index

FACTION.spawnPoints = {
    ["Location"] = {
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
    },
    ["Another Location"] = {
        canUse = function(character)
            return true
        end,
        spawns = {
            Vector(-4913, -467, 161),
            Vector(-4797, -467, 161),
            Vector(-4725, -467, 161),
            Vector(-4653, -467, 161),
            Vector(-4519, -467, 161),
            Vector(-4387, -467, 161),
            Vector(-4913, -968, 161),
            Vector(-4797, -968, 161),
            Vector(-4725, -968, 161),
            Vector(-4653, -968, 161),
            Vector(-4519, -968, 161),
            Vector(-4387, -968, 161)
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