--// TrainingUI LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--// Player
local player = Players.LocalPlayer

--// UI
local gui = script.Parent
local uiBalance = gui:WaitForChild("UIBalance")
local startStopTreadButton = uiBalance:WaitForChild("Start/StopTreadButton")

--// RemoteEvents
local treadmillEvent = ReplicatedStorage:WaitForChild("TreadmillEvents")
local treadmillRequestEvent = treadmillEvent:WaitForChild("TreadmillRequestEvent")
local treadmillResponceEvent = treadmillEvent:WaitForChild("TreadmillResponseEvent")

--// Player treadmill data
local currentTreadmill = player:WaitForChild("CurrentTreadmill")
local treadmillsFolder = player:WaitForChild("Treadmills")

--// Setting
local MAX_TREADMILLS = 3
local SHOW_BUTTON_DISTANCE = 12

local treadmillObjects = {}
local nearestTreadmillId = nil

startStopTreadButton.Visible = false

--// Helpers
local function getMainPart(object)
	if object:IsA("BasePart") then 
		return object
	end
	
	return object:FindFirstChildWhichIsA("BasePart", true)
end

for i = 1, MAX_TREADMILLS do
	local treadmillObject = workspace:WaitForChild("Treadmill" .. i)
	local mainPart = getMainPart(treadmillObject)
	
	if mainPart then 
		treadmillObjects[i] = { 
			Object = treadmillObject,
			Part = mainPart,
		}
	else 
		warn("No BasePart found for Treadmill" .. i)
	end
end

local function setButtonText(text)
	if startStopTreadButton:IsA("TextButton") then 
		startStopTreadButton.Text = text 
		return
	end
	
	local label = 
		startStopTreadButton:FindFirstChild("TextLabel", true)
	    or startStopTreadButton:FindFirstChild("ButtonText", true)
		or startStopTreadButton:FindFirstChild("StatusLabel", true)
	
	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function getCharacterHRP()
	local character = player.Character
	if not character then return nil end
	
	return character:FindFirstChild("HumanoidRootPart")
end

local function isTreadmillCompleted(treadmillId)
	local folder = treadmillsFolder:FindFirstChild("Treadmill" .. treadmillId)
	if not folder then return false end
	
	local level = folder:FindFirstChild("Level")
	local stage = folder:FindFirstChild("Stage")
	
	if not level or not stage then
		return false
	end
	
	return stage.Value >= 5 and level.Value >= 25
end

local function isTreadmillUnlocked(treadmillId)
	if treadmillId <= 1 then 
		return true
	end
	
	return isTreadmillCompleted(treadmillId - 1)
end

local function getNearestUnlockedTreadmill()
	local hrp = getCharacterHRP()
	if not hrp then return nil end 
	
	local bestId = nil 
	local bestDistance = math.huge
	
	for treadmillId, data in pairs(treadmillObjects) do 
		if data.Part and isTreadmillUnlocked(treadmillId) then 
			local distance = (hrp.Position - data.Part.Position).Magnitude
			
			if distance < bestDistance then 
				bestDistance = distance
				bestId = treadmillId
			end
		end
	end
	
	if bestId and bestDistance <= SHOW_BUTTON_DISTANCE then 
		return bestId 
	end
	
	return nil 
end

local function updateStartStopButton()
	local activeTreadmillId = currentTreadmill.Value 
	
	if activeTreadmillId > 0 then 
		startStopTreadButton.Visible = true 
		setButtonText("STOP")
		return
	end
	
	nearestTreadmillId = getNearestUnlockedTreadmill()
	
	if nearestTreadmillId then 
		startStopTreadButton.Visible = true 
		setButtonText("E")
	else 
		startStopTreadButton.Visible = false
	end
end

local function toggleTraining()
	if currentTreadmill.Value > 0 then
		treadmillRequestEvent:FireServer("StopTraining", currentTreadmill.Value)
		return
	end
	
	if not nearestTreadmillId then 
		return
	end
	
	treadmillRequestEvent:FireServer("StartTraining", nearestTreadmillId)
end

--// Button click
startStopTreadButton.MouseButton1Click:Connect(function()
	toggleTraining()
end)

--// Keyboard E
UserInputService.InputBegan:Connect(function(input, gameProgressed)
	if gameProgressed then return end 
	
	if input.KeyCode == Enum.KeyCode.E then 
		if startStopTreadButton.Visible then 
			toggleTraining()
		end
	end
end)

--// Server responce
treadmillResponceEvent.OnClientEvent:Connect(function(action, success, reason, info)
	if not success then
		warn("Treadmill action failed:", action, reason)
	end
	
	updateStartStopButton()
end)

--// Update when treadmill unlock data changes
currentTreadmill.Changed:Connect(updateStartStopButton)

for i = 1, MAX_TREADMILLS do 
	local folder = treadmillsFolder:WaitForChild("Treadmill" .. i)
	
	local level = folder:WaitForChild("Level")
	local stage = folder:WaitForChild("Stage")
	
	level.Changed:Connect(updateStartStopButton)
	stage.Changed:Connect(updateStartStopButton)
end

--// Main loop 
RunService.RenderStepped:Connect(function()
	updateStartStopButton()
end)


print("YUA SI YOBNU loaded")
