local RaceModule = {}

--// Основные настройки гонки
RaceModule.Settings = {
	WaitTime = 30,
	RaceTime = 150,
	
	MaxTrackLength = 5000,
	
	MaxStage = 5,
	MaxRoadLevel = 5,
	MaxRewardLevel = 25,
	RewardLevelsPerStage = 5,
	
	BaseSpeed = 16,
	BaseAccelerationPerSecond = 0.2,
	
	BaseGemChance = 0.20,
	
	TopPlayerCount = 3,
}

RaceModule.WorldNames = {
	RaceTrack = "RaceTrack",
	
	RaceStartPoint = "RaceStartPoint",
	RaceMaxEndPoint = "RaceMaxEndPoint",
	
	StartGate = "StartGate",
	StartTrigger = "StartTrigger",
	
	RewardGateTemplate = "RewardGate",
	FinishGateTemplate = "FinishGate",
}

--// Настройки юи
RaceModule.UI = {
	Speedometer = {
		TickCount = 5,
		
		MinArrowRotation = -85,
		MaxArrowRotation = 85,
	},
	
	Bars = {
		RewardLevelMaxScale = 0.93,
		RoadLevelMaxScale = 0.93,
		StageLevelMaxScale = 0.922,
		StageRequirementMaxScale = 0.796,
	},
	
	RewardBar = {
		LengthScale = 0.502,
	},
	
	StageArrow = {
		StartPosition = UDim2.new(0.417, 0, 0.222, 0),
		EndPosition = UDim2.new(0.455, 0, 0.222, 0),	
	},
	
	RacePanel = {
		LineSize = UDim2.new(0.824, 0, 0.155, 0),
		
		StagePathUnits = {
			[1] = {
				[1] = 0.20,
				[2] = 0.40,
				[3] = 0.60,
				[4] = 0.80,
				[5] = 1.00,
			},
			
			[2] = {
				[1] = 0.20,
				[2] = 0.40,
				[3] = 0.60,
				[4] = 0.80,
				[5] = 1.00,
			},
			
			[3] = {
				[1] = 1 / 3,
				[2] = 2 / 3,
				[3] = 1.00,
				[4] = 1.25,
				[5] = 1.50,
			},
			
			[4] = {
				[1] = 0.50,
				[2] = 1.00,
				[3] = 1.50,
				[4] = 2.00,
				[5] = 2.20,
			},
			
			[5] = {
				[1] = 0.50,
				[2] = 1.00,
				[3] = 1.50,
				[4] = 2.00,
				[5] = 3.00,
			},
		},
	},
}

--// Настройки стадий
RaceModule.Stages = {
	[1] = {
		Name = "DUST RUNNER",
		
		RewardMultiplier = 1.00,
		
		Distance = 200,
		
		Icon = "rbxassetid://80634958548140",
		
		LevelUpgradePrices = {
			[2] = 100,
			[3] = 250,
			[4] = 500,
			[5] = 1000,
		},
		
		NextStageRequirements = {
			Level = 5,
			Money = 1500,
			RaceTouch = 100,
			Rebirth = 500,
			Energy = 50000,
		},
	},
	
	[2] = {
		Name = "STONE RACER",
		
		RewardMultiplier = 2.00,

		Distance = 400,

		Icon = "rbxassetid://132992843832066",

		LevelUpgradePrices = {
			[2] = 2500,
			[3] = 3500,
			[4] = 4500,
			[5] = 6000,
		},

		NextStageRequirements = {
			Level = 5,
			Money = 5000,
			RaceTouch = 250,
			Rebirth = 2500,
			Energy = 1000000,
		},
	},
	
	[3] = {
		Name = "FLINT SPRINTER",
		
		RewardMultiplier = 3.00,

		Distance = 600,

		Icon = "rbxassetid://122433413012673",

		LevelUpgradePrices = {
			[2] = 7500,
			[3] = 9000,
			[4] = 11500,
			[5] = 13000,
		},

		NextStageRequirements = {
			Level = 5,
			Money = 25000,
			RaceTouch = 500,
			Rebirth = 50000,
			Energy = 25000000,
		},
	},
	
	[4] = {
		Name = "PRIMAL CHAMPION",
		
		RewardMultiplier = 4.00,

		Distance = 800,

		Icon = "rbxassetid://100510262721575",

		LevelUpgradePrices = {
			[2] = 15000,
			[3] = 17500,
			[4] = 20000,
			[5] = 25000,
		},

		NextStageRequirements = {
			Level = 5,
			Money = 100000,
			RaceTouch = 1000,
			Rebirth = 500000,
			Energy = 1000000000,
		},
	},
	
	[5] = {
		Name = "ANCIENT LEGEND",
		
		RewardMultiplier = 5.00,

		Distance = 1000,

		Icon = "rbxassetid://99609767140625",

		LevelUpgradePrices = {
			[2] = 30000,
			[3] = 35000,
			[4] = 42500,
			[5] = 50000,
		},
		
		NextStageRequirements = nil,
	},
}

