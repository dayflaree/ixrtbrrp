local animationTime = 0.5
local matrixZScale = Vector(1, 1, 0.0001)

-- character menu panel
DEFINE_BASECLASS("ixSubpanelParent")
local PANEL = {}

AccessorFunc(PANEL, "bNoDim", "NoDim", FORCE_BOOL)

function PANEL:Init()
    self:SetSize(self:GetParent():GetSize())
    self:SetPos(0, 0)

    self.childPanels = {}
    self.subpanels = {}
    self.activeSubpanel = ""

    self.currentDimAmount = 0
    self.currentY = 0
    self.currentScale = 1
    self.currentAlpha = 255
    self.targetDimAmount = 255
    self.targetScale = 0.9

    self.bNoDim = false
end

function PANEL:Dim(length, callback)
    length = length or animationTime
    self.currentDimAmount = 0

    self:CreateAnimation(length, {
        target = {
            currentDimAmount = self.targetDimAmount,
            currentScale = self.targetScale
        },
        easing = "outCubic",
        OnComplete = callback
    })

    self:OnDim()
end

function PANEL:Undim(length, callback)
    length = length or animationTime
    self.currentDimAmount = self.targetDimAmount

    self:CreateAnimation(length, {
        target = {
            currentDimAmount = 0,
            currentScale = 1
        },
        easing = "outCubic",
        OnComplete = callback
    })

    self:OnUndim()
end

function PANEL:OnDim()
end

function PANEL:OnUndim()
end

local vignette = Material("helix/gui/vignette.png")
function PANEL:Paint(width, height)
    local amount = self.currentDimAmount
    local bShouldScale = self.currentScale != 1
    local matrix

    -- draw child panels with scaling if needed
    if (bShouldScale) then
        matrix = Matrix()
        matrix:Scale(matrixZScale * self.currentScale)
        matrix:Translate(Vector(
            ScrW() * 0.5 - (ScrW() * self.currentScale * 0.5),
            ScrH() * 0.5 - (ScrH() * self.currentScale * 0.5),
            1
        ))

        cam.PushModelMatrix(matrix)
        self.currentMatrix = matrix
    end

    BaseClass.Paint(self, width, height)

    if (bShouldScale) then
        cam.PopModelMatrix()
        self.currentMatrix = nil
    end

    if (amount > 0 and !self.bNoDim) then
        ix.util.DrawBlur(self, 5, 1, amount)

        surface.SetDrawColor(25, 25, 25, amount * 0.75)
        surface.DrawRect(0, 0, width, height)
    
        surface.SetDrawColor(25, 25, 25, amount)
        surface.SetMaterial(vignette)
        surface.DrawTexturedRect(0, 0, width, height)
    end
end

vgui.Register("synapse.maimenu.panel", PANEL, "ixSubpanelParent")