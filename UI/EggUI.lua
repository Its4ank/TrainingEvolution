--// EggUI LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)

local guiFolder = raceGui:WaitForChild("GuiFolder")

local eggFolderUI = guiFolder:WaitForChild("EggFolder")

local openEggEvent = ReplicatedStorage:WaitForChild("OpenEggEvent")

local cityEggFolder = workspace:WaitForChild("CityEggFolder")
local egg1Folder = cityEggFolder:WaitForChild("Egg1")
local egg1Part = egg1Folder:WaitForChild("EggPart")

local egg1Billboard = eggFolderUI:WaitForChild("EggInfoBillboard")
egg1Billboard.Adornee = egg1Part

local petsGrid = egg1Billboard.MainFrame.PetsGrid

local petSlots = {
	{
		Name = "Dog",
		Viewport = petsGrid.PetSlot1:WaitForChild("PetViewport"),
		ChanceLabel = petsGrid.PetSlot1:WaitForChild("ChanceLabel"),
		BaseChance = 35,
	},
	{
		Name = "Cow",
		Viewport = petsGrid.PetSlot2:WaitForChild("PetViewport"),
		ChanceLabel = petsGrid.PetSlot2:WaitForChild("ChanceLabel"),
		BaseChance = 25,
	},
	{
		Name = "Cat",
		Viewport = petsGrid.PetSlot3:WaitForChild("PetViewport"),
		ChanceLabel = petsGrid.PetSlot3:WaitForChild("ChanceLabel"),
		BaseChance = 20,
	},
	{
		Name = "Pig",
		Viewport = petsGrid.PetSlot4:WaitForChild("PetViewport"),
		ChanceLabel = petsGrid.PetSlot4:WaitForChild("ChanceLabel"),
		BaseChance = 15,
	},
	{
		Name = "Chicken",
		Viewport = petsGrid.PetSlot5:WaitForChild("PetViewport"),
		ChanceLabel = petsGrid.PetSlot5:WaitForChild("ChanceLabel"),
		BaseChance = 5,
	},
}

local openButton = egg1Billboard.MainFrame.ButtonsBar:WaitForChild("OpenButton")
local open3Button = egg1Billboard.MainFrame.ButtonsBar:WaitForChild("Open3Button")
local autoOpenButton = egg1Billboard.MainFrame.ButtonsBar:WaitForChild("AutoOpen")

egg1Billboard.Active = true
egg1Billboard.AlwaysOnTop = true

openButton.Active = true
open3Button.Active = true
autoOpenButton.Active = true

local petPreviewRoot = ReplicatedStorage
	:WaitForChild("PetPreviewModels")
	:WaitForChild("Earth")
	:WaitForChild("Egg1")

local function getUpgradeLevel(upgradeName)
	local upgrades = ClientDataModule.GetUpgrades(player)
	if not upgrades then return 0 end

	local upgrade = upgrades:FindFirstChild(upgradeName)
	if not upgrade then return 0 end

	return upgrade.Value
end

local function setupPetViewport(viewport, petName)
	viewport:ClearAllChildren()

	local modelTemplate = petPreviewRoot:FindFirstChild(petName)
	if not modelTemplate then
		warn("Egg pet preview not found:", petName)
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
	local distance = math.max(biggest * 1.8, 3)

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

local function setupEggChances()
	local petLuckLevel = getUpgradeLevel("PetLuck")
	local luckBonus = petLuckLevel * 0.10

	local totalWeight = 0
	local weights = {}

	for index, info in ipairs(petSlots) do
		local rarityPower = index - 1
		local weight = info.BaseChance * (1 + (luckBonus * rarityPower))

		weights[index] = weight
		totalWeight += weight
	end

	for index, info in ipairs(petSlots) do
		local percent = 0

		if totalWeight > 0 then
			percent = (weights[index] / totalWeight) * 100
		end

		info.ChanceLabel.Text = string.format("%.1f%%", percent)
		info.ChanceLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	end
end

local function setupEggPetsPreview()
	for _, info in ipairs(petSlots) do
		setupPetViewport(info.Viewport, info.Name)
	end
end

local function updateEggBillboard()
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		egg1Billboard.Enabled = false
		return
	end

	local distance = (hrp.Position - egg1Part.Position).Magnitude
	egg1Billboard.Enabled = distance <= 15
end

local function canOpenEgg()
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	
	local distance = (hrp.Position - egg1Part.Position).Magnitude
	return distance <= 15
end

local function requestOpenEgg(amount)
	if not canOpenEgg() then return end
	
	openEggEvent:FireServer("Egg1", amount)
end

local autoOpenEnabled = false
local autoOpenDelay = 1

local function startAutoOpen()
	if autoOpenEnabled then return end
	
	autoOpenEnabled = true
	autoOpenButton.Text = "Stop Auto-Opening"
	
	task.spawn(function()
		while autoOpenEnabled do
			if canOpenEgg() then
				requestOpenEgg(1)
			else
				autoOpenEnabled = false
				autoOpenButton.Text = "Auto-Open"
				break
			end
			task.wait(autoOpenDelay)
		end
	end)
end

local function stopAutoOpen()
	autoOpenEnabled = false
	autoOpenButton.Text = "Auto-Open"
end

openButton.Activated:Connect(function()
	print("OPEN BUTTON PRESSED")
	requestOpenEgg(1)
end)

open3Button.Activated:Connect(function()
	requestOpenEgg(3)
end)

autoOpenButton.Activated:Connect(function()
	if autoOpenEnabled then
		stopAutoOpen()
	else
		startAutoOpen()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not egg1Billboard.Enabled then return end

	if input.KeyCode == Enum.KeyCode.E then
		requestOpenEgg(1)
	elseif input.KeyCode == Enum.KeyCode.R then
		requestOpenEgg(3)
	elseif input.KeyCode == Enum.KeyCode.T then
		if autoOpenEnabled then
			stopAutoOpen()
		else
			startAutoOpen()
		end
	end
end)



local upgradesFolder = ClientDataModule.GetUpgrades(player)
local petLuckUpgrade = upgradesFolder:WaitForChild("PetLuck")

petLuckUpgrade.Changed:Connect(setupEggChances)

RunService.RenderStepped:Connect(updateEggBillboard)

setupEggPetsPreview()
setupEggChances()
updateEggBillboard()

print("EggUI loaded")
