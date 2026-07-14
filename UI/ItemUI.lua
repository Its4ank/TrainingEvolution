local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)
local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")


local itemsFolderUI = guiFolder:WaitForChild("ItemsFolder")
local uiBalance = guiFolder:WaitForChild("UIBalance")

--//RemoteEvents
local buyItemEvent = ReplicatedStorage:WaitForChild("BuyItemEvent")
local upgradeItemEvent = ReplicatedStorage:WaitForChild("UpgradeItemEvent")
local evolveItemEvent = ReplicatedStorage:WaitForChild("EvolveItemEvent")
local itemSREvent = ReplicatedStorage:WaitForChild("ItemSREvent") 



--//Player stats
local energy = ClientDataModule.GetEnergy(player)
local money = ClientDataModule.GetMoney(player)
local srRobux = ClientDataModule.GetSrRobux(player)



--// Items Menu
local itemsMenu = itemsFolderUI:WaitForChild("ItemsMenu")
local itemsOpenButton = uiBalance:WaitForChild("ItemsOpenButton")
local backButtonItemsMenu = itemsMenu:WaitForChild("BackButtonItemsMenu")

local itemDetails = itemsMenu:WaitForChild("ItemDetailsFrame")



--// Item balance UI
local leaderstatsUIImage = itemsMenu:WaitForChild("leaderstatsUIImage")

local srRobuxLabel = leaderstatsUIImage:WaitForChild("SRRobuxLabel")
local itemsMoneyLabel = leaderstatsUIImage:WaitForChild("MoneyLabel")
local itemsEnergyLabel = leaderstatsUIImage:WaitForChild("EnergyLabel")



--// Item details UI
local itemNameLabel = itemDetails:WaitForChild("ItemNameLabel")
local itemLevelLabel = itemDetails:WaitForChild("ItemLevelLabel")
local itemEvolutionLabel = itemDetails:WaitForChild("ItemEvolutionLabel")
local itemTierLabel = itemDetails:WaitForChild("ItemTierLabel")
local itemPreviewViewport = itemDetails:WaitForChild("ItemPreviewViewport")
local itemAccelerationLabel = itemDetails:WaitForChild("ItemAccelerationLabel")
local itemRacePowerLabel = itemDetails:WaitForChild("ItemRacePowerLabel")
local itemRarityLabel = itemDetails:WaitForChild("ItemRarityLabel")

local buyItemButton = itemDetails:WaitForChild("BuyItemButton")
local upgradeItemButton = itemDetails:WaitForChild("UpgradeItemButton")
local evolveItemButton = itemDetails:WaitForChild("EvolveItemButton")
local srItemButton = itemDetails:WaitForChild("SRItemButton")

local buyEquippedLabel = buyItemButton:WaitForChild("BuyEquippedLabel")
local buyUnequippedLabel = buyItemButton:WaitForChild("BuyUnequippedLabel")
local upgradeLabel = upgradeItemButton:WaitForChild("UpgradeLabel")

local itemRarityImage = itemDetails:WaitForChild("ItemRarityImage")
local itemTierRarityImage = itemDetails:WaitForChild("ItemTierRarityImage")



--// SR Menu
local srFolder = itemsFolderUI:WaitForChild("SRItem")

local srShoesFrame = srFolder:WaitForChild("SRShoesFrame")
local srBackButton = srShoesFrame:WaitForChild("BackButton")
local srShoesButton = srShoesFrame:WaitForChild("SRShoesButton")

local evolutionShoesSR = srShoesFrame:WaitForChild("EvolutionShoesSR")
local levelShoesSR = srShoesFrame:WaitForChild("LevelShoesSR")
local energyShoesSR = srShoesFrame:WaitForChild("EnergyShoesSR")



--// Item data
local itemsFolder = ClientDataModule.GetItems(player)
local earthFolder = itemsFolder:WaitForChild("Earth")
local shoesFolder = earthFolder:WaitForChild("Shoes")

local shoesOwned = shoesFolder:WaitForChild("Owned")
local shoesEquipped = shoesFolder:WaitForChild("Equipped")
local shoesLevel = shoesFolder:WaitForChild("Level")
local shoesEvolution = shoesFolder:WaitForChild("Evolution")
local shoesTier = shoesFolder:WaitForChild("ItemTier")
local shoesAcceleration = shoesFolder:WaitForChild("Acceleration")
local shoesRacePower = shoesFolder:WaitForChild("RacePower")



