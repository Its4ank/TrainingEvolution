--// RaceServer 1.3

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local RaceModule = require(ReplicatedStorage.Modules.RaceModule)
local RebirthModule = require(ReplicatedStorage.Modules.RebirthModule)
local TrainerModule = require(ReplicatedStorage.Modules.TrainerModule)
local TrailModule = require(ReplicatedStorage.Modules.TrailModule)
local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)

local BoostModule = require(ServerScriptService.Modules.BoostModule)
local ItemModule = require(ServerScriptService.Modules.ItemModule)
local PetModule = require(ServerScriptService.Modules.PetModule)
local XPModule = require(ServerScriptService.Modules.XPModule)

--// Instance helpers
local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateValue(parent, className, name, defaultValue)
	local value = parent:FindFirstChild(name)
	if not value then
		value = Instance.new(className)
		value.Name = name
		value.Value = defaultValue
		value.Parent = parent
	end
	return value
end

local function getOrCreateRemoteEvent(parent, name)
	local remote = parent:FindFirstChild(name)
	
	if remote and not remote:IsA("RemoteEvent") then
		error(name .. " exists, but it is not a RemoteEvent")
	end
	
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		
		remote.Parent = parent
	end
	return remote
end

local function getOrCreateRemoteFunction(parent, name)
	local remote = parent:FindFirstChild(name)
	
	if remote and not remote:IsA("RemoteFunction") then 
		error(name .. " exists, but it is not a RemoteFunction")
	end
	
	if not remote then
		remote = Instance.New("RemoteFunction")
		remote.Name = name
		remote.Parent = parent
	end
	return remote
end

local function findDescendant(parent, name)
	if parent.Name == name then return parent end
	
	for _, descendant in ipairs(parent:GetDescendants()) do
		if descendant.Name == name then
			return descendant
		end
	end
	return nil
end

local function requireBasePart(parent, name)
	local object = findDescendant(parent, name)
	
	if not object then
		error("RaceServer: " .. name .. " was not found inside " .. parent:GetFullName())
	end
	
	if not object:IsA("BasePart") then
		error("RaceServer: " .. object:GetFullName() .. " is not a BasePart")
	end
	return object
end

local function getBaseParts(object)
	local parts = {}
	
	if object:IsA("BasePart") then
		table.insert(parts, object)
	end
	
	for _, decendant in ipairs(object:GetDescendants()) do
		if decendant:IsA("BasePart") then
			table.insert(parts, decendant)
		end
	end
	return parts
end

--// World references
local worldNames = RaceModule.WorldNames
local settings = RaceModule.Settings

local raceTrack = workspace:WaitForChild(worldNames.RaceTrack)
local raceStartPoint = requireBasePart(raceTrack, worldNames.RaceStartPoint)
local raceMaxEndPoint = requireBasePart(raceTrack, worldNames.RaceMaxEndPoint)
local startTrigger = requireBasePart(raceTrack, worldNames.StartTrigger)
local startGate = findDescendant(raceTrack, worldNames.StartGate)
local spawnPart = workspace:FindFirstChild("SpawnLocation")

if not startGate then
	error("RaceServer: " .. worldNames.StartGate .. " was not found inside " .. raceTrack:GetFullName())
end

local startCFrame = raceStartPoint.CFrame

--// Remote and replicated race state
local raceFolder = getOrCreateFolder(ReplicatedStorage, "RaceFolder")

local racePopupEvent = getOrCreateRemoteEvent(raceFolder, "RacePopupEvent")
local leaveRaceEvent = getOrCreateRemoteEvent(raceFolder, "LeaveRaceEvent")
local raceActionEvent = getOrCreateRemoteEvent(raceFolder, "RaceActionEvent")
local raceActionResultEvent = getOrCreateRemoteEvent(raceFolder, "RaceActionResultEvent")
local raceWarningEvent = getOrCreateRemoteEvent(raceFolder, "RaceWarningEvent")
local racePreviewFunction = getOrCreateRemoteFunction(raceFolder, "RacePreviewFunction")

local raceStatusText = getOrCreateValue(ReplicatedStorage, "StringValue", "RaceStatusText", "Race starts in")
local raceTimerText = getOrCreateValue(ReplicatedStorage, "StringValue", "RaceTimerText", "0:00")

