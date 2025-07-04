local PLUGIN = PLUGIN

function PLUGIN:ShouldRenderMapScene()
	local panel = ix.gui.characterMenu
	if ( IsValid(panel) and panel.spawnpointPanel and panel.spawnpointPanel.bActive and panel.spawnpointPanel.factionData and panel.spawnpointPanel.factionData.spawnCam ) then
		return false
	end
end

local spawnCamModel
function PLUGIN:CalcView(ply, origin, angles, fov)
	local panel = ix.gui.characterMenu
	if ( IsValid(panel) and IsValid(panel.spawnpointPanel) and panel.spawnpointPanel.bActive and panel.spawnpointPanel.factionData ) then
		local factionData = panel.spawnpointPanel.factionData
		local spawnCam = factionData.spawnCam
		if ( spawnCam ) then
			if ( !IsValid(spawnCamModel) ) then
				spawnCamModel = ClientsideModel(panel.spawnpointPanel.character:GetModel())

				local modelSequence = spawnCam.modelSequence
				if ( istable(modelSequence) ) then
					modelSequence = modelSequence[math.random(1, #modelSequence)]
				end

				modelSequence = spawnCamModel:LookupSequence(modelSequence)

				spawnCamModel:ResetSequence(modelSequence)
			else
				spawnCamModel:SetPos(spawnCam.modelPos)
				spawnCamModel:SetAngles(spawnCam.modelAng)

				spawnCamModel:FrameAdvance(RealFrameTime())

				if ( spawnCamModel:GetModel() != panel.spawnpointPanel.character:GetModel() ) then
					spawnCamModel:Remove()
				end
			end

			local view = {}
			view.origin = spawnCam.pos
			view.angles = spawnCam.ang
			view.fov = spawnCam.fov or fov

			return view
		end
	else
		if ( spawnCamModel ) then
			spawnCamModel:Remove()
		end
	end
end