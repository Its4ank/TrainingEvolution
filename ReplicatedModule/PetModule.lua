local PetModule = {}

--// General settings
PetModule.DEFAULT_MAX_STORAGE = 50
PetModule.BASE_EQUIPPED_PETS = 3
PetModule.MAX_LEVEL = 30
PetModule.MIN_PATTERN = 1
PetModule.MAX_PATTERN = 100

--// UI images
PetModule.InventoryButtonImages = {
	Default = "",
	Selected = "",
	Equipped = "",
	Delete = "",
}

PetModule.EquipSlotImages = {
	Default = "",
	Filled = "",
}

--// Rarities
PetModule.Rarities = {
	Common = {
		Name = "Common",
		Order = 1,
		Icon = "",
	},
	
	Uncommon = {
		Name = "Uncommon",
		Order = 2,
		Icon = "",
	},
	
	Rare = {
		Name = "Rare",
		Order = 3,
		Icon = "",
	},
	
	Epic = {
		Name = "Epic",
		Order = 4,
		Icon = "",
	},
	
	Legendary = {
		Name = "Legendary",
		Order = 5,
		Icon = "",
	},
}

--// PetData
PetModule.Pets = {
	Dog = {
		Name = "Dog",
		Rarity = "Common",
		Icon = "",
		ModelName = "Dog",
		
		BaseStats = {
			Energy = 1,
			Money = 1,
			RacePower = 1,
		},
	},
	
	Cow = {
		Name = "Cow",
		Rarity = "Uncommon",
		Icon = "",
		ModelName = "Cow",
		
		BaseStats = {
			Energy = 2.5,
			Money = 1.5,
			RacePower = 2,
		},
	},
	
	Cat = {
		Name = "Cat",
		Rarity = "Rare",
		Icon = "",
		ModelName = "Cat",
		
		BaseStats = {
			Energy = 5,
			Money = 2.5,
			RacePower = 4,
		},
	},
	
	Pig = {
		Name = "Pig",
		Rarity = "Epic",
		Icon = "",
		ModelName = "Pig",
		
		BaseStats = {
			Energy = 10,
			Money = 6.5,
			RacePower = 12,
		},
	},
	
	Chicken = {
		Name = "Chicken",
		Rarity = "Legendary",
		Icon = "",
		ModelName = "Chicken",
		
		BaseStats = {
			Energy = 15,
			Money = 10,
			RacePower = 17.5,
		},
	},
	
	Reaper = {
		Name = "Reaper",
		Rarity = "Rare",
		Icon = "",
		ModelName = "Reaper",
		
		BaseStats = {
			Energy = 7.5,
			Money = 10,
			RacePower = 15,
		},
	},
	
	DualReaper = {
		Name = "Dual Reaper",
		Rarity = "Epic",
		Icon = "",
		ModelName = "DualReaper",
		
		BaseStats = {
			Energy = 15,
			Money = 12.5,
			RacePower = 30,
		},
	},
	
	HugeQueen = {
		Name = "Huge Queen",
		Rarity = "Legendary",
		Icon = "",
		ModelName = "HugeQueen",
		
		BaseStats = {
			Energy = 45,
			Money = 35,
			RacePower = 50,
		},
	},
	
	ErrCube = {
		Name = "ErrCube",
		Rarity = "Legendary",
		Icon = "",
		ModelName = "ErrCube",
		
		BaseStats = {
			Energy = 70,
			Money = 50,
			RacePower = 125,
		},
	},
	
	Thunger = {
		Name = "Thunger",
		Rarity = "Legendary",
		Icon = "",
		ModelName = "Thunger",
		
		BaseStats = {
			Energy = 100,
			Money = 75,
			RacePower = 150,
		},
	},
	
	CubeHead = {
		Name = "Cube Head",
		Rarity = "Legendary",
		Icon = "",
		ModelName = "CubeHead",
		
		BaseStats = {
			Energy = 125,
			Money = 100,
			RacePower = 200,
		},
	},
	
	TheCube = {
		Name = "The Cube",
		Rarity = "Legendary",
		Icon = "",
		ModelName = "TheCube",
		
		BaseStats = {
			Energy = 150,
			Money = 125,
			RacePower = 250,
		},
	},
	
	MagicalGolden = {
		Name = "MagicalGolden",
		Rarity = "Legendary",
		Icon = "",
		ModelName = "MagicalGolden",
		
		BaseStats = {
			Energy = 175,
			Money = 150,
			RacePower = 300,
		},
	},
}

--// Eggs
PetModule.Eggs = {
	Egg1 = {
		Name = "Egg1",
		Price = 100,
		
		Pets = {
			{PetName = "Dog", Chance = 35,},
			{PetName = "Cow", Chance = 25,},
			{PetName = "Cat", Chance = 20,},
			{PetName = "Pig", Chance = 15,},
			{PetName = "Chicken", Chance = 5,},
		},
	},
}

