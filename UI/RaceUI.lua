--// RaceUI LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)

local guiFolder = raceGui:WaitForChild("GuiFolder")

local leaveRaceEvent = ReplicatedStorage:WaitForChild("LeaveRaceEvent")

local raceStatusText = ReplicatedStorage:WaitForChild("RaceStatusText")
local raceTimerText = ReplicatedStorage:WaitForChild("RaceTimerText")

local backgroundMusic = SoundService:WaitForChild("BackgroundMusik")
local raceMusik = SoundService:WaitForChild("RaceSound"):WaitForChild("RaceSounds")

local raceFolder = guiFolder:WaitForChild("RaceFolder")

--// Race UI
local racePanel = raceFolder:WaitForChild("RacePanel")
local speedometer = raceFolder:WaitForChild("Speedometer")
local leaveButton = raceFolder:WaitForChild("LeaveButton")

--// Race Timer
local raceTimer = raceFolder:WaitForChild("RaceTimer")
local raceStatusLabel = raceTimer:WaitForChild("RaceStatus")
local timerStatusLabel = raceTimer:WaitForChild("TimerStatus")

--// Speedometer
local energyValueLabel = speedometer:WaitForChild("EnergyValueLabel")
local tickLabels = speedometer:WaitForChild("TickLabels")
local arrow = speedometer:WaitForChild("Arrow")

local tick1 = tickLabels:WaitForChild("Tick1")
local tick2 = tickLabels:WaitForChild("Tick2")
local tick3 = tickLabels:WaitForChild("Tick3")
local tick4 = tickLabels:WaitForChild("Tick4")
local tick5 = tickLabels:WaitForChild("Tick5")
local tick6 = tickLabels:WaitForChild("Tick6")

local progressBar = speedometer:FindFirstChild("ProgressBar")
local progressFill = progressBar and progressBar:FindFirstChild("Fill")

--// Race Panel
local panelIcon = racePanel:WaitForChild("Icon")
--local panelTextLabel = racePanel:WaitForChild("TextLabel")

panelIcon.Image = Players:GetUserThumbnailAsync(
	player.UserId,
	Enum.ThumbnailType.HeadShot,
	Enum.ThumbnailSize.Size100x100
)

local panelLines = {
	Line1 = racePanel:WaitForChild("Line1"),
	Line2 = racePanel:WaitForChild("Line2"),
	Line3 = racePanel:WaitForChild("Line3"),
}

local rewardLineMap = {
	Reward1 = "Line1",
	Reward2 = "Line1",
	Reward3 = "Line1",
	Reward4 = "Line1",
	Reward5 = "Line1",
	Reward6 = "Line1",
	Reward7 = "Line1",
	Reward8 = "Line1",

	Reward9 = "Line2",
	Reward10 = "Line2",
	Reward11 = "Line2",
	Reward12 = "Line2",
	Reward13 = "Line2",
	Reward14 = "Line2",

	Reward15 = "Line3",
	Reward16 = "Line3",
}

local segmentColors = {
	Color3.fromRGB(255, 60, 60),
	Color3.fromRGB(255, 150, 40),
	Color3.fromRGB(255, 230, 60),
	Color3.fromRGB(80, 255, 80),
	Color3.fromRGB(60, 220, 255),
	Color3.fromRGB(80, 120, 255),
	Color3.fromRGB(180, 80, 255),
	Color3.fromRGB(255, 80, 200),
}

--// Player data
local inRaceValue = player:WaitForChild("InRace")
local raceSpeedValue = player:WaitForChild("RaceSpeed")
local raceProgressValue = player:WaitForChild("RaceProgress")

local energy = ClientDataModule.GetEnergy(player)

local upgradesFolder = player:WaitForChild("Upgrades")
local racePowerUpgrade = upgradesFolder:WaitForChild("RacePower")

--// Settings
local MIN_SPEED = 10
local MAX_ARROW_ROTATION = 170

speedometer.Visible = false
leaveButton.Visible = false
racePanel.Visible = true
raceTimer.Visible = true

--// Helpers
local function findDescendantByName(parent, targetName)
	for _, obj in ipairs(parent:GetDescendants()) do
		if obj.Name == targetName then
			return obj
		end
	end

	return nil
end

