--// TrainerServer 1.2v

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TrainerModule = require(
	ReplicatedStorage.Modules.TrainerModule
)

local XPModule = require(
	ServerScriptService.Modules.XPModule
)

local TRAINERS = TrainerModule.Data

--// Folders

local trainerModelsFolder =
	ReplicatedStorage:WaitForChild("TrainerModels")

local trainerEventFolder =
	ReplicatedStorage:WaitForChild("TrainerEvent")

--// Events

local trainerEquipEvent =
	trainerEventFolder:WaitForChild(
		"TrainerEquipEvent"
	)

local trainerLevelUpEvent =
	trainerEventFolder:WaitForChild(
		"TrainerLevelUpEvent"
	)

local trainerStageUpEvent =
	trainerEventFolder:WaitForChild(
		"TrainerStageUpEvent"
	)

local trainerStageResultEvent =
	trainerEventFolder:WaitForChild(
		"TrainerStageResultEvent"
	)

local closeTrainerMenuEvent =
	trainerEventFolder:WaitForChild(
		"CloseTrainerMenuEvent"
	)

local playerDataLoadedEvent =
	trainerEventFolder:WaitForChild(
		"PlayerDataLoadedEvent"
	)

local trainerEquipResultEvent =
	trainerEventFolder:WaitForChild(
		"TrainerEquipResultEvent"
	)

local trainerLevelResultEvent =
	trainerEventFolder:WaitForChild(
		"TrainerLevelResultEvent"
	)

--// World

local backPart =
	workspace:WaitForChild("TrainerPosBack")

--// Runtime

local equippedTrainers = {}
local trainerConnections = {}

local equipLocks = {}
local levelUpLocks = {}
local stageUpLocks = {}

--// Follow settings

local FOLLOW_DISTANCE = 4
local FOLLOW_SIDE_OFFSET = 1.5
local TELEPORT_DISTANCE = 80
local FOLLOW_SPEED = 4

--==================================================
-- Utility
--==================================================

local function runWithPlayerLock(
	lockTable,
	player,
	callback
)
	if lockTable[player] then
		return
	end

	lockTable[player] = true

	local success, errorMessage =
		pcall(callback)

	lockTable[player] = nil

	if not success then
		warn(
			"[TrainerServer] Operation failed:",
			player.Name,
			errorMessage
		)
	end
end

local function getTrainerFolder(player)
	local folder =
		player:FindFirstChild("Trainer")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Trainer"
		folder.Parent = player
	end

	return folder
end

local function getOrCreateValue(
	parent,
	className,
	valueName,
	defaultValue
)
	local value =
		parent:FindFirstChild(valueName)

	if value and not value:IsA(className) then
		warn(
			"[TrainerServer] Wrong class:",
			value:GetFullName(),
			"expected",
			className,
			"got",
			value.ClassName
		)

		value:Destroy()
		value = nil
	end

	if not value then
		value = Instance.new(className)
		value.Name = valueName
		value.Value = defaultValue
		value.Parent = parent
	end

	return value
end

local function getPlayerStat(
	player,
	statName
)
	local leaderstats =
		player:FindFirstChild("leaderstats")

	local playerData =
		player:FindFirstChild("PlayerData")

	if leaderstats then
		local value =
			leaderstats:FindFirstChild(statName)

		if value then
			return value
		end
	end

	if playerData then
		local value =
			playerData:FindFirstChild(statName)

		if value then
			return value
		end
	end

	return nil
end

local function getSpendableStat(
	player,
	requirementType
)
	if requirementType == "Energy" then
		return getPlayerStat(
			player,
			"Energy"
		)
	end

	if requirementType == "Money" then
		return getPlayerStat(
			player,
			"Money"
		)
	end

	if requirementType == "Rebirth" then
		return getPlayerStat(
			player,
			"Rebirth"
		)
	end

	return nil
end

--==================================================
-- Billboard
--==================================================

