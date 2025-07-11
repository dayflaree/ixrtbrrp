AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "#rtbr.weapons.crowbar"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/crowbar.vmt")
end

SWEP.ViewModel		= "models/weapons/crowbar/c_crowbar.mdl"
SWEP.WorldModel		= "models/weapons/crowbar/w_crowbar.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 0
SWEP.SlotPos		= 0

SWEP.CrosshairX		= 0.75
SWEP.CrosshairY		= 0.75
SWEP.HoldType		= "melee"

SWEP.FireRate		= 0.4
SWEP.Damage			= 10

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 15/32,
}

SWEP.SwingSound		= "Weapon_Crowbar.Swing"
SWEP.DeploySound	= "Weapon_Crowbar.Draw"
SWEP.HitSound		= "RTBR_Weapon_Crowbar.Melee_Hit"

function SWEP:PrimaryAttack()
	self:Swing(self.Damage)
	self:SetNextPrimaryFire(CurTime() + self.FireRate)
	self:SetNextSecondaryFire(CurTime() + self.FireRate)
end

function SWEP:Think()
	self:Idle()
end

function SWEP:Swing(damage)
	local owner = self:GetOwner()
	local activity = ACT_VM_MISSCENTER

	self:EmitSound(self.SwingSound)
	owner:SetAnimation( PLAYER_ATTACK1 )

	local forward = owner:GetAimVector()
	local start = owner:GetShootPos()
	local endp = start + forward * 75

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

local waterslime = CONTENTS_WATER + CONTENTS_SLIME

function SWEP:HitWater(start, endp)
	if bit.band(util.PointContents(start), waterslime) ~= 0 then return end
	if bit.band(util.PointContents(endp), waterslime) == 0 then return end

	local tr = util.TraceLine({
		start			= start,
		endpos			= endp,
		mask			= waterslime,
		collisiongroup	= COLLISION_GROUP_NONE,
		filter			= self:GetOwner(),
	})

	if tr.Hit then
		local ef = EffectData()
		ef:SetOrigin(tr.HitPos)
		ef:SetNormal(tr.HitNormal)
		ef:SetScale(8.0)
		if bit.band(tr.Contents, CONTENTS_SLIME) ~= 0 then
			ef:SetFlags(1) -- FX_WATER_IN_SLIME
		else
			ef:SetFlags(0)
		end
		util.Effect("watersplash", ef)
	end
end

function SWEP:ApplyViewKick()
	local ang = Angle()
	ang.x = util.SharedRandom("dinkx", 1, 2)
	ang.y = util.SharedRandom("dinky", -2, -1	)
	self:GetOwner():ViewPunch(ang)
end
