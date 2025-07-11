AddCSLuaFile()
list.Set("ContentCategoryIcons", "Raising The Bar: Redux", "icon16/rtbr.png")

game.AddParticles("particles/rtbr_muzzle_fx.pcf")

local BaseClass = baseclass.Get( "weapon_base" )
if engine.ActiveGamemode() == "terrortown" then
	SWEP.Base			= "weapon_tttbase"
	SWEP.NoSights		= true
	SWEP.DrawCrosshair	= true
	SWEP.AutoSpawnable	= false
	BaseClass = baseclass.Get( "weapon_tttbase" )
else
	SWEP.Base		= "weapon_base"
end

SWEP.PrintName		= "weapon_rtbr_base"
SWEP.Category		= "Raising The Bar: Redux"

SWEP.BounceWeaponIcon	= false
SWEP.DrawWeaponInfoBox	= false

SWEP.ViewModel		= "models/error.mdl"
SWEP.ViewModelFOV	= 65
SWEP.ViewModelFlip	= false
SWEP.WorldModel		= "models/error.mdl"
SWEP.UseHands		= true
SWEP.Spawnable		= false

SWEP.Primary.Ammo			= ""
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true

SWEP.Secondary.Ammo			= ""
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true

-- custom data
SWEP.FireRate		= 0.1
SWEP.BulletSpread	= vector_origin
SWEP.BulletDamage	= 1
SWEP.BulletDamageNPC= 1
SWEP.BulletCount	= 1

SWEP.CrosshairX		= 0.0
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "normal"

SWEP.DeploySound	= ""

SWEP.ReadyTimings	= {}
SWEP.ReloadTime		= -1

function SWEP:Initialize()
	self:SetDeploySpeed(100.0)
	self:SetHoldType(self.HoldType)
end

-- not to be confused with reloading (gun)
function SWEP:OnReloaded()
	self:Initialize()
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float",	"NextIdleTime" )
	self:NetworkVar( "Float",	"FireDuration" ) -- time spent holding primary trigger
	self:NetworkVar( "Int",		"ShotsFired" ) -- consecutive shot counter
	self:NetworkVar( "Bool",	"IsReloading")
	self:NetworkVar( "Float",	"ReloadTime" )
	self:NetworkVar( "Bool",	"FirstTimePickup")

	if SERVER then
		self:SetShotsFired(0)
		self:SetIsReloading(false)
	end
end

-- dont want first draw animation to play all the time
if engine.ActiveGamemode() ~= "terrortown" then
	function SWEP:Equip(ent)
		if ent:IsPlayer() then
			self:SetFirstTimePickup(true)
		end
	end
else
	function SWEP:WasBought(buyer)
		self:SetFirstTimePickup(true)
	end
end

function SWEP:PlayActivity(act, blocker)
	self:SendWeaponAnim(act)

	local delay = self:SequenceDuration()
	self:SetNextIdleTime(CurTime() + delay)
	if blocker or false then
		if self.ReadyTimings[act] and self.ReadyTimings[act] ~= -1 then
			delay = self.ReadyTimings[act]
		end
		self:SetNextPrimaryFire(CurTime() + delay)
		self:SetNextSecondaryFire(CurTime() + delay)
	end
end

function SWEP:Deploy()
	self:PlayActivity(ACT_VM_DRAW, true, 0.8)
	self:EmitSound(self.DeploySound)

	if self.SetFireDuration and self.SetShotsFired then
		self:SetFireDuration(0)
		self:SetShotsFired(0)
	end

	if self:GetFirstTimePickup() and SERVER then
		local vm = self:GetOwner():GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence("drawfirst"))

		self:SetNextIdleTime(self:GetNextIdleTime() + vm:SequenceDuration())
		self:SetFirstTimePickup(false)
	end
	return true
end

function SWEP:Holster(wep)
	self:SetIsReloading(false)
	return true
end

function SWEP:CanReload()
	if self:GetIsReloading() then return false end
	if self:Clip1() >= self:GetMaxClip1() then return false end
	if self:GetNextPrimaryFire() > CurTime() then return false end
	if self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return false end

	return true
end

function SWEP:Reload()
	if self:CanReload() then
		self:BeginReload()
	end
end

function SWEP:BeginReload()
	self:PlayActivity(ACT_VM_RELOAD, true)
	self:GetOwner():SetAnimation( PLAYER_RELOAD )
	self:SetIsReloading(true)

	local delay = self:SequenceDuration()
	if self.ReloadTime != -1 then delay = self.ReloadTime end
	self:SetReloadTime(CurTime() + delay)
