--// ShopUI v1.3

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)
local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)
local FormatModule = require(game.ReplicatedStorage.Modules.FormatModule)
local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReady(player)
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local shopFolder = guiFolder:WaitForChild("ShopFolder")
local shopHost = shopFolder:WaitForChild("ShopHost")

local uiBalance = guiFolder:WaitForChild("UIBalance")
local uiValueFrame = uiBalance:WaitForChild("UIValueFrame")
local shopOpenButton = uiBalance:WaitForChild("ShopOpen")

local shopRobuxFrame = shopHost:WaitForChild("ShopRobuxFrame")
local detailsFrame = shopHost:WaitForChild("ShopDetailsFrame")
local purchaseFrame = shopHost:WaitForChild("PurchaseFrame")
local purchaseBlurFrame = shopHost:WaitForChild("PurchaseBlurFrame")
local backButton = shopHost:WaitForChild("BackShopButton")
local leaderShopUI = shopHost:WaitForChild("LeaderstatsShopUI")
local shopWarningLabel = shopHost:WaitForChild("ShopWarningLabel")
local srRobuxLabel = leaderShopUI:WaitForChild("SRRobuxLabel")

local music = SoundService:WaitForChild("BackgroundMusik")
local menuOpenSound = SoundService:WaitForChild("UISound"):WaitForChild("OpenShop")

--// Stats
local srRobux = ClientDataModule.GetSrRobux(player)
local gamepasses = ClientDataModule.GetGamepasses(player)
local playerData = player:WaitForChild("PlayerData")

--//RemoteEvents
local shopEventFolder = ReplicatedStorage:WaitForChild("ShopEvent")
local buyPassEvent = shopEventFolder:WaitForChild("BuyPassEvent")
local shopUpdateEvent = shopEventFolder:WaitForChild("ShopUpdateEvent")
local buyPotionEvent = shopEventFolder:WaitForChild("BuyPotionEvent")
local usePotionEvent = shopEventFolder:WaitForChild("UsePotionEvent")
local equipPassEvent = shopEventFolder:WaitForChild("EquipPassEvent")

--// shopRobuxFrame
local ScrollingFrame = shopRobuxFrame:WaitForChild("ScrollingFrame")
local potionPassBox = ScrollingFrame:WaitForChild("PotionPassBox")
local gamePassBox = ScrollingFrame:WaitForChild("GamePassBox")
local srRobuxInfoLabel = shopRobuxFrame:WaitForChild("SrRobuxInfoLabel")

local srValueShopButton = shopRobuxFrame:WaitForChild("SRValueShopButton")
local potionBoxButton = shopRobuxFrame:WaitForChild("PotionBoxButton")
local passBoxButton = shopRobuxFrame:WaitForChild("PassBoxButton")
local itemsBoxButton = shopRobuxFrame:WaitForChild("ItemsBoxButton")
local currencyBoxButton = shopRobuxFrame:WaitForChild("CurrencyBoxButton")
local codeBoxButton = shopRobuxFrame:WaitForChild("CodeBoxButton")

--// Details
local detailsPassNameLabel = detailsFrame:WaitForChild("PassNameLabel")
local detailsPassBoostLabel = detailsFrame:WaitForChild("PassBoostLabel")
local detailsPassInfoLabel = detailsFrame:WaitForChild("PassInfoLabel")
local purchaseInfoLabel = detailsFrame:WaitForChild("PurchaseInfoLabel")

local passIconDetails = detailsFrame:WaitForChild("PassIconDetails")
local purchaseButton = detailsFrame:WaitForChild("PurchaseButton")

--// PurchaseFrame
local buyPassButton = purchaseFrame:WaitForChild("BuyPassButton")
local buyStatusLabel = buyPassButton:WaitForChild("BuyStatusLabel")
local buyRobuxPassButton = purchaseFrame:WaitForChild("BuyRobuxPassButton")
local buyRobuxStatusLabel = buyRobuxPassButton:WaitForChild("BuyRobuxStatusLabel")
local purchaseIconPass = purchaseFrame:WaitForChild("PurchaseIconPass")
local closePurcFrame = purchaseFrame:WaitForChild("ClosePurcFrame")

