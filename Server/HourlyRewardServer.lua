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

local function getNow()
	return os.time()
end

local function getHourlyResetId(resetTime)
	return "Reset_" .. tostring(math.floor(tonumber(resetTime) or 0))
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

	local sessionSeconds =
		rewardsFolder.HourlySessionSeconds.Value

	local resetTime =
		rewardsFolder.HourlyResetTime.Value

	local resetTimeLeft =
		math.max(0, resetTime - now)

	local resetId =
		getHourlyResetId(resetTime)

	local rewardsData = {}

	for slot = 1, MAX_HOURLY_REWARDS do
		local claimedValue = rewardsFolder["HourlyReward"
			.. slot
			.. "Claimed"
		]

		local maxValueObj = rewardsFolder["HourlyReward"
			.. slot
			.. "MaxValue"
		]

		local rewardData, reason =
			RewardModule.GetHourlyReward(
				player,
				slot,
				maxValueObj.Value,
				resetId
			)

		if rewardData then
			if rewardData.Amount
				> maxValueObj.Value
			then
				maxValueObj.Value =
					rewardData.Amount
			else
				rewardData.Amount =
					maxValueObj.Value
			end

			local unlockTime =
				RewardModule
				.GetHourlyUnlockTime(slot)

			local timeLeft =
				math.max(
					0,
					unlockTime
					- sessionSeconds
				)

			local isUnlocked =
				sessionSeconds >= unlockTime

			local isClaimed =
				claimedValue.Value

			local isAvailable =
				isUnlocked
				and not isClaimed

			rewardData.Slot = slot
			rewardData.UnlockTime = unlockTime
			rewardData.TimeLeft = timeLeft
			rewardData.IsUnlocked = isUnlocked
			rewardData.IsAvailable = isAvailable
			rewardData.IsClaimed = isClaimed

			table.insert(
				rewardsData,
				rewardData
			)
		else
			warn(
				"HOURLY REWARD BUILD FAILED:",
				player.Name,
				slot,
				reason
			)
		end
	end

	return {
		SessionSeconds = sessionSeconds,
		ResetTimeLeft = resetTimeLeft,
		ResetTime = resetTime,
		Rewards = rewardsData,
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
	local unlockTime = RewardModule.GetHourlyUnlockTime(slot)
	if not unlockTime then
		sendHourlyUpdate(player)
		return
	end
	
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
	
	local resetTime =
		rewardsFolder.HourlyResetTime.Value

	local resetId =
		getHourlyResetId(resetTime)

	local rewardData, buildReason =
		RewardModule.GetHourlyReward(
			player,
			slot,
			maxValueObj.Value,
			resetId
		)

	if not rewardData then
		warn(
			"HOURLY CLAIM BUILD FAILED:",
			player.Name,
			slot,
			buildReason
		)

		sendHourlyUpdate(player)
		return
	end

	if rewardData.Amount > maxValueObj.Value then
		maxValueObj.Value = rewardData.Amount
	else
		rewardData.Amount = maxValueObj.Value
	end

	local success, giveReason =
		RewardModule.GiveReward(
			player,
			rewardData
		)

	if success then
		claimedValue.Value = true
	else
		if giveReason == "StorageFull" then
			warn(
				"Hourly pet reward storage full:",
				player.Name,
				slot
			)

		elseif giveReason == "AlreadyClaimed" then
			-- Модуль уже подтверждает, что эта
			-- награда была выдана.
			claimedValue.Value = true

		else
			warn(
				"HOURLY REWARD GIVE FAILED:",
				player.Name,
				slot,
				giveReason
			)
		end
	end

	sendHourlyUpdate(player)
	
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
