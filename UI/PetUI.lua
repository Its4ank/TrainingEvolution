--// PetUI 1.3

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local MenuManager = require(ReplicatedStorage.Modules.MenuManager)
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local ClientDataModule = require(ReplicatedStorage.Modules.ClientDataModule)

--// Player
local player = Players.LocalPlayer

ClientDataModule.WaitUntilReady(player)

--// Main GUI
local raceGui = script.Parent

local guiFolder = raceGui:WaitForChild("GuiFolder")
local petsFolderUI = guiFolder:WaitForChild("PetsFolder")
local uiBalance = guiFolder:WaitForChild("UIBalance")

local petHost = petsFolderUI:WaitForChild("PetHost")
local petMenu = petHost:WaitForChild("PetMenu")

local petsButton = uiBalance:WaitForChild("PetsButton")

--// Pet warning
local petWarning = petHost:WaitForChild("PetWarning")

--// Selected pet
local petSelectViewport = petMenu:WaitForChild("PetSelectViewport")
local petName = petMenu:WaitForChild("PetName")
local petSelectLevel = petMenu:WaitForChild("PetSelectLevel")
local petEnergyBoost = petMenu:WaitForChild("PetEnergyBoost")
local petMoneyBoost = petMenu:WaitForChild("PetMoneyBoost")
local petPowerBoost = petMenu:WaitForChild("PetPowerBoost")
local petRarityIcon = petMenu:WaitForChild("PetRarityIcon")
local petRarityLabel = petMenu:WaitForChild("PetRarityLabel")
local petPatternLabel = petMenu:WaitForChild("PetPatternLabel")
local petStageLabel = petMenu:WaitForChild("PetStageLabel")

--// Level bar
local petBarWindow = petMenu:WaitForChild("PetBarWindow")
local petLvlBar = petBarWindow:WaitForChild("PetLvlBar")
local petBarRequirXp = petBarWindow:WaitForChild("PetBarRequirXp")

--// Resource / counts
local petStorageLabel = petMenu:WaitForChild("PetStorageLabel")
local petEquipLabel = petMenu:WaitForChild("PetEquipLabel")
local petResMoney = petMenu:WaitForChild("PetResMoney")

--// Main buttons
local petEquippedAll = petMenu:WaitForChild("PetEquippedAll")
local equipAllLabel = petEquippedAll:WaitForChild("EquipAllLabel")
local petMassDelete = petMenu:WaitForChild("PetMassDelete")
local massDelLabel = petMassDelete:WaitForChild("MassDelLabel")
local petDeleteButton = petMenu:WaitForChild("PetDeleteButton")
local petEquippedButton = petMenu:WaitForChild("PetEquippedButton")
local equipLabel = petEquippedButton:WaitForChild("EquipLabel")
local petUpgButton = petMenu:WaitForChild("PetUpgButton")
local upgMoneyLabel = petUpgButton:WaitForChild("UpgMoneyLabel")
local petCloseMenu = petMenu:WaitForChild("PetCloseMenu")

--// Search
local petSearchButton = petMenu:WaitForChild("PetSearchButton")

petSearchButton.PlaceholderText = "Search..."
petSearchButton.Text = ""

--// Inventory
local petScrollContainer = petMenu:WaitForChild("PetScrollContainer")
local petContainerTemplate = petScrollContainer:WaitForChild("PetContainer1")
local petButtonTemplate = petContainerTemplate:WaitForChild("PetSelectedButton")

petButtonTemplate.Visible = false

--// Equipped pets
local petEquipInfoScroll = petMenu:WaitForChild("PetEquipInfoScroll")
local petEquipContainer1 = petEquipInfoScroll:WaitForChild("PetEquipContainer1")
local petEquipContainer2 = petEquipInfoScroll:WaitForChild("PetEquipContainer2")
local petEquipContainer3 = petEquipInfoScroll:WaitForChild("PetEquipContainer3")

--// Player data
local petsFolder = ClientDataModule.GetPets(player)
local moneyValue = ClientDataModule.GetMoney(player)
local xpValue = ClientDataModule.GetXP(player)
local maxEquippedPetsValue = ClientDataModule.GetMaxEquippedPets(player)
local playerData = ClientDataModule.GetPlayerData(player)
local maxPetStorageValue = playerData:WaitForChild("MaxPetStorage")