local raceOpenValue = getOrCreateValue(raceFolder, "BoolValue", "RaceOpen", false)
local raceRoundIdValue = getOrCreateValue(raceFolder, "IntValue", "RaceRoundId", 0)

local raceTopData = getOrCreateFolder(raceFolder, "RaceTopData")
local topSlots = {}

for place = 1, settings.TopPlayerCount do
	topSlots[place] = {
		UserId = getOrCreateValue(raceTopData, "IntValue", "Top" .. place .. "UserId", 0),
		Distance = getOrCreateValue(raceTopData, "NumberValue", "Top" .. place .. "Distance", 0),
	}
end

--// Start gate
local startGateDefaults = {}

for _, part in ipairs(getBaseParts(startGate)) do
	startGateDefaults[part] = {
		CanCollide = part.CanCollide,
		CanTouch = part.CanTouch,
		Transparency = part.Transparency,
	}
end

local function setStartGateOpen(isOpen)
	for part, defaults in pairs(startGateDefaults) do
		if part.Parent then
			if isOpen then
				part.CanCollide = false
				part.CanTouch = false
				part.Transparency = 1
			else
				part.CanCollide = defaults.CanCollide
				part.CanTouch = defaults.CanTouch
				part.Transparency = defaults.Transparency
			end
		end
	end
end

--// Runtime state
local raceOpen = false
local activeRacers = {}
local roundStates = {}
local savedWalkSpeeds = {}
local actionLocks = {}

local function newRoundState()
	return {
		Speed = settings.BaseSpeed,
		CommittedDistance = 0,
		SegmentMaxDistance = 0,
		CollectedRewards = {},
		TrackDistance = 0,
		Checkpoints = {},
	}
end

local function getRoundState(player)
	local state = roundStates[player]
	
	if not state then
		state = newRoundState()
		roundStates[player] = state
	end
	return state
end

--// Player race values
local function setupPlayerRaceData(player)
	local playerData = player:WaitForChild("PlayerData")
	local raceData = getOrCreateFolder(playerData, "RaceData")
	
	local stageValue = getOrCreateValue(raceData, "IntValue", "Stage", 1)
	local roadLevelValue = getOrCreateValue(raceData, "IntValue", "RoadLevel", 1)
	local rewardLevelValue = getOrCreateValue(raceData, "IntValue", "RewardLevel", 0)
	
	local leaderstats = player:WaitForChild("leaderstats")
	local raceRecordValue = getOrCreateValue(leaderstats, "IntValue", "RaceRecord", 0)
	
	local inRaceValue = getOrCreateValue(player, "BoolValue", "InRace", false)
	local raceProgressValue = getOrCreateValue(player, "NumberValue", "RaceProgress", 0)
	local raceSpeedValue = getOrCreateValue(player, "NumberValue", "RaceSpeed", settings.BaseSpeed)
	local raceTargetSpeedValue = getOrCreateValue(player, "NumberValue", "RaceTargetSpeed", settings.BaseSpeed)
	local lapDistanceValue = getOrCreateValue(player, "NumberValue", "RaceLapDistance", 0)
	local roundDistanceValue = getOrCreateValue(player, "NumberValue", "RaceRoundDistance", 0)
	local trackDistanceValue = getOrCreateValue(player, "NumberValue", "RaceTrackDistance", 0)
	
	local data = {
		RaceData = raceData,
		Stage = stageValue,
		RoadLevel = roadLevelValue,
		RewardLevel = rewardLevelValue,
		RaceRecord = raceRecordValue,
		
		InRace = inRaceValue,
		RaceProgress = raceProgressValue,
		RaceSpeed = raceSpeedValue,
		RaceTargetSpeed = raceTargetSpeedValue,
		LapDistance = lapDistanceValue,
		RoundDistance = roundDistanceValue,
		TrackDistance = trackDistanceValue,
	}
	
	player:SetAttribute("RaceServerReady", true)
	return data
end

