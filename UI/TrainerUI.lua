--// TrainerUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)
local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReady(player)
MenuManager.init(raceGui)

--// Иконки
local ICONS = {
	--Звезды ранга
	StageStarActive = "rbxassetid://117035434388256",
	StageStarInactive = "rbxassetid://105741165654536",
	
	-- Специальности тренера
	SpecialEnergy = "rbxassetid://97563972013859",
	SpecialMoney = "rbxassetid://106068703860201",
	SpecialPetLuck = "rbxassetid://84934349596853",
	SpecialPower = "rbxassetid://84748246477718",
	
	-- Валюта в правом верхнем блоке
	LeaderEnergy = "rbxassetid://74509086636062",
	LeaderMoney = "rbxassetid://123691959584167",
	LeaderRebirth = "rbxassetid://91670074635222",
	LeaderEgg = "rbxassetid://73197884503844",
	
	-- Требоания ранкап
	RequirementLevel = "rbxassetid://139561962294465",
	RequirementEnergy = "rbxassetid://74509086636062",
	RequirementMoney = "rbxassetid://123691959584167",
	RequirementTime = "rbxassetid://104625083427194",
	RequirementEgg = "rbxassetid://73197884503844",
	RequirementPet = "rbxassetid://100104272754861",
	RequirementRebirth = "rbxassetid://91670074635222",
	RequirementRace = "rbxassetid://96359633366140",
	
	-- иконка текущего бонуса в ранкап
	BoostEnergy = "rbxassetid://74509086636062",
	BoostMoney = "rbxassetid://123691959584167",
	BoostPetLuck = "rbxassetid://133756841733950",
	BoostPower = "rbxassetid://106902968675278",
	
	-- два состояни кнопки еквипет
	EquipButton = "rbxassetid://101363862301835",
	EquippedButton = "rbxassetid://125946369743403",
}

--// Тренера
local TRAINER_INFO = {
	LedyTrainer = {
		DisplayName = "LEDY",
		Specialty = "Energy Trainer",
		ModelName = "LedyTrainer",
		PriceText = "5000 ENERGY",
		
		InfoText = "The Lady Trainer may look sweet and charming at first glance, but behind those beautiful eyes hides a truly dedicated and disciplined coach. With her by your side, your training efficiency will rise to a whole new level.",
		
		SpecialIcon = ICONS.SpecialEnergy,
		LeaderIcon = ICONS.LeaderEnergy,
		LeaderValueType = "Energy",
		
		PrimaryBoostName = "Energy",
		BaseBoost1 = 20,
		BaseBoost2 = 0,
	},
	
	BellaTrainer = {
		DisplayName = "Bella",
		Specialty = "Money Trainer",
		ModelName = "BellaTrainer",
		PriceText = "1000 Money",
		
		InfoText = "Bella is a true master of money-making. With her charm and experience, she helps you earn much more money from races and rewards. Her beauty is only matched by her incredible talent for turning every run into profit.",
		
		SpecialIcon = ICONS.SpecialMoney,
		LeaderIcon = ICONS.LeaderMoney,
		LeaderValueType = "Money",
		
		PrimaryBoostName = "Money",
		BaseBoost1 = 20,
		BaseBoost2 = 0,
	},
	
	MonikaTrainer = {
		DisplayName = "Monika",
		Specialty = "Luck Trainer",
		ModelName = "MonikaTrainer",
		PriceText = "COMING SOON",
		
		InfoText = "Monika’s middle name is Lady Luck. Wherever Monika appears, luck follows close behind. If you manage to win her heart, consider yourself lucky already — because with Monika by your side, fortune is always on your side.",
		
		SpecialIcon = ICONS.SpecialPetLuck,
		LeaderIcon = ICONS.LeaderEgg,
		LeaderValueType = "EggHatched",
		
		PrimaryBoostName = "PetLuck",
		SecondaryBoostName = "RACE XP",
		
		BaseBoost1 = 20,
		BaseBoost2 = 10,
	},
	
	JoeTrainer = {
		DisplayName = "Joe",
		Specialty = "Power/Acc Trainer",
		ModelName = "JoeTrainer",
		PriceText = "100 Rebirth",
		
		InfoText = "Joe may look serious, but that’s exactly what makes him dangerous. With his intimidating presence and relentless discipline, he pushes you to run faster and harder in every race. Because when Joe is watching, slowing down is not an option.",
		
		SpecialIcon = ICONS.SpecialPower,
		LeaderIcon = ICONS.LeaderRebirth,
		LeaderValueType = "Rebirth",
		
		PrimaryBoostName = "Power",
		SecondaryBoostName = "Acceleration",
		
		BaseBoost1 = 15,
		BaseBoost2 = 15,
	},
}

--// ранги
local STAGE_NAMES = {
	[1] = "Rookie",
	[2] = "Athlete",
	[3] = "Champion",
	[4] = "Titan",
	[5] = "Mythic",
}

local STAGE_MAX_LEVELS = {
	[1] = 5,
	[2] = 10,
	[3] = 15,
	[4] = 20,
	[5] = 25,
}

local STAGE_MULTIPLIERS = {
	[1] = 1.0,
	[2] = 1.1,
	[3] = 1.2,
	[4] = 1.3,
	[5] = 1.4,
}

