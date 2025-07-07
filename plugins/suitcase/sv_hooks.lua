local PLUGIN = PLUGIN

local ALLOWED_WEAPONS = {
    ["ix_hands"] = true,
    ["ix_keys"] = true,
    ["gmod_tool"] = true,
    ["weapon_physgun"] = true,
}

local SUITCASE_SWEP_MAP = {
    ["suitcase"] = "ix_suitcase",
    ["suitcase_big"] = "ix_suitcase_big",
    ["briefcase"] = "ix_briefcase",
}

-- Check if player has a suitcase in their inventory, and return the item and class
function PLUGIN:GetSuitcaseItemAndClass(client)
    if not IsValid(client) or not client:GetCharacter() then
        return nil, nil
    end
    local inventory = client:GetCharacter():GetInventory()
    if not inventory then
        return nil, nil
    end
    for _, item in pairs(inventory:GetItems()) do
        if item.isSuitcase then
            local class = SUITCASE_SWEP_MAP[item.uniqueID]
            if class then
                return item, class
            end
        end
    end
    return nil, nil
end

-- Suitcase storage system
local suitcaseStorage = {}

-- Store items in suitcase when suitcase is transferred to world (dropped)
hook.Add("OnItemTransferred", "SuitcaseStorageDrop", function(item, oldInventory, newInventory)
    if not item.isSuitcase then return end
    
    -- Only trigger when suitcase is being dropped (transferred to world inventory 0)
    if newInventory and newInventory:GetID() != 0 then return end
    
    -- Check if oldInventory exists before trying to get owner
    if not oldInventory then return end
    
    -- Find items in suitcase storage slots and store them
    local player = oldInventory:GetOwner()
    if not player then return end
    
    local character = player:GetCharacter()
    if not character then return end
    
    local playerInv = character:GetInventory()
    if not playerInv then return end
    
    local invWidth, invHeight = playerInv:GetSize()
    local storedItems = {}
    
    -- Check bottom 2 rows for items
    for x = 1, invWidth do
        for y = invHeight - 1, invHeight do
            local slotItem = playerInv:GetItemAt(x, y)
            if slotItem and not slotItem.isSuitcase then
                table.insert(storedItems, {
                    item = slotItem,
                    x = x,
                    y = y
                })
                -- Remove from main inventory using the correct method
                playerInv:Remove(slotItem.id)
            end
        end
    end
    
    -- Store items in suitcase
    if #storedItems > 0 then
        suitcaseStorage[item.id] = storedItems
    end
end)

-- Restore items when suitcase is transferred from world (picked up)
hook.Add("OnItemTransferred", "SuitcaseStoragePickup", function(item, oldInventory, newInventory)
    if not item.isSuitcase then return end
    
    -- Only trigger when suitcase is being picked up (transferred from world inventory 0)
    if oldInventory and oldInventory:GetID() != 0 then return end
    
    local storedItems = suitcaseStorage[item.id]
    if not storedItems then return end
    
    -- Check if newInventory exists before trying to get owner
    if not newInventory then return end
    
    local player = newInventory:GetOwner()
    if not player then return end
    
    local character = player:GetCharacter()
    if not character then return end
    
    local playerInv = character:GetInventory()
    if not playerInv then return end
    
    -- Restore items to their original positions using the correct Add method
    for _, storedData in ipairs(storedItems) do
        local restoredItem = playerInv:Add(storedData.item.uniqueID, 1, storedData.item.data, storedData.x, storedData.y)
    end
    
    -- Clear stored items
    suitcaseStorage[item.id] = nil
end)

-- Force select suitcase SWEP if suitcase is in inventory (any faction)
hook.Add("PlayerPostThink", "SuitcaseForceSWEP", function(client)
    if not IsValid(client) or not client:Alive() then return end
    local item, swepClass = PLUGIN:GetSuitcaseItemAndClass(client)
    if item and swepClass then
        if not client:HasWeapon(swepClass) then
            client:Give(swepClass)
        end
        local active = client:GetActiveWeapon()
        if not IsValid(active) or active:GetClass() ~= swepClass then
            client:SelectWeapon(swepClass)
        end
    else
        -- Remove suitcase SWEPs if not in inventory
        for _, class in pairs(SUITCASE_SWEP_MAP) do
            if client:HasWeapon(class) then
                client:StripWeapon(class)
            end
        end
    end
end)

-- Drop suitcase if player tries to select any other SWEP
hook.Add("PlayerSwitchWeapon", "SuitcaseDropOnSwitch", function(client, oldWeapon, newWeapon)
    -- Don't drop suitcase if this is a newly created character
    if client.ixNewCharacter then return end
    
    local item, swepClass = PLUGIN:GetSuitcaseItemAndClass(client)
    if item and swepClass then
        if newWeapon and newWeapon:GetClass() ~= swepClass then
            -- Drop the suitcase item on the floor (as if using inventory drop)
            local inventory = client:GetCharacter():GetInventory()
            if inventory then
                item:Transfer(nil, nil, nil, client)
                client:Notify("You dropped your suitcase.")
            end
            -- Remove all suitcase SWEPs
            for _, class in pairs(SUITCASE_SWEP_MAP) do
                if client:HasWeapon(class) then
                    client:StripWeapon(class)
                end
            end
        end
    end
end)