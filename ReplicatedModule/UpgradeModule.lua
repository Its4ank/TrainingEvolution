local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormatModule = require(ReplicatedStorage.Modules.FormatModule)

local UpgradeModule = {}

local DEFAULT_MAX_LEVEL = 10

UpgradeModule.VISIBLE_LEVEL_SLOTS = 10
UpgradeModule.CENTER_LEVEL_SLOT = 6

UpgradeModule.LevelFrameImages = {
	Default = "rbxassetid://135816242619104",
	Selected = "rbxassetid://72491574027703",
}

UpgradeModule.Upgrades = {
	Acceleration = {
		DisplayName = "ACCELERATION",
		ButtonName = "UpgAccButton",
		Description = "Увеличивает скорость набора скорости в гонке",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "PercentBonus",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://130498996568585",
			Stats = "rbxassetid://130498996568585",
		},
		
		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 2,
				EndPrice = 26,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 40,
				EndPrice = 120,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	Energy = {
		DisplayName = "ENERGY",
		ButtonName = "UpgEnergyButton",
		Description = "Увеличивает количество энергии, получаемой на беговой дорожке",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "Multiplier",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://74509086636062",
			Stats = "rbxassetid://74509086636062",
		},
		
		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 5,
				EndPrice = 45,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 65,
				EndPrice = 225,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	GemChance = {
		DisplayName = "GEM CHANCE",
		ButtonName = "UpgGemChanceButton",
		Description = "Увеличивает шанс выпадения гемов из наград в гонке.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "PercentBonus",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://83147992622387",
			Stats = "rbxassetid://83147992622387",
		},
		
		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 10,
				EndPrice = 70,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 100,
				EndPrice = 500,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	GemMore = {
		DisplayName = "GEM MORE",
		ButtonName = "UpgGemMoreButton",
		Description = "Увеличивает количество гемов, получаемых за награду в гонке.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "IntegerBonus",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://92484530085697",
			Stats = "rbxassetid://92484530085697",
		},

		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 20,
				EndPrice = 120,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 180,
				EndPrice = 980,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	Money = {
		DisplayName = "MONEY",
		ButtonName = "UpgMoneyButton",
		Description = "Увеличивает количество денег, получаемых за награду в гонке.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "Multiplier",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://123691959584167",
			Stats = "rbxassetid://123691959584167",
		},

		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 5,
				EndPrice = 45,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 65,
				EndPrice = 225,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	MoneyMultiplier = {
		DisplayName = "REBIRTH MONEY",
		ButtonName = "UpgMoneyMultiplierButton",
		Description = "Открывает денежный множитель, зависящий от количества Rebirth.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = 1,
		
		EffectType = "Unlock",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://120220589129413",
			Stats = "rbxassetid://120220589129413",
		},

		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 1,
				StartPrice = 100,
				EndPrice = 100,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	PetLuck = {
		DisplayName = "PET LUCK",
		ButtonName = "UpgPetLuckButton",
		Description = "Увеличивает шанс выпадения редких питомцев.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "PercentBonus",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://135052778438167",
			Stats = "rbxassetid://135052778438167",
		},

		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 2,
				EndPrice = 26,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 40,
				EndPrice = 120,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	RacePower = {
		DisplayName = "RACE POWER",
		ButtonName = "UpgRacePowerButton",
		Description = "Увеличивает енергию игрока только при расчете скорости в гонке.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "Multiplier",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://84300616126953",
			Stats = "rbxassetid://84300616126953",
		},

		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 1,
				EndPrice = 13,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 20,
				EndPrice = 60,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
	
	RebirthButton = {
		DisplayName = "REBIRTH BUTTONS",
		ButtonName = "UpgRebirthButton",
		Description = "Последовательно открывает дополнительные кнопки Rebirth.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = 6,
		
		EffectType = "RebirthButtons",
		
		RebirthButtonOrder = {
			"RebirthButton1",
			"RebirthButton2",
			"RebirthButton3",
			"RebirthButton4",
			"RebirthButton5",
			"RebirthButton6",
			"RebirthButton7",
		},
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://91670074635222",
			Stats = "rbxassetid://91670074635222",
		},

		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 2,
				StartPrice = 3,
				EndPrice = 12,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 3,
				ToLevel = 4,
				StartPrice = 35,
				EndPrice = 80,
				Curve = 1,
				RoundTo = 1,
			},
			{FromLevel = 5, ToLevel = 6, StartPrice = 160, EndPrice = 300, Curve = 1, RoundTo = 1,},
		},
	},
	
	SpeedTraining = {
		DisplayName = "SPEED TRAINING",
		ButtonName = "UpgSpeedTrainingButton",
		Description = "Увеличивает скорость игрока при тренировке.",
		
		ButtonImages = {
			Default = "rbxassetid://101008238777302",
			Selected = "rbxassetid://86011246645061",
		},
		
		Currency = "Gems",
		MaxLevel = DEFAULT_MAX_LEVEL,
		
		EffectType = "TickReduction",
		
		Icons = {
			Default = "rbxassetid://81342077488409",
			Selected = "rbxassetid://75143354585621",
			Stats = "rbxassetid://75143354585621",
		},

		PriceRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				StartPrice = 2,
				EndPrice = 18,
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,
				StartPrice = 26,
				EndPrice = 90,
				Curve = 1,
				RoundTo = 1,
			},
		},
	},
}