--// требования
local STAGE_REQUIREMENTS = {
	LedyTrainer = {
		[1] = {
			{Type = "Level", Need = 5},
			{Type = "Energy", Need = 1000},
			{Type = "TrainerTreadmillTime", Need = 60},
		},

		[2] = { 
			{Type = "Level", Need = 10},
			{Type = "Energy", Need = 5000},
			{Type = "TrainerTreadmillTime", Need = 180},
		},

		[3] = {
			{Type = "Level", Need = 15},
			{Type = "Energy", Need = 25000},
			{Type = "TrainerTreadmillTime", Need = 300},
		},

		[4] = {
			{Type = "Level", Need = 20},
			{Type = "Energy", Need = 100000},
			{Type = "TrainerTreadmillTime", Need = 600},
		},
	},
	
	BellaTrainer = {
		[1] = {
			{Type = "Level", Need = 5},
			{Type = "Money", Need = 1000},
			{Type = "TrainerTreadmillTime", Need = 60},
		},
		
		[2] = {
			{Type = "Level", Need = 10},
			{Type = "Money", Need = 5000},
			{Type = "TrainerTreadmillTime", Need = 180},
		},
		
		[3] = {
			{Type = "Level", Need = 15},
			{Type = "Money", Need = 25000},
			{Type = "TrainerTreadmillTime", Need = 300},
		},
		
		[4] = {
			{Type = "Level", Need = 20},
			{Type = "Money", Need = 100000},
			{Type = "TrainerTreadmillTime", Need = 600},
		},
	},
	
	MonikaTrainer = {
		[1] = {
			{Type = "Level", Need = 5},
			{Type = "EggHatched", Need = 0},
			{Type = "PetRarity", Need = 5},
		},
		
		[2] = {
			{Type = "Level", Need = 10},
			{Type = "EggHatched", Need = 0},
			{Type = "PetRarity", Need = 5},
		},
		
		[3] = {
			{Type = "Level", Need = 15},
			{Type = "EggHatched", Need = 0},
			{Type = "PetRarity", Need = 15},
		},
		
		[4] = {
			{Type = "Level", Need = 20},
			{Type = "EggHatched", Need = 0},
			{Type = "PetRarity", Need = 10},
		},
	},
	
	JoeTrainer = {
		[1] = {
			{Type = "Level", Need = 5},
			{Type = "Rebirth", Need = 100},
			{Type = "RaceRewards", Need = 50},
		},
		
		[2] = {
			{Type = "Level", Need = 10},
			{Type = "Rebirth", Need = 500},
			{Type = "RaceRewards", Need = 100},
		},
		
		[3] = {
			{Type = "Level", Need = 15},
			{Type = "Rebirth", Need = 1000},
			{Type = "RaceRewards", Need = 150},
		},
		
		[4] = {
			{Type = "Level", Need = 20},
			{Type = "Rebirth", Need = 2500},
			{Type = "RaceRewards", Need = 200},
		},
	},
}

local guiFolder = raceGui:WaitForChild("GuiFolder")


--// REMOTE EVENTS
local trainerEventFolder = ReplicatedStorage:WaitForChild("TrainerEvent")
local trainerModelsFolder = ReplicatedStorage:WaitForChild("TrainerModels")

local trainerEquipEvent = trainerEventFolder:WaitForChild("TrainerEquipEvent")
local trainerLevelUpEvent = trainerEventFolder:WaitForChild("TrainerLevelUpEvent")
local trainerStageUpEvent = trainerEventFolder:WaitForChild("TrainerStageUpEvent")
local trainerStageResultEvent = trainerEventFolder:WaitForChild("TrainerStageResultEvent")
local closeTrainerMenuEvent = trainerEventFolder:WaitForChild("CloseTrainerMenuEvent")
local trainerEquipResultEvent = trainerEventFolder:WaitForChild("TrainerEquipResultEvent")

local trainerFolderUI = guiFolder:WaitForChild("TrainerFolder")
local trainerHost = trainerFolderUI:WaitForChild("TrainerHost")
local trainerMenu = trainerHost:WaitForChild("TrainerMenu")
local trainerStageFrame = trainerHost:WaitForChild("TrainerStageFrame")
local trainerBlurFrame = trainerHost:WaitForChild("TrainerBlurFrame")
local trainerWarningLabel = trainerHost:WaitForChild("TrainerWarningLabel")
local closeTrainer = trainerHost:WaitForChild("CloseTrainer")

MenuManager.register("Trainer", trainerHost)

local function findUI(parent, objectName, required)
	local object = parent:FindFirstChild(objectName, true)
	
	if not object and required ~= false then
		warn("[TrainerUI Не найден UI-обьект:", objectName)
	end
	return object
end

local trainerEnergyButton = findUI(trainerMenu, "TrainerEnergyButton")
local trainerMoneyButton = findUI(trainerMenu, "TrainerMoneyButton")
local trainerPetLuckButton = findUI(trainerMenu, "TrainerPetLuckButton")
local trainerPowerAccButton = findUI(trainerMenu, "TrainerPowerAccButton")

local trainerButtons = {
	TrainerEnergyButton = {Button = trainerEnergyButton, TrainerName = "LedyTrainer",},
	TrainerMoneyButton = {Button = trainerMoneyButton, TrainerName = "BellaTrainer",},
	TrainerPetLuckButton = {Button = trainerPetLuckButton, TrainerName = "MonikaTrainer",},
	TrainerPowerAccButton = {Button = trainerPowerAccButton, TrainerName = "JoeTrainer",},
}

