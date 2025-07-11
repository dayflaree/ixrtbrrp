AddCSLuaFile()
DEFINE_BASECLASS("weapon_rtbr_base")

SWEP.Base			= "weapon_rtbr_base"
SWEP.PrintName		= "Modified Colt M1911"
SWEP.Category		= "Raising The Bar: Redux"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("sprites/weapons/alyxgun.vmt")
end

SWEP.ViewModel		= "models/weapons/alyxgun/c_alyx_gun.mdl"
SWEP.WorldModel		= "models/weapons/alyxgun/w_alyx_gun.mdl"

SWEP.Spawnable		= true
SWEP.Slot			= 1
SWEP.SlotPos		= 2

SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.ClipMax		= 90 -- for TTT

SWEP.FireRate		= 0.0745
SWEP.BulletSpread	= Vector( 0.01745, 0.01745, 0.01745 )
SWEP.BulletDamage	= 8

SWEP.CrosshairX		= 0.0
SWEP.CrosshairY		= 0.0
SWEP.HoldType		= "revolver"

SWEP.DeploySound	= ""	-- Weapon_Alyxgun.Draw is called from animation
SWEP.ShootSound 	= Sound("Weapon_Alyxgun.Fire_Player")

SWEP.ReadyTimings	= {
	[ACT_VM_DRAW]	= 30/45,
	[ACT_VM_RELOAD]	= 90/50,
}
SWEP.ReloadTime		= 55/50

-- TTT overrides
if engine.ActiveGamemode() == "terrortown" then
	SWEP.PrintName		= "Alyx Gun"
	SWEP.Kind		= WEAPON_EQUIP1
	SWEP.AmmoEnt	= "item_ammo_pistol_ttt"
	SWEP.CanBuy		= { ROLE_TRAITOR }
	SWEP.Slot			= 6
	SWEP.AutoSpawnable	= false
	SWEP.Icon 		= "VGUI/ttt/icon_rtbr_alyxgun"
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Accurate, rapid-fire machine pistol.\nUses normal pistol ammo."
	};
end

function SWEP:Initialize()
	BaseClass.Initialize(self)

	-- devious bit of tomfoolery -- look into weapon_base's sh_anim.lua file to get context
	self.ActivityTranslate[ ACT_MP_RELOAD_STAND ]	= ACT_HL2MP_IDLE_PISTOL + 6
	self.ActivityTranslate[ ACT_MP_RELOAD_CROUCH ]	= ACT_HL2MP_IDLE_PISTOL + 6
end

function SWEP:ApplyViewKick()
	self:DoMachineGunKick(1, self:GetFireDuration(), 2)
end