UpgradeModule.LevelBoost = {
	Acceleration = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 7.5, EndBoost = 37.5,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 45, EndBoost = 75,},
	},
	
	Energy = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 1.10, EndBoost = 1.50,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 1.60, EndBoost = 2.00,},
	},
	
	GemChance = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 2, EndBoost = 10,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 12, EndBoost = 20,},
	},
	
	GemMore = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 0.2, EndBoost = 1.0,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 1.2, EndBoost = 2.0,},
	},
	
	Money = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 1.10, EndBoost = 1.50,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 1.60, EndBoost = 2.00,},
	},
	
	PetLuck = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 10, EndBoost = 50,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 60, EndBoost = 100,},
	},
	
	RacePower = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 1.10, EndBoost = 1.50,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 1.60, EndBoost = 2.00,},
	},
	
	SpeedTraining = {
		{FromLevel = 1, ToLevel = 5, StartBoost = 2.5, EndBoost = 12.5,},
		{FromLevel = 6, ToLevel = 10, StartBoost = 15, EndBoost = 25,},
	},
}

--// Порядок кнопок и апгрейдов в UI
UpgradeModule.UpgradeOrder = {
	"Acceleration",
	"Energy",
	"GemChance",
	"GemMore",
	"Money",
	"MoneyMultiplier",
	"PetLuck",
	"RacePower",
	"RebirthButton",
	"SpeedTraining",
}

--// Helpers
local function clampLevel(level, maxLevel)
	level = tonumber(level) or 0
	maxLevel = tonumber(maxLevel) or 0
	
	return math.clamp(math.floor(level), 0, maxLevel)
end

local function roundToStep(value, step)
	step = tonumber(step) or 1
	
	if step <= 1 then 
		return math.floor(value + 0.5)
	end
	
	return math.floor((value / step) + 0.5) * step
end

local function formatCompactNumber(value, decimalPlaces)
	decimalPlaces = decimalPlaces or 2
	
	local text = string.format("%." .. decimalPlaces .. "f", value)
	
	text = text:gsub("(%..-)0+$", "%1")
	text = text:gsub("%.$", "")
	
	return text
end

local function getLevelRatio(level, maxLevel)
	level = clampLevel(level, maxLevel)
	
	if maxLevel <= 0 then
		return 0
	end
	
	return level / maxLevel
end

local function getPlayerUpgradeFolder(player)
	if not player then 
		return nil
	end
	
	return player:FindFirstChild("Upgrades")
end

--// Основная информация
function UpgradeModule.GetConfig(upgradeName)
	return UpgradeModule.Upgrades[upgradeName]
end

function UpgradeModule.IsValidUpgrade(upgradeName)
	return UpgradeModule.Upgrades[upgradeName] ~= nil
end

function UpgradeModule.GetUpgradeNames()
	local result = {}
	
	for index, upgradeName in ipairs(UpgradeModule.UpgradeOrder) do
		result[index] = upgradeName
	end
	
	return result
end

function UpgradeModule.GetUpgradeNameFromButton(buttonName)
	for upgradeName, config in pairs(UpgradeModule.Upgrades) do
		if config.ButtonName == buttonName then
			return upgradeName
		end
	end
	return nil
