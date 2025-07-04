ITEM.name = "Civil Protection Uniform"
ITEM.abbreviation = "CP Uniform"
ITEM.description = "A slash-resistant layered padded black uniform jacket with green pants, black leather gloves, black leather boots and a CP emblazoned grey armband. A uniform tailored by the Combine Overwatch for the use by Civil Protection units."
ITEM.model = Model("models/blackwatch/entropyzero/characters/civilprotection/items/cpuniform.mdl")
ITEM.category = "Clothing"

ITEM.rarity = "Common"

ITEM.clothingCategory = "outfit"
ITEM.replacements = {
    {"/citizens/", "/civilprotection/"}
}

ITEM.iconCam = {
    pos = Vector(0, 0, 200),
    ang = Angle(90, 0, 0),
    fov = 7.16
}

local function UnEquipAllClothing(realItem, ply)
    if ( !IsValid(ply) ) then return end
    
    local char = ply:GetCharacter()
    local inventory = char:GetInventory()

    for item in inventory:Iter() do
        if ( item.isClothing and item:GetData("equip") and item:GetID() != realItem:GetID() ) then
            item:UnEquipClothing(ply)
        end
    end
end

function ITEM:CanEquipClothing(ply)
    local char = ply:GetCharacter()
    if ( !char ) then return false end

    local faction = char:GetFaction()
    if ( faction == FACTION_CP ) then return false end

    if ( !ply:HasWhitelist(FACTION_CP) ) then
        ply:Notify("You are not whitelisted for this faction!")
        return false
    end
end

function ITEM:PreEquip(ply)
    UnEquipAllClothing(self, ply)

    local char = ply:GetCharacter()
    if ( !char ) then return end

    local faction = char:GetFaction()
    if ( faction == FACTION_CP ) then return end

    local class = char:GetClass()
    local rank = char:GetRank()

    char:SetData("oldFaction", faction)
    char:SetData("oldClass", class)
    char:SetData("oldRank", rank)

    char:SetFaction(FACTION_CP)
    char:SetClass(char:GetData("cpClass"))
    char:SetRank(char:GetData("cpRank"))

    char:Save()
end

function ITEM:PreUnEquip(ply)
    UnEquipAllClothing(self, ply)

    local char = ply:GetCharacter()
    if ( !char ) then return end

    local oldFaction = char:GetData("oldFaction")
    if ( oldFaction ) then
        local class = char:GetClass()
        local rank = char:GetRank()

        char:SetData("cpClass", class)
        char:SetData("cpRank", rank)

        char:SetFaction(oldFaction)
        char:SetClass(char:GetData("oldClass"))
        char:SetRank(char:GetData("oldRank"))

        char:SetData("oldFaction", nil)
        char:SetData("oldClass", nil)
        char:SetData("oldRank", nil)

        char:Save()
    end
end