--// Pattern
PetModule.PatternRanges = {
	{MinPattern = 1, MaxPattern = 20, Chance = 60,},
	{MinPattern = 21, MaxPattern = 40, Chance = 30,},
	{MinPattern = 41, MaxPattern = 60, Chance = 6,},
	{MinPattern = 61, MaxPattern = 80, Chance = 3.5,},
	{MinPattern = 81, MaxPattern = 100, Chance = 0.5,},
}

--// Tiers
PetModule.Tiers = {
	[0] = {Name = "Normal", Chance = 95, StatMultiplier = 1,},
	[1] = {Name = "Big", Chance = 3, StatMultiplier = 1.5,},
	[2] = {Name = "Silver", Chance = 1, StatMultiplier = 2,},
	[3] = {Name = "Gold", Chance = 0.5, StatMultiplier = 3,},
	[4] = {Name = "Rainbow", Chance = 0.4, StatMultiplier = 4,},
	[5] = {Name = "Legend", Chance = 0.1, StatMultiplier = 5,},
}

--// PetLevel upgrade prices
PetModule.LevelUp = {
	{FromLevel = 1, ToLevel = 5, StartPrice = 100, EndPrice = 500, StartXP = 5, EndXP = 50,},
	{FromLevel = 6, ToLevel = 10, StartPrice = 1000, EndPrice = 5000, StartXP = 60, EndXP = 100,},
	{FromLevel = 11, ToLevel = 15, StartPrice = 10000, EndPrice = 50000, StartXP = 125, EndXP = 250,},
	{FromLevel = 16, ToLevel = 20, StartPrice = 100000, EndPrice = 500000, StartXP = 300, EndXP = 500,},
	{FromLevel = 21, ToLevel = 25, StartPrice = 1000000, EndPrice = 5000000, StartXP = 550, EndXP = 750,},
	{FromLevel = 26, ToLevel = 30, StartPrice = 10000000, EndPrice = 50000000, StartXP = 800, EndXP = 1100,},
}

--// Pet level stat boost
PetModule.LevelBoost = {
	{FromLevel = 1, ToLevel = 5, StartBoost = 0.10, EndBoost = 0.25,},
	{FromLevel = 6, ToLevel = 10, StartBoost = 0.25, EndBoost = 0.50,},
	{FromLevel = 11, ToLevel = 15, StartBoost = 0.50, EndBoost = 0.75,},
	{FromLevel = 16, ToLevel = 20, StartBoost = 0.75, EndBoost = 1.00,},
	{FromLevel = 21, ToLevel = 25, StartBoost = 1.00, EndBoost = 1.25,},
	{FromLevel = 26, ToLevel = 30, StartBoost = 1.25, EndBoost = 1.50,},
}

--// Internal helpers
local function lerpNumber(startValue, endValue, alpha)
	return startValue + ((endValue - startValue) * alpha)
end

local function getRangeAlpha(value, minValue, maxValue)
	if maxValue <= minValue then return 0 end
	
	return math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
end

--// Config getters
function PetModule.GetPetConfig(petName)
	return PetModule.Pets[petName]
end

function PetModule.GetEggConfig(eggName)
	return PetModule.Eggs[eggName]
end

function PetModule.GetRarityConfig(rarityName)
	return PetModule.Rarities[rarityName]
end

function PetModule.GetTierConfig(tier)
	return PetModule.Tiers[tier]
end

function PetModule.GetPatternRanges()
	return PetModule.PatternRanges
end

function PetModule.GetDisplayName(petName)
	local config = PetModule.GetPetConfig(petName)
	if not config then return petName end
	
	return config.DisplayName or config.Name
end

--// Pattern
function PetModule.GetPatternMultiplier(pattern)
	pattern = math.clamp(pattern or PetModule.MIN_PATTERN, PetModule.MIN_PATTERN, PetModule.MAX_PATTERN)
	if pattern <= 20 then
		return 1 + (pattern * 0.05)
	end
	
	return pattern / 10
end

--// Pattern roll
function PetModule.RollPattern()
	local roll = math.random() * 100
	local accumulatedChance = 0
	
	for _, range in ipairs(PetModule.PatternRanges) do
		accumulatedChance += range.Chance
		
		if roll <= accumulatedChance then
			return math.random(range.MinPattern, range.MaxPattern)
		end
	end
	return PetModule.MIN_PATTERN
end

--// Tier roll
function PetModule.RollTier()
	local roll = math.random() * 100
	local accumulatedChance = 0
	
	for tier = 0, 5 do
		local tierConfig = PetModule.Tiers[tier]
		
		if tierConfig then
			accumulatedChance += tierConfig.Chance
			
			if roll <= accumulatedChance then return tier end
		end
	end
	return 0
end

--// Level upgrade config
function PetModule.GetLevelUpgradeRange(targetLevel)
	for _, range in ipairs(PetModule.LevelUp) do
		if targetLevel >= range.FromLevel and targetLevel <= range.ToLevel then
			return range
		end
	end
	return nil
end