end

function UpgradeModule.GetMaxLevel(upgradeName)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then
		return 0
	end
	
	return config.MaxLevel or 0
end

function UpgradeModule.GetUpgradeValue(player, upgradeName)
	local upgradesFolder = getPlayerUpgradeFolder(player)
	
	if not upgradesFolder then
		return nil
	end
	
	return upgradesFolder:FindFirstChild(upgradeName)
end

function UpgradeModule.GetUpgradeLevel(player, upgradeName)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then
		return 0
	end
	
	local upgradeValue = UpgradeModule.GetUpgradeValue(player, upgradeName)
	
	if not upgradeValue then
		return 0
	end
	
	return clampLevel(upgradeValue.Value, config.MaxLevel)
end

function UpgradeModule.GetNextLevel(upgradeName, currentLevel)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then
		return nil
	end
	
	currentLevel = clampLevel(currentLevel, config.MaxLevel)
	
	if currentLevel >= config.MaxLevel then
		return nil
	end
	
	return currentLevel + 1
end

function UpgradeModule.IsMaxLevel(upgradeName, level)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then
		return false
	end
	
	level = clampLevel(level, config.MaxLevel)
	
	return level >= config.MaxLevel
end

--// Расчет стоимости
function UpgradeModule.GetLevelPrice(upgradeName, targetLevel)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	
	if not config then
		return nil
	end
	
	targetLevel = tonumber(targetLevel)
	
	if not targetLevel then
		return nil
	end
	
	targetLevel = math.floor(targetLevel)
	
	if targetLevel < 1 or targetLevel > config.MaxLevel then
		return nil
	end
	
	for _, priceRange in ipairs(config.PriceRanges or {}) do
		local fromLevel = priceRange.FromLevel
		local toLevel = priceRange.ToLevel
		
		if targetLevel >= fromLevel and targetLevel <= toLevel then
			local startPrice = priceRange.StartPrice or 0
			local endPrice = priceRange.EndPrice or startPrice
			local curve = priceRange.Curve or 1
			local roundTo = priceRange.RoundTo or 1
			
			if fromLevel == toLevel then
				return roundToStep(startPrice, roundTo)
			end
			
			local alpha = (targetLevel - fromLevel) / (toLevel - fromLevel)
			
			alpha = math.clamp(alpha, 0, 1)
			alpha = alpha ^ curve
			
			local price = startPrice + ((endPrice - startPrice) * alpha)
			
			return roundToStep(price, roundTo)
		end
	end
	
	warn("Price range not found for upgrade:", upgradeName, "Level:", targetLevel)
	return nil
end

function UpgradeModule.GetNextLevelPrice(upgradeName, currentLevel)
	local nextLevel = UpgradeModule.GetNextLevel(upgradeName, currentLevel)
	
	if not nextLevel then
		return nil
	end
	
	return UpgradeModule.GetLevelPrice(upgradeName, nextLevel)
end


