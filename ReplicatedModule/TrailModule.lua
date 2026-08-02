local TrailModule = {}

--// CONSTANTS
TrailModule.MAX_TRAILS_PER_ERA = 3
TrailModule.MIN_LEVEL = 0
TrailModule.MAX_LEVEL = 25

TrailModule.DEFAULT_TRAIL_ID = "TrailStone"

--// SHARED ICONS
TrailModule.Icons = {
	TrailList = {
		Selected = "rbxassetid://83651888385417",
		Default = "rbxassetid://90815160752499",
	},
	
	Equipped = {
		Selected = "rbxassetid://130606674129045",
		Default = "rbxassetid://91644446213802",
	},
	
	Stages = {
		[1] = "rbxassetid://105234933061667",
		[2] = "rbxassetid://129346516632269",
		[3] = "rbxassetid://130513411629121",
		[4] = "rbxassetid://107984855399889",
		[5] = "rbxassetid://73158660699565",
	},
	
	Currencies = {
		Money = "rbxassetid://",
		Rebirth = "rbxassetid://",
		XP = "rbxassetid://84764867479981",
		SrRobux = "rbxassetid://",
	},
}

--// STAGE DEFINITIONS
TrailModule.Stages = {
	[1] = {
		Id = 1,
		Name = "SPARK",
		
		MinLevel = 0,
		MaxLevel = 5,
		
		Multiplier = 1.0,
	},
	
	[2] = {
		Id = 2,
		Name = "FLOW",
		
		MinLevel = 6,
		MaxLevel = 10,
		
		Multiplier = 1.15,
	},
	
	[3] = {
		Id = 3,
		Name = "SURGE",
		
		MinLevel = 11,
		MaxLevel = 15,
		
		Multiplier = 1.30,
	},
	
	[4] = {
		Id = 4,
		Name = "HYPER",
		
		MinLevel = 16,
		MaxLevel = 20,
		
		Multiplier = 1.50,
	},
	
	[5] = {
		Id = 5,
		Name = "ASCENDED",
		
		MinLevel = 21,
		MaxLevel = 25,
		
		Multiplier = 1.75,
	},
}

--// TRAIL CONFIGURATION
TrailModule.Trails = {
	TrailStone = {
		Id = "TrailStone",
		
		Order = 1,
		Era = 1,
		Location = 1,
		
		Enabled = true,
		
		DisplayName = "STONE TRAIL",
		
		Description = "",
		
		Icon = "",
		
		Preview = {
			ModelName = "TrailStone",
			StyleId = "TrailStone",
		},
		
		Purchase = {
			Currency = "Money",
			Price = 100,
		},
		
		Boosts = {
			BasePowerPercent = 5,
			BaseAccelerationPercent = 3,
			
			PowerPercentPerLevel = 1,
			AccelerationPercentPerLevel = 0.5,
		},
		
		LevelCostRanges = {
			{
				FromLevel = 1,
				ToLevel = 5,
				
				StartPrice = 50,
				EndPrice = 250,
				
				StartXP = 5,
				EndXP = 25,
				
				Curve = 1,
				RoundTo = 1,
			},
			{
				FromLevel = 6,
				ToLevel = 10,

				StartPrice = 300,
				EndPrice = 600,

				StartXP = 30,
				EndXP = 100,

				Curve = 1,
				RoundTo = 5,
			},
			{
				FromLevel = 11,
				ToLevel = 15,

				StartPrice = 750,
				EndPrice = 1500,

				StartXP = 125,
				EndXP = 200,

				Curve = 1.10,
				RoundTo = 10,
			},
			{
				FromLevel = 16,
				ToLevel = 20,

				StartPrice = 1750,
				EndPrice = 2250,

				StartXP = 250,
				EndXP = 400,

				Curve = 1.15,
				RoundTo = 50,
			},
			{
				FromLevel = 21,
				ToLevel = 25,

				StartPrice = 3000,
				EndPrice = 5500,

				StartXP = 500,
				EndXP = 750,

				Curve = 1.20,
				RoundTo = 100,
			},
		},
		
		StageRequirements = {
			[1] = {
				Level = 5,
				Money = 500,
				Rebirth = 100,
				
				SpendMoney = true,
				SpendRebirth = true,
			},
			
			[2] = {
				Level = 10,
				Money = 1000,
				Rebirth = 250,
				
				SpendMoney = true,
				SpendRebirth = true,
			},
			
			[3] = {
				Level = 15,
				Money = 2500,
				Rebirth = 500,
				
				SpendMoney = true,
				SpendRebirth = true,
			},
			
			[4] = {
				Level = 20,
				Money = 5000,
				Rebirth = 100,
				
				SpendMoney = true,
				SpendRebirth = true,
			},
		},
	},
}

