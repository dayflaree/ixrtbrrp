local PLUGIN = PLUGIN

PLUGIN.name = "Music Kits"
PLUGIN.author = "Riggs, eon, vingard"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 Riggs Mackay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

PLUGIN.passiveMusic = {
    {"rtbr/mus/comp1/rtbr_equilibrium.mp3"},
    {"rtbr/mus/comp1/rtbr_reversal_symmetry.mp3"},
    {"rtbr/mus/comp1/rtbr_tefres_aimatos.mp3"},
    {"rtbr/mus/comp2/rtbr_concealed_derelict.mp3"},
    {"rtbr/mus/comp2/rtbr_continuity_of_light.mp3"},
    {"rtbr/mus/comp2/rtbr_fractal_space.mp3"},
    {"rtbr/mus/comp2/rtbr_human_chaos.mp3"},
    {"rtbr/mus/comp2/rtbr_old_friends.mp3"},
    {"rtbr/mus/comp2/rtbr_vacant_oscillations.mp3"},
    {"rtbr/mus/comp3/rtbr_hyperboreas.mp3"},
    {"rtbr/mus/comp3/rtbr_nihil.mp3"},
    {"rtbr/mus/comp3/rtbr_our_actions.mp3"},
    {"rtbr/mus/comp3/rtbr_power_distress.mp3"},
    {"rtbr/mus/comp3/rtbr_subaqueous_haven.mp3"},
    {"rtbr/mus/comp3/rtbr_their_reactions.mp3"},
    {"rtbr/mus/comp4/rtbr_decadent_error.mp3"},
    {"rtbr/mus/comp4/rtbr_pensive_regimen.mp3"},
    {"rtbr/mus/comp4/rtbr_subspace_melody.mp3"},
    {"rtbr/mus/comp4/rtbr_vain_delusion.mp3"},
    {"rtbr/mus/comp4/rtbr_wave_lengths.mp3"},
    {"rtbr/mus/comp4/rtbr_weve_come_so_far.mp3"},
    {"rtbr/mus/comp5/rtbr_combined_efforts.mp3"},
    {"rtbr/mus/comp5/rtbr_socioscan.mp3"},
    {"rtbr/mus/comp5/rtbr_zen.mp3"},
    {"rtbr/mus/comp6/rtbr_abyase.mp3"},
    {"rtbr/mus/comp6/rtbr_acrophobia.mp3"},
    {"rtbr/mus/comp6/rtbr_flesh_and_blood.mp3"},
    {"rtbr/mus/comp6/rtbr_gravity_sway.mp3"},
    {"rtbr/mus/comp6/rtbr_heat_death.mp3"},
    {"rtbr/mus/comp6/rtbr_oscillation_echoform.mp3"},
    {"rtbr/mus/comp6/rtbr_psionic_interference.mp3"},
    {"rtbr/mus/comp7/rtbr_dimensionless_deepness.mp3"},
    {"rtbr/mus/comp7/rtbr_im_not_shutting_down.mp3"},
    {"rtbr/mus/comp7/rtbr_its_safer_here.mp3"},
    {"rtbr/mus/comp7/rtbr_jeep_sea.mp3"},
    {"rtbr/mus/comp7/rtbr_manufacturing_yield.mp3"},
    {"rtbr/mus/comp7/rtbr_the_machine.mp3"},
    {"rtbr/mus/comp7/rtbr_tribal.mp3"},
    {"rtbr/mus/rtbr_human_error.mp3"}
    
}

