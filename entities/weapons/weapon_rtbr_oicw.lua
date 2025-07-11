AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "XM29 OICW"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/oicw.vmt")
end

SWEP.ViewModel		= "models/weapons/OICW/c_oicw.mdl"
SWEP.WorldModel		= "models/weapons/OICW/w_oicw.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 2
SWEP.SlotPos		= 4

SWEP.Primary.Ammo			= "rtbr_oicw"
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.ClipMax		= 60 -- for TTT

SWEP.Secondary.Ammo			= "SMG1_Grenade"
SWEP.Secondary.ClipSize		= 2
SWEP.Secondary.DefaultClip	= 0

SWEP.FireRate			= 0.1
SWEP.FireRateScoped		= 0.25
SWEP.BulletSpread		= Vector( 0.02618, 0.02618, 0.02618 )
SWEP.BulletSpreadScoped	= Vector( 0.00873, 0.00873, 0.00873 )
SWEP.BulletDamage		= 10

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "ar2"

SWEP.ShootSound		= "Weapon_OICW.Fire_Player"	-- beware, gets overwritten by Scope function below
SWEP.AltShootSound	= "Weapon_OICW.Fire_Alt_Player"
SWEP.DeploySound	= "Weapon_OICW.Draw"
SWEP.ZoomInSound	= "Weapon_OICW.Zoom_In"
SWEP.ZoomOutSound	= "Weapon_OICW.Zoom_Out"

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 31/50,
	[ACT_VM_RELOAD]	= 110/50,
	[ACT_VM_RELOAD2] = 109/50,
}
SWEP.ReloadTime		= 50/50
SWEP.ReloadTimeAlt	= 94/50

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "OICW"
	SWEP.Primary.Ammo	= "SMG1"
	SWEP.Kind			= WEAPON_HEAVY
	SWEP.AmmoEnt		= "item_ammo_smg1_ttt"
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_oicw"
	SWEP.AutoSpawnable	= true
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar( "Bool", "IsScoped" )
	self:NetworkVar( "Float", "ScopeTime" )

	if SERVER then
		self:SetIsScoped(false)
		self:SetScopeTime(-1)
	end
end

function SWEP:Holster(wpn)
	self:ForceDescope()
	return BaseClass.Holster(self, wpn)
end

function SWEP:GetFireRate()
	if self:GetIsScoped() then
		return self.FireRateScoped
	end

	return self.FireRate
end

function SWEP:GetBulletSpread()
	if self:GetIsScoped() then
		if self:GetShotsFired() == 0 then
			return vector_origin
		elseif self:GetShotsFired() < 3 then
			return self.BulletSpreadScoped
		else
			return self.BulletSpreadScoped * 1.5
		end
	end

	return self.BulletSpread
end

-- dumb hack but i can't really be bothered to do better. BITE ME.
local unscoped_shoot= "Weapon_OICW.Fire_Player"
local scoped_shoot	= "Weapon_OICW.Fire_Scoped"

function SWEP:Scope()
	if CurTime() < self:GetScopeTime() then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	local owner = self:GetOwner()
	if not self:GetIsScoped() then
		self:SetIsScoped(true)
		owner:SetFOV(30, 0.2)
		self:EmitSound(self.ZoomInSound)
		self.ShootSound = scoped_shoot
		owner:SetCanZoom( false )
		owner:ScreenFade( SCREENFADE.IN, color_black, 0.4, 0 )
	else
		self:SetIsScoped(false)
		owner:SetFOV(0, 0.0)
		self:EmitSound(self.ZoomOutSound)
		self.ShootSound = unscoped_shoot
		owner:SetCanZoom( true )
		if SERVER then owner:StopZooming() end -- prevents suit zoom overlay from getting stuck
	end
	self:SetScopeTime(CurTime() + 0.4)
end

function SWEP:ForceDescope()
	if not self:GetIsScoped() then return end
	local owner = self:GetOwner()
	self:SetIsScoped(false)
	owner:SetFOV(0, 0)
	owner:SetCanZoom( true )
	self:EmitSound(self.ZoomOutSound)
	if SERVER then owner:StopZooming() end -- prevents suit zoom overlay from getting stuck
	self.ShootSound = unscoped_shoot
end

if engine.ActiveGamemode() == "terrortown" then
	function SWEP:SecondaryAttack()
		self:Scope()
	end
else
	function SWEP:SecondaryAttack()
		if self:GetIsScoped() then return end

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
	local scopeOverlay = Material( "effects/weapons/oicw_scope" )

	function SWEP:DrawHUD()
		if self:GetIsScoped() then
			render.SetMaterial(scopeOverlay)
			render.DrawScreenQuad()
		end
	end

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
	if self:Clip2() < self:GetMaxClip2() and self:Ammo2() > 0 and CurTime() > self:GetNextPrimaryFire() then return true end
	return false
end

function SWEP:Reload()
	if self:CanReload() then
		self:ForceDescope()
	else
		if self:CanReloadSecondary() then
			self:ReloadSecondary()
			return
		end
	end
	BaseClass.Reload(self)
end

function SWEP:ReloadSecondary()
	if not self:CanReloadSecondary() or self:GetIsReloading() then return end

	self:ForceDescope()

	self:SetIsReloading(true)
	self:PlayActivity(ACT_VM_RELOAD2, true)
	self:GetOwner():SetAnimation( PLAYER_RELOAD )

	local delay = self:SequenceDuration()
	delay = self.ReloadTimeAlt
	self:SetReloadTime(CurTime() + delay)
end

function SWEP:FinishReload()
	if self:GetActivity() == ACT_VM_RELOAD2 then
		local num = self:GetMaxClip2() - self:Clip2()
		num = math.min(num, self:Ammo2())

		self:SetClip2( self:Clip2() + num )
		self:GetOwner():RemoveAmmo(num, self:GetSecondaryAmmoType())
		self:SetIsReloading(false)
		return
	end
	BaseClass.FinishReload(self)
end

function SWEP:Think()
	if self:GetOwner():KeyDown(IN_WEAPON1) then
		self:Scope()
	end
	BaseClass.Think(self)
end

function SWEP:ApplyViewKick()
	local vertical_kick = 1.0
	local slide_limit	= 2.0

	if self:GetIsScoped() then
		vertical_kick	= 0.1
		slide_limit		= 0.2
	end

	self:DoMachineGunKick(vertical_kick, self:GetFireDuration(), slide_limit)
end
