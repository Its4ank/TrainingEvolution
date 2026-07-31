--// TrailUI 1.2v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local raceGui = script.Parent

--// MONULES
local TrailModule = require(ReplicatedStorage.Modules.TrailModule)
local MenuManager = require(ReplicatedStorage.Modules.MenuManager)

--// REMOTES
local trailEventFolder = ReplicatedStorage:WaitForChild("TrailEvent")
local trailRequestFunction = trailEventFolder:WaitForChild("TrailRequestFunction")

--// GUI
local trailFolder = raceGui:WaitForChild("TrailFolder")
local trailHost = trailFolder:WaitForChild("TrailHost")
local trailMenu = trailHost:WaitForChild("TrailMenu")
local trailStage = trailHost:WaitForChild("TrailStage")
local trailStageBlur = trailHost:WaitForChild("TraStageBlur")
local warningLabel = trailHost:WaitForChild("TraWarningLabel")

--// LEADERSTATS
local trailLeaderstats = trailHost:WaitForChild("TrailLeaderstats")

local moneyLead = trailLeaderstats:WaitForChild("MoneyLead")
local rebirthLead = trailLeaderstats:WaitForChild("RebirthLead")
local srRobuxLead = trailLeaderstats:WaitForChild("SrRobuxLead")

--// MAIN MENU
local trailStats = trailMenu:WaitForChild("TrailStats")
local trailPreviewFrame = trailMenu:WaitForChild("TrailPreviewFrame")
local trailChoiceButton = trailMenu:WaitForChild("TrailChoiceButton")
local trailListBackButton = trailMenu:WaitForChild("TrailListBackButton")
local trailListNextButton = trailMenu:WaitForChild("TrailListNextButton")
local trailClose = trailMenu:WaitForChild("TrailClose")

--// TRAIL STATS
local trailNameLabel = trailStats:WaitForChild("TraStatTrailName")
local stageIcon = trailStats:WaitForChild("TraStatStageIcon")
local stageNameLabel = trailStats:WaitForChild("TraStatStageName")
local powerBoostLabel = trailStats:WaitForChild("TraStatPowerBoost")
local accelerationBoostLabel = trailStats:WaitForChild("TraStatAccBoost")
local levelLabel = trailStats:WaitForChild("TraStatLevel")
local xpBar = trailStats:WaitForChild("TraStatXpBar")
local xpLabel = trailStats:WaitForChild("TraStatXpLabel")
local equipButton = trailStats:WaitForChild("TraStatEquipInfo")
local infoLabel = trailStats:WaitForChild("TraStatInfo")
local buyUpgradeFrame = trailStats:WaitForChild("TraStatUpUpgLvl")
local buyUpgradeButton = buyUpgradeFrame:WaitForChild("TraStatBuy/Upg")
local upgradePriceLabel = buyUpgradeFrame:WaitForChild("TraStatUpgPrice")
local stageOpenButton = trailStats:WaitForChild("TraStatStageOpen")

--// STAGE
local stageCurrentIcon = trailStage:WaitForChild("TraStageCurIcon")
local stageNextIcon = trailStage:WaitForChild("TraStageNextIcon")
local stageCurrentBoost = trailStage:WaitForChild("TraStageCurBoost")
local stageNextBoost = trailStage:WaitForChild("TraStageNextBoost")

local stageBar1 = trailStage:WaitForChild("TraStageBar1")
local stageBar2 = trailStage:WaitForChild("TraStageBar2")
local stageBar3 = trailStage:WaitForChild("TraStageBar3")

local stageRequirement1 = trailStage:WaitForChild("TraStageRequir1")
local stageRequirement2 = trailStage:WaitForChild("TraStageRequir2")
local stageRequirement3 = trailStage:WaitForChild("TraStageRequir3")

local stageCloseButton = trailStage:WaitForChild("TraStageClose")
local stageUpButton = trailStage:WaitForChild("TraStageUpButton")

--// STATE
local selectedTrail = TrailModule.DEFAULT_TRAIL_ID

local allTrailData = {}
local orderedTrailIds = {}

local selectedTrailIndex = 1

local requestBusy = false
local warningToken = 0

--// TRAILO BUTTON CONFIGURATION
local trailChoiceButtons = {
	{
		Button = trailChoiceButton,
		TrailId = "TrailStone",
	},
}

