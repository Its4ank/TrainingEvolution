--// DataSaveServer
-- Сохраняет прогресс игрока

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemModule = require(game.ServerScriptService.Modules.ItemModule)
local XPModule = require(game.ServerScriptService.Modules.XPModule)
local PlayerDataSetupModule = require(game.ServerScriptService.Modules.PlayerDataSetupModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)

local trainerEvent = ReplicatedStorage:WaitForChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:WaitForChild("PlayerDataLoadedEvent")

local grantPotionPurchaseFunction = ServerScriptService:FindFirstChild("GrantPotionPurchaseFunction")
if not grantPotionPurchaseFunction then
	grantPotionPurchaseFunction = Instance.new("BindableFunction")
	grantPotionPurchaseFunction.Name = "GrantPotionPurchaseFunction"
	grantPotionPurchaseFunction.Parent = ServerScriptService
end

local sessionLockMap = MemoryStoreService:GetSortedMap("TrainingEvolution_SessionLocks_v1")
local SERVER_ID = game.JobId

local DATA_STORE_NAME = "TrainingEvolution_Data_v2"
local dataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)

local AUTOSAVE_TIME = 60
local SESSION_LOCK_TTL = 300
local SESSION_LOCK_REFRESH_TIME = 60

local foldersToSave = {
	"leaderstats",
	"PlayerData",
	"Upgrades",
	"Treadmills",
	"Items",
	"Pets",
	"Trails",
	"Trainer",
	"Resources",
	"Rewards",
	"Potions",
	"PotionTimers",
	"BoostData",
	"PurchaseReceipts",
}

local function isSavableValue(obj)
	return obj:IsA("IntValue")
		or obj:IsA("NumberValue")
		or obj:IsA("BoolValue")
		or obj:IsA("StringValue")
end

local function serializeFolder(folder)
	local data = {}

	for _, child in ipairs(folder:GetChildren()) do
		if isSavableValue(child) then
			data[child.Name] = {
				ClassName = child.ClassName,
				Value = child.Value,
			}
		elseif child:IsA("Folder") then
			data[child.Name] = {
				ClassName = "Folder",
				Children = serializeFolder(child),
			}
		end
	end

	return data
end

local function createValue(className)
	if className == "IntValue" then
		return Instance.new("IntValue")
	elseif className == "NumberValue" then
		return Instance.new("NumberValue")
	elseif className == "BoolValue" then
		return Instance.new("BoolValue")
	elseif className == "StringValue" then
		return Instance.new("StringValue")
	end
	
	return nil
end

local function applyDataToFolder(folder, data)
	if type(data) ~= "table" then return end
	
	for name, savedObj in pairs(data) do
		local currentObj = folder:FindFirstChild(name)
		
		if savedObj.ClassName == "Folder" then
			if not currentObj then
				currentObj = Instance.new("Folder")
				currentObj.Name = name
				currentObj.Parent = folder
			end
			
			if currentObj:IsA('Folder') then
				applyDataToFolder(currentObj, savedObj.Children)
			end
		else
			if not currentObj then
				currentObj = createValue(savedObj.ClassName)
				
				if currentObj then
					currentObj.Name = name
					currentObj.Parent = folder
				end
			end
			
			if currentObj and isSavableValue(currentObj) then
				currentObj.Value = savedObj.Value
			end
		end
	end
end

local function collectPlayerData(player)
	local data = {}

	for _, folderName in ipairs(foldersToSave) do
		local folder = player:FindFirstChild(folderName)

		if folder and folder:IsA("Folder") then
			data[folderName] = serializeFolder(folder)
		end
	end

	return data
end

local function applyPlayerData(player, data)
	if type(data) ~= "table" then return end
	
	for _, folderName in ipairs(foldersToSave) do
		local folderData = data[folderName]
		
		if folderData then
			local folder = player:FindFirstChild(folderName)
			
			if not folder then
				folder = Instance.new("Folder")
				folder.Name = folderName
				folder.Parent = player
			end
			applyDataToFolder(folder, folderData)
		end
	end	
end

local function loadPlayer(player)
	local key = "Player_" .. player.UserId

	local success, data = pcall(function()
		return dataStore:GetAsync(key)
	end)

	if not success then
		warn("DATA LOAD FAILED:", player.Name, data)
		return false
	end

	if data then
		task.wait(1)
		applyPlayerData(player, data)
		print("DATA LOADED:", player.Name)
	else
		print("NEW PLAYER DATA:", player.Name)
	end
	return true
end

local playerSaveLocks = {}

local function lockPlayerSave(player)
	local userId = player.UserId
	while playerSaveLocks[userId] do
		task.wait()
	end
	playerSaveLocks[userId] = true
end

local function unlockPlayerSave(player)
	playerSaveLocks[player.UserId] = nil
end

local function savePlayerUnlocked(player)
	local key = "Player_" .. player.UserId
	local data = collectPlayerData(player)
	
	local success, err = pcall(function()
		dataStore:SetAsync(key, data)
	end)
	
	if success then
		print("DATA SAVED:", player.Name)
	else 
		warn("DATA SAVE FAILED:", player.Name, err)
	end
	return success, err