--// States
local locationFramee = itemsMenu:WaitForChild("LocationFrame")
local locationFrame = locationFramee:WaitForChild("ScrollLocationFrame")

local earthButton = locationFrame:WaitForChild("EarthButton")

local era1Button = locationFrame:WaitForChild("Era1")

local itemsListFrame1 = itemsMenu:WaitForChild("ItemsListFrame1")
local itemsListFrame2 = itemsMenu:WaitForChild("ItemsListFrame2")
local itemsListFrame3 = itemsMenu:WaitForChild("ItemsListFrame3")
local itemsListFrame4 = itemsMenu:WaitForChild("ItemsListFrame4")
local itemsListFrame5 = itemsMenu:WaitForChild("ItemsListFrame5")

local shoesButton = itemsListFrame1:WaitForChild("ShoesButton")
local boardButton = itemsListFrame2:WaitForChild("BoardButton")
local scooterButton = itemsListFrame3:WaitForChild("ScooterButton")
local hoverboardButton = itemsListFrame4:WaitForChild("HoverboardButton")
local eScooterButton = itemsListFrame5:WaitForChild("EScooterButton")

local shoesViewport = shoesButton:WaitForChild("ItemViewport")
local boardViewport = boardButton:WaitForChild("ItemViewport")
local scooterViewport = scooterButton:WaitForChild("ItemViewport")
local hoverboardViewport = hoverboardButton:WaitForChild("ItemViewport")
local eScooterViewport = eScooterButton:WaitForChild("ItemViewport")

local shoesLockedLabel = shoesButton:WaitForChild("LockedLabel")
local boardLockedLabel = boardButton:WaitForChild("LockedLabel")
local scooterLockedLabel = scooterButton:WaitForChild("LockedLabel")
local hoverboardLockedLabel = hoverboardButton:WaitForChild("LockedLabel")
local eScooterLockedLabel = eScooterButton:WaitForChild("LockedLabel")



local earthOpen = false
local era1Open = false
local selectedItemTier = 1

MenuManager.register("Items", itemsMenu)




--// Balance
local UPGRADE_PRICES = {
	[1] = 750,
	[2] = 1250,
	[3] = 1750,
	[4] = 2000,
	[5] = 2350,
	[6] = 2750,
	[7] = 3250,
	[8] = 3750,
	[9] = 4100,
	[10] = 4500,
}

local TIER_PRICE_MULTIPLIER = {
	[1] = 1.00,
	[2] = 1.25,
	[3] = 1.5,
	[4] = 1.75,
	[5] = 2.00,
}

local ITEM_PREVIEW_BY_TIER = {
	[1] = "ShoesVisual",
	[2] = "Board",
	[3] = "Scooter",
	[4] = "Hoverboard_Red",
	[5] = "E-Scooter",
}

local ITEM_NAMES_BY_TIER = {
	[1] = "Shoes",
	[2] = "Board",
	[3] = "Scooter",
	[4] = "Hoverboard",
	[5] = "E-Scooter",
}

local ITEM_RARITY_BY_TIER = {
	[1] = "Common",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Epic",
	[5] = "Legendary",
}

local ITEM_RARITY_IMAGE_BY_TIER = {
	[1] = "rbxassetid://125557164640494",
	[2] = "rbxassetid://139402889171300",
	[3] = "rbxassetid://99898076943285",
	[4] = "rbxassetid://125028078426045",
	[5] = "rbxassetid://98153882736668",
}

local ITEM_TIER_IMAGE_BY_TIER = {
	[1] = "rbxassetid://73943552547641",
	[2] = "rbxassetid://118679363157693",
	[3] = "rbxassetid://104403571627394",
	[4] = "rbxassetid://125968338598520",
	[5] = "rbxassetid://95006719050053",
}

local ITEM_DETAILS_BY_TIER = {
	[1] = {
	Name = "Shoes",
	Rarity = "Common",
	Acceleration = 1.00,
	RacePower = 1.00,
	},
	
	[2] = {
		Name = "Board",
		Rarity = "Uncommon",
		Acceleration = 1.05,
		RacePower = 1.05,
	},
	
	[3] = {
		Name = "Scooter",
		Rarity = "Rare",
		Acceleration = 1.10,
		RacePower = 1.10,
	},
	
	[4] = {
		Name = "Hoverboard",
		Rarity = "Epic",
		Acceleration = 1.15,
		RacePower = 1.15,
	},
	
	[5] = {
		Name = "E-Scooter",
		Rarity = "Legendary",
		Acceleration = 1.20,
		RacePower = 1.20,
	},
}



