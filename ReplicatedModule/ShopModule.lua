--// ShopModule 1.3v

local ShopModule = {}

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local PetModule = require(script.Parent.PetModule)

local function pass(frame, name, boost, info, icon, gamePassId, robux, srRobux, effect)
	return {
		FrameName = frame, Name = name, Boost = boost, Info = info,
		Description = info, Icon = icon, GamePassId = gamePassId,
		RobuxPrice = robux, SRRobuxPrice = srRobux, Effect = effect, EffectReady = false,
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
	EnergyPass = pass("PassEnergyFrame", "Energy Pass", "2x Energy", "Gain an extra 100% base Energy from training and rewards!.", "rbxassetid://72931645765112", 1860533278, 49, 39, "Energy"),
	RaceTouchPass = pass("PassRaceTouchFrame", "Race Touch Pass", "2x RaceTouch", "Earn an extra 100% base RaceTouch from races!", "rbxassetid://111988324538451", 2053548331, 49, 29, "RaceTouch"),
	MoneyPass = pass("PassMoneyFrame", "Money Pass", "2x Money", "Gain an extra 100% base Money from all rewards!", "rbxassetid://90642449616683", 2053380238, 49, 29, "Money"),
	PetStatPass = pass("PassPetStatFrame", "Pet Stat Pass", "2x PetStat", "Double all final pet stats, including level and tier bonuses!", "rbxassetid://101224774099593", 2053848263, 89, 69, "PetStat"),
	RebirthPass = pass("PassRebirthFrame", "Rebirth Pass", "2x Rebirth", "Earn twice as many Rebirths every time you rebirth!", "rbxassetid://96014338468295", 2052012357, 110, 89, "Rebirth"),
	GemsPass = pass("PassGemsFrame", "Gems Pass", "2x Gems", "Gain an extra 100% base Gems from all rewards!", "rbxassetid://130206347035457", 2053890231, 79, 59, "Gems"),
	TripleHatchPass = pass("PassTripleHatchFrame", "Triple Pass", "Open 3", "Hatch up to 3 eggs at the same time!", "rbxassetid://123451228200379", 2052162337, 139, 119, "TripleHatch"),
	PetLuckPass = pass("PassPetLuckFrame", "Pet Luck Pass", "2x PetLuck", "Get an extra 100% base Pet Luck when hatching eggs!", "rbxassetid://100026343618067" , 2052732252, 119, 99, "PetLuck"),
	RacePowerPass = pass("PassRacePowerFrame", "RacePower Pass", "2x RacePower", "Gain an extra 100% base Race Power!", "rbxassetid://112235652483676", 2052138230, 99, 79, "RacePower"),
	AccelerationPass = pass("PassAccelerationFrame", "Acceleration Pass", "2x Acceleration", "Gain an extra 100% base Acceleration in races!", "rbxassetid://86690693258798", 2052036337, 99, 79, "Acceleration"),
	AutoTrainingPass = pass("PassAutoTrainingFrame", "AutoTraining", "Auto Training", "Automatically train on your best available treadmill!", "rbxassetid://79885813969656" , 2054124210, 69, 49, "AutoTraining"),
	EggHatchSpeedPass = pass("PassEggHatchSpeedFrame", "Egg Hatch Speed", "2x HatchSpeed", "Hatch eggs twice as fast", "rbxassetid://124027859865924" , 2053440251, 59, 39, "EggHatchSpeed"),
	AutoRebirthPass = pass("PassAutoRebirthFrame", "Auto Rebirth", "Auto Rebireth", "Automatically rebirth whenever you have enough Energy!", "rbxassetid://99219517475671", 1903338380, 99, 129, "AutoRebirth"),
	MaxRebirthPass = pass("PassMaxRebirthFrame", "Max Rebirth", "Max Rebirth", "Perform the maximum available Rebirths with one ckick!", "rbxassetid://73622299266956", 1902642397, 139, 169, "MaxRebirth"),
	EggAutoHatchPass = pass("PassEggAutoHatchFrame", "Auto Open Egg", "Auto Open Egg", "Automatically hatch eggs without clicking!", "rbxassetid://81605234487811", 2053854274, 89, 59, "AutoOpenEgg"),
	AutoRacePass = pass("PassAutoRaceFrame", "Auto Race", "Auto Race", "Automatically join, tun and repeat races!", "rbxassetid://94993803080554", 2055468150, 69, 39, "AutoRace"),
}

