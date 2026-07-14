--// RebirthUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)
local RebirthModule = require(game.ReplicatedStorage.Modules.RebirthModule)
local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)
local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)

local player = Players.LocalPlayer
local gui = script.Parent
ClientDataModule.WaitUntilReade(player)
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

--// RemoteEvents 
local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
local performRebirthEvent = rebirthEvent:WaitForChild("PerformRebirthEvent")
local autoRebirthEvent = rebirthEvent:WaitForChild("AutoRebirthEvent")

--// PlayerValues
local energyValue = ClientDataModule.GetEnergy(player)
local rebirthValue = ClientDataModule.GetRebirth(player)

local playerData = ClientDataModule.GetPlayerData(player)
local gamepasses = ClientDataModule.GetGamepasses(player)

local autoRebirthPass = gamepasses:WaitForChild("AutoRebirthPass")
local maxRebirthPass = gamepasses:WaitForChild("MaxRebirthPass")

--// Details Frame 
local totalRebirthLabel = rebirthDetails:WaitForChild("RebirthNumberLabel")
local energyBoostLabel = rebirthDetails:WaitForChild("EnergyBoostLabel")
local moneyBoostLabel = rebirthDetails:WaitForChild("MoneyBoostLabel")
local xpBoostLabel = rebirthDetails:WaitForChild("XpBoostLabel")

local detailsPerformButton = rebirthDetails:WaitForChild("PerformRebirthButton")
local detailsPerformRebirthLabel = detailsPerformButton:WaitForChild("RebirthNumberLabel")
local detailsPriceLabel = detailsPerformButton:WaitForChild("RebirthPriceLabel")

--// Rebirth Info Frame
local rebirthNumberInfoLabel = rebirthInfoFrame:WaitForChild("RebirthNumberInfoLabel")

local energyCurrentMult = rebirthInfoFrame:WaitForChild("EnergyCurrentMult")
local moneyCurrentMult = rebirthInfoFrame:WaitForChild("MoneyCurrentMult")
local xpCurrentMult = rebirthInfoFrame:WaitForChild("XpCurrentMult")

local energyNextMult = rebirthInfoFrame:WaitForChild("EnergyNextMult")
local moneyNextMult = rebirthInfoFrame:WaitForChild("MoneyNextMult")
local xpNextMult = rebirthInfoFrame:WaitForChild("XpNextMult")

local requirEnergyLabel = rebirthInfoFrame:WaitForChild("RequirEnergyLabel")
local infoTotalRebirthImage = rebirthInfoFrame:WaitForChild("InfoTotalRebirthImage")

local infoPerformButton = rebirthInfoFrame:WaitForChild("PerformRebirthButton")
local infoPerformNumberLabel = infoPerformButton:WaitForChild("RebirthNumberLabel")
local infoPerformPriceLabel = infoPerformButton:WaitForChild("RebirthPriceLabel")

local autoRebirthButton = rebirthInfoFrame:WaitForChild("AutoRebirthButton")
local autoToggleImage = autoRebirthButton:WaitForChild("On/OffAutoLabel")

MenuManager.register("Rebirth", rebirthHost)

--// Image IDs 
local BUTTON_NORMAL_IMAGE = "rbxassetid://91177636175681"
local BUTTON_SELECTED_IMAGE = "rbxassetid://127648911912349"

local INFO_NOT_ENOUGH_IMAGE = "rbxassetid://108923555840576"
local INFO_ENOUGH_IMAGE = "rbxassetid://115091081917961"

local ENERGY_ICON = "rbxassetid://74509086636062"

--// Auto positions
local AUTO_OFF_POSITION = UDim2.new(0.64, 0, 0.195, 0)
local AUTO_ON_POSITION = UDim2.new(0.735, 0, 0.195, 0)

--// State
local selectedButtonName = "RebirthButton1"
local selectedAmount = 1 
local isMaxSelected = false 
local autoRebirthEnabled = false

local autoButtonName = nil
local autoAmount = 0 
local autoIsMax = false

--// Buttons
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

local rebirthMaxButton = rebirthFrame:WaitForChild("RebirthMaxButton")
local rebirthMaxPriceLabel = rebirthMaxButton:WaitForChild("RebirthInfoPrice")
local rebirthMaxStatusLabel = rebirthMaxButton:WaitForChild("StatusRebirthLabel")

