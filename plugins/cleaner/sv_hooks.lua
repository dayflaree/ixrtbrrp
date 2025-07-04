local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
    timer.Simple(1, function()
        self.allow = true
    end)

    if ( timer.Exists("ixEntityCleaner") ) then
        timer.Remove("ixEntityCleaner")
    end

    timer.Create("ixEntityCleaner", 1, 0, function()
        for k, v in pairs(ents.GetAll()) do
            if ( IsValid(v) ) then
                local class = v:GetClass()
                if ( self.allow ) then
                    local time = self.entities[class]
                    if ( time ) then
                        local id = "ixEntityCleaner." .. v:EntIndex()
                        timer.Create(id, time, 1, function()
                            if ( !IsValid(v) ) then
                                timer.Remove(id)
                                return
                            end

                            if ( v:GetNetVar("Vanguard.Owner") ) then
                                timer.Remove(id)
                                return
                            end

                            v:Remove()
                        end)
                    end
                end

                if ( self.entityCollisions[class] ) then
                    v:SetCollisionGroup(self.entityCollisions[class])
                end
            end
        end
    end)
end

function PLUGIN:OnReloaded()
    self:InitPostEntity()
end