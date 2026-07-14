local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)

local player = Players.LocalPlayer
local zone = workspace:WaitForChild("TrainerZone")

local raceGui = script.Parent
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")

local trainerFolder = guiFolder:WaitForChild("TrainerFolder")

local trainerMenu = trainerFolder:WaitForChild("TrainerMenu")
MenuManager.register("Trainer", trainerMenu)

local radius = 6
local inside = false

RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	local distance = (char.HumanoidRootPart.Position - zone:GetPivot().Position).Magnitude

	if distance <= radius then
		if not inside then
			inside = true
			MenuManager.toggleFull("Trainer")
		end
	else
		if inside then
			inside = false
			MenuManager.close("Trainer")
		end
	end
end)
