local PetModule = {}

local DEFAULT_MAX_PET_STORAGE = 50

local PET_STATS = { 
	Dog = { 
		Energy = 1.10,
		Money = 1.05,
		XP = 1.00,
	},
	
	Caw = { 
		Energy = 1.15,
		Money = 1.10,
		XP = 1.00,
	},
	
	Cat = { 
		Energy = 1.20,
		Money = 1.15,
		XP = 1.00,
	},
	
	Pig = { 
		Energy = 1.25,
		Money = 1.20,
		XP = 1.00,
	},
	
	Chicken = { 
		Energy = 1.30,
		Money = 1.25,
		XP = 1.00,
	},
	
	Reaper = { 
		Energy = 2.00,
		Money = 1.4,
		XP = 1.25,
	},
	
	DualReaper = { 
		Energy = 2.5,
		Money = 1.75,
		XP = 1.5,
	},
	
	["Huge Queen"] = { 
		Energy = 3.00,
		Money = 2.50,
		XP = 2.00,
	},
}

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

function PetModule.getPetStorageCount(player)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return 0 end 
	
	local count = 0
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			count += 1
		end
	end
	return count
end

function PetModule.getMaxStorage(player)
	local playerData = getOrCreateFolder(player, "PlayerData")
	local maxPetStorage = getOrCreateValue(playerData, "IntValue", "MaxPetStorage", DEFAULT_MAX_PET_STORAGE)
	return maxPetStorage.Value
end

function PetModule.addPetStorage(player, amount)
	local playerData = getOrCreateFolder(player, "PlayerData")
	local maxPetStorage = getOrCreateValue(playerData, "IntValue", "MaxPetStorage", DEFAULT_MAX_PET_STORAGE)
	maxPetStorage.Value += amount
	return maxPetStorage.Value
end

function PetModule.isPetStorageFull(player)
	return PetModule.getPetStorageCount(player) >= PetModule.getMaxStorage(player)
end



--Pet data helpers
function PetModule.getEquippedPet(player)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return nil end 
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local owned = petFolder:FindFirstChild("Owned")
		local equipped = petFolder:FindFirstChild("Equipped")
		
		if owned and equipped and owned.Value and equipped.Value then
			return petFolder
		end
	end
	
	return nil
end

function PetModule.getEquippedPets(player)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return {} end 
	
	local equippedPets = {}
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local owned = petFolder:FindFirstChild("Owned")
		local equipped = petFolder:FindFirstChild("Equipped")
		
		if owned and equipped and owned.Value and equipped.Value then
			table.insert(equippedPets, petFolder)
		end
	end
	
	return equippedPets
end

function PetModule.getPetXPRequired(level)
	return 10 + (level * 5)
end



--Multiplier logic
function PetModule.updatePetMultipliers(pet)
	local petNameValue = pet:FindFirstChild("PetName")
	local fuseTier = pet:FindFirstChild("FuseTier")
	local level = pet:FindFirstChild("Level")
	local energyMultiplier = pet:FindFirstChild("EnergyMultiplier")
	local moneyMultiplier = pet:FindFirstChild("MoneyMultiplier")
	local xpMultiplier = pet:FindFirstChild("XPMultiplier")
	
	if not petNameValue or not fuseTier or not level or not energyMultiplier or not moneyMultiplier or not xpMultiplier then
		return
	end
	
	local petName = petNameValue.Value
	local tier = fuseTier.Value
	local lvl = level.Value
	
	local stats = PET_STATS[petName]
	if not stats then 
		stats = {
			Energy = 1,
			Money = 1,
			XP = 1,
		}
	end
	
	local fuseMultipliers = {
		[0] = 1,
		[1] = 1.25,
		[2] = 1.5,
		[3] = 2,
		[4] = 2.5,
		[5] = 3,
	}
	
	local fuseMultiplier = fuseMultipliers[tier] or 1
	
	energyMultiplier.Value = (stats.Energy * fuseMultiplier) + (lvl * 0.10)
	moneyMultiplier.Value = (stats.Money * fuseMultiplier) + (lvl * 0.05)
	xpMultiplier.Value = (stats.XP * fuseMultiplier) + (lvl * 0.0)
end



--XP logic
function PetModule.givePetXP(player, amount)
	local equippedPets = PetModule.getEquippedPets(player)
	if not equippedPets or #equippedPets == 0 then return end
	
	for _, pet in ipairs(equippedPets) do
		local owned = pet:FindFirstChild("Owned")
		local equipped = pet:FindFirstChild("Equipped")
		local level = pet:FindFirstChild("Level")
		local xp = pet:FindFirstChild("XP")
		local maxLevel = pet:FindFirstChild("MaxLevel")
		
		if owned and equipped and level and xp and maxLevel then
			if owned.Value and equipped.Value and level.Value < maxLevel.Value then
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
		end
	end
end



--Pet creation
function PetModule.givePet(player, petName)
	local petsFolder = getOrCreateFolder(player, "Pets")
	if PetModule.isPetStorageFull(player) then
		warn(player.Name .. " Pet storage is full")
		return nil, "StorageFull"
	end
	
	local petId = "Pet_" .. tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
	
	
	local petFolder = Instance.new("Folder")
	petFolder.Name = petId
	petFolder.Parent = petsFolder
	
	getOrCreateValue(petFolder, "StringValue", "PetName", petName)
	getOrCreateValue(petFolder, "BoolValue", "Owned", true)
	getOrCreateValue(petFolder, "BoolValue", "Equipped", false)
	getOrCreateValue(petFolder, "IntValue", "Level", 0)
	getOrCreateValue(petFolder, "IntValue", "XP", 0)
	getOrCreateValue(petFolder, "IntValue", "MaxLevel", 25)
	getOrCreateValue(petFolder, "IntValue", "FuseTier", 0)
	
	local energyMultiplier = getOrCreateValue(petFolder, "NumberValue", "EnergyMultiplier", 1)
	local moneyMultiplier = getOrCreateValue(petFolder, "NumberValue", "MoneyMultiplier", 1)
	local xpMultiplier = getOrCreateValue(petFolder, "NumberValue", "XPMultiplier", 1)

	local owned = petFolder:FindFirstChild("Owned")
	if owned then
		owned.Value = true
	end

	-- Базовые статы по имени пета
	local stats = PET_STATS[petName]
	if stats then 
		energyMultiplier.Value = stats.Energy
		moneyMultiplier.Value = stats.Money
		xpMultiplier.Value = stats.XP
	else 
		energyMultiplier.Value = 1 
		moneyMultiplier.Value = 1 
		xpMultiplier.Value = 1 
	end
	
	PetModule.updatePetMultipliers(petFolder)
	
	return petFolder
end

return PetModule