--// Helper 
local function formatNumber(n)
	if n >= 1e18 then
		return string.format("%.1fQ", n / 1e18)
	elseif n >= 1e12 then
		return string.format("%.1fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	else
		return tostring(n)
	end
end

local function promptPass(passName)
	local passData = ShopModule.Passes[passName]
	if not passData then return end 
	if not passData.GamePassId or passData.GamePassId == 0 then return end 
	
	MarketplaceService:PromptGamePassPurchase(player, passData.GamePassId)
end

local function hasAutoRebirthPass()
	return autoRebirthPass.Value == true
end

local function hasMaxRebirthPass()
	return maxRebirthPass.Value == true
end

local function getOneRebirthCost(currentRebirths)
	return RebirthModule.GetOneRebirthCost(currentRebirths)
end

local function getRebirthCost(currentRebirths, amount)
	return RebirthModule.GetRebirthCost(currentRebirths, amount)
end

local function getMaxRebirthAmount(currentRebirths, currentEnergy)
	return RebirthModule.GetMaxRebirthAmount(currentRebirths, currentEnergy)
end

local function getSelectedAmount()
	if isMaxSelected then
		return getMaxRebirthAmount(rebirthValue.Value, energyValue.Value)
	end

	return selectedAmount
end

local function getEnergyMultiplier(rebirths)
	return RebirthModule.GetEnergyMultiplierFromRebirths(rebirthValue.Value)
end

local function getMoneyMultiplier(rebirths)
	return RebirthModule.GetMoneyMultiplierFromRebirths(rebirthValue.Value)
end

local function getXpMultiplier(rebirths)
	return RebirthModule.GetXpMultiplierFromRebirths(rebirthValue.Value)
end

local function setEnergyText(label, price)
	label.RichText = true
	label.Text = '<img src="' .. ENERGY_ICON .. '"/> ' .. formatNumber(price) .. ""
end

local function setAutoVisual()
	local currentAmount = getSelectedAmount()
	
	local isThisButtonAuto = autoRebirthEnabled and autoButtonName == selectedButtonName
	
	if isThisButtonAuto then 
		autoToggleImage.Position = AUTO_ON_POSITION 
	else 
		autoToggleImage.Position = AUTO_OFF_POSITION
	end
end

local function updateSelectedImages()
	for buttonName, data in pairs(rebirthButtons) do 
		if buttonName == selectedButtonName and not isMaxSelected then
			data.Button.Image = BUTTON_SELECTED_IMAGE
		else 
			data.Button.Image = BUTTON_NORMAL_IMAGE
		end
	end
	
	if isMaxSelected then 
		rebirthMaxButton.Image = BUTTON_SELECTED_IMAGE
	else 
		rebirthMaxButton.Image = BUTTON_NORMAL_IMAGE
	end
end

local function updateButtonPrices()
	for _, data in pairs(rebirthButtons) do 
		local button = data.Button
		local amount = data.Amount
		local priceLabel = button:WaitForChild("RebirthInfoPrice")
		
		local price = getRebirthCost(rebirthValue.Value, amount)
		setEnergyText(priceLabel, price)
	end
	
	local maxAmount = getMaxRebirthAmount(rebirthValue.Value, energyValue.Value)
	rebirthMaxStatusLabel.Text = "+" .. maxAmount .. " Rebirths"
	
	local maxPrice = getRebirthCost(rebirthValue.Value, math.max(maxAmount, 1))
	setEnergyText(rebirthMaxPriceLabel, maxPrice)
end

local function updateDetails()
	local currentRebirths = rebirthValue.Value 
	local amount = getSelectedAmount()
	local price = getRebirthCost(currentRebirths, amount)
	
	totalRebirthLabel.Text = tostring(currentRebirths)
	
	energyBoostLabel.Text = "x" .. string.format("%.1f", RebirthModule.GetEnergyMultiplierFromRebirths(currentRebirths))
	moneyBoostLabel.Text = "x" .. string.format("%.2f", RebirthModule.GetMoneyMultiplierFromRebirths(currentRebirths))
	xpBoostLabel.Text = "x" .. string.format("%.2f", RebirthModule.GetXpMultiplierFromRebirths(currentRebirths))
	
	detailsPerformRebirthLabel.Text = "+" .. amount .. " Rebirth"
	setEnergyText(detailsPriceLabel, price)
end

local function updateInfoFrame()
	local currentRebirths = rebirthValue.Value 
	local currentEnergy = energyValue.Value 
	
	local amount = getSelectedAmount()
	local nextRebirths = currentRebirths + amount
	
	local selectedPrice = getRebirthCost(currentRebirths, amount)
	local nextOneCost = getOneRebirthCost(currentRebirths)
	
	rebirthNumberInfoLabel.Text = "+" .. amount .. " Rebirths"
	
	energyCurrentMult.Text = "x" .. string.format("%.1f", getEnergyMultiplier(currentRebirths))
	moneyCurrentMult.Text = "x" .. string.format("%.2f", getMoneyMultiplier(currentRebirths))
	xpCurrentMult.Text = "x" .. string.format("%.2f", getXpMultiplier(currentRebirths))
	
	local addedEnergyMult = amount * RebirthModule.EnergyBonusPerRebirth 
	local addedMoneyMult = amount * RebirthModule.MoneyBonusPerRebirth 
	local addedXpMult = amount * RebirthModule.XpBonusPerRebirth 
	
	energyNextMult.Text = "+" .. string.format("%.1f", addedEnergyMult) .. "x"
	moneyNextMult.Text = "+" .. string.format("%.2f", addedMoneyMult) .. "x"
	xpNextMult.Text = "+" .. string.format("%.2f", addedXpMult) .. "x"
	
	if isMaxSelected then 
		local maxAmount = getMaxRebirthAmount(currentRebirths, currentEnergy)
		
		if maxAmount <= 0 then 
			requirEnergyLabel.Text = formatNumber(currentEnergy) .. "/" .. formatNumber(nextOneCost)
			infoTotalRebirthImage.Image = INFO_NOT_ENOUGH_IMAGE
		else 
			local costForMax = getRebirthCost(currentRebirths, maxAmount)
			local nextAfterMaxCost = getOneRebirthCost(currentRebirths + maxAmount)
			
			requirEnergyLabel.Text = formatNumber(currentEnergy) .. "/" .. formatNumber(costForMax + nextAfterMaxCost)
			infoTotalRebirthImage.Image = INFO_ENOUGH_IMAGE
		end
	else 
		requirEnergyLabel.Text = formatNumber(currentEnergy) .. "/" .. formatNumber(selectedPrice)
		
		if currentEnergy >= selectedPrice and amount > 0 then 
			infoTotalRebirthImage.Image = INFO_ENOUGH_IMAGE
		else 
			infoTotalRebirthImage.Image = INFO_NOT_ENOUGH_IMAGE
		end
	end
end

local function updatePerformButtons()
	local amount = getSelectedAmount()
	local currentRebirths = rebirthValue.Value 
	local price = getRebirthCost(currentRebirths, amount)
	
	local text = "+" .. amount .. " Rebirths"
	
	if amount == 1 then 
		text = "+1 Rebirths"
	end
	
	if amount <= 0 then 
		text = "+0 Rebirths"
	end
	
	detailsPerformRebirthLabel.Text = text 
	infoPerformNumberLabel.Text = text 
	
	setEnergyText(detailsPriceLabel, price)
	setEnergyText(infoPerformPriceLabel, price)
end

local function updateRebirthUI()
	updateSelectedImages()
	updateButtonPrices()
	updateDetails()
	updateInfoFrame()
	updatePerformButtons()
	setAutoVisual()
end

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

local function performSelectedRebirth()
	if isMaxSelected and not hasMaxRebirthPass() then 
		promptPass("MaxRebirthPass")
		return
	end
	
	local amount = getSelectedAmount()
	
	if amount <= 0 then 
		return
	end
	
	if isMaxSelected then 
		performRebirthEvent:FireServer("Max")
	else 
		performRebirthEvent:FireServer(amount)
	end
end

local function toggleAutoRebirth()
	if not hasAutoRebirthPass() then 
		promptPass("AutoRebirthPass")
		return
	end
	
	if isMaxSelected and not hasMaxRebirthPass() then 
		promptPass("MaxRebirthPass")
		return
	end
	
	local amount = getSelectedAmount()
	
	if autoRebirthEnabled and autoButtonName == selectedButtonName then 
		autoRebirthEnabled = false 
		autoButtonName = nil
		autoAmount = 0
		autoIsMax = false
		
		autoRebirthEvent:FireServer(false, 0)
		
		updateRebirthUI()
		return
	end
	
	autoRebirthEnabled = true 
	autoButtonName = selectedButtonName 
	autoAmount = amount 
	autoIsMax = isMaxSelected
	
	if isMaxSelected then 
		autoRebirthEvent:FireServer(true, "Max")
	else 
		if amount <= 0 then 
			return
		end
		
		autoRebirthEvent:FireServer(true, amount)
	end
	
	updateRebirthUI()
end

--// Connections
for buttonName, data in pairs(rebirthButtons) do 
	data.Button.MouseButton1Click:Connect(function()
		selectRebirth(buttonName, data.Amount)
	end)
end

rebirthMaxButton.MouseButton1Click:Connect(selectMaxRebirth)

detailsPerformButton.MouseButton1Click:Connect(performSelectedRebirth)
infoPerformButton.MouseButton1Click:Connect(performSelectedRebirth)

autoRebirthButton.MouseButton1Click:Connect(toggleAutoRebirth)

openRebirthMenu.MouseButton1Click:Connect(function()
	MenuManager.toggleFull("Rebirth")
end)

closeButton.MouseButton1Click:Connect(function()
	MenuManager.close("Rebirth")
end)

energyValue.Changed:Connect(updateRebirthUI)
rebirthValue.Changed:Connect(updateRebirthUI)

task.spawn(function()
	while true do 
		task.wait(1)
		
		if rebirthHost.Visible then 
			updateRebirthUI()
		end
	end
end)

updateRebirthUI()

print("RebirthUI loaded")