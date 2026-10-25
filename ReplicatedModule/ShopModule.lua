--// ShopModule 1.3v

local ShopModule = {}

local function pass(frame, name, boost, info, icon, gamePassId, robux, srRobux, effect)
	return {
		FrameName = frame, Name = name, Boost = boost, Info = info,
		Description = info, Icon = icon, GamePassId = gamePassId,
		RobuxPrice = robux, SRobuxPrice = srRobux, Effect = effect, EffectReady = false,
	}
end

ShopModule.PassOrder = {
	"EnergyPass", "RaceTouchPass", "MoneyPass", "PetStatPass",
	"RebirthPass", "GemsPass", "TripleHatchPass", "PetLuckPass",
	"RacePowerPass", "AccelerationPass", "AutoTrainingPass",
	"EggHatchSpeedPass", "AutoRebirthPass", "MaxRebirthPass",
	"EggAutoHatchPass", "AutoRacePass",
}

ShopModule.Passes = {
	EnergyPass = pass("PassEnergyFrame", "Energy Pass", "2x Energy", "Info"),
	RaceTouchPass = pass("PassRaceTouchFrame", "Race Touch Pass", "2x RaceTouch", "Info"),
	MoneyPass = pass("PassMoneyFrame", "Money Pass", "2x Money", "Info"),
	PetStatPass = pass("PassPetStatFrame", "Pet Stat Pass", "2x PetStats", "Info"),
	RebirthPass = pass("PassRebirthFrame", "Rebirth Pass", "2x Rebirth", "Info"),
	GemsPass = pass("PassGemsFrame", "Gems Pass", "2x Gems", "Info"),
	TripleHatchPass = pass("PassTripleHatchFrame", "Triple Pass", "Open 3", "Info"),
	PetLuckPass = pass("PassPetLuckFrame", "Pet Luck Pass", "2x PetLuck", "info"),
	RacePowerPass = pass("RassRacePowerFrame", "RacePower Pass", "2x RacePower", "Info"),
	AccelerationPass = pass("PassAccelerationFrame", "Acceleration Pass", "2x Acceleration", "Info"),
	AutoTrainingPass = pass("PassAutoTrainingFrame", "AutoTraining", "Auto Training", "Info"),
	EggHatchSpeedPass = pass("PassEggHatchSpeedFrame", "Egg Hatch Speed", "2x HatchSpeed", "Info"),
	AutoRebirthPass = pass("PassAutoRebirthFrame", "Auto Rebirth", "Auto Rebireth", "Info"),
	MaxRebirthPass = pass("PassMaxRebirthFrame", "Max Rebirth", "Max Rebirth", "Info"),
	EggAutoHatchPass = pass("PassEggAutoHatchFrame", "Auto Open Egg", "Auto Open Egg", "Info"),
	AutoRacePass = pass("PassAutoRaceFrame", "Auto Race", "Auto Race", "Info"),
}

for _, passId in ipairs({"EnergyPass", "AutoRebirthPass", "MaxRebirthPass"}) do
	ShopModule.Passes[passId].EffectReady = true
end

ShopModule.PassCount = #ShopModule.PassOrder
ShopModule.TestGamepasses = {Enabled = false, All = false}

ShopModule.UIImages = {
	PotionUseUnselected = "rbxassetid://88821350180635",
	PotionUseSelected = "rbxassetid://98055215682398",
}

ShopModule.ErrorMessages = {
	UNKNOWN_PASS = "This pass does not exist.",
	UNKNOWN_POTION = "This potion does not exist.",
	INVALID_CURRENCY = "Choose a valid payment method.",
	INVALID_AMOUNT = "Choose a valid quantity.",
	INVALID_REQUEST = "The request was not valid.",
	DATA_NOT_MISSING = "Your data is still loading. Try again.",
	PASS_DATA_MISSING = "Potion data is unavailable. Try again.",
	POTION_DATA_MISSING = "Potion data is unailable. Try again.",
	BALANCE_MISSING = "Your SRRobux balance is unavailable.",
	NOT_CONFIGURED = "This item is not available yet.",
	ALREADY_OWNED = "You already own thus pass.",
	NOT_OWNED = "You do not own this pass.",
	NOT_ENOUGH_SRROBUX = "Not enough SRRobux.",
	NOT_ENOUGH_POSIONS = "Not enough potions.",
	OWNERSHIP_CHECK_FAILED = "Could not verify ownership. Try again.",
	PROMPT_FAILED = "Could not open the purchase window.",
	PURCHASE_FAILED = "Purchase failed. Your SRRobux was not charged.",
	SAVE_FAILED = "Could not save the purchase. Your SRRobux was restored.",
	EQUIP_FAILED = "Could not changed this pass right now.",
	POTION_USE_FAILED = "Could not use the potion right now.",
	BUSY = "Another shop request is still processing.",
}

