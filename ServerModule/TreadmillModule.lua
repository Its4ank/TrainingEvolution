local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TreadmillModule = {}

local PetModule = require(ReplicatedStorage.Modules.PetModule)
local TrainerModule = require(ReplicatedStorage.Modules.TrainerModule)
local ClientDataModule = require(ReplicatedStorage.Modules.ClientDataModule)
local ShopModule = require(ReplicatedStorage.Modules.ShopModule)
local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)
local RebirthModule = require(ReplicatedStorage.Modules.RebirthModule)

local BoostModule = require(ServerScriptService.Modules.BoostModule)

TreadmillModule.MAX_TREADMILLS = 3
TreadmillModule.MAX_STAGE = 5
TreadmillModule.MAX_LEVEL = 25

TreadmillModule.Treadmills = { 
	[1] = {
		Name = "Treadmill 1",
		BaseEnergy = 2,
		EnergyPerLevel = 0.4,
		
		LevelPriceBase = 20,
		LevelPriceMultiplier = 1.15,
	},
	
	[2] = {
		Name = "Treadmill 2",
		BaseEnergy = 30,
		EnergyPerLevel = 1.2,
		
		LevelPriceBase = 180,
		LevelPriceMultiplier = 1.14,
	},
	
	[3] = {
		Name = "Treadmill 3",
		BaseEnergy = 150,
		EnergyPerLevel = 4,
		
		LevelPriceBase = 1500,
		LevelPriceMultiplier = 1.13,
	},
}

TreadmillModule.Stages = { 
	[1] = {
		Name = "Reborn",
		Multiplier = 1.00,
		Icon = "rbxassetid://127918052787935"
	},
	
	[2] = {
		Name = "Awakened",
		Multiplier = 1.25,
		Icon = "rbxassetid://85346007051576"
	},
	
	[3] = {
		Name = "Enlightened",
		Multiplier = 1.50,
		Icon = "rbxassetid://79005943884110"
	},
	
	[4] = {
		Name = "Imortal",
		Multiplier = 1.75,
		Icon = "rbxassetid://96537683340864"
	},
	
	[5] = {
		Name = "Infinite",
		Multiplier = 2.00,
		Icon = "rbxassetid://108017334410514"
	},
}

TreadmillModule.TierRequirements = { 
	[1] = { -- Treadmill 1
		[1] = {Energy = 150, Rebirth = 5, Time = 60}, -- Stage 1 > 2
		[2] = {Energy = 300, Rebirth = 10, Time = 90}, -- Stage 2 > 3
		[3] = {Energy = 600, Rebirth = 15, Time = 120}, -- Stage 3 > 4
		[4] = {Energy = 1000, Rebirth = 25, Time = 150}, -- Stage 4 > 5
	},
	
	[2] = { -- Treadmill 2
		[1] = {Energy = 2500, Rebirth = 40, Time = 90}, -- Stage 1 > 2
		[2] = {Energy = 6000, Rebirth = 60, Time = 120}, -- Stage 2 > 3
		[3] = {Energy = 12000, Rebirth = 85, Time = 150}, -- Stage 3 > 4
		[4] = {Energy = 20000, Rebirth = 110, Time = 180}, -- Stage 4 > 5
	},
	
	[3] = { -- Treadmill 3
		[1] = {Energy = 50000, Rebirth = 140, Time = 120}, -- Stage 1 > 2
		[2] = {Energy = 100000, Rebirth = 180, Time = 150}, -- Stage 2 > 3
		[3] = {Energy = 180000, Rebirth = 230, Time = 180}, -- Stage 3 > 4
		[4] = {Energy = 300000, Rebirth = 300, Time = 210}, -- Stage 4 > 5
	},
}

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

local function getLeaderstats(player, name)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return nil end
	
	return leaderstats:FindFirstChild(name)
end

function TreadmillModule.SetupPlayer(player)
	local treadmillsFolder = getOrCreateFolder(player, "Treadmills")
	
	for treadmillId = 1, TreadmillModule.MAX_TREADMILLS do 
		local treadmillFolder = getOrCreateFolder(treadmillsFolder, "Treadmill" .. treadmillId)
		
		getOrCreateValue(treadmillFolder, "IntValue", "Level", 0)
		getOrCreateValue(treadmillFolder, "IntValue", "Stage", 1)
		getOrCreateValue(treadmillFolder, "NumberValue", "TrainingTime", 0)
	end
	
	getOrCreateValue(player, "IntValue", "CurrentTreadmill", 0)
end

function TreadmillModule.GetTreadmillFolder(player, treadmillId)
	TreadmillModule.SetupPlayer(player)
	
	local treadmillsFolder = player:FindFirstChild("Treadmills")
	if not treadmillsFolder then return nil end
	
	return treadmillsFolder:FindFirstChild("Treadmill" .. treadmillId)
end