local trainerNameLabel = findUI(trainerMenu, "TrainerNameLabel")
local trainerSpecialIcon = findUI(trainerMenu, "TrainerSpecialIcon")
local trainerSpecialistLabel = findUI(trainerMenu, "TrainerSpecialistLabel")
local trainerStageInfoLabel = findUI(trainerMenu, "TrainerStageInfoLabel")
local trainerValue = findUI(trainerMenu, "TrainerValue")
local trainerInfoLabel = findUI(trainerMenu, "TrainerInfoLabel")
local trainerXpLabel = findUI(trainerMenu, "TrainerXpLabel")
local trainerXpBar = findUI(trainerMenu, "TrainerXpBar")
local trainerPreviewViewport = findUI(trainerMenu, "TrainerPreviewViewport", false)
local levelUpButton = findUI(trainerMenu, "LevelUpButton")
local stageOpenButton = findUI(trainerMenu, "StageOpen")
local equipButton = findUI(trainerMenu, "EquipButton")
local equipButtonText = equipButton and findUI(equipButton, "ButtonText")

--// звезды
local menuStageIcons = {}

for index = 1, 5 do 
	menuStageIcons[index] = findUI(trainerMenu, "TrainerStageIcon" .. index)
end

--// бонусы
local energyIcon = findUI(trainerMenu, "EnergyIcon")
local energyBoostLabel = findUI(trainerMenu, "EnergyBoostLabel")
local energyFrame = findUI(trainerMenu, "EnergyFrame")
local moneyIcon = findUI(trainerMenu, "MoneyIcon")
local moneyBoostLabel = findUI(trainerMenu, "MoneyBoostLabel")
local moneyFrame = findUI(trainerMenu, "MoneyFrame")
local petPowerFrame = findUI(trainerMenu, "PetPowerFrame")
local petPowerBoost1 = findUI(trainerMenu, "Pet/PowerBoost1")
local petPowerBoost2 = findUI(trainerMenu, "Pet/PowerBoost2")

--// leaderstats
local leaderstatsUITrainer = findUI(trainerMenu, "leaderstatsUITrainer")
local srRobuxLabel = findUI(leaderstatsUITrainer, "SRRobuxLabel")
local moneyLabel = findUI(leaderstatsUITrainer, "MoneyLabel")
local trainerLeaderLabel = findUI(leaderstatsUITrainer, "TrainerLeaderLabel")
local trainerLeaderIcon = findUI(leaderstatsUITrainer, "TrainerLeaderIcon")

--// окно ранга
local closeStageFrameButton = findUI(trainerStageFrame, "CloseStageFrame")
local rankUpButton = findUI(trainerStageFrame, "RankUpButton")
local stageNameTrainer = findUI(trainerStageFrame, "StageNameTrainer")
local trainerStageSpecialtyLabel = findUI(trainerStageFrame, "TrainerStageSpecialtyLabel")
local stageCurrentBoostIcon = findUI(trainerStageFrame, "StageCurrentBoostIcon")
local stageCurrentBoost = findUI(trainerStageFrame, "StageCurrentBoost")
local stageNextBoost = findUI(trainerStageFrame, "StageNextBoost")

local stageFrameIcons = {}
local requirementIcons = {}
local requirementValueLabels = {}
local requirementBars = {}
local requirementBarLabels = {}

for index = 1, 5 do
	stageFrameIcons[index] = findUI(trainerStageFrame, "TrainerStageIcon" .. index)
end

for index = 1, 3 do
	requirementIcons[index] = findUI(trainerStageFrame, "StageRequirIcon" .. index)
	requirementValueLabels[index] = findUI(trainerStageFrame, "CurrentStageValue" .. index)
	requirementBars[index] = findUI(trainerStageFrame, "TrainerXpBar" .. index)
	requirementBarLabels[index] = findUI(trainerStageFrame, "CurrentRequirBarExecut" .. index)
end

--// PLAYER DATA
local energy = ClientDataModule.GetEnergy(player)
local money = ClientDataModule.GetMoney(player)
local rebirth = ClientDataModule.GetRebirth(player)
local srRobux = ClientDataModule.GetSrRobux(player)
local xp = ClientDataModule.GetXP(player)

--// положение карт
local folderCards = {
	TrainerEnergyButton = {
		Position = UDim2.new(0, 0, 0.002, 0),
		Rotation = -3,
		ZIndex = 4,
	},
	
	TrainerMoneyButton = {
		Position = UDim2.new(0.08, 0, 0.01, 0),
		Rotation = 3,
		ZIndex = 3,
	},
	
	TrainerPetLuckButton = {
		Position = UDim2.new(0.165, 0, 0.02, 0),
		Rotation = 7,
		ZIndex = 2,
	},
	
	TrainerPowerAccButton = {
		Position = UDim2.new(0.264, 0, 0.05, 0),
		Rotation = 9,
		ZIndex = 1,
	},
}

local expandedCards = {
	TrainerEnergyButton = {
		Position = UDim2.new(-0.259, 0, 0.008, 0),
		Rotation = -11,
		ZIndex = 4,
	},

	TrainerMoneyButton = {
		Position = UDim2.new(-0.087, 0, -0.005, 0),
		Rotation = -4,
		ZIndex = 3,
	},

	TrainerPetLuckButton = {
		Position = UDim2.new(0.096, 0, 0.02, 0),
		Rotation = 3,
		ZIndex = 2,
	},

	TrainerPowerAccButton = {
		Position = UDim2.new(0.271, 0, 0.054, 0),
		Rotation = 10,
		ZIndex = 1,
	},
}

