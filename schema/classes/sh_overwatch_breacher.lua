CLASS.name = "Overwatch Soldier"
CLASS.faction = FACTION_OTA
CLASS.isDefault = true

function CLASS:OnSet(client)
	local character = client:GetCharacter()

	if (character) then
		character:SetModel("models/zrtbr/combine_soldier.mdl")
		client:SetSkin(1)
	end
end

CLASS_BREACHER = CLASS.index
