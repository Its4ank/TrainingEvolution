--// DailyRewardServer 1.2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RewardModule = require(ServerScriptService.Modules.RewardModule)

--// RemoteEvents
local rewardEventFolder = ReplicatedStorage:WaitForChild("RewardEvent")
local dailyUpdateEvent = rewardEventFolder:WaitForChild("DailyRewardUpdateEvent")
local claimDailyRewardEvent = rewardEventFolder:WaitForChild("ClaimDailyRewardEvent")
local dailyRewardMessageEvent = rewardEventFolder:WaitForChild("DailyRewardMessageEvent")
local requestDailyRewardUpdateEvent = rewardEventFolder:WaitForChild("RequestDailyRewardUpdateEvent")

--// SETTING
local DAY_SECONDS = 24 * 60 * 60

local CLAIM_GRACE_SECONDS = 24 * 60 * 60

local DAILY_SCHEDULE_LENGTH = 28
local UPDATE_INTERVAL = 5

local CLAIM_COOLDOWN = 0.5

--// Runtime data
local lastClaimRequests = {}

--// Helpers
local function getNow()
	return os.time()
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

local function waitForDataReady(player)
	if player:GetAttribute("DataReady") == true then return end
	
	while player.Parent do
		if player:GetAttribute("DataReady") == true then return true end
		task.wait(0.1)
	end
	return false
end

local function isDataReady(player)
	return player:GetAttribute("DataReady") == true
end

local function sendMessage(player, message)
	dailyRewardMessageEvent:FireClient(player, message)
end

--// Migration from old Daily system
local function getMigratedCurrentDay(rewardsFolder)
	local oldCycleStartDay = rewardsFolder:FindFirstChild("DailyCycleStartDay")
	local oldClaimedCount = rewardsFolder:FindFirstChild("DailyClaimedCount")
	
	if oldCycleStartDay and oldClaimedCount then return math.max(1, oldCycleStartDay.Value + oldClaimedCount.Value) end
	return 1
end

--// Daily data setup
local function setupDailyRewards(player)
	local rewardsFolder = getOrCreateFolder(player, "Rewards")
	local currentDay = rewardsFolder:FindFirstChild("DailyCurrentDay")
	
	if not currentDay then
		currentDay = Instance.new("IntValue")
		currentDay.Name = "DailyCurrentDay"
		currentDay.Value = getMigratedCurrentDay(rewardsFolder)
		currentDay.Parent = rewardsFolder
	end
	
	getOrCreateValue(rewardsFolder, "IntValue", "DailyStreak", 0)
	getOrCreateValue(rewardsFolder, "NumberValue", "LastDailyClaimTime", 0)
	getOrCreateValue(rewardsFolder, "NumberValue", "NextDailyClaimTime", 0)
	getOrCreateValue(rewardsFolder, "NumberValue", "DailyCurrentMaxValue", 0)
	
	return rewardsFolder
end

--// Streak reset
local function checkDailyStreakReset(player)
	local rewardsFolder = setupDailyRewards(player)
	local nextClaimTime = rewardsFolder.NextDailyClaimTime.Value
	
	if nextClaimTime <= 0 then return false end
	
	local now = getNow()
	local streakResetTime = nextClaimTime + CLAIM_GRACE_SECONDS
	
	if now < streakResetTime then return false end
	
	rewardsFolder.DailyStreak.Value = 0
	rewardsFolder.NextDailyClaimTime.Value = 0
	rewardsFolder.LastDailyClaimTime.Value = 0
	
	return true
end

--// Reward calculation
local function getCurrentRewardData(player, rewardsFolder)
	local absoluteDay = rewardsFolder.DailyCurrentDay.Value
	local previousMax = rewardsFolder.DailyCurrentMaxValue.Value
	local rewardData, reason = RewardModule.GetDailyReward(player, absoluteDay, previousMax)
	
	if not rewardData then return nil, reason end
	
	if rewardData.Amount > previousMax then
		rewardsFolder.DailyCurrentMaxValue.Value = rewardData.Amount
	else
		rewardData.Amount = previousMax
	end
	return rewardData
end

local function getCycleStartDay(absoluteDay)
	local cycleInfo = RewardModule.GetDailyCycleInfo(absoluteDay)
	
	return ((cycleInfo.Cycle - 1) * DAILY_SCHEDULE_LENGTH) + 1
end

