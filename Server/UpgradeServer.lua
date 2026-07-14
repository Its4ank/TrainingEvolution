local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeEvent")

local MAX_LEVEL = 10

local UpgradeConfig = {
	Money = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	Energy = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	GemChance = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	GemMore = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	SpeedTraining = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	PetLuck = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	Acceleration = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	RacePower = {
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	RebirthMultiplierMoney = {
		MaxLevel = 1,
		BasePrice = 10,
		PriceMultiplier = 1,
		BonusPerLevel = 1,
	},
	
	RebirthButton = {
		MaxLevel = 6,
		BasePrice = 5,
		PriceMultiplier = 1.45,
		BonusPerLevel = 1,
	},
	
	HatLuck = {
		MaxLevel = 10,
		BaseLevel = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
	
	RelicsLuck = {
		MaxLevel = 10,
		BaseLevel = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
	},
}

local function getPrice(upgradeName, currentLevel)
	local config = UpgradeConfig[upgradeName]
	if not config then return 0 end
	
	return math.floor(config.BasePrice * (config.PriceMultiplier ^ currentLevel))
end

local function createUpgradeValues(player)
	local upgradesFolder = Instance.new("Folder")
	upgradesFolder.Name = "Upgrades"
	upgradesFolder.Parent = player
	
	for upgradeName, config in pairs(UpgradeConfig) do
		local value = Instance.new("IntValue")
		value.Name = upgradeName
		value.Value = 0
		value.Parent = upgradesFolder
	end
end

Players.PlayerAdded:Connect(function(player)
	createUpgradeValues(player)
end)

upgradeEvent.OnServerEvent:Connect(function(player, upgradeName)
	local config = UpgradeConfig[upgradeName]
	if not config then return end
	
	if config.ComingSoon then
		return
	end
	
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return end
	
	local gems = playerData:FindFirstChild("Gems")
	if not gems then return end
	
	local upgradeFolder = player:FindFirstChild("Upgrades")
	if not upgradeFolder then return end
	
	local upgradeValue = upgradeFolder:FindFirstChild(upgradeName)
	if not upgradeValue then return end
	
	if upgradeValue.Value >= config.MaxLevel then
		return
	end
	
	local price = getPrice(upgradeName, upgradeValue.Value)
	
	if gems.Value < price then
		return
	end
	
	gems.Value -= price
	upgradeValue.Value += 1
end)

print("UPGRADEServer loaded")
