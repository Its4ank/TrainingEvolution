--// TrainerServer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TrainerModule = require(game.ServerScriptService.Modules.TrainerModule)
local XPModule = require(game.ServerScriptService.Modules.XPModule)
local TRAINERS = TrainerModule.Data

local trainerModelsFolder = ReplicatedStorage:WaitForChild("TrainerModels")
local trainerEventFolder = ReplicatedStorage:WaitForChild("TrainerEvent")

local trainerEquipEvent = trainerEventFolder:WaitForChild("TrainerEquipEvent")
local trainerLevelUpEvent = trainerEventFolder:WaitForChild("TrainerLevelUpEvent")
local trainerStageUpEvent = trainerEventFolder:WaitForChild("TrainerStageUpEvent")
local trainerStageResultEvent = trainerEventFolder:WaitForChild("TrainerStageResultEvent")
local closeTrainerMenuEvent = trainerEventFolder:WaitForChild("CloseTrainerMenuEvent")
local playerDataLoadedEvent = trainerEventFolder:WaitForChild("PlayerDataLoadedEvent")
local trainerEquipResultEvent = trainerEventFolder:WaitForChild("TrainerEquipResultEvent")

local backPart = workspace:WaitForChild("TrainerPosBack")

local equippedTrainers = {}
local trainerConnections = {}

local FOLLOW_DISTANCE = 4
local FOLLOW_SIDE_OFFSET = 1.5
local TELEPORT_DISTANCE = 80
local FOLLOW_SPEED = 4

