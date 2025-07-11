AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "XM29 OICW Union"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/oicwscopeless.vmt")
end

SWEP.ViewModel		= "models/weapons/oicwscopeless/c_oicw.mdl"
SWEP.WorldModel		= "models/weapons/oicwscopeless/w_oicw.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 2
SWEP.SlotPos		= 4

SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.ClipMax		= 60 -- for TTT

SWEP.Secondary.Ammo			= "SMG1_Grenade"
SWEP.Secondary.ClipSize		= 4
SWEP.Secondary.DefaultClip	= 0

SWEP.FireRate			= 0.09
SWEP.BulletSpread		= Vector( 0.024, 0.024, 0.024 )
SWEP.BulletDamage		= 10

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "ar2"

SWEP.ShootSound		= "Weapon_OICWU.Fire_Player"
SWEP.AltShootSound	= "Weapon_OICW.Fire_Alt_Player"
SWEP.DeploySound	= "Weapon_OICW.Draw"
SWEP.ZoomInSound	= "Weapon_OICW.Zoom_In"
SWEP.ZoomOutSound	= "Weapon_OICW.Zoom_Out"

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 31/50,
	[ACT_VM_RELOAD]	= 110/50,
	[ACT_VM_RELOAD2] = 109/50,
	[ACT_VM_RELOADEMPTY] = 110/50,
	[ACT_VM_RELOAD_M203] = 79/50,
}
SWEP.ReloadTime		= 90/50
SWEP.ReloadTime2	= 60/50
SWEP.ReloadTimeAlt	= 94/50
SWEP.ReloadTimeAlt2	= 60/50

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "OICW Union"
	SWEP.Primary.Ammo	= "AR2"
	SWEP.Kind			= WEAPON_HEAVY
	SWEP.AmmoEnt		= "item_ammo_smg1_ttt"
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_oicw"
	SWEP.AutoSpawnable	= true
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
end

function SWEP:Holster(wpn)
	return BaseClass.Holster(self, wpn)
end

if engine.ActiveGamemode() == "terrortown" then
	function SWEP:SecondaryAttack()
		return SWEP:SecondaryAttack()
	end
else
	function SWEP:SecondaryAttack()
		local owner = self:GetOwner()
		if self:Clip2() == 0 or owner:WaterLevel() == 3 then
			self:SetNextSecondaryFire(CurTime() + 0.3)
			self:ReloadSecondary()
			return
		end

		self:SetClip2(self:Clip2() - 1)

		self:EmitSound(self.AltShootSound)
		self:PlayActivity(ACT_VM_SECONDARYATTACK)
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
		self:SetNextSecondaryFire(CurTime() + 0.5)
		self:SetNextPrimaryFire(CurTime() + 0.5)

		if SERVER then
			local angs = owner:EyeAngles() + owner:GetViewPunchAngles()
			local throwvec = angs:Forward() * 1000

			local nade = ents.Create("rtbr_grenade_oicw")
			nade:SetOwner(owner)
			nade:SetPos(owner:GetShootPos())
			nade:SetAngles(angs)
			nade:SetVelocity(throwvec)
			nade:SetLocalAngularVelocity( AngleRand(-400, 400) )
			nade:Spawn()
		end
	end
end

if CLIENT then
	function SWEP:CustomAmmoDisplay()
		local display = {
			Draw = true,
			PrimaryClip = self:Clip1(),
			PrimaryAmmo = self:Ammo1(),
			SecondaryAmmo = self:Clip2() + self:Ammo2(),
		}
		return display
	end
end

function SWEP:CanReloadSecondary()
	if self:Clip2() < self:GetMaxClip2() and self:Ammo2() > 0 then return true end
	return false
end

function SWEP:Reload()
	if self:CanReload() then
		if self:Clip1() >= 1 then
			self:BeginReloadAlt()
		else
			BaseClass.BeginReload(self)
		end
	else
		if not self:GetIsReloading() and self:GetActivity() == ACT_VM_IDLE then
			self:PlayActivity(ACT_VM_FIDGET)
		end
	end
	if self:CanReloadSecondary() then
		self:ReloadSecondary()
		return
	end
end

function SWEP:BeginReloadAlt()
	self:PlayActivity(ACT_VM_RELOAD_EMPTY, true)
	self:GetOwner():SetAnimation( PLAYER_RELOAD )
	self:SetIsReloading(true)

	local delay = self:SequenceDuration()
	if self.ReloadTime2 != -1 then delay = self.ReloadTime2 end
	self:SetReloadTime(CurTime() + delay)
end

function SWEP:FinishReload()
	if self:GetActivity() == ACT_VM_RELOAD2 or self:GetActivity() == ACT_VM_RELOAD_M203 then
		local num = self:GetMaxClip2() - self:Clip2()
		num = math.min(num, self:Ammo2())

		self:SetClip2( self:Clip2() + num )
		self:GetOwner():RemoveAmmo(num, self:GetSecondaryAmmoType())
		self:SetIsReloading(false)
		return
	end
	BaseClass.FinishReload(self)
end

function SWEP:ReloadSecondary()
	if not self:CanReloadSecondary() or self:GetIsReloading() then return end
	if self:Clip2() >= 1 then
		self:SetIsReloading(true)
		self:PlayActivity(ACT_VM_RELOAD_M203, true)
		self:GetOwner():SetAnimation( PLAYER_RELOAD )

		local delay = self:SequenceDuration()
		delay = self.ReloadTimeAlt2
		self:SetReloadTime(CurTime() + delay)
	elseif self:Clip2() == 0 then
		self:SetIsReloading(true)
		self:PlayActivity(ACT_VM_RELOAD2, true)
		self:GetOwner():SetAnimation( PLAYER_RELOAD )

		local delay = self:SequenceDuration()
		delay = self.ReloadTimeAlt
		self:SetReloadTime(CurTime() + delay)
	end
end

function SWEP:Think()
	BaseClass.Think(self)
end

function SWEP:ApplyViewKick()
	local vertical_kick = 1.5
	local slide_limit	= 3.0

	self:DoMachineGunKick(vertical_kick, self:GetFireDuration(), slide_limit)
end