local potionFrames = { 
	EnergyPotion = potionPassBox:WaitForChild("EnergyPotionFrame"),
	MoneyPotion = potionPassBox:WaitForChild("MoneyPotionFrame"),
	LuckPotion = potionPassBox:WaitForChild("LuckPotionFrame")
}

local passFrames = {}
for _, passId in ipairs(ShopModule.PassOrder) do
	local passData = ShopModule.GetPass(passId)
	passFrame[passId] = gamePassBox:FindFirstChild(passData.FrameName)
end

local priceMode = "Robux"
local selectedPass = nil
local selectedPotionUseAmount = {}
local warningToken = 0
local musicNormalVolume = music.Volume

MenuManager.register("Shop", shopHost)

--// Functions
local function showWarning(message)
	warningToken += 1
	local token = warningToken
	shopWarningLabel.Text = message
	shopWarningLabel.Visible = true
	
	task.delay(3, function()
		if warningToken == token then
			shopWarningLabel.Visible = false
			shopWarningLabel.Text = ""
		end
	end)
end

local function showSRRobuxInfo(message)
	srRobuxInfoLabel.Text = message
	srRobuxInfoLabel.Visible = true
	
	task.delay(3, function()
		if srRobuxInfoLabel.Text == message then
			srRobuxInfoLabel.Visible = false
			srRobuxInfoLabel.Text = ""
		end
	end)
end

local function updateSRRobuxLabel()
	srRobuxLabel.Text = "SRRobux: " .. FormatModule.FormatNumber(srRobux.Value)
end

local function setMusicVolume(volume)
	TweenService:Create(music, TweenInfo.new(0.3), {Volume = volume}):Play()
end

local function getPassState(passId)
	local owned = gamepasses:FindFirstChild(passId)
	local equippedFolder = playerData:FindFirstChild("EquippedGamepasses")
	local equipped = equippedFolder and equippedFolder:FindFirstChild(passId)
	
	return owned and owned.Value == true, equipped == nil or equipped.Value == true
end

local function updatePassCard(passId)
	local frame = passFrames[passId]
	if not frame then return end
	
	local button = frame:FindFirstChild("BuyPassButton") or frame:FindFirstChild("TapPassButton")
	local status = button and button:FindFirstChild("PassStatusLabel", true) or frame:FindFirstChild("PassStatusLabel", true)
	if status then
		status.Text = ShopModule.GetPassStatus(player, passId, priceMode)
	end
end

local function updateAllPassCards()
	for _, passId in ipairs(ShopModule.PassOrder) do
		updatePassCard(passId)
	end
end

local function priceText(passId)
	if not ShopModule.IsPassConfigured(passId) then return "Coming soon" end
	
	local robux = ShopModule.GetPassPrice(passId, "Robux")
	local sr = ShopModule.GetPassPrice(passId, "SRRobux")
	
	return FormatModule.FormatNumber(robux) .. " Robux OR " .. FormatModule.FormatNumber(sr) .. " SRRobux"
end

local function setButtonCaption(button, caption)
	if button:IsA("TextButton") then
		button.Text = caption 
		return
	end
	
	local label = button:FindFirstChild("TextLabel", true)
	if label then label.Text = caption end
end

local function updateSelectedPass()
	if not selectedPass then return end
	local data = ShopModule.GetPass(selectedPass)
	if not data then return end
	
	local owned, equipped = getPassState(selectedPass)
	detailsPassNameLabel.Text = data.Name
	detailsPassBoostLabel.Text = data.Boost
	detailsPassInfoLabel.Text = data.Info
	purchaseInfoLabel.Text = priceText(selectedPass)
	passIconDetails.Image = data.Icon
	purchaseIconPass.Image = data.Icon
	
	if owned then
		setButtonCaption(purchaseButton, equipped and "UNEQUIP" or "EQUIP")
		buyStatusLabel.Text = "OWNED"
		buyRobuxStatusLabel.Text = "OWNED"
	else 
		setButtonCaption(purchaseButton, "PURCHASE")
		local label = ShopModule.IsPassConfigured(selectedPass) and "BUY" or "SOON"
		buyStatusLabel.Text = label 
		buyRobuxStatusLabel.Text = label 
	end
end