local function getPlayerRaceData(player)
	local playerData = player:FindFirstChild("PlayerData")
	local raceData = playerData and playerData:FindFirstChild("RaceData")
	local leaderstats = player:FindFirstChild("leaderstats")
	
	if not raceData or not leaderstats then return nil end
	
	local data = {
		RaceData = raceData,
		Stage = raceData:FindFirstChild("Stage"),
		RoadLevel = raceData:FindFirstChild("RoadLevel"),
		RewardLevel = raceData:FindFirstChild("RewardLevel"),
		RaceRecord = leaderstats:FindFirstChild("RaceRecord"),
		
		InRace = player:FindFirstChild("InRace"),
		RaceProgress = player:FindFirstChild("RaceProgress"),
		RaceSpeed = player:FindFirstChild("RaceSpeed"),
		RaceTargetSpeed = player:FindFirstChild("RaceTargetSpeed"),
		LapDistance = player:FindFirstChild("RaceLapDistance"),
		RoundDistance = player:FindFirstChild("RaceRoundDistance"),
		TrackDistance = player:FindFirstChild("RaceTrackDistance"),
	}
	
	for name, value in pairs(data) do
		if name ~= "RaceData" and not value then return nil end
	end
	return data
end

local function refreshPlayerTrackData(player, data)
	data = data or getPlayerRaceData(player)
	if not data then return false end
	
	local trackDistance = RaceModule.GetTrackDistance(data.Stage.Value, data.RoadLevel.Value)
	
	trackDistance = tonumber(trackDistance) or 0
	
	if trackDistance <= 0 then
		warn("RaceServer: invalid track distance for", player.Name)
		return false
	end
	
	data.TrackDistance.Value = trackDistance
	
	local state = getRoundState(player)
	state.TrackDistance = trackDistance
	state.Checkpoints = RaceModule.GetRewardCheckpoint(data.Stage.Value, data.RoadLevel.Value)
	return true
end

--// Resource helpers
local function getPlayerResources(player)
	local playerData = player:FindFirstChild("PlayerData")
	local leaderstats = player:FindFirstChild("leaderstats")
	local resources = player:FindFirstChild("Resources")
	
	if not playerData or not leaderstats or not resources then return nil end
	
	local values = {
		Money = playerData:FindFirstChild("Money"),
		Gems = playerData:FindFirstChild("Gems"),
		RaceTouch = playerData:FindFirstChild("RaceTouch"),
		Energy = leaderstats:FindFirstChild("Energy"),
		Rebirth = leaderstats:FindFirstChild("Rebirth"),
		XP = resources:FindFirstChild("XPModule"),
	}
	
	for _, value in pairs(values) do
		if not value then return nil end
	end
	return values
end

local function getPetMoneyMultiplier(player)
	local multiplier = 1
	
	for _, pet in ipairs(PetModule.getEquippedPets(player)) do
		local petMoney = pet:FindFirstChild("MoneyMultiplier")
		
		if petMoney then
			multiplier *= petMoney.Value
		end
	end
	return multiplier
end

local function getEquippedTrailData(player)
	local trailsFolder = player:FindFirstChild("Trails")
	
	if not trailsFolder then return nil end
	
	local equippedTrail = trailsFolder:FindFirstChild("EquippedTrail")
	if not equippedTrail or not equippedTrail:IsA("StringValue") or equippedTrail.Value == "" then
		return nil
	end
	
	local trailFolder = trailsFolder:FindFirstChild(equippedTrail.Value)
	if not trailFolder then return nil end
	
	local owned = trailFolder:FindFirstChild("Owned")
	local level = trailFolder:FindFirstChild("Level")
	local stage = trailFolder:FindFirstChild("Stage")
	
	if not owned or not owned.Value or not level or not stage then return nil end
	if not TrailModule.GetTrailConfig(equippedTrail.Value) then return nil end
	
	return {
		Id = equippedTrail.Value,
		Level = level.Value,
		Stage = stage.Value,
	}
end

local function getTrailRacePowerMultiplier(player)
	local trailData = getEquippedTrailData(player)
	
	if not trailData then return 1 end
	
	return TrailModule.GetRacePowerMultiplier(trailData.Id, trailData.Level, trailData.Stage)
end

local function getTrailAccelerationMultiplier(player)
	local trailData = getEquippedTrailData(player)
	
	if not trailData then return 1 end
	
	return TrailModule.GetAccelerationMultiplier(trailData.Id, trailData.Level, trailData.Stage)
end

