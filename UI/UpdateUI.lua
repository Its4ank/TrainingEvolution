local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)

local raceGui = script.Parent
local player = Players.LocalPlayer
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local updateFolder = guiFolder:WaitForChild("UpdateFolder")
local updateFrame = updateFolder:WaitForChild("UpdateFrame")
local uiBalance = guiFolder:WaitForChild("UIBalance")
local openUpdateFrame = uiBalance:WaitForChild("OpenUpdateFrame")

--//updateFrame
local updFrame = updateFrame:WaitForChild("UPDFrame")
local scrollingFrameButton = updateFrame:WaitForChild("ScrollingFrameButton")
local closeUpdateFrame = updateFrame:WaitForChild("CloseUpdateButton")

--// scrollingFrameButton
local upd0Button = scrollingFrameButton:WaitForChild("UPD0Button")
local upd1Button = scrollingFrameButton:WaitForChild("UPD1Button")

--//UPDFrame
local scrolingUPD0 = updFrame:WaitForChild("ScrollingUPD0")
local scrolingUPD1 = updFrame:WaitForChild("ScrollingUPD1")


MenuManager.register("UpdateFrame", updateFrame)



--//Buttons
local updateFrames = { 
	scrolingUPD0, 
	scrolingUPD1
}

local function toggleUpdate(targetFrame)
	local wasVisible = targetFrame.Visible
	
	for _, frame in ipairs(updateFrames) do 
		frame.Visible = false
	end
	
	targetFrame.Visible = not wasVisible
end

upd0Button.MouseButton1Click:Connect(function()
	toggleUpdate(scrolingUPD0)
end)

upd1Button.MouseButton1Click:Connect(function()
	toggleUpdate(scrolingUPD1)
end)

openUpdateFrame.MouseButton1Click:Connect(function()
	MenuManager.toggleFull("UpdateFrame")
end)

closeUpdateFrame.MouseButton1Click:Connect(function()
	MenuManager.close("UpdateFrame")
end)