end

local function savePlayer(player)
	lockPlayerSave(player)
	
	local success, err = savePlayerUnlocked(player)
	
	unlockPlayerSave(player)
	
	return success, err
end

local function setupPotions(player)
	local potions = player:FindFirstChild("Potions")
	if not potions then
		potions = Instance.new("Folder")
		potions.Name = "Potions"
		potions.Parent = player
	end
	
	local potionNames = { 
		"EnergyPotion",
		"MoneyPotion",
		"LuckPotion",
	}
	
	for _, potionName in ipairs(potionNames) do 
		local potion = potions:FindFirstChild(potionName)
		if not potion then
			potion = Instance.new("IntValue")
			potion.Name = potionName
			potion.Value = 0
			potion.Parent = potions
		end
	end
end

local function setupPotionTimers(player)
	local potionTimers = player:FindFirstChild("PotionTimers")
	if not potionTimers then
		potionTimers = Instance.new("Folder")
		potionTimers.Name = "PotionTimers"
		potionTimers.Parent = player
	end
	
	local timerNames = { 
		"EnergyPotionTimeLeft",
		"MoneyPotionTimeLeft",
		"LuckPotionTimeLeft",
	}
	
	for _, timerName in ipairs(timerNames) do 
		local timer = potionTimers:FindFirstChild(timerName)
		if not timer then
			timer = Instance.new("NumberValue")
			timer.Name = timerName
			timer.Value = 0
			timer.Parent = potionTimers
		end
	end
end

local function setupBoostData(player)
	local boostData = player:FindFirstChild("BoostData")
	if not boostData then
		boostData = Instance.new("Folder")
		boostData.Name = "BoostData"
		boostData.Parent = player
	end
	
	local seconds = boostData:FindFirstChild("TimeBoostSeconds")
	if not seconds then
		seconds = Instance.new("IntValue")
		seconds.Name = "TimeBoostSeconds"
		seconds.Value = 0
		seconds.Parent = boostData
	end
	
	local percent = boostData:FindFirstChild("TimeBoostPercent")
	if percent and not percent:IsA("NumberValue") then
		local oldValue = tonumber(percent.Value) or 0
		
		percent:Destroy()
		percent = Instance.new("NumberValue")
		percent.Name = "TimeBoostPercent"
		percent.Value = oldValue
		percent.Parent = boostData
	end
	
	if not percent then
		percent = Instance.new("NumberValue")
		percent.Name = "TimeBoostPercent"
		percent.Value = 0
		percent.Parent = boostData
	end
	
	local bonus = boostData:FindFirstChild("TimeBoostBonus")
	if not bonus then
		bonus = Instance.new("NumberValue")
		bonus.Name = "TimeBoostBonus"
		bonus.Value = 0
		bonus.Parent = boostData
	end
	
	local lastLeave = boostData:FindFirstChild("LastLeaveTime")
	if not lastLeave then
		lastLeave = Instance.new("NumberValue")
		lastLeave.Name = "LastLeaveTime"
		lastLeave.Value = 0
		lastLeave.Parent = boostData
	end
end

local function setupPurchaseReceipts(player)
	local receipts = player:FindFirstChild("PurchaseReceipts")
	
	if not receipts then
		receipts = Instance.new("Folder")
		receipts.Name = "PurchaseReceipts"
		receipts.Parent = player
	end
	return receipts
end

local function acquireSessionLock(player)
	local key = "Player_" .. player.UserId
	
	local success, result = pcall(function()
		return sessionLockMap:UpdateAsync(key, function(oldValue)
			if oldValue and oldValue.ServerId and oldValue.ServerId ~= SERVER_ID then
				return oldValue
			end
			
			return { 
				ServerId = SERVER_ID,
				Time = os.time(),
			}
		end, SESSION_LOCK_TTL)
	end)
	
	if not success then 
		warn("SESSION LOCK FAILED:", player.Name, result)
		return false
	end
	
	return result and result.ServerId == SERVER_ID
end

local function refreshSessionLock(player)
	local key = "Player_" .. player.UserId
	
	local success, result = pcall(function()
		return sessionLockMap:UpdateAsync(key, function(oldValue)
			if oldValue and oldValue.ServerId and oldValue.ServerId ~= SERVER_ID then
				return oldValue
			end
			
			return {
				ServerId = SERVER_ID,
				Time = os.time(),
			}
		end, SESSION_LOCK_TTL)
	end)
	
	if not success then
		warn("SESSION LOCK REFRESH FAILED:", player.Name, result)
		return false, "REQUEST_FAILED"
	end
	
	if not result or result.ServerId ~= SERVER_ID then
		warn("SESSION LOCK LOST:", player.Name)
		return false, "LOCK_LOST"
	end
	return true
end

