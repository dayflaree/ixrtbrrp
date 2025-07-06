function Schema:LoadData()
	self:LoadRationDispensers()
	self:LoadVendingMachines()
	self:LoadCombineLocks()
	self:LoadForceFields()

	Schema.CombineObjectives = ix.data.Get("combineObjectives", {}, false, true)
end

function Schema:SaveData()
	self:SaveRationDispensers()
	self:SaveVendingMachines()
	self:SaveCombineLocks()
	self:SaveForceFields()
end

function Schema:PlayerSwitchFlashlight(client, enabled)
	if (client:IsCombine()) then
		return true
	end
end

function Schema:PlayerUseDoor(client, door)
	if (client:IsCombine()) then
		if (!door:HasSpawnFlags(256) and !door:HasSpawnFlags(1024)) then
			door:Fire("open")
		end
	end
end

function Schema:PlayerLoadout(client)
	client:SetNetVar("restricted")
end

function Schema:CharacterVarChanged(character, key, oldValue, value)
	local client = character:GetPlayer()
	if (key == "name") then
		local factionTable = ix.faction.Get(client:Team())

		if (factionTable.OnNameChanged) then
			factionTable:OnNameChanged(client, oldValue, value)
		end
	end
end

function Schema:PlayerFootstep(client, position, foot, soundName, volume)
	local factionTable = ix.faction.Get(client:Team())

	if (factionTable.runSounds and client:IsRunning()) then
		client:EmitSound(factionTable.runSounds[foot])
		return true
	end

	client:EmitSound(soundName)
	return true
end

function Schema:OnNPCKilled(npc, attacker, inflictor)
	if (IsValid(npc.ixPlayer)) then
		hook.Run("PlayerDeath", npc.ixPlayer, inflictor, attacker)
	end
end

function Schema:PlayerMessageSend(speaker, chatType, text, anonymous, receivers, rawText)
	if (chatType == "ic" or chatType == "w" or chatType == "y" or chatType == "dispatch") then
		local class = self.voices.GetClass(speaker)
		
		-- Check for multiple voicelines (space-separated)
		local voicelineIDs = {}
		for voicelineID in rawText:gmatch("%S+") do
			table.insert(voicelineIDs, voicelineID)
		end
		
		-- If multiple voicelines found, play them in sequence
		if #voicelineIDs > 1 then
			local foundVoicelines = {}
			local combinedText = ""
			
			-- Find all the voicelines
			for i, voicelineID in ipairs(voicelineIDs) do
				for k, v in ipairs(class) do
					local info = self.voices.Get(v, voicelineID)
					if (info) then
						table.insert(foundVoicelines, info)
						if i == 1 then
							combinedText = info.text
						else
							combinedText = combinedText .. ". " .. info.text
						end
						break
					end
				end
			end
			
			-- Add period to the end if the last voiceline doesn't end with punctuation
			if #foundVoicelines > 1 then
				local lastText = foundVoicelines[#foundVoicelines].text
				if not lastText:match("[.!?]$") then
					combinedText = combinedText .. "."
				end
			end
			
			-- If we found multiple voicelines, play them in sequence
			if #foundVoicelines > 1 then
				local volume = 80
				if (chatType == "w") then
					volume = 60
				elseif (chatType == "y") then
					volume = 150
				end
				
				-- Collect all sounds into one sequence
				local allSounds = {}
				for i, info in ipairs(foundVoicelines) do
					table.insert(allSounds, info.sound)
					
					-- Add radio off sound after the last voiceline for Combine
					if (speaker:IsCombine() and i == #foundVoicelines) then
						table.insert(allSounds, "NPC_MetroPolice.Radio.Off")
					end
				end
				
				-- Play all sounds as one sequence
				local totalDuration = ix.util.EmitQueuedSounds(speaker, allSounds, nil, nil, volume)
				
				if (speaker:IsCombine()) then
					return string.format("<:: %s ::>", combinedText)
				else
					return combinedText
				end
			end
		end
		
		-- Original single voiceline logic
		for k, v in ipairs(class) do
			local info = self.voices.Get(v, rawText)

			if (info) then
				local volume = 80

				if (chatType == "w") then
					volume = 60
				elseif (chatType == "y") then
					volume = 150
				end

				if (info.sound) then
					if (info.global) then
						netstream.Start(nil, "PlaySound", info.sound)
					else
						local sounds = {info.sound}

						if (speaker:IsCombine()) then
							speaker.bTypingBeep = nil
							sounds[#sounds + 1] = "NPC_MetroPolice.Radio.Off"
						end

						ix.util.EmitQueuedSounds(speaker, sounds, nil, nil, volume)
					end
				end

				if (speaker:IsCombine()) then
					return string.format("<:: %s ::>", info.text)
				else
					return info.text
				end
			end
		end

		if (speaker:IsCombine()) then
			return string.format("<:: %s ::>", text)
		end
	end
end

function Schema:PlayerSpray(client)
	return false
end

netstream.Hook("PlayerChatTextChanged", function(client, key)
	if (client:IsCombine() and !client.bTypingBeep
	and (key == "y" or key == "w" or key == "r" or key == "t")) then
		client:EmitSound("NPC_MetroPolice.Radio.On")
		client.bTypingBeep = true
	end
end)

netstream.Hook("PlayerFinishChat", function(client)
	if (client:IsCombine() and client.bTypingBeep) then
		client:EmitSound("NPC_MetroPolice.Radio.Off")
		client.bTypingBeep = nil
	end
end)