--// PetUI LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)
local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")

local petsFolderUI = guiFolder:WaitForChild("PetsFolder")
local UIBalance = guiFolder:WaitForChild("UIBalance")

local petEquipEvent = ReplicatedStorage:WaitForChild("PetEquipEvent")
local petEquipLimitEvent = ReplicatedStorage:WaitForChild("PetEquipLimitEvent")
local petDeleteEvent = ReplicatedStorage:FindFirstChild("PetDeleteEvent")
local petUnequipAllEvent = ReplicatedStorage:WaitForChild("PetUnequipAllEvent")
local petEquipBestEvent = ReplicatedStorage:WaitForChild("PetEquipBestEvent")

local petsButton = UIBalance:WaitForChild("PetsButton")
local petsFrame = petsFolderUI:WaitForChild("PetsFrame")
local petDetailsFrame = petsFrame:WaitForChild("PetDetailsFrame")
local buttonListFrame = petsFrame:WaitForChild("ButtonListFrame")
local closePetsFrame = petsFrame:WaitForChild("ClosePetsFrame")

local equipBestButton = buttonListFrame:WaitForChild("EquipBestButton")
local statusEquipLabel = equipBestButton:WaitForChild("StatusEquipLabel")
local deleteButton = petsFrame:WaitForChild("DeleteButton")
local infoDeleteLabel = deleteButton:WaitForChild("InfoDeleteLabel")

local petsContainer = petsFrame:WaitForChild("PetsContainer")
local petButtonTemplate = petsContainer:WaitForChild("PetButtonTemplate")
local equippedCountLabel = petsFrame:WaitForChild("EquippedCountLabel")
local storageCountLabel = petsFrame:WaitForChild("StorageCountLabel")

local petNameLabel = petDetailsFrame:WaitForChild("PetNameLabel")
local petLevelLabel = petDetailsFrame:WaitForChild("PetLevelLabel")
local petXPLabel = petDetailsFrame:WaitForChild("PetXPLabel")
local petFuseLabel = petDetailsFrame:WaitForChild("PetFuseLabel")
local petEnergyLabel = petDetailsFrame:WaitForChild("PetEnergyLabel")
local petMoneyLabel = petDetailsFrame:WaitForChild("PetMoneyLabel")

local equipButton = petDetailsFrame:WaitForChild("EquipPetButton")
local petEquippedLabel = equipButton:WaitForChild("PetEquippedLabel")
local petDetailsViewport = petDetailsFrame:WaitForChild("PetViewport")

local petsFolder = ClientDataModule.GetPets(player)

local maxEquippedPetsValue = ClientDataModule.GetMaxEquippedPets(player)

local petPreviewRoot = ReplicatedStorage:WaitForChild("PetPreviewModels"):WaitForChild("Earth"):WaitForChild("Egg1")

local selectedPetName = nil
local currentPetXPConnection
local currentPetLevelConnection
local deleteMode = false
local equipBestMode = false
local selectedForDelete = {}

MenuManager.register("Pets", petsFrame)

--local MAX_EQUIPPED_PETS = 3
local MAX_PET_STORAGE = 50

petsButton.Visible = true
petDetailsFrame.Visible = false
petButtonTemplate.Visible = false

local PetRarityOrder = {
	Dog = 1,
	Cow = 2,
	Cat = 3,
	Pig = 4,
	Chicken = 5,
}

local function getFuseName(tier)
	if tier == 0 then return "Normal" end
	if tier == 1 then return "Big" end
	if tier == 2 then return "Silver" end
	if tier == 3 then return "Gold" end
	if tier == 4 then return "Rainbow" end
	if tier == 5 then return "Legend" end
	return "Unknown"
end

local function getPetDisplayName(petFolder)
	local petNameValue = petFolder:FindFirstChild("PetName")
	
	if petNameValue then
		return petNameValue.Value
	end
	return petFolder.Name
end

local function setupViewport(viewport, petName, distanceMultiplier)
	viewport:ClearAllChildren()

	local modelTemplate = petPreviewRoot:FindFirstChild(petName)
	if not modelTemplate then
		warn("Pet preview not found:", petName)
		return
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local previewModel = Instance.new("Model")
	previewModel.Name = petName .. "_Preview"
	previewModel.Parent = worldModel

	local copiedParts = {}

	for _, obj in ipairs(modelTemplate:GetDescendants()) do
		if obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("UnionOperation") then
			local clone = obj:Clone()

			for _, child in ipairs(clone:GetDescendants()) do
				if child:IsA("Script") or child:IsA("LocalScript") then
					child:Destroy()
				elseif child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("Motor6D") then
					child:Destroy()
				end
			end

			clone.Anchored = true
			clone.CanCollide = false
			clone.Parent = previewModel
			table.insert(copiedParts, clone)
		end
	end

	if #copiedParts == 0 then return end

	local cf = previewModel:GetBoundingBox()
	local offset = cf.Position

	for _, part in ipairs(copiedParts) do
		part.CFrame = part.CFrame - offset
	end

	local _, newSize = previewModel:GetBoundingBox()
	local biggest = math.max(newSize.X, newSize.Y, newSize.Z)
	local distance = math.max(biggest * distanceMultiplier, 3)

	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	viewport.Ambient = Color3.fromRGB(255, 255, 255)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.LightDirection = Vector3.new(-1, -1, -1)

	camera.CFrame = CFrame.new(
		Vector3.new(0, newSize.Y * 0.25, distance),
		Vector3.new(0, newSize.Y * 0.1, 0)
	)