--// Remotes
local petEvent = ReplicatedStorage:WaitForChild("PetEvent")
local petEquipEvent = petEvent:WaitForChild("PetEquipEvent")
local petDeleteEvent = petEvent:WaitForChild("PetDeleteEvent")
local petEquipBestEvent = petEvent:WaitForChild("PetEquipBestEvent")
local petUpgradeEvent = petEvent:WaitForChild("PetUpgradeEvent")
local petWarningEvent = petEvent:WaitForChild("PetWarningEvent")

--// State
local selectedPetId = nil

local deleteMode = false
local selectedForDelete = {}

local warningToken = 0

--// Connections
local petValueConnections = {}

--// Helpers
local function formatNumber(number)
	number = tonumber(number) or 0
	
	if number >= 1e18 then
		return string.format("%.1fQ", number / 1e18)
	elseif number >= 1e12 then
		return string.format("%.1fT", number / 1e12)
	elseif number >= 1e9 then
		return string.format("%.1fB", number / 1e9)
	elseif number >= 1e6 then
		return string.format("%.1fM", number / 1e6)
	elseif number >= 1e3 then
		return string.format("%.1fK", number / 1e3)
	end
	
	if number % 1 == 0 then
		return tostring(math.floor(number))
	end
	
	return string.format("%.1f", number)
end

local function showWarning(text)
	warningToken += 1
	
	local currentToken = warningToken
	
	petWarning.Text = text
	petWarning.Visible = true
	
	task.delay(4, function()
		if currentToken ~= warningToken then return end
		
		petWarning.Visible = false
	end)
end

local function getPetData(petFolder)
	if not petFolder then return nil end
	
	local petNameValue = petFolder:FindFirstChild("PetName")
	local patternValue = petFolder:FindFirstChild("Pattern")
	local tierValue = petFolder:FindFirstChild("Tier")
	local levelValue = petFolder:FindFirstChild("Level")
	local equippedValue = petFolder:FindFirstChild("Equipped")
	
	if not petNameValue or not patternValue or not tierValue or not levelValue or not equippedValue then return nil end
	
	return {
		PetName = petNameValue.Value,
		Pattern = patternValue.Value,
		Tier = tierValue.Value,
		Level = levelValue.Value,
		Equipped = equippedValue.Value
	}
end

local function getSelectedPetFolder()
	if not selectedPetId then return nil end
	
	return petsFolder:FindFirstChild(selectedPetId)
end

--// Viewport
local function findPetModule(petName)
	local config = PetModule.GetPetConfig(petName)
	if not config then return nil end
	
	local modelName = config.ModelName or config.Name
	local previewRoot = ReplicatedStorage:FindFirstChild("PetPreviewModels")
	if not previewRoot then return nil end
	
	return previewRoot:FindFirstChild(modelName, true)
end

local function setupViewport(viewport, petName, distanceMultiplier)
	viewport:ClearAllChildren()
	
	local template = findPetModule(petName)
	if not template then
		warn("Pet preview model not found:", petName)
		return
	end
	
	local worldModel = Instance.new("WorldModel")
	
	worldModel.Parent = viewport
	
	local previewModel = Instance.new("Model")
	
	previewModel.Name = petName .. "_Preview"
	previewModel.Parent = worldModel
	
	local copiedParts = {}
	
	for _, object in ipairs(template:GetDescendants()) do
		if object:IsA("BasePart") then
			local clone = object:Clone()
			
			for _, child in ipairs(clone:GetDescendants()) do
				if child:IsA("Script") or child:IsA("LocalScript") then
					
					child:Destroy()
				end
			end
			
			clone.Anchored = true
			clone.CanCollide = false
			clone.Massless = true
			
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
	
	local _, size = previewModel:GetBoundingBox()
	local biggest = math.max(size.X, size.Y, size.Z)
	local distace = math.max(biggest * (distanceMultiplier or 2.2), 3)
	local camera = Instance.new("Camera")
	
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	viewport.Ambient = Color3.fromRGB(255, 255, 255)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	
	camera.CFrame = CFrame.new(Vector3.new(0, size.Y * 0.25, distace), Vector3.new(0, size.Y * 0.1, 0))
