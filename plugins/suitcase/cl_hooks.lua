local PLUGIN = PLUGIN

-- Store suitcase entities and item for each player
PLUGIN.suitcaseEntities = {}
PLUGIN.suitcaseItems = {}

-- Create suitcase entity for player's hand
function PLUGIN:CreateSuitcaseOnHand(client, item)
    if not IsValid(client) or not item then return end
    self:RemoveSuitcaseFromHand(client)
    local suitcase = ClientsideModel(item.handModel or item.model, RENDERGROUP_OPAQUE)
    if not IsValid(suitcase) then return end
    suitcase:SetNoDraw(false)
    suitcase:SetModel(item.handModel or item.model)
    suitcase:SetRenderMode(RENDERMODE_NORMAL)
    suitcase:SetColor(Color(255,255,255,255))
    suitcase:SetMaterial("")
    suitcase:SetSkin(0)
    suitcase:SetBodygroup(0,0)
    suitcase:SetParent(nil)
    self.suitcaseEntities[client] = suitcase
    self.suitcaseItems[client] = item
end

function PLUGIN:RemoveSuitcaseFromHand(client)
    if not IsValid(client) then return end
    local suitcase = self.suitcaseEntities[client]
    if IsValid(suitcase) then suitcase:Remove() end
    self.suitcaseEntities[client] = nil
    self.suitcaseItems[client] = nil
end

function PLUGIN:UpdatePlayerSuitcase(client)
    if not IsValid(client) or not client:GetCharacter() then self:RemoveSuitcaseFromHand(client) return end
    local inventory = client:GetCharacter():GetInventory()
    if not inventory then self:RemoveSuitcaseFromHand(client) return end
    for _, item in pairs(inventory:GetItems()) do
        if item.isSuitcase then
            self:CreateSuitcaseOnHand(client, item)
            return
        end
    end
    self:RemoveSuitcaseFromHand(client)
end

hook.Add("InventoryItemAdded", "SuitcaseVisualUpdate", function(inventory, item)
    if not item.isSuitcase then return end
    local client = inventory:GetOwner()
    if IsValid(client) then PLUGIN:UpdatePlayerSuitcase(client) end
end)

hook.Add("InventoryItemRemoved", "SuitcaseVisualUpdate", function(inventory, item)
    if not item.isSuitcase then return end
    local client = inventory:GetOwner()
    if IsValid(client) then PLUGIN:UpdatePlayerSuitcase(client) end
end)

hook.Add("PlayerSpawn", "SuitcaseVisualSpawn", function(client)
    timer.Simple(0.1, function()
        if IsValid(client) then PLUGIN:UpdatePlayerSuitcase(client) end
    end)
end)

hook.Add("PlayerDisconnected", "SuitcaseVisualCleanup", function(client)
    PLUGIN:RemoveSuitcaseFromHand(client)
end)

-- Manual positioning every frame
hook.Add("PostPlayerDraw", "SuitcaseDrawToHand", function(client)
    local suitcase = PLUGIN.suitcaseEntities[client]
    local item = PLUGIN.suitcaseItems[client]
    if not (IsValid(suitcase) and item) then return end
    local bone = client:LookupBone("ValveBiped.Bip01_R_Hand")
    if not bone then suitcase:SetNoDraw(true) return end
    local pos, ang = client:GetBonePosition(bone)
    if not pos or not ang then suitcase:SetNoDraw(true) return end
    -- Offset and angle from item definition
    local offset = item.handOffset or Vector(4, 0, 0)
    local angle = item.handAngle or Angle(0, 0, 0)
    -- Apply offset and angle
    local newAng = Angle(ang)
    newAng:RotateAroundAxis(newAng:Right(), angle.p)
    newAng:RotateAroundAxis(newAng:Up(), angle.y)
    newAng:RotateAroundAxis(newAng:Forward(), angle.r)
    local newPos = pos + newAng:Forward() * offset.x + newAng:Right() * offset.y + newAng:Up() * offset.z
    suitcase:SetPos(newPos)
    suitcase:SetAngles(newAng)
    suitcase:SetNoDraw(false)
end)

-- Periodic cleanup
hook.Add("Think", "SuitcaseCleanupInvalid", function()
    for client, suitcase in pairs(PLUGIN.suitcaseEntities) do
        if not IsValid(client) or not IsValid(suitcase) then
            PLUGIN:RemoveSuitcaseFromHand(client)
        end
    end
end) 