local Players = game:GetService("Players")

local BoostModule = {}

local USE_FAKE_TOP_PLAYERS = true

local FAKE_TOP_PLAYERS = {
	{ Name = "FakeTop1", Rebirth = 50, Energy = 1000000},
	{ Name = "FakeTop2", Rebirth = 40, Energy = 800000},
	{ Name = "FakeTop3", Rebirth = 30, Energy = 600000},
}

--// Premium Boost
local PREMIUN_BOOST = {
	Energy = 1.25,
	Money = 1.25,
	Luck = 1.25,
}

--// Time Boost
local TIME_BOOST_INTERVAL = 180
local TIME_BOOST_RESET_AFTER = 600
local MAX_TIME_PERCENT = 100
local TIME_BOOST_PER_INTERVAL = 1

local playerTimeBoosts = {}
local playerLeaveTimes = {}

--// Potion Boost
local POTION_DURATIONS = { 
	Energy = 900, 
	Money = 900, 
	Luck = 1200,
	Server = 1200,
}

local PERSONAL_POTION_MULTIPLIER = 2
local SERVER_POTION_MULTIPLIER = 1.5

local playerPotionBoosts = {}
local serverPotionBoosts = {
	Energy = {
		Multiplier = 1,
		ExpiresAt = 0,
	},
	
	Money = {
		Multiplier = 1,
		ExpiresAt = 0,
	},
	
	Luck = {
		Multiplier = 1,
		ExpiresAt = 0,
	},
}

local MAX_TIME_PERCENT = 100
local TIME_BOOST_PER_MINUTE = 1

--// Top Boost
local TOP_BOOST = {
	[1] = 1.30,
	[2] = 1.20,
	[3] = 1.10,
}



--// Helper Functions
local function getBoostData(player)
	return player:FindFirstChild("BoostData")
end

local function getDefaultPotionBoosts()
	return {
		Energy = {
			Multiplier = 1,
			ExpiresAt = 0,
		},

		Money = {
			Multiplier = 1,
			ExpiresAt = 0,
		},

		Luck = {
			Multiplier = 1,
			ExpiresAt = 0,
		},
	}
end

local function getOrCreateValue(parent, ClassName, name, defaultValue)
	local value = parent:FindFirstChild(name)
	if not value then
		value = Instance.new(ClassName)
		value.Name = name
		value.Value = defaultValue
		value.Parent = parent
	end
	return value
end

function BoostModule.AddTimeBoostBonus(player, amount)
	local boostData = player:FindFirstChild("BoostData")
	if not boostData then 
		boostData = Instance.new("Folder")
		boostData.Name = "BoostData"
		boostData.Parent = player
	end
	
	local bonus = getOrCreateValue(boostData, "NumberValue", "TimeBoostBonus", 0)
	bonus.Value += amount
	
	return bonus.Value 
end

function BoostModule.GetPremiumBoost(player)
	if player.MembershipType == Enum.MembershipType.Premium then
		return PREMIUN_BOOST
	end
	
	return {
		Energy = 1,
		Money = 1,
		Luck = 1,
	}
end

local function getPotionTimerValue(player, boostType)
	local potionTimers = player:FindFirstChild("PotionTimers")
	if not potionTimers then return nil end
	
	return potionTimers:FindFirstChild(boostType .. "PotionTimeLeft")
end

function BoostModule.ActivatePersonalPotion(player, boostType)
	local userId = player.UserId
	
	if not playerPotionBoosts[userId] then
		playerPotionBoosts[userId] = getDefaultPotionBoosts()
	end
	
	local potionData = playerPotionBoosts[userId][boostType]
	if not potionData then
		warn("Unknown personal potion type:", boostType)
		return
	end
	
	local now = os.time()
	local currentTimeLeft = math.max(0, potionData.ExpiresAt - now)
	local duration = POTION_DURATIONS[boostType] or 900
	
	potionData.Multiplier = PERSONAL_POTION_MULTIPLIER
	potionData.ExpiresAt = now + currentTimeLeft + duration
	
	local timerValue = getPotionTimerValue(player, boostType)
	if timerValue then
		timerValue.Value = currentTimeLeft + duration
	end
end

function BoostModule.ActivateServerPotion()
	local now = os.time()
	local duration = POTION_DURATIONS.Server
	
	for boostType, potionData in pairs(serverPotionBoosts) do
		potionData.Multiplier = SERVER_POTION_MULTIPLIER
		
		if potionData.ExpiresAt > now then
			potionData.ExpiresAt += duration
		else
			potionData.ExpiresAt = now + duration
		end
	end
end

