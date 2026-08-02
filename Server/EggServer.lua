--EggServer 1.2v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PetModule = require(game.ServerScriptService.Modules.PetModule)
local BoostModule = require(game.ServerScriptService.Modules.BoostModule)
local TrainerModule = require(game.ReplicatedStorage.Modules.TrainerModule)
local UpgradeModule = require(game.ReplicatedStorage.Modules.UpgradeModule)


-- RemoteEvent
local openEggEvent = ReplicatedStorage:FindFirstChild("OpenEggEvent")
if not openEggEvent then
	openEggEvent = Instance.new("RemoteEvent")
	openEggEvent.Name = "OpenEggEvent"
	openEggEvent.Parent = ReplicatedStorage
end



--Helpers
local function getMoney(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return nil end

	return playerData:FindFirstChild("Money")
end

local function getEggHatched(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return nil end
	
	return playerData:FindFirstChild("EggHatched")
end

--Egg data
local eggData = {
	Egg1 = {
		price = 100,
		pets = {
			{ name = "Dog", chance = 35, rarity = "Common" },
			{ name = "Cow", chance = 25, rarity = "Uncommon" },
			{ name = "Cat", chance = 20, rarity = "Rare" },
			{ name = "Pig", chance = 15, rarity = "Epic" },
			{ name = "Chicken", chance = 5, rarity = "Legendary" },
		}
	},

	Egg2 = {
		price = 500,
		pets = {
			{ name = "FirstPet", chance = 60 },
			{ name = "RarePet", chance = 30 },
			{ name = "EpicPet", chance = 10 },
		}
	},

	Egg3 = {
		price = 1000,
		pets = {
			{ name = "RarePet", chance = 60 },
			{ name = "EpicPet", chance = 30 },
			{ name = "LegendaryPet", chance = 10 },
		}
	},
}



--Roll logic
local function rollPetFromEgg(player, eggName)
	local eggInfo = eggData[eggName]
	if not eggInfo then return nil, nil end
	
	local petLuckBonus = UpgradeModule.GetPetLuckBonus(player)
	
	local boostLuckMultiplier = BoostModule.GetLuckMultiplier(player)
	
	local weightedPets = {}
	local totalWeight = 0
	
	for index, petInfo in ipairs(eggInfo.pets) do
		local rarityPower = index - 1
		
		local finalChance = petInfo.chance
		
		if rarityPower > 0 then
			finalChance *= 1 + (petLuckBonus * rarityPower)
			finalChance *= boostLuckMultiplier
		end
		
		table.insert(weightedPets, {
			name = petInfo.name,
			rarity = petInfo.rarity,
			weight = finalChance,
		})
		
	    totalWeight += finalChance
	end
	
	local roll = math.random() * totalWeight
	local current = 0
	
	for _, petInfo in ipairs(weightedPets) do 
		current += petInfo.weight
		
		if roll <= current then
			return petInfo.name, petInfo.rarity
		end
	end
	
	return weightedPets[1].name, weightedPets[1].rarity
end



-- Main egg actions
local function openEgg(player, eggName)
	local eggInfo = eggData[eggName]
	if not eggInfo then return end 

	local money = getMoney(player)
	if not money then return end 

	if money.Value < eggInfo.price then
		warn(player.Name .. " not enough money for " .. eggName)
		return
	end

	money.Value -= eggInfo.price

	local wonPet, rarity = rollPetFromEgg(player, eggName)
	if not wonPet then
		warn("Failed to roll pet from " .. eggName)
		return
	end
	

	local petFolder, giveError = PetModule.givePet(player, wonPet)
	
	if not petFolder then
		warn("Failed to give pet:", wonPet, giveError)
		money.Value += eggInfo.price
		return false
	end
	
	local eggHatched = getEggHatched(player)
	if eggHatched then
		eggHatched.Value += 1
	end
	
	TrainerModule.addEquippedTrainerProgress(player, "EggHatched", 1)
	
	local rarityRequirement = TrainerModule.getCurrentRequirement(player, "MonikaTrainer", "PetRarity")
	if rarityRequirement and rarityRequirement.Rarity == rarity then
		TrainerModule.addEquippedTrainerProgress(player, "PetRarity", 1)
	end

	print(player.Name, "opened", eggName, "and got", wonPet, "(" .. tostring(rarity) .. ")")
	return true
end

local function openEggMultiple(player, eggName, amount)
	amount = math.floor(tonumber(amount) or 1)
	amount = math.clamp(amount, 1, 3)
	
	for i = 1, amount do
		openEgg(player, eggName)
	end
end



--// Event Connections
openEggEvent.OnServerEvent:Connect(function(player, eggName, amount)
	openEggMultiple(player, eggName, amount)
end)



--Give pet
local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

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



--Connect eggs in workspace
for eggName, _ in pairs(eggData) do
	local egg = workspace:FindFirstChild(eggName)
	if egg then
		local prompt = egg:FindFirstChild("PriximityPrompt")
		if prompt then

			prompt.Triggered:Connect(function(player)
				openEgg(player, eggName)
			end)
		end
	end
end

print("EggServer loaded")
