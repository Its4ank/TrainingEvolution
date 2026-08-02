local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)
local UpdateConfig = require(game.ReplicatedStorage.Modules.UpdateConfig)

local updateEventFolder = ReplicatedStorage:WaitForChild("UpdateEvent")
local updateViewedEvent = updateEventFolder:WaitForChild("UpdateViewedEvent")

local raceGui = script.Parent
local player = Players.LocalPlayer
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local updateFolder = guiFolder:WaitForChild("UpdateFolder")
local updateFrame = updateFolder:WaitForChild("UpdateFrame")
local uiBalance = guiFolder:WaitForChild("UIBalance")
local openUpdateFrame = uiBalance:WaitForChild("OpenUpdateFrame")

MenuManager.register("UpdateFrame", updateFrame)

--//updateFrame
local updFrame = updateFrame:WaitForChild("UPDFrame")
local scrollingFrameButton = updateFrame:WaitForChild("ScrollingFrameButton")
local closeUpdateFrame = updateFrame:WaitForChild("CloseUpdateButton")

--// scrollingFrameButton
local upd0Button = scrollingFrameButton:WaitForChild("UPD0Button")
local upd1Button = scrollingFrameButton:WaitForChild("UPD1Button")
local upd2Button = scrollingFrameButton:WaitForChild("UPD2Button")

--//UPDFrame
local scrolingUPD0 = updFrame:WaitForChild("ScrollingUPD0")
local scrolingUPD1 = updFrame:WaitForChild("ScrollingUPD1")
local scrolingUPD2 = updFrame:WaitForChild("ScrollingUPD2")

local updateEntries = {}

for version, updateInfo in pairs(UpdateConfig.Updates) do
	local button = scrollingFrameButton:FindFirstChild(updateInfo.ButtonName)
	local frame = updFrame:FindFirstChild(updateInfo.FrameName)
	
	if button and frame then
		updateEntries[version] = {
			Button = button,
			Frame = frame,
		}
	else
		warn("Update UI object not found for version:", version, updateInfo.ButtonName, updateInfo.FrameName)
	end
end


local function hideAllUpdates()
	for _, updateEntry in pairs(updateEntries) do
		updateEntry.Frame.Visible = false
	end
end

local function showUpdate(version)
	local updateEntry = updateEntries[version]
	
	if not updateEntry then
		warn("Update page is not registered:", version)
		return false
	end
	
	hideAllUpdates()
	
	updateEntry.Frame.Visible = true
	return true
end

for version, updateEntry in pairs(updateEntries) do
	local selectedVersion = version
	
	updateEntry.Button.MouseButton1Click:Connect(function()
		showUpdate(selectedVersion)
	end)
end

openUpdateFrame.MouseButton1Click:Connect(function()
	if not updateFrame.Visible then
		showUpdate(UpdateConfig.CurrentUpdate)
	end
	
	MenuManager.toggleFull("UpdateFrame")
end)

closeUpdateFrame.MouseButton1Click:Connect(function()
	MenuManager.close("UpdateFrame")
end)

local function waitForPlayerData()
	while player:FindFirstChild("DataReady") ~= true do
		player:GetAttributeChangedSignal("DataReady"):Wait()
	end
	
	local playerData = player:FindFirstChild("PlayerData")
	local lastSeenUpdate = playerData:FindFirstChild("LastSeenUpdate")
	
	return lastSeenUpdate
end

task.spawn(function()
	local lastSeenUpdate = waitForPlayerData()
	local currentUpdate = UpdateConfig.CurrentUpdate
	
	if lastSeenUpdate.Value == currentUpdate then
		return
	end
	
	local updateWassShown = showUpdate(currentUpdate)
	
	if not updateWassShown then
		warn("Current update could not be opened:", currentUpdate)
		return
	end
	
	MenuManager.openFull("UpdateFrame")
	
	updateViewedEvent:FireServer(currentUpdate)
end)
