local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)

local raceGui = script.Parent
local player = Players.LocalPlayer
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local rewardFolderUI = guiFolder:WaitForChild("RewardFolder")

local rewardEventFolder = ReplicatedStorage:WaitForChild("RewardEvent")
local dailyUpdateEvent = rewardEventFolder:WaitForChild("DailyRewardUpdateEvent")
local claimDailyRewardEvent = rewardEventFolder:WaitForChild("ClaimDailyRewardEvent")
local dailyRewardMessageEvent = rewardEventFolder:WaitForChild("DailyRewardMessageEvent")

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
local closeReward = dailyRewardFrame:WaitForChild("CloseRewardButton")

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

local rewardSlots = {}
local lastDailyData = nil
local lockHideTask = nil

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

local function openMenu()
	MenuManager.open("DailyRewards")
end

local function closeMenu()
	MenuManager.close("DailyRewards")
end

openRewardButton.MouseButton1Click:Connect(function()
	MenuManager.toggleBlur("DailyRewards")
end)

local closeRewardButton = dailyRewardFrame:WaitForChild("CloseRewardButton")

closeRewardButton.MouseButton1Click:Connect(function()
	MenuManager.close("DailyRewards")
end)

local function setupRewardSlots()
	for i = 1, 7 do
		local rewardImage = dailyRewardFrame:WaitForChild("Rewards" .. i .. "Image")
		
		local claimButton = rewardImage:WaitForChild("ClaimRewardButton")
		local claimLabel = claimButton:WaitForChild("ClaimRewardLabel")
		
		local lockButton = rewardImage:WaitForChild("LockRewardsButton")
		local dayLabel = rewardImage:WaitForChild("DayRewardsLabel")
		local timerLabel = rewardImage:WaitForChild("TimerRewardLabel")
		
		rewardSlots[i] = {
			RewardImage = rewardImage,
			ClaimButton = claimButton,
			ClaimLabel = claimLabel,
			LockButton = lockButton,
			DayLabel = dayLabel,
			TimerLabel = timerLabel,
		}
		
		claimButton.Visible = false
		
		claimButton.MouseButton1Click:Connect(function()
			claimDailyRewardEvent:FireServer(i)
		end)
		
		lockButton.MouseButton1Click:Connect(function()
			if not lastDailyData then
				return
			end
			
			local rewardData = lastDailyData.Rewards[i]
			if not rewardData then
				return
			end
			
			if rewardData.IsAvailable then
				showLockText("Reward is available!")
				return
			end
			
			showLockText( 
				"Reward will be available in "
				.. formatTime(rewardData.TimeLeft)
			)
		end)
	end
end

local function updateDailyUI(data)
	lastDailyData = data 
	
	for _, rewardData in ipairs(data.Rewards) do 
		local slot = rewardSlots[rewardData.Slot]
		if slot then
			slot.DayLabel.Text = "Day " .. tostring(rewardData.Day)
			
			if rewardData.IsAvailable then
				slot.TimerLabel.Text = "Available"
				slot.ClaimButton.Visible = true
				slot.ClaimLabel.Text = "CLAIM"
			elseif rewardData.IsClaimed then
				slot.TimerLabel.Text = "Claimed"
				slot.ClaimButton.Visible = true
				slot.ClaimLabel.Text = "CLAIMED"
			else
				slot.TimerLabel.Text = formatTime(rewardData.TimeLeft)
				slot.ClaimButton.Visible = false
			end
		end
	end
	
	local streak = math.clamp(data.Streak or 0, 0, 7)
	
	strikIconLabel.Text = tostring(streak)
	streakLabel.Text = tostring(streak) .. " Days"
	
	if streakImages[streak] and streakImages[streak] ~= "" then
		strikImageLabel.Image = streakImages[streak]
	end
	
	claimChestButton.Visible = data.ChestAvailable == true
end

dailyUpdateEvent.OnClientEvent:Connect(function(data)
	updateDailyUI(data)
end)

dailyRewardMessageEvent.OnClientEvent:Connect(function(message)
	showLockText(message)
end)

chestStrikButton.MouseButton1Click:Connect(function()
	showLockText("Reach 7 Days streak to unlock this chest!")
end)

claimChestButton.MouseButton1Click:Connect(function()
	showLockText("Chest reward will be added later")
end)

closeReward.MouseButton1Click:Connect(function()
	dailyRewardFrame.Visible = false
end)

setupRewardSlots()

dailyRewardFrame.Visible = false
lockTextLabel.Visible = false
claimChestButton.Visible = false

print("DailyRewardUI loaded")
