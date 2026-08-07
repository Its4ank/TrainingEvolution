--// DailyRewardUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local MenuManager = require(ReplicatedStorage.Modules.MenuManager)

local raceGui = script.Parent
local player = Players.LocalPlayer
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local rewardFolderUI = guiFolder:WaitForChild("RewardFolder")

local rewardEventFolder = ReplicatedStorage:WaitForChild("RewardEvent")
local dailyUpdateEvent = rewardEventFolder:WaitForChild("DailyRewardUpdateEvent")
local claimDailyRewardEvent = rewardEventFolder:WaitForChild("ClaimDailyRewardEvent")
local dailyRewardMessageEvent = rewardEventFolder:WaitForChild("DailyRewardMessageEvent")
local requestDailyRewardUpdateEvent = rewardEventFolder:WaitForChild("RequestDailyRewardUpdateEvent")

local dailyRewardFrame = rewardFolderUI:WaitForChild("DailyRewardFrame")

MenuManager.register("DailyRewards", dailyRewardFrame)

local uiBalance = guiFolder:WaitForChild("UIBalance")
local openRewardButton = uiBalance:WaitForChild("OpenRewardButton")

local lockTextLabel = dailyRewardFrame:WaitForChild("LockTextLabel")

local strikRewardFrame = dailyRewardFrame:WaitForChild("StrikRewardFrame")
local strikIconLabel = strikRewardFrame:WaitForChild("StrikIconLabel")
local streakLabel = strikRewardFrame:WaitForChild("StreakLabel")
local strikImageLabel = strikRewardFrame:WaitForChild("StrikImageLabel")
local chestStrikButton = strikRewardFrame:WaitForChild("ChestStrikButton")
local claimChestButton = dailyRewardFrame:WaitForChild("ClaimChestButton")
local closeRewardButton = dailyRewardFrame:WaitForChild("CloseRewardButton")

--// Settings
local VISIBLE_REWARD_SLOTS = 7
local DAYS_PER_WEEK = 7

local streakImages = {
	[0] = "rbxassetid://96634192024275",
	[1] = "rbxassetid://96634192024275",
	[2] = "rbxassetid://131185548649789",
	[3] = "rbxassetid://137678262683000",
	[4] = "rbxassetid://114886882688620",
	[5] = "rbxassetid://80474345501469",
	[6] = "rbxassetid://70748168572506",
	[7] = "rbxassetid://109460695683413",
}

--// Runtime data
local rewardSlots = {}

local lastDailyData = nil
local visibleRewards = {}

local lockHideTask = nil
local localTimerConnection = nil

--// Helpers
local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	
	if days > 0 then
		return days .. "d " .. hours .. "h"
	elseif hours > 0 then
		return hours .. "h " .. minutes .. "m"
	else
		return minutes .. "m " .. secs .. "s"
	end
end

local function showLockText(text)
	lockTextLabel.Text = text
	lockTextLabel.Visible = true
	
	if lockHideTask then
		task.cancel(lockHideTask)
	end
	
	lockHideTask = task.delay(4, function()
		lockTextLabel.Visible = false
	end)
end

local function getOptionalObject(parent, objectNames)
	for _, objectName in ipairs(objectNames) do 
		local object = parent:FindFirstChild(objectName, true)
		
		if object then return object end
	end
	return nil
end

local function setButtonEnabled(button, enabled)
	button.Active = enabled
	button.AutoButtonColor = enabled
	button.Selectable = enabled
end

