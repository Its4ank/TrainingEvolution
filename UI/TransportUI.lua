--// TransportUI v1.3

--// SEVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// PLAYER
local player = Players.LocalPlayer 

--// MODULES
local TransportModule = require(ReplicatedStorage.Modules.TransportModule)
local FormatModule = require(ReplicatedStorage.Modules.FormatModule)

--// CONFIG
local LOCATION_ID = "StoneAge"

local XP_BAR_MIN = -0.95
local XP_BAR_MAX = 0.02

local STAGE_BAR_MIN = -0.95
local STAGE_BAR_MAX = 0.018

local BAR_TWEEN_TIME = 0.25

local WARNING_DURATION = 3

--// REMOTES
local transportEvent = ReplicatedStorage.Remotes:WaitForChild("TransportEvent")

local actionEvent = transportEvent:WaitForChild("TransportActionEvent")
local resultEvent = transportEvent:WaitForChild("TransportResultEvent")
local warningEvent = transportEvent:WaitForChild("TransportWarningEvent")

--// GUI
local transportFolder = script.Parent 

local host = transportFolder:WaitForChild("TransportHost")
local transportMenu = host:WaitForChild("TransportMenu")
local stageMenu = host:WaitForChild("TranStageMenu")
local stageResources = host:WaitForChild("TranStageResources")
local blurFrame = host:WaitForChild("TranBlurFrame")
local warningLabel = host:WaitForChild("TranWarningLabel")

--// TRANSPORT MENU
local viewport = transportMenu:WaitForChild("TranViewportModel")

local locationFolder = transportMenu:WaitForChild("TranLocation")
local stoneAgeButton = locationFolder:WaitForChild("TranLocatStoneAge")
local feetButton = locationFolder:WaitForChild("TranLocFeedButton")
local logButton = locationFolder:WaitForChild("TranLocLogButton")
local stoneButton = locationFolder:WaitForChild("TranLocStoneButton")

local backButton = transportMenu:WaitForChild("TranBackButton")
local nextButton = transportMenu:WaitForChild("TranNextButton")
local closeButton = transportMenu:WaitForChild("TranMenuClose")

--// SELECTION INDICATORS
local selectionIndicators = {
	transportMenu:WaitForChild("TranSelect1"),
	transportMenu:WaitForChild("TranSelect2"),
	transportMenu:WaitForChild("TranSelect3"),
}

--// DETAILS
local detailsFolder = transportMenu:WaitForChild("TranDetailsFolder")
local details = detailsFolder:WaitForChild("TranDetails")
local nameLabel = details:WaitForChild("TranDetName")
local stageNameLabel = details:WaitForChild("TranDetNameStage")
local stageIcon = details:WaitForChild("TranDetStageIcon")
local powerCurrent = details:WaitForChild("DetPowerCurBoost")
local powerNext = details:WaitForChild("DetPowerNextBoost")
local accelerationCurrent = details:WaitForChild("DetAccCurBoost")
local accelerationNext = details:WaitForChild("DetAccNextBoost")
local levelLabel = details:WaitForChild("DetLvlNumber")

--// XP BAR
local xpBarWindow = details:WaitForChild("DetUpgBarWindow")
local xpBar = xpBarWindow:WaitForChild("DetUpgBarXp")
local xpLabel = details:WaitForChild("BarXpLabel")

--// BUTTONS
local equipButton = details:WaitForChild("TranEquipButton")
local equipLabel = equipButton:WaitForChild("TranDetEquipLabel")
local upgradeButton = details:WaitForChild("TranDetUpgButton")
local upgradeMoney = upgradeButton:WaitForChild("UpgPriceTouch")
local stageOpenButton = details:WaitForChild("TranDetStageUpButton")

