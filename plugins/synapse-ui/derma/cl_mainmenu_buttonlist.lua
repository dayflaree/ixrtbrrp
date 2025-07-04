-- character menu main button list
local PANEL = {}

function PANEL:Init()
    local parent = self:GetParent()
    self:SetSize(parent:GetWide() * 0.25, ScreenScale(14))
    self:DockPadding(8, 8, 8, 8)
end

function PANEL:Add(name)
    local panel = vgui.Create(name, self)
    panel:Dock(LEFT)
    panel:DockMargin(0, 0, 8, 0)

    return panel
end

function PANEL:SizeToContents()
    local children = self:GetChildren()
    local width = 32 + 8
    local height = 48

    for _, child in pairs(children) do
        width = width + child:GetWide()
        height = math.max(height, child:GetTall())
    end

    self:SetSize(width, height)
end

function PANEL:Paint(width, height)
end

vgui.Register("synapse.maimenu.button.list", PANEL, "DPanel")