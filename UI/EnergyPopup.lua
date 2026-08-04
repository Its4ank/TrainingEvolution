local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local energyPopupEvent = ReplicatedStorage:WaitForChild("EnergyPopupEvent")

local raceGui = script.Parent

local popupTemplate = raceGui:WaitForChild("EnergyGainFrame"):WaitForChild("EnergyGainLabel")

local function formatNumber(number)
	number = tonumber(number) or 0
	
	local suffixes = {
		{Value = 1e30, Suffix = "N"}, -- Нонилион
		{Value = 1e27, Suffix = "O"}, --Октиллион
		{Value = 1e24, Suffix = "S"}, --Септиллион
		{Value = 1e21, Suffix = "Sp"}, --Секстиллион
		{Value = 1e18, Suffix = "Qd"}, --Квинтиллион
		{Value = 1e15, Suffix = "Q"}, --Квадриллион
		{Value = 1e12, Suffix = "T"}, --Триллион
		{Value = 1e9, Suffix = "B"}, --Миллиард
		{Value = 1e6, Suffix = "M"}, --Миллион
		{Value = 1e3, Suffix = "K"}, --Тысяча
	}
	
	for _, data in ipairs(suffixes) do
		if number >= data.Value then
			local short = number / data.Value

			if short >= 100 then
				return string.format("%.0f%s", short, data.Suffix)
			elseif short >= 10 then
				return string.format("%.1f%s", short, data.Suffix)
			else
				return string.format("%.2f%s", short, data.Suffix)
			end
		end
	end
	return tostring(math.floor(number))
end

energyPopupEvent.OnClientEvent:Connect(function(amount)
	local popup = popupTemplate:Clone()

	popup.Text = "+" .. formatNumber(amount)
	popup.Visible = true
	popup.TextTransparency = 0
	popup.Parent = popupTemplate.Parent

	popup.Position = UDim2.new(0.5, math.random(-50,50), 0.5, math.random(-20,20))

	local tween =TweenService:Create(popup, TweenInfo.new(1),
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