local function openPassDetails(passId)
	if not ShopModule.GetPass(passId) then return end
	
	if detailsFrame.Visible and selectedPass == passId then
		detailsFrame.Visible = false
		selectedPass = nil 
		return
	end
	
	selectedPass = passId
	purchaseFrame.Visible = false 
	purchaseBlurFrame.Visible = false 
	updateSelectedPass()
	detailsFrame.Visible = true
end

local function connectPassFrame(passId, frame)
	local button = frame:FindFirstChild("BuyPassButton") or frame:FindFirstChild("TapPassButton")
	if button or not button:IsA("GuiButton") then
		warn("Shop pass button missing:", passId, frame:GetFullName())
		return
	end
	
	button.Activated:Connect(function()
		openPassDetails(passId)
	end)
	
	updatePassCard(passId)
end

for _, passId in ipairs(ShopModule.PassOrder) do
	local frame = passFrames[passId]
	if frame then
		connectPassFrame(passId, frame)
	else 
		warn("Shop pass frame missing:", ShopModule.GetPass(passId).FrameName)
	end
end

gamePassBox.ChildAdded:Connect(function(child)
	for _, passId in ipairs(ShopModule.PassOrder) do
		if child.Name == ShopModule.GetPass(passId).FrameName and not passFrames[passId] then
			passFrames[passId] = child
			connectPassFrame(passId, child)
			break
		end
	end
end)

local function bindBoolValues(folder)
	for _, value in ipairs(folder:GetChildren()) do
		if value:IsA("BoolValue") then
			value.Changed:Connect(function()
				updatePassCard(value.Name)
				if selectedPass == value.Name then updateSelectedPass() end
			end)
		end
	end
	
	folder.ChildAdded:Connect(function(value)
		if value:IsA("BoolValue") then
			value.Changed:Connect(function()
				updatePassCard(value.Name)
				if selectedPass == value.Name then updateSelectedPass() end
			end)
			
			updatePassCard(value.Name)
		end
	end)
end

bindBoolValues(gamepasses)

local equippedFolder = playerData:FindFirstChild("EquippedGamepasses")
if equippedFolder then bindBoolValues(equippedFolder) end
playerData.ChildAdded:Connect(function(child)
	if child.Name == "EquippedGamepasses" and child:IsA("Folder") then
		bindBoolValues(child)
		updateAllPassCards()
	end
end)

purchaseButton.Activated:Connect(function()
	if not selectedPass then return end
	
	local owned, equipped = getPassState(selectedPass)
	if owned then
		equipPassEvent:FireServer(selectedPass, not equipped)
		return
	end
	
	if not ShopModule.IsPassConfigured(selectedPass) then
		showWarning(ShopModule.ErrorMessages.NOT_CONFIGURED)
		return
	end
	
	purchaseFrame.Visible = true
	purchaseBlurFrame.Visible = true
end)

closePurcFrame.Activated:Connect(function()
	purchaseFrame.Visible = false
	purchaseBlurFrame.Visible = false
end)

local function buySelectedPass(currency)
	if not selectedPass then return end
	local owned = getPassState(selectedPass)
	if owned then
		showWarning(ShopModule.ErrorMessages.ALREADY_OWNED)
		return
	end
	
	if not ShopModule.IsPassConfigured(selectedPass) then
		showWarning(ShopModule.ErrorMessages.NOT_CONFIGURED)
		return
	end
	
	buyPassEvent:FireServer(selectedPass, currency)
end

buyPassButton.Activated:Connect(function()
	buySelectedPass("SRRobux")
end)

buyRobuxPassButton.Activated:Connect(function()
	buySelectedPass("Robux")
end)

local function openShop()
	updateAllPassCards()
	updateSRRobuxLabel()
	
	menuOpenSound:Stop()
	menuOpenSound.TimePosition = 0
	menuOpenSound:Play()
	
	setMusicVolume(0.1)
	MenuManager.toggleBlur("Shop")
end

local function closeShop()
	purchaseFrame.Visible = false 
	purchaseBlurFrame.Visible = false 
	detailsFrame.Visible = false 
	selectedPass = nil
	
	setMusicVolume(musicNormalVolume)
	
	MenuManager.close("Shop")
end