end

function SWEP:FinishReload()
	local num = self:GetMaxClip1() - self:Clip1()
	num = math.min(num, self:Ammo1())

	self:SetClip1( self:Clip1() + num )
	self:GetOwner():RemoveAmmo(num, self:GetPrimaryAmmoType())
	self:SetIsReloading(false)
end

----------------------------------------------------
-- returns true if the amount of ammo requested was taken successfully, false otherwise
----------------------------------------------------
function SWEP:TakePrimaryAmmo(amount)
	-- if the weapon doesn't use clips, take directly from our owner
	if self:Clip1() < 0 then
		-- check if owner has enough ammo
		if ( self:Ammo1() < amount ) then return false end

		self:GetOwner():RemoveAmmo( amount, self:GetPrimaryAmmoType() )
		return true
	end

	-- check if clip has enough ammo
	if self:Clip1() < amount then return false end

	self:SetClip1( self:Clip1() - amount )
	return true
end

function SWEP:PrimaryAttack()
	if not self:TakePrimaryAmmo(1) then return end
	local owner = self:GetOwner()

	if self.ShootSound then
		self:EmitSound(self.ShootSound)
	end

	owner:SetAnimation( PLAYER_ATTACK1 )
	self:PlayActivity( self:GetPrimaryAttackActivity() )
	self:ApplyViewKick()

	if SERVER then
		sound.EmitHint(SOUND_COMBAT, self:GetPos(), 1500, 0.2, owner)
	end
	owner:MuzzleFlash()

	self:ShootBullet(self:GetBulletSpread(), self.BulletDamage, self.BulletCount)

	self:SetShotsFired( self:GetShotsFired() + 1 )
	self:SetNextPrimaryFire(CurTime() + self:GetFireRate())
	self:SetLastShootTime()
end

function SWEP:SecondaryAttack() end

-- HACK: this is necessary to have circular spread because gmod is fucking stupid and doesn't use hl2's built-in circular spread system
-- instead it opts for its own dumb implementation where the spread is square-shaped
-- that's what every basic bullet gun is supposed to be using, by the way. absurd, honestly.
function SWEP:SpreadedVector(vec, spread)
	local owner = self:GetOwner()
	local x, y
	local i = 0
	while i < 10 do -- give up after 10 iterations just incase we somehow get stuck.......
		x, y = util.SharedRandom("x", -1.0, 1.0, i), util.SharedRandom("y", -1.0, 1.0, i)
		if x*x + y*y < 1 then
			break
		end
		i = i + 1
	end
	local aimdir, right, up = owner:GetAimVector(), owner:GetRight(), owner:GetUp()

	aimdir = aimdir + x * right * spread + y * up * spread
	return aimdir
end

function SWEP:ShootBullet(spread, damage, count)
	local owner = self:GetOwner()

	local vec = owner:GetAimVector()
	local src = owner:GetShootPos()
	local num = count or 1

	-- use built-in spread here because the shotgun feels even worse when calling FireBullets multiple times instead of using Num
	if num > 1 then
		owner:FireBullets({
							Src = src,
							Dir = vec,
							Damage = damage,
							Num = num,
							Spread = spread * (math.pi / 4), -- compensate for square-shaped spread
							AmmoType = self.Primary.Ammo,
						})
	else
		local spreaded = self:SpreadedVector(vec, spread, i)
		owner:FireBullets({
							Src = src,
							Dir = spreaded,
							Damage = damage,
							AmmoType = self.Primary.Ammo,
						})
	end
end

function SWEP:UtilImpactTrace(tr)
	if not tr.Hit or tr.HitSky or not IsFirstTimePredicted() then return end
	local ef = EffectData()
	ef:SetStart(tr.StartPos)
	ef:SetOrigin(tr.HitPos)
	ef:SetEntity(tr.Entity)
	ef:SetNormal(tr.HitNormal)
	ef:SetSurfaceProp( tr.SurfaceProps )

	util.Effect("Impact", ef)
end

function SWEP:Think()
	if game.SinglePlayer() and CLIENT then return end

	local owner = self:GetOwner()
	local cmd = owner:GetCurrentCommand()

	if not self:GetIsReloading() and self:Clip1() == 0 and self:CanReload() then
		self:Reload()
	end

	if cmd:KeyDown(IN_ATTACK) and not self:GetIsReloading() then
		self:SetFireDuration(self:GetFireDuration() + FrameTime())
	elseif CurTime() > self:GetNextPrimaryFire() then
		self:SetFireDuration(0)
		self:SetShotsFired(0)
	end

	if self:GetIsReloading() and self:GetReloadTime() <= CurTime() then
		self:FinishReload()
	end

	self:Idle()
