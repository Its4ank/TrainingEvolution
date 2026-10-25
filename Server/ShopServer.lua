--ShopServer 1.3v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

--// Modules
local ShopModule = require(ReplicatedStorage.Modules.ShopModule)
local BoostModule = require(ServerScriptService.Modules.BoostModule)
local BetaPurchaseTracker = require(ServerScriptService.Modules.BetaPurchaseTracker)

--// Remotes
local shopEvent = ReplicatedStorage:WaitForChild("ShopEvent")
local buyPassEvent = shopEvent:WaitForChild("BuyPassEvent")
local shopUpdateEvent = shopEvent:WaitForChild("ShopUpdateEvent")
local buyPotionEvent = shopEvent:WaitForChild("BuyPotionEvent")
local usePotionEvent = shopEvent:WaitForChild("UsePotionEvent")
local equipPassEvent = shopEvent:WaitForChild("EquipPassEvent")

local dataLoadedEvent = ReplicatedStorage:WaitForChild("TrainerEvent"):WaitForChild("PlayerDataLoadedEvent")
local grantPotionPurchase = ServerScriptService:WaitForChild("GrantPotionPurchaseFunction")
local grantPassPurchase = ServerScriptService:WaitForChild("GrantPassPurchaseFunction")
local grantSRPotionPurchase = ServerScriptService:WaitForChild("GrantSRPotionPurchaseFunction")

local busy = {}

local function report(player, itemId, success, code)
	if player.Parent == Players then
		shopUpdateEvent:FireClient(player, itemId, success, code)
	end
end

local function getPlayerData(player)
	if player:GetAttribute("DataReqdy") ~= true then return nil end
	local data = player:FindFirstChild("PlayerData")
	if not data or not data:IsA("Folder") then return nil end
	return data 
end

local function getPassValues(player, passId)
	local data = getPlayerData(player)
	local ownedFolder = data and data:FindFirstChild("Gamepasses")
	local equippedFolder = data and data:FindFirstChild("EquippedGamepasses")
	local owned = ownedFolder and ownedFolder:FindFirstChild(passId)
	local equipped = equippedFolder and equippedFolder:FindFirstChild(passId)
	
	if not owned or not owned:IsA("BoolValue") then return nil, nil end
	if not equipped or not equipped:IsA("BoolValue") then return nil, nil end
	
	return owned, equipped
end

local function getPotionValue(player, potionId)
	local folder = player:FindFirstChild("Potions")
	local value = folder and folder:FindFirstChild(potionId)
	
	return value and value:IsA("IntValue") and value or nil
end

local function getCurrency(player)
	local data = getPlayerData(player)
	local value = data and data:FindFirstChild("SrRobux")
	
	return value and value:IsA("IntValue") and value or nil
end

local function ensurePassValues(player)
	local data = getPlayerData(player)
	if not data then return false end
	
	local ownedFolder = data:FindFirstChild("Gamepasses")
	if not ownedFolder then
		ownedFolder = Instance.new("Folder")
		ownedFolder.Name = "Gamepasses"
		ownedFolder.Parent = data
	end
	
	local equippedFolder = data:FindFirstChild("EquippedGamepasses")
	if not equippedFolder then
		equippedFolder = Instance.new("Folder")
		equippedFolder.Name = "EquippedGamepasses"
		equippedFolder.Parent = data
	end
	
	for _, passId in ipairs(ShopModule.PassOwned) do
		if not ownedFolder:FindFirstChild(passId) then
			local value = Instance.new("BoolValue")
			value.Name = passId
			value.Value = false
			value.Parent = ownedFolder
		end
		
		if not equippedFolder:FindFirstChild(passId) then
			local value = Instance.new("BoolValue")
			value.Name = passId
			value.Value = true
			value.Parent = equippedFolder 
		end
	end
	return true
end

local function syncRobloxPasses(player)
	if not ensurePassValues(player) then return end
	
	for _, passId in ipairs(ShopModule.PassOrder) do
		local data = ShopModule.GetPass(passId)
		if type(data.GamePassId) == "number" and data.GamePassId > 0 then
			local ok, owns = pcall(MarketplaceService.UseOwnsGamePassAsync, MarketplaceService, player.UserId, data.GamePassId)
			if ok and owns and player.Parent == Players then
				local owned = getPassValues(player, passId)
				if owned then
					owned.Value = true
					report(player, passId, true, "SYNC")
				end
			elseif not ok then
				warn("Shop pass sync failed:", player.Name, passId, owns)
			end
		end
	end
end