shopOpenButton.Activated:Connect(openShop)
backButton.Activated:Connect(closeShop)
srRobux.Changed:Connect(updateSRRobuxLabel)
updateSRRobuxLabel()

shopUpdateEvent.OnClientEvent:Connect(function(itemId, success, code)
	if ShopModule.GetPass(itemId) then
		updatePassCard(itemId)
		
		if success and code == "PURCHASE_GRANTED" then
			purchaseFrame.Visible = false
			purchaseBlurFrame.Visible = false 
		end
	end
	
	if not success then
		local message = ShopModule.ErrorMessage[code] or "Shop request failed."
		showWarning(message)
		if code == "NOT_ENOUGH_SRROBUX" then showSRRobuxInfo(message) end
	end
end)

local function updatePotionAmount(potionId)
	local frame = potionFrames[potionId]
	local label = frame and frame:FindFirstChild("NumberPotionLabel")
	local value = ClientDataModule.GetPotion(player, potionId)
	
	if label and value then
		label.Text = "x" .. FormatModule.FormatNumber(value.Value)
	end
end

local function updatePotionPrices()
	for potionId, frame in pairs(potionFrames) do
		for _, amount in ipairs({1, 5, 10}) do
			local button = frame:FindFirstChild("Buy" .. amount .. "PotionButton")
			local label = button and button:FindFirstChild("ValuePotions")
			local price = ShopModule.GetPotionPrice(potionId, amount, priceMode)
			
			if label then
				label.Text = price and (FormatModule.FormatNumber(price) .. " " .. priceMode) or "SOON"
			end
		end
	end
end

local function selectedPotionAmount(potionId, amountMode)
	selectedPotionUseAmount[potionId] = amountMode
	
	local frame = potionFrames[potionId]
	
	for _, option in ipairs({1, 5, "Max"}) do
		local button = frame:FindFirstChild("UseNumberPotions" .. option)
		if button then
			button.Image = option == amountMode and ShopModule.UIImages.PotionUseSelected or ShopModule.UIImages.PotionUseUnselected
		end
	end
end

local function showPotionInfo(potionId, message)
	local frame = potionFrames[potionId]
	local label = frame and frame:FindFirstChild("InfoPotionLabel")
	if not label then
		showWarning(message)
		return
	end
	
	label.Text = message
	label.Visible = true
	
	task.delay(2, function()
		if label.Text == message then
			label.Visible = false
			label.Text = ""
		end
	end)
end

local function setupPotionFrame(potionId)
	local frame = potionFrames[potionId]
	local value = ClientDataModule.GetPotion(player, potionId)
	
	value.Changed:Connect(function() updatePotionAmount(potionId) end)
	updatePotionAmount(potionId)
	selectedPotionAmount(potionId, 1)
	
	for _, amount in ipairs({1, 5, 10}) do
		local button = frame:FindFirstChild("Buy" .. amount .. "PotionButton")
		
		if button then
			button.Activated:Connect(function()
				buyPotionEvent:FireServer(potionId, amount, priceMode)
			end)
		end
	end
	
	for _, option in ipairs({1, 5, "Max"}) do
		local button = frame:FindFirstChild("UseNumberPotions" .. option)
		if button then
			button.Activated:Connect(function()
				if value.Value <= 0 then
					showPotionInfo(potionId, ShopModule.ErrorMessages.NOT_ENOUGH_POTIONS)
				else 
					selectedPotionAmount(potionId, option)
				end
			end)
		end
	end
	
	local useButton = frame:FindFirstChild("UsePotionButton")
	if useButton then
		useButton.Activated:Connect(function()
			usePotionEvent:FireServer(potionId, selectedPotionUseAmount[potionId])
		end)
	end
end

for _, potionId in ipairs(ShopModule.PotionOrder) do
	setupPotionFrame(potionId)
end

srValueShopButton.Activated:Connect(function()
	priceMode = priceMode == "Robux" and "SRRobux" or "Robux"
	updatePotionPrices()
	updateAllPassCards()
end)

updatePotionPrices()
updateAllPassCards()
detailsFrame.Visible = false
purchaseFrame.Visible = false
purchaseBlurFrame.Visible = false
srRobuxInfoLabel.Visible = false
showWarningLabel.Visible = false
closeShop()

print("ShopUI loaded")
