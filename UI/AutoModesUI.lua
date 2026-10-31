--// AutoModesUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ShopModule = require(ReplicatedStorage.Modules.ShopModule)
local RaceModule = require(ReplicatedStorage.Modules.RaceModule)

local player = Players.LocalPlayer
local raceGui = script.Parent

local uiBalance = raceGui:WaitForChild("GuiFolder"):WaitForChild("UIBalance")

local autoRaceButton = uiBalance:WaitForChild("AutoRaceButton")
local autoTrainingButton = uiBalance:WaitForChild("AutoTrainingButton")

--// AUTO MODE UI IMAGES
local AUTO_IMAGES = {
	Button = {
		AutoRace = {Default = "rbxassetid://136301470935154", Selected = "rbxassetid://131850748669787",},
		AutoTraining = {Default = "rbxassetid://98911228909481", Selected = "rbxassetid://112787116198848",},
	},
	
	State = {Default = "rbxassetid://111832755634593", Selected = "rbxassetid://74278827181555",},
}

local automaticModeFunction = ReplicatedStorage:WaitForChild("ShopEvent"):WaitForChild("AutomaticModeFunction")

local inRace = player:WaitForChild("InRace")

--// UI
local function updateButton(button, modeName, selected)
	button:SetAttribute("Selected", selected)
	
	local state = selected and "Selected" or "Default"
	local buttonImages = AUTO_IMAGES.Button[modeName]
	
	if button:IsA("ImageButton") then
		local buttonImage = buttonImages[state]
		
		if buttonImage ~= "" then
			button.Image = buttonImage
		end
		
		button.ImageTransparency = 0
	end
	
	local stateIcon = button:FindFirstChild("AutoStateIcon")
	
	if stateIcon and (stateIcon:IsA("ImageLabel") or stateIcon:IsA("ImageButton")) then
		local stateImage = AUTO_IMAGES.State[state]
		
		if stateImage and stateImage ~= "" then
			stateIcon.Image = stateImage
		end
	end
	
	local statusLabel = button:FindFirstChild("AutoStatusLabel", true)
	
	if statusLabel and statusLabel:IsA("TextLabel") then
		statusLabel.Text = selected and "ON" or "OFF"
	end
end

local function updateButtons()
	local mode = player:GetAttribute("AutomaticMode") or "None"
	
	updateButton(autoRaceButton, "AutoRace", mode == "AutoRace")
	updateButton(autoTrainingButton, "AutoTraining", mode == "AutoTraining")
end

local modeRequestBusy = false

local function toggleMode(mode)
	if modeRequestBusy then return end
	modeRequestBusy = true
	
	local currentMode = player:GetAttribute("AutomaticMode")
	local enable = currentMode ~= mode 
	
	local success, accepted, reason = pcall(function()
		return automaticModeFunction:InvokeServer(mode, enable)
	end)
	
	modeRequestBusy = false
	
	if not success then
		warn("Automatic mode request failed:", accepted)
		return
	end
	
	if not accepted then
		warn("Automatic mode denied:", mode, reason)
		return
	end
	
	updateButtons()
end

autoRaceButton.Activated:Connect(function()
	toggleMode("AutoRace")
end)

autoTrainingButton.Activated:Connect(function()
	toggleMode("AutoTraining")
end)

player:GetAttributeChangedSignal("AutomaticMode"):Connect(updateButtons)

updateButtons()

--// AutoRace movement
local raceTrack = workspace:WaitForChild(RaceModule.WorldNames.RaceTrack)

local startPart = raceTrack:FindFirstChild(RaceModule.WorldNames.RaceStartPoint, true)

local endPart = raceTrack:FindFirstChild(RaceModule.WorldNames.RaceMaxEndPoint, true)

RunService:BindToRenderStep("TrainingEvolutionAutoRace", Enum.RenderPriority.Input.Value + 2, function()
	if player:GetAttribute("AutomaticMode") ~= "AutoRace" then
		return
	end
	
	if not ShopModule.CanUseAutomaticMode(player, "AutoRace") then return end
	
	if not inRace.Value then return end
	if not startPart or not endPart then return end
	
	local character = player.Character 
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if not humanoid or humanoid.Health <= 0 then return end
	
	local direction = endPart.Position - startPart.Position
	
	if direction.Magnitude <= 0 then return end
	
	humanoid:Move(direction.Unit, false)
end)

print("AutoModesUI loaded")