--// GENERIC GUI HELPERS
local function setText(guiObject, text)
	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
		guiObject.Text = tostring(text or "")
		return
	end
	
	local textLabel = guiObject:FindFirstChildWhichIsA("TextLabel", true)
	
	if textLabel then
		textLabel.Text = tostring(text or "")
	end
end

local function setImage(guiObject, imageId)
	if not guiObject then 
		return
	end
	
	imageId = imageId or ""
	
	if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
		guiObject.Image = imageId
		return
	end
	
	local imageObject = guiObject:FindFirstChildWhichIsA("ImageLabel", true)
	
	if imageObject then
		imageObject.Image = imageId
	end
end

local function setButtonEnabled(button, enabled)
	if not button:IsA("GuiButton") then
		return
	end
	
	button.Active = enabled
	button.AutoButtonColor = enabled
	button.Selectable = enabled
end

local function formatNumber(number)
	number = tonumber(number) or 0
	
	local absolute = math.abs(number)
	
	if absolute >= 1e18 then
		return string.format("%.2fQ", number / 1e18)
	elseif absolute >= 1e12 then
		return string.format("%.2fT", number / 1e12)
	elseif absolute >= 1e9 then
		return string.format("%.2fB", number / 1e9)
	elseif absolute >= 1e6 then
		return string.format("%.2fM", number / 1e6)
	elseif absolute >= 1e3 then
		return string.format("%.2fK", number / 1e3)
	end
	return tostring(math.floor(number))
end

local function showWarning(message, duration)
	warningToken += 1
	
	local currentToken = warningToken
	
	setText(warningLabel, message)
	warningLabel.Visible = true
	
	
	task.delay(duration or 2.5, function()
		if warningToken ~= currentToken then
			return
		end
		warningLabel.Visible = false
	end)
end

--// SERVER REQUEST
local function requestServer(action, trailId)
	if requestBusy then
		return nil
	end
	
	requestBusy = true
	
	local success, response = pcall(function()
		return trailRequestFunction:InvokeServer(action, trailId)
	end)
	
	requestBusy = false
	
	if not success then
		warn("TrailUI server request failed:", action, trailId, response)
		showWarning("Ошибка соединения с сервером")
		return nil
	end
	
	if type(response) ~= "table" then
		showWarning("Сервер вернул неверные данные")
		return nil
	end
	return response
end

--// PLAYER RESOURCES
local function updateLeaderstatsGui()
	local leaderstats = player:FindFirstChild("leaderstats")
	local playerData = player:FindFirstChild("PlayerData")
	
	if leaderstats then
		local rebirth = leaderstats:FindFirstChild("Rebirth")
		
		if rebirth then
			setText(rebirthLead, formatNumber(rebirth.Value))
		end
	end
	
	if playerData then
		local money = playerData:FindFirstChild("Money")
		local srRobux = playerData:FindFirstChild("SrRobux")
		
		if money then
			setText(moneyLead, formatNumber(money.Value))
		end
		
		if srRobux then
			setText(srRobuxLead, formatNumber(srRobux.Value))
		end
	end
end

local function connectResourceUpdates()
	local leaderstats = player:WaitForChild("leaderstats")
	local playerData = player:WaitForChild("PlayerData")
	
	local money = playerData:WaitForChild("Money")
	local srRobux = playerData:WaitForChild("SrRobux")
	local rebirth = leaderstats:WaitForChild("Rebirth")
	
	money:GetPropertyChangedSignal("Value"):Connect(updateLeaderstatsGui)
	srRobux:GetPropertyChangedSignal("Value"):Connect(updateLeaderstatsGui)
	rebirth:GetPropertyChangedSignal("Value"):Connect(updateLeaderstatsGui)
	
	updateLeaderstatsGui()
end

--// XP BAR
local function updateXPBar(trailData)
	local upgradeCost = trailData.UpgradeCost
	local resources = trailData.PlayerResources
	
	if not upgradeCost or not resources then
		xpBar.Size = UDim2.fromScale(1, 1)
		
		if trailData.Level >= trailData.MaxLevel then
			setText(xpLabel, "MAX LEVEL")
		else
			setText(xpLabel, "0 / 0")
		end
		
		
		return
	end
	
	local currentXP = resources.XP or 0
	local requiredXP = upgradeCost.XP or 0
	
	local progress = 1
	
	if requiredXP > 0 then
		progress = math.clamp(currentXP / requiredXP, 0, 1)
	end
	
	xpBar.Size = UDim2.fromScale(progress, 1)
	
	setText(xpLabel, formatNumber(currentXP) .. " / " .. formatNumber(requiredXP))
