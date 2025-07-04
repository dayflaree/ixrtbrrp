local PLUGIN = PLUGIN

function PLUGIN:ShouldSpawnClientRagdoll(ply)
    return false
end

local limbTranslator = {
    [HITGROUP_LEFTLEG] = "left leg",
    [HITGROUP_RIGHTLEG] = "right leg",
    [HITGROUP_LEFTARM] = "left arm",
    [HITGROUP_RIGHTARM] = "right arm",
    [HITGROUP_HEAD] = "head",
    [HITGROUP_CHEST] = "chest",
    [HITGROUP_STOMACH] = "stomach",
    [HITGROUP_GEAR] = "gear",
    [HITGROUP_GENERIC] = "generic"
}

function PLUGIN:DoPlayerDeath(ply, attacker, damageinfo)
    if ( hook.Run("ShouldSpawnPlayerCorpse") == false ) then
        return
    end

    local messages = {}
    if ( IsValid(attacker) and attacker:IsPlayer() ) then
        local wep = attacker:GetActiveWeapon()
        if ( IsValid(wep) ) then
            messages[#messages + 1] = "Weapon used for murder appears to be \"" .. wep:GetPrintName() .. "\"."
        end
    end

    if ( ply:IsOnFire() ) then
        messages[#messages + 1] = "This person seems to have been on fire."
    end

    if ( ply:IsRestricted() or ply:GetData("arrested", false) ) then
        messages[#messages + 1] = "This person seems to have been hand-cuffed."
    end

    if ( damageinfo:IsExplosionDamage() ) then
        messages[#messages + 1] = "There seems to have been an explosion upon the person's death."
    end

    messages[#messages + 1] = "The last place the person's been hit is " .. limbTranslator[ ( ply:LastHitGroup() or HITGROUP_GENERIC ) ] or "unknown"

    local entity = IsValid(ply.ixRagdoll) and ply.ixRagdoll or ply:CreateServerRagdoll()
    entity:RemoveCallOnRemove("fixer")
    entity:SetNetVar("deathCauses", messages)
    entity:CallOnRemove("ixPersistentCorpse", function(ragdoll)
        if ( ragdoll.ixInventory ) then
            ix.storage.Close(ragdoll.ixInventory)
        end

        if ( IsValid(ply) and !ply:Alive() ) then
            ply:SetLocalVar("ragdoll", nil)
        end
    end)

    if ( !ply.ixRagdoll ) then
        entity:SetCollisionGroup(COLLISION_GROUP_WORLD)

        local velocity = ply:GetVelocity() * ix.config.Get("corpseVelocityScale", 1)
        for i = 0, entity:GetPhysicsObjectCount() - 1 do
            local physObj = entity:GetPhysicsObjectNum(i)

            if ( IsValid(physObj) ) then
                physObj:SetVelocity(velocity)

                local index = entity:TranslatePhysBoneToBone(i)
                if ( index ) then
                    local position, angles = ply:GetBonePosition(index)

                    physObj:SetPos(position)
                    physObj:SetAngles(angles)
                end
            end
        end
    end

    ply.ixRagdoll = nil
    entity.ixPlayer = nil

    hook.Run("OnPlayerCorpseCreated", ply, entity)
end

local randomizeItems = {
    --[FACTION_CP] = true,
    --[FACTION_CONSCRIPT] = true,
    --[FACTION_OTA] = true,
}

function PLUGIN:OnPlayerCorpseCreated(ply, entity)
    local velocity = ply:GetVelocity()

    local char = ply:GetCharacter()
    if ( !char ) then return end

    local charInventory = char:GetInventory()
    if ( !charInventory ) then return end

    charInventory:UnEquipAll()

    local bRandomItems = false
    local factionData = ix.faction.Get(char:GetFaction())
    if ( factionData ) then
        if ( factionData.OnCorpseCreated ) then
            factionData:OnCorpseCreated(ply, entity)
        end

        if ( factionData.bRandomizeItems ) then
            bRandomItems = true
        end
    end

    if ( !self.factionInventoryBlacklist[char:GetFaction()] ) then
        local width, height = charInventory:GetSize()
        local inventory = ix.inventory.Create(width, height, os.time())
        inventory.noSave = true

        for v in charInventory:Iter() do
            // if the item is a combine item and the faction is a combine item faction, we'll remove the item from the inventory
            if ( v.bCombineItem and factionData.bCombineItems ) then
                charInventory:Remove(v:GetID())
                continue
            end

            // same for human
            if ( v.bHumanItem and factionData.bHumanItems ) then
                charInventory:Remove(v:GetID())
                continue
            end

            if ( v.base == "base_weapons" and v:GetData("equip") ) then
                ix.item.Spawn(v.uniqueID, ply:GetShootPos() + Vector(math.random(-16, 16), math.random(-16, 16), 0), function(item, itemEntity)
                    item:SetData("ammo", item:GetData("ammo", 0))
                    itemEntity:SetVelocity(velocity)
                end)

                continue
            end

            if ( bRandomItems ) then
                if ( math.random(1, 100) <= 50 ) then
                    charInventory:Remove(v:GetID())
                    continue
                end
            end

            v:Transfer(inventory:GetID(), v.gridX, v.gridY)
        end

        entity.ixInventory = inventory
    end

    timer.Simple(ix.config.Get("corpseDecayTime", 60), function()
        if ( IsValid(entity) ) then
            entity:Remove()
        end
    end)

    local faction = char:GetFaction()
    if ( self.factionDrops[faction] ) then
        local items = {}

        local callback = self.factionDropCallbacks[faction]
        if ( callback ) then
            for k, v in pairs(callback) do
                local can, percentage = v(ply)

                if ( can ) then
                    table.insert(items, { k, percentage })
                end
            end
        end

        local maxDrops = self.maxFactionDrops[faction]
        if ( maxDrops ) then
            for i = 1, maxDrops do
                local item = items[math.random(#items)]
                if ( item ) then
                    local itemID, chance = item[1], item[2]
                    if ( math.random(1, 100) <= chance ) then
                        ix.item.Spawn(itemID, ply:GetShootPos() + Vector(math.random(-16, 16), math.random(-16, 16), 0), function(item, itemEntity)
                            itemEntity:SetVelocity(velocity)
                        end)
                    end
                end
            end
        else
            for k, v in ipairs(items) do
                local itemID, chance = v[1], v[2]
                if ( math.random(1, 100) <= chance ) then
                    ix.item.Spawn(itemID, ply:GetShootPos() + Vector(math.random(-16, 16), math.random(-16, 16), 0), function(item, itemEntity)
                        itemEntity:SetVelocity(velocity)
                    end)
                end
            end
        end
    end
end

function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
    if ( self.npcDrops[npc:GetClass()] ) then
        for itemID, chance in pairs(self.npcDrops[npc:GetClass()]) do
            if ( math.random(1, 100) <= chance ) then
                ix.item.Spawn(itemID, npc:GetPos() + Vector(math.random(-16, 16), math.random(-16, 16), 0))
            end
        end
    end
end

local nextUse = 0
function PLUGIN:PlayerUse(ply, entity)
    if ( nextUse > CurTime() ) then return end
    nextUse = CurTime() + 1

    // old jury code from minerva version 0.5b
    /*
    if ( entity:GetClass() == "prop_ragdoll" ) then
        if ( !ply:KeyDown(IN_WALK) ) then
            if ( entity.ixInventory and !ix.storage.InUse(entity.ixInventory) ) then
                ix.storage.Open(ply, entity.ixInventory, {
                    entity = entity,
                    name = "Corpse",
                    searchText = "Searching...",
                    searchTime = ix.config.Get("corpseSearchTime", 2),
                })
            end
        else
            local char = ply:GetCharacter()
            local class = char:GetClass() or 0

            if ( !char or char:GetFaction() != FACTION_CP or class != CLASS_CP_JURY ) then
                return
            end

            ply:SetAction("Investigating...", 5)
            ply:DoStaredAction(entity, function()
                local char = ply:GetCharacter()
                if ( char and char:GetFaction() == FACTION_CP and ( char:GetClass() or 0 ) == CLASS_CP_JURY ) then
                    for k, v in ipairs(entity:GetNetVar("deathCauses", {})) do
                        ply:ChatNotify(v)
                    end
                end
            end, 5, function()
                ply:SetAction()
            end)

        end

        return false
    end
    */
end

function PLUGIN:PlayerSpawn(ply)
    ply:SetLocalVar("ragdoll", nil)
end