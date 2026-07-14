local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local raceGui = script.Parent

local guiFolder = raceGui:WaitForChild("GuiFolder")

local boostUIEvent = ReplicatedStorage:WaitForChild("BoostEvent"):WaitForChild("BoostUIEvent")

local boostFolder = guiFolder:WaitForChild("BoostFolder")


local potionServerImage = boostFolder:WaitForChild("PotionServerImage")
local potionMoneyImage = boostFolder:WaitForChild("PotionMoneyImage")
local potionEnergyImage = boostFolder:WaitForChild("PotionEnergyImage")
local potionLuckImage = boostFolder:WaitForChild("PotionLukImage")

local top1Image = boostFolder:WaitForChild("Top1BoostImage")
local top2Image = boostFolder:WaitForChild("Top2BoostImage")
local top3Image = boostFolder:WaitForChild("Top3BoostImage")

local timeBoostImage = boostFolder:WaitForChild("TimeBoostImage")

local premiumBoostImage = boostFolder:WaitForChild("PremiumBoostImage")

local allImages = {
	potionServerImage,
	potionMoneyImage,
	potionEnergyImage,
	potionLuckImage,
	top1Image,
	top2Image,
	top3Image,
	timeBoostImage,
	premiumBoostImage,
}

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds or 0))

	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60

	return string.format("%02d:%02d", minutes, secs)
end

for _, image in ipairs(allImages) do
	image.Visible = false
	
	local potionTime = image:FindFirstChild("PotionTime")
	if potionTime then 
		potionTime.Text = ""
	end
end

local function setImage(image, visible, text)
	image.Visible = visible 

	local potionTime = image:FindFirstChild("PotionTime")
	if potionTime then
		potionTime.Text = text or ""
		potionTime.Visible = visible
	end
end

boostUIEvent.OnClientEvent:Connect(function(data)
	setImage(top1Image, data.TopPlace == 1, "x1.30")
	setImage(top2Image, data.TopPlace == 2, "x1.20")
	setImage(top3Image, data.TopPlace == 3, "x1.10")

	local timePercent = 0
	if data.TimeBoost then
		timePercent = data.TimeBoost.Percent or 0
	end

	setImage(timeBoostImage, true, "+" .. tostring(timePercent) .. "%")
	
	local premium = data.PremiumBoost or {
		Energy = 1,
		Money = 1,
		Luck = 1,
	}
	
	local premiumText = "0"
	
	if premium.Energy and premium.Energy > 1 then
		premiumText = "x" .. tostring(premium.Energy)
	end
	
	setImage(premiumBoostImage, true, premiumText)

	local personal = data.PersonalPotions or {
		Energy = 1,
		Money = 1,
		Luck = 1,
	}

	local timeLeft = data.PotionTimeLeft or {}
	
	timeLeft.Personal = timeLeft.Personal or {
		Energy = 0,
		Money = 0,
		Luck = 0,
	}
	
	timeLeft.Server = timeLeft.Server or {
		Energy = 0,
		Money = 0,
		Luck = 0,
	}

	setImage(
		potionEnergyImage,
		personal.Energy and personal.Energy > 1,
		formatTime((timeLeft.Personal and timeLeft.Personal.Energy) or 0)
	)

	setImage(
		potionMoneyImage,
		personal.Money and personal.Money > 1,
		formatTime((timeLeft.Personal and timeLeft.Personal.Money) or 0)
	)

	setImage(
		potionLuckImage,
		personal.Luck and personal.Luck > 1,
		formatTime((timeLeft.Personal and timeLeft.Personal.Luck) or 0)
	)

	local server = data.ServerPotions or {
		Energy = 1,
		Money = 1,
		Luck = 1,
	}

	local serverTime = math.max(
		timeLeft.Server.Energy or 0,
		timeLeft.Server.Money or 0,
		timeLeft.Server.Luck or 0
	)

	local serverActive =
		(server.Energy and server.Energy > 1)
		or (server.Money and server.Money > 1)
		or (server.Luck and server.Luck > 1)

	setImage(
		potionServerImage,
		serverActive,
		formatTime(serverTime)
	)
end)

print("BoostUI loaded")
