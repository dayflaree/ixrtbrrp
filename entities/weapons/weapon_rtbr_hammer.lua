 
AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_crowbar")

SWEP.Base			= "weapon_rtbr_crowbar"
SWEP.PrintName		= "#rtbr.weapons.hammer"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/hammer.vmt")
end

SWEP.ViewModel		= "models/weapons/rtbrhammer/c_hammer.mdl"
SWEP.WorldModel		= "models/weapons/rtbrhammer/w_hammer.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 0
SWEP.SlotPos		= 0

SWEP.CrosshairX		= 0.75
SWEP.CrosshairY		= 0.75
SWEP.HoldType		= "melee"

SWEP.FireRate		= 0.4
SWEP.Damage			= 12

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 35/60,
}

SWEP.SwingSound		= "RTBR_Weapon_Hammer.Swing"
SWEP.DeploySound	= "RTBR_Weapon_Hammer.Draw"
SWEP.HitSound		= "RTBR_Weapon_Crowbar.Melee_Hit"

function SWEP:Deploy()
	return BaseClass.Deploy(self)
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
end

function SWEP:Holster(wep)
	return BaseClass.Holster(self, wep)
end

function SWEP:Swing(damage)
	local owner = self:GetOwner()
	local activity = ACT_VM_MISSCENTER

	self:EmitSound(self.SwingSound)
	owner:SetAnimation( PLAYER_ATTACK1 )

	local forward = owner:GetAimVector()
	local start = owner:GetShootPos()
	local endp = start + forward * 60

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

function SWEP:Think()
	if self:GetNextIdleTime() <= CurTime() then
		self:PlayActivity(ACT_VM_IDLE)
	end
end
