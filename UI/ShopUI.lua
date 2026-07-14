--// ShopUI

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)
local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local shopFolder = guiFolder:WaitForChild("ShopFolder")
local uiBalance = guiFolder:WaitForChild("UIBalance")

local music = SoundService:WaitForChild("BackgroundMusik")
local menuOpenSound = SoundService:WaitForChild("UISound"):WaitForChild("OpenShop")




--// Stats
local srRobux = ClientDataModule.GetSrRobux(player)
local gamepasses = ClientDataModule.GetGamepasses(player)



--//RemoteEvents
local shopEventFolder = ReplicatedStorage:WaitForChild("ShopEvent")
local buyPassEvent = shopEventFolder:WaitForChild("BuyPassEvent")
local shopUpdateEvent = shopEventFolder:WaitForChild("ShopUpdateEvent")
local buyPotionEvent = shopEventFolder:WaitForChild("BuyPotionEvent")
local usePotionEvent = shopEventFolder:WaitForChild("UsePotionEvent")

local uiValueFrame = uiBalance:WaitForChild("UIValueFrame")
local shopOpenButton = uiBalance:WaitForChild("ShopOpen")

local shopFrame = shopFolder:WaitForChild("ShopRobuxFrame")

local srValueShopButton = shopFrame:WaitForChild("SRValueShopButton")
local srRobuxInfoLabel = shopFrame:WaitForChild("SrRobuxInfoLabel")
srRobuxInfoLabel.Visible = false
srRobuxInfoLabel.Text = ""

local ScrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local potionPassBox = ScrollingFrame:WaitForChild("PotionPassBox")
local gamePassBox = ScrollingFrame:WaitForChild("GamePassBox")

local backButton = shopFrame:WaitForChild("BackShopButton")

local leaderstatsShopUI = shopFrame:WaitForChild("LeaderstatsShopUI")
local srRobuxLabel = leaderstatsShopUI:WaitForChild("SRRobuxLabel")

local detailsFrame = shopFolder:WaitForChild("ShopDetailsFrame")
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")

local passEnergyFrame = gamePassBox:WaitForChild("PassEnergyFrame")
local passAutoRebirthFrame = gamePassBox:WaitForChild("PassAutoRebirthFrame")
local passMaxRebirthFrame = gamePassBox:WaitForChild("PassMaxRebirthFrame")

local energyTapPassButton = passEnergyFrame:WaitForChild("TapPassButton")
local autoRebirthTapPassButton = passAutoRebirthFrame:WaitForChild("TapPassButton")
local maxRebirthTapPassButton = passMaxRebirthFrame:WaitForChild("TapPassButton")

local detailsPassNameLabel = detailsFrame:WaitForChild("PassNameLabel")
local detailsPassBoostLabel = detailsFrame:WaitForChild("PassBoostLabel")
local detailsPassInfoLabel = detailsFrame:WaitForChild("PassInfoLabel")
local purchaseInfoLabel = detailsFrame:WaitForChild("PurchaseInfoLabel")

local buyPassButton = detailsFrame:WaitForChild("BuyPassButton")
local buyStatusLabel = buyPassButton:WaitForChild("BuyStatusLabel")
local buyRobuxPassButton = detailsFrame:WaitForChild("BuyRobuxPassButton")

local passIconDetails = detailsFrame:WaitForChild("PassIconDetails")

local selectedPass = nil 

MenuManager.register("Shop", shopFrame)

local potionFrames = { 
	EnergyPotion = potionPassBox:WaitForChild("EnergyPotionFrame"),
	MoneyPotion = potionPassBox:WaitForChild("MoneyPotionFrame"),
	LuckPotion = potionPassBox:WaitForChild("LuckPotionFrame")
}

local priceMode = "Robux"

local passFrames = { 
	EnergyPass = gamePassBox:WaitForChild("PassEnergyFrame"),
	AutoRebirthPass = gamePassBox:WaitForChild("PassAutoRebirthFrame"),
	MaxRebirthPass = gamePassBox:WaitForChild("PassMaxRebirthFrame"),
}

