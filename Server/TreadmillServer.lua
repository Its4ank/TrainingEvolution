--// TreadmillServer

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Modules
local TreadmillModule = require(ServerScriptService.Modules.TreadmillModule)

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
local runEvent = ReplicatedStorage:FindFirstChild("RunEvent")

--// Setting
local MAX_DISTANCE_TO_START = 15
local MAX_DISTANCE_WHILE_TRAINING = 25
local CHECK_LOOP_DELAY = 0.1

local RUN_ANIMATION_ID = "rbxassetid://913376220"

local activeTraining = {}

--// Helpers

local function getTreadmillObject(treadmillId)
	return workspace:FindFirstChild("Treadmill" .. tostring(treadmillId))
end

local function getTreadmillPosition(treadmillId)
	local treadmillObject = getTreadmillObject(treadmillId)
	if not treadmillObject then 
		return nil
	end
	
	if treadmillObject:IsA("BasePart") then 
		return treadmillObject.Position
	end
	
	local part = treadmillObject:FindFirstChildWhichIsA("BasePart", true)
	if part then 
		return part.Position
	end
	
	return nil
end

local function getUpgradeLevel(player, upgradeName)
	local upgrades = player:FindFirstChild("Upgrades")
	if not upgrades then return 0 end 
	
	local upgrade = upgrades:FindFirstChild(upgradeName)
	if not upgrade then return 0 end 
	
	return upgrade.Value
end

local function getTrainingInterval(player)
	local speedTrainingLevel = getUpgradeLevel(player, "SpeedTraining")
	
	local interval = 1 - (speedTrainingLevel * 0.05)
	
	return math.max(0.2, interval)
end

local function fireResponse(player, action, success, reason, info)
	treadmillResponseEvent:FireClient(player, action, success, reason, info)
end

local function cleanupTraining(player)
	local data = activeTraining[player]
	if not data then return end 
	
	activeTraining[player] = nil
	
	local humanoid = data.Humanoid
	local hrp = data.HRP
	local runTrack = data.RunTrack
	
	if runTrack then
		runTrack:Stop()
		runTrack:Destroy()
	end
	
	if humanoid then
		humanoid.AutoRotate = data.OldAutoRotate
		
		if data.OldWalkSpeed then 
			humanoid.WalkSpeed = data.OldWalkSpeed
		else
			humanoid.WalkSpeed = 16
		end
		
		if data.OldJumpPower then 
			humanoid.JumpPower = data.OldJumpPower
		else
			humanoid.JumpPower = 50
		end
	end
	
	if hrp then 
		hrp.Anchored = false
	end
	
	local currentTreadmill = player:FindFirstChild("CurrentTreadmill")
	if currentTreadmill then 
		currentTreadmill.Value = 0
	end
	
	if runEvent then 
		runEvent:FireClient(player, false)
	end 
	
	fireResponse(player, "StopTraining", true, "STOPPED", { 
		TreadmillId = data.TreadmillId,
	})
end

