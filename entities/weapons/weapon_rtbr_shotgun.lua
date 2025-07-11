AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Franchi SPAS-12"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/shotgun.vmt")
end


SWEP.ViewModel		= "models/weapons/shotgun/c_shotgun.mdl"
SWEP.WorldModel		= "models/weapons/shotgun/w_shotgun.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 3
SWEP.SlotPos		= 0

SWEP.Primary.Ammo			= "Buckshot"
SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.ClipMax		= 24 -- for TTT

SWEP.BulletSpread	= Vector( 0.08716, 0.08716, 0.08716 )
SWEP.BulletSpread2	= SWEP.BulletSpread * 2
SWEP.BulletDamage	= 9
SWEP.BulletCount	= 7

SWEP.CrosshairX		= 0.75
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "shotgun"

SWEP.ShootSound 	= Sound("Weapon_Shotgun.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]				= 23/52,
	[ACT_VM_PRIMARYATTACK]		= 22/52,
	[ACT_VM_SECONDARYATTACK]	= 21/52,
	[ACT_SHOTGUN_PUMP]			= 26/52,
	[ACT_SHOTGUN_RELOAD_FINISH]	= 26/50,
}

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName	= "SPAS-12"
	SWEP.Slot		= 2
	SWEP.Kind		= WEAPON_HEAVY
	SWEP.AmmoEnt	= "item_box_buckshot_ttt"
	SWEP.Icon 		= "VGUI/ttt/icon_rtbr_shotgun"
	SWEP.AutoSpawnable = true
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar( "Bool", "NeedPump" )
	self:NetworkVar( "Bool", "InterruptReload" )

	if SERVER then
		self:SetNeedPump(false)
	end
end

function SWEP:PrimaryAttack()
	if self:GetNeedPump() or self:GetIsReloading() then return end
	if not self:TakePrimaryAmmo(1) then return end

	if self.ShootSound then
		self:EmitSound(self.ShootSound)
	end
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	self:SetIsReloading(false)
	self:SetNeedPump(true)

	self:ApplyViewKick()
	self:PlayActivity(ACT_VM_PRIMARYATTACK, true)

	self:ShootBullet(self.BulletSpread, self.BulletDamage, self.BulletCount)
	-- absolutely NO firing until we pump
	self:SetNextPrimaryFire(CurTime() + 100.0)
	self:SetNextSecondaryFire(CurTime() + 100.0)
end

-- copy of base.GunFire cause im lazy
function SWEP:SecondaryAttack()
	if not self:TakePrimaryAmmo(1) then return end

	if self.ShootSound then
		self:EmitSound(self.ShootSound)
	end

	local owner = self:GetOwner()
	owner:SetAnimation( PLAYER_ATTACK1 )

	self:ShootBullet(self.BulletSpread2, self.BulletDamage, self.BulletCount)

	self:ApplyViewKick()
	self:PlayActivity(ACT_VM_SECONDARYATTACK, true)
end

function SWEP:BeginReload()
	if self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return end -- no shells ?

	self:PlayActivity(ACT_SHOTGUN_RELOAD_START, true)
	self:GetOwner():SetAnimation( PLAYER_RELOAD )
	self:SetIsReloading(true)
	self:SetInterruptReload(false)
end

function SWEP:LoadShell()
	local owner = self:GetOwner()
	if self:Clip1() == self:GetMaxClip1() or owner:GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return end -- no shells ?

	self:SetClip1(self:Clip1() + 1)
	owner:RemoveAmmo(1, self:GetPrimaryAmmoType())
end

function SWEP:ReloadCycle()
	self:PlayActivity(ACT_VM_RELOAD, true)
	if IsFirstTimePredicted() then self:LoadShell() end
end

function SWEP:FinishReload()
	self:PlayActivity(ACT_SHOTGUN_RELOAD_FINISH, true)
	self:SetIsReloading(false)
end

function SWEP:Pump()
	self:PlayActivity(ACT_SHOTGUN_PUMP, true)
	self:SetNeedPump(false)
end

function SWEP:ShouldInterrupt()
	local owner = self:GetOwner()
	return owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)
end

function SWEP:Think()
	if game.SinglePlayer() and CLIENT then return end
	local owner = self:GetOwner()

	if not self:GetIsReloading() and self:Clip1() == 0 and self:CanReload() then
		self:Reload()
	end

	if self:GetNextIdleTime() <= CurTime() then
		if self:GetIsReloading() then
			-- if the player is holding down the trigger, let them interrupt
			if self:GetInterruptReload() then
				if self:ShouldInterrupt() then
					self:SetIsReloading(false)
					self:SetNextPrimaryFire(CurTime())
					self:SetNextSecondaryFire(CurTime())
				else
					self:FinishReload()
				end
				return
			end

			if self:Clip1() < self:GetMaxClip1() and owner:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
				self:ReloadCycle()
			else
				self:FinishReload()
			end
		else
			self:PlayActivity(ACT_VM_IDLE)

			if self:GetNeedPump() and not self:GetIsReloading() then
				self:Pump()
				return
			end
		end
	end

	if self:GetIsReloading() and self:ShouldInterrupt() and self:Clip1() > 0 then
		self:SetInterruptReload(true)
	end
end

function SWEP:ApplyViewKick()
	local ang = Angle()
	ang.x = util.SharedRandom("blamx", -2, -1)
	ang.y = util.SharedRandom("blamy", -2, 2	)
	self:GetOwner():ViewPunch(ang)
end
