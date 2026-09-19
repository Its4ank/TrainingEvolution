--// EggServer 1.3v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")

--// Modules
local EggModule = require(ReplicatedStorage.Modules.EggModule)
local PetModule = require(ReplicatedStorage.Modules.PetModule)

local PetServiceModule = require(ServerScriptService.Modules.PetServiceModule)

--// EggEvent
local eggEvent = ReplicatedStorage:WaitForChild("EggEvent")

local hatchRequestFunction = eggEvent:WaitForChild("HatchRequestFunction")
local eggStateFunction = eggEvent:WaitForChild("EggStateFunction")
local specificAutoDeleteEvent = eggEvent:WaitForChild("SpecificAutoDeleteEvent")
local globalAutoDeleteEvent = eggEvent:WaitForChild("GlobalAutoDeleteEvent")
local eggDataChangedEvent = eggEvent:WaitForChild("EggDataChangedEvent")
local eggWarningEvent = eggEvent:WaitForChild("EggWarningEvent")

--// Runtime protection
local hatchLocks = {}

--// Basic data
local function getPlayerData(player)
	return player:FindFirstChild("PlayerData")
end

local function getEggData(player)
	return player:FindFirstChild("EggData")
end

local function getMoney(player)
	local playerData = getPlayerData(player)
	if not playerData then return nil end
	
	return playerData:FindFirstChild("Money")
end

local function getEggHatched(player)
	local playerData = getPlayerData(player)
	if not playerData then return nil end
	
	return playerData:FindFirstChild("EggHatched")
end

local function getLuckOpenings(player)
	local eggData = getEggData(player)
	if not eggData then return nil end
	
	return eggData:FindFirstChild("LuckOpenings")
end

local function getLastLeaveTime(player)
	local eggData = getEggData(player)
	if not eggData then return nil end
	
	return eggData:FindFirstChild("LastLeaveTime")
end

local function getEggOpenedValue(player, eggName)
	local eggData = getEggData(player)
	if not eggData then return nil end
	
	local eggOpened = eggData:FindFirstChild("EggOpened")
	if not eggOpened then return nil end
	
	return eggOpened:FindFirstChild(eggName)
end

--// Warnings
local function fireWarning(player, message)
	eggWarningEvent:FireClient(player, message)
end

--// Gamepasses
local function hasTestGamepass(passName)
	local testConfig = EggModule.TestGamepasses
	if not testConfig then return false end
	
	if testConfig.Enabled ~= true then return false end
	
	return testConfig[passName] == true
end

local function hasGamepass(player, passName)
	if hasTestGamepass(passName) then return true end
	
	local passId = EggModule.Gamepasses[passName]
	if not passId or passId <= 0 then return false end
	
	local success, ownsPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	
	if not success then
		warn("GAMEPASS CHECK FAILED:", player.Name, passName)
		return false
	end
	return ownsPass == true
end

--// Pattern roll
local function rollPattern()
	local roll = math.random() * 100
	local accumulatedChance = 0
	
	for _, range in ipairs(PetModule.GetPatternRanges()) do
		accumulatedChance += range.Chance
		
		if roll <= accumulatedChance then
			return math.random(range.MinPattern, range.MaxPattern)
		end
	end
	return PetModule.MIN_PATTERN
end

--// Tier roll
local function rollTier()
	local roll = math.random() * 100
	local accumulatedChance = 0
	
	for tier = 0, 5 do
		local tierConfig = PetModule.GetTierConfig(tier)
		
		if tierConfig then
			accumulatedChance += tierConfig.Chance
			
			if roll <= accumulatedChance then
				return tier
			end
		end
	end
	return 0
end

--// Luck pet chance
local function getLuckWeight(petName)
	local petConfig = PetModule.GetPetConfig(petName)
	if not petConfig then return 0 end
	
	local rarityConfig = PetModule.GetRarityConfig(petConfig.Rarity)
	if not rarityConfig then return 0 end
	
	local rarityOrder = rarityConfig.Order or 1
	
	return math.clamp((rarityOrder - 1) / 4, 0, 1)
end