local function buildDailyData(player)
	checkDailyStreakReset(player)
	local rewardsFolder = setupDailyRewards(player)
	local now = getNow()
	local currentDay = rewardsFolder.DailyCurentDay.Value
	local streak = rewardsFolder.DailyStreak.Value
	local nextClaimTime = rewardsFolder.NextDailyClaimTime.Value
	local currentCycleInfo = RewardModule.GetDailyCycleInfo(currentDay)
	local cycleStartDay = getCycleStartDay(currentDay)
	local currentRewardAvailable = nextClaimTime == 0 or now >= nextClaimTime
	local firstUnlockTime
	
	if currentRewardAvailable then
		firstUnlockTime = now
	else
		firstUnlockTime = nextClaimTime
	end
	
	local rewardsData = {}
	
	for scheduleSlot = 1, DAILY_SCHEDULE_LENGTH do
		local absoluteDay = cycleStartDay + scheduleSlot - 1
		local previousMaxValue = 0
		
		if absoluteDay == currentDay then
			previousMaxValue = rewardsFolder.DailyCurrentMaxValue.Value
		end
		
		local rewardData, errorReason = RewardModule.GetDailyReward(player, absoluteDay, previousMaxValue)
		if rewardData then
			local isClaimed = absoluteDay < currentDay
			local isAvailable = absoluteDay == currentDay and currentRewardAvailable
			local timeLeft = 0
			
			if absoluteDay > currentDay then
				local daysAfterCurrent = absoluteDay - currentDay
				local unlockTime = firstUnlockTime + (daysAfterCurrent * DAY_SECONDS)
				
				timeLeft = math.max(0, unlockTime - now)
			elseif absoluteDay == currentDay and not currentRewardAvailable then
				timeLeft = math.max(0, nextClaimTime - now)
			end
			
			rewardData.Slot = scheduleSlot
			rewardData.Day = absoluteDay
			rewardData.TimeLeft = timeLeft
			rewardData.IsClaimed = isClaimed
			rewardData.IsAvailable = isAvailable
			rewardData.IsLocked = not isClaimed and not isAvailable
			
			table.insert(rewardsData, rewardData)
		else 
			warn("DAILY REWARD BUILD FAILED:", player.Name, absoluteDay, errorReason)
		end
	end
	
	local currentReward, currentRewardError = getCurrentRewardData(player, rewardsFolder)
	
	if not currentReward then
		warn("CURRENT DAILY RWEARD FAILED:", player.Name, currentRewardError)
	end
	
	return {
		CurrentDay = currentDay,
		
		ScheduleDay = currentCycleInfo.ScheduleDay,
		
		Cycle = currentCycleInfo.Cycle,
		
		CycleStartDay = cycleStartDay,
		CycleEndDay = cycleStartDay + DAILY_SCHEDULE_LENGTH - 1,
		
		Streak = streak,
		
		nextClaimTime = nextClaimTime,
		
		currentRewardAvailable = currentRewardAvailable,
		
		CurrentReward = currentReward,
		
		Rewards = rewardsData,
	}
end

local function sendDailyUpdate(player)
	if not isDataReady(player) then return end
	
	local data = buildDailyData(player)
	
	dailyUpdateEvent:FireClient(player, data)
end

--// Claim protection
local function canProcessClaim(player)
	local now = os.clock()
	local userId = player.UserId
	
	local lastRequest = lastClaimRequests[userId] or 0
	
	if now - lastRequest < CLAIM_COOLDOWN then return false end
	
	lastClaimRequests[userId] = now
	
	return true
end

--// Claim reward
claimDailyRewardEvent.OnServerEvent:Connect(function(player, requestDay)
	if not isDataReady(player) then return end 
	if not canProcessClaim(player) then return end
	
	if typeof(requestDay) ~= "number" then
		sendDailyUpdate(player)
		return
	end
	
	requestDay = math.floor(requestDay)
	checkDailyStreakReset(player)
	
	local rewardsFolder = setupDailyRewards(player)
	local currentDay = rewardsFolder.DailyCurrentDay.Value
	
	if requestDay ~= currentDay then
		sendDailyUpdate(player)
		return
	end
	
	local now = getNow()
	local nextClaimTime = rewardsFolder.NextDailyClaimTime.Value
	
	if nextClaimTime > 0 and now < nextClaimTime then
		sendDailyUpdate(player)
		return
	end
	
	local rewardData, buildReason = getCurrentRewardData(player, rewardsFolder)
	
	if not rewardData then
		warn("Reward data could not be loaded.")
		sendDailyUpdate(player)
		return
	end
	
	local success, giveReason = RewardModule.GiveReward(player, rewardData)
	
	if not success then
		if giveReason == "StorageFull" then
			sendMessage(player, "Your pet backpack is full. Free up space and claim the reward.")
		elseif giveReason == "AlreadyClaimed" then
			rewardsFolder.DailyCurrentDay.Value += 1
			rewardsFolder.DailyCurrentMaxValue.Value = 0
		elseif giveReason == "OnceRewardAlreadyClaimed" then
			sendMessage(player, "This permanent reward was already claimed.")
		else
			warn("DAILY REWARD GIVE FAILED:", player.Name, currentDay, giveReason)
			sendMessage(player, "Reward could not be claimed.")
		end
		sendDailyUpdate(player)
		return
	end
	
	rewardsFolder.LastDailyClaimTime.Value = now
	rewardsFolder.NextDailyClaimTime.Value = now + DAY_SECONDS
	rewardsFolder.DailyCurrentDay.Value += 1
	rewardsFolder.DailyCurrentDay.Value += 1
	rewardsFolder.DailyCurrentMaxValue.Value = 0
	
	sendDailyUpdate(player)
end)

--// Manual update request
requestDailyRewardUpdateEvent.OnServerEvent:Connect(function(player)
	if not isDataReady(player) then return end 
	sendDailyUpdate(player)
end)

--// Player lifecycle
local function onPlayerAdded(player)
	task.sapwn(function()
		local ready = waitForDataReady(player)
		if not ready or not player.Parent then return end 
		
		setupDailyRewards(player)
		checkDailyStreakReset(player)
		sendDailyUpdate(player)
		
		while player.Parent do
			task.wait(UPDATE_INTERVAL)
			
			if isDataReady(player) then
				sendDailyUpdate(player)
			end
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	lastClaimRequests[player.UserId] = nil
end)

print("DailyRewardServer loaded!")
