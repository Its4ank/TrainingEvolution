local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local FormatModule = require(ReplicatedStorage.Modules.FormatModule)

local raceFolder = ReplicatedStorage:WaitForChild("RaceFolder")
local racePopupEvent = raceFolder:WaitForChild("RacePopupEvent")

local raceGui = script.Parent

local popupTemplate = raceGui:WaitForChild("RaceGainFrame"):WaitForChild("RaceGainPopup")

local popupStyles = {
	Money = {
		Image = "rbxassetid://123691959584167",
		Color = Color3.fromRGB(95, 255, 95),
	},
	
	Gems = {
		Image = "rbxassetid://137014409758293",
		Color = Color3.fromRGB(85, 0, 255),
	},
	
	XP = {
		Image = "rbxassetid://84764867479981",
		Color = Color3.fromRGB(255, 210, 65),
	},
}

local popupSlots = {
	UDim2.fromScale(0.20, 0.25),
	UDim2.fromScale(0.40, 0.20),
	UDim2.fromScale(0.60, 0.20),
	UDim2.fromScale(0.80, 0.25),
	
	UDim2.fromScale(0.25, 0.45),
	UDim2.fromScale(0.50, 0.40),
	UDim2.fromScale(0.75, 0.25),
	
	UDim2.fromScale(0.20, 0.65),
	UDim2.fromScale(0.40, 0.70),
	UDim2.fromScale(0.60, 0.70),
	UDim2.fromScale(0.80, 0.65),
}

local occupiedSlots = {}

local function getFreePopupSlot()
	local freeSlots = {}
	
	for slotIndex = 1, #popupSlots do
		if not occupiedSlots[slotIndex] then
			table.insert(freeSlots, slotIndex)
		end
	end
	
	if #freeSlots == 0 then
		return math.random(1, #popupSlots)
	end
	
	local selectedIndex = freeSlots[math.random(1, #freeSlots)]
	
	occupiedSlots[selectedIndex] = true
	return selectedIndex
end

local function releasePopupSlot(slotIndex)
	occupiedSlots[slotIndex] = nil
end

local function showPopup(rewardType, amount)
	local style = popupStyles[rewardType]
	if not style then
		warn("Unknown popup reward type:", rewardType)
		return
	end

	local popup = popupTemplate:Clone()
	popup.Parent = popupTemplate.Parent

	local rewardIcon = popup:WaitForChild("RewardIcon")
	local amountLabel = popup:WaitForChild("RewardAmountLabel")

	local slotIndex = getFreePopupSlot()
	local startPosition = popupSlots[slotIndex]

	rewardIcon.Image = style.Image
	rewardIcon.ImageTransparency = 0
	rewardIcon.Visible = true

	amountLabel.Text = "+" .. FormatModule.FormatNumber(amount)
	amountLabel.TextColor3 = style.Color
	amountLabel.TextTransparency = 0
	amountLabel.Visible = true

	popup.Position = startPosition
	popup.Visible = true

	local targetPosition =
		startPosition - UDim2.fromScale(0, 0.10)

	local tweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local positionTween = TweenService:Create(
		popup,
		tweenInfo,
		{
			Position = targetPosition,
		}
	)

	local textTween = TweenService:Create(
		amountLabel,
		tweenInfo,
		{
			TextTransparency = 1,
		}
	)

	local iconTween = TweenService:Create(
		rewardIcon,
		tweenInfo,
		{
			ImageTransparency = 1,
		}
	)

	positionTween:Play()
	textTween:Play()
	iconTween:Play()

	positionTween.Completed:Once(function()
		releasePopupSlot(slotIndex)
		popup:Destroy()
	end)
end

racePopupEvent.OnClientEvent:Connect(function(rewardType, amount)
	showPopup(rewardType, amount)
end)
