--// UpgradeUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local raceGui = script.Parent

--// Modules
local ClientDataModule = require(ReplicatedStorage.Modules.ClientDataModule)
local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)
local MenuManager = require(ReplicatedStorage.Modules.MenuManager)

ClientDataModule.WaitUntilReady(player)
MenuManager.init(raceGui)

--// RemoteEvent
local upgradeEvents = ReplicatedStorage:WaitForChild("UpgradeEvents")

local upgradeEvent = upgradeEvents:WaitForChild("UpgradeEvent")
assert(upgradeEvent:IsA("RemoteEvent"), "UpgradeEvents.UpgradeEvent должен быть RemoteEvent")

--// PLayer Data
local gemsValue = ClientDataModule.GetGems(player)
local upgradesFolder = ClientDataModule.GetUpgrades(player)

--// UI paths
local guiFolder = raceGui:WaitForChild("GuiFolder")
local upgradeFolder = guiFolder:WaitForChild("UpgradeFolder")
local upgradeHost = upgradeFolder:WaitForChild("UpgradeHost")

local upgScrollFrame = upgradeHost:WaitForChild("UpgScrollFrame")
local upgCurrentStatsFrame = upgradeHost:WaitForChild("UpgCurrentStatsFrame")
local upgCurrentFrame = upgradeHost:WaitForChild("UpgCurrentFrame")
local upgLeaderstats = upgradeHost:WaitForChild("UpgLeaderstats")
local upgWarningLabel = upgradeHost:WaitForChild("UpgWarningLabel")
local upgCloseButton = upgradeHost:WaitForChild("UpgCloseButton")

MenuManager.register("Upgrade", upgradeHost)

--// CurrentStats
local upgStatsIcon = upgCurrentStatsFrame:WaitForChild("UpgStatsIcon")
local upgStatsCurMult = upgCurrentStatsFrame:WaitForChild("UpgStatsCurMult")
local upgStatsLvl = upgCurrentStatsFrame:WaitForChild("UpgStatsLvl")
local upgStatsName = upgCurrentStatsFrame:WaitForChild("UpgStatsName")
local upgStatsNextLvl = upgCurrentStatsFrame:WaitForChild("UpgStatsNextLvl")
local upgStatsNextMult = upgCurrentStatsFrame:WaitForChild("UpgStatsNextMult")
local upgStatsInfo = upgCurrentStatsFrame:WaitForChild("UpgStatsInfo")

--// LevelContainer
local upgContainerScroll = upgCurrentFrame:WaitForChild("UpgContainerScroll")
local upgButtonContainer = upgContainerScroll:WaitForChild("UpgButtonContainer")

--// Gems
local gemsLabel = upgLeaderstats:WaitForChild("GemsLabel")

--// Settings
local visibleSlotCount = UpgradeModule.VISIBLE_LEVEL_SLOTS
local centerLevelSlot = UpgradeModule.CENTER_LEVEL_SLOT

local DEFAULT_UPGRADE = "Energy"
local WARNING_TIME = 2.5

--// Runtime data
local selectedUpgradeName = nil
local levelFrames = {}
local levelControls = {}
local upgradeSelectionButtons = {}

local warningVersion = 0

--// Helpers
local function formatNumber(value)
	value = math.floor(tonumber(value) or 0)
	
	local sign = ""
	
	if value < 0 then 
		sign = "-"
		value = math.abs(value)
	end
	
	local text = tostring(value)
	local formatted = text
	
	while true do
		local newText, replacements = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = newText
		
		if replacements == 0 then
			break
		end
	end
	return sign .. formatted
end

local function clearWarning()
	warningVersion += 1
	upgWarningLabel.Visible = false
end

local function showWarning(message)
	warningVersion += 1
	local currentVersion = warningVersion
	
	upgWarningLabel.Text = message
	upgWarningLabel.Visible = true
	
	task.delay(WARNING_TIME, function()
		if warningVersion ~= currentVersion then
			return
		end
		
		upgWarningLabel.Visible = false
	end)
end

local function updateGemsLabel()
	gemsLabel.Text = formatNumber(gemsValue.Value)
end

