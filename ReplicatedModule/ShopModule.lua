local ShopModule = {}

ShopModule.Passes = {
	EnergyPass = {
		GamePassId = 1860533278,
		SRobuxPrice = 39,
		EnergyBonus = 1,
	},
	
	AutoRebirthPass = { 
		GamePassId = 1903338380,
		SRobuxPrice = 129,
	},
	
	MaxRebirthPass = { 
		GamePassId = 1902642397,
		SRobuxPrice = 169,
	},
}

ShopModule.Potions = { 
	EnergyPotion = { 
		BoostType = "Energy",
		
		Products = { 
			[1] = 3605923166,
			[5] = 3605923313,
			[10] = 3605923404,
		},
		
		Prices = { 
			[1] = { 
				Robux = 19,
				SRRobux = 9,
			},
			
			[5] = {
				Robux = 79,
				SRRobux = 49,
			},
			
			[10] = { 
				Robux = 169,
				SRRobux = 99,
			},
		},
	},
	
	MoneyPotion = { 
		BoostType = "Money",
		
		Products = { 
			[1] = 3605923802,
			[5] = 3605923866,
			[10] = 3605923925,
		},
		
		Prices = { 
			[1] = { 
				Robux = 19,
				SRRobux = 9,
			},
			
			[5] = {
				Robux = 79,
				SRRobux = 49,
			},
			
			[10] = { 
				Robux = 169,
				SRRobux = 99,
			},
		},
	},
	
	LuckPotion = { 
		BoostType = "Luck",
		
		Products = { 
			[1] = 3605923597,
			[5] = 3605923668,
			[10] = 3605923725,
		},
		
		Prices = { 
			[1] = { 
				Robux = 19,
				SRRobux = 9,
			},
			
			[5] = {
				Robux = 79,
				SRRobux = 49,
			},
			
			[10] = { 
				Robux = 169,
				SRRobux = 99,
			},
		},
	},
}

function ShopModule.HasPass(player, passId)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return false end

	local gamepasses = playerData:FindFirstChild("Gamepasses")
	if not gamepasses then return false end

	local passValue = gamepasses:FindFirstChild(passId)
	if not passValue then return false end

	return passValue.Value == true
end

function ShopModule.HasAutoRebirth(player)
	return ShopModule.HasPass(player, "AutoRebirthPass")
end

function ShopModule.HasMaxRebirth(player)
	return ShopModule.HasPass(player, "MaxRebirthPass")
end

function ShopModule.GetEnergyBonus(player)
	if ShopModule.HasPass(player, "EnergyPass") then
		return ShopModule.Passes.EnergyPass.EnergyBonus
	end
	return 0
end

return ShopModule