end

local function updateStageProgressBar(bar, progress)
	progress = math.clamp(tonumber(progress) or 0, 0, 1)
	
	bar.Size = UDim2.new(progress, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
end

local function closeStageMenu()
	trailStage.Visible = false
	trailStageBlur.Visible = false
end

local function renderStageMenu()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные трейла не найдены")
		closeStageMenu()
		return
	end
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		closeStageMenu()
		return
	end
	
	if trailData.IsMaxStage then
		showWarning("Достигнута максимальная стадия")
		closeStageMenu()
		return
	end
	
	-- Иконки текущей т следующей стадии
	setImage(stageCurrentIcon, trailData.StageIcon)
	
	local nextStageId = trailData.Stage + 1
	
	setImage(stageNextIcon, TrailModule.GetStageIcon(nextStageId))
	
	-- Множитель текущей и следующей стадии
	local currentStageConfig = TrailModule.GetStageConfig(trailData.Stage)
	local nextStageConfig = TrailModule.GetStageConfig(nextStageId)
	local currentMultiplier = currentStageConfig and currentStageConfig.Multiplier or 1
	local nextMultiplier = nextStageConfig and nextStageConfig.Multiplier or 1
	
	setText(stageCurrentBoost, TrailModule.FormatMultiplier(currentMultiplier))
	setText(stageNextBoost, TrailModule.FormatMultiplier(nextMultiplier))
	
	-- Прогресс требований
	local progress = trailData.StageProgress
	
	if not progress then
		setButtonEnabled(stageUpButton, false)
		showWarning("Требования стадии не найдены")
		return
	end
	
	-- 1: Level
	setText(stageRequirement1, formatNumber(progress.Level.Current) .. " / " .. formatNumber(progress.Level.Required))
	updateStageProgressBar(stageBar1, progress.Level.Progress)
	
	-- 2: Money
	setText(stageRequirement2, formatNumber(progress.Money.Current) .. " / " .. formatNumber(progress.Money.Required))
	updateStageProgressBar(stageBar2, progress.Money.Progress)
	
	-- 3: Rebirth
	setText(stageRequirement3, formatNumber(progress.Rebirth.Current) .. " / " .. formatNumber(progress.Rebirth.Required))
	updateStageProgressBar(stageBar3, progress.Rebirth.Progress)
	setButtonEnabled(stageUpButton, progress.CanStageUp == true)
end

--// PREVIEW
local function updateTrailPreview(trailData)
	-- tut vizual treyla
	
	trailPreviewFrame:SetAttribute("SelectedTrail", trailData.TrailId)
end

--// CHOICE BUTTONS
local function updateChoiceButtons()
	for _, buttonData in ipairs(trailChoiceButtons) do
		local button = buttonData.Button
		local trailId = buttonData.TrailId
		
		local isSelected = trailId == selectedTrail
		
		button:SetAttribute("Selected", isSelected)
		
		local selectedImage = TrailModule.Icons.TrailList.Selected
		local defaultImage = TrailModule.Icons.TrailList.Default
		
		if button:IsA("ImageButton") and selectedImage ~= "" and defaultImage ~= "" then
			button.Image = isSelected and selectedImage or defaultImage
		end
	end
end

--// MAIN RENDER
local function renderSelectedTrail()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные выббранного трейла не найдены")
		return
	end
	
	setText(trailNameLabel, trailData.DisplayName)
	setText(stageNameLabel, trailData.StageName)
	setImage(stageIcon, trailData.StageIcon)
	setText(levelLabel, "LEVEL " .. tostring(trailData.Level) .. " / " .. tostring(trailData.StageMaxLevel))
	
	local boosts = trailData.Boosts or {}
	
	setText(powerBoostLabel, TrailModule.FormatPercent(boosts.PowerPercent or 0))
	setText(accelerationBoostLabel, TrailModule.FormatPercent(boosts.AccelerationPercent or 0))
	setText(infoLabel, trailData.Description or "")
	
	updateXPBar(trailData)
	updateTrailPreview(trailData)
	updateChoiceButtons()
	
	if not trailData.Owned then
		setText(buyUpgradeButton, "BUY")
		setText(upgradePriceLabel, formatNumber(trailData.Purchase.Price))
		setText(equipButton, "EQUIP")
		setButtonEnabled(equipButton, false)
		setButtonEnabled(buyUpgradeButton, trailData.Available == true)
		
	elseif trailData.Level >= trailData.MaxLevel then
		setText(buyUpgradeButton, "MAX")
		setText(upgradePriceLabel, "MAX")
		
		setButtonEnabled(buyUpgradeButton, false)
		setButtonEnabled(equipButton, true)
		
	elseif not trailData.CanLevelUpAtStage then
		setText(buyUpgradeButton, "UPGRADE")
		setText(upgradePriceLabel, "STAGE UP")
		setButtonEnabled(buyUpgradeButton, false)
		setButtonEnabled(equipButton, true)
	else
		setText(buyUpgradeButton, "UPGRADE")
		local upgradeCost = trailData.UpgradeCost
		
		if upgradeCost then
			setText(upgradePriceLabel, formatNumber(upgradeCost.Money))
		else
			setText(upgradePriceLabel, "-")
		end
		
		setButtonEnabled(buyUpgradeButton, true)
		setButtonEnabled(equipButton, true)
	end
	
	if trailData.Owned then
		if trailData.Equipped then
			setText(equipButton, "UNEQUIP")
		else
			setText(equipButton, "EQUIP")
		end
	end
	
	setButtonEnabled(stageOpenButton, trailData.Owned == true and trailData.IsMaxStage ~= true)
	
	updateLeaderstatsGui()
end

--// DATA LOADING
local function rebuildOrderedTrailList()
	table.clear(orderedTrailIds)
	
	for trailId, trailData in pairs(allTrailData) do
		table.insert(orderedTrailIds, {
			TrailId = trailId,
			Order = trailData.Order or 999,
		})
	end
	
	table.sort(orderedTrailIds, function(a, b)
		return a.Order < b.Order
	end)
	
	for index, data in ipairs(orderedTrailIds) do
		if data.TrailId == selectedTrail then
			selectedTrailIndex = index
			break
		end
	end
end

local function loadAllTrailData()
	local response = requestServer("GetAllData")
	
	if not response then
		return false
	end
	
	if not response.Success then
		showWarning(response.Message)
		return false
	end
	
	local data = response.Data
	
	if type(data) ~= "table" or type(data.Trails) ~= "table" then
		showWarning("Не удалось загрузить трейлы")
		return false
	end
	
	allTrailData = data.Trails
	
	if not allTrailData[selectedTrail] then
		selectedTrail = data.DefaultTrailId or TrailModule.DEFAULT_TRAIL_ID
	end
	
	rebuildOrderedTrailList()
	renderSelectedTrail()
	
	return true
end

local function applyActionResponse(response)
	if not response then
		return
	end
	
	if response.Message and response.Message ~= "" then
		showWarning(response.Message)
	end
	
	if not response.Success then
		return
	end
	
	local updateTrail = response.Data
	
	if type(updateTrail) == "table" and updateTrail.TrailId then
		allTrailData[updateTrail.TrailId] = updateTrail
	end
	
	renderSelectedTrail()
end

--// SELECT TRAIL
local function selectTrail(trailId)
	if not allTrailData[trailId] then
		showWarning("Этот трейл пока недостуен")
		return
	end
	
	selectedTrail = trailId
	
	for index, data in ipairs(orderedTrailIds) do
		if data.TrailId == trailId then
			selectedTrailIndex = index
			break
		end
	end
	renderSelectedTrail()
end

local function selectPreviousTrail()
	if #orderedTrailIds <= 1 then
		return
	end
	
	selectedTrailIndex -= 1
	
	if selectedTrailIndex < 1  then
		selectedTrailIndex = #orderedTrailIds
	end
	
	selectTrail(orderedTrailIds[selectedTrailIndex].TrailId)
end

local function selectNextTrail()
	if #orderedTrailIds <= 1 then
		return
	end
	
	selectedTrailIndex += 1
	
	if selectedTrailIndex > #orderedTrailIds then
		selectedTrailIndex = 1
	end
	
	selectTrail(orderedTrailIds[selectedTrailIndex].TrailId)
end

--// BUTTON ACTIONS
buyUpgradeButton.Activated:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		return
	end
	
	if not trailData.Owned then
		local response = requestServer("PurchaseTrail", selectedTrail)
		
		applyActionResponse(response)
		return
	end
	
	if trailData.Level >= trailData.MaxLevel then
		showWarning("Достигнут максимальный уровень")
		return
	end
	
	if not trailData.CanLevelUpAtStage then
		showWarning("Необходимо повысть стадию для открытия следующих уровней")
		return
	end
	
	local response = requestServer("UpgradeTrail", selectedTrail)
	
	applyActionResponse(response)
end)