ShopModule.PotionOrder = {"EnergyPotion", "MoneyPotion", "LuckPotion"}
ShopModule.Potions = {
	EnergyPotion = {
		Name = "Energy Potion", Icon = "", Desctiption = "", Boost = "2x Energy",
		BoostType = "Energy", Duration = 900,
		Products = {[1] = 3605923166, [5] = 3605923313, [10] = 3605923404},
		Prices = {
			[1] = {Robux = 19, SRRobux = 9},
			[5] = {Robux = 79, SRRobux = 49},
			[10] = {Robux = 169, SRRobux = 99},
		},
	},
	
	MoneyPotion = {
		Name = "Money Potion", Icon = "", Desription = "", Boost = "x2 Money",
		BoostType = "Money", Duration = 900,
		Products = {[1] = 3605923802, [5] = 3605923866, [10] = 3605923925},
		Prices = {
			[1] = {Robux = 19, SRRobux = 9},
			[5] = {Robux = 79, SRRobux = 49},
			[10] = {Robux = 169, SRRobux = 99},
		},
	},
	
	LuckPotion = {
		Name = "Luck Potion", Icon= "", Description = "", Boost = "x2 Luck",
		BoostType = "Luck", Duration = 1200,
		Products = {[1] = 3605923597, [5] = 3605923668, [10] = 3605923725},
		Prices = {
			[1] = {Robux = 19, SRRobux = 9},
			[5] = {Robux = 79, SRRobux = 49},
			[10] = {Robux = 169, SRRobux = 99},
		},
	},
}

function ShopModule.GetPass(passId)
	return ShopModule.Passes[passId]
end

function ShopModule.GetPassPrice(passId, currency)
	local data = ShopModule.GetPass(passId)
	if not data then return nil end 
	
	local price = currency == "Robux" and data.RobuxPrice or currency == "SRRobux" and data.SRRobuxPrice
	if type(price) ~= "number" or price <= 0 then return nil end
	return price
end

function ShopModule.IsPassConfigured(passId)
	local data = ShopModule.GetPass(passId)
	return data ~= nil and data.EffectReady == true
		and type(data.GamePassId) == "number" and data.GamePassId > 0
		and ShopModule.GetPassPrice(passId, "Robux") ~= nil
		and ShopModule.GetPassPrice(passId, "SRRobux") ~= nil
		and type(data.Icon) == "string" and data.Icon ~= ""
end

function ShopModule.GetPotionPrice(potionId, amount, currency)
	local data = ShopModule.Potions[potionId]
	local prices = data and data.Prices[amount]
	local price = prices and prices[currency]
	
	if type(price) ~= "number" or price <= 0 then return nil end
	return price 
end

function ShopModule.IsGamepassTest(passId)
	local config = ShopModule.TestGamepasses
	
	return config.Enabled == true and (config.All == true or config[passId] == true)
end

function ShopModule.OwnsPass(player, passId)
	if not ShopModule.GetPass(passId) then return false end 
	if ShopModule.IsGamepassTest(passId) then return true end
	
	local data = player and player:FindFirstChild("PlayerData")
	local folder = data and data:FindFirstChild("Gamepasses")
	local value = folder and folder:FindFirstChild(passId)
	
	return value ~= nil and value:IsA("BoolValue") and value.Value == true
end

function ShopModule.IsEquipped(player, passId)
	if not ShopModule.OwnsPass(player, passId) then return false end
	
	local data = player and player:FindFirstChild("PlayerData")
	local folder = data and data:FindFirstChild("EquippedGamepasses")
	local value = folder and folder:FindFirstChild(passId)
	
	return value == nil or (value:IsA("BoolValue") and value.Value == true)
end

function ShopModule.HasPass(player, passId)
	return ShopModule.IsEquipped(player, passId)
end

function ShopModule.GetPassStatus(player, passId, currency)
	if not ShopModule.GetPass(passId) then return "UNKNOWN" end
	if ShopModule.IsEquipped(player, passId) then return "OWNED" end
	if ShopModule.OwnsPass(player, passId) then return "EQUIP" end
	
	local price = ShopModule.GetPassPrice(passId, currency)
	
	if not ShopModule.IsPassConfigured(passId) or not price then return "SOON" end
	
	return tostring(price) .. " " .. currency
end

