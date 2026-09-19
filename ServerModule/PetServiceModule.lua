--// PetServiceModule

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetModule = require(ReplicatedStorage.Modules.PetModule)

local PetServiceModule = {}

local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function createValue(parent, className, name, value)
	local object = Instance.new(className)
	object.Name = name
	object.Value = value
	object.Parent = parent
	
	return object
end

function PetServiceModule.GetStorageCount(player)
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return 0 end
	
	local count = 0
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then count += 1 end
	end
	return count
end

function PetServiceModule.GetMaxStorage(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return PetModule.DEFAULT_MAX_STORAGE end
	
	local maxStorage = playerData:FindFirstChild("MaxStorage")
	if not maxStorage then return PetModule.DEFAULT_MAX_STORAGE end
	
	return maxStorage.Value
end

function PetServiceModule.GetFreeStorage(player)
	local maxStorage = PetServiceModule.GetMaxStorage(player)
	local currentStorage = PetServiceModule.GetMaxStorage(player)
	
	return math.max(0, maxStorage - currentStorage)
end

function PetServiceModule.IsStorageFull(player)
	return PetServiceModule.GetFreeStorage(player) <= 0
end


function PetServiceModule.CreatePet(player, petName, pattern, tier)
	if not player or not player:IsA("Player") then return nil, "InvalidPlayer" end
	
	if player:GetAttribute("DataReady") ~= true then return nil, "DataNotReady" end
	
	local petConfig = PetModule.GetPetConfig(petName)
	if not petConfig then return nil, "UncknownPet" end
	
	if PetServiceModule.IsStorageFull(player) then return nil, "StorageFull" end
	
	pattern = math.clamp(
		math.floor(tonumber(pattern) or PetModule.MIN_PATTERN),
		PetModule.MIN_PATTERN,
		PetModule.MAX_PATTERN
	)
	
	tier = math.floor(tonumber(tier) or 0)
	
	if not PetModule.GetTierConfig(tier) then tier = 0 end
	
	local petsFolder = getOrCreateFolder(player, "Pets")
	local petId = "Pet_" .. HttpService:GenerateGUID(false)
	
	local petFolder = Instance.new("Folder")
	petFolder.Name = petId
	petFolder.Parent = petsFolder
	
	createValue(petFolder, "StringValue", "PetName", petName)
	createValue(petFolder, "IntValue", "Pattern", pattern)
	createValue(petFolder, "IntValue", "Tier", tier)
	createValue(petFolder, "IntValue", "Level", 0)
	createValue(petFolder, "BoolValue", "Equipped", false)
	
	return petFolder, nil
end

return PetServiceModule