local function startTraining(player, treadmillId)
	treadmillId = tonumber(treadmillId)
	if not treadmillId then 
		fireResponse(player, "StartTraining", false, "BAD_TREADMILL_ID")
		return
	end
	
	if activeTraining[player] then 
		cleanupTraining(player)
		return
	end
	
	TreadmillModule.SetupPlayer(player)
	
	if not TreadmillModule.IsTreadmillUnlocked(player, treadmillId) then 
		fireResponse(player, "StartTraining", false, "LOCKED", { 
			TreadmillId = treadmillId,
		})
		return
	end
	
	local treadmillPosition = getTreadmillPosition(treadmillId)
	if not treadmillPosition then 
		fireResponse(player, "StartTraining", false, "NO_TREADMILL_PART", { 
			TreadmillId = treadmillId,
		})
		return 
	end
	
	local character = player.Character 
	if not character then 
		fireResponse(player, "StartTraining", false, "NO_CHARACTER")
		return
	end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	
	if not hrp or not humanoid then
		fireResponse(player, "StartTraining", false, "NO_HUMANOID")
		return
	end
	
	local distance = (hrp.Position - treadmillPosition).Magnitude
	if distance > MAX_DISTANCE_TO_START then 
		fireResponse(player, "StartTraining", false, "TOO_FAR", { 
			Distance = distance,
			MaxDistance = MAX_DISTANCE_TO_START,
		})
		return
	end
	
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then 
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	local runAnim = Instance.new("Animation")
	runAnim.AnimationId = RUN_ANIMATION_ID
	
	local runTrack = animator:LoadAnimation(runAnim)
	runTrack.Priority = Enum.AnimationPriority.Action
	runTrack.Looped = true
	runTrack:Play()
	runTrack:AdjustSpeed(3)
	
	local oldWalkSpeed = humanoid.WalkSpeed
	local oldJumpPower = humanoid.JumpPower
	local oldAutoRotate = humanoid.AutoRotate
	
	hrp.CFrame = CFrame.new(treadmillPosition + Vector3.new(0, 3, 0))
	
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.AutoRotate = false
	hrp.Anchored = true 
	
	local currentTreadmill = player:FindFirstChild("CurrentTreadmill")
	if currentTreadmill then 
		currentTreadmill.Value = treadmillId
	end
	
	activeTraining[player] = { 
		TreadmillId = treadmillId,
		HRP = hrp,
		Humanoid = humanoid,
		RunTrack = runTrack,
		
		OldWalkSpeed = oldWalkSpeed,
		OldJumpPower = oldJumpPower,
		OldAutoRotate = oldAutoRotate,
		
		LastEnergyTick = os.clock(),
		LastTimeUpdate = os.clock(),
	}
	
	if runEvent then 
		runEvent:FireClient(player, true)
	end
	
	fireResponse(player, "StartTraining", true, "STARTED", { 
		TreadmillId = treadmillId,
	})
	
	task.spawn(function()
		while activeTraining[player] do 
			local data = activeTraining[player]
			if not data then break end
			
			local currentCharacker = player.Character 
			if not currentCharacker then 
				break
			end
			
			local currentHumanoid = data.Humanoid
			if not currentHumanoid or currentHumanoid.Health <= 0 then
				break
			end
			
			local treadmillPosition = getTreadmillPosition(data.TreadmillId)
			
			if not treadmillPosition or not data.HRP then 
				break
			end
			
			local distanceFromTreadmill = (data.HRP.Position - treadmillPosition).Magnitude
			
			if distanceFromTreadmill > MAX_DISTANCE_WHILE_TRAINING then 
				break
			end
			
			local now = os.clock()
			
			local dt = now - data.LastTimeUpdate
			data.LastTimeUpdate = now
			
			TreadmillModule.AddTrainingTime(player, data.TreadmillId, dt)
			
			local interval = getTrainingInterval(player)
			
			if now - data.LastEnergyTick >= interval then 
				data.LastEnergyTick = now 
				
				local leaderstats = player:FindFirstChild("leaderstats")
				local energy = leaderstats and leaderstats:FindFirstChild("Energy")
				
				if energy then
					local gainedEnergy = TreadmillModule.GetFinalEnergyPerSecond(player, data.TreadmillId)
					
					gainedEnergy = math.floor(gainedEnergy)
					
					if gainedEnergy < 1 then 
						gainedEnergy = 1
					end
					
					energy.Value += gainedEnergy
				end
			end
			
			task.wait(CHECK_LOOP_DELAY)
		end
		cleanupTraining(player)
	end)
end

local function upgradeLevel(player, treadmillId)
	treadmillId = tonumber(treadmillId)
	if not treadmillId then return end
	
	TreadmillModule.SetupPlayer(player)
	
	local success, reason, info = TreadmillModule.UpgradeLevel(player, treadmillId)
	
	fireResponse(player, "UpgradeLevel", success, reason, info)
end

local function tierUp(player, treadmillId)
	treadmillId = tonumber(treadmillId)
	if not treadmillId then return end
	
	TreadmillModule.SetupPlayer(player)
	
	local success, reason, info = TreadmillModule.TierUp(player, treadmillId)
	
	fireResponse(player, "TierUp", success, reason, info)
end

--// Remoite handling
treadmillRequestEvent.OnServerEvent:Connect(function(player, action, treadmillId)
	if action == "StartTraining" then 
		startTraining(player, treadmillId)
		
	elseif action == "StopTraining" then 
		cleanupTraining(player)
		
	elseif action == "ToggleTraining" then
		if activeTraining[player] then 
			cleanupTraining(player)
		else 
			startTraining(player, treadmillId)
		end
		
	elseif action == "UpgradeLevel" then 
		upgradeLevel(player, treadmillId)
		
	elseif action == "TierUp" then 
		tierUp(player, treadmillId)
	end
end)

local function getTreadmillInfo(player, treadmillId)
	treadmillId = tonumber(treadmillId) or 1
	
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
	
	local currentEnergy = TreadmillModule.GetFinalEnergyPerSecond(player, treadmillId, level, stage)
	local nextEnergy = TreadmillModule.GetFinalEnergyPerSecond(player, treadmillId, nextLevel, stage)
	
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
	return getTreadmillInfo(player, treadmillId)
end

Players.PlayerAdded:Connect(function(player)
	TreadmillModule.SetupPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	cleanupTraining(player)
end)

print("TreadmillServer loaded")
