AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

local rtbr_gauss_jumping = CreateConVar("rtbr_gauss_jumping", "1", FCVAR_NOTIFY)
local rtbr_gauss_max_penetration = CreateConVar("rtbr_gauss_max_penetration", "48", FCVAR_NOTIFY)
local rtbr_gauss_turbo = CreateConVar("rtbr_gauss_turbo", "0", FCVAR_NOTIFY)

game.AddParticles("particles/weapon_rtbr_gauss.pcf")
PrecacheParticleSystem( "weapon_gauss_beam" )
PrecacheParticleSystem( "weapon_gauss_beam_reflect" )
PrecacheParticleSystem( "weapon_gauss_impact" )

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Tau Cannon"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/gauss.vmt")
end

SWEP.ViewModel		= "models/weapons/Gauss/c_gauss.mdl"
SWEP.WorldModel		= "models/weapons/Gauss/w_gauss.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 0
SWEP.SlotPos		= 4

SWEP.Primary.Ammo			= "Uranium"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.ClipMax		= 100 -- for TTT

SWEP.FireRate		= 0.2
SWEP.BulletDamage	= 30
SWEP.BulletDamageMax= 150
SWEP.BulletSpread	= Vector( 0.00873, 0.00873, 0.00873 )

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.25
SWEP.HoldType		= "shotgun"

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 32/60,
}

SWEP.ShootSound		= "Weapon_Gauss.Fire_Player"
SWEP.ShootSoundAlt	= "Weapon_Gauss.Fire_Alt_Player"

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Tau Cannon"
	SWEP.Kind			= WEAPON_EQUIP1
	SWEP.Slot			= 6
	SWEP.CanBuy			= {ROLE_TRAITOR}
	SWEP.LimitedStock	= true
	SWEP.AutoSpawnable	= false
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_gauss"

	SWEP.FireRate		= 0.5 -- prevent primary spam fire
	SWEP.BulletDamage	= 20
	SWEP.HeadshotMultiplier = 1.0 -- TTT's default is 2.7 which with the gauss's primary shot deals 81 damage on headshot -- excessive !!!!
	SWEP.Primary.ClipSize = 100

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A powerful energy weapon. \nAlt shot charges and pierces surfaces.\n\nBeware of recoil."
	};
end

local GAUSS_CHARGE_INTERVAL = 0.2
local MAX_GAUSS_CHARGE_TIME = 3.2
local DANGER_GAUSS_CHARGE_TIME = 10

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Bool", "Charging")
	self:NetworkVar("Float", "ChargeStartTime")
	self:NetworkVar("Bool", "ChargeIndicated")

	if SERVER then
		self:SetCharging(false)
	end
end

function SWEP:Reload()
	if self:GetActivity() == ACT_VM_IDLE then
		self:PlayActivity(ACT_VM_FIDGET)
	end
end

function SWEP:Holster()
	self:SetCharging(false)

	if self.ChargingNoise then
		self.ChargingNoise:Stop()
	end

	-- we have to do this separately because some of these may become invalid from their particles fully being gone
	if IsValid(self.CoilEffect) then	self.CoilEffect:StopEmission(false, true) end
	if IsValid(self.SpinnyEffect) then	self.SpinnyEffect:StopEmission(false, true) end
	if IsValid(self.ExhaustEffect) then	self.ExhaustEffect:StopEmission(false, true) end

	return BaseClass.Holster(self)
end

function SWEP:PrimaryAttack()
	if self:GetCharging() then
		self:ChargedShot()
		return
	end

	if not self:TakePrimaryAmmo(1) then return end

	if self.ShootSound then
		self:EmitSound(self.ShootSound)
	end

	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	self:PlayActivity(ACT_VM_PRIMARYATTACK)
	self:GaussFire()
	self:SetNextPrimaryFire(CurTime() + self:GetFireRate())
	self:SetNextSecondaryFire(CurTime() + 0.3)
	self:ApplyViewKick()
end

-- some hacks for TTT cause the gauss has an actual clip there to make the ammo count visible
function SWEP:HasAmmo()
	if self.Primary.ClipSize ~= -1 then
		return self:Ammo1() > 0
	else
		return self:Clip1() > 0
	end
end