--// Speed calculations
local function getEffectiveEnergy(player, resources)
	resources = resources or getPlayerResources(player)
	
	if not resources then return 0 end
	
	return UpgradeModule.GetRaceEnergy(player, resources.Energy.Value)
end

local function getTargetSpeed(player, resources)
	local targetSpeed = RaceModule.GetTargetSpeedFromEnergy(getEffectiveEnergy(player, resources))
	
	return targetSpeed 
		* TrainerModule.getRacePowerMultiplier(player) * getTrailRacePowerMultiplier(player)
end

local function getAccelerationMultiplier(player)
	return UpgradeModule.GetAccelerationMultiplier(player) 
		* TrainerModule.getAccelerationMultiplier(player) 
		* getTrailAccelerationMultiplier(player)
end

--// Reward calculations and granting
local function getRewardModifiers(player)
	local moneyMultiplier = ItemModule.getShoesMultiplier(player) 
		* getPetMoneyMultiplier(player)
		* UpgradeModule.GetMoneyMultiplier(player) 
		* TrainerModule.getMoneyMultiplier(player)
		* BoostModule.GetMoneyMultiplier(player)
		* RebirthModule.GetMoneyMultiplier(player)
	
	local xpMultiplier = RebirthModule.GetXpMultiplier(player) 
		* TrainerModule.getRaceXPMultiplier(player)
	local baseGemChance = settings.BaseGemChance
	local finalGemChance = UpgradeModule.GetFinalGemChance(player, baseGemChance)
	local gemChanceBonus = finalGemChance - baseGemChance
	local gemFlatBonus = UpgradeModule.GetFinalGemAmount(player, 0)
	
	return {
		MoneyMultiplier = moneyMultiplier,
		XPMultiplier = xpMultiplier,
		GemsMultiplier = 1,
		RaceTouchMultiplier = 1,
		GemFlatBonus = gemFlatBonus,
		GemChanceBonus = gemChanceBonus,
	}
end

racePreviewFunction.OnServerInvoke = function(player)
	local data = getPlayerRaceData(player)
	
	if not data then return {} end 
	
	local stage = data.Stage.Value
	local roadLevel = data.roadLevel.Value
	local rewardLevel = data.RewardLevel.Value
	local rewardCount = RaceModule.GetRewardCount(stage, roadLevel)
	local rewardCap = RaceModule.GetRewardLevelCap(stage)
	local nextRewardLevel = math.min(rewardLevel + 1, rewardCap)
	local modifiers = getRewardModifiers(player)
	
	local preview = {}
	
	for rewardIndex = 1, rewardCount do 
		preview[rewardIndex] = {
			Current = RaceModule.calculateFinalReward(rewardIndex, stage, rewardLevel, modifiers),
			Next = RaceModule.calculateFinalReward(rewardIndex, stage, nextRewardLevel, modifiers),
		}
	end
	return preview
end

local function giveCheckpointReward(player, rewardIndex)
	local data = getPlayerRaceData(player)
	local resources = getPlayerResources(player)
	
	if not data or not resources then return false end
	
	local reward = RaceModule.calculateFinalReward(rewardIndex, data.Stage.Value, data.RewardLevel.Value, getRewardModifiers(player))
	
	if not reward then return false end
	
	if reward.Money > 0 then
		resources.Money.Value += reward.Money
		racePopupEvent:FireClient(player, "Money", reward.Money)
		
		TrainerModule.addEquippedTrainerProgress(player, "Money", reward.Money)
	end
	
	if reward.RaceTouch > 0 then
		resources.RaceTouch.Value += reward.RaceTouch
		racePopupEvent:FireClient(player, "RaceTouch", reward.RaceTouch)
		
		TrainerModule.addEquippedTrainerProgress(player, "RaceTouch", reward.RaceTouch)
	end
	
	if reward.XP > 0 then
		XPModule.addXP(player, reward.XP)
		racePopupEvent:FireClient(player, "XP", reward.XP)
	end
	
	if reward.Gems > 0 and math.random() < reward.GemChance then
		resources.Gems.Value += reward.Gems
		racePopupEvent:FireClient(player, "Gems", reward.Gems)
	end
	return true
end

