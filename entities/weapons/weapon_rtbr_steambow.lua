 AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

game.AddParticles("particles/weapon_rtbr_steambow.pcf")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Steambow"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/steambow.vmt")
end

SWEP.ViewModel		= "models/weapons/steambow/c_crossbow.mdl"
SWEP.WorldModel		= "models/weapons/steambow/W_crossbow.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 3
SWEP.SlotPos		= 2

SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.ClipMax		= 8 -- for TTT

SWEP.FireRate		= 0.5

SWEP.CrosshairX		= 0.0
SWEP.CrosshairY		= 0.25
SWEP.HoldType		= "shotgun"

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 40/50,
	[ACT_VM_PRIMARYATTACK]	= 41/50,
	[ACT_VM_RELOAD]			= 210/51,
	[ACT_VM_RELOAD2]		= 240/51,
	[ACT_VM_RELOAD_EMPTY]	= 202/51,
}
SWEP.ReloadTimings	= {
	[ACT_VM_RELOAD]			= 120/51,	-- put in one bolt
	[ACT_VM_RELOAD_EMPTY]	= 151/51,	-- put in 2 bolts
	[ACT_VM_RELOAD2]		= 112/51,	-- put in last bolt
}

SWEP.ShootSound		= "Weapon_Crossbow.Fire_Player"
SWEP.ShootSoundAlt	= "Weapon_Crossbow.AltFire_Player"

SWEP.ZoomInSound	= "Weapon_OICW.Zoom_In"
SWEP.ZoomOutSound	= "Weapon_OICW.Zoom_Out"

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Steambow"
	SWEP.Primary.DefaultClip	= 3
	SWEP.Kind			= WEAPON_EQUIP1
	SWEP.Slot			= 6
	SWEP.CanBuy			= {ROLE_DETECTIVE}
	SWEP.AutoSpawnable	= false
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_steambow"

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Long-range projectile weapon on primary fire.\nPress mouse3 to scope. Hold mouse2 to charge\na close-range area denial shot.\n\nBeware of the area of effect!"
	};
end

function SWEP:Initialize()
	BaseClass.Initialize(self)

	-- devious bit of tomfoolery -- look into weapon_base's sh_anim.lua file to get context
	self.ActivityTranslate[ ACT_MP_RELOAD_STAND ]	= ACT_HL2MP_IDLE_AR2 + 6
	self.ActivityTranslate[ ACT_MP_RELOAD_CROUCH ]	= ACT_HL2MP_IDLE_AR2 + 6
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Bool", "IsScoped")
	self:NetworkVar("Bool", "Charging")
	self:NetworkVar("Float", "ChargeStartTime")
	self:NetworkVar("Bool", "IdleNoise")

	if SERVER then
		self:SetCharging(false)
	end
end

function SWEP:Deploy()
	return BaseClass.Deploy(self)
end

function SWEP:Holster(wep)
	self:ForceDescope()
	self:SetIdleNoise(false)
	self:SetCharging(false)
	self:StopSound("Weapon_Crossbow.Idle_Steam")
	self:StopSound("Weapon_Crossbow.Charge")
	if IsValid(self.ChargeFX1) then
		self.ChargeFX1:StopEmission(false, true)
		self.ChargeFX1 = nil
	end
	if IsValid(self.ChargeFX2) then
		self.ChargeFX2:StopEmission(false, true)
		self.ChargeFX2 = nil
	end
	if IsValid(self.ChargeFX3) then
		self.ChargeFX3:StopEmission(false, true)
		self.ChargeFX3 = nil
	end
	return BaseClass.Holster(self, wep)
end

function SWEP:BeginReload()
	if self:GetCharging() then return end

	self:ForceDescope()
	local activity = ACT_VM_RELOAD

	if self:Clip1() <= 0 then
		if self:Ammo1() <= 1 then
			activity = ACT_VM_RELOAD2
		else
			activity = ACT_VM_RELOAD_EMPTY
		end
	end

	self:PlayActivity(activity, true)
	self:GetOwner():SetAnimation( PLAYER_RELOAD )
	self:SetIsReloading(true)

	local delay = self:SequenceDuration()
	delay = self.ReloadTimings[activity]
	self:SetReloadTime(CurTime() + delay)
end

function SWEP:PrimaryAttack()
	if self:GetCharging() or not self:TakePrimaryAmmo(1) then return end
	local owner = self:GetOwner()
	self:PlayActivity(ACT_VM_PRIMARYATTACK, true)
	self:EmitSound(self.ShootSound)
	self:FireBolt(0)
end

function SWEP:SecondaryAttack()
	if not self:GetCharging() and self:Clip1() > 0 then
		self:EmitSound("Weapon_Crossbow.Charge")
		self:SetCharging(true)
		self:SetChargeStartTime(CurTime())
		self:PlayActivity(ACT_VM_PULLBACK)
	end
end

local chargeshotacts = {
	ACT_VM_PRIMARYATTACK_1,
	ACT_VM_PRIMARYATTACK_2,
	ACT_VM_PRIMARYATTACK_3,
}