function SWEP:GetChargeTimeScale()
	local scalar = 1.0
	if rtbr_gauss_turbo:GetBool() then
		scalar = 0.5
	end
	return scalar
end

function SWEP:SecondaryAttack()
	if not self:HasAmmo() then return end

	local owner = self:GetOwner()
	if owner:WaterLevel() == 3 then
		if IsFirstTimePredicted() then
			self:EmitSound("Weapon_Gauss.Discharge_Player")
		end

		self:PlayActivity(ACT_VM_IDLE)
		self:SetNextSecondaryFire(CurTime() + 1)
		self:SetCharging(false)
		self:EndChargeEffects()
		if self.ChargingNoise then self.ChargingNoise:Stop() end

		if SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(25)
			dmginfo:SetInflictor(self)
			dmginfo:SetAttacker(owner)
			dmginfo:SetDamageType(bit.bor(DMG_SHOCK, DMG_CRUSH))
			owner:TakeDamageInfo(dmginfo)
		end
		return
	end

	if not self:GetCharging() then
		self:PlayActivity(ACT_VM_PULLBACK)
		self:SetCharging(true)
		self:SetChargeStartTime(CurTime())
		self:SetChargeIndicated(false)
		self:CreateChargeEffects()

		if not IsValid(self.ChargingNoise) and IsFirstTimePredicted() then
			self.ChargingNoise = CreateSound(self, "Weapon_Gauss.Charge")
			self.ChargingNoise:Play()
		end
	end

	local scalar = self:GetChargeTimeScale()

	if CurTime() - self:GetChargeStartTime() > MAX_GAUSS_CHARGE_TIME * scalar then
		if not self:GetChargeIndicated() then
			if IsFirstTimePredicted() then
				self:EmitSound("Weapon_Gauss.Discharge_Player")
			end
			self:SetChargeIndicated(true)
		end

		if CurTime() - self:GetChargeStartTime() > DANGER_GAUSS_CHARGE_TIME then
			if IsFirstTimePredicted() then
				self:EmitSound("Weapon_Gauss.Discharge_Player")
			end

			if SERVER then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(25)
				dmginfo:SetInflictor(self)
				dmginfo:SetAttacker(owner)
				dmginfo:SetDamageType(bit.bor(DMG_SHOCK, DMG_CRUSH))
				owner:TakeDamageInfo(dmginfo)
			end
			owner:ScreenFade(SCREENFADE.IN, Color(255, 128, 0, 128), 0.2, 0.2)
			self:SetNextSecondaryFire(CurTime() + util.SharedRandom("dummmy", 0.5, 2.5))
		end

		return
	end

	self:TakePrimaryAmmo(1)

	if self.ChargingNoise then
		local t = 4.0
		if rtbr_gauss_turbo:GetBool() then
			t = 1.5
		end
		local pitch = (CurTime() - self:GetChargeStartTime()) * (150 / t) + 100
		if pitch > 250 then pitch = 250 end
		self.ChargingNoise:ChangePitch(pitch)
	end

	if not self:HasAmmo() then
		self:ChargedShot()
		return
	end
	self:SetNextSecondaryFire(CurTime() + GAUSS_CHARGE_INTERVAL * scalar )
end

function SWEP:GaussFire()
	local owner = self:GetOwner()
	owner:LagCompensation( true )

	local aimdir = self:SpreadedVector(owner:GetAimVector(), self:GetBulletSpread())

	local p1, p2, p3

	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + aimdir * 65535,
		mask = MASK_SHOT,
		collisiongroup = COLLISION_GROUP_INTERACTIVE,
		filter = owner,
	})

	p1 = tr.HitPos

	self:DamageEntity(tr, self.BulletDamage, aimdir)
	self:ImpactParticles(tr)
	self:DoImpactEffect(tr, DMG_SHOCK)

	if tr.HitWorld and not tr.HitSky then
		local ang = -tr.HitNormal:Dot(aimdir)
		if ang < 0.5 then
			local reflected = 2.0 * tr.HitNormal * ang + aimdir

			local start2 = tr.HitPos
			local end2 = start2 + reflected * 65535

			tr = util.TraceLine({
				start = start2,
				endpos = end2,
				mask = MASK_SHOT,
				collisiongroup = COLLISION_GROUP_NONE,
				filter = owner,
			})

			p2 = p1
			p3 = tr.HitPos

			self:DamageEntity(tr, self.BulletDamage, aimdir)

			self:ImpactParticles(tr)
		end
	end

	if SERVER then
		self:SendBeams(0, p1, p2, p3)
	elseif CLIENT and IsFirstTimePredicted() then
		self:GaussBeams(0, p1, p2, p3)
	end
	owner:LagCompensation( false )