end

--// Counts
local function getStorageCount()
	local count = 0
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then count += 1 end
	end
	return count
end

local function getEquippedPets()
	local equippedPets = {}
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		local data = getPetData(petFolder)
		if data and data.Equipped then
			table.insert(equippedPets, petFolder)
		end
	end
	return equippedPets
end

local function updateCountLabels()
	local storageCount = getStorageCount()
	
	local equippedCount = #getEquippedPets()
	
	petStorageLabel.Text = tostring(storageCount) .. "/" .. tostring(maxPetStorageValue.Value)
	petEquipLabel.Text = tostring(equippedCount) .. "/" .. tostring(maxEquippedPetsValue.Value)
end 

--//Money
local function updateMoney()
	petResMoney.Text = formatNumber(moneyValue.Value)
end

--// Equipped slot UI
local function getEquipSlotButtons()
	local result = {}
	
	local containers = {
		petEquipContainer1,
		petEquipContainer2,
		petEquipContainer3,
	}
	
	for _, container in ipairs(containers) do
		for index = 1, 3 do
			local button = container:FindFirstChild("PetEquipButton" .. tostring(index))
			
			if button then
				table.insert(result, {Button = button, Container = container,})
			end
		end
	end
	return result
end

local equipSlotButtons = getEquipSlotButtons()

local function updateEquippedSlots()
	local equippedPets = getEquippedPets()
	local maxEquipped = maxEquippedPetsValue.Value
	
	for index, slotInfo in ipairs(equipSlotButtons) do
		local button = slotInfo.Button
		local viewport = button:FindFirstChild("PetViewport")
		local shouldExist = index <= maxEquipped
		
		button.Visible = shouldExist
		
		if viewport then
			viewport.Visible = shouldExist
		end
		
		if shouldExist then
			local petFolder = equippedPets[index]
			
			if petFolder then
				local data = getPetData(petFolder)
				
				button.Image = PetModule.GetEquipSlotImage("Filled")
				button:SetAttribute("PetId", petFolder.Name)
				
				if viewport and data then
					setupViewport(viewport, data.PetName, 2)
				end
			else
				button.Image = PetModule.GetEquipSlotImage("Default")
				button:SetAttribute("PetId", nil)
				
				if viewport then
					viewport:ClearAllChildren()
				end
			end
		end
	end
	
	petEquipContainer1.Visible = maxEquipped >= 1
	petEquipContainer2.Visible = maxEquipped >= 4
	petEquipContainer3.Visible = maxEquipped >= 7
end

--// Level progress
local function updateLevelProgress(level)
	local targetLevel = level + 1
	
	if level >= PetModule.MAX_LEVEL then
		petBarRequirXp.Text = "MAX"
		petLvlBar.Position = UDim2.new(0, 0, 0.207, 0)
		return
	end
	
	local cost = PetModule.GetLevelUpgradeCost(targetLevel)
	if not cost then return end
	
	local requiredXP = cost.XP
	local currentXP = xpValue.Value
	local progress = 1
	
	if requiredXP > 0 then
		progress = math.clamp(currentXP / requiredXP, 0, 1)
	end
	
	petBarRequirXp.Text = formatNumber(currentXP) .. "/" .. formatNumber(requiredXP)
	petLvlBar.Position = UDim2.new(-1 + progress, 0, 0.207, 0)
end

--// Selected pet UI
local function clearSelectedPet()
	selectedPetId = nil
	
	petSelectViewport:ClearAllChildren()
	
	petName.Text = ""
	petSelectLevel.Text = ""
	petEnergyBoost.Text = ""
	petMoneyBoost.Text = ""
	petPowerBoost.Text = ""
	petRarityLabel.Text = ""
	petPatternLabel.Text = ""
	petStoraLabel.Text = ""
	
	petRarityIcon.Image = ""
	
	equipLabel.Text = "EQUIP"
	
	upgMoneyLabel.Text = ""
	petBarRequirXp.Text = ""
	
	petLvlBar.Position = UDim2.new(-1, 0, 0.207, 0)
