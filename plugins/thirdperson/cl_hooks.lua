local PLUGIN = PLUGIN

for k, v in pairs(PLUGIN) do
    if ( type(v) == "function" ) then
        PLUGIN[k] = function(self, ...)
            return
        end
    end
end

function PLUGIN:ShouldDrawThirdPerson(ply)
    if ( !ix.option.Get("thirdpersonEnabled", false) ) then return false end

    if ( !IsValid(ply) or !ply:GetCharacter() or !ply:Alive() ) then return false end

    if ( ply:InVehicle() ) then return false end
    if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then return false end
    if ( ply:GetViewEntity() != ply ) then return false end

    return true
end

function PLUGIN:ShouldDrawLocalPlayer(ply)
    if ( !hook.Run("ShouldDrawThirdPerson", ply) ) then return end

    return true
end

local cameraAngle
local cameraLerp
function PLUGIN:CalcView(ply, origin, angles, fov)
    if ( !hook.Run("ShouldDrawThirdPerson", ply) ) then return end

    if ( !cameraAngle ) then
        cameraAngle = angles
    end

    if ( !cameraLerp ) then
        cameraLerp = angles
    end
    
    local trace = util.TraceHull({
        start = origin,
        endpos = origin - cameraAngle:Forward() * ix.option.Get("thirdpersonDistance", 50) - cameraAngle:Up() * ix.option.Get("thirdpersonVertical", 0) + cameraAngle:Right() * ix.option.Get("thirdpersonHorizontal", 0),
        filter = ply,
        mins = Vector(-8, -8, -8),
        maxs = Vector(8, 8, 8),
        mask = MASK_SHOT_HULL
    })

    local view = {}
    view.origin = trace.HitPos
    view.angles = cameraAngle
    view.fov = fov

    cameraLerp = LerpAngle(FrameTime() * 10, ply:EyeAngles(), cameraAngle)
    cameraLerp.r = 0

    local bClassic = ix.option.Get("thirdpersonClassic", false)
    if ( bClassic or ply:IsWepRaised() or ( ply:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT) ) and ply:GetVelocity():Length() >= 10 ) ) then
        ply:SetEyeAngles(cameraLerp)
    end

    return view
end

function PLUGIN:InputMouseApply(cmd, x, y, angle)
    local ply = LocalPlayer()

    if ( !cameraAngle ) then
        cameraAngle = Angle(0, 0, 0)
    end

    if ( !cameraLerp ) then
        cameraLerp = Angle(0, 0, 0)
    end

    cameraAngle.p = math.Clamp(math.NormalizeAngle(cameraAngle.p + y / 50), -85, 85)
    cameraAngle.y = math.NormalizeAngle(cameraAngle.y - x / 50)
    cameraAngle.r = 0

    return hook.Run("ShouldDrawThirdPerson", ply)
end