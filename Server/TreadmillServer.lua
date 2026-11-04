--// TreadmillServer v1.3

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

--// Modules
local TreadmillModule = require(ServerScriptService.Modules.TreadmillModule)

local TrainerModule = require(ReplicatedStorage.Modules.TrainerModule)
local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)

--// RemopteEvents
local treadmillEventsFolder = ReplicatedStorage:FindFirstChild("TreadmillEvents")
if not treadmillEventsFolder then 
	treadmillEventsFolder = Instance.new("Folder")
	treadmillEventsFolder.Name = "TreadmillEvents"
	treadmillEventsFolder.Parent = ReplicatedStorage
end

local treadmillRequestEvent = treadmillEventsFolder:FindFirstChild("TreadmillRequestEvent")
if not treadmillRequestEvent then 
	treadmillRequestEvent = Instance.new("RemoteEvent")
	treadmillRequestEvent.Name = "TreadmillRequestEvent"
	treadmillRequestEvent.Parent = treadmillEventsFolder
end

local treadmillResponseEvent = treadmillEventsFolder:FindFirstChild("TreadmillResponseEvent")
if not treadmillResponseEvent then 
	treadmillResponseEvent = Instance.new("RemoteEvent")
	treadmillResponseEvent.Name = "TreadmillResponseEvent"
	treadmillResponseEvent.Parent = treadmillEventsFolder
end

local treadmillInfoFunction = treadmillEventsFolder:FindFirstChild("TreadmillInfoFunction")
if not treadmillInfoFunction then 
	treadmillInfoFunction = Instance.new("RemoteFunction")
	treadmillInfoFunction.Name = "TreadmillInfoFunction"
	treadmillInfoFunction.Parent = treadmillEventsFolder
end

--// Optional old RunEvent for effects/UI
local energyPopupEvent = ReplicatedStorage:FindFirstChild("EnergyPopupEvent")
if not energyPopupEvent then 
	energyPopupEvent = Instance.new("RemoteEvent")
	energyPopupEvent.Name = "EnergyPopupEvent"
	energyPopupEvent.Parent = ReplicatedStorage
end

--// Settings
local CHECK_LOOP_DELAY = 0.1

local trainingStates = {}

local function isValidId(id)
	return type(id) == "number" and id == math.floor(id) and id >= 1 and id <= TreadmillModule.MAX_TREADMILLS
end

--// Helpers
local function getTrainingInterval(player)
	return UpgradeModule.GetTrainingInterval(player, 1)
end

--// Check active physical treadmill
local function getRunningTreadmill(player)
	if player:GetAttribute("DataReady") ~= true then return nil end
	if player:GetAttribute("StoneTreadmillRunning") ~= true then return nil end
	
	local treadmillId = player:GetAttribute("StoneTreadmillHeld")
	
	if not isValidId(treadmillId) then return nil end
	if not TreadmillModule.IsTreadmillUnlocked(player, treadmillId) then return nil end
	
	local currentTreadmill = player:FindFirstChild("CurrentTreadmill")
	if not currentTreadmill or currentTreadmill.Value ~= treadmillId then return nil end
	
	local inRace = player:FindFirstChild("InRace")
	if inRace and inRace.Value then return nil end
	
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return nil end
	
	return treadmillId 
end

local function fireResponse(player, action, success, reason, info)
	treadmillResponseEvent:FireClient(player, action, success, reason, info)
end

local function upgradeLevel(player, treadmillId)
	treadmillId = tonumber(treadmillId)
	if not isValidId(treadmillId) then return end
	
	TreadmillModule.SetupPlayer(player)
	
	local success, reason, info = TreadmillModule.UpgradeLevel(player, treadmillId)
	
	fireResponse(player, "UpgradeLevel", success, reason, info)
end

local function tierUp(player, treadmillId)
	treadmillId = tonumber(treadmillId)
	if not isValidId(treadmillId) then return end
	
	TreadmillModule.SetupPlayer(player)
	
	local success, reason, info = TreadmillModule.TierUp(player, treadmillId)
	
	fireResponse(player, "TierUp", success, reason, info)
end

--// Remoite handling
treadmillRequestEvent.OnServerEvent:Connect(function(player, action, treadmillId)
	if player:GetAttribute("DataReady") ~= true then return end
	
	local id = tonumber(treadmillId)
	
	if action == "UpgradeLevel" then
		upgradeLevel(player, id)
		
	elseif action == "TierUp" then
		tierUp(player, id)
		
	elseif action == "StartTraining" or action == "StopTraining" or action == "ToggleTraining" then
		fireResponse(player, action, false, "USE_PHYSICAL_TREADMILL")
	end
end)

