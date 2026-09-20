--// StatsUI LocalScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientDataModule = require(game.ReplicatedStorage.Modules.ClientDataModule)
local FormatModule = require(game.ReplicatedStorage.Modules.FormatModule)

local raceGui = script.Parent
local player = Players.LocalPlayer
ClientDataModule.WaitUntilReady(player)

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

local function updateStatsUI()
	energyLabel.Text = "" .. FormatModule.FormatShort(energyStat.Value)
	moneyLabel.Text = "" .. FormatModule.FormatShort(moneyStat.Value)
	gemsLabel.Text = "" .. FormatModule.FormatShort(gemsStat.Value)
	rebirthLabel.Text = "" .. FormatModule.FormatShort(rebirthStat.Value)
end

energyStat.Changed:Connect(updateStatsUI)
moneyStat.Changed:Connect(updateStatsUI)
gemsStat.Changed:Connect(updateStatsUI)
rebirthStat.Changed:Connect(updateStatsUI)

updateStatsUI()

print("StatsUI loaded")