--// STAGE MENU
local stageCurrentIcon = stageMenu:WaitForChild("StaCurIcon")
local stageNextIcon = stageMenu:WaitForChild("StaNextIcon")
local stageCurrentName = stageMenu:WaitForChild("StageCurName")
local stageNextName = stageMenu:WaitForChild("StageNextName")
local stageCurrentBoost = stageMenu:WaitForChild("StaCurBoost")
local stageNextBoost = stageMenu:WaitForChild("StaNextBoost")
local requiredLevel = stageMenu:WaitForChild("StaRequirLevel")
local requiredTouch = stageMenu:WaitForChild("StaRequirTouch")
local requiredMoney = stageMenu:WaitForChild("StaRequirMoney")
local requiredDistance = stageMenu:WaitForChild("StaRequirDistance")
local stageBarWindow = stageMenu:WaitForChild("StaBarWindow")
local stageBar = stageBarWindow:WaitForChild("StageRequirBar")
local stagePercent = stageMenu:WaitForChild("StaRequirBarPercent")
local stageUpButton = stageMenu:WaitForChild("StageUpButton")
local stageCloseButton = stageMenu:WaitForChild("StageClose")

--// CURRENT RESOURCES
local resourceTouch = stageResources:WaitForChild("ResRaceTouchLabel")
local resourceMoney = stageResources:WaitForChild("ResMoneyLabel")
local resourceDistance = stageResources:WaitForChild("ResDistanceLabel")

--// PLAYER DATA
local playerData = player:WaitForChild("PlayerData")
local resources = player:WaitForChild("Resources")
local moneyValue = playerData:WaitForChild("Money")
local touchValue = playerData:WaitForChild("RaceTouch")
local xpValue = resources:WaitForChild("XPModule")
local distanceValue = resources:WaitForChild("Distance")
local transports = player:WaitForChild("Transports")
local locationData = transports:WaitForChild(LOCATION_ID)

--// TRANSPORT ORDER
local transportOrder = TransportModule.GetTransportOrder(LOCATION_ID) or {}

local transportButtons = {
	Feet = feetButton,
	Log = logButton,
	Stone = stoneButton,
}

--// STATE
local selectedTransportId = TransportModule.DEFAULT_TRANSPORT

local warningToken = 0
local activeTweens = {}

--// FORMAT
local function formatNumber(value)
	return FormatModule.FormatNumber(value or 0)
end

local function formatPercent(value)
	return FormatModule.FormatPercent(value or 0)
end

--// RESOURCES
local function getCurrentResources()
	return {
		
		Money = moneyValue.value,
		RaceTouch = touchValue.Value,
		XP = xpValue.Value,
		Distance = distanceValue.Value,
	}
end

--// TRANSPORT DATA
local function getTransportData(transportId)
	local folder = locationData:FindFirstChild(transportId)
	if not folder then return nil end
	
	local unlocked = folder:FindFirstChild("Unlocked")
	local owned = folder:FindFirstChild("Owned")
	local equipped = folder:FindFirstChild("Equipped")
	local level = folder:FindFirstChild("Level")
	local stage = folder:FindFirstChild("Stage")
	
	if not unlocked or not owned or not equipped or not level or not stage then return nil end
	
	return {
		Unlocked = unlocked.Value,
		Owned = owned.Value,
		Equipped = equipped.Value,
		Level = level.Value,
		Stage = stage.Value,
	}
end

--// WARNING
local function showWarning(message)
	warningToken += 1
	
	local token = warningToken
	
	warningLabel.Text = message
	warningLabel.Visible = true
	
	task.delay(WARNING_DURATION, function()
		if warningToken == token then
			warningLabel.Visible = false 
		end
	end)
end

--// BAR ANIMATION
local function updateBar(bar, progress, minX, maxX, yScale)
	progress = math.clamp(progress or 0, 0, 1)
	
	local targetX = minX + (maxX - minX) * progress
	
	local targetPosition = UDim2.new(targetX, 0, yScale, 0)
	
	if activeTweens[bar] then
		activeTweens[bar]:Cancel()
	end
	
	local tween = TweenService:Create(bar, TweenInfo.new(BAR_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPosition})
	
	activeTweens[bar] = tween
	tween:Play()
end

--// ICON
local function setIcon(object, iconId)
	if iconId and iconId ~= "" then
		object.Image = iconId
	end
end

