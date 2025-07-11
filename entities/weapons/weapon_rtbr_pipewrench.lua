 
AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_crowbar")

SWEP.Base			= "weapon_rtbr_crowbar"
SWEP.PrintName		= "#rtbr.weapons.pipewrench"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/pipewrench.vmt")
end

SWEP.ViewModel		= "models/weapons/rtbrpipewrench/c_pipewrench.mdl"
SWEP.WorldModel		= "models/weapons/rtbrpipewrench/w_pipewrench.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 0
SWEP.SlotPos		= 0

SWEP.CrosshairX		= 0.75
SWEP.CrosshairY		= 0.75
SWEP.HoldType		= "melee"

SWEP.FireRate		= 0.9
SWEP.Damage			= 20

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 35/60,
}

SWEP.SwingSound		= "Weapon_Crowbar.Swing"
SWEP.DeploySound	= "Weapon_Crowbar.Draw"
SWEP.HitSound		= "RTBR_Weapon_Crowbar.Melee_Hit"

local STUNSTICK_MAX_CHARGE = 4

function SWEP:Deploy()
	return BaseClass.Deploy(self)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "IsCharging")
	self:NetworkVar("Float", "ChargeStartTime")
	BaseClass.SetupDataTables(self)
end

function SWEP:Holster(wep)
	self:SetIsCharging(false)
	return BaseClass.Holster(self, wep)
end

function SWEP:Swing(damage)
	local owner = self:GetOwner()
	local activity = ACT_VM_MISSCENTER

	self:EmitSound(self.SwingSound)
	owner:SetAnimation( PLAYER_ATTACK1 )

	local forward = owner:GetAimVector()
	local start = owner:GetShootPos()
	local endp = start + forward * 65

	owner:LagCompensation(true)

	local tr = util.TraceLine({
		start			= start,
		endpos			= endp,
		mask			= MASK_SHOT_HULL,
		collisiongroup	= COLLISION_GROUP_NONE,
		filter			= owner,
	})

	self:HitWater(start, tr.HitPos)

	if not tr.Hit then
		local bludgeonHullRadius = 1.732 * 16
		endp = endp - forward * bludgeonHullRadius

		tr = util.TraceHull({
			mins			= -Vector(16, 16, 16),
			maxs			= Vector(16, 16, 16),
			start			= start,
			endpos			= endp,
			mask			= MASK_SHOT_HULL,
			collisiongroup	= COLLISION_GROUP_NONE,
			filter			= owner,
		})

		if tr.Hit then
			-- something funny happens if the hulltrace hits the world, cause it'll compare against the map origin. i think this is funny so im keeping it
			local dirToTarget = tr.Entity:GetPos() - start
			dirToTarget:Normalize()

			if dirToTarget:Dot(forward) < 0.70721 then
				tr.Hit = false
				tr.Fraction = 1
			end
		end
	end
	owner:LagCompensation(false)

	self:UtilImpactTrace(tr)

	if tr.Hit then
		activity = ACT_VM_HITCENTER
		self:EmitSound(self.HitSound)
		self:ApplyViewKick()

		if IsValid(tr.Entity) then
			local dmg = DamageInfo()
			dmg:SetAttacker(owner)
			dmg:SetInflictor(self)
			dmg:SetDamage(damage)
			dmg:SetDamageType(DMG_CLUB)
			dmg:SetDamagePosition(tr.HitPos)
			dmg:SetDamageForce(forward * 75 * 4 * damage)

			tr.Entity:DispatchTraceAttack(dmg, tr)
		end
	end

	self:PlayActivity(activity)
end

function SWEP:SecondaryAttack()
	if not self:GetIsCharging() then
		self:SetIsCharging(true)
		self:SetChargeStartTime(CurTime())
		self:PlayActivity(ACT_VM_HAULBACK)
		self:SetNextPrimaryFire(CurTime() + 1000)
	end
end

function SWEP:Think()
	if self:GetIsCharging() then
		local owner = self:GetOwner()
		local chargetime = CurTime() - self:GetChargeStartTime()

		if game.SinglePlayer() and CLIENT then return end

		if not owner:KeyDown(IN_ATTACK2) or chargetime > STUNSTICK_MAX_CHARGE then
			self:SetIsCharging(false)
			if chargetime < 0.5 then
				self:PlayActivity(ACT_VM_IDLE)
				self:SetNextPrimaryFire(CurTime())
				self:SetNextSecondaryFire(CurTime())
			else
				self:Swing( math.min(chargetime * 20, 83) )
				self:SetNextPrimaryFire(CurTime() + self.FireRate)
				self:SetNextSecondaryFire(CurTime() + self.FireRate)
			end
		end
	elseif self:GetNextIdleTime() <= CurTime() then
		self:PlayActivity(ACT_VM_IDLE)
	end
end
