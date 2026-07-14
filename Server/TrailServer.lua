local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local XPModule = require(game.ServerScriptService.Modules.XPModule)

local buyTrailEvent = ReplicatedStorage:WaitForChild("BuyTrailEvent")
local trailDataEvent = ReplicatedStorage:WaitForChild("TrailDataEvent")
local tierUpTrailEvent = ReplicatedStorage:WaitForChild("TierUpTrailEvent")
local UpgradeTrailEvent = ReplicatedStorage:WaitForChild("UpgradeTrailEvent")
local upgradeTrailEvent = ReplicatedStorage:WaitForChild("UpgradeTrailEvent")
local closeTrailMenuEvent = ReplicatedStorage:WaitForChild("CloseTrailMenuEvent")
local requestTrailDataEvent = ReplicatedStorage:WaitForChild("RequestTrailDataEvent")

local backPart = workspace:WaitForChild("TrailPosBack")

local TRAIL_CONFIG = {
	BlueTrail = {
		DisplayName = "Blue Trail",
		Price = 1000,
		
		BaseAcceleration = 1.10,
		BaseRacePower = 1.05,
		
		Tiers = {
			[1] = {
				Name = "Spark",
				Multiplier = 1,
				LevelBonus = 0.05,
				XPPerReward = 1,
				MaxLevel = 5,
				TierUpCost = 1500,
			},
			
			[2] = {
				Name = "Flow",
				Multiplier = 1.10,
				LevelBonus = 0.05,
				XPPerReward = 2,
				MaxLevel = 10,
				TierUpCost = 2500,
			},
			
			[3] = {
				Name = "Surge",
				Multiplier = 1.25,
				LevelBonus = 0.05,
				XPPerReward = 3,
				MaxLevel = 15,
				TierUpCost = 3500,
			},
			
			[4] = {
				Name = "Hyper",
				Multiplier = 1.35,
				LevelBonus = 0.05,
				XPPerReward = 4,
				MaxLevel = 20,
				TierUpCost = 4500,
			},
			
			[5] = {
				Name = "Ascended",
				Multiplier = 1.45,
				LevelBonus = 0.05,
				XPPerReward = 5,
				MaxLevel = 25,
			},
		},
	}
}

local function getOrCreateValue(parent, className, name, default)
	local value = parent:FindFirstChild(name)
	
	if not value then
		value = Instance.new(className)
		value.Name = name
		value.Value = default
		value.Parent = parent
	end
	
	return value
end

local function getTrailConfig(trailName)
	return TRAIL_CONFIG[trailName]
end

local function calculateTrailState(trailName, level, tier)
	local config = getTrailConfig(trailName)
	if not config then
		return 1, 1
	end
	
	local tierData = config.Tiers[tier]
	if not tierData then
		return 1, 1
	end
	
	local levelBonus = level * tierData.LevelBonus
	
	local acceleration = (config.BaseAcceleration + levelBonus) * tierData.Multiplier
	
	local racePower = (config.BaseRacePower + levelBonus) * tierData.Multiplier
	
	return acceleration, racePower
end

local function setupBlueTrail(player)
	local trailsFolder = player:FindFirstChild("Trails")
	
	if not trailsFolder then
		trailsFolder = Instance.new("Folder")
		trailsFolder.Name = "Trails"
		trailsFolder.Parent = player
	end
	
	local blueTrail = trailsFolder:FindFirstChild("BlueTrail")
	
	if not blueTrail then
		blueTrail = Instance.new("Folder")
		blueTrail.Name = "BlueTrail"
		blueTrail.Parent = trailsFolder
	end
	
	getOrCreateValue(blueTrail, "BoolValue", "Owned", false)
	getOrCreateValue(blueTrail, "BoolValue", "Equipped", false)
	
	getOrCreateValue(blueTrail, "IntValue", "Level", 0)
	getOrCreateValue(blueTrail, "IntValue", "XP", 0)
	getOrCreateValue(blueTrail, "IntValue", "Tier", 1)
	
	getOrCreateValue(blueTrail, "NumberValue", "AccelerationMultiplier", 1)
	getOrCreateValue(blueTrail, "NumberValue", "RacePowerMultiplier", 1)
	
	return blueTrail
end