end

function SWEP:ChargedShot()
	local owner = self:GetOwner()
	owner:LagCompensation( true )

	self:PlayActivity(ACT_VM_SECONDARYATTACK)
	self:SetCharging(false)
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	self:EndChargeEffects()

	if self.ShootSoundAlt then self:EmitSound(self.ShootSoundAlt) end
	if self.ChargingNoise then self.ChargingNoise:Stop() end

	self:SetNextPrimaryFire(CurTime() + 1.5)
	self:SetNextSecondaryFire(CurTime() + 1.5)

	local ang = Angle()
	ang.x = util.SharedRandom("pewx", -4, -8)
	ang.y = util.SharedRandom("pewy", -.25, .25	)
	owner:ViewPunch(ang)

	local chargeamount = math.min(1, (CurTime() - self:GetChargeStartTime()) / (MAX_GAUSS_CHARGE_TIME * self:GetChargeTimeScale()))
	local damage = self.BulletDamage + ((self.BulletDamageMax) * chargeamount);

	--local recoilvel = owner:GetVelocity() - owner:GetAimVector() * damage * 5
	local recoilvel = -owner:GetAimVector() * damage * 5

	recoilvel.z = recoilvel.z + 12.8
	if not rtbr_gauss_jumping:GetBool() then
		recoilvel.z = math.min(recoilvel.z, 350)
	end

	owner:SetVelocity(recoilvel)

	local p1, p2, p3

	local start = owner:GetShootPos()
	local aimdir = owner:GetAimVector()
	local endpos = start + aimdir * 65535

	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = endpos,
		mask = MASK_SHOT,
		collisiongroup = COLLISION_GROUP_NONE,
		filter = owner,
	})

	p1 = tr.HitPos

	self:ImpactParticles(tr)
	self:DamageEntity(tr, damage, aimdir)

	local penetrated = false
	if tr.Hit then
		local endpos2 = tr.HitPos

		tr = util.TraceLine({
			start = endpos2 + 1 * aimdir,
			endpos = endpos2 + rtbr_gauss_max_penetration:GetFloat() * aimdir,
			mask = MASK_SHOT,
			collisiongroup = COLLISION_GROUP_NONE,
		})

		if not tr.AllSolid then
			start = tr.StartPos
			penetrated = true
			local backtr = util.TraceLine({start = start + aimdir, endpos = start - aimdir, mask = MASK_SHOT})
			self:ImpactParticles(backtr)
		end

	end

	if penetrated then
		tr = util.TraceLine({
			start = start + aimdir,
			endpos = endpos,
			mask = MASK_SHOT,
			collisiongroup = COLLISION_GROUP_NONE,
			filter = owner,
		})

		-- if this trace starts inside a solid, that's bad and will result in it not hitting entities. bail.
		if not tr.StartSolid then
			p2 = start
			p3 = tr.HitPos

			self:DamageEntity(tr, damage, aimdir)

			self:ImpactParticles(tr)
		end
	end

	if SERVER then
		self:SendBeams(chargeamount, p1, p2, p3)
	elseif CLIENT and IsFirstTimePredicted() then
		self:GaussBeams(chargeamount, p1, p2, p3)
	end

	owner:LagCompensation( false )
end

function SWEP:DamageEntity(tr, damage, aimvec)
	if not tr.Hit or not IsValid(tr.Entity) then return end
	local dmg = DamageInfo()
	dmg:SetDamageType(DMG_SHOCK)
	dmg:SetDamage(damage)
	dmg:SetAttacker(self:GetOwner())
	dmg:SetInflictor(self)
	dmg:SetDamagePosition(tr.HitPos)
	dmg:SetDamageForce(aimvec * 12503.691375)
	tr.Entity:DispatchTraceAttack(dmg, tr)
end

