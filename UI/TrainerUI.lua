local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)

local guiFolder = raceGui:WaitForChild("GuiFolder")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local trainerEventFolder = ReplicatedStorage:WaitForChild("TrainerEvent")
local trainerModelsFolder = ReplicatedStorage:WaitForChild("TrainerModels")

local trainerEquipEvent = trainerEventFolder:WaitForChild("TrainerEquipEvent")
local trainerLevelUpEvent = trainerEventFolder:WaitForChild("TrainerLevelUpEvent")
local trainerStageUpEvent = trainerEventFolder:WaitForChild("TrainerStageUpEvent")
local trainerStageResultEvent = trainerEventFolder:WaitForChild("TrainerStageResultEvent")
local closeTrainerMenuEvent = trainerEventFolder:WaitForChild("CloseTrainerMenuEvent")

local trainerFolderUI = guiFolder:WaitForChild("TrainerFolder")



--// Ready Frame
--Trainer
local stageReadyFrame = trainerFolderUI:WaitForChild("TrainerStageReadyFrame")
local stageReadyTitle = stageReadyFrame:WaitForChild("TitleLabel")
local stageReadyReq1 = stageReadyFrame:WaitForChild("Requirement1Label")
local stageReadyReq2 = stageReadyFrame:WaitForChild("Requirement2Label")



--Menu
local trainerMenu = trainerFolderUI:WaitForChild("TrainerMenu")

local openListButton = trainerMenu:WaitForChild("TrainerListOpenButton")
local closeTrainerMenuButton = trainerMenu:WaitForChild("CloseTrainerMenuButton")


--ListFrame
local listFrame = trainerMenu:WaitForChild("TrainerStage1ListFrame")


--Details
local detailsFrame = trainerMenu:WaitForChild("TrainerDetailsFrame")

local stageRequirementFrame = detailsFrame:WaitForChild("StageRequirementFrame")
local requirementEnergyLabel = stageRequirementFrame:WaitForChild("RequirementEnergyLabel")
local requirementTimeLabel = stageRequirementFrame:WaitForChild("RequirementTimeLabel")


local equipButton = detailsFrame:WaitForChild("EquipButton")
local equipButtonText = equipButton:WaitForChild("ButtonText")

local levelUpButton = detailsFrame:WaitForChild("LevelUpButton")
local levelUpButtonText = levelUpButton:WaitForChild("ButtonText")

local stageUpButton = detailsFrame:WaitForChild("StageUpButton")
local buttonStageText = stageUpButton:WaitForChild("ButtonStageText")

local viewport = detailsFrame:WaitForChild("TrainerPreviewViewport")

local nameLabel = detailsFrame:WaitForChild("TrainerNameLabel")
local bonusLabel = detailsFrame:WaitForChild("TrainerBonusLabel")
local trainerLevelText = detailsFrame:WaitForChild("TrainerLevel")
local trainerValue = detailsFrame:WaitForChild("TrainerValue")
local trainerSpecialistLabel = detailsFrame:WaitForChild("TrainerSpecialistLabel")
local trainerInfoLabel = detailsFrame:WaitForChild("TrainerInfoLabel")
local trainerStageInfoLabel = detailsFrame:WaitForChild("TrainerStageInfoLabel")


local trainerStageIcon = detailsFrame:WaitForChild("TrainerStageIcon")
local trainerSpecialistIcon = detailsFrame:WaitForChild("TrainerSpecialistIcon")


--// XPBar
local trainerXPBar = detailsFrame:WaitForChild("TrainerXPBar")

local trainerXPFill = trainerXPBar:WaitForChild("Fill")
local trainerXPLabel = trainerXPBar:WaitForChild("TrainerXPLabel")


--// Leaderstats UI
local energy = ClientDataModule.GetEnergy(player)
local rebirth = ClientDataModule.GetRebirth(player)
local money = ClientDataModule.GetMoney(player) 
local srRobux =  ClientDataModule.GetSrRobux(player)
local resources = ClientDataModule.GetResources(player)
local xp = ClientDataModule.GetXP(player)