local function createBillboard(
	trainerModel,
	trainerData
)
	local head =
		trainerModel:FindFirstChild("Head")

	if not head then
		return
	end

	local oldBillboard =
		head:FindFirstChild(
			"TrainerBillboard"
		)

	if oldBillboard then
		oldBillboard:Destroy()
	end

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name = "TrainerBillboard"
	billboard.Size =
		UDim2.new(0, 220, 0, 80)

	billboard.StudsOffset =
		Vector3.new(0, 2.8, 0)

	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label =
		Instance.new("TextLabel")

	label.Name = "Text"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	label.TextStrokeTransparency = 0.3

	label.Text =
		tostring(
			trainerData.DisplayName
			or "Trainer"
		)
		.. "\nStage: Rookie"
		.. "\nLv. 1"

	label.Parent = billboard
end

local function updateTrainerBillboard(
	player,
	trainerName
)
	local model =
		equippedTrainers[player]

	if not model then
		return
	end

	local head =
		model:FindFirstChild("Head")

	if not head then
		return
	end

	local billboard =
		head:FindFirstChild(
			"TrainerBillboard"
		)

	if not billboard then
		return
	end

	local label =
		billboard:FindFirstChild("Text")

	if not label then
		return
	end

	local trainerData =
		TRAINERS[trainerName]

	local trainerFolder =
		getTrainerFolder(player)
		:FindFirstChild(trainerName)

	if not trainerData
		or not trainerFolder then

		return
	end

	local level =
		trainerFolder:FindFirstChild(
			"Level"
		)

	local stage =
		trainerFolder:FindFirstChild(
			"Stage"
		)

	local levelValue =
		level and level.Value or 1

	local stageValue =
		stage and stage.Value or 1

	local stageName =
		TrainerModule.getStageName(
			stageValue
		)

	label.Text =
		tostring(
			trainerData.DisplayName
			or "Trainer"
		)
		.. "\nStage: "
		.. stageName
		.. "\nLv. "
		.. tostring(levelValue)
end

--==================================================
-- Player trainer data
--==================================================

local function setupTrainerData(
	player,
	trainerName
)
	local trainerData =
		TRAINERS[trainerName]

	if not trainerData then
		warn(
			"[TrainerServer] Trainer data missing:",
			trainerName
		)

		return nil
	end

	local trainersFolder =
		getTrainerFolder(player)

	local trainerFolder =
		trainersFolder:FindFirstChild(
			trainerName
		)

	if not trainerFolder then
		trainerFolder =
			Instance.new("Folder")

		trainerFolder.Name =
			trainerName

		trainerFolder.Parent =
			trainersFolder
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
		"Stage",
		1
	)

	getOrCreateValue(
		trainerFolder,
		"IntValue",
		"Evolution",
		0
	)

	local progressFolder =
		trainerFolder:FindFirstChild(
			"RequirementProgress"
		)

	if not progressFolder then
		progressFolder =
			Instance.new("Folder")

		progressFolder.Name =
			"RequirementProgress"

		progressFolder.Parent =
			trainerFolder
	end

	local progressConfig =
		TrainerModule.ProgressValues[trainerName]

	if progressConfig then
		for valueName, className
			in pairs(progressConfig) do

			getOrCreateValue(
				progressFolder,
				className,
				valueName,
				0
			)
		end
	end

	return trainerFolder
end

local function setupAllTrainers(player)
	for trainerName, trainerData
		in pairs(TRAINERS) do

		if trainerData.Enabled then
			setupTrainerData(
				player,
				trainerName
			)
		end
	end
end

--==================================================
-- Trainer model
--==================================================

local function removeTrainer(player)
	local connection =
		trainerConnections[player]

	if connection then
		connection:Disconnect()
		trainerConnections[player] = nil
	end

	local model =
		equippedTrainers[player]

	if model then
		model:Destroy()
		equippedTrainers[player] = nil
	end
end