local function formatShort(n)
	if n >= 1e15 then
		return string.format("%.2fQ", n / 1e15)
	elseif n >= 1e12 then
		return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.2fK", n / 1e3)
	else
		return tostring(math.floor(n))
	end
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function getTargetSpeedFromEnergy(value)
	if value <= 0 then
		return 16
	end

	if value < 1e6 then
		return lerp(16, 50, value / 1e6)
	end

	if value < 1e9 then
		return lerp(50, 100, (value - 1e6) / (1e9 - 1e6))
	end

	if value < 1e12 then
		return lerp(100, 200, (value - 1e9) / (1e12 - 1e9))
	end

	if value < 1e15 then
		return lerp(200, 400, (value - 1e12) / (1e15 - 1e12))
	end

	return 400
end

local function getRacePowerEnergy()
	local racePowerLevel = racePowerUpgrade.Value
	local racePowerMultiplier = 1 + (racePowerLevel * 0.10)

	return energy.Value * racePowerMultiplier
end

local function getTrack()
	return workspace:WaitForChild("RaceTrack")
end

local function getRewardZ(rewardName)
	local reward = findDescendantByName(getTrack(), rewardName)

	if not reward then
		return nil
	end

	return reward.Position.Z
end

local function getLineLocalProgressByZ(z, lineName)
	local startZ
	local endZ

	if lineName == "Line1" then
		startZ = getRewardZ("Reward1")
		endZ = getRewardZ("Reward8")
	elseif lineName == "Line2" then
		startZ = getRewardZ("Reward9")
		endZ = getRewardZ("Reward14")
	elseif lineName == "Line3" then
		startZ = getRewardZ("Reward15")
		endZ = getRewardZ("Reward16")
	end

	if not startZ or not endZ then
		return 0
	end

	local total = endZ - startZ
	if total <= 0 then
		return 0
	end

	return math.clamp((z - startZ) / total, 0, 1)
end

local function getPlayerPanelLineAndProgress()
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		return panelLines.Line1, 0
	end

	local z = hrp.Position.Z

	local reward8Z = getRewardZ("Reward8")
	local reward14Z = getRewardZ("Reward14")

	if reward8Z and z <= reward8Z then
		return panelLines.Line1, getLineLocalProgressByZ(z, "Line1")
	end

	if reward14Z and z <= reward14Z then
		return panelLines.Line2, getLineLocalProgressByZ(z, "Line2")
	end

	return panelLines.Line3, getLineLocalProgressByZ(z, "Line3")
end

