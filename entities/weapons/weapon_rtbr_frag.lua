 AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Frag Grenade"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/grenade.vmt")
end

SWEP.ViewModel		= "models/weapons/grenade/c_grenade.mdl"
SWEP.WorldModel		= "models/weapons/grenade/w_grenade.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 4
SWEP.SlotPos		= 0

SWEP.Primary.Ammo			= "Grenade"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1

SWEP.CrosshairX		= 0.75
SWEP.CrosshairY		= 0.75
SWEP.HoldType		= "grenade"

SWEP.DeploySound	= Sound("WeaponFrag.Draw")
SWEP.ThrowSound		= Sound("WeaponFrag.Throw_High_Player")
SWEP.LobSound		= Sound("WeaponFrag.Throw_Low_Player")
SWEP.RollSound		= Sound("WeaponFrag.Throw_Roll_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]				= 12/30,
	-- :)
	[ACT_VM_PULLBACK_HIGH]		= math.huge,
	[ACT_VM_PULLBACK_LOW]		= math.huge,
}

SWEP.PinPullTime	= 20/30

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName	= "Frag Grenade"
	SWEP.Slot		= 3
	SWEP.Kind		= WEAPON_NADE
	SWEP.Icon 		= "VGUI/ttt/icon_rtbr_frag"
	SWEP.AutoSpawnable = true
end

function SWEP:SetupDataTables()
	-- only network the stuff from base that we use
	self:NetworkVar("Float","NextIdleTime")
	self:NetworkVar("Bool",	"FirstTimePickup")
	-- grenade-specific
	self:NetworkVar("Bool",	"IsSecondary")
	self:NetworkVar("Bool",	"Thrown")
	self:NetworkVar("Float","PullTime")
	self:NetworkVar("Float","NextBlip")
end

function SWEP:Deploy()
	self:CheckAmmo()
	self:SetThrown(false)
	self:DrawShadow( true )
	self:SetPullTime(-1)
	return BaseClass.Deploy(self)
end

function SWEP:Holster(wep)
	self:CheckAmmo()

	self:SetThrown(false)
	self:SetPullTime(-1)
	return true
end

function SWEP:Reload()
	if self:GetActivity() == ACT_VM_IDLE then
		self:PlayActivity(ACT_VM_FIDGET)
	end
end

function SWEP:CheckAmmo()
	if IsValid(self:GetOwner()) and not self:GetOwner():Alive() then return false end

	if self:Ammo1() <= 0 then
		if SERVER then self:GetOwner():StripWeapon( self.ClassName ) end
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	if not self:CheckAmmo() then return end
	self:PlayActivity(ACT_VM_PULLBACK_HIGH, true)
	self:SetIsSecondary(false)
	self:SetPullTime(CurTime() + self.PinPullTime)
	self:SetNextBlip(CurTime() + self.PinPullTime)
end

function SWEP:SecondaryAttack()
	if not self:CheckAmmo() then return end
	self:PlayActivity(ACT_VM_PULLBACK_LOW, true)
	self:SetIsSecondary(true)
	self:SetPullTime(CurTime() + self.PinPullTime)
	self:SetNextBlip(CurTime() + self.PinPullTime)
end

function SWEP:Think()
	if game.SinglePlayer() and CLIENT then return end
	local owner = self:GetOwner()

	if self:GetPullTime() ~= -1 and CurTime() > self:GetPullTime() then
		if CurTime() > self:GetNextBlip() and CurTime() < self:GetPullTime() + 3.0 then
			self:BlipSound()

			local bwah = 1
			if self:GetElapsedCookTime() > 1.5 then
				bwah = 0.3
			end

			self:SetNextBlip( self:GetNextBlip() + bwah )
		end

		if not self:GetIsSecondary() and not owner:KeyDown(IN_ATTACK) then
			self:ThrowGrenade()
		end
		if self:GetIsSecondary() and not owner:KeyDown(IN_ATTACK2) then
			if owner:KeyDown(IN_DUCK) then
				self:RollGrenade()
			else
				self:LobGrenade()
			end
		end
	end

	if self:GetNextIdleTime() <= CurTime() and self:GetActivity() ~= ACT_VM_PULLBACK_HIGH and self:GetActivity() ~= ACT_VM_PULLBACK_LOW then
		self:PlayActivity(ACT_VM_IDLE)

		if self:GetThrown() then
			self:CheckAmmo()

			self:SetThrown(false)
			self:DrawShadow( true )
			self:PlayActivity(ACT_VM_DRAW, true)
		end
	end
end

function SWEP:GetElapsedCookTime()
	return CurTime() - self:GetPullTime()
end

function SWEP:UncheeseThrowPos(pos)
	local tr = util.TraceHull(
	{
		start = self:GetOwner():GetShootPos(),
		endpos = pos,
		mins = -Vector(4, 4, 4),
		maxs = Vector(4, 4, 4),
		mask = MASK_PLAYERSOLID,
		collisiongroup = self:GetOwner():GetCollisionGroup(),
		filter = self:GetOwner()
	} )

	if tr.Hit then return tr.HitPos end
	return pos
end

