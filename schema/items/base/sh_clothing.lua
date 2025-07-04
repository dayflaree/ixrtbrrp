ITEM.name = "Clothing"
ITEM.description = "A generic piece of clothing."
ITEM.model = Model("models/props_c17/briefcase001a.mdl")
ITEM.category = "Clothing"
ITEM.width = 1
ITEM.height = 1

ITEM.isClothing = true
ITEM.clothingCategory = "head"

ITEM.pacData = {}

if ( CLIENT ) then
    function ITEM:PaintOver(item, w, h)
    end

    function ITEM:PopulateTooltip(tooltip)
        if ( self:GetData("equip") ) then
            local name = tooltip:GetRow("name")
            name:SetBackgroundColor(derma.GetColor("Success", tooltip))
        end
    end
end

function ITEM:EquipClothing(ply)
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    if ( self.PreEquip ) then
        self:PreEquip(ply)
    end

    hook.Run("PrePlayerEquippedClothing", ply, item)

    self:SetData("equip", true)

    if ( isfunction(self.OnGetReplacement) ) then
        char:SetData("oldModel" .. self.clothingCategory,
            char:GetData("oldModel" .. self.clothingCategory, ply:GetModel()))
        char:SetModel(self:OnGetReplacement())
    elseif ( self.replacement or self.replacements ) then
        char:SetData("oldModel" .. self.clothingCategory,
            char:GetData("oldModel" .. self.clothingCategory, ply:GetModel()))

        if ( istable(self.replacements) ) then
            if (#self.replacements == 2 and isstring(self.replacements[1])) then
                char:SetModel(ply:GetModel():gsub(self.replacements[1], self.replacements[2]))
            else
                for _, v in ipairs(self.replacements) do
                    char:SetModel(ply:GetModel():gsub(v[1], v[2]))
                end
            end
        else
            char:SetModel(self.replacement or self.replacements)
        end
    end

    if ( self.subMaterials ) then
        for k, value in pairs(self.subMaterials) do
            ply:SetSubMaterial(k - 1, value)
        end
    end

    if ( self.bodyGroups ) then
        local groups = char:GetData("groups", {})

        for k, value in pairs(self.bodyGroups) do
            local index = ply:FindBodygroupByName(k)

            if ( index > -1 ) then
                groups[index] = value
                char:SetData("groups", groups)
                ply:SetBodygroup(index, value)
            end
        end
    end

    if ( self:GetData("cosmeticData", self.cosmeticData) and COSMETIC ) then
        if ( self.PreCosmeticMake ) then
            self:PreCosmeticMake(ply)
        end

        COSMETIC:MakeCosmetic(ply, self.cosmeticData.bone, self:GetData("cosmeticData", self.cosmeticData), self.clothingCategory)
    end

    ply:AddPart(self.uniqueID, self)

    if ( self.PostEquip ) then
        self:PostEquip(ply)
    end

    hook.Run("OnPlayerEquippedClothing", ply, self)
end

function ITEM:UnEquipClothing(ply)
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    if ( self.PreUnEquip ) then
        self:PreUnEquip(ply)
    end

    hook.Run("PrePlayerUnequippedClothing", ply, self)

    self:SetData("equip", false)

    // restore the original player model
    if ( char:GetData("oldModel" .. self.clothingCategory) ) then
        char:SetModel(char:GetData("oldModel" .. self.clothingCategory))
        char:SetData("oldModel" .. self.clothingCategory, nil)
    end

    if ( self.bodyGroups ) then
        local char = ply:GetCharacter()
        local groups = char:GetData("groups", {})

        for k in pairs(self.bodyGroups) do
            local index = ply:FindBodygroupByName(k)

            if ( index > -1 ) then
                groups[index] = 0
                char:SetData("groups", groups)
                ply:SetBodygroup(index, 0)
            end
        end
    end

    if ( self.subMaterials ) then
        for k in pairs(self.subMaterials) do
            ply:SetSubMaterial(k - 1, "")
        end
    end

    if ( self:GetData("cosmeticData", self.cosmeticData) and COSMETIC ) then
        if ( self.PreCosmeticRemove ) then
            self:PreCosmeticRemove(ply)
        end

        COSMETIC:RemoveCosmetic(ply, self.clothingCategory)
    end

    ply:RemovePart(self.uniqueID)

    if ( self.PostUnEquip ) then
        self:PostUnEquip(ply)
    end

    hook.Run("OnPlayerUnequippedClothing", ply, self)
end

ITEM:Hook("drop", function(item)
    if ( item:GetData("equip", false) ) then
        item:UnEquipClothing(item:GetOwner())
    end
end)

ITEM.functions.EquipUn = {
    name = "Un-equip",
    tip = "equipTip",
    icon = "icon16/cross.png",
    OnRun = function(item)
        local ply = item.player
        if ( IsValid(ply) ) then
            local oldVel = ply:GetVelocity()
            local oldMoveType = ply:GetMoveType()

            local oldVel = ply:GetVelocity()

            ply:EmitSound("Minerva.Item.UnEquip")
            ply:SetAction("Un-equipping...", item.unEquipTime or 1, function()
                if not ( item ) then
                    return
                end

                item:UnEquipClothing(ply)

                if ( item.OnUnEquip ) then
                    item:OnUnEquip(ply)
                end
            end)
        else
            item:SetData("equip", false)

            if ( item.OnUnEquip ) then
                item:OnUnEquip()
            end
        end

        return false
    end,
    OnCanRun = function(item)
        local ply = item.player

        if ( timer.Exists("ixAct"..ply:UniqueID()) ) then
            return false
        end

        if not ( ply:IsOnGround() ) then
            return false
        end

        return not IsValid(item.entity) and IsValid(ply) and item:GetData("equip") == true and hook.Run("CanPlayerUnequipItem", ply, item) != false and item:CanUnequipClothing(ply)
    end
}

ITEM.functions.Equip = {
    name = "Equip",
    tip = "equipTip",
    icon = "icon16/tick.png",
    OnRun = function(item, creationClient)
        local ply = item.player or creationClient
        local char = ply:GetCharacter()
        if ( item.allowedFactions and !item.allowedFactions[char:GetFaction()] ) then
            ply:Notify("You are not in the correct faction to equip this clothing.")
            return false
        end

        if ( item.allowedModels and !item.allowedModels[ply:GetModel()] ) then
            ply:Notify("Your model is not allowed to equip this clothing.")
            return false
        end

        for itemIterated, x, y in char:GetInventory():Iter() do
            if ( itemIterated.id != item.id ) then
                local itemTable = ix.item.instances[itemIterated.id]

                if ( ix.util.StringMatches(itemIterated.clothingCategory, item.clothingCategory) and itemTable:GetData("equip") ) then
                    ply:NotifyLocalized(item.equippedNotify or "clothingAlreadyEquipped")
                    return false
                end
            end
        end

        local oldVel = ply:GetVelocity()
        local oldMoveType = ply:GetMoveType()

        ply:EmitSound("Minerva.Item.Equip")
        ply:SetAction("Equipping...", item.equipTime or 1, function()
            if not ( item ) then
                return
            end

            item:EquipClothing(ply)

            if ( item.OnEquip ) then
                item:OnEquip(ply)
            end

            hook.Run("OnPlayerEquippedClothing", ply, item)
        end)

        return false
    end,
    OnCanRun = function(item)
        local ply = item.player

        if ( timer.Exists("ixAct"..ply:UniqueID()) ) then
            return false
        end

        if not ( ply:IsOnGround() ) then
            return false
        end

        return not IsValid(item.entity) and IsValid(ply) and item:GetData("equip") != true and hook.Run("CanPlayerEquipItem", ply, item) != false and item:CanEquipClothing(ply)
    end
}

function ITEM:OnRemoved()
    if ( self.invID != 0 and self:GetData("equip") ) then
        self.player = self:GetOwner()
        self:UnEquipClothing(self.player)

        if ( self.OnUnEquip ) then
            self:OnUnEquip()
        end

        self.player = nil
    end
end

function ITEM:CanEquipClothing(ply)
    return true
end

function ITEM:CanUnequipClothing(ply)
    return true
end

function ITEM:CanTransfer(inventory, newInventory)
    return !self:GetData("equip", false) and inventory != newInventory
end