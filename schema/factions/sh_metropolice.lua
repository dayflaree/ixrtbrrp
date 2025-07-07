FACTION.name = "Metropolice"
FACTION.description = "A metropolice unit working as Civil Protection."
FACTION.color = Color(50, 100, 150)
FACTION.models = {
	"models/zrtbr/police.mdl",
	"models/zrtbr/female_police.mdl"
}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true

function FACTION:OnCharacterCreated(client, character)
	character:GetInventory():Add("melee_stunstick", 1)
end

FACTION.gearSounds = {
	"npc/metropolice/gear1.wav",
	"npc/metropolice/gear2.wav", 
	"npc/metropolice/gear3.wav",
	"npc/metropolice/gear4.wav",
	"npc/metropolice/gear5.wav",
	"npc/metropolice/gear6.wav"
}

function FACTION:ModifyPlayerStep(client, data)
	if data.running then
		local gearSound = table.Random(self.gearSounds)
		timer.Simple(0.05, function()
			if IsValid(client) and client:IsRunning() then
				client:EmitSound(gearSound, 60, 100, 0.3, CHAN_AUTO)
			end
		end)
	end
end

FACTION.painSounds = {
	"rtbr/npc/metropolice/pain1.wav",
    "rtbr/npc/metropolice/pain2.wav",
    "rtbr/npc/metropolice/pain3.wav",
    "rtbr/npc/metropolice/pain4.wav"
}

FACTION.fempolicePainSounds = {
	"rtbr/npc/fempolice/pain1.wav",
    "rtbr/npc/fempolice/pain2.wav",
    "rtbr/npc/fempolice/pain3.wav",
    "rtbr/npc/fempolice/pain4.wav"
}

FACTION.elitepolicePainSounds = {
	"rtbr/npc/elitepolice/pain1.wav",
    "rtbr/npc/elitepolice/pain2.wav",
    "rtbr/npc/elitepolice/pain3.wav",
    "rtbr/npc/elitepolice/pain4.wav"
}

FACTION.deathSounds = {
	"rtbr/npc/metropolice/die1.wav",
    "rtbr/npc/metropolice/die2.wav",
    "rtbr/npc/metropolice/die3.wav",
    "rtbr/npc/metropolice/die4.wav"
}

FACTION.fempoliceDeathSounds = {
	"rtbr/npc/fempolice/die1.wav",
    "rtbr/npc/fempolice/die2.wav",
    "rtbr/npc/fempolice/die3.wav",
    "rtbr/npc/fempolice/die4.wav"
}

FACTION.elitepoliceDeathSounds = {
	"rtbr/npc/elitepolice/die1.wav",
    "rtbr/npc/elitepolice/die2.wav",
    "rtbr/npc/elitepolice/die3.wav",
    "rtbr/npc/elitepolice/die4.wav"
}

FACTION.taglines = {
    "Defender",
    "Hero",
    "Jury",
    "King",
    "Line",
    "Patrol",
    "Quick",
    "Roller",
    "Stick",
    "Tap",
    "Union",
    "Victor",
    "Xray",
    "Yellow",
    "Vice"
}

function FACTION:GetDefaultName(client)
    local tagline = string.upper(table.Random(self.taglines))
    return "MPF-00." .. tagline .. "-" .. Schema:ZeroNumber(math.random(1, 99999), 5), true
end

function FACTION:OnTransferred(character)
	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])
end

function FACTION:OnNameChanged(client, oldValue, value)
	local character = client:GetCharacter()

	if (!Schema:IsCombineRank(oldValue, "RCT") and Schema:IsCombineRank(value, "RCT")) then
		character:JoinClass(CLASS_MPR)
	elseif (!Schema:IsCombineRank(oldValue, "OfC") and Schema:IsCombineRank(value, "OfC")) then
		character:SetModel("models/policetrench.mdl")
	elseif (!Schema:IsCombineRank(oldValue, "EpU") and Schema:IsCombineRank(value, "EpU")) then
		character:JoinClass(CLASS_EMP)

		character:SetModel("models/leet_police2.mdl")
	elseif (!Schema:IsCombineRank(oldValue, "DvL") and Schema:IsCombineRank(value, "DvL")) then
		character:SetModel("models/eliteshockcp.mdl")
	elseif (!Schema:IsCombineRank(oldValue, "SeC") and Schema:IsCombineRank(value, "SeC")) then
		character:SetModel("models/sect_police2.mdl")
	elseif (!Schema:IsCombineRank(oldValue, "SCN") and Schema:IsCombineRank(value, "SCN")
	or !Schema:IsCombineRank(oldValue, "SHIELD") and Schema:IsCombineRank(value, "SHIELD")) then
		character:JoinClass(CLASS_MPS)
	end

	if (!Schema:IsCombineRank(oldValue, "GHOST") and Schema:IsCombineRank(value, "GHOST")) then
		character:SetModel("models/eliteghostcp.mdl")
	end
end

FACTION_MPF = FACTION.index

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

hook.Add("GetPlayerPainSound", "MetropolicePainSounds", function(client)
	if IsValid(client) and client:Team() == FACTION_MPF then
		local faction = ix.faction.Get(FACTION_MPF)
		if faction then
			local model = client:GetModel()
			
			-- Only return sounds for specific Metro Police models
			if model == "models/zrtbr/police.mdl" then
				return table.Random(faction.painSounds)
			elseif model == "models/zrtbr/female_police.mdl" then
				return table.Random(faction.fempolicePainSounds)
			elseif model == "models/zrtbr/police_elite.mdl" then
				return table.Random(faction.elitepolicePainSounds)
			end
		end
	end
end)

-- Override Helix's death sound system for Metropolice
hook.Add("GetPlayerDeathSound", "MetropoliceDeathSounds", function(client)
	if IsValid(client) and client:Team() == FACTION_MPF then
		local faction = ix.faction.Get(FACTION_MPF)
		if faction then
			local model = client:GetModel()
			
			-- Only return sounds for specific Metro Police models
			if model == "models/zrtbr/police.mdl" then
				return table.Random(faction.deathSounds)
			elseif model == "models/zrtbr/female_police.mdl" then
				return table.Random(faction.fempoliceDeathSounds)
			elseif model == "models/zrtbr/police_elite.mdl" then
				return table.Random(faction.elitepoliceDeathSounds)
			end
		end
	end
end)