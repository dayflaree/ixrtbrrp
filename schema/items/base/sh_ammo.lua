ITEM.name = "Ammo Base"
ITEM.model = Model("models/Items/BoxSRounds.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.ammo = "pistol" // type of the ammo
ITEM.ammoAmount = 30 // amount of the ammo
ITEM.description = "A Box that contains %s of Pistol Ammo"
ITEM.category = "Ammunition"
ITEM.useSound = "items/ammo_pickup.wav"

function ITEM:GetDescription()
    local rounds = self:GetData("rounds", self.ammoAmount)
    return Format(self.description, rounds)
end

// On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.use = {
    name = "Load",
    tip = "useTip",
    icon = "icon16/add.png",
    OnRun = function(item)
        local ply = item.player
        local text = item.useText or "Using..."
        local time = item.useTime or 1

        local char = ply:GetCharacter()
        local inventory = char:GetInventory()
        if ( time > 0 ) then
            item.bBeingUsed = true
            
            ply:SetAction(text, time, function()
                item.bBeingUsed = false

                item:Apply(ply, char, inventory)
            end)
        else
            item:Apply(ply, char, inventory)
        end

        return false
    end,
    OnCanRun = function(item)
        local ply = item.player
        if ( timer.Exists("ixAct" .. ply:UniqueID()) ) then
            return false
        end

        if not ( ply:IsOnGround() ) then
            return false
        end

        local ent = item.entity
        if ( IsValid(ent) ) then
            return false
        end

        if ( item.bBeingUsed ) then
            return false
        end

        return true
    end
}

function ITEM:Apply(ply, char, inventory)
    local item = self
    if ( item.bBeingUsed ) then
        return
    end

    local rounds = item:GetData("rounds", item.ammoAmount)
    local quantity = item:GetData("quantity", 1)

    ply:GiveAmmo(rounds, item.ammo)
    ply:EmitSound(item.useSound, 60)

    local x, y
    if ( quantity > 1 ) then
        item:SetData("quantity", quantity - 1)
    else
        x, y = inventory:Remove(item:GetID())
    end

    if ( item.giveItems ) then
        for k, v in ipairs(item.giveItems) do
            if not ( inventory:Add(v, nil, nil, x, y) ) then
                ix.item.Spawn(v, ply)
            end
        end
    end

    item.bBeingUsed = true

    hook.Run("OnItemUsed", item, ply, rounds)
end

// Called after the item is registered into the item tables.
function ITEM:OnRegistered()
    if ( ix.ammo ) then
        ix.ammo.Register(self.ammo)
    end

    if ( !self.isStackable ) then
        self.PaintOver = function(self, item, width, height)
            local rounds = item:GetData("rounds", item.ammoAmount)
            if ( rounds > 0 ) then
                draw.SimpleTextOutlined(rounds, "BlackwatchGenericFont6", width - 5, height - 5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
            end
        end
    end
end

function ITEM:CanTransfer(inventory, newInventory)
    return !self.bBeingUsed
end

ITEM:MakeIllegal()