local function getTreadmillInfo(player, treadmillId)
	treadmillId = tonumber(treadmillId) or 1
	
	if not isValidId(treadmillId) then return nil end
	
	TreadmillModule.SetupPlayer(player)
	
	local data = TreadmillModule.GetTreadmillValues(player, treadmillId)
	if not data then 
		return nil
	end
	
	local level = data.Level.Value
	local stage = data.Stage.Value
	local trainingTime = data.TrainingTime.Value
	
	local stageData = TreadmillModule.GetStageData(stage)
	local nextStageData = TreadmillModule.GetStageData(math.min(stage + 1, TreadmillModule.MAX_STAGE))
	
	local stageMaxLevel = TreadmillModule.GetStageMaxLevel(stage)
	
	local nextLevel = level 
	if level < stageMaxLevel then 
		nextLevel = level + 1
	end
	
	local levelPrice = TreadmillModule.GetLevelPrice(treadmillId, level)
	
	local interval = getTrainingInterval(player)
	local currentEnergy = TreadmillModule.GetFinalEnergyPerSecond(player, treadmillId, level, stage) / interval
	local nextEnergy = TreadmillModule.GetFinalEnergyPerSecond(player, treadmillId, nextLevel, stage) / interval
	
	local canTierUp, tierReason, tierInfo = TreadmillModule.GetTierUpStatus(player, treadmillId)
	
	return { 
		TreadmillId = treadmillId, 
		Name = "Treadmill " .. tostring(treadmillId), 
		
		Unlocked = TreadmillModule.IsTreadmillUnlocked(player, treadmillId),
		Completed = TreadmillModule.IsTreadmillCompleted(player, treadmillId),
		
		Level = level,
		Stage = stage, 
		TrainingTime = trainingTime,
		
		StageMaxLevel = stageMaxLevel,
		MaxLevel = TreadmillModule.MAX_LEVEL,
		MaxStage = TreadmillModule.MAX_STAGE,
		
		LevelPrice = levelPrice,
		
		CurrentEnergy = currentEnergy,
		NextEnergy = nextEnergy,
		
		StageName = stageData.Name,
		StageIcon = stageData.Icon,
		StageMultiplier = stageData.Multiplier,
		
		NextStageName = nextStageData.Name,
		NextStageIcon = nextStageData.Icon,
		NextStageMultiplier = nextStageData.Multiplier,
		
		CanTierUp = canTierUp,
		TierReason = tierReason,
		TierInfo = tierInfo,
	}
end

treadmillInfoFunction.OnServerInvoke = function(player, treadmillId)
	if player:GetAttribute("DataReady") ~= true then return nil end
	
	return getTreadmillInfo(player, treadmillId)
end

--// Energy rewards
local function processEnergy(player, state, treadmillId, now)
	local interval = getTrainingInterval(player)
	
	if now - state.LastEnergyTick < interval then return end
	
	state.LastEnergyTick += interval 
	
	local leaderstats = player:FindFirstChild("leaderstats")
	local energy = leaderstats and leaderstats:FindFirstChild("Energy")
	
	if not energy then return end
	
	local energyPerTick = TreadmillModule.GetFinalEnergyPerSecond(player, treadmillId)
	local accumulated = energyPerTick + state.EnergyRemainder
	local gainedEnergy = math.floor(accumulated + 1e-9)
	
	state.EnergyRemainder = math.max(0, accumulated - gainedEnergy)
	
	if gainedEnergy > 0 then
		energy.Value += gainedEnergy
		
		TrainerModule.addEquippedTrainerProgress(player, "Energy", gainedEnergy)
		
		energyPopupEvent:FireClient(player, gainedEnergy)
	end
end

--// Physical treadmill training loop
local accumulator = 0

RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	
	if accumulator < CHECK_LOOP_DELAY then return end
	
	accumulator = 0
	
	local now = os.clock()
	
	for _, player in ipairs(Players:GetPlayers()) do
		local treadmillId = getRunningTreadmill(player)
		
		if not treadmillId then
			trainingState[player] = nil
			continue
		end
		
		local state = trainingStates[player]
		
		if not state or state.TreadmillId ~= treadmillId then
			trainingStates[player] = {
				TreadmillId = treadmillId,
				LastEnergyTick = now,
				LastTimeUpdate = now,
				EnergyRemainder = 0,
			}
			
			continue
		end
		
		local elapsed = math.clamp(now - state.LastTimeUpdate, 0, 0.5)
		
		state.LastTimeUpdate = now
		
		if elapsed > 0 then
			TreadmillModule.AddTrainingTime(player, treadmillId, elapsed)
			TreadmillModule.AddTrainerTrainingTime(player, elapsed)
		end
		
		processEnergy(player, state, treadmillId, now)
	end
end)

Players.PlayerAdded:Connect(function(player)
	TreadmillModule.SetupPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	trainingStates[player] = nil
end)

print("TreadmillServer loaded")
