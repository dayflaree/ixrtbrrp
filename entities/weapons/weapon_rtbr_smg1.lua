AddCSLuaFile()


SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "H&K MP7 PDW"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/smg1.vmt")
end

SWEP.ViewModel		= "models/weapons/smg1/c_smg1.mdl"
SWEP.WorldModel		= "models/weapons/smg1/w_smg1.mdl"
SWEP.UseHands		= true

SWEP.Spawnable		= true
SWEP.Slot			= 2
SWEP.SlotPos		= 0

SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.ClipMax		= 60 -- for TTT

SWEP.FireRate		= 0.0745
SWEP.BulletSpread	= Vector( 0.04362, 0.04362, 0.04362 )
SWEP.BulletDamage	= 5

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "smg"

SWEP.DeploySound = Sound("Weapon_SMG1.Draw")
SWEP.ShootSound = Sound("Weapon_SMG1.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 17 / 30,
	[ACT_VM_RELOAD]	= 93 / 50,
}
SWEP.ReloadTime = 50 / 50

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName	= "MP7A1"
	SWEP.Kind		= WEAPON_HEAVY
	SWEP.AmmoEnt	= "item_ammo_smg1_ttt"
	SWEP.Icon 		= "VGUI/ttt/icon_rtbr_smg1"
	SWEP.AutoSpawnable = true
end

function SWEP:ApplyViewKick()
	self:DoMachineGunKick(1, self:GetFireDuration(), 2)
end
