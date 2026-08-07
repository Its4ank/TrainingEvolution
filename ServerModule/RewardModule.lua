local RewardModule = {}

local ServerScriptService = game:GetService("ServerScriptService")

local PetModule = require(game.ServerScriptService.Modules.PetModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)

local DAILY_SCHEDULE_LENGTH = 28

RewardModule.RewardTypes = {
	Money = {
		Name = "Money",
		Icon = "rbxassetid://123691959584167",
		Category = "Currency",
		Scalable = true,
		Minimum = 10,
	},
	
	Energy = {
		Name = "Energy",
		Icon = "rbxassetid://74509086636062",
		Category = "Currency",
		Scalable = true,
		Minimum = 10,
	},
	
	Gems = {
		Name = "Gems",
		Icon = "rbxassetid://137014409758293",
		Category = "Currency",
		Scalable = true,
		Minimum = 10,
	},
	
	EnergyPotion = {
		Name = "Energy Potion",
		Icon = "rbxassetid://72201487270864",
		Category = "Potion",
		Scalable = false,
	},
	
	MoneyPotion = {
		Name = "Money Potion",
		Icon = "rbxassetid://106593575059620",
		Category = "Potion",
		Scalable = false,
	},
	
	LuckPotion = {
		Name = "Luck Potion",
		Icon = "rbxassetid://128046081280070",
		Category = "Potion",
		Scalable = false,
	},
	
	PotionBundle = {
		Name = "Potion Bundle",
		Icon = "rbxassetid://112904883059437",
		Category = "Bundle",
		Scalable = false,
	},
	
	Pet = {
		Name = "Pet",
		Icon = "rbxassetid://129654646355724",
		Category = "Pet",
		Scalable = false,
	},
	
	PetStorage = {
		Name = "Pet Storage",
		Icon = "rbxassetid://85897444660228",
		Category = "Permanent",
		Scalable = false,
	},
	
	EquippedPetSlot = {
		Name = "Equipped Pet Slot",
		Icon = "rbxassetid://71954756599104",
		Category = "Permanent",
		Scalable = false,
	},
	
	TimeBoostBonus = {
		Name = "Time Boost",
		Icon = "rbxassetid://82214780063112",
		Category = "Permanent",
		Scalable = false,
	},
}

RewardModule.WealthMultiplier = {
	[1] = 2.00,
	[2] = 3.00,
	[3] = 4.00,
}

