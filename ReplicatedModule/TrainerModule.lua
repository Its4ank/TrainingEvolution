local TrainerModule = {}

TrainerModule.Data = {
	TestTrainer = {
		DisplayName = "Test Trainer",
		ModelName = "TestTrainer",
		Enabled = false,
		
		Specialist = "Test Master",
		SpecialistIcon = "",
		
		LeaderStatName = "Energy",
		LeaderStatIcon = "",
		
		UnlockType = "None",
		Currency = "None",
		Price = 0,
		
		MaxLevel = 25,
		MaxEvolution = 10,
	},
	
	JoeTrainer = {
		DisplayName = "Joe Trainer",
		ModelName = "JoeTrainer",
		Enabled = true,
		
		Specialist = "Power/Acc Master",
		SpecialistIcon = "rbxassetid://84748246477718",
		
		LeaderStatName = "Rebirth",
		LeaderStatIcon = "rbxassetid://91670074635222",
		
		UnlockType = "Currency",
		Currency = "Rebirth",
		Price = 15,
		
		MaxLevel = 25,
		MaxEvolution = 10,
	},
	
	MonikaTrainer = {
		DisplayName = "Monika Trainer",
		ModelName = "MonikaTrainer",
		Enabled = true,
		
		Specialist = "Ledy Luck",
		SpecialistIcon = "rbxassetid://84934349596853",
		
		LeaderStatName = "EggHatched",
		LeaderStatIcon = "rbxassetid://73197884503844",
		
		UnlockType = "EggHatched",
		RequiredPets = 50,
		AutoUnlock = true,
		
		MaxLevel = 25,
		MaxEvolution = 10,
	},
	
	LedyTrainer = {
		DisplayName = "Ledy Trainer",
		ModelName = "LedyTrainer",
		Enabled = true,
		
		Specialist = "Energy Master",
		SpecialistIcon = "rbxassetid://97563972013859",
		
		LeaderStatName = "Energy",
		LeaderStatIcon = "rbxassetid://74509086636062",
		
		UnlockType = "Currency",
		Currency = "Energy",
		Price = 1000,
		
		MaxLevel = 25,
		MaxEvolution = 10,
	},
	
	BellaTrainer = {
		DisplayName = "Bella Trainer",
		ModelName = "BellaTrainer",
		Enabled = true,
		
		Specialist = "Money Master",
		SpecialistIcon = "rbxassetid://106068703860201",
		
		LeaderStatName = "Money",
		LeaderStatIcon = "rbxassetid://123691959584167",
		
		UnlockType = "Currency",
		Currency = "Money",
		Price = 500,
		
		MaxLevel = 25,
		MaxEvolution = 10,
	},
}

TrainerModule.LevelBoost = {
	LedyTrainer = {
		{FromLevel = 1, ToLevel = 5, StartEnergy = 20, EndEnergy = 24,},
		{FromLevel = 6, ToLevel = 10, StartEnergy = 26, EndEnergy = 32,},
		{FromLevel = 11, ToLevel = 15, StartEnergy = 34, EndEnergy = 42,},
		{FromLevel = 16, ToLevel = 20, StartEnergy = 44, EndEnergy = 52,},
		{FromLevel = 21, ToLevel = 25, StartEnergy = 54, EndEnergy = 62,},
	},
	
	BellaTrainer = {
		{FromLevel = 1, ToLevel = 5, StartMoney = 20, EndMode = 24,},
		{FromLevel = 6, ToLevel = 10, StartMoney = 26, EndMode = 32,},
		{FromLevel = 11, ToLevel = 15, StartMoney = 34, EndMode = 42,},
		{FromLevel = 16, ToLevel = 20, StartMoney = 44, EndMode = 52,},
		{FromLevel = 21, ToLevel = 25, StartMoney = 54, EndMode = 62,},
	},
	
	JoeTrainer = {
		{FromLevel = 1, ToLevel = 5, StartRacePower = 15, EndRacePower = 18, StartAcceleration = 15, EndAcceleration = 18,},
		{FromLevel = 6, ToLevel = 10, StartRacePower = 19, EndRacePower = 23, StartAcceleration = 19, EndAcceleration = 23,},
		{FromLevel = 11, ToLevel = 15, StartRacePower = 24.5, EndRacePower = 30.5, StartAcceleration = 24.5, EndAcceleration = 30.5,},
		{FromLevel = 16, ToLevel = 20, StartRacePower = 32, EndRacePower = 38, StartAcceleration = 32, EndAcceleration = 38,},
		{FromLevel = 21, ToLevel = 25, StartRacePower = 39.5, EndRacePower = 45.5, StartAcceleration = 39.5, EndAcceleration = 45.5,},
	},
	
	MonikaTrainer = {
		{FromLevel = 1, ToLevel = 5, StartPetLuck = 20, EndPetLuck = 24, StartRaceXP = 15, EndRaceXP = 18},
		{FromLevel = 6, ToLevel = 10, StartPetLuck = 26, EndPetLuck = 32, StartRaceXP = 19, EndRaceXP = 23,},
		{FromLevel = 11, ToLevel = 15, StartPetLuck = 34, EndPetLuck = 42, StartRaceXP = 24.5, EndRaceXP = 30.5,},
		{FromLevel = 16, ToLevel = 20, StartPetLuck = 44, EndPetLuck = 52, StartRaceXP = 32, EndRaceXP = 38,},
		{FromLevel = 21, ToLevel = 25, StartPetLuck = 54, EndPetLuck = 62, StartRaceXP = 39.5, EndRaceXP = 45.5,},
	}
}

