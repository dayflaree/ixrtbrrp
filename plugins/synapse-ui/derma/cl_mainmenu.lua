
local gradient = surface.GetTextureID("vgui/gradient-d")
local audioFadeInTime = 2
local animationTime = 0.5
local matrixZScale = Vector(1, 1, 0.0001)

-- container panel
local PANEL = {}

function PANEL:Init()
    if (IsValid(ix.gui.loading)) then
        ix.gui.loading:Remove()
    end

    if (IsValid(ix.gui.characterMenu)) then
        if (IsValid(ix.gui.characterMenu.channel)) then
            ix.gui.characterMenu.channel:Stop()
        end

        ix.gui.characterMenu:Remove()
    end

    ix.gui.characterMenu = self

    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)

    -- main menu panel
    self.mainPanel = self:Add("synapse.maimenu.splash")

    -- new character panel
    self.newCharacterPanel = self:Add("synapse.maimenu.create")
    self.newCharacterPanel:SlideDown(0)

    -- load character panel
    self.loadCharacterPanel = self:Add("synapse.maimenu.load")
    self.loadCharacterPanel:SlideDown(0)

    -- spawnpoint panel
    self.spawnpointPanel = self:Add("synapse.maimenu.spawnpoint")
    self.spawnpointPanel:SlideDown(0)

    -- notice bar
    self.notice = self:Add("ixNoticeBar")

    -- finalization
    self:MakePopup()
    self.currentAlpha = 255
    self.volume = 0

    ix.gui.characterMenu = self

    if (!IsValid(ix.gui.intro)) then
        local delay = ix.config.Get("musicDelay", 0)
        timer.Create("ixCharacterMusicDelay", delay, 1, function()
            if (IsValid(self)) then
                self:PlayMusic()
            end
        end)
    end

    if ( BRANCH != "x86-64" and !tobool(cookie.GetNumber("ixLowPerformance", 0)) ) then
        Derma_Query("You are currently using the 32-bit version of the game, which may limit performance and stability. To enhance your gaming experience, we recommend switching to the 64-bit branch [x86-x64]. To do this, open your game library, navigate to the properties of the game, and update the launch options to select the 64-bit branch. This change ensures improved performance, better resource utilization, and greater compatibility with modern systems.", "Potential Performance Impact", "Disconnect", function()
            RunConsoleCommand("disconnect")
        end, "Play with reduced FPS", function()
            cookie.Set("ixLowPerformance", 1)
        end)
    end

    hook.Run("OnCharacterMenuCreated", self)
end

function PANEL:PlayMusic()
    local path = "sound/" .. ix.config.Get("music")
    local url = path:match("http[s]?://.+")
    local play = url and sound.PlayURL or sound.PlayFile
    path = url and url or path

    play(path, "noplay", function(channel, error, message)
        if (!IsValid(self) or !IsValid(channel)) then
            return
        end

        channel:SetVolume(self.volume or 0)
        channel:Play()

        self.channel = channel

        self:CreateAnimation(audioFadeInTime, {
            index = 10,
            target = {volume = ix.config.Get("musicVolume", 0.5)},

            Think = function(animation, panel)
                if (IsValid(panel.channel)) then
                    panel.channel:SetVolume(self.volume)
                end
            end
        })

        -- if the timer exists, then we're already looping the music, so don't create another timer
        if (timer.Exists("ixCharacterMusic")) then
            return
        end
    
        -- don't loop the music if the config is false
        if (!ix.config.Get("musicLoop", false)) then
            return
        end
    
        -- loop the music
        local length = channel:GetLength()
        timer.Create("ixCharacterMusic", length, 1, function()
            if (IsValid(self) and IsValid(self.channel)) then
                self.channel:Stop()
                self.channel = nil
    
                self:PlayMusic()
            end
        end)
    end)
end

function PANEL:ShowNotice(type, text)
    self.notice:SetType(type)
    self.notice:SetText(text)
    self.notice:Show()
end

function PANEL:HideNotice()
    if (IsValid(self.notice) and !self.notice:GetHidden()) then
        self.notice:Slide("up", 0.5, true)
    end
end

function PANEL:OnCharacterDeleted(character)
    if (#ix.characters == 0) then
        self.mainPanel.loadButton:SetDisabled(true)
        self.mainPanel:Undim() -- undim since the load panel will slide down
    else
        self.mainPanel.loadButton:SetDisabled(false)
    end

    self.loadCharacterPanel:OnCharacterDeleted(character)
end

function PANEL:OnCharacterLoadFailed(error)
    self.loadCharacterPanel:SetMouseInputEnabled(true)
    self.loadCharacterPanel:SlideUp()
    self:ShowNotice(3, error)
end

function PANEL:IsClosing()
    return self.bClosing
end

function PANEL:Close(bFromMenu)
    self.bClosing = true
    self.bFromMenu = bFromMenu

    local fadeOutTime = animationTime * 8

    self:CreateAnimation(fadeOutTime, {
        index = 1,
        target = {currentAlpha = 0},

        Think = function(animation, panel)
            panel:SetAlpha(panel.currentAlpha)
        end,

        OnComplete = function(animation, panel)
            panel:Remove()
        end
    })

    self:CreateAnimation(fadeOutTime - 0.1, {
        index = 10,
        target = {volume = 0},

        Think = function(animation, panel)
            if (IsValid(panel.channel)) then
                panel.channel:SetVolume(self.volume)
            end
        end,

        OnComplete = function(animation, panel)
            if (IsValid(panel.channel)) then
                panel.channel:Stop()
                panel.channel = nil
            end
        end
    })

    -- hide children if we're already dimmed
    if (bFromMenu) then
        for _, v in pairs(self:GetChildren()) do
            if (IsValid(v)) then
                v:SetVisible(false)
            end
        end
    else
        -- fade out the main panel quicker because it significantly blocks the screen
        self.mainPanel.currentAlpha = 255

        self.mainPanel:CreateAnimation(animationTime * 2, {
            target = {currentAlpha = 0},
            easing = "outQuint",

            Think = function(animation, panel)
                panel:SetAlpha(panel.currentAlpha)
            end,

            OnComplete = function(animation, panel)
                panel:SetVisible(false)
            end
        })
    end

    -- relinquish mouse control
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    gui.EnableScreenClicker(false)
end

local vignette = Material("helix/gui/vignette.png")
function PANEL:Paint(width, height)
    surface.SetDrawColor(50, 50, 50, self.currentAlpha / 2)
    surface.DrawRect(0, 0, width, height)

    surface.SetDrawColor(0, 0, 0, self.currentAlpha)
    surface.SetMaterial(vignette)
    surface.DrawTexturedRect(0, 0, width, height)
end

function PANEL:PaintOver(width, height)
    if (self.bClosing and self.bFromMenu) then
        surface.SetDrawColor(color_black)
        surface.DrawRect(0, 0, width, height)
    end
end

function PANEL:OnRemove()
    if (IsValid(self.channel)) then
        self.channel:Stop()
        self.channel = nil
    end

    if (timer.Exists("ixCharacterMusic")) then
        timer.Remove("ixCharacterMusic")
    end

    if (timer.Exists("ixCharacterMusicDelay")) then
        timer.Remove("ixCharacterMusicDelay")
    end
end

vgui.Register("ixCharMenu", PANEL, "EditablePanel")

if (IsValid(ix.gui.characterMenu)) then
    ix.gui.characterMenu:Remove()

    timer.Simple(0, function()
        vgui.Create("ixCharMenu")
    end)
end
