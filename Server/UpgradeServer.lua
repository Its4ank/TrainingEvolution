--// UpgradeServer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)

local upgradeEvents = ReplicatedStorage:WaitForChild("UpgradeEvents")
local upgradeEvent = upgradeEvents:WaitForChild("UpgradeEvent")

if upgradeEvent then 
	assert(upgradeEvent:IsA("RemoteEvent"), "ReplicatedStorage.UpgradeEvent должен быть RemoteEvent")
else
	upgradeEvent = Instance.new("RemoteEvent")
	upgradeEvent.Name = "UpgradeEvent"
	upgradeEvent.Parent = ReplicatedStorage
end

local purchaseLocks = {}

local LEGACY_UPGRADE_NAMES = {
	RebirthMultiplierMoney = "MoneyMultiplier",
}

local function sendResult(player, data)
	
	if not player or player.Parent ~= Players then
		return
	end
	
	upgradeEvent:FireClient(player, data)
end

local function sendFailure(player, code, extraData)
	local result = extraData or {}
	
	result.Success = false
	result.Code = code
	
	sendResult(player, result)
end

local function createdUpgradeValue(upgradeFolder, upgradeName, defaultLevel)
	local upgradeValue = Instance.new("IntValue")
	
	upgradeValue.Name = upgradeName
	upgradeValue.Value = defaultLevel or 0
	upgradeValue.Parent = upgradeFolder
	
	return upgradeValue
end

local function migrateLegacyUpgrades(upgradeFolder)
	for oldName, newName in pairs(LEGACY_UPGRADE_NAMES) do
		local oldValue = upgradeFolder:FindFirstChild(oldName)
		
		if oldValue and not oldValue:IsA("ValueBase") then 
			local config = UpgradeModule.GetConfig(newName)
			
			if config then 
				local migratedLevel = tonumber(oldValue.Value) or 0
				
				migratedLevel = math.clamp(math.floor(migratedLevel), 0, config.MaxLevel)
				
				local newValue = UpgradeModule:FindFirstChild(newName)
				
				if not newValue then
					createdUpgradeValue(upgradeFolder, newName, migratedLevel)
					print("UPGRADE MIGRATED:", oldName, "->", newName)
				elseif newValue:IsA("IntValue") and migratedLevel > newValue.Value then 
					newValue.Valuee = migratedLevel
					print("UPGRADE MIGRATED:", oldName, "->", newName)
				end
			end
		end
	end
end

local function ensureUpgradeValues(player)
	local upgradesFolder = player:FindFirstChild("Upgrades")
	
	if not upgradesFolder then 
		upgradesFolder = Instance.new("Folder")
		upgradesFolder.Name = "Upgrades"
		upgradesFolder.Parent = player
	end
	
	migrateLegacyUpgrades(upgradesFolder)
	
	for _, upgradeName in ipairs(UpgradeModule.GetUpgradeNames()) do
		local config = UpgradeModule.GetConfig(upgradeName)
		
		if config then 
			local upgradeValue = upgradesFolder:FindFirstChild(upgradeName)
			
			if not upgradeValue then
				upgradeValue = createdUpgradeValue(upgradesFolder, upgradeName, 0)
			elseif not upgradeValue:IsA("IntValue") then
				local oldLevel = tonumber(upgradeValue.Value) or 0
				
				oldLevel = math.clamp(math.floor(oldLevel), 0, config.MaxLevel)
				
				upgradeValue:Destroy()
				
				upgradeValue = createdUpgradeValue(upgradesFolder, upgradeName, oldLevel)
			else 
				upgradeValue.Value = math.clamp(math.floor(tonumber(upgradeValue.Value) or 0), 0, config.MaxLevel)
			end
		end
	end
	return upgradesFolder
end

local function getGemsValue(player)
	local playerData = player:FindFirstChild("PlayerData")
	
	if not playerData then 
		return nil
	end
	
	local gems = playerData:FindFirstChild("Gems")
	
	if not gems then 
		return nil
	end
	
	if not gems:IsA("IntValue") then 
		return nil
	end
	
	return gems
end

