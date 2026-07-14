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

local trainerEvent = ReplicatedStorage:WaitForChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:WaitForChild("PlayerDataLoadedEvent")

local sessionLockMap = MemoryStoreService:GetSortedMap("TrainingEvolution_SessionLocks_v1")
local SERVER_ID = game.JobId

local DATA_STORE_NAME = "TrainingEvolution_Data_v1"
local dataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)

local AUTOSAVE_TIME = 120

local foldersToSave = {
	"leaderstats",
	"PlayerData",
	"Upgrades",
	"TrainingTiers",
	"Items",
	"Pets",
	"Trails",
	"Trainer",
	"Resources",
	"Rewards",
	"Potions",
	"PotionTimers",
	"BoostData",
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
		return
	end

	if data then
		task.wait(1)
		applyPlayerData(player, data)
		print("DATA LOADED:", player.Name)
	else
		print("NEW PLAYER DATA:", player.Name)
	end
end

local function savePlayer(player)
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
	if not percent then
		percent = Instance.new("IntValue")
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
		end, 300)
	end)
	
	if not success then 
		warn("SESSION LOCK FAILED:", player.Name, result)
		return false
	end
	
	return result and result.ServerId == SERVER_ID
end

local function releaseSessionLock(player)
	local key = "Player_" .. player.UserId
	
	pcall(function()
		sessionLockMap:RemoveAsync(key)
	end)
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
	
	loadPlayer(player)
	
	PlayerDataSetupModule.setup(player)
	XPModule.setupPlayer(player)
	ItemModule.setupItems(player)
	
	setupPotions(player)
	setupPotionTimers(player)
	setupBoostData(player)
	
	player:SetAttribute("DataReady", true)
	print("DATA READY:", player.Name)
	playerDataLoadedEvent:Fire(player)
end)

Players.PlayerRemoving:Connect(function(player)
	if player:GetAttribute("DataReady") == true then
		savePlayer(player)
	end
	
	releaseSessionLock(player)
end)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_TIME)

		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("DataReady") == true then
			savePlayer(player)
		end
		releaseSessionLock(player)
	end

	task.wait(2)
end)

print("DataSaveServer loaded")
