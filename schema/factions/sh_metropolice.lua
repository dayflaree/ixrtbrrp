FACTION.name = "Metropolice"
FACTION.description = "A metropolice unit working as Civil Protection."
FACTION.color = Color(50, 100, 150)
FACTION.models = {
	"models/zrtbr/police.mdl",
	"models/zrtbr/female_police.mdl"
}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true

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
    return tagline .. ".00:" .. Schema:ZeroNumber(math.random(1, 99), 2), true
end

function FACTION:OnTransferred(character)
	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])
end

function FACTION:OnSpawn(client)
	local character = client:GetCharacter()
	if character then
		character:SetName(self:GetDefaultName())
	end
end

FACTION_MPF = FACTION.index

FACTION.spawnPoints = {
    ["Location"] = {
        canUse = function(character)
            return true
        end,
        spawns = {
            Vector(7813.733887, 9028.799805, -246.517609)
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