TrainerModule.Stage = {
	[1] = {
		Name = "Rookie",
		MaxLevel = 5,
		Multiplier = 1.0,
	},
	
	[2] = {
		Name = "Athlete",
		MaxLevel = 10,
		Multiplier = 1.1,
	},
	
	[3] = {
		Name = "Champion",
		MaxLevel = 15,
		Multiplier = 1.2,
	},
	
	[4] = {
		Name = "Titan",
		MaxLevel = 20,
		Multiplier = 1.3,
	},
	
	[5] = {
		Name = "Mythic",
		MaxLevel = 25,
		Multiplier = 1.4,
	},
}

TrainerModule.LevelCostRanges = {
	{
		FromLevel = 1,
		ToLevel = 5,

		StartPrice = 15,
		EndPrice = 75,

		StartXP = 2,
		EndXP = 10,

		Curve = 1,
		RoundTo = 1,
	},

	{
		FromLevel = 6,
		ToLevel = 10,

		StartPrice = 100,
		EndPrice = 220,

		StartXP = 12,
		EndXP = 28,

		Curve = 1,
		RoundTo = 1,
	},

	{
		FromLevel = 11,
		ToLevel = 15,

		StartPrice = 280,
		EndPrice = 560,

		StartXP = 36,
		EndXP = 68,

		Curve = 1,
		RoundTo = 1,
	},

	{
		FromLevel = 16,
		ToLevel = 20,

		StartPrice = 700,
		EndPrice = 1100,

		StartXP = 80,
		EndXP = 120,

		Curve = 1,
		RoundTo = 1,
	},

	{
		FromLevel = 21,
		ToLevel = 24,

		StartPrice = 1300,
		EndPrice = 1900,

		StartXP = 140,
		EndXP = 200,

		Curve = 1,
		RoundTo = 1,
	},
}

TrainerModule.StageStarIcons = { 
	Active = "rbxassetid://117035434388256",
	Inactive = "rbxassetid://105741165654536",
}

TrainerModule.RequirementIcons = { 
	Level = "rbxassetid://139561962294465",
	
	Energy = "rbxassetid://74509086636062",
	Money = "rbxassetid://123691959584167",
	Rebirth = "rbxassetid://91670074635222",
	
	TrainerTreadmillTime = "rbxassetid://104625083427194",
	EggHatched = "rbxassetid://73197884503844",
	PetRarity = "rbxassetid://100104272754861",
	RaceTouch = "rbxassetid://96359633366140",
}

TrainerModule.RequirementDisplayNames = { 
	Level = "LEVEL",
	
	Energy = "ENERGY",
	Money = "MONEY",
	Rebirth = "REBIRTH",
	
	TrainerTreadmillTime = "TREADMILL TIME",
	EggHatched = "EGGS HATCHED",
	PetRarity = "PET RARITY",
	RaceTouch = "RACE REWARDS",
}