local function createBillboard(trainerModel, data)
	local head = trainerModel:FindFirstChild("Head")
	if not head then return end
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TrainerBillboard"
	billboard.Size = UDim2.new(0, 220, 0, 80)
	billboard.StudsOffset = Vector3.new(0, 2.8, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head
	
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.3
	local stageName = TrainerModule.getStageName(1)
	
	label.Text = tostring(data.DisplayName or "Trainer")
	.. "\nStage: " .. stageName .. "\nLv. 1"
	label.Parent = billboard
end

local function getTrainerFolder(player)
	local folder = player:FindFirstChild("Trainer")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Trainer"
		folder.Parent = player
	end
	return folder
end

local function getOrCreateValue(parent, className, valueName, defaultValue)
	local value = parent:FindFirstChild(valueName)
	
	if not value then
		value = Instance.new(className)
		value.Name = valueName
		value.Value = defaultValue
		value.Parent = parent
	end
	return value
end

local function updateTrainerBillboard(player, trainerName)
	local model = equippedTrainers[player]
	if not model then return end

	local head = model:FindFirstChild("Head")
	if not head then return end

	local billboard = head:FindFirstChild("TrainerBillboard")
	if not billboard then return end

	local label = billboard:FindFirstChild("Text")
	if not label then return end

	local data = TRAINERS[trainerName]
	local folder = getTrainerFolder(player):FindFirstChild(trainerName)
	if not data or not folder then return end
	
	local level = folder:FindFirstChild("Level")
	local stage = folder:FindFirstChild("Stage")
	
	local levelValue = level and level.Value or 1
	local stageValue = stage and stage.Value or 1
	local stageName = TrainerModule.getStageName(stageValue)
	
	label.Text = tostring(data.DisplayName or "Trainer")
	.. "\nStage: " .. stageName .. "\nLv. " .. tostring(levelValue)
end

local function setupTrainerData(player, trainerName)
	local data = TRAINERS[trainerName]
	
	if not data then 
		warn("No trainer data:", trainerName)
		return nil
	end
	
	local trainersFolder = getTrainerFolder(player)
	
	local trainerFolder = trainersFolder:FindFirstChild(trainerName)
	
	if not trainerFolder then
		trainerFolder = Instance.new("Folder")
		trainerFolder.Name = trainerName
		trainerFolder.Parent = trainersFolder
	end
	
	getOrCreateValue(
		trainerFolder,
		"BoolValue",
		"Owned",
		false
	)
	
	getOrCreateValue( 
		trainerFolder,
		"BoolValue",
		"Equipped",
		false
	)
	
	getOrCreateValue(
		trainerFolder,
		"IntValue",
		"Level",
		1
	)
	
	getOrCreateValue(
		trainerFolder,
		"IntValue",
		"XP",
		0
	)
	
	getOrCreateValue(
		trainerFolder,
		"IntValue",
		"Evolution",
		0
	)
	
	getOrCreateValue(
		trainerFolder,
		"IntValue",
		"Stage",
		1
	)
	
	local progreassFolder = trainerFolder:FindFirstChild(
		"RequirementProgress"
	)
	
	if not progreassFolder then
		progreassFolder = Instance.new("Folder")
		progreassFolder.Name = "RequirementProgress"
		progreassFolder.Parent = trainerFolder
	end
	
	if trainerName == "LedyTrainer" then
		getOrCreateValue(
			progreassFolder,
			"NumberValue",
			"Energy",
			0
		)
		
		getOrCreateValue(
			progreassFolder,
			"NumberValue",
			"TrainerTreadmillTime",
			0
		)
		
	elseif trainerName == "BellaTrainer" then
		getOrCreateValue(
			progreassFolder,
			"NumberValue",
			"Money",
			0
		)
		
		getOrCreateValue(
			progreassFolder,
			"NumberValue",
			"TrainerTreadmillTime",
			0
		)
		
	elseif trainerName == "MonikaTrainer" then
		getOrCreateValue(
			progreassFolder,
			"IntValue",
			"EggHatched",
			0
		)
		
		getOrCreateValue(
			progreassFolder,
			"IntValue",
			"PetRarity",
			0
		)
		
	elseif trainerName == "JoeTrainer" then
		getOrCreateValue(
			progreassFolder,
			"IntValue",
			"Rebirth",
			0
		)
		
		getOrCreateValue(
			progreassFolder,
			"IntValue",
			"RaceRewards",
			0
		)
	end
	
	updateTrainerBillboard(player, trainerName)
	
	return trainerFolder
end

local function setupAllTrainers(player)
	for trainerName, data in pairs(TRAINERS) do
		if data.Enabled then
			setupTrainerData(player, trainerName)
		end
	end
end

local function getTrainerXPRequired(level)
	return 100 + (level * 50)
end

local function removeTrainer(player)
	if trainerConnections[player] then
		
		trainerConnections[player]:Disconnect()
		trainerConnections[player] = nil
	end
	
	if equippedTrainers[player] then
		equippedTrainers[player]:Destroy()
		equippedTrainers[player] = nil
	end
end

local function equipTrainer(player, trainerName)
	removeTrainer(player)
	
	local trainerData = TRAINERS[trainerName]
	if not trainerData then return end
	
	local character = player.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local modelTemplate = trainerModelsFolder:FindFirstChild(trainerData.ModelName)
	if not modelTemplate then
		warn("Trainer model not found:", trainerData.ModelName)
		return
	end
	
	local trainerModel = modelTemplate:Clone()
	trainerModel.Name = player.Name .. "_" .. trainerName
	trainerModel.Parent = workspace
	
	local trainerHrp = trainerModel:FindFirstChild("HumanoidRootPart")
	local humanoid = trainerModel:FindFirstChildOfClass("Humanoid")
	
	if not trainerHrp or not humanoid then
		warn("Trainer needs HumanoidRootPart and Humanoid")
		trainerModel:Destroy()
		return
	end
	
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	--IDLE
	local idleAnim = Instance.new("Animation")
	idleAnim.AnimationId = "rbxassetid://507766388"
	
	local idleTrack = animator:LoadAnimation(idleAnim)
	idleTrack.Priority = Enum.AnimationPriority.Idle
	idleTrack.Looped = true
	
	-- RUN
	local runAnim = Instance.new("Animation")
	runAnim.AnimationId = "rbxassetid://913376220"
	
	local runTrack = animator:LoadAnimation(runAnim)
	runTrack.Priority = Enum.AnimationPriority.Movement
	runTrack.Looped = true
	
	idleTrack:Play()
	
	trainerModel.PrimaryPart = trainerHrp
	trainerHrp.CFrame = hrp.CFrame * CFrame.new(FOLLOW_SIDE_OFFSET, 0, FOLLOW_DISTANCE)
	
	trainerHrp.Anchored = true
	humanoid.PlatformStand = true
	
	createBillboard(trainerModel, trainerData)
	
	equippedTrainers[player] = trainerModel
	
	local trainersFolder = getTrainerFolder(player)
	for _, folder in ipairs(trainersFolder:GetChildren()) do
		local eq = folder:FindFirstChild("Equipped")
		if eq then
			eq.Value = false
		end
	end
	
	local trainerFolder = trainersFolder:FindFirstChild(trainerName)
	if trainerFolder and trainerFolder:FindFirstChild("Equipped") then
		trainerFolder.Equipped.Value = true
	end
	
	trainerConnections[player] = RunService.Heartbeat:Connect(function(dt)
		local char = player.Character
		local playerHrp = char and char:FindFirstChild("HumanoidRootPart")
		
		if not playerHrp or not trainerModel.Parent then
			removeTrainer(player)
			return
		end
		
		local followCFrame = playerHrp.CFrame * CFrame.new(FOLLOW_SIDE_OFFSET, 0, FOLLOW_DISTANCE)
		local targetPosition = followCFrame.Position
		
		local distance = (trainerHrp.Position - targetPosition).Magnitude
		
		local targetCFrame = CFrame.new(targetPosition)
		
		if distance > TELEPORT_DISTANCE then
			trainerHrp.CFrame = targetCFrame
		end

		if distance > 3 then
			if not runTrack.IsPlaying then
				idleTrack:Stop()
				runTrack:Play()
			end

			local alpha = math.clamp(dt * FOLLOW_SPEED, 0, 1)
			local lookAt = Vector3.new(playerHrp.Position.X, trainerHrp.Position.Y, playerHrp.Position.Z)
			local desiredCFrame = CFrame.new(targetPosition, lookAt)

			trainerHrp.CFrame = trainerHrp.CFrame:Lerp(desiredCFrame, alpha)
		else
			if not idleTrack.IsPlaying then
				runTrack:Stop()
				idleTrack:Play()
			end
		end
	end)
	
	updateTrainerBillboard(player, trainerName)
end

local function equipSavedTrainer(player)
	local trainerFolder = getTrainerFolder(player)
	
	for _, trainerData in ipairs(trainerFolder:GetChildren()) do 
		local equipped = trainerData:FindFirstChild("Equipped")
		
		if equipped and equipped.Value == true then
			equipTrainer(player, trainerData.Name)
			return
		end
	end
end

local function connectCharacter(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		equipSavedTrainer(player)
	end)
end

Players.PlayerAdded:Connect(function(player)
	setupAllTrainers(player)
	connectCharacter(player)
end)

Players.PlayerRemoving:Connect(function(player)
	removeTrainer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupAllTrainers(player)
	connectCharacter(player)
	
	if player.Character then
		task.wait(1)
		--equipTrainer(player, "TestTrainer")
	end
end

local function getPlayerStat(player, statName)
	local leaderstats = player:FindFirstChild("leaderstats")
	local playerData = player:FindFirstChild("PlayerData")
	
	if leaderstats and leaderstats:FindFirstChild(statName) then
		return leaderstats:FindFirstChild(statName)
	end
	
	if playerData and playerData:FindFirstChild(statName) then
		return playerData:FindFirstChild(statName)
	end
	
	return nil
end

local function buyTrainer(player, trainerName)
	local data = TRAINERS[trainerName]
	if not data or not data.Enabled then
		return false, "InvalidTrainer"
	end
	
	local trainerFolder = getTrainerFolder(player):FindFirstChild(trainerName)
	if not trainerFolder then
		return false, "TrainerFolderMissing"
	end
	
	local owned = trainerFolder:FindFirstChild("Owned")
	if not owned then
		return false, "OwnedValueMissing"
	end
	
	if owned.Value == true then 
		return true, "AlreadyOwned"
	end
	
	if data.UnlockType == "PetHatched" then
		return false, "ComingSoon"
	end
	
	if data.UnlockType == "Currency" then
		local currency = getPlayerStat(player, data.Currency)
		if not currency then
			return false, "CurrencyMissing"
		end
		
		local price = tonumber(data.Price) or 0
		
		if currency.Value < price then
			return false, "NotEnoughCurrency"
		end
		
		currency.Value -= price
		owned.Value = true
		
		return true, "Purchased"
	end
	return false, "UnsupportedUnlockType"
end

local function getSpendableStat(player, requirementType)
	if requirementType == "Energy" then 
		local leaderstats = player:FindFirstChild("leaderstats")
		
		return leaderstats and leaderstats:FindFirstChild("Energy")
	end
	
	if requirementType == "Money" then
		local playerData = player:FindFirstChild("PlayerData")
		
		if playerData then 
			local money = playerData:FindFirstChild("Money")
			
			if money then 
				return money
			end
		end
		
		local leaderstats = player:FindFirstChild("leaderstats")
		
		return leaderstats and leaderstats:FindFirstChild("Money")
	end
	
	if requirementType == "Rebirth" then 
		local leaderstats = player:FindFirstChild("leaderstats")
		
		return leaderstats and leaderstats:FindFirstChild("Rebirth")
	end
	return nil
end

local function getRequirementCurrentValue(player, trainerName, requirement)
	if not requirement then 
		return 0
	end
	
	local requirementType = requirement.Type
	
	if requirementType == "Level" then
		local trainerFolder = TrainerModule.getTrainerPlayerFolder(player, trainerName)
		
		local level = trainerFolder and trainerFolder:FindFirstChild("Level")
		
		return level and level.Value or 0
	end
	
	return TrainerModule.getRequirementProgress(player, trainerName, requirementType)
end

local function checkStageRequirements(player, trainerName, stageValue)
	
	local requirements = TrainerModule.getStageRequirements(trainerName, stageValue)
	
	local missing = {}
	local allCompleted = true 
	
	for index, requirement in ipairs(requirements) do
		local requirementType = requirement.Type
		local need = tonumber(requirement.Need) or 0
		
		if requirement.Placeholder == true then
			continue
		end
		
		local current = getRequirementCurrentValue(player, trainerName, requirement)
		
		local progressCompleted = current >= need
		local balanceCompleted = true 
		local balanceCurrent = nil
		
		if requirement.Spend == true then 
			local spendableStat = getSpendableStat(player, requirementType)
			
			balanceCurrent = spendableStat and spendableStat.Value or 0
			
			balanceCompleted = balanceCurrent >= need
		end
		
		if not progressCompleted or not balanceCompleted then 
			allCompleted = false
			
			missing[index] = {
				Index = index,
				Type = requirementType,
				
				Current = current,
				Need = need,
				
				ProgressCompleted = progressCompleted,
				
				Spend = requirement.Spend == true,
				BalanceCurrent = balanceCurrent,
				BalanceCompleted = balanceCompleted,
			}
		end
	end
	
	return allCompleted, missing
end

local function spendStageRequirements(player, trainerName, stageValue)
	local requirements = TrainerModule.getStageRequirements(trainerName, stageValue)
	
	for _, requirement in ipairs(requirements) do
		if requirement.Placeholder == true then
			continue
		end
		
		if requirement.Spend == true then 
			local stat = getSpendableStat(player, requirement.Type)
			
			local need = tonumber(requirement.Need) or 0
			
			if stat and need > 0 then
				stat.Value = math.max(0, stat.Value - need)
			end
		end
	end
end

local function resetStageRequirementProgress(player, trainerName, stageValue)
	local requirements = TrainerModule.getStageRequirements(trainerName, stageValue)
	
	for _, requirement in ipairs(requirements) do
		if requirement.ResetOnRankUp == true then
			TrainerModule.resetRequirementProgress(player, trainerName, requirement.Type)
		end
	end
end

playerDataLoadedEvent.Event:Connect(function(player)
	task.wait(0.5)
	
	if player.Character then
		equipSavedTrainer(player)
	end
end)

closeTrainerMenuEvent.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = backPart.CFrame + Vector3.new(0, 3, 0)
end)

trainerEquipEvent.OnServerEvent:Connect(function(player, action, trainerName)
	local data = TRAINERS[trainerName]
	
	if not data or not data.Enabled then
		trainerEquipResultEvent:FireClient(player, false, trainerName, "InvalidTrainer")
		return
	end 
	
	setupTrainerData(player, trainerName)
	
	local trainerFolder = getTrainerFolder(player):FindFirstChild(trainerName)
	if not trainerFolder then
		return
	end
	
	local owned = trainerFolder:FindFirstChild("Owned")
	local equipped = trainerFolder:FindFirstChild("Equipped")
	
	if action == "Equip" then
		if not owned or owned.Value == false then
			local bought, resultType = buyTrainer(player, trainerName)
			if not bought then
				trainerEquipResultEvent:FireClient(player, false, trainerName, resultType)
				return
			end
		end
		
		equipTrainer(player, trainerName)
		
		trainerEquipResultEvent:FireClient(player, true, trainerName, "Equipped")
		return
	end
	
	if action == "Unequip" then
		if equipped and equipped.Value == true then
			removeTrainer(player)
			equipped.Value = false
			
			trainerEquipResultEvent:FireClient(player, true, trainerName, "Unequipped")
		end
		return
	end
end)

trainerLevelUpEvent.OnServerEvent:Connect(function(player, trainerName)
	local data = TRAINERS[trainerName]
	if not data or not data.Enabled then return end
	
	setupTrainerData(player, trainerName)
	
	local trainerFolder = getTrainerFolder(player):FindFirstChild(trainerName)
	if not trainerFolder then return end
	
	local owned = trainerFolder:FindFirstChild("Owned")
	local level = trainerFolder:FindFirstChild("Level")
	
	if not owned or owned.Value == false then return end
	if not level then return end
	
	local stage = trainerFolder:FindFirstChild("Stage")
	local currentStage = stage and stage.Value or 1
	
	local maxLevel = TrainerModule.getStageMaxLevel(currentStage)
	
	if level.Value >= maxLevel then
		warn("Trainer reached max level for current stage:", trainerName, maxLevel)
		return
	end
	
	local cost = getTrainerXPRequired(level.Value)
	
	if not XPModule.hasXP(player, cost) then
		return
	end
	
	local removed = XPModule.removeXP(player, cost)
	if not removed then return end
	level.Value += 1
	
	updateTrainerBillboard(player, trainerName)
end)

trainerStageUpEvent.OnServerEvent:Connect(function(player, trainerName)
	local data = TRAINERS[trainerName]
	
	if not data or not data.Enabled then 
		return
	end
	
	setupTrainerData(player, trainerName)
	
	local trainerFolder = getTrainerFolder(player):FindFirstChild(trainerName)
	
	if not trainerFolder then 
		return
	end
	
	local owned = trainerFolder:FindFirstChild("Owned")
	local level = trainerFolder:FindFirstChild("Level")
	local stage = trainerFolder:FindFirstChild("Stage")
	
	if not owned or owned.Value == false then
		trainerStageResultEvent:FireClient(player, false, trainerName, "NotOwned", {})
		return
	end
	
	if not level or not stage then
		return 
	end
	
	local currentStage = stage.Value
	
	if currentStage >= 5 then
		trainerStageResultEvent:FireClient(player, false, trainerName, "MaxStage", {})
		return
	end
	
	local stageData = TrainerModule.getStageData(currentStage)
	
	if not stageData then
		warn("Stage data not found:", currentStage)
		return
	end
	
	if level.Value < stageData.MaxLevel then
		trainerStageResultEvent:FireClient(player, false, trainerName, "NeedLevel", {
			CurrentLevel = level.Value,
			NeedLevel = stageData.MaxLevel,
		})
		return
	end
	
	local completed, missing = checkStageRequirements(player, trainerName, currentStage)
	
	if not completed then
		trainerStageResultEvent:FireClient(player, false, trainerName, "MissingRequirements", missing)
		return
	end
	
	spendStageRequirements(player, trainerName, currentStage)
	resetStageRequirementProgress(player, trainerName, currentStage)
	
	stage.Value += 1
	level.Value = 1
	
	updateTrainerBillboard(player, trainerName)
	trainerStageResultEvent:FireClient(player, true, trainerName, "StageUpSuccess", {
		OldStage = currentStage,
		NewStage = stage.Value,
		NewStageName = TrainerModule.getStageName(stage.Value),
	})
end)

print("TrainerServer loaded")
