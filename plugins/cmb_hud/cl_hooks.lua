/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:ShouldDrawCombineHud()
    if ( IsValid(ix.gui.menu) and !ix.gui.menu.bClosing ) then return false end
    if ( IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing() ) then return false end

    local ply = LocalPlayer()
    if ( !IsValid(ply) ) then return false end
    if ( ply:CanOverrideView() ) then return false end

    local char = ply:GetCharacter()
    if ( !char ) then return false end

    local inventory = char:GetInventory()
    if ( !inventory ) then return false end

    if ( !inventory:HasEquipped("clothing_cp_uniform") ) then return false end
    if ( !inventory:HasEquipped("clothing_cp_mask") ) then return false end

    return true
end

function PLUGIN:LoadFonts()
    for i = 4, 32, 2 do
        // Combine font
        surface.CreateFont("BlackwatchCombineFont" .. i, {
            font = "Courier New",
            size = i,
            weight = 400
        })
    end
end

local randomMessages = {
    "Analyzing Minerva Metastasis...",
    "Analyzing Overwatch protocols...",
    "Appending all data to black box...",
    "Caching internal watch protocols...",
    "Caching new response protocols...",
    "Calculating the duration of patrol...",
    "Checking exodus protocol status...",
    "Command uplink established...",
    "Creating ID's for internal structs...",
    "Creating socket for incoming connection...",
    "Dumping cache data and renewing from external memory...",
    "Encoding network messages...",
    "Establishing Clockwork protocols...",
    "Establishing DC link...",
    "Establishing connection to long term maintenance procedures...",
    "Establishing connection with overwatch...",
    "Establishing variables for connection hooks...",
    "Filtering incoming messages...",
    "Idle connection...",
    "Inititaing self-maintenance scan...",
    "Looking up CP-5 Main...",
    "Looking up active fireteam control centers...",
    "Looking up front end codebase changes...",
    "Looking up main protocols...",
    "Opening up aura scanners...",
    "Parsing heads-up display and data arrays...",
    "Pinging loopback...",
    "Querying database for new cadets... RESPONSE: OK",
    "Refreshing primary database connections...",
    "Regaining equalization modules...",
    "Scanning for active biosignals...",
    "Sending commdata to dispatch...",
    "Sensoring proximity...",
    "Software status nominal...",
    "Synchronizing database records...",
    "Transmitting physical transition vector...",
    "Updating Minerva Metastasis...",
    "Updating Translation Matrix...",
    "Updating biosignal co-ordinates...",
    "Updating cid registry link...",
    "Updating data connections...",
    "Updating railroad activity monitors...",
    "Updating squad statuses...",
    "Updating squad uplink interface...",
    "Validating Minerva Metastasis...",
    "Validating memory replacement integrity...",
    "Verifying Playback of Minerva Metastasis.",
    "Visual uplink status code: GREEN...",
    "Working deconfliction with other ground assets..."
}

local storedMessages = {}
local lerpX = {}
local lerpY = {}

local function DrawText(text, scale, x, y, color, xAlign, yAlign)
    local textWidth, textHeight = draw.SimpleTextOutlined(text, "BlackwatchCombineFont" .. scale, x, y, color, xAlign, yAlign, 1, color_black)
    return textWidth, textHeight
end

local function Approach(delta, current, target)
    return Lerp(math.ease.OutSine(delta), current, target)
end

local padding = ScreenScale(16)
local extraPadding = ScreenScale(32)
local color_cyan = Color(0, 255, 255)
local color_red = Color(255, 0, 0)
local color_green = Color(0, 255, 0)

local nextMessage = 0
local messagesY = 0
local function DrawMessages()
    local scrW, scrH = ScrW(), ScrH()

    if ( nextMessage < CurTime() ) then
        local availableMessages = {}
        for k, v in pairs(randomMessages) do
            local bAlreadyExists = false
            for _, v2 in pairs(storedMessages) do
                if ( v == v2.text ) then
                    bAlreadyExists = true
                    break
                end
            end

            if ( !bAlreadyExists ) then
                table.insert(availableMessages, v)
            end
        end

        local randomMessage = availableMessages[math.random(1, #availableMessages)]
        table.insert(storedMessages, {text = randomMessage, time = CurTime() + math.random(30, 60), id = #storedMessages + 1})

        nextMessage = CurTime() + math.random(15, 45)
    end

    local frameTime = FrameTime()
    local time = frameTime * 4
    local textWidth, textHeight
    local y = extraPadding
    for k, v in pairs(storedMessages) do
        local id = v.id
        local text = string.upper(v.text)
        textWidth, textHeight = ix.util.GetTextSize("<:: " .. text, "BlackwatchCombineFont16")

        if ( !lerpX[id] ) then
            lerpX[id] = padding
        else
            if ( v.time < CurTime() ) then
                if ( lerpX[id] < -textWidth * 0.95 ) then
                    storedMessages[k] = nil
                    lerpX[id] = nil
                    lerpY[id] = nil
                else
                    lerpX[id] = Approach(time, lerpX[id], -(textWidth))
                end
            else
                lerpX[id] = Approach(time, lerpX[id], padding)
            end
        end

        if ( !lerpY[id] ) then
            lerpY[id] = -padding
        else
            lerpY[id] = Approach(time, lerpY[id], y)
        end

        if ( !lerpX[id] or !lerpY[id] ) then continue end

        textWidth, textHeight = DrawText("<:: " .. text, 16, lerpX[id], lerpY[id], color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        y = y + textHeight
    end

    messagesY = y
end

local unitsY = 0
local function DrawUnits()
    local y = messagesY + padding
    for k, v in player.Iterator() do
        if ( !v:IsCombine() ) then continue end

        local char = v:GetCharacter()
        if ( !char ) then continue end

        local color = color_white
        if ( v == ply ) then
            color = color_green
        end

        if ( !v:Alive() ) then
            color = color_red
        end

        local zone = "BIOSIGNAL ZONE: UNKNOWN"
        local area = v:GetArea()
        if ( area ) then
            zone = "BIOSIGNAL ZONE: " .. area:utf8upper()
        end

        local name = char:GetName():utf8upper()
        local health = math.max(0, v:Health())
        local armor = math.max(0, v:Armor())

        textWidth, textHeight = DrawText("<:: " .. name, 16, padding, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        textWidth, textHeight = DrawText(" " .. zone, 16, padding * 5, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        textWidth, textHeight = DrawText(" VITALS: " .. health, 16, padding * 9, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if ( armor > 0 ) then
            textWidth, textHeight = DrawText(" PCV: " .. armor, 16, padding * 11, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        y = y + textHeight
    end

    unitsY = y
end

function PLUGIN:HUDPaint()
    if ( hook.Run("ShouldDrawCombineHud") == false ) then return end

    local ply = LocalPlayer()
    local char = ply:GetCharacter()
    local inventory = char:GetInventory()

    if ( !inventory:HasEquipped("clothing_cp_uniform") ) then return end
    if ( !inventory:HasEquipped("clothing_cp_mask") ) then return end

    DrawMessages()
    DrawUnits()
end