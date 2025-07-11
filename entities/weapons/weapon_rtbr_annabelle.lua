AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_shotgun")

SWEP.Base			= "weapon_rtbr_shotgun"
SWEP.PrintName		= "Winchester Model 1886"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/annabelle.vmt")
end

SWEP.ViewModel		= "models/weapons/annabelle/c_annabelle.mdl"
SWEP.WorldModel		= "models/weapons/annabelle/w_annabelle.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 3
SWEP.SlotPos		= 1

SWEP.Primary.Ammo			= "45x70Govt"
SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.ClipMax		= 8 -- for TTT

SWEP.FireRate		= 1.5
SWEP.BulletCount	= 1
SWEP.BulletDamage	= 60
SWEP.BulletSpread	= vector_origin
SWEP.BulletSpread2	= Vector( 0.04362, 0.04362, 0.04362 )

SWEP.CrosshairX		= 0.25
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "shotgun"

SWEP.ShootSound		= "Weapon_Annabelle.Fire_Player"
SWEP.DeploySound	= ""

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]				= 40/52,
	[ACT_VM_SECONDARYATTACK]	= 22/57,
	-- override so the annabelle doesn't inherit the shotty's timings
	[ACT_SHOTGUN_PUMP]			= 1,
	[ACT_SHOTGUN_RELOAD_FINISH]	= 0.75,
}

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Annabelle"
	SWEP.Kind		= WEAPON_EQUIP1
	SWEP.Slot		= 6
	SWEP.AmmoEnt	= "item_ammo_357_ttt"
	SWEP.CanBuy		= { ROLE_DETECTIVE }
	SWEP.LimitedStock = true
	SWEP.AutoSpawnable	= false
	SWEP.Icon 		= "VGUI/ttt/icon_rtbr_annabelle"
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Slow precision rifle.\nUses rifle ammo."
	}
end
