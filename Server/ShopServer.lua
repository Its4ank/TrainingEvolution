local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")

local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)
local BetaPurchaseTracker = require(game.ServerScriptService.Modules.BetaPurchaseTracker)

local grantPotionPurchaseFunction = ServerScriptService:WaitForChild("GrantPotionPurchaseFunction")

--//RemoteEvents
local shopEventFolder = ReplicatedStorage:WaitForChild("ShopEvent")
local buyPassEvent = shopEventFolder:WaitForChild("BuyPassEvent")
local shopUpdateEvent = shopEventFolder:WaitForChild("ShopUpdateEvent")
local buyPotionEvent = shopEventFolder:WaitForChild("BuyPotionEvent")
local usePotionEvent = shopEventFolder:WaitForChild("UsePotionEvent")

local trainerEvent = ReplicatedStorage:WaitForChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:WaitForChild("PlayerDataLoadedEvent")



local PASSES = ShopModule.Passes
local POTIONS = ShopModule.Potions

local function getPotionValue(player, potionId)
	local potions = player:FindFirstChild("Potions")
	if not potions then return nil end
	
	return potions:FindFirstChild(potionId)
end

local function getSRRobux(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return nil end
	
	return playerData:FindFirstChild("SrRobux")
end

local function syncRobloxGamepasses(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return end 
	
	local gamepasses = playerData:FindFirstChild("Gamepasses")
	if not gamepasses then return end
	
	for passId, passData in pairs(PASSES) do
		local gamePassId = passData.GamePassId
		if gamePassId and gamePassId ~= 0 then
			local passValue = gamepasses:FindFirstChild(passId)
			
			if passValue then
				local success, ownsPass = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
				end)
				
				if success and ownsPass then 
					passValue.Value = true
				end
			end
		end
	end
end

playerDataLoadedEvent.Event:Connect(function(player)
	syncRobloxGamepasses(player)
end)

buyPotionEvent.OnServerEvent:Connect(function(player, potionId, amount, payType)
	local potionData = POTIONS[potionId]
	if not potionData then return end
	
	local priceData = potionData.Prices[amount]
	if not priceData then return end
	
	local potionValue = getPotionValue(player, potionId)
	if not potionValue then return end
	
	if payType == "Robux" then
		local productId = potionData.Products and potionData.Products[amount]
		if not productId then return end
		
		MarketplaceService:PromptProductPurchase(player, productId)
		return
	end
	
	if payType == "SRRobux" then
		local srRobux = getSRRobux(player)
		if not srRobux then return end 
		
		if srRobux.Value < priceData.SRRobux then
			return
		end
		
		srRobux.Value -= priceData.SRRobux
		potionValue.Value += amount
		
		BetaPurchaseTracker.addPurchase(player, "Potions", potionId, amount)
	end
end)

usePotionEvent.OnServerEvent:Connect(function(player, potionId, amountMode)
	if player:GetAttribute("DataReady") ~= true then return end
	if typeof(potionId) ~= "string" then return end
	
	local potionData = POTIONS[potionId]
	if not potionData then return end
	
	local potionValue = getPotionValue(player, potionId)
	if not potionValue or not potionValue:IsA("IntValue") then return end
	
	local useAmount
	
	if amountMode == "Max" then
		useAmount = potionValue.Value
	elseif amountMode == 1 or amountMode == 5 then
		useAmount = amountMode
	else
		warn("INVALID POTION USE AMOUNT:", player.Name, tostring(amountMode))
		return
	end
	
	if useAmount <= 0 then return end 
	if potionValue.Value < useAmount then return end
	
	local activated = BoostModule.ActivatePersonalPotion(player, potionData.BoostType, useAmount)
	if not activated then return end
	
	potionValue.Value -= useAmount
end)

buyPassEvent.OnServerEvent:Connect(function(player, passId, payType)
	local passData = PASSES[passId]
	if not passData then return end
	
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return end
	
	local gamepasses = playerData:FindFirstChild("Gamepasses")
	if not gamepasses then return end
	
	local passValue = gamepasses:FindFirstChild(passId)
	if not passValue then return end
	
	if passValue.Value then
		shopUpdateEvent:FireClient(player, passId, false, "Owned")
		return
	end
	
	if payType == "Robux" then
		if not passData.GamePassId or passData.GamePassId == 0 then
			return
		end
		
		MarketplaceService:PromptGamePassPurchase(player, passData.GamePassId)
		return
	end
	
	if payType == "SRRobux" then
		local srRobux = playerData:FindFirstChild("SrRobux")
		if not srRobux then return end
		
		if srRobux.Value < passData.SRobuxPrice then
		    shopUpdateEvent:FireClient(player, passId, false, "Not Enough")
			return
		end
		
		srRobux.Value -= passData.SRobuxPrice
		passValue.Value = true

		shopUpdateEvent:FireClient(player, passId, true, "Owned")
		return
	end
	warn("INVALID PASS PAYMENT TYPE:", player.Name, passId, payType)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end
	
	for passId, passData in pairs(PASSES) do
		if passData.GamePassId == gamePassId then
			local playerData = player:FindFirstChild("PlayerData")
			if not playerData then return end
			
			local gamepasses = playerData:FindFirstChild("Gamepasses")
			if not gamepasses then return end
			
			local passValue = gamepasses:FindFirstChild(passId)
			if not passValue then return end
			
			passValue.Value = true
			
			shopUpdateEvent:FireClient(player, passId, true, "Owned")
			break
		end
	end
end)

local productToPotion = {}

for potionId, potionData in pairs(POTIONS) do 
	if potionData.Products then 
		for amount, productId in pairs(potionData.Products) do 
			productToPotion[productId] = { 
				PotionId = potionId,
				Amount = amount,
			}
		end
	end
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local purchaseId = tostring(receiptInfo.PurchaseId)

	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if player:GetAttribute("DataReady") ~= true then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productData = productToPotion[receiptInfo.ProductId]

	if not productData then
		warn(
			"UNKNOWN DEVELOPER PRODUCT:",
			receiptInfo.ProductId,
			purchaseId
		)

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Защищаем ProcessReceipt от ошибки внутри BindableFunction
	local invokeSuccess, grantSuccess, reason = pcall(function()
		return grantPotionPurchaseFunction:Invoke(
			player,
			purchaseId,
			productData.PotionId,
			productData.Amount
		)
	end)

	if not invokeSuccess then
		warn(
			"PURCHASE FUNCTION ERROR:",
			player.Name,
			purchaseId,
			tostring(grantSuccess)
		)

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if not grantSuccess then
		warn(
			"PURCHASE GRANT FAILED:",
			player.Name,
			purchaseId,
			tostring(reason)
		)

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Записываем покупку в BetaPurchaseTracker только при первой выдаче.
	-- При ALREADY_PROCESSED повторно статистику не увеличиваем.
	if reason == "PURCHASE_GRANTED" then
		local trackerSuccess, trackerResult = pcall(function()
			return BetaPurchaseTracker.addPurchase(
				player,
				"Potions",
				productData.PotionId,
				productData.Amount
			)
		end)

		if not trackerSuccess then
			warn(
				"BETA PURCHASE TRACKER ERROR:",
				player.Name,
				purchaseId,
				tostring(trackerResult)
			)
		elseif trackerResult ~= true then
			warn(
				"BETA PURCHASE TRACKER SAVE FAILED:",
				player.Name,
				purchaseId
			)
		end
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
