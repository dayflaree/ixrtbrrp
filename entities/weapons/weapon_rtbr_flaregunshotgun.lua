AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Flare Pistol"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/flaregun.vmt")
end

SWEP.ViewModel		= "models/weapons/flaregunshotgun/c_flaregun.mdl"
SWEP.WorldModel		= "models/weapons/flaregunshotgun/w_flaregun.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 1
SWEP.SlotPos		= 3

SWEP.Primary.Ammo			= "Buckshot"
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.ClipMax		= 8 -- for TTT

SWEP.BulletSpread	= Vector( 0.12, 0.12, 0.12 )
SWEP.BulletSpread2	= SWEP.BulletSpread * 2
SWEP.BulletDamage	= 10
SWEP.BulletCount	= 7

SWEP.FireRate		= 0.5

SWEP.CrosshairX		= 0.75
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "revolver"

SWEP.DeploySound		= Sound("Weapon_Flaregun.Draw")
SWEP.ShootSound 		= Sound("Weapon_Shotgun.Fire_Alt_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 13/30,
}
SWEP.ReloadTime		= 82/30

function SWEP:PrimaryAttack()
	if not self:TakePrimaryAmmo(1) then return end

	if self.ShootSound then
		self:EmitSound(self.ShootSound)
	end
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	self:SetIsReloading(false)

	self:ApplyViewKick()
	self:PlayActivity(ACT_VM_PRIMARYATTACK, true)

	self:ShootBullet(self.BulletSpread, self.BulletDamage, self.BulletCount)
end

function SWEP:ApplyViewKick()
	local owner = self:GetOwner()
	local punch = Angle()
	punch.x = -16
	punch.y = util.SharedRandom(self:GetClass(), -16, 8, 0)

	owner:ViewPunch( punch)
end
