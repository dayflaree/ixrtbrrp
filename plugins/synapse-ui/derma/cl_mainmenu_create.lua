
local padding = ScreenScale(32)

local nameNoticeText = {
    "Please choose a serious character name.",
    "Names should be realistic and not contain any special characters.",
    "Refusal to do so will result in a ban.",
}

-- create character panel
DEFINE_BASECLASS("synapse.maimenu.panel")
local PANEL = {}

function PANEL:Init()
    local parent = self:GetParent()
    local halfWidth = parent:GetWide() / 2 - (padding * 2)
    local halfHeight = parent:GetTall() / 2 - (padding * 2)
    local width = parent:GetWide()
    local height = parent:GetTall()
    local modelFOV = (ScrW() > ScrH() * 1.8) and 100 or 78

    self:ResetPayload(true)

    self.currentSubpanelX = 0
    self.targetSubpanelX = 0
    self.padding = 0

    self.factionButtons = {}
    self.repopulatePanels = {}
    self.factions = {}

    for k, v in SortedPairsByMemberValue(ix.faction.indices, "index") do
        if (v.bNoCreate) then
            continue
        end

        self.factions[k] = v
    end

    -- faction selection subpanel
    self.factionPanel = self:AddSubpanel("faction", true)
    self.factionPanel:SetTitle("")
    self.factionPanel.OnSetActive = function()
        -- if we only have one faction, we are always selecting that one so we can skip to the description section
        if (#self.factionButtons == 1) then
            self:SetActiveSubpanel("description", 0)
        end
    end

    local factionButtons = self.factionPanel:Add("Panel")
    factionButtons:Dock(BOTTOM)
    factionButtons:DockMargin(padding, padding, padding, padding)

    local factionProceed = factionButtons:Add("synapse.button")
    factionProceed:Dock(RIGHT)
    factionProceed:SetText("proceed")
    factionProceed:SizeToContents()
    factionProceed.DoClick = function()
        self.progress:IncrementProgress()

        self:Populate()
        self:SetActiveSubpanel("description")
    end

    factionButtons:SetTall(factionProceed:GetTall())

    local factionBack = factionButtons:Add("synapse.button")
    factionBack:Dock(LEFT)
    factionBack:SetText("return")
    factionBack:SizeToContents()
    factionBack.DoClick = function()
        self.progress:DecrementProgress()

        self:SetActiveSubpanel("faction", 0)
        self:SlideDown()

        parent.mainPanel:Undim()
    end

    self.factionButtonsPanel = self.factionPanel:Add("Panel")
    self.factionButtonsPanel:Dock(FILL)
    self.factionButtonsPanel:DockMargin(padding, 0, padding, 0)
    self.factionButtonsPanel:InvalidateParent(true)

    self.factionModel = self.factionButtonsPanel:Add("ixModelPanel")
    self.factionModel:SetSize(width / 2, height)
    self.factionModel:SetPos(self.factionButtonsPanel:GetWide() / 2 - self.factionModel:GetWide() / 2, 0)
    self.factionModel:SetModel("models/error.mdl")
    self.factionModel:SetFOV(30)
    self.factionModel:SetLookAt(self.factionModel.Entity:GetPos() + Vector(0, 0, 60))
    self.factionModel:SetCamPos(Vector(64, 0, 60))
    self.factionModel.LayoutEntity = function(this, entity)
        entity:SetEyeTarget(Vector(64 + math.sin(RealTime() / 4) * 16, 16 + math.sin(RealTime() / 4) * 16, 60 + math.cos(RealTime() / 4) * 8))

        this:RunAnimation()
    end

    local factionTitle = self.factionButtonsPanel:Add("DLabel")
    factionTitle:SetText("faction name")
    factionTitle:SetFont("synapse.nagonia.24")
    factionTitle:SizeToContents()
    factionTitle:SetPos(self.factionButtonsPanel:GetWide() / 2 - factionTitle:GetWide() / 2, padding / 4)

    self.factionDescriptions = {}

    local factionPrev = self.factionButtonsPanel:Add("synapse.button")
    factionPrev:SetText("<")
    factionPrev:SizeToContents()
    factionPrev:SetPos(padding, self.factionButtonsPanel:GetTall() / 2 - factionPrev:GetTall() / 2)

    local factionNext = self.factionButtonsPanel:Add("synapse.button")
    factionNext:SetText(">")
    factionNext:SizeToContents()
    factionNext:SetPos(self.factionButtonsPanel:GetWide() - factionNext:GetWide() - padding, self.factionButtonsPanel:GetTall() / 2 - factionNext:GetTall() / 2)

    self.factionButtonsPanel.OnMouseWheeled = function(this, delta)
        if (delta > 0) then
            factionNext:OnMousePressed(MOUSE_LEFT)
        else
            factionPrev:OnMousePressed(MOUSE_LEFT)
        end
    end

    self.currentFaction = ix.faction.GetIndex("1_citizen")

    local function updateFactionModel()
        if ( !self.currentFaction ) then return end

        local faction = self.factions[self.currentFaction]
        if ( !faction ) then return end

        local models = faction:GetModels(LocalPlayer())

        self.payload:Set("faction", self.currentFaction)
        self.payload:Set("model", math.random(1, #models))
        
        factionTitle:SetText(L(faction.name))
        factionTitle:SetColor(faction.color)
        factionTitle:SizeToContents()
        factionTitle:SetPos(self.factionButtonsPanel:GetWide() / 2 - factionTitle:GetWide() / 2, padding / 4)

        local description = ix.util.WrapText(L(faction.description), halfWidth, "synapse.nagonia.8")
        for k, v in ipairs(self.factionDescriptions) do
            v:Remove()
        end

        self.factionDescriptions = {}

        for i = 1, #description do
            local label = self.factionButtonsPanel:Add("DLabel")
            label:SetText(description[i])
            label:SetFont("synapse.nagonia.8")
            label:SizeToContents()
            label:SetPos(self.factionButtonsPanel:GetWide() / 2 - label:GetWide() / 2, factionTitle:GetY() + factionTitle:GetTall() + (label:GetTall() + 4) * (i - 1))

            table.insert(self.factionDescriptions, label)
        end
    end

    factionPrev.DoClick = function()
        local faction = self.factions[self.currentFaction - 1]
        if ( !faction ) then return end

        self.currentFaction = self.currentFaction - 1

        updateFactionModel()
    end

    factionNext.DoClick = function()
        local faction = self.factions[self.currentFaction + 1]
        if ( !faction ) then return end

        self.currentFaction = self.currentFaction + 1

        updateFactionModel()
    end

    updateFactionModel()

    -- character customization subpanel
    self.descriptionPanel = self:AddSubpanel("description")
    self.descriptionPanel:SetTitle("")

    self.descriptionModel = self.descriptionPanel:Add("ixModelPanel")
    self.descriptionModel:Dock(LEFT)
    self.descriptionModel:SetSize(width / 3, height)
    self.descriptionModel:SetModel("models/error.mdl")
    self.descriptionModel:SetFOV(20)
    self.descriptionModel:SetLookAt(self.descriptionModel.Entity:GetPos() + Vector(0, 0, 60))
    self.descriptionModel:SetCamPos(Vector(64, 0, 60))
    self.descriptionModel.LayoutEntity = function(this, entity)
        entity:SetAngles(Angle(0, 45 / 4, 0))
        entity:SetEyeTarget(Vector(64 + math.sin(RealTime() / 4) * 16, 16 + math.sin(RealTime() / 4) * 16, 60 + math.cos(RealTime() / 4) * 8))

        this:RunAnimation()
    end

    local descriptionButtons = self.descriptionPanel:Add("Panel")
    descriptionButtons:Dock(BOTTOM)
    descriptionButtons:DockMargin(padding, padding, padding, padding)

    local descriptionBack = descriptionButtons:Add("synapse.button")
    descriptionBack:SetText("return")
    descriptionBack:SizeToContents()
    descriptionBack:Dock(LEFT)
    descriptionBack.DoClick = function()
        self.progress:DecrementProgress()

        if (#self.factionButtons == 1) then
            factionBack:DoClick()
        else
            self:SetActiveSubpanel("faction")
        end
    end

    descriptionButtons:SetTall(descriptionBack:GetTall())

    local descriptionProceed = descriptionButtons:Add("synapse.button")
    descriptionProceed:SetText("proceed")
    descriptionProceed:SizeToContents()
    descriptionProceed:Dock(RIGHT)
    descriptionProceed.DoClick = function()
        if (self:VerifyProgression("description")) then
            -- there are no panels on the attributes section other than the create button, so we can just create the character
            if (#self.attributesPanel:GetChildren() < 2) then
                self:SendPayload()
                return
            end

            self.progress:IncrementProgress()
            self:SetActiveSubpanel("attributes")
        end
    end

    self.descriptionContainer = self.descriptionPanel:Add("Panel")
    self.descriptionContainer:Dock(FILL)
    self.descriptionContainer:DockMargin(padding, 0, padding, 0)

    -- attributes subpanel
    self.attributes = self:AddSubpanel("attributes")
    self.attributes:SetTitle("chooseSkills")

    local attributesModelList = self.attributes:Add("Panel")
    attributesModelList:Dock(LEFT)
    attributesModelList:SetSize(halfWidth, halfHeight)

    local attributesBack = attributesModelList:Add("ixMenuButton")
    attributesBack:SetText("return")
    attributesBack:SetContentAlignment(4)
    attributesBack:SizeToContents()
    attributesBack:Dock(BOTTOM)
    attributesBack.DoClick = function()
        self.progress:DecrementProgress()
        self:SetActiveSubpanel("description")
    end

    self.attributesModel = attributesModelList:Add("ixModelPanel")
    self.attributesModel:Dock(FILL)
    self.attributesModel:SetModel(self.factionModel:GetModel())
    self.attributesModel:SetFOV(modelFOV - 13)
    self.attributesModel.PaintModel = self.attributesModel.Paint

    self.attributesPanel = self.attributes:Add("Panel")
    self.attributesPanel:SetWide(halfWidth + padding * 2)
    self.attributesPanel:Dock(RIGHT)

    local create = self.attributesPanel:Add("ixMenuButton")
    create:SetText("finish")
    create:SetContentAlignment(6)
    create:SizeToContents()
    create:Dock(BOTTOM)
    create.DoClick = function()
        self:SendPayload()
    end

    -- creation progress panel
    self.progress = self:Add("ixSegmentedProgress")
    self.progress:SetBarColor(ix.config.Get("color"))
    self.progress:SetSize(parent:GetWide(), 0)
    self.progress:SizeToContents()
    self.progress:SetPos(0, parent:GetTall() - self.progress:GetTall())

    -- setup payload hooks
    self:AddPayloadHook("model", function(value)
        local faction = self.factions[self.payload.faction]
        if (faction) then
            local model = faction:GetModels(LocalPlayer())[value]

            -- assuming bodygroups
            if (istable(model)) then
                self.factionModel:SetModel(model[1], model[2] or 0, model[3])
                self.descriptionModel:SetModel(model[1], model[2] or 0, model[3])
                self.attributesModel:SetModel(model[1], model[2] or 0, model[3])
            else
                self.factionModel:SetModel(model)
                self.descriptionModel:SetModel(model)
                self.attributesModel:SetModel(model)
            end
        end
    end)

    -- setup character creation hooks
    net.Receive("ixCharacterAuthed", function()
        timer.Remove("ixCharacterCreateTimeout")
        self.awaitingResponse = false

        local id = net.ReadUInt(32)
        local indices = net.ReadUInt(6)
        local charList = {}

        for _ = 1, indices do
            charList[#charList + 1] = net.ReadUInt(32)
        end

        ix.characters = charList

        self:SlideDown()

        if (!IsValid(self) or !IsValid(parent)) then
            return
        end

        if (LocalPlayer():GetCharacter()) then
            parent.mainPanel:Undim()
            parent:ShowNotice(2, L("charCreated"))
        elseif (id) then
            self.bMenuShouldClose = true

            net.Start("ixCharacterChoose")
                net.WriteUInt(id, 32)
            net.SendToServer()
        else
            self:SlideDown()
        end
    end)

    net.Receive("ixCharacterAuthFailed", function()
        timer.Remove("ixCharacterCreateTimeout")
        self.awaitingResponse = false

        local fault = net.ReadString()
        local args = net.ReadTable()

        self:SlideDown()

        parent.mainPanel:Undim()
        parent:ShowNotice(3, L(fault, unpack(args)))
    end)
end

function PANEL:SendPayload()
    if (self.awaitingResponse or !self:VerifyProgression()) then
        return
    end

    self.awaitingResponse = true

    timer.Create("ixCharacterCreateTimeout", 10, 1, function()
        if (IsValid(self) and self.awaitingResponse) then
            local parent = self:GetParent()

            self.awaitingResponse = false
            self:SlideDown()

            parent.mainPanel:Undim()
            parent:ShowNotice(3, L("unknownError"))
        end
    end)

    self.payload:Prepare()

    net.Start("ixCharacterCreate")
    net.WriteUInt(table.Count(self.payload), 8)

    for k, v in pairs(self.payload) do
        net.WriteString(k)
        net.WriteType(v)
    end

    net.SendToServer()
end

function PANEL:OnSlideUp()
    self:ResetPayload()
    self:Populate()
    self.progress:SetProgress(1)

    -- the faction subpanel will skip to next subpanel if there is only one faction to choose from,
    -- so we don't have to worry about it here
    self:SetActiveSubpanel("faction", 0)
end

function PANEL:OnSlideDown()
end

function PANEL:ResetPayload(bWithHooks)
    if (bWithHooks) then
        self.hooks = {}
    end

    self.payload = {}

    -- TODO: eh..
    function self.payload.Set(payload, key, value)
        self:SetPayload(key, value)
    end

    function self.payload.AddHook(payload, key, callback)
        self:AddPayloadHook(key, callback)
    end

    function self.payload.Prepare(payload)
        self.payload.Set = nil
        self.payload.AddHook = nil
        self.payload.Prepare = nil
    end
end

function PANEL:SetPayload(key, value)
    self.payload[key] = value
    self:RunPayloadHook(key, value)
end

function PANEL:AddPayloadHook(key, callback)
    if (!self.hooks[key]) then
        self.hooks[key] = {}
    end

    self.hooks[key][#self.hooks[key] + 1] = callback
end

function PANEL:RunPayloadHook(key, value)
    local hooks = self.hooks[key] or {}

    for _, v in ipairs(hooks) do
        v(value)
    end
end

function PANEL:GetContainerPanel(name)
    -- TODO: yuck
    if (name == "description") then
        return self.descriptionContainer
    elseif (name == "attributes") then
        return self.attributesPanel
    end

    return self.descriptionContainer
end

function PANEL:AttachCleanup(panel)
    self.repopulatePanels[#self.repopulatePanels + 1] = panel
end

function PANEL:Populate()
    -- remove panels created for character vars
    for i = 1, #self.repopulatePanels do
        self.repopulatePanels[i]:Remove()
    end

    self.repopulatePanels = {}

    self.currentFaction = ix.faction.GetIndex("1_citizen")

    -- payload is empty because we attempted to send it - for whatever reason we're back here again so we need to repopulate
    if (!self.payload.faction) then
        self:SetPayload("faction", self.currentFaction)

        local faction = self.factions[self.currentFaction]
        if (!faction) then return end

        local models = faction:GetModels(LocalPlayer())
        local model = math.random(1, #models)

        self:SetPayload("model", model)
    end

    local zPos = 1

    -- set up character vars
    for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
        if (!v.bNoDisplay and k != "__SortedIndex") then
            local container = self:GetContainerPanel(v.category or "description")

            if (v.ShouldDisplay and v:ShouldDisplay(container, self.payload) == false) then
                continue
            end

            local panel

            -- if the var has a custom way of displaying, we'll use that instead
            if (v.OnDisplay) then
                panel = v:OnDisplay(container, self.payload)
            elseif (isstring(v.default)) then
                panel = container:Add("HG.TextEntry")
                panel:Dock(TOP)
                panel:SetFont("synapse.nagonia.8")
                panel:SizeToContents()
                panel:SetTall(panel:GetTall() * 2)
                panel:SetUpdateOnType(true)
                panel.OnValueChange = function(this, text)
                    self.payload:Set(k, text)

                    surface.PlaySound("common/talk.wav")
                end
            end

            if (v.field == "name") then
                for _, v in ipairs(nameNoticeText) do
                    local label = container:Add("DLabel")
                    label:SetFont("synapse.nagonia.4")
                    label:SetText("• " .. v)
                    label:SizeToContents()
                    label:Dock(TOP)

                    label:SetZPos(zPos)

                    self:AttachCleanup(label)
                end

                local label = container:Add("DLabel")
                label:SetFont("synapse.nagonia.bold.6")
                label:SetText("Before you continue, please read the following:")
                label:SizeToContents()
                label:DockMargin(0, 16, 0, 2)
                label:Dock(TOP)

                label:SetZPos(zPos)

                self:AttachCleanup(label)
            end

            if (IsValid(panel)) then
                -- add label for entry
                local label = container:Add("DLabel")
                label:SetFont("synapse.nagonia.bold.12")
                label:SetText(L(k))
                label:SizeToContents()
                label:DockMargin(0, 16, 0, 2)
                label:Dock(TOP)

                -- we need to set the docking order so the label is above the panel
                label:SetZPos(zPos - 1)
                panel:SetZPos(zPos)

                self:AttachCleanup(label)
                self:AttachCleanup(panel)

                if (v.OnPostSetup) then
                    v:OnPostSetup(panel, self.payload)
                end

                zPos = zPos + 2
            end
        end
    end

    if (!self.bInitialPopulate) then
        -- setup progress bar segments
        if (#self.factionButtons > 1) then
            self.progress:AddSegment("@faction")
        end

        self.progress:AddSegment("@description")

        if (#self.attributesPanel:GetChildren() > 1) then
            self.progress:AddSegment("@skills")
        end

        -- we don't need to show the progress bar if there's only one segment
        if (#self.progress:GetSegments() == 1) then
            self.progress:SetVisible(false)
        end
    end

    self.bInitialPopulate = true
end

function PANEL:VerifyProgression(name)
    for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
        if (name != nil and (v.category or "description") != name) then
            continue
        end

        local value = self.payload[k]

        if (!v.bNoDisplay or v.OnValidate) then
            if (v.OnValidate) then
                local result = {v:OnValidate(value, self.payload, LocalPlayer())}

                if (result[1] == false) then
                    self:GetParent():ShowNotice(3, L(unpack(result, 2)))
                    return false
                end
            end

            self.payload[k] = value
        end
    end

    return true
end

function PANEL:Paint(width, height)
end

vgui.Register("synapse.maimenu.create", PANEL, "synapse.maimenu.panel")