TrainerModule.ProgressValues = { 
	LedyTrainer = { 
		Energy = "NumberValue",
		TrainerTreadmillTime = "NumberValue",
	},
	
	BellaTrainer = { 
		Money = "NumberValue",
		TrainerTreadmillTime = "NumberValue",
	},
	
	MonikaTrainer = { 
		EggHatched = "IntValue",
		PetRarity = "IntValue",
	},
	
	JoeTrainer = { 
		Rebirth = "IntValue",
		RaceTouch = "NumberValue",
	},
}

TrainerModule.StageRequirements = {
	LedyTrainer = {
		[1] = {
			{Type = "Level", Need = 5,},
			{Type = "Energy", Need = 500, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 90, ResetOnRankUp = true,},
		},
		
		[2] = {
			{Type = "Level", Need = 10,},
			{Type = "Energy", Need = 2500, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 150, ResetOnRankUp = true,},
		},
		
		[3] = {
			{Type = "Level", Need = 15,},
			{Type = "Energy", Need = 10000, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 240, ResetOnRankUp = true,},
		},
		
		[4] = {
			{Type = "Level", Need = 20,},
			{Type = "Energy", Need = 30000, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 360, ResetOnRankUp = true,},
		},
	},
	
	BellaTrainer = {
		[1] = {
			{Type = "Level", Need = 5,},
			{Type = "Money", Need = 250, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 60, ResetOnRankUp = true,},
		},
		[2] = {
			{Type = "Level", Need = 10,},
			{Type = "Money", Need = 1000, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 120, ResetOnRankUp = true,},
		},
		[3] = {
			{Type = "Level", Need = 15,},
			{Type = "Money", Need = 3500, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 180, ResetOnRankUp = true,},
		},
		[4] = {
			{Type = "Level", Need = 20,},
			{Type = "Money", Need = 9000, Spend = true, ResetOnRankUp = true,},
			{Type = "TrainerTreadmillTime", Need = 240, ResetOnRankUp = true,},
		},
	},
	
	MonikaTrainer = {
		[1] = {
			{Type = "Level", Need = 5,},
			{Type = "EggHatched", Need = 15, ResetOnRankUp = true,},
			{Type = "PetRarity", Rarity = "Rare", Need = 3, ResetOnRankUp = true,},
		},
		[2] = {
			{Type = "Level", Need = 10,},
			{Type = "EggHatched", Need = 25, ResetOnRankUp = true,},
			{Type = "PetRarity", Rarity = "Epic", Need = 3, ResetOnRankUp = true,},
		},
		[3] = {
			{Type = "Level", Need = 15,},
			{Type = "EggHatched", Need = 40, ResetOnRankUp = true,},
			{Type = "PetRarity", Rarity = "Epic", Need = 5, ResetOnRankUp = true,},
		},
		[4] = {
			{Type = "Level", Need = 20,},
			{Type = "EggHatched", Need = 60, ResetOnRankUp = true,},
			{Type = "PetRarity", Rarity = "Legendary", Need = 2,ResetOnRankUp = true,},
		},
	},
	
	JoeTrainer = {
		[1] = {
			{Type = "Level", Need = 5,},
			{Type = "Rebirth", Need = 10, Spend = true, ResetOnRankUp = true,},
			{Type = "RaceTouch", Need = 15, Spend = true, ResetOnRankUp = true,},
		},
		[2] = {
			{Type = "Level", Need = 10,},
			{Type = "Rebirth", Need = 25, Spend = true, ResetOnRankUp = true,},
			{Type = "RaceTouch", Need = 40, Spen = true, ResetOnRankUp = true,},
		},	
		[3] = {
			{Type = "Level", Need = 15,},
			{Type = "Rebirth", Need = 50, Spend = true, ResetOnRankUp = true,},
			{Type = "RaceTouch", Need = 100, Spen = true, ResetOnRankUp = true,},
		},
		[4] = {
			{Type = "Level", Need = 20,},
			{Type = "Rebirth", Need = 90, Spend = true, ResetOnRankUp = true,},
			{Type = "RaceTouch", Need = 250, Spent = true, ResetOnRankUp = true,},
		},
	},
}