function PetModule.GetLevelUpgradeCost(targetLevel)
	targetLevel = math.clamp(targetLevel, 1, PetModule.MAX_LEVEL)
	
	local range = PetModule.GetLevelUpgradeRange(targetLevel)
	if not range then return nil end
	
	local alpha = getRangeAlpha(targetLevel, range.FromLevel, range.ToLevel)
	local moneyPrice = lerpNumber(range.StartPrice, range.EndPrice, alpha)
	local xpPrice = lerpNumber(range.StartXP, range.EndXP, alpha)
	
	return {Money = math.floor(moneyPrice), XP = math.floor(xpPrice),}
end

--// Level stat boost
function PetModule.GetLevelBoost(level)
	if level <= 0 then return 0 end
	
	level = math.clamp(level, 1, PetModule.MAX_LEVEL)
	
	for _, range in ipairs(PetModule.LevelBoost) do
		if level >= range.FromLevel and level <= range.ToLevel then
			local alpha = getRangeAlpha(level, range.FromLevel, range.ToLevel)
			
			return lerpNumber(range.StartBoost, range.EndBoost, alpha)
		end
	end
	return 0
end

--// Tier multiplier
function PetModule.GetTierMultiplier(tier)
	local config = PetModule.GetTierConfig(tier)
	if not config then return 1 end
	
	return config.StatMultiplier or 1
end

--// Own pet stats
function PetModule.CalculatePetStats(petName, pattern, tier, level)
	local config = PetModule.GetPetConfig(petName)
	if not config then return nil end
	
	pattern = pattern or 1
	tier = tier or 0
	level = level or 0
	
	local patternMultiplier = PetModule.GetPatternMultiplier(pattern)
	local tierMultiplier = PetModule.GetTierMultiplier(tier)
	local levelBoost = PetModule.GetLevelBoost(level)
	
	local internalMultiplier = patternMultiplier * tierMultiplier * (1 + levelBoost)
	
	return {
		Energy = config.BaseStats.Energy * internalMultiplier,
		Money = config.BaseStats.Money * internalMultiplier,
		RacePower = config.BaseStats.RacePower * internalMultiplier,
	}
end

--// External PetStat boosts
function PetModule.CombinePetStatBoosts(boosts)
	local finalMultiplier = 1
	
	for _, multiplier in ipairs(boosts) do
		multiplier = multiplier or 1
		
		if multiplier > 1 then
			finalMultiplier += multiplier - 1
		end
	end
	return finalMultiplier
end

function PetModule.ApplyPetStatBoosts(stats, boosts)
	local multiplier = PetModule.CombinePetStatBoosts(boosts)
	
	return {
		Energy = (stats.Energy or 0) * multiplier,
		Money = (stats.Money or 0) * multiplier,
		RacePower = (stats.RacePower or 0) * multiplier,
	}
end

--// Full pet stats
function PetModule.CalculateFinalPetStats(petName, pattern, tier, level, externalBoosts)
	local ownStats = PetModule.CalculatePetStats(petName, pattern, tier, level)
	if not ownStats then return nil end
	
	externalBoosts = externalBoosts or {}
	
	return PetModule.ApplyPetStatBoosts(ownStats, externalBoosts)
end

--// Power score
function PetModule.GetPowerScore(stats)
	if not stats then return 0 end
	
	return (stats.Energy or 0) + (stats.Money or 0) + (stats.RacePower or 0)
end

--// Inventory button state
function PetModule.GetInventoryBuyttonImage(state)
	return PetModule.InventoryButtonImages[state] or PetModule.InventoryButtonImages.Default
end

--// Equipped slot state
function PetModule.GetEquipSlotImage(state)
	return PetModule.EquipSlotImages[state] or PetModule.EquipSlotImages.Default
end

--// Rarity helpers
function PetModule.GetRarityIcon(rarityName)
	local rarity = PetModule.GetRarityConfig(rarityName)
	if not rarity then return "" end
	
	return rarity.Icon or ""
end

function PetModule.GetRarityOrder(rarityName)
	local rarity = PetModule.GetRarityConfig(rarityName)
	if not rarity then return 0 end
	
	return rarity.Order or 0
end

--// Pet display data
function PetModule.GetPetDisplayData(petName, pattern, tier, level)
	local petConfig = PetModule.GetPetConfig(petName)
	if not petConfig then return nil end
	
	local rarityConfig = PetModule.GetRarityConfig(petConfig.Rarity)
	local tierConfig = PetModule.GetTierConfig(tier)
	local stats = PetModule.CalculatePetStats(petName, pattern, tier,level)
	
	return {
		Name = petConfig.DisplayName or petConfig.Name,
		Rarity = petConfig.Rarity,
		RarityIcon = rarityConfig and rarityConfig.Icon or "",
		
		Pattern = pattern,
		Tier = tier,
		TierName = tierConfig and tierConfig.Name or "Normal",
		Level = level,
		
		Energy = stats and stats.Energy or 0,
		Money = stats and stats.Money or 0,
		RacePower = stats and stats.RacePower or 0,
		
		Icon = petConfig.Icon,
		ModelName = petConfig.ModelName,
	}
end

return PetModule
