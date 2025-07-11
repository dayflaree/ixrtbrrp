AddCSLuaFile()


SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "H&K MP7A1"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/smg2.vmt")
end

SWEP.ViewModel		= "models/weapons/smg2/c_smg2.mdl"
SWEP.WorldModel		= "models/weapons/smg2/w_smg2.mdl"
SWEP.UseHands		= true

SWEP.Spawnable		= true
SWEP.Slot			= 2
SWEP.SlotPos		= 0

SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.ClipSize		= 45
SWEP.Primary.DefaultClip	= 45
SWEP.Primary.ClipMax		= 60 -- for TTT

SWEP.FireRate		= 0.06
SWEP.BulletSpread	= Vector( 0.04632, 0.04632, 0.04632 )
SWEP.BulletDamage	= 6

SWEP.CrosshairX		= 0.5
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "smg"

SWEP.DeploySound = Sound("Weapon_SMG1.Draw")
SWEP.ShootSound = Sound("Weapon_SMG2.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 17 / 30,
	[ACT_VM_RELOAD]	= 93 / 50,
}
SWEP.ReloadTime = 50 / 50

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName	= "SMG2"
	SWEP.Kind		= WEAPON_HEAVY
	SWEP.AmmoEnt	= "item_ammo_smg1_ttt"
	SWEP.Icon 		= "VGUI/ttt/icon_rtbr_smg1"
	SWEP.AutoSpawnable = true
end

function SWEP:ApplyViewKick()
	self:DoMachineGunKick(1.5, self:GetFireDuration(), 3)
end