--// SELECTION INDICATORS
local function updateSelecionIndicators()
	for index, indicator in ipairs(selectionIndicators) do
		local transportId = transportOrder[index]
		local selected = transportId == selectedTransportId
		local state = selected and "Selected" or "Default"
		
		local icon = TransportModule.GetTransportIocn(LOCATION_ID, transportId, state)
		
		setIcon(indicator, icon)
	end
end

--// TRANSPORT BUTTONS
local function updateTransportButtons()
	for _, transportId in ipairs(transportOrder) do
		local button = transportButtons[transportId]
		if not button then continue end 
		
		local data = getTransportData(transportId)
		if not data then continue end
		
		local state
		
		if not data.Unlocked then
			state = "Locked"
		elseif selectedTransportId == transportId then
			state = "Selected"
		else 
			state = "Default"
		end
		
		local icon = TransportModule.GetTransportIcon(LOCATION_ID, transportId, state)
		
		setIcon(button, icon)
		
		local lockIcon = button:FindFirstChild("TranLockIcon")
		if lockIcon then
			lockIcon.Visible = not data.Unlocked
		end
		
		local requiredStageLabel = button:FindFirstChild("LocStageName")
		if requiredStageLabel then
			local config = TransportModule.GetTransport(LOCATION_ID, transportId)
			
			if config and config.Unlock then
				requiredStageLabel.Text = "STAGE " .. tostring(config.Unlock.RequiredStage or 5)
			end
			
			requiredStageLabel.Visible = not data.Unlocked
		end
	end
end

--// VIEWPORT
local function updateViewport()
	viewport:ClearAllChiuldren()
	
	local config = TransportModule.GetTransport(LOCATION_ID, selectedTransportId)
	if not config then return end
	
	local visual = TransportModule.GetViewportData(LOCATION_ID, selectedTransportId)
	if not visual or not visual.ModelName then return end
	
	local modelsFolder = ReplicatedStorage:FindFirstChild("TransportModels")
	if not modelsFolder then return end
	
	local originalModel = modelsFolder:FindFirstChild(visual.ModelName)
	if not originalModel then return end
	
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport
	
	local model = originalModel:Clone()
	model.Parent = worldModel
	
	local boundingCFrame, boundingSize = model:GetBoundingBox()
	
	model:PivotTo(CFrame.new(0, 0, 0) * boundingCFrame.Rotation)
	
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	
	viewport.CurrentCamera = camera
	
	local viewportConfig = visual.Viewport or {}
	local rotation = viewportConfig.Rotation or Vector3.zero
	local cameraDistance = viewportConfig.CameraDistance or math.max(boundingSize.Magnitude, 5)
	local cameraHeight = viewportConfig.CameraHeight or viewportConfig.CameraHight or 1
	local rotationCFrame = CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	local cameraOffset = rotationCFrame:VectorToWorldSpace(Vector3.new(0, cameraHeight, cameraDistance))
	
	camera.CFrame = CFrame.lookAt(cameraOffset, Vector3.zero)
end

--// XP PROGRESS
local function updateXPBar(data)
	local canUpgrade = TransportModule.CanLevelUp(data.Level, data.Stage)
	
	if not canUpgrade then
		xpLabel.Text = "MAX"
		
		updateBar(xpBar, 1, XP_BAR_MIN, XP_BAR_MAX, 0.27)
		return
	end
	
	local price = TransportModule.GetNextLevelPrice(LOCATION_ID, selectedTransportId, data.Level)
	if not price then 
		xpLabel.Text = "0/0"
		
		updateBar(xpBar, 0, XP_BAR_MIN, XP_BAR_MAX, 0.27)
		return
	end
	
	local requiredXP = price.XP or 0
	local currentXP = xpValue.Value
	
	local progress = requiredXP > 0 and math.clamp(currentXP / requiredXP, 0, 1) or 1
	
	xpLabel.Text = formatNumber(currentXP) .. "/" .. formatNumber(requiredXP)
	updateBar(xpBar, progress, XP_BAR_MIN, XP_BAR_MAX, 0.27)
