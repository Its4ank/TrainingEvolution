--// TransportServer 1.3v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TransportModule = require(ReplicatedStorage.Modules.TransportModule)

local transportConfigValid, transportConfigError = TransportModule.ValidateAll()
if not transportConfigValid then
	error("[TransportServer] Invalid TransportModule config: " .. tostring(transportConfigError))
end

--// CONFIG
local DEFAULT_LOCATION = "StoneAge"
local DEFAULT_TRANSPORT = "Feet"

--// TRANSPORT TEST MODE
local TRANSPORT_TEST_MODE = true

local TEST_TRANSPORT = {
	Feet = true,
	Log = false,
	Stone = false,
}

--// HELPERS
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
		if value.ClassName == className then
			return value 
		end
		
		local recoveredValue = defaultValue
		
		if value:IsA("ValueBase") then
			local oldValue = value.Value
			
			if className == "IntValue" or className == "NumberValue" then
				local number = tonumber(oldValue)
				
				if number and number == number and number ~= math.rad and number ~= -math.huge then
					recoveredValue = className == "IntValue" and math.floor(number) or number 
				end
			elseif className == "BoolValue" then
				if oldValue == true or oldValue == "true" or oldValue == 1 then
					recoveredValue = true 
				elseif oldValue == false or oldValue == "false" or oldValue == 0 then
					recoveredValue = false
				end
			end
		end
		
		warn("[TransportServer] Incorrect value class:", name, "Expected:", className, "Found:", value.CalssName)
		value:Destroy()
		value = Instance.new(className)
		value.Name = name
		value.Value = defaultValue
		value.Parent = parent
		return value 
	end
	
	value = Instance.new(className)
	value.Name = name
	value.Value = defaultValue
	value.Parent = parent
	
	return value 
end

--// REMOTES
local transportEventFolder = ReplicatedStorage:WaitForChild("TransportEvent")

local transportActionEvent = transportEventFolder:WaitForChild("TransportActionEvent")
local transportActionResultEvent = transportEventFolder:WaitForChild("TransportActionResultEvent")
local transportWarningEvent = transportEventFolder:WaitForChild("TransportWarningEvent")

--// RUNTIME
local actionLocks = {}

--// PLAYER RESURCE HELPER
local function getPlayerResources(player)
	local playerData = player:FindFirstChild("PlayerData")
	local resources = player:FindFirstChild("Resources")
	
	if not playerData or not resources then return nil end
	
	local values = {
		Money = playerData:FindFirstChild("Money"),
		RaceTouch = playerData:FindFirstChild("RaceTouch"),
		XP = resources:FindFirstChild("XPModule"),
		Distance = resources:FindFirstChild("Distance"),
	}
	
	if not values.Money or not values.RaceTouch or not values.XP or not values.Distance then
		return nil
	end
	return values 
end

local function getResourceValues(player)
	local resources = getPlayerResources(player)
	if not resources then return nil end
	
	return {
		Money = resources.Money.Value,
		RaceTouch = resources.RaceTouch.Value,
		XP = resources.XP.Value,
		Distance = resources.Distance.Value,
	}
end

local function getResourceObject(resources, resourceName)
	return resources[resourceName]
end

local function getMissingResource(resources, costs)
	local missing = {}
	
	for resourceName, requiredAmount in pairs(costs or {}) do
		local resource = getResourceObject(resources, resourceName)
		
		if not resource then
			missing[resourceName] = requiredAmount
		elseif resource.Value < requiredAmount then
			missing[resourceName] = requiredAmount - resource.Value
		end
	end
	return missing
end

local function hasMissingResource(missing)
	return next(missing) ~= nil
end

local function spendResources(resources, costs)
	for resourceName, amount in pairs(costs or {}) do
		if amount > 0 then
			local resource = getResourceObject(resources, resourceName)
			if not resource then return false end
			
			if resource.Value < amount then return false end 
		end
	end
	
	for resourceName, amount in pairs(costs or {}) do
		if amount > 0 then
			local resource = getResourceObject(resources, resourceName)
			resource.Value -= amount
		end
	end
	return true 
end

--// WARNING
local function fireWarning(player, warningType, data)
	transportWarningEvent:FireClient(player, warningType, data or {})
