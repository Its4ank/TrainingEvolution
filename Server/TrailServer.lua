--// TrailServer 1.2v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TrailModule = require(ReplicatedStorage.Modules.TrailModule)
local XPModule = require(ServerScriptService.Modules.XPModule)

--// REMOTES
local trailEventFolder = ReplicatedStorage:WaitForChild("TrailEvent")
local trailRequestFunction = trailEventFolder:WaitForChild("TrailRequestFunction")

--// CONSTANTS
local DEFAULT_LEVEL = 0
local DEFAULT_STAGE = 1

local playerRequestLocks = {}

--// GEMERIC HELPERS
local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	
	if folder and not folder:IsA("Folder") then
		warn("TrailServer:", parent:GetFullName(), "уже содержит обьект", name, "не являющийся Folder")
		return nil
	end
	
	if not folder then 
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateValue(parent, className, name, defaultValue)
	local valueObject = parent:FindFirstChild(name)
	
	if valueObject and not valueObject:IsA(className) then
		warn("TrailServer:", valueObject:GetFullName(), "имеет неправильный ClassName")
		return nil
	end
	
	if not valueObject then 
		valueObject = Instance.new(className)
		valueObject.Name = name
		valueObject.Value = defaultValue
		valueObject.Parent = parent
	end
	return valueObject
end

local function makeResponse(success, message, data)
	return {
		success = success == true,
		message = message or "",
		data = data,
	}
end

local function isValidTrailId(trailId)
	if type(trailId) ~= "string" then
		return false
	end
	
	local config = TrailModule.GetTrailConfig(trailId)
	
	return config ~= nil and config.Enabled == true
end

--// PLAYER DATA SETUP
local function setupTrailData(player)
	local trailsFolder = getOrCreateFolder(player, "Trails")
	
	if not trailsFolder then
		return nil
	end
	
	local equippedTrail = getOrCreateValue(trailsFolder, "StringValue", "EquippedTrail", "")
	
	for trailId, config in pairs(TrailModule.Trails) do
		if config.Enabled then 
			local trailFolder = getOrCreateFolder(trailsFolder, trailId)
			if trailFolder then
				getOrCreateValue(trailFolder, "BoolVlue", "Owned", false)
				getOrCreateValue(trailFolder, "IntValue", "Level", DEFAULT_LEVEL)
				getOrCreateValue(trailFolder, "IntValue", "Stage", DEFAULT_STAGE)
			end
		end
	end
	return {
		Folder = trailsFolder,
		EquippedTrail = equippedTrail,
	}
end

local function getTrailDataObject(player, trailId)
	if not isValidTrailId(trailId) then
		return nil
	end
	
	local trailsFolder = player:FindFirstChild("Trails")
	
	if not trailsFolder then
		return nil
	end
	
	local trailFolder = trailsFolder:FindFirstChild(trailId)
	local equippedTrail = trailsFolder:FindFirstChild("EquippedTrail")
	
	if not trailFolder or not trailFolder:IsA("Folder") then
		return nil
	end
	
	local owned = trailFolder:FindFirstChild("Owned")
	local level = trailFolder:FindFirstChild("Level")
	local stage = trailFolder:FindFirstChild("Stage")
	
	if not owned or not owned:IsA("BoolValue") then
		return nil
	end
	
	if not level or not level:IsA("IntValue") then
		return nil
	end
	
	if not stage or not stage:IsA("IntValue") then
		return nil
	end
	
	if not equippedTrail or not equippedTrail:IsA("StringValue") then
		return nil
	end
	
	return {
		TrailsFolder = trailsFolder,
		TrailFolder = trailFolder,
		
		Owned = owned,
		Level = level,
		Stage = stage,
		
		EquippedTrail = equippedTrail,
	}
end

