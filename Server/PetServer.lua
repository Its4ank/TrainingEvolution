--// PetServer 1.3v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local XPModule = require(ReplicatedStorage.Modules.XPModule)

--// RemoteEvents
local petEvent = ReplicatedStorage:FindFirstChild("PetEvent")
local petEquipEvent = petEvent:FindFirstChild("PetEquipEvent")
local petDeleteEvent = petEvent:FindFirstChild("PetDeleteEvent")
local petUnequipAllEvent = petEvent:WaitForChild("PetUnequipAllEvent")
local petEquipBestEvent = petEvent:WaitForChild("PetEquipBestEvent")
local petUpgradeEvent = petEvent:WaitForChild("PetUpgradeEvent")
local petWarningEvent = petEvent:WaitForChild("PetWarningEvent")

--// Helpers
local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateValue(parent, className, name, defaultValue)
	local value = parent:FindFirstChild(name)
	
	if not value then
		value = Instance.new(className)
		value.Name = name
		value.Value = defaultValue
		value.Parent = parent
	end
	return value
end

local function getPetsFolder(player)
	return player:FindFirstChild("Pets")
end

local function getPlayerData(player)
	return player:FindFirstChild("PlayerData")
end

local function getMoneyValue(player)
	local playerData = getPlayerData(player)
	if not playerData then return nil end
	
	return playerData:FindFirstChild("Money")
end

local function getMaxEquippedPets(player)
	local playerData = getPlayerData(player)
	if not playerData then return PetModule.BASE_EQUIPPED_PETS end
	
	local value = playerData:FindFirstChild("MaxEquippedPets")
	if not value then return PetModule.BASE_EQUIPPED_PETS end
	
	return value.Value
end

local function getMaxStorage(player)
	local playerData = getPlayerData(player)
	if not playerData then return PetModule.DEFAULT_MAX_STORAGE end
	
	local value = playerData:FindFirstChild("MaxPetStorage")
	if not value then return PetModule.DEFAULT_MAX_STORAGE end
	
	return value.Value
end

local function getPetFolder(player, petId)
	local petsFolder = getPetsFolder(player)
	if not petsFolder then return nil end
	
	return petsFolder:FindFirstChild(petId)
end

local function getEquippedPets(player)
	local petsFolder = getPetsFolder(player)
	if not petsFolder then return {} end 
	
	local result = {}
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local equipped = petFolder:FindFirstChild("Equipped")
		
		if equipped and equipped.Value then
			table.insert(result, petFolder)
		end
	end
	return result
end

local function getEquippedCount(player)
	return #getEquippedPets(player)
end

local function getStorageCount(player)
	local petsFolder = getPetsFolder(player)
	if not petsFolder then return 0 end
	
	local count = 0
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			count += 1
		end
	end
	return count
end

local function isStorageFull(player)
	return getStorageCount(player) >= getMaxStorage(player)
end

local function fireWarning(player, message)
	petWarningEvent:FierClient(player, message)
end

--// Pet data
local function readPetData(petFolder)
	if not petFolder then return nil end
	
	local petName = petFolder:FindFirstChild("PetName")
	local pattern = petFolder:FindFirstChild("Pattern")
	local tier = petFolder:FindFirstChild("Tier")
	local level = petFolder:FindFirstChild("Level")
	
	if not petName or not pattern or not tier or not level then return nil end
	
	return {
		PetName = petName.Value,
		Pattern = pattern.Value,
		Tier = tier.Value,
		Level = level.Value,
	}
end

local function getPetOwnStats(petFolder)
	local data = readPetData(petFolder)
	if not data then return nil end
	
	return PetModule.CalculatePetStats(data.PetName, data.Pattern, data.Tier, data.Level)
end

local function getPetPowerScore(petFolder)
	local stats = getPetOwnStats(petFolder)
	return PetModule.GetPowerScore(stats)
end

