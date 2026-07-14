local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PetModule = require(game.ServerScriptService.Modules.PetModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)

local rewardEventFolder = ReplicatedStorage:WaitForChild("RewardEvent")
local dailyUpdateEvent = rewardEventFolder:WaitForChild("DailyRewardUpdateEvent")
local claimDailyRewardEvent = rewardEventFolder:WaitForChild("ClaimDailyRewardEvent")
local dailyRewardMessageEvent = rewardEventFolder:WaitForChild("DailyRewardMessageEvent")

local DAY_SECONDS = 24 * 60 * 60
local CLAIM_GRACE_SECONDS = 24 * 60 * 60
local MAX_DAILY_REWARDS = 7

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

local function getMaxEquippedPetsValue(player)
	local playerData = getOrCreateFolder(player, "PlayerData")
	return getOrCreateValue(playerData, "IntValue", "MaxEquippedPets", 3)
end

local function addPotion(player, potionName, amount)
	local potions = getOrCreateFolder(player, "Potions")
	local potion = getOrCreateValue(potions, "IntValue", potionName, 0)
	
	potion.Value += amount
	return true
end

local function setupRewards(player)
	local rewardsFolder = getOrCreateFolder(player, "Rewards")
	
	getOrCreateValue(rewardsFolder, "IntValue", "DailyCycleStartDay", 1)
	getOrCreateValue(rewardsFolder, "IntValue", "DailyClaimedCount", 0)
	getOrCreateValue(rewardsFolder, "IntValue", "DailyStreak", 0)
	getOrCreateValue(rewardsFolder, "NumberValue", "LastDailyClaimTime", 0)
	getOrCreateValue(rewardsFolder, "NumberValue", "NextDailyClaimTime", 0)
	getOrCreateValue(rewardsFolder, "BoolValue", "ChestClaimed", false)
	getOrCreateValue(rewardsFolder, "BoolValue", "ExtraPetSlotClaimed", false)
	getOrCreateValue(rewardsFolder, "BoolValue", "ExtraPetStorageClaimed", false)
	getOrCreateValue(rewardsFolder, "BoolValue", "ExtraTimeBoostClaimed", false)
	
	return rewardsFolder
end

local function resetDailyRewards(player)
	local rewardsFolder = setupRewards(player)
	
	rewardsFolder.DailyCycleStartDay.Value = 1
	rewardsFolder.DailyClaimedCount.Value = 0
	rewardsFolder.DailyStreak.Value = 0
	rewardsFolder.LastDailyClaimTime.Value = 0
	rewardsFolder.NextDailyClaimTime.Value = 0
	rewardsFolder.ChestClaimed.Value = false
end

local function checkDailyReset(player)
	local rewardsFolder = setupRewards(player)
	local now = getNow()
	
	local nextClaimTime = rewardsFolder.NextDailyClaimTime.Value
	
	if nextClaimTime > 0 then
		local resetTime = nextClaimTime + CLAIM_GRACE_SECONDS
		
		if now >= resetTime then
			resetDailyRewards(player)
		end
	end
end

local function buildDailyData(player)
	checkDailyReset(player)
	
	local rewardsFolder = setupRewards(player)
	local now = getNow()
	
	local cycleStartDay = rewardsFolder.DailyCycleStartDay.Value
	local claimedCount = rewardsFolder.DailyClaimedCount.Value
	local streak = rewardsFolder.DailyStreak.Value
	local nextClaimTime = rewardsFolder.NextDailyClaimTime.Value
	local chestClaimed = rewardsFolder.ChestClaimed.Value
	
	local rewardsData = {}
	
	for slot = 1, MAX_DAILY_REWARDS do 
		local dayNumber = cycleStartDay + slot - 1
		
		local isClaimed = slot <= claimedCount
		local isAvailable = false
		local timeLeft = 0
		
		if not isClaimed then
			if slot == claimedCount + 1 then
				if nextClaimTime == 0 or now >= nextClaimTime then
					isAvailable = true
				else 
					timeLeft = nextClaimTime - now 
				end
			else 
				local unlockTime = nextClaimTime + ((slot - claimedCount - 1) * DAY_SECONDS)
				timeLeft = math.max(0, unlockTime - now)
			end
		end
		
		table.insert(rewardsData, {
			Slot = slot, 
			Day = dayNumber, 
			TimeLeft = timeLeft, 
			IsAvailable = isAvailable, 
			IsClaimed = isClaimed,
		})
	end
	
	return {
		CycleStartDay = cycleStartDay,
		ClaimedCount = claimedCount,
		Streak = streak, 
		ChestClaimed = chestClaimed, 
		ChestAvailable = streak >= 7 and not chestClaimed,
		Rewards = rewardsData, 
	}
