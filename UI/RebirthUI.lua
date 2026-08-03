--// RebirthUI 1.2v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ClientDataModule = require(ReplicatedStorage.Modules.ClientDataModule)
local RebirthModule = require(ReplicatedStorage.Modules.RebirthModule)
local MenuManager = require(ReplicatedStorage.Modules.MenuManager)
local ShopModule = require(ReplicatedStorage.Modules.ShopModule)
local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)

local player = Players.LocalPlayer
local gui = script.Parent

ClientDataModule.WaitUntilReady(player)
MenuManager.init(gui)

--// UI PATHS

local guiFolder = gui:WaitForChild("GuiFolder")
local rebirthFolder = guiFolder:WaitForChild("RebirthFolder")
local rebirthHost = rebirthFolder:WaitForChild("RebirthHost")

local uiBalance = guiFolder:WaitForChild("UIBalance")
local openRebirthMenu = uiBalance:WaitForChild("RebirthMenu")

local closeButton = rebirthHost:WaitForChild("CloseRebirthFrame")
local rebirthDetails = rebirthHost:WaitForChild("RebirthDetails")
local rebirthFrame = rebirthHost:WaitForChild("RebirthFrame")
local rebirthInfoFrame = rebirthHost:WaitForChild("RebirthInfoFrame")

--// Leaderstats UI

local rebirthLeaderstatsUI =
	rebirthHost:WaitForChild("RebirthLeaderstatsUI")

local energyLabel =
	rebirthLeaderstatsUI:WaitForChild("EnergyLabel")

local rebirthLabel =
	rebirthLeaderstatsUI:WaitForChild("RebirthLabel")

--// RemoteEvents

local rebirthEvent =
	ReplicatedStorage:WaitForChild("RebirthEvent")

local performRebirthEvent =
	rebirthEvent:WaitForChild("PerformRebirthEvent")

local autoRebirthEvent =
	rebirthEvent:WaitForChild("AutoRebirthEvent")

--// Player values

local energyValue =
	ClientDataModule.GetEnergy(player)

local rebirthValue =
	ClientDataModule.GetRebirth(player)

local upgradesFolder =
	ClientDataModule.GetUpgrades(player)

local rebirthButtonUpgrade =
	upgradesFolder:WaitForChild("RebirthButton")

local moneyMultiplierUpgrade =
	upgradesFolder:WaitForChild("MoneyMultiplier")

local gamepasses =
	ClientDataModule.GetGamepasses(player)

local autoRebirthPass =
	gamepasses:WaitForChild("AutoRebirthPass")

local maxRebirthPass =
	gamepasses:WaitForChild("MaxRebirthPass")

--// Details Frame

local totalRebirthLabel =
	rebirthDetails:WaitForChild("RebirthNumberLabel")

local energyBoostLabel =
	rebirthDetails:WaitForChild("EnergyBoostLabel")

local moneyBoostLabel =
	rebirthDetails:WaitForChild("MoneyBoostLabel")

local xpBoostLabel =
	rebirthDetails:WaitForChild("XpBoostLabel")

local detailsPerformButton =
	rebirthDetails:WaitForChild("PerformRebirthButton")

local detailsPerformRebirthLabel =
	detailsPerformButton:WaitForChild("RebirthNumberLabel")

local detailsPriceLabel =
	detailsPerformButton:WaitForChild("RebirthPriceLabel")

--// Rebirth Info Frame

local rebirthNumberInfoLabel =
	rebirthInfoFrame:WaitForChild("RebirthNumberInfoLabel")

local energyCurrentMult =
	rebirthInfoFrame:WaitForChild("EnergyCurrentMult")

local moneyCurrentMult =
	rebirthInfoFrame:WaitForChild("MoneyCurrentMult")

local xpCurrentMult =
	rebirthInfoFrame:WaitForChild("XpCurrentMult")

local energyNextMult =
	rebirthInfoFrame:WaitForChild("EnergyNextMult")

local moneyNextMult =
	rebirthInfoFrame:WaitForChild("MoneyNextMult")

local xpNextMult =
	rebirthInfoFrame:WaitForChild("XpNextMult")

local requirEnergyLabel =
	rebirthInfoFrame:WaitForChild("RequirEnergyLabel")