local CARD_TWEEN_INFO =TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

--// размеры бонусных иконок
local NORMAL_BOOST_SIZE = UDim2.new(0.213, 0, 0.104, 0)
local SELECTED_BOOST_SIZE = UDim2.new(0.24, 0, 0.12, 0)

--// состояние
local selectedTrainerName = "LedyTrainer"

local cardsExpanded = false
local cardsTweening = false

local warningId = 0
local connectedValues = {}

local function formatNumber(value)
	value = tonumber(value) or 0

	if value >= 1e15 then
		return string.format("%.2fQ", value / 1e15)
	elseif value >= 1e12 then
		return string.format("%.2fT", value / 1e12)
	elseif value >= 1e9 then
		return string.format("%.2fB", value / 1e9)
	elseif value >= 1e6 then
		return string.format("%.2fM", value / 1e6)
	elseif value >= 1e3 then
		return string.format("%.2fK", value / 1e3)
	else
		return tostring(math.floor(value))
	end
end

local function formatTime(seconds)
	seconds = math.floor(tonumber(seconds) or 0)

    local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	
	if hours > 0 then
		return string.format("%02d:%02d:%02d", hours, minutes, secs)
	end

	return string.format("%02d:%02d", minutes, secs)
end

local function getTrainerFolder(trainerName)
	local trainerRoot = player:FindFirstChild("Trainer")
	
	if not trainerRoot then
		return nil
	end
	
	return trainerRoot:FindFirstChild(trainerName)
end

local function getTrainerValue(trainerName, valueName, defaultValue)
	local folder = getTrainerFolder(trainerName)
	
	local value = folder and folder:FindFirstChild(valueName)
	
	if not value then
		return defaultValue
	end
	
	return value.Value
end

local function getProgressValue(trainerName, requirementType)
	if requirementType == "Level" then
		return getTrainerValue(trainerName, "Level", 1)
	end
	
	local folder = getTrainerFolder(trainerName)
	
	local progressFolder = folder and folder:FindFirstChild("RequirementProgress")
	local value = progressFolder and progressFolder:FindFirstChild(requirementType)
	
	return value and value.Value or 0
end

local function getXPRequired(level)
	return 100 + (level * 50)
end

local function isTrainerOwned(trainerName)
	return getTrainerValue(trainerName, "Owned", false) == true
end

local function isTrainerEquipped(trainerName)
	return getTrainerValue(trainerName, "Equipped", false) == true
end

local function getRequirementName(requirementType)
	local names = {
		Level = "LEVEL",
		Energy = "ENERGY",
		Money = "MONEY",
		TrainerTreadmillTime = "TREADMILL TIME",
		EggHatched = "EGGS HATCHED",
		PetRarity = "RARITY PETS",
		Rebirth = "REBIRTH",
		RaceRewards = "RACE REWARDS",
	}
	
	return names[requirementType] or string.upper(requirementType)
end

local function getRequirementIcon(requirementType)
	local icons = {
		Level = ICONS.RequirementLevel,
		Energy = ICONS.RequirementEnergy,
		Money = ICONS.RequirementMoney,
		TrainerTreadmillTime = ICONS.RequirementTime,
		EggHatched = ICONS.RequirementEgg,
		PetRarity = ICONS.RequirementPet,
		Rebirth = ICONS.RequirementRebirth,
		RaceRewards = ICONS.RequirementRace,
	}
	
	return icons[requirementType] or ""
end

local function formatRequirementValue(requirementType, value)
	if requirementType == "TrainerTreadmillTime" then
		return formatTime(value)
	end
	return formatNumber(value)
end

local function showWarning(text, duration)
	warningId += 1
	
	local currentWarningId = warningId
	
	trainerWarningLabel.Text = text or ""
	trainerWarningLabel.Visible = true
	
	task.delay(duration or 3, function()
		if currentWarningId ~= warningId then
			return
		end
		
		trainerWarningLabel.Visible = false
	end)
end

local function setImageIfValid(imageObject, imageId)
	if not imageObject then 
		return
	end
	
	if imageId and imageId ~= "rbxassetid://0" then
		imageObject.Image = imageId
	end
end

--// Viewport
local function clearViewport(viewport)
	if not viewport then
		return
	end

	for _, object in ipairs(
		viewport:GetChildren()
		) do
		if object:IsA("WorldModel")
			or object:IsA("Camera") then

			object:Destroy()
		end
	end
end

local function setupViewport(viewport, trainerName, cameraDistance)
	if not viewport then 
		return
	end
	
	clearViewport(viewport)
	
	local info = TRAINER_INFO[trainerName]
	if not info then 
		return
	end
	
	local modelTemplate = trainerModelsFolder:FindFirstChild(info.ModelName)
	
	if not modelTemplate then
		warn("[TrainerUI Не найдена модель:", info.ModelName)
		return
	end
	
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport 
	
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	
	viewport.CurrentCamera = camera
	
	local model = modelTemplate:Clone()
	model.Parent = worldModel
	
	local rootPart = model:FindFirstChild("HumanoidRootPart", true)
	
	if not rootPart then
		model:Destroy()
		return
	end
	
	model.PrimaryPart = rootPart
	
	model:PivotTo( 
		CFrame.new(0, 0, 0)
		* CFrame.Angles( 
			0,
			math.rad(180),
			0
		)
	)
	
	camera.CFrame = CFrame.new(
		Vector3.new( 
			0, 
			1,
			cameraDistance or 5
		),
		Vector3.new( 
			0, 
			-0.3,
			0
		)
	)
