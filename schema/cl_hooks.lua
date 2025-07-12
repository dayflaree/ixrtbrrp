
function Schema:PopulateCharacterInfo(client, character, tooltip)
	if (client:IsRestricted()) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("tiedUp"))
		panel:SizeToContents()
	elseif (client:GetNetVar("tying")) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("beingTied"))
		panel:SizeToContents()
	elseif (client:GetNetVar("untying")) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("beingUntied"))
		panel:SizeToContents()
	end
end

local COMMAND_PREFIX = "/"

function Schema:ChatTextChanged(text)
	if (LocalPlayer():IsCombine()) then
		local key = nil

		if (text == COMMAND_PREFIX .. "radio ") then
			key = "r"
		elseif (text == COMMAND_PREFIX .. "w ") then
			key = "w"
		elseif (text == COMMAND_PREFIX .. "y ") then
			key = "y"
		elseif (text:sub(1, 1):match("%w")) then
			key = "t"
		end

		if (key) then
			netstream.Start("PlayerChatTextChanged", key)
		end
	end
end

function Schema:FinishChat()
	netstream.Start("PlayerFinishChat")
end

function Schema:CanPlayerJoinClass(client, class, info)
	return false
end

function Schema:PlayerFootstep(client, position, foot, soundName, volume)
	return true
end

local COLOR_BLACK_WHITE = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.5,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

-- creates labels in the status screen
function Schema:CreateCharacterInfo(panel)
	if (LocalPlayer():Team() == FACTION_CITIZEN) then
		panel.cid = panel:Add("ixListRow")
		panel.cid:SetList(panel.list)
		panel.cid:Dock(TOP)
		panel.cid:DockMargin(0, 0, 0, 8)
	end
end

-- populates labels in the status screen
function Schema:UpdateCharacterInfo(panel)
	if (LocalPlayer():Team() == FACTION_CITIZEN) then
		panel.cid:SetLabelText(L("citizenid"))
		panel.cid:SetText(string.format("##%s", LocalPlayer():GetCharacter():GetData("cid") or "UNKNOWN"))
		panel.cid:SizeToContents()
	end
end

function Schema:BuildBusinessMenu(panel)
	local bHasItems = false

	for k, _ in pairs(ix.item.list) do
		if (hook.Run("CanPlayerUseBusiness", LocalPlayer(), k) != false) then
			bHasItems = true

			break
		end
	end

	return bHasItems
end