local infoTotalRebirthImage =
	rebirthInfoFrame:WaitForChild("InfoTotalRebirthImage")

local infoPerformButton =
	rebirthInfoFrame:WaitForChild("PerformRebirthButton")

local infoPerformNumberLabel =
	infoPerformButton:WaitForChild("RebirthNumberLabel")

local infoPerformPriceLabel =
	infoPerformButton:WaitForChild("RebirthPriceLabel")

local autoRebirthButton =
	rebirthInfoFrame:WaitForChild("AutoRebirthButton")

local autoToggleImage =
	autoRebirthButton:WaitForChild("On/OffAutoLabel")

MenuManager.register("Rebirth", rebirthHost)

--// Image IDs

local BUTTON_NORMAL_IMAGE =
	"rbxassetid://91177636175681"

local BUTTON_SELECTED_IMAGE =
	"rbxassetid://127648911912349"

local INFO_NOT_ENOUGH_IMAGE =
	"rbxassetid://108923555840576"

local INFO_ENOUGH_IMAGE =
	"rbxassetid://115091081917961"

local ENERGY_ICON =
	"rbxassetid://74509086636062"

--// Auto positions

local AUTO_OFF_POSITION =
	UDim2.new(0.64, 0, 0.195, 0)

local AUTO_ON_POSITION =
	UDim2.new(0.735, 0, 0.195, 0)

--// State

local selectedButtonName = "RebirthButton1"
local selectedAmount = 1
local isMaxSelected = false

local autoRebirthEnabled = false
local autoButtonName = nil

--// Rebirth buttons

local rebirthButtons = {
	RebirthButton1 = {
		Button = rebirthFrame:WaitForChild("RebirthButton1"),
		Amount = 1,
	},

	RebirthButton2 = {
		Button = rebirthFrame:WaitForChild("RebirthButton2"),
		Amount = 5,
	},

	RebirthButton3 = {
		Button = rebirthFrame:WaitForChild("RebirthButton3"),
		Amount = 25,
	},

	RebirthButton4 = {
		Button = rebirthFrame:WaitForChild("RebirthButton4"),
		Amount = 75,
	},

	RebirthButton5 = {
		Button = rebirthFrame:WaitForChild("RebirthButton5"),
		Amount = 150,
	},

	RebirthButton6 = {
		Button = rebirthFrame:WaitForChild("RebirthButton6"),
		Amount = 250,
	},

	RebirthButton7 = {
		Button = rebirthFrame:WaitForChild("RebirthButton7"),
		Amount = 500,
	},
}

local rebirthMaxButton =
	rebirthFrame:WaitForChild("RebirthMaxButton")

local rebirthMaxPriceLabel =
	rebirthMaxButton:WaitForChild("RebirthInfoPrice")

local rebirthMaxStatusLabel =
	rebirthMaxButton:WaitForChild("StatusRebirthLabel")

--// Helpers

local function formatNumber(number)
	number = tonumber(number) or 0

	if number >= 1e18 then
		return string.format("%.1fQ", number / 1e18)
	elseif number >= 1e12 then
		return string.format("%.1fT", number / 1e12)
	elseif number >= 1e9 then
		return string.format("%.1fB", number / 1e9)
	elseif number >= 1e6 then
		return string.format("%.1fM", number / 1e6)
	elseif number >= 1e3 then
		return string.format("%.1fK", number / 1e3)
	end

	return tostring(number)
end

local function promptPass(passName)
	local passData = ShopModule.Passes[passName]

	if not passData then
		return
	end

	local gamePassId = passData.GamePassId

	if not gamePassId or gamePassId == 0 then
		return
	end

	MarketplaceService:PromptGamePassPurchase(
		player,
		gamePassId
	)
end

local function hasAutoRebirthPass()
	return autoRebirthPass.Value == true
end

local function hasMaxRebirthPass()
	return maxRebirthPass.Value == true
end

local function getOneRebirthCost(currentRebirths)
	return RebirthModule.GetOneRebirthCost(
		currentRebirths
	)
end

local function getRebirthCost(currentRebirths, amount)
	return RebirthModule.GetRebirthCost(
		currentRebirths,
		amount
	)