local function purchaseUpgrade(player, upgradeName)
	if type(upgradeName) ~= "string" then 
		sendFailure(player, "InvalidRequest")
		
		return
	end
	
	if player:GetAttribute("DataReady") ~= true then 
		sendFailure(player, "DataNotReady")
		
		return
	end
	
	local config = UpgradeModule.GetConfig(upgradeName)
	
	if not config then 
		sendFailure(player, "InvalidUpgrade", {
			UpgradeName = upgradeName,
		})
		return
	end
	
	local upgradesFolder = ensureUpgradeValues(player)
	local upgradeValue = upgradesFolder:FindFirstChild(upgradeName)
	
	if not upgradeValue or not upgradeValue:IsA("IntValue") then 
		sendFailure(player, "UpgradeValueMissing", {
			UpgradeName = upgradeName,
		})
		return
	end
	
	local currentLevel = math.clamp(math.floor(tonumber(upgradeValue.Value) or 0), 0, config.MaxLevel)
	
	if currentLevel >= config.MaxLevel then 
		sendFailure(player, "MaxLevel", {
			UpgradeName = upgradeName,
			CurrentLevel = currentLevel,
			MaxLevel = config.MaxLevel,
		})
		return
	end
	
	local targetLevel = currentLevel + 1
	local price = UpgradeModule.GetLevelPrice(upgradeName, targetLevel)
	
	if typeof(price) ~= "number" then  
		warn("UPGRADE PRICE ERROR:", upgradeName, "Level:", targetLevel, "Price in mil")
		
		sendFailure(player, "InvalidPrice", {
			UpgradeName = upgradeName,
			TargetLevel = targetLevel,
		})
		return
	end
	
	if price < 0 then
		warn("UPGRADE PRICE ERRPR:", upgradeName, "Level:", targetLevel, "Price:", price)
		
		sendFailure(player, "InvalidPrice", {
			UpgradeName = upgradeName,
			TargetLevel = targetLevel,
		})
		return
	end
	
	price = math.floor(price)
	
	local gems = getGemsValue(player)
	
	if not gems then 
		sendFailure(player, "CurrencyMissing", {
			UpgradeName = upgradeName,
		})
		return
	end
	
	if gems.Value < price then 
		sendFailure(player, "NotEnoughGems", {
			UpgradeName = upgradeName,
			
			CurrentLevel = currentLevel,
			TargetLevel = targetLevel,
			MaxLevel = config.MaxLevel,
			
			Price = price,
			CurrentGems = gems.Value,
			MissingGems = price - gems.Value,
		})
		return
	end
	
	gems.Value -= price
	upgradeValue.Value = targetLevel
	
	local nextPrice = UpgradeModule.GetNextLevelPrice(upgradeName, targetLevel)
	sendResult(player, {
		Success = true,
		Code = "Purchased",
		
		UpgradeName = upgradeName,
		
		OldLevel = currentLevel,
		NewLevel = targetLevel,
		MaxLevel = config.MaxLevel,
		
		PricePaid = price,
		CurrentGems = gems.Value,
		NextPrice = nextPrice,
		
		CurrentBonus = UpgradeModule.GetCurrentBonusText(upgradeName, targetLevel),
		NextBonus = UpgradeModule.GetNextBonusText(upgradeName, targetLevel),
	})
end

upgradeEvent.OnServerEvent:Connect(function(player, upgradeName)
	if purchaseLocks[player] then 
		sendFailure(player, "PurchaseBusy", {
			UpgradeName = upgradeName,
		})
		return
	end
	
	purchaseLocks[player] = true
	
	local success, errorMessage = xpcall(function()
		purchaseUpgrade(player, upgradeName)
	end, debug.traceback)
	
	purchaseLocks[player] = nil
	
	if not success then 
		warn("UPGRADE PURCHASE ERROR:", player.Name, errorMessage)
		
		sendFailure(player, "ServerError", {
			UpgradeName = upgradeName,
		})
	end
end)

local function setupPlayer(player)
	task.spawn(function()
		local upgradesFolder = player:WaitForChild("Upgrades", 15)
		
		if not upgradesFolder then 
			warn("Upgrades folder was not created for:", player.Name)
			return
		end
		
		ensureUpgradeValues(player)
	end)
	
	player:GetAttributeChangedSignal("DataReady"):Connect(function()
		if player:GetAttribute("DataReady") == true then 
			ensureUpgradeValues(player)
		end
	end)
	
	if player:GetAttribute("DataReady") == true then
		ensureUpgradeValues(player)
	end
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
	purchaseLocks[player] = nil
end)

local configValid = UpgradeModule.ValidateConfig()

if configValid then 
	print("UPGRADE SERVER LOADED: configuration is valid")
else 
	warn("UPGRADE SERVER LOADED: configuraton has errors")
end

print("UpgradeServer loaded")