end

local function setupAllCardViewports()
	for _, cardData in pairs(trainerButtons) do
		local button = cardData.Button
		
		if button then
			local viewport = button:FindFirstChild("TrainerViewport", true)
			
			setupViewport( 
				viewport,
				cardData.TrainerName,
				3.3
			)
		end
	end
end

--// анимация карт
local function applyCardLayout(layout)
	for buttonName, cardData in pairs(trainerButtons) do
		local state = layout[buttonName]
		local button = cardData.Button
		
		if state and button then 
			button.Position = state.Position
			button.Rotation = state.Rotation
			button.ZIndex = state.ZIndex
		end
	end
end

local function tweenCardLayout(layout)
	if cardsTweening then 
		return
	end
	
	cardsTweening = true
	
	local finished = 0
	local tweenCount = 0
	
	for buttonName, cardData in pairs(trainerButtons) do 
		local state = layout[buttonName]
		local button = cardData.Button
		
		if state and button then 
			tweenCount += 1
			
			button.ZIndex = state.ZIndex
			
			local tween = TweenService:Create(button, CARD_TWEEN_INFO,{
				Position = state.Position,
				Rotation = state.Rotation,
			})
			
			tween.Completed:Connect(function()
				finished += 1
				
				if finished >= tweenCount then 
					cardsTweening = false
				end
			end)
			
			tween:Play()
		end
	end
	
	if tweenCount == 0 then
		cardsTweening = false
	end
end

local function setCardsExpanded(expanded)
	if cardsTweening then
		return
	end
	
	cardsExpanded = expanded
	
	if expanded then 
		tweenCardLayout(expandedCards)
	else 
		tweenCardLayout(folderCards)
	end
end

--// звезды
local function updateStars(icons, currentStage)
	for index = 1, 5 do 
		local icon = icons[index]
		
		if icon then
			if index <= currentStage then
				setImageIfValid(
					icon,
					ICONS.StageStarActive
				)
			else 
				setImageIfValid( 
					icon,
					ICONS.StageStarInactive
				)
			end
		end
	end
end


--// бонусы
local function getTrainerBoosts(trainerName, stage, level)
	local info = TRAINER_INFO[trainerName]
	
	if not info then 
		return 0, 0
	end
	
	local stageMultiplier = STAGE_MULTIPLIERS[stage] or 1
	
	local levelMultiplier = 1 + math.max(0, level - 1) * 0.02
	
	local totalMultiplier = stageMultiplier * levelMultiplier
	
	local boost1 = math.floor( 
		(info.BaseBoost1 or 0) * totalMultiplier
	)
	
	local boost2 = math.floor(
		(info.BaseBoost2 or 0) * totalMultiplier
	)
	
	return boost1, boost2
end

local function setBoostLabelText(object, text)
	if not object then 
		return
	end
	
	if object:IsA("TextLabel") or object:IsA("TextButton") then 
		
		object.Text = text 
		return
	end
	
	local label = object:FindFirstChildWhichIsA("TextLabel", true)
	
	if label then 
		label.Text = text
	end
end

local function updateBoostSection(trainerName, stage, level)
	local boost1, boost2 = getTrainerBoosts(trainerName, stage, level)
	
	energyIcon.Size = NORMAL_BOOST_SIZE
	moneyIcon.Size = NORMAL_BOOST_SIZE
	
	petPowerBoost1.Size = NORMAL_BOOST_SIZE
	petPowerBoost2.Size = NORMAL_BOOST_SIZE
	
	energyFrame.Visible = false
	moneyFrame.Visible = false
	petPowerFrame.Visible = false
	
	if trainerName == "LedyTrainer" then 
		energyIcon.Size = SELECTED_BOOST_SIZE 
		energyFrame.Visible = true 
		
		setBoostLabelText(
			energyBoostLabel, 
			"+" .. boost1 .. "%"
		)
		
	elseif trainerName == "BellaTrainer" then 
		moneyIcon.Size = SELECTED_BOOST_SIZE
		moneyFrame.Visible = true
		
		setBoostLabelText( 
			moneyBoostLabel, 
			"+" .. boost1 .. "%"
		)
		
	elseif trainerName == "MonikaTrainer" then
		petPowerBoost1.Size = SELECTED_BOOST_SIZE
		petPowerBoost2.Size = SELECTED_BOOST_SIZE
		petPowerFrame.Visible = true
		
		setBoostLabelText( 
			petPowerBoost1, 
			"PET LUCK\n+" .. boost1 .. "%"
		)
		
		setBoostLabelText(
			petPowerBoost2,
			"RACE XP\n+" .. boost2 .. "%"
		)
		
	elseif trainerName == "JoeTrainer" then 
		petPowerBoost1.Size = SELECTED_BOOST_SIZE
		petPowerBoost2.Size = SELECTED_BOOST_SIZE
		petPowerFrame.Visible = true
		
		setBoostLabelText( 
			petPowerBoost1,
			"POWER\n+" .. boost1 .. "%"
		)
		
		setBoostLabelText( 
			petPowerBoost2,
			"ACCELERATION\n+" .. boost2 .. "%"
		)
	end