end

local function getMaxRebirthAmount(
	currentRebirths,
	currentEnergy
)
	return RebirthModule.GetMaxRebirthAmount(
		currentRebirths,
		currentEnergy
	)
end

local function getSelectedAmount()
	if isMaxSelected then
		return getMaxRebirthAmount(
			rebirthValue.Value,
			energyValue.Value
		)
	end

	return selectedAmount
end

local function getEnergyMultiplier(rebirths)
	return RebirthModule.GetEnergyMultiplierFromRebirths(
		rebirths
	)
end

local function getMoneyMultiplier(rebirths)
	if not UpgradeModule.IsMoneyMultiplierUnlocked(player) then
		return 1
	end

	return RebirthModule.GetMoneyMultiplierFromRebirths(
		rebirths
	)
end

local function getXpMultiplier(rebirths)
	return RebirthModule.GetXpMultiplierFromRebirths(
		rebirths
	)
end

local function setEnergyText(label, price)
	label.RichText = true

	label.Text =
		'<img src="'
		.. ENERGY_ICON
		.. '"/> '
		.. formatNumber(price)
end

--// UI updating

local function updateLeaderstatsUI()
	energyLabel.Text =
		formatNumber(energyValue.Value)

	rebirthLabel.Text =
		formatNumber(rebirthValue.Value)
end

local function updateRebirthButtonUnlocks()
	local selectedButtonUnlocked = true

	for buttonName, data in pairs(rebirthButtons) do
		local unlocked =
			UpgradeModule.IsRebirthButtonUnlocked(
				player,
				buttonName
			)

		data.Button.Visible = unlocked
		data.Button.Active = unlocked
		data.Button.Interactable = unlocked

		if buttonName == selectedButtonName
			and not unlocked then

			selectedButtonUnlocked = false
		end
	end

	if not isMaxSelected
		and not selectedButtonUnlocked then

		selectedButtonName = "RebirthButton1"
		selectedAmount =
			RebirthModule.Buttons.RebirthButton1

		isMaxSelected = false
	end
end

local function updateSelectedImages()
	for buttonName, data in pairs(rebirthButtons) do
		local isSelected =
			buttonName == selectedButtonName
			and not isMaxSelected

		if isSelected then
			data.Button.Image =
				BUTTON_SELECTED_IMAGE
		else
			data.Button.Image =
				BUTTON_NORMAL_IMAGE
		end
	end

	if isMaxSelected then
		rebirthMaxButton.Image =
			BUTTON_SELECTED_IMAGE
	else
		rebirthMaxButton.Image =
			BUTTON_NORMAL_IMAGE
	end
end

local function updateButtonPrices()
	local currentRebirths =
		rebirthValue.Value

	local currentEnergy =
		energyValue.Value

	for _, data in pairs(rebirthButtons) do
		local priceLabel =
			data.Button:WaitForChild(
				"RebirthInfoPrice"
			)

		local price =
			getRebirthCost(
				currentRebirths,
				data.Amount
			)

		setEnergyText(priceLabel, price)
	end

	local maxAmount =
		getMaxRebirthAmount(
			currentRebirths,
			currentEnergy
		)

	rebirthMaxStatusLabel.Text =
		"+" .. maxAmount .. " Rebirths"

	-- Цена всех доступных Max Rebirth.
	-- Если пока недоступно ни одного,
	-- показываем стоимость одного Rebirth.
	local displayedAmount =
		math.max(maxAmount, 1)

	local maxPrice =
		getRebirthCost(
			currentRebirths,
			displayedAmount
		)

	setEnergyText(
		rebirthMaxPriceLabel,
		maxPrice
	)
end

local function updateDetails()
	local currentRebirths =
		rebirthValue.Value

	local amount =
		getSelectedAmount()

	local price =
		getRebirthCost(
			currentRebirths,
			amount
		)

	totalRebirthLabel.Text =
		formatNumber(currentRebirths)

	energyBoostLabel.Text =
		"x"
		.. string.format(
			"%.1f",
			getEnergyMultiplier(currentRebirths)
		)

	moneyBoostLabel.Text =
		"x"
		.. string.format(
			"%.2f",
			getMoneyMultiplier(currentRebirths)
		)

	xpBoostLabel.Text =
		"x"
		.. string.format(
			"%.2f",
			getXpMultiplier(currentRebirths)
		)

	detailsPerformRebirthLabel.Text =
		"+" .. amount .. " Rebirths"

	setEnergyText(
		detailsPriceLabel,
		price
	)
