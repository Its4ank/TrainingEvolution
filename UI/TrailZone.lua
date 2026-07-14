local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)

local player = Players.LocalPlayer
local zone = workspace:WaitForChild("TrailZone")

local raceGui = script.Parent
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")

local trailsFolder = guiFolder:WaitForChild("TrailsFolder")
local trailMenu = trailsFolder:WaitForChild("TrailMenu")

MenuManager.register("Trails", trailMenu)

local radius = 6
local inside = false

RunService.RenderStepped:Connect(function()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local distance = (hrp.Position - zone:GetPivot().Position).Magnitude

	if distance <= radius then
		if not inside then
			inside = true
			MenuManager.toggleFull("Trails")
		end
	else
		if inside then
			inside = false
			MenuManager.close("Trails")
		end
	end
end)