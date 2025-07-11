AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Mare's Leg"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/annabella.vmt")
end


SWEP.ViewModel		= "models/weapons/annabella/c_annabella.mdl"
SWEP.WorldModel		= "models/weapons/annabella/w_annabella.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 3
SWEP.SlotPos		= 1

SWEP.Primary.Ammo			= "357"
SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= 4
SWEP.Primary.ClipMax		= 4 -- for TTT

SWEP.FireRate		= 0.01
SWEP.BulletCount	= 1
SWEP.BulletDamage	= 45
SWEP.BulletSpread	= Vector( 0.002, 0.002, 0.002 )

SWEP.CrosshairX		= 0.25
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "shotgun"

SWEP.ShootSound		= "Weapon_AnnaBella.Fire_Player"
SWEP.DeploySound	= "Weapon_Annabelle.Draw"

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]				= 40/52,
	[ACT_VM_PRIMARYATTACK]	= 24/57,
	[ACT_SHOTGUN_PUMP]			= 81/90,
	[ACT_SHOTGUN_RELOAD_FINISH]	= 47/72,
}

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "AnnaBella"
	SWEP.Kind		= WEAPON_EQUIP1
	SWEP.Slot		= 6
	SWEP.AmmoEnt	= "item_ammo_357_ttt"
	SWEP.CanBuy		= { ROLE_DETECTIVE }
	SWEP.LimitedStock = true
	SWEP.AutoSpawnable	= false
	SWEP.Icon 		= "VGUI/ttt/icon_rtbr_annabella"
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Fast precision rifle.\nUses rifle ammo."
	}
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
	if not self:GetNeedPump() and self:GetIsReloading() then return end
	if not self:TakePrimaryAmmo(1) then return end

	if self.ShootSound then
		self:EmitSound(self.ShootSound)
	end
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	
	self:SetIsReloading(false)

	self:ShootBullet(self.BulletSpread, self.BulletDamage, self.BulletCount)

	self:ApplyViewKick()
	if self:Clip1() == 0 then
		self:PlayActivity(ACT_VM_SECONDARYATTACK, true)
	else
		self:PlayActivity(ACT_VM_PRIMARYATTACK, true)
	end
end

function SWEP:BeginReload()
	if self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return end -- no shells ?
	
	if self:Clip1() == 0 then
		self:SetNeedPump(true)
	end
	
	if self:GetNeedPump() then
		self:PlayActivity(ACT_HL2MP_GESTURE_RELOAD_AR2, true)
	else
		self:PlayActivity(ACT_SHOTGUN_RELOAD_START, true)
	end
	
	self:GetOwner():SetAnimation( PLAYER_RELOAD )
	self:SetIsReloading(true)
	self:SetInterruptReload(false)
end

function SWEP:LoadShell()
	local owner = self:GetOwner()
	if self:Clip1() == self:GetMaxClip1() or owner:GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return end

	self:SetClip1(self:Clip1() + 1)
	owner:RemoveAmmo(1, self:GetPrimaryAmmoType())
end

function SWEP:ReloadCycle()
	if self:GetNeedPump() then
		self:PlayActivity(ACT_VM_RELOAD_EMPTY, true)
	else
		self:PlayActivity(ACT_VM_RELOAD, true)
	end
	if IsFirstTimePredicted() then self:LoadShell() end
end

function SWEP:FinishReload()
	if self:GetNeedPump() then
		self:PlayActivity(ACT_HL2MP_GESTURE_RELOAD_SHOTGUN, true)
	else
		self:PlayActivity(ACT_SHOTGUN_RELOAD_FINISH, true)
	end
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
			if self:GetInterruptReload() then
				if self:ShouldInterrupt() then
					self:SetIsReloading(false)
					self:SetNextPrimaryFire(CurTime())
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