end

--// UPGRADE PRICE
local function updateUpgradePrice(data)
	local canUpgrade = TransportModule.CanLevelUp(data.Level, data.Stage)
	if not canUpgrade then
		upgradeMoney.Text = "MAX"
		upgradeTouch.Text = "MAX"
		return
	end
	
	local price = TransportModule.GetNextLevelPrice(LOCATION_ID, selectedTransportId, data.Level)
	if not price then
		upgradeMoney.Text = "-"
		upgradeTouch.Text = "-"
		return
	end
	
	updateMoney.Text = formatNumber(price.Money)
	upgradeTouch.Text = formatNumber(price.Touch)
end

--// BOOSTS
local function updateBoosts(data)
	local boostData = TransportModule.GetCurrentAndNextBoost(LOCATION_ID, selectedTransportId, data.Level, data.Stage)
	if not boostData then return end
	
	local current = boostData.Current
	local nextBoost = boostData.Next
	
	if current then
		powerCurrent.Text = formatPercent(current.RacePower)
		accelerationCurrent.Text = formatPercent(current.Acceleration)
	end
	
	if nextBoost then
		powerNext.Text = formatPercent(nextBoost.RacePower)
		accelerationNext.Text = formatPercent(nextBoost.Acceleration)
	else 
		powerNext.Text = "MAX"
		accelerationNext.Text = "MAX"
	end
end

--// EQUIP BUTTON
local function updateEquipButton(data)
	if not data.Unlocked then 
		equipLabel.Text = "LOCKED"
		return
	end
	
	if not data.Owned then
		equipLabel.Text = "BUY"
		return
	end
	
	if data.Equipped then
		equipLabel.Text = "UNEQUIP"
	else 
		equipLabel.Text = "EQUIP"
	end
end

--// DETAILS
local function updateDetails()
	local data = getTransportData(selectedTransportId)
	local config = TransportModule.GetTransport(LOCATION_ID, selectedTransportId)
	
	if not data or not config then return end
	
	local stageConfig = TransportModule.GetStage(data.Stage)
	
	nameLabel.Text = config.Name
	stageNameLabel.Text = stageConfig and stageConfig.Name or "Stage 1"
	levelLabel.Text = tostring(data.Level) .. "/" .. tostring(TransportModule.GetStageMaxLevel(data.Stage) or TransportModule.MAX_LEVEL)
	setIcon(stageIcon, TransportModule.GetStageIcon(data.Stage, "Default"))
	
	updateBoosts(data)
	updateXPBar(data)
	updateUpgradePrice(data)
	updateEquipButton(data)
end

--// STAGE RESOURCES
local function updateStageResources()
	resourceMoney.Text = formatNumber(moneyValue.Value)
	resourceTouch.Text = formatNumber(touchValue.Value)
	resourceDistance.Text = formatNumber(distanceValue.Value)
end

--// STAGE MENU
local function updateStageMenu()
	local data = getTransportData(selectedTransportId)
	if not data then return end
	
	local currentStage = TransportModule.GetStage(data.Stage)
	local nextStage = TransportModule.GetStage(data.Stage + 1)
	if not currentStage then return end
	
	stageCurrentName.Text = currentStage.Name
	stageCurrentBoost.Text = formatNumber(currentStage.BoostMultiplier) .. "x"
	setIcon(stageCurrentIcon, TransportModule.GetStageIcon(data.Stage, "Default"))
	
	if not nextStage then
		stageNextName.Text = "MAX"
		stageNextBoost.Text = "MAX"
		
		requiredLevel.Text = "MAX"
		requiredMoney.Text = "MAX"
		requiredTouch.Text = "MAX"
		requiredDistance.Text = "MAX"
		
		stagePercent.Text = "100%"
		
		updateBar(stageBar, 1, STAGE_BAR_MIN, STAGE_BAR_MAX, 0.204)
		updateStageResources()
		return
	end
	
	stageNextName.Text = nextStage.Name
	stageNextBoost.Text = formatNumber(nextStage.BoostMultiplier) .. "x"
	setIcon(stageNextIcon, TransportModule.GetStageIcon(data.Stage + 1, "Default"))
	
	local stageData = TransportModule.GetStageUpData(LOCATION_ID, selectedTransportId, data.Stage)
	if not stageData then return end
	
	local costs = stageData.Cost or {}
	
	requiredLevel.Text = formatNumber(data.Level) .. "/" // formatNumber(stageData.RequiredLevel)
	requiredMoney.Text = formatNumber(costs.Money)
	requiredTouch.Text = formatNumber(costs.RaceTouch)
	requiredDistance.Text = formatNumber(costs.Distance)
	
	local progress = TransportModule.GetStageRequirementProgress(LOCATION_ID, selectedTransportId, data.Level, data.Stage, getCurrentResources())
	if progress then
		stagePercent.Text = formatPercent(progress.OverallPercent)
		updateBar(stageBar, progress.OverallProgress, STAGE_BAR_MIN, STAGE_BAR_MAX, 0.204)
	end
	updateStageResources()
