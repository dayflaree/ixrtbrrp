local PLUGIN = PLUGIN

PLUGIN.name = "Icon HUD"
PLUGIN.author = "AI"
PLUGIN.description = "A minimalist icon-based HUD for player stats."

if CLIENT then
    -- Icon paths
    local ICONS = {
        { key = "health",  mat = Material("mrp/hud/health.png", "smooth"),  color = Color(255, 255, 255),  get = function() return LocalPlayer():Health() / math.max(LocalPlayer():GetMaxHealth(), 1) end },
        { key = "armor",   mat = Material("mrp/hud/armor.png", "smooth"),   color = Color(255, 255, 255), get = function() return LocalPlayer():Armor() / 100 end },
        { key = "hunger",  mat = Material("mrp/hud/hunger.png", "smooth"),  color = Color(255, 255, 255), get = function() return 1 end }, -- No functionality yet
        { key = "thirst",  mat = Material("mrp/hud/thirst.png", "smooth"),  color = Color(255, 255, 255), get = function() return 1 end }, -- No functionality yet
    }

    -- Icon size and spacing
    local BASE_SIZE = 200
    local scale = math.min(ScrH(), ScrW()) / 1080 -- scale for 1080p and up
    local ICON_SIZE = math.max(ScreenScale(32), BASE_SIZE * 0.18 * scale) -- ~36px at 1080p, scales up
    local ICON_SPACING = ICON_SIZE * 0.10
    local HUD_MARGIN = ScreenScale(12)

    -- Animation variables for smooth icon transitions
    local iconPositions = {}
    local iconAlphas = {}
    local animationSpeed = 8 -- higher = faster animation

    -- Initialize icon positions and alphas
    for i, icon in ipairs(ICONS) do
        iconPositions[i] = 0
        iconAlphas[i] = 0
    end

    -- Flashing parameters
    local FLASH_SPEED = 1.2 -- seconds per cycle
    local DARK_COLOR = Color(50, 50, 50)

    -- Stamina bar images
    local STAMINA_LEFT = Material("mrp/hud/bar/corner.png", "smooth")
    local STAMINA_MID = Material("mrp/hud/bar/center.png", "smooth")
    local STAMINA_RIGHT = Material("mrp/hud/bar/corner_right.png", "smooth")

    -- Bar dimensions (adjust to match yellow bar in screenshot)
    local BAR_X = ScreenScale(8)
    local BAR_Y = ScreenScale(4) -- moved up
    local BAR_HEIGHT = ScreenScale(8)
    local BAR_WIDTH = ScreenScale(180) -- Adjust as needed

    local END_WIDTH = BAR_HEIGHT -- Square ends
    local MID_WIDTH = BAR_WIDTH - END_WIDTH * 2

    -- Stamina bar fade logic
    local staminaAlpha = 0
    local fadeSpeed = 800 -- alpha per second (even faster fade)

    -- Stamina fill bar images
    local STAMINA_FILL_LEFT = Material("mrp/hud/bar/corner_fill.png", "smooth")
    local STAMINA_FILL_MID = Material("mrp/hud/bar/center_fill.png", "smooth")
    local STAMINA_FILL_RIGHT = Material("mrp/hud/bar/corner_fillb.png", "smooth")

    -- Color for the stamina fill bar
    local STAMINA_FILL_COLOR = Color(171, 171, 171)

    local displayedFrac = 1
    local fillLerpSpeed = 6 -- higher = snappier, lower = smoother

    -- Ammo counter background color fade state
    local ammoBgColor = {r = 40, g = 40, b = 40, a = 200}
    local ammoBgTarget = {r = 40, g = 40, b = 40, a = 200}
    local ammoBgOrig = {r = 40, g = 40, b = 40, a = 200}
    local ammoBgFiring = {r = 80, g = 80, b = 80, a = 220}
    local ammoFadeSpeed = 10 -- higher = faster fade

    hook.Add("HUDPaint", "ixIconHUD", function()
        if (!IsValid(LocalPlayer()) or !LocalPlayer():Alive()) then return end
        
        -- Only show HUD icons when inventory is open
        if not IsValid(ix.gui.inv1) or not ix.gui.inv1:IsVisible() then return end
        
        local x = HUD_MARGIN - ScreenScale(8) -- move icons further to the left
        local y = ScrH() - HUD_MARGIN - ICON_SIZE + ScreenScale(12) -- move icons down very slightly
        
        -- Calculate which icons should be visible and their target positions
        local visibleIcons = {}
        local currentX = x
        
        for i, icon in ipairs(ICONS) do
            local frac = math.Clamp(icon.get(), 0, 1)
            
            -- Only show icon if it has a value > 0
            if frac > 0 then
                table.insert(visibleIcons, {
                    index = i,
                    icon = icon,
                    targetX = currentX,
                    frac = frac
                })
                currentX = currentX + ICON_SIZE + ICON_SPACING
            end
        end
        
        -- Animate icon positions and alphas
        for i, icon in ipairs(ICONS) do
            local targetAlpha = 0
            local targetPosition = 0
            
            -- Find if this icon should be visible
            for _, visibleIcon in ipairs(visibleIcons) do
                if visibleIcon.index == i then
                    targetAlpha = 255
                    targetPosition = visibleIcon.targetX - x
                    break
                end
            end
            
            -- Smoothly animate alpha
            iconAlphas[i] = Lerp(FrameTime() * animationSpeed, iconAlphas[i], targetAlpha)
            
            -- Smoothly animate position
            iconPositions[i] = Lerp(FrameTime() * animationSpeed, iconPositions[i], targetPosition)
        end
        
        -- Draw visible icons with animations
        for i, icon in ipairs(ICONS) do
            local alpha = iconAlphas[i]
            if alpha <= 0 then continue end
            
            local frac = math.Clamp(icon.get(), 0, 1)
            local mat = icon.mat
            local color = icon.color
            local drawX = x + iconPositions[i]
            
            -- Apply alpha to colors
            local darkColor = Color(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, alpha)
            local iconColor = Color(color.r, color.g, color.b, alpha)
            
            -- Draw dark background icon
            surface.SetMaterial(mat)
            surface.SetDrawColor(darkColor)
            surface.DrawTexturedRect(drawX, y, ICON_SIZE, ICON_SIZE)
            
            -- Draw colored foreground icon, cropped from top to bottom
            if frac > 0 then
                local cropH = ICON_SIZE * frac
                local cropY = y + (ICON_SIZE - cropH)
                surface.SetMaterial(mat)
                surface.SetDrawColor(iconColor)
                surface.DrawTexturedRectUV(
                    drawX, cropY, ICON_SIZE, cropH,
                    0, 1 - frac, 1, 1
                )
            end
        end
    end)

    -- Optionally hide default bars
    hook.Add("CreateBars", "ixIconHUD_HideBars", function()
        return false
    end)

    hook.Add("HUDPaint", "ixStaminaBarEmpty", function()
        local stm = LocalPlayer():GetLocalVar("stm", 100)
        local belowMax = stm < 100
        local frac = math.Clamp(stm / 100, 0, 1)

        -- Hide stamina bar when inventory is open
        if IsValid(ix.gui.inv1) and ix.gui.inv1:IsVisible() then return end

        -- Smoothly interpolate the displayed fill
        displayedFrac = Lerp(FrameTime() * fillLerpSpeed, displayedFrac, frac)

        -- Fade in/out
        if belowMax then
            staminaAlpha = math.min(255, staminaAlpha + FrameTime() * fadeSpeed)
        else
            staminaAlpha = math.max(0, staminaAlpha - FrameTime() * fadeSpeed)
        end

        if staminaAlpha <= 0 then return end

        -- Draw empty bar (background)
        surface.SetMaterial(STAMINA_LEFT)
        surface.SetDrawColor(255, 255, 255, staminaAlpha)
        surface.DrawTexturedRect(BAR_X, BAR_Y, END_WIDTH, BAR_HEIGHT)

        surface.SetMaterial(STAMINA_MID)
        surface.SetDrawColor(255, 255, 255, staminaAlpha)
        surface.DrawTexturedRect(BAR_X + END_WIDTH, BAR_Y, MID_WIDTH, BAR_HEIGHT)

        surface.SetMaterial(STAMINA_RIGHT)
        surface.SetDrawColor(255, 255, 255, staminaAlpha)
        surface.DrawTexturedRect(BAR_X + END_WIDTH + MID_WIDTH, BAR_Y, END_WIDTH, BAR_HEIGHT)

        -- Draw fill bar (foreground, improved logic)
        if displayedFrac > 0 then
            local fillTotal = BAR_WIDTH * displayedFrac

            if fillTotal <= END_WIDTH then
                -- Only enough for cropped left end
                surface.SetMaterial(STAMINA_FILL_LEFT)
                surface.SetDrawColor(STAMINA_FILL_COLOR.r, STAMINA_FILL_COLOR.g, STAMINA_FILL_COLOR.b, staminaAlpha)
                surface.DrawTexturedRect(BAR_X, BAR_Y, fillTotal, BAR_HEIGHT)
            elseif fillTotal <= END_WIDTH * 2 then
                -- Enough for full left and cropped right
                surface.SetMaterial(STAMINA_FILL_LEFT)
                surface.SetDrawColor(STAMINA_FILL_COLOR.r, STAMINA_FILL_COLOR.g, STAMINA_FILL_COLOR.b, staminaAlpha)
                surface.DrawTexturedRect(BAR_X, BAR_Y, END_WIDTH, BAR_HEIGHT)

                local rightW = fillTotal - END_WIDTH
                if rightW > 0 then
                    surface.SetMaterial(STAMINA_FILL_RIGHT)
                    surface.SetDrawColor(STAMINA_FILL_COLOR.r, STAMINA_FILL_COLOR.g, STAMINA_FILL_COLOR.b, staminaAlpha)
                    surface.DrawTexturedRect(BAR_X + END_WIDTH, BAR_Y, rightW, BAR_HEIGHT)
                end
            else
                -- Enough for full left, middle, and full right
                surface.SetMaterial(STAMINA_FILL_LEFT)
                surface.SetDrawColor(STAMINA_FILL_COLOR.r, STAMINA_FILL_COLOR.g, STAMINA_FILL_COLOR.b, staminaAlpha)
                surface.DrawTexturedRect(BAR_X, BAR_Y, END_WIDTH, BAR_HEIGHT)

                local fillMidW = fillTotal - END_WIDTH * 2
                surface.SetMaterial(STAMINA_FILL_MID)
                surface.SetDrawColor(STAMINA_FILL_COLOR.r, STAMINA_FILL_COLOR.g, STAMINA_FILL_COLOR.b, staminaAlpha)
                surface.DrawTexturedRectUV(
                    BAR_X + END_WIDTH, BAR_Y,
                    fillMidW, BAR_HEIGHT,
                    0, 0, fillMidW / MID_WIDTH, 1
                )

                surface.SetMaterial(STAMINA_FILL_RIGHT)
                surface.SetDrawColor(STAMINA_FILL_COLOR.r, STAMINA_FILL_COLOR.g, STAMINA_FILL_COLOR.b, staminaAlpha)
                surface.DrawTexturedRect(BAR_X + fillTotal - END_WIDTH, BAR_Y, END_WIDTH, BAR_HEIGHT)
            end
        end
    end)

    -- Hide default Helix ammo counter
    hook.Add("CanDrawAmmoHUD", "ixHideDefaultAmmoHUD", function()
        return false
    end)

    -- Custom ammo counter HUD
    hook.Add("HUDPaint", "ixCustomAmmoCounter", function()
        local lp = LocalPlayer()
        if not IsValid(lp) or not lp:Alive() then return end
        
        -- Hide ammo counter when inventory is open
        if IsValid(ix.gui.inv1) and ix.gui.inv1:IsVisible() then return end
        
        local wep = lp:GetActiveWeapon()
        if not IsValid(wep) or not wep:Clip1() or wep:Clip1() < 0 then return end
        local clip = wep:Clip1()
        local reserve = lp:GetAmmoCount(wep:GetPrimaryAmmoType())

        -- Only show for weapons with a clip (not fists, tools, etc.)
        if wep:GetMaxClip1() <= 0 then return end

        -- Detect firing
        local isFiring = lp:KeyDown(IN_ATTACK) and clip > 0
        if isFiring then
            ammoBgTarget = ammoBgFiring
        else
            ammoBgTarget = ammoBgOrig
        end
        -- Smoothly approach target color
        ammoBgColor.r = Lerp(FrameTime() * ammoFadeSpeed, ammoBgColor.r, ammoBgTarget.r)
        ammoBgColor.g = Lerp(FrameTime() * ammoFadeSpeed, ammoBgColor.g, ammoBgTarget.g)
        ammoBgColor.b = Lerp(FrameTime() * ammoFadeSpeed, ammoBgColor.b, ammoBgTarget.b)
        ammoBgColor.a = Lerp(FrameTime() * ammoFadeSpeed, ammoBgColor.a, ammoBgTarget.a)

        -- Format: [clip/reserve]
        local text = string.format("[%d/%d]", clip, reserve)

        -- Style
        surface.SetFont("ixMediumFont" or "DermaLarge")
        local tw, th = surface.GetTextSize(text)
        local padding = ScreenScale(8)
        local boxW, boxH = tw + padding * 2, th + padding * 2
        local x = ScrW() - boxW - ScreenScale(8)
        local y = ScrH() - boxH - ScreenScale(6)

        -- Draw background square
        surface.SetDrawColor(math.Round(ammoBgColor.r), math.Round(ammoBgColor.g), math.Round(ammoBgColor.b), math.Round(ammoBgColor.a))
        surface.DrawRect(x, y, boxW, boxH)
        -- Draw border
        surface.SetDrawColor(180, 180, 180, 255)
        surface.DrawOutlinedRect(x, y, boxW, boxH, 1)

        -- Draw square brackets
        local bracketPad = ScreenScale(2)
        local bracketSpine = 2 -- vertical line thickness
        local bracketThickness = 1 -- horizontal line thickness
        surface.SetDrawColor(220, 220, 220, 255)
        -- Left bracket
        surface.DrawRect(x + bracketPad, y + bracketPad, bracketSpine, boxH - bracketPad * 2)
        surface.DrawRect(x + bracketPad, y + bracketPad, (boxW / 16), bracketThickness)
        surface.DrawRect(x + bracketPad, y + boxH - bracketPad - bracketThickness, (boxW / 16), bracketThickness)
        -- Right bracket
        surface.DrawRect(x + boxW - bracketPad - bracketSpine, y + bracketPad, bracketSpine, boxH - bracketPad * 2)
        surface.DrawRect(x + boxW - (boxW / 16) - bracketPad, y + bracketPad, (boxW / 16), bracketThickness)
        surface.DrawRect(x + boxW - (boxW / 16) - bracketPad, y + boxH - bracketPad - bracketThickness, (boxW / 16), bracketThickness)

        -- Draw text
        draw.SimpleText(text, "ixMediumFont" or "DermaLarge", x + boxW / 2, y + boxH / 2, Color(220,220,220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
end 