end

local function updateInfoFrame()
	local currentRebirths =
		rebirthValue.Value

	local currentEnergy =
		energyValue.Value

	local amount =
		getSelectedAmount()

	local selectedPrice =
		getRebirthCost(
			currentRebirths,
			amount
		)

	rebirthNumberInfoLabel.Text =
		"+" .. amount .. " Rebirths"

	energyCurrentMult.Text =
		"x"
		.. string.format(
			"%.1f",
			getEnergyMultiplier(currentRebirths)
		)

	moneyCurrentMult.Text =
		"x"
		.. string.format(
			"%.2f",
			getMoneyMultiplier(currentRebirths)
		)

	xpCurrentMult.Text =
		"x"
		.. string.format(
			"%.2f",
			getXpMultiplier(currentRebirths)
		)

	-- Показываем, сколько добавит выбранное
	-- количество Rebirth.
	local addedEnergyMult =
		amount
		* RebirthModule.EnergyBonusPerRebirth

	local addedMoneyMult = 0

	if UpgradeModule.IsMoneyMultiplierUnlocked(player) then
		addedMoneyMult =
			amount
			* RebirthModule.MoneyBonusPerRebirth
	end

	local addedXpMult =
		amount
		* RebirthModule.XpBonusPerRebirth

	energyNextMult.Text =
		"+"
		.. string.format(
			"%.1f",
			addedEnergyMult
		)
		.. "x"

	moneyNextMult.Text =
		"+"
		.. string.format(
			"%.2f",
			addedMoneyMult
		)
		.. "x"

	xpNextMult.Text =
		"+"
		.. string.format(
			"%.2f",
			addedXpMult
		)
		.. "x"

	if isMaxSelected then
		local maxAmount =
			getMaxRebirthAmount(
				currentRebirths,
				currentEnergy
			)

		-- Порог энергии для следующего количества.
		-- Например, доступно +10:
		-- показываем прогресс до +11.
		local nextMaxThreshold =
			getRebirthCost(
				currentRebirths,
				maxAmount + 1
			)

		requirEnergyLabel.Text =
			formatNumber(currentEnergy)
			.. "/"
			.. formatNumber(nextMaxThreshold)

		if maxAmount > 0 then
			infoTotalRebirthImage.Image =
				INFO_ENOUGH_IMAGE
		else
			infoTotalRebirthImage.Image =
				INFO_NOT_ENOUGH_IMAGE
		end
	else
		requirEnergyLabel.Text =
			formatNumber(currentEnergy)
			.. "/"
			.. formatNumber(selectedPrice)

		if amount > 0
			and currentEnergy >= selectedPrice then

			infoTotalRebirthImage.Image =
				INFO_ENOUGH_IMAGE
		else
			infoTotalRebirthImage.Image =
				INFO_NOT_ENOUGH_IMAGE
		end
	end
end

local function updatePerformButtons()
	local amount =
		getSelectedAmount()

	local currentRebirths =
		rebirthValue.Value

	local price =
		getRebirthCost(
			currentRebirths,
			amount
		)

	local text

	if amount == 1 then
		text = "+1 Rebirth"
	else
		text = "+" .. amount .. " Rebirths"
	end

	if amount <= 0 then
		text = "+0 Rebirths"
	end

	detailsPerformRebirthLabel.Text = text
	infoPerformNumberLabel.Text = text

	setEnergyText(
		detailsPriceLabel,
		price
	)

	setEnergyText(
		infoPerformPriceLabel,
		price
	)
end

local function setAutoVisual()
	local isThisButtonAuto =
		autoRebirthEnabled
		and autoButtonName == selectedButtonName

	if isThisButtonAuto then
		autoToggleImage.Position =
			AUTO_ON_POSITION
	else
		autoToggleImage.Position =
			AUTO_OFF_POSITION
	end
end