--// Create pet
local function createPet(player, petName, pattern, tier)
	if isStorageFull(player) then return nil, "StorageFull" end
	
	local petConfig = PetModule.GetPetConfig(petName)
	if not petConfig then return nil, "UncknownPet" end
	
	pattern = math.clamp( tonumber(pattern) or PetModule.MIN_PATTERN, PetModule.MIN_PATTERN, PetModule.MAX_PATTERN)
	
	tier = tonumber(tier) or 0
	
	if not PetModule.GetTierConfig(tier) then tier = 0 end
	
	local petsFolder = getOrCreateFolder(player, "Pets")
	
	local petId = "Pet_" .. tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
	
	local petFolder = Instance.new("Folder")
	petFolder.Name = petId
	petFolder.Parent = petsFolder
	
	getOrCreateValue(petFolder, "StringValue", "PetName", petName)
	getOrCreateValue(petFolder, "IntValue", "Pattern", pattern)
	getOrCreateValue(petFolder, "IntValue", "Tier", tier)
	getOrCreateValue(petFolder, "IntValue", "Level", 0)
	getOrCreateValue(petFolder, "BoolValue", "Equipped", false)
	
	return petFolder
end

--// Equip / Unequip
local function setPetEquipped(player, petId, shouldEquip)
	local petFolder = getPetFolder(player, petId)
	if not petFolder then return false, "PetNotFount" end
	
	local equipped = petFolder:FindFirstChild("Equipped")
	if not equipped then return false, "InvalidPetData" end
	
	if shouldEquip then
		if equipped.Value then
			fireWarning(player, "This pet is already equipped.")
			return false, "AlreadyEquipped"
		end
		
		local maxEquipped = getMaxEquippedPets(player)
		local equippedCount = getEquippedCount(player)
		
		if equippedCount >= maxEquipped then
			fireWarning(player, "Maximum " .. tostring(maxEquipped) .. " pets equipped.")
			return false, "EquipLimit"
		end
		
		equipped.Value = true
	else
		if not equipped.Value then
			fireWarning(player, "This pet is not equipped.")
			return false, "AlreadyUnequipped"
		end
		equipped.Value = false
	end
	return true
end

local function unequipAllPets(player)
	local equippedPets = getEquippedPets(player)
	
	for _, petFolder in ipairs(equippedPets) do
		local equipped = petFolder:FindFirstChild("Equipped")
		
		if equipped then equipped.Value = false end
	end
	return true
end