local function releaseSessionLock(player)
	local key = "Player_" .. player.UserId

	local success, currentLock = pcall(function()
		return sessionLockMap:GetAsync(key)
	end)

	if not success then
		warn(
			"SESSION LOCK CHECK FAILED:",
			player.Name,
			currentLock
		)
		return
	end

	-- Ключ уже отсутствует
	if not currentLock then
		return
	end

	-- Этот Lock уже принадлежит другому серверу.
	-- Удалять его запрещено.
	if currentLock.ServerId ~= SERVER_ID then
		warn(
			"SESSION LOCK NOT OWNED:",
			player.Name,
			tostring(currentLock.ServerId)
		)
		return
	end

	local removeSuccess, removeError = pcall(function()
		sessionLockMap:RemoveAsync(key)
	end)

	if not removeSuccess then
		warn(
			"SESSION LOCK RELEASE FAILED:",
			player.Name,
			removeError
		)
	end
end

local ALLOWED_POTION_PRODUCTS = {
	EnergyPotion = true,
	MoneyPotion = true,
	LuckPotion = true,
}

grantPotionPurchaseFunction.OnInvoke = function(player, purchaseId, potionId, amount)
	if not player or not player:IsA("Player") then
		return false, "IMVALID_PLAYER"
	end
	
	if player:GetAttribute("DataReady") ~= true then
		return false, "DATA_NOT_READY"
	end
	
	if typeof(purchaseId) ~= "string" or purchaseId == "" then
		return false, "INVALID_PURCHASE_ID"
	end
	
	if typeof(potionId) ~= "string" or not ALLOWED_POTION_PRODUCTS[potionId] then
		return false, "INVALID_POTION"
	end
	
	amount = math.floor(tonumber(amount) or 0)
	
	if amount <= 0 or amount > 10 then
		return false, "INVALID_AMOUNT"
	end
	
	lockPlayerSave(player)
	
	if player:GetAttribute("DataReady") ~= true then
		unlockPlayerSave(player)
		return false, "DATA_NOT_READY"
	end
	
	local receipts = setupPurchaseReceipts(player)
	local receiptName = "Receipt_" .. purchaseId
	
	if receipts:FindFirstChild(receiptName) then
		unlockPlayerSave(player)
		return true, "ALREADY_PROCESSED"
	end
	
	local potions = player:FindFirstChild("Potions")
	local potionValue = potions and potions:FindFirstChild(potionId)
	
	if not potionValue or not potionValue:IsA("IntValue") then
		unlockPlayerSave(player)
		return false, "POTION_VALUE_NOT_FOUND"
	end
	
	potionValue.Value += amount
	
	local receiptValue = Instance.new("NumberValue")
	receiptValue.Name = receiptName
	receiptValue.Value = os.time()
	receiptValue.Parent = receipts
	
	local saved, saveError = savePlayerUnlocked(player)
	
	if not saved then
		potionValue.Value -= amount
		receiptValue:Destroy()
		
		unlockPlayerSave(player)
		
		warn("PURCHASE PROFILE SAVE FAILED:", player.Name, purchaseId, saveError)
		return false, "SAVE_FAILED"
	end
	unlockPlayerSave(player)
	return true, "PURCHASE_GRANTED"
end

Players.PlayerAdded:Connect(function(player)
	local lockOk = acquireSessionLock(player)
	
	if not lockOk then
		player:Kick("This account is already playing on another device. Please close the other session and rejoin.")
		return
	end
	
	player:SetAttribute("DataReady", false)
	
	PlayerDataSetupModule.setup(player)
	XPModule.setupPlayer(player)
	ItemModule.setupItems(player)
	
	setupPotions(player)
	setupPotionTimers(player)
	setupBoostData(player)
	setupPurchaseReceipts(player)
	
	local loadSuccess = loadPlayer(player)
	
	if not loadSuccess then
		warn("PLAYER DATA WAS NOT LOADED:", player.Name)
		
		releaseSessionLock(player)
		player:Kick("Не удалось загрузить ваши данные. " .. "Пожалуйста, зайдите в игру еще раз.")
		return
	end
	
	PlayerDataSetupModule.setup(player)
	XPModule.setupPlayer(player)
	ItemModule.setupItems(player)
	
	setupPotions(player)
	setupPotionTimers(player)
	setupBoostData(player)
	setupPurchaseReceipts(player)
	
	player:SetAttribute("DataReady", true)
	print("DATA READY:", player.Name)
	playerDataLoadedEvent:Fire(player)
end)

Players.PlayerRemoving:Connect(function(player)
	if player:GetAttribute("DataReady") == true then
		BoostModule.RemovePlayer(player)
		savePlayer(player)
	end
	
	releaseSessionLock(player)
end)

task.spawn(function()
	while true do
		task.wait(SESSION_LOCK_REFRESH_TIME)
		
		for _, player in ipairs(Players:GetPlayers()) do
			local refreshed, reason = refreshSessionLock(player)
			
			if not refreshed and reason == "LOCK_LOST" then
				player:SetAttribute("DataReady", false)
				player:Kick("Ваша игровая сессия была открыта " .. "на другом сервере. Пожалуйста зайдите снова.")
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_TIME)

		for _, player in ipairs(Players:GetPlayers()) do
			if player:GetAttribute("DataReady") == true then
				savePlayer(player)
			end
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("DataReady") == true then
			BoostModule.RemovePlayer(player)
			savePlayer(player)
		end
		releaseSessionLock(player)
	end
end)

print("DataSaveServer loaded")