end

--// REFRESH
local function refreshUI()
	updateSelecionIndicators()
	updateTransportButtons()
	updateDetails()
	
	if stageMenu.Visible then
		updateStageMenu()
	end
end

--// SELECT TRANSPORT
local function selectTransport(transportId)
	if not TransportModule.GetTransport(LOCATION_ID, transportId) then return end
	
	selectedTransportId = transportId 
	
	updateViewport()
	refreshUI()
end

--// NAVIGATION
local function getSelectedIndex()
	for index, transportId in ipairs(transportOrder) do
		if transportId == selectedTransportId then return index end
	end
	return 1
end

local function selectPrevious()
	local index = getSelectedIndex()
	if index <= 1 then return end
	
	selectTransport(transportOrder[index - 1])
end

local function selectNext()
	local index = getSelectedIndex()
	
	if index >= #transportOrder then return end
	
	selectTransport(transportOrder[index + 1])
end

--// STAGE WINDOW
local function openStageMenu()
	stageMenu.Visible = true 
	stageResources.Visible = true 
	blurFrame.Visible = true 
	
	updateStageMenu()
end

local function closeStageMenu()
	stageMenu.Visible = false
	stageResources.Visible = false 
	blurFrame.Visible = false 
end

--// ACTION
local function sendAction(actionName)
	if player:GetAttribute("DataReady") ~= true then
		showWarning("Player data is still loading.")
		return
	end
	
	actionEvent:FireServer(actionName, LOCATION_ID. selectedTransportId)
end

--// EQUIP / BUY
local function onEquipClicked()
	local data = getTransportData(selectedTransportId)
	if not data then return end 
	
	if not data.Unlocked then
		showWarning("This transport is unavailable.")
		return
	end
	
	if not data.Owned then
		sendAction("BuyTransport")
		return
	end
	
	sendAction("EquipTransport")
end

--// UPGRADE
local function onUpgradeClicked()
	local data = getTransportData(selectedTransportId)
	if not data then return end 
	
	if not data.Unlocked then
		showWarning("This transport is unavailable.")
		return
	end
	
	if not data.Owned then
		showWarning("First, buy a transport.")
		return
	end
	
	if TransportModule.IsMaxTransport(data.Level, data.Stage) then
		showWarning("The maximum level has been reached.")
		return
	end
	
	if not TransportModule.CanLevelUp(data.Level, data.Stage) then
		showWarning("Firest, increase then stage.")
		return
	end
	
	sendAction("UpgradeTransport")
end

--// STAGE UP
local function onStageUpClicked()
	local data = getTransportData(selectedTransportId)
	if not data then return end 
	
	if not data.Owned then
		showWarning("First, buy a transport.")
		return
	end
	
	if data.Stage >= TransportModule.MAX_STAGE then
		showWarning("Maximum stage reached.")
		return
	end
	
	sendAction("StageUpTransport")
end