function SWEP:Discharge()
	self:StopSound("Weapon_Crossbow.Charge")
	self:SetCharging(false)
	local chargelvl = math.floor((CurTime() - self:GetChargeStartTime()) * 3 / 2)
	chargelvl = math.min(3, chargelvl)
	if chargelvl == 0 then
		self:PlayActivity(ACT_VM_IDLE)
		return
	end

	local activity = chargeshotacts[chargelvl]
	self:EmitSound(self.ShootSoundAlt)
	self:PlayActivity(activity, true)

	self:FireBolt(chargelvl)
	self:TakePrimaryAmmo(1)
end

function SWEP:FireBolt(chargelevel)
	if CLIENT then return end -- nuh uh
	local owner = self:GetOwner()
	owner:ViewPunch(Angle(-2, 0, 0))
	owner:SetAnimation(PLAYER_ATTACK1)

	local scale = owner:WaterLevel() < 3 and 2500 or 1500
	if chargelevel > 0 then
		scale = scale * 0.7
	end
	local bolt = ents.Create("rtbr_steambow_bolt")
	bolt:SetPos(owner:GetShootPos())
	bolt:SetAngles(owner:EyeAngles())
	bolt:SetLocalVelocity(owner:GetAimVector() * scale)
	bolt:SetOwner(owner)
	bolt:SetChargeLevel(chargelevel)
	bolt:Spawn()
end

function SWEP:Scope()
	if self:GetIsReloading() then return end
	local owner = self:GetOwner()
	if self:GetIsScoped() then
		owner:SetFOV(0, 0.2)
		self:SetIsScoped(false)
		owner:SetCanZoom( true )
		self:EmitSound(self.ZoomOutSound)
		if SERVER then owner:StopZooming() end -- prevents suit zoom overlay from getting stuck
	else
		owner:ScreenFade( SCREENFADE.IN, color_black, 0.4, 0 )
		owner:SetFOV(20, 0.2)
		self:SetIsScoped(true)
		owner:SetCanZoom( false )
		self:EmitSound(self.ZoomInSound)
		if self:GetActivity() == ACT_VM_FIDGET then
			self:PlayActivity(ACT_VM_IDLE)
		end
	end
end

function SWEP:ForceDescope()
	if not self:GetIsScoped() then return end
	local owner = self:GetOwner()
	self:SetIsScoped(false)
	owner:SetFOV(0, 0.2)
	owner:SetCanZoom( true )
	self:EmitSound(self.ZoomOutSound)
	if SERVER then owner:StopZooming() end -- prevents suit zoom overlay from getting stuck
end

function SWEP:Think()
	if CLIENT then
		self:UpdateChargeFX()
	end
	if game.SinglePlayer() and CLIENT then return end
	if self:GetOwner():KeyPressed(IN_WEAPON1) then
		self:Scope()
	end

	local act = self:GetActivity()
	if not self:GetIdleNoise() and (act == ACT_VM_IDLE or act == ACT_VM_FIDGET) then
		self:EmitSound("Weapon_Crossbow.Idle_Steam")
		self:SetIdleNoise(true)
	elseif self:GetIdleNoise() and act ~= ACT_VM_IDLE and act ~= ACT_VM_FIDGET then
		self:StopSound("Weapon_Crossbow.Idle_Steam")
		self:SetIdleNoise(false)
	end

	if self:GetCharging() then
		if self:GetNextIdleTime() <= CurTime() then
			self:PlayActivity(ACT_VM_SECONDARYATTACK)
		end
		if not self:GetOwner():KeyDown(IN_ATTACK2) then
			self:Discharge()
		end
	else
		BaseClass.Think(self)
	end
end

if CLIENT then
	local scopeOverlay = Material( "effects/weapons/crossbow_scope" )

	function SWEP:DrawHUD()
		if self:GetIsScoped() then
			render.UpdateRefractTexture()
			render.SetMaterial(scopeOverlay)
			render.DrawScreenQuad()
		end
	end

	function SWEP:UpdateChargeFX()
		if not self:GetCharging() then
			if IsValid(self.ChargeFX1) then
				self.ChargeFX1:StopEmission()
				self.ChargeFX1 = nil
			end
			if IsValid(self.ChargeFX2) then
				self.ChargeFX2:StopEmission()
				self.ChargeFX2 = nil
			end
			if IsValid(self.ChargeFX3) then
				self.ChargeFX3:StopEmission()
				self.ChargeFX3 = nil
			end
		else
			local vm = self:GetOwner():GetViewModel()
			local chargelvl = math.floor((CurTime() - self:GetChargeStartTime()) * 3 / 2)
			if not IsValid(self.ChargeFX1) and chargelvl == 1 then
				self.ChargeFX1 = CreateParticleSystem(vm, "weapon_steambow_charge", PATTACH_POINT_FOLLOW, vm:LookupAttachment("battery_1"))
			end
			if not IsValid(self.ChargeFX2) and chargelvl == 2 then
				self.ChargeFX2 = CreateParticleSystem(vm, "weapon_steambow_charge", PATTACH_POINT_FOLLOW, vm:LookupAttachment("battery_2"))
			end
			if not IsValid(self.ChargeFX3) and chargelvl == 3 then
				self.ChargeFX3 = CreateParticleSystem(vm, "weapon_steambow_charge", PATTACH_POINT_FOLLOW, vm:LookupAttachment("battery_3"))
			end
		end
	end
end
