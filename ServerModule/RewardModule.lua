local RewardModule = {}

local PetModule = require(game.ServerScriptService.Modules.PetModule)

local WEALTH_MULTIPLIERS = {
	[1] = 0.5,
	[2] = 2,
	[3] = 3,
}

local MIN_REWARDS = {
	Energy = 10,
	Money = 10,
	Gems = 1,
}

local function getLeaderstatsValue(player, valueName)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return nil end
	
	return leaderstats:FindFirstChild(valueName)
end

local function formatNumber(n)
	n = math.floor(n)
	
	if n >= 1e18 then
		return string.format("%.1fQ", n / 1e18)
	elseif n >= 1e12 then
		return string.format("%.1fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	else
		return tostring(n)
	end
end

local function getNumberValue(player, folderName, valueName)
	local folder = player:FindFirstChild(folderName)
	if not folder then return nil end
	
	return folder:FindFirstChild(valueName)
end

local function addPotion(player, potionName, amount)
	local potions = player:FindFirstChild("Potions")
	if not potions then return false end 
	
	local potion = potions:FindFirstChild(potionName)
	if not potion then return false end 
	
	potion.Value += amount
	return true
end

function RewardModule.getPotionRewardAmount(player)
	-- закладка я си ебну
	-- пока 1 азкалдка потом будет больше)
	return 1
end

function RewardModule.calculateScalingReward(player, rewardType, wealthStage, previousMaxValue)
	local multiplier = WEALTH_MULTIPLIERS[wealthStage] or 0.5
	local minReward = MIN_REWARDS[rewardType] or 1

	local baseValue = 0

	if rewardType == "Energy" then
		local energy = getLeaderstatsValue(player, "Energy")
		baseValue = energy and energy.Value or 0

	elseif rewardType == "Money" then
		local money = getNumberValue(player, "PlayerData", "Money")
		baseValue = money and money.Value or 0

	elseif rewardType == "Gems" then
		local gems = getNumberValue(player, "PlayerData", "Gems")
		baseValue = gems and gems.Value or 0
	end

	local calculated = math.floor(baseValue * multiplier)

	if calculated < minReward then
		calculated = minReward
	end

	if previousMaxValue and calculated < previousMaxValue then
		calculated = previousMaxValue
	end

	return calculated
end

function RewardModule.getHourlyRewardConfig(slot)
	local configs = {
		[1] = {Type = "Energy", WealthStage = 1},
		[2] = {Type = "Money", WealthStage = 1},
		[3] = {Type = "EnergyPotion", WealthStage = 1, Placeholder = true},
		[4] = {Type = "Gems", WealthStage = 1},
		[5] = {Type = "MoneyPotion", WealthStage = 1, Placeholder = true},
		[6] = {Type = "Pet", PetName = "Reaper", WealthStage = 1},
		[7] = {Type = "LuckPotion", WealthStage = 1, Placeholder = true},
		[8] = {Type = "Money", WealthStage = 2},
		[9] = {Type = "Gems", WealthStage = 2},
		[10] = {Type = "Pet", PetName = "DualReaper", WealthStage = 1},
		[11] = {Type = "PotionBundle", WealthStage = 1, Placeholder = true},
		[12] = {Type = "Energy", WealthStage = 3},
	}
	
	return configs[slot]
end

function RewardModule.getRewardDisplayText(rewardType, amount)
	local textAmount = formatNumber(amount)

	if rewardType == "Energy" then
		return "+" .. textAmount .. " Energy"
	elseif rewardType == "Money" then
		return "+" .. textAmount .. " Money"
	elseif rewardType == "Gems" then
		return "+" .. textAmount .. " Gems"
	elseif rewardType == "EnergyPotion" then
		return "+" .. textAmount .. " Energy Potion"
	elseif rewardType == "MoneyPotion" then
		return "+" .. textAmount .. " Money Potion"
	elseif rewardType == "LuckPotion" then
		return "+" .. textAmount .. " Luck Potion"
	elseif rewardType == "PotionBundle" then
		return "+" .. textAmount .. " All Potions"
	elseif rewardType == "Pet" then
		return "Pet Reward"
	end

	return "Reward"
end

function RewardModule.giveHourlyReward(player, slot, amount)
	local config = RewardModule.getHourlyRewardConfig(slot)
	if not config then return end
	
	local rewardType = config.Type
	
	if rewardType == "Energy" then
		local energy = getLeaderstatsValue(player, "Energy")
		if energy then
			energy.Value += amount
			return true
		end
		
	elseif rewardType == "Money" then
		local money = getNumberValue(player, "PlayerData", "Money")
		if money then
			money.Value += amount
			return true
		end

	elseif rewardType == "Gems" then
		local gems = getNumberValue(player, "PlayerData", "Gems")
		if gems then
			gems.Value += amount
			return true
		end
		
	elseif rewardType == "EnergyPotion" then
		return addPotion(player, "EnergyPotion", amount)
		
	elseif rewardType == "MoneyPotion" then
		return addPotion(player, "MoneyPotion", amount)
		
	elseif rewardType == "LuckPotion" then
		return addPotion(player, "LuckPotion", amount)
		
	elseif rewardType == "PotionBundle" then
		local a = addPotion(player, "EnergyPotion", amount)
		local b = addPotion(player, "MoneyPotion", amount)
		local c = addPotion(player, "LuckPotion", amount)
		return a and b and c
		
	elseif rewardType == "Pet" then
		local petName = config.PetName
		if not petName then 
			warn("Hourly reward pet name missing for slot:", slot)
			return false
		end
		
		local petFolder, err = PetModule.givePet(player, petName)
		if not petFolder then 
			warn("Failed to give hourly pet:", petName, err)
			return false
		end
		
		print("Gave hourly pet:", petName, "to", player.Name)
		return true
	end
	
	return false
end

return RewardModule
