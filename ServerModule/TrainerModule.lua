local TrainerModule = {}

TrainerModule.Data = {
	TestTrainer = {
		DisplayName = " Test Trainer",
		ModelName = "TestTrainer",
		Enabled = false,
		
		stage = "Rookie",
		MaxLevel = 25,
		MaxEvolution = 10,
		
		UnlockType = "None",
		Currency = "None",
		Price = 0,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		RaceXPMultiplier = 1,
	},
	
	JoeTrainer = {
		DisplayName = " Joe Trainer",
		ModelName = "JoeTrainer",
		Enabled = true,
		
		stage = "Rookie",
		MaxLevel = 25,
		MaxEvolution = 10,
		
		UnlockType = "Currency",
		Currency = "Rebirth",
		Price = 1,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		RaceXPMultiplier = 1,
	},
	
	MonikaTrainer = {
		DisplayName = " Monika Trainer",
		ModelName = "MonikaTrainer",
		Enabled = true,
		
		stage = "Rookie",
		MaxLevel = 25,
		MaxEvolution = 10,
		
		UnlockType = "PetHatched",
		RequiredPets = 500,
		AutoUnlock = true,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		RaceXPMultiplier = 1,
	},
	
	LedyTrainer = {
		DisplayName = " Ledy Trainer",
		ModelName = "LedyTrainer",
		Enabled = true,
		
		stage = "Rookie",
		MaxLevel = 25,
		MaxEvolution = 10,
		
		UnlockType = "Currency",
		Currency = "Energy",
		Price = 5000,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
		PetLuckMultiplier = 1,
		RacePowerMultiplier = 1,
		AccelerationMultiplier = 1,
		RaceXPMultiplier = 1,
	},
	
	BellaTrainer = {
		DisplayName = " Bella Trainer",
		ModelName = "BellaTrainer",
		Enabled = true,
		
		stage = "Rookie",
		MaxLevel = 25,
		MaxEvolution = 10,
		
		UnlockType = "Currency",
		Currency = "Money",
		Price = 1000,
		
		EnergyMultiplier = 1,
		MoneyMultiplier = 1,
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

TrainerModule.StageRequirements = {
	LedyTrainer = {
		[1] = {Energy = 5000, TreadmillTime = 60},
		[2] = {Energy = 25000, TreadmillTime = 180},
		[3] = {Energy = 100000, TreadmillTime = 300},
		[4] = {Energy = 500000, TreadmillTime = 600},
	},
	
	BellaTrainer = {
		[1] = {Money = 5000},
		[2] = {Money = 25000},
		[3] = {Money = 100000},
		[4] = {Money = 500000},
	},
	
	MonikaTrainer = {
		[1] = {PetHatched = 100},
		[2] = {PetHatched = 500},
		[3] = {PetHatched = 1000},
		[4] = {PetHatched = 2500},
	},
	
	JoeTrainer = {
		[1] = {Rebirth = 1000},
		[2] = {Rebirth = 100000},
		[3] = {Rebirth = 1000000},
		[4] = {Rebirth = 10000000},
	},
}

function TrainerModule.getStageRequirement(trainerName, stageValue)
	local trainerRequirements = TrainerModule.StageRequirements[trainerName]
	if not trainerRequirements then return {} end
	
	return trainerRequirements[stageValue] or {}
end

function TrainerModule.getStageData(stageValue)
	local stageNumber = tonumber(stageValue) or 1
	return TrainerModule.Stage[stageNumber] or TrainerModule.Stage[1]
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

local function getTrainerFolder(player)
	return
		player:WaitForChild("Trainer")
end

function TrainerModule.getEquippedTrainerName(player)
	local trainerFolder = getTrainerFolder(player)
	if not trainerFolder then return nil end
	
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
	if not trainerName then return nil end
	return TrainerModule.Data[trainerName]
end

local function getMultiplier(player, multiplierName)
	local trainerName = TrainerModule.getEquippedTrainerName(player)
	if not trainerName then return 1 end

	local data = TrainerModule.Data[trainerName]
	if not data then return 1 end

	local baseMultiplier = data[multiplierName] or 1

	local trainerFolder = player:FindFirstChild("Trainer")
	local trainerDataFolder = trainerFolder and trainerFolder:FindFirstChild(trainerName)
	local stageValue = trainerDataFolder and trainerDataFolder:FindFirstChild("Stage")

	local stage = stageValue and stageValue.Value or 1
	local stagePower = TrainerModule.getStageMultiplier(stage)
	
	local levelValue = trainerDataFolder and trainerDataFolder:FindFirstChild("Level")
	local level = levelValue and levelValue.Value or 1
	
	local levelPower = 1 + ((level - 1) * 0.02)

	return 1 + ((baseMultiplier - 1) * stagePower * levelPower)
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

return TrainerModule