RewardModule.DailySchedule = {
	[1] = {
		[1] = {Type = "Energy", Wealth = 1,},
		[2] = {Type = "EnergyPotion", Amount = 2,},
		[3] = {Type = "PotionBundle", Amount = 3,},
	
	},
	
	[2] = {
		[1] = {Type = "PotionBundle", Amount = 1,},
		[2] = {Type = "Money", Wealth = 2,},
		[3] = {Type = "Money", Wealth = 3,},
	},
	
	[3] = {
		[1] = {Type = "Gems", Wealth = 1,},
		[2] = {Type = "MoneyPotion", Amount = 2,},
		[3] = {Type = "Gems", Wealth = 3,},
	},
	
	[4] = {
		[1] = {Type = "Money", Wealth = 1,},
		[2] = {Type = "LuckPotion", Amount = 2,},
		[3] = {Type = "MoneyPotion", Amount = 3,},
	},
	
	[5] = {
		[1] = {Type = "PetStorage", Amount = 10,},
		[2] = {Type = "Gems", Wealth = 2,},
		[3] = {Type = "TimeBoostBonus", Amount = 0.5,},
	},
	
	[6] = {
		[1] = {Type = "Energy", Wealth = 1,},
		[2] = {Type = "LuckPotion", Amount = 2,},
		[3] = {Type = "Energy", Wealth = 3,},

	},

	[7] = {
		[1] = {Type = "Pet", PetName = "HugeQueen",},
		[2] = {Type = "Pet", PetName = "ErrCube",},
		[3] = {Type = "Pet", PetName = "Thunget",},
	},

	[8] = {
		[1] = {Type = "Money", Wealth = 1,},
		[2] = {Type = "PetStorage", Amount = 15,},
		[3] = {Type = "EnergyPotion", Amount = 3,},
	},

	[9] = {
		[1] = {Type = "EnergyPotion", Amount = 1,},
		[2] = {Type = "Energy", Wealth = 2,},
		[3] = {Type = "Gems", Wealth = 3,},
	},

	[10] = {
		[1] = {Type = "Gems", Wealth = 1,},
		[2] = {Type = "Gems", Wealth = 2,},
		[3] = {Type = "Energy", Wealth = 3,},
	},
	
	[11] = {
		[1] = {Type = "LuckPotion", Amount = 1,},
		[2] = {Type = "PotionBundle", Amount = 2,},
		[3] = {Type = "Money", Amount = 3,},

	},

	[12] = {
		[1] = {Type = "Energy", Wealth = 1,},
		[2] = {Type = "Money", Wealth = 2,},
		[3] = {Type = "MoneyPotion", Amount = 3,},
	},

	[13] = {
		[1] = {Type = "Gems", Wealth = 1,},
		[2] = {Type = "Energy", Wealth = 2,},
		[3] = {Type = "Energy", Wealth = 3,},
	},

	[14] = {
		[1] = {Type = "EquippedPetSlot", Amount = 1,},
		[2] = {Type = "Pet", PetName = "CubeHead",},
		[3] = {Type = "PetStorage", Amount = 25,},
	},

	[15] = {
		[1] = {Type = "TimeBoostBonus", Amount = 0.5,},
		[2] = {Type = "Money", Wealth = 2,},
		[3] = {Type = "LuckPotion", Amount = 3,},
	},

	[16] = {
		[1] = {Type = "Energy", Wealth = 1,},
		[2] = {Type = "EnergyPotion", Amount = 2,},
		[3] = {Type = "Energy", Wealth = 3,},

	},

	[17] = {
		[1] = {Type = "EnergyPotion", Amount = 1,},
		[2] = {Type = "Gems", Amount = 2,},
		[3] = {Type = "MoneyPotion", Amount = 3,},
	},

	[18] = {
		[1] = {Type = "Money", Wealth = 1,},
		[2] = {Type = "Money", Wealth = 2,},
		[3] = {Type = "Money", Wealth = 3,},
	},

	[19] = {
		[1] = {Type = "PotionBundle", Amount = 1,},
		[2] = {Type = "LuckPotion", Amount = 2,},
		[3] = {Type = "Energy", Wealth = 3,},
	},

	[20] = {
		[1] = {Type = "Gems", Wealth = 1,},
		[2] = {Type = "Money", Wealth = 2,},
		[3] = {Type = "EnergyPotion", Amount = 3,},
	},
	
	[21] = {
		[1] = {Type = "Pet", PetName = "TheCube",},
		[2] = {Type = "TimeBoostBonus", Amount = 0.5,},
		[3] = {Type = "Pet", PetName = "MagicalGolder",},
	},
	
	[22] = {
		[1] = {Type = "MoneyPotion", Amount = 1,},
		[2] = {Type = "Energy", Wealth = 2,},
		[3] = {Type = "Money", Wealth = 3,},
	},
	
	[23] = {
		[1] = {Type = "Money", Wealth = 1,},
		[2] = {Type = "MoneyPotion", Amount = 2,},
		[3] = {Type = "PotionBundle", Amount = 3,},
	},
	
	[24] = {
		[1] = {Type = "Energy", Wealth = 1,},
		[2] = {Type = "Gems", Wealth = 2,},
		[3] = {Type = "Gems", Wealth = 3,},
	},
	
	[25] = {
		[1] = {Type = "EnergyPotion", Amount = 1,},
		[2] = {Type = "Money", Wealth = 2,},
		[3] = {Type = "Energy", Wealth = 3,},
	},
	
	[26] = {
		[1] = {Type = "Gems", Wealth = 1,},
		[2] = {Type = "PotionBundle", Amount = 2,},
		[3] = {Type = "MoneyPotion", Amount = 3,},
	},
		
	[27] = {
		[1] = {Type = "Energy", Wealth = 1,},
		[2] = {Type = "Energy", Wealth = 2,},
		[3] = {Type = "Energy", Wealth = 3,},
	},
	
	[28] = {
		[1] = {Type = "EquippedPetSlot", Amount = 1,},
		[2] = {Type = "EquippedPetSlot", Amount = 1,},
		[3] = {Type = "EquippedPetSlot", Amount = 1,},
	},
}