local function roundToStep(value, step)
	step = tonumber(step) or 1

	if step <= 1 then
		return math.floor(value + 0.5)
	end

	return math.floor(
		(value / step) + 0.5
	) * step
end

function TrainerModule.getLevelCostRange(level)
	level = math.floor(tonumber(level) or 1)
	
	for _, range in ipairs(TrainerModule.LevelCostRanges) do
		if level >= range.FromLevel and level <= range.ToLevel then
			return range
		end
	end
	
	return nil
end

function TrainerModule.getLevelCost(level)
	level = math.floor(tonumber(level) or 1)
	
	local range = TrainerModule.getLevelCostRange(level)
	
	if not range then
		return nil
	end
	
	local levelCount = math.max(1, range.ToLevel - range.FromLevel)
	local alpha = (level - range.FromLevel) / levelCount
	alpha = math.clamp(alpha, 0, 1)
	
	local curve = tonumber(range.Curve) or 1
	local curveAlpha = alpha ^ curve
	local moneyCost = range.StartPrice + (range.EndPrice - range.StartPrice) * curveAlpha
	local xpCost = range.StartXP + (range.EndXP - range.StartXP) * curveAlpha
	local roundStep = tonumber(range.RoundTo) or 1
	
	return {
		Money = roundToStep(moneyCost, roundStep),
		XP = roundToStep(xpCost, roundStep),
	}
end

function TrainerModule.getTrainerData(trainerName)
	return TrainerModule.Data[trainerName]
end

function TrainerModule.getStageRequirements(trainerName, stageValue)
	local trainerRequirements = TrainerModule.StageRequirements[trainerName]
	
	if not trainerRequirements then
		return {}
	end
	
	local stageNumber = tonumber(stageValue) or 1
	
	return trainerRequirements[stageNumber] or {}
end

function TrainerModule.getStageRequirementByIndex( 
	trainerName,
	stageValue,
	requirementIndex
)
	local requirements = TrainerModule.getStageRequirements( 
		trainerName,
		stageValue
	)
	
	return requirements[requirementIndex]
end

function TrainerModule.getRequirementDisplayName(requirementType)
	return TrainerModule.RequirementDisplayNames[requirementType]
	    or tostring(requirementType)
end

function TrainerModule.getRequirementIcon(requirementType)
	return TrainerModule.RequirementIcons[requirementType] or ""
end

function TrainerModule.getStageData(stageValue)
	local stageNumber = tonumber(stageValue) or 1
	return TrainerModule.Stage[stageNumber]
		or TrainerModule.Stage[1]
end

function TrainerModule.getStageName(stageValue)
	return TrainerModule.getStageData(stageValue).Name
end

function TrainerModule.getStageMaxLevel(stageValue)
	return TrainerModule.getStageData(stageValue).MaxLevel
end

function TrainerModule.getStageMultiplier(stageValue)
	return TrainerModule.getStageData(stageValue).Multiplier
end

function TrainerModule.getNextStageData(stageValue)
	local currentStage = tonumber(stageValue) or 1
	local nextStage = math.clamp(currentStage + 1, 1, 5)
	
	return TrainerModule.getStageData(nextStage)
end

local function getTrainerFolder(player)
	return player:FindFirstChild("Trainer")
end

function TrainerModule.getTrainerPlayerFolder(player, trainerName)
	local trainerFolder = getTrainerFolder(player)
	
	if not trainerFolder then 
		return nil
	end
	
	return trainerFolder:FindFirstChild(trainerName)
end

function TrainerModule.getRequirementProgressFolder(player, trainerName)
	local trainerFolder = TrainerModule.getTrainerPlayerFolder(player, trainerName)
	
	if not trainerFolder then 
		return nil
	end
	
	return trainerFolder:FindFirstChild("RequirementProgress")
end

function TrainerModule.getRequirementProgressValue(
	player,
	trainerName,
	requirementType
)
	local progressFolder = TrainerModule.getRequirementProgressFolder(player, trainerName)
	
	if not progressFolder then
		return nil
	end
	
	return progressFolder:FindFirstChild(requirementType)