local function getAdjustedPetWeights(eggName, luckMultiplier)
	local eggConfig = EggModule.GetEggConfig(eggName)
	if not eggConfig then return nil end
	
	local weights = {}
	local totalWeight = 0
	
	for _, eggPet in ipairs(eggConfig.Pets) do
		local luckWeight = getLuckWeight(eggPet.PetName)
		local luckBonus = 1 + (luckMultiplier - 1) * luckWeight
		local adjustedWeight = eggPet.Chance * luckBonus
		
		totalWeight += adjustedWeight
		
		table.insert(weights, {
			PetName = eggPet.PetName,
			Weight = adjustedWeight,
		})
	end
	return weights, totalWeight
end

local function rollPet(eggName, luckMultiplier)
	local weights, totalWeight = getAdjustedPetWeights(eggName, luckMultiplier)
	if not weights or totalWeight <= 0 then return nil end
	
	local roll = math.random() * totalWeight
	local accumulatedWeight = 0
	
	for _, petData in ipairs(weights) do
		accumulatedWeight += petData.Weight
		
		if roll <= accumulatedWeight then
			return petData.PetName
		end
	end
	return weights[#weights].PetName
end

--// Auto Delete
local function getSpecificAutoDeleteValue(player, eggName, petName)
	local eggData = EggModule.GetEggData(player)
	if not eggData then return nil end
	
	local autoDelete = eggData:FindFirstChild("EggAutoDelete")
	if not autoDelete then return nil end
	
	local eggFolder = autoDelete:FindFirstChild(eggName)
	if not eggFolder then return nil end
	
	return eggFolder:FindFirstChild(petName)
end

local function getGlobalAutoDeleteValue(player, rarityName)
	local eggData = getEggData(player)
	if not eggData then return nil end
	
	local globalAutoDelete = eggData:FindFirstChild("GlobalAutoDelete")
	if not globalAutoDelete then return nil end
	
	return globalAutoDelete:FindFirstChild(rarityName)
end

local function shouldAutoDelete(player, eggName, petName)
	local eggConfig = EggModule.GetEggConfig(eggName)
	local petConfig = PetModule.GetPetConfig(petName)
	if not eggConfig or not petConfig then return false end
	
	local cpecificValue = getSpecificAutoDeleteValue(player, eggName, petName)
	if cpecificValue and cpecificValue.Value then return true end
	
	if eggConfig.AllowGlobalAutoDelete ~= true then return false end
	
	local globalValue = getGlobalAutoDeleteValue(player, petConfig.Rarity)
	if globalValue and globalValue.Value then return true end
	
	return false
end

--// Calculate maximum hatch amount
local function getMaximumRequestedAmount(player, requestedAmount, hasTriple)
	requestedAmount = math.clamp(math.floor(tonumber(requestedAmount) or 1), 1, EggModule.MAX_MULTI_HATCH)
	if not hasTriple then return 1 end
	
	return requestedAmount
end

local function getAvailableHatchAmount(player, eggName, requestedAmount, hasTriple)
	local money = getMoney(player)
	if not money then
		return 0, 0, "MoneyNotFound"
	end
	
	local openedValue = getEggOpenedValue(player, eggName)
	if not openedValue then
		return 0, 0, "EggOpenedNotFound"
	end
	
	local maxRequested = getMaximumRequestedAmount(player, requestedAmount, hasTriple)
	local freeStorage = PetServiceModule.GetFreeStorage(player)
	
	local storageAmount = math.min(maxRequested, freeStorage)
	if storageAmount <= 0 then
		return 0, 0, "StorageFull"
	end
	
	local affordableAmount, totalPrice = EggModule.GetAffordableAmount(eggName, openedValue.Value, money.Value, storageAmount)
	if affordableAmount <= 0 then
		return 0, 0, "NotEnoughMoney"
	end
	
	return affordableAmount, totalPrice, nil
end

--// One hatch result
local function createHatchResult(player, eggName, luckMultiplier)
	local petName = rollPet(eggName, luckMultiplier)
	if not petName then
		return nil, "PetRollFailed"
	end
	
	local petConfig = PetModule.GetPetConfig(petName)
	if not petConfig then
		return nil, "PetConfigNotFound"
	end
	
	local pattern = rollPattern()
	local tier = rollTier()
	
	local autoDeleted = shouldAutoDelete(player, eggName, petName)
	local petId = nil
	
	if not autoDeleted then
		local petFolder, createError = PetServiceModule.CreatePet(player, petName, pattern, tier)
		if not petFolder then
			return nil, createError or "PetCreateFailed"
		end
		petId = petFolder.Name
	end
	
	return {
		PetId = petId,
		
		PetName = petName,
		DisplayName = PetModule.GetDisplayName(petName),
		
		Rarity = petConfig.Rarity,
		
		Pattern = pattern,
		Tier = tier,
		
		AutoDeleted = autoDeleted,
	}
end

--// Hatch request
local function hatchEgg(player, eggName, requestedAmount)
	if player:GetAttribute("DataReady") ~= true then
		return {
			Success = false,
			Error = "DataNotReady",
		}
	end
	
	if hatchLocks[player] then
		return {
			Success = false,
			Error = "HatchBusy",
		}
	end
	
	local eggConfig = EggModule.GetEggConfig(eggName)
	if not eggConfig then
		return {
			Success = false,
			Error = "UnknownEgg",
		}
	end
	
	hatchLocks[player] = true
	
	local success, response = pcall(function()
		local triplePass = hasGamepass(player, "TripleHatch")
		local amount, totalPrice, amountError = getAvailableHatchAmount(player, eggName, requestedAmount, triplePass)
		
		if amount <= 0 then
			return {
				Success = false,
				Error = amountError,
			}
		end
		
		local money = getMoney(player)
		local eggHatched = getEggHatched(player)
		
		local openedValue = getEggOpenedValue(player, eggName)
		local luckOpenings = getLuckOpenings(player)
		
		if not money or not eggHatched or not openedValue or not luckOpenings then
			return {
				Success = false,
				Error = "EggDataMissing",
			}
		end
		
		money.Value -= totalPrice
		
		local results = {}
		
		for _ = 1, amount do
			local luckMultiplier = EggModule.GetLuckMultiplier(luckOpenings.Value)
			local result, hatchError = createHatchResult(player, eggName, luckMultiplier)
			if not result then
				for _, oldResult in ipairs(results) do
					if oldResult.PetId then
						local petsFolder = player:FindFirstChild("Pets")
						local petFolder = petsFolder and petsFolder:FindFirstChild(oldResult.PetId)
						if petFolder then
							petFolder:Destroy()
						end
					end
				end
				money.Value += totalPrice
				
				return {
					Success = false,
					Error = hatchError or "HatchFailed",
				}
			end
			
			table.insert(results, result)
			
			
			openedValue.Value += 1
			eggHatched.Value += 1
			
			if luckOpenings.Value < EggModule.Luck.MaxOpenings then
				luckOpenings.Value += 1
			end
		end
		
		return {
			Success = true,
			
			EggName = eggName,
			Amount = amount,
			Price = totalPrice,
			
			Results = results,
			
			EggOpened = openedValue.Value,
			
			LuckOpenings = luckOpenings.Value,
			
			LuckMultiplier = EggModule.GetLuckMultiplier(luckOpenings.Value),
		}
	end)
	
	hatchLocks[player] = nil
	
	if not success then
		warn("EGG HATCH ERROR:", player.Name, response)
		return {
			Success = false,
			Error = "ServerError",
		}
	end
	return response
end

--// State sent to UI
local function getEggState(player, eggName)
	if player:GetAttribute("DataReady") ~= true then return nil end
	
	local eggConfig = EggModule.GetEggConfig(eggName)
	if not eggConfig then return nil end
	
	local money = getMoney(player)
	
	local openedValue = getEggOpenedValue(player, eggName)
	local luckOpenings = getLuckOpenings(player)
	
	if not money or not openedValue or not luckOpenings then return nil end
	
	local hasTriple = hasGamepass(player, "TripleHatch")
	local hasAuto = hasGamepass(player, "AutoHatch")
	
	local requestedMax = hasTriple and EggModule.MAX_MULTI_HATCH or 1
	local availableAmount, batchPrice, reason = getAvailableHatchAmount(player, eggName, requestedMax, hasTriple)
	
	local pets = {}
	
	local luckMultiplier = EggModule.GetLuckMultiplier(luckOpenings.Value)
	local adjustedWeights, totalWeight = getAdjustedPetWeights(eggName, luckMultiplier)
	
	local chanceByPet = {}
	
	if adjustedWeights and totalWeight > 0 then
		for _, data in ipairs(adjustedWeights) do
			chanceByPet[data.PetName] = (data.Weight / totalWeight) * 100
		end
	end
	
	for _, eggPet in ipairs(eggConfig.Pets) do
		local petConfig = PetModule.GetPetConfig(eggPet.PetName)
		local specificValue = getSpecificAutoDeleteValue(player, eggName, eggPet.PetName)
		
		table.insert(pets, {
			PetName = eggPet.PetName,
			
			DisplayName = PetModule.GetDisplayName(eggPet.PetName),
			
			Rarity = petConfig and petConfig.Rarity or "",
			ModelName = petConfig and petConfig.ModelName or eggPet.PetName,
			ButtonName = eggPet.ButtonName,
			Chance = chanceByPet[eggPet.PetName] or eggPet.Chance,
			SpecificAutoDelete = specificValue and specificValue.Value or false,
		})
	end
	
	local globalAutoDelete = {}
	
	for _, rarityName in ipairs({
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		}) do
		
		local value = getGlobalAutoDeleteValue(player, rarityName)
		
		globalAutoDelete[rarityName] = value and value.Value or false
	end
	
	return {
		EggName = eggName,
		Money = money.Value,
		EggOpened = openedValue.Value,
		CurrentPrice = EggModule.GetEggPrice(eggName, openedValue.Value),
		AvailableAmount = availableAmount,
		BatchPrice = batchPrice,
		UnavailableReason = reason,
		HasTripleHatch = hasTriple,
		HasAutoHatch = hasAuto,
		FreeStorage = PetServiceModule.GetFreeStorage(player),
		luckOpenings = luckOpenings.Value,
		LuckMultiplier = luckMultiplier,
		Pets = pets,
		GlobalAutoDelete = globalAutoDelete,
	}
end

--// Specific Auto Delete toggle
specificAutoDeleteEvent.OnServerEvent:Connect(function(player, eggName, petName)
	if player:GetAttribute("DataReady") ~= true then return end 
	if typeof(eggName) ~= "string" or typeof(petName) ~= "string" then return end 
	
	local eggPetConfig = EggModule.GetEggConfig(eggName, petName)
	if not eggPetConfig then return end 
	
	local value = getSpecificAutoDeleteValue(player, eggName, petName)
	if not value then return end 
	
	value.Value = not value.Value
	eggDataChangedEvent:FireClient(player, eggName)
end)

--// Global rarity Auto Delete toggle
globalAutoDeleteEvent.OnServerEvent:Connect(function(player, rarityName)
	if player:GetAttribute("DataReady") ~= true then return end 
	if typeof(rarityName) ~= "string" then return end 
	
	if not PetModule.GetRarityConfig(rarityName) then return end 
	
	local value = getGlobalAutoDeleteValue(player, rarityName)
	if not value then return end 
	
	value.Value = not value.Value
	eggDataChangedEvent:FireClient(player)
end)

--// Client requests
hatchRequestFunction.OnServerInvoke = function(player, eggName, requestedAmount)
	if typeof(eggName) ~= "string" then
		return {
			Success = false,
			Error = "InvalidEgg"
		}
	end
	
	return hatchEgg(player, eggName, requestedAmount)
end

eggStateFunction.OnServerInvoke = function(player, eggName)
	if typeof(eggName) ~= "string" then return nil end
	
	return getEggState(player, eggName)
end

--// Luck offline handling
local function checkOfflineLuck(player)
	local luckOpenings = getLuckOpenings(player)
	local lastLeave = getLastLeaveTime(player)
	
	if not luckOpenings or not lastLeave then return end 
	if lastLeave.Value <= 0 then return end 
	
	local offlineTime = os.time() - lastLeave.Value
	
	if offlineTime > EggModule.Luck.OfflineResetTime then
		luckOpenings.Value = 0
	end
end

--// Existing project fires this after data load
local trainerEvent = ReplicatedStorage:WaitForChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:WaitForChild("PlayerDataLoadedEvent")

playerDataLoadedEvent.Event:Connect(function(player)
	checkOfflineLuck(player)
end)

--// Leave timestamp
Players.PlayerRemoving:Connect(function(player)
	if player:GetAttribute("DataReady") ~= true then return end 
	
	local lastLeave = getLastLeaveTime(player)
	
	if lastLeave then
		lastLeave.Value = os.time()
	end
	
	hatchLocks[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("DataReady") == true then
			local lastLeave = getLastLeaveTime(player)
			
			if lastLeave then
				lastLeave.Value = os.time()
			end
		end
	end
end)

print("EggServer 1.3 loaded")