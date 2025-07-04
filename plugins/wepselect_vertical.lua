local PLUGIN = PLUGIN

PLUGIN.name = "Weapon Select Vertical"
PLUGIN.author = "Chessnut, Modified by AI"
PLUGIN.description = "A vertical, boxed weapon selection UI."

if (CLIENT) then
    -- Move getBoxMetrics to the top of the CLIENT block so it's always defined before use
    local function getBoxMetrics()
        local boxWidth = ScreenScale(26)
        local boxHeight = ScreenScale(16)
        local boxSpacing = ScreenScale(3)
        local font = "ixWeaponSelectFontSmall"
        return boxWidth, boxHeight, boxSpacing, font
    end

    PLUGIN.index = PLUGIN.index or 1
    PLUGIN.deltaIndex = PLUGIN.deltaIndex or PLUGIN.index
    PLUGIN.infoAlpha = PLUGIN.infoAlpha or 0
    PLUGIN.alpha = PLUGIN.alpha or 0
    PLUGIN.alphaDelta = PLUGIN.alphaDelta or PLUGIN.alpha
    PLUGIN.fadeTime = PLUGIN.fadeTime or 0

    function PLUGIN:LoadFonts(baseFont, genericFont)
        surface.CreateFont("ixWeaponSelectFontSmall", {
            font = baseFont,
            size = ScreenScale(13),
            extended = true,
            weight = 1000
        })
    end

    function PLUGIN:HUDShouldDraw(name)
        if (name == "CHudWeaponSelection") then return false end
    end

    function PLUGIN:HUDPaint()
        local frameTime = FrameTime()
        self.alphaDelta = Lerp(frameTime * 10, self.alphaDelta, self.alpha)
        local fraction = self.alphaDelta
        if (fraction > 0.01) then
            local boxWidth, boxHeight, boxSpacing, font = getBoxMetrics()
            local weapons = LocalPlayer():GetWeapons()
            local numSlots = math.max(6, #weapons)
            local totalHeight = numSlots * boxHeight + (numSlots - 1) * boxSpacing
            local x = math.Clamp(ScrW() * 0.02, 8, ScrW() - boxWidth - 8)
            -- Vertically center the stack
            local y = (ScrH() - totalHeight) / 2
            self.deltaIndex = Lerp(frameTime * 12, self.deltaIndex, self.index)
            local index = self.deltaIndex
            if (!weapons[self.index]) then
                self.index = #weapons
            end
            for i = 1, numSlots do
                local isSelected = (i == self.index)
                local boxColor = isSelected and Color(80, 80, 80, 220) or Color(40, 40, 40, 200)
                local borderColor = isSelected and Color(180, 180, 180, 255) or Color(80, 80, 80, 255)
                local textColor = isSelected and color_white or Color(200, 200, 200, 255)
                local slotY = y + (i - 1) * (boxHeight + boxSpacing)
                draw.RoundedBox(4, x, slotY, boxWidth, boxHeight, boxColor)
                surface.SetDrawColor(borderColor)
                surface.DrawOutlinedRect(x, slotY, boxWidth, boxHeight, 1)
                draw.SimpleText("[" .. i .. "]", font, x + boxWidth / 2, slotY + boxHeight / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                if isSelected and weapons[i] then
                    local weaponName = language.GetPhrase(weapons[i]:GetClass()):utf8upper()
                    if (weapons[i].GetPrintName) then
                        weaponName = weapons[i]:GetPrintName():utf8upper()
                    end
                    draw.SimpleText(weaponName, font, x + boxWidth + ScreenScale(8), slotY + boxHeight / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
            if (self.fadeTime < CurTime() and self.alpha > 0) then
                self.alpha = 0
            end
        end
    end

    function PLUGIN:OnIndexChanged(weapon)
        self.alpha = 1
        self.fadeTime = CurTime() + 5
        self.markup = nil
        if (IsValid(weapon)) then
            local instructions = weapon.Instructions
            local text = ""
            if (instructions != nil and instructions:find("%S")) then
                local color = ix.config.Get("color")
                text = text .. string.format(
                    "<font=ixItemBoldFont><color=%d,%d,%d>%s</font></color>\n%s\n",
                    color.r, color.g, color.b, L("Instructions"), instructions
                )
            end
            if (text != "") then
                self.markup = markup.Parse("<font=ixItemDescFont>"..text, ScrW() * 0.3)
                self.infoAlpha = 0
            end
            local source, pitch = hook.Run("WeaponCycleSound")
            LocalPlayer():EmitSound(source or "common/talk.wav", 50, pitch or 180)
        end
    end

    function PLUGIN:PlayerBindPress(client, bind, pressed)
        bind = bind:lower()
        if (!pressed or !bind:find("invprev") and !bind:find("invnext")
        and !bind:find("slot") and !bind:find("attack")) then return end
        local currentWeapon = client:GetActiveWeapon()
        local bValid = IsValid(currentWeapon)
        local bTool
        if (client:InVehicle() or (bValid and currentWeapon:GetClass() == "weapon_physgun" and client:KeyDown(IN_ATTACK))) then return end
        if (bValid and currentWeapon:GetClass() == "gmod_tool") then
            local tool = client:GetTool()
            bTool = tool and (tool.Scroll != nil)
        end
        local weapons = client:GetWeapons()
        if (bind:find("invprev") and !bTool) then
            local oldIndex = self.index
            self.index = math.max(self.index - 1, 1)
            if (self.alpha == 0 or oldIndex != self.index) then
                self:OnIndexChanged(weapons[self.index])
            end
            return true
        elseif (bind:find("invnext") and !bTool) then
            local oldIndex = self.index
            self.index = math.min(self.index + 1, #weapons)
            if (self.alpha == 0 or oldIndex != self.index) then
                self:OnIndexChanged(weapons[self.index])
            end
            return true
        elseif (bind:find("slot")) then
            self.index = math.Clamp(tonumber(bind:match("slot(%d)")) or 1, 1, #weapons)
            self:OnIndexChanged(weapons[self.index])
            return true
        elseif (bind:find("attack") and self.alpha > 0) then
            local weapon = weapons[self.index]
            if (IsValid(weapon)) then
                LocalPlayer():EmitSound(hook.Run("WeaponSelectSound", weapon) or "HL2Player.Use")
                input.SelectWeapon(weapon)
                self.alpha = 0
            end
            return true
        end
    end

    function PLUGIN:Think()
        local client = LocalPlayer()
        if (!IsValid(client) or !client:Alive()) then
            self.alpha = 0
        end
    end

    function PLUGIN:ScoreboardShow()
        self.alpha = 0
    end

    function PLUGIN:ShouldPopulateEntityInfo(entity)
        if (self.alpha > 0) then return false end
    end
end 