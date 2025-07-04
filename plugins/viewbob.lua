/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.name = "View Bob"
PLUGIN.description = "Implements a very immersive subtle view bobbing effect that follows the player's head accurately."
PLUGIN.author = "Riggs"

function PLUGIN:InitializedConfig()
    ix.config.Add("viewBob", true, "Whether or not to enable the view bobbing effect.", nil, {
        category = "View Bob"
    })

    ix.config.Add("viewBobFOV", 90, "The field of view to use for the view bobbing effect.", nil, {
        data = {min = 1, max = 180},
        category = "View Bob"
    })
end

ix.lang.AddTable("english", {
    viewBob = "View Bob"
})

if ( SERVER ) then return end

function PLUGIN:GetPlayerHead(ply)
    local headBone = ply:LookupBone("ValveBiped.Bip01_Head1")
    if ( headBone ) then
        return headBone
    end

    headBone = ply:LookupBone("ValveBiped.Bip01_Head")
    if ( headBone ) then
        return headBone
    end

    headBone = ply:LookupBone("ValveBiped.Head")
    if ( headBone ) then
        return headBone
    end
end

local buildWeapons = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true,
    ["gmod_camera"] = true
}

function PLUGIN:ShouldDrawImmersiveView(ply)
    if ( ply:CanOverrideView() ) then return false end

    if ( !ix.config.Get("viewBob", true) ) then
        return false
    end

    if ( !IsValid(ply) ) then
        return false
    end

    if ( ply:GetNoDraw() ) then
        return false
    end

    if ( ply:InVehicle() ) then
        return false
    end

    if ( hook.Run("ShouldDrawLocalPlayer", ply) == true ) then
        return false
    end

    if ( hook.Run("GetPlayerHead", ply) == nil ) then
        return false
    end

    local viewEntity = ply:GetViewEntity()
    if ( viewEntity != ply ) then
        return false
    end

    local weapon = ply:GetActiveWeapon()
    if ( IsValid(weapon) and buildWeapons[weapon:GetClass()] ) then
        return false
    end

    return true
end

local lerpOrigin
local lerpAngles
local lerpViewAngles
local view = {}
function PLUGIN:CalcView(ply, origin, angles, fov)
    if ( hook.Run("ShouldDrawImmersiveView", ply) != true ) then
        lerpOrigin = nil
        lerpAngles = nil
        lerpViewAngles = nil

        return
    end

    view.origin = origin
    view.angles = angles
    view.fov = fov

    local char = ply:GetCharacter()
    if ( !char ) then return end
    
    local head = hook.Run("GetPlayerHead", ply)
    if ( head ) then
        view.origin = ply:GetBonePosition(head)
    end

    // If the player is aiming down sights, don't apply the view bobbing effect
    local weapon = ply:GetActiveWeapon()
    if ( IsValid(weapon) and weapon.GetIronSights ) then
        if ( weapon:GetIronSights() ) then
            view.origin = origin
            view.angles = angles
        end
    end

    if ( !lerpOrigin or !lerpAngles ) then
        lerpOrigin = view.origin
        lerpAngles = view.angles
    end

    if ( !lerpViewAngles ) then
        lerpViewAngles = view.angles
    end

    local ft = FrameTime()
    local time = ft * 10

    local pos = view.origin

    local trace = util.TraceHull({
        start = ply:EyePos(),
        endpos = pos,
        filter = ply,
        mask = MASK_PLAYERSOLID,
        mins = Vector(-5, -5, -5),
        maxs = Vector(5, 5, 5)
    })

    if ( trace.Hit ) then
        pos = trace.HitPos
    end

    lerpOrigin = LerpVector(time, lerpOrigin, pos)
    lerpAngles = LerpAngle(time, lerpAngles, view.angles)
    lerpAngles = lerpAngles + ply:GetViewPunchAngles() * 0.1

    lerpViewAngles = LerpAngle(time * 2, lerpViewAngles, view.angles)

    return {
        origin = lerpOrigin,
        angles = lerpAngles,
        fov = ix.config.Get("viewBobFOV", 90)
    }
end

local newOrigin
local newAngles
local lerpWall = 0
function PLUGIN:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAng, eyePos, eyeAng)
    if ( hook.Run("ShouldDrawImmersiveView", LocalPlayer()) != true ) then
        return
    end

    if ( !IsValid(weapon) or !IsValid(viewModel) ) then
        return
    end

    if ( !eyePos or !eyeAng or !oldEyePos or !oldEyeAng ) then
        return
    end

    local origin, angles = GAMEMODE:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAng, eyePos, eyeAng)
    if ( !origin or !angles or !oldEyePos or !oldEyeAng or !lerpOrigin or !lerpViewAngles ) then
        return
    end

    if ( !newOrigin ) then
        newOrigin = origin
        newAngles = angles
    end

    newOrigin = lerpOrigin + (origin - oldEyePos)
    newAngles = lerpViewAngles + (angles - oldEyeAng)

    // if we are infront of a wall, move the viewmodel back a bit smoothly
    local tr = util.TraceHull({
        start = LocalPlayer():EyePos(),
        endpos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 32,
        filter = LocalPlayer(),
        mask = MASK_PLAYERSOLID,
        mins = Vector(-4, -4, -4),
        maxs = Vector(4, 4, 4),
    })

    local ft = FrameTime()
    local time = ft

    local distance = tr.HitPos:Distance(LocalPlayer():EyePos())
    distance = math.Clamp(distance, 0, 16)

    local invertedDistance = 16 - distance
    invertedDistance = math.Clamp(invertedDistance, 0, 16)

    if ( tr.Hit ) then
        lerpWall = Lerp(time, lerpWall, invertedDistance)
    else
        lerpWall = Lerp(time, lerpWall, 0)
    end

    newOrigin = newOrigin - newAngles:Forward() * lerpWall

    return newOrigin, newAngles
end