for _, passId in ipairs(ShopModule.PassOrder) do
	ShopModule.Passes[passId].EffectReady = true
end

ShopModule.PassCount = #ShopModule.PassOrder

--// TEST PASS
ShopModule.PassTest = false

ShopModule.TestPasses = {
	EnergyPass = false,
	RaceTouchPass = false,
	MoneyPass = false,
	PetStatPass = false,
	RebirthPass = false,
	GemsPass = false,
	TripleHatchPass = false,
	PetLuckPass = false,
	RacePowerPass = false,
	AccelerationPass = false,
	AutoTrainingPass = false,
	EggHatchSpeedPass = false,
	AutoRebirthPass = false,
	MaxRebirthPass = false,
	EggAutoHatchPass = false,
	AutoRacePass = false,
}

ShopModule.UIImages = {
	PotionUseUnselected = "rbxassetid://88821350180635",
	PotionUseSelected = "rbxassetid://98055215682398",
	
	PassFrame = {
		Default = "rbxassetid://139954531126914",
		Selected = "rbxassetid://139236025897762",
	},
}

ShopModule.ErrorMessages = {
	UNKNOWN_PASS = "This pass does not exist.",
	UNKNOWN_POTION = "This potion does not exist.",
	
	INVALID_CURRENCY = "Choose a valid payment method.",
	INVALID_AMOUNT = "Choose a valid quantity.",
	INVALID_REQUEST = "The request was not valid.",
	
	DATA_NOT_READY = "Your data is still loading. Try again.",
	PASS_DATA_MISSING = "Pass data is unavailable. Try again.",
	POTION_DATA_MISSING = "Potion data is unavailable. Try again.",
	BALANCE_MISSING = "Your SRRobux balance is unavailable.",
	
	NOT_CONFIGURED = "This item is not available yet.",
	ALREADY_OWNED = "You already own this pass.",
	NOT_OWNED = "You do not own this pass.",
	
	NOT_ENOUGH_SRROBUX = "Not enough SRRobux.",
	NOT_ENOUGH_POTIONS = "Not enough potions.",
	
	OWNERSHIP_CHECK_FAILED = "Could not verify ownership. Try again.",
	PROMPT_FAILED = "Could not open the purchase window.",
	PURCHASE_FAILED = "Purchase failed.",
	SAVE_FAILED = "Could not save the purchase.",
	
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
			[1] = {Robux = 19, SRRobux = 3},
			[5] = {Robux = 79, SRRobux = 9},
			[10] = {Robux = 169, SRRobux = 15},
		},
	},
	
	MoneyPotion = {
		Name = "Money Potion", Icon = "", Desription = "", Boost = "x2 Money",
		BoostType = "Money", Duration = 900,
		Products = {[1] = 3605923802, [5] = 3605923866, [10] = 3605923925},
		Prices = {
			[1] = {Robux = 19, SRRobux = 3},
			[5] = {Robux = 79, SRRobux = 9},
			[10] = {Robux = 169, SRRobux = 15},
		},
	},
	
	LuckPotion = {
		Name = "Luck Potion", Icon= "", Description = "", Boost = "x2 Luck",
		BoostType = "Luck", Duration = 1200,
		Products = {[1] = 3605923597, [5] = 3605923668, [10] = 3605923725},
		Prices = {
			[1] = {Robux = 19, SRRobux = 3},
			[5] = {Robux = 79, SRRobux = 9},
			[10] = {Robux = 169, SRRobux = 15},
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

--// Regional Robux prices
function ShopModule.GetRegionalRobuxPrice(itemId, infoType)
	if typeof(itemId) ~= "number" or itemId <= 0 then return nil end
	
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(itemId, infoType)
	end)
	
	if not success then
		warn("Regional price request failed:", itemId, info)
		return nil
	end
	
	local price = info and info.PriceInRobux
	if typeof(price) ~= "number" or price <= 0 then return nil end
	
	return price
end

function ShopModule.GetRegionalPassRobuxPrice(passId)
	local data = ShopModule.GetPass(passId)
	if not data then return nil end
	
	return ShopModule.GetRegionalRobuxPrice(data.GamePassId, Enum.InfoType.GamePass)
end

function ShopModule.GetRegionalPotionRobuxPrice(potionId, amount)
	local data = ShopModule.Potions[potionId]
	if not data then return nil end
	
	local productId = data.Products[amount]
	
	return ShopModule.GetRegionalRobuxPrice(productId, Enum.InfoType.Product)
end

function ShopModule.IsPassTestActive()
	return ShopModule.PassTest == true and RunService:IsStudio()
end

function ShopModule.IsGamepassTest(passId)
	return ShopModule.IsPassTestActive() and ShopModule.TestPasses[passId] == true
end

function ShopModule.OwnsPass(player, passId)
	if not ShopModule.GetPass(passId) then return false end 
	if ShopModule.IsPassTestActive() then return ShopModule.TestPasses[passId] == true end
	
	local data = player and player:FindFirstChild("PlayerData")
	local folder = data and data:FindFirstChild("Gamepasses")
	local value = folder and folder:FindFirstChild(passId)
	
	return value ~= nil and value:IsA("BoolValue") and value.Value == true
end

function ShopModule.IsEquipped(player, passId)
	if not ShopModule.GetPass(passId) then return false end
	if ShopModule.IsPassTestActive() then return ShopModule.TestPasses[passId] == true end
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

--// 2x PetStat
function ShopModule.GetPetStatMultiplier(player)
	return ShopModule.HasPass(player, "PetStatPass") and 2 or 1
end

function ShopModule.ApplyPetStats(player, stats)
	if type(stats) ~= "table" then return nil end
	
	local multiplier = ShopModule.GetPetStatMultiplier(player)
	
	return {
		Energy = (tonumber(stats.Energy) or 0) * multiplier,
		Money = (tonumber(stats.Money) or 0) * multiplier,
		RacePower = (tonumber(stats.RacePower) or 0) * multiplier,
	}
end

function ShopModule.GetPetStats(player, petName, pattern, tier, level, externalBoosts)
	local calculatedStats = PetModule.CalculateFinalPetStats(petName, pattern, tier, level, externalBoosts)
	
	return ShopModule.ApplyPetStats(player, calculatedStats)
end

function ShopModule.GetEquippedBonuses(player)
	local result = {Energy = 0, Money = 0, RacePower = 0,}
	
	local petsFolder = player and player:FindFirstChild("Pets")
	if not petsFolder then return result end
	
	for _, petFolder in ipairs(petsFolder:GetChildren()) do
		if petFolder:IsA("Folder") then
			local equipped = petFolder:FindFirstChild("Equipped")
			local petName = petFolder:FindFirstChild("PetName")
			local pattern = petFolder:FindFirstChild("Pattern")
			local tier = petFolder:FindFirstChild("Tier")
			local level = petFolder:FindFirstChild("Level")
			
			if equipped and equipped.Value and petName and pattern and tier and level then
				local stats = ShopModule.GetPetStats(player, petName.Value, pattern.Value, tier.Value, level.Value)
				
				if stats then
					result.Energy += math.max(0, tonumber(stats.Energy) or 0)
					result.Money += math.max(0, tonumber(stats.Money) or 0)
					result.RacePower += math.max(0, tonumber(stats.RacePower) or 0)
				end
			end
		end
	end
	return result
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
