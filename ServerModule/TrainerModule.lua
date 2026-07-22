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
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		RaceXPMultiplier = 1,
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
		Price = 1,
		
		MaxLevel = 25,
		MaxEvolution = 10,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1,
		
		RacePowerMultiplier = 1.15,
		AccelerationMultiplier = 1.15,
		
		RaceXPMultiplier = 1,
	},
	
	MonikaTrainer = {
		DisplayName = "Monika Trainer",
		ModelName = "MonikaTrainer",
		Enabled = true,
		
		Specialist = "Ledy Luck",
		SpecialistIcon = "rbxassetid://84934349596853",
		
		LeaderStatName = "EggHatched",
		LeaderStatIcon = "rbxassetid://73197884503844",
		
		UnlockType = "PetHatched",
		RequiredPets = 500,
		AutoUnlock = true,
		
		MaxLevel = 25,
		MaxEvolution = 10,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1.20,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		
		RaceXPMultiplier = 1.10,
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
		Price = 5000,
		
		MaxLevel = 25,
		MaxEvolution = 10,
		
		EnergyMultiplier = 1.20,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		RaceXPMultiplier = 1,
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
		Price = 1000,
		
		MaxLevel = 25,
		MaxEvolution = 10,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1.20,
		PetLuckMultiplier = 1,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		RaceXPMultiplier = 1,
	},
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

TrainerModule.StageStarIcons = { 
	Active = "rbxassetid://117035434388256",
	Inactive = "rbxassetid://105741165654536",
}

TrainerModule.RequirementIcons = { 
	Level = "",
	
	Energy = "rbxassetid://74509086636062",
	Money = "rbxassetid://123691959584167",
	Rebirth = "rbxassetid://91670074635222",
	
	TrainerTreadmillTime = "rbxassetid://104625083427194",
	EggHatched = "rbxassetid://73197884503844",
	PetRarity = "",
	RaceRewards = "",
}

TrainerModule.RequirementDisplayNames = { 
	Level = "LEVEL",
	
	Energy = "ENERGY",
	Money = "MONEY",
	Rebirth = "REBIRTH",
	
	TrainerTreadmillTime = "TREADMILL TIME",
	EggHatched = "EGGS HATCHED",
	PetRarity = "PET HATCHED",
	RaceRewards = "RACE REWARDS",
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
		RaceRewards = "IntValue",
	},
}

