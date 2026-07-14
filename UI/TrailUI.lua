local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)
local MenuManager = require(game.ReplicatedStorage.Modules.MenuManager)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)
MenuManager.init(raceGui)

local guiFolder = raceGui:WaitForChild("GuiFolder")
local trailsFolderUI = guiFolder:WaitForChild("TrailsFolder")



--//RemoteEvent
local buyTrailEvent = ReplicatedStorage:WaitForChild("BuyTrailEvent")
local trailDataEvent = ReplicatedStorage:WaitForChild("TrailDataEvent")
local updateTrailEvent = ReplicatedStorage:WaitForChild("UpdateTrailEvent")
local upgradeTrailEvent = ReplicatedStorage:WaitForChild("UpgradeTrailEvent")
local tierUpTrailEvent = ReplicatedStorage:WaitForChild("TierUpTrailEvent")
local closeTrailMenuEvent = ReplicatedStorage:WaitForChild("CloseTrailMenuEvent")
local requestTrailDataEvent = ReplicatedStorage:WaitForChild("RequestTrailDataEvent")



--// leaderstats
local money = ClientDataModule.GetMoney(player)
local srRobux = ClientDataModule.GetSrRobux(player)



--// Trail
local trailMenu = trailsFolderUI:WaitForChild("TrailMenu")

local trailMenuFrame = trailMenu:WaitForChild("TrailMenuFrame")

local closeTrailMenuButton = trailMenu:WaitForChild("CloseTrailMenuButton")

local blueTrailButton = trailMenuFrame:WaitForChild("BlueTrailButton")
--
local trailDetailsFrame = trailMenu:WaitForChild("TrailDetailsFrame")

local trailPreviewFrame = trailDetailsFrame:WaitForChild("TrailPreviewFrame")

local tierUpButton = trailDetailsFrame:WaitForChild("TierUpButton")

local trailNameLabel = trailDetailsFrame:WaitForChild("TrailNameLabel")
local tierLabel = trailDetailsFrame:WaitForChild("TierLabel")
local levelLabel = trailDetailsFrame:WaitForChild("LevelLabel")
local xpLabel = trailDetailsFrame:WaitForChild("XPLabel")
local racePowerLabel = trailDetailsFrame:WaitForChild("RacePowerLabel")
local accelerationLabel = trailDetailsFrame:WaitForChild("AccelerationLabel")

local buyButton = trailDetailsFrame:WaitForChild("BuyButton")
local ownedButton = trailDetailsFrame:WaitForChild("OwnedButton")
local upgradeButton = trailDetailsFrame:WaitForChild("UpgradeButton")
--
local trailTierFrame = trailMenu:WaitForChild("TrailTierFrame")

local currentTierLabel = trailTierFrame:WaitForChild("CurrentTierLabel")
local nextTierLabel = trailTierFrame:WaitForChild("NextTierLabel")
local requirementsLabel = trailTierFrame:WaitForChild("RequirementsLabel")

local upButton = trailTierFrame:WaitForChild("UpButton")
local closeTierFrameButton = trailTierFrame:WaitForChild("CloseTierFrameButton")



--//leaderstatsUI
local leaderstatsUITrail = trailMenu:WaitForChild("leaderstatsUITrail")

local moneyLabel = leaderstatsUITrail:WaitForChild("MoneyLabel")
local srRobuxLabel = leaderstatsUITrail:WaitForChild("SRRobuxLabel")

MenuManager.register("	Trail", trailMenu)




local selectedTrail = nil
local selectedTrailData = nil
trailDetailsFrame.Visible = false



--// functions
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

local function updateCurrencies()
	moneyLabel.Text = formatShort(money.Value)
	srRobuxLabel.Text = formatShort(srRobux.Value)
end

local function connectCurrencyUpdates()
    moneyLabel.Text = formatShort(money.Value)
	srRobuxLabel.Text = formatShort(srRobux.Value)
	
	if money then
		money:GetPropertyChangedSignal("Value"):Connect(updateCurrencies)
	end
	
	if srRobux then
		srRobux:GetPropertyChangedSignal("Value"):Connect(updateCurrencies)
	end
	
	updateCurrencies()
end

connectCurrencyUpdates()

local previewConnection = nil

local function clearTrailPreview()
	if previewConnection then
		previewConnection:Disconnect()
		previewConnection = nil
	end
	
	trailPreviewFrame:ClearAllChildren()
end