local function equipTrainer(
	player,
	trainerName
)
	local trainerData =
		TRAINERS[trainerName]

	if not trainerData then
		return false, "InvalidTrainer"
	end

	local character =
		player.Character

	if not character then
		return false, "CharacterMissing"
	end

	local playerHrp =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not playerHrp then
		return false, "CharacterMissing"
	end

	local modelTemplate =
		trainerModelsFolder:FindFirstChild(
			trainerData.ModelName
		)

	if not modelTemplate then
		warn(
			"[TrainerServer] Model missing:",
			trainerData.ModelName
		)

		return false, "ModelMissing"
	end

	removeTrainer(player)

	local trainerModel =
		modelTemplate:Clone()

	trainerModel.Name =
		player.Name
		.. "_"
		.. trainerName

	trainerModel.Parent = workspace

	local trainerHrp =
		trainerModel:FindFirstChild(
			"HumanoidRootPart"
		)

	local humanoid =
		trainerModel:FindFirstChildOfClass(
			"Humanoid"
		)

	if not trainerHrp or not humanoid then
		trainerModel:Destroy()

		return false, "InvalidModel"
	end

	humanoid.DisplayDistanceType =
		Enum.HumanoidDisplayDistanceType.None

	local animator =
		humanoid:FindFirstChildOfClass(
			"Animator"
		)

	if not animator then
		animator =
			Instance.new("Animator")

		animator.Parent = humanoid
	end

	local idleAnimation =
		Instance.new("Animation")

	idleAnimation.AnimationId =
		"rbxassetid://507766388"

	local idleTrack =
		animator:LoadAnimation(
			idleAnimation
		)

	idleTrack.Priority =
		Enum.AnimationPriority.Idle

	idleTrack.Looped = true

	local runAnimation =
		Instance.new("Animation")

	runAnimation.AnimationId =
		"rbxassetid://913376220"

	local runTrack =
		animator:LoadAnimation(
			runAnimation
		)

	runTrack.Priority =
		Enum.AnimationPriority.Movement

	runTrack.Looped = true

	trainerModel.PrimaryPart =
		trainerHrp

	trainerHrp.CFrame =
		playerHrp.CFrame
		* CFrame.new(
			FOLLOW_SIDE_OFFSET,
			0,
			FOLLOW_DISTANCE
		)

	trainerHrp.Anchored = true
	humanoid.PlatformStand = true

	createBillboard(
		trainerModel,
		trainerData
	)

	equippedTrainers[player] =
		trainerModel

	local trainersFolder =
		getTrainerFolder(player)

	for _, folder
		in ipairs(
			trainersFolder:GetChildren()
		) do

		local equipped =
			folder:FindFirstChild(
				"Equipped"
			)

		if equipped then
			equipped.Value = false
		end
	end

	local selectedFolder =
		trainersFolder:FindFirstChild(
			trainerName
		)

	local selectedEquipped =
		selectedFolder
		and selectedFolder:FindFirstChild(
			"Equipped"
		)

	if selectedEquipped then
		selectedEquipped.Value = true
	end

	idleTrack:Play()

	trainerConnections[player] =
		RunService.Heartbeat:Connect(
			function(deltaTime)
				local currentCharacter = player.Character

				local currentPlayerHrp = currentCharacter
				and currentCharacter
				:FindFirstChild(
					"HumanoidRootPart"
				)

				if not currentPlayerHrp	or not trainerModel.Parent or not trainerHrp.Parent then

					removeTrainer(player)
					return
				end

				local followCFrame = currentPlayerHrp.CFrame
				* CFrame.new(
					FOLLOW_SIDE_OFFSET,
					0,
					FOLLOW_DISTANCE
				)

				local targetPosition = followCFrame.Position

				local distance = (
					trainerHrp.Position
					- targetPosition
				).Magnitude

				local lookAt = Vector3.new(
					currentPlayerHrp.Position.X,
					targetPosition.Y,
					currentPlayerHrp.Position.Z
				)

				local desiredCFrame = CFrame.new(
					targetPosition,
					lookAt
				)

				-- Если тренер слишком далеко,
				-- сразу переносим его и завершаем этот кадр.
				if distance > TELEPORT_DISTANCE then
					trainerHrp.CFrame = desiredCFrame

					if runTrack.IsPlaying then
						runTrack:Stop()
					end

					if not idleTrack.IsPlaying then
						idleTrack:Play()
					end

					return
				end

				if distance > 3 then
					if not runTrack.IsPlaying then
						idleTrack:Stop()
						runTrack:Play()
					end

					local alpha = math.clamp(
						deltaTime * FOLLOW_SPEED,
						0,
						1
					)

					trainerHrp.CFrame = trainerHrp.CFrame:Lerp(
						desiredCFrame,
						alpha
					)
				else
					if runTrack.IsPlaying then
						runTrack:Stop()
					end

					if not idleTrack.IsPlaying then
						idleTrack:Play()
					end
				end
			end
		)

	updateTrainerBillboard(
		player,
		trainerName
	)

	return true, "Equipped"
end