--// Базовые награды R1-R10
RaceModule.Rewards = {
	R1 = {
		Money = 2.5,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R2 = {
		Money = 5,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R3 = {
		Money = 10,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R4 = {
		Money = 25,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R5 = {
		Money = 50,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R6 = {
		Money = 100,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R7 = {
		Money = 200,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R8 = {
		Money = 400,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R9 = {
		Money = 800,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
	
	R10 = {
		Money = 1600,
		Gems = 1,
		XP = 1,
		RaceTouch = 1,
	},
}

--// уровень общего улучшения наград
RaceModule.RewardUpgradeLevels = {
	[1] = {
		FromLevel = 1,
		ToLevel = 5,
		
		StartBonus = 1.1,
		EndBonus = 1.3,
		
		StartPriceMoney = 50,
		EndPriceMoney = 500,
		
		StartPriceTouch = 5,
		EndPriceTouch = 25,
		
		StartPriceXP = 15,
		EndPriceXP = 45,
	},
	
	[2] = {
		FromLevel = 6,
		ToLevel = 10,
		
		StartBonus = 1.4,
		EndBonus = 1.7,

		StartPriceMoney = 1000,
		EndPriceMoney = 5000,

		StartPriceTouch = 35,
		EndPriceTouch = 75,

		StartPriceXP = 60,
		EndPriceXP = 125,
	},
	
	[3] = {
		FromLevel = 11,
		ToLevel = 15,
		
		StartBonus = 1.8,
		EndBonus = 2.1,

		StartPriceMoney = 7500,
		EndPriceMoney = 12500,

		StartPriceTouch = 20,
		EndPriceTouch = 50,

		StartPriceXP = 50,
		EndPriceXP = 100,
	},
	
	[4] = {
		FromLevel = 16,
		ToLevel = 20,
		
		StartBonus = 2.2,
		EndBonus = 2.5,

		StartPriceMoney = 14000,
		EndPriceMoney = 20000,

		StartPriceTouch = 20,
		EndPriceTouch = 50,

		StartPriceXP = 50,
		EndPriceXP = 100,
	},
	
	[5] = {
		FromLevel = 21,
		ToLevel = 25,
		
		StartBonus = 2.6,
		EndBonus = 3.0,

		StartPriceMoney = 25000,
		EndPriceMoney = 40000,

		StartPriceTouch = 20,
		EndPriceTouch = 50,

		StartPriceXP = 50,
		EndPriceXP = 100,
	},
}

--// Вспомогательные функции
local function interpolate(startValue, endValue, fromLevel, toLevel, level)
	if fromLevel == toLevel then return endValue end
	
	local alpha = (level - fromLevel) / (toLevel - fromLevel)
	return startValue + ((endValue - startValue) * alpha)
end

local function clampStage(stage)
	stage = math.floor(tonumber(stage) or 1)
	
	return math.clamp(stage, 1, RaceModule.Settings.MaxStage)
end

local function clampRoadLevel(level)
	level = math.floor(tonumber(level) or 1)
	
	return math.clamp(level, 1, RaceModule.Settings.MaxRoadLevel)
end

local function clampRewardLevel(level)
	level = math.floor(tonumber(level) or 0)
	
	return math.clamp(level, 0, RaceModule.Settings.MaxRewardLevel)
end

local function roundNumber(number, decimalPlaces)
	number = tonumber(number) or 0
	decimalPlaces = math.max(0, math.floor(decimalPlaces or 0))
	
	local multiplier = 10 ^ decimalPlaces
	
	return math.floor(number * multiplier + 0.5) / multiplier
end

local function trimZeros(text)
	text = text:gsub("(%..-)0+$", "%1")
	text = text:gsub("%.$", "")
	return text
end

--// Получение конфигурации
function RaceModule.GetStageConfig(stage)
	stage = clampStage(stage)
	
	return RaceModule.Stages[stage]
end

function RaceModule.GetStageName(stage)
	local config = RaceModule.GetStageConfig(stage)
	
	return config.Name
end

function RaceModule.GetStageIcon(stage)
	local config = RaceModule.GetStageConfig(stage)
	
	return config.Icon
end

function RaceModule.GetStageRewardMultiplier(stage)
	local config = RaceModule.GetStageConfig(stage)
	
	return tonumber(config.RewardMultiplier) or 1
end

--// Длина трассы и количество наград
function RaceModule.GetTrackDistance(stage, roadLevel)
	stage = clampStage(stage)
	roadLevel = clampRoadLevel(roadLevel)
	
	local stageConfig = RaceModule.GetStageConfig(stage)
	
	return stageConfig.Distance * roadLevel
end

function RaceModule.GetRewardCount(stage, roadLevel)
	stage = clampStage(stage)
	roadLevel = clampRoadLevel(roadLevel)
	
	return stage + roadLevel
end

function RaceModule.GetRewardName(rewardIndex)
	rewardIndex = math.floor(tonumber(rewardIndex) or 1)
	
	return "R" .. tostring(rewardIndex)
end

function RaceModule.GetRewardDistance(stage, roadLevel, rewardIndex)
	local trackDistance = RaceModule.GetTrackDistance(stage, roadLevel)
	local rewardCount = RaceModule.GetRewardCount(stage, roadLevel)
	
	rewardIndex = math.clamp(math.floor(tonumber(rewardIndex) or 1), 1, rewardCount)
	
	return trackDistance * rewardIndex / rewardCount
end

function RaceModule.GetRewardDistances(stage, roadLevel)
	local rewardCount = RaceModule.GetRewardCount(stage, roadLevel)
	local distance = {}
	
	for rewardIndex = 1, rewardCount do
		distance[rewardIndex] = RaceModule.GetRewardDistance(stage, roadLevel, rewardIndex)
	end
	return distance
end

function RaceModule.GetRewardCheckpoint(stage, roadLevel)
	local rewardCount = RaceModule.GetRewardCount(stage, roadLevel)
	local checkpoints = {}
	
	for rewardIndex = 1, rewardCount do
		table.insert(checkpoints, {
			Index = rewardIndex,
			Name = RaceModule.GetRewardName(rewardIndex),
			
			Distance = RaceModule.GetRewardDistance(stage, roadLevel, rewardIndex),
			
			IsFinish = rewardIndex == rewardCount,
		})
	end
	return checkpoints
end

--// Прокачка длины дороги
function RaceModule.GetRoadUpgradePrice(stage, currentLevel)
	stage = clampStage(stage)
	currentLevel = clampRoadLevel(currentLevel)
	
	if currentLevel >= RaceModule.Settings.MaxRoadLevel then return nil end
	
	local nextLevel = currentLevel + 1
	local stageConfig = RaceModule.GetStageConfig(stage)
	
	return stageConfig.LevelUpgradePrices[nextLevel]
end

function RaceModule.GetRewardUpgradeRange(level)
	level = math.floor(tonumber(level) or 0)
	
	for _, range in ipairs(RaceModule.RewardUpgradeLevels) do
		if level >= range.FromLevel and level <= range.ToLevel then
			return range
		end
	end
	return nil
end

function RaceModule.GetRewardUpgradeData(level)
	level = math.floor(tonumber(level) or 0)
	
	if level == 0 then
		return {
			Level = 0,
			Bonus = 1,
			
			PriceMoney = nil,
			PriceRaceTouch = nil,
			PriceXP = nil,
		}
	end
	
	local range = RaceModule.GetRewardUpgradeRange(level)
	if not range then return nil end
	
	return {
		Level = level,
		
		Bonus = interpolate(
			range.StartBonus,
			range.EndBonus,
			range.FromLevel,
			range.ToLevel,
			level
		),
		
		PriceMoney = interpolate(
			range.StartPriceMoney,
			range.EndPriceMoney,
			range.FromLevel,
			range.ToLevel,
			level
		),
		
		PriceRaceTouch = interpolate(
			range.StartPriceTouch,
			range.EndPriceTouch,
			range.FromLevel,
			range.ToLevel,
			level
		),
		
		PriceXP = interpolate(
			range.StartPriceXP,
			range.EndPriceXP,
			range.FromLevel,
			level
		),
	}
end

function RaceModule.GetRewardBonus(level)
	if level <= 0 then return 1 end
	
	local data = RaceModule.GetRewardUpgradeData(level)
	
	return data and data.Bonus or 1
end

function RaceModule.GetRewardUpgradePrice(targetLevel)
	local data = RaceModule.GetRewardUpgradeData(targetLevel)
	if not data then return nil end
	
	return {
		Money = data.PriceMoney,
		RaceTouch = data.PriceRaceTouch,
		XP = data.PriceXP,
	}
end

function RaceModule.GetNextProgressionPreview(stage, currentLevel)
	stage = clampStage(stage)
	currentLevel = clampRoadLevel(currentLevel)
	
	local nextStage = stage
	local nextLevel = currentLevel + 1
	
	if nextLevel > RaceModule.Settings.MaxRoadLevel then
		nextStage += 1
		nextLevel = 1
	end
	
	if nextStage > RaceModule.Settings.MaxStage then return nil end
	
	return {
		Stage = nextStage,
		Level = nextLevel,
		
		Distance = RaceModule.GetTrackDistance(nextStage, nextLevel),
		
		RewardCount = RaceModule.GetRewardCount(nextStage, nextLevel),
	}
end

--// Уровни наград
function RaceModule.GetRewardLevelCap(stage)
	stage = clampStage(stage)
	
	
	return math.min(
		stage * RaceModule.Settings.RewardLevelsPerStage,
		RaceModule.Settings.MaxRewardLevel
	)
end

function RaceModule.GetRewardUpgradeConfig(rewardLevel)
	rewardLevel = clampRewardLevel(rewardLevel)
	
	return RaceModule.GetRewardUpgradeData(rewardLevel)
end

function RaceModule.GetRewardUpgradeMultiplier(rewardLevel)
	return RaceModule.GetRewardBonus(rewardLevel)
end


function RaceModule.GetNextRewardUpgrade(stage, currentRewardLevel)
	stage = clampStage(stage)
	currentRewardLevel = clampRewardLevel(currentRewardLevel)
	
	local stageCap = RaceModule.GetRewardLevelCap(stage)
	
	if currentRewardLevel >= stageCap then return nil end
	if currentRewardLevel >= RaceModule.Settings.MaxRewardLevel then return nil end
	
	local nextLevel = currentRewardLevel + 1
	local nextData = RaceModule.GetRewardUpgradeData(nextLevel)
	
	if not nextData then return nil end
	
	return {
		Level = nextLevel,
		RewardMultiplier = nextData.Bonus,
		
		Price = {
			Money = nextData.PriceMoney,
			RaceTouch = nextData.PriceRaceTouch,
			XP = nextData.PriceXP,
		},
	}
end

function RaceModule.GetLocalRewardLevel(stage, rewardLevel)
	stage = clampStage(stage)
	rewardLevel = clampRewardLevel(rewardLevel)
	
	local previousStageCap = (stage - 1) * RaceModule.Settings.RewardLevelsPerStage
	
	return math.clamp( 
		rewardLevel - previousStageCap,
		0,
		RaceModule.Settings.RewardLevelsPerStage
	)
end

--// Базовые и итоговые настройки
function RaceModule.GetBaseReward(rewardIndex)
	local rewardName = RaceModule.GetRewardName(rewardIndex)
	
	return RaceModule.Rewards[rewardName]
end

function RaceModule.calculateFinalReward(rewardIndex, stage, rewardLevel, modifiers)
	modifiers = modifiers or {}
	
	local baseReward = RaceModule.GetBaseReward(rewardIndex)
	if not baseReward then return nil end
	
	local stageMultiplier = RaceModule.GetStageRewardMultiplier(stage)
	local rewardUpgradeMultiplier = RaceModule.GetRewardBonus(rewardLevel)
	local sharedMultiplier = stageMultiplier * rewardUpgradeMultiplier
	
	local moneyMultiplier = tonumber(modifiers.MoneyMultiplier) or 1
	local xpMultiplier = tonumber(modifiers.XPMultiplier) or 1
	local gemsMultiplier = tonumber(modifiers.GemsMultiplier) or 1
	local raceTouchMultiplier = tonumber(modifiers.RaceTouchMultiplier) or 1
	
	local gemFlatBonus = tonumber(modifiers.GemFlatBonus) or 0
	local gemsChanceBonus = tonumber(modifiers.GemChanceBonus) or 0
	
	local baseMoney = tonumber(baseReward.Money) or 0
	local baseGems = tonumber(baseReward.Gems) or 0
	local baseXp = tonumber(baseReward.XP) or 0
	local baseRaceTouch = tonumber(baseReward.RaceTouch) or 1
	
	local finalMoney = math.floor(baseMoney * sharedMultiplier * moneyMultiplier)
	local finalGems = math.floor((baseGems + gemFlatBonus) * sharedMultiplier * gemsMultiplier)
	local finalXP = roundNumber(baseXp * sharedMultiplier * xpMultiplier, 3)
	
	local finalRaceTouch = math.floor(baseRaceTouch * raceTouchMultiplier)
	local finalGemChance = math.clamp(RaceModule.Settings.BaseGemChance + gemsChanceBonus, 0, 1)
	
	return {
		Money = math.max(0, finalMoney),
		Gems = math.max(0, finalGems),
		XP = math.max(0, finalXP),
		RaceTouch = math.max(0, finalRaceTouch),
		
		GemChance = finalGemChance,
		StageMultiplier = stageMultiplier,
		RewardUpgradeMultiplier = rewardUpgradeMultiplier,
		SharedRewardMultiplier = sharedMultiplier,
	}
end

--// Требования повышения стадии
function RaceModule.GetNextStageRequirements(stage)
	stage = clampStage(stage)
	
	local stageConfig = RaceModule.GetStageConfig(stage)
	
	return stageConfig.NextStageRequirements
end

function RaceModule.GetStageRequirementProgress(stage, currentValues)
	stage = clampStage(stage)
	currentValues = currentValues or {}
	
	local requirements = RaceModule.GetNextStageRequirements(stage)
	
	if not requirements then 
		return {
			Progress = 1,
			Percent = 100,
			CanStageUp = false,
			IsMaxStage = true,
			Ratios = {},
		}
	end
	
	local requirementOrder = {
		"Level",
		"Money",
		"RaceTouch",
		"Rebirth",
		"Energy",
	}
	
	local ratios = {}
	local ratioSum = 0
	local canStageUp = true
	
	for _, requirementName in ipairs(requirementOrder) do
		local requiredAmount = tonumber(requirements[requirementName]) or 0
		local currentAmount = tonumber(currentValues[requirementName]) or 0
		local ratio
		
		if requiredAmount <= 0 then
			ratio = 1
		else 
			ratio = math.clamp(currentAmount / requiredAmount, 0, 1)
		end
		
		ratios[requirementName] = ratio
		ratioSum += ratio
		
		if currentAmount < requiredAmount then
			canStageUp = false
		end
	end
	
	local progress = ratioSum / #requirementOrder
	
	return {
		Progress = progress,
		
		Percent = math.floor(progress * 100 + 0.5),
		
		CanStageUp = canStageUp,
		IsMaxStage = false,
		
		Ratios = ratios,
	}
end

function RaceModule.GetMissingRequirements(requiredValues, currentValues)
	requiredValues = requiredValues or {}
	currentValues = currentValues or {}
	
	local missing = {}
	
	for resourceName, requiredAmount in pairs(requiredValues) do
		requiredAmount = tonumber(requiredAmount) or 0
		
		local currentAmount = tonumber(currentValues[resourceName]) or 0
		
		if currentAmount < requiredAmount then
			missing[resourceName] = requiredAmount - currentAmount
		end
	end
	return missing
end

function RaceModule.HasRequiredResources(requiredValues, currentValues)
	local missing = RaceModule.GetMissingRequirements(requiredValues, currentValues)
	
	return next(missing) == nil
end

--// Позицилнирование обьектов в мире
function RaceModule.GetForwardDistance(startCFrame, worldPosition)
	local direction = startCFrame.LookVector
	local offset = worldPosition - startCFrame.Position
	
	return offset:Dot(direction)
end

function RaceModule.GetWorldPositionAtDistance(startCFrame, disatnce)
	disatnce = tonumber(disatnce) or 0
	
	return startCFrame.Position + startCFrame.LookVector * disatnce
end

function RaceModule.GetWorldCFrameAtDistance(startCFrame, distance)
	local position = RaceModule.GetWorldPositionAtDistance(startCFrame, distance)
	local direction = startCFrame.LookVector
	return CFrame.lookAt(position, position + direction, startCFrame.UpVector)
end

function RaceModule.MeasureTrack(startCFrame, endPosition)
	local offset = endPosition - startCFrame.Position
	local direction = startCFrame.LookVector
	local forwardLength = offset:Dot(direction)
	local lateralOffset = offset - direction * forwardLength
	
	return {
		Length = forwardLength,
		LateralError = lateralOffset.Magnitude,
		
		IsCorrect = math.abs(forwardLength - RaceModule.Settings.MaxTrackLength) <= 0.01 and lateralOffset.Magnitude <= 0.01,
	}
end

--// Позиции на RacePanel
function RaceModule.GetPanelPathUnits(stage, roadLevel)
	stage = clampStage(stage)
	roadLevel = clampRoadLevel(roadLevel)
	
	local stageParths = RaceModule.UI.RacePanel.StagePathUnits[stage]
	
	return stageParths[roadLevel]
end

function RaceModule.GetPanelPointByAlpha(stage, roadLevel, alpha)
	alpha = math.clamp(tonumber(alpha) or 0, 0, 1)
	
	local totalPathUnits =RaceModule.GetPanelPathUnits(stage, roadLevel)
	local currentPathUnits = totalPathUnits * alpha
	local lineIndex
	local lineProgress
	
	if currentPathUnits <= 1 then
		lineIndex = 1
		lineProgress = currentPathUnits
	elseif currentPathUnits <= 2 then
		lineIndex = 2
		lineProgress = currentPathUnits - 1
	else
		lineIndex = 3
		lineProgress = currentPathUnits - 2
	end
	
	return {
		LineIndex = lineIndex,
		LineName = "Line" .. tostring(lineIndex),
		
		Progress = math.clamp(lineProgress, 0, 1),
	}
end

function RaceModule.GetPlayerPanelPoint(stage, roadLevel, lapDistance)
	local trackDistance = RaceModule.GetTrackDistance(stage, roadLevel)
	local alpha = 0
	
	if trackDistance > 0 then
		alpha = math.clamp((tonumber(lapDistance) or 0) / trackDistance, 0, 1)
	end
	
	return RaceModule.GetPanelPointByAlpha(stage, roadLevel, alpha)
end

function RaceModule.GetRewardPanelPoint(stage, roadLevel, rewardIndex)
	local rewardCount = RaceModule.GetRewardCount(stage, roadLevel)
	
	rewardIndex = math.clamp(math.floor(tonumber(rewardIndex) or 1), 1, rewardCount)
	
	local alpha = rewardIndex / rewardCount
	
	return RaceModule.GetPanelPointByAlpha(stage, roadLevel, alpha)
end

--// Позиции RewardButton внутри RaceMeenu
function RaceModule.GetRewardBarPosition(stage, roadLevel, rewardIndex)
	local rewardCount = RaceModule.GetRewardCount(stage, roadLevel)
	
	rewardIndex = math.clamp(math.floor(tonumber(rewardIndex) or 1), 1, rewardCount)
	
	local alpha = rewardIndex / rewardCount
	
	return RaceModule.UI.RewardBar.LengthScale * alpha
end

--// Размеры полосок UI
function RaceModule.GetRoadLevelBarScale(roadLevel)
	roadLevel = clampRoadLevel(roadLevel)
	
	return RaceModule.UI.Bars.RoadLevelMaxScale * (roadLevel / RaceModule.Settings.MaxRoadLevel)
end

function RaceModule.GetStageLevelBarScale(stage)
	stage = clampStage(stage)
	
	return RaceModule.UI.Bars.StageLevelMaxScale * (stage / RaceModule.Settings.MaxStage)
end

function RaceModule.GetRewardLevelBarScale(stage, rewardLevel)
	local localLevel = RaceModule.GetLocalRewardLevel(stage, rewardLevel)
	
	return RaceModule.UI.Bars.RewardLevelMaxScale 
		* (localLevel / RaceModule.Settings.RewardLevelsPerStage)
end

function RaceModule.GetStageRequirementBarScale(progress)
	progress = math.clamp(tonumber(progress) or 0, 0, 1)
	
	return RaceModule.UI.Bars.StageRequirementMaxScale * progress
end

--// Расчет скорости
local function lerp(a, b, alpha)
	return a + (b - a) * alpha
end

function RaceModule.GetTargetSpeedFromEnergy(effectiveEnergy)
	effectiveEnergy = math.max(0, tonumber(effectiveEnergy) or 0)
	
	if effectiveEnergy <= 0 then
		return RaceModule.Settings.BaseSpeed
	end
	
	if effectiveEnergy < 1e6 then
		return lerp(16, 50, effectiveEnergy / 1e6)
	end
	
	if effectiveEnergy < 1e9 then
		return lerp(50, 100, (effectiveEnergy - 1e6) / (1e9 - 1e6))
	end
	
	if effectiveEnergy < 1e12 then
		return lerp(100, 200, (effectiveEnergy - 1e9) / (1e12 - 1e9))
	end
	
	if effectiveEnergy < 1e15 then
		return lerp(200, 400, (effectiveEnergy - 1e12) / (1e15 - 1e12))
	end
	
	return 400
end

function RaceModule.GetNextSpeed(currentSpeed, targetSpeed, deltaTime, accelerationMultiplier)
	currentSpeed = math.max(RaceModule.Settings.BaseSpeed, tonumber(currentSpeed) or RaceModule.Settings.BaseSpeed)
	targetSpeed = math.max(RaceModule.Settings.BaseSpeed, tonumber(targetSpeed) or RaceModule.Settings.BaseSpeed)
	deltaTime = math.max(0, tonumber(deltaTime) or 0)
	accelerationMultiplier = math.max(0, tonumber(accelerationMultiplier) or 1)
	
	local acceleration = RaceModule.Settings.BaseAccelerationPerSecond * accelerationMultiplier
	
	return math.min(currentSpeed + acceleration * deltaTime, targetSpeed)
end

--// Speedometer
function RaceModule.GetSpeedometerTicks(effectiveEnergy)
	effectiveEnergy = math.max(0, tonumber(effectiveEnergy) or 0)
	
	local tickCount = RaceModule.UI.Speedometer.TickCount
	local ticks = {}
	
	for tickIndex = 1, tickCount do
		ticks[tickIndex] = effectiveEnergy * tickIndex / tickCount
	end
	return ticks
end

function RaceModule.GetSpeedometerArrowRotation(currentSpeed, targetSpeed)
	currentSpeed = tonumber(currentSpeed) or RaceModule.Settings.BaseSpeed
	targetSpeed = tonumber(targetSpeed) or RaceModule.Settings.BaseSpeed
	
	local minRotation = RaceModule.UI.Speedometer.MinArrowRotation
	local maxRotation = RaceModule.UI.Speedometer.MaxArrowRotation
	
	if targetSpeed <= RaceModule.Settings.BaseSpeed then
		return minRotation
	end
	
	local alpha = math.clamp((currentSpeed - RaceModule.Settings.BaseSpeed) / (targetSpeed - RaceModule.Settings.BaseSpeed), 0, 1)
	
	return lerp(minRotation, maxRotation, alpha)
end

--// Формфтирование чисел
local suffixes = {
	{Value = 1e33, Suffix = "Dc"},
	{Value = 1e30, Suffix = "N"},
	{Value = 1e27, Suffix = "O"},
	{Value = 1e24, Suffix = "Sp"},
	{Value = 1e21, Suffix = "Sx"},
	{Value = 1e18, Suffix = "Qi"},
	{Value = 1e15, Suffix = "Q"},
	{Value = 1e12, Suffix = "T"},
	{Value = 1e9, Suffix = "B"},
	{Value = 1e6, Suffix = "M"},
	{Value = 1e3, Suffix = "K"},
}

function RaceModule.FormatNumber(number)
	number = tonumber(number) or 0
	
	local absoluteNumber = math.abs(number)
	
	if absoluteNumber < 1000 then
		if number % 1 == 0 then
			return tostring(math.floor(number))
		end
		
		return trimZeros(string.format("%.2f", number))
	end
	
	for _, suffixData in ipairs(suffixes) do
		if absoluteNumber >= suffixData.Value then
			local scaleNumber = number / suffixData.Value
			local absoluteScaled = math.abs(scaleNumber)
			local decimalPlaces 
			
			if absoluteScaled < 10 then
				decimalPlaces = 2
			elseif absoluteScaled < 100 then
				decimalPlaces = 1
			else
				decimalPlaces = 0
			end
			
			local formatted = trimZeros(string.format("%." .. decimalPlaces .. "f", scaleNumber))
			
			if absoluteScaled < 10 and not formatted:find("%.") then
				formatted ..= ".0"
			end
			
			return formatted .. suffixData.Suffix
		end
	end
	return tostring(math.floor(number))
end

function RaceModule.FormatDistance(distance)
	return RaceModule.FormatNumber(distance) .. "M"
end

function RaceModule.FormatMultiplier(multiplier)
	multiplier = tonumber(multiplier) or 1
	
	return "x" .. trimZeros(string.format("%.2f", multiplier))
end

function RaceModule.FormatPercent(decimalValue)
	decimalValue = tonumber(decimalValue) or 0
	
	local percent = decimalValue * 100
	
	return trimZeros(string.format("%.1f", percent))
end

function RaceModule.FormatTime(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	
	local minutes = math.floor(seconds / 60)
	local reminingSeconds = seconds % 60
	
	return string.format("%d:%02d", minutes, reminingSeconds)
end

return RaceModule
