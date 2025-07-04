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

-- Force select suitcase SWEP if suitcase is in inventory
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

-- Strip weapons when picking up suitcase (DISABLED: do not strip any weapons)
hook.Add("InventoryItemAdded", "SuitcaseStripWeapons", function(inventory, item)
    if not item.isSuitcase then return end
    local client = inventory:GetOwner()
    if not IsValid(client) then return end
    client:Notify("You are now carrying a suitcase.")
end)