local function equipSavedTrainer(player)
	local trainersFolder =
		getTrainerFolder(player)

	local savedTrainerName = nil

	for _, trainerFolder in ipairs(
		trainersFolder:GetChildren()
		) do
		local equipped =
			trainerFolder:FindFirstChild(
				"Equipped"
			)

		local owned =
			trainerFolder:FindFirstChild(
				"Owned"
			)

		if equipped
			and equipped.Value == true
			and owned
			and owned.Value == true then

			if not savedTrainerName then
				savedTrainerName =
					trainerFolder.Name
			else
				equipped.Value = false
			end
		end
	end

	if savedTrainerName then
		equipTrainer(
			player,
			savedTrainerName
		)
	end
end

--==================================================
-- Buying
--==================================================

local function buyTrainer(
	player,
	trainerName
)
	local trainerData =
		TRAINERS[trainerName]

	if not trainerData
		or not trainerData.Enabled then

		return false, "InvalidTrainer"
	end

	local trainerFolder =
		getTrainerFolder(player)
		:FindFirstChild(trainerName)

	if not trainerFolder then
		return false, "TrainerFolderMissing"
	end

	local owned =
		trainerFolder:FindFirstChild(
			"Owned"
		)

	if not owned then
		return false, "OwnedValueMissing"
	end

	if owned.Value == true then
		return true, "AlreadyOwned"
	end

	if trainerData.UnlockType
		== "EggHatched" then

		local playerData =
			player:FindFirstChild(
				"PlayerData"
			)

		local eggHatched =
			playerData
			and playerData:FindFirstChild(
				"EggHatched"
			)

		if not eggHatched then
			return false,
				"EggHatchedMissing"
		end

		local requiredPets =
			math.max(
				0,
				tonumber(
					trainerData.RequiredPets
				) or 0
			)

		if eggHatched.Value
			< requiredPets then

			return false,
				"NotEnoughEggHatched"
		end

		owned.Value = true

		return true, "Purchased"
	end

	if trainerData.UnlockType
		== "Currency" then

		local currency =
			getPlayerStat(
				player,
				trainerData.Currency
			)

		if not currency then
			return false,
				"CurrencyMissing"
		end

		local price =
			math.max(
				0,
				tonumber(
					trainerData.Price
				) or 0
			)

		if currency.Value < price then
			return false,
				"NotEnoughCurrency"
		end

		currency.Value -= price
		owned.Value = true

		return true, "Purchased"
	end

	return false, "UnsupportedUnlockType"
end

--==================================================
-- Rank requirements
--==================================================

local function getRequirementCurrentValue(
	player,
	trainerName,
	requirement
)
	if not requirement then
		return 0
	end

	if requirement.Type == "Level" then
		local trainerFolder =
			TrainerModule
			.getTrainerPlayerFolder(
				player,
				trainerName
			)

		local level =
			trainerFolder
			and trainerFolder:FindFirstChild(
				"Level"
			)

		return level and level.Value or 0
	end

	return TrainerModule
		.getRequirementProgress(
			player,
			trainerName,
			requirement.Type
		)
end

local function checkStageRequirements(
	player,
	trainerName,
	stageValue
)
	local requirements =
		TrainerModule.getStageRequirements(
			trainerName,
			stageValue
		)

	local missing = {}
	local allCompleted = true

	for index, requirement
		in ipairs(requirements) do

		if requirement.Placeholder == true then
			continue
		end

		local need =
			math.max(
				0,
				tonumber(
					requirement.Need
				) or 0
			)

		local current =
			getRequirementCurrentValue(
				player,
				trainerName,
				requirement
			)

		local progressCompleted =
			current >= need

		local balanceCompleted = true
		local balanceCurrent = nil

		if requirement.Spend == true then
			local spendableStat =
				getSpendableStat(
					player,
					requirement.Type
				)

			balanceCurrent =
				spendableStat
				and spendableStat.Value
				or 0

			balanceCompleted =
				balanceCurrent >= need
		end

		if not progressCompleted
			or not balanceCompleted then

			allCompleted = false

			missing[index] = {
				Index = index,
				Type = requirement.Type,

				Current = current,
				Need = need,

				ProgressCompleted =
					progressCompleted,

				Spend =
					requirement.Spend
					== true,

				BalanceCurrent =
					balanceCurrent,

				BalanceCompleted =
					balanceCompleted,
			}
		end
	end

	return allCompleted, missing