dataLoadedEvent.Event:Connect(function(player)
	task.spawn(syncRobloxPasses, player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player:GetAttribute("DataReady") == true then
		task.spawn(syncRobloxPasses, player)
	end
end

local function lockPlayer(player, itemId)
	if busy[player] then
		report(player, itemId, false, "BUSY")
		return false
	end
	
	busy[player] = true
	return true
end

local function unlockPlayer(player)
	busy[player] = nil
end

Players.PlayerRemoving:Connect(unlockPlayer)

local function processPassPurchase(player, passId, currency)
	if typeof(passId) ~= "string" or not ShopModule.GetPass(passId) then
		report(player, passId, false, "UNKNOWN_PASS")
		return
	end
	
	if currency ~= "Roblox" and currency ~= "SRRobux" then
		report(player, passId, false, "INVALID_CURRENCY")
		return 
	end
	
	if not ensurePassValues(player) then
		report(player, passId, false, "DATA_NOT_READY")
		return
	end
	
	if not ShopModule.IsPassConfigured(passId) then
		report(player, passId, false, "NOT_CONFIGURED")
		return
	end
	
	local owned, equipped = getPassValues(player, passId)
	if not owned then
		report(player, passId, false, "PASS_DATA_MISSING")
		return
	end
	
	if owned.Value then
		report(player, passId, false, "ALREADY_OWNED")
		return
	end
	
	local passData = ShopModule.GetPass(passId)
	local ok, robloxOwns = pcall(MarketplaceService.UseOwnsGamePassAsync, MarketplaceService, player.UserId, passData.GamePassId)
	if not ok then
		report(player, passId, false, "OWNERSHIP_CHECK_FAILED")
		return
	end
	
	if robloxOwns then
		owned.Value = true
		equipped.Value = true
		report(player, passId, true, "ALREADY_OWNED")
		return
	end
	
	if currency == "Roblox" then
		local prompted, promptError = pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, player, passData.GamePassId)
		if not prompted then
			warn("Pass prompt failed:", player.Name, passId, promptError)
			report(player, passId, false, "PROMPT_FAILED")
		else 
			report(player, passId, true, "PROMPT_OPENED")
		end
		return
	end
	
	local balance = getCurrency(player)
	if not balance then
		report(player, passId, false, "BALANCE_MISSING")
		return
	end
	
	local price = ShopModule.GetPassPrice(passId, "SRRobux")
	if balance.Value < price then
		report(player, passId, false, "NOT_ENOUGH_SRROBUX")
		return
	end
	
	local invoked, granted, reason = pcall(grantPassPurchase.Invoke, grantPassPurchase, player, passId)
	if not invoked then
		warn("Pass grant failed:", player.Name, passId, granted)
		report(player, passId, false, "PURCHASE_FAILED")
	elseif not granted then
		report(player, passId, false, reason or "PURCHASE_FAILED")
	else 
		report(player, passId, true, "PURCHASE_GRANTED")
	end
end

buyPassEvent.OnServerEvent:Connect(function(player, passId, currency)
	if not lockPlayer(player, passId) then return end
	local ok, err = pcall(processPassPurchase, player, passId, currency)
	
	unlockPlayer(player)
	
	if not ok then
		warn("Pass request crached:", player.Name, err)
		report(player, passId, false, "PURCHASE_FAILED")
	end
end)

equipPassEvent.OnServerEvent:Connect(function(player, passId, shouldEquip)
	if typeof(passId) ~= "string" or typeof(shouldEquip) ~= "boolean" then
		report(player, passId, false, "INVALID_REQUEST")
		return
	end
	
	if not lockPlayer(player, passId) then return end
	local ok, err = pcall(function()
		if not ShopModule.GetPass(passId) then
			report(player, passId, false, "UNKNOWN_PASS")
			return
		end
		
		local owned, equipped = getPassValues(player, passId)
		if not owned or not equipped then
			report(player, passId, false, "DATA_NOT_READY")
			return
		end
		
		if not owned.Value then
			report(player, passId, false, "NOT_OWNED")
			return
		end
		
		equipped.Value = shouldEquip
		report(player, passId, true, shouldEquip and "EQUIPPED" or "UNEQUIPPED")
	end)
	
	unlockPlayer(player)
	if not ok then
		warn("Pass equip failed:", player.Name, passId, err)
		report(player, passId, false, "EQUIP_FAILED")
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end
	for _, passId in ipairs(ShopModule.PassOrder) do
		local data = ShopModule.GetPass(passId)
		if data.GamePassId == gamePassId then
			if not ensurePassValues(player) then
				report(player, passId, false, "DATA_NOT_READY")
				return
			end
			
			local owned, equipped = getPassValues(player, passId)
			if not owned then
				report(player, passId, false, "PASS_DATA_MISSING")
				return
			end
			
			if not owned.Value then
				owned.Value = true
				equipped.Value = true
			end
			
			report(player, passId, true, "PURCHASE_GRANTED")
			return
		end
	end
end)

local function processPotionPurchase(player, potionId, amount, currency)
	if typeof(potionId) ~= "string" or not ShopModule.Potions[potionId] then
		report(player, potionId, false, "UNKNOWN_POTION")
		return
	end
	
	if amount ~= 1 and amount ~= 5 and amount ~= 10 then
		report(player, potionId, false, "INVALID_AMOUNT")
		return
	end
	
	local price = ShopModule.GetPotionPrice(potionId, amount, currency)
	if not price then
		report(player, potionId, false, "DATA_NOT_READY")
		return
	end
	
	local potion = getPotionValue(player, potionId)
	if not potion then
		report(player, potionId, false, "POTION_DATA_MISSING")
		return
	end
	
	if currency == "Robux" then
		local productId = ShopModule.Potions[potionId].Products[amount]
		if not productId then
			report(player, potionId, false, "NOT_CONFIGURED")
			return
		end
		
		local ok, err = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, productId)
		if not ok then
			warn("Potion prompt failed:", player.Name, potionId, err)
			report(player, potionId, false, "PROMPT_FAILED")
		else 
			report(player, potionId, true, "PROMPT_OPENED")
			return
		end
		
		local balance = getCurrency(player)
		if not balance then
			report(player, potionId, false, "BALANCE_MISSING")
			return
		end
		
		if balance.Value < price then
			report(player, potionId, false, "NOT_ENOUGH_SRROBUX")
			return
		end
		
		local invoked, granted, reason = pcall(grantSRPotionPurchase.Invoke, grantSRPotionPurchase, player, potionId, amount)
		if not invoked then
			warn("Potion grant failed:", player.Name, potionId, granted)
			report(player, potionId, false, "PURCHASE_FAILED")
			return
		end
		
		if not granted then
			report(player, potionId, false, reason or "PURCHASE_FAILED")
			return
		end
		
		local tracked, trackingError = pcall(BetaPurchaseTracker.addPurchase, player, "Potions", potionId, amount)
		warn("Potion tracker failed:", player.Name, potionId, trackingError)
	end
	report(player, potionId, true, "PURCHASE_GRANTED")
