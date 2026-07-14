--// RebirthServer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RebirthModule = require(game.ReplicatedStorage.Modules.RebirthModule)
local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)

--// RemoteEvents 
local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
local performRebirthEvent = rebirthEvent:WaitForChild("PerformRebirthEvent")
local autoRebirthEvent = rebirthEvent:WaitForChild("AutoRebirthEvent")

local autoRebirthPlayers = {}

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

local function doRebirth(player, amount)
	if typeof(amount) ~= "number" then return false end 
	amount = math.floor(amount)
	
	if amount <= 0 then return false end 
	
	local energy = getEnergy(player)
	local rebirth = getRebirth(player)
	
	if not energy or not rebirth then return false end 
	
	local cost = RebirthModule.GetRebirthCost(rebirth.Value, amount)
	
	if energy.Value < cost then 
		return false
	end
	
	energy.Value = 0
	rebirth.Value += amount
	
	print(player.Name .. " rebirth +" .. amount)
	print("Total Rebirth:", rebirth.Value)
	
	return true
end

performRebirthEvent.OnServerEvent:Connect(function(player, amount)
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
	
	local validButtons = { 
		[1] = true,
		[5] = true,
		[25] = true,
		[75] = true,
		[150] = true,
		[250] = true,
		[500] = true,
	}
	
	if not validButtons[amount] then 
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
				doRebirth(player, amount)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	autoRebirthPlayers[player] = nil
end)

print("RebirthServer loaded")