RewardModule.HourlySchedule = {
	[1] = {UnlockTime = 5 * 60, Type = "Energy", Wealth = 1,},
	[2] = {UnlockTime = 10 * 60, Type = "Money", Wealth = 1,},
	[3] = {UnlockTime = 15 * 60, Type = "EnergyPotion", Amount = 1,},
	[4] = {UnlockTime = 25 * 60, Type = "Gems", Wealth = 1,},
	[5] = {UnlockTime = 35 * 60, Type = "MoneyPotion", Amount = 1,},
	[6] = {UnlockTime = 50 * 60, Type = "Pet", PetName = "Reaper",},
	[7] = {UnlockTime = 65 * 60, Type = "LuckPotion", Amount = 1,},
	[8] = {UnlockTime = 85 * 60, Type = "Money", Wealth = 2,},
	[9] = {UnlockTime = 105 * 60, Type = "Gems", Wealth = 2,},
	[10] = {UnlockTime = 130 * 60, Type = "Pet", PetName = "DualReaper",},
	[11] = {UnlockTime = 155 * 60, Type = "PotionBundle", Amount = 1,},
	[12] = {UnlockTime = 180 * 60, Type = "Energy", Wealth = 3,},
}

-- Internal Helper
local function getCycleConfig(dayCycles, requestedCycle)
	if dayCycles[requestedCycle] then
		return dayCycles[requestedCycle]
	end
	
	local highestCycle = nil
	local highestConfig = nil
	
	for cycleNumber, config in pairs(dayCycles) do
		if cycleNumber <= requestedCycle then
			if not highestCycle or cycleNumber > highestCycle then
				highestCycle = cycleNumber
				highestConfig = config
			end
		end
	end
	return highestConfig
end

local function copyTable(source)
	local result = {}
	
	for key, value in pairs(source) do
		if type(value) == "table" then
			result[key] = copyTable(value)
		else 
			result[key] = value
		end
	end
	return result
end

local function getFolderValue(player, folderName, valueName)
	local folder = player:FindFirstChild(folderName)
	if not folder then return nil end
	
	return folder:FindFirstChild(valueName)
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

local function addPotion(player, potionName, amount)
	local potions = getOrCreateFolder(player, "Potions")
	local potion = getOrCreateValue(potions, "IntValue", potionName, 0)
	
	potion.Value += amount
	return true
end

local function getRawBalance(player, rewardType)
	if rewardType == "Energy" then
		local energy = getFolderValue(player, "leaderstats", "Energy")
		return energy and energy.Value or 0
	end
	
	if rewardType == "Money" then
		local money = getFolderValue(player, "PlayerData", "Money")
		return money and money.Value or 0
	end
	
	if rewardType == "Gems" then
		local gems = getFolderValue(player, "PlayerData", "Gems")
		return gems and gems.Value or 0
	end
	
	return 0
end

local function getClaimValue(player, folderName, claimKey)
	if not claimKey then return nil end

	local rewardsFolder = getOrCreateFolder(player, "Rewards")
	local claimsFolder = getOrCreateFolder(rewardsFolder, folderName)

	return getOrCreateValue(claimsFolder, "BoolValue", claimKey, false)