--// Utils
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

local function getItemTierName(tier)
	if tier == 1 then return "Novice" end 
	if tier == 2 then return "Advanced" end 
	if tier == 3 then return "Expert" end 
	if tier == 4 then return "Master" end 
	if tier == 5 then return "Legend" end 
	return "Unknown"
end



--//Preview
local function cleanPreviewModel(model)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("Script")
			or obj:IsA("LocalScript")
			or obj:IsA("ClickDetector")
			or obj:IsA("sound") then 
			obj:Destroy()
		end

		if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
			obj.Disabled = true
			obj.CanTouch = false
			obj.CanCollide = false
		end

		if obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
			obj.CanTouch = false
		end
	end
end

local function setupItemButtonViewport(viewport, visualName)
	viewport:ClearAllChildren()
	
	local previewRoot = game.ReplicatedStorage:FindFirstChild("ItemPreviewModels")
	if not previewRoot then return end
	
	local earthFolder = previewRoot:FindFirstChild("Earth")
	if not earthFolder then return end
	
	local modelTemplate = earthFolder:FindFirstChild(visualName)
	if not modelTemplate then
		warn("Preview not found:", visualName)
		return
	end
	
	local clone = modelTemplate:Clone()
	clone.Parent = viewport
	
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
		end
	end
	
	local cf, size = clone:GetBoundingBox()
	local center = cf.Position
	
	clone:PivotTo(CFrame.new(-center) * clone:GetPivot())
	
	local biggest = math.max(size.X, size.Y, size.Z)
	
	local distance = biggest *  1.2
	local height = size.Y * 0.25
	
	if visualName == "ShoesVisual" then
		distance = biggest * 1.1
		height = size.Y * 0.25
	elseif visualName == "Board" then
		distance = biggest * 0.9
		height = size.Y * 0.35
		clone:PivotTo(CFrame.Angles(0.3, math.rad(90), 0) * clone:GetPivot())
	elseif visualName == "Scooter" then
		distance = biggest * 1.0
		height = size.Y * 0.35
	elseif visualName == "Hoverboard_Red" then
		distance = biggest * 0.9
		height = size.Y * 0.35
		clone:PivotTo(CFrame.Angles(0.1, math.rad(90), 0) * clone:GetPivot())
	elseif visualName == "E-Scooter" then
		distance = biggest * 1.2
		height = size.Y * 0.35
	end
	
	camera.CFrame = CFrame.new( 
		Vector3.new(0, height, distance),
		Vector3.new(0, 0, 0)
	)
end

local currentPreviewModel = nil
local currentPreviewBaseCFrame = nil
local previewRotationAngle = 0

