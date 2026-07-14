local MenuManager = {}

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer 

local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
local controls = playerModule:GetControls()

local menus = {}
local screenGui
local screenBlocker 
local blur 

local currentMenu = nil 

local BLOCKER_ZINDEX = 5
local MENU_ZINDEX = 5

local function setGuiZIndex(guiObject, minZIndex)
	if guiObject:IsA("GuiObject") then 
		if guiObject.ZIndex < minZIndex then
			guiObject.ZIndex = minZIndex 
		end
	end
	
	for _, child in ipairs(guiObject:GetDescendants()) do 
		if child:IsA("GuiObject") then 
			if child.ZIndex < minZIndex then 
				child.ZIndex = minZIndex
			end
		end
	end
end

local function getOrCreateBlur()
	local foundBlur = Lighting:FindFirstChild("MenuBlur")
	
	if not foundBlur then 
		foundBlur = Instance.new("BlurEffect")
		foundBlur.Name = "MenuBlur"
		foundBlur.Size = 0
		foundBlur.Parent = Lighting
	end
	
	return foundBlur
end

local function getOrCreateScreenBlocker(parentGui)
	local blocker = parentGui:FindFirstChild("AutoScreenBlocker")
	
	if not blocker then 
		blocker = Instance.new("Frame")
		blocker.Name = "AutoScreenBlocker"
		blocker.Size = UDim2.fromScale(1, 1)
		blocker.Position = UDim2.fromScale(0, 0)
		blocker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		blocker.BackgroundTransparency = 1
		blocker.BorderSizePixel = 0
		blocker.Visible = false
		blocker.Active = true
		blocker.ZIndex = BLOCKER_ZINDEX
		blocker.Parent = parentGui
	end
	
	return blocker
end

local function setRobloxUI(enabled)
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", enabled)
	end)
	
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, enabled)
	end)
	
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, enabled)
	end)
	
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, enabled)
	end)
	
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, enabled)
	end)
	
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, enabled)
	end)
end

function MenuManager.init(parentGui)
	screenGui = parentGui
	screenBlocker = getOrCreateScreenBlocker(screenGui)
	blur = getOrCreateBlur()
end

function MenuManager.register(name, frame)
	menus[name] = frame
	frame.Visible = false
	setGuiZIndex(frame, MENU_ZINDEX)
end

function MenuManager.closeAll()
	for _, frame in pairs(menus) do 
		frame.Visible = false 
	end
	
	currentMenu = nil 
	
	if screenBlocker then 
		screenBlocker.Visible = false
	end
	
	if blur then 
		blur.Size = 0
	end
	
	controls:Enable()
	setRobloxUI(true)
end

function MenuManager.openFull(name)
	local frame = menus[name]
	if not frame then return end
	
	for menuName, menuFrame in pairs(menus) do 
		menuFrame.Visible = (menuName == name)
	end
	
	currentMenu = name 
	
	if screenBlocker then 
		screenBlocker.Visible = true
	end
	
	if blur then 
		blur.Size = 0
	end
	
	controls:Disable()
	setRobloxUI(false)
end

function MenuManager.openBlur(name)
	local frame = menus[name]
	if not frame then return end
	
	for menuName, menuFrame in pairs(menus) do 
		menuFrame.Visible = (menuName == name)
	end
	
	currentMenu = name 
	
	if screenBlocker then 
		screenBlocker.Visible = false
	end
	
	if blur then 
		blur.Size = 30
	end
	
	controls:Disable()
	setRobloxUI(false)
end

function MenuManager.close(name)
	local frame = menus[name]
	if not frame then return end
	
	frame.Visible = false
	
	if currentMenu == name then 
		currentMenu = nil 
	end
	
	if screenBlocker then 
		screenBlocker.Visible = false
	end
	
	if blur then 
		blur.Size = 0
	end
	
	controls:Enable()
	setRobloxUI(true)
end

function MenuManager.toggleFull(name)
	local frame = menus[name]
	if not frame then return end
	
	if frame.Visible then 
		MenuManager.close(name)
	else 
		MenuManager.openFull(name)
	end
end

function MenuManager.toggleBlur(name)
	local frame = menus[name]
	if not frame then return end
	
	if frame.Visible then 
		MenuManager.close(name)
	else 
		MenuManager.openBlur(name)
	end
end

return MenuManager