--// MISSING REQUIREMENTS
local function buildMissingMessage(missing)
	local names = {
		Level = "Level",
		Money = "Money",
		RaceTouch = "RaceTouch",
		XP = "XP",
		Distance = "Distance",
	}
	
	local order = {
		"Level",
		"Money",
		"RaceTouch",
		"XP",
		"Distance",
	}
	
	local parts = {}
	
	for _, resourceName in ipairs(order) do
		local amount = missing[resourceName]
		
		if amount and amount > 0 then
			table.insert(parts, formatNumber(amount) .. " " .. names[resourceName])
		end
	end
	
	if #parts == 0 then return "Insuffcient resources" end
	
	return "You are lacking: " .. table.concat(parts, ", ")
end

--// SERVER WARNINGS
warningEvent.OnClientEvent:Connect(function(warningType, data)
	if warningType == "TRANSPORT_LOCKED" then
		showWarning("This transport is not available.")
	elseif warningType == "MISSING_RESOURCES" then
		showWarning(buildMissingMessage(data))
	elseif warningType == "MISSING_STAGE_REQUIREMENTS" then
		showWarning(buildMissingMessage(data))
	else 
		showWarning("Action unavailable")
	end
end)

--// SERVER RESULTS
resultEvent.OnClientEvent:Connect(function(actionName, success, reason, locationId, transportId)
	if locationId ~= LOCATION_ID then return end 
	
	if not success then 
		if reason == "STAGE_UP_REQUIRED" then
			showWarning("First, increase the stage.")
		elseif reason == "NOT_OWNED" then
			showWarning("Fist buy the transport.")
		elseif reason == "MAX" then
			showWarning("Maximum level.")
		elseif reason == "MAX_STAGE" then
			showWarning("Maximum stage.")
		elseif reason == "SERVER_STAGE" then
			showWarning("Server Error.")
		elseif reason == "PRICE_NOT_FOUND" then
			showWarning("Upgrade cost not found.")
		end
	end
	
	refreshUI()
end)

--// BUTTOM CONNECTIONS
feetButton.MouseButton1Click:Connect(function()
	selectTransport("Feet")
end)

logButton.MouseButton1Click:Connect(function()
	selectTransport("Log")
end)

stoneButton.MouseButton1Click:Connect(function()
	selectTransport("Stone")
end)

backButton.MouseButton1Click:Connect(selectPrevious)
nextButton.MouseButton1Click:Connect(selectNext)

stoneAgeButton.MouseButton1Click:Connect(function()
	selectTransport(TransportModule.DEFAULT_TRANSPORT)
end)

equipButton.MouseButton1Click:Connect(onEquipClicked)
upgradeButton.MouseButton1Click:Connect(onUpgradeClicked)
stageOpenButton.MouseButton1Click:Connect(openStageMenu)
stageUpButton.MouseButton1Click:Connect(onStageUpClicked)
stageCloseButton.MouseButton1Click:Connect(closeStageMenu)

closeButton.MouseButton1Click:Connect(function()
	closeStageMenu()
	transportMenu.Visible = false
end)

--// RESOURCE CHANGES
moneyValue.Changed:Connect(refreshUI)
touchValue.Changed:Connect(refreshUI)
xpValue.Changed:Connect(refreshUI)
distanceValue.Changed:Connect(refreshUI)

--// TRANSPORT DATA CHANGES
local function connectTransportData()
	for _, transportId in ipairs(transportOrder) do
		local folder = locationData:WaitForChild(transportId)
		
		for _, value in ipairs(folder:GetChildren()) do
			if value:IsA("ValueBase") then
				value.Changed:Connect(refreshUI)
			end
		end
	end
end

--// MENU VISIBILITY
transportMenu:GetPropertyChangedSignal("Visible"):Connect(function()
	if transportMenu.Visible then
		selectTransport(TransportModule.DEFAULT_TRANSPORT)
	end
end)

--// INITIALIZATION
local function initialize()
	closeStageMenu()
	
	warningLabel.Visible = false 
	
	connectTransportData()
	selectTransport(TransportModule.DEFAULT_TRANSPORT)
	updateStageResources()
end

initialize()

print("TransportUI v1.3 loaded")