end

local function resolveRepeatReward(player, config)
	if not config.OnceKey then return config end
	
	local onceValue = getClaimValue(player, "PermanentClaims", config.OnceKey)
	if onceValue and onceValue.Value then
		if config.RepeatReward then
			return copyTable(config.RepeatReward)
		end
	end
	return config
end

local function getLastDefinedCycle(cycles, requestedCycle)
	local selectedCycle = nil
	local selectedConfig = nil
	
	for cycleNumber, cycleConfig in pairs(cycles) do
		if cycleNumber <= requestedCycle then
			if not selectedCycle or cycleNumber > selectedCycle then
				selectedCycle = cycleNumber
				selectedConfig = cycleConfig
			end
		end
	end
	return selectedConfig
end

local function markRewardClaimed(player, rewardData)
	if rewardData.ClaimKey then
		local claimFolderName
		
		if rewardData.Source == "Daily" then
			claimFolderName = "DailyClaims"
		elseif rewardData.Source == "Hourly" then
			claimFolderName = "HourlyClaims"
		else 
			claimFolderName = "OtherClaims"
		end
		
		local claimValue = getClaimValue(player, claimFolderName, rewardData.ClaimKey)
		if claimValue then claimValue.Value = true end 
	end
	
	if rewardData.OnceKey then
		local onceValue = getClaimValue(player, "PermanentClaims", rewardData.OnceKey)
		if onceValue then onceValue.Value = true end
	end
end

-- FORMATING
function RewardModule.FormatNumber(number)
	number = math.floor(tonumber(number) or 0)
	
	local suffixes = {
		{Value = 1e30, Suffix = "No"}, -- Нонилион
		{Value = 1e27, Suffix = "Oc"}, --Октиллион
		{Value = 1e24, Suffix = "Sp"}, --Септиллион
		{Value = 1e21, Suffix = "Sx"}, --Секстиллион
		{Value = 1e18, Suffix = "Qi"}, --Квинтиллион
		{Value = 1e15, Suffix = "Qa"}, --Квадриллион
		{Value = 1e12, Suffix = "T"}, --Триллион
		{Value = 1e9, Suffix = "B"}, --Миллиард
		{Value = 1e6, Suffix = "M"}, --Миллион
		{Value = 1e3, Suffix = "K"}, --Тысяча
	}
	
	for _, suffixData in ipairs(suffixes) do
		if number >= suffixData.Value then
			local formatted = string.format("%.1f", number / suffixData.Value)
			formatted = formatted:gsub("%.0$", "")
			return formatted .. suffixData.Suffix
		end
	end
	return tostring(number)
end

-- DAILY CYCLE CALCULATION
function RewardModule.GetDailyCycleInfo(absoluteDay)
	absoluteDay = math.max(1, math.floor(tonumber(absoluteDay) or 1))
	
	local scheduleDay = ((absoluteDay - 1) % DAILY_SCHEDULE_LENGTH) + 1
	local cycle = math.floor((absoluteDay - 1) / DAILY_SCHEDULE_LENGTH) + 1
	
	return {
		AbsoluteDay = absoluteDay,
		ScheduleDay = scheduleDay,
		Cycle = cycle,
	}
end

function RewardModule.GetDailyConfig(player, absoluteDay)
	local cycleInfo = RewardModule.GetDailyCycleInfo(absoluteDay)
	local dayEntry = RewardModule.DailySchedule[cycleInfo.ScheduleDay]
	
	if not dayEntry then return nil, "DailyScheduleMissing" end
	
	local selectedConfig = getCycleConfig(dayEntry, cycleInfo.Cycle)
	if not selectedConfig then return nil, "DailyRewardConfigMissing" end
	
	selectedConfig = copyTable(selectedConfig)
	selectedConfig = resolveRepeatReward(player, selectedConfig)
	
	selectedConfig.Source = "Daily"
	selectedConfig.ClaimKey = string.format("Cycle%d_Day%d", cycleInfo.Cycle, cycleInfo.ScheduleDay)
	
	selectedConfig.AbsoluteDay = cycleInfo.AbsoluteDay
	selectedConfig.ScheduleDay = cycleInfo.ScheduleDay
	selectedConfig.Cycle = cycleInfo.Cycle
	
	return selectedConfig