--// HELPERS
local function roundToStep(value, step)
	step = tonumber(step) or 1
	
	
	if step <= 0 then 
		step = 1
	end
	return math.floor((value / step) + 0.5) * step
end


local function interpolateRange(startValue, endValue, alpha, curve)
	startValue = tonumber(startValue) or 0
	endValue = tonumber(endValue) or startValue
	alpha = math.clamp(alpha, 0, 1)
	curve = tonumber(curve) or 1
	
	if curve <= 0 then
		curve = 1
	end
	
	local curveAlpha = alpha ^ curve
	
	return startValue + ((endValue - startValue) * curveAlpha)
end

local function getRangeAlpha(level, fromLevel, toLevel)
	if toLevel <= fromLevel then
		return 0
	end
	
	return math.clamp((level - fromLevel) / (toLevel - fromLevel), 0, 1)
end

local function getLevelRange(trailConfig, targetLevel)
	for _, range in ipairs(trailConfig.LevelCostRanges or {}) do
		if targetLevel >= range.FromLevel and targetLevel <= range.ToLevel then
			return range
		end
	end
	return nil
end

--// CONFIG GETTERS
function TrailModule.GetTrailConfig(trailId)
	if type(trailId) ~= "string" then
		return nil
	end
	
	return TrailModule.Trails[trailId]
end

function TrailModule.GetStageConfig(stageId)
	stageId = tonumber(stageId)
	
	if not stageId then
		return nil
	end
	
	return TrailModule.Stages[stageId]
end

function TrailModule.GetStageName(stageId)
	local stageConfig = TrailModule.GetStageConfig(stageId)
	
	if not stageConfig then
		return "UNKNOWN"
	end
	
	return stageConfig.Name
end

function TrailModule.GetStageIcon(stageId)
	return TrailModule.Icons.Stages[stageId] or ""
end

function TrailModule.GetMaxStage()
	return #TrailModule.Stages
end

function TrailModule.IsMaxStage(stageId)
	stageId = tonumber(stageId) or 1
	
	return stageId >= TrailModule.GetMaxStage()
end

function TrailModule.GetNextStage(stageId)
	if TrailModule.IsMaxStage(stageId) then
		return nil
	end
	
	return TrailModule.GetStageConfig(stageId + 1)
end

--// TRAIL LISTS
function TrailModule.GetTrailsForEra(eraId)
	local result = {}
	
	for trailId, config in pairs(TrailModule.Trails) do
		if config.Enabled and config.Era == eraId then
			table.insert(result, {
				TrailId = trailId,
				Order = config.Order,
				Location = config.Location,
			})
		end
	end
	
	table.sort(result , function(a, b)
		return a.Order < b.Order
	end)
	return result
end

function TrailModule.GetTrailForLocation(eraId, locationId)
	for trailId, config in pairs(TrailModule.Trails) do
		if config.Enabled and config.Era == eraId and config.Location == locationId then
			return trailId
		end
	end
	return nil
end

function TrailModule.GetTrailOrder(trailId)
	local config = TrailModule.GetTrailConfig(trailId)
	
	if not config then 
		return nil
	end
	
	return config.Order
end

--// LEVEL FUNCTIONS
function TrailModule.GetStageMaxLevel(stageId)
	local stageConfig = TrailModule.GetStageConfig(stageId)
	
	if not stageConfig then 
		return 0
	end
	
	return stageConfig.MaxLevel