local potionPrices = { 
	[1] = { 
		Robux = 19,
		SRRobux = 9,
	},

	[5] = {
		Robux = 79,
		SRRobux = 49,
	},

	[10] = { 
		Robux = 169,
		SRRobux = 99,
	},
}

local selectedPotionUseAmount = { 
	EnergyPotion = 1,
	MoneyPotion = 1,
	LuckPotion = 1,
}

local UNSELECTED_IMAGE = "rbxassetid://88821350180635"
local SELECTED_IMAGE = "rbxassetid://98055215682398"

local passes = {
	EnergyPass = {
		Name = "Energy Pass",
		Icon = "rbxassetid://122391878019995",
		Boost = "x2 Energy",
		RobuxPrice = 49,
		SRobuxPrice = 39,
		Info = "Increases your Energy gain by +100%. This bonus is added separately and does not multiply all other boosts.",
		Owned = false,
	},
	
	AutoRebirthPass = { 
		Name = "Auto Rebirth",
		Icon = "rbxassetid://113494810568723",
		Boost = "Auto Rebirth",
		RobuxPrice = 99,
		SRobuxPrice = 129,
		Info = "Automatically rebirths when you have enough Energy.",
		Owned = false,
	},
	
	MaxRebirthPass = { 
		Name = "Max Rebirth",
		Icon = "rbxassetid://70550586083463",
		Boost = "Max Rebirth",
		RobuxPrice = 139,
		SRobuxPrice = 199,
		Info = "Unlocks max rebirth purchase for faster progression.",
		Owned = false,
	},
}

local function setMusicVolume(volume)
	local tween = TweenService:Create( 
		music,
		TweenInfo.new(0.3),
		{
			Volume = volume
		}
	)
	tween:Play()
end

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

local function showSRRobuxInfo(text)
	srRobuxInfoLabel.Visible = true
	srRobuxInfoLabel.Text = text
	
	task.spawn(function()
		task.wait(3)
		
		if srRobuxInfoLabel.Text == text then
			srRobuxInfoLabel.Visible = false
			srRobuxInfoLabel.Text = ""
		end
	end)
end

local function getPotionValue(potionId)
	return ClientDataModule.GetPotion(player, potionId)
end

local function updatePotionAmount(potionId)
	local frame = potionFrames[potionId]
	if not frame then return end
	
	local numberLabel = frame:WaitForChild("NumberPotionLabel")
	local potionValue = getPotionValue(potionId)
	
	numberLabel.Text = "x" .. formatNumber(potionValue.Value)
end

local function updatePotionPrices()
	for potionId, frame in pairs(potionFrames) do 
		for amount, priceData in pairs(potionPrices) do 
			local button = frame:FindFirstChild("Buy" .. amount .. "PotionButton")
			if button then 
				local valueLabel = button:FindFirstChild("ValuePotions")
				if valueLabel then 
					valueLabel.Text = formatNumber(priceData[priceMode]) .. " " .. priceMode
				end
			end
		end
	end
end

local function setPotionUseSelection(potionId, amountMode)
	selectedPotionUseAmount[potionId] = amountMode
	
	local frame = potionFrames[potionId]
	if not frame then return end
	
	local button = { 
		[1] = frame:WaitForChild("UseNumberPotions1"),
		[5] = frame:WaitForChild("UseNumberPotions5"),
		Max = frame:WaitForChild("UseNumberPotionsMax"),
	}
	
	for mode, button in pairs(button) do 
		if mode == amountMode then
			button.Image = SELECTED_IMAGE
		else 
			button.Image = UNSELECTED_IMAGE
		end
	end
end

local function showPotionInfo(potionId, text)
	local frame = potionFrames[potionId]
	if not frame then return end 
	
	local infoLabel = frame:WaitForChild("InfoPotionLabel")
	
	infoLabel.Visible = true
	infoLabel.Text = text 
	
	task.spawn(function()
		task.wait(2)
		
		if infoLabel.Text == text then 
			infoLabel.Visible = false
			infoLabel.Text = ""
		end
	end)
end