end

buyPotionEvent.OnServerEvent:Connect(function(player, potionId, amount, currency)
	if not lockPlayer(player, potionId) then return end
	local ok, err = pcall(processPotionPurchase, player, potionId, amount, currency)
	
	unlockPlayer(player)
	
	if not ok then
		warn("Potion request crashed:", player.Name, err)
		report(player, potionId, false, "PURCHASE_FAILED")
	end
end)

usePotionEvent.OnServerEvent:Connect(function(player, potionId, amountMode)
	if typeof(potionId) ~= "string" or not ShopModule.Potions[potionId] then
		report(player, potionId, false, "UNKNOWN_POTION")
		return
	end
	
	if not lockPlayer(player, potionId) then return end
	local ok, err = pcall(function()
		if not ensurePassValues(player) then
			report(player, potionId, false, "DATA_NOT_READY")
			return
		end
		
		local potion = getPotionValue(player, potionId)
		if not potion then
			report(player, potionId, false, "POTION_DATA_MISSING")
			return
		end
		
		local amount = amountMode == "Max" and potion.Value or amountMode
		if amountMode ~= "Max" and amountMode ~= 1 and amountMode ~= 5 then
			report(player, potionId, false, "INVALID_AMOUNT")
			return
		end
		
		if amount <= 0 or potion.Value < amount then
			report(player, potionId, false, "NOT_ENOUGH_POTIONS")
			return
		end
		
		local activated = BoostModule.ActivatePersonalPotion(player, ShopModule.Potions[potionId].BoostType, amount)
		if not activated then
			report(player, potionId, false, "POTION_USE_FAILED")
			return
		end
		
		potion.Value -= amount 
		report(player, potionId, true, "POTION_USED")
	end)
	
	unlockPlayer(player)
	
	if not ok then
		warn("Potion use crashed:", player.Name, potionId, err)
		report(player, potionId, false, "POTION_USE_FAILED")
	end
end)

local productToPotion = {}

for potionId, potionData in pairs(ShopModule.Potions) do
	for amount, productId in pairs(potionData.Products) do
		productToPotion[productId] = {Potion = potionId, Amount = amount}
	end
end

MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player or player:GetAttribute("DataReady") ~= true then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local product = productToPotion[receipt.ProductId]
	if not product then
		warn("Unknown developer product:", receipt.ProductId, receipt.PurchaseId)
		return Enum.ProductPurchaseDecision.NotProcessedYet 
	end
	
	local ok, granted, reason = pcall(grantPotionPurchase.Invoke, grantPotionPurchase, player, tostring(receipt.PurchaseId), product.PotionId, product.Amount)
	if not ok or not granted then
		warn("Potion receipt grant failed:", player.Name, receipt.PurchaseId, ok and reason or granted)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	if reason == "PURCHASE_GRANTED" then
		local tracked, trackingResult = pcall(BetaPurchaseTracker.addPurchase, player, "Potion", product.PotionId, product.Amount)
		if not tracked or trackingResult ~= true then
			warn("Potion tracker failed:", player.Name, receipt.PurchaseId)
		end
	end
	report(player, product.PotionId, true, "PURCHASE_GRANTED")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