end

function TrailModule.CanLevelUpAtStage(level, stageId)
	level = tonumber(level) or 0
	
	local stageConfig = TrailModule.GetStageConfig(stageId)
	
	if not stageConfig then 
		return false
	end
	
	if level >= TrailModule.MAX_LEVEL then
		return false
	end
	
	return level < stageConfig.MaxLevel
end

function TrailModule.GetNextLevel(level)
	level = math.max(tonumber(level) or 0, 0)
	
	if level >= TrailModule.MAX_LEVEL then
		return nil
	end
	
	return level + 1
end

function TrailModule.GetLevelUpgradeCost(trailId, currentLevel)
	local config = TrailModule.GetTrailConfig(trailId)
	
	
	if not config then 
		return nil
	end
	
	currentLevel = math.max(tonumber(currentLevel) or 0, 0)
	
	local targetLevel = TrailModule.GetNextLevel(currentLevel)
	
	if not targetLevel then 
		return nil
	end
	
	local range = getLevelRange(config, targetLevel)
	
	if not range then 
		warn("TrailModule: для трейла", trailId, "Не найден диапазон цены уровня", targetLevel)
		return nil
	end
	
	local alpha = getRangeAlpha(targetLevel, range.FromLevel, range.ToLevel)
	local rawMoney = interpolateRange(range.StartPrice, range.EndPrice, alpha, range.Curve)
	local rawXP = interpolateRange(range.StartXP, range.EndXP, alpha, range.Curve)
	local moneyCost = roundToStep(rawMoney, range.RoundTo)
	local xpCost = roundToStep(rawXP, range.RoundXPTo or 1)
	
	return {
		CurrentLevel = currentLevel,
		TargetLevel = targetLevel,
		
		Money = math.max(moneyCost, 0),
		XP = math.max(xpCost, 0),
	}
end

--// STAGE FUNCTIONS
function TrailModule.GetStageRequirements(trailId, currentStage)
	local config = TrailModule.GetTrailConfig(trailId)
	
	if not config then 
		return nil
	end
	
	currentStage = tonumber(currentStage) or 1
	
	if TrailModule.IsMaxStage(currentStage) then
		return nil
	end
	
	local requirements = config.StageRequirements[currentStage]
	
	if not requirements then
		warn("TrailModule: для трейла", trailId, "Не найдены требования стадии", currentStage)
		return nil
	end
	return requirements
end

function TrailModule.GetStageProgress(trailId, currentStage, level, money, rebirth)
	local requirements = TrailModule.GetStageRequirements(trailId, currentStage)
	
	if not requirements then
		return nil
	end
	
	level = math.max(tonumber(level) or 0, 0)
	money = math.max(tonumber(money) or 0, 0)
	rebirth = math.max(tonumber(rebirth) or 0, 0)
	
	local requiredLevel = requirements.Level or 0
	local requiredMoney = requirements.Money or 0
	local requiredRebirth = requirements.Rebirth or 0
	
	local levelProgress = requiredLevel > 0 and math.clamp(level / requiredLevel, 0, 1) or 1
	local moneyProgress = requiredMoney > 0 and math.clamp(money / requiredMoney, 0, 1) or 1
	local rebirthProgress = requiredRebirth > 0 and math.clamp(rebirth / requiredRebirth, 0, 1) or 1
	
	return {
		Level = {
			Current = level,
			Required = requiredLevel,
			Progress = levelProgress,
			Missing = math.max(requiredLevel - level, 0),
			Completed = level >= requiredLevel,
		},
		
		Money = {
			Current = money,
			Required = requiredMoney,
			Progress = moneyProgress,
			Missing = math.max(requiredMoney - money, 0),
			Completed = money >= requiredMoney,
		},
		
		Rebirth = {
			Current = rebirth,
			Required = requiredRebirth,
			Progress = rebirthProgress,
			Missing = math.max(requiredRebirth - rebirth, 0),
			Completed = rebirth >= requiredRebirth,
		},
		
		CanStageUp = level >= requiredLevel and money >= requiredMoney and rebirth >= requiredRebirth,
	}
