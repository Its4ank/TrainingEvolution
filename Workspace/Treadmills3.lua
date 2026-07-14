local treadmillVisualPart = script.Parent
local treadmill = treadmillVisualPart.Parent
local treadmillName = treadmill.Name
local prompt = treadmill:WaitForChild("ProximityPrompt")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local PetModule = require(game.ServerScriptService.Modules.PetModule)
local TrainerModule = require(game.ServerScriptService.Modules.TrainerModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)
local RebirthModule = require(game.ReplicatedStorage.Modules.RebirthModule)
local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)

local runEvent = ReplicatedStorage:WaitForChild("RunEvent")
local energyPopupEvent = ReplicatedStorage:WaitForChild("EnergyPopupEvent")

local trainingPlayers = {}

local teleportPos = treadmill.Position + Vector3.new(0, 3, 0)

local TREADMILL_BASE_ENERGY = {
	[1] = 1,
	[2] = 10,
	[3] = 50,
	[4] = 100,
	[5] = 175,
}

local treadmillNumber = tonumber(string.match(treadmillName, "%d+")) or 1
local baseEnergyPerTick = TREADMILL_BASE_ENERGY[treadmillNumber] or 1

local MAX_TIER = 5

local function isTreadmillUnlocked(player)
	if treadmillNumber == 1 then
		return true
	end

	local trainingTiers = player:FindFirstChild("TrainingTiers")
	if not trainingTiers then return false end

	local previousTier = trainingTiers:FindFirstChild("Treadmill" .. (treadmillNumber - 1) .. "Tier")
	if not previousTier then return false end

	return previousTier.Value >= MAX_TIER
end

local function getUpgradeLevel(player, upgradeName)
	local upgrades = player:FindFirstChild("Upgrades")
	if not upgrades then return 0 end

	local upgrade = upgrades:FindFirstChild(upgradeName)
	if not upgrade then return 0 end

	return upgrade.Value
end

local function addTrainerTreadmillTime(player, dt)
	local trainerFolder = player:FindFirstChild("Trainer")
	if not trainerFolder then return end

	local equippedTrainerName = TrainerModule.getEquippedTrainerName(player)
	if not equippedTrainerName then return end

	local currentTrainer = trainerFolder:FindFirstChild(equippedTrainerName)
	if not currentTrainer then return end

	local level = currentTrainer:FindFirstChild("Level")
	local stage = currentTrainer:FindFirstChild("Stage")
	local treadmillTime = currentTrainer:FindFirstChild("TreadmillTimeAfterMaxLevel")

	if not level or not stage or not treadmillTime then return end

	local maxLevel = TrainerModule.getStageMaxLevel(stage.Value)

	if level.Value >= maxLevel then
		treadmillTime.Value += dt
	end
end

prompt.Triggered:Connect(function(player)
	if not isTreadmillUnlocked(player) then
		warn(treadmillName .. " locked")
		return
	end

	if trainingPlayers[player] then return end

	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return end

	trainingPlayers[player] = true
	--prompt.Enabled = false

	runEvent:FireClient(player, true)

	hrp.CFrame = CFrame.new(teleportPos)

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.AutoRotate = false
	hrp.Anchored = true

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local runAnim = Instance.new("Animation")
	runAnim.AnimationId = "rbxassetid://913376220"

	local runTrack = animator:LoadAnimation(runAnim)
	runTrack.Priority = Enum.AnimationPriority.Action
	runTrack.Looped = true
	runTrack:Play()
	runTrack:AdjustSpeed(3)

	task.spawn(function()
		local lastTick = tick()
		local lastTimeUpdate = os.clock()

		while trainingPlayers[player] do
			if humanoid.Jump then
				break
			end

			local speedTrainingLevel = getUpgradeLevel(player, "SpeedTraining")
			local interval = math.max(0.2, 1 - (speedTrainingLevel * 0.05))

			if tick() - lastTick >= interval then
				lastTick = tick()

				local stats = player:FindFirstChild("leaderstats")
				local energy = stats and stats:FindFirstChild("Energy")

				if energy then
					local petEnergyMultiplier = 1

					local equippedPets = PetModule.getEquippedPets(player)
					for _, pet in ipairs(equippedPets) do
						local petEnergy = pet:FindFirstChild("EnergyMultiplier")
						if petEnergy then
							petEnergyMultiplier *= petEnergy.Value
						end
					end

					local now = os.clock()
					local dt = now - lastTimeUpdate
					lastTimeUpdate = now

					addTrainerTreadmillTime(player, dt)

					local trainingTiers = player:FindFirstChild("TrainingTiers")
					local treadmillTier = trainingTiers and trainingTiers:FindFirstChild(treadmillName .. "Tier")

					local tierBonus = 1
					if treadmillTier then
						tierBonus = treadmillTier.Value
					end

					local energyUpgradeLevel = getUpgradeLevel(player, "Energy")
					local energyUpgradeMultiplier = 1 + (energyUpgradeLevel * 0.10)

					local trainerEnergyMultiplier = TrainerModule.getEnergyMultiplier(player)
					local boostEnergyMultiplier = BoostModule.GetEnergyMultiplier(player)
					local rebirthMultiplier = RebirthModule.GetEnergyMultiplier(player)
					local rebirthFlatBonus = RebirthModule.GetEnergyFlatBonus(player)
					local gamepassEnergyBonus = ShopModule.GetEnergyBonus(player)
					local topBoost = BoostModule.GetTopPublicBoost(player)

					local finalMultiplier = 1
						+ (petEnergyMultiplier - 1)
						+ (rebirthMultiplier - 1)
						+ (energyUpgradeMultiplier -1)
						+ (trainerEnergyMultiplier - 1)
						+ (boostEnergyMultiplier - 1)
						+ (topBoost.Energy - 1)
						+ (baseEnergyPerTick + rebirthFlatBonus)
					    + gamepassEnergyBonus

					local gainedEnergy = baseEnergyPerTick
						* tierBonus
						* finalMultiplier
					
					gainedEnergy = math.floor(gainedEnergy + 0.5)
					
					energy.Value += gainedEnergy
					energyPopupEvent:FireClient(player, gainedEnergy)
				end
			end

			task.wait(0.1)
		end

		trainingPlayers[player] = nil

		if runTrack then
			runTrack:Stop()
			runTrack:Destroy()
		end

		humanoid.AutoRotate = true
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		hrp.Anchored = false

		--prompt.Enabled = true
		runEvent:FireClient(player, false)
	end)
end)
