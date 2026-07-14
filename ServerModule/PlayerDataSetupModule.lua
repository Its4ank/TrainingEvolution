--// PlayerDataSetupModule

local PlayerDataSetupModule = {}

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

function PlayerDataSetupModule.setup(player)
	--// leaderstats
	local leaderstats = getOrCreateFolder(player, "leaderstats")
	
	getOrCreateValue(leaderstats, "StringValue", "Top", "-")
	getOrCreateValue(leaderstats, "IntValue", "Energy", 0)
	getOrCreateValue(leaderstats, "IntValue", "Rebirth", 0)
	
	--// PlayerData
	local playerData = getOrCreateFolder(player, "PlayerData")
	
	getOrCreateValue(playerData, "IntValue", "Money", 0)
	getOrCreateValue(playerData, "IntValue", "Gems", 0)
	getOrCreateValue(playerData, "IntValue", "SrRobux", 0)
	getOrCreateValue(playerData, "IntValue", "MaxEquippedPets", 3)
	
	getOrCreateValue(playerData, "BoolValue", "BetaTester", false)
	getOrCreateValue(playerData, "BoolValue", "BetaRewardClaimed", false)
	
	--// Gamepasses
	local gamepasses = getOrCreateFolder(playerData, "Gamepasses")
	
	getOrCreateValue(gamepasses, "BoolValue", "EnergyPass", false)
	getOrCreateValue(gamepasses, "BoolValue", "MaxRebirthPass", false)
	getOrCreateValue(gamepasses, "BoolValue", "AutoRebirthPass", false)
	
	--// Boosts
	
	--// Main folder
	getOrCreateFolder(player, "Upgrades")
	getOrCreateFolder(player, "TrainingTiers")
	getOrCreateFolder(player, "Items")
	getOrCreateFolder(player, "Pets")
	getOrCreateFolder(player, "Trails")
	getOrCreateFolder(player, "Trainer")
	getOrCreateFolder(player, "Resources")
	getOrCreateFolder(player, "Rewards")
	getOrCreateFolder(player, "Potions")
	getOrCreateFolder(player, "PotionTimers")
	getOrCreateFolder(player, "BoostData")
end

return PlayerDataSetupModule
