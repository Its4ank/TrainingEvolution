local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)

local raceGui = script.Parent
local player = Players.LocalPlayer
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")

local rewardEventFolder = ReplicatedStorage:WaitForChild("RewardEvent")
local hourlyUpdateEvent = rewardEventFolder:WaitForChild("HourlyRewardUpdateEvent")
local claimHourlyRewardEvent = rewardEventFolder:WaitForChild("ClaimHourlyRewardEvent")
local requestHourlyRewardUpdateEvent = rewardEventFolder:WaitForChild("RequestHourlyRewardUpdateEvent")

local rewardFolder = guiFolder:WaitForChild("RewardFolder")
local hourlyRewardFrame = rewardFolder:WaitForChild("HourlyRewardFrame")

local uiBalance = guiFolder:WaitForChild("UIBalance")
local openHourlyButton = uiBalance:WaitForChild("OpenHourlyButton")

local closeHourlyButton = hourlyRewardFrame:WaitForChild("CloseHourlyButton")
local hourlyTimerLabel = hourlyRewardFrame:WaitForChild("HourlyTimerLabel")
local rewardTimeInfoLabel = hourlyRewardFrame:WaitForChild("RewardTimeInfoLabel")

local hourlyRewardBox = hourlyRewardFrame:WaitForChild("HourlyRewardBox")

MenuManager.register("HourlyRewards", hourlyRewardFrame)

local rewardSlots = {}
local lastHourlyData = nil
local infoHideTask = nil

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	
	if hours > 0 then
		return hours .. "h " .. minutes .. "m"
	else
		return minutes .. "m " .. secs .. "s"
	end
end

local function showInfoText(text)
	rewardTimeInfoLabel.Text = text 
	rewardTimeInfoLabel.Visible = true
	
	if infoHideTask then
		task.cancel(infoHideTask)
	end
	
	infoHideTask = task.delay(4, function()
		rewardTimeInfoLabel.Visible = false
	end)
end

local function openMenu()
	MenuManager.open("HourlyRewards")
	requestHourlyRewardUpdateEvent:FireServer()
end

local function closeMenu()
	MenuManager.close("HourlyRewards")
end

local function getRewardFrame(slot)
	local lineNumber = math.ceil(slot / 4)
	local lineFrame = hourlyRewardBox:FindFirstChild("RewardLine" .. lineNumber)
	
	return lineFrame:FindFirstChild("HourlyRewards" .. slot)
end

local function setupRewardSlots()
	for i = 1, 12 do
		local rewardFrame = getRewardFrame(i)
		
		local rewardButton = rewardFrame:WaitForChild("HourlyRewardButton")
		local rewardInfoLabel = rewardButton:WaitForChild("HourlyRewardInfoLabel")
		
		local rewardTimerLabel = rewardFrame:WaitForChild("HourlyRewardTimer")
		local rewardValueLabel = rewardFrame:WaitForChild("Reward1Value")
		
		rewardSlots[i] = {
			Frame = rewardFrame,
			Button = rewardButton,
			InfoLabel = rewardInfoLabel,
			TimerLabel = rewardTimerLabel,
			ValueLabel = rewardValueLabel,
		}
		
		rewardButton.Visible = false
		
		rewardButton.MouseButton1Click:Connect(function()
			if not lastHourlyData then 
				showInfoText("Rewards are loading...")
				return
			end
			
			local rewardData = lastHourlyData.Rewards[i]
			if not rewardData then
				return
			end
			
			if rewardData.IsAvailable then
				claimHourlyRewardEvent:FireServer(i)
				return
			end
			
			if rewardData.IsClaimed then
				showInfoText( 
					"Reward will refresh in "
					.. formatTime(lastHourlyData.ResetTimeLeft)
				    .. ". After refresh it unlocks in "
			        .. formatTime(rewardData.UnlockTime)
				)
				return
			end
			
			showInfoText( 
				"Reward unlocks in "
				.. formatTime(rewardData.TimeLeft)
			)
		end)
	end
end

local function updateHourlyUI(data)
	lastHourlyData = data 
	
	hourlyTimerLabel.Text = "Reward Refresh in " .. formatTime(data.ResetTimeLeft)
	
	for _, rewardData in ipairs(data.Rewards) do
		local slot = rewardSlots[rewardData.Slot]
		
		if slot then
			slot.ValueLabel.Text = rewardData.DisplayText
			
			if rewardData.IsClaimed then
				slot.TimerLabel.Text = "Claimed"
				slot.Button.Visible = true
				slot.Button.Active = true
				slot.InfoLabel.Text = "CLAIMED"

			elseif rewardData.IsAvailable then
				slot.TimerLabel.Text = "Available"
				slot.Button.Visible = true
				slot.Button.Active = true
				slot.InfoLabel.Text = "CLAIM"

			else
				slot.TimerLabel.Text = formatTime(rewardData.TimeLeft)
				slot.Button.Visible = false
				slot.Button.Active = true
				slot.InfoLabel.Text = "LOCKED"
			end
		end
	end
end

openHourlyButton.MouseButton1Click:Connect(function()
	MenuManager.toggleBlur("HourlyRewards")
end)

closeHourlyButton.MouseButton1Click:Connect(function()
	MenuManager.close("HourlyRewards")
end)

hourlyUpdateEvent.OnClientEvent:Connect(function(data)
	updateHourlyUI(data)
end)

setupRewardSlots()

hourlyRewardFrame.Visible = false
rewardTimeInfoLabel.Visible = false

print("HourlyRewardUI loaded")
