AddCSLuaFile()

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "S&W Model 66"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/357snubnose.vmt")
end

SWEP.ViewModel		= "models/weapons/357snubnose/c_357.mdl"
SWEP.WorldModel		= "models/weapons/357snubnose/w_357.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 1
SWEP.SlotPos		= 2

SWEP.Primary.Ammo			= "357"
SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.ClipMax		= 12 -- for TTT

SWEP.FireRate		= 0.4
SWEP.BulletSpread	= Vector( 0.001, 0.001, 0.001 )
SWEP.BulletSpreadSustained1 = Vector( 0.01, 0.01, 0.01 )
SWEP.BulletSpreadSustained2 = Vector( 0.05, 0.05, 0.05 )
SWEP.BulletSpreadSustained3 = Vector( 0.1, 0.1, 0.1 )
SWEP.BulletDamage	= 50

SWEP.CrosshairX		= 0.25
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "revolver"

SWEP.DeploySound		= Sound("Weapon_357.Draw")
SWEP.ShootSound 		= Sound("Weapon_357.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 16/28,
	[ACT_VM_RELOAD]	= 2.7,
}
SWEP.ReloadTime		= 45/27

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Python"
	SWEP.Kind			= WEAPON_PISTOL
	SWEP.AmmoEnt		= "item_ammo_revolver_ttt"
	SWEP.Primary.Ammo	= "AlyxGun" -- why
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_357"
	SWEP.AutoSpawnable	= true
end

function SWEP:GetPrimaryAttackActivity()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:GetBulletSpread()
	if self:GetShotsFired() <= 0 then
		return self.BulletSpread
	elseif self:GetShotsFired() <= 1 then
		return self.BulletSpreadSustained1
	elseif self:GetShotsFired() <= 2 then
		return self.BulletSpreadSustained2
	elseif self:GetShotsFired() >= 3 then
		return self.BulletSpreadSustained3
	else
		return self.BulletSpreadSustained3
	end

	return self.BulletSpread
end

function SWEP:ApplyViewKick()
	local owner = self:GetOwner()
	if (IsFirstTimePredicted() and CLIENT) or (game.SinglePlayer() and SERVER) then
		local angs = owner:EyeAngles()

		angs = angs + Angle(util.SharedRandom(self:GetClass(), -2, 2),
							util.SharedRandom(self:GetClass(), -2, 2),
							0)

		owner:SetEyeAngles(angs)
	end

	local punch = Angle()
	punch.x = -12
	punch.y = util.SharedRandom(self:GetClass(), -4, 4, 0)

	owner:ViewPunch( punch)
end