function BoostModule.InitPlayer(player)
	local userId = player.UserId
	local now = os.time()
	
	local boostData = getBoostData(player)
	local savedSeconds = 0
	local savedPercent = 0
	local savedLastLeave = 0
	
	if boostData then
		local secondsValue = boostData:FindFirstChild("TimeBoostSeconds")
		local percentValue = boostData:FindFirstChild("TimeBoostPercent")
		local lastLeaveValue = boostData:FindFirstChild("LastLeaveTime")
		
		if secondsValue then savedSeconds = secondsValue.Value end 
		if percentValue then savedPercent = percentValue.Value end
		if lastLeaveValue then savedLastLeave = lastLeaveValue.Value end
	end
	
	if savedLastLeave > 0 and now - savedLastLeave > TIME_BOOST_RESET_AFTER then
		playerTimeBoosts[userId] = { 
			Seconds = 0,
			Percent = 0,
		}
	else
		playerTimeBoosts[userId] = {
			Seconds = savedSeconds,
			Percent = savedPercent,
		}
	end
	
	if not playerPotionBoosts[userId] then
		playerPotionBoosts[userId] = getDefaultPotionBoosts()
	end
	
	local potionTimers = player:FindFirstChild("PotionTimers")
	if potionTimers then
		local data = playerPotionBoosts[userId]
		
		local timerMap = { 
			Energy = "EnergyPotionTimeLeft",
			Money = "MoneyPotionTimeLeft",
			Luck = "LuckPotionTimeLeft",
		}
		
		for boostType, timerName in pairs(timerMap) do
			local timerValue = potionTimers:FindFirstChild(timerName)
			
			if timerValue and timerValue.Value > 0 then
				data[boostType].Multiplier = PERSONAL_POTION_MULTIPLIER
				data[boostType].ExpiresAt = now + timerValue.Value
			end
		end
	end
end

function BoostModule.RemovePlayer(player)
	local userId = player.UserId
	
	playerLeaveTimes[userId] = os.time()
	
	task.delay(TIME_BOOST_RESET_AFTER, function()
		if not Players:GetPlayerByUserId(userId) then
			playerTimeBoosts[player.UserId] = nil
			playerLeaveTimes[userId] = nil
		end
	end)
	
	local boostData = getBoostData(player)
	if boostData then
		local lastLeaveValue = boostData:FindFirstChild("LastLeaveTime")
		local secondsValue = boostData:FindFirstChild("TimeBoostSeconds")
		local percentValue = boostData:FindFirstChild("TimeBoostPercent")
		local data = playerTimeBoosts[userId]
		
		if data then 
			if secondsValue then secondsValue.Value = data.Seconds end
			if percentValue then percentValue.Value = data.Percent end
		end
		
		if lastLeaveValue then
			lastLeaveValue.Value = os.time()
		end
	end
end

function BoostModule.StartTimeBoostLoop()
	task.spawn(function()
		while true do
			task.wait(1)
			
			for _, player in ipairs(Players:GetPlayers()) do
				local data = playerTimeBoosts[player.UserId]
				
				if data then
					data.Seconds += 1
					
					if data.Seconds >= TIME_BOOST_INTERVAL then
						data.Seconds = 0
						
						local bonus = 0
						local boostData = getBoostData(player)
						
						if boostData then 
							local bonusValue = boostData:FindFirstChild("TimeBoostBonus")
							if bonusValue then 
								bonus = bonusValue.Value
							end
						end
						
						data.Percent = math.clamp(
							data.Percent + TIME_BOOST_PER_INTERVAL + bonus, 
							0,
							MAX_TIME_PERCENT
						)
					end
					
					local boostData = getBoostData(player)
					if boostData then
						local secondsValue = boostData:FindFirstChild("TimeBoostSeconds")
						local percentValue = boostData:FindFirstChild("TimeBoostPercent")
						
						if secondsValue then
							secondsValue.Value = data.Seconds
						end
						
						if percentValue then
							percentValue.Value = data.Percent
						end
					end
				end
				
				local potionData = playerPotionBoosts[player.UserId]
				if potionData then
					for boostType, potionInfo in pairs(potionData) do
						local timerValue = getPotionTimerValue(player, boostType)
						if timerValue then
							timerValue.Value = math.max(0, potionInfo.ExpiresAt - os.time())
						end
					end
				end
			end
		end
	end)
end

function BoostModule.GetTimeMultiplier(player)
	local data = playerTimeBoosts[player.UserId]
	if not data then 
		return 1
	end
	return 1 + (data.Percent / 100)
end

function BoostModule.GetTopPublicBoost(player)
	local rankedGroups = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		local leaderstats = plr:FindFirstChild("leaderstats")
		if leaderstats then
			local rebirth = leaderstats:FindFirstChild("Rebirth")
			local energy = leaderstats:FindFirstChild("Energy")

			if rebirth and energy then
				local rebirthValue = rebirth.Value

				if not rankedGroups[rebirthValue] then
					rankedGroups[rebirthValue] = {}
				end

				table.insert(rankedGroups[rebirthValue], {
					Player = plr,
					Energy = energy.Value,
					Rebirth = rebirthValue,
				})
			end
		end
	end

	local rebirthValues = {}

	for rebirthValue, _ in pairs(rankedGroups) do
		table.insert(rebirthValues, rebirthValue)
	end

	table.sort(rebirthValues, function(a, b)
		return a > b
	end)

	for place, rebirthValue in ipairs(rebirthValues) do
		local group = rankedGroups[rebirthValue]

		for _, data in ipairs(group) do
			if data.Player == player then
				local energyBoost = TOP_BOOST[place] or 1

				return {
					Energy = energyBoost,
					Money = 1,
					Luck = 1,
				}
			end
		end
	end

	return {
		Energy = 1,
		Money = 1,
		Luck = 1,
	}
