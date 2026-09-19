local EggModule = {}

--// General settings
EggModule.MAX_MULTI_HATCH = 3

EggModule.Luck = {
	MaxOpenings = 100,
	LuckPerOpening = 0.01,
	MaxMultiplier = 2,
	OfflineResetTime = 10 * 60,
}

EggModule.AutoHatch = {
	ResultDisplayTime = 2,
}

EggModule.TestGamepasses = {
	Enabled = true,
	
	TripleHatch = true,
	AutoHatch = true,
}

--// UI images
EggModule.AutoDeleteImages = {
	Default = "",
	Selected = "",
}

EggModule.AutoStopImages = {
	Default = "",
	Selected = "",
}

--// Egg hatch animation images
EggModule.EggAnimationImages = {
	Egg1 = {
		Stage1 = "",
		Stage2 = "",
		Stage3 = "",
		Stage4 = "",
	},
}

--// Price progression
EggModule.PriceRanges = {
	{From = 0, To = 9, Increase = 50},
	{From = 10, To = 24, Increase = 100},
	{From = 25, To = 49, Increase = 250},
	{From = 50, To = 99, Increase = 500},
	{From = 100, To = 199, Increase = 2500},
	{From = 200, To = 499, Increase = 10000},
	{From = 500, To = 999, Increase = 50000},
	{From = 1000, To = math.huge, Increase = 250000},
}

--// Eggs
EggModule.Eggs = {
	Egg1 = {
		Name = "Egg1",
		
		Currency = "Money",
		BasePrice = 100,
		
		IsDonateEgg = false,
		AllowGlobalAutoDelete = true,
		
		Pets = {
			{PetName = "Dog", Chance = 35, ButtonName = "EggCommonBut",},
			{PetName = "Cow", Chance = 25, ButtonName = "EggUncommonBut",},
			{PetName = "Cat", Chance = 20, ButtonName = "EggRareBut",},
			{PetName = "Pig", Chance = 15, ButtonName = "EggEpicBut",},
			{PetName = "Chicken", Chance = 5, ButtonName = "EggLegendaryBut",},
		},
	},
}

--// Internal helpers
local function getPriceRange(openedCount)
	for _, range in ipairs(EggModule.PriceRanges) do
		if openedCount >= range.From and openedCount <= range.To then
			return range
		end
	end
	return nil
end

--// Egg config
function EggModule.GetEggConfig(eggName)
	return EggModule.Eggs[eggName]
end

function EggModule.GetEggPetConfig(eggName, petName)
	local eggConfig = EggModule.GetEggConfig(eggName)
	if not eggConfig then return nil end 
	
	for _, petConfig in ipairs(eggConfig.Pets) do
		if petConfig.PetName == petName then
			return petConfig
		end
	end
	return nil
end

function EggModule.GetPetByButtonName(eggName, buttonName)
	local eggConfig = EggModule.GetEggConfig(eggName)
	if not eggConfig then return nil end
	
	for _, petConfig in ipairs(eggConfig.Pets) do
		if petConfig.ButtonName == buttonName then
			return petConfig
		end
	end
	return nil
end

--// Price
function EggModule.GetEggPrice(eggName, openedCount)
	local eggConfig = EggModule.GetEggConfig(eggName)
	if not eggConfig then return nil end
	
	openedCount = math.max(0, math.floor(openedCount or 0))
	
	local price = eggConfig.BasePrice
	local remainingOpenings = openedCount
	local currentOpening = 0
	
	for _, range in ipairs(EggModule.PriceRanges) do
		if remainingOpenings <= 0 then break end
		
		local rangeLength
		
		if range.To == math.huge then
			rangeLength = remainingOpenings
		else
			rangeLength = range.To - range.From + 1
		end
		
		local openingsInRange = math.min(remainingOpenings, rangeLength)
		
		price += openingsInRange * range.Increase
		
		remainingOpenings -= openingsInRange
		currentOpening += openingsInRange
	end
	return math.floor(price)
end

function EggModule.GetBatchPrice(eggName, openedCount, amount)
	amount = math.clamp(math.floor(amount or 1), 1, EggModule.MAX_MULTI_HATCH)
	
	local totalPrice = 0
	
	for index = 0, amount - 1 do
		local price = EggModule.GetEggPrice(eggName, openedCount + index)
		if not price then return nil end
		
		totalPrice += price
	end
	return totalPrice
end

function EggModule.GetAffordableAmount(eggName, openedCount, balance, maxAmount)
	maxAmount = math.clamp(math.floor(maxAmount or 1), 1, EggModule.MAX_MULTI_HATCH)
	
	balance = math.max(0, balance or 0)
	
	local affordableAmount = 0
	local totalPrice = 0
	
	for index = 0, maxAmount - 1 do
		local price = EggModule.GetEggPrice(eggName, openedCount + index)
		if not price then return nil end
		
		if totalPrice + price > balance then break end
		
		totalPrice += price
		affordableAmount += 1
	end
	return affordableAmount, totalPrice
end

--// Luck
function EggModule.GetLuckMultiplier(luckOpenings)
	luckOpenings = math.clamp(math.floor(luckOpenings or 0), 0, EggModule.Luck.MaxOpening)
	
	local multiplier = 1 + (luckOpenings * EggModule.Luck.LuckPerOpening)
	
	return math.min(multiplier, EggModule.Luck.MaxMultiplier)
end

function EggModule.GetLuckProgress(luckOpenings)
	luckOpenings = math.clamp(math.floor(luckOpenings or 0), 0, EggModule.Luck.MaxOpenings)
	
	return luckOpenings / EggModule.Luck.MaxOpenings
end

function EggModule.GetLuckBarPosition(luckOpenings)
	local progress = EggModule.GetLuckProgress(luckOpenings)
	
	local startX = -0.97
	local endX = 0.01
	
	local x = startX + ((endX - startX) * progress)
	
	return UDim2.new(x, 0, 0, 0)
end

function EggModule.GetLuckLabel(luckOpenings)
	luckOpenings = math.clamp(math.floor(luckOpenings or 0), 0, EggModule.Luck.MaxOpenings)
	
	local multiplier = EggModule.GetLuckMultiplier(luckOpenings)
	return string.format("%d/%.2fx", luckOpenings, multiplier)
end

--// UI images
function EggModule.GetAutoDeleteImage(state)
	return EggModule.AutoDeleteImages[state] or EggModule.AutoDeleteImages.Default
end

function EggModule.GetAutoStopImage(state)
	return EggModule.AutoStopImages[state] or EggModule.AutoStopImages.Default
end

function EggModule.GetAnimationImage(eggName, stageName)
	local eggImages = EggModule.EggAnimationImages[eggName]
	if not eggImages then return "" end
	
	return eggImages[stageName] or ""
end

return EggModule