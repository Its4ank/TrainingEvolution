local ShopModule = {}

ShopModule.TestGamepasses = {
	Enabled = false,
	All = false,
	
	EnergyPass = false,
	AutoRebirthPass = false,
	MaxRebirthPass = false,
}

ShopModule.Passes = {
	EnergyPass = {
		Name = "Energy Pass",
		Icon = "",
		Description = "",
		Boost = "x2 Energy",
		
		GamePassId = 1860533278,
		
		RobuxPrice = 49,
		SRobuxPrice = 39,
		
		EnergyBonus = 1,
	},
	
	AutoRebirthPass = { 
		Name = "Auto Rebirth",
		Icon = "",
		Description = "",
		Boost = "Auto Rebirth",
		
		GamePassId = 1903338380,
		
		RobuxPrice = 99,
		SRobuxPrice = 129,
	},
	
	MaxRebirthPass = { 
		Name = "Max Rebirth",
		Icon = "",
		Description = "",
		Boost = "Max Rebirth",
		
		GamePassId = 1902642397,
		
		RobuxPrice = 139,
		SRobuxPrice = 169,
	},
}

ShopModule.Potions = { 
	EnergyPotion = { 
		Name = "Energy Potion",
		
		Icon = "",
		Description = "",
		
		Boost = "x2 Energy",
		BoostType = "Energy",
		
		Duration = 900,
		
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

function ShopModule.IsGamepassTest(passId)
	local testConfig = ShopModule.TestGamepasses
	
	if testConfig.Enabled ~= true then return false end
	if testConfig.All == true then return false end
	
	return testConfig[passId] == true
end

function ShopModule.HasPass(player, passId)
	if not ShopModule.IsGamepassTest(passId) then return false end
	
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return false end

	local gamepasses = playerData:FindFirstChild("Gamepasses")
	if not gamepasses then return false end

	local passValue = gamepasses:FindFirstChild(passId)

	return passValue ~= nil and passValue:IsA("BoolValue") and passValue.Value == true
end

function ShopModule.HasAutoRebirth(player)
	return ShopModule.HasPass(player, "AutoRebirthPass")
end

function ShopModule.HasMaxRebirth(player)
	return ShopModule.HasPass(player, "MaxRebirthPass")
end

function ShopModule.GetEnergyBonus(player)
	if ShopModule.HasPass(player, "EnergyPass") then
		return ShopModule.Passes.EnergyPass.EnergyBonus or 0
	end
	return 0
end

return ShopModule