local function setupPotionFrame(potionId)
	local frame = potionFrames[potionId]
	if not frame then return end
	
	local potionValue = getPotionValue(potionId)
	
	potionValue.Changed:Connect(function()
		updatePotionAmount(potionId)
	end)
	
	updatePotionAmount(potionId)
	setPotionUseSelection(potionId, 1)
	
	frame:WaitForChild("Buy1PotionButton").MouseButton1Click:Connect(function()
		if priceMode == "SRRobux" then
			srRobuxLabel.Text = "SRRobux: " .. formatNumber(srRobux.Value)
			local price = potionPrices[1].SRRobux
			local missing = price - srRobux.Value
			
			if missing > 0 then
				showSRRobuxInfo("Not enough SRRobux. Need " .. formatNumber(missing) .. " more.")
				return
			end
		end
		buyPotionEvent:FireServer(potionId, 1, priceMode)
	end)
	
	frame:WaitForChild("Buy5PotionButton").MouseButton1Click:Connect(function()
		if priceMode == "SRRobux" then
			srRobuxLabel.Text = "SRRobux: " .. formatNumber(srRobux.Value)
			local price = potionPrices[5].SRRobux
			local missing = price - srRobux.Value

			if missing > 0 then
				showSRRobuxInfo("Not enough SRRobux. Need " .. formatNumber(missing) .. " more.")
				return
			end
		end
		buyPotionEvent:FireServer(potionId, 5, priceMode)
	end)
	
	frame:WaitForChild("Buy10PotionButton").MouseButton1Click:Connect(function()
		if priceMode == "SRRobux" then
			srRobuxLabel.Text = "SRRobux: " .. formatNumber(srRobux.Value)
			local price = potionPrices[10].SRRobux
			local missing = price - srRobux.Value

			if missing > 0 then
				showSRRobuxInfo("Not enough SRRobux. Need " .. formatNumber(missing) .. " more.")
				return
			end
		end
		buyPotionEvent:FireServer(potionId, 10, priceMode)
	end)
	
	frame:WaitForChild("UseNumberPotions1").MouseButton1Click:Connect(function()
		if potionValue.Value < 1 then 
			showPotionInfo(potionId, "Not enough potions")
			return
		end
		
		setPotionUseSelection(potionId, 1)
	end)
	
	frame:WaitForChild("UseNumberPotions5").MouseButton1Click:Connect(function()
		if potionValue.Value < 5 then 
			showPotionInfo(potionId, "Not enough potions")
			return
		end
		
		setPotionUseSelection(potionId, 5)
	end)
	
	frame:WaitForChild("UseNumberPotionsMax").MouseButton1Click:Connect(function()
		setPotionUseSelection(potionId, "Max")
	end)
	
	frame:WaitForChild("UsePotionButton").MouseButton1Click:Connect(function()
		local selectedAmount = selectedPotionUseAmount[potionId]
		
		if potionValue.Value <= 0 then
			showPotionInfo(potionId, "Not enough potions")
			return
		end
		
		if selectedAmount ~= "Max" and potionValue.Value < selectedAmount then
			showPotionInfo(potionId, "Not enough potions")
			return
		end
		
		usePotionEvent:FireServer(potionId, selectedAmount)
	end)
end

local function updatePassCard(passId)
	local passData = passes[passId]
	local frame = passFrames[passId]
	if not passData or not frame then return end
	
	local statusLabel = frame:FindFirstChild("PassStatusLabel", true)
	
	if statusLabel then
		statusLabel.Text = passData.Owned and "Owned" or "off"
	end
end

local function openPassDetails(passId)
	local passData = passes[passId]
	if not passData then return end
	
	selectedPass = passId
	
	detailsPassNameLabel.Text = passData.Name
	passIconDetails.Image = passData.Icon
	detailsPassBoostLabel.Text = passData.Boost
	detailsPassInfoLabel.Text = passData.Info
	purchaseInfoLabel.Text = formatNumber(passData.RobuxPrice) .. " Robux OR                   " .. formatNumber(passData.SRobuxPrice) .. " SRRobux"
	
	if passData.Owned then
		buyStatusLabel.Text = "Owned"
	else
		buyStatusLabel.Text = "Buy"
	end
	
	detailsFrame.Visible = true
