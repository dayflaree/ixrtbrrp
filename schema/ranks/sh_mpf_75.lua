RANK.name = "Metropolice Rank 75"
RANK.faction = FACTION_MPF
RANK.isDefault = false

function RANK:OnSet(client)
	local character = client:GetCharacter()
	if character then
		local faction = ix.faction.Get(self.faction)
		local tagline = string.upper(table.Random(faction.taglines))
		local newName = tagline .. ".75:" .. Schema:ZeroNumber(math.random(1, 99), 2)
		character:SetName(newName)
	end
end

RANK_MPF_75 = RANK.index