end

function SWEP:Idle()
	if self:GetNextIdleTime() <= CurTime() then
		self:PlayActivity(ACT_VM_IDLE)
	end
end

function SWEP:GetPrimaryAttackActivity()
	if self:GetShotsFired() < 2 then
		return ACT_VM_PRIMARYATTACK end
	if self:GetShotsFired() < 3 then
		return ACT_VM_RECOIL1 end
	if self:GetShotsFired() < 4 then
		return ACT_VM_RECOIL2 end

	return ACT_VM_RECOIL3
end

function SWEP:GetBulletSpread()
	return self.BulletSpread
end

function SWEP:GetFireRate()
	return self.FireRate
end

function SWEP:ApplyViewKick()
end

----------------------------------------------------
-- copied from hl2 machinegun code
----------------------------------------------------
function SWEP:DoMachineGunKick(maxVerticalKickAngle, fireDurationTime, slideLimitTime)
	local owner = self:GetOwner()
	local vecScratch = Angle()

	local duration
	if ( fireDurationTime > slideLimitTime ) then
		duration = slideLimitTime
	else
		duration = fireDurationTime
	end

	local kickPerc = duration / slideLimitTime

	owner:ViewPunchReset(10)

	vecScratch.x = -( 0.2 + ( maxVerticalKickAngle * kickPerc ) )
	vecScratch.y = -( 0.2 + ( maxVerticalKickAngle * kickPerc ) ) / 3
	vecScratch.z =    0.1 + ( maxVerticalKickAngle * kickPerc ) / 8

	if util.SharedRandom("DoMachineGunKickX", -1, 1) >= 0 then
		vecScratch.y = -vecScratch.y
	end
	if util.SharedRandom("DoMachineGunKickY", -1, 1) >= 0 then
		vecScratch.x = -vecScratch.x
	end

	local punchangle = vecScratch + owner:GetViewPunchAngles()

	vecScratch.x = math.Clamp(vecScratch.x, punchangle.x - 24, punchangle.x + 24 )
	vecScratch.y = math.Clamp(vecScratch.y, punchangle.y - 3, punchangle.y + 3 )
	vecScratch.z = math.Clamp(vecScratch.z, punchangle.z - 1, punchangle.z + 1 )

	vecScratch = punchangle - owner:GetViewPunchAngles()

	owner:ViewPunch(vecScratch * 0.5)
end

if CLIENT then
	local fov_desired = GetConVar("fov_desired")

	function SWEP:AdjustMouseSensitivity()
		local local_fov = self:GetOwner():GetFOV()

		return local_fov / fov_desired:GetInt()
	end

	local crosshairs = Material("hud/rtbr_crosshairs.vmt")
	local rtbr_crosshair_colour = Color(255,255,255)

	if engine.ActiveGamemode() == "terrortown" then
		-- copied from weapon_tttbase
		function SWEP:DoDrawCrosshair(x, y)
			-- atleast one HUD addon explicitly tells the SWEP to draw the crosshair at (0, 0) for some fucking reason...? so i have to bail if that happens.
			if x == 0 and y == 0 then return false end
			if LocalPlayer().IsTraitor and LocalPlayer():IsTraitor() then
				surface.SetDrawColor(255,
									50,
									50,
									255)
			else
				surface.SetDrawColor(0,
									255,
									0,
									255)
			end
			surface.SetMaterial(crosshairs)
			surface.DrawTexturedRectUV( x-32, y-32, 64, 64, self.CrosshairX, self.CrosshairY, self.CrosshairX+0.25, self.CrosshairY+0.25)
			return true
		end
		-- dummy this out to zap the TTT crosshair
		function SWEP:DrawHUD() end
	else
		function SWEP:DoDrawCrosshair(x, y)
			if x == 0 and y == 0 then return false end
			surface.SetDrawColor(rtbr_crosshair_colour)
			surface.SetMaterial(crosshairs)
			surface.DrawTexturedRectUV( x-32, y-32, 64, 64, self.CrosshairX, self.CrosshairY, self.CrosshairX+0.25, self.CrosshairY+0.25)
			return true
		end
	end


	function SWEP:DrawWeaponSelection(  x,  y,  width,  height, alpha )
		surface.SetDrawColor( 255, 220, 0, alpha )
		surface.SetTexture( self.WepSelectIcon )

		y = y + 10
		x = x + 10
		width = width - 20
		height = height - 20

		surface.DrawTexturedRect( x, y, width, width * 0.5 )
	end
end