end

local function updateSelectedPetUI()
	local petFolder = getSelectedPetFolder()
	if not petFolder then
		clearSelectedPet()
		return
	end
	
	local data = getPetData(petFolder)
	if not data then return end
	
	local displayData = PetModule.GetPetDisplayData(data.PetName, data.Pattern, data.Tier, data.Level)
	if not displayData then return end
	
	petName.Text = displayData.Name
	petSelectLevel.Text = tostring(data.Level)
	petEnergyBoost.Text = "+" .. formatNumber(displayData.Energy)
	petMoneyBoost.Text = "+" .. formatNumber(displayData.Money)
	petPowerBoost.Text = "+" .. formatNumber(displayData.RacePower)
	petRarityLabel.Text = string.upper(displayData.Rarity)
	petRarityIcon.Image = displayData.RarityIcon or ""
	petPatternLabel.Text = "PATTERN " .. tostring(data.Pattern)
	petStageLabel.Text = "STAGE: " .. string.upper(displayData.TierName)
	setupViewport(petSelectViewport, data.PetName, 2.4)
	
	if data.Equipped then
		equipLabel.Text = "UNEQUIP"
	else
		equipLabel.Text = "EQUIP"
	end
	
	if data.Level >= PetModule.MAX_LEVEL then
		upgMoneyLabel.Text = "MAX"
	else
		local cost = PetModule.GetLevelUpgradeCost(data.Level + 1)
		
		if cost then
			upgMoneyLabel.Text = " " .. formatNumber(cost.Money)
		end
	end
	updateLevelProgress(data.Level)
end

--// Inventory sorting
local function getPetPower(petFolder)
	local data = getPetData(petFolder)
	if not data then return 0 end
	
	local stats = PetModule.CalculatePetStats(data.PetName, data.Pattern, data.Tier, data.Level)
	
	return PetModule.GetPowerScore(stats)
end

local function getSortedPets()
	local list = {}
	
	local searchText = string.lower(petSearchButton.Text)
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			local data = getPetData(petFolder)
			if data then
				local config = PetModule.GetPetConfig(data.PetName)
				local displayData = config and (config.DisplayName or config.Name) or data.PetName
				local matchesSearch = searchText == "" or string.find(string.lower(displayData), searchText, 1, true)
				
				if matchesSearch then
					table.insert(list, {Folder = petFolder, Data = data, Power = getPetPower(petFolder),})
				end
			end
		end
	end
	
	table.sort(list, function(a, b)
		if a.Data.Equipped ~= b.Data.Equipped then
			return a.Data.Equipped
		end
		
		if a.Power ~= b.Power then
			return a.Power > b.Power
		end
		
		return a.Folder.Name < b.Folder.Name
	end)
	return list
end

--// Delete selection
local function isSelectedForDelete(petId)
	return selectedForDelete[petId] == true
end

local function clearDeleteSelection()
	selectedForDelete = {}
end

local function getDeleteCount()
	local count = 0
	
	for _, selected in pairs(selectedForDelete) do
		if selected then
			count += 1
		end
	end
	return count
end

local function getSelectedDeleteList()
	local result = {}
	
	for petId, selected in pairs(selectedForDelete) do
		if selected then
			table.insert(result, petId)
		end
	end
	return result
end

local function updateMassDeleteLabel()
	if not deleteMode then
		massDelLabel.Text = "DELETE MASS"
		return
	end
	
	if getDeleteCount() == 0 then
		massDelLabel.Text = "EXIT MASS DELETE"
	else
		massDelLabel.Text = "DELETE"
	end
end

--// Inventory button state
local function getButtonState(petFolder, data)
	if deleteMode and isSelectedForDelete(petFolder.Name) then return "Delete" end
	if selectedPetId == petFolder.Name then return "Selected" end
	if data.Equipped then return "Equipped" end
	
	return "Default"
end