end

--// LeaderstatsUI
local function getEggHatchedProgress()
	local folder = getTrainerFolder("MonikaTrainer")
	
	local progressFolder = folder and folder:FindFirstChild("RequirementProgress")
	
	local value = progressFolder and progressFolder:FindFirstChild("EggHatched")
	
	return value and value.Value or 0
end

local function updateLeaderstats()
	if srRobuxLabel then 
		srRobuxLabel.Text = formatNumber(srRobux and srRobux.Value or 0)
	end
	
	if moneyLabel then
		moneyLabel.Text = formatNumber(money and money.Value or 0)
	end
	
	local info = TRAINER_INFO[selectedTrainerName]
	
	if not info then
		return
	end
	
	setImageIfValid(trainerLeaderIcon, info.LeaderIcon)
	
	local leaderValue = 0
	
	if info.LeaderValueType == "Energy" then
		leaderValue = energy and energy.Value or 0
		
	elseif info.LeaderValueType == "Money" then 
		leaderValue = money and money.Value or 0
		
	elseif info.LeaderValueType == "Rebirth" then
		leaderValue = rebirth and rebirth.Value or 0
	elseif info.LeaderValueType == "EggHatched" then 
		leaderValue = getEggHatchedProgress()
	end
	
	if trainerLeaderLabel then 
		trainerLeaderLabel.Text = formatNumber(leaderValue)
	end
end

--// equip button
local function updateEquipButton()
	if not selectedTrainerName then
		return
	end
	
	local info = TRAINER_INFO[selectedTrainerName]
	if not info then 
		return
	end
	
	local owned = isTrainerOwned(selectedTrainerName)
	local equipped = isTrainerEquipped(selectedTrainerName)
	
	if equipped then 
		equipButtonText.Text = "EQUIPPED"
		
		setImageIfValid(equipButton, ICONS.EquippedButton)
		
	elseif owned then 
		equipButtonText.Text = "EQUIP"
		
		setImageIfValid(equipButton, ICONS.EquipButton)
	else
		equipButtonText.Text = "BUY\n" .. (info.PriceText or "")
		
		setImageIfValid(equipButton, ICONS.EquipButton)
	end
end

--// основная информация
local function updateMainTrainerUI()
	local trainerName = selectedTrainerName
	local info = TRAINER_INFO[trainerName]
	
	if not info then
		return
	end
	
	local level = getTrainerValue(trainerName, "Level", 1)
	local stage = getTrainerValue(trainerName, "Stage", 1)
	
	local maxStageLevel = STAGE_MAX_LEVELS[stage] or 25
	local stageName = STAGE_NAMES[stage] or "Rookie"
	
	local currentXP = xp and xp.Value or 0
	local requiredXP = getXPRequired(level)
	
	trainerNameLabel.Text = info.DisplayName
	trainerSpecialistLabel.Text = info.Specialty
	
	if trainerInfoLabel then
		trainerInfoLabel.Text = info.InfoText or ""
	end
	
	setImageIfValid(trainerSpecialIcon, info.SpecialIcon)
	
	trainerStageInfoLabel.Text = "RANK: " .. stageName
	trainerValue.Text = tostring(level) .. " / " .. tostring(maxStageLevel)
	trainerXpLabel.Text = formatNumber(currentXP) .. " / " .. formatNumber(requiredXP)
	
	local xpProgress = math.clamp(currentXP / math.max(1, requiredXP), 0, 1)
	
	trainerXpBar.Size = UDim2.new(0.19 * xpProgress, 0, 0.032, 0)
	
	updateStars(menuStageIcons, stage)
	updateBoostSection(trainerName, stage, level)
	
	updateEquipButton()
	updateLeaderstats()
end

--// ребования ранкап
local function getCurrentRequirements(trainerName, stage)
	local trainerRequirements = STAGE_REQUIREMENTS[trainerName]
	
	if not trainerRequirements then
		return {}
	end
	return trainerRequirements[stage] or {}
end

local function updateRequirementBar(index, requirement)
	local requirementType = requirement.Type
	local need = tonumber(requirement.Need) or 0
	local current = getProgressValue(selectedTrainerName, requirementType)
	local progress = math.clamp(current / math.max(1, need), 0, 1)
	
	local icon = requirementIcons[index]
	local valueLabel = requirementValueLabels[index]
	
	local bar = requirementBars[index]
	local barLabel = requirementBarLabels[index]
	
	setImageIfValid(icon, getRequirementIcon(requirementType))
	
	if valueLabel then 
		valueLabel.Text = getRequirementName(requirementType)
	end
	
	if bar then 
		bar.Size = UDim2.new(0.18 * progress, 0, 0.028, 0)
	end
	
	if barLabel then 
		barLabel.Text = formatRequirementValue(requirementType, current) .. " / " .. formatRequirementValue(requirementType, need)
	end
end