PLUGIN.combatMusic = {
    {"rtbr/mus/comp1/rtbr_annihilation_operators.mp3"},
    {"rtbr/mus/comp1/rtbr_canum_venaticorum.mp3"},
    {"rtbr/mus/comp1/rtbr_high_pressure.mp3"},
    {"rtbr/mus/comp1/rtbr_steam_in_the_pipes.mp3"},
    {"rtbr/mus/comp1/rtbr_substorm_phases.mp3"},
    {"rtbr/mus/comp1/rtbr_vector_error.mp3"},
    {"rtbr/mus/comp2/rtbr_born.mp3"},
    {"rtbr/mus/comp2/rtbr_government_property.mp3"},
    {"rtbr/mus/comp2/rtbr_we_the_people.mp3"},
    {"rtbr/mus/comp3/rtbr_a_fleeting_threat.mp3"},
    {"rtbr/mus/comp3/rtbr_despair_protocol.mp3"},
    {"rtbr/mus/comp3/rtbr_terminal_verdict.mp3"},
    {"rtbr/mus/comp3/rtbr_velosiped.mp3"},
    {"rtbr/mus/comp4/rtbr_anti-oxidisation.mp3"},
    {"rtbr/mus/comp4/rtbr_exchanged_sabotage.mp3"},
    {"rtbr/mus/comp4/rtbr_familiar_intrusion.mp3"},
    {"rtbr/mus/comp4/rtbr_stand_your_ground.mp3"},
    {"rtbr/mus/comp5/rtbr_execution_and_evasion.mp3"},
    {"rtbr/mus/comp5/rtbr_good_mourning.mp3"},
    {"rtbr/mus/comp5/rtbr_necropolis_march.mp3"},
    {"rtbr/mus/comp5/rtbr_prophylactic_safeguard.mp3"},
    {"rtbr/mus/comp5/rtbr_vertical_peril.mp3"},
    {"rtbr/mus/comp5/rtbr_youre_supposed_to_be_here.mp3"},
    {"rtbr/mus/comp6/rtbr_captus.mp3"},
    {"rtbr/mus/comp6/rtbr_gaussian_capacitor.mp3"},
    {"rtbr/mus/comp6/rtbr_psionic_interference.mp3"},
    {"rtbr/mus/comp6/rtbr_total_regicide.mp3"},
    {"rtbr/mus/comp7/rtbr_auditory_input_stimulation_emulation.mp3"},
    {"rtbr/mus/comp7/rtbr_the_machine.mp3"}
}

ix.lang.AddTable("english", {
    optMusicKit = "Kit",
    optMusicKitEnabled = "Kit Enabled",
    optdMusicKitEnabled = "Should Kits be Enabled?",
    optdMusicKit = "What Music Kit do you want to be played?",
    optMusicAmbientVol = "Kit Ambient Volume",
    optdMusicAmbientVol = "How much Ambient Kit Volume do you prefer?",
    optMusicCombatVol = "Kit Combat Volume",
    optdMusicCombatVol = "How much Combat Kit Volume do you prefer?",
})

local lastSongs = lastSongs or {}
CUSTOM_MUSICKITS = CUSTOM_MUSICKITS or {}

file.CreateDir("helix/musickits")

CreateClientConVar("ix_music_forcecombat", "0", false, false, "If we should force the combat state for music. Used for debugging.", 0, 1)
CreateClientConVar("ix_music_debug", "0", false, false, "Prints details about the currently playing music to console. Used for debugging.", 0, 1)

local function DebugPrint(msg)
    if GetConVar("ix_music_debug"):GetBool() then
        print("[Helix] [musicdebug] "..msg)
    end
end

