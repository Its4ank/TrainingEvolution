--// RebirthServer 1.2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RebirthModule = require(game.ReplicatedStorage.Modules.RebirthModule)
local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)
local UpgradeModule = require(game.ReplicatedStorage.Modules.UpgradeModule)

--// RemoteEvents 
local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
local performRebirthEvent = rebirthEvent:WaitForChild("PerformRebirthEvent")
local autoRebirthEvent = rebirthEvent:WaitForChild("AutoRebirthEvent")

local autoRebirthPlayers = {}
local lastRebirthRequest = {}
local REBIRTH_REQUEST_COOLDOWN = 0.1

local function getEnergy(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return nil end
	
	return leaderstats:FindFirstChild("Energy")
end

local function getRebirth(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return nil end
	
	return leaderstats:FindFirstChild("Rebirth")
end

local function getRebirthButtonNameFromAmount(amount)
	amount = tonumber(amount)
	
	if not amount then
		return nil
	end
	
	amount = math.floor(amount)
	
	for buttonName, buttonAmount in pairs(RebirthModule.Buttons) do
		if buttonAmount == amount then
			return buttonName
		end
	end
	return nil
end

local function isRebirthAmountUnlocked(player, amount)
	local buttonName = getRebirthButtonNameFromAmount(amount)
	
	if not buttonName then
		return false
	end
	
	return UpgradeModule.IsRebirthButtonUnlocked(player, buttonName)
end

local function canProcessRebirthRequest(player)
	local now = os.clock()
	
	local lastRequest = lastRebirthRequest[player] or 0
	
	if now - lastRequest < REBIRTH_REQUEST_COOLDOWN then
		return false
	end
	
	lastRebirthRequest[player] = now
	return true
end

local function doRebirth(player, amount)
	if typeof(amount) ~= "number" then
		return false
	end 
	
	amount = math.floor(amount)
	
	if amount <= 0 then return false end 
	
	if amount > RebirthModule.MaxRebirthPerOperation then
		return false
	end
	
	local energy = getEnergy(player)
	local rebirth = getRebirth(player)
	
	if not energy or not rebirth then return false end 
	
	if energy.Value < 0 or rebirth.Value < 0 then
		return false
	end
	
	local cost = RebirthModule.GetRebirthCost(rebirth.Value, amount)
	
	if cost <= 0 then
		return false
	end
	
	if energy.Value < cost then 
		return false
	end
	
	energy.Value = 0
	rebirth.Value += amount
	
	return true
end

performRebirthEvent.OnServerEvent:Connect(function(player, amount)
	if not canProcessRebirthRequest(player) then
		return
	end
	
	if amount == "Max" then 
		if not ShopModule.HasMaxRebirth(player) then
			return
		end
		
		local energy = getEnergy(player)
		local rebirth = getRebirth(player)
		if not energy or not rebirth then return end 
		
		local maxAmount = RebirthModule.GetMaxRebirthAmount(rebirth.Value, energy.Value)
		if maxAmount <= 0 then return end 
		
		doRebirth(player, maxAmount)
		return
	end
	
	if not isRebirthAmountUnlocked(player, amount) then
		warn("LOCKED REBIRTH BUTTON REQUEST:", player.Name, amount)
		return
	end
	
	
	doRebirth(player, amount)
end)

autoRebirthEvent.OnServerEvent:Connect(function(player, enabled, amount)
	if enabled ~= true then
		autoRebirthPlayers[player] = nil
		return
	end
	
	if not ShopModule.HasAutoRebirth(player) then 
		return
	end
	
	if amount == "Max" then 
		if not ShopModule.HasMaxRebirth(player) then 
			return
		end
		
		autoRebirthPlayers[player] = "Max"
		return
	end
	
	if typeof(amount) ~= "number" then
		return
	end

	amount = math.floor(amount)

	if amount <= 0 then
		return
	end
	
	if not isRebirthAmountUnlocked(player,amount) then
		warn("LOCKED AUTO REBIRTH REQUEST:", player.Name, amount)
		return
	end
	
	autoRebirthPlayers[player] = amount
end)

task.spawn(function()
	while true do 
		task.wait(0.5)
		
		for player, amount in pairs(autoRebirthPlayers) do 
			if not player.Parent then 
				autoRebirthPlayers[player] = nil 
				continue
			end
			
			if amount == "Max" then 
				local energy = getEnergy(player)
				local rebirth = getRebirth(player)
				
				if energy and rebirth then 
					local maxAmount = RebirthModule.GetMaxRebirthAmount(rebirth.Value, energy.Value)

					if maxAmount > 0 then 
						doRebirth(player, maxAmount)
					end
				end
			else 
				if isRebirthAmountUnlocked(player, amount) then
					doRebirth(player, amount)
				else 
					autoRebirthPlayers[player] = nil
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	autoRebirthPlayers[player] = nil
	lastRebirthRequest[player] = nil
end)

print("RebirthServer loaded")