TrainerModule.StageRequirements = {
	LedyTrainer = {
		[1] = {
			{ 
				Type = "Level",
				Need = 5,
			},
			{
				Type = "Energy",
				Need = 1000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 60,
				ResetOnRankUp = true,
			},
		},
		[2] = {
			{ 
				Type = "Level",
				Need = 10,
			},
			{ 
				Type = "Energy",
				Need = 5000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 180,
				ResetOnRankUp = true,
			},
		},
		[3] = {
			{
				Type = "Level",
				Need = 15,
			},
			{
				Type = "Energy",
				Need = 25000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 300,
				ResetOnRankUp = true,
			},
		},
		[4] = {
			{
				Type = "Level",
				Need = 20,
			},
			{
				Type = "Energy",
				Need = 100000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 600,
				ResetOnRankUp = true,
			},
		},
	},
	
	BellaTrainer = {
		[1] = {
			{
				Type = "Level",
				Need = 5,
			},
			{
				Type = "Money",
				Need = 1000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 60,
				ResetOnRankUp = true,
			},
		},
		[2] = {
			{
				Type = "Level",
				Need = 10,
			},
			{
				Type = "Money",
				Need = 5000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 180,
				ResetOnRankUp = true,
			},
		},
		[3] = {
			{ 
				Type = "Level",
				Need = 15,
			},
			{
				Type = "Money",
				Need = 25000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 300,
				ResetOnRankUp = true,
			},
		},
		[4] = {
			{
				Type = "Level",
				Need = 20,
			},
			{
				Type = "Money",
				Need = 100000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "TrainerTreadmillTime",
				Need = 600,
				ResetOnRankUp = true,
			},
		},
	},
	
	MonikaTrainer = {
		[1] = {
			{
				Type = "Level",
				Need = 5,
			},
			{
				Type = "EggHatched",
				Need = 0,
				Placeholder = true,
				ResetOnRankUp = true,
			},
			{
				Type = "PetRarity",
				Rarity = "Rare",
				Need = 5,
				ResetOnRankUp = true,
			},
		},
		[2] = {
			{
				Type = "Level",
				Need = 10,
			},
			{
				Type = "EggHatched",
				Need = 0,
				Placeholder = true,
				ResetOnRankUp = true,
			},
			{
				Type = "PetRarity",
				Rarity = "Epic",
				Need = 5,
				ResetOnRankUp = true,
			},
		},
		[3] = {
			{
				Type = "Level",
				Need = 15,
			},
			{
				Type = "EggHatched",
				Need = 0,
				Placeholder = true,
				ResetOnRankUp = true,
			},
			{
				Type = "PetRarity",
				Rarity = "Epic",
				Need = 15,
				ResetOnRankUp = true,
			},
		},
		[4] = {
			{
				Type = "Level",
				Need = 20,
			},
			{
				Type = "EggHatched",
				Need = 0,
				Placeholder = true,
				ResetOnRankUp = true,
			},
			{
				Type = "PetRarity",
				Rarity = "Legendary",
				Need = 10,
				ResetOnRankUp = true,
			},
		},
	},
	
	JoeTrainer = {
		[1] = {
			{
				Type = "Level",
				Need = 5,
			},
			{
				Type = "Rebirth",
				Need = 100,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "RaceRewards",
				Need = 50,
				ResetOnRankUp = true,
			},
		},
		[2] = {
			{
				Type = "Level",
				Need = 10,
			},
			{
				Type = "Rebirth",
				Need = 500,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "RaceRewards",
				Need = 100,
				ResetOnRankUp = true,
			},
		},	
		[3] = {
			{
				Type = "Level",
				Need = 15,
			},
			{
				Type = "Rebirth",
				Need = 1000,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "RaceRewards",
				Need = 150,
				ResetOnRankUp = true,
			},
		},
		[4] = {
			{
				Type = "Level",
				Need = 20,
			},
			{
				Type = "Rebirth",
				Need = 2500,
				Spend = true,
				ResetOnRankUp = true,
			},
			{
				Type = "RaceRewards",
				Need = 200,
				ResetOnRankUp = true,
			},
		},
	},
}

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

local function getMultiplier(player, multiplierName)
	local trainerName = TrainerModule.getEquippedTrainerName(player)
	
	if not trainerName then
		return 1
	end

	local data = TrainerModule.Data[trainerName]
	
	if not data then
		return 1
	end

	local baseMultiplier = data[multiplierName] or 1
	
	local trainerDataFolder = TrainerModule.getTrainerPlayerFolder( 
		player,
		trainerName
	)

	local stageValue = trainerDataFolder and trainerDataFolder:FindFirstChild("Stage")
	
	local levelValue = trainerDataFolder and trainerDataFolder:FindFirstChild("Level")
	
	local stage = stageValue and stageValue.Value or 1
	local level = levelValue and levelValue.Value or 1
	
	local stagePower = TrainerModule.getStageMultiplier(stage)
	local levelPower = 1 + ((level - 1) * 0.02)

	return 1 + (
		(baseMultiplier - 1)
		* stagePower 
		* levelPower
	)
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

function TrainerModule.getTrainerMultiplier( 
	player, 
	trainerName,
	multiplierName
)
	local data = TrainerModule.Data[trainerName]
	
	if not data then 
		return 1
	end
	
	local baseMultiplier = data[multiplierName] or 1
	
	local trainerDataFolder = TrainerModule.getTrainerPlayerFolder( 
		player,
		trainerName
	)
	
	local stageValue = trainerDataFolder and trainerDataFolder:FindFirstChild("Stage")
	
	local levelValue = trainerDataFolder and trainerDataFolder:FindFirstChild("Level")
	
	local stage = stageValue and stageValue.Value or 1
	local level = levelValue and levelValue.Value or 1
	
	local stagePower = TrainerModule.getStageMultiplier(stage)
	local levelPower = 1 + ((level - 1) * 0.02)
	
	return 1 + (
		(baseMultiplier - 1)
		* stagePower 
		* levelPower
	)
end

function TrainerModule.multiplierToPercent(multiplier)
	multiplier = tonumber(multiplier) or 1
	
	return math.max(0, (multiplier - 1) * 100)
end

return TrainerModule