local function setupRewardSlots()
	for slotNumber = 1, VISIBLE_REWARD_SLOTS do 
		local rewardImage = dailyRewardFrame:WaitForChild("Rewards" .. slotNumber .. "Image")
		local claimButton = rewardImage:WaitForChild("ClaimRewardButton")
		local claimLabel = claimButton:WaitForChild("ClaimRewardLabel")
		local lockButton = rewardImage:WaitForChild("LockRewardsButton")
		local dayLabel = rewardImage:WaitForChild("DayRewardsLabel")
		local timerLabel = rewardImage:WaitForChild("TimerRewardLabel")
		
		local rewardIcon = getOptionalObject(rewardImage, {
			"RewardIcon",
			"RewardIconLabel",
			"RewardImageLabel",
		})
		
		local rewardValueLabel = getOptionalObject(rewardImage, {
			"RewardValueLabel",
			"RewardInfoLabel",
			"RewardAmountLabel",
		})
		
		local rewardNameLabel = getOptionalObject(rewardImage, {
			"RewardNameLabel",
			"RewardTitleLabel",
		})
		
		rewardSlots[slotNumber] = {
			Frame = rewardImage,
			
			ClaimButton = claimButton,
			ClaimLabel = claimLabel,
			
			LockButton = lockButton,
			
			DayLabel = dayLabel,
			TimerLabel = timerLabel,
			
			RewardIcon = rewardIcon,
			RewardValueLabel = rewardValueLabel,
			RewardNameLabel = rewardNameLabel,
			
			RewardData = nil,
		}
		
		claimButton.Visible = false
		
		claimButton.MouseButton1Click:Connect(function()
			local slot = rewardSlots[slotNumber]
			local rewardData = slot and slot.RewardData
			
			if not rewardData then
				showLockText("Reward data is loading...")
				return
			end
			
			if rewardData.IsClaimed then
				showLockText("This reward has already been claimed.")
				return
			end
			
			if not rewardData.IsAvailable then
				showLockText("Reward will be available in. " .. formatTime(rewardData.TimeLeft))
				return
			end
			
			claimDailyRewardEvent:FireServer(rewardData.Day)
		end)
		
		lockButton.MouseButton1Click:Connect(function()
			local slot = rewardSlots[slotNumber]
			local rewardData = slot and slot.RewardData
			
			if not rewardData then
				showLockText("Reward data is loading...")
				return
			end
			
			if rewardData.IsClaimed then
				showLockText("This reward has already been claimed.")
				return
			end
			
			if rewardData.IsAvailable then
				showLockText("Reward is available!")
				return
			end
			
			showLockText("Reward will be available in " .. formatTime(rewardData.TimeLeft))
		end)
	end
end

--//Week selection
local function getCurrentWeekBounds(data)
	local scheduleDay = math.clamp(tonumber(data.ScheduleDay) or 1, 1, 28)
	local weekIndex = math.floor((scheduleDay - 1) / DAYS_PER_WEEK)
	local firstScheduleSlot = (weekIndex * DAYS_PER_WEEK) + 1
	local lastScheduleSlot = firstScheduleSlot + DAYS_PER_WEEK - 1
	
	return firstScheduleSlot, lastScheduleSlot
end

local function collectVisibleRewards(data)
	local firstSlot, lastSlot = getCurrentWeekBounds(data)
	local result = {}
	
	for _, rewardData in ipairs(data.Rewards or {}) do
		local scheduleSlot = tonumber(rewardData.ScheduleDay) or tonumber(rewardData.Slot)
		
		if scheduleSlot and scheduleSlot >= firstSlot and scheduleSlot <= lastSlot then
			table.insert(result, rewardData)
		end
	end
	
	table.sort(result, function(a, b)
		local aSlot = a.ScheduleDay or a.Slot or 0
		local bSlot = b.ScheduleDay or b.Slot or 0
		
		return aSlot < bSlot
	end)
	return result
end

--// Slot visual
local function clearRewardSlot(slot)
	slot.RewardData = nil
	
	slot.DayLabel.Text = "Day -"
	slot.TimerLabel.Text = ""
	
	slot.ClaimButton.Visible = false
	setButtonEnabled(slot.ClaimButton, false)
	
	slot.LockButton.Visible = true
	setButtonEnabled(slot.LockButton, false)
	
	if slot.RewardValueLabel then
		slot.RewardValueLabel.Text = ""
	end
	
	if slot.RewardNameLabel then
		slot.RewardNameLabel.Text = ""
	end
	
	if slot.RewardIcon and (slot.RewardIcon:IsA("ImageLabel") or slot.RewardIcon and slot.RewardIcon:IsA("ImageButton")) then
		slot.RewardIcon.Image = ""
	end
end