equipButton.Activated:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		return
	end
	
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		return
	end
	
	local response = requestServer("ToggleEquip", selectedTrail)
	
	applyActionResponse(response)
	
	if response and response.Success then
		loadAllTrailData()
	end
end)

stageOpenButton.Activated:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные трейла не найдены")
		return
	end
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		return
	end
	
	if trailData.IsMaxStage then
		showWarning("Достигнута максимальная стадия")
		return
	end
	
	local response = requestServer("GetTrailData", selectedTrail)
	
	if not response then
		return
	end
	
	if not response.Success then
		showWarning(response.Message)
		return
	end
	
	local updateTrail = response.Data
	
	if type(updateTrail) ~= "table" or not updateTrail.TrailId then
		showWarning("Не удалось обновить данные стадии")
		return
	end
	
	allTrailData[updateTrail.TrailId] = updateTrail
	
	trailData = updateTrail
	
	trailStage:SetAttribute("SelectedTrail", selectedTrail)
	
	renderStageMenu()
	
	trailStageBlur.Visible = true
	trailStage.Visible = true
end)

stageUpButton.Activated:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные трейла не найдены")
		return
	end
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		return
	end
	
	if trailData.IsMaxStage then
		showWarning("Достигнута максимальная стадия")
		closeStageMenu()
		return
	end
	
	local progress = trailData.StageProgress
	
	if not progress then
		showWarning("Требования стадии не найдены")
		return
	end
	
	if not progress.CanStageUp then
		showWarning("Не все требования выполнены")
		return
	end
	
	setButtonEnabled(stageUpButton, false)
	
	local response = requestServer("StageUp", selectedTrail)
	
	if not response then
		renderStageMenu()
		return
	end
	
	if response.Message and response.Message ~= "" then
		showWarning(response.Message)
	end
	
	if not response.Success then
		renderStageMenu()
		return
	end
	
	local updateTrail = response.Data
	
	if type(updateTrail) ~= "table" or not updateTrail.TrailId then
		showWarning("Сервер вернул неверные данные трейла")
		loadAllTrailData()
		closeStageMenu()
		return
	end
	
	allTrailData[updateTrail.TrailId] = updateTrail
	
	renderSelectedTrail()
	
	if updateTrail.IsMaxStage then
		closeStageMenu()
		return
	end
	
	renderStageMenu()
end)

stageCloseButton.Activated:Connect(function()
	closeStageMenu()
end)

trailListBackButton.Activated:Connect(selectPreviousTrail)
trailListNextButton.Activated:Connect(selectNextTrail)

for _, buttonData in ipairs(trailChoiceButtons) do
	buttonData.Button.Activated:Connect(function()
		selectTrail(buttonData.TrailId)
	end)
end

trailClose.Activated:Connect(function()
	trailStage.Visible = false
	trailStageBlur.Visible = false
	
	MenuManager.close("Trails")
end)


--// OPEN REFRESH
trailMenu:GetPropertyChangedSignal("Visible"):Connect(function()
	if not trailMenu.Visible then
		return
	end
	
	loadAllTrailData()
end)

--// INITIALIZED
warningLabel.Visible = false
trailStage.Visible = false 
trailStageBlur.Visible = false

connectResourceUpdates()

task.spawn(function()
	while player:GetAttribute("DataReady") ~= true do
		player:GetAttributeChangedSignal("DataReady"):Wait()
	end
	
	loadAllTrailData()
end)

print("TrailUI loaded")
