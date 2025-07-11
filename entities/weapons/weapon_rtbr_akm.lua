AddCSLuaFile()

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "AK-47"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/akm.vmt")
end

SWEP.ViewModel		= "models/weapons/akm/c_akm.mdl"
SWEP.WorldModel		= "models/weapons/akm/w_akm.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 2
SWEP.SlotPos		= 3

SWEP.Primary.Ammo			= "rtbr_akm"
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.ClipMax		= 60 -- for TTT

SWEP.FireRate		= 0.1
SWEP.BulletSpread	= Vector( 0.02618, 0.02618, 0.02618 )
SWEP.BulletDamage	= 8

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "ar2"

SWEP.ShootSound		= "Weapon_AKM.Fire_Player"
SWEP.DeploySound	= "Weapon_AKM.Draw"

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 17/45,
}
SWEP.ReloadTime		= 58/46

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "AKM"
	SWEP.Primary.Ammo	= "SMG1"
	SWEP.Kind			= WEAPON_HEAVY
	SWEP.AmmoEnt		= "item_ammo_smg1_ttt"
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_akm"
	SWEP.AutoSpawnable	= true
end

function SWEP:GetFireRate()
	if self:GetShotsFired() >= 5 then
		return self.FireRate * 1.25
	else
		return self.FireRate
	end
end

function SWEP:ApplyViewKick()
	self:DoMachineGunKick(2, self:GetFireDuration(), 4)
end