local function updateRewardSlot(slot, rewardData)
	slot.RewardData = rewardData
	slot.DayLabel.Text = "Day " .. tostring(rewardData.Day)
	
	if slot.RewardValueLabel then
		slot.RewardValueLabel.Text = tostring(rewardData.DisplayText or rewardData.Name or "Reward")
	end
	
	if slot.RewardNameLabel then
		slot.RewardNameLabel.Text = tostring(rewardData.Name or rewardData.Type or "Reward")
	end
	
	if slot.RewardIcon and (slot.RewardIcon:IsA("ImageLabel") or slot.RewardIcon:IsA("ImageButton")) then
		slot.RewardIcon.Image = tostring(rewardData.Icon or "")
	end
	
	if rewardData.IsClaimed then
		slot.TimerLabel.Text = "Claimed"
		
		slot.ClaimButton.Visible = true
		slot.ClaimLabel.Text = "CLAIMED"
		
		setButtonEnabled(slot.ClaimButton, false)
		
		slot.LockButton.Visible = false
		setButtonEnabled(slot.LockButton, false)
	elseif rewardData.IsAvailable then
		slot.TimerLabel.Text = "Available"
		
		slot.ClaimButton.Visible = true
		slot.ClaimLabel.Text = "CLAIM"
		
		setButtonEnabled(slot.ClaimButton, true)
		
		slot.LockButton.Visible = false
		setButtonEnabled(slot.LockButton, false)
	else
		slot.TimerLabel.Text = formatTime(rewardData.TimeLeft)
		
		slot.ClaimButton.Visible = false
		setButtonEnabled(slot.ClaimButton, false)
		
		slot.LockButton.Visible = true
		setButtonEnabled(slot.LockButton, true)
	end
end

--// Streak visual
local function updateStreakUI(data)
	local streak = math.max(0, math.floor(tonumber(data.Streak) or 0))
	local visualStreak = math.clamp(streak, 0, 7)
	
	strikIconLabel.Text = tostring(visualStreak)
	streakLabel.Text = tostring(visualStreak)
	
	local imageId = streakImages[visualStreak]
	
	if imageId and imageId ~= "" then
		strikImageLabel.Image = imageId
	end
	
	claimChestButton.Visible = false
end

--// Full UI update
local function updateDailyUI(data)
	if type(data) ~= "table" then return end
	
	lastDailyData = data
	visibleRewards = collectVisibleRewards(data)
	
	for slotNumber = 1, VISIBLE_REWARD_SLOTS do
		local slot = rewardSlots[slotNumber]
		local rewardData = visibleRewards[slotNumber]
		
		if slot then
			if rewardData then
				updateRewardSlot(slot, rewardData)
			else
				clearRewardSlot(slot)
			end
		end
	end
	
	updateStreakUI(data)
end

--// Local countdown
local function startLocalCountdown()
	if localTimerConnection then return end
	
	localTimerConnection = task.spawn(function()
		while raceGui.Parent do
			task.wait(1)
			
			if lastDailyData then
				for _, rewardData in ipairs(visibleRewards) do
					if not rewardData.IsClaimed and not rewardData.IsAvailable then
						rewardData.TimeLeft = math.max(0, (tonumber(rewardData.TimeLeft) or 0) - 1)
					end
				end
				
				for slotNumber = 1, VISIBLE_REWARD_SLOTS do
					local slot = rewardSlots[slotNumber]
					local rewardData = slot and slot.RewardData
					
					if slot and rewardData and not rewardData.IsClaimed and not rewardData.IsAvailable then
						slot.TimerLabel.Text = formatTime(rewardData.TimeLeft)
					end
				end
			end
		end
	end)
end

--// Menu controls
local function openMenu()
	MenuManager.openBlur("DailyRewards")
	
	requestDailyRewardUpdateEvent:FireServer()
end

local function closeMenu()
	MenuManager.close("DailyRewards")
end

openRewardButton.MouseButton1Click:Connect(function()
	if dailyRewardFrame.Visible then
		closeMenu()
	else
		openMenu()
	end
end)

closeRewardButton.MouseButton1Click:Connect(function()
	closeMenu()
end)

--// Server updates
dailyUpdateEvent.OnClientEvent:Connect(function(data)
	updateDailyUI(data)
end)

dailyRewardMessageEvent.OnClientEvent:Connect(function(message)
	showLockText(message)
end)

--// Chest placeholder
chestStrikButton.MouseButton1Click:Connect(function()
	showLockText(("Streak chest rewards will be added later."))
end)

claimChestButton.MouseButton1Click:Connect(function()
	showLockText("Streak chest rewards will be added later.")
end)

--// Initialization
setupRewardSlots()
startLocalCountdown()

dailyRewardFrame.Visible = false
lockTextLabel.Visible = false
claimChestButton.Visible = false

print("DailyRewardUI loaded")
