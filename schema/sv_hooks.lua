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
		local remainingText = ""
		local foundVoicelines = {}
		local combinedText = ""
		
		-- Split the text into words and check each for voicelines
		local words = {}
		for word in rawText:gmatch("%S+") do
			table.insert(words, word)
		end
		
		-- Find voicelines at the beginning of the message
		local voicelineCount = 0
		for i, word in ipairs(words) do
			local foundVoiceline = false
			for k, v in ipairs(class) do
				local info = self.voices.Get(v, word)
				if (info) then
					table.insert(foundVoicelines, info)
					voicelineCount = voicelineCount + 1
					foundVoiceline = true
					break
				end
			end
			
			-- If no voiceline found, this is the start of normal text
			if not foundVoiceline then
				remainingText = table.concat(words, " ", i)
				break
			end
		end
		
		-- Build combined text for voicelines
		for i, info in ipairs(foundVoicelines) do
			if i == 1 then
				combinedText = info.text
			else
				combinedText = combinedText .. ". " .. info.text
			end
		end
		
		-- Add period to the end if the last voiceline doesn't end with punctuation
		if #foundVoicelines > 1 then
			local lastText = foundVoicelines[#foundVoicelines].text
			if not lastText:match("[.!?]$") then
				combinedText = combinedText .. "."
			end
		end
		
		-- If we found voicelines, play them and handle remaining text
		if #foundVoicelines > 0 then
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
			ix.util.EmitQueuedSounds(speaker, allSounds, nil, nil, volume)
			
			-- Combine voiceline text with remaining text
			local finalText = combinedText
			if remainingText ~= "" then
				if #foundVoicelines > 1 then
					finalText = finalText .. " " .. remainingText
				else
					finalText = finalText .. ". " .. remainingText
				end
			end
			
			if (speaker:IsCombine()) then
				return string.format("<:: %s ::>", finalText)
			else
				return finalText
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