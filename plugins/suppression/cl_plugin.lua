print("[Suppression] Client loaded.")

-- Default configuration values
/*
local suppression_viewpunch = true
local suppression_viewpunch_intensity = 1
local suppression_buildupspeed = 1
local suppression_sharpen = true
local suppression_sharpen_intensity = 1
local suppression_bloom = true
local suppression_blur = false -- Performance heavy, should be off by default
local suppression_blur_style = true
local suppression_blur_intensity = 1
local suppression_bloom_intensity = 1
local suppression_enabled = true
local suppression_gasp_enabled = true
local suppression_enable_vehicle = true
local suppression_self_suppress = false
*/

local suppression_viewpunch = ix.config.Get("suppressionViewPunch", true)
local suppression_viewpunch_intensity = ix.config.Get("suppressionViewPunchIntensity", 1)
local suppression_buildupspeed = ix.config.Get("suppressionBuildupSpeed", 1)
local suppression_sharpen = ix.config.Get("suppressionSharpen", true)
local suppression_sharpen_intensity = ix.config.Get("suppressionSharpenIntensity", 1)
local suppression_bloom = ix.config.Get("suppressionBloom", true)
local suppression_blur = ix.config.Get("suppressionBlur", false)
local suppression_blur_style = ix.config.Get("suppressionBlurStyle", true)
local suppression_blur_intensity = ix.config.Get("suppressionBlurIntensity", 1)
local suppression_bloom_intensity = ix.config.Get("suppressionBloomIntensity", 1)
local suppression_enabled = ix.config.Get("suppressionEnabled", true)
local suppression_gasp_enabled = ix.config.Get("suppressionGaspEnabled", true)
local suppression_enable_vehicle = ix.config.Get("suppressionEnableVehicle", true)
local suppression_self_suppress = ix.config.Get("suppressionSelfSuppress", false)

local effect_amount = 0

local function readVectorUncompressed()
    local tempVec = Vector(0, 0, 0)
    tempVec.x = net.ReadFloat()
    tempVec.y = net.ReadFloat()
    tempVec.z = net.ReadFloat()
    return tempVec
end

net.Receive("suppression_fire_event", function(len)
    if not suppression_enabled then return end

    if LocalPlayer():InVehicle() and not suppression_enable_vehicle then return end

    local src = readVectorUncompressed()
    local dir = readVectorUncompressed()
    local entity = net.ReadEntity()
    if not suppression_self_suppress and entity == LocalPlayer() then return end

    local tr = util.TraceLine({
        start = src,
        endpos = src + dir * 100000,
        mask = CONTENTS_WINDOW + CONTENTS_SOLID + CONTENTS_AREAPORTAL + CONTENTS_MONSTERCLIP + CONTENTS_CURRENT_0
    })

    local distance_from_line, nearest_point, dist_along_the_line = util.DistanceToLine(tr.StartPos, tr.HitPos, LocalPlayer():GetPos())

    if LocalPlayer():Alive() and nearest_point:Distance(LocalPlayer():GetPos()) < 100 then
        effect_amount = math.Clamp(effect_amount + 0.08 * suppression_buildupspeed, 0, 1)
        sound.Play("bul_snap/supersonic_snap_" .. math.random(1, 18) .. ".wav", nearest_point, 75, 100, 1)
        sound.Play("bul_flyby/subsonic_" .. math.random(1, 27) .. ".wav", nearest_point, 75, 100, 1)
        if suppression_viewpunch then
            local angle = Angle(math.Rand(-1.5, 1.5) * (effect_amount * suppression_viewpunch_intensity),
                                math.Rand(-1.5, 1.5) * (effect_amount * suppression_viewpunch_intensity),
                                math.Rand(-1.5, 1.5) * (effect_amount * suppression_viewpunch_intensity))
            LocalPlayer():ViewPunch(angle)
        end
    end
end)

local started_effect = false
hook.Add("Think", "suppression_loop", function()
    if effect_amount == 0 then
        if started_effect then
            started_effect = false
        end
        return
    end

    effect_amount = math.Clamp(effect_amount - 0.2 * FrameTime(), 0, 1)
    started_effect = true
end)

local sharpen_lerp = 0
local bloom_lerp = 0
local effect_lerp = 0
hook.Add("RenderScreenspaceEffects", "suppression_ApplySuppression", function()
    if effect_amount == 0 then return end

    if suppression_sharpen then
        sharpen_lerp = Lerp(6 * FrameTime(), sharpen_lerp, effect_amount * suppression_sharpen_intensity)
        DrawSharpen(sharpen_lerp, 0.4)
    end

    if suppression_bloom then
        bloom_lerp = Lerp(6 * FrameTime(), bloom_lerp, effect_amount * suppression_bloom_intensity)
        DrawBloom(0.30, bloom_lerp, 0.33, 4.5, 1, 0, 1, 1, 1)
    end

    if suppression_blur then
        effect_lerp = Lerp(6 * FrameTime(), effect_lerp, effect_amount)
        if suppression_blur_style == 0 then
            DrawBokehDOF(effect_lerp * suppression_blur_intensity, 0, 0)
        else
            DrawBokehDOF(effect_lerp * suppression_blur_intensity, 0.05, 0.25)
        end
    end
end)

local m = Material("helix/gui/vignette.png")
local alphanew = 0
hook.Add("RenderScreenspaceEffects", "suppression_vignette", function()
    if effect_amount == 0 then return end

    alphanew = Lerp(6 * FrameTime(), alphanew, effect_amount)

    render.SetMaterial(m)
    m:SetFloat("$alpha", alphanew)
    m:SetVector("$color", Vector(0, 0, 0)) -- Set color to black

    for i = 1, 4 do
        render.DrawScreenQuad()
    end
end)

hook.Add("PlayerInitialSpawn", "suppression_Initialize", function(ply)
    effect_amount = 0
end)

hook.Add("PlayerDeath", "suppression_ClearDeath", function(ply, i, a)
    effect_amount = 0
end)