end

function TrainerModule.getRequirementProgress(player, trainerName, requirementType)
	if requirementType == "Level" then
		local trainerFolder = TrainerModule.getTrainerPlayerFolder(
			player,
			trainerName
		)
		
		local level = trainerFolder
			and trainerFolder:FindFirstChild("Level")
		
		return level and level.Value or 0
	end
	
	local progressValue = TrainerModule.getRequirementProgressValue(player, trainerName, requirementType)
	
	return progressValue and progressValue.Value or 0
end

function TrainerModule.addRequirementProgress(
	player,
	trainerName,
	requirementType,
	amount
)
	amount = tonumber(amount) or 0
	
	if amount <= 0 then
		return false
	end
	
	if not TrainerModule.isTrainerEquipped(player, trainerName) then
		return false
	end
	
	local requirement = TrainerModule.getCurrentRequirement( 
		player,
		trainerName,
		requirementType
	)
	if not requirement then
		return false
	end
	
	local progressValue = TrainerModule.getRequirementProgressValue(
		player,
		trainerName,
		requirementType
	)
	
	if not progressValue then
		return false
	end
	
	local maximum = requirement and requirement.Need
	
	if maximum and maximum > 0 then 
		progressValue.Value = math.min( 
			progressValue.Value + amount,
			maximum
		)
	else 
		progressValue.Value += amount
	end
	
	return true
end

function TrainerModule.addEquippedTrainerProgress(player, requirementType, amount)
	local trainerName = TrainerModule.getEquippedTrainerName(player)
	
	if not trainerName then
		return false
	end
	
	return TrainerModule.addRequirementProgress(
		player,
		trainerName,
		requirementType,
		amount
	)
end

function TrainerModule.isCurrentStageRequirement(
	player,
	trainerName,
	requirementType
)
	local trainerFolder = TrainerModule.getTrainerPlayerFolder( 
		player,
		trainerName
	)
	
	if not trainerFolder then
		return false
	end
	
	local stageValue = trainerFolder:FindFirstChild("Stage")
	local currentStage = stageValue and stageValue.Value or 1
	
	local requirements = TrainerModule.getStageRequirements(trainerName, currentStage)
	
	for _, requirement in ipairs(requirements) do
		if requirement.Type == requirementType then
			return true
		end
	end
	
	return false
end

function TrainerModule.getCurrentRequirement(player, trainerName, requirementType)
	local trainerFolder = TrainerModule.getTrainerPlayerFolder( 
		player,
		trainerName
	)
	
	if not trainerFolder then
		return nil
	end
	
	local stageValue = trainerFolder:FindFirstChild("Stage")
	local currentStage = stageValue and stageValue.Value or 1
	
	local requirements = TrainerModule.getStageRequirements(trainerName, currentStage) 
	
	for _, requirement in ipairs(requirements) do
		if requirement.Type == requirementType then
			return requirement
		end
	end
	return nil
end

function TrainerModule.resetRequirementProgress( 
	player,
	trainerName,
	requirementType
)
	local progressValue = TrainerModule.getRequirementProgressValue( 
		player,
		trainerName,
		requirementType
	)
	
	if not progressValue then 
		return false
	end
	
	progressValue.Value = 0
	
	return true
end

function TrainerModule.resetCurrentStageProgress(player, trainerName, stageValue)
	local requirements = TrainerModule.getStageRequirements(trainerName, stageValue)
	
	for _, requirement in ipairs(requirements) do 
		if requirement.ResetOnRankUp == true then 
			TrainerModule.resetRequirementProgress( 
				player,
				trainerName,
				requirement.Type
			)
		end
	end
	return true
end

function TrainerModule.getEquippedTrainerName(player)
	local trainerFolder = getTrainerFolder(player)
	
	if not trainerFolder then
		return nil
	end
	
	for _, trainer in ipairs(trainerFolder:GetChildren()) do
		local equipped = trainer:FindFirstChild("Equipped")
		
		if equipped and equipped.Value == true then
			return trainer.Name
		end
	end
	return nil
end

function TrainerModule.getEquippedTrainerData(player)
	local trainerName = TrainerModule.getEquippedTrainerName(player)
	
	if not trainerName then
		return nil
	end
	
	return TrainerModule.Data[trainerName]
