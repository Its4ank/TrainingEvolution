local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoostModule = require(game.ServerScriptService.Modules.BoostModule)

local boostEventFolder = ReplicatedStorage:WaitForChild("BoostEvent")
local boostUIEvent = boostEventFolder:WaitForChild("BoostUIEvent")

local trainerEvent = ReplicatedStorage:WaitForChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:WaitForChild("PlayerDataLoadedEvent")

local TEST_BOOSTS_ENABLED = false

local TEST = {
	TimeBoost = true,
	TopBoost = true,
	EnergyPotion = true,
	MoneyPotion = true,
	LuckPotion = true,
	ServerPotion = true,
}



local function updateTopBadge(player, topPlace)
	local character = player.Character
	if not character then return end
	
	local head = character:FindFirstChild("Head")
	if not head then return end
	
	local oldBadge = head:FindFirstChild("Top1Badge")
	
	if topPlace == 1 then
		if oldBadge then return end
		
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Top1Badge"
		billboard.Size = UDim2.new(0, 70, 0, 70)
		billboard.StudsOffset = Vector3.new(0, 2.2, 0)
		billboard.AlwaysOnTop = false
		billboard.MaxDistance = 50
		billboard.Parent = head
		
		local image = Instance.new("ImageLabel")
		image.Name = "BadgeImage"
		image.Size = UDim2.new(1, 0, 1, 0)
		image.BackgroundTransparency = 1
		image.Image = "rbxassetid://128243712611327"
		image.Parent = billboard
	else
		if oldBadge then
			oldBadge:Destroy()
		end
	end
end

local function updateBoostUI(player)
	local topPlace = BoostModule.GetTopPlace(player)
	local timeMultiplier = BoostModule.GetTimeMultiplier(player)
	local personalPotions = BoostModule.GetPersonalPotionBoost(player)
	local serverPotions = BoostModule.GetServerPotionBoost()
	local potionTimeLeft = BoostModule.GetPotionTimeLeft(player)
	
	if TEST_BOOSTS_ENABLED then
		topPlace = nil
		timeMultiplier = 1
		
		personalPotions = {
			Energy = 1,
			Money = 1,
			Luck = 1,
		}
		
		serverPotions = {
			Energy = 1,
			Money = 1,
			Luck = 1,
		}
		
		potionTimeLeft = {
			Personal = {
				Energy = TEST.EnergyPotion and 600 or 0,
				Money = TEST.MoneyPotion and 600 or 0,
				Luck = TEST.LuckPotion and 600 or 0,
			},
			Server = {
				Energy = TEST.ServerPotion and 600 or 0,
				Money = TEST.ServerPotion and 600 or 0,
				Luck = TEST.ServerPotion and 600 or 0,
			},
		}
		
		if TEST.TimeBoost then
			timeMultiplier = 1.23
		end
		
		if TEST.TopBoost then
			topPlace = 1
		end
		
		if TEST.EnergyPotion then
			personalPotions.Energy = 2
		end
		
		if TEST.MoneyPotion then
			personalPotions.Money = 2
		end
		
		if TEST.LuckPotion then
			personalPotions.Luck = 2
		end
		
		if TEST.ServerPotion then
			serverPotions.Energy = 1.5
			serverPotions.Money = 1.5
			serverPotions.Luck = 1.5
		end
	end
	
	updateTopBadge(player, topPlace)
	
	local premiumBoost = BoostModule.GetPremiumBoost(player)
	
	local timePercent = math.max(0, (timeMultiplier - 1) * 100)
	timePercent = math.round(timePercent * 10) / 10
	
	boostUIEvent:FireClient(player, {
		TopPlace = topPlace,
		
		TimeBoost = {
			Active = timeMultiplier > 1,
			Multiplier = timeMultiplier,
			Percent = timePercent,
		},
		
		PersonalPotions = personalPotions,
		ServerPotions = serverPotions,
		PotionTimeLeft = potionTimeLeft,
		PremiumBoost = premiumBoost,
	})
end

task.spawn(function()
	while true do
		task.wait(1)
		
		for _, player in ipairs(Players:GetPlayers()) do
			updateBoostUI(player)
		end
	end
end)

playerDataLoadedEvent.Event:Connect(function(player)
	BoostModule.InitPlayer(player)
end)

local timeBoostLoopStarted = false

function BoostModule.StartTimeBoostLoop()
	if timeBoostLoopStarted then return end
	timeBoostLoopStarted = true
	
	task.spawn(function()
		local previousTick = os.clock()
		
		while true do
			task.wait(1)
			local now = os.clock()
			local elapsed = now - previousTick
			previousTick = now
			local wallNow = os.time()
			
			for _, player in ipairs(Players:GetPlayers()) do
				if player:GetAttribute("DataReady") == true then
					local data = playerTimeBoosts[player.UserId]
					local boostData = getBoostData(player)
					
					if data then
						data.Seconds += elapsed
						local intervals = math.floor(data.Seconds / TIME_BOOST_INTERVAL)
						
						if intervals > 0 then
							data.Seconds -= intervals * TIME_BOOST_INTERVAL
							local bonusValue = boostData and boostData:FindFirstChild("TimeBoostBonus")
							local bonus = math.max(0, bonusValue and bonusValue.Value or 0)
							
							data.Percent = math.clamp(data.Percent + intervals * (TIME_BOOST_PER_INTERVAL + bonus), 0, MAX_TIME_PERCENT)
						end
						
						if boostData then
							local secondsValue = boostData:FindFirstChild("TimeBoostSeconds")
							local percentValue = boostData:FindFirstChild("TimeBoostPercent")
							
							if secondsValue then
								secondsValue.Value = math.floor(data.Seconds)
							end
							
							if percentValue then
								percentValue.Value = data.Percent
							end
						end
					end
					
					local potionData = playerPotionBoosts[player,UserId]
					if potionData then
						for boostType, potionInfo in pairs(potionData) do
							local timerValue = getPotionTimerValue(player, boostType)
							
							if timerValue then
								timerValue.Value = math.max(0, potionInfo.ExpiresAt - wallNow)
							end
						end
					end
				end
			end
		end
	end)
end

print("BoostServer loaded")