local function updateTrailStats(player, trailName)
	local trailsFolder = player:FindFirstChild("Trails")
	if not trailsFolder then return end
	
	local trailFolder = trailsFolder:FindFirstChild(trailName)
	if not trailFolder then return end
	
	local owned = trailFolder:FindFirstChild("Owned")
	local level = trailFolder:FindFirstChild("Level")
	local tier = trailFolder:FindFirstChild("Tier")
	
	local accelerationValue = trailFolder:FindFirstChild("AccelerationMultiplier")
	local racePowerValue = trailFolder:FindFirstChild("RacePowerMultiplier")
	
	if not owned or not level or not tier or not accelerationValue or not racePowerValue then
		return
	end
	
	if not owned.Value then
		accelerationValue.Value = 1
		racePowerValue.Value = 1
		return
	end
	
	local acceleration, racePower = calculateTrailState(trailName, level.Value, tier.Value)
	
	accelerationValue.Value = acceleration
	racePowerValue.Value = racePower
end

local function getXPNeeded(level)
	return 5 + (level * 5)
end

local function sendTrailData(player, trailName)
	local trailsFolder = player:FindFirstChild("Trails")
	if not trailsFolder then return end
	
	local trailFolder = trailsFolder:FindFirstChild(trailName)
	if not trailFolder then return end
	
	local config = getTrailConfig(trailName)
	if not config then return end
	
	local tier = trailFolder:FindFirstChild("Tier")
	local tierData = config.Tiers[tier.Value]
	
	local level = trailFolder:FindFirstChild("Level")
	local playerXP = XPModule.getXP(player)
	local xpNeeded = getXPNeeded(level.Value)
	
	local nextTierData = config.Tiers[tier.Value + 1]
	
	local moneyValue = 0
	local playerData = player:FindFirstChild("PlayerData")
	if playerData then
		local money = playerData:FindFirstChild("Money")
		if money then
			moneyValue = money.Value
		end
	end
	
	local isMaxTier = tier.Value >= 5
	local canTierUp = false
	
	if not isMaxTier then
		canTierUp = level.Value >= tierData.MaxLevel and moneyValue >= tierData.TierUpCost
	end
	
	trailDataEvent:FireClient(player, trailName, {
		DisplayName = config.DisplayName,
		Price = config.Price,
		
		Owned = trailFolder.Owned.Value,
		Equipped = trailFolder.Equipped.Value,
		
		Level = trailFolder.Level.Value,
		XP = playerXP,
		XPNeeded = xpNeeded,
		
		CanUpgrade = playerXP >= xpNeeded,
		
		Tier = tier.Value,
		TierName = tierData.Name,
		
		MaxLevel = tierData.MaxLevel,
		TierUpCost = tierData.TierUpCost,
		CanTierUp = canTierUp,
		IsMaxTier = isMaxTier,
		
		NextTierName = nextTierData and nextTierData.Name or "MAX",
		
		AccelerationMultiplier = trailFolder.AccelerationMultiplier.Value,
		RacePowerMultiplier = trailFolder.RacePowerMultiplier.Value,
	})
end

local activeTrailOrbits = {}

local function equipTrail(player, trailName)
	local trailsFolder = player:FindFirstChild("Trails")
	if not trailsFolder then return end
	
	for _, trailFolder in ipairs(trailsFolder:GetChildren()) do
		local equipped = trailFolder:FindFirstChild("Equipped")
		if equipped then
			equipped.Value = false
		end
	end
	
	local trailFolder = trailsFolder:FindFirstChild(trailName)
	if not trailFolder then return end 
	
	local owned = trailFolder:FindFirstChild("Owned")
	local equipped = trailFolder:FindFirstChild("Equipped")
	
	if owned and equipped and owned.Value then
		equipped.Value = true
	end
end

local function removeVisualTrail(player)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local oldTrail = hrp:FindFirstChild("EquippedTrail")
	if oldTrail then oldTrail:Destroy()
	end
	
	local oldTrail2 = hrp:FindFirstChild("EquippedTrailSecond")
	if oldTrail2 then oldTrail2:Destroy()
	end

	local oldAura = hrp:FindFirstChild("EquippedTrailAura")
	if oldAura then oldAura:Destroy()
	end

	local oldA0 = hrp:FindFirstChild("EquippedAttachment0")
	if oldA0 then oldA0:Destroy()
	end

	local oldA1 = hrp:FindFirstChild("TrailAttachment1")
	if oldA1 then oldA1:Destroy()
	end
	
	if activeTrailOrbits[player] then
		if activeTrailOrbits[player].Connection then

			activeTrailOrbits[player].Connection:Disconnect()
		end

		for _, orb in ipairs(activeTrailOrbits[player].Orbs) do
			if orb and orb.Parent then
				orb:Destroy()
			end
		end

		activeTrailOrbits[player] = nil
	end
	
	for _, obj in ipairs(character:GetChildren()) do
		if obj.Name == "TrailOrbitParticle" then
			obj:Destroy()
		end
	end
