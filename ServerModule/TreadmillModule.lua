local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TreadmillModule = {}

local PetModule = require(ServerScriptService.Modules.PetModule)
local TrainerModule = require(ServerScriptService.Modules.TrainerModule)
local BoostModule = require(ServerScriptService.Modules.BoostModule)

local ClientDataModule = require(ReplicatedStorage.Modules.ClientDataModule)
local ShopModule = require(ReplicatedStorage.Modules.ShopModule)

TreadmillModule.MAX_TREADMILLS = 3
TreadmillModule.MAX_STAGE = 5
TreadmillModule.MAX_LEVEL = 25

TreadmillModule.REBIRTH_ENERGY_BONUS = 1

TreadmillModule.Treadmills = { 
	[1] = {
		Name = "Treadmill 1",
		BaseEnergy = 1,
		EnergyPerLevel = 0.2,
		
		LevelPriceBase = 1000,
		LevelPriceMultiplier = 1.45,
	},
	
	[2] = {
		Name = "Treadmill 2",
		BaseEnergy = 5,
		EnergyPerLevel = 1,
		
		LevelPriceBase = 5000,
		LevelPriceMultiplier = 1.5,
	},
	
	[3] = {
		Name = "Treadmill 3",
		BaseEnergy = 25,
		EnergyPerLevel = 5,
		
		LevelPriceBase = 25000,
		LevelPriceMultiplier = 1.55,
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
		[1] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 1 > 2
		[2] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 2 > 3
		[3] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 3 > 4
		[4] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 4 > 5
	},
	
	[2] = { -- Treadmill 2
		[1] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 1 > 2
		[2] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 2 > 3
		[3] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 3 > 4
		[4] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 4 > 5
	},
	
	[3] = { -- Treadmill 3
		[1] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 1 > 2
		[2] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 2 > 3
		[3] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 3 > 4
		[4] = {Energy = 1, Rebirth = 1, Time = 1}, -- Stage 4 > 5
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

local function getUpgradeLevel(player, upgradeName)
	local upgrades = player:FindFirstChild("Upgrades")
	if not upgrades then return 0 end
	
	local upgrade = upgrades:FindFirstChild(upgradeName)
	if not upgrade then return 0 end
	
	return upgrade.Value
end

local function getGamepassEnergyMultiplier(player)
	local bonus = 0
	
	local success, result = pcall(function()
		return ShopModule.GetEnergyBonus(player)
	end)
	
	if success and typeof(result) == "number" then 
		bonus = result
	end
	
	return 1 + bonus
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

function TreadmillModule.ResetTrainingTime(player, treadmillId)
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	if not data then return end 
	
	data.TrainingTime.Value = 0
end

function TreadmillModule.GetPlayerEnergyMultiplier(player)
	
	local multiplier = 1 
	
	local petEnergyMultiplier = 1
	
	local successPets, equippedPets = pcall(function()
		return PetModule.getEquippedPets(player)
	end)
	
	if successPets and equippedPets then 
		for _, pet in ipairs(equippedPets) do 
			local petEnergy = pet:FindFirstChild("EnergyMultiplier")
			
			if petEnergy then
				petEnergyMultiplier *= petEnergy.Value
			end
		end
	end
	
	multiplier *= petEnergyMultiplier
	
	--// Улучшение енергии
	local energyUpgradeLevel = getUpgradeLevel(player, "Energy")
	local energyUpgradeMultiplier = 1 + (energyUpgradeLevel * 0.10)
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
	multiplier *= getGamepassEnergyMultiplier(player)
	
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
		+ (rebirthValue * TreadmillModule.REBIRTH_ENERGY_BONUS)
	
	return flatEnergy * stageData.Multiplier
end

function TreadmillModule.GetFinalEnergyPerSecond(player, treadmillId, levelOverride, stageOverride)
	local baseEnergy = TreadmillModule.GetBaseEnergyPerSecond(player, treadmillId, levelOverride, stageOverride)
	local multiplier = TreadmillModule.GetPlayerEnergyMultiplier(player)
	
	local result = baseEnergy * multiplier 
	
	return math.floor(result * 100) / 100
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
	local canTierUp, reason, info = TreadmillModule.GetTierUpStatus(player, treadmillId)
	
	if not canTierUp then 
		return false, "NOT_ENOUGH", info 
	end
	
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	if not data then 
		return false, "NO_DATA"
	end
	
	local energy = getLeaderstats(player, "Energy")
	local rebirth = getLeaderstats(player, "Rebirth")
	
	if energy then 
		energy.Value = 0
	end
	
	if rebirth then 
		rebirth.Value = 0
	end
	
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
