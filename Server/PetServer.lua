--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PetModule = require(game.ServerScriptService.Modules.PetModule)



-- RemoteEvent
local petEquipLimitEvent = ReplicatedStorage:FindFirstChild("PetEquipLimitEvent")
local petEquipEvent = ReplicatedStorage:FindFirstChild("PetEquipEvent")
local petDeleteEvent = ReplicatedStorage:FindFirstChild("PetDeleteEvent")
local petUnequipAllEvent = ReplicatedStorage:FindFirstChild("PetUnequipAllEvent")
local petEquipBestEvent = ReplicatedStorage:FindFirstChild("PetEquipBestEvent")
local trainerEvent = ReplicatedStorage:FindFirstChild("TrainerEvent")
local playerDataLoadedEvent = trainerEvent:FindFirstChild("PlayerDataLoadedEvent")

if not petEquipEvent then
	petEquipEvent = Instance.new("RemoteEvent")
	petEquipEvent.Name = "PetEquipEvent"
	petEquipEvent.Parent = ReplicatedStorage
end

if not petDeleteEvent then
	petDeleteEvent = Instance.new("RemoteEvent")
	petDeleteEvent.Name = "PetDeleteEvent"
	petDeleteEvent.Parent = ReplicatedStorage
end

if not petUnequipAllEvent then
	petUnequipAllEvent = Instance.new("RemoteEvent")
	petUnequipAllEvent.Name = "PetUnequipAllEvent"
	petUnequipAllEvent.Parent = ReplicatedStorage
end

if not petEquipBestEvent then
	petEquipBestEvent = Instance.new("RemoteEvent")
	petEquipBestEvent.Name = "PetEquipBestEvent"
	petEquipBestEvent.Parent = ReplicatedStorage
end



--Helpers
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

local function getEquippedPetsCount(player)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return 0 end
	
	local count = 0
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local owned = petFolder:FindFirstChild("Owned")
		local equipped = petFolder:FindFirstChild("Equipped")
		
		if owned and equipped and owned.Value and equipped.Value then
			count += 1
		end
	end
	
	return count
end

