local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)

local RebirthModule = {}

RebirthModule.BaseCost = 150
RebirthModule.CostPerRebirth = 10

RebirthModule.EnergyFlatBonusPerRebirth = 0
RebirthModule.EnergyBonusPerRebirth = 0.01

RebirthModule.XpBonusPerRebirth = 0.001
RebirthModule.MoneyBonusPerRebirth = 0.001

RebirthModule.MaxRebirthPerOperation = 100_000_000

RebirthModule.Buttons = {
	RebirthButton1 = 1,
	RebirthButton2 = 5,
	RebirthButton3 = 25,
	RebirthButton4 = 75,
	RebirthButton5 = 150,
	RebirthButton6 = 250,
	RebirthButton7 = 500,
}

function RebirthModule.GetXpMultiplier(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return 1
	end
	
	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if not rebirth then return 1 end
	
	return 1 + (rebirth.Value * RebirthModule.XpBonusPerRebirth)
end

function RebirthModule.GetOneRebirthCost(currentRebirths)
	currentRebirths = math.max(0, math.floor(tonumber(currentRebirths) or 0))
		
	return RebirthModule.BaseCost + (currentRebirths * RebirthModule.CostPerRebirth)
end

function RebirthModule.GetRebirthCost(currentRebirths, rebirthAmount, rebirthPerPurchase)
	rebirthAmount = math.max(0, math.floor(tonumber(rebirthAmount) or 0))
	rebirthPerPurchase = math.max(1, math.max(tonumber(rebirthPerPurchase) or 1))
	
	local firstCost = RebirthModule.GetOneRebirthCost(currentRebirths)
	local priceStep = RebirthModule.GetPerRebirth * rebirthPerPurchase
	
	return rebirthAmount * firstCost + priceStep * rebirthAmount * (rebirthAmount - 1) / 2
end

function RebirthModule.GetMaxRebirthAmount(currentRebirth, currentEnergy, rebirthPerPurchase)
	currentEnergy = math.max(0, tonumber(currentEnergy) or 0)
	
	local firstCost = RebirthModule.GetOneRebirthCost(currentRebirth)
	if firstCost <= 0 then return 0 end
	
	local maxPerOperation = math.max(1, math.floor(tonumber(RebirthModule.MaxRebirthPerOperation) or 1000000))

	local low = 0
	local high = math.min(maxPerOperation, math.floor(currentEnergy / firstCost))
	
	while low < high do
		local middle = math.floor((low + high + 1) / 2)
		
		local cost = RebirthModule.GetRebirthCost(currentRebirth, middle, rebirthPerPurchase)
		
		if cost <= currentEnergy then
			low = middle
		else
			high = middle - 1
		end
		
		return low
	end
	
	return math.clamp(maxAmount, 0, maxPerOperation)
end

function RebirthModule.GetEnergyMultiplier(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 1 end

	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if not rebirth then return 1 end

	return 1 + (rebirth.Value * RebirthModule.EnergyBonusPerRebirth)
end

function RebirthModule.IsMoneyMultiplierUnlocked(player)
	return UpgradeModule.IsMoneyMultiplierUnlocked(player)
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