local function updateStageBoost()
	local info = TRAINER_INFO[selectedTrainerName]
	
	if not info then
		return
	end
	
	local stage = getTrainerValue(selectedTrainerName, "Stage", 1)
	local level = getTrainerValue(selectedTrainerName, "Level", 1)
	
	local currentBoost1, currentBoost2 = getTrainerBoosts(selectedTrainerName, stage, level)
	local nextStage = math.min(stage + 1, 5)
	local nextBoost1, nextBoost2 = getTrainerBoosts(selectedTrainerName, nextStage, 1)
	
	if selectedTrainerName == "LedyTrainer" then
		setImageIfValid(stageCurrentBoostIcon, ICONS.BoostEnergy)
		
		stageCurrentBoost.Text = "+" .. currentBoost1 .. "% ENERGY"
		stageNextBoost.Text = "+" .. nextBoost1 .. "% ENERGY"
		
	elseif selectedTrainerName == "BellaTrainer" then
		setImageIfValid(stageCurrentBoostIcon, ICONS.BoostMoney)
		
		stageCurrentBoost.Text = "+" .. currentBoost1 .. "% MONEY"
		stageNextBoost.Text = "+" .. nextBoost1 .. "% MONEY"
		
	elseif selectedTrainerName == "MonikaTrainer" then
		setImageIfValid(stageCurrentBoostIcon, ICONS.BoostPetLuck)
		
		stageCurrentBoost.Text = "+" .. currentBoost1 .. "% LUCK / +" .. currentBoost2 .. "% XP"
		stageNextBoost.Text = "+" .. nextBoost1 .. "% LUCK / +" .. nextBoost2 .. "% XP"
		
	elseif selectedTrainerName == "JoeTrainer" then
		setImageIfValid(stageCurrentBoostIcon, ICONS.BoostPower)
		
		stageCurrentBoost.Text = "+" .. currentBoost1 .. "% POWER / +" .. currentBoost2 .. "% ACC"
		stageNextBoost.Text = "+" .. nextBoost1 .. "% POWER / +" .. nextBoost2 .. "% ACC"
	end
end

local function updateStageFrame()
	local trainerName = selectedTrainerName
	local info = TRAINER_INFO[trainerName]
	
	if not info then
		return
	end
	
	local stage = getTrainerValue(trainerName, "Stage", 1)
	local stageName = STAGE_NAMES[stage] or "Rookie"
	
	stageNameTrainer.Text = info.DisplayName .. " _ " .. stageName
	trainerStageSpecialtyLabel.Text = info.Specialty
	
	updateStars(stageFrameIcons, stage)
	updateStageBoost()
	
	local requirements = getCurrentRequirements(trainerName, stage)
	
	for index = 1, 3 do
		local requirement = requirements[index]
		
		if requirement then
			if requirementIcons[index] then
				requirementIcons[index].Visible = true
			end
			
			if requirementValueLabels[index] then
				requirementValueLabels[index].Visible = true
			end
			
			if requirementBars[index] then 
				requirementBars[index].Visible = true 
			end
			
			updateRequirementBar(index, requirement)
		else 
			if requirementIcons[index] then 
				requirementIcons[index].Visible = false
			end
			
			if requirementValueLabels[index] then 
				requirementValueLabels[index].Visible = false
			end
			
			if requirementBars[index] then 
				requirementBars[index].Visible = false
			end
		end
	end
end

local function selectTrainer(trainerName)
	if not TRAINER_INFO[trainerName] then
		return
	end
	
	selectedTrainerName = trainerName
	
	if trainerPreviewViewport then
		setupViewport(trainerPreviewViewport, trainerName, 3.9)
	end
	
	updateMainTrainerUI()
	
	if trainerStageFrame.Visible then 
		updateStageFrame()
	end
end

--// подключение изменений дата
local function disconnectDataConnections()
	for _, connection in ipairs(connectedValues) do
		connection:Disconnect()
	end
	table.clear(connectedValues)
end

local function connectValue(valueObject)
	if not valueObject or not valueObject:IsA("ValueBase") then
		return
	end
	
	local connection = valueObject.Changed:Connect(function()
		updateMainTrainerUI()
		
		if trainerStageFrame.Visible then 
			updateStageFrame()
		end
	end)
	
	table.insert(connectedValues, connection)
end

local function connectTrainerData()
	disconnectDataConnections()
	
	local trainerRoot = player:FindFirstChild("Trainer")
	
	if trainerRoot then
		for _, trainerFolder in ipairs(trainerRoot:GetChildren()) do
			for _, object in ipairs(trainerFolder:GetDescendants()) do
				connectValue(object)
			end
		end
	end
	
	connectValue(energy)
	connectValue(money)
	connectValue(rebirth)
	connectValue(srRobux)
	connectValue(xp)
end

--// кнопки карт
for _, cardData in pairs(trainerButtons) do
	local button = cardData.Button
	local trainerName = cardData.TrainerName
	
	if button then 
		button.MouseButton1Click:Connect(function()
			if cardsTweening then
				return
			end
			
			if not cardsExpanded then
				setCardsExpanded(true)
				return
			end
			
			selectTrainer(trainerName)
			setCardsExpanded(false)
		end)
	end
end

--// equip
equipButton.MouseButton1Click:Connect(function()
	if not selectedTrainerName then
		return
	end
	
	if isTrainerEquipped(selectedTrainerName) then
		trainerEquipEvent:FireServer("Unequip", selectedTrainerName)
	else
		trainerEquipEvent:FireServer("Equip", selectedTrainerName)
	end
end)

