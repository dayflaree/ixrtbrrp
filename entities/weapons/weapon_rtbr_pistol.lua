AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "H&K USP Match"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/pistol.vmt")
end

SWEP.ViewModel		= "models/weapons/pistol/c_pistol.mdl"
SWEP.WorldModel		= "models/weapons/pistol/w_pistol.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 1
SWEP.SlotPos		= 0

SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.ClipSize		= 18
SWEP.Primary.DefaultClip	= 18
SWEP.Primary.ClipMax		= 36 -- for TTT

SWEP.FireRate		= 60 / 220
SWEP.BulletSpread	= Vector( 0.00873, 0.00873, 0.00873 )
SWEP.BulletDamage	= 7

SWEP.CrosshairX		= 0.0
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "pistol"

SWEP.DeploySound		= Sound("Weapon_Pistol.Draw")
SWEP.ShootSound 		= Sound("Weapon_Pistol.Fire_Player")
SWEP.BurstSound			= Sound("Weapon_Pistol.Burst")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 19/30,
	[ACT_VM_RELOAD]	= 118/60,
}
SWEP.ReloadTime		= 68/60

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Pistol"
	SWEP.Kind			= WEAPON_PISTOL
	SWEP.AmmoEnt		= "item_ammo_pistol_ttt"
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_pistol"
	SWEP.AutoSpawnable	= true
	SWEP.BulletDamage	= 12
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar( "Int",	"BurstCount" )
end

function SWEP:Holster(wep)
	if self:GetBurstCount() > 0 then return false end
	return BaseClass.Holster(self, wep)
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() < 2 then
		self:PrimaryAttack()
		return
	end

	if IsFirstTimePredicted() then self:EmitSound(self.BurstSound) end

	self:SetBurstCount(2)
	self:Think()
	self:SetNextSecondaryFire(CurTime() + 0.25)
end

function SWEP:Think()
	BaseClass.Think(self)

	if game.SinglePlayer() and CLIENT then return end

	if self:GetBurstCount() > 0 and self:GetNextPrimaryFire() <= CurTime() then
		if not self:TakePrimaryAmmo(1) then return end

		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
		self:PlayActivity( self:GetPrimaryAttackActivity() )
		self:ShootBullet(self:GetBulletSpread() * 5.0, self.BulletDamage)
		self:ApplyViewKick()
		self:SetBurstCount(self:GetBurstCount() - 1)

		self:SetNextSecondaryFire(CurTime() + self.FireRate / 3 )
		self:SetNextPrimaryFire(CurTime() + self.FireRate / 3)

		if self:GetBurstCount() == 0 then
			self:SetNextSecondaryFire(CurTime() + 0.25 - self.FireRate / 3)
		end
	end
end

function SWEP:GetPrimaryAttackActivity()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:ApplyViewKick()
	local ang = Angle()
	ang.x = util.SharedRandom("pewx", -.25, -.5)
	ang.y = util.SharedRandom("pewy", -.6, .6	)
	self:GetOwner():ViewPunch(ang)
end

function SWEP:GetNPCBurstSettings()
	return 2, 2, 0.24
end
