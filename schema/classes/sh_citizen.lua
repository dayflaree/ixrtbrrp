CLASS.name = "Citizen"
CLASS.faction = FACTION_CITIZEN
CLASS.isDefault = true

function CLASS:OnSet(client)
	local character = client:GetCharacter()
	if not character then return end
	
	local originalModel = character:GetData("originalCitizenModel")
	if originalModel then
		client:SetModel(originalModel)
		character:SetData("originalCitizenModel", nil)
	end
end

CLASS_CITIZEN = CLASS.index