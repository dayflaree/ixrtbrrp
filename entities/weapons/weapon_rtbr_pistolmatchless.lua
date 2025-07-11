AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "H&K USP"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/pistolmatchless.vmt")
end

SWEP.ViewModel		= "models/weapons/pistolmatchless/c_pistol.mdl"
SWEP.WorldModel		= "models/weapons/pistolmatchless/w_pistol.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 1
SWEP.SlotPos		= 0

SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.ClipSize		= 15
SWEP.Primary.DefaultClip	= 15
SWEP.Primary.ClipMax		= 30 -- for TTT
SWEP.Primary.Automatic		= false

SWEP.FireRate		= 30 / 220
SWEP.BulletSpread	= Vector( 0.00837, 0.00837, 0.00837 )
SWEP.BulletDamage	= 8

SWEP.CrosshairX		= 0.0
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "pistol"

SWEP.DeploySound		= Sound("Weapon_Pistol.Draw")
SWEP.ShootSound 		= Sound("Weapon_Pistol2.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 19/30,
	[ACT_VM_RELOAD]	= 118/60,
}
SWEP.ReloadTime		= 68/60

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Pistol Matchless"
	SWEP.Kind			= WEAPON_PISTOL
	SWEP.AmmoEnt		= "item_ammo_pistol_ttt"
	SWEP.Icon 			= "VGUI/ttt/icon_rtbr_pistol"
	SWEP.AutoSpawnable	= true
	SWEP.BulletDamage	= 10
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
end

function SWEP:Holster(wep)
	return BaseClass.Holster(self, wep)
end

function SWEP:Think()
	BaseClass.Think(self)

	if game.SinglePlayer() and CLIENT then return end
end

function SWEP:GetPrimaryAttackActivity()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:ApplyViewKick()
	local ang = Angle()
	ang.x = util.SharedRandom("pewx", -.35, -.4)
	ang.y = util.SharedRandom("pewy", -.5, .7)
	self:GetOwner():ViewPunch(ang)
end