end

local function createTrailOrbitParticles(player, hrp, character, count, color)
	if count <= 0 then return end 
	
	local orbs = {}
	
	for i = 1, count do 
		local orb = Instance.new("Part")
		orb.Name = "TrailOrbitParticle"
		orb.Shape = Enum.PartType.Ball
		orb.Material = Enum.Material.Neon
		orb.Color = color
		orb.Size = Vector3.new(0.2, 0.2, 0.2)
		orb.Transparency = 0.15
		orb.Anchored = true
		orb.CanCollide = false
		orb.Parent = character
		table.insert(orbs, orb)
	end
	
	local startTime = tick()
	
	local connection 
	connection = RunService.Heartbeat:Connect(function()
		if not player.Parent or not hrp.Parent then
			if connection then
				connection:Disconnect()
			end
			return
		end
		
		local t = tick() - startTime
		
		for i, orb in ipairs(orbs) do
			if not orb.Parent then
				continue
			end
			
			local angle = (t * (3 + ( 1* 0.25))) + (i * (( math.pi * 2) / count))
			
			local baseOffset = CFrame.new(0, 0.35, 1.5)
			
			local orbitOffset = CFrame.new( 
				math.cos(angle) * 1,
				math.sin(angle * 1.5) * 0.6,
				math.sin(angle) * 1
			)
			
			orb.CFrame = hrp.CFrame * baseOffset * orbitOffset
			
			local pulse = 0.16 + math.abs(math.sin(t * 6 + i)) * 0.08
			orb.Size = Vector3.new(pulse, pulse, pulse)
			orb.Transparency = 0.1 + math.abs(math.sin(t * 5 + i)) * 0.25
		end
	end)
	
	activeTrailOrbits[player] = {
		Connection = connection,
		Orbs = orbs,
	}
end

