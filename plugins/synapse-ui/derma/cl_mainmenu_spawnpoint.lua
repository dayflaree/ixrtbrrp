-- spawnpoint panel
local PANEL = {}

function PANEL:Init()
    local parent = self:GetParent()
    local padding = self:GetPadding()
    local halfWidth = ScrW() / 2
    local halfHeight = ScrH() / 2
    local halfPadding = padding / 2
    local bHasCharacter = #ix.characters > 0

    self.bNoDim = true

    self.character = nil
    self.currentAlpha = 255
    self.cameraData = {}
    self.factionData = {}
    self.spawnPoint = ""

    local buttons = self:Add("Panel")
    buttons:Dock(BOTTOM)
    buttons:DockMargin(padding, padding, padding, padding)

    local back = buttons:Add("synapse.button")
    back:Dock(LEFT)
    back:SetText(L"back")
    back:SizeToContents()
    back.DoClick = function()
        self:SlideDown()
        parent.loadCharacterPanel:SlideUp()

        local parent = self:GetParent()
        parent.mainPanel:CreateAnimation(1, {
            target = {
                currentDimAmount = parent.mainPanel.targetDimAmount,
                currentScale = parent.mainPanel.targetScale
            },
            easing = "outCubic"
        })
    end

    buttons:SetTall(back:GetTall())

    self.spawn = buttons:Add("synapse.button")
    self.spawn:Dock(LEFT)
    self.spawn:DockMargin(5, 0, 0, 0)
    self.spawn:SetText(L"spawn")
    self.spawn:SizeToContents()
    self.spawn:SetEnabled(false)
    self.spawn.DoClick = function()
        self:SlideDown(1, function()
            net.Start("ixCharacterChoose")
                net.WriteUInt(self.character:GetID(), 32)
                net.WriteString(self.spawnPoint)
            net.SendToServer()
        end, true)

        local parent = self:GetParent()
        parent.mainPanel:CreateAnimation(1, {
            target = {
                currentDimAmount = parent.mainPanel.targetDimAmount,
                currentScale = parent.mainPanel.targetScale
            },
            easing = "outCubic"
        })
    end

    self.spawnPoints = self:Add("DScrollPanel")
    self.spawnPoints:Dock(LEFT)
    self.spawnPoints:DockMargin(padding, padding, padding, 0)
    self.spawnPoints:SetWide(halfWidth / 1.5)
end

function PANEL:Populate()
    self.spawnPoints:Clear()

    for k, v in pairs(self.factionData.spawnPoints) do
        local canUse = v.canUse
        local bCanUse = canUse(self.character)
        if (!bCanUse) then
            continue
        end

        local button = self.spawnPoints:Add("synapse.button")
        button:Dock(TOP)
        button:DockMargin(0, 0, 0, 5)
        button:SetText(k)
        button:SetFont("synapse.nagonia.8")
        button:SizeToContents()
        button:SetTall(button:GetTall() * 2)
        button.DoClick = function()
            self.spawnPoint = k
            self.spawn:SetEnabled(true)

            surface.PlaySound("buttons/button9.wav")
        end
    end
end

function PANEL:OnDim()
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
        if ( IsValid(v) ) then
            v:SetVisible(false)
        end
    end
end

function PANEL:OnSlideUp()
    self.bActive = true
    self:Populate()

    local parent = self:GetParent()
    parent.mainPanel:CreateAnimation(1, {
        target = {
            currentDimAmount = 0,
            currentScale = 1
        },
        easing = "outCubic"
    })
end

function PANEL:OnSlideDown()
    self.bActive = false
end

vgui.Register("synapse.maimenu.spawnpoint", PANEL, "synapse.maimenu.panel")