--// Получаем 10 готовых UpgLvlFrame
local function collectLevelFrames()
	table.clear(levelFrames)
	
	for _, child in ipairs(upgButtonContainer:GetChildren()) do
		if child.Name == "UpgLvlFrame" and child:IsA("GuiObject") then
			table.insert(levelFrames, child)
		end
	end
	
	table.sort(levelFrames, function(firstFrame, secondFrame)
		return firstFrame.LayoutOrder < secondFrame.LayoutOrder
	end)
	
	assert(#levelFrames >= visibleSlotCount, "B UpgButtonContainer должно находится минимум "
		.. tostring(visibleSlotCount) .. " обьектов UpgLvlFrame")
	
	for index = visibleSlotCount + 1, #levelFrames do
		levelFrames[index].Visible = false
	end
end

print("UPGRADE UI: level frames collected", #levelFrames)

--// получаем обьекты каждого слота
local function collectLevelControls()
	table.clear(levelControls)
	
	for slotIndex = 1, visibleSlotCount do
		local levelFrame = levelFrames[slotIndex]
		
		
		local currentIcon = levelFrame:WaitForChild("UpgLvlCurrentIcon")
		local successIcon = levelFrame:WaitForChild("UpgLvlSuccessIcon")
		local bonusLabel = levelFrame:WaitForChild("UpgLvlCurBonus")
		local levelLabel = levelFrame:WaitForChild("UpgLvlLevel")
		local improvedButton = levelFrame:WaitForChild("UpgLvlImprovedButton")
		local upButton = levelFrame:WaitForChild("UpgLvlUpButton")
		local lockedButton = levelFrame:WaitForChild("UpgLvlLockedButton")
		local priceLabel = upButton:WaitForChild("UpgLvlPrice")
		
		for _, button in ipairs({
			improvedButton,
			upButton,
			lockedButton,}) do
			button.Active = true
			button.Interactable = true
			button.ZIndex = 50
		end
		
		levelControls[levelFrame] = {
			CurrentIcon = currentIcon,
			SuccessIcon = successIcon,
			
			BonusLabel = bonusLabel,
			LevelLabel = levelLabel,
			PriceLabel = priceLabel,
			
			ImprovedButton = improvedButton,
			UpButton = upButton,
			LockedButton = lockedButton,
		}
		
		levelFrame:SetAttribute("SlotIndex", slotIndex)
		levelFrame:SetAttribute("DisplayedLevel", 0)
		levelFrame:SetAttribute("LevelState", "Hidden")
	end
end

print("UPGRADE UI: level controls collected")

--// Определяем перовый уровень видимого окна
local function getFirstDisplayedLevel(currentLevel, maxLevel)
	if maxLevel <= visibleSlotCount then
		return 1
	end
	
	local nextLevel = math.min(currentLevel + 1, maxLevel)
	local maximumStartLevel = math.max(1, maxLevel - visibleSlotCount + 1)
	local desiredStartLevel = nextLevel - centerLevelSlot + 1
	
	return math.clamp(desiredStartLevel, 1, maximumStartLevel)
end

--// Обновление одной карточки уровня
local function updateLevelFrame(levelFrame, upgradeName, displayedLevel, currentLevel, maxLevel)
	local controls = levelControls[levelFrame]
	
	if not controls then 
		return
	end
	
	if displayedLevel < 1 or displayedLevel > maxLevel then
		levelFrame.Visible = false
		
		levelFrame:SetAttribute("DisplayedLevel", 0)
		levelFrame:SetAttribute("LevelState", "Hidden")
		return
	end
	
	levelFrame.Visible = true
	
	levelFrame:SetAttribute("UpgradeName", upgradeName)
	levelFrame:SetAttribute("DisplayedLevel", displayedLevel)
	
	controls.LevelLabel.Text = "Lvl. " .. tostring(displayedLevel)
	controls.BonusLabel.Text = UpgradeModule.GetBonusText(upgradeName, displayedLevel)
	
	local defaultIcon = UpgradeModule.GetIcon(upgradeName, "Default")
	local selectedIcon = UpgradeModule.GetIcon(upgradeName, "Selected")
	
	local defaultFrameImage = UpgradeModule.GetLevelFrameImage("Default")
	local selectedFrameImage = UpgradeModule.GetLevelFrameImage("Selected")
	
	if displayedLevel <= currentLevel then
		levelFrame:SetAttribute("LevelState", "Improved")
		levelFrame.Image = defaultFrameImage
		
		controls.CurrentIcon.Image = selectedIcon
		
		controls.SuccessIcon.Visible = true
		controls.ImprovedButton.Visible = true
		
		controls.UpButton.Visible = false
		controls.LockedButton.Visible = false
		
		controls.PriceLabel.Text = ""
		return
	end
	
	if displayedLevel == currentLevel + 1 and currentLevel < maxLevel then 
		levelFrame:SetAttribute("LevelState", "Available")
		levelFrame.Image = selectedFrameImage
		
		controls.CurrentIcon.Image = selectedIcon
		
		controls.SuccessIcon.Visible = false
		controls.ImprovedButton.Visible = false
		
		controls.UpButton.Visible = true
		controls.LockedButton.Visible = false
		
		local price = UpgradeModule.GetLevelPrice(upgradeName, displayedLevel)
		if type(price) == "number" then
			controls.PriceLabel.Text = formatNumber(price)
		else
			controls.PriceLabel.Text = "?"
		end
		return
	end
	
	levelFrame:SetAttribute("LevelState", "Locked")
	levelFrame.Image = defaultFrameImage
	
	controls.CurrentIcon.Image = defaultIcon
	
	controls.SuccessIcon.Visible = false
	controls.ImprovedButton.Visible = false 
	
	controls.UpButton.Visible = false
	controls.LockedButton.Visible = true
	
	controls.PriceLabel.Text = ""
end

--// Статистика выбранного апгрейда
local function updateCurrentStats(upgradeName, currentLevel)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then
		return
	end
	
	upgStatsIcon.Image = UpgradeModule.GetIcon(upgradeName, "Stats")
	upgStatsName.Text = config.DisplayName
	upgStatsInfo.Text = config.Description or ""
	upgStatsLvl.Text = tostring(currentLevel) .. "/" .. tostring(config.MaxLevel)
	upgStatsCurMult.Text = UpgradeModule.GetCurrentBonusText(upgradeName, currentLevel)
	
	if currentLevel >= config.MaxLevel then
		upgStatsNextLvl.Text = "MAX LEVEL"
		upgStatsNextMult.Text = "MAX"
		
		return
	end
	
	local nextLevel = currentLevel + 1
	
	upgStatsNextLvl.Text = "NEXT LEVEL " .. tostring(nextLevel)
	
	upgStatsNextMult.Text = UpgradeModule.GetNextBonusText(upgradeName, currentLevel)
end

--// обновляем 10 визуальных слотов 
local function updateVisibleLevels(upgradeName, currentLevel)
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then 
		return
	end
	
	local firstDisplayedLevel = getFirstDisplayedLevel(currentLevel, config.MaxLevel)
	
	for slotIndex = 1, visibleSlotCount do
		local levelFrame = levelFrames[slotIndex]
		
		local displayedLevel = firstDisplayedLevel + slotIndex - 1
		
		updateLevelFrame( 
			levelFrame,
			upgradeName,
			displayedLevel,
			currentLevel,
			config.MaxLevel
		)
	end
end

--// Полное обновление выбранного апгрейда
local function refreshSelectedUpgrade()
	if not selectedUpgradeName then
		return
	end
	
	local config = UpgradeModule.GetConfig(selectedUpgradeName)
	
	if not config then 
		return
	end
	
	local upgradeValue = upgradesFolder:FindFirstChild(selectedUpgradeName)
	
	if not upgradeValue then 
		return
	end
	
	local currentLevel = math.clamp(math.floor(tonumber(upgradeValue.Value) or 0), 0, config.MaxLevel)
	
	updateCurrentStats(selectedUpgradeName, currentLevel)
	updateVisibleLevels(selectedUpgradeName, currentLevel)
end

--// Выбор апгрейда
local function updateUpgradeSelectionButtons()
	for _, upgradeName in ipairs(UpgradeModule.GetUpgradeNames()) do
		local button = upgradeSelectionButtons[upgradeName]
		
		if button and button:IsA("ImageButton") then
			if upgradeName == selectedUpgradeName then
				button.Image = UpgradeModule.GetButtonImage(upgradeName, "Selected")
			else 
				button.Image = UpgradeModule.GetButtonImage(upgradeName, "Default")
			end
		end
	end
end

local function selectUpgrade(upgradeName)
	if not UpgradeModule.IsValidUpgrade(upgradeName) then
		return
	end
	
	selectedUpgradeName = upgradeName
	
	updateUpgradeSelectionButtons()
	clearWarning()
	refreshSelectedUpgrade()
end

print("BLA")

local function setupLevelFrameButtons()
	for slotIndex = 1, visibleSlotCount do
		local levelFrame = levelFrames[slotIndex]
		local controls = levelControls[levelFrame]
		
		controls.UpButton.Activated:Connect(function()
			print("UPGRADE BUTTON PRESSED", slotIndex, levelFrame:GetAttribute("LevelState"), levelFrame:GetAttribute("UpgradeName"))
			local state = levelFrame:GetAttribute("LevelState")
			local upgradeName = levelFrame:GetAttribute("UpgradeName")
			
			if state ~= "Available" then
				return
			end
			
			if type(upgradeName) ~= "string" then 
				return
			end
			
			clearWarning()
			
			upgradeEvent:FireServer(upgradeName)
		end)
		
		controls.ImprovedButton.Activated:Connect(function()
			showWarning("Этот уровень уже улучшен")   
		end)
		
		controls.LockedButton.Activated:Connect(function()
			showWarning("Этот уровень закрыт")
		end)
	end
end

print("UPGRADE UI: level buttons connected")

--// Кнопка выбора апгрейда
local function setupUpgradeSelectionButtons()
	for _, upgradeName in ipairs(UpgradeModule.GetUpgradeNames()) do
		local config = UpgradeModule.GetConfig(upgradeName)
		
		if config then
			local button = upgScrollFrame:WaitForChild(config.ButtonName)
			assert(button:IsA("GuiButton"), config.ButtonName .. " должен быть ImageButton или TextButton")
			
			upgradeSelectionButtons[upgradeName] = button
			
			button.Activated:Connect(function()
				selectUpgrade(upgradeName)
			end)
		end
	end
end

--// Слудим за изменением уровней
local function connectUpgradeValues()
	for _, upgradeName in ipairs(UpgradeModule.GetUpgradeNames()) do
		local upgradeValue = upgradesFolder:WaitForChild(upgradeName, 15)
		
		if upgradeValue then 
			upgradeValue:GetPropertyChangedSignal("Value"):Connect(function()
				if selectedUpgradeName == upgradeName then
					refreshSelectedUpgrade()
				end
			end)
		else
			warn("Upgrade value not fount:", upgradeName)
		end
	end
end

--// Ответ сервер
local function getFailureMessage(result)
	local code = result.Code
	
	if code == "NotEnoughGems" then
		local missingGems = tonumber(result.MissingGems) or 0
		
		return "Для улучшения вам не хватает " .. formatNumber(missingGems) .. " гемов"
	end
	
	if code == "MaxLevel" then
		return "Достигнут максимальный уровень"
	end
	
	if code == "DataNotReady" then
		return "Данные игрока еще загружаются"
	end
	
	if code == "PurchaseBusy" then
		return "Предыдущая покупка еще обрабатывается"
	end
	
	if code == "CurrencyMissing" then
		return "Баланс гемов не найден"
	end
	
	if code == "InvalidPrice" then
		return "Не удалось определить цену улучшения"
	end
	
	if code == "InvalidUpgrade" or code == "InvalidRequest" then
		return "Апгрейд не найден"
	end
	
	if code == "UpgradeValueMissing" then 
		return "Данные апгрейда не найдены"
	end
	
	return "Не удалось улучшить уровень"
end

upgCloseButton.MouseButton1Click:Connect(function()
	MenuManager.close("Upgrade")
end)

upgradeEvent.OnClientEvent:Connect(function(result)
	if type(result) ~= "table" then
		return
	end
	
	if result.Success == true then
		clearWarning()
		
		if type(result.UpgradeName) == "string" and UpgradeModule.IsValidUpgrade(result.UpgradeName) then
			selectedUpgradeName = result.UpgradeName
		end
		
		refreshSelectedUpgrade()
		return
	end
	showWarning(getFailureMessage(result))
end)

--// Changed
gemsValue:GetPropertyChangedSignal("Value"):Connect(updateGemsLabel)

--// Start
upgWarningLabel.Visible = false

collectLevelFrames()
collectLevelControls()

setupLevelFrameButtons()
setupUpgradeSelectionButtons()
connectUpgradeValues()

updateGemsLabel()

if UpgradeModule.IsValidUpgrade(DEFAULT_UPGRADE) then
	selectUpgrade(DEFAULT_UPGRADE)
else 
	local upgradeNames = UpgradeModule.GetUpgradeNames()
	
	selectUpgrade(upgradeNames[1])
end

print("UpgradeUI loaded")
