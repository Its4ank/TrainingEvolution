local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RewardModule = require(game.ServerScriptService.Modules.RewardModule)

local rewardEventFolder = ReplicatedStorage:WaitForChild("RewardEvent")

local hourlyUpdateEvent = rewardEventFolder:WaitForChild("HourlyRewardUpdateEvent")
local claimHourlyRewardEvent = rewardEventFolder:WaitForChild("ClaimHourlyRewardEvent")
local requestHourlyRewardUpdateEvent = rewardEventFolder:WaitForChild("RequestHourlyRewardUpdateEvent")

local MAX_HOURLY_REWARDS = 12
local DAY_SECONDS = 24 * 60 * 60

local UNLOCK_TIMES = {
	[1] = 5 * 60,
	[2] = 10 * 60,
	[3] = 15 * 60,
	[4] = 25 * 60,
	[5] = 35 * 60,
	[6] = 50 * 60,
	[7] = 65 * 60,
	[8] = 85 * 60,
	[9] = 105 * 60,
	[10] = 130 * 60,
	[11] = 155 * 60,
	[12] = 180 * 60,
}

local function getNow()
	return os.time()
end

local function getNextNidnight()
	local now = getNow()
	local date = os.date("*t", now)
	
	date.hour = 24
	date.min = 0
	date.sec = 0
	
	return os.time(date)
end

local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateValue(parent, className, name, dafaultValue)
	local value = parent:FindFirstChild(name)
	
	if not value then
		value = Instance.new(className)
		value.Name = name
		value.Value = dafaultValue
		value.Parent = parent
	end
	
	return value
end

local function setupHourlyRewards(player)
	local rewardsFolder = getOrCreateFolder(player, "Rewards")
	
	getOrCreateValue(rewardsFolder, "NumberValue", "HourlySessionSeconds", 0)
	getOrCreateValue(rewardsFolder, "NumberValue", "HourlyResetTime", getNextNidnight())
	
	for i = 1, MAX_HOURLY_REWARDS do
		getOrCreateValue(rewardsFolder, "BoolValue", "HourlyReward" .. i .. "Claimed", false)
		getOrCreateValue(rewardsFolder, "NumberValue", "HourlyReward" .. i .. "MaxValue", 0)
	end
	
	return rewardsFolder
end

local function resetHourlyRewards(player)
	local rewardsFolder = setupHourlyRewards(player)
	
	rewardsFolder.HourlySessionSeconds.Value = 0
	rewardsFolder.HourlyResetTime.Value = getNextNidnight()
	
	for i = 1, MAX_HOURLY_REWARDS do
		rewardsFolder["HourlyReward" .. i .. "Claimed"].Value = false
		rewardsFolder["HourlyReward" .. i .. "MaxValue"].Value = 0
	end
end

local function checkHourlyReset(player)
	local rewardsFolder = setupHourlyRewards(player)
	local now = getNow()
	
	if now >= rewardsFolder.HourlyResetTime.Value then
		resetHourlyRewards(player)
	end
end

local function buildHourlyData(player)
	checkHourlyReset(player)
	
	local rewardsFolder = setupHourlyRewards(player)
	local now = getNow()
	
	local sessionSeconds = rewardsFolder.HourlySessionSeconds.Value
	local resetTime = rewardsFolder.HourlyResetTime.Value
	local resetTimeLeft = math.max(0, resetTime - now)
	
	local rewardsData = {}
	
	for slot = 1, MAX_HOURLY_REWARDS do
		local config = RewardModule.getHourlyRewardConfig(slot)
		local claimedValue = rewardsFolder["HourlyReward" .. slot .. "Claimed"]
		local maxValueObj = rewardsFolder["HourlyReward" .. slot .. "MaxValue"]
		
		local rewardAmount
		
		if config.Placeholder then
			rewardAmount = RewardModule.getPotionRewardAmount(player)
		else
			rewardAmount = RewardModule.calculateScalingReward( 
				player,
				config.Type,
				config.WealthStage,
				maxValueObj.Value
			)
		end
		
		if rewardAmount > maxValueObj.Value then
			maxValueObj.Value = rewardAmount
		else 
			rewardAmount = maxValueObj.Value
		end
		
		local unlockTime = UNLOCK_TIMES[slot]
		local timeLeft = math.max(0, unlockTime - sessionSeconds)
		
		local isUnlocked = sessionSeconds >= unlockTime
		local isClaimed = claimedValue.Value
		local isAvailable = isUnlocked and not isClaimed
		
		table.insert(rewardsData, {
			Slot = slot,
			Type = config.Type,
			Amount = rewardAmount,
			DisplayText = RewardModule.getRewardDisplayText(config.Type, rewardAmount),
			
			UnlockTime = unlockTime,
			TimeLeft = timeLeft,
			
			IsUnlocked = isUnlocked,
			IsAvailable = isAvailable,
			IsClaimed = isClaimed,
		})
	end
	
	return {
		SessionSeconds = sessionSeconds,
		ResetTimeLeft = resetTimeLeft,
		Rewards = rewardsData
	}
end

local function sendHourlyUpdate(player)
	local data = buildHourlyData(player)
	hourlyUpdateEvent:FireClient(player, data)
end

claimHourlyRewardEvent.OnServerEvent:Connect(function(player, slot)
	if typeof(slot) ~= "number" then
		return
	end
	
	if slot < 1 or slot > MAX_HOURLY_REWARDS then
		return
	end
	
	checkHourlyReset(player)
	
	local rewardsFolder = setupHourlyRewards(player)
	local sessionSeconds = rewardsFolder.HourlySessionSeconds.Value
	local unlockTime = UNLOCK_TIMES[slot]
	
	local claimedValue = rewardsFolder["HourlyReward" .. slot .. "Claimed"]
	local maxValueObj = rewardsFolder["HourlyReward" .. slot .. "MaxValue"]
	
	if claimedValue.Value then
		sendHourlyUpdate(player)
		return
	end
	
	if sessionSeconds < unlockTime then
		sendHourlyUpdate(player)
		return
	end
	
	local amount = maxValueObj.Value
	
	if amount <= 0 then
		local config = RewardModule.getHourlyRewardConfig(slot)
		
		if config.Placeholder then
			amount = RewardModule.getPotionRewardAmount(player)
		else
			amount = RewardModule.calculateScalingReward(player, config.Type, config.WealthStage, 0)
		end
		
		maxValueObj.Value = amount
	end
	
	local success = RewardModule.giveHourlyReward(player, slot, amount)
	
	if success then
		claimedValue.Value = true
	end
	
	sendHourlyUpdate(player)
end)

requestHourlyRewardUpdateEvent.OnServerEvent:Connect(function(player)
	sendHourlyUpdate(player)
end)

local function onPlayerAdded(player)
	task.wait(4)
	
	local rewardsFolder = setupHourlyRewards(player)
	checkHourlyReset(player)
	sendHourlyUpdate(player)
	
	task.spawn(function()
		while player.Parent do 
			task.wait(1)
			
			checkHourlyReset(player)
			
			if rewardsFolder and rewardsFolder.Parent then
				rewardsFolder.HourlySessionSeconds.Value += 1
			end
		end
	end)
	
	task.spawn(function()
		while player.Parent do 
			task.wait(1)
			sendHourlyUpdate(player)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do 
	task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

print("HourlyRewardServer loaded")
