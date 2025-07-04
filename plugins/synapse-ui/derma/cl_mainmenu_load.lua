
local errorModel = Model("models/error.mdl")

-- character load panel
local PANEL = {}

AccessorFunc(PANEL, "animationTime", "AnimationTime", FORCE_NUMBER)
AccessorFunc(PANEL, "backgroundFraction", "BackgroundFraction", FORCE_NUMBER)

function PANEL:Init()
    local parent = self:GetParent()
    local padding = self:GetPadding()
    local halfWidth = parent:GetWide() * 0.5 - (padding * 2)
    local halfHeight = parent:GetTall() * 0.5 - (padding * 2)
    local width = parent:GetWide()
    local height = parent:GetTall()
    local modelFOV = (ScrW() > ScrH() * 1.8) and 102 or 78

    self.animationTime = 1
    self.backgroundFraction = 1

    self.currentSubpanelX = 0
    self.targetSubpanelX = 0
    self.padding = 0

    self.character = nil
    self.characters = {}
    self.characterDescriptions = {}
    self.currentCharacter = 1

    -- main panel
    self.panel = self:AddSubpanel("main")
    self.panel:SetTitle("")
    self.panel.OnSetActive = function()
        self:CreateAnimation(self.animationTime, {
            index = 2,
            target = {backgroundFraction = 1},
            easing = "outQuint",
        })
    end

    self.characterButtonsPanel = self.panel:Add("Panel")
    self.characterButtonsPanel:Dock(FILL)
    self.characterButtonsPanel:DockMargin(padding, 0, padding, 0)
    self.characterButtonsPanel:InvalidateParent(true)

    self.characterModel = self.characterButtonsPanel:Add("ixModelPanel")
    self.characterModel:SetSize(width / 2, height)
    self.characterModel:SetPos(self.characterButtonsPanel:GetWide() / 2 - self.characterModel:GetWide() / 2, 0)
    self.characterModel:SetModel("models/error.mdl")
    self.characterModel:SetFOV(30)
    self.characterModel:SetLookAt(self.characterModel.Entity:GetPos() + Vector(0, 0, 60))
    self.characterModel:SetCamPos(Vector(64, 0, 60))
    self.characterModel.LayoutEntity = function(this, entity)
        entity:SetEyeTarget(Vector(64 + math.sin(RealTime() / 4) * 16, 16 + math.sin(RealTime() / 4) * 16, 60 + math.cos(RealTime() / 4) * 8))

        this:RunAnimation()
    end

    local characterTitle = self.characterButtonsPanel:Add("DLabel")
    characterTitle:SetText("character name")
    characterTitle:SetFont("synapse.nagonia.24")
    characterTitle:SizeToContents()
    characterTitle:SetPos(self.characterButtonsPanel:GetWide() / 2 - characterTitle:GetWide() / 2, padding / 4)

    local characterPrev = self.characterButtonsPanel:Add("synapse.button")
    characterPrev:SetText("<")
    characterPrev:SizeToContents()
    characterPrev:SetPos(padding, self.characterButtonsPanel:GetTall() / 2 - characterPrev:GetTall() / 2)

    local characterNext = self.characterButtonsPanel:Add("synapse.button")
    characterNext:SetText(">")
    characterNext:SizeToContents()
    characterNext:SetPos(self.characterButtonsPanel:GetWide() - characterNext:GetWide() - padding, self.characterButtonsPanel:GetTall() / 2 - characterNext:GetTall() / 2)

    self.characterButtonsPanel.OnMouseWheeled = function(this, delta)
        if (delta > 0) then
            characterNext:OnMousePressed(MOUSE_LEFT)
        else
            characterPrev:OnMousePressed(MOUSE_LEFT)
        end
    end

    local function UpdateCharacter()
        if ( !self.currentCharacter ) then return end

        local character = ix.char.loaded[self.characters[self.currentCharacter]]
        if ( !character ) then return end

        local faction = ix.faction.indices[character:GetFaction()]
        if ( !faction ) then return end
        
        characterTitle:SetText(character:GetName())
        characterTitle:SetColor(faction.color)
        characterTitle:SizeToContents()
        characterTitle:SetPos(self.characterButtonsPanel:GetWide() / 2 - characterTitle:GetWide() / 2, padding / 4)

        local description = ix.util.WrapText(character:GetDescription(), halfWidth, "synapse.nagonia.8")
        for k, v in ipairs(self.characterDescriptions) do
            v:Remove()
        end

        self.characterDescriptions = {}

        for i = 1, #description do
            local label = self.characterButtonsPanel:Add("DLabel")
            label:SetText(description[i])
            label:SetFont("synapse.nagonia.8")
            label:SizeToContents()
            label:SetPos(self.characterButtonsPanel:GetWide() / 2 - label:GetWide() / 2, characterTitle:GetY() + characterTitle:GetTall() + (label:GetTall() + 4) * (i - 1))

            table.insert(self.characterDescriptions, label)
        end

        self.characterModel:SetModel(character:GetModel(), character:GetData("skin", 0))

        self.character = character
    end

    self.UpdateCharacter = UpdateCharacter

    characterPrev.DoClick = function()
        local character = self.characters[self.currentCharacter - 1]
        if ( !character ) then return end

        self.currentCharacter = self.currentCharacter - 1

        self:UpdateCharacter()
    end

    characterNext.DoClick = function()
        local character = self.characters[self.currentCharacter + 1]
        if ( !character ) then return end

        self.currentCharacter = self.currentCharacter + 1

        self:UpdateCharacter()
    end

    self:UpdateCharacter()

    local buttons = self.panel:Add("Panel")
    buttons:Dock(BOTTOM)
    buttons:DockMargin(padding, padding, padding, padding)

    local back = buttons:Add("synapse.button")
    back:Dock(LEFT)
    back:SetText("return")
    back:SizeToContents()
    back.DoClick = function()
        self:SlideDown()
        parent.mainPanel:Undim()
    end

    buttons:SetTall(back:GetTall())

    local continueButton = buttons:Add("synapse.button")
    continueButton:Dock(RIGHT)
    continueButton:SetText("choose")
    continueButton:SizeToContents()
    continueButton.DoClick = function()
        /*
        self:SlideDown(self.animationTime, function()
            net.Start("ixCharacterChoose")
                net.WriteUInt(self.character:GetID(), 32)
            net.SendToServer()
        end, true)
        */

        self:SlideDown()

        parent.spawnpointPanel.character = self.character
        parent.spawnpointPanel.factionData = ix.faction.indices[self.character:GetFaction()]
        parent.spawnpointPanel:SlideUp()
    end

    local deleteButton = buttons:Add("synapse.button")
    deleteButton:Dock(RIGHT)
    deleteButton:DockMargin(0, 0, 5, 0)
    deleteButton:SetText("delete")
    deleteButton:SizeToContents()
    deleteButton:SetTextColor(derma.GetColor("Error", deleteButton))
    deleteButton.DoClick = function()
        self:SetActiveSubpanel("delete")
    end

    -- character deletion panel
    self.delete = self:AddSubpanel("delete")
    self.delete:SetTitle(nil)
    self.delete.OnSetActive = function()
        self.deleteModel:SetModel(self.character:GetModel(), self.character:GetData("skin", 0))
        self:CreateAnimation(self.animationTime, {
            index = 2,
            target = {backgroundFraction = 0},
            easing = "outQuint"
        })
    end

    self.deleteModel = self.delete:Add("ixModelPanel")
    self.deleteModel:Dock(LEFT)
    self.deleteModel:SetSize(width / 2, height)
    self.deleteModel:SetModel(errorModel)
    self.deleteModel:SetFOV(30)
    self.deleteModel:SetLookAt(self.deleteModel.Entity:GetPos() + Vector(0, 0, 60))
    self.deleteModel:SetCamPos(Vector(64, 0, 60))
    self.deleteModel.LayoutEntity = function(this, entity)
        entity:SetEyeTarget(Vector(64 + math.sin(RealTime() / 4) * 16, 16 + math.sin(RealTime() / 4) * 16, 60 + math.cos(RealTime() / 4) * 8))

        this:RunAnimation()
    end
    self.deleteModel.PaintModel = self.deleteModel.Paint

    local deleteButtons = self.delete:Add("Panel")
    deleteButtons:Dock(BOTTOM)
    deleteButtons:DockMargin(padding, padding, padding, padding)

    local deleteReturn = deleteButtons:Add("synapse.button")
    deleteReturn:Dock(LEFT)
    deleteReturn:SetText("no")
    deleteReturn:SizeToContents()
    deleteReturn.DoClick = function()
        self:SetActiveSubpanel("main")
    end

    deleteButtons:SetTall(deleteReturn:GetTall())

    local deleteConfirm = deleteButtons:Add("synapse.button")
    deleteConfirm:Dock(RIGHT)
    deleteConfirm:SetText("yes")
    deleteConfirm:SizeToContents()
    deleteConfirm:SetTextColor(derma.GetColor("Error", deleteConfirm))
    deleteConfirm.DoClick = function()
        local id = self.character:GetID()

        parent:ShowNotice(1, L("deleteComplete", self.character:GetName()))

        self:Populate(id)
        self:SetActiveSubpanel("main")

        net.Start("ixCharacterDelete")
            net.WriteUInt(id, 32)
        net.SendToServer()
    end

    local deleteNag = self.delete:Add("Panel")
    deleteNag:Dock(FILL)
    deleteNag:DockMargin(padding, padding, padding, padding)
    deleteNag:DockPadding(0, padding, 0, 0)

    local deleteTitle = deleteNag:Add("DLabel")
    deleteTitle:SetFont("synapse.nagonia.24")
    deleteTitle:SetText(L("areYouSure"):utf8upper())
    deleteTitle:SetTextColor(ix.config.Get("color"))
    deleteTitle:SetContentAlignment(5)
    deleteTitle:SizeToContents()
    deleteTitle:Dock(TOP)

    local deleteText = deleteNag:Add("DLabel")
    deleteText:SetFont("synapse.nagonia.10")
    deleteText:SetText(L("deleteConfirm"))
    deleteText:SetTextColor(color_white)
    deleteText:SetContentAlignment(8)
    deleteText:Dock(FILL)

    -- finalize setup
    self:SetActiveSubpanel("main", 0)
end

function PANEL:Populate()
    for k, v in pairs(ix.characters) do
        table.insert(self.characters, v)

        if (LocalPlayer():GetCharacter() and v == LocalPlayer():GetCharacter():GetID()) then
            self.currentCharacter = #self.characters
        end
    end

    self:UpdateCharacter()
end

function PANEL:OnCharacterDeleted(character)
    if (self.bActive and #ix.characters == 0) then
        self:SlideDown()
    end
end

function PANEL:OnSlideUp()
    self.bActive = true
    self:Populate()
end

function PANEL:OnSlideDown()
    self.bActive = false
end

function PANEL:OnCharacterButtonSelected(panel)
    local character = panel.character
    self.character = character

    self.carousel:SetModel(character:GetModel())

    local ent = self.carousel.Entity
    if ( !IsValid(ent) ) then return end

    for i = 0, ( ent:GetNumBodyGroups() - 1 ) do
        ent:SetBodygroup(i, 0)
    end

    local bodygroups = character:GetData("groups", nil)
    if ( istable(bodygroups) ) then
        for k, v in pairs(bodygroups) do
            ent:SetBodygroup(k, v)
        end
    end
end

vgui.Register("synapse.maimenu.load", PANEL, "synapse.maimenu.panel")