end

local function spendStageRequirements(
	player,
	trainerName,
	stageValue
)
	local requirements =
		TrainerModule.getStageRequirements(
			trainerName,
			stageValue
		)

	for _, requirement
		in ipairs(requirements) do

		if requirement.Placeholder == true then
			continue
		end

		if requirement.Spend == true then
			local stat =
				getSpendableStat(
					player,
					requirement.Type
				)

			local need =
				math.max(
					0,
					tonumber(
						requirement.Need
					) or 0
				)

			if stat and need > 0 then
				stat.Value =
					math.max(
						0,
						stat.Value - need
					)
			end
		end
	end
end

local function resetStageRequirementProgress(
	player,
	trainerName,
	stageValue
)
	local requirements =
		TrainerModule.getStageRequirements(
			trainerName,
			stageValue
		)

	for _, requirement
		in ipairs(requirements) do

		if requirement.ResetOnRankUp
			== true then

			TrainerModule
				.resetRequirementProgress(
					player,
					trainerName,
					requirement.Type
				)
		end
	end
end

--==================================================
-- Equip event
--==================================================

local function processEquipRequest(
	player,
	action,
	trainerName
)
	local trainerData =
		TRAINERS[trainerName]

	if not trainerData
		or not trainerData.Enabled then

		trainerEquipResultEvent:FireClient(
			player,
			false,
			trainerName,
			"InvalidTrainer"
		)

		return
	end

	setupTrainerData(
		player,
		trainerName
	)

	local trainerFolder =
		getTrainerFolder(player)
		:FindFirstChild(trainerName)

	if not trainerFolder then
		return
	end

	local owned =
		trainerFolder:FindFirstChild(
			"Owned"
		)

	local equipped =
		trainerFolder:FindFirstChild(
			"Equipped"
		)

	if action == "Equip" then
		if not owned
			or owned.Value == false then

			local purchased,
				purchaseResult =
				buyTrainer(
					player,
					trainerName
				)

			if not purchased then
				trainerEquipResultEvent
					:FireClient(
						player,
						false,
						trainerName,
						purchaseResult
					)

				return
			end
		end

		local success,
			equipResult =
			equipTrainer(
				player,
				trainerName
			)

		trainerEquipResultEvent:FireClient(
			player,
			success,
			trainerName,
			equipResult
		)

		return
	end

	if action == "Unequip" then
		if equipped
			and equipped.Value == true then

			removeTrainer(player)
			equipped.Value = false

			trainerEquipResultEvent:FireClient(
				player,
				true,
				trainerName,
				"Unequipped"
			)
		end

		return
	end

	trainerEquipResultEvent:FireClient(
		player,
		false,
		trainerName,
		"InvalidAction"
	)
end

trainerEquipEvent.OnServerEvent:Connect(
	function(player, action, trainerName)
		runWithPlayerLock(
			equipLocks,
			player,
			function()
				processEquipRequest(
					player,
					action,
					trainerName
				)
			end
		)
	end
)

--==================================================
-- Level Up
--==================================================