local function updateShoesPreview()

	itemPreviewViewport:ClearAllChildren()

	local previewRoot = game.ReplicatedStorage:FindFirstChild("ItemPreviewModels")
	if not previewRoot then return end

	local earthPreviewFolder = previewRoot:FindFirstChild("Earth")
	if not earthPreviewFolder then return end

	local visualName = ITEM_PREVIEW_BY_TIER[selectedItemTier] or "ShoesVisual"
	local visualTemplate = earthPreviewFolder:FindFirstChild(visualName)

	if not visualTemplate then
		warn("Preview visual not found:", visualName)
		return
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = itemPreviewViewport

	local clone = visualTemplate:Clone()
	clone.Parent = worldModel

	cleanPreviewModel(clone)

	local previewOffset = CFrame.new(0, 0, 0)
	local previewRotation = CFrame.Angles(0, math.rad(150), 0)

	if selectedItemTier == 1 then
		-- ShoesVisual
		previewOffset = CFrame.new(0, 0, 0)
		previewOffset = CFrame.Angles(0, math.rad(150), 0)
	elseif selectedItemTier == 2 then
		-- Board
		previewOffset = CFrame.new(0, 0, 0)
		previewOffset = CFrame.Angles(0, math.rad(90), 0)
	elseif selectedItemTier == 3 then
		-- Scooter
		previewOffset = CFrame.new(0, 0, 0)
		previewOffset = CFrame.Angles(0, math.rad(130), 0)
	elseif selectedItemTier == 4 then
		-- Hoverboard
		previewOffset = CFrame.new(0, 1, 0)
		previewOffset = CFrame.Angles(0, math.rad(90), 0)
	elseif selectedItemTier == 5 then
		-- E-Scooter
		previewOffset = CFrame.new(0, 0, 0)
		previewOffset = CFrame.Angles(0, math.rad(140), 0)
	end

	clone:PivotTo(previewOffset * previewRotation * clone:GetPivot())

	local cf, size = clone:GetBoundingBox()
	local center = cf.Position

	clone:PivotTo(CFrame.new(-center) * clone:GetPivot())
	clone:PivotTo(previewOffset * previewRotation * clone:GetPivot())
	
	currentPreviewModel = clone
	currentPreviewBaseCFrame = clone:GetPivot()
	previewRotationAngle = 0

	local _, newSize = clone:GetBoundingBox()

	local _, newSize = clone:GetBoundingBox()
	local biggest = math.max(newSize.X, newSize.Y, newSize.Z)
	local distance = math.max(biggest * 1.1, 5)

	local camera = Instance.new("Camera")
	camera.Parent = itemPreviewViewport
	itemPreviewViewport.CurrentCamera = camera

	itemPreviewViewport.Ambient = Color3.fromRGB(255, 255, 255)
	itemPreviewViewport.LightColor = Color3.fromRGB(255, 255, 255)
	itemPreviewViewport.LightDirection = Vector3.new(0, 1, 0)

	camera.CFrame = CFrame.new(
		Vector3.new(0, newSize.Y * 0.4, distance),
		Vector3.new(0, newSize.Y * 0.25, 0)
	)
end

local function updateSRShoesButton()
	local canSR = shoesLevel.Value >=10 and shoesEvolution.Value >= 5 and energy.Value >= 1000 and shoesTier.Value < 5

	if canSR then
		srShoesButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		srShoesButton.Text = "SR Item"
		srShoesButton.Active = true
		srShoesButton.AutoButtonColor = true
	else
		srShoesButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		srShoesButton.Text = "Locked"
		srShoesButton.Active = true
		srShoesButton.AutoButtonColor = false
	end

	if shoesTier.Value >= 5 then
		srShoesButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		srShoesButton.Text = "MAX TIER"
		srShoesButton.Active = false
		srShoesButton.AutoButtonColor = false
	end
end

local function updateSRShoesRequirements()
	local requiredEvolution = 5
	local requiredLevel = 10
	local requiredEnergy = 1000

	local currentEvolution = shoesEvolution.Value
	local currentLevel = shoesLevel.Value
	local currentEnergy = energy.Value

	evolutionShoesSR.Text = "Evolution" .. tostring(currentEvolution) .. "/" .. tostring(requiredEvolution)
	levelShoesSR.Text = "Level: " .. tostring(currentLevel) .. "/" .. tostring(requiredLevel)
	energyShoesSR.Text = "Energy: " .. tostring(currentEnergy) .. "/" .. tostring(requiredEnergy)

	if currentEvolution >= requiredEvolution then
		evolutionShoesSR.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		evolutionShoesSR.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end

	if currentLevel >= requiredLevel then
		levelShoesSR.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		levelShoesSR.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end

	if currentEnergy >= requiredEnergy then
		energyShoesSR.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		energyShoesSR.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end

local function updateItemBalanceUI()
	itemsEnergyLabel.Text = "" .. formatShort(energy.Value)
	itemsMoneyLabel.Text = "" .. formatShort(money.Value)
	
	if srRobux then
		srRobuxLabel.Text = "" .. formatShort(srRobux.Value)
	else
		srRobuxLabel.Text = "0"
	end
end

local function isSelectedItemUnlocked()
	return selectedItemTier <= shoesTier.Value
end

local function updateItemSlotLocks()
	local slots = {
		[1] = {
			lockedLabel = shoesLockedLabel,
		},

		[2] = {
			lockedLabel = boardLockedLabel,
		},

		[3] = {
			lockedLabel = scooterLockedLabel,
		},

		[4] = {
			lockedLabel = hoverboardLockedLabel,
		},

		[5] = {
			lockedLabel = eScooterLockedLabel,
		},
	}

	for tier, slot in ipairs(slots) do
		local unlocked = tier <= shoesTier.Value

		if unlocked then
			slot.lockedLabel.Visible = false
		else
			slot.lockedLabel.Visible = true

			slot.lockedLabel.Text = "Locked"
		end
	end
