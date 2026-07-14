local ReplicatedStorage = game:GetService("ReplicatedStorage")

local energyPopupEvent = ReplicatedStorage:WaitForChild("EnergyPopupEvent")

local popupTemplate = script.Parent:WaitForChild("EnergyGainFrame"):WaitForChild("EnergyGainLabel")

energyPopupEvent.OnClientEvent:Connect(function(amount)
	local popup = popupTemplate:Clone()

	local displayText

	if amount % 1 == 0 then
		displayText = "+" .. tostring(math.floor(amount))
	else
		displayText = string.format("+%.1f", amount)
	end

	popup.Text = displayText
	popup.Visible = true
	popup.Parent = popupTemplate.Parent

	popup.Position = UDim2.new(
		0.5,
		math.random(-50,50),
		0.5,
		math.random(-20,20)
	)

	local tween = game:GetService("TweenService"):Create(
		popup,
		TweenInfo.new(1),
		{
			Position = popup.Position - UDim2.new(0,0,0.1,0),
			TextTransparency = 1,
		}
	)

	tween:Play()

	tween.Completed:Connect(function()
		popup:Destroy()
	end)
end)