local function createBlueVisualTrail(player)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end 
	
	local tierName = "Spark"
	
	local trailsFolder = player:FindFirstChild("Trails")
	if trailsFolder then
		local blueTrail = trailsFolder:FindFirstChild("BlueTrail")
		if blueTrail then
			local tier = blueTrail:FindFirstChild("Tier")
			if tier then
				local config = TRAIL_CONFIG.BlueTrail
				local tierData = config.Tiers[tier.Value]
				
				if tierData then
					tierName = tierData.Name
				end
			end
		end
	end
	
	local trailStyle = { 
		Color = Color3.fromRGB(255, 255, 255),
		SecondColor = nil,
		LightEmission = 0.2,
		Lifetime = 0.45,
		WidthStart = 1,
		WidthEnd = 0.2,
		OrbitCount = 0,
		OrbitColor = Color3.fromRGB(255, 255, 255),
		Aura = false,
	}
	
	if tierName == "Flow" then
		trailStyle.OrbitCount = 2
		trailStyle.OrbitColor = Color3.fromRGB(255, 255, 255)
		trailStyle.LightEmission = 0.4
		trailStyle.Lifetime = 0.6
	elseif tierName == "Surge" then
		trailStyle.OrbitCount = 4
		trailStyle.OrbitColor = Color3.fromRGB(85, 255, 0)
		trailStyle.LightEmission = 0.6
		trailStyle.Lifetime = 0.75
		trailStyle.WidthStart = 1.2
	elseif tierName == "Hyper" then
		trailStyle.Color = Color3.fromRGB(0, 80, 255)
		trailStyle.SecondColor = Color3.fromRGB(255, 255, 255)
		trailStyle.LightEmission = 0.8
		trailStyle.Lifetime = 0.9
		trailStyle.WidthStart = 1.4
		trailStyle.OrbitCount = 6
		trailStyle.OrbitColor = Color3.fromRGB(85, 0, 127)
		trailStyle.Aura = true
	elseif tierName == "Ascended" then
		trailStyle.Color = Color3.fromRGB(0, 0, 255)
		trailStyle.SecondColor = Color3.fromRGB(0, 170, 255)
		trailStyle.LightEmission = 1
		trailStyle.Lifetime = 1.1
		trailStyle.WidthStart = 1.8
		trailStyle.WidthEnd = 0.4
		trailStyle.OrbitCount = 8
		trailStyle.OrbitColor = Color3.fromRGB(255, 255, 0)
		trailStyle.Aura = true
	end

	removeVisualTrail(player)

	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "TrailAttachment0"
	attachment0.Position = Vector3.new(0, 0.2, 0.5)
	attachment0.Parent = hrp

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "TrailAttachment1"
	attachment1.Position = Vector3.new(0, 0.2, -0.5)
	attachment1.Parent = hrp

	local trail = Instance.new("Trail")
	trail.Name = "EquippedTrail"
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = ColorSequence.new(trailStyle.Color)
	trail.LightEmission = trailStyle.LightEmission
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.8)
	})
	trail.Lifetime = trailStyle.Lifetime
	trail.MinLength = 0.1
	trail.FaceCamera = true
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, trailStyle.WidthStart),
		NumberSequenceKeypoint.new(1, trailStyle.WidthEnd)
	})
	trail.Enabled = true
	trail.Parent = hrp
	
	if trailStyle.SecondColor then
		local trail2 = Instance.new("Trail")
		trail2.Name = "EquippedTrailSecond"
		trail2.Attachment0 = attachment0
		trail2.Attachment1 = attachment1
		trail2.Color = ColorSequence.new(trailStyle.SecondColor)
		trail2.LightEmission = 1
		trail2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.25),
			NumberSequenceKeypoint.new(1, 0.9)
		})
		trail2.Lifetime = trailStyle.Lifetime
		trail2.MinLength = 0.1
		trail2.FaceCamera = true
		trail2.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, trailStyle.WidthStart + 0.4),
			NumberSequenceKeypoint.new(1, trailStyle.WidthEnd)
			})
		trail2.Enabled = true
		trail2.Parent = hrp
	end
	
	if trailStyle.Aura then
		local aura = Instance.new("Trail")
		aura.Name = "EquippedTrailAura"
		aura.Attachment0 = attachment0
		aura.Attachment1 = attachment1
		aura.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
		aura.LightEmission = 1
		aura.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(1, 1)
		})
		aura.Lifetime = trailStyle.Lifetime + 0.25
		aura.MinLength = 0.1
		aura.FaceCamera = true
		aura.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, trailStyle.WidthStart + 1),
			NumberSequenceKeypoint.new(1, 0)
		})
		aura.Enabled = true
		aura.Parent = hrp
	end
	
	createTrailOrbitParticles( 
		player,
		hrp,
		character,
		trailStyle.OrbitCount,
		trailStyle.OrbitColor
	)
end

local function applyEquippedVisualTrail(player)
	local trailsFolder = player:FindFirstChild("Trails")
	if not trailsFolder then return end

	local blueTrail = trailsFolder:FindFirstChild("BlueTrail")
	if not blueTrail then return end

	local owned = blueTrail:FindFirstChild("Owned")
	local equipped = blueTrail:FindFirstChild("Equipped")

	if owned and equipped and owned.Value and equipped.Value then
		createBlueVisualTrail(player)
	end
end

requestTrailDataEvent.OnServerEvent:Connect(function(player, trailName)
	setupBlueTrail(player)
	updateTrailStats(player, trailName)
	sendTrailData(player, trailName)
end)



--//OnServerEvent
buyTrailEvent.OnServerEvent:Connect(function(player, trailName)
	print("BUY TRAIL REQUEST:", player.Name, trailName)
	
	local config = getTrailConfig(trailName)
	if not config then 
		warn("NO TRAIL CONFIG:", trailName)
		return 
	end
	print("2")
	
	setupBlueTrail(player)
	print(3)
	
	local trailsFolder = player:FindFirstChild("Trails")
	if not trailsFolder then
		warn("NO TRAILS FOLDER")
		return
	end
	print(4)

	local trailFolder = trailsFolder:FindFirstChild(trailName)
	if not trailFolder then
		warn("TRAIL FOLDER NOT FOUND:", trailName)
		return
	end
	print(5)

	local owned = trailFolder:FindFirstChild("Owned")
	if not owned then
		warn("OWNED VALUE NOT FOUND:", trailName)
		return
	end
	print("6 OWNED OK:", owned.Value)
	
	if owned.Value then
		sendTrailData(player, trailName)
		return
	end
	print(7)
	
	local PlayerData = player:FindFirstChild("PlayerData")
	if not PlayerData then return end 
	
	local money = PlayerData:FindFirstChild("Money")
	if not money then return end
	
	if money.Value < config.Price then 
		sendTrailData(player, trailName)
		return
	end
	print(8)
	
	money.Value -= config.Price
	
	owned.Value = true
	print("TRAIL OWNED SET TRUE:", trailName, owned.Value)
	
	equipTrail(player, trailName)
	updateTrailStats(player, trailName)
	applyEquippedVisualTrail(player)
	sendTrailData(player, trailName)
	
	print(player.Name .. " купил " .. trailName)
end)	

