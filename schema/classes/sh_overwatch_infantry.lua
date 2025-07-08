CLASS.name = "Overwatch Infantry"
CLASS.faction = FACTION_OTA
CLASS.isDefault = true

function CLASS:OnSet(client)
	local character = client:GetCharacter()

	if (character) then
		character:SetModel("models/zrtbr/combine_soldier.mdl")
		client:SetSkin(0)
	end
end

CLASS_INFANTRY = CLASS.index
