local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ItemModule = require(game.ServerScriptService.Modules.ItemModule)

local trainerEvent = ReplicatedStorage:WaitForChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:WaitForChild("PlayerDataLoadedEvent")

-- RemoteEvent
local buyItemEvent = ReplicatedStorage:FindFirstChild("BuyItemEvent")
if not buyItemEvent then
	buyItemEvent = Instance.new("RemoteEvent")
	buyItemEvent.Name = "BuyItemEvent"
	buyItemEvent.Parent = ReplicatedStorage
end

local upgradeItemEvent = ReplicatedStorage:FindFirstChild("UpgradeItemEvent")
if not upgradeItemEvent then
	upgradeItemEvent = Instance.new("RemoteEvent")
	upgradeItemEvent.Name = "UpgradeItemEvent"
	upgradeItemEvent.Parent = ReplicatedStorage
end

local evolveItemEvent = ReplicatedStorage:FindFirstChild("EvolveItemEvent")
if not evolveItemEvent then
	evolveItemEvent = Instance.new("RemoteEvent")
	evolveItemEvent.Name = "EvolveItemEvent"
	evolveItemEvent.Parent = ReplicatedStorage
end

local itemSREvent = ReplicatedStorage:FindFirstChild("ItemSREvent")
if not itemSREvent then
	itemSREvent = Instance.new("RemoteEvent")
	itemSREvent.Name = "ItemSREvent"
	itemSREvent.Parent = ReplicatedStorage
end

--Helpers
local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateValue(parent, className, name, default)
	local v = parent:FindFirstChild(name)
	if not v then
		v = Instance.new(className)
		v.Name = name
		v.Value = default
		v.Parent = parent
	end
	return v
end