--// Character helpers
local function getCharacterParts(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	
	return character, humanoid, rootPart
end

local function teleportToRaceStart(player)
	local _, _, rootPart = getCharacterParts(player)
	if not rootPart then return false end
	
	local startPosition = startCFrame.Position + startCFrame.UpVector * 3
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	rootPart.CFrame = CFrame.lookAt(startPosition, startPosition + startCFrame.LookVector, startCFrame.UpVector)
	return true
end

local function teleportToSpawn(player)
	if not spawnPart then return end
	
	local _, _, rootPart = getCharacterParts(player)
	
	if rootPart then
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		rootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
	end
end

local function restoreWalkSpeed(player)
	local _, humanoid = getCharacterParts(player)
	
	if humanoid then
		humanoid.WalkSpeed = savedWalkSpeeds[player] or 16
	end
	savedWalkSpeeds[player] = nil
end

--// Record and round distance
local function updatePlayerRecord(player, data)
	data = data or getPlayerRaceData(player)
	if not data then return end 
	
	local currentDistance = math.floor(data.RoundDistance.Value)
	
	
	if currentDistance > data.RaceRecord.Value then
		data.RaceRecord.Value = currentDistance
	end
end

local function comitCurrentSegment(player, data, state)
	data = data or getPlayerRaceData(player)
	state = state or getRoundState(player)
	
	if not data then return end 
	
	state.CommittedDistance += state.SegmentMaxDistance
	state.SegmentMaxDistance = 0
	
	data.LapDistance.Value = 0
	data.RaceProgress.Value = 0
	data.RoundDistance.Value = state.CommittedDistance
	
	updatePlayerRecord(player, data)
end

--// Entering, leaving and finishing laps
local leaveRace

local function startRace(player)
	if not raceOpen or player:GetAttribute("DataReady") ~= true then return end 
	if activeRacers[player] then return end
	
	local data = getPlayerRaceData(player)
	local resources = getPlayerResources(player)
	local _, humanoid = getCharacterParts(player)
	
	if not data or not resources or not humanoid then return end 
	if not refreshPlayerTrackData(player, data) then return end 
	
	local state = getRoundState(player)
	state.SegmentMaxDistance = 0
	
	savedWalkSpeeds[player] = humanoid.WalkSpeed
	humanoid.WalkSpeed = state.Speed
	
	data.InRace.Value = true
	data.RaceSpeed.Value = state.Speed
	data.LapDistance.Value = 0
	data.RaceProgress.Value = 0
	data.RoundDistance.Value = state.CommittedDistance
	
	teleportToRaceStart(player)
	
	local activeData = {}
	activeRacers[player] = activeData
	
	activeData.DiedConnection = humanoid.Died:Connect(function()
		leaveRace(player, true, false)
	end)
end

leaveRace = function(player, preserveRound, shouldTeleport)
	local activeData = activeRacers[player]
	local data = getPlayerRaceData(player)
	local state = getRoundState(player)
	
	if activeData then
		if activeData.DiedConnection then
			activeData.DiedConnection:Disconnect()
		end
		
		activeRacers[player] = nil
		comitCurrentSegment(player, data, state)
	end
	
	if data then
		data.InRace.Value = false
		data.LapDistance.Value = 0
		data.RaceProgress.Value = 0
	end
	
	if preserveRound then
		if preserveRound then
			data.RaceSpeed.Value = state.Speed
			data.RoundDistance.Value = state.CommittedDistance
		end
    else
		state.Speed = settings.BaseSpeed
		state.CommittedDistance = 0
		state.SegmentMaxDistance = 0
		state.CollectedRewards = {}
		
		if data then
			data.RaceSpeed.Value = settings.BaseSpeed
			data.RaceTargetSpeed.Value = settings.BaseSpeed
			data.RoundDistance.Value = 0
		end
	end

	restoreWalkSpeed(player)

	if shouldTeleport then
		teleportToSpawn(player)
	end
end

local function finishLap(player, data, state)
	state.CommittedDistance += state.TrackDistance
	state.SegmentMaxDistance = 0
	state.CollectedRewards = {}
	
	data.LapDistance.Value = 0
	data.RaceProgress.Value = 0
	data.RoundDistance.Value = state.CommittedDistance
	
	updatePlayerRecord(player, data)
	teleportToRaceStart(player)
end

--// Per-player race update
local function updateRacer(player, deltaTime)
	local data = getPlayerRaceData(player)
	local resources = getPlayerResources(player)
	local state = getRoundState(player)
	local _, humanoid, rootPart = getCharacterParts(player)
	
	if not data or not resources or not humanoid or not rootPart or humanoid.Health <= 0 then return end 
	
	local targetSpeed = getTargetSpeed(player, resources)
	local accelerationMultiplier = getAccelerationMultiplier(player)
	
	state.Speed = RaceModule.GetNextSpeed(state.Speed, targetSpeed, deltaTime, accelerationMultiplier)
	
	data.RaceSpeed.Value = state.Speed
	data.RaceTargetSpeed.Value = targetSpeed
	humanoid.WalkSpeed = state.Speed
	
	local forwardDistance = RaceModule.GetForwardDistance(startCFrame, rootPart.Position)
	
	forwardDistance = math.clamp(tonumber(forwardDistance) or 0, 0, state.TrackDistance)
	
	local previousDistance = state.SegmentMaxDistance
	local currentDistance = math.max(previousDistance, forwardDistance)
	
	if currentDistance <= previousDistance then return end 
	
	state.SegmentMaxDistance = currentDistance
	
	data.LapDistance.Value = currentDistance
	data.RaceProgress.Value = currentDistance / state.TrackDistance
	data.RoundDistance.Value = state.CommittedDistance + currentDistance
	
	for _, checkpoint in ipairs(state.Checkpoints) do
		if previousDistance < checkpoint.Distance and currentDistance >= checkpoint.Distance
			and not state.CollectedRewards[checkpoint.Name] then
			
			state.CollectedRewards[checkpoint.Name] = true
			giveCheckpointReward(player, checkpoint.Index)
		end
	end
	
	updatePlayerRecord(player, data)
	
	if currentDistance >= state.TrackDistance then
		finishLap(player, data, state)
	end
end

--// Race Top 1-3
local function clearRaceTop()
	for _, slot in ipairs(topSlots) do
		slot.UserId.Value = 0
		slot.Distance.Value = 0
	end
end

local function updateRaceTop()
	local rankedPlayers = {}
	
	for player in pairs(activeRacers) do
		local data = getPlayerRaceData(player)
		
		if data and data.InRace.Value then
			table.insert(rankedPlayers, {
				Player = player,
				Distance = data.RoundDistance.Value
			})
		end
	end
	
	table.sort(rankedPlayers, function(a, b)
		if a.Distance == b.Distance then
			return a.Player.UserId < b.Player.UserId
		end
		return a.Distance > b.Distance
	end)
	
	for place, slot in ipairs(topSlots) do
		local rankedData = rankedPlayers[place]
		
		if rankedData then
			slot.UserId.Value = rankedData.Player.UserId
			slot.Distance.Value = rankedData.Distance
		else 
			slot.UserId.Value = 0
			slot.Distance.Value = 0
		end
	end
end

--// Warning helpers
local resourceDisplayNames = {
	Level = "race levels",
	Money = "coins",
	RaceTouch = "Race Touch",
	XP = "XP",
	Rebirth = "rebirths",
	Energy = "energy",
}

local warningPriority = {
	"Level",
	"Money",
	"RaceTouch",
	"XP",
	"Rebirth",
	"Energy",
}

local function formatNumber(number)
	local success, result = pcall(RaceModule.FormatNumber, number)
	
	if success then return result end
	return tostring(number)
end

local function fireWarning(player, message)
	raceWarningEvent:FireClient(player, message)
end

local function fireMissingWarning(player, missing)
	for _, resourceName in ipairs(warningPriority) do
		local amount = missing[resourceName]
		
		if amount and amount > 0 then
			fireWarning(player, "You are missing " 
				.. formatNumber(amount)
				.. " "
				.. resourceDisplayNames[resourceName]
			)
			return
		end
	end
	fireWarning(player, "Requirements are not completed")
end

local function rejectWhileRacing(player)
	local data = getPlayerRaceData(player)
	
	if data and data.InRace.Value then
		fireWarning(player, "Leave the race before upgrading")
		return true
	end
	return false
end

--// Upgrade actions
local function upgradeRoad(player)
	if rejectWhileRacing(player) then return false end
	
	local data = getPlayerRaceData(player)
	local resources = getPlayerResources(player)
	
	if not data or not resources then return false end
	
	local price = RaceModule.GetRoadUpgradePrice(data.Stage.Value, data.RoadLevel.Value)
	
	if not price then
		fireWarning(player, "Road level is already MAX")
		return false
	end
	
	if resources.Money.Value < price then
		fireMissingWarning(player, {
			Money = price - resources.Money.Value,
		})
		return false
	end
	
	resources.Money.Value -= price
	data.RoadLevel.Value += 1
	
	refreshPlayerTrackData(player, data)
	getRoundState(player).CollectedRewards = {}
	return true
end

local function upgradeReward(player)
	if rejectWhileRacing(player) then return false end 
	
	local data = getPlayerRaceData(player)
	local resources = getPlayerResources(player)
	
	if not data or not resources then return false end 
	
	local stageCap = RaceModule.GetRewardLevelCap(data.Stage.Value)
	
	if data.RewardLevel.Value >= stageCap then
		fireWarning(player, "Upgrade the race stage to unlock more reward levels")
		return false
	end
	
	local targetLevel = data.RewardLevel.Value + 1
	local price = RaceModule.GetRewardUpgradePrice(targetLevel)
	
	if not price then
		fireWarning(player, "Reward level is already MAX")
		return false
	end
	
	local missing = {}
	
	if resources.Money.Value < price.Money then
		missing.Money = price.Money - resources.Money.Value
	end
	
	if resources.RaceTouch.Value < price.RaceTouch then
		missing.RaceTouch = price.RaceTouch - resources.RaceTouch.Value
	end
	
	if resources.XP.Value < price.XP then
		missing.XP = price.XP - resources.XP.Value
	end
	
	if next(missing) then
		fireMissingWarning(player, missing)
		return false
	end
	
	resources.Money.Value -= price.Money
	resources.RaceTouch.Value -= price.RaceTouch
	
	if not XPModule.removeXP(player, price.XP) then
		resources.Money.Value += price.Money
		resources.RaceTouch.Value += price.RaceTouch
		fireWarning(player, "Reward upgrade failed. Please try again")
		return false
	end
	
	data.RewardLevel.Value = targetLevel
	
	return true
end

local function stageUp(player)
	if rejectWhileRacing(player) then return false end 
	
	local data = getPlayerRaceData(player)
	local resources = getPlayerResources(player)
	
	if not data or not resources then return false end 
	
	local requirements = RaceModule.GetNextStageRequirements(data.Stage.Value)
	
	if not requirements then
		fireWarning(player, "Race stage is already MAX")
		return false
	end
	
	local currentValues = {
		Level = data.RoadLevel.Value,
		Money = resources.Money.Value,
		RaceTouch = resources.RaceTouch.Value,
		Rebirth = resources.Rebirth.Value,
		Energy = resources.Energy.Value,
	}
	
	local missing = RaceModule.GetMissingRequirements(requirements, currentValues)
	
	if next(missing) then
		fireMissingWarning(player, missing)
		return false
	end
	
	resources.Money.Value -= requirements.Money or 0
	resources.RaceTouch.Value -= requirements.RaceTouch or 0
	resources.Rebirth.Value -= requirements.Rebirth or 0
	resources.Energy.Value -= requirements.Energy or 0
	
	data.Stage.Value += 1
	data.RoadLevel.Value = 1
	
	refreshPlayerTrackData(player, data)
	getRoundState(player).CollectedRewards = {}
	
	return true
end

local raceActions = {
	UpgradeRoad = upgradeRoad,
	UpgradeReward = upgradeReward,
	StageUp = stageUp,
}

--// Remote connections
leaveRaceEvent.OnServerEvent:Connect(function(player)
	if activeRacers[player] then
		leaveRace(player, true, true)
	end
end)

raceActionEvent.OnServerEvent:Connect(function(player, actionName)
	if type(actionName) ~= "string" then return end 
	
	local action = raceActions[actionName]
	if not action or actionLocks[player] then return end 
	
	if player:GetAttribute("DataReady") ~= true then return end 
	
	actionLocks[player] = true 
	
	local success, result = pcall(action, player)
	
	actionLocks[player] = nil
	
	if not success then 
		warn("RaceServer action failed:", player.Name, actionName, result)
		fireWarning(player, "Race action failed. Please try again")
		raceActionResultEvent:FireClient(player, actionName, false)
		return
	end
	raceActionResultEvent:FireClient(player, actionName, result == true)
end)

--// Start trigger
local startTouchDebounce = {}

startTrigger.Touched:Connect(function(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	
	if not player or startTouchDebounce[player] then return end 
	
	startTouchDebounce[player] = true
	startRace(player) 
	
	task.delay(1, function()
		startTouchDebounce[player] = nil
	end)
end)

--// Player lifecycle
local function setupPlayer(player)
	while player.Parent and player:GetAttribute("DataReady") ~= true do task.wait() end 
	if not player.Parent then return end 
	
	local data = setupPlayerRaceData(player)
	local state = getRoundState(player)
	
	state.Speed = settings.BaseSpeed
	data.RaceSpeed.Value = settings.BaseSpeed
	
	refreshPlayerTrackData(player, data)
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(setupPlayer, player)
end)

for _, player in ipairs(Players:GetPlayers()) do 
	task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	local data = getPlayerRaceData(player)
	if data then updatePlayerRecord(player, data) end
	
	local activeData = activeRacers[player]
	if activeData and activeData.DiedConnection then
		activeData.DiedConnection:Disconnect()
	end
	
	activeRacers[player] = nil
	roundStates[player] = nil
	savedWalkSpeeds[player] = nil
	actionLocks[player] = nil
	startTouchDebounce[player] = nil
end)