local function getPlayerResources(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local playerData = player:FindFirstChild("PlayerData")
	
	if not leaderstats or not playerData then
		return nil
	end
	
	local money = playerData:FindFirstChild("Money")
	local rebirth = leaderstats:FindFirstChild("Rebirth")
	
	if not money or not money:IsA("IntValue") then
		return nil
	end
	
	if not rebirth or not rebirth:IsA("IntValue") then
		return nil
	end
	
	return {
		Money = money,
		Rebirth = rebirth,
	}
end

--// AVAILABILITY
local function isTrailAvailableForPlayer(player, trailId)
	local config = TrailModule.GetTrailConfig(trailId)
	
	if not config or not config.Enabled then
		return false, "Этот трейл недоступен"
	end
	
	--сюда проверку новіх локаций
	
	return true, ""
end

--// SNAPSHOT FOR CLIENT
local function buildTrailSnapshot(player, trailId)
	local config = TrailModule.GetTrailConfig(trailId)
	local object = getTrailDataObject(player, trailId)
	local resources = getPlayerResources(player)
	
	if not config or not object or not resources then 
		return nil
	end
	
	local owned = object.Owned.Value
	local level = object.Level.Value
	local stage = object.Stage.Value
	
	local boostData = TrailModule.GetBoostData(trailId, level, stage)
	
	local purchaseData = {
		Currency = config.Purchase.Currency,
		Price = config.Purchase.Price,
	}
	
	local upgradeCost = nil
	
	if owned then
		upgradeCost = TrailModule.GetLevelUpgradeCost(trailId, level)
	end
	
	local stageRequirements = TrailModule.GetStageRequirements(trailId, stage)
	
	local stageProgress = nil
	
	if stageRequirements then 
		stageProgress = TrailModule.GetStageProgress(trailId, stage, level, resources.Money.Value, resources.Rebirth.Value)
	end
	
	local available, unavailableReason = isTrailAvailableForPlayer(player, trailId)
	
	return {
		TrailId = trailId,
		
		DisplayName = config.DisplayName,
		Description = config.Description,
		Icon = config.Icon,
		
		Order = config.Order,
		Era = config.Era,
		Location = config.Location,
		
		Available = available,
		UnavailableReason = unavailableReason,
		
		Owned = owned,
		Equipped = object.EquippedTrail.Value == trailId,
		
		Level = level,
		MaxLevel = TrailModule.MAX_LEVEL,
		
		Stage = stage,
		StageName = TrailModule.GetStageName(stage),
		StageIcon = TrailModule.GetStageIcon(stage),
		StageMaxLevel = TrailModule.GetStageMaxLevel(stage),
		IsMaxStage = TrailModule.IsMaxStage(stage),
		CanLevelUpAtStage = TrailModule.CanLevelUpAtStage(level, stage),
		
		Purchase = purchaseData,
		UpgradeCost = upgradeCost,
		
		Boosts = boostData,
		
		StageRequirements = stageRequirements,
		StageProgress = stageProgress,
		
		PlayerResources = {
			Money = resources.Money.Value,
			Rebirth = resources.Rebirth.Value,
			XP = XPModule.getXP(player),
		},
	}
end

local function buildAllTrailsSnapshot(player)
	local trails = {}
	
	for trailId, config in pairs(TrailModule.Trails) do
		if config.Enabled then
			trails[trailId] = buildTrailSnapshot(player, trailId)
		end
	end
	
	local trailsFolder = player:FindFirstChild("Trails")
	local equippedTrail = ""
	
	if trailsFolder then
		local equippedValue = trailsFolder:FindFirstChild("EquippedTrail")
		
		if equippedValue and equippedValue:IsA("StringValue") then
			equippedTrail = equippedValue.Value
		end
	end
	
	return {
		Trails = trails,
		EquippedTrail = equippedTrail,
		DefaultTrailId = TrailModule.DEFAULT_TRAIL_ID,
	}
end

--// PURCHASE
local function purchaseTrail(player, trailId)
	local config = TrailModule.GetTrailConfig(trailId)
	local object = getTrailDataObject(player, trailId)
	local resources = getPlayerResources(player)
	
	if not config or not object or not resources then
		return makeResponse(false, "Не удалось данным трейла")
	end
	
	if object.Owned.Value then
		return makeResponse(false, "Этот трейл уже куплен", buildTrailSnapshot(player, trailId))
	end
	
	local available, unavailableReason = isTrailAvailableForPlayer(player, trailId)
	
	if not available then
		return makeResponse(false, unavailableReason, buildTrailSnapshot(player, trailId))
	end
	
	local purchaseConfig = config.Purchase
	
	if not purchaseConfig then 
		return makeResponse(false, "Для трейла не указана стоимость покупки")
	end
	
	local currencyName = purchaseConfig.CurrentName
	local price = math.max(math.floor(tonumber(purchaseConfig.Price) or 0), 0)
	
	if currencyName ~= "Money" then
		return makeResponse(false, "Неизвестная валюта покупки: " .. tostring(currencyName))
	end
	
	if resources.Money.Value < price then
		return makeResponse(false, "Недостаточно денег", buildTrailSnapshot(player, trailId))
	end
	
	resurces.Money.Value -= price
	object.Owned.Value = true
	
	return makeResponse(true, "Трейл успешно куплен", buildTrailSnapshot(player, trailId))
end

--// LEVEL UPGRADE
local function upgradeTrail(player, trailId)
	local object = getTrailDataObject(player, trailId)
	local resources = getPlayerResources(player)
	
	if not object or not resources then
		return makeResponse(false, "Не удалось получить данные трейла")
	end
	
	if not object.Owned.Value then
		return makeResponse(false, "Сначала купите этот трейл", buildTrailSnapshot(player, trailId))
	end
	
	local currentLevel = object.Level.Value
	local currentStage = object.Stage.Value
	
	if currentLevel >= TrailModule.MAX_LEVEL then
		return makeResponse(false, "Достигнут максимальный уровень трейла", buildTrailSnapshot(player, trailId))
	end
	
	if not TrailModule.CanLevelUpAtStage(currentLevel, currentStage) then
		return makeResponse(false, "Необходимо повысить стадию для открытия следующий уровень", buildTrailSnapshot(player, trailId))
	end
	
	local cost = TrailModule.GetLevelUpgradeCost(trailId, currentLevel)
	
	if not cost then
		return makeResponse(false, "Не удалось определить стоимости улучшения")
	end
	
	if resources.Money.Value < cost.Money then
		return makeResponse(false, "Недостаточно денег", buildTrailSnapshot(player, trailId))
	end
	
	if not XPModule.hasXP(player, cost.XP) then
		return makeResponse(false, "Недостаточно опыта", buildTrailSnapshot(player, trailId))
	end
	
	resurces.Money.Value -= cost.Money
	
	local xpRemoved = XPModule.removeXP(player, cost.XP)
	
	if not xpRemoved then
		resources.Money.Value += cost.Money
		
		return makeResponse(false, "Не удалось списать опыт", buildTrailSnapshot(player, trailId))
	end
	
	object.Level.Value = cost.TragetLevel
	
	return makeResponse(true, "Уровень списать опыт", buildTrailSnapshot(player, trailId))
end

--// EQUIP / UNEQUIP
local function toggleTrailEquip(player, trailId)
	local object = getTrailDataObject(player, trailId)
	
	if not object then
		return makeResponse(false, "Не удалось получить данные трейла")
	end
	
	if not object.Owned.Value then
		return makeResponse(false, "Сначала купите этот трейл", buildTrailSnapshot(player, trailId))
	end
	
	if object.EquippedTrail.Value == trailId then
		object.EquippedTrail.Value = ""
		
		return makeResponse(true, "Трейл снят", buildTrailSnapshot(player, trailId))
	end
	
	object.EquippedTrail.Value = trailId
	
	return makeResponse(true, "Трейл надет", buildTrailSnapshot(player, trailId))
end

--// STAGE UP
local function stageUpTrail(player, trailId)
	local object = getTrailDataObject(player, trailId)
	local resources = getPlayerResources(player)
	
	if not object or not resources then
		return makeResponse(false, "Не удалось получить данные трейла")
	end
	
	if not object.Owned.Value then
		return makeResponse(false, "Сначала купите этот трейл", buildTrailSnapshot(player, trailId))
	end
	
	local currentStage = object.Stage.Value
	local currentLevel = object.Level.Value
	
	if TrailModule.IsMaxStage(currentStage) then
		return makeResponse(false, "Достигнута максимальная стадия трейла", buildTrailSnapshot(player, trailId))
	end
	
	local requirements = TrailModule.GetStageRequirements(trailId, currentStage)
	
	if not requirements then
		return makeResponse(false, "Не удалось получить требования стадии")
	end
	
	local requiredLevel = math.max(requirements.Level or 0, 0)
	local requiredMoney = math.max(requirements.Money or 0, 0)
	local requiredRebirth = math.max(requirements.Rebirth or 0, 0)
	
	if currentLevel < requiredLevel then
		return makeResponse(false, "Недостаточный уровень трейла", buildTrailSnapshot(player, trailId))
	end
	
	if resources.Money.Value < requiredMoney then
		return makeResponse(false, "Недостаточно денег", buildTrailSnapshot(player, trailId))
	end
	
	if resources.Rebirth.Value < requiredRebirth then
		return makeResponse(false, "Недостаточно ребитхов", buildTrailSnapshot(player, trailId))
	end
	
	if requirements.SpendMoney == true then
		resouces.Money.Value -= requiredMoney
	end
	
	if requirements.SpendRebirth == true then
		resources.Rebirth.Value -= requiredRebirth
	end
	
	object.Stage.Value += 1
	
	return makeResponse(true, "Стадия трейла повышена", buildTrailSnapshot(player, trailId))
end

--// REMOTE HANDLER
local function handleRequest(player, action, trailId)
	if player:GetAttribute("DateReady") ~= true then
		return makeResponse(false, "Данные игрока еще загружаются")
	end
	
	if type(action) ~= "string" then
		return makeResponse(false, "Неверное действие")
	end
	
	if action == "GetAllData" then
		return makeResponse(true, "", buildAllTrailsSnapshot(player))
	end
	
	if not isValidTrailId(trailId) then
		return makeResponse(false, "Неизвестный трейл")
	end
	
	if action == "GetTrailData" then
		return makeResponse(true, "", buildTrailSnapshot(player, trailId))
	end
	
	if action == "PurchaseTrail" then
		return purchaseTrail(player, trailId)
	end
	
	if action == "UpgradeTrail" then
		return upgradeTrail(player, trailId)
	end
	
	if action == "ToggleEquip" then
		return toggleTrailEquip(player, trailId)
	end
	
	if action == "StageUp" then
		return stageUpTrail(player, trailId)
	end
	
	return makeResponse(false, "Неизвестное действие: " .. action)
end

trailRequestFunction.OnServerInvoke = function(player, action, trailId)
	if playerRequestLocks[player] then
		return makeResponse(false, "Предыдущий запрос еще выполняется")
	end
	
	playerRequestLocks[player] = true
	
	local success, result = pcall(handleRequest, player, action, trailId)
	
	playerRequestLocks[player] = nil
	
	if not success then
		warn("TrailServer request error:", player.Name, action, trailId, result)
		
		return makeResponse(false, "Произошла серверная ошибка")
	end
	return result
end

--// PLAYER SETUP
local function initializePlayer(player)
	if player:GetAttribute("DataReady") == true then
		setupTrailData(player)
		return
	end
	
	local connection
	
	connection = player:GetAttributeChangedSignal("DataReady"):Connect(function()
		if player:GetAttribute("DataReady") ~= true then
			return
		end
		
		connection:Disconnect()
		setupTrailData(player)
	end)
end

Players.PlayerAdded:Conncet(initializePlayer)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(initializePlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	playerRequestLocks[player] = nil
end)

print("TrailServer loaded")
