AddCSLuaFile()

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "AK-104"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/akmcarbine.vmt")
end

SWEP.ViewModel		= "models/weapons/akmcarbine/c_akm.mdl"
SWEP.WorldModel		= "models/weapons/akmcarbine/w_akm.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 2
SWEP.SlotPos		= 3

SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.ClipMax		= 40 -- for TTT

SWEP.FireRate		= 0.09
SWEP.BulletSpread	= Vector( 0.03489, 0.03489, 0.03489 )
SWEP.BulletDamage	= 7

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.25
SWEP.HoldType		= "ar2"

SWEP.ShootSound		= "Weapon_AKMCarbine.Fire_Player"
SWEP.DeploySound	= "Weapon_AKM.Draw"

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 12/45,
}
SWEP.ReloadTime		= 52/46

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "AKM Carbine"
	SWEP.Primary.Ammo	= "SMG1"
	SWEP.Kind			= WEAPON_HEAVY
	SWEP.AmmoEnt		= "item_ammo_smg1_ttt"
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_akm"
	SWEP.AutoSpawnable	= true
end

function SWEP:GetBulletSpread()
	if self:GetShotsFired() <= 1 then
		return self.BulletSpread * 0.2
	elseif self:GetShotsFired() <= 5 and self:GetShotsFired() > 1 then
		return self.BulletSpread * 0.6
	else
		return self.BulletSpread
	end
	
	return self.BulletSpread
end

function SWEP:ApplyViewKick()
	local vertical_kick = 2.0
	local slide_limit	= 4.0

	self:DoMachineGunKick(vertical_kick, vertical_kick + self:GetFireDuration() * 0.5, slide_limit)
end