local leaderstatsUITrainer = trainerMenu:WaitForChild("leaderstatsUITrainer")

local energyLabel = leaderstatsUITrainer:WaitForChild("EnergyLabel")
local rebirthLabel = leaderstatsUITrainer:WaitForChild("RebirthLabel")
local moneyLabel = leaderstatsUITrainer:WaitForChild("MoneyLabel")
local srRobuxLabel = leaderstatsUITrainer:WaitForChild("SRRobuxLabel")

local buttons = {
	TrainerEnergyButton = "LedyTrainer",
	TrainerMoneyButton = "BellaTrainer",
	TrainerPetLuckButton = "MonikaTrainer",
	TrainerPowerAccButton = "JoeTrainer",
}

local trainerInfo = {
	LedyTrainer = {
		DisplayName = "Ledy Trainer",
		Stage = "Rookie",
		BonusText = "+20% Energy",
		PriceText = "5000 Energy",
		ModelName = "LedyTrainer",
		BaseBonus = 20,
		BonusType = "Energy",
		
		Specialist = "Energy Master",
		SpecialistIcon = "rbxassetid://126850032226698",
		InfoText = "The Lady Trainer may look sweet and charming at first glance, but behind those beautiful eyes hides a truly dedicated and disciplined coach. With her by your side, your training efficiency will rise to a whole new level.",
	},
	
	BellaTrainer = {
		DisplayName = "Bella Trainer",
		Stage = "Rookie",
		BonusText = "+20% Money",
		PriceText = "5000 Money",
		ModelName = "BellaTrainer",
		BaseBonus = 20,
		BonusType = "Money",
		
		Specialist = "Money Master",
		SpecialistIcon = "rbxassetid://99953331838736",
		InfoText = "Bella is a true master of money-making. With her charm and experience, she helps you earn much more money from races and rewards. Her beauty is only matched by her incredible talent for turning every run into profit 😍",
	},
	
	MonikaTrainer = {
		DisplayName = "Monika Trainer",
		Stage = "Rookie",
		BonusText = "+20% Pet Luck",
		PriceText = "Requires 500 Pets",
		ModelName = "MonikaTrainer",
		BaseBonus = 20,
		BonusType = "Luck",
		
		Specialist = "Ledu Luck",
		SpecialistIcon = "rbxassetid://74345221099055",
		InfoText = "Monica’s middle name is Lady Luck. Wherever Monica appears, luck follows close behind. If you manage to win her heart, consider yourself lucky already — because with Monica by your side, fortune is always on your side 🍀",
	},
	
	JoeTrainer = {
		DisplayName = "Joe Trainer",
		Stage = "Rookie",
		BonusText = "+20% Power / Acceleration",
		PriceText = "1 Rebirth",
		ModelName = "JoeTrainer",
		BaseBonus = 15,
		BonusType = "RacePower / Acceleration",
		
		Specialist = "Power/Acceleration Master",
		SpecialistIcon = "rbxassetid://86198292216471",
		InfoText = "Joe may look serious, but that’s exactly what makes him dangerous. With his intimidating presence and relentless discipline, he pushes you to run faster and harder in every race. Because when Joe is watching… slowing down is not an option.",
	},
}

local STAGE_MAX_LEVELS = {
	[1] = 5,
	[2] = 10,
	[3] = 15,
	[4] = 20,
	[5] = 25,
}

local STAGE_NAMES = {
	[1] = "Rookie",
	[2] = "Athlete",
	[3] = "Champion",
	[4] = "Titan",
	[5] = "Mythic",
}

local STAGE_MULTIPLIERS = {
	[1] = 1.0,
	[2] = 1.1,
	[3] = 1.2,
	[4] = 1.3,
	[5] = 1.4,
}

local STAGE_ICONS = {
	[1] = "rbxassetid://99685622375377",
	[2] = "rbxassetid://79413916252604",
	[3] = "rbxassetid://73368705756459",
	[4] = "rbxassetid://112841420719900",
	[5] = "rbxassetid://132452972957601",
}