function TreadmillModule.GetTreadmillValues(player, treadmillId)
	local treadmillFolder = TreadmillModule.GetTreadmillFolder(player, treadmillId)
	if not treadmillFolder then return nil end
	
	local level = treadmillFolder:FindFirstChild("Level")
	local stage = treadmillFolder:FindFirstChild("Stage")
	local trainingTime = treadmillFolder:FindFirstChild("TrainingTime")
	
	if not level or not stage or not trainingTime then 
		return nil
	end
	
	return { 
		Folder = treadmillFolder,
		Level = level,
		Stage = stage, 
		TrainingTime = trainingTime,
	}
end

function TreadmillModule.GetStageData(stage)
	return TreadmillModule.Stages[stage] or TreadmillModule.Stages[1]
end

function TreadmillModule.GetStageMaxLevel(stage)
	stage = tonumber(stage) or 1
	return math.clamp(stage * 5, 5, TreadmillModule.MAX_LEVEL)
end

function TreadmillModule.GetLevelPrice(treadmillId, currentLevel)
	local treadmillConfig = TreadmillModule.Treadmills[treadmillId]
	if not treadmillConfig then return 0 end
	
	currentLevel = tonumber(currentLevel) or 0
	
	local price = treadmillConfig.LevelPriceBase * (treadmillConfig.LevelPriceMultiplier ^ currentLevel)
	
	return math.floor(price)
end

function TreadmillModule.IsTreadmillCompleted(player, treadmillId)
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	
	if not data then return false end
	
	return data.Stage.Value >= TreadmillModule.MAX_STAGE
	    and data.Level.Value >= TreadmillModule.MAX_LEVEL
end

function TreadmillModule.IsTreadmillUnlocked(player, treadmillId)
	treadmillId = tonumber(treadmillId) or 1
	
	if treadmillId <= 1 then 
		return true
	end
	
	local previousTreadmillId = treadmillId - 1
	
	return TreadmillModule.IsTreadmillCompleted(player, previousTreadmillId)
end

function TreadmillModule.AddTrainingTime(player, treadmillId, dt)
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	if not data then return end
	
	data.TrainingTime.Value += dt 
end

function TreadmillModule.AddTrainerTrainingTime(player, dt)
	dt = tonumber(dt) or 0
	
	if dt <= 0 then 
		return false
	end
	
	return TrainerModule.addEquippedTrainerProgress( 
		player,
		"TrainerTreadmillTime",
		dt
	)
end

function TreadmillModule.ResetTrainingTime(player, treadmillId)
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	if not data then return end 
	
	data.TrainingTime.Value = 0
end

local function getPetEnergyBonus(player)
	return ShopModule.GetEquippedPetBonuses(player).Energy
end

function TreadmillModule.GetPlayerEnergyMultiplier(player)
	local multiplier = 1
	
	--// Буст к беговой дорожке
	local rebirthEnergyMultiplier = RebirthModule.GetEnergyMultiplier(player)
	
	multiplier *= rebirthEnergyMultiplier
	
	--// Улучшение енергии
	local energyUpgradeMultiplier = UpgradeModule.GetEnergyMultiplier(player)
	
	multiplier *= energyUpgradeMultiplier
	
	--// Тренер
	local trainerEnergyMultiplier = 1 
	
	local successTrainer, trainerResult = pcall(function()
		return TrainerModule.getEnergyMultiplier(player)
	end)
	
	if successTrainer and typeof(trainerResult) == "number" then 
		trainerEnergyMultiplier = trainerResult
	end
	
	multiplier *= trainerEnergyMultiplier
	
	--// Бусты: Time, Top, Pemium, Potions, Server Potions
	local boostEnergyMultiplier = 1
	
	local successBoost, boostResult = pcall(function()
		return BoostModule.GetEnergyMultiplier(player)
	end)
	
	if successBoost and typeof(boostResult) == "number" then
		boostEnergyMultiplier = boostResult
	end
	
	multiplier *= boostEnergyMultiplier 
	
	--// Gamepass 2x Energy
	multiplier = ShopModule.ApplyResourcePass(player, "Energy", 1, multiplier)
	
	return multiplier
end

function TreadmillModule.GetBaseEnergyPerSecond(player, treadmillId, levelOverride, stageOverride)
	local treadmillConfig = TreadmillModule.Treadmills[treadmillId]
	if not treadmillConfig then return 0 end
	
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	if not data then return 0 end
	
	local level = levelOverride 
	if level == nil then 
		level = data.Level.Value
	end
	
	local stage = stageOverride
	if stage == nil then 
		stage = data.Stage.Value
	end
	
	level = math.clamp(level, 0, TreadmillModule.MAX_LEVEL)
	stage = math.clamp(stage, 1, TreadmillModule.MAX_STAGE)
	
	local stageData = TreadmillModule.GetStageData(stage)
	
	local rebirth = getLeaderstats(player, "Rebirth")
	local rebirthValue = rebirth and rebirth.Value or 0
	
	local flatEnergy = 
		treadmillConfig.BaseEnergy 
		+ (level * treadmillConfig.EnergyPerLevel)
		+ (rebirthValue * RebirthModule.EnergyFlatBonusPerRebirth)
	
	return flatEnergy * stageData.Multiplier
end