local function setupTrailPreview(tierName )
	clearTrailPreview()
	
	local tierStyle = {
		Color = Color3.fromRGB(255, 255, 255),
		SecondColor = nil,
		Transparency = 0.25,
		Size = Vector3.new(1, 1, 5),
		Neon = false,
		OrbitCount = 0,
		OrbitColor = Color3.fromRGB(255, 255, 255),
	}

	if tierName == "Flow" then
		tierStyle.OrbitCount = 2
		tierStyle.OrbitColor = Color3.fromRGB(255, 255, 255)
	elseif tierName == "Surge" then
		tierStyle.OrbitCount = 4
		tierStyle.OrbitColor = Color3.fromRGB(85, 255, 0)
		tierStyle.Transparency = 0.15
	elseif tierName == "Hyper" then
		tierStyle.OrbitCount = 6
		tierStyle.OrbitColor = Color3.fromRGB(85, 0, 127)
		tierStyle.Color = Color3.fromRGB(0, 80, 255)
		tierStyle.SecondColor = Color3.fromRGB(0, 0, 255)
		tierStyle.Transparency = 0.08
		tierStyle.Neon = true
	elseif tierName == "Ascended" then
		tierStyle.OrbitCount = 8
		tierStyle.OrbitColor = Color3.fromRGB(255, 255, 0)
		tierStyle.Color = Color3.fromRGB(0, 0, 255)
		tierStyle.SecondColor = Color3.fromRGB(0, 170, 255)
		tierStyle.Transparency = 0
		tierStyle.Size = Vector3.new(1.4, 1.4, 6)
		tierStyle.Neon = true
	end
	
	local character = player.Character
	if not character then return end
	
	character.Archivable = true
	local previewCharacter = character:Clone()
	character.Archivable = false
	
	if not previewCharacter then return end
	
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = trailPreviewFrame
	
	local camera = Instance.new("Camera")
	camera.Parent = trailPreviewFrame
	trailPreviewFrame.CurrentCamera = camera
	
	previewCharacter.Parent = worldModel
	
	local fakeTrail = Instance.new("Part")
	fakeTrail.Name = "FakeTrail"
	fakeTrail.Anchored = true
	fakeTrail.CanCollide = false
	fakeTrail.Material = tierStyle.Neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
	fakeTrail.Color = tierStyle.Color
	fakeTrail.Transparency = tierStyle.Transparency
	fakeTrail.Size = tierStyle.Size
	fakeTrail.Parent = worldModel
	
	local orbitParts = {}
	
	for i = 1, tierStyle.OrbitCount do
		local orb = Instance.new("Part")
		orb.Name = "PreviewOrbitParticle"
		orb.Shape = Enum.PartType.Ball
		orb.Material = Enum.Material.Neon
		orb.Color = tierStyle.OrbitColor
		orb.Size = Vector3.new(0.22, 0.22, 0.22)
		orb.Transparency = 0.15
		orb.Anchored = true
		orb.CanCollide = false
		orb.Parent = worldModel
		
		table.insert(orbitParts, orb)
	end
	
	local humanoid = previewCharacter:FindFirstChildOfClass("Humanoid")
	local hrp = previewCharacter:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not hrp then
		clearTrailPreview()
		return
	end
	
	for _, obj in ipairs(previewCharacter:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") then
			obj:Destroy()
		elseif obj:IsA("Accessory") then
			local handle = obj:FindFirstChild("Handle")
			local accessoryType = obj.AccessoryType
			
			if accessoryType == Enum.AccessoryType.Back then
				obj:Destroy()
			elseif handle then
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				
				if mesh and mesh.Scale.Magnitude > 8 then
					obj:Destroy()
				end
			end
			
		elseif obj:IsA("BasePart") then
			obj.CanCollide = false
			obj.Anchored = false
			
			if obj.Name == "HumanoidRootPart" then
				obj.Transparency = 1
			end
		elseif obj:IsA("Decal") then
			obj.Transparency = 0
		end
	end
	
	hrp.CFrame = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(-90), 0)
	
	camera.CFrame = CFrame.new(Vector3.new(0, 2.2, 6), Vector3.new(0, 1.5, 0))
	
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	local runAnim = Instance.new("Animation")
	runAnim.AnimationId = "rbxassetid://913376220"
	
	local runTrack = animator:LoadAnimation(runAnim)
	runTrack.Priority = Enum.AnimationPriority.Action
	runTrack:Play()
	runTrack:AdjustSpeed(2.5)
	
	local startTime = tick()
	
	previewConnection = RunService.RenderStepped:Connect(function()
		if not trailPreviewFrame.Visible then return end
		if not hrp or not hrp.Parent then return end
		
		local t = tick() - startTime
		
		--основной фейк трейл
		fakeTrail.CFrame = hrp.CFrame * CFrame.new(0, 0.6 + math.sin(t * 4) * 0.08, 2.3) * CFrame.Angles(0, 0, math.sin(t * 3) * 0.25)
		
		fakeTrail.Size = Vector3.new( 
			1 + math.sin(t * 5) * 0.1,
			1 + math.sin(t * 5) * 0.1,
			5 + math.sin(t * 3) * 0.5
		)
		
		fakeTrail.Transparency = tierStyle.Transparency + math.sin(t * 4) * 0.05
		
		--шарики у основания трейла
		for i, orb in ipairs(orbitParts) do
			local angle = (t * (3 + i * 0.25)) + (i * ((math.pi * 2) / #orbitParts))
			
			local baseOffset = CFrame.new(0, 0.45, 1.4)
			
			local orbitOffset = CFrame.new( 
				math.cos(angle) * 0.7,
				math.sin(angle * 1.5) * 0.4,
				math.sin(angle) * 0.5
			)
			
			orb.CFrame = hrp.CFrame * baseOffset * orbitOffset
			
			local pulse = 0.18 + math.abs(math.sin(t * 6 + i)) * 0.08
			orb.Size = Vector3.new(pulse, pulse, pulse)
			
			orb.Transparency = 0.1 + math.abs(math.sin(t * 5 + i)) * 0.25
		end
	end)
end

local function updateTrailDetails(trailName, data)
	selectedTrail = trailName
	selectedTrailData = data
	
	trailDetailsFrame.Visible = true


	trailNameLabel.Text = data.DisplayName .. " [" .. data.TierName .. "]"
	tierLabel.Text = "Tier: " .. data.TierName
	levelLabel.Text = "Level: " .. data.Level
	racePowerLabel.Text = "RacePower: x" .. string.format("%.2f", data.RacePowerMultiplier)
	accelerationLabel.Text = "Acceleration: x" .. string.format("%.2f", data.AccelerationMultiplier)
	
	if data.IsMaxTier and data.Level >= data.MaxLevel then
		xpLabel.Text = "MAX TIER"
	else
		xpLabel.Text = "XP: " .. formatShort(data.XP) .. " / " .. formatShort(data.XPNeeded)
	end
	
	setupTrailPreview(data.TierName)

	if data.Owned then
		buyButton.Visible = false
		ownedButton.Visible = true
		
		if data.IsMaxTier and data.Level >= data.MaxLevel then
			upgradeButton.Visible = false
			tierUpButton.Visible = true
			tierUpButton.Text = "MAX TIER"
		elseif data.Level >= data.MaxLevel then
			upgradeButton.Visible = false
			tierUpButton.Visible = true
			tierUpButton.Text = "Tier UP"
		else 
			upgradeButton.Visible = true
			tierUpButton.Visible = false
			upgradeButton.Text = "Upgrade"
			
			if data.CanUpgrade then
				upgradeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
			else
				upgradeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
			end
		end
	else
		buyButton.Visible = true
		ownedButton.Visible = false
		upgradeButton.Visible = false
		tierUpButton.Visible = false
		
		buyButton.Text = "Buy -" .. data.Price .. " Money"
	end
	
end



--//ButtonHendles
blueTrailButton.MouseButton1Click:Connect(function()
	
	if trailDetailsFrame.Visible and selectedTrail == "BlueTrail" then
		trailDetailsFrame.Visible = false
		selectedTrail = nil
		return
	end
	
	selectedTrail = "BlueTrail"
	
	requestTrailDataEvent:FireServer("BlueTrail")
end)

buyButton.MouseButton1Click:Connect(function()
	if selectedTrail then

		buyTrailEvent:FireServer(selectedTrail)
	end
end)

upgradeButton.MouseButton1Click:Connect(function()
	if selectedTrail then
		
		upgradeTrailEvent:FireServer(selectedTrail)
	end
end)

tierUpButton.MouseButton1Click:Connect(function()
	if not selectedTrailData then return end
	if selectedTrailData.IsMaxTier then return end
	
	trailMenuFrame.Visible = false
	trailDetailsFrame.Visible = false
	trailTierFrame.Visible = true
	
	currentTierLabel.Text = "Current Tier: " .. selectedTrailData.TierName
	nextTierLabel.Text = "Next Tier: " .. selectedTrailData.NextTierName
	
	requirementsLabel.Text = "Requirements:\n" .. "Level: " .. selectedTrailData.Level .. " / " .. selectedTrailData.MaxLevel .. "\n" .. "Money: " .. selectedTrailData.TierUpCost
	
	if selectedTrailData.CanTierUp then
		upButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	else
		upButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	end
end)

upButton.MouseButton1Click:Connect(function()
	if selectedTrail then
		
		tierUpTrailEvent:FireServer(selectedTrail)
		
		trailTierFrame.Visible = false
		trailMenuFrame.Visible = true
		trailDetailsFrame.Visible = true
	end
end)

closeTierFrameButton.MouseButton1Click:Connect(function()
	trailTierFrame.Visible = false
	trailMenuFrame.Visible = true
	trailDetailsFrame.Visible = true
end)

closeTrailMenuButton.MouseButton1Click:Connect(function()
	closeTrailMenuEvent:FireServer()
end)



--//OnClient
trailDataEvent.OnClientEvent:Connect(function(trailName, data)
	selectedTrail = trailName
	selectedTrailData = data
	
	if trailTierFrame.Visible then
		return
	end
	
	updateTrailDetails(trailName, data)
end)

print("TrailUI loaded")