trainerEquipResultEvent.OnClientEvent:Connect(function(success, trainerName, resultType)
	if trainerName ~= selectedTrainerName then
		return
	end
	
	if success then
		if resultType == "Equipped" then
			showWarning("TRAINER EQUIPPED!", 3)
		elseif resultType == "Unequipped" then
			showWarning("TRAINER UNEQUIPPED!", 3)
		end
		updateMainTrainerUI()
		return
	end
	
	if resultType == "NotEnoughCurrency" then
		showWarning("NOT ENOUGH CURRENCY!", 3)
	elseif resultType == "ComingSoon" then
		showWarning("MONIKA COMING SOON!", 3)
	elseif resultType == "CurrencyMissing" then
		showWarning("CURRENCY NOT FOUND!", 3)
	else
		showWarning("PURCHASE FAILED!", 3)
	end
end)

--// lelev up
levelUpButton.MouseButton1Click:Connect(function()
	if not selectedTrainerName then
		return
	end
	
	if not isTrainerOwned(selectedTrainerName) then 
		showWarning("TRAINER IS NOT OWNED!", 3)
		return
	end
	
	local level = getTrainerValue(selectedTrainerName, "Level", 1)
	local stage = getTrainerValue(selectedTrainerName, "Stage", 1)
	local maxLevel = STAGE_MAX_LEVELS[stage] or 25
	
	if level >= maxLevel then 
		showWarning("MAX LEVEL FOR THIS RANK!", 3)
		return
	end
	
	local requiredXP = getXPRequired(level)
	local currentXP = xp and xp.Value or 0
	
	if currentXP < requiredXP then
		showWarning("NOT ENOUGH XP! " .. formatNumber(currentXP) .. " / " .. formatNumber(requiredXP), 3)
		return
	end
	
	trainerLevelUpEvent:FireServer(selectedTrainerName)
end)

--// открытие ранг фрейм
stageOpenButton.MouseButton1Click:Connect(function()
	if not selectedTrainerName then 
		return
	end
	
	trainerStageFrame.Visible = true
	trainerBlurFrame.Visible = true 
	
	updateStageFrame()
end)

closeStageFrameButton.MouseButton1Click:Connect(function()
	trainerStageFrame.Visible = false
	trainerBlurFrame.Visible = false
end)

--// RANK UP
rankUpButton.MouseButton1Click:Connect(function()
	if not selectedTrainerName then
		return
	end
	
	if not isTrainerOwned(selectedTrainerName) then
		showWarning("TRAINER IS NOT OWNED!", 3)
		return
	end
	
	local stage = getTrainerValue(selectedTrainerName, "Stage", 1)
	
	if stage >= 5 then
		showWarning("MAX RANK!", 3)
		return
	end
	
	trainerStageUpEvent:FireServer(selectedTrainerName)
end)

--// результат RANK UP
local function buildMissingText(missing)
	local lines = {}
	
	for _, item in pairs(missing or {}) do
		local requirementType = item.Type or "Requirement"
		
		local current = item.Current or 0
		
		local need = item.Need or 0
		
		table.insert(lines, getRequirementName(requirementType)
			.. ": " .. formatRequirementValue(requirementType, current)
			.. " / " .. formatRequirementValue(requirementType, need)
		)
		
		if item.Spend == true and item.BalanceCompleted == false then
			
			table.insert(lines, "BALANCE " .. getRequirementName(requirementType)
				.. ": " .. formatNumber(item.BalanceCurrent or 0)
				.. " / " .. formatNumber(need)
			)
		end
	end
	
	if #lines == 0 then
		return "REQUIREMENTS NOT COMPLETED!"
	end
	
	return table.concat(lines, "\n")
end

trainerStageResultEvent.OnClientEvent:Connect(function(success, trainerName, resultType, data)
	if trainerName and trainerName ~= selectedTrainerName then
		return
	end
	
	if success then 
		showWarning("RANK UP COMPLETE!", 4)
		
		task.wait(0.1)
		
		updateMainTrainerUI()
		updateStageFrame()
		return
	end
	
	if resultType == "NotOwned" then
		showWarning("TRAINER IS NOT OWNED!", 3)
		
	elseif resultType == "MaxStage" then
		showWarning("MAX RANK!", 3)
	elseif resultType == "NeedLevel" then 
		local currentLevel = data and data.CurrentLevel or 1
		local needLevel = data and data.NeedLevel or 5
		
		showWarning("LEVEL: " .. currentLevel .. " / " .. needLevel, 4)
	elseif resultType == "MissingRequirements" then
		showWarning(buildMissingText(data), 6)
	else
		showWarning("RANK UP FAILED!", 3)
	end
end)

--// pакрытие меню
closeTrainer.MouseButton1Click:Connect(function()
	MenuManager.close("Trainer")
end)

closeTrainerMenuEvent.OnClientEvent:Connect(function()
	MenuManager.close("Trainer")
end)

--// автообновление раз в секунду
task.spawn(function()
	while true do
		task.wait(1)
		
		if trainerMenu.Visible then 
			updateMainTrainerUI()
		end
		
		if trainerStageFrame.Visible then 
			updateStageFrame()
		end
	end
end)

--// инициализация
trainerStageFrame.Visible = false
trainerBlurFrame.Visible = false
trainerWarningLabel.Visible = false 

applyCardLayout(folderCards)

setupAllCardViewports()
connectTrainerData()

selectTrainer("LedyTrainer")
updateMainTrainerUI()

print("TrainerUI loaded")
