
Schema.name = "RAISING THE BAR: REDUX ROLEPLAY"
Schema.author = "dayflare"
Schema.description = "A schema based on Raising the Bar: Redux."

-- Include netstream
ix.util.Include("libs/thirdparty/sh_netstream2.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("cl_schema.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sh_voices.lua")
ix.util.Include("sv_schema.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("meta/sh_player.lua")
ix.util.Include("meta/sv_player.lua")
ix.util.Include("meta/sh_character.lua")

-- Schema flags

ix.flag.Add("S", "Access to the spawn menu.")
ix.flag.Add("s", "Access to the context menu.")

-- Schema config

local config = {
    color = Color(72, 72, 72),
    music = "rtbr/mus/rtbr_human_error.mp3",
    communityURL = "",
    intro = false,
    areaTickTime = 0.5,
    allowBusiness = false,
	allowVoice = true,
    thirdperson = true,
    vignette = false,
    allowGlobalOOC = false,
    chatColor = Color(255, 217, 67),
    chatListenColor = Color(107, 193, 78),
    maxCharacters = 4,
	inventoryHeight = 5,
	animMaxRate = 1,
    walkSpeed = 70,
    runSpeed = 180,
    staminaDrain = 2,
	punchStamina = 5,
    staminaRegeneration = 1.5,
}

for k, v in pairs(config) do
    ix.config.SetDefault(k, v)
    ix.config.ForceSet(k, v)
end

-- Schema playermodels

ix.anim.SetModelClass("models/zrtbr/female_police.mdl", "metrocop")
ix.anim.SetModelClass("models/zrtbr/police.mdl", "metrocop")
ix.anim.SetModelClass("models/zrtbr/police_elite.mdl", "metrocop")
ix.anim.SetModelClass("models/rtbr_retail/police.mdl", "metrocop")
ix.anim.SetModelClass("models/zrtbr/combine_soldier.mdl", "overwatch")
ix.anim.SetModelClass("models/zrtbr/combine_soldier_prison.mdl", "overwatch")
ix.anim.SetModelClass("models/rtbr_retail/combine_soldier.mdl", "overwatch")

function Schema:ZeroNumber(number, length)
	local amount = math.max(0, length - string.len(number))
	return string.rep("0", amount)..tostring(number)
end

function Schema:IsCombineRank(text, rank)
	return string.find(text, "[%D+]"..rank.."[%D+]")
end

do
	local CLASS = {}
	CLASS.color = Color(150, 100, 100)
	CLASS.format = "Dispatch broadcasts \"%s\""

	function CLASS:CanSay(speaker, text)
		if (!speaker:IsDispatch()) then
			speaker:NotifyLocalized("notAllowed")

			return false
		end
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(self.color, string.format(self.format, text))
	end

	ix.chat.Register("dispatch", CLASS)
end

do
	local CLASS = {}
	CLASS.color = Color(75, 150, 50)
	CLASS.format = "%s radios in \"%s\""

	function CLASS:CanHear(speaker, listener)
		local character = listener:GetCharacter()
		local inventory = character:GetInventory()
		local bHasRadio = false

		for k, v in pairs(inventory:GetItemsByUniqueID("handheld_radio", true)) do
			if (v:GetData("enabled", false) and speaker:GetCharacter():GetData("frequency") == character:GetData("frequency")) then
				bHasRadio = true
				break
			end
		end

		return bHasRadio
	end

	function CLASS:OnChatAdd(speaker, text)
		text = speaker:IsCombine() and string.format("<:: %s ::>", text) or text
		chat.AddText(self.color, string.format(self.format, speaker:Name(), text))
	end

	ix.chat.Register("radio", CLASS)
end

do
	local CLASS = {}
	CLASS.color = Color(255, 255, 175)
	CLASS.format = "%s radios in \"%s\""

	function CLASS:GetColor(speaker, text)
		if (LocalPlayer():GetEyeTrace().Entity == speaker) then
			return Color(175, 255, 175)
		end

		return self.color
	end

	function CLASS:CanHear(speaker, listener)
		if (ix.chat.classes.radio:CanHear(speaker, listener)) then
			return false
		end

		local chatRange = ix.config.Get("chatRange", 280)

		return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (chatRange * chatRange)
	end

	function CLASS:OnChatAdd(speaker, text)
		text = speaker:IsCombine() and string.format("<:: %s ::>", text) or text
		chat.AddText(self.color, string.format(self.format, speaker:Name(), text))
	end

	ix.chat.Register("radio_eavesdrop", CLASS)
end

do
	local CLASS = {}
	CLASS.color = Color(175, 125, 100)
	CLASS.format = "%s requests \"%s\""

	function CLASS:CanHear(speaker, listener)
		return listener:IsCombine() or speaker:Team() == FACTION_ADMIN
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(self.color, string.format(self.format, speaker:Name(), text))
	end

	ix.chat.Register("request", CLASS)
end

do
	local CLASS = {}
	CLASS.color = Color(175, 125, 100)
	CLASS.format = "%s requests \"%s\""

	function CLASS:CanHear(speaker, listener)
		if (ix.chat.classes.request:CanHear(speaker, listener)) then
			return false
		end

		local chatRange = ix.config.Get("chatRange", 280)

		return (speaker:Team() == FACTION_CITIZEN and listener:Team() == FACTION_CITIZEN)
		and (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (chatRange * chatRange)
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(self.color, string.format(self.format, speaker:Name(), text))
	end

	ix.chat.Register("request_eavesdrop", CLASS)
end

do
	local CLASS = {}
	CLASS.color = Color(150, 125, 175)
	CLASS.format = "%s broadcasts \"%s\""

	function CLASS:CanSay(speaker, text)
		if (speaker:Team() != FACTION_ADMIN) then
			speaker:NotifyLocalized("notAllowed")

			return false
		end
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(self.color, string.format(self.format, speaker:Name(), text))
	end

	ix.chat.Register("broadcast", CLASS)
end