end

function BoostModule.GetPersonalPotionBoost(player)
	local userId = player.UserId 
	local data = playerPotionBoosts[userId] 
	
	
	if not data then
		return {
			Energy = 1,
			Money = 1,
			Luck = 1,
		}
	end
	
	local now = os.time()
	
	local result = {
		Energy = 1,
		Money = 1,
		Luck = 1,
	}
	
	for boostType, potionData in pairs(data) do
		if potionData.ExpiresAt > now then
			result[boostType] = potionData.Multiplier
		else
			potionData.Multiplier = 1
			potionData.ExpiresAt = 0
		end
	end
	return result
end

function BoostModule.GetServerPotionBoost()
	local now = os.time()
	
	local result = {
		Energy = 1,
		Money = 1,
		Luck = 1,
	}
	
	for boostType, potionData in pairs(serverPotionBoosts) do
		if potionData.ExpiresAt > now then
			result[boostType] = potionData.Multiplier
		else
			potionData.Multiplier = 1
			potionData.ExpiresAt = 0
		end
	end
	return result
end

function BoostModule.SetPersonalPotionBoost(player, boostType, multiplier)
	local data = playerPotionBoosts[player.UserId]
	if not data then
		data = getDefaultPotionBoosts()
		playerPotionBoosts[player.UserId] = data
	end
	
	if data[boostType] then
		data[boostType] = multiplier
	end
end

function BoostModule.GetPotionTimeLeft(player)
	local now = os.time()
	local userId = player.UserId
	
	local personalData = playerPotionBoosts[userId]
	local personalTimeLeft = {
		Energy = 0,
		Money = 0,
		Luck = 0,
	}
	
	if personalData then
		for boostType, potionData in pairs(personalData) do
			personalTimeLeft[boostType] = math.max(0, potionData.ExpiresAt - now)
		end
	end
	
	local serverTimeLeft = {
		Energy = 0,
		Money = 0,
		Luck = 0,
	}
	
	for boostType, potionData in pairs(serverPotionBoosts) do
		serverTimeLeft[boostType] = math.max(0, potionData.ExpiresAt - now)
	end
	
	return {
		Personal = personalTimeLeft,
		Server = serverTimeLeft,
	}
end

function BoostModule.GetTopPlace(player)
	local rankedGroups = {}
	
	for _, plr in ipairs(Players:GetPlayers()) do
		local leaderstats = plr:FindFirstChild("leaderstats")
		if leaderstats then
			local rebirths = leaderstats:FindFirstChild("Rebirth")
			
			if rebirths then
				local rebirthsValue = rebirths.Value
				
				if not rankedGroups[rebirthsValue] then
					rankedGroups[rebirthsValue] = {}
				end
				
				table.insert(rankedGroups[rebirthsValue], plr)
			end
		end
	end
	
	local rebierhValues = {}
	
	for rebierthValue, _ in pairs(rankedGroups) do
		table.insert(rebierhValues, rebierthValue)
	end
	
	table.sort(rebierhValues, function(a, b)
		return a > b
	end)
	
	for place, rebirthValue in ipairs(rebierhValues) do
		local group = rankedGroups[rebirthValue]
		
		for _, plr in ipairs(group) do
			if plr == player then
				return place
			end
		end
	end
	return nil
end

function BoostModule.GetEnergyMultiplier(player)
	local topBoost = BoostModule.GetTopPublicBoost(player)
	local timeBoost = BoostModule.GetTimeMultiplier(player)
	local potionBoost = BoostModule.GetPersonalPotionBoost(player)
	local serverBoost = BoostModule.GetServerPotionBoost()
	local premiumBoost = BoostModule.GetPremiumBoost(player)
	
	return topBoost.Energy * timeBoost * potionBoost.Energy * serverBoost.Energy * premiumBoost.Energy
end

function BoostModule.GetMoneyMultiplier(player)
	local topBoost = BoostModule.GetTopPublicBoost(player)
	local timeBoost = BoostModule.GetTimeMultiplier(player)
	local potionBoost = BoostModule.GetPersonalPotionBoost(player)
	local serverBoost = BoostModule.GetServerPotionBoost()
	local premiumBoost = BoostModule.GetPremiumBoost(player)
	
	return topBoost.Money * timeBoost * potionBoost.Money * serverBoost.Money * premiumBoost.Money
end

function BoostModule.GetLuckMultiplier(player)
	local topBoost = BoostModule.GetTopPublicBoost(player)
	local timeBoost = BoostModule.GetTimeMultiplier(player)
	local potionBoost = BoostModule.GetPersonalPotionBoost(player)
	local serverBoost = BoostModule.GetServerPotionBoost()
	
	return topBoost.Luck * timeBoost * potionBoost.Luck * serverBoost.Luck
end

return BoostModule