local function processLevelUp(
	player,
	trainerName
)
	local trainerData =
		TRAINERS[trainerName]

	if not trainerData
		or not trainerData.Enabled then

		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"InvalidTrainer",
			{}
		)

		return
	end

	local trainerFolder =
		setupTrainerData(
			player,
			trainerName
		)

	if not trainerFolder then
		return
	end

	local owned =
		trainerFolder:FindFirstChild(
			"Owned"
		)

	local level =
		trainerFolder:FindFirstChild(
			"Level"
		)

	local stage =
		trainerFolder:FindFirstChild(
			"Stage"
		)

	if not owned
		or owned.Value == false then

		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"NotOwned",
			{}
		)

		return
	end

	if not level or not stage then
		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"DataMissing",
			{}
		)

		return
	end

	local maxLevel =
		TrainerModule.getStageMaxLevel(
			stage.Value
		)

	if level.Value >= maxLevel then
		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"MaxLevel",
			{
				CurrentLevel = level.Value,
				MaxLevel = maxLevel,
			}
		)

		return
	end

	local cost =
		TrainerModule.getLevelUpCost(
			level.Value
		)

	if not cost then
		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"CostMissing",
			{}
		)

		return
	end

	local money =
		getPlayerStat(
			player,
			"Money"
		)

	local currentXP =
		XPModule.getXP(player)

	if not money then
		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"ResourceMissing",
			{}
		)

		return
	end

	local moneyCost =
		math.max(
			0,
			math.floor(
				tonumber(cost.Money)
				or 0
			)
		)

	local xpCost =
		math.max(
			0,
			math.floor(
				tonumber(cost.XP)
				or 0
			)
		)

	local missingMoney =
		math.max(
			0,
			moneyCost - money.Value
		)

	local missingXP =
		math.max(
			0,
			xpCost - currentXP
		)

	if missingMoney > 0
		or missingXP > 0 then

		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"NotEnoughResources",
			{
				MissingMoney =
					missingMoney,

				MissingXP =
					missingXP,

				CurrentMoney =
					money.Value,

				CurrentXP =
					currentXP,

				NeedMoney =
					moneyCost,

				NeedXP =
					xpCost,
			}
		)

		return
	end

	-- Повторная серверная проверка XP
	-- перед фактическим списанием.

	if not XPModule.hasXP(
		player,
		xpCost
		) then
		trainerLevelResultEvent:FireClient(
			player,
			false,
			trainerName,
			"NotEnoughResources",
			{
				MissingMoney = 0,
				MissingXP =
					math.max(
						0,
						xpCost
						- XPModule
						.getXP(player)
					),

				NeedMoney = moneyCost,
				NeedXP = xpCost,
			}
		)

		return
	end

	local oldMomey = money.Value
	local oldXP = XPModule.getXP(player)
	local oldLevel = level.Value
	
	local transactionSuccess, transactionError = pcall(function()
		local removeXP = XPModule.removeXP(player, xpCost)
		if not removeXP then
			error("XPRemoveFailed")
		end
		
		money.Value -= moneyCost
		level.Value += 1
	end)
	
	if not transactionSuccess then
		money.Value = oldMomey
		
		local currentXP = XPModule.getXP(player)
		if currentXP < oldXP then
			XPModule.addXP(player, oldXP - currentXP)
		end
		
		level.Value = oldLevel
		
		warn("[TrainerServer] Level transaction failed:", player.Name, trainerName, transactionError)
		
		trainerLevelResultEvent:FireClient(player, false, trainerName, "LevelTransactionFiled", {})
		return
	end

	updateTrainerBillboard(
		player,
		trainerName
	)

	trainerLevelResultEvent:FireClient(
		player,
		true,
		trainerName,
		"LevelUpSuccess",
		{
			NewLevel = level.Value,
			SpentMoney = moneyCost,
			SpentXP = xpCost,
		}
	)
end

trainerLevelUpEvent.OnServerEvent:Connect(
	function(player, trainerName)
		runWithPlayerLock(
			levelUpLocks,
			player,
			function()
				processLevelUp(
					player,
					trainerName
				)
			end
		)
	end
)

--==================================================
-- Rank Up
--==================================================