local selectedTrainerName = nil
local listOpened = false

local closedPositions = {
	TrainerEnergyButton = UDim2.new(0, 0, 0, 0),
	TrainerMoneyButton = UDim2.new(0, 70, 0, 10),
	TrainerPetLuckButton = UDim2.new(0, 150, 0, 10),
	TrainerPowerAccButton = UDim2.new(0, 250 , 0, 15),
}

local openPositions = {
	TrainerEnergyButton = UDim2.new(0, 0, 0, 0),
	TrainerMoneyButton = UDim2.new(0, 230, 0, 10),
	TrainerPetLuckButton = UDim2.new(0, 460, 0, 10),
	TrainerPowerAccButton = UDim2.new(0, 690, 0, 15),
}

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

local function formatShort(n)
	if n >= 1e15 then
		return string.format("%.2fQ", n / 1e15)
	elseif n >= 1e12 then
		return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.2fK", n / 1e3)
	else
		return tostring(math.floor(n))
	end
end

local function formatTime(seconds)
	seconds = math.floor(tonumber(seconds) or 0)
	
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	
	return string.format("%02d:%02d", minutes, secs)
end

local function setupCardViewport(button, trainerName)
	local viewport = button:WaitForChild("TrainerViewport")
	
	for _, obj in ipairs(viewport:GetChildren()) do
		if obj:IsA("WorldModel") or obj:IsA("Camera") then
			obj:Destroy()
		end
	end
	
	local info = trainerInfo[trainerName]
	if not info then return end
	
	local modelTemplate = trainerModelsFolder:FindFirstChild(info.ModelName)
	if not modelTemplate then return end
	
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport
	
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	local model = modelTemplate:Clone()
	model.Parent = worldModel
	
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	model.PrimaryPart = hrp
	model:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
	
	camera.CFrame = CFrame.new( 
		Vector3.new(0, 2.2, 3.2),
		Vector3.new(0, 1.8, 0)
	)
end

local function updateLeaderstatsUITrainer()
	energyLabel.Text = formatShort(energy.Value)
	moneyLabel.Text = formatShort(money.Value)
	rebirthLabel.Text = formatShort(rebirth.Value)
	srRobuxLabel.Text = formatShort(srRobux.Value)
	
	if energy then
		energyLabel.Text = formatNumber(energy.Value)
	end
	
	if money then
		moneyLabel.Text = formatNumber(money.Value)
	end
	
	if rebirth then
		rebirthLabel.Text = formatNumber(rebirth.Value)
	end
	
	if srRobux then
		srRobuxLabel.Text = formatNumber(srRobux.Value)
	else
		srRobuxLabel.Text = "0"
	end
end

local requirementOpenId = 0

local function showStageRequirements(line1, line2)
	requirementOpenId += 1
	local currentId = requirementOpenId
	
	requirementEnergyLabel.Text = line1 or ""
	requirementTimeLabel.Text = line2 or ""
	
	stageRequirementFrame.Visible = true
	
	task.delay(30, function()
		if requirementOpenId == currentId then
			stageRequirementFrame.Visible = false
		end
	end)
end

local function getTrainerDataFolder(trainerName)
	if not trainerName then return nil end
	
	local trainerFolder = player:FindFirstChild("Trainer")
	if not trainerFolder then return nil end
	
	return trainerFolder:FindFirstChild(trainerName)
end