end

--// TRANSPORT DATA HELPERS
local function getTransportFolder(player, locationId, transportId)
	local transportsFolder = player:FindFirstChild("Transports")
	if not transportsFolder then return nil end
	
	local locationFolder = transportsFolder:FindFirstChild(locationId)
	if not locationFolder then return nil end
	
	return locationFolder:FindFirstChild(transportId)
end

local function getTransportValues(player, locationId, transportId)
	local folder = getTransportFolder(player, locationId, transportId)
	if not folder or not folder:IsA("Folder") then return nil end
	
	local requiredValues = {
		Unlocked = "BoolValue",
		Owned = "BoolValue",
		Equipped = "BoolValue",
		Level = "IntValue",
		Stage = "IntValue",
	}
	
	local values = {
		Folder = folder,
	}
	
	for name, className in pairs(requiredValues) do
		local value = folder:FindFirstChild(name)
		
		if not value or value.ClassName ~= className then 
			warn("[TransportServer] Missing or invalid transport value:", locationId, transportId, name)
			return nil
		end
		values[name] = value 
	end
	return values 
end

--// SETUP
local function setupTransport(player, locationId, transportId, config)
	local transportsFolder = getOrCreateFolder(player, "Transports")
	
	local locationFolder = getOrCreateFolder(transportsFolder, locationId)
	local transportFolder = getOrCreateFolder(locationFolder, transportId)
	
	getOrCreateValue(transportFolder, "BoolValue", "Unlocked", config.DefaultUnlocked == true)
	getOrCreateValue(transportFolder, "BoolValue", "Owned", config.DefaultOwned == true)
	getOrCreateValue(transportFolder, "BoolValue", "Equipped", config.DefaultEquipped == true)
	getOrCreateValue(transportFolder, "IntValue", "Level", 0)
	getOrCreateValue(transportFolder, "IntValue", "Stage", 1)
	
	return transportFolder 
end

local function setupPlayerTransports(player)
	for locationId, locationConfig in pairs(TransportModule.Locations) do
		if locationConfig.Transports then
			for transportId, transportConfig in pairs(locationConfig.Transports) do
				setupTransport(player, locationId, transportId, transportConfig)
			end
		end
	end
end

--// VALIDATE SAVED TRANSPORT PROGRESS
local function validateTransportProgress(player)
	for locationId, locationConfig in pairs(TransportModule.Locations) do
		for _, transportId in ipairs(locationConfig.TransportOrder) do
			local data = getTransportValues(player, locationId, transportId)
			
			if not data then
				warn("[TransportServer] Transport data missing:", locationId, transportId)
				continue
			end
			
			local oldStage = data.Stage.Value
			local oldLevel = data.Level.Value
			
			local stage = math.clamp(oldStage, 1, TransportModule.MAX_STAGE)
			local stageConfig = TransportModule.GetStage(stage)
			if not stageConfig then
				warn("[TransportServer] Invalid stage:", stage)
				continue
			end
			
			local level = math.clamp(oldLevel, stageConfig.MinLevel, stageConfig.MaxLevel)
			
			if oldStage ~= stage or oldLevel ~= level then
				warn("[TransportServer] Correcting transportt progress:", locationId, transportId, "Stage:", oldStage, "->", stage, "Level:", oldLevel, "->", level)
				
				data.Stage.Value = stage
				data.Level.Value = level
			end
		end
	end
end

--// TEST MODE
local function getTestTransportId()
	if not TRANSPORT_TEST_MODE then return nil end
	
	local selectedTransportId = nil
	
	for _, transportId in ipairs(TransportModule.GetTransportOrder(DEFAULT_LOCATION) or {}) do
		if TEST_TRANSPORT[transportId] == true then
			if selectedTransportId then
				warn("[TransportServer] Multiple test transports are enabled:", selectedTransportId, transportId)
				return nil
			end
			selectedTransportId = transportId
		end
	end
	return selectedTransportId
end

--// EQUIPPED STATE
local function unequipAll(player)
	local transportsFolder = player:FindFirstChild("Transports")
	if not transportsFolder then return end
	
	for _, locationFolder in ipairs(transportsFolder:GetChildren()) do
		if locationFolder:IsA("Folder") then
			for _, transportFolder in ipairs(locationFolder:GetChildren()) do
				if transportFolder:IsA("Folder") then
					local equipped = transportFolder:FindFirstChild("Equipped")

					if equipped and equipped:IsA("BoolValue") then
						equipped.Value = false
					end
				end
			end
		end
	end
