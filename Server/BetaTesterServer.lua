local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local betaStore = DataStoreService:GetDataStore("TrainingEvolution_BetaTesters_v1")

-- Пока идет бета-тест = true 
-- Когда выйдет релиз = false
local BETA_ACTIVE = true 

-- Когда будешь готов выдать награды за бету, поставишь true 
local RELEASE_REWARDS_ACTIVE = false

local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	
	if not folder then 
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateBool(parent, name, defaultValue)
	local value = parent:FindFirstChild(name)
	
	if not value then 
		value = Instance.new("BoolValue")
		value.Name = name
		value.Value = defaultValue
		value.Parent = parent
	end
	return value
end

local function markBetaTester(player)
	local key = "Player_" .. player.UserId
	
	local success, result = pcall(function()
		return betaStore:UpdateAsync(key, function(oldData)
			oldData = oldData or {}
			
			oldData.IsBetaTester = true 
			oldData.FirstMarkedTime = oldData.FirstMarkedTime or os.time()
			
			return oldData
		end)
	end)
	
	if success then 
		print("BETA TESTER MARKED:", player.Name)
		return true 
	else 
		warn("FAILED TO MARK BETA TESTER:", player.Name, result)
		return false
	end
end

local function loadBetaData(player)
	local key = "Player_" .. player.UserId
	
	local success, data = pcall(function()
		return betaStore:GetAsync(key)
	end)
	
	if success and data then 
		return data
	end
	
	return nil
end

local function giveBetaReward(player)
	-- СЮДА ПОТОМ ДОБАВИМ НАГРАДУ
	-- Например
	--1. Выдать Beta Pet
	--2. Выдать туг Beta Tester
	--3. Выдать бонусы
	
	print("BETA REWARD GIVEN TO:", player.Name)
end

local function markRewardClaimed(player)
	local key = "Player_" .. player.UserId
	
	local success, result = pcall(function()
		return betaStore:UpdateAsync(key, function(oldData)
			oldData = oldData or {}
			
			oldData.IsBetaTester = oldData.IsBetaTester == true
			oldData.BetaRewardClaimed = true
			oldData.RewardClaimTime = os.time()
			
			return oldData
		end)
	end)
	
	if not success then 
		warn("FAILED TO MARK BETA REWARD CLAIMED:", player.Name, result)
	end
end

Players.PlayerAdded:Connect(function(player)
	local playerData = getOrCreateFolder(player, "PlayerData")

	local betaTesterValue = getOrCreateBool(playerData, "BetaTester", false)
	local betaRewardClaimedValue = getOrCreateBool(playerData, "BetaRewardClaimed", false)

	task.wait(5)

	local betaData = loadBetaData(player)

	if BETA_ACTIVE then
		local marked = markBetaTester(player)

		if marked then
			betaTesterValue.Value = true
		end
	else
		if betaData and betaData.IsBetaTester == true then
			betaTesterValue.Value = true
		else
			betaTesterValue.Value = false
		end
	end

	if betaData and betaData.BetaRewardClaimed == true then
		betaRewardClaimedValue.Value = true
	end

	if RELEASE_REWARDS_ACTIVE then
		if betaTesterValue.Value == true and betaRewardClaimedValue.Value == false then
			giveBetaReward(player)

			betaRewardClaimedValue.Value = true
			markRewardClaimed(player)
		end
	end
end)

print("BetaTesterServer loaded")
