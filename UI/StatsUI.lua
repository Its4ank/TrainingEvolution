--// StatsUI LocalScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReade(player)

local guiFolder = raceGui:WaitForChild("GuiFolder")

--// Stats
local energyStat = ClientDataModule.GetEnergy(player)
local moneyStat = ClientDataModule.GetMoney(player)
local gemsStat = ClientDataModule.GetGems(player)
local rebirthStat = ClientDataModule.GetRebirth(player)

--// UI
local uiBalance = guiFolder:WaitForChild("UIBalance")

local uiValueFrame = uiBalance:WaitForChild("UIValueFrame")

local energyLabel = uiValueFrame:WaitForChild("EnergyLabel")
local moneyLabel = uiValueFrame:WaitForChild("MoneyLabel")
local gemsLabel = uiValueFrame:WaitForChild("GemsLabel")
local rebirthLabel = uiValueFrame:WaitForChild("RebirthLabel")

local function formatShort(n)
	if n >= 1e18 then
		return string.format("%.1fQ", n / 1e18)
	elseif n >= 1e15 then
		return string.format("%.1fQa", n / 1e15)
	elseif n >= 1e12 then
		return string.format("%.1fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	else
		return tostring(math.floor(n))
	end
end

local function updateStatsUI()
	energyLabel.Text = "" .. formatShort(energyStat.Value)
	moneyLabel.Text = "" .. formatShort(moneyStat.Value)
	gemsLabel.Text = "" .. formatShort(gemsStat.Value)
	rebirthLabel.Text = "" .. formatShort(rebirthStat.Value)
end

energyStat.Changed:Connect(updateStatsUI)
moneyStat.Changed:Connect(updateStatsUI)
gemsStat.Changed:Connect(updateStatsUI)
rebirthStat.Changed:Connect(updateStatsUI)

updateStatsUI()

print("StatsUI loaded")
