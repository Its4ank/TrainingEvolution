--// TreadmillUI

--//Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Player
local gui = script.Parent

local treadmillFolder = gui:WaitForChild("TreadmillFolder")

local treadmillHost = treadmillFolder:WaitForChild("TreadmillHost")
local treadBlur = treadmillFolder:WaitForChild("TreadBlur")
local treadTierFrame = treadmillFolder:WaitForChild("TreadTierFrame")
local treadWarningLabel = treadmillFolder:WaitForChild("TreadWarningLabel")

--// Host
local treadmillViewport = treadmillHost:WaitForChild("TreadmillViewport")
local treadmillLocation = treadmillHost:WaitForChild("TreadmillLocation")
local treadmillDetails = treadmillHost:WaitForChild("TreadmillDetails")
local treadCloseButton = treadmillHost:WaitForChild("TreadCloseButton")

--// Tier Frame 
local tierCurrentName = treadTierFrame:WaitForChild("TierCurrentName")
local tierNextName = treadTierFrame:WaitForChild("TierNextName")

local tierCurrentIcon = treadTierFrame:WaitForChild("TierCurrentIcon")
local tierNextIcon = treadTierFrame:WaitForChild("TierNextIcon")

local tierCurrentBoost = treadTierFrame:WaitForChild("TierCurrentBoost")
local tierNextBoost = treadTierFrame:WaitForChild("TierNextBoost")

local energyRequirStatus = treadTierFrame:WaitForChild("EnergyRequirStatus")
local rebirthRequirStatus = treadTierFrame:WaitForChild("RebirthRequirStatus")
local timeRequirStatus = treadTierFrame:WaitForChild("TimeRequirStatus")

local energyRequir = treadTierFrame:WaitForChild("EnergyRequir")
local rebirthRequir = treadTierFrame:WaitForChild("RebirthRequir")
local timeRequir = treadTierFrame:WaitForChild("TimeRequir")

local energyBar = energyRequir:WaitForChild("FrameRequirCompl")
local rebirthBar = rebirthRequir:WaitForChild("FrameRequirCompl")
local timeBar = timeRequir:WaitForChild("FrameRequirCompl")

local tierUpButton = treadTierFrame:WaitForChild("TierUpButton")
local tierBackButton = treadTierFrame:WaitForChild("TierBackButton")

--// Location
local treadStoneChoice = treadmillLocation:WaitForChild("TreadStoneChoice")

--// Viewport
local treadChoiceNext = treadmillViewport:WaitForChild("TreadChoiceNext")
local treadChoiceBack = treadmillViewport:WaitForChild("TreadChoiceBack")

local treadViewChoice1 = treadmillViewport:WaitForChild("TreadViewChoice1")
local treadViewChoice2 = treadmillViewport:WaitForChild("TreadViewChoice2")
local treadViewChoice3 = treadmillViewport:WaitForChild("TreadViewChoice3")

local treadStatusLabel = treadmillViewport:WaitForChild("TreadStatusLabel")
local lockedTreadFrame = treadmillViewport:WaitForChild("LockedTreadFrame")

--// Details
local upgTreadButton = treadmillDetails:WaitForChild("UpgTreadButton")
local upgValue = treadmillDetails:WaitForChild("UpgValue")

local treadStageIcon = treadmillDetails:WaitForChild("TreadStageIcon")
local treadStageName = treadmillDetails:WaitForChild("TreadStageName")
local treadStageNumber = treadmillDetails:WaitForChild("TreadStageNumber")
local treadLvlNumber = treadmillDetails:WaitForChild("TreadLvlNumber")
local treadQuanCurrent = treadmillDetails:WaitForChild("TreadQuanCurrent")
local treadQuanNext = treadmillDetails:WaitForChild("TreadQuanNext")

local tierOpenButton = treadmillDetails:WaitForChild("TierOpenButton")

--// Remote 
local treadmillEventFolder = ReplicatedStorage:WaitForChild("TreadmillEvents")
local treadmillRequestEvent = treadmillEventFolder:WaitForChild("TreadmillRequestEvent")
local treadmillResponseEvent = treadmillEventFolder:WaitForChild("TreadmillResponseEvent")
local treadmillInfoFunction = treadmillEventFolder:WaitForChild("TreadmillInfoFunction")

--// Settings
local MAX_TREADMILLS = 3

local selectedTreadmillId = 1
local currentInfo = nil

--// Icons
local TREADMILL_ICONS = { 
	[1] = { 
		Normal = "rbxassetid://99507594373860",
		Selected = "rbxassetid://99208116534485",
	},
	
	[2] = { 
		Normal = "rbxassetid://99507594373860",
		Selected = "rbxassetid://99208116534485",
	},
	
	[3] = { 
		Normal = "rbxassetid://99507594373860",
		Selected = "rbxassetid://99208116534485",
	},
}

--// Initial state
treadmillHost.Visible = false
treadmillViewport.Visible = false
treadmillDetails.Visible = false
treadmillLocation.Visible = false
treadTierFrame.Visible = false
treadBlur.Visible = false
treadWarningLabel.Visible = false