end

function TrainerModule.isTrainerEquipped(player, trainerName)
	return TrainerModule.getEquippedTrainerName(player) == trainerName
end

local TRAINER_BOOST_STATS = {
	"Energy",
	"Money",
	"PetLuck",
	"RacePower",
	"Acceleration",
	"RaceXP",
}

local TRAINER_MULTIPLIER_STATS = {
	EnergyMultiplier = "Energy",
	MoneyMultiplier = "Money",
	PetLuckMultiplier = "PetLuck",
	RacePowerMultiplier = "RacePower",
	AccelerationMultiplier = "Acceleration",
	RaceXPMultiplier = "RaceXP",
}

function TrainerModule.getBaseBoost(trainerName, level)
	local boosts = {}
	
	for _, statName in ipairs(TRAINER_BOOST_STATS) do
		boosts[statName] = 0
	end
	
	local data = TrainerModule.Data[trainerName]
	local ranges = TrainerModule.LevelBoost[trainerName]
	
	if not data or not ranges then return boosts end
	
	level = math.clamp(math.floor(tonumber(level) or 1), 1, data.MaxLevel or 25)
	
	for _, range in ipairs(ranges) do
		if level >= range.FromLevel and level <= range.ToLevel then
			local span = range.ToLevel - range.FromLevel
			local alpha = 0
			
			if span > 0 then
				alpha = (level - range.FromLevel) / span 
			end
			
			for _, statName in ipairs(TRAINER_BOOST_STATS) do
				local startValue = tonumber(range["Start" .. statName]) or 0
				local endValue = tonumber(range["End" .. statName]) or startValue
				
				boosts[statName] = startValue + (endValue - startValue) * alpha
			end
			return boosts
		end
	end
	return boosts
end

function TrainerModule.getBoost(trainerName, level, stage)
	local boosts = TrainerModule.getBaseBoost(trainerName, level)
	
	stage = math.clamp(math.floor(tonumber(stage) or 1), 1, #TrainerModule.Stage)
	
	local stageMultiplier = TrainerModule.getStageMultiplier(stage)
	
	for _, statName in ipairs(TRAINER_BOOST_STATS) do
		boosts[statName] = boosts[statName] * stageMultiplier
	end
	return boosts
end

function TrainerModule.getTrainerMultiplier(player, trainerName, multiplierName)
	local statName = TRAINER_MULTIPLIER_STATS[multiplierName]
	
	if not statName or not TrainerModule.Data[trainerName] then return 1 end
	
	local folder = TrainerModule.getTrainerPlayerFolder(player, trainerName)
	local levelValue = folder and folder:FindFirstChild("Level")
	local stageValue = folder and folder:FindFirstChild("Stage")
	
	local boosts = TrainerModule.getBoost(trainerName, levelValue and levelValue.Value or 1, stageValue and stageValue.Value or 1)
	
	return 1 + (boosts[statName] or 0) / 100
end

local function getMultiplier(player, multiplierName)
	local trainerName = TrainerModule.getEquippedTrainerName(player)
	if not trainerName then return 1 end
	
	return TrainerModule.getTrainerMultiplier(player, trainerName, multiplierName)
end

function TrainerModule.getEnergyMultiplier(player)
	return getMultiplier(player, "EnergyMultiplier")
end

function TrainerModule.getMoneyMultiplier(player)
	return getMultiplier(player, "MoneyMultiplier")
end

function TrainerModule.getPetLuckMultiplier(player)
	return getMultiplier(player, "PetLuckMultiplier")
end

function TrainerModule.getRacePowerMultiplier(player)
	return getMultiplier(player, "RacePowerMultiplier")
end

function TrainerModule.getAccelerationMultiplier(player)
	return getMultiplier(player, "AccelerationMultiplier")
end

function TrainerModule.getRaceXPMultiplier(player)
	return getMultiplier(player, "RaceXPMultiplier")
end

function TrainerModule.multiplierToPercent(multiplier)
	multiplier = tonumber(multiplier) or 1
	
	return math.max(0, (multiplier - 1) * 100)
end

return TrainerModule