end

-- Reward calculation
function RewardModule.CalculateAmount(player, config, previousMaxValue)
	if config.Amount ~= nil then
		return tonumber(config.Amount) or 0
	end
	
	local rewardType = config.Type
	local typeData = RewardModule.RewardTypes[rewardType]
	
	if not typeData then return 0 end
	if not typeData.Scalable then return 1 end
	
	local wealth = config.Wealth or 1
	local multiplier = RewardModule.WealthMultiplier[wealth] or 0.5
	local baseValue = getRawBalance(player, rewardType)
	local calculated = math.floor(baseValue * multiplier)
	local minimum = typeData.Minimum or 1
	
	calculated = math.max(minimum, calculated)
	calculated = math.max(calculated, tonumber(previousMaxValue) or 0)
	
	return calculated
end

function RewardModule.BuildRewardData(player, config, previousMaxValue)
	if not config then return nil, "ConfigMissing" end
	
	local typeData = RewardModule.RewardTypes[config.Type]
	if not typeData then return nil, "UnknownRewardType" end 
	
	local amount = RewardModule.CalculateAmount(player, config, previousMaxValue)
	local displayName = typeData.Name
	local displayText
	
	if config.Type == "Pet" then
		displayName = config.PetName or "Pet"
		displayText = displayName
	elseif config.Type == "PotionBundle" then
		displayText = "+" .. RewardModule.FormatNumber(amount) .. " All Potions"
	elseif config.Type == "PetStorage" then
		displayText = "+" .. RewardModule.FormatNumber(amount) .. " Pet Storage"
	elseif config.Type == "EquippedPetSlot" then
		displayText = "+" .. RewardModule.FormatNumber(amount) .. " Equipped Pet Slot"
	elseif config.Type == "TimeBoostBonus" then
		displayText = "+" .. tostring(amount) .. "% Time Boost Speed"
	else
		displayText = "+" .. RewardModule.FormatNumber(amount) .. " " .. displayName
	end
	
	return {
		Type = config.Type,
		Name = displayName,
		Icon = config.Icon or typeData.Icon,
		Category = typeData.Category,
		
		Amount = amount,
		Wealth = config.Wealth,
		DisplayText = displayText,
		
		PetName = config.PetName,
		OnceKey = config.OnceKey,
		
		AbsoluteDay = config.AbsoluteDay,
		ScheduleDay = config.ScheduleDay,
		Cycle = config.Cycle,
		
		UnlockTime = config.UnlockTime,
		
		Source = config.Source,
		ClaimKey = config.ClaimKey,
	}
end

function RewardModule.GetDailyReward(player, absoluteDay, previousMaxValue)
	local config, errorReason = RewardModule.GetDailyConfig(player, absoluteDay)
	if not config then return nil, errorReason end
	
	return RewardModule.BuildRewardData(player, config, previousMaxValue)
end

function RewardModule.GetHourlyReward(player, slot, previousMaxValue, resetId)
	slot = math.floor(tonumber(slot) or 0)
	
	local config = RewardModule.HourlySchedule[slot]
	if not config then return nil, "HourlyRewardMissing" end
	
	config = copyTable(config)
	config.Source = "Hourly"
	config.ClaimKey = tostring(resetId) .. "_Slot" .. slot
	
	return RewardModule.BuildRewardData(player, copyTable(config), previousMaxValue)
end