--// Helpers
local function setImage(object, imageId)
	if object:IsA("ImageLabel") or object:IsA("ImageButton") then
		object.Image = imageId or ""
	end
end

local function setText(object, text)
	if object:IsA("TextLabel") or object:IsA("TextButton") then
		object.Text = text
		return
	end
	
	local label = object:FindFirstChildWhichIsA("TextLabel", true)
	if label then 
		label.Text = text
	end
end

local function formatShort(n)
	n = tonumber(n) or 0
	
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

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	
	if hours > 0 then
		return tostring(hours) .. "h " .. tostring(minutes) .. "m"
	end
	
	if minutes > 0 then 
		return tostring(minutes) .. "m " .. tostring(secs) .. "s"
	end
	
	return tostring(secs) .. "s"
end

local function showWarning(text)
	treadWarningLabel.Visible = true 
	treadWarningLabel.Text = text 
	
	task.delay(3, function()
		if treadWarningLabel.Text == text then 
			treadWarningLabel.Visible = false
		end
	end)
end

local function getProgress(current, required)
	current = tonumber(current) or 0
	required = tonumber(required) or 1
	
	if required <= 0 then
		return 1
	end
	
	return math.clamp(current / required, 0, 1)
end

local function tweenRequirementBar(bar, progress)
	local x = -1 + progress 
	
	TweenService:Create( 
		bar,
		TweenInfo.new(0.25),
		{ 
			Position = UDim2.new(x, 0, 0.625, 0)
		}
	):Play()
end

local function getInfo(treadmillId)
	local success, result = pcall(function()
		return treadmillInfoFunction:InvokeServer(treadmillId)
	end)
	
	if success then 
		return result
	end
	
	warn("Failed to get treadmill info:", result)
	return nil
end

local function updateChoiceIcons()
	local choices = { 
		[1] = treadViewChoice1,
		[2] = treadViewChoice2,
		[3] = treadViewChoice3,
	}
	
	for i = 1, MAX_TREADMILLS do
		local iconData = TREADMILL_ICONS[i]
		local imageId = ""
		
		if iconData then 
			if selectedTreadmillId == i then
				imageId = iconData.Selected
			else 
				imageId = iconData.Normal
			end
		end
		
		setImage(choices[i], imageId)
	end
end

local function buildMissingText(info)
	if not info or not info.TierInfo then
		return "Requirements are not completed"
	end
	
	local missing = info.TierInfo.Missing
	if not missing then 
		return "Requirements are not completed"
	end
	
	local parts = {}
	
	if missing.Level and missing.Level > 0 then
		table.insert(parts, tostring(missing.Level) .. " Level")
	end
	
	if missing.Energy and missing.Energy > 0 then
		table.insert(parts, formatShort(missing.Energy) .. " Energy")
	end
	
	if missing.Rebirth and missing.Rebirth > 0 then
		table.insert(parts, formatShort(missing.Rebirth) .. " Rebirth")
	end
	
	if missing.Time and missing.Time > 0 then
		table.insert(parts, formatTime(missing.Time) .. " Training Time")
	end
	
	if #parts <= 0 then
		return "Requirements are not completed"
	end
	
	return "Need: " .. table.concat(parts, ", ")
end

local function updateTierFrame(info)
	if not info then return end 
	
	local tierInfo = info.TierInfo
	local isMaxStage = info.Stage >= info.MaxStage
	
	tierCurrentName.Text = info.StageName or "Unknown"
	tierCurrentBoost.Text = "x" .. string.format("%.2f", info.StageMultiplier or 1)
	
	setImage(tierCurrentIcon, info.StageIcon)
	
	if isMaxStage then
		tierNextName.Text = "MAX"
		tierNextBoost.Text = "MAX"
		setImage(tierNextIcon, info.StageIcon)
		
		energyRequirStatus.Text = "MAX"
		rebirthRequirStatus.Text = "MAX"
		timeRequirStatus.Text = "MAX"
		
		tweenRequirementBar(energyBar, 1)
		tweenRequirementBar(rebirthBar, 1)
		tweenRequirementBar(timeBar, 1)
		
		setText(tierUpButton, "MAX TIER")
		return
	end
	
	tierNextName.Text = info.NextStageName or "Unknown"
	tierNextBoost.Text = "x" .. string.format("%.2f", info.NextStageMultiplier or 1)
	setImage(tierNextIcon, info.NextStageIcon)
	
	if not tierInfo or not tierInfo.Requirement or not tierInfo.Current then 
		return
	end
	
	local req = tierInfo.Requirement
	local cur = tierInfo.Current
	
	energyRequirStatus.Text = formatShort(cur.Energy) .. " / " .. formatShort(req.Energy) .. " Energy"
	rebirthRequirStatus.Text = formatShort(cur.Rebirth) .. " / " .. formatShort(req.Rebirth) .. " Rebirth"
	timeRequirStatus.Text = formatTime(cur.Time) .. " / " .. formatTime(req.Time)
	
	tweenRequirementBar(energyBar, getProgress(cur.Energy, req.Energy))
	tweenRequirementBar(rebirthBar, getProgress(cur.Rebirth, req.Rebirth))
	tweenRequirementBar(timeBar, getProgress(cur.Time, req.Time))
	
	if info.CanTierUp then 
		setText(tierUpButton, "TIER UP")
	else
		setText(tierUpButton, "LOCKED")
	end
