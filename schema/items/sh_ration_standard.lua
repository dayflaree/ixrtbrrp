ITEM.name = "Standard CMB Ration Packet"
ITEM.abbreviation = "Standard Ration"
ITEM.description = "A blue large CMB shrink-wrapped packet containing some food and money."
ITEM.model = "models/willardnetworks/rations/wn_new_ration.mdl"
ITEM.category = "Tools"

ITEM.width = 1
ITEM.height = 1
ITEM.skin = 0

ITEM.functions.Open = {
    OnRun = function(itemTable)
        local ply = itemTable.player
        local char = ply:GetCharacter()

        for k, v in ipairs({"food_cmb_eggcaloriepaste", "food_cmb_watersustenancebar", "junk_ration_packet"}) do
            if not ( char:GetInventory():Add(v) ) then
                ix.item.Spawn(v, ply)
            end
        end

        char:GiveMoney(25)
        ply:EmitSound("blackwatch/entropyzero/crafting/fabric/"..math.random(1,6)..".wav", nil, nil, 0.35)
    end
}