end

local function updateEquippedCountLabel()
	local equippedCount = 0

	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local owned = petFolder:FindFirstChild("Owned")
		local equipped = petFolder:FindFirstChild("Equipped")

		if owned and equipped and owned.Value and equipped.Value then
			equippedCount += 1
		end
	end

	equippedCountLabel.Text = tostring(equippedCount) .. "/" .. tostring(maxEquippedPetsValue.Value)
end

local function hasEquippedPets()
	for _, petFolder in ipairs(petsFolder:GetChildren()) do 
		local owned = petFolder:FindFirstChild("Owned") 
		local equipped = petFolder:FindFirstChild("Equipped") 
		
		if owned and equipped and owned.Value and equipped.Value then
			return true
		end
	end
	return false
end

local function updateEquipBestButtonText()
	equipBestMode = hasEquippedPets()
	
	if equipBestMode then 
		statusEquipLabel.Text = "UnequipAll"
	else 
		statusEquipLabel.Text = "EquipBest"
	end
end

local function updateStorageCountLabel()
	local count = 0
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			count += 1
		end
	end
	storageCountLabel.Text = "Pets: " .. tostring(count) .. "/" .. tostring(MAX_PET_STORAGE)
end

local function updateDeleteButtonText()
	if deleteMode then 
		infoDeleteLabel.Text = "Confirm Delete"
	else 
		infoDeleteLabel.Text = "Delete"
	end
end

local function isSelectedForDelete(petId)
	return selectedForDelete[petId] == true
end

local function toggleDeleteSelection(petId)
	selectedForDelete[petId] = not selectedForDelete[petId]
end

local function clearDeleteSelection()
	selectedForDelete = {}
end

local function getSelectedDeleteList()
	local list = {}
	
	for petId, seleted in pairs(selectedForDelete) do
		if seleted then
			table.insert(list, petId)
		end
	end
	return list
end

local function updateSelectedPetUI()
	if not selectedPetName then return end

	local petFolder = petsFolder:FindFirstChild(selectedPetName)
	if not petFolder then return end

	local level = petFolder:FindFirstChild("Level")
	local xp = petFolder:FindFirstChild("XP")
	local maxLevel = petFolder:FindFirstChild("MaxLevel")
	local fuseTier = petFolder:FindFirstChild("FuseTier")
	local energyMultiplier = petFolder:FindFirstChild("EnergyMultiplier")
	local moneyMultiplier = petFolder:FindFirstChild("MoneyMultiplier")
	local equipped = petFolder:FindFirstChild("Equipped")

	if not level or not xp or not maxLevel or not fuseTier or not energyMultiplier or not moneyMultiplier or not equipped then
		return
	end

	petNameLabel.Text = getPetDisplayName(petFolder)
	petLevelLabel.Text = "Level: " .. level.Value .. "/" .. maxLevel.Value
	petXPLabel.Text = "XP: " .. xp.Value .. "/" .. tostring(10 + (level.Value * 5))
	petFuseLabel.Text = "Fuse: " .. getFuseName(fuseTier.Value)
	petEnergyLabel.Text = "Energy: x" .. string.format("%.2f", energyMultiplier.Value)
	petMoneyLabel.Text = "Money: x" .. string.format("%.2f", moneyMultiplier.Value)

	setupViewport(petDetailsViewport, getPetDisplayName(petFolder), 2.4)

	if equipped.Value then
		petEquippedLabel.Text = "Equipped"
	else
		petEquippedLabel.Text = "Equip"
	end

	if currentPetXPConnection then currentPetXPConnection:Disconnect() end
	if currentPetLevelConnection then currentPetLevelConnection:Disconnect() end

	currentPetXPConnection = xp:GetPropertyChangedSignal("Value"):Connect(function()
		petXPLabel.Text = "XP: " .. xp.Value .. "/" .. tostring(10 + (level.Value * 5))
	end)

	currentPetLevelConnection = level:GetPropertyChangedSignal("Value"):Connect(function()
		petLevelLabel.Text = "Level: " .. level.Value .. "/" .. maxLevel.Value
		petXPLabel.Text = "XP: " .. xp.Value .. "/" .. tostring(10 + (level.Value * 5))
	end)
