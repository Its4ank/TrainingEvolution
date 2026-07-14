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
	
	boostUIEvent:FireClient(player, {
		TopPlace = topPlace,
		
		TimeBoost = {
			Active = timeMultiplier > 1,
			Multiplier = timeMultiplier,
			Percent = math.floor((timeMultiplier - 1) * 100),
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

Players.PlayerRemoving:Connect(function(player)
	BoostModule.RemovePlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	BoostModule.InitPlayer(player)
end

BoostModule.StartTimeBoostLoop()

print("BoostServer loaded")
