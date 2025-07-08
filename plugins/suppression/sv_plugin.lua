print("[Suppression] Server loaded.")

util.AddNetworkString("suppression_fire_event")

local function writeVectorUncompressed(vector)
    net.WriteFloat(vector.x)
    net.WriteFloat(vector.y)
    net.WriteFloat(vector.z)
end

local function networkGunshotEvent(data)
    timer.Simple(0, function() 
        net.Start("suppression_fire_event", false)
            writeVectorUncompressed(data.Src)
            writeVectorUncompressed(data.Dir)
            net.WriteEntity(data.Entity)
        net.Broadcast()
    end)
end

function arc9_suppression_detour(args)
    local bullet = args[2]
    local attacker = bullet.Attacker
    
    if attacker.suppression_shotThisTick == nil then attacker.suppression_shotThisTick = false end
    if attacker.suppression_shotThisTick then return end
    if table.Count(bullet.Damaged) ~= 0 or bullet.suppr_detected then return end

    local weapon = bullet.Weapon
    local pos = attacker:GetShootPos()
    local ammotype = bullet.Weapon.Primary.Ammo
    local dir = bullet.Vel:Angle():Forward()

    timer.Simple(0, function()
        local data = {}
        data.Src = pos
        data.Dir = dir
        data.Vel = bullet.Vel
        data.Spread = Vector(0, 0, 0)
        data.Ammotype = ammotype
        data.Entity = attacker
        data.Weapon = attacker:GetActiveWeapon()
        networkGunshotEvent(data)
    end)
    
    bullet.suppr_detected = true
    attacker.suppression_shotThisTick = true

    timer.Simple(engine.TickInterval() * 2, function() attacker.suppression_shotThisTick = false end)
end

hook.Add("InitPostEntity", "suppression_create_physbul_hooks", function()
    if ARC9 then
        local function suppr_wrapfunction(a)
            return function(...)
                local args = { ... }
                arc9_suppression_detour(args)
                return a(...)
            end
        end
        ARC9.SendBullet = suppr_wrapfunction(ARC9.SendBullet)
    end

    if TFA then
        hook.Add("Think", "suppression_detecttfaphys", function()
            local latestPhysBullet = TFA.Ballistics.Bullets["bullet_registry"][table.Count(TFA.Ballistics.Bullets["bullet_registry"])]
            if not latestPhysBullet then return end
            if latestPhysBullet["suppr_detected"] then return end

            local weapon = latestPhysBullet["inflictor"]
            local pos = latestPhysBullet["bul"]["Src"]
            local dir = latestPhysBullet["velocity"]:Angle():Forward()
            local vel = latestPhysBullet["velocity"]
            local entity = latestPhysBullet["inflictor"]:GetOwner()

            if entity.suppression_shotThisTick == nil then entity.suppression_shotThisTick = false end
            if entity.suppression_shotThisTick then return end
            entity.suppression_shotThisTick = true
            timer.Simple(engine.TickInterval() * 2, function() entity.suppression_shotThisTick = false end)

            local data = {}
            data.Src = pos
            data.Dir = dir
            data.Vel = vel
            data.Spread = Vector(0, 0, 0)
            data.Ammotype = weapon.Primary.Ammo
            data.Entity = entity
            data.Weapon = weapon
            networkGunshotEvent(data)

            latestPhysBullet["suppr_detected"] = true
        end)
    end

    if ArcCW then
        hook.Add("Think", "suppression_detectarccwphys", function()
            local latestPhysBullet = ArcCW.PhysBullets[table.Count(ArcCW.PhysBullets)]
            if not latestPhysBullet or latestPhysBullet["suppr_detected"] then return end
            if latestPhysBullet["Attacker"] == Entity(0) then return end
            local entity = latestPhysBullet["Attacker"]

            if entity.suppression_shotThisTick == nil then entity.suppression_shotThisTick = false end
            if entity.suppression_shotThisTick then return end
            entity.suppression_shotThisTick = true
            timer.Simple(engine.TickInterval() * 2, function() entity.suppression_shotThisTick = false end)

            local weapon = latestPhysBullet["Weapon"]
            local pos = latestPhysBullet["Pos"]
            local dir = latestPhysBullet["Vel"]:Angle():Forward()
            local vel = latestPhysBullet["Vel"]

            local data = {}
            data.Src = pos
            data.Dir = dir
            data.Vel = vel
            data.Spread = Vector(0, 0, 0)
            data.Ammotype = weapon.Primary.Ammo
            data.Entity = entity
            data.Weapon = entity:GetActiveWeapon()
            networkGunshotEvent(data)
            
            latestPhysBullet["suppr_detected"] = true
        end)
    end

    if MW_ATTS then
        hook.Add("OnEntityCreated", "suppression_detectmw2019phys", function(ent)
            if ent:GetClass() ~= "mg_sniper_bullet" and ent:GetClass() ~= "mg_slug" then return end
            timer.Simple(0, function()
                local attacker = ent:GetOwner()
                local entity = attacker
                local weapon = attacker:GetActiveWeapon()
                local pos = ent.LastPos
                local dir = (ent:GetPos() - ent.LastPos):GetNormalized()
                local vel = ent:GetAngles():Forward() * ent.Projectile.Speed
                local ammotype = weapon.Primary and weapon.Primary.Ammo or "none"

                if entity.suppression_shotThisTick == nil then entity.suppression_shotThisTick = false end
                if entity.suppression_shotThisTick then return end
                entity.suppression_shotThisTick = true
                timer.Simple(engine.TickInterval() * 2, function() entity.suppression_shotThisTick = false end)

                local data = {}
                data.Src = pos
                data.Dir = dir
                data.Vel = vel
                data.Spread = Vector(0, 0, 0)
                data.Ammotype = ammotype
                data.Entity = attacker
                data.Weapon = weapon

                networkGunshotEvent(data)
            end)
        end)
    end

    hook.Remove("InitPostEntity", "suppression_create_physbul_hooks")
end)