local function processStageUp(
	player,
	trainerName
)
	local trainerData =
		TRAINERS[trainerName]

	if not trainerData
		or not trainerData.Enabled then

		return
	end

	local trainerFolder =
		setupTrainerData(
			player,
			trainerName
		)

	if not trainerFolder then
		return
	end

	local owned =
		trainerFolder:FindFirstChild(
			"Owned"
		)

	local level =
		trainerFolder:FindFirstChild(
			"Level"
		)

	local stage =
		trainerFolder:FindFirstChild(
			"Stage"
		)

	if not owned
		or owned.Value == false then

		trainerStageResultEvent:FireClient(
			player,
			false,
			trainerName,
			"NotOwned",
			{}
		)

		return
	end

	if not level or not stage then
		return
	end

	local currentStage =
		stage.Value

	if currentStage >= 5 then
		trainerStageResultEvent:FireClient(
			player,
			false,
			trainerName,
			"MaxStage",
			{}
		)

		return
	end

	local stageData =
		TrainerModule.getStageData(
			currentStage
		)

	if not stageData then
		trainerStageResultEvent:FireClient(
			player,
			false,
			trainerName,
			"StageDataMissing",
			{}
		)

		return
	end

	-- Для повышения ранга тренер должен
	-- достичь максимального уровня
	-- ТЕКУЩЕГО ранга:
	--
	-- Rookie   -> 5
	-- Athlete  -> 10
	-- Champion -> 15
	-- Titan    -> 20

	if level.Value < stageData.MaxLevel then
		trainerStageResultEvent:FireClient(
			player,
			false,
			trainerName,
			"NeedLevel",
			{
				CurrentLevel =
					level.Value,

				NeedLevel =
					stageData.MaxLevel,
			}
		)

		return
	end

	local completed, missing =
		checkStageRequirements(
			player,
			trainerName,
			currentStage
		)

	if not completed then
		trainerStageResultEvent:FireClient(
			player,
			false,
			trainerName,
			"MissingRequirements",
			missing
		)

		return
	end

	spendStageRequirements(
		player,
		trainerName,
		currentStage
	)

	resetStageRequirementProgress(
		player,
		trainerName,
		currentStage
	)

	local oldStage =
		currentStage

	-- ВАЖНО:
	-- уровень НЕ сбрасывается.
	stage.Value += 1

	local srRobuxReward = 0

	if oldStage == 4
		and stage.Value == 5 then

		local playerData =
			player:FindFirstChild(
				"PlayerData"
			)

		local srRobux =
			playerData
			and playerData:FindFirstChild(
				"SrRobux"
			)

		if srRobux then
			srRobuxReward = 2
			srRobux.Value += 2
		else
			warn(
				"[TrainerServer] SrRobux missing:",
				player.Name
			)
		end
	end

	updateTrainerBillboard(
		player,
		trainerName
	)

	trainerStageResultEvent:FireClient(
		player,
		true,
		trainerName,
		"StageUpSuccess",
		{
			OldStage = oldStage,
			NewStage = stage.Value,

			CurrentLevel =
				level.Value,

			NewMaxLevel =
				TrainerModule
				.getStageMaxLevel(
					stage.Value
				),

			NewStageName =
				TrainerModule
				.getStageName(
					stage.Value
				),

			SrRobuxReward =
				srRobuxReward,
		}
	)
end

trainerStageUpEvent.OnServerEvent:Connect(
	function(player, trainerName)
		runWithPlayerLock(
			stageUpLocks,
			player,
			function()
				processStageUp(
					player,
					trainerName
				)
			end
		)
	end
)

--==================================================
-- Menu close / teleport
--==================================================

closeTrainerMenuEvent.OnServerEvent:Connect(
	function(player)
		local character =
			player.Character

		if not character then
			return
		end

		local hrp =
			character:FindFirstChild(
				"HumanoidRootPart"
			)

		if not hrp then
			return
		end

		hrp.CFrame =
			backPart.CFrame
			* CFrame.new(0, 3, 0)
	end
)

--==================================================
-- Player lifecycle
--==================================================

local function connectCharacter(player)
	player.CharacterAdded:Connect(function(character)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
		
		if not humanoidRootPart then
			warn("[TrainerServer] HumanoidRootPart timeout:", player.Data)
			return
		end
		
		if player:GetAttribute("DataReady") ~= true then
			return
		end
		
		task.wait(0.25)
		
		if player.Character ~= character then
			return
		end
		equipSavedTrainer(player)
	end)
end

Players.PlayerAdded:Connect(
	function(player)
		setupAllTrainers(player)
		connectCharacter(player)
	end
)

playerDataLoadedEvent.Event:Connect(function(player)
	if not player or not player.Parent then
		return
	end
	
	setupAllTrainers(player)
	
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
	
	if not humanoidRootPart then
		warn("[TrainerServer] HumanoidRootPart missing after data load:", player.Name)
		return
	end
	
	task.wait(0.25)
	
	if player.Character ~= character then
		return
	end
	
	equipSavedTrainer(player)
end)
	

Players.PlayerRemoving:Connect(
	function(player)
		removeTrainer(player)

		equipLocks[player] = nil
		levelUpLocks[player] = nil
		stageUpLocks[player] = nil
	end
)

for _, player in ipairs(Players:GetPlayers()) do
	setupAllTrainers(player)
	connectCharacter(player)

	if player:GetAttribute("DataReady") == true and player.Character then
		task.defer(function()
			if player.Parent and player.Character then
				equipSavedTrainer(player)
			end
		end)
	end
end

print("TrainerServer loaded")