function ShopModule.AddBaseBonus(player, passId, baseAmount, currentAmount)
	if type(baseAmount) ~= "number" or type(currentAmount) ~= "number" then
		return currentAmount
	end
	
	if ShopModule.HasPass(player, passId) then
		return currentAmount + baseAmount
	end
	
	return currentAmount
end

local RESOURCES_PASSES = {
	Energy = "EnergyPass", Money = "MoneyPass", Gems = "GemsPass", RaceTouch = "RaceTouchPass",
}

function ShopModule.ApplyResourcePass(player, resourceName, baseAmount, currentAmount)
	local passId = RESOURCES_PASSES[resourceName]
	if not passId then return currentAmount end
	
	return ShopModule.AddBaseBonus(player, passId, baseAmount, currentAmount)
end

function ShopModule.ApplyPetStat(player, baseStat, currentStat)
	return ShopModule.AddBaseBonus(player, "PetStatPass", baseStat, currentStat)
end

function ShopModule.ApplyPetLuck(player, baseLuck, currentLuck)
	return ShopModule.AddBaseBonus(player, "PetLuckPass", baseLuck, currentLuck)
end

function ShopModule.ApplyRacePower(player, basePercent, currentPercent)
	return ShopModule.AddBaseBonus(player, "RacePowerPass", basePercent, currentPercent)
end

function ShopModule.GetTransportRacePowerMultiplier(player, transportBoost)
	if type(transportBoost) ~= "table" then return 1 end
	
	local basePercent = math.max(0, tonumber(transportBoost.BaseRacePower) or 0)
	local currentPercent = math.max(0, tonumber(transportBoost.RacePower) or 0)
	local finalPercent = ShopModule.ApplyRacePower(player, basePercent, currentPercent)
	
	return 1 + finalPercent / 100
end

function ShopModule.ApplyAcceleration(player, baseAcceleration, currentAcceleration)
	return ShopModule.AddBaseBonus(player, "AccelerationPass", baseAcceleration, currentAcceleration)
end

function ShopModule.GetRebirthAward(player, purchaseAmount)
	if type(purchaseAmount) ~= "number" or purchaseAmount < 1 then return 0 end
	
	local amount = math.floor(purchaseAmount)
	
	return ShopModule.AddBaseBonus(player, "RebirthPass", amount, amount)
end

function ShopModule.GetEggOpenLimit(player)
	return ShopModule.HasPass(player, "TripleHatchPass") and 3 or 1
end

function ShopModule.GetEggHatchDuration(player, normalDuration)
	if type(normalDuration) ~= "number" or normalDuration < 0 then return 0 end
	
	return ShopModule.HasPass(player, "EggHatchSpeedPass") and normalDuration / 2 or normalDuration
end

function ShopModule.GetLatestAvailableTreadmill(maxTreadmill, isUnlocked)
	if type(maxTreadmill) ~= "number" or type(isUnlocked) ~= "function" then return nil end
	
	for id = math.floor(maxTreadmill), 1, -1 do
		if isUnlocked(id) then return id end
	end
	
	return nil
end

ShopModule.AutomaticModes = {
	AutoTraining = "AutoTrainingPass",
	AutoRace = "AutoRacePass",
	AutoOpenEgg = "EggAutoHatchPass",
}

function ShopModule.CanUseAutomaticMode(player, mode)
	local passId = ShopModule.AutomaticModes[mode]
	return passId ~= nil and ShopModule.HasPass(player, passId)
end

function ShopModule.AutomaticModesConflict(firstMode, secondMode)
	return firstMode ~= secondMode and ShopModule.AutomaticModes[firstMode] ~= nil and ShopModule.AutomaticModes[secondMode] ~= nil
end

function ShopModule.HasAutoRebirth(player)
	return ShopModule.HasPass(player, "AutoRebirthPass")
end

function ShopModule.HasMaxRebirth(player)
	return ShopModule.HasPass(player, "MaxRebirthPass")
end

function ShopModule.GetEnergyBonus(player)
	return ShopModule.HasPass(player, "EnergyPass") and 1 or 0
end

function ShopModule.GetAutoEggOpenCount(player, freeSlots, canAfford)
	if type(freeSlots) ~= "number" or type(canAfford) ~= "function" then return 0 end
	
	local limit = math.min(ShopModule.GetEggOpenLimit(player), math.max(0, math.floor(freeSlots)))
	
	for amount = limit, 1, -1 do 
		if canAfford(amount) then return amount end
	end
	
	return 0
end

function ShopModule.GetAutoRaceState(isRaceOpen)
	return isRaceOpen and "Racing" or "Waiting"
end

return ShopModule