--// Equip best
local function equipBestPets(player)
	local petsFolder = getPetsFolder(player)
	if not petsFolder then return false end
	
	local petList = {}
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			local powerScore = getPetPowerScore(petFolder)
			
			table.insert(petList, {Folder = petFolder, Power = powerScore,})
		end
	end
	
	table.sort(petList, function(a, b)
		return a.Power > b.Power
	end)
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local equipped = petFolder:FindFirstChild("Equipped")
		if equipped then equipped.Value = false end
	end
	
	local maxEquipped = getMaxEquippedPets(player)
	
	for index = 1, math.min(maxEquipped, #petList) do
		local equipped = petList[index].Folder:FindFirstChild("Equipped")
		if equipped then equipped.Value = true end
	end
	return true
end

--// Check if current equipped set already is best
local function isBestSetEquipped(player)
	local petsFolder = getPetsFolder(player)
	if not petsFolder then return false end
	
	local allPets = {}
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			table.insert(allPets, {Folder = petFolder, Power = getPetPowerScore(petFolder),})
		end
	end
	
	table.insert(allPets, function(a, b)
		return a.Power > b.Power
	end)
	
	local maxEquipped = getMaxEquippedPets(player)
	local targetCount = math.min(maxEquipped, #allPets)
	
	local equippedPets = getEquippedPets(player)
	
	if #equippedPets ~= targetCount then return false end
	
	local bestIds = {}
	
	for i = 1, targetCount do
		bestIds[allPets[i].Folder.Name] = true
	end
	
	for _, petFolder in ipairs(equippedPets) do
		if not bestIds[petFolder.Name] then return false end
	end
	return true
end

--// Equip Best toggle
local function toggleEquipBest(player)
	if isBestSetEquipped(player) then
		return unequipAllPets(player)
	end
	return equipBestPets(player)
end

--// Delete one pet
local function deletePet(player, petId)
	local petFolder = getPetFolder(player, petId)
	if not petFolder then return false, "PetNotFount" end
	
	local equipped = petFolder:FindFirstChild("Equipped")
	if equipped and equipped.Value then
		fireWarning(player, "Equipped pets cannot be deleted.")
		return false, "PetEquipped"
	end
	
	petFolder:Destroy()
	
	return true
end

--// Mass delete
local function deletePets(player, petIds)
	if typeof(petIds) ~= "table" then return false end
	
	local deletedCount = 0
	
	for _, petId in ipairs(petIds) do
		if typeof(petId) == "string" then
			local success = deletePet(player, petId)
			
			if success then deleteCount += 1 end
		end
	end
	return true, deletedCount
end

--// Upgrade pet level
local function upgradePet(player, petId)
	local petFolder = getPetFolder(player, petId)
	if not petFolder then return false, "PetNotFound" end
	
	local level = petFolder:FindFirstChild("Level")
	if not level then return false, "InvalidPetData" end
	
	if level.Value >= PetModule.MAX_LEVEL then
		fireWarning(player, "Pet is already max level.")
		return false, "MaxLevel"
	end
	
	local targetLevel = level.Value + 1
	local cost = PetModule.GetLevelUpgradeCost(targetLevel)
	
	if not cost then return false, "NoUpgradeConfig" end
	
	local money = getMoneyValue(player)
	if not money then return false, "MoneyNotFount" end
	
	local currentMoney = money.Value
	local currentXP = XPModule.getXP(player)
	
	local missingMoney = math.max(0, cost.Money - currentMoney)
	local missingXP = math.max(0, cost.XP - currentXP)
	
	if missingMoney > 0 or missingXP > 0 then
		local parts = {}
		
		if missingMoney > 0 then
			table.insert(parts, tostring(missingMoney) .. " Money")
		end
		
		if missingXP > 0 then
			table.insert(parts, tostring(missingXP) .. " XP")
		end
		
		fireWarning(player, "Not enoung " .. table.contact(parts, " and ") .. ".")
		return false, "NotEnoughResources"
	end
	
	money.Value -= cost.Money
	
	local xpRemoved = XPModule.removeXP(player, cost.XP)
	
	if not xpRemoved then
		money.Value += cost.Money
		
		return false, "XPRemoveFailed"
	end
	
	level.Value = targetLevel
	
	return true
end

--// Pet visuals
local function removePetVisuals(character)
	for _, child in ipairs(character:GetChildren()) do
		if child.Name:match("^PetVisual_") then
			child:Destroy()
		end
	end
end

local function getPetModule(petName)
	local config = PetModule.GetPetConfig(petName)
	if not config then return nil end
	
	local modelName = config.ModelName or config.Name
	local previewRoot = ReplicatedStorage:FindFirstChild("PetPreviewModels")
	if not previewRoot then return nil end
	
	local earth = previewRoot:FindFirstChild("Earth")
	if not earth then return nil end
	
	local egg1 = earth:FindFirstChild("Egg1")
	if not egg1 then return nil end
	
	return egg1:FindFirstChild(modelName)
end

local function getPetOffset(count)
	if count <= 1 then
		return {
			Vector3.new(0, -1.5, 4),
		}
	end
	
	if count == 2 then
		return {
			Vector3.new(-2, -1.5, 4),
			Vector3.new(2, -1.5, 3),
		}
	end
	
	if count == 3 then
		return {
			Vector3.new(-3, -1.5, 4),
			Vector3.new(0, -1.5, 4),
			Vector3.new(3, -1.5, 4),
		}
	end
	
	local offset = {}
	
	for index = 1, count do
		local row = math.floor((index - 1) / 3)
		local column = (index - 1) % 3
		
		local x = (column - 1) * 3
		local z = 4 + (row * 3)
		
		table.insert(offset, Vector3.new(x, -1.5, z))
	end
	return offset
end

local function updatePetVisuals(player)
	local character = player.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	removePetVisuals(character)
	
	local equippedPets = getEquippedPets(player)
	local offset = getPetOffset(#equippedPets)
	
	for index, petFolder in ipairs(equippedPets) do
		local petName = petFolder:FindFirstChild("PetName")
		if petName then
			local template = getPetModule(petName.Value)
			
			if template then
				local clone = template:Clone()
				
				clone.Name = "PetVisual_" .. tostring(index)
				clone.Parent = character
				
				for _, object in ipairs(clone:GetDescendants()) do
					if object:IsA("BasePart") then
						object.Anchored = true	
						object.CanCollide = true
						object.Massless = true
					end
				end
				
				local offset = offset[index] or Vector3.new(0, -1.5, 4)
				
				clone:PivotTo(hrp.CFrame * CFrame.new(offset))
			end
		end
	end
end

--// Following visuals
local followTokens = {}

local function stopFollowing(player)
	followTokens[player] = (followTokens[player] or 0) + 1
end

local function startFolloming(player)
	stopFollowing(player)
	
	local token = followTokens[player]
	
	task.spawn(function()
		while player.Parent do 
			if followTokens[player] ~= token then break end
			
			local character = player.Character
			if not character then break end
			
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if not hrp then break end
			
			local equippedPets = getEquippedPets(player)
			local offset = getPetOffset(#equippedPets)
			
			for index, _ in ipairs(equippedPets) do
				local visual = character:FindFirstChild("PetVisual_" .. tostring(index))
				
				if visual then
					local offset = offset[index] or Vector3.new(0, -1.5, 4)
					local targetPosition = (hrp.CFrame * CFrame.new(offset)).Position
					local time = os.clock()
					
					targetPosition += Vector3.new(0, math.sin(time * 3 + index) * 0.5, 0)
					
					local currentPosition = visual:GetPivot().Position
					local newPosition = currentPosition:Lerp(targetPosition, 0.1)
					
					visual:PivotTo(CFrame.new(newPosition, hrp.Position) * CFrame.Angles(0, math.rad(180), 0))
				end
			end
			task.wait(0.03)
		end
	end)
end

local function refreshPetVisuals(player)
	updatePetVisuals(player)
	
	if #getEquippedPets(player) > 0 then
		startFolloming(player)
	else
	    stopFollowing(player)
	end
end

--// Events
petEquipEvent.OnServerEvent:Connect(function(player, petId, shouldEquip)
	if typeof(petId) ~= "string" then return end
	if typeof(shouldEquip) ~= "boolean" then return end
	
	local success = setPetEquipped(player, petId, shouldEquip)
	
	if success then
		refreshPetVisuals(player)
	end
end)

petDeleteEvent.OnServerEvent:Connect(function(player, petIds)
	if typeof(petIds) == "string" then
		deletePet(player, petIds)
	elseif typeof(petIds) == "table" then
		deletePets(player, petIds)
	end
end)

petUnequipAllEvent.OnServerEvent:Connect(function(player)
	unequipAllPets(player)
	refreshPetVisuals(player)
end)

petEquipBestEvent.OnServerEvent:Connect(function(player)
	toggleEquipBest(player)
	refreshPetVisuals(player)
end)

petUpgradeEvent.OnServerEvent:Connect(function(player, petId)
	if typeof(petId) ~= "string" then return end
	upgradePet(player, petId)
end)

--// Player setup
local function setupPlayer(player)
	getOrCreateFolder(player, "Pets")
	
	player.CharacterAdded:Connect(function()
		task.wait(1)
		
		refreshPetVisuals(player)
	end)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
	
	if player.Character then
		task.defer(function()
			task.wait(1)
			refreshPetVisuals(player)
		end)
	end
end

Players.PlayerRemoving:Connect(function(player)
	followTokens[player] = nil
end)

print("PetServer 1.3 loaded")