local function updateTrainerCards()
	for buttonName, trainerName in pairs(buttons) do
		local button = listFrame:FindFirstChild(buttonName)
		local info = trainerInfo[trainerName]
		local folder = getTrainerDataFolder(trainerName)

		if button and info and folder then
			local cardNameLabel = button:FindFirstChild("TrainerNameLabel")
			local cardSpecialtyLabel = button:FindFirstChild("TrainerSpecialtyLabel")
			local cardStageLabel = button:FindFirstChild("TrainerCardStageLabel")
			local cardLevelLabel = button:FindFirstChild("TrainerCardLevelLabel")
			local cardStatusLabel = button:FindFirstChild("TrainerCardStatusLabel")

			local level = folder:FindFirstChild("Level")
			local stage = folder:FindFirstChild("Stage")
			local owned = folder:FindFirstChild("Owned")
			local equipped = folder:FindFirstChild("Equipped")

			local currentStage = stage and stage.Value or 1
			local stageName = STAGE_NAMES[currentStage] or "Rookie"

			if cardNameLabel then
				cardNameLabel.Text = info.DisplayName or trainerName
			end

			if cardSpecialtyLabel then
				cardSpecialtyLabel.Text = info.Specialist or "Trainer"
			end

			if cardStageLabel then
				cardStageLabel.Text = stageName
			end

			if cardLevelLabel then
				cardLevelLabel.Text = "Lv. " .. tostring(level and level.Value or 1)
			end

			if cardStatusLabel then
				if equipped and equipped.Value == true then
					cardStatusLabel.Text = "Equipped"
				elseif owned and owned.Value == true then
					cardStatusLabel.Text = "Owned"
				else
					cardStatusLabel.Text = "Locked"
				end
			end
		end
	end
end

local function updateStageReadyFrame()
	if not selectedTrainerName then
		stageReadyFrame.Visible = false
		return
	end
	
	local folder = getTrainerDataFolder(selectedTrainerName)
	if not folder then
		stageReadyFrame.Visible = false
		return
	end
	
	local level = folder:FindFirstChild("Level")
	local stage = folder:FindFirstChild("Stage")
	
	local currentLevel = level and level.Value or 1
	local currentStage = stage and stage.Value or 1
	local maxLevel = STAGE_MAX_LEVELS[currentStage] or 5
	
	if currentStage >= 5 then
		stageReadyFrame.Visible = false
		return
	end
	
	if currentLevel < maxLevel then
		stageReadyFrame.Visible = false
		return
	end
	
	stageReadyFrame.Visible = true
	stageReadyTitle.Text = "Stage Up Availabel!"
	
	if selectedTrainerName == "LedyTrainer" then
		stageReadyReq1.Text = "Energy required"
		stageReadyReq2.Text = "Treadmill Time required"
	elseif selectedTrainerName == "BellaTrainer" then
		stageReadyReq1.Text = "Money required"
		stageReadyReq2.Text = ""
	elseif selectedTrainerName == "MonikaTrainer" then
		stageReadyReq1.Text = "Pet Hatched required"
		stageReadyReq2.Text = ""
	elseif selectedTrainerName == "JoeTrainer" then
		stageReadyReq1.Text = "Rebirth required"
		stageReadyReq2.Text = ""
	end
end

local function updateStageButton(trainerName)
	local folder = getTrainerDataFolder(trainerName)
	if not folder then return end
	
	local level = folder:FindFirstChild("Level")
	local stage = folder:FindFirstChild("Stage")
	
	local currentLevel = level and level.Value or 1
	local currentStage = stage and stage.Value or 1
	local maxLevel = STAGE_MAX_LEVELS[currentStage] or 5
	
	if currentStage >= 5 then
		buttonStageText.Text = "Max Stage"
		return
	end
	
	if currentLevel < maxLevel then
		buttonStageText.Text = "Need Lv. " .. maxLevel
	else
		buttonStageText.Text = "Stage Up"
	end
end

local function getCurrentTrainerPower(trainerName)
	local info = trainerInfo[trainerName]
	if not info then return 1 end
	
	local folder = getTrainerDataFolder(trainerName)
	if not folder then return 1 end
	
	local level = folder:FindFirstChild("Level")
	local stage = folder:FindFirstChild("Stage")
	
	local currentLevel = level and level.Value or 1
	local currentStage = stage and stage.Value or 1
	
	local stagePower = STAGE_MULTIPLIERS[currentStage] or 1
	local levelPower = 1 + ((currentLevel - 1) * 0.02)
	
	return stagePower * levelPower
end

local function getTrainerXPRequired(level)
	return 100 + (level * 50)
end

local function getSharedXP()
	return xp.Value
end

