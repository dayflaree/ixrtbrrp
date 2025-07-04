

net.Receive("ixCharacterChoose", function(length, client)
    local id = net.ReadUInt(32)
    local spawnPoint = net.ReadString()

    if (client:GetCharacter() and client:GetCharacter():GetID() == id) then
        net.Start("ixCharacterLoadFailure")
            net.WriteString("@usingChar")
        net.Send(client)
        return
    end

    local character = ix.char.loaded[id]

    if (character and character:GetPlayer() == client) then
        local status, result = hook.Run("CanPlayerUseCharacter", client, character)

        if (status == false) then
            net.Start("ixCharacterLoadFailure")
                net.WriteString(result or "")
            net.Send(client)
            return
        end

        local currentChar = client:GetCharacter()

        if (currentChar) then
            currentChar:Save()

            for _, v in ipairs(currentChar:GetInventory(true)) do
                if (istable(v)) then
                    v:RemoveReceiver(client)
                end
            end
        end

        hook.Run("PrePlayerLoadedCharacter", client, character, currentChar)
        character:Setup()
        client:Spawn()

        hook.Run("PlayerLoadedCharacter", client, character, currentChar)

        timer.Simple(0.1, function()
            local factionData = ix.faction.indices[character:GetFaction()]
            if (factionData and factionData.spawnPoints) then
                local spawnPointsData = factionData.spawnPoints[spawnPoint]
                if (spawnPointsData) then
                    local canUse = spawnPointsData.canUse
                    local bCanUse = canUse(character)
                    if (!bCanUse) then
                        print("Spawn point '" .. spawnPoint .. "' for faction '" .. factionData.name .. "' is not available for character '" .. character:GetName() .. "'")
                        return
                    end

                    local spawns =  spawnPointsData.spawns
                    client:SetPos(spawns[math.random(1, #spawns)])
                else
                    print("Invalid spawn point '" .. spawnPoint .. "' for faction '" .. factionData.name .. "'")
                end
            else
                print("No spawn points for faction '" .. character:GetFaction() .. "'")
            end
        end)
    else
        net.Start("ixCharacterLoadFailure")
            net.WriteString("@unknownError")
        net.Send(client)

        ErrorNoHalt("[Helix] Attempt to load invalid character '" .. id .. "'\n")
    end
end)