function RewardModule.GetHourlyUnlockTime(slot)
	local config = RewardModule.HourlySchedule[slot]
	if not config then return nil end
	return config.UnlockTime
end

-- Reward grantige
function RewardModule.GiveReward(player, rewardData)
	if not player or not rewardData then
		return false, "InvalidArguments"
	end

	local rewardType = rewardData.Type
	local amount = tonumber(rewardData.Amount) or 0

	if amount <= 0 and rewardType ~= "Pet" then
		return false, "InvalidAmount"
	end

	-- Защита от повторного получения конкретной награды
	if rewardData.ClaimKey then
		local folderName = "OtherClaims"

		if rewardData.Source == "Daily" then
			folderName = "DailyClaims"
		elseif rewardData.Source == "Hourly" then
			folderName = "HourlyClaims"
		end

		local claimValue = getClaimValue(
			player,
			folderName,
			rewardData.ClaimKey
		)

		if claimValue and claimValue.Value then
			return false, "AlreadyClaimed"
		end
	end

	-- Универсальная награда один раз на аккаунт
	if rewardData.OnceKey then
		local onceValue = getClaimValue(
			player,
			"PermanentClaims",
			rewardData.OnceKey
		)

		if onceValue and onceValue.Value then
			return false, "OnceRewardAlreadyClaimed"
		end
	end

	local success = false
	local reason = nil

	if rewardType == "Energy" then
		local energy = getFolderValue(
			player,
			"leaderstats",
			"Energy"
		)

		if not energy then
			return false, "EnergyMissing"
		end

		energy.Value += amount
		success = true

	elseif rewardType == "Money" then
		local money = getFolderValue(
			player,
			"PlayerData",
			"Money"
		)

		if not money then
			return false, "MoneyMissing"
		end

		money.Value += amount
		success = true

	elseif rewardType == "Gems" then
		local gems = getFolderValue(
			player,
			"PlayerData",
			"Gems"
		)

		if not gems then
			return false, "GemsMissing"
		end

		gems.Value += amount
		success = true

	elseif rewardType == "EnergyPotion" then
		success = addPotion(
			player,
			"EnergyPotion",
			amount
		)

	elseif rewardType == "MoneyPotion" then
		success = addPotion(
			player,
			"MoneyPotion",
			amount
		)

	elseif rewardType == "LuckPotion" then
		success = addPotion(
			player,
			"LuckPotion",
			amount
		)

	elseif rewardType == "PotionBundle" then
		local energyGiven = addPotion(
			player,
			"EnergyPotion",
			amount
		)

		local moneyGiven = addPotion(
			player,
			"MoneyPotion",
			amount
		)

		local luckGiven = addPotion(
			player,
			"LuckPotion",
			amount
		)

		success =
			energyGiven
			and moneyGiven
			and luckGiven

	elseif rewardType == "Pet" then
		if not rewardData.PetName then
			return false, "PetNameMissing"
		end

		local petFolder
		petFolder, reason = PetModule.givePet(
			player,
			rewardData.PetName
		)

		success = petFolder ~= nil

	elseif rewardType == "PetStorage" then
		success = PetModule.addPetStorage(
			player,
			amount
		) ~= nil

	elseif rewardType == "EquippedPetSlot" then
		local playerData = getOrCreateFolder(
			player,
			"PlayerData"
		)

		local maxEquippedPets = getOrCreateValue(
			playerData,
			"IntValue",
			"MaxEquippedPets",
			3
		)

		maxEquippedPets.Value += amount
		success = true

	elseif rewardType == "TimeBoostBonus" then
		success = BoostModule.AddTimeBoostBonus(
			player,
			amount
		) ~= nil

	else
		return false, "UnsupportedRewardType"
	end

	if not success then
		return false, reason or "RewardGiveFailed"
	end

	markRewardClaimed(player, rewardData)

	return true
end

return RewardModule
