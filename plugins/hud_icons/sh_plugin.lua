local PLUGIN = PLUGIN

PLUGIN.name = "Icon HUD"
PLUGIN.author = "AI"
PLUGIN.description = "A minimalist icon-based HUD for player stats."

if CLIENT then
    -- Icon paths
    local ICONS = {
        { key = "health",  mat = Material("mrp/hud/health.png", "smooth"),  color = Color(200, 60, 60),  get = function() return LocalPlayer():Health() / math.max(LocalPlayer():GetMaxHealth(), 1) end },
        { key = "armor",   mat = Material("mrp/hud/armor.png", "smooth"),   color = Color(80, 120, 200), get = function() return LocalPlayer():Armor() / 100 end },
        { key = "hunger",  mat = Material("mrp/hud/hunger.png", "smooth"),  color = Color(200, 180, 80), get = function() return 1 end }, -- No functionality yet
        { key = "thirst",  mat = Material("mrp/hud/thirst.png", "smooth"),  color = Color(80, 180, 220), get = function() return 1 end }, -- No functionality yet
    }

    -- Icon size and spacing
    local BASE_SIZE = 200
    local scale = math.min(ScrH(), ScrW()) / 1080 -- scale for 1080p and up
    local ICON_SIZE = math.max(ScreenScale(32), BASE_SIZE * 0.18 * scale) -- ~36px at 1080p, scales up
    local ICON_SPACING = ICON_SIZE * 0.10
    local HUD_MARGIN = ScreenScale(12)

    -- Flashing parameters
    local FLASH_SPEED = 1.2 -- seconds per cycle
    local DARK_COLOR = Color(50, 50, 50)

    hook.Add("HUDPaint", "ixIconHUD", function()
        if (!IsValid(LocalPlayer()) or !LocalPlayer():Alive()) then return end
        local x = HUD_MARGIN - ScreenScale(8) -- move icons further to the left
        local y = ScrH() - HUD_MARGIN - ICON_SIZE + ScreenScale(12) -- move icons down very slightly
        for i, icon in ipairs(ICONS) do
            local frac = math.Clamp(icon.get(), 0, 1)
            local mat = icon.mat
            local color = icon.color
            -- Draw dark background icon
            local flash = 1
            if frac <= 0 then
                flash = 0.5 + 0.5 * math.sin(CurTime() * (2 * math.pi / FLASH_SPEED))
            end
            surface.SetMaterial(mat)
            surface.SetDrawColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, 255 * flash)
            surface.DrawTexturedRect(x, y, ICON_SIZE, ICON_SIZE)
            -- Draw colored foreground icon, cropped from top to bottom
            if frac > 0 then
                local cropH = ICON_SIZE * frac
                local cropY = y + (ICON_SIZE - cropH)
                -- Draw only the lower portion of the icon using UV cropping
                surface.SetMaterial(mat)
                surface.SetDrawColor(color)
                surface.DrawTexturedRectUV(
                    x, cropY, ICON_SIZE, cropH,
                    0, 1 - frac, 1, 1
                )
            end
            x = x + ICON_SIZE + ICON_SPACING
        end
    end)

    -- Optionally hide default bars
    hook.Add("CreateBars", "ixIconHUD_HideBars", function()
        return false
    end)
end 