function SWEP:ThrowGrenade()
	local owner = self:GetOwner()

	if SERVER then
		local forward = owner:GetForward()
		local right = owner:GetRight()

		local srcvec = owner:GetShootPos()
		srcvec = srcvec + forward * 18
		srcvec = srcvec + right * 8

		srcvec = self:UncheeseThrowPos(srcvec)

		forward.z = forward.z + 0.1
		local throwvec = owner:GetVelocity() + forward * 1200

		self:CreateNade(srcvec, Angle(), throwvec, Vector(600, math.Rand(-1200, 1200), 0 ), 3 - self:GetElapsedCookTime() )
	end

	self:EmitSound(self.ThrowSound)
	self:PlayActivity(ACT_VM_THROW, true)
	owner:SetAnimation( PLAYER_ATTACK1 )
	owner:RemoveAmmo(1, self:GetPrimaryAmmoType())

	self:SetThrown(true)
	self:DrawShadow( false )
	self:SetPullTime(-1)
end

function SWEP:LobGrenade()
	local owner = self:GetOwner()

	if SERVER then
		local forward = owner:GetForward()
		local right = owner:GetRight()

		local srcvec = owner:GetShootPos()
		srcvec = srcvec + forward * 18
		srcvec = srcvec + right * 8
		srcvec.z = srcvec.z - 8

		srcvec = self:UncheeseThrowPos(srcvec)

		local throwvec = owner:GetVelocity() + forward * 350 + Vector(0, 0, 50)

		self:CreateNade(srcvec, Angle(), throwvec, Vector(200, math.Rand(-600, 600), 0 ), 3 - self:GetElapsedCookTime() )
	end

	self:EmitSound(self.LobSound)
	self:PlayActivity(ACT_VM_SECONDARYATTACK, true)
	owner:SetAnimation( PLAYER_ATTACK1 )
	owner:RemoveAmmo(1, self:GetPrimaryAmmoType())

	self:SetThrown(true)
	self:DrawShadow( false )
	self:SetPullTime(-1)
end

function SWEP:RollGrenade()
	local owner = self:GetOwner()

	if SERVER then
		local hull, _ = owner:GetHull()
		local bottom = owner:GetPos() + Vector(0, 0, hull.z + 4)

		local eyeang = owner:EyeAngles()
		eyeang.x = 0
		local forward = eyeang:Forward()

		local tr = util.TraceLine( {
			start = bottom,
			endpos = bottom - Vector(0, 0, 16),
			mask = MASK_PLAYERSOLID,
			collisiongroup = owner:GetCollisionGroup(),
			filter = owner,
		})

		if tr.Hit then
			local tangent = forward:Cross(tr.HitNormal)
			forward = tr.HitNormal:Cross(tangent)
		end

		local srcvec = bottom + forward * 18
		srcvec = self:UncheeseThrowPos(srcvec)

		local throwvec = owner:GetVelocity() + forward * 700

		self:CreateNade(srcvec, Angle(0, owner:GetLocalAngles().y, -90 ), throwvec, Vector(0, 0, 720 ), 3 - self:GetElapsedCookTime() )
	end

	self:EmitSound(self.RollSound)
	self:PlayActivity(ACT_VM_HAULBACK, true)
	owner:SetAnimation( PLAYER_ATTACK1 )
	owner:RemoveAmmo(1, self:GetPrimaryAmmoType())

	self:SetThrown(true)
	self:DrawShadow( false )
	self:SetPullTime(-1)
end

local blip = Sound("RTBRGrenade.Blip")

function SWEP:BlipSound()
	-- force this sound to always be server-sided, so the client doesn't predict the blips
	-- grenade throws aren't predicted so there's no point in predicting blips
	if CLIENT then return end
	SuppressHostEvents(NULL)
	self:EmitSound(blip)
	SuppressHostEvents(self:GetOwner())
end

function SWEP:CreateNade(position, angle, velocity, angvel, timer)
	if CLIENT then return end

	local frag = ents.Create("rtbr_grenade_frag")
	frag:SetThrower(self:GetOwner())
	frag:SetPos(position)
	frag:SetAngles(angle)
	frag:SetTimer( timer )
	frag:SetNextBlip( self:GetNextBlip())
	frag:Spawn()
	frag:GetPhysicsObject():SetVelocity(velocity)
	frag:GetPhysicsObject():SetAngleVelocity(angvel)
end

function SWEP:DropLive()
	local own = self:GetOwner()
	self:CreateNade(own:GetShootPos(), Angle(), vector_origin, vector_origin, 3 - self:GetElapsedCookTime() )
end

hook.Add("DoPlayerDeath", "RTBRDropLive", function(ply)
	local wpn = ply:GetActiveWeapon()
	if IsValid(wpn) and wpn:GetClass() == "weapon_rtbr_frag" and wpn:GetPullTime() ~= -1 and wpn:GetPullTime() < CurTime() then
		wpn:DropLive()
	end
end)

-- hack for TTT, fixes grenade disappearing when dropped manually
function SWEP:PreDrop()
end

if CLIENT then
	function SWEP:DrawWorldModel()
		if not IsValid(self:GetOwner()) or (self:Ammo1() > 0 and not self:GetThrown()) then
			BaseClass.DrawWorldModel(self)
		end
	end
end