--// Heartbeat
local topUpdateAccumulator = 0

RunService.Heartbeat:Connect(function(deltaTime)
	for player in pairs(activeRacers) do
		updateRacer(player, deltaTime)
	end
	
	topUpdateAccumulator += deltaTime
	
	if topUpdateAccumulator >= 0.2 then
		topUpdateAccumulator = 0
		updateRaceTop()
	end
end)

--// Timer
local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	
	return string.format("%d:%02d", minutes, remainingSeconds)
end

local function runCountdown(duration)
	local finishTime = workspace:GetServerTimeNow() + duration
	local previousTimeLeft
	
	while true do
		local timeLeft = math.max(0, math.ceil(finishTime - workspace:GetServerTimeNow()))
		
		if timeLeft ~= previousTimeLeft then
			previousTimeLeft = timeLeft
			raceTimerText.Value = formatTime(timeLeft)
		end
		
		if timeLeft <= 0 then break end
		task.wait(0.1)
	end
end

local function resetAllRoundStates()
	local playersToStop = {}
	
	for player in pairs(activeRacers) do
		table.insert(playersToStop, player)
	end
	
	for _, player in ipairs(playersToStop) do
		leaveRace(player, false, true)
	end
	
	for _, player in ipairs(Players:GetPlayers()) do
		local data = getPlayerRaceData(player)
		local state = getRoundState(player)
		
		if data then
			updatePlayerRecord(player, data)
			
			state.Speed = settings.BaseSpeed
			state.CommittedDistance = 0
			state.SegmentMaxDistance = 0
			state.CollectedRewards = {}
			
			data.InRace.Value = false
			data.RaceSpeed.Value = settings.BaseSpeed
			data.RaceTargetSpeed.Value = settings.BaseSpeed
			data.LapDistance.Value = 0
			data.RoundDistance.Value = 0
			data.RaceProgress.Value = 0
		end
	end
	clearRaceTop()
end

local measurement = RaceModule.MeasureTrack(startCFrame, raceMaxEndPoint.Position)

if not measurement.IsCorrect then
	warn("RaceServer: track measurement mismatch. Length =", measurement.Length, "LateralError =", measurement.LateralError)
end

task.spawn(function()
	while true do
		raceOpen = false
		raceOpenValue.Value = false
		setStartGateOpen(false)
		
		raceStatusText.Value = "Race starts in"
		runCountdown(settings.WaitTime)
		
		raceRoundIdValue.Value += 1
		raceOpen = true
		raceOpenValue.Value = true
		setStartGateOpen(true)
		
		raceStatusText.Value = "Race has started"
		runCountdown(settings.RaceTime)
		
		raceOpen = false
		raceOpenValue.Value = false
		setStartGateOpen(false)
		
		resetAllRoundStates()
	end
end)

print("RaceServer 1.3 loaded")