local function updateTrainerUI(trainerName)
	if not trainerName then
		warn("updateTrainerUI called withous trainerName")
		return
	end
	
	local folder = getTrainerDataFolder(trainerName)
	if not folder then return end
	
	local level = folder:FindFirstChild("Level")
	
	local currentLevel = level and level.Value or 1
	local currentXP = getSharedXP()
	local needXP = getTrainerXPRequired(currentLevel)
	
	trainerLevelText.Text = "LEVEL"
	trainerValue.Text = tostring(currentLevel)
	
	trainerXPLabel.Text = formatNumber(currentXP) .. " / " .. formatNumber(needXP) .. " XP"
	
	local progress = math.clamp(currentXP / needXP, 0, 1)
	
	trainerXPFill.Size = UDim2.new(progress, 0, 1, 0)
	
	if currentLevel >= 25 then
		levelUpButtonText.Text = "Max Level"
	elseif currentXP >= needXP then
		levelUpButtonText.Text = "Level Up"
	else
		levelUpButtonText.Text = "Need XP"
	end
end

local function isOwned(trainerName)
	local folder = getTrainerDataFolder(trainerName)
	local owned = folder and folder:FindFirstChild("Owned")
	return owned and owned.Value == true
end

local function isEquipped(trainerName)
	local folder = getTrainerDataFolder(trainerName)
	local equipped = folder and folder:FindFirstChild("Equipped")
	return equipped and equipped.Value == true
end

local function clearViewport()
	for _, obj in ipairs(viewport:GetChildren()) do
		if obj:IsA("WorldModel") or obj:IsA("Camera") then
			obj:Destroy()
		end
	end
end

local function showTrainerViewport(trainerName)
	clearViewport()
	
	local info = trainerInfo[trainerName]
	if not info then return end
	
	local modelTemplate = trainerModelsFolder:FindFirstChild(info.ModelName)
	if not modelTemplate then return end
	
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport
	
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	local model = modelTemplate:Clone()
	model.Parent = worldModel
	
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	model.PrimaryPart = hrp
	model:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
	
	camera.CFrame = CFrame.new(Vector3.new(0, 2, 7), Vector3.new(0, 2, 0))
end

local function updateEquipButton()
	if not selectedTrainerName then
		equipButtonText.Text = "Select Trainer"
		return
	end
	
	local info = trainerInfo[selectedTrainerName]
	if not info then return end
	
	if isEquipped(selectedTrainerName) then
		equipButtonText.Text = "Equipped"
	elseif isOwned(selectedTrainerName) then
		equipButtonText.Text = "Equip"
	else
		equipButtonText.Text = "Buy\n" .. info.PriceText
	end
end

local function selectTrainer(trainerName)
	selectedTrainerName = trainerName
	
	local folder = getTrainerDataFolder(trainerName)
	
	local info = trainerInfo[trainerName]
	if not info then return end
	
	nameLabel.Text = info.DisplayName
	local stage = folder and folder:FindFirstChild("Stage")
	local currentStage = stage and stage.Value or 1
	local stageName = STAGE_NAMES[currentStage] or "Rookie"
	
	trainerStageIcon.Image = STAGE_ICONS[currentStage] or ""
	
	local stageMultiplier = STAGE_MULTIPLIERS[currentStage] or 1
	
	trainerStageInfoLabel.Text = "Current Stage: " .. stageName .. "\nBonus Power: x" .. tostring(stageMultiplier)
	
	local level = folder and folder:FindFirstChild("Level")
	
	local power = getCurrentTrainerPower(trainerName)
	local finalBonus = math.floor((info.BaseBonus or 0) * power)
	
	bonusLabel.Text = "+" .. finalBonus .. "% " .. (info.BonusType or "Bonus")
	
	trainerSpecialistLabel.Text = info.Specialist or "Trainer"
	trainerSpecialistIcon.Image = info.SpecialistIcon or ""
	trainerInfoLabel.Text = info.InfoText
	
	showTrainerViewport(trainerName)
	updateEquipButton()
	updateTrainerUI(trainerName)
	updateStageButton(trainerName)
	updateTrainerCards()