--// Расчет силы апгрейда
function UpgradeModule.GetEffectValue(upgradeName, level)
	local config = UpgradeModule.GetConfig(upgradeName)
	if not config then return nil end
	
	level = clampLevel(level, config.MaxLevel)
	
	if config.EffectType == "Unlock" then
		return level >= 1
	end
	
	if config.EffectType == "RebirthButtons" then
		return math.clamp(level + 1, 1, #(config.RebirthButtonOrder or {}))
	end
	
	if level == 0 then
		return config.EffectType == "Multiplier" and 1 or 0
	end
	
	for _, range in ipairs(UpgradeModule.LevelBoost[upgradeName] or {}) do
		if level >= range.FromLevel and level <= range.ToLevel then
			local span = range.ToLevel - range.FromLevel
			local alpha = span > 0 and (level - range.FromLevel) / span or 0
			
			local startValue = tonumber(range.StartBoost) or 0
			local endValue = tonumber(range.EndBoost) or startValue
			
			local value = startValue + (endValue - startValue) * alpha
			
			if config.EffectType == "PercentBonus" or config.EffectType == "TickReduction" then 
				return value / 100
			end
			
			if config.EffectType == "IntegerBonus" then
				return math.floor(value + 0.5)
			end
			
			return value
		end
	end
	
	return nil
end

function UpgradeModule.GetPlayerEffectValue(player, upgradeName)
	local level = UpgradeModule.GetUpgradeLevel(player, upgradeName)
	
	return UpgradeModule.GetEffectValue(upgradeName, level)
end

--// Текс бонуса для UI
function UpgradeModule.GetBonusText(upgradeName, level)
	local config = UpgradeModule.GetConfig(upgradeName)
	if not config then return "" end
	
	level = clampLevel(level, config.MaxLevel)
	
	local effectValue = UpgradeModule.GetEffectValue(upgradeName, level)
	
	if config.EffectType == "Multiplier" then
		local prefix = upgradeName == "RacePower" and "ENERGY x" or "x"
		return prefix .. formatCompactNumber(effectValue, 2)
	end
	
	if config.EffectType == "PercentBonus" then 
		return "+" .. FormatModule.FormatPercent(effectValue * 100)
	end
	
	if config.EffectType == "FlatBonus" or config.EffectType == "IntegerBonus" then
		return "+" .. FormatModule.FormatNumber(effectValue) .. " GEMS"
	end
	
	if config.EffectType == "TickReduction" then
		return "-" .. FormatModule.FormatPercent(effectValue * 100)
	end
	
	if config.EffectType == "Unlock" then
		return effectValue and "UNLOCKED" or "LOCKED"
	end
	
	if config.EffectType == "RebirthButtons" then
		return tostring(effectValue) .. "/" .. tostring(#(config.RebirthButtonOrder or {})) .. " BUTTONS"
	end
	
	return ""
end

function UpgradeModule.GetCurrentBonusText(upgradeName, currentLevel)
	return UpgradeModule.GetBonusText(upgradeName, currentLevel)
end

function UpgradeModule.GetNextBonusText(upgradeName, currentLevel)
	local nextLevel = UpgradeModule.GetNextLevel(upgradeName, currentLevel)
	
	if not nextLevel then
		return "MAX"
	end
	
	return UpgradeModule.GetBonusText(upgradeName, nextLevel)
end

--// Иконки
function UpgradeModule.GetIcon(upgradeName, iconType)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then 
		return ""
	end
	
	local icons = config.Icons or {}
	
	if iconType == "Selected" then 
		return icons.Selected or icons.Default or ""
	end
	
	if iconType == "Stats" then
		return icons.Stats or icons.Default or ""
	end
	
	return icons.Default or ""
end

function UpgradeModule.GetLevelFrameImage(imageType)
	local images = UpgradeModule.LevelFrameImages or {}
	
	if imageType == "Selected" then
		return images.Selected or images.Default or ""
	end
	return images.Default or ""
end

function UpgradeModule.GetButtonImage(upgradeName, imageType)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then
		return ""
	end
	
	local images = config.ButtonImages or {}
	
	if imageType == "Selected" then
		return images.Selected or images.Default or ""
	end
	return images.Default or ""
end

function UpgradeModule.GetEnergyMultiplier(player)
	return UpgradeModule.GetPlayerEffectValue(player, "Energy") or 1
end

function UpgradeModule.GetMoneyMultiplier(player)
	return UpgradeModule.GetPlayerEffectValue(player, "Money") or 1
end

function UpgradeModule.GetRacePowerMultiplier(player)
	return UpgradeModule.GetPlayerEffectValue(player, "RacePower") or 1
end

function UpgradeModule.GetRaceEnergy(player, realEnergy)
	realEnergy = tonumber(realEnergy) or 0
	
	return realEnergy * UpgradeModule.GetRacePowerMultiplier(player)
end

function UpgradeModule.GetAccelerationBonus(player)
	return UpgradeModule.GetPlayerEffectValue(player, "Acceleration") or 0
end

function UpgradeModule.GetAccelerationMultiplier(player)
	return 1 + UpgradeModule.GetAccelerationBonus(player)
end

function UpgradeModule.GetGemChanceBonus(player)
	return UpgradeModule.GetPlayerEffectValue(player, "GemChance") or 0
end

function UpgradeModule.GetFinalGemChance(player, baseChance)
	baseChance = tonumber(baseChance) or 0
	
	local finalChance = baseChance + UpgradeModule.GetGemChanceBonus(player)
	
	return math.clamp(finalChance, 0, 1)
end

function UpgradeModule.GetGemMoreBonus(player)
	return UpgradeModule.GetPlayerEffectValue(player, "GemMore") or 0
end

function UpgradeModule.GetFinalGemAmount(player, baseAmount)
	baseAmount = tonumber(baseAmount) or 0
	
	return math.max(0, baseAmount + UpgradeModule.GetGemMoreBonus(player))
end

function UpgradeModule.GetPetLuckBonus(player)
	return UpgradeModule.GetPlayerEffectValue(player, "PetLuck") or 0
end

function UpgradeModule.GetSpeedTrainingReduction(player)
	return UpgradeModule.GetPlayerEffectValue(player, "SpeedTraining") or 0
end

function UpgradeModule.GetTrainingInterval(player, baseInterval)
	baseInterval = tonumber(baseInterval) or 1
	
	local reduction = UpgradeModule.GetSpeedTrainingReduction(player)
	
	return math.max(0.01, baseInterval * (1 - reduction))
end

function UpgradeModule.IsMoneyMultiplierUnlocked(player)
	return UpgradeModule.GetPlayerEffectValue(player, "MoneyMultiplier") == true
end

function UpgradeModule.GetUnlockedRebirthButtonCount(player)
	return UpgradeModule.GetPlayerEffectValue(player, "RebirthButton") or 1
end

function UpgradeModule.GetRequiredLevelForRebirthButton(buttonName)
	local config = UpgradeModule.GetConfig("RebirthButton")
	
	if not config then 
		return nil
	end
	
	for buttonIndex, configureButtonName in ipairs(config.RebirthButtonOrder or {}) do
		if configureButtonName == buttonName then
			return math.max(0, buttonIndex - 1)
		end
	end
	return nil
end

function UpgradeModule.IsRebirthButtonUnlocked(player, buttonName)
	local requiredUpgradeLevel = UpgradeModule.GetRequiredLevelForRebirthButton(buttonName)
	
	if requiredUpgradeLevel == nil then 
		return false
	end
	
	local currentUpgradeLevel = UpgradeModule.GetUpgradeLevel(player, "RebirthButton")
	
	return currentUpgradeLevel >= requiredUpgradeLevel
end

function UpgradeModule.ValidateConfig()
	local valid = true
	
	local function report(message, upgradeName, level)
		valid = false
		
		warn("UpgradeModule: " .. message, upgradeName, level or "")
	end
	
	local function coverage(ranges, level)
		local count = 0
		
		for _, range in ipairs(ranges or {}) do
			if type(range.FromLevel) == "number" and type(range.ToLevel) == "number" and level >= range.FromLevel and level <= range.ToLevel then
				count += 1
			end
		end
		
		return count
	end
	
	for upgradeName, config in pairs(UpgradeModule.Upgrades) do
		local maxLevel = config.MaxLevel
		
		if type(maxLevel) ~= "number" or maxLevel < 1 or maxLevel % 1 ~= 0 then
			report("invalid MaxLevel", upgradeName)
		else 
			if not config.ButtonName then
				report("Missing ButtonName", upgradeName)
			end
			
			local numericEffect = config.EffectType ~= "Unlock" and config.EffectType ~= "RebirthButtons"
			for level = 1, maxLevel do
				if coverage(config.PriceRanges, level) ~= 1 then
					report("price range gap or overlap", upgradeName, level)
				else 
					local price = UpgradeModule.GetLevelPrice(upgradeName, level)
					
					if type(price) ~= "number" or price <= 0 or price % 1 ~= 0 then
						report("invalid price", upgradeName, level)
					end
				end
				
				if numericEffect then
					if coverage(UpgradeModule.LevelBoost[upgradeName], level) ~= 1 then
						report("boost range gap or overlap", upgradeName, level)
					else 
						local effect = UpgradeModule.GetEffectValue(upgradeName, level)
						local previous = UpgradeModule.GetEffectValue(upgradeName, level - 1)
						
						if type(effect) ~= "number" or type(previous) ~= "number" or effect <= previous then
							report("level gives no improvement", upgradeName, level)
						end
					end
				end
			end
		end
	end
	
	return valid
end

assert(UpgradeModule.ValidateConfig(), "UpgradeModule: check price and boost ranges")

return UpgradeModule
