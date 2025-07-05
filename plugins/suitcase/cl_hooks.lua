local PLUGIN = PLUGIN

-- Store suitcase entities and item for each player
PLUGIN.suitcaseEntities = {}
PLUGIN.suitcaseItems = {}

-- Create suitcase entity for player's hand
function PLUGIN:CreateSuitcaseOnHand(client, item)
    if not IsValid(client) or not item then return end
    
    -- Remove any existing suitcase first
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
    
    -- Parent to hand bone
    local bone = client:LookupBone("ValveBiped.Bip01_R_Hand")
    if bone then
        suitcase:SetParent(client)
        suitcase:AddEffects(EF_BONEMERGE)
        suitcase:SetBone(bone)
    end
    
    self.suitcaseEntities[client] = suitcase
    self.suitcaseItems[client] = item
end

function PLUGIN:RemoveSuitcaseFromHand(client)
    if not IsValid(client) then return end
    local suitcase = self.suitcaseEntities[client]
    if IsValid(suitcase) then 
        suitcase:Remove() 
    end
    self.suitcaseEntities[client] = nil
    self.suitcaseItems[client] = nil
end

function PLUGIN:UpdatePlayerSuitcase(client)
    if not IsValid(client) or not client:GetCharacter() then 
        self:RemoveSuitcaseFromHand(client) 
        return 
    end
    local inventory = client:GetCharacter():GetInventory()
    if not inventory then 
        self:RemoveSuitcaseFromHand(client) 
        return 
    end
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
    
    -- Only create suitcase if one doesn't exist and player has a suitcase
    if not (IsValid(suitcase) and item) then
        if client:GetCharacter() and client:GetCharacter():GetInventory() then
            local inventory = client:GetCharacter():GetInventory()
            local hasSuitcase = false
            for _, invItem in pairs(inventory:GetItems()) do
                if invItem.isSuitcase then
                    -- Only create if no suitcase exists for this player
                    if not PLUGIN.suitcaseEntities[client] then
                        PLUGIN:CreateSuitcaseOnHand(client, invItem)
                        suitcase = PLUGIN.suitcaseEntities[client]
                        item = PLUGIN.suitcaseItems[client]
                    end
                    hasSuitcase = true
                    break
                end
            end
            -- Remove suitcase if player doesn't have one
            if not hasSuitcase and PLUGIN.suitcaseEntities[client] then
                PLUGIN:RemoveSuitcaseFromHand(client)
                return
            end
        end
    end
    
    if not (IsValid(suitcase) and item) then return end
    
    -- Apply offset and angle if suitcase is parented
    if suitcase:GetParent() then
        local offset = item.handOffset or Vector(4, 0, 0)
        local angle = item.handAngle or Angle(0, 0, 0)
        
        suitcase:SetLocalPos(offset)
        suitcase:SetLocalAngles(angle)
    end
    
    suitcase:SetNoDraw(false)
end)

-- Periodic cleanup and sync
hook.Add("Think", "SuitcaseCleanupInvalid", function()
    -- Clean up invalid entities
    for client, suitcase in pairs(PLUGIN.suitcaseEntities) do
        if not IsValid(client) or not IsValid(suitcase) then
            PLUGIN:RemoveSuitcaseFromHand(client)
        end
    end
    
    -- Periodic sync for all players (less frequent to prevent spam)
    if not PLUGIN.lastSync or CurTime() - PLUGIN.lastSync > 10 then
        for _, client in pairs(player.GetAll()) do
            if IsValid(client) and client:GetCharacter() then
                local inventory = client:GetCharacter():GetInventory()
                if inventory then
                    local hasSuitcase = false
                    for _, item in pairs(inventory:GetItems()) do
                        if item.isSuitcase then
                            hasSuitcase = true
                            -- Only create if no suitcase exists
                            if not PLUGIN.suitcaseEntities[client] then
                                PLUGIN:CreateSuitcaseOnHand(client, item)
                            end
                            break
                        end
                    end
                    -- Remove if no suitcase and one exists
                    if not hasSuitcase and PLUGIN.suitcaseEntities[client] then
                        PLUGIN:RemoveSuitcaseFromHand(client)
                    end
                end
            end
        end
        PLUGIN.lastSync = CurTime()
    end
end)

-- Receive suitcase sync from server
net.Receive("SuitcaseSync", function()
    local client = net.ReadEntity()
    local hasSuitcase = net.ReadBool()
    
    if not IsValid(client) then return end
    
    if hasSuitcase then
        local uniqueID = net.ReadString()
        local model = net.ReadString()
        local offset = net.ReadVector()
        local angle = net.ReadAngle()
        
        -- Create a temporary item object for the suitcase
        local item = {
            uniqueID = uniqueID,
            model = model,
            handModel = model,
            handOffset = offset,
            handAngle = angle,
            isSuitcase = true
        }
        
        PLUGIN:CreateSuitcaseOnHand(client, item)
    else
        PLUGIN:RemoveSuitcaseFromHand(client)
    end
end) 