end

local function equipTransportInternal(player, locationId, transportId)
	local data = getTransportValues(player, locationId, transportId)
	if not data then return false end
	
	if not data.Unlocked.Value or not data.Owned.Value then return false end
	
	unequipAll(player)
	
	data.Equipped.Value = true
	
	return true 
end

local function equipDefaultTransport(player)
	return equipTransportInternal(player, DEFAULT_LOCATION, DEFAULT_TRANSPORT)
end

local function forceEquipTestTransport(player)
	if not TRANSPORT_TEST_MODE then
		player:SetAttribute("TestTransport", nil)
		return false 
	end
	
	local transportId = getTestTransportId()
	
	if not transportId then
		player:SetAttribute("TestTransport", nil)
		warn("[TransportServer] No valid test transport selected.")
		return false
	end
	
	local transportConfig = TransportModule.GetTransport(DEFAULT_LOCATION, transportId)
	if not transportConfig then
		player:SetAttribute("TestTransport", nil)
		warn("[TransportServer] Invalid test transport:", transportId)
		return false
	end
	
	player:SetAttribute("TestTransport", transportId) 
	
	return true 
end

local function normalizeEquippedTransport(player)
	local transportsFolder = player:FindFirstChild("Transports")
	if not transportsFolder then return end
	
	local equippedCandidate = nil 
	local equippedCandidateOrder = -math.huge
	
	for locationId, locationConfig in pairs(TransportModule.Locations) do
		local locationFolder = transportsFolder:FindFirstChild(locationId)
		
		if locationFolder then
			for _, transportId in ipairs(locationConfig.TransportOrder or {}) do
				local transportFolder = locationFolder:FindFirstChild(transportId)
				local transportConfig = TransportModule.GetTransport(locationId, transportId)
				
				if transportFolder and transportConfig then
					local unlocked = transportFolder:FindFirstChild("Unlocked")
					local owned = transportFolder:FindFirstChild("Owned")
					local equipped = transportFolder:FindFirstChild("Equipped")
					
					local validEquipped = unlocked and unlocked:IsA("BoolValue") 
						and unlocked.Value and owned and owned:IsA("BoolValue") 
						and owned.Value and equipped and equipped:IsA("BoolValue") and equipped.Value
					
					if validEquipped then
						if transportConfig.Order > equippedCandidateOrder then
							if equippedCandidate then
								equippedCandidate.Value = false
							end
							
							equippedCandidate = equipped 
							equippedCandidateOrder = transportConfig.Order
						else 
							equipped.Value = false
						end
					elseif equipped and equipped:IsA("BoolValue") and equipped.Value then
						equipped.Value = false
					end
				end
			end
		end
	end
	
	if not equippedCandidate then
		equipDefaultTransport(player)
	end
end

--// UNLOCK
local function refreshTransportUnlock(player, locationId, transportId)
	local config = TransportModule.GetTransport(locationId, transportId)
	local data = getTransportValues(player, locationId, transportId)
	
	if not config or not data then return false end
	if data.Unlocked.Value then return true end
	
	if config.DefaultUnlocked then
		data.Unlocked.Value = true 
		return true 
	end
	
	local unlock = config.Unlock
	
	if not unlock or not unlock.PreviousTransport then return false end 
	
	local previousData = getTransportValues(player, locationId, unlock.PreviousTransport)
	if not previousData then return false end
	
	local canUnlock = TransportModule.CanUnlockTransport(locationId, transportId, previousData.Level.Value, previousData.Stage.Value)
	if canUnlock then
		data.Unlocked.Value = true
		return true
	end 
	
	return false
end

local function refreshLocationUnlocks(player, locationId)
	local order = TransportModule.GetTransportOrder(locationId)
	if not order then return end 
	
	for _, transportId in ipairs(order) do
		refreshTransportUnlock(player, locationId, transportId)
	end
end

local function refreshAllUnlocks(player)
	for locationId in pairs(TransportModule.Locations) do
		refreshLocationUnlocks(player, locationId)
	end