function Schema:PopulateHelpMenu(tabs)
	tabs["voices"] = function(container)
		local classes = {}

		for k, v in pairs(Schema.voices.classes) do
			if (v.condition(LocalPlayer())) then
				classes[#classes + 1] = k
			end
		end

		if (#classes < 1) then
			local info = container:Add("DLabel")
			info:SetFont("ixSmallFont")
			info:SetText("You do not have access to any voice lines!")
			info:SetContentAlignment(5)
			info:SetTextColor(color_white)
			info:SetExpensiveShadow(1, color_black)
			info:Dock(TOP)
			info:DockMargin(0, 0, 0, 8)
			info:SizeToContents()
			info:SetTall(info:GetTall() + 16)

			info.Paint = function(_, width, height)
				surface.SetDrawColor(ColorAlpha(derma.GetColor("Error", info), 160))
				surface.DrawRect(0, 0, width, height)
			end

			return
		end

		table.sort(classes, function(a, b)
			return a < b
		end)

		for _, class in ipairs(classes) do
			local category = container:Add("Panel")
			category:Dock(TOP)
			category:DockMargin(0, 0, 0, 8)
			category:DockPadding(8, 8, 8, 8)
			category.Paint = function(_, width, height)
				surface.SetDrawColor(Color(0, 0, 0, 66))
				surface.DrawRect(0, 0, width, height)
			end

			local categoryLabel = category:Add("DLabel")
			categoryLabel:SetFont("ixMediumLightFont")
			categoryLabel:SetText(class:upper())
			categoryLabel:Dock(FILL)
			categoryLabel:SetTextColor(color_white)
			categoryLabel:SetExpensiveShadow(1, color_black)
			categoryLabel:SizeToContents()
			category:SizeToChildren(true, true)

			for command, info in SortedPairs(self.voices.stored[class]) do
				local title = container:Add("DLabel")
				title:SetFont("ixMediumLightFont")
				title:SetText(command:upper())
				title:Dock(TOP)
				title:SetTextColor(ix.config.Get("color"))
				title:SetExpensiveShadow(1, color_black)
				title:SizeToContents()

				local description = container:Add("DLabel")
				description:SetFont("ixSmallFont")
				description:SetText(info.text)
				description:Dock(TOP)
				description:SetTextColor(color_white)
				description:SetExpensiveShadow(1, color_black)
				description:SetWrap(true)
				description:SetAutoStretchVertical(true)
				description:SizeToContents()
				description:DockMargin(0, 0, 0, 8)
			end
		end
	end
end

netstream.Hook("PlaySound", function(sound)
	surface.PlaySound(sound)
end)

function Schema:OnSpawnMenuOpen()
    if not LocalPlayer():GetCharacter():HasFlags("S") then
        return false
    end
end

function Schema:ContextMenuOpen()
    if not LocalPlayer():GetCharacter():HasFlags("s") then
        return false
    end
end

local scrW, scrH = ScrW(), ScrH()
function Schema:HUDPaintBackground()
    local ply, char = LocalPlayer(), LocalPlayer():GetCharacter()
    
    if ( IsValid(ix.gui.characterMenu) and not ix.gui.characterMenu:IsClosing() ) then return end
    if not ( IsValid(ply) and char ) then return end

    draw.DrawText(Schema.name.."", "synapse.din.small", scrW / 2, ScreenScale(4), ColorAlpha(ix.config.Get("color"), 150), TEXT_ALIGN_CENTER)
    draw.DrawText("Everything you see may be subject to change!", "synapse.din.small", scrW / 2, ScreenScale(14), ColorAlpha(color_white, 100), TEXT_ALIGN_CENTER)
end

local find = ix.util.StringMatches
local footsteps = {}
local path = "rtbr/footsteps/"

local function AddFootsteps(name)
    footsteps[name] = {}
    footsteps[name]["run"] = {}
    footsteps[name]["walk"] = {}

    for i = 1, 4 do
        table.insert(footsteps[name]["run"], path .. name .. i .. ".wav")
        table.insert(footsteps[name]["walk"], path .. name .. i .. ".wav")
    end
end

AddFootsteps("concrete")
AddFootsteps("dirt")
AddFootsteps("duct")
AddFootsteps("flesh")
AddFootsteps("grass")
AddFootsteps("gravel")
AddFootsteps("metal")
AddFootsteps("metalgrate")
AddFootsteps("mud")
AddFootsteps("sand")
AddFootsteps("slosh")
AddFootsteps("tile")
AddFootsteps("wade")
AddFootsteps("wood")
AddFootsteps("woodpanel")

function Schema:ModifyPlayerStep(ply, data)
    local char = ply:GetCharacter()
    if ( !char ) then return end

    local inventory = char:GetInventory()
    if ( !inventory ) then return end

    local material = ply:GetSurfaceData()
    material = string.lower(material.name)
    
    if ( ply:GetMoveType() == MOVETYPE_LADDER ) then
        return
    end

    local footstepType = data.bRunning and "run" or "walk"
    local footstepSounds = footsteps["concrete"][footstepType]
    if ( !footstepSounds ) then return end

    local footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    local bRunning = data.running

    if ( find(material, "dirt") ) then
        footstepSounds = footsteps["dirt"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "duct") ) then
        footstepSounds = footsteps["duct"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "flesh") ) then
        footstepSounds = footsteps["flesh"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "grass") ) then
        footstepSounds = footsteps["grass"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "gravel") ) then
        footstepSounds = footsteps["gravel"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]

    elseif ( find(material, "metalgrate") ) then
        footstepSounds = footsteps["metalgrate"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "metal") ) then
        footstepSounds = footsteps["metal"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "mud") ) then
        footstepSounds = footsteps["mud"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "sand") ) then
        footstepSounds = footsteps["sand"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "slosh") ) then
        footstepSounds = footsteps["slosh"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "tile") ) then
        footstepSounds = footsteps["tile"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "wade") ) then
        footstepSounds = footsteps["wade"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "wood_panel") ) then
        footstepSounds = footsteps["woodpanel"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    elseif ( find(material, "wood") ) then
        footstepSounds = footsteps["wood"][footstepType]
        footstepPath = footstepSounds[math.random(1, #footstepSounds)]
    end

    data.snd = footstepPath
    data.pitch = math.random(95, 105)
end