end

local function closeCards()
	listOpened = false
	openListButton.Visible = true
	openListButton.Active = true
	openListButton.ZIndex = 50
	
	local energyButton = listFrame:FindFirstChild("TrainerEnergyButton")
	local moneyButton = listFrame:FindFirstChild("TrainerMoneyButton")
	local petLuckButton = listFrame:FindFirstChild("TrainerPetLuckButton")
	local powerButton = listFrame:FindFirstChild("TrainerPowerAccButton")
	
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	if energyButton then
		TweenService:Create(energyButton, tweenInfo, {Position = closedPositions.TrainerEnergyButton}):Play()
	end
	
	if moneyButton then
		TweenService:Create(moneyButton, tweenInfo, {Position = closedPositions.TrainerMoneyButton}):Play()
	end
	
	if petLuckButton then
		TweenService:Create(petLuckButton, tweenInfo, {Position = closedPositions.TrainerPetLuckButton}):Play()
	end
	
	if powerButton then
		TweenService:Create(powerButton, tweenInfo, {Position = closedPositions.TrainerPowerAccButton}):Play()
	end
end

local function openCards()
	listOpened = true
	openListButton.Visible = false
	
	for buttonName, _ in pairs(buttons) do
		local button = listFrame:FindFirstChild(buttonName)
		if button and openPositions[buttonName] then
			TweenService:Create(
				button,
				TweenInfo.new(0.3,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out),
				{Position = openPositions[buttonName]}
				):Play()
		end
	end
end

for buttonName, trainerName in pairs(buttons) do
	local button = listFrame:WaitForChild(buttonName)
	
	setupCardViewport(button, trainerName)
	
	button.MouseButton1Click:Connect(function()
		selectTrainer(trainerName)
		closeCards()
	end)
end

listFrame.TrainerMoneyButton.ZIndex = 2
listFrame.TrainerPetLuckButton.ZIndex = 3
listFrame.TrainerPowerAccButton.ZIndex = 4
listFrame.TrainerEnergyButton.ZIndex = 1

openListButton.Active = true
openListButton.ZIndex = 10
openListButton.Visible = true

closeTrainerMenuButton.MouseButton1Click:Connect(function()
	closeTrainerMenuEvent:FireServer()
end)

stageUpButton.MouseButton1Click:Connect(function()
	if not selectedTrainerName then return end
	
	trainerStageUpEvent:FireServer(selectedTrainerName)
end)

task.wait(0.25)
if selectedTrainerName then
	updateTrainerUI(selectedTrainerName)
end
updateStageButton(selectedTrainerName)
updateStageReadyFrame()
updateTrainerCards()

openListButton.MouseButton1Click:Connect(function()
	print("TRAINER LIST BUTTON CLICKED")
	
	if listOpened then
		closeCards()
	else
		openCards()
	end
end)

equipButton.MouseButton1Click:Connect(function()
	if not selectedTrainerName then return end
	
	if isEquipped(selectedTrainerName) then
		
		trainerEquipEvent:FireServer("Unequip", selectedTrainerName)
	else
		trainerEquipEvent:FireServer("Equip", selectedTrainerName)
	end
	
	task.wait(0.2)
	updateEquipButton()
	updateTrainerCards()
	
	if selectedTrainerName then
		
		if selectedTrainerName then
			updateTrainerUI(selectedTrainerName)
		end
		
		updateStageButton(selectedTrainerName)
	end
end)

levelUpButton.MouseButton1Click:Connect(function()
	if not selectedTrainerName then return end
	
	trainerLevelUpEvent:FireServer(selectedTrainerName)
	
	task.wait(0.4)
	
	if selectedTrainerName then
		updateTrainerUI(selectedTrainerName)
		
		updateStageButton(selectedTrainerName)
		updateStageReadyFrame()
		updateTrainerCards()
		selectTrainer(selectedTrainerName)
	end
	updateEquipButton()
end)

