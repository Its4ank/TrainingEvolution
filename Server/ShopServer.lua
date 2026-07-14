local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)
local BetaPurchaseTracker = require(game.ServerScriptService.Modules.BetaPurchaseTracker)



--//RemoteEvents
local shopEventFolder = ReplicatedStorage:WaitForChild("ShopEvent")
local buyPassEvent = shopEventFolder:WaitForChild("BuyPassEvent")
local shopUpdateEvent = shopEventFolder:WaitForChild("ShopUpdateEvent")
local buyRobuxPassEvent = shopEventFolder:WaitForChild("BuyRobuxPassEvent")
local buyPotionEvent = shopEventFolder:WaitForChild("BuyPotionEvent")
local usePotionEvent = shopEventFolder:WaitForChild("UsePotionEvent")

local trainerEvent = ReplicatedStorage:WaitForChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:WaitForChild("PlayerDataLoadedEvent")



local PASSES = ShopModule.Passes

local PASS_PRODUCTS = {
	EnergyPass = 0000000000
}

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
	local potionData = POTIONS[potionId]
	if not potionData then return end
	
	local potionValue = getPotionValue(player, potionId)
	if not potionValue then return end
	
	local useAmount = 0
	
	if amountMode == "Max" then
		useAmount = potionValue.Value
	else
		useAmount = tonumber(amountMode) or 0
	end
	
	if useAmount <= 0 then return end 
	if potionValue.Value < useAmount then return end
	
	potionValue.Value -= useAmount
	
	for i = 1, useAmount do 
		BoostModule.ActivatePersonalPotion(player, potionData.BoostType)
	end
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
	
	local srRobux = playerData:FindFirstChild("SrRobux")
	if not srRobux then return end
	
	if srRobux.Value < passData.SRobuxPrice then
		shopUpdateEvent:FireClient(player, passId, false, "Not Enough")
		return
	end
	
	srRobux.Value -= passData.SRobuxPrice
	passValue.Value = true
	
	shopUpdateEvent:FireClient(player, passId, true, "Owned")
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

buyRobuxPassEvent.OnServerEvent:Connect(function(player, passId)
	local productId = PASS_PRODUCTS[passId]
	if not productId then return end
	
	MarketplaceService:PromptProductPurchase(
		player,
		productId
	)
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
	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then 
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local productData = productToPotion[receiptInfo.ProductId]
	if not productData then 
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local potionValue = getPotionValue(player, productData.PotionId)
	if not potionValue then 
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	potionValue.Value += productData.Amount
	
	BetaPurchaseTracker.addPurchase(player, "Potions", productData.PotionId, productData.Amount)
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