hook.Add("EntityFireBullets", "suppression_EntityFireBullets", function(attacker, data)
    if data.Spread.z == 0.125 then return end -- for my blood decal workaround for MW sweps

    local entity = NULL
    local weapon = NULL
    local weaponIsWeird = false
    local ammotype = "none"

    if attacker:IsPlayer() or attacker:IsNPC() then
        entity = attacker
        weapon = entity:GetActiveWeapon()
    else
        weapon = attacker
        entity = weapon:GetOwner()
        if entity == NULL then 
            entity = attacker
            weaponIsWeird = true
        end
    end

    if not weaponIsWeird and weapon ~= NULL and entity.GetShootPos then
        local weaponClass = weapon:GetClass()

        if weaponClass == "mg_arrow" or (weaponClass == "mg_sniper_bullet" and data.Spread == Vector(0, 0, 0)) or (weaponClass == "mg_slug" and data.Spread == Vector(0, 0, 0)) then return end
        if data.Distance < 200 then return end -- melee

        if string.StartWith(weaponClass, "arccw_") then
            if data.Distance == 20000 or (data.Spread == Vector(0, 0, 0) and not weapon:IsGrenadeLauncher()) then
                return
            end
        end

        if string.StartWith(weaponClass, "arc9_") then
            if data.Spread == Vector(0, 0, 0) then return end
        end

        if game.GetTimeScale() < 1 and data.Spread == Vector(0, 0, 0) and data.Tracer == 0 then return end -- FEAR bullet time

        if entity.suppression_shotThisTick == nil then entity.suppression_shotThisTick = false end
        if entity.suppression_shotThisTick then return end
        entity.suppression_shotThisTick = true
        timer.Simple(engine.TickInterval() * 2, function() entity.suppression_shotThisTick = false end)

        if #data.AmmoType > 2 then
            ammotype = data.AmmoType
        elseif weapon.Primary then
            ammotype = weapon.Primary.Ammo
        end
    end

    local dwr_data = {}
    dwr_data.Src = data.Src
    dwr_data.Dir = data.Dir
    dwr_data.Vel = Vector(0, 0, 0)
    dwr_data.Spread = data.Spread
    dwr_data.Ammotype = ammotype
    dwr_data.Entity = entity
    dwr_data.Weapon = weapon
    networkGunshotEvent(dwr_data)
end)
