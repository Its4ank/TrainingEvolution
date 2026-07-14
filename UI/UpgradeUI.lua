--// UpgradeUI LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local upgradeFolderUI = guiFolder:WaitForChild("UpgradeFolder")


local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeEvent")

local upgradeMenu = upgradeFolderUI:WaitForChild("UPGRADEMenu")
local upgradesFrame = upgradeMenu:WaitForChild("UpgradesFrame"):WaitForChild("ScrollingFrame")

local gemsStat = ClientDataModule.GetGems(player)

local upgradesFolder = ClientDataModule.GetUpgrades(player)

local UpgradeConfig = {
	Money = {
		DisplayName = "Money",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Multiplier",
	},

	Energy = {
		DisplayName = "Energy",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Multiplier",
	},

	GemChance = {
		DisplayName = "Gem Chance",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Percent",
	},

	GemMore = {
		DisplayName = "Gem More",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.55,
		BonusPerLevel = 1,
		BonusType = "Number",
	},

	SpeedTraining = {
		DisplayName = "Speed Training",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Multiplier",
	},

	PetLuck = {
		DisplayName = "Pet Luck",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Percent",
	},

	Acceleration = {
		DisplayName = "Acceleration",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Multiplier",
	},

	RacePower = {
		DisplayName = "Race Power",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Multiplier",
	},

	RebirthMultiplierMoney = {
		DisplayName = "Rebirth Money",
		MaxLevel = 1,
		BasePrice = 10,
		PriceMultiplier = 1,
		BonusType = "Unlock",
	},

	RebirthButton = {
		DisplayName = "Rebirth Button",
		MaxLevel = 6,
		BasePrice = 5,
		PriceMultiplier = 1.45,
		BonusType = "Unlock",
	},

	HatLuck = {
		DisplayName = "Hat Luck",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Percent",
		ComingSoon = true,
	},

	RelicsLuck = {
		DisplayName = "Relics Luck",
		MaxLevel = 10,
		BasePrice = 1,
		PriceMultiplier = 1.45,
		BonusPerLevel = 0.10,
		BonusType = "Percent",
		ComingSoon = true,
	},
}

local function getUpgradePrice(upgradeName, currentLevel)
	local config = UpgradeConfig[upgradeName]
	if not config then return 0 end

	return math.floor(config.BasePrice * (config.PriceMultiplier ^ currentLevel))
end

local function getUpgradeBonusText(upgradeName, level)
	local config = UpgradeConfig[upgradeName]
	if not config then return "" end

	if config.ComingSoon then
		return "Soon"
	end

	if config.BonusType == "Multiplier" then
		local multiplier = 1 + (level * config.BonusPerLevel)
		return "x" .. string.format("%.2f", multiplier)
	end

	if config.BonusType == "Percent" then
		local percent = level * config.BonusPerLevel * 100
		return "+" .. string.format("%.0f", percent) .. "%"
	end

	if config.BonusType == "Number" then
		local base = 1
		local total = base + (level * config.BonusPerLevel)
		return "+" .. tostring(total) .. " Gems"
	end
	
	if upgradeName == "RebirthButton" then
		local nextButtons = {
			[0] = "Unlock +5",
			[1] = "Unlock +10",
			[2] = "Unlock +15",
			[3] = "Unlock +20",
			[4] = "Unlock +25",
			[5] = "Unlock +30",
			[6] = "Unlock +35",
		}
		return nextButtons[level] or "All unlocked"
	end
	
	if upgradeName == "RebirthMultiplierMoney" then
		if level <= 0 then
			return "Money boost locked"
		else
			return "Money boost unlocked"
		end
	end

	if config.BonusType == "Unlock" then
		if level <= 0 then
			return "Locked"
		else
			return "Unlocked"
		end
	end

	return ""
end

local function updateUpgradeRow(upgradeName)
	local config = UpgradeConfig[upgradeName]
	if not config then return end

	local upgradeValue = upgradesFolder:FindFirstChild(upgradeName)
	if not upgradeValue then
		warn("Upgrade value not found:", upgradeName)
		return
	end

	local row = upgradesFrame:FindFirstChild(upgradeName .. "Upgrade")
	if not row then
		warn("Upgrade row not found:", upgradeName .. "Upgrade")
		return
	end
	
	local nameLabel = row:WaitForChild("NameLabel")
	local bonusLabel = row:WaitForChild("BonusLabel")
	local levelLabel = row:WaitForChild("LevelLabel")
	local upgradeButton = row:WaitForChild("UpgradeButton")

	local level = upgradeValue.Value

	nameLabel.Text = config.DisplayName
	bonusLabel.Text = getUpgradeBonusText(upgradeName, level)
	levelLabel.Text = "Level: " .. tostring(level) .. "/" .. tostring(config.MaxLevel)

	if config.ComingSoon then
		upgradeButton.Text = "Coming Soon"
		upgradeButton.Active = false
		upgradeButton.AutoButtonColor = false
		upgradeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		return
	end

	if level >= config.MaxLevel then
		upgradeButton.Text = "MAX"
		upgradeButton.Active = false
		upgradeButton.AutoButtonColor = false
		upgradeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		return
	end

	local price = getUpgradePrice(upgradeName, level)

	upgradeButton.Text = tostring(price) .. " Gems"
	upgradeButton.Active = true
	upgradeButton.AutoButtonColor = true

	if gemsStat.Value >= price then
		upgradeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		upgradeButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end

local function updateAllUpgradesUI()
	for upgradeName, _ in pairs(UpgradeConfig) do
		updateUpgradeRow(upgradeName)
	end
end

local function setupUpgradeButtons()
	for upgradeName, config in pairs(UpgradeConfig) do
		local row = upgradesFrame:FindFirstChild(upgradeName .. "Upgrade")

		if row then
			local upgradeButton = row:WaitForChild("UpgradeButton")

			upgradeButton.MouseButton1Click:Connect(function()
				if config.ComingSoon then return end

				local upgradeValue = upgradesFolder:FindFirstChild(upgradeName)
				if not upgradeValue then return end

				if upgradeValue.Value >= config.MaxLevel then return end

				upgradeEvent:FireServer(upgradeName)
			end)

			local upgradeValue = upgradesFolder:FindFirstChild(upgradeName)
			if upgradeValue then
				upgradeValue.Changed:Connect(function()
					updateUpgradeRow(upgradeName)
				end)
			end
		end
	end
end

gemsStat.Changed:Connect(updateAllUpgradesUI)

setupUpgradeButtons()
updateAllUpgradesUI()

print("UpgradeUI loaded")