tierUpTrailEvent.OnServerEvent:Connect(function(player, trailName)
	local config = getTrailConfig(trailName)
	if not config then return end

	local trailsFolder = player:FindFirstChild("Trails")
	if not trailsFolder then return end

	local trailFolder = trailsFolder:FindFirstChild(trailName)
	if not trailFolder then return end

	local owned = trailFolder:FindFirstChild("Owned")
	local level = trailFolder:FindFirstChild("Level")
	local xp = trailFolder:FindFirstChild("XP")
	local tier = trailFolder:FindFirstChild("Tier")

	if not owned or not level or not xp or not tier then return end
	if not owned.Value then return end

	if tier.Value >= 5 then
		sendTrailData(player, trailName)
		return
	end

	local tierData = config.Tiers[tier.Value]
	if not tierData then return end

	if level.Value < tierData.MaxLevel then
		sendTrailData(player, trailName)
		return
	end

	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return end

	local money = playerData:FindFirstChild("Money")
	if not money then return end

	if money.Value < tierData.TierUpCost then
		sendTrailData(player, trailName)
		return
	end

	money.Value -= tierData.TierUpCost

	tier.Value += 1
	level.Value = 0
	xp.Value = 0
	
	if tier.Value >= 5 then
		local playerData = player:FindFirstChild("PlayerData")
		
		if playerData then
			local srRobux = playerData:FindFirstChild("SrRobux")
			
			if srRobux then
				srRobux.Value += 1
			end
		end
	end

	updateTrailStats(player, trailName)
	applyEquippedVisualTrail(player)
	sendTrailData(player, trailName)

	print(player.Name .. " повысил Tier " .. trailName .. " до " .. config.Tiers[tier.Value].Name)
end)

upgradeTrailEvent.OnServerEvent:Connect(function(player, trailName)
	local trailsFolder = player:FindFirstChild("Trails")
	if not trailsFolder then return end
	
	local trailFolder = trailsFolder:FindFirstChild(trailName)
	if not trailFolder then return end
	
	local owned = trailFolder:FindFirstChild("Owned")
	local level = trailFolder:FindFirstChild("Level")
	local xp = trailFolder:FindFirstChild("XP")
	local tier = trailFolder:FindFirstChild("Tier")
	
	if not owned or not level or not xp or not tier then return end
	if not owned.Value then return end
	
	local config = getTrailConfig(trailName)
	if not config then return end
	
	local tierData = config.Tiers[tier.Value]
	if not tierData then return end
	
	if level.Value >= tierData.MaxLevel then
		sendTrailData(player, trailName)
		return
	end
	
	local xpNeeded = getXPNeeded(level.Value)
	
	if not XPModule.hasXP(player, xpNeeded) then
		sendTrailData(player, trailName)
		return
	end
	
	XPModule.removeXP(player, xpNeeded)
	level.Value += 1
	
	updateTrailStats(player, trailName)
	applyEquippedVisualTrail(player)
	sendTrailData(player, trailName)
	
	print(player.Name .. " повысил уровень " .. trailName .. " до " .. level.Value)
end)

closeTrailMenuEvent.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	hrp.CFrame = backPart.CFrame + Vector3.new(0, 3, 0)
end)



Players.PlayerAdded:Connect(function(player)
	setupBlueTrail(player)
	
	task.delay(4, function()
		if not player.Parent then return end 
		
		setupBlueTrail(player)
		updateTrailStats(player, "BlueTrail")
		applyEquippedVisualTrail(player)
	end)
	
	player.CharacterAdded:Connect(function()
		task.wait(4)
		updateTrailStats(player, "BlueTrail")
		applyEquippedVisualTrail(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupBlueTrail(player)
	updateTrailStats(player, "BlueTrail")
	
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		applyEquippedVisualTrail(player)
	end)
end

print("TrailServer loaded")
