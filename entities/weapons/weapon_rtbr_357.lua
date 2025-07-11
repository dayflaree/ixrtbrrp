AddCSLuaFile()

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Colt Anaconda"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/357.vmt")
end

SWEP.ViewModel		= "models/weapons/357/c_357.mdl"
SWEP.WorldModel		= "models/weapons/357/W_357.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 1
SWEP.SlotPos		= 2

SWEP.Primary.Ammo			= "357"
SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.ClipMax		= 12 -- for TTT

SWEP.FireRate		= 0.75
SWEP.BulletSpread	= vector3_origin
SWEP.BulletDamage	= 40

SWEP.CrosshairX		= 0.25
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "revolver"

SWEP.DeploySound		= Sound("Weapon_357.Draw")
SWEP.ShootSound 		= Sound("Weapon_357.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 16/28,
	[ACT_VM_RELOAD]	= 3,
}
SWEP.ReloadTime		= 52/27

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Python"
	SWEP.Kind			= WEAPON_PISTOL
	SWEP.AmmoEnt		= "item_ammo_revolver_ttt"
	SWEP.Primary.Ammo	= "AlyxGun" -- why
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_357"
	SWEP.AutoSpawnable	= true
end

function SWEP:GetPrimaryAttackActivity()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:ApplyViewKick()
	local owner = self:GetOwner()
	if (IsFirstTimePredicted() and CLIENT) or (game.SinglePlayer() and SERVER) then
		local angs = owner:EyeAngles()

		angs = angs + Angle(util.SharedRandom(self:GetClass(), -1, 1),
							util.SharedRandom(self:GetClass(), -1, 1),
							0)

		owner:SetEyeAngles(angs)
	end

	local punch = Angle()
	punch.x = -8
	punch.y = util.SharedRandom(self:GetClass(), -2, 2, 0)

	owner:ViewPunch( punch)
end