local function ReadMusicKit(name)
    local txt = file.Read("helix/musickits/"..name)

    if not txt then
        return "Failed to read music kit file."
    end

    local json = util.JSONToTable(txt)
    local antiCrash = {}

    if not json or not istable(json) then
        return "Corrupted music kit file. Check formatting."
    end

    if not json.Name or not isstring(json.Name) then
        return "Missing name value, or name value is not a string."
    end

    if not json.Combat or not istable(json.Combat) or not json.Ambient or not istable(json.Ambient) then
        return "Missing combat and ambient tracks."
    end

    if table.Count(json.Combat) < 4 then
        return "At least 4 tracks are required in the combat track list."
    end

    if table.Count(json.Ambient) < 4 then
        return "At least 4 tracks are required in the ambient track list."
    end

    for v,k in ipairs(json.Ambient) do
        if not istable(k) or not k.Sound or not k.Length or not isstring(k.Sound) or not isnumber(k.Length) then
            return "Ambient track "..v.." is missing required data."
        end

        if antiCrash[k.Sound] then
            return "Same sound is used more than once, this is not allowed."
        end

        antiCrash[k.Sound] = true
    end

    for v,k in ipairs(json.Combat) do
        if not istable(k) or not k.Sound or not k.Length or not isstring(k.Sound) or not isnumber(k.Length) then
            return "Combat track "..v.." is missing required data."
        end

        if antiCrash[k.Sound] then
            return "Same sound is used more than once, this is not allowed."
        end

        antiCrash[k.Sound] = true
    end

    if json.DeathSound and not isstring(json.DeathSound) then
        return "DeathSound must be a string."
    end

    // comment: compile it
    local comp = {}

    comp.Ambient = {}
    comp.Combat = {}

    for v,k in ipairs(json.Ambient) do
        comp.Ambient[#comp.Ambient + 1] = {k.Sound, k.Length}
    end

    for v,k in ipairs(json.Combat) do
        comp.Combat[#comp.Combat + 1] = {k.Sound, k.Length}
    end

    if json.DeathSound then
        comp.DeathSound = json.DeathSound
    end

    CUSTOM_MUSICKITS[json.Name] = comp

    print("[Helix] [musickits] Loaded "..json.Name.." ("..name..") music kit.")
end

local function GetMusicKits()
    local kits = file.Find("helix/musickits/*.json", "DATA")
    local comp = {}

    for v,k in ipairs(kits) do
        local err = ReadMusicKit(k)

        if err then
            print("[Helix] [musickits] Failed to load "..k.." | "..err)
            continue
        end
    end
end

GetMusicKits()

local names = {"RTBR"}
for v,k in ipairs(CUSTOM_MUSICKITS) do
    names[#names + 1] = v
end

ix.option.Add("musicKitEnabled", ix.type.bool, true, {
    category = "Music Kits"
})

local function createCommand()
    ix.option.Add("musicKit", ix.type.array, "RTBR", {
        category = "Music Kits",
        bNetworked = true,
        populate = function()
            local entries = {}

            for _, v in SortedPairs(names) do
                local name = v

                entries[v] = name
            end

            return entries
        end
    })
end

createCommand()

concommand.Add("ix_reloadmusickits", function()
    print("[Helix] Reloading music kits...")
    CUSTOM_MUSICKITS = {}

    GetMusicKits()

    local names = {"RTBR"}
    for v,k in ipairs(CUSTOM_MUSICKITS) do
        names[#names + 1] = v
    end

    createCommand()
end)

local nextThink = 0
local currentPassive = currentPassive or nil
local currentCombat = currentCombat or nil
local currentPassiveFading = currentPassiveFading or nil
local currentCombatFading = currentCombatFading or nil

timer.Simple(0.3, function()
    if ( currentPassive ) then
        timer.Remove("ixMusicPassiveTrackTime")
        currentPassive:Stop()
    end

    if ( currentCombat ) then
        timer.Remove("ixMusicCombatTrackTime")
        currentCombat:Stop()
    end
end)

ix.option.Add("musicAmbientVol", ix.type.number, 0.2, {
    category = "Music Kits",
    decimals = 1,
    min = 0,
    max = 1,
    OnChanged = function(oldVal, newVal)
        if ( currentPassive ) then
            currentPassive:ChangeVolume(newVal, 0)
        end
    end
})

ix.option.Add("musicCombatVol", ix.type.number, 0.4, {
    category = "Music Kits",
    decimals = 1,
    min = 0,
    max = 1,
    OnChanged = function(oldVal, newVal)
        if ( currentCombat ) then
            currentCombat:ChangeVolume(newVal, 0)
        end
    end
})

function PLUGIN:GetMusicKitDeathSound(ply)
    local kitName = SERVER and ix.option.Get(ply, "musicKit", "RTBR") or ix.option.Get("musicKit", "RTBR")

    if kitName and CUSTOM_MUSICKITS[kitName] and CUSTOM_MUSICKITS[kitName].DeathSound then
        return CUSTOM_MUSICKITS[kitName].DeathSound
    end

    return nil
end

if ( SERVER ) then
    util.AddNetworkString("ixMusicKit.DeathSound")

    function PLUGIN:PlayerHurt(ply, attacker, health, damage)
        if ( IsValid(ply) and ply:GetChar() and IsValid(attacker) ) then
            local uID = "ixMusicKit.CombatTimer." .. ply:SteamID64()

            if not ( timer.Exists(uID) ) then
                ply:SetNetVar("bInCombat", true)

                timer.Create(uID, 60, 1, function()
                    if not ( IsValid(ply) or ply:GetChar() ) then
                        ply:SetNetVar("bInCombat", false)
                        timer.Remove(uID)

                        return
                    end

                    ply:SetNetVar("bInCombat", false)
                end)
            else
                if ( timer.TimeLeft(uID) <= 5 ) then
                    timer.Adjust(uID, 20)
                end
            end
        end

        if ( IsValid(attacker) and attacker:IsPlayer() and attacker:GetChar() ) then
            uID = "ixMusicKit.CombatTimer." .. attacker:SteamID64()
            if not ( timer.Exists(uID) ) then
                attacker:SetNetVar("bInCombat", true)

                timer.Create(uID, 60, 1, function()
                    if not ( IsValid(attacker) or attacker:GetChar() ) then
                        attacker:SetNetVar("bInCombat", false)
                        timer.Remove(uID)

                        return
                    end

                    attacker:SetNetVar("bInCombat", false)
                end)
            else
                if ( timer.TimeLeft(uID) <= 5 ) then
                    timer.Adjust(uID, 20)
                end
            end
        end
    end

    function PLUGIN:PlayerDeath(ply, inflictor, attacker)
        if ( !IsValid(ply) ) then return end

        local char = ply:GetChar()

        if ( !char ) then
            return
        end

        local uID = "ixMusicKit.CombatTimer." .. ply:SteamID64()

        local deathSound = self:GetMusicKitDeathSound(ply)
        if deathSound then
            net.Start("ixMusicKit.DeathSound")
                net.WriteString(deathSound)
            net.Send(ply)
        end

        if ( timer.Exists(uID) ) then
            ply:SetNetVar("bInCombat", false)
            timer.Remove(uID)
        end

        if ( IsValid(attacker) and attacker:IsPlayer() and attacker:GetChar() ) then
            uID = "ixMusicKit.CombatTimer." .. attacker:SteamID64()

            if ( timer.Exists(uID) ) then
                attacker:SetNetVar("bInCombat", false)
                timer.Remove(uID)
            end
        end
    end

    return
end

net.Receive("ixMusicKit.DeathSound", function()
    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    local deathSound = net.ReadString()
    surface.PlaySound(deathSound)
end)

local default = {
    ["Default"] = true,
    ["HalfLife2"] = true,
    ["HalfLife1"] = true,
    ["EpisodeOne"] = true,
    ["EpisodeTwo"] = true,
}

local songLinks = {
    ["HalfLife2"] = {PLUGIN.passiveMusicHL2, PLUGIN.combatMusicHL2},
    ["HalfLife1"] = {PLUGIN.passiveMusicHL1, PLUGIN.combatMusicHL1},
    ["EpisodeOne"] = {PLUGIN.passiveMusicEpisodic, PLUGIN.combatMusicEpisodic},
    ["EpisodeTwo"] = {PLUGIN.passiveMusicEP2, PLUGIN.combatMusicEP2},
    ["HalfLife"] = {PLUGIN.passiveHalfLife, PLUGIN.combatHalfLife},
}

local function GetRandomSong(style)
    local x = PLUGIN.passiveMusic
    if style == "combat" then
        x = PLUGIN.combatMusic
    end

    local kitName = ix.option.Get("musicKit", "RTBR")
    local linkData = songLinks[kitName]

    if ( linkData ) then
        x = linkData[1]

        if style == "combat" then
            x = linkData[2]
        end
    end

    if kitName and not default[kitName] and CUSTOM_MUSICKITS[kitName] then
        if style == "combat" then
            x = CUSTOM_MUSICKITS[kitName].Combat
        else
            x = CUSTOM_MUSICKITS[kitName].Ambient
        end
    end

    local t = x[math.random(1, #x)]
    local r = t[1]

    if lastSongs[r] then
        return GetRandomSong(style)
    end

    local highest = -1
    local lowest = 999999
    local key = ""
    for v,k in pairs(lastSongs) do
        if k < lowest then
            lowest = k
            key = v
        end

        if k > highest then
            highest = k
        end
    end

    if table.Count(lastSongs) > 2 then
        lastSongs[key] = nil
    end

    lastSongs[r] = highest + 1

    DebugPrint("Selected track "..r.." (length: ".. SoundDuration("sound/" .. r) ..")")

    return r, SoundDuration("sound/" .. r)
end

local combatCityCodes = {
    ["turmoil"] = true,
    ["aj"] = true,
    ["jw"] = true,
}

local function InCombat() // comment: simple for now
    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return false end

    local forcedCombat = GetConVar("ix_music_forcecombat"):GetBool()

    if forcedCombat then
        return true
    end

    return hook.Run("IsPlayerInCombat", ply)
end

function PLUGIN:IsPlayerInCombat(ply)
    if ( ply:GetNetVar("bInCombat", false) ) then return true end
    if ( combatCityCodes[GetNetVar("cmb_citycode", "civil")] ) then return true end

    return false
end

function PLUGIN:Think()
    local ctime = CurTime()
    if nextThink > ctime then
        return
    end

    nextThink = ctime + 1

    local kitName = ix.option.Get("musicKit", "RTBR")
    local swap = false

    if lastKitName and kitName != lastKitName then
        swap = true
    end

    lastKitName = kitName

    if swap or LocalPlayer():Team() == 0 or ((ix) and (IsValid(ix.gui.characterMenu) and not ix.gui.characterMenu.popup and ix.gui.characterMenu:IsVisible())) then
        if currentPassive then
            timer.Remove("ixMusicPassiveTrackTime")
            currentPassive:Stop()
        end

        if currentCombat then
            timer.Remove("ixMusicCombatTrackTime")
            currentCombat:Stop()
        end

        return
    end

    if not ix.option.Get("musicKitEnabled", false) or not LocalPlayer():Alive() then
        if currentPassive and currentPassive:IsPlaying() then
            timer.Remove("ixMusicPassiveTrackTime")
            currentPassive:FadeOut(1.5)

            timer.Simple(1.5, function()
                if currentPassive then
                    currentPassive:Stop()
                end
            end)
        end

        if currentCombat and currentCombat:IsPlaying() then
            timer.Remove("ixMusicCombatTrackTime")
            currentCombat:FadeOut(1.5)

            timer.Simple(1.5, function()
                if currentCombat then
                    currentCombat:Stop()
                end
            end)
        end

        return
    end

    local inCombat = InCombat()

    if inCombat then
        if currentPassive and currentPassive:IsPlaying() then
            if not currentPassiveFading then
                timer.Remove("ixMusicPassiveTrackTime")
                currentPassive:FadeOut(6)
                currentPassiveFading = true
                DebugPrint("Fading out ambient to move to combat...")

                timer.Simple(6, function()
                    currentPassive:Stop()
                    currentPassiveFading = false
                    DebugPrint("Stopped ambient track")
                end)
            end
        end

        if not currentCombat or not currentCombat:IsPlaying() then
            local s, l = GetRandomSong("combat")

            currentCombat = CreateSound(LocalPlayer(), s)
            currentCombat:SetSoundLevel(0)
            currentCombat:PlayEx(0, 100)
            currentCombat:ChangeVolume(ix.option.Get("musicCombatVol"), 6)

            DebugPrint("Playing combat track...")

            timer.Remove("ixMusicCombatTrackTime")
            timer.Create("ixMusicCombatTrackTime", l + 2, 1, function()
                if currentCombat then
                    currentCombat:FadeOut(2)
                    DebugPrint("Stopping combat track (track complete)...")
                end
            end)
        end

        return
    elseif currentCombat and currentCombat:IsPlaying() then
        if not currentCombatFading then
            timer.Remove("ixMusicCombatTrackTime")
            currentCombat:ChangeVolume(0, 120)
            currentCombatFading = true
            DebugPrint("Fading out combat to move to ambient...")

            timer.Simple(8, function()
                currentCombat:Stop()
                currentCombatFading = false
                DebugPrint("Stopped combat track")
            end)
        end

        return
    end

    if not currentPassive or not currentPassive:IsPlaying() then
        local s, l = GetRandomSong("passive")

        currentPassive = CreateSound(LocalPlayer(), s)
        currentPassive:SetSoundLevel(0)
        currentPassive:PlayEx(0, 100)
        currentPassive:ChangeVolume(ix.option.Get("musicAmbientVol"), 12)

        DebugPrint("Playing ambient track...")

        timer.Remove("ixMusicPassiveTrackTime")
        timer.Create("ixMusicPassiveTrackTime", l + 2, 1, function()
            if currentPassive then
                currentPassive:FadeOut(2)
                DebugPrint("Stopping ambient track (track complete)...")
            end
        end)
    end
end