function TreadmillModule.GetFinalEnergyPerSecond(player, treadmillId, levelOverride, stageOverride)
	local baseEnergy = TreadmillModule.GetBaseEnergyPerSecond(player, treadmillId, levelOverride, stageOverride)
	local petEnergy = getPetEnergyBonus(player)
	local multiplier = TreadmillModule.GetPlayerEnergyMultiplier(player)
	
	return (baseEnergy + petEnergy) * multiplier
end

function TreadmillModule.CanUpgradeLevel(player, treadmillId)
	if not TreadmillModule.IsTreadmillUnlocked(player, treadmillId) then 
		return false, "LOCKED"
	end
	
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	if not data then 
		return false, "NO_DATA"
	end
	
	local currentLevel = data.Level.Value
	local currentStage = data.Stage.Value
	local maxLevelForStage = TreadmillModule.GetStageMaxLevel(currentStage)
	
	if currentLevel >= TreadmillModule.MAX_LEVEL then 
		return false, "MAX_LEVEL"
	end
	
	if currentLevel >= maxLevelForStage then 
		return false, "NEED_STAGE_UP"
	end
	
	local energy = getLeaderstats(player, "Energy")
	if not energy then 
		return false, "NO_ENERGY"
	end
	
	local price = TreadmillModule.GetLevelPrice(treadmillId, currentLevel)
	
	if energy.Value < price then 
		return false, "NOT_ENOUGH_ENERGY", {
		    Need = price - energy.Value,
		    Price = price,
		}
	end
	
	return true, "CAN_UPGRADE", { 
		Price = price,
	}
end

function TreadmillModule.UpgradeLevel(player, treadmillId)
	local canUpgrade, reason, info = TreadmillModule.CanUpgradeLevel(player, treadmillId)
	
	if not canUpgrade then 
		return false, reason, info 
	end
	
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	local energy = getLeaderstats(player, "Energy")
	local price = info.Price
	
	energy.Value -= price 
	data.Level.Value += 1
	
	return true, "LEVEL_UP", { 
		NewLevel = data.Level.Value,
		Price = price,
	}
end

function TreadmillModule.GetTierRequirement(treadmillId, stage)
	local treadmillRequirements = TreadmillModule.TierRequirements[treadmillId]
	if not treadmillRequirements then return nil end 
	
	return treadmillRequirements[stage]
end

function TreadmillModule.GetTierUpStatus(player, treadmillId)
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	
	if not data then 
		return false, "NO_DATA"
	end
	
	local currentStage = data.Stage.Value
	
	if currentStage >= TreadmillModule.MAX_STAGE then 
		return false, "MAX_STAGE"
	end
	
	local requirement = TreadmillModule.GetTierRequirement(treadmillId, currentStage)
	
	if not requirement then 
		return false, "NO_REQUIREMENT"
	end
	
	local energy = getLeaderstats(player, "Energy")
	local rebirth = getLeaderstats(player, "Rebirth")
	
	local currentEnergy = energy and energy.Value or 0
	local currentRebirth = rebirth and rebirth.Value or 0
	local currentTime = data.TrainingTime.Value
	local currentLevel = data.Level.Value
	
	local requiredLevel = TreadmillModule.GetStageMaxLevel(currentStage)
	
	local missing = { 
		Level = math.max(0, requiredLevel - currentLevel),
		Energy = math.max(0, requirement.Energy - currentEnergy),
		Rebirth = math.max(0, requirement.Rebirth - currentRebirth),
		Time = math.max(0, requirement.Time - currentTime),
	}
	
	local completed = { 
		Level = missing.Level <= 0,
		Energy = missing.Energy <= 0,
		Rebirth = missing.Rebirth <= 0,
		Time = missing.Time <= 0,
	}
	
	local canTierUp = completed.Level and completed.Energy and completed.Rebirth and completed.Time
	
	return canTierUp, "STATUS", { 
		Requirement = requirement,
		
		Current = { 
			Level = currentLevel,
			Energy = currentEnergy,
			Rebirth = currentRebirth,
			Time = currentTime,
		},
		
		Missing = missing,
		Completed = completed,
		RequiredLevel = requiredLevel,
	}
end

function TreadmillModule.TierUp(player, treadmillId)
	local canTierUp, _, info = TreadmillModule.GetTierUpStatus(player, treadmillId)
	
	if not canTierUp then 
		return false, "NOT_ENOUGH", info 
	end
	
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	local energy = getLeaderstats(player, "Energy")
	local rebirth = getLeaderstats(player, "Rebirth")
	
	if not data or not energy or not rebirth then 
		return false, "NO_DATA"
	end
	
	energy.Value = 0
	rebirth.Value = 0
	
	data.TrainingTime.Value = 0
	data.Stage.Value += 1
	
	return true, "TIER_UP", {
		NewStage = data.Stage.Value,
		Level = data.Level.Value,
	}
end

function TreadmillModule.FormatTime(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	
	if hours > 0 then 
		return tostring(hours) .. "h " .. tostring(minutes) .. "m"
	end
	
	if minutes > 0 then
		return tostring(minutes) .. "m " .. tostring(secs) .. "s"
	end
	
	return tostring(secs) .. "s"
end

return TreadmillModule
