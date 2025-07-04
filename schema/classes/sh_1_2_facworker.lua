CLASS.name = "Factory Worker"
CLASS.faction = FACTION_CITIZEN

CLASS.models = {
	"models/zrtbr/humans/group04/female_01.mdl",
	"models/zrtbr/humans/group04/female_02.mdl",
	"models/zrtbr/humans/group04/female_03.mdl",
	"models/zrtbr/humans/group04/female_04.mdl",
	"models/zrtbr/humans/group04/female_05.mdl",
	"models/zrtbr/humans/group04/female_06.mdl",
	"models/zrtbr/humans/group04/female_07.mdl",
	"models/zrtbr/humans/group04/male_01.mdl",
	"models/zrtbr/humans/group04/male_02.mdl",
	"models/zrtbr/humans/group04/male_03.mdl",
	"models/zrtbr/humans/group04/male_04.mdl",
	"models/zrtbr/humans/group04/male_05.mdl",
	"models/zrtbr/humans/group04/male_06.mdl",
	"models/zrtbr/humans/group04/male_07.mdl",
	"models/zrtbr/humans/group04/male_08.mdl",
	"models/zrtbr/humans/group04/male_09.mdl"
}

function CLASS:CanSwitchTo(client)
	return false
end

function CLASS:OnSet(client)
	local character = client:GetCharacter()
	if not character then return end
	
	if not character:GetData("originalCitizenModel") then
		character:SetData("originalCitizenModel", client:GetModel())
	end
	
	local currentModel = client:GetModel()
	local modelIndex = self:GetModelIndex(currentModel)
	
	if modelIndex then
		client:SetModel(self.models[modelIndex])
	end
end

function CLASS:OnUnset(client)
	local character = client:GetCharacter()
	if not character then return end
	
	local originalModel = character:GetData("originalCitizenModel")
	if originalModel then
		client:SetModel(originalModel)
	end
end

function CLASS:GetModelIndex(citizenModel)
	local modelMap = {
		["models/zrtbr/humans/group01/female_01.mdl"] = 1,  -- group04/female_01.mdl
		["models/zrtbr/humans/group01/female_02.mdl"] = 2,  -- group04/female_02.mdl
		["models/zrtbr/humans/group01/female_03.mdl"] = 3,  -- group04/female_03.mdl
		["models/zrtbr/humans/group01/female_04.mdl"] = 4,  -- group04/female_04.mdl
		["models/zrtbr/humans/group01/female_06.mdl"] = 5,  -- group04/female_06.mdl
		["models/zrtbr/humans/group01/female_07.mdl"] = 6,  -- group04/female_07.mdl
		["models/zrtbr/humans/group01/male_01.mdl"] = 8,    -- group04/male_01.mdl
		["models/zrtbr/humans/group01/male_02.mdl"] = 9,    -- group04/male_02.mdl
		["models/zrtbr/humans/group01/male_03.mdl"] = 10,   -- group04/male_03.mdl
		["models/zrtbr/humans/group01/male_04.mdl"] = 11,   -- group04/male_04.mdl
		["models/zrtbr/humans/group01/male_05.mdl"] = 12,   -- group04/male_05.mdl
		["models/zrtbr/humans/group01/male_06.mdl"] = 13,   -- group04/male_06.mdl
		["models/zrtbr/humans/group01/male_07.mdl"] = 14,   -- group04/male_07.mdl
		["models/zrtbr/humans/group01/male_08.mdl"] = 15,   -- group04/male_08.mdl
		["models/zrtbr/humans/group01/male_09.mdl"] = 16    -- group04/male_09.mdl
	}
	
	return modelMap[citizenModel]
end

CLASS_FACWORKER = CLASS.index