--// Inventory containers
local function clearGeneratedInventory()
	for _, child in ipairs(petScrollContainer:GetChildren()) do
		if child:GetAttribute("GeneratedPetContainer") then
			child:Destroy()
		end
	end
	
	for _, child in ipairs(petContainerTemplate:GetChildren()) do
		if child:GetAttribute("GeneratedPetButton") then
			child:Destroy()
		end
	end
end

local function createdInventoryContainer(index)
	if index == 1 then
		petContainerTemplate.Visible = true
		return petContainerTemplate
	end
	
	local container = petContainerTemplate:Clone()
	
	container.Name = "PetContainer" .. tostring(index)
	container.Visible = true
	container:SetAttribute("GeneratedPetContainer", true)
	
	local template = container:FindFirstChild("PetSelectedButton")
	
	if template then
		template.Visible = false
	end
	
	container.Parent = petScrollContainer
	return container
end

--// Froward declaration
local refreshUI

--//Create inventory button
local function createPetButton(container, petFolder, data)
	local button = petButtonTemplate:Clone()
	
	button.Name = petFolder.Name .. "_Button"
	button.Visible = true
	button:SetAttribute("GeneratedPetButton", true)
	button.Parent = container
	
	local viewport = button:WaitForChild("PetPreview")
	local equippedIcon = button:WaitForChild("PetSelInfoEquip")
	
	setupViewport(viewport, data.PetName, 2.2)
	equippedIcon.Visible = data.Equipped
	
	local state = getButtonState(petFolder, data)
	
	button.Image = PetModule.GetInventoryButtonImage(state)
	button.Activated:Connect(function()
		if deleteMode then
			if data.Equipped then
				showWarning("Equipped pets cannot be deleted.") 
				return
			end
			
			if selectedForDelete[petFolder.Name] then
				selectedForDelete[petFolder.Name] = nil
			else
				selectedForDelete[petFolder.Name] = true
			end
			
			updateMassDeleteLabel()
			refreshUI()
			return
		end
		
		selectedPetId = petFolder.Name
		refreshUI()
	end)
end

