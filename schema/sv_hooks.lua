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
		local foundVoicelines = {}
		local finalWords = {}
		local words = {}
		for word in rawText:gmatch("%S+") do
			table.insert(words, word)
		end

		for i, word in ipairs(words) do
			local foundVoiceline = false
			for k, v in ipairs(class) do
				local info = self.voices.Get(v, word)
				if (info) then
					table.insert(foundVoicelines, info)
					table.insert(finalWords, info.text)
					foundVoiceline = true
					break
				end
			end
			if not foundVoiceline then
				table.insert(finalWords, word)
			end
		end

		-- Add periods between consecutive voicelines and at the end
		if #finalWords > 0 then
			for i = 1, #finalWords - 1 do
				local currentWord = finalWords[i]
				local nextWord = finalWords[i + 1]
				
				-- Check if current word is a voiceline and next word is also a voiceline
				local currentIsVoiceline = false
				local nextIsVoiceline = false
				
				for _, info in ipairs(foundVoicelines) do
					if info.text == currentWord then
						currentIsVoiceline = true
					end
					if info.text == nextWord then
						nextIsVoiceline = true
					end
				end
				
				-- If current is voiceline and next is voiceline, add period to current
				if currentIsVoiceline and nextIsVoiceline and not currentWord:match("[.!?]$") then
					finalWords[i] = currentWord .. "."
				end
			end
			
			-- Add period to voicelines at the end of the message
			local lastWord = finalWords[#finalWords]
			for _, info in ipairs(foundVoicelines) do
				if info.text == lastWord and not lastWord:match("[.!?]$") then
					finalWords[#finalWords] = lastWord .. "."
					break
				end
			end
		end

		if #foundVoicelines > 0 then
			local volume = 80
			if (chatType == "w") then
				volume = 60
			elseif (chatType == "y") then
				volume = 150
			end

			local allSounds = {}
			for i, info in ipairs(foundVoicelines) do
				table.insert(allSounds, info.sound)
				if (speaker:IsCombine() and i == #foundVoicelines) then
					table.insert(allSounds, "NPC_MetroPolice.Radio.Off")
				end
			end

			ix.util.EmitQueuedSounds(speaker, allSounds, nil, nil, volume)

			local finalText = table.concat(finalWords, " ")

			if (speaker:IsCombine()) then
				return string.format("<:: %s ::>", finalText)
			else
				return finalText
			end
		end

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