local function updateRebirthUI()
	updateRebirthButtonUnlocks()
	updateSelectedImages()
	updateButtonPrices()
	updateDetails()
	updateInfoFrame()
	updatePerformButtons()
	setAutoVisual()
end

--// Selection

local function selectRebirth(buttonName, amount)
	selectedButtonName = buttonName
	selectedAmount = amount
	isMaxSelected = false

	updateRebirthUI()
end

local function selectMaxRebirth()
	if not hasMaxRebirthPass() then
		promptPass("MaxRebirthPass")
		return
	end

	selectedButtonName = "RebirthMaxButton"
	isMaxSelected = true

	updateRebirthUI()
end

--// Perform Rebirth

local function performSelectedRebirth()
	if isMaxSelected
		and not hasMaxRebirthPass() then

		promptPass("MaxRebirthPass")
		return
	end

	local amount =
		getSelectedAmount()

	if amount <= 0 then
		return
	end

	if isMaxSelected then
		performRebirthEvent:FireServer("Max")
	else
		performRebirthEvent:FireServer(amount)
	end
end

--// Auto Rebirth

local function toggleAutoRebirth()
	if not hasAutoRebirthPass() then
		promptPass("AutoRebirthPass")
		return
	end

	if isMaxSelected
		and not hasMaxRebirthPass() then

		promptPass("MaxRebirthPass")
		return
	end

	local amount =
		getSelectedAmount()

	-- Если Auto уже включён именно
	-- на текущей выбранной кнопке —
	-- выключаем его.
	if autoRebirthEnabled
		and autoButtonName == selectedButtonName then

		autoRebirthEnabled = false
		autoButtonName = nil

		autoRebirthEvent:FireServer(
			false,
			0
		)

		updateRebirthUI()
		return
	end

	-- Включаем Auto на текущей кнопке.
	-- Предыдущая Auto-кнопка автоматически
	-- заменяется на новую.
	if not isMaxSelected
		and amount <= 0 then

		return
	end

	autoRebirthEnabled = true
	autoButtonName = selectedButtonName

	if isMaxSelected then
		autoRebirthEvent:FireServer(
			true,
			"Max"
		)
	else
		autoRebirthEvent:FireServer(
			true,
			amount
		)
	end

	updateRebirthUI()
end

--// Connections

for buttonName, data in pairs(rebirthButtons) do
	data.Button.MouseButton1Click:Connect(function()
		local unlocked =
			UpgradeModule.IsRebirthButtonUnlocked(
				player,
				buttonName
			)

		if not unlocked then
			return
		end

		selectRebirth(
			buttonName,
			data.Amount
		)
	end)
end

rebirthMaxButton.MouseButton1Click:Connect(
	selectMaxRebirth
)

detailsPerformButton.MouseButton1Click:Connect(
	performSelectedRebirth
)

infoPerformButton.MouseButton1Click:Connect(
	performSelectedRebirth
)

autoRebirthButton.MouseButton1Click:Connect(
	toggleAutoRebirth
)

openRebirthMenu.MouseButton1Click:Connect(function()
	updateRebirthUI()
	updateLeaderstatsUI()

	MenuManager.toggleFull("Rebirth")
end)

closeButton.MouseButton1Click:Connect(function()
	MenuManager.close("Rebirth")
end)

--// Value updates

energyValue.Changed:Connect(function()
	updateRebirthUI()
	updateLeaderstatsUI()
end)

rebirthValue.Changed:Connect(function()
	updateRebirthUI()
	updateLeaderstatsUI()
end)

rebirthButtonUpgrade.Changed:Connect(
	updateRebirthUI
)

moneyMultiplierUpgrade.Changed:Connect(
	updateRebirthUI
)

autoRebirthPass.Changed:Connect(
	updateRebirthUI
)

maxRebirthPass.Changed:Connect(
	updateRebirthUI
)

-- Max Rebirth необходимо обновлять постоянно,
-- потому что доступное количество зависит от Energy.
task.spawn(function()
	while true do
		task.wait(1)

		if rebirthHost.Visible then
			updateRebirthUI()
			updateLeaderstatsUI()
		end
	end
end)

--// Initial update

updateRebirthUI()
updateLeaderstatsUI()

print("RebirthUI loaded")
