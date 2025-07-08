RANK.name = "Metropolice Rank Leader"
RANK.faction = FACTION_MPF
RANK.isDefault = false

function RANK:OnSet(client)
	local character = client:GetCharacter()
	if character then
		local faction = ix.faction.Get(self.faction)
		local tagline = string.upper(table.Random(faction.taglines))
		local newName = tagline .. ".RL:" .. Schema:ZeroNumber(math.random(1, 99), 2)
		character:SetName(newName)
	end
end

RANK_MPF_RL = RANK.index