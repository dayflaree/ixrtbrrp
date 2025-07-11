 
AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_crowbar")

game.AddParticles("particles/weapon_rtbr_stunstick.pcf")

SWEP.Base			= "weapon_rtbr_crowbar"
SWEP.PrintName		= "Stun Baton"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/stunstick.vmt")
end

SWEP.ViewModel		= "models/weapons/stunstick/c_stunstick.mdl"
SWEP.WorldModel		= "models/weapons/stunstick/w_stunbaton.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 0
SWEP.SlotPos		= 1

SWEP.CrosshairX		= 0.75
SWEP.CrosshairY		= 0.75
SWEP.HoldType		= "melee"

SWEP.FireRate		= 0.8
SWEP.Damage			= 15

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 35/60,
}

SWEP.SwingSound		= "Weapon_Crowbar.Swing"
SWEP.DeploySound	= "Weapon_Stunstick.Draw"
SWEP.HitSound		= "RTBR_Weapon_Stunstick.Melee_Hit"

local STUNSTICK_MAX_CHARGE = 5.5

function SWEP:Deploy()
	self:EmitSound("RTBR_Weapon_StunStick.Activate")
	return BaseClass.Deploy(self)
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Bool", "IsCharging")
	self:NetworkVar("Float", "ChargeStartTime")
end

function SWEP:Holster(wep)
	self:EmitSound("RTBR_Weapon_StunStick.Deactivate")
	self:SetIsCharging(false)
	self:StopSound("Weapon_StunStick.Charge")
	self:KillChargeFx()
	return BaseClass.Holster(self, wep)
end

function SWEP:UtilImpactTrace(tr)
	BaseClass.UtilImpactTrace(self, tr)
	if tr.Hit and IsFirstTimePredicted() then
		ParticleEffect("weapon_stunstick_impact", tr.HitPos, tr.HitNormal:Angle())
	end
end

function SWEP:Swing(damage)
	self:SwingFx()
	BaseClass.Swing(self, damage)
end

function SWEP:SwingFx()
	if SERVER then
		if game.SinglePlayer() then self:CallOnClient("SwingFx") end
		return
	end
	if game.SinglePlayer() or IsFirstTimePredicted() then
		local vm = self:GetOwner():GetViewModel()
		CreateParticleSystem( vm, "weapon_stunstick_swing", PATTACH_POINT_FOLLOW, 2)
	end
end

function SWEP:CreateChargeFX()
	if SERVER then
		if game.SinglePlayer() then self:CallOnClient("CreateChargeFX") end
		return
	end
	if not IsValid(self.ChargeFX) then
		local vm = self:GetOwner():GetViewModel()
		self.ChargeFX = CreateParticleSystem(vm, "weapon_stunstick_charge", PATTACH_POINT_FOLLOW, 2 )
	end
end

function SWEP:KillChargeFx()
	if SERVER then
		if game.SinglePlayer() then self:CallOnClient("KillChargeFx") end
		return
	end
	if IsValid(self.ChargeFX) then
		self.ChargeFX:StopEmission(false, true)
	end
end

function SWEP:SecondaryAttack()
	if not self:GetIsCharging() then
		self:SetIsCharging(true)
		self:SetChargeStartTime(CurTime())
		self:EmitSound("Weapon_StunStick.Charge")
		self:PlayActivity(ACT_VM_HAULBACK)
		self:CreateChargeFX()
		self:SetNextPrimaryFire(CurTime() + 1000)
	end
end

function SWEP:Think()
	if self:GetIsCharging() then
		local owner = self:GetOwner()
		local chargetime = CurTime() - self:GetChargeStartTime()

		if CLIENT and IsValid(self.ChargeFX) then
			self.ChargeFX:SetControlPoint(1, Vector(chargetime / STUNSTICK_MAX_CHARGE, 0, 0) )
		end

		if game.SinglePlayer() and CLIENT then return end

		if not owner:KeyDown(IN_ATTACK2) or chargetime > STUNSTICK_MAX_CHARGE then
			self:SetIsCharging(false)
			self:KillChargeFx()
			self:StopSound("Weapon_StunStick.Charge")
			if chargetime < 0.5 then
				self:PlayActivity(ACT_VM_IDLE)
				self:SetNextPrimaryFire(CurTime())
				self:SetNextSecondaryFire(CurTime())
			else
				self:Swing( math.min(chargetime * 15, 83) )
				self:SetNextPrimaryFire(CurTime() + self.FireRate)
				self:SetNextSecondaryFire(CurTime() + self.FireRate)
			end
		end
	elseif self:GetNextIdleTime() <= CurTime() then
		self:PlayActivity(ACT_VM_IDLE)
	end
end
