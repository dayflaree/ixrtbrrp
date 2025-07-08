FACTION.name = "Overwatch Transhuman Arm"
FACTION.description = "A transhuman Overwatch soldier produced by the Combine."
FACTION.color = Color(150, 50, 50, 255)
FACTION.models = {"models/zrtbr/combine_soldier.mdl"}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true

FACTION.gearSounds = {
	"npc/combine_soldier/gear1.wav",
    "npc/combine_soldier/gear2.wav",
    "npc/combine_soldier/gear3.wav",
    "npc/combine_soldier/gear4.wav",
    "npc/combine_soldier/gear5.wav",
    "npc/combine_soldier/gear6.wav"
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
	"rtbr/npc/combine_soldier/pain1.wav",
    "rtbr/npc/combine_soldier/pain2.wav",
    "rtbr/npc/combine_soldier/pain3.wav"
}

FACTION.deathSounds = {
	"rtbr/npc/combine_soldier/die1.wav",
    "rtbr/npc/combine_soldier/die2.wav",
    "rtbr/npc/combine_soldier/die3.wav"
}

FACTION.taglines = {
    "Leader",
    "Flash",
    "Ranger",
    "Hunter",
    "Blade",
    "Hammer",
    "Sweeper",
    "Swift",
    "Fist",
    "Sword",
    "Savage",
    "Tracker",
    "Slash",
    "Razor",
    "Stab",
    "Spear",
    "Striker",
    "Dagger"
}

function FACTION:GetDefaultName(client)
    local tagline = string.upper(table.Random(self.taglines))
    return tagline .. ":" .. Schema:ZeroNumber(math.random(1, 99), 2), true
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

-- Override Helix's pain sound system for OTA
hook.Add("GetPlayerPainSound", "OTAPainSounds", function(client)
	if IsValid(client) and client:Team() == FACTION_OTA then
		local faction = ix.faction.Get(FACTION_OTA)
		if faction and faction.painSounds then
			return table.Random(faction.painSounds)
		end
	end
end)

-- Override Helix's death sound system for OTA
hook.Add("PlayerDeathSound", "OTADeathSounds", function(client)
	if IsValid(client) and client:Team() == FACTION_OTA then
		local faction = ix.faction.Get(FACTION_OTA)
		if faction and faction.deathSounds then
			client:EmitSound(table.Random(faction.deathSounds), 80, 100, 1, CHAN_VOICE)
			return false -- Prevent default death sound
		end
	end
end)