end

local function refreshPetList()
	for _, child in ipairs(petsContainer:GetChildren()) do
		if child:IsA("ImageButton") and child.Name ~= "PetButtonTemplate" then
			child:Destroy()
		end
	end

	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local owned = petFolder:FindFirstChild("Owned")

		if owned and owned.Value then
			local button = petButtonTemplate:Clone()
			button.Name = petFolder.Name .. "Button"
			button.Visible = true
			button.Parent = petsContainer
			
		
			local petViewport = button:WaitForChild("PetViewport")
			local multiplierLabel = button:WaitForChild("MultiplierLabel")
			local equippedIcon = button:WaitForChild("EquippedIcon")
			local deleteSelectedFrame = button:WaitForChild("DeleteSelectedFrame")
			
			deleteSelectedFrame.Visible = isSelectedForDelete(petFolder.Name)
			
			local energyMultiplier = petFolder:FindFirstChild("EnergyMultiplier")
			local equipped = petFolder:FindFirstChild("Equipped")

			setupViewport(petViewport, getPetDisplayName(petFolder), 2.2)

			if energyMultiplier then
				multiplierLabel.Text = "x" .. string.format("%.1f", energyMultiplier.Value)
				
				local petDisplayName = getPetDisplayName(petFolder)
				
				local rarityOrder = PetRarityOrder[petDisplayName] or 999
				local powerOrder = math.floor((energyMultiplier and energyMultiplier.Value or 0) * 100)
				
				if equipped and equipped.Value then
					button.LayoutOrder = 
						-100000
						- (rarityOrder * 1000)
						- powerOrder
				else
					button.LayoutOrder = 
						-(rarityOrder * 1000)
					    - powerOrder
				end
			else
				multiplierLabel.Text = "x1.0"
				
				if equipped and equipped.Value then
					button.LayoutOrder = -100000
				else	
					button.LayoutOrder = 0
				end
			end

			equippedIcon.Visible = equipped and equipped.Value or false

			button.MouseButton1Click:Connect(function()
				if deleteMode then
					toggleDeleteSelection(petFolder.Name)
					
					deleteSelectedFrame.Visible = isSelectedForDelete(petFolder.Name)
					return
				end
				selectedPetName = petFolder.Name
				petDetailsFrame.Visible = true
				updateSelectedPetUI()
			end)
		end
	end

	updateEquippedCountLabel()
	updateStorageCountLabel()
	updateEquipBestButtonText()
end

petsButton.MouseButton1Click:Connect(function()
	if petsFrame.Visible then
		refreshPetList()
	end
	
	MenuManager.toggleFull("Pets")
end)

closePetsFrame.MouseButton1Click:Connect(function()
	if petsFrame.Visible then
		refreshPetList()
	end
	
	MenuManager.close("Pets")
end)

equipButton.Activated:Connect(function()
	if selectedPetName then
		petEquipEvent:FireServer(selectedPetName, true)

		task.wait(0.1)

		refreshPetList()
		updateSelectedPetUI()
	end
end)

petsFolder.ChildAdded:Connect(function()
	task.wait(0.1)
	refreshPetList()
end)

maxEquippedPetsValue.Changed:Connect(function()
	updateEquippedCountLabel()
	updateEquipBestButtonText()
end)

deleteButton.MouseButton1Click:Connect(function()
	if not deleteMode then 
		deleteMode = true 
		clearDeleteSelection()
		updateDeleteButtonText()
		petDetailsFrame.Visible = false
		refreshPetList()
		return
	end
	
	local petsToDelete = getSelectedDeleteList()
	
	if #petsToDelete > 0 then 
		
		petDeleteEvent:FireServer(petsToDelete)
	end
	
	deleteMode = false 
	clearDeleteSelection()
	updateDeleteButtonText()
	
	task.delay(0.1, function()
		refreshPetList()
	end)
end)

equipBestButton.Activated:Connect(function()
	updateEquipBestButtonText()

	if equipBestMode then 
		print("SEND UNEQUIP ALL")
		petUnequipAllEvent:FireServer()
	else 
		print("SEND EQUIP BEST")
		petEquipBestEvent:FireServer()
	end

	task.wait(0.2)

	refreshPetList()
	updateSelectedPetUI()
end)

for _, petFolder in ipairs(petsFolder:GetChildren()) do
	local equipped = petFolder:FindFirstChild("Equipped")
	if equipped then
		equipped.Changed:Connect(function()
			refreshPetList()
			updateSelectedPetUI()
		end)
	end
end

petEquipLimitEvent.OnClientEvent:Connect(function(message)
	warn(message)
end)

refreshPetList()
updateDeleteButtonText()

print("PetUI loaded")