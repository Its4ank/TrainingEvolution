local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local FormatModule = require(ReplicatedStorage.Modules.FormatModule)

local energyPopupEvent = ReplicatedStorage:WaitForChild("EnergyPopupEvent")

local popupTemplate = script.Parent:WaitForChild("EnergyGainFrame"):WaitForChild("EnergyGainLabel")

local ENERGY_ICON = "rbxassetid://74509086636062" -- сюда можно поставить свою иконку энергии

local function setupEnergyIcon(popup)
	local icon = popup:FindFirstChild("EnergyIcon")

	if not icon then
		icon = Instance.new("ImageLabel")
		icon.Name = "EnergyIcon"
		icon.Parent = popup
	end

	icon.Image = ENERGY_ICON
	icon.BackgroundTransparency = 1
	icon.ImageTransparency = 0
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.Position = UDim2.new(1.02, 0, 0.5, 0)
	icon.Size = UDim2.new(0.35, 0, 0.8, 0)
	icon.Visible = true

	return icon
end

energyPopupEvent.OnClientEvent:Connect(function(amount)
	local popup = popupTemplate:Clone()
	local icon = setupEnergyIcon(popup)

	popup.Text = "+" .. FormatModule.FormatNumber(amount)
	popup.Visible = true
	popup.TextTransparency = 0
	popup.Parent = popupTemplate.Parent

	popup.AnchorPoint = Vector2.new(0.5, 0.5)
	
	local startPosition = UDim2.new(0.5, 0, 0.5, 0)
	local endPosition = UDim2.new(0.5, 0, 0.4, 0)
	
	popup.Position = startPosition

	local moveGoal = {
		Position = endPosition,
		TextTransparency = 1,
	}

	local popupTween = TweenService:Create(
		popup,
		TweenInfo.new(1),
		moveGoal
	)

	local iconTween = TweenService:Create(
		icon,
		TweenInfo.new(1),
		{
			ImageTransparency = 1,
		}
	)

	popupTween:Play()
	iconTween:Play()

	popupTween.Completed:Connect(function()
		popup:Destroy()
	end)
end)
