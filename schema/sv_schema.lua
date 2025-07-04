function Schema:SaveRationDispensers()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_rationdispenser")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetEnabled()}
	end

	ix.data.Set("rationDispensers", data)
end

function Schema:SaveVendingMachines()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_vendingmachine")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetAllStock()}
	end

	ix.data.Set("vendingMachines", data)
end

function Schema:SaveCombineLocks()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_combinelock")) do
		if (IsValid(v.door)) then
			data[#data + 1] = {
				v.door:MapCreationID(),
				v.door:WorldToLocal(v:GetPos()),
				v.door:WorldToLocalAngles(v:GetAngles()),
				v:GetLocked()
			}
		end
	end

	ix.data.Set("combineLocks", data)
end

function Schema:SaveForceFields()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_forcefield")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetMode()}
	end

	ix.data.Set("forceFields", data)
end

-- data loading
function Schema:LoadRationDispensers()
	for _, v in ipairs(ix.data.Get("rationDispensers") or {}) do
		local dispenser = ents.Create("ix_rationdispenser")

		dispenser:SetPos(v[1])
		dispenser:SetAngles(v[2])
		dispenser:Spawn()
		dispenser:SetEnabled(v[3])
	end
end

function Schema:LoadVendingMachines()
	for _, v in ipairs(ix.data.Get("vendingMachines") or {}) do
		local vendor = ents.Create("ix_vendingmachine")

		vendor:SetPos(v[1])
		vendor:SetAngles(v[2])
		vendor:Spawn()
		vendor:SetStock(v[3])
	end
end

function Schema:LoadCombineLocks()
	for _, v in ipairs(ix.data.Get("combineLocks") or {}) do
		local door = ents.GetMapCreatedEntity(v[1])

		if (IsValid(door) and door:IsDoor()) then
			local lock = ents.Create("ix_combinelock")

			lock:SetPos(door:GetPos())
			lock:Spawn()
			lock:SetDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
			lock:SetLocked(v[4])
		end
	end
end

function Schema:LoadForceFields()
	for _, v in ipairs(ix.data.Get("forceFields") or {}) do
		local field = ents.Create("ix_forcefield")

		field:SetPos(v[1])
		field:SetAngles(v[2])
		field:Spawn()
		field:SetMode(v[3])
	end
end