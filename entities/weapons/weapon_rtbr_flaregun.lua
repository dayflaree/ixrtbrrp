AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

game.AddParticles("particles/weapon_rtbr_flaregun.pcf")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Flaregun"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/flaregun.vmt")
end

SWEP.ViewModel		= "models/weapons/flaregun/c_flaregun.mdl"
SWEP.WorldModel		= "models/weapons/flaregun/W_flaregun.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 1
SWEP.SlotPos		= 3

SWEP.Primary.Ammo			= "rtbr_flare"
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.ClipMax		= 8 -- for TTT

SWEP.FireRate		= 0.5

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.75
SWEP.HoldType		= "revolver"

SWEP.DeploySound		= Sound("Weapon_Flaregun.Draw")
SWEP.ShootSound 		= Sound("Weapon_Flaregun.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 13/30,
}
SWEP.ReloadTime		= 82/30

function SWEP:PrimaryAttack()
	if not self:TakePrimaryAmmo(1) then return end

	local owner = self:GetOwner()
	if self:Clip2() == 0 or owner:WaterLevel() == 3 then
		self:SetNextSecondaryFire(CurTime() + 0.3)
		self:ReloadSecondary()
		return
	end

	self:EmitSound(self.ShootSound)
	self:PlayActivity(ACT_VM_PRIMARYATTACK)
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	self:SetNextPrimaryFire(CurTime() + 1.0)

	if SERVER then
		local angs = owner:EyeAngles() + owner:GetViewPunchAngles()
		local throwvec = angs:Forward() * 1000

		local nade = ents.Create("rtbr_grenade_flare")
		nade:SetOwner(owner)
		nade:SetPos(owner:GetShootPos())
		nade:SetAngles(angs)
		nade:SetVelocity(throwvec)
		nade:Spawn()
	end
end
