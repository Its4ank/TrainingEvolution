local RebirthModule = {}

RebirthModule.BaseCost = 250
RebirthModule.CostPerRebirth = 10

RebirthModule.EnergyFlatBonusPerRebirth = 1

RebirthModule.EnergyBonusPerRebirth = 0.10
RebirthModule.XpBonusPerRebirth = 0.05
RebirthModule.MoneyBonusPerRebirth = 0.01

RebirthModule.Buttons = {
	RebirthButton1 = 1,
	RebirthButton2 = 5,
	RebirthButton3 = 25,
	RebirthButton4 = 75,
	RebirthButton5 = 150,
	RebirthButton6 = 250,
	RebirthButton7 = 500,
}

function RebirthModule.IsXpMultiplierUnlocked(player)
	-- infoinefoiunefoiun
	return false
end

function RebirthModule.GetXpMultiplier(player)
	if not RebirthModule.IsXpMultiplierUnlocked(player) then 
		return 1
	end
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 1 end
	
	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if not rebirth then return 1 end
	
	return 1 + (rebirth.Value * RebirthModule.XpBonusPerRebirth)
end

function RebirthModule.GetOneRebirthCost(currentRebirths)
	return RebirthModule.BaseCost + (currentRebirths * RebirthModule.CostPerRebirth)
end

function RebirthModule.GetRebirthCost(currentRebirths, rebirthAmount)
	local oneCost = RebirthModule.GetOneRebirthCost(currentRebirths)
	return oneCost * rebirthAmount
end

function RebirthModule.GetMaxRebirthAmount(currentRebirth, currentEnergy)
	local oneCost = RebirthModule.GetOneRebirthCost(currentRebirth)
	if oneCost <= 0 then return 0 end 

	return math.floor(currentEnergy / oneCost)
end

function RebirthModule.GetEnergyMultiplier(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 1 end

	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if not rebirth then return 1 end

	return 1 + (rebirth.Value * RebirthModule.EnergyBonusPerRebirth)
end

function RebirthModule.IsMoneyMultiplierUnlocked(player)
	local upgradesFolder = player:FindFirstChild("Upgrades")
	if not upgradesFolder then return false end

	local moneyUnlock = upgradesFolder:FindFirstChild("RebirthMultiplierMoney")
	if not moneyUnlock then return false end

	return moneyUnlock.Value >= 1
end

function RebirthModule.GetMoneyMultiplier(player)
	if not RebirthModule.IsMoneyMultiplierUnlocked(player) then
		return 1
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 1 end

	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if not rebirth then return 1 end

	return 1 + (rebirth.Value * RebirthModule.MoneyBonusPerRebirth)
end

function RebirthModule.GetEnergyFlatBonus(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 0 end
	
	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if not rebirth then return 0 end
	
	return rebirth.Value * RebirthModule.EnergyFlatBonusPerRebirth
end

function RebirthModule.GetEnergyMultiplierFromRebirths(rebirths)
	return 1 + (rebirths * RebirthModule.EnergyBonusPerRebirth)
end

function RebirthModule.GetMoneyMultiplierFromRebirths(rebirths)
	return 1 + (rebirths * RebirthModule.MoneyBonusPerRebirth)
end

function RebirthModule.GetXpMultiplierFromRebirths(rebirths)
	return 1 + (rebirths * RebirthModule.XpBonusPerRebirth)
end

return RebirthModule