local function getMoney(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		return nil
	end
	
	return playerData:FindFirstChild("Money")
end



--Visual logic
local function removeShoesVisual(character)
	for _, obj in ipairs(character:GetChildren()) do
		if obj.Name == "EquippedShoesVisual" then
			obj:Destroy()
		end
	end
	
	for _, obj in ipairs(character:GetDescendants()) do
		if obj.Name == "LeftShoe" or obj.Name == "RightShoe" then
			obj:Destroy()
		end
	end
end

local function getCharacterFeet(character)
	local leftFoot = character:FindFirstChild("LeftFoot")
		or character:FindFirstChild("Left Leg")
	local rightFoot = character:FindFirstChild("RightFoot")
		or character:FindFirstChild("Right Leg") 
	return leftFoot, rightFoot
end

local function attachShoePart(shoePart, footPart, offsetCFrame)
	shoePart.Anchored = false
	shoePart.CanCollide = false
	shoePart.Massless = true

	shoePart.CFrame = footPart.CFrame * offsetCFrame
	shoePart.Parent = footPart.Parent

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = shoePart
	weld.Part1 = footPart
	weld.Parent = shoePart
end

local ITEM_VISUAL_BY_TIER = {
	[1] = "ShoesVisual",
	[2] = "Board",
	[3] = "Scooter",
	[4] = "Hoverboard_Red",
	[5] = "E-Scooter",
}

local function cleanVisualClone(model)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("Script")
			or obj:IsA("LocalScript")
			or obj:IsA("ClickDetector")
			or obj:IsA("Sound") then
			obj:Destroy()
		end
		
		if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
			obj.Disabled = true
			obj.CanTouch = false
			obj.CanCollide = false
		end
		
		if obj:IsA("BasePart") then
			obj.Anchored = false
			obj.CanCollide = false
			obj.CanTouch = false
			obj.Massless = true
		end
	end
end

local function weldAllPartsToMain(model, mainPart)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") and obj ~= mainPart then
			obj.Anchored = false
			obj.CanCollide = false
			obj.Massless = true

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = mainPart
			weld.Part1 = obj
			weld.Parent = mainPart
		end
	end
end

local function setDefaultAnimation(character, enabled)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animate = character:FindFirstChild("Animate")
	
	if animate then
		animate.Disabled = not enabled
	end
	
	if humanoid and not enabled then
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end
end

local DEFAULT_HIP_HEIGHT = 2

local function setRideHipHeight(character, tierValue)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	if tierValue == 2 then
		--Board
		humanoid.HipHeight = 3
	elseif tierValue == 3 then
		--Scooter
		humanoid.HipHeight = 2.8
	elseif tierValue == 4 then
		--Hoverboard_Red
		humanoid.HipHeight = 2.9
	elseif tierValue == 5 then
		--E-Scooter
		humanoid.HipHeight = 3.3
	else
		humanoid.HipHeight = DEFAULT_HIP_HEIGHT
	end
end

local function updateShoesVisual(player)
	print("UPDATE SHOES VISUAL")
	local character = player.Character
	if not character then return end

	removeShoesVisual(character)

	local shoes = ItemModule.getShoesFolder(player)
	if not shoes then return end

	local owned = shoes:FindFirstChild("Owned")
	local tier = shoes:FindFirstChild("ItemTier")

	if not owned or not owned.Value then return end
	if not tier then return end
	
	if tier.Value == 1 then
		setDefaultAnimation(character, true)
		setRideHipHeight(character, 1)
	else
		setDefaultAnimation(character, false)
		setRideHipHeight(character, tier.Value)
	end

	local visualName = ITEM_VISUAL_BY_TIER[tier.Value] or "ShoesVisual"

	local visualsFolder = ServerStorage:FindFirstChild("ItemVisuals")
	if not visualsFolder then return end

	local earthFolder = visualsFolder:FindFirstChild("Earth")
	if not earthFolder then return end

	local visualTemplate = earthFolder:FindFirstChild(visualName)
	if not visualTemplate then
		warn("Visual not found:", visualName)
		return
	end

	-- TIER 1: ShoesVisual надеваем на ноги
	if tier.Value == 1 then
		local leftFoot, rightFoot = getCharacterFeet(character)
		if not leftFoot or not rightFoot then return end

		local visualFolder = Instance.new("Folder")
		visualFolder.Name = "EquippedShoesVisual"
		visualFolder.Parent = character

		local leftShoeTemplate = visualTemplate:FindFirstChild("LeftShoe")
		local rightShoeTemplate = visualTemplate:FindFirstChild("RightShoe")

		if leftShoeTemplate and leftShoeTemplate:IsA("BasePart") then
			local leftShoe = leftShoeTemplate:Clone()
			leftShoe.Parent = visualFolder
			leftShoe.TextureID = ""
			leftShoe.Color = Color3.fromRGB(0, 170, 255)
			leftShoe.Material = Enum.Material.SmoothPlastic

			attachShoePart(leftShoe, leftFoot, CFrame.new(0, 0.25, -0.4))
		end

		if rightShoeTemplate and rightShoeTemplate:IsA("BasePart") then
			local rightShoe = rightShoeTemplate:Clone()
			rightShoe.Parent = visualFolder
			rightShoe.TextureID = ""
			rightShoe.Color = Color3.fromRGB(0, 170, 255)
			rightShoe.Material = Enum.Material.SmoothPlastic

			attachShoePart(rightShoe, rightFoot, CFrame.new(0, 0.25, -0.4))
		end

		return
	end

	-- TIER 2+: транспорт под игроком
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local clone = visualTemplate:Clone()
	clone.Name = "EquippedShoesVisual"
	clone.Parent = character

	cleanVisualClone(clone)

	local mainPart = clone:FindFirstChild("RideRoot", true) or clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	if not mainPart then warn("No BasePart in visual:", visualName)
		clone:Destroy()
		return
	end

	clone.PrimaryPart = mainPart

	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = false
			obj.CanCollide = false
			obj.Massless = true
		end
	end

	local offset = CFrame.new(0, -3, 0)
	
	if tier.Value == 2 then
		-- Board
		offset = CFrame.new(0, -3.3, 0) * CFrame.Angles(0, math.rad(0), 0)
		elseif tier.Value == 3 then
		-- Scooter
		offset = CFrame.new(0, -2.6, 0) * CFrame.Angles(0, math.rad(0), 0)
		elseif tier.Value == 4 then
		-- Hoverboard
		offset = CFrame.new(0, -3, 0) * CFrame.Angles(0, math.rad(0), 0)
		elseif tier.Value == 5 then
		-- E-Scooter
		offset = CFrame.new(0, -3.35, 0) * CFrame.Angles(0, math.rad(90), 0)
	end
	
	clone:PivotTo(root.CFrame * offset)
	
	mainPart.Anchored = false
	mainPart.CanCollide = false
	mainPart.CanTouch = false
	mainPart.Massless = true

	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") and obj ~= mainPart then
			obj.Anchored = false
			obj.CanCollide = false
			obj.CanTouch = false
			obj.Massless = true
			
			if obj ~= mainPart then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = mainPart
				weld.Part1 = obj
				weld.Parent = mainPart
			end
		end
	end

	local weldToPlayer = Instance.new("WeldConstraint")
	weldToPlayer.Part0 = mainPart
	weldToPlayer.Part1 = root
	weldToPlayer.Parent = mainPart
end



--Main item actions
local function setupItems(player)
	local itemsFolder = getOrCreateFolder(player, "Items")
	local earthFolder = getOrCreateFolder(itemsFolder, "Earth")

	local shoes = getOrCreateFolder(earthFolder, "Shoes")

	getOrCreateValue(shoes, "BoolValue", "Owned", false)
	getOrCreateValue(shoes, "BoolValue", "Equipped", false)
	getOrCreateValue(shoes, "IntValue", "Level", 0)
	getOrCreateValue(shoes, "IntValue", "Evolution", 0)
	getOrCreateValue(shoes, "IntValue", "ItemTier", 1)
	getOrCreateValue(shoes, "NumberValue", "Acceleration", 1)
	getOrCreateValue(shoes, "NumberValue", "RacePower", 1)
	ItemModule.updateShoesBoosts(player)
end

local function buyItem(player, worldName, itemName)
	local itemsFolder = player:FindFirstChild("Items")
	if not itemsFolder then return end

	local worldFolder = itemsFolder:FindFirstChild(worldName)
	if not worldFolder then return end 

	local itemFolder = worldFolder:FindFirstChild(itemName)
	if not itemFolder then return end 

	local owned = itemFolder:FindFirstChild("Owned")
	if not owned then return end 
	
	local equipped = itemFolder:FindFirstChild("Equipped")
	if not equipped then 
		equipped = Instance.new("BoolValue")
		equipped.Name = "Equipped"
		equipped.Value = false
		equipped.Parent = itemFolder
	end

	local equipped = itemFolder:FindFirstChild("Equipped")
	if not equipped then return end 
	
	if owned.Value then
		equipped.Value = not equipped.Value
		
		print("TOGGLE EQUIPPED:", equipped.Value)
		
		if equipped.Value then
			updateShoesVisual(player)
		else
			if player.Character then
				removeShoesVisual(player.Character)
				
				setDefaultAnimation(player.Character, true)
				setRideHipHeight(player.Character, 1)
			end
		end
		return
	end

	local money = getMoney(player)
	if not money then return end 

	local price = 0

	if worldName == "Earth" and itemName == "Shoes" then
		price = 500
	end

	if money.Value < price then
		return
	end

	money.Value -= price
	owned.Value = true
	equipped.Value = true
	ItemModule.updateShoesBoosts(player)
	updateShoesVisual(player)

	print(player.Name, "купить", itemName, "за", price)
end

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

local function upgradeItem(player, worldName, itemName)
	local itemsFolder = player:FindFirstChild("Items")
	if not itemsFolder then return end

	local worldFolder = itemsFolder:FindFirstChild(worldName)
	if not worldFolder then return end 

	local itemFolder = worldFolder:FindFirstChild(itemName)
	if not itemFolder then return end 

	local owned = itemFolder:FindFirstChild("Owned")
	local level = itemFolder:FindFirstChild("Level")

	if not owned or not owned.Value then
		return
	end

	if not level then
		return
	end

	if level.Value >= 10 then
		return
	end

	local money = getMoney(player) 
	if not money then
		return
	end

	local nextLevel = level.Value + 1
	
	local tier = itemFolder:FindFirstChild("ItemTier")
	local tierValue = tier and tier.Value or 1
	local tierMultiplier = TIER_PRICE_MULTIPLIER[tierValue] or 1
	
	local basePrice = UPGRADE_PRICES[nextLevel] or 999999
	local price = math.floor(basePrice * tierMultiplier)

	if money.Value < price then
		return
	end

	money.Value -= price
	level.Value = nextLevel
	ItemModule.updateShoesBoosts(player)

	print(player.Name, "upgrade", itemName, "to level", nextLevel, "for", price)
end

local function evolveItem(player, worldName, itemName)
	local itemsFolder = player:FindFirstChild("Items")
	if not itemsFolder then return end

	local worldFolder = itemsFolder:FindFirstChild(worldName)
	if not worldFolder then return end 

	local itemFolder = worldFolder:FindFirstChild(itemName)
	if not itemFolder then return end 

	local level = itemFolder:FindFirstChild("Level")
	local evolution = itemFolder:FindFirstChild("Evolution")

	if not level or not evolution then
		return end 

	if level.Value ~= 10 then
		return
	end

	if evolution.Value >= 5 then
		return
	end

	evolution.Value += 1
	level.Value = 0
	ItemModule.updateShoesBoosts(player)

	print(player.Name, "EVOLVED", itemName, "-> Evolution:", evolution.Value)
end

local function doItemSR(player)
	local shoes = ItemModule.getShoesFolder(player)
	if not shoes then
		warn("SR: no shoes folder")
		return
	end
	
	local owned = shoes:FindFirstChild("Owned")
	local level = shoes:FindFirstChild("Level")
	local evolution = shoes:FindFirstChild("Evolution")
	local tier = shoes:FindFirstChild("ItemTier")
	
	if not owned or not level or not evolution or not tier then 
		warn("SR: missing values")
		return
	end
	
	print("SR CHECK:", "Owned", owned.Value, "Level", level.Value, "Evolution", evolution.Value, "Tier", tier.Value)
	
	if not owned.Value then
		return
	end
	
	if level.Value < 10 then
		return
	end
	
	if evolution.Value < 5 then
		return
	end
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	
	local energy = leaderstats:FindFirstChild("Energy")
	if not energy then
		return
	end
	
	if energy.Value < 1000 then
		return
	end
	
	if tier.Value >= 5 then
		return
	end
	
	tier.Value += 1
	level.Value = 0
	evolution.Value = 1
	
	if tier.Value == 5 then
		local playerData = player:FindFirstChild("PlayerData")
		if playerData then
			local srRobux = playerData:FindFirstChild("SrRobux")
			if srRobux then
				srRobux.Value += 1
			end
		end
	end
	
	ItemModule.updateShoesBoosts(player)
	updateShoesVisual(player)
	
	print(player.Name, "SR Item ->", ItemModule.getItemTierName(tier.Value))
end

local function tryEquipSavedItem(player)
	local shoes = ItemModule.getShoesFolder(player)
	if not shoes then return end 
	
	local owned = shoes:FindFirstChild("Owned")
	local equipped = shoes:FindFirstChild("Equipped")
	
	print("TRY EQUIP SAVED ITEM:", owned and owned.Value, equipped and equipped.Value)
	
	if owned and equipped and owned.Value and equipped.Value then
		updateShoesVisual(player)
	end
end



--Event connections
buyItemEvent.OnServerEvent:Connect(function(player, worldName, itemName)
	print("SERVER BUY/EQUIP EVENT:", player.Name, worldName, itemName)
	buyItem(player, worldName, itemName)
end)

upgradeItemEvent.OnServerEvent:Connect(function(player, worldName, itemName)
	upgradeItem(player, worldName, itemName)
end)

evolveItemEvent.OnServerEvent:Connect(function(player, worldName, itemName)
	evolveItem(player, worldName, itemName)
end)

itemSREvent.OnServerEvent:Connect(function(player)
	print("ITEM SR EVENT FROM", player.Name)
	doItemSR(player)
end)

--Player setup
Players.PlayerAdded:Connect(function(player)
	setupItems(player)
	
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		character:WaitForChild("HumanoidRootPart")
		
		task.wait(1)
		tryEquipSavedItem(player)
	end)
end)

playerDataLoadedEvent.Event:Connect(function(player)
	task.wait(1)
	tryEquipSavedItem(player)
end)

for _, player in ipairs(Players:GetPlayers()) do 
	setupItems(player)
	
	if player.Character then
		task.wait(1)
		
		local shoes = ItemModule.getShoesFolder(player)
		if shoes then 
			local owned = shoes:FindFirstChild("Owned")
			local equipped = shoes:FindFirstChild("Equipped")
			
			if owned and equipped and owned.Value and equipped.Value then
				updateShoesVisual(player)
			end
		end
	end
end

print("ItemServer loaded")
