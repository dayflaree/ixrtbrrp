-- main character menu panel
local PANEL = {}

AccessorFunc(PANEL, "bUsingCharacter", "UsingCharacter", FORCE_BOOL)

function PANEL:Init()
    local parent = self:GetParent()
    local padding = self:GetPadding()
    local halfWidth = ScrW() / 2
    local halfHeight = ScrH() / 2
    local halfPadding = padding / 2
    local bHasCharacter = #ix.characters > 0

    self.currentAlpha = 255
    self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
    self:DockPadding(padding, padding, padding, padding)

    local infoLabel = self:Add("DLabel")
    infoLabel:SetTextColor(Color(255, 255, 255, 25))
    infoLabel:SetFont("ixMenuMiniFont")
    infoLabel:SetText(L("helix") .. " " .. GAMEMODE.Version)
    infoLabel:SizeToContents()
    infoLabel:SetPos(ScrW() - infoLabel:GetWide() - 4, ScrH() - infoLabel:GetTall() - 4)

    -- title label
    local titleLabel = self:Add("DLabel")
    titleLabel:SetFont("synapse.hl2.small")
    titleLabel:SetText("R A S I N G  T H E  B A R : R E D U X")
    titleLabel:SizeToContents()
    titleLabel:SetPos(halfWidth - titleLabel:GetWide() / 2, halfHeight - titleLabel:GetTall() * 2)
    titleLabel:SetExpensiveShadow(4, Color(0, 0, 0, 200))
    titleLabel:SetColor(Color(101, 117, 87))

    -- subtitle label
    local subtitleLabel = self:Add("DLabel")
    subtitleLabel:SetFont("synapse.din.medium")
    subtitleLabel:SetText("R   O   L   E   P   L   A   Y")
    subtitleLabel:SizeToContents()
    subtitleLabel:SetWide(titleLabel:GetWide())
    subtitleLabel:SetContentAlignment(5)
    subtitleLabel:SetPos(halfWidth - subtitleLabel:GetWide() / 2, halfHeight - subtitleLabel:GetTall())
    subtitleLabel:SetExpensiveShadow(4, Color(0, 0, 0, 200))
    subtitleLabel:SetColor(color_white)
    subtitleLabel.PaintOver = function(_, width, height)
		surface.SetDrawColor(color_white)
		surface.DrawRect(0, height / 2, width / 5, 2)
		surface.DrawRect(width / 5 * 4, height / 2, width / 5, 2)
    end

    -- button list
    self.buttonList = self:Add("synapse.maimenu.button.list")

    if ( bHasCharacter ) then
        -- create character button
        local createButton = self.buttonList:Add("synapse.button")
        createButton:SetText("create")
        createButton:SizeToContents()
        createButton.DoClick = function()
            local maximum = hook.Run("GetMaxPlayerCharacter", LocalPlayer()) or ix.config.Get("maxCharacters", 5)
            -- don't allow creation if we've hit the character limit
            if (#ix.characters >= maximum) then
                self:GetParent():ShowNotice(3, L("maxCharacters"))
                return
            end

            self:Dim()
            parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
            parent.newCharacterPanel:SlideUp()
        end

        -- load character button
        self.loadButton = self.buttonList:Add("synapse.button")
        self.loadButton:SetText("load")
        self.loadButton:SizeToContents()
        self.loadButton.DoClick = function()
            self:Dim()
            parent.loadCharacterPanel:SlideUp()
        end

        -- community button
        local extraURL = ix.config.Get("communityURL", "")
        local extraText = ix.config.Get("communityText", "@community")

        if (extraURL != "" and extraText != "") then
            if (extraText:sub(1, 1) == "@") then
                extraText = L(extraText:sub(2))
            end

            local extraButton = self.buttonList:Add("synapse.button")
            extraButton:SetText(extraText, true)
            extraButton:SizeToContents()
            extraButton.DoClick = function()
                gui.OpenURL(extraURL)
            end
        end

        if ( self.bUsingCharacter ) then
            -- leave/return button
            self.returnButton = self.buttonList:Add("synapse.button")
            self:UpdateReturnButton()
            self.returnButton.DoClick = function()
                if (self.bUsingCharacter) then
                    parent:Close()
                else
                    RunConsoleCommand("disconnect")
                end
            end
        end

        self.buttonList:SizeToContents()
    else
        -- create character button
        local playButton = self.buttonList:Add("synapse.button")
        playButton:Dock(FILL)
        playButton:SetText("play")
        playButton:SizeToContents()
        playButton.DoClick = function()
            self:Dim()
            parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
            parent.newCharacterPanel:SlideUp()
        end

        self.buttonList:SizeToContents()

        playButton:Center()
    end
end

function PANEL:UpdateReturnButton(bValue)
    if (bValue != nil) then
        self.bUsingCharacter = bValue
    end

    if ( IsValid(self.returnButton) ) then
        self.returnButton:SetText(self.bUsingCharacter and "return" or "leave")
        self.returnButton:SizeToContents()

        self.buttonList:SizeToContents()
    end
end

function PANEL:OnDim()
    -- disable input on this panel since it will still be in the background while invisible - prone to stray clicks if the
    -- panels overtop slide out of the way
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)

    self:CreateAnimation(0.5, {
        index = 2,
        target = {currentAlpha = 0},
        easing = "outQuint",
        Think = function(animation, panel)
            for k, v in pairs(panel:GetChildren()) do
                if (IsValid(v)) then
                    v:SetAlpha(panel.currentAlpha)
                end
            end
        end
    })
end

function PANEL:OnUndim()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)

    -- we may have just deleted a character so update the status of the return button
    self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
    self:UpdateReturnButton()

    self:CreateAnimation(2, {
        index = 2,
        target = {currentAlpha = 255},
        easing = "outQuint",
        Think = function(animation, panel)
            for k, v in pairs(panel:GetChildren()) do
                if (IsValid(v)) then
                    v:SetAlpha(panel.currentAlpha)
                end
            end
        end
    })
end

function PANEL:OnClose()
    for _, v in pairs(self:GetChildren()) do
        if (IsValid(v)) then
            v:SetVisible(false)
        end
    end
end

function PANEL:PerformLayout(width, height)
    self.buttonList:Center()
    self.buttonList:AlignBottom(height / 2.25)
end

vgui.Register("synapse.maimenu.splash", PANEL, "synapse.maimenu.panel")