end

local function updateDetails(info)
	if not info then return end 
	
	currentInfo = info
	treadStatusLabel.Text = info.Name or ("Treadmill " .. selectedTreadmillId)
	updateChoiceIcons()
	
	if not info.Unlocked then 
		lockedTreadFrame.Visible = true 
		treadmillDetails.Visible = false
		return
	end
	
	lockedTreadFrame.Visible = false
	treadmillDetails.Visible = true 
	
	treadStageName.Text = info.StageName or "Unknown"
	treadStageNumber.Text = "Stage " .. tostring(info.Stage)
	treadLvlNumber.Text = "Lvl: " .. tostring(info.Level) .. " / " .. tostring(info.StageMaxLevel)
	
	treadQuanCurrent.Text = "+" .. formatShort(info.CurrentEnergy) .. " Energy/sec"
	treadQuanNext.Text = "+" .. formatShort(info.NextEnergy) .. " Next"
	
	setImage(treadStageIcon, info.StageIcon)
	
	if info.Level >= info.MaxLevel then 
		upgValue.Text = "MAX LEVEL"
	elseif info.Level >= info.StageMaxLevel then
		upgValue.Text = "Tier Up Required"
	else 
		upgValue.Text = formatShort(info.LevelPrice) .. " Energy"
	end
	
	updateTierFrame(info)
end

local function refreshSelectedTreadmill()
	local info = getInfo(selectedTreadmillId)
	updateDetails(info)
end

local function openTreadmillMenu()
	treadmillHost.Visible = true 
	treadmillViewport.Visible = true 
	treadmillLocation.Visible = true 
	treadmillDetails.Visible = true 
	
	selectedTreadmillId = 1
	refreshSelectedTreadmill()
end

local function closeTreadmillMenu()
	treadmillHost.Visible = false 
	treadmillViewport.Visible = false 
	treadmillLocation.Visible = true
	treadmillDetails.Visible = false 
	
	treadTierFrame.Visible = false 
	treadBlur.Visible = false
	treadWarningLabel.Visible = false
end

local function openTierFrame()
	treadBlur.Visible = true 
	treadTierFrame.Visible = true
	refreshSelectedTreadmill()
end

local function closeTierFrame()
	treadBlur.Visible = false 
	treadTierFrame.Visible = false
end

--// Buttons 
treadStoneChoice.MouseButton1Click:Connect(function()
	openTreadmillMenu()
end)

treadCloseButton.MouseButton1Click:Connect(function()
	closeTreadmillMenu()
end)

treadChoiceNext.MouseButton1Click:Connect(function()
	selectedTreadmillId += 1
	
	if selectedTreadmillId > MAX_TREADMILLS then
		selectedTreadmillId = 1
	end
	
	refreshSelectedTreadmill()
end)

treadChoiceBack.MouseButton1Click:Connect(function()
	selectedTreadmillId -= 1
	
	if selectedTreadmillId < 1 then
		selectedTreadmillId = MAX_TREADMILLS
	end
	
	refreshSelectedTreadmill()
end)

if tierOpenButton then 
	tierOpenButton.MouseButton1Click:Connect(function()
		openTierFrame()
	end)
else 
	warn("TierOpenButton not found in TreadmillDetails")
end

tierBackButton.MouseButton1Click:Connect(function()
	closeTierFrame()
end)

upgTreadButton.MouseButton1Click:Connect(function()
	treadmillRequestEvent:FireServer("UpgradeLevel", selectedTreadmillId)
end)

tierUpButton.MouseButton1Click:Connect(function()
	if currentInfo and currentInfo.CanTierUp then 
		treadmillRequestEvent:FireServer("TierUp", selectedTreadmillId)
	else 
		showWarning(buildMissingText(currentInfo))
	end
end)

--// Server responses
treadmillResponseEvent.OnClientEvent:Connect(function(action, success, reason, info)
	if action == "UpgradeLevel" then 
		if not success then 
			if reason == "NOT_ENOUGH_ENERGY" and info and info.Need then
				showWarning("Need " .. formatShort(info.Need) .. " more Energy")
			elseif reason == "NEED_STAGE_UP" then
				showWarning("Upgrade your Tier first")
			elseif reason == "MAX_LEVEL" then 
				showWarning("Treadmill already max level")
			elseif reason == "LOCKED" then 
				showWarning("This treadmill is locked")
			else 
				showWarning("Upgrade failed: " .. tostring(reason))
			end
		end
		
		refreshSelectedTreadmill()
	end
	
	if action == "TierUp" then 
		if not success then 
			showWarning(buildMissingText({ 
				TierInfo = info
			}))
		else
			showWarning("Tier upgrade!")
			closeTierFrame()
		end
		
		refreshSelectedTreadmill()
	end
end)

--// Auto refresh every second
task.spawn(function()
	while true do 
		task.wait(1)
		
		if treadmillHost.Visible then 
			refreshSelectedTreadmill()
		end
	end
end)
