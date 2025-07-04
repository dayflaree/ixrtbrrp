local PLUGIN = PLUGIN

PLUGIN.name = "Suitcases"
PLUGIN.description = "Adds suitcases that can be used to store items."
PLUGIN.author = "Riggs"
PLUGIN.schema = "HL2 RP"
PLUGIN.license = [[
Copyright 2024 Riggs Mackay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

-- Ensure the entities/weapons directory exists for suitcase SWEPs
-- (No code needed here, just a note for the assistant to create the folders)

local supportedModels = {
    ["models/zrtbr/humans/group01/male_01.mdl"] = true,
    ["models/zrtbr/humans/group01/male_02.mdl"] = true,
    ["models/zrtbr/humans/group01/male_03.mdl"] = true,
    ["models/zrtbr/humans/group01/male_04.mdl"] = true,
    ["models/zrtbr/humans/group01/male_05.mdl"] = true,
    ["models/zrtbr/humans/group01/male_06.mdl"] = true,
    ["models/zrtbr/humans/group01/male_07.mdl"] = true,
    ["models/zrtbr/humans/group01/male_08.mdl"] = true,
    ["models/zrtbr/humans/group01/male_09.mdl"] = true,
    ["models/zrtbr/humans/group04/male_01.mdl"] = true,
    ["models/zrtbr/humans/group04/male_02.mdl"] = true,
    ["models/zrtbr/humans/group04/male_03.mdl"] = true,
    ["models/zrtbr/humans/group04/male_04.mdl"] = true,
    ["models/zrtbr/humans/group04/male_05.mdl"] = true,
    ["models/zrtbr/humans/group04/male_06.mdl"] = true,
    ["models/zrtbr/humans/group04/male_07.mdl"] = true,
    ["models/zrtbr/humans/group04/male_08.mdl"] = true,
    ["models/zrtbr/humans/group04/male_09.mdl"] = true,
    ["models/zrtbr/humans/group05/male_01.mdl"] = true,
    ["models/zrtbr/humans/group05/male_02.mdl"] = true,
    ["models/zrtbr/humans/group05/male_03.mdl"] = true,
    ["models/zrtbr/humans/group05/male_04.mdl"] = true,
    ["models/zrtbr/humans/group05/male_05.mdl"] = true,
    ["models/zrtbr/humans/group05/male_06.mdl"] = true,
    ["models/zrtbr/humans/group05/male_07.mdl"] = true,
    ["models/zrtbr/humans/group05/male_08.mdl"] = true,
    ["models/zrtbr/humans/group05/male_09.mdl"] = true,
    ["models/zrtbr/humans/group07/male_01.mdl"] = true,
    ["models/zrtbr/humans/group07/male_02.mdl"] = true,
    ["models/zrtbr/humans/group07/male_03.mdl"] = true,
    ["models/zrtbr/humans/group07/male_04.mdl"] = true,
    ["models/zrtbr/humans/group07/male_05.mdl"] = true,
    ["models/zrtbr/humans/group07/male_06.mdl"] = true,
    ["models/zrtbr/humans/group07/male_07.mdl"] = true,
    ["models/zrtbr/humans/group07/male_08.mdl"] = true,
    ["models/zrtbr/humans/group07/male_09.mdl"] = true,
}

-- Explicitly map supported models to the 'citizen_male' animation class
for model, _ in pairs(supportedModels) do
    ix.anim.SetModelClass(model, "citizen_male")
end

-- Custom animation class for suitcase holding
ix.anim.suitcase = {
    normal = {
        [ACT_MP_STAND_IDLE] = "d1_t01_luggage_idle",
        [ACT_MP_WALK] = "luggage_walk_all",
        [ACT_MP_RUN] = "luggage_run_all",
    }
}

-- Set the animation hold type to 'suitcase' when holding a suitcase SWEP
hook.Add("UpdateAnimation", "ixSuitcaseAnimClass", function(ply, velocity, maxSeqGroundSpeed)
    local model = string.lower(ply:GetModel() or "")
    local wep = ply:GetActiveWeapon()
    if not supportedModels[model] then return end
    if IsValid(wep) and (wep:GetClass() == "ix_suitcase" or wep:GetClass() == "ix_suitcase_big" or wep:GetClass() == "ix_briefcase") then
        ply.ixAnimHoldType = "suitcase"
        print("[SuitcaseAnim] Set hold type to 'suitcase' for", ply, "Model:", model, "Weapon:", wep:GetClass())
    else
        print("[SuitcaseAnim] Not using suitcase hold type for", ply, "Model:", model, "Weapon:", IsValid(wep) and wep:GetClass() or "none")
    end
end)