end


local function updateShoes()
	updateShoesPreview()
	updateItemSlotLocks()
	local currentTier = selectedItemTier
	local unlocked = isSelectedItemUnlocked()
	
	local details = ITEM_DETAILS_BY_TIER[currentTier]
	if not details then return end
	
	itemNameLabel.Text = details.Name
	itemRarityLabel.Text = "Rarity: " .. details.Rarity
	
	itemRarityImage.Image = ITEM_RARITY_IMAGE_BY_TIER[currentTier] or ""
	itemTierRarityImage.Image = ITEM_TIER_IMAGE_BY_TIER[currentTier] or ""

	itemLevelLabel.Text = "Level: " .. tostring(shoesLevel.Value)
	itemEvolutionLabel.Text = "Evolution: " .. tostring(shoesEvolution.Value) .. "/5"
	itemTierLabel.Text = "Tier: " .. getItemTierName(shoesTier.Value)
	itemAccelerationLabel.Text = "Acceleration: x" .. string.format("%.2f", details.Acceleration)
	itemRacePowerLabel.Text = "RAce Power: x" .. string.format("%.2f", details.RacePower)
	
	if not unlocked then
		itemNameLabel.Text = details.Name
		itemRarityLabel.Text = "Locked"
		itemLevelLabel.Text = "Required: " .. getItemTierName(currentTier)
		itemEvolutionLabel.Text = "Unclock Tier: " .. tostring(currentTier)
		itemTierLabel.Text = "Need " .. getItemTierName(currentTier)
		itemAccelerationLabel.Text = "Locked"
		itemRacePowerLabel.Text = "Locked"
			
		buyItemButton.Visible = false
		upgradeItemButton.Visible = false
		evolveItemButton.Visible = false
		srItemButton.Visible = false
			
		return
	end

	upgradeItemButton.Visible = false
	evolveItemButton.Visible = false
	srItemButton.Visible = false
	
	if shoesOwned.Value then
		if shoesLevel.Value < 10 then
			upgradeItemButton.Visible = true
		elseif shoesEvolution.Value < 5 then
			evolveItemButton.Visible = true
		elseif shoesEvolution.Value >= 5 then
			srItemButton.Visible = true
		end
	end
	
	buyItemButton.Visible = true
	buyItemButton.Active = true
	buyItemButton.AutoButtonColor = true
	
	buyEquippedLabel.Visible = false
	buyUnequippedLabel.Visible = false

	if not shoesOwned.Value then
		buyUnequippedLabel.Visible = true
		buyUnequippedLabel.Text = "Buy"
	else
		if shoesEquipped.Value then
			buyEquippedLabel.Visible = true
			buyEquippedLabel.Text = "Equipped"
		else
			buyUnequippedLabel.Visible = true
			buyUnequippedLabel.Text = "Equip"
		end
	end

	if shoesLevel.Value >= 10 then
		upgradeLabel.Text = "Upgrade: MAX"

		if shoesEvolution.Value < 5 then
			evolveItemButton.Visible = true
		else
			evolveItemButton.Visible = false
		end
	else
		local nextLevel = shoesLevel.Value + 1

		local basePrice = UPGRADE_PRICES[nextLevel] or 999999
		local tierMultiplier = TIER_PRICE_MULTIPLIER[shoesTier.Value] or 1
		local price = math.floor(basePrice * tierMultiplier)

		upgradeLabel.Text = "Upgrade: " .. formatShort(price)
	end
end

local function refreshItemsMenuState()
	era1Button.Visible = earthOpen
	itemsListFrame1.Visible = era1Open
	itemsListFrame2.Visible = era1Open
	itemsListFrame3.Visible = era1Open
	itemsListFrame4.Visible = era1Open
	itemsListFrame5.Visible = era1Open
	itemDetails.Visible = selectedItem ~= nil
end

local function selectItemTier(tier)
	selectedItemTier = tier
	itemDetails.Visible = true
	updateShoes()
end



--// Button Handlers
itemsOpenButton.MouseButton1Click:Connect(function()
	if itemsMenu.Visible then
		refreshItemsMenuState()
	end
	
	MenuManager.toggleFull("Items")
end)

backButtonItemsMenu.MouseButton1Click:Connect(function()
	MenuManager.close("Items")
end)

