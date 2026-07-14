local ClientDataModule = {}

function ClientDataModule.WaitUntilReade(player)
	while player:GetAttribute("DataReady") ~= true do 
		task.wait()
	end
end

function ClientDataModule.GetLeaderstats(player)
	return player:WaitForChild("leaderstats")
end

function ClientDataModule.GetPlayerData(player)
	return player:WaitForChild("PlayerData")
end

function ClientDataModule.GetEnergy(player)
	return ClientDataModule.GetLeaderstats(player):WaitForChild("Energy")
end

function ClientDataModule.GetRebirth(player)
	return ClientDataModule.GetLeaderstats(player):WaitForChild("Rebirth")
end

function ClientDataModule.GetMoney(player)
	return ClientDataModule.GetPlayerData(player):WaitForChild("Money")
end

function ClientDataModule.GetGems(player)
	return ClientDataModule.GetPlayerData(player):WaitForChild("Gems")
end

function ClientDataModule.GetSrRobux(player)
	return ClientDataModule.GetPlayerData(player):WaitForChild("SrRobux")
end

function ClientDataModule.GetMaxEquippedPets(player)
	return ClientDataModule.GetPlayerData(player):WaitForChild("MaxEquippedPets")
end

function ClientDataModule.GetGamepasses(player)
	return ClientDataModule.GetPlayerData(player):WaitForChild("Gamepasses")
end

function ClientDataModule.GetPotions(player)
	return player:WaitForChild("Potions")
end

function ClientDataModule.GetPotion(player, potionName)
	return ClientDataModule.GetPotions(player):WaitForChild(potionName)
end

function ClientDataModule.GetItems(player)
	return player:WaitForChild("Items")
end

function ClientDataModule.GetPets(player)
	return player:WaitForChild("Pets")
end

function ClientDataModule.GetTrails(player)
	return player:WaitForChild("Trails")
end

function ClientDataModule.GetTrainer(player)
	return player:WaitForChild("Trainer")
end

function ClientDataModule.GetUpgrades(player)
	return player:WaitForChild("Upgrades")
end

function ClientDataModule.GetResources(player)
	return player:WaitForChild("Resources")
end

function ClientDataModule.GetXP(player)
	local resources = ClientDataModule.GetResources(player)
	return resources:WaitForChild("XPModule")
end

function ClientDataModule.GetTreadmills(player)
	return player:WaitForChild("Treadmills")
end

function ClientDataModule.GetTreadmill(player, treadmillId)
	local treadmills = ClientDataModule.GetTreadmills(player)
	return treadmills:WaitForChild("Treadmill" .. tostring(treadmillId))
end

function ClientDataModule.GetTreadmillLevel(player, treadmillId)
	return ClientDataModule.GetTreadmill(player, treadmillId):WaitForChild("Level")
end

function ClientDataModule.GetTreadmillStage(player, treadmillId)
	return ClientDataModule.GetTreadmill(player, treadmillId):WaitForChild("Stage")
end

function ClientDataModule.GetTreadmillTrainingTime(player, treadmillId)
	return ClientDataModule.GetTreadmill(player, treadmillId):WaitForChild("TrainingTime")
end


return ClientDataModule