end

--// BUY
local function buyTransport(player, locationId, transportId)
	local config = TransportModule.GetTransport(locationId, transportId)
	local data = getTransportValues(player, locationId, transportId)
	
	if not config or not data then return false, "INVALID_TRANSPORT" end 
	
	refreshTransportUnlock(player, locationId, transportId)
	
	if not data.Unlocked.Value then
		fireWarning(player, "TRANSPORT_LOCKED", {LocationId = locationId, TransportId = transportId,})
		return false, "LOCKED"
	end
	
	if data.Owned.Value then
		return false, "ALREADY_OWNED"
	end
	
	if not config.Purchasable then
		return false, "NOT_PURCHASABLE"
	end
	
	local price = TransportModule.GetPurchasePrice(locationId, transportId)
	
	if not price then return false, "INVALID_PRICE" end 
	
	local resources = getPlayerResources(player)
	
	if not resources then
		return false, "RESOURCES_NOT_FOUND"
	end
	
	local missing = getMissingResource(resources, price)
	
	if hasMissingResource(missing) then
		fireWarning(player, "MISSING_RESOURCES", missing)
		return false, "MISSING_RESOURCES"
	end
	
	if not spendResources(resources, price) then
		return false, "PURCHASE_FAILED"
	end
	
	data.Owned.Value = true 
	data.Level.Value = 0
	data.Stage.Value = 1
	
	equipTransportInternal(player, locationId, transportId)
	
	return true, "PURCHASED"
end

--// EQUIP / UNEQUIP
local function equipTransport(player, locationId, transportId)
	local data = getTransportValues(player, locationId, transportId)
	if not data then return false, "INVALID_TRANSPORT" end 
	
	if not data.Unlocked.Value then
		fireWarning(player, "TRANSPORT_LOCKED", {LocationId = locationId, TransportId = transportId,})
		return false, "LOCKED"
	end
	
	if not data.Owned.Value then
		return false, "NOT_OWNED"
	end
	
	if data.Equipped.Value then
		if transportId == DEFAULT_TRANSPORT and locationId == DEFAULT_LOCATION then
			return true, "DEFAULT_STAYS_EQUIPPED"
		end
		
		equipDefaultTransport(player)
		
		return true, "UNEQUIPPED_TO_DEFAULT"
	end
	
	local success = equipTransportInternal(player, locationId, transportId)
	if not success then return false, "EQUIP_FAILED" end 
	
	return true, "EQUIPPED"
end

--// LEVEL Up 
local function upgradeTransport(player, locationId, transportId)
	local config = TransportModule.GetTransport(locationId, transportId)
	local data = getTransportValues(player, locationId, transportId)
	
	if not config or not data then
		return false, "INVALID_TRANSPORT"
	end
	
	if not data.Unlocked.Value then
		return false, "LOCKED"
	end
	
	if not data.Owned.Value then
		return false, "NOT_OWNED"
	end
	
	local currentLevel = data.Level.Value
	local currentStage = data.Stage.Value 
	
	if TransportModule.IsMaxTransport(currentLevel, currentStage) then
		return false, "MAX"
	end
	
	if not TransportModule.CanLevelUp(currentLevel, currentStage) then
		return false, "STAGE_UP_REQUIRED"
	end
	
	local price = TransportModule.GetNextLevelPrice(locationId, transportId, currentLevel)
	if not price then
		return false, "PRICE_NOT_FOUND"
	end
	
	local resources = getPlayerResources(player)
	if not resources then return false, "RESOURCES_NOT_FOUND" end 
	
	local currentResources = getResourceValues(player)
	if not currentResources then return false, "RESOURCES_NOT_FOUND" end 
	
	local hasResources = TransportModule.HasLevelResources(locationId, transportId, currentLevel, currentResources)
	if not hasResources then
		local missing = getMissingResource(resources, price)
		fireWarning(player, "MISSING_RESOURCES", missing)
		return false, "MISSING_RESOURCES"
	end
	
	if not spendResources(resources, price) then
		return false, "UPGRADE_FAILED"
	end
	
	data.Level.Value += 1
	
	refreshLocationUnlocks(player, locationId)
	
	return true, "LEVEL_UP"