function SWEP:ImpactParticles(tr)
	if not tr.HitSky then ParticleEffect( "weapon_gauss_impact", tr.HitPos, tr.HitNormal:Angle() ) end
	self:UtilImpactTrace(tr)
end

function SWEP:CreateChargeEffects()
	if SERVER then
		if game.SinglePlayer() then self:CallOnClient("CreateChargeEffects") end
		return
	end
	local vm = self:GetOwner():GetViewModel()
	if not IsValid(self.CoilEffect) then
		self.CoilEffect = CreateParticleSystem(vm, "weapon_gauss_vm_coil_charge", PATTACH_POINT_FOLLOW, 1 )
		self.SpinnyEffect = CreateParticleSystem(vm, "weapon_gauss_vm_capacitor_charge", PATTACH_POINT_FOLLOW, 2 )
		self.ExhaustEffect = CreateParticleSystem(vm, "weapon_gauss_vm_exhaust_charge", PATTACH_POINT_FOLLOW, 3 )
	end
end

function SWEP:EndChargeEffects()
	if SERVER then
		if game.SinglePlayer() then self:CallOnClient("EndChargeEffects") end
		return
	end

	if IsValid(self.CoilEffect) then	self.CoilEffect:StopEmission() end
	if IsValid(self.SpinnyEffect) then	self.SpinnyEffect:StopEmission() end
	if IsValid(self.ExhaustEffect) then	self.ExhaustEffect:StopEmission() end
end

function SWEP:Think()
	if CLIENT and game.SinglePlayer() then return end
	local owner = self:GetOwner()

	if self:GetCharging() then
		if not owner:KeyDown(IN_ATTACK2) or owner:KeyDown(IN_ZOOM) or not owner:Alive() then
			self:ChargedShot()
		end

		return -- prevent idle animation from taking over
	end
	self:Idle()
end

function SWEP:ApplyViewKick()
	local ang = Angle()
	ang.x = util.SharedRandom("pewx", -.5, -.2)
	ang.y = util.SharedRandom("pewy", -.5, .5	)
	self:GetOwner():ViewPunch(ang)
end

-- if there is a better way to do this whole thing please tell me
if SERVER then
	util.AddNetworkString( "rtbrgaussbeam" )

	function SWEP:SendBeams(charge, p1, p2, p3)
		local owner = self:GetOwner()
		net.Start("rtbrgaussbeam")
		net.WritePlayer(owner)
		net.WriteBool(p2)
		net.WriteUInt(charge * 15, 4)
		net.WriteVector(p1)

		if p2 then
			net.WriteVector(p2)
			net.WriteVector(p3)
		end

		-- singleplayer client doesn't predict, so it doesn't create beam particles -- tell it to quit fuckin' around
		if game.SinglePlayer() then
			net.Send(owner)
		else
			net.SendOmit(owner)
		end
	end
else
	function SWEP:GaussBeams(charge, p1, p2, p3 )
		local owner = self:GetOwner()
		local ent = self

		if LocalPlayer() == owner and not LocalPlayer():ShouldDrawLocalPlayer() then
			ent = owner:GetViewModel()
		end

		local ef = CreateParticleSystem( ent, "weapon_gauss_beam", PATTACH_POINT_FOLLOW, 1)
		ef:SetControlPoint(1, p1)
		ef:SetControlPoint(2, Vector(charge, 0, 0))

		if p2 then
			local ef = CreateParticleSystemNoEntity( "weapon_gauss_beam_reflect", p2, angle_zero)
			ef:SetControlPoint(1, p3)
			ef:SetControlPoint(2, Vector(charge, 0, 0))
		end
	end

	net.Receive( "rtbrgaussbeam", function()
		local owner		= net.ReadPlayer()
		local wpn		= owner:GetActiveWeapon()
		local secondbeam= net.ReadBool()
		local charge	= net.ReadUInt(4) / 15
		local p1		= net.ReadVector()
		local p2, p3

		if secondbeam then
			p2 = net.ReadVector()
			p3 = net.ReadVector()
		end

		-- bandaid fix for gauss beams error if a player dies as a result of shooting gauss -- results in beams just not appearing, but oh well
		if wpn.GaussBeams then
			wpn:GaussBeams(charge, p1, p2, p3)
		end
	end )

end