end

local function togglePassDetails(passId)
	
	if detailsFrame.Visible and selectedPass == passId then
		detailsFrame.Visible = false
		selectedPass = nil
		return
	end
	
	openPassDetails(passId)
end

local function updateSRRobuxLabel()
	srRobuxLabel.Text = "SRRobux: " .. formatNumber(srRobux.Value)
end

local blur = Lighting:FindFirstChild("ShopBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "ShopBlur"
	blur.Size = 0
	blur.Parent = Lighting
end


local oldWalkSpeed = 16
local oldJumpPower = 50

local function getHumanoid()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("Humanoid")
end

local function setPlayerLocked(isLocked)
	local humanoid = getHumanoid()
	
	if isLocked then
		oldWalkSpeed = humanoid.WalkSpeed
		oldJumpPower = humanoid.JumpPower
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	else
		humanoid.WalkSpeed = oldWalkSpeed
		humanoid.JumpPower = oldJumpPower
	end
end

local function loadOwnedPasses()
	for passId, passData in pairs(passes) do
		local passValue = gamepasses:FindFirstChild(passId)

		if passValue and passValue.Value == true then
			passData.Owned = true
		else
			passData.Owned = false
		end

		updatePassCard(passId)
	end
end

local function openShop()
	loadOwnedPasses()
	
	menuOpenSound:Stop()
	menuOpenSound.TimePosition = 0
	menuOpenSound:Play()
	
	setMusicVolume(0.1)
	
	MenuManager.toggleBlur("Shop")
end

local function closeShop()
	setMusicVolume(0.3)
	
	MenuManager.close("Shop")
end

local function buySelectedPass()
	if not selectedPass then return end

	local passData = passes[selectedPass]
	if not passData then return end

	if passData.Owned then
		buyStatusLabel.Text = "Owned"
		return
	end

	buyPassEvent:FireServer(selectedPass, "SRRobux")
end

local function buySelectedPassRobux()
	if not selectedPass then return end

	local passData = passes[selectedPass]
	if not passData then return end

	if passData.Owned then
		buyStatusLabel.Text = "Owned"
		return
	end
	buyPassEvent:FireServer(selectedPass, "Robux")
end

shopOpenButton.MouseButton1Click:Connect(openShop)
backButton.MouseButton1Click:Connect(closeShop)
buyPassButton.MouseButton1Click:Connect(buySelectedPass)
buyRobuxPassButton.MouseButton1Click:Connect(buySelectedPassRobux)

energyTapPassButton.MouseButton1Click:Connect(function()
	togglePassDetails("EnergyPass")
end)

autoRebirthTapPassButton.MouseButton1Click:Connect(function()
	togglePassDetails("AutoRebirthPass")
end)

maxRebirthTapPassButton.MouseButton1Click:Connect(function()
	togglePassDetails("MaxRebirthPass")
end)

loadOwnedPasses()
detailsFrame.Visible = false

closeShop()

srRobuxLabel.Text = formatNumber(srRobux.Value)

srRobux.Changed:Connect(updateSRRobuxLabel)
updateSRRobuxLabel()

shopUpdateEvent.OnClientEvent:Connect(function(passId, success, message)
	local passData = passes[passId]
	if not passData then return end
	
	if success then
		passData.Owned = true
		buyStatusLabel.Text = "Owned"
		updatePassCard(passId)
		updateSRRobuxLabel()
	else
		buyStatusLabel.Text = message or "Error"
		
		task.wait(1)
		
		if selectedPass == passId and not passData.Owned then
			buyStatusLabel.Text = "Buy"
		end
	end
end)

for potionId in pairs(potionFrames) do 
	setupPotionFrame(potionId)
end

srValueShopButton.MouseButton1Click:Connect(function()
	if priceMode == "Robux" then 
		priceMode = "SRRobux"
	else 
		priceMode = "Robux"
	end
	
	updatePotionPrices()
end)

updatePotionPrices()

print("ShopUI loaded")