earthButton.MouseButton1Click:Connect(function()
	earthOpen = not earthOpen

	if not earthOpen then
		era1Open = false
		selectedItem = nil
	end

	refreshItemsMenuState()
end)

era1Button.MouseButton1Click:Connect(function()
	era1Open = not era1Open
	
	if not era1Open then
		selectedItem = nil
	end
	
	refreshItemsMenuState()
end)

--local function selectItem(itemTier)
	--selectedItem = itemTier 
	--itemDetails.Visible = true
	
	--updateShoes()
	--refreshItemsMenuState()
--end

shoesButton.MouseButton1Click:Connect(function() 
	selectItemTier(1)
end)

boardButton.MouseButton1Click:Connect(function()
	selectItemTier(2)
end)

scooterButton.MouseButton1Click:Connect(function()
	selectItemTier(3)
end)

hoverboardButton.MouseButton1Click:Connect(function()
	selectItemTier(4)
end)

eScooterButton.MouseButton1Click:Connect(function()
	selectItemTier(5)
end)


buyItemButton.MouseButton1Click:Connect(function()
	print("BUY/EQUIP BUTTON CLICK")
	buyItemEvent:FireServer("Earth", "Shoes")
end)

upgradeItemButton.MouseButton1Click:Connect(function()
	upgradeItemEvent:FireServer("Earth", "Shoes")
end)

evolveItemButton.MouseButton1Click:Connect(function()
	evolveItemEvent:FireServer("Earth", "Shoes")
end)

srItemButton.MouseButton1Click:Connect(function()
	itemsMenu.Visible = false
	srShoesFrame.Visible = true
	updateSRShoesButton()
	updateSRShoesRequirements()
end)

srShoesButton.MouseButton1Click:Connect(function()
	if shoesLevel.Value >= 10 and shoesEvolution.Value >= 5 and energy.Value >= 1000 and shoesTier.Value < 5 then
		print("SR SHOES BUTTON CLICK")
		itemSREvent:FireServer()
	end
end)

srBackButton.MouseButton1Click:Connect(function()
	srShoesFrame.Visible = false
	itemsMenu.Visible = true
	
	updateShoes()
end)



--//Value Connections
shoesOwned.Changed:Connect(updateShoes)
shoesEquipped.Changed:Connect(updateShoes)
shoesLevel.Changed:Connect(updateShoes)
shoesEvolution.Changed:Connect(updateShoes)
shoesTier.Changed:Connect(updateShoes)
shoesAcceleration.Changed:Connect(updateShoes)
shoesRacePower.Changed:Connect(updateShoes)

shoesLevel.Changed:Connect(updateSRShoesButton)
shoesEvolution.Changed:Connect(updateSRShoesButton)
shoesTier.Changed:Connect(updateSRShoesButton)

shoesLevel.Changed:Connect(updateSRShoesRequirements)
shoesEvolution.Changed:Connect(updateSRShoesRequirements)
energy.Changed:Connect(updateSRShoesRequirements)
energy.Changed:Connect(updateItemBalanceUI)
money.Changed:Connect(updateItemBalanceUI)

if srRobux then
	srRobux:GetPropertyChangedSignal("Value"):Connect(function()
		updateItemBalanceUI()
	end)
end



--// Init
refreshItemsMenuState()
updateShoes()
updateSRShoesButton()
updateSRShoesRequirements()
updateItemBalanceUI()

--ButtonViewport
setupItemButtonViewport(shoesViewport, "ShoesVisual")
setupItemButtonViewport(boardViewport, "Board")
setupItemButtonViewport(scooterViewport, "Scooter")
setupItemButtonViewport(hoverboardViewport, "Hoverboard_Red")
setupItemButtonViewport(eScooterViewport, "E-Scooter")

era1Button.Visible = false
itemsListFrame1.Visible = false
itemsListFrame2.Visible = false
itemsListFrame3.Visible = false
itemsListFrame4.Visible = false
itemsListFrame5.Visible = false
itemDetails.Visible = false

RunService.RenderStepped:Connect(function(dt)
	if currentPreviewModel and currentPreviewBaseCFrame then
		previewRotationAngle = previewRotationAngle + (dt * math.rad(35))
		
		currentPreviewModel:PivotTo( 
			currentPreviewBaseCFrame * CFrame.Angles(0, previewRotationAngle, 0)
		)
	end
end)

print("ItemUI loaded")