end

--// BOOST CALCULATIONS
function TrailModule.GetBoostData(trailId, level, stageId)
	local config = TrailModule.GetTrailConfig(trailId)
	
	if not config then
		return {
			PowerPercent = 0,
			AccelerationPercent = 0,
			
			PowerMultiplier = 1,
			AccelerationMultiplier = 1,
			
			StageMultiplier = 1,
		}
	end
	
	level = math.clamp(tonumber(level) or 0, TrailModule.MIN_LEVEL, TrailModule.MAX_LEVEL)
	
	stageId = tonumber(stageId) or 1
	
	
	local stageConfig = TrailModule.GetStageConfig(stageId) or TrailModule.Stages[1]
	
	local boostConfig = config.Boosts or {}
	
	local rawPowerPercent = (boostConfig.BasePowerPercent or 0) + (level * (boostConfig.PowerPercentPerLevel or 0))
	local rawAccelerationPercent = (boostConfig.BaseAccelerationPercent or 0) + (level * (boostConfig.AccelerationPercentPerLevel or 0))
	
	local stageMultiplier = stageConfig.Multiplier or 1
	local finalPowerPercent = rawPowerPercent * stageMultiplier
	local finalAccelerationPercent = rawAccelerationPercent * stageMultiplier
	
	return {
		PowerPercent = finalPowerPercent,
		AccelerationPercent = finalAccelerationPercent,
		
		PowerMultiplier = 1 + (finalPowerPercent / 100),
		AccelerationMultiplier = 1 + (finalAccelerationPercent / 100),
		
		StageMultiplier = stageMultiplier,
	}
end

function TrailModule.GetRacePowerMultiplier(trailId, level, stageId)
	local data = TrailModule.GetBoostData(trailId, level, stageId)
	
	return data.PowerMultiplier
end

function TrailModule.GetAccelerationMultiplier(trailId, level, stageId)
	local data = TrailModule.GetBoostData(trailId, level, stageId)
	
	return data.AccelerationMultiplier
end

--// DISPLAY HELPERS
function TrailModule.FormatPercent(value)
	value = tonumber(value) or 0
	
	local rounded = math.floor((value * 10) + 0.5) / 10
	
	if rounded % 1 == 0 then 
		return string.format("+%d%%", rounded)
	end
	return string.format("+%.1f%%", rounded)
end

function TrailModule.FormatMultiplier(value)
	value = tonumber(value) or 1
	
	local rounded = math.floor((value * 100) + 0.5) / 100
	
	if rounded % 1 == 0 then 
		return string.format("%.0fx", rounded)
	end
	return string.format("%.2fx", rounded)
end

--// CONFIG VALIDATION
function TrailModule.ValidateConfiguration()
	local usedEraLocations = {}
	
	for trailId, config in pairs(TrailModule.Trails) do
		assert(config.Id == trailId, "TrailModule: id трейла не совпадает с ключом:" .. trailId)
		assert(type(config.Order) == "number", "TrailModule: отсутствует Order у " .. trailId)
		assert(type(config.Era) == "number", "TrailModule: отсутствует Era у " .. trailId)
		assert(type(config.Location) == "number", "TrailModule:  отсутствует Location у" .. trailId)
		
		local eraLocationKey = tostring(config.Era) .. ":" .. tostring(config.Location)
		
		assert(not usedEraLocations[eraLocationKey], "TrailModule: два трейла назначены одной локации : " .. eraLocationKey)
		
		usedEraLocations[eraLocationKey] = trailId
		
		for level = 1, TrailModule.MAX_LEVEL do
			assert(getLevelRange(config, level) ~= nil, string.format("TrailModule: у %s отсутствует цена для Level %d", trailId, level))
		end
		
		for stageId = 1, TrailModule.GetMaxStage() - 1 do
			assert(config.StageRequirements[stageId] ~= nil, string.format("TrailModule: у %s отсутствует требования Stage %d", trailId, stageId))
		end
	end
	return true
end

TrailModule.ValidateConfiguration()

return TrailModule