trainerStageResultEvent.OnClientEvent:Connect(function(success, trainerName, reason, data)
	if success then
		stageRequirementFrame.Visible = false
		
		task.wait(0.2)
		
		if selectedTrainerName then
			
			if selectedTrainerName then
				updateTrainerUI(selectedTrainerName)
			end
			
			updateStageButton(selectedTrainerName)
			updateTrainerCards()
			selectTrainer(selectedTrainerName)
		end
		return
	end
	
	if reason == "NeedLevel" then
		showStageRequirements( 
			"Level: " .. 
				tostring(data.CurrentLevel) .. " / " .. tostring(data.NeedLevel),
			"Reach max level first"
		)
		return
	end
	
	if reason == "MissingRequirements" then
		local line1 = ""
		local line2 = ""
		
		if data.Energy then
			line1 = "Energy: " .. formatNumber(data.Energy.Current) .. " / " .. formatNumber(data.Energy.Need)
		elseif data.Money then
			line1 = "Money: " .. formatNumber(data.Money.Current) .. " / " .. formatNumber(data.Money.Need)
		elseif data.Rebirth then
			line1 = "Rebirth: " .. formatNumber(data.Rebirth.Current) .. " / " .. formatNumber(data.Rebirth.Need)
		elseif data.PetHatched then
			line1 = "Pet Hatched: " .. formatNumber(data.PetHatched.Current) .. " / " .. formatNumber(data.PetHatched.Need)
		end
		
		if data.TreadmillTime then
			line2 = "Treadmill Time: " .. formatTime(data.TreadmillTime.Current) .. " / " .. formatTime(data.TreadmillTime.Need)
		end
		
		if reason == "MaxStage" then
			showStageRequirements( 
				"Max Stage reached",
				"Your trainer is already Mythic"
			)
		end
		
		showStageRequirements(line1, line2)
		return
	end
end)

task.wait(0.25)
selectTrainer("LedyTrainer")
closeCards()
updateTrainerCards()

if selectedTrainerName then
	updateTrainerUI(selectedTrainerName)
end
updateStageButton(selectedTrainerName)
updateStageReadyFrame()

local function getPlayerStat(statName)
	local leaderstats = player:WaitForChild("leaderstats")
	local playerData = player:WaitForChild("PlayerData")
	
	local stat = leaderstats:FindFirstChild(statName)
	if stat then
		return stat
	end
	
	stat = playerData:FindFirstChild(statName)
	if stat then
		return stat
	end
	
	warn("Stat not found:", statName)
	return nil
end

local function connectPlayerStat(statName)
	local stat = getPlayerStat(statName)
	
	if stat then
		stat.Changed:Connect(function()
			updateLeaderstatsUITrainer()
		end)
	end
end

local function connectTrainerCardUpdates()
	local trainerFolder = player:FindFirstChild("Trainer")

	for _, trainerData in ipairs(trainerFolder:GetChildren()) do
		for _, value in ipairs(trainerData:GetChildren()) do
			if value:IsA("ValueBase") then
				value.Changed:Connect(function()
					updateTrainerCards()

					if selectedTrainerName == trainerData.Name then
						updateEquipButton()

						if selectedTrainerName then
							updateTrainerUI(selectedTrainerName)
						end

						updateStageButton(selectedTrainerName)
					end
				end)
			end
		end
	end
end

task.spawn(function()
	local leaderstats = player:WaitForChild("leaderstats")
	local playerData = player:WaitForChild("PlayerData")

	connectPlayerStat("Energy")
	connectPlayerStat("Money")
	connectPlayerStat("Rebirth")
	connectPlayerStat("SrRobux")

	updateLeaderstatsUITrainer()

	local resources = player:WaitForChild("Resources")
	local sharedXP = resources:WaitForChild("XPModule")

	sharedXP.Changed:Connect(function()
		if selectedTrainerName then

			if selectedTrainerName then
				updateTrainerUI(selectedTrainerName)
			end
		end
	end)
end)

task.spawn(function()
	task.wait(1)
	connectTrainerCardUpdates()
	updateTrainerCards()
end)

print("TrainerUI loaded")