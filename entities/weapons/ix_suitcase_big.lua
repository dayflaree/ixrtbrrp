SWEP.PrintName = "Big Suitcase"
SWEP.Author = "Riggs"
SWEP.Instructions = "You are carrying a big suitcase."
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Category = "Suitcase"

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = "models/props_c17/SuitCase001a.mdl"
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "normal"

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    return false
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:DrawWorldModel()
    self:DrawModel()
end 