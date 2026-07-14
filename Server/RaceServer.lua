--Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PetModule = require(game.ServerScriptService.Modules.PetModule)
local ItemModule = require(game.ServerScriptService.Modules.ItemModule)
local XPModule = require(game.ServerScriptService.Modules.XPModule)
local TrainerModule = require(game.ServerScriptService.Modules.TrainerModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)
local RebirthModule = require(game.ReplicatedStorage.Modules.RebirthModule)



--World helpers
local function findDescendantByName(parent, targetName)
	for _, obj in ipairs(parent:GetDescendants()) do
		if obj.Name == targetName then
			return obj
		end
	end
	return nil
end

local function requireBasePart(parent, targetName)
	local obj = findDescendantByName(parent, targetName)
	if not obj then
		error("Не найден объект '" .. targetName .. "' внутри " .. parent:GetFullName())
	end
	if not obj:IsA("BasePart") then
		error("Объект '" .. targetName .. "' найден, но он не BasePart. ClassName = " .. obj.ClassName)
	end
	return obj
end



--World references
local track = workspace:WaitForChild("RaceTrack")

local startLine = requireBasePart(track, "StartLine")
local raceBarrier = requireBasePart(track, "RaceBarrier")
local finishLine = requireBasePart(track, "Finish")
local road1 = requireBasePart(track, "Road1")
local road1_2 = requireBasePart(track, "Road1.2")
local road2 = requireBasePart(track, "Road2")
local road3 = requireBasePart(track, "Road3")
local road4 = requireBasePart(track, "Road4")
local road5 = requireBasePart(track, "Road5")
local spawnPart = workspace:FindFirstChild("SpawnLocation")



--RemoteEvent
local leaveRaceEvent = ReplicatedStorage:FindFirstChild("LeaveRaceEvent")
if not leaveRaceEvent then
	leaveRaceEvent = Instance.new("RemoteEvent")
	leaveRaceEvent.Name = "LeaveRaceEvent"
	leaveRaceEvent.Parent = ReplicatedStorage
end

local raceStatusText = ReplicatedStorage:FindFirstChild("RaceStatusText")
if not raceStatusText then
	raceStatusText = Instance.new("StringValue")
	raceStatusText.Name = "RaceStatusText"
	raceStatusText.Parent = ReplicatedStorage
end

local raceTimerText = ReplicatedStorage:FindFirstChild("RaceTimerText")
if not raceTimerText then
	raceTimerText = Instance.new("StringValue")
	raceTimerText.Name = "RaceTimerText"
	raceTimerText.Parent = ReplicatedStorage
end



--Constants
local WAIT_TIME = 30
local RACE_TIME = 150

local raceOpen = false
local totalTrackLength = 9278.5
local MIN_SPEED = 10
local ACCELERATION_PER_SECOND = 0.2
local rewardValues = {
	Reward1 = 1,
	Reward2 = 5,
	Reward3 = 10,
	Reward4 = 25,
	Reward5 = 50,
	Reward6 = 100,
	Reward7 = 250,
	Reward8 = 500,
	Reward9 = 1000,
	Reward10 = 2000,
	Reward11 = 4000,
	Reward12 = 7000,
	Reward13 = 12000,
	Reward14 = 25000,
	Reward15 = 35000,
	Reward16 = 50000,
}
local GEM_CHANCE = 0.2 -- 20% шанс получить гем
local GEM_REWARD = 1 -- сколько гемов всего дается



--Runtime state
local activeConnections = {}
local savedWalkSpeed = {}
local savedJumpPower = {}
local savedJumpHeight = {}
local savedAutoRotate = {}
local collectedRewards = {}



--Helpers
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
	if not playerData then return nil end

	return playerData:FindFirstChild("Money")
end

local function resetCollectedRewards(player)
	collectedRewards[player] = {}
end

local function getPlayerFromHit(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%d:%02d", minutes, secs)
end



--Race values
local function getOrCreateInRace(player)
	return getOrCreateValue(player, "BoolValue", "InRace", false)
end

local function getOrCreateRaceProgress(player)
	return getOrCreateValue(player, "NumberValue", "RaceProgress", 0)
end

local function getOrCreateRaceSpeed(player)
	return getOrCreateValue(player, "NumberValue", "RaceSpeed", 0)
end

local function setupPlayerValues(player)
	getOrCreateInRace(player)
	getOrCreateRaceProgress(player)
	getOrCreateRaceSpeed(player)
	resetCollectedRewards(player)
end



--Race calculations
local function lerp(a, b, t)
	return a + (b - a) * t
end

local function getRaceSpeedFromEnergy(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return MIN_SPEED
	end

	local energy = leaderstats:FindFirstChild("Energy")
	if not energy then
		return MIN_SPEED
	end

	local value = energy.Value
	if value <= 0 then
		return MIN_SPEED
	end

	-- 0 - 1m 16/50
	if value < 1e6 then
		local t = value / 1e6
		return lerp(16, 50, t)
	end

	-- 1m - 1b  50/100  
	if value < 1e9 then
		local t = (value - 1e6) / (1e9 - 1e6)
		return lerp(50, 100, t)
	end

	-- 1b - 1t  100/200
	if value < 1e12 then
		local t = (value - 1e9) / (1e12 - 1e9)
		return lerp(100, 200, t)
	end

	-- 1t - 1q  200/400
	if value < 1e15 then
		local t = (value - 1e12) / (1e15 - 1e12)
		return lerp(200, 400, t)
	end

	-- все выше 1q
	return 400
end



--Character control
local function lockPlayerToTrack(player)
	local character = player.Character
	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then
		return nil, nil
	end

	savedWalkSpeed[player] = humanoid.WalkSpeed
	savedJumpPower[player] = humanoid.JumpPower
	savedJumpHeight[player] = humanoid.JumpHeight
	savedAutoRotate[player] = humanoid.AutoRotate

	local targetPos = startLine.Position + Vector3.new(0, 3, 0)
	hrp.CFrame = CFrame.new(targetPos, targetPos + startLine.CFrame.LookVector)

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

	return humanoid, hrp
end

local function unlockPlayer(player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid.WalkSpeed = savedWalkSpeed[player] or 16
	humanoid.JumpPower = savedJumpPower[player] or 50
	humanoid.JumpHeight = savedJumpHeight[player] or 7.2
	humanoid.AutoRotate = savedAutoRotate[player]
	if humanoid.AutoRotate == nil then
		humanoid.AutoRotate = true
	end
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

	savedWalkSpeed[player] = nil
	savedJumpPower[player] = nil
	savedJumpHeight[player] = nil
	savedAutoRotate[player] = nil
end



--Main race function
local function getUpgradeLevel(player, upgradeName)
	local upgrades = player:FindFirstChild("Upgrades")
	if not upgrades then return 0 end

	local upgrade = upgrades:FindFirstChild(upgradeName)
	if not upgrade then return 0 end

	return upgrade.Value
end

local function startRace(player)
	if not raceOpen then
		return
	end
	
	if activeConnections[player] then
		return
	end

	setupPlayerValues(player)

	local inRaceValue = getOrCreateInRace(player)
	local progressValue = getOrCreateRaceProgress(player)
	local speedValue = getOrCreateRaceSpeed(player)

	inRaceValue.Value = true
	progressValue.Value = 0
	resetCollectedRewards(player)
	speedValue.Value = MIN_SPEED

	local humanoid, hrp = lockPlayerToTrack(player)
	if not humanoid or not hrp then
		return
	end

	print("START:", player.Name)

	activeConnections[player] = RunService.Heartbeat:Connect(function(dt)
		local character = player.Character
		local currentHumanoid = character and character:FindFirstChildOfClass("Humanoid")
		local currentHrp = character and character:FindFirstChild("HumanoidRootPart")
		if not currentHumanoid or not currentHrp then
			return
		end

		local currentPos = currentHrp.Position
		currentHrp.CFrame = CFrame.new(currentPos, currentPos + startLine.CFrame.LookVector)

		local targetSpeed = getRaceSpeedFromEnergy(player) * TrainerModule.getRacePowerMultiplier(player)
		local currentSpeed = speedValue.Value

		--Upgrade: Acceleration
		local accelerationLevel = getUpgradeLevel(player, "Acceleration")
		local trainerAccelerationMultiplier = TrainerModule.getAccelerationMultiplier(player)
		local accelerationMultiplier = (1 + (accelerationLevel * 0.15)) * trainerAccelerationMultiplier

		local delta = ACCELERATION_PER_SECOND * accelerationMultiplier * dt currentSpeed = math.min(currentSpeed + delta, targetSpeed)

		speedValue.Value = currentSpeed
		currentHrp.AssemblyLinearVelocity = startLine.CFrame.LookVector * currentSpeed

		local distanceFromStart = math.abs(currentHrp.Position.Z - startLine.Position.Z)
		local progress = distanceFromStart / totalTrackLength
		progressValue.Value = math.clamp(progress, 0, 1)
	end)
end

local function restartRace(player)
	local character = player.Character
	if not character then
		return
	end

	resetCollectedRewards(player)

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local progressValue = getOrCreateRaceProgress(player)
	progressValue.Value = 0

	local targetPos = startLine.Position + Vector3.new(0, 3, 0)
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(targetPos, targetPos + startLine.CFrame.LookVector)

	print("RESTART:", player.Name)
end

local function leaveRace(player)
	local conn = activeConnections[player]
	if conn then
		conn:Disconnect()
		activeConnections[player] = nil
	end

	resetCollectedRewards(player)

	local character = player.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			if spawnPart then
				hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end

	unlockPlayer(player)

	getOrCreateInRace(player).Value = false
	getOrCreateRaceProgress(player).Value = 0
	getOrCreateRaceSpeed(player).Value = 0

	print("LEAVE RACE:", player.Name)
end

local function stopAllRacers()
	local playersToStop = {}

	for player, _ in pairs(activeConnections) do
		table.insert(playersToStop, player)
	end

	for _, player in ipairs(playersToStop) do
		leaveRace(player)
	end
end



--Rewards
local function connectRewardTouch(reward)
	reward.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)
		if not player then
			return
		end

		local inRaceValue = getOrCreateInRace(player)
		if not inRaceValue.Value then
			return
		end

		collectedRewards[player] = collectedRewards[player] or {}

		if collectedRewards[player][reward.Name] then
			return
		end

		local rewardAmount = rewardValues[reward.Name]
		if not rewardAmount then
			return
		end

		collectedRewards[player][reward.Name] = true

		local money = getMoney(player)
		if money then

			local shoesMultiplier = ItemModule.getShoesMultiplier(player)

			local petMoneyMultiplier = 1

			local equippedPets = PetModule.getEquippedPets(player)
			for _, pet in ipairs(equippedPets) do
				local petMoney = pet:FindFirstChild("MoneyMultiplier")
				if petMoney then
					petMoneyMultiplier *= petMoney.Value
				end
			end

			--Upgrade: Money
			local moneyUpgradeLevel = getUpgradeLevel(player, "Money")
			local moneyUpgradeMultiplier = 1 + (moneyUpgradeLevel * 0.10)

			local trainerMoneyMultiplier = TrainerModule.getMoneyMultiplier(player)
			
			local boostMoneyMultiplier = BoostModule.GetMoneyMultiplier(player)
			local rebirthMoneyMultiplier = RebirthModule.GetMoneyMultiplier(player)
			
			
			local finalMultiplier = 
				shoesMultiplier 
				* petMoneyMultiplier 
				* moneyUpgradeMultiplier 
				* trainerMoneyMultiplier 
				* boostMoneyMultiplier
				* rebirthMoneyMultiplier
			
			
			local finalReward = math.floor(rewardAmount * finalMultiplier)
			money.Value += finalReward
		end

		PetModule.givePetXP(player, 1)
		XPModule.addXP(player, 1)
		local pet = PetModule.getEquippedPet(player)
		if pet then
			local xp = pet:FindFirstChild("XP")
			local level = pet:FindFirstChild("Level")
			if xp and level then
				print("PET XP:", xp.Value, "LEVEL:", level.Value)
			end
		end

		print(player.Name, "got base reward", rewardAmount, "from", reward.Name)

		-- UPGRADE: GemChance + GemMore
		local gemChanceLevel = getUpgradeLevel(player, "GemChance")
		local gemMoreLevel = getUpgradeLevel(player, "GemMore")

		local finalGemChance = GEM_CHANCE + (gemChanceLevel * 0.02)
		finalGemChance = math.clamp(finalGemChance, 0, 1)

		local finalGemReward = GEM_REWARD + gemMoreLevel

		if math.random() < finalGemChance then
			local playerData = player:FindFirstChild("PlayerData")
			if playerData then
				local gems = playerData:FindFirstChild("Gems")
				if gems then
					gems.Value += finalGemReward
					print(player.Name, "получил GEM")
				end

			end
		end
	end)
end



--Track connections
startLine.Touched:Connect(function(hit)
	local player = getPlayerFromHit(hit)
	if player then
		startRace(player)
	end
end)

finishLine.Touched:Connect(function(hit)
	local player = getPlayerFromHit(hit)
	if player and activeConnections[player] then
		restartRace(player)
	end
end)



--Remote connections
leaveRaceEvent.OnServerEvent:Connect(function(player)
	if activeConnections[player] then
		leaveRace(player)
	end
end)



--Player lifecycle
Players.PlayerAdded:Connect(function(player)
	setupPlayerValues(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayerValues(player)
end

Players.PlayerRemoving:Connect(function(player)
	local conn = activeConnections[player]
	if conn then
		conn:Disconnect()
		activeConnections[player] = nil
	end

	savedWalkSpeed[player] = nil
	savedJumpPower[player] = nil
	savedJumpHeight[player] = nil
	savedAutoRotate[player] = nil
end)



--Reward hookup
for _, obj in ipairs(track:GetDescendants()) do
	if obj:IsA("BasePart") and rewardValues[obj.Name] then
		connectRewardTouch(obj)
	end
end

task.spawn(function()
	while true do
		raceOpen = false
		raceBarrier.CanCollide = true
		raceBarrier.Transparency = 0

		raceStatusText.Value = "Race starts in"

		for timeLeft = WAIT_TIME, 0, -1 do
			raceTimerText.Value = formatTime(timeLeft)
			task.wait(1)
		end

		raceOpen = true
		raceBarrier.CanCollide = false
		raceBarrier.Transparency = 1

		raceStatusText.Value = "Race has started"

		for timeLeft = RACE_TIME, 0, -1 do
			raceTimerText.Value = formatTime(timeLeft)
			task.wait(1)
		end

		raceOpen = false
		raceBarrier.CanCollide = true
		raceBarrier.Transparency = 0

		stopAllRacers()
	end
end)

print("RaceServer loaded")