local function getMaxEquippedPets(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return 3 end
	
	local maxEquippedPets = playerData:FindFirstChild("MaxEquippedPets")
	if not maxEquippedPets then return 3 end
	
	return maxEquippedPets.Value
end

local function getPetDisplayName(petFolder)
	local petNameValue = petFolder:FindFirstChild("PetName")

	if petNameValue then
		return petNameValue.Value
	end
	return petFolder.Name
end



--Pet config helpers
local function getFuseName(tier)
	if tier == 0 then return "Normal" end 
	if tier == 1 then return "Big" end 
	if tier == 2 then return "Silver" end 
	if tier == 3 then return "Gold" end 
	if tier == 4 then return "Rainbow" end 
	if tier == 5 then return "Legend" end 
	return "Unknown"
end



--Setup pets
local function setupPets(player)
	local petsFolder = getOrCreateFolder(player, "Pets")
end



--XP logic
local function givePetXP(player, amount)
	local pet = PetModule.getEquippedPet(player)
	if not pet then return end

	local owned = pet:FindFirstChild("Owned")
	local equipped = pet:FindFirstChild("Equipped")
	local level = pet:FindFirstChild("Level")
	local xp = pet:FindFirstChild("XP")
	local maxLevel = pet:FindFirstChild("MaxLevel")

	if not owned or not equipped or not level or not xp or not maxLevel then
		return
	end

	if not owned.Value or not equipped.Value then
		return
	end

	if level.Value >= maxLevel.Value then
		return
	end

	xp.Value += amount

	while level.Value < maxLevel.Value do 
		local needed = PetModule.getPetXPRequired(level.Value)
		if xp.Value < needed then
			break
		end

		xp.Value -= needed
		level.Value += 1
	end

	if level.Value >= maxLevel.Value then
		level.Value = maxLevel.Value
		xp.Value = 0
	end

	PetModule.updatePetMultipliers(pet)
end



--Pet visuals
local function removePetVisuals(character)
	for _, child in ipairs(character:GetChildren()) do
		if child.Name:match("^PetVisual_") then
			child:Destroy()
		end
	end
end

local function updatePetVisual(player)
	local character = player.Character
	if not character then
		warn("PetVisual: no character")
		return
	end

	removePetVisuals(character)

	local equippedPets = PetModule.getEquippedPets(player)
	if #equippedPets == 0 then
		warn("PetVisual: no equipped pets")
		return
	end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		warn("PetVisual: no HumanoidRootPart")
		return
	end
	
	for index, pet in ipairs(equippedPets) do
		local petTemplate = game.ReplicatedStorage
		:WaitForChild("PetPreviewModels")
		:WaitForChild("Earth")
		:WaitForChild("Egg1")
		:FindFirstChild(getPetDisplayName(pet))
	
	if not petTemplate then
			warn("PetVisual: no template for", getPetDisplayName(pet))
		continue
	end
	
	local clone = petTemplate:Clone()
	clone.Name = "PetVisual_" .. tostring(index)
	clone.Parent = character
	
	local rootPart = clone:FindFirstChild("RootPart", true)
	if not rootPart then
		warn("PetVisual: no RootPart inside clone")
		clone:Destroy()
		continue
	end
	
	for _, obj in ipairs(clone:GetDescendants()) do 
		if obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
			obj.Massless = true
		end
	end
	
	local startOffsets = {
		Vector3.new(-3, -1.5, 4),
		Vector3.new(0, -1.5, 4),
		Vector3.new(3, -1.5, 4),
	}
	
	local offset = startOffsets[index] or Vector3.new(0, -1.5, 4)
	clone:PivotTo(CFrame.new((hrp.CFrame * CFrame.new(offset)).Position))
	end
	
	print("PetVisuals created:", #equippedPets)
end

local MAX_EQUIPPED_PETS = 3

local function followPet(player)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		warn("FollowPet: no HRP")
		return
	end
	
	task.spawn(function()
		while character.Parent and hrp.Parent do
			local equippedPets = PetModule.getEquippedPets(player)
			if #equippedPets == 0 then
				break
			end
			
			local offset = {
				Vector3.new(-3, -1.5, 4),
				Vector3.new(0, -1.5, 4),
				Vector3.new(3, -1.5, 4),
			}
			
			for index = 1, MAX_EQUIPPED_PETS do
				local petVisual = character:FindFirstChild("PetVisual_" .. tostring(index))
				if petVisual then
					local offset = offset[index] or Vector3.new(0, -1.5, 4)
					local targetPos = (hrp.CFrame * CFrame.new(offset)).Position
					
					local t = tick()
					targetPos += Vector3.new(0, math.sin(t * 3 + index) * 0.5, 0)
					
					local currentPos = petVisual:GetPivot().Position
					local newPos = currentPos:Lerp(targetPos, 0.1)
					
					petVisual:PivotTo(CFrame.new(newPos, hrp.Position) * CFrame.Angles(0, math.rad(180), 0))
				end
			end
			
			task.wait(0.03)
		end
	end)
end



--Equip/Unequip logic
local function setPetEquipped(player, petName, shouldEquip)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return end

	local petFolder = petsFolder:FindFirstChild(petName)
	if not petFolder then return end

	local owned = petFolder:FindFirstChild("Owned")
	local equipped = petFolder:FindFirstChild("Equipped")

	if not owned or not equipped or not owned.Value then return end
	
	if shouldEquip then
		if equipped.Value then
			return
		end
		
		local equippedCount = getEquippedPetsCount(player)
		if equippedCount >= getMaxEquippedPets(player) then
			if petEquipLimitEvent then
				petEquipLimitEvent:FireClient(player, "Maximum 3 pets equipped")
			end
			
			warn(player.Name .. " trieed to equip more than 3 pets")
			return
		end
		
		equipped.Value = true
	else
		equipped.Value = false
	end

	updatePetVisual(player)
	followPet(player)
end

local function unequipAllPets(player)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return end
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local equipped = petFolder:FindFirstChild("Equipped")
		
		if equipped then
			equipped.Value = false
		end
	end
	
	updatePetVisual(player)
end

local function equipBestPets(player)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return end
	
	local petList = {}
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local owned = petFolder:FindFirstChild("Owned")
		local equipped = petFolder:FindFirstChild("Equipped")
		local energyMultiplier = petFolder:FindFirstChild("EnergyMultiplier")
		
		if owned and equipped and energyMultiplier and owned.Value then
			table.insert(petList, {
				Folder = petFolder,
				Power = energyMultiplier.Value
			})
			
			equipped.Value = false
		end
	end
	
	table.sort(petList, function(a, b)
		return a.Power > b.Power
	end)
	
	local maxEquippedPets = getMaxEquippedPets(player)
	
	for i = 1, math.min(maxEquippedPets, #petList) do
		petList[i].Folder.Equipped.Value = true
	end
	
	updatePetVisual(player)
	followPet(player)
end

local function deletePets(player, petIds)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return end
	
	if typeof(petIds) ~= "table" then return end
	
	for _, petId in ipairs(petIds) do
		local petFolder = petsFolder:FindFirstChild(petId)
		
		if petFolder and petFolder:IsA("Folder") then
			local equipped = petFolder:FindFirstChild("Equipped")
			
			if equipped and equipped.Value == true then
				warn("Cannot delete equipped pet:, petFolder.Name")
			else
				petFolder:Destroy()
			end
		end
	end
	
	updatePetVisual(player)
	followPet(player)
end



--Event connections
petEquipEvent.OnServerEvent:Connect(function(player, petName, shouldEquip)
	setPetEquipped(player, petName, shouldEquip)
end)

petDeleteEvent.OnServerEvent:Connect(function(player, petIds)
	deletePets(player, petIds)
end)

petUnequipAllEvent.OnServerEvent:Connect(function(player)
	unequipAllPets(player)
end)

petEquipBestEvent.OnServerEvent:Connect(function(player)
	equipBestPets(player)
end)


--Player setup
Players.PlayerAdded:Connect(function(player)
	setupPets(player)

	player.CharacterAdded:Connect(function()
		task.wait(1)
		updatePetVisual(player)
		followPet(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupPets(player)

	player.CharacterAdded:Connect(function()
		task.wait(1)
		updatePetVisual(player)
		followPet(player)
	end)

	if player.Character then
		task.wait(1)
		updatePetVisual(player)
		followPet(player)
	end
end

playerDataLoadedEvent.Event:Connect(function(player)
	task.wait(0.5)
	
	updatePetVisual(player)
	followPet(player)
end)

print("PetServer loaded")