local function createRewardMarkers()
	for _, line in pairs(panelLines) do
		for _, child in ipairs(line:GetChildren()) do
			if child.Name:find("_Marker") or child.Name:find("_Segment") then
				child:Destroy()
			end
		end
	end

	local lineRewards = {
		Line1 = {"Reward1", "Reward2", "Reward3", "Reward4", "Reward5", "Reward6", "Reward7", "Reward8"},
		Line2 = {"Reward9", "Reward10", "Reward11", "Reward12", "Reward13", "Reward14"},
		Line3 = {"Reward15", "Reward16"},
	}

	for lineName, rewards in pairs(lineRewards) do
		local line = panelLines[lineName]

		for index = 1, #rewards - 1 do
			local rewardA = findDescendantByName(getTrack(), rewards[index])
			local rewardB = findDescendantByName(getTrack(), rewards[index + 1])

			if rewardA and rewardB and line then
				local startProgress = getLineLocalProgressByZ(rewardA.Position.Z, lineName)
				local endProgress = getLineLocalProgressByZ(rewardB.Position.Z, lineName)

				local segment = Instance.new("Frame")
				segment.Name = rewards[index] .. "_Segment"
				segment.AnchorPoint = Vector2.new(0, 0.5)
				segment.Position = UDim2.new(startProgress, 0, 0.5, 0)
				segment.Size = UDim2.new(endProgress - startProgress, 0, 1, 0)
				segment.BackgroundColor3 = segmentColors[((index - 1) % #segmentColors) + 1]
				segment.BorderSizePixel = 0
				segment.ZIndex = line.ZIndex + 1
				segment.Parent = line
			end
		end

		for _, rewardName in ipairs(rewards) do
			local reward = findDescendantByName(getTrack(), rewardName)

			if reward and line then
				local progress = getLineLocalProgressByZ(reward.Position.Z, lineName)

				local marker = Instance.new("Frame")
				marker.Name = rewardName .. "_Marker"
				marker.Size = UDim2.new(0, 8, 0, 8)
				marker.AnchorPoint = Vector2.new(0.5, 0.5)
				marker.Position = UDim2.new(progress, 0, 0.5, 0)
				marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				marker.BorderSizePixel = 0
				marker.ZIndex = line.ZIndex + 3
				marker.Parent = line

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(1, 0)
				corner.Parent = marker
			end
		end
	end
end

--// Music
local function startRaceMusik()
	backgroundMusic.Volume = 0
	backgroundMusic:Pause()

	raceMusik.TimePosition = 0
	raceMusik.Volume = 0.7
	raceMusik.Looped = true
	raceMusik:Play()
end

local function stopRaceMusic()
	raceMusik:Stop()

	backgroundMusic.Volume = 0.3
	backgroundMusic:Resume()
end

--// UI Updates
local wasInRace = false

local function updateRaceVisibility()
	local visible = inRaceValue.Value

	speedometer.Visible = visible
	leaveButton.Visible = visible
	racePanel.Visible = true
	raceTimer.Visible = true

	if visible and not wasInRace then
		wasInRace = true
		startRaceMusik()
	elseif not visible and wasInRace then
		wasInRace = false
		stopRaceMusic()
	end
end

local function updateSpeedometerTicks()
	local currentEnergy = getRacePowerEnergy()

	if currentEnergy < 1 then
		currentEnergy = 1
	end

	local step = currentEnergy / 5

	tick1.Text = formatShort(0)
	tick2.Text = formatShort(step)
	tick3.Text = formatShort(step * 2)
	tick4.Text = formatShort(step * 3)
	tick5.Text = formatShort(step * 4)
	tick6.Text = formatShort(step * 5)
end

local function updateEnergyLabel()
	local currentEnergy = getRacePowerEnergy()
	energyValueLabel.Text = formatShort(currentEnergy)
end

local function updateArrow()
	local currentEnergy = getRacePowerEnergy()
	local targetSpeed = getTargetSpeedFromEnergy(currentEnergy)
	local currentSpeed = raceSpeedValue.Value

	if targetSpeed <= MIN_SPEED then
		arrow.Rotation = -120
		return
	end

	local alpha = math.clamp((currentSpeed - MIN_SPEED) / (targetSpeed - MIN_SPEED), 0, 1)

	arrow.Rotation = -120 + (MAX_ARROW_ROTATION * alpha)
end

local function updateRacePanel()
	local currentLine, localProgress = getPlayerPanelLineAndProgress()
	localProgress = math.clamp(localProgress, 0, 1)

	panelIcon.Position = UDim2.new(
		currentLine.Position.X.Scale + (currentLine.Size.X.Scale * localProgress),
		currentLine.Position.X.Offset + (currentLine.Size.X.Offset * localProgress),
		currentLine.Position.Y.Scale,
		currentLine.Position.Y.Offset
	)

	--panelTextLabel.Text = math.floor(raceProgressValue.Value * 100) .. "%"
end

local function updateProgressBar()
	if progressFill then
		local progress = math.clamp(raceProgressValue.Value, 0, 1)
		progressFill.Size = UDim2.new(progress, 0, 1, 0)
	end

	updateRacePanel()
end

local function updateRaceTimerUI()
	raceStatusLabel.Text = raceStatusText.Value
	timerStatusLabel.Text = raceTimerText.Value
end

local function updateAllRaceUI()
	updateRaceVisibility()
	updateSpeedometerTicks()
	updateEnergyLabel()
	updateArrow()
	updateProgressBar()
	updateRaceTimerUI()
end

--// Connections
leaveButton.MouseButton1Click:Connect(function()
	leaveRaceEvent:FireServer()
end)

inRaceValue:GetPropertyChangedSignal("Value"):Connect(updateRaceVisibility)

energy.Changed:Connect(function()
	updateSpeedometerTicks()
	updateEnergyLabel()
	updateArrow()
end)

racePowerUpgrade.Changed:Connect(function()
	updateSpeedometerTicks()
	updateEnergyLabel()
	updateArrow()
end)

raceSpeedValue.Changed:Connect(function()
	updateArrow()
	updateRacePanel()
end)

raceProgressValue.Changed:Connect(function()
	updateProgressBar()
	updateRacePanel()
end)

raceStatusText.Changed:Connect(updateRaceTimerUI)
raceTimerText.Changed:Connect(updateRaceTimerUI)

RunService.RenderStepped:Connect(function()
	if racePanel.Visible then
		updateRacePanel()
	end
end)

--// Start
createRewardMarkers()
updateAllRaceUI()

print("RaceUI loaded")