end

local function sendDailyUpdate(player)
	local data = buildDailyData(player)
	dailyUpdateEvent:FireClient(player, data)
end

local function giveDailyReward(player, day, slot)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return false end
	
	local rewardsFolder = setupRewards(player)
	
	if slot == 1 then 
		return addPotion(player, "EnergyPotion", 1)
	end
	
	if slot == 2 then 
		local claimed = rewardsFolder:FindFirstChild("ExtraPetStorageClaimed")
		if claimed and claimed.Value then 
			return true
		end
		
		PetModule.addPetStorage(player, 25)
		
		if claimed then 
			claimed.Value = true
		end
		return true
	end
	
	if slot == 3 then 
		local claimed = rewardsFolder:FindFirstChild("ExtraTimeBoostClaimed")
		if claimed and claimed.Value then 
			return true
		end
		
		BoostModule.AddTimeBoostBonus(player, 0.5)
		
		if claimed then 
			claimed.Value = true
		end
		return true
	end
	
	if slot == 4 then 
		addPotion(player, "EnergyPotion", 1)
		addPotion(player, "MoneyPotion", 1)
		addPotion(player, "LuckPotion", 1)
	end
	
	if slot == 5 then 
		addPotion(player, "MoneyPotion", 1)
	end
	
	if slot == 6 then 
		local extraPetSlotClaimed = rewardsFolder:FindFirstChild("ExtraPetSlotClaimed")
		local maxEquippedPets = getMaxEquippedPetsValue(player)
		
		if extraPetSlotClaimed and extraPetSlotClaimed.Value then
			return true
		end
		
		if maxEquippedPets.Value < 4 then 
			maxEquippedPets.Value = 4
		end
		
		if extraPetSlotClaimed then 
			extraPetSlotClaimed.Value = true
		end
		
		print("Gave +1 equipped pet slot to", player.Name)
		return true
	end
	
	if slot == 7 then 
		local petFolder, err = PetModule.givePet(player, "Huge Queen")
		
		if not petFolder then 
			warn("Failed to give daily pet Huge Queen:", err)
			return false, err
		end
		
		print("Gave daily pet Huge Queen to", player.Name)
		return true
	end
	
	local money = playerData:FindFirstChild("Money")
	if money then
		money.Value += 100 * day
		return true
	end
	return false
end

claimDailyRewardEvent.OnServerEvent:Connect(function(player, slot)
	local rewardsFolder = setupRewards(player)
	checkDailyReset(player)
	
	local now = getNow()
	local claimedCount = rewardsFolder.DailyClaimedCount.Value
	local nextSlot = claimedCount + 1
	
	if slot ~= nextSlot then 
		sendDailyUpdate(player)
		return
	end
	
	local nextClaimTime = rewardsFolder.NextDailyClaimTime.Value
	
	if nextClaimTime ~= 0 and now < nextClaimTime then 
		sendDailyUpdate(player)
		return
	end
	
	local dayNumber = rewardsFolder.DailyCycleStartDay.Value + slot - 1
	
	local rewardGiven, reason = giveDailyReward(player, dayNumber, slot)
	
	if not rewardGiven then 
		if reason == "StorageFull" then
			dailyRewardMessageEvent:FireClient( 
				player, 
				"Your pet backpack is full. Free up space and claim the reward."
			)
		end
		
		sendDailyUpdate(player)
		return
	end
	
	rewardsFolder.LastDailyClaimTime.Value = now 
	rewardsFolder.NextDailyClaimTime.Value = now + DAY_SECONDS
	rewardsFolder.DailyClaimedCount.Value += 1
	rewardsFolder.DailyStreak.Value += 1
	
	if rewardsFolder.DailyStreak.Value > 7 then
		rewardsFolder.DailyStreak.Value = 7
	end
	
	if rewardsFolder.DailyClaimedCount.Value >= MAX_DAILY_REWARDS then
		rewardsFolder.DailyCycleStartDay.Value += MAX_DAILY_REWARDS
		rewardsFolder.DailyClaimedCount.Value = 0
		rewardsFolder.ChestClaimed.Value = false
	end
	
	sendDailyUpdate(player)
end)

Players.PlayerAdded:Connect(function(player)
	task.wait(4)
	setupRewards(player)
	sendDailyUpdate(player)
	
	task.spawn(function()
		while player.Parent do 
			task.wait(10)
			sendDailyUpdate(player)
		end
	end)
end)

print("RewardServer loaded!")