end

--// STAGE UP 
local function stageUpTransport(player, locationId, transportId)
	local config = TransportModule.GetTransport(locationId, transportId)
	local data = getTransportValues(player, locationId, transportId)
	
	if not config or not data then
		return false, "INVALID_TRANSPORT"
	end
	
	if not data.Unlocked.Value then
		return false, "LOCKED"
	end
	
	if not data.Owned.Value then
		return false, "NOT_OWNED"
	end
	
	local currentLevel = data.Level.Value
	local currentStage = data.Stage.Value 
	
	if currentStage >= TransportModule.MAX_STAGE then
		return false, "MAX_STAGE"
	end
	
	local stageData = TransportModule.GetStageUpData(locationId, transportId, currentStage)
	if not stageData then 
		return false, "STAGE_DATA_NOT_FOUND"
	end
	
	local resources = getPlayerResources(player)
	if not resources then
		return false, "RESOURCES_NOT_FOUND"
	end
	
	local currentResources = getResourceValues(player)
	if not currentResources then
		return false, "RESOURCES_NOT_FOUND"
	end
	
	local progress = TransportModule.GetStageRequirementProgress(locationId, transportId, currentLevel, currentStage, currentResources)
	if not progress then
		return false, "REQUIREMENTS_NOT_FOUND"
	end
	
	if not progress.Complete then
		local missing = {}
		
		for resourceName, requirement in pairs(progress.Requirements) do
			if not requirement.Enough then
				missing[resourceName] = requirement.Missing 
			end
		end
		
		fireWarning(player, "MISSING_STAGE_REQUIREMENTS", missing)
		return false, "MISSING_REQUIREMENTS"
	end
	
	local cost = stageData.Cost or {}
	
	if not spendResources(resources, cost) then
		return false, "STAGE_UP_FAILED"
	end
	
	data.Stage.Value += 1
	
	refreshLocationUnlocks(player, locationId)
	return true, "STAGE_UP"
end

--// ACTION 
local transportActions = {
	BuyTransport = buyTransport,
	EquipTransport = equipTransport,
	UpgradeTransport = upgradeTransport,
	StageUpTransport = stageUpTransport,
}

--// REMOTE 
transportActionEvent.OnServerEvent:Connect(function(player, actionName, locationId, transportId)
	if player:GetAttribute("DataReady") ~= true then return end 
	
	if typeof(actionName) ~= "string" or typeof(locationId) ~= "string" or typeof(transportId) ~= "string" then return end
	
	local action = transportActions[actionName]
	if not action then return end 
	
	if actionLocks[player] then return end 
	actionLocks[player] = true 
	
	local success, actionSuccess, reason = pcall(action, player, locationId, transportId)
	
	actionLocks[player] = nil
	
	if not success then
		warn("TransportServer action failed:", player.Name, actionName, actionSuccess)
		
		transportActionResultEvent:FireClient(player, actionName, false, "SERVER_ERROR", locationId, transportId)
		return
	end
	
	transportActionResultEvent:FireClient(player, actionName, actionSuccess == true, reason, locationId, transportId)
end)

--// DATA LOADED
local function onPlayerDataReady(player)
	setupPlayerTransports(player)
	
	validateTransportProgress(player)
	
	refreshAllUnlocks(player)
	normalizeEquippedTransport(player)
	
	if TRANSPORT_TEST_MODE then
		forceEquipTestTransport(player)
	else 
		player:SetAttribute("TestTransport", nil)
	end
	
	player:SetAttribute("TransportServerReady", true)
end

local function waitForPlayerData(player)
	if player:GetAttribute("DataReady") == true then 
		onPlayerDataReady(player)
		return
	end
	
	while player.Parent and player:GetAttribute("DataReady") ~= true do
		player:GetAttributeChangedSignal("DataReady"):Wait()
	end
	
	if player.Parent then 
		onPlayerDataReady(player)
	end
end

--// PLAYER LIFECYCLE
Players.PlayerAdded:Connect(function(player)
	task.spawn(waitForPlayerData, player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(waitForPlayerData, player)
end

Players.PlayerRemoving:Connect(function(player)
	actionLocks[player] = nil
end)

print("TransportServer v1.3 loaded")