--// Inventory refresh
local function refreshInventory()
	clearGeneratedInventory()
	
	local sortedPets = getSortedPets()
	
	if #sortedPets == 0 then
		petContainerTemplate.Visible = false
		return
	end
	
	local containerCount = math.ceil(#sortedPets / 4)
	local containers = {}
	
	for index = 1, containerCount do
		containers[index] = createdInventoryContainer(index)
	end
	
	for index, entry in ipairs(sortedPets) do
		local containerIndex = math.ceil(index / 4)
		local container = containers[containerIndex]
		
		createPetButton(container, entry.Folder, entry.Data)
	end
end

--// Equip Best label
local function isBestSetEquipped()
	local allPets = {}
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			table.insert(allPets, {Folder = petFolder, Power = getPetPower(petFolder),})
		end
	end
	
	table.insert(allPets, function(a, b) return a.Power > b.Power end)
	
	local maxCount = math.min(maxEquippedPetsValue.Value, #allPets)
	local equippedPets = getEquippedPets()
	
	if #equippedPets ~= maxCount then return false end
	
	local bestIds = {}
	
	for index = 1, maxCount do
		bestIds[allPets[index].Folder.Name] = true
	end
	
	for _, petFolder in ipairs(equippedPets) do
		if not bestIds[petFolder.Name] then
			return false
		end
	end
	return true
end

local function updateEquipAllLabel()
	if #getEquippedPets() > 0 and isBestSetEquipped() then
		equipAllLabel.Text = "UNEQUIP ALL"
	else
		equipAllLabel.Text = "EQUIP BEST"
	end
end

--// Full refresh
refreshUI = function()
	updateCountLabels()
	updateMoney()
	
	updateSelectedPetUI()
	updateEquippedSlots()
	
	updateEquipAllLabel()
	updateMassDeleteLabel()
	
	refreshInventory()
end

--// Equipped slot clicks
for _, slotInfo in ipairs(equipSlotButtons) do
	slotInfo.Button.Archivable:Connect(function()
		local petId = slotInfo.Button:GetAttribute("PetId")
		if not petId then return end
		
		petEquipEvent:FireServer(petId, false)
	end)
end

--// Selected pet equip / unequip
petEquippedButton.Activated:Connect(function()
	local petFolder = getSelectedPetFolder()
	if not petFolder then return end
	
	local data = getPetData(petFolder)
	if not data then return end
	
	petEquipEvent:FireServer(petFolder.Name, not data.Equipped)
end)

--// Delete selected pet
petDeleteButton.Activated:Connect(function()
	local petFolder = getSelectedPetFolder()
	if not petFolder then return end
	
	local data = getPetData(petFolder)
	if not data then return end
	
	if data.Equipped then
		showWarning("Equipped pets cannot be delete.")
		return
	end
	
	petDeleteEvent:FireServer(petFolder.Name)
	selectedPetId = nil
end)

--// Mass delete
petMassDelete.Activated:Connect(function()
	if not deleteMode then
		deleteMode = true
		
		clearDeleteSelection()
		updateMassDeleteLabel()
		refreshUI()
		return
	end
	
	local deleteList = getSelectedDeleteList()
	
	if #deleteList == 0 then
		deleteMode = false
		
		clearDeleteSelection()
		updateMassDeleteLabel()
		refreshUI()
		return
	end
	
	petDeleteEvent:FireServer(deleteList)
	
	deleteMode = false
	clearDeleteSelection()
	
	if selectedPetId then
		for _, petId in ipairs(deleteList) do
			if petId == selectedPetId then
				selectedPetId = nil
				break
			end
		end
	end
	refreshUI()
end)

--// Equip best / Unequip all
petEquippedAll.Activated:Connect(function()
	petEquipBestEvent:FireServer()
end)

--// Upgrade level
petUpgButton.Activated:Connect(function()
	local petFolder = getSelectedPetFolder()
	if not petFolder then return end
	
	local data = getPetData(petFolder)
	if not data then return end
	
	if data.Level >= PetModule.MAX_LEVEL then
		showWarning("Pet is already max level.")
		return
	end
	
	petUpgradeEvent:FireServer(petFolder.Name)
end)

--// Search
petSearchButton:GetPropertyChangedSignal("Text"):Connect(function()
	refreshInventory()
end)

--// Warning from server
petWarningEvent.OnClientEvent:Connect(function(message)
	showWarning(message)
end)

--// Pet folder monitoring
local function disconnectPetConnections()
	for _, connection in ipairs(petValueConnections) do
		connection:Disconnect()
	end
	petValueConnections = {}
end

local function rebuildPetConnections()
	disconnectPetConnections()
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			for _, valueName in ipairs({
				"PetName",
				"Pattern",
				"Tier",
				"Level",
				"Equipped",
				}) do
				
				local value = petFolder:FindFirstChild(valueName)
				if value then
					table.insert(petValueConnections,
						value:GetPropertyChangedSignal("Value"):Connect(function()
							refreshUI()
						end)
					)
				end
			end
		end
	end
end

petsFolder.ChildAdded:Connect(function()
	task.defer(function()
		rebuildPetConnections()
		refreshUI()
	end)
end)

petsFolder.ChildRemoved:Connect(function()
	task.defer(function()
		if selectedPetId and not petsFolder:FindFirstChild(selectedPetId) then
			selectedPetId = nil
		end
		
		rebuildPetConnections()
		refreshUI()
	end)
end)

--// Resource changes
moneyValue:GetPropertyChangedSignal("Value"):Connect(function()
	updateMoney()
	updateSelectedPetUI()
end)

xpValue:GetPropertyChangedSignal("Value"):Connect(function()
	updateSelectedPetUI()
end)

maxEquippedPetsValue:GetPropertyChangedSignal("Value"):Connect(function()
	refreshUI()
end)

maxPetStorageValue:GetPropertyChangedSignal("Value"):Connect(function()
	updateCountLabels()
end)

--// Open menu
petsButton.Activated:Connect(function()
	petHost.Visible = true
	refreshUI()
end)

petCloseMenu.Activated:Connect(function()
	petHost.Visible = false
end)

--// Start
petHost.Visible = false
petWarning.Visible = false

petEquipContainer2.Visible = false
petEquipContainer3.Visible = false

clearSelectedPet()
rebuildPetConnections()
refreshUI()

print("PetUI 1.3 loaded")
