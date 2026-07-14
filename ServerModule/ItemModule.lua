local ItemModule = {}

--Helpers
local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateValue(parent, className, name, default)
	local v = parent:FindFirstChild(name)
	if not v then
		v = Instance.new(className)
		v.Name = name
		v.Value = default
		v.Parent = parent
	end
	return v
end



--Item data helpers
function ItemModule.getShoesFolder(player)
	local itemsFolder = player:FindFirstChild("Items")
	if not itemsFolder then return nil end 

	local earthFolder = itemsFolder:FindFirstChild("Earth")
	if not earthFolder then return nil end

	return earthFolder:FindFirstChild("Shoes")
end



--Tier helpers
local itemTiers = {
	[1] = "Novice",
	[2] = "Advanced",
	[3] = "Expert",
	[4] = "Master",
	[5] = "Legend",
}

function ItemModule.getItemTierName(tier)
	return itemTiers[tier] or "Unknown"
end

local ITEM_BOOST_BY_TIER = {
	[1] = {Acceleration = 1.00, RacePower = 1.00},
	[2] = {Acceleration = 1.05, RacePower = 1.05},
	[3] = {Acceleration = 1.10, RacePower = 1.10},
	[4] = {Acceleration = 1.15, RacePower = 1.15},
	[5] = {Acceleration = 1.20, RacePower = 1.20},
}

function ItemModule.updateShoesBoosts(player)
	local shoes = ItemModule.getShoesFolder(player)
	if not shoes then return end
	
	local tier = shoes:FindFirstChild("ItemTier")
	local accelerationValue = shoes:FindFirstChild("Acceleration")
	local racePowerValue = shoes:FindFirstChild("RacePower")
	
	if not tier or not accelerationValue or not racePowerValue then return end
	
	local boosts = ITEM_BOOST_BY_TIER[tier.Value] or ITEM_BOOST_BY_TIER[1]
	
	accelerationValue.Value = boosts.Acceleration
	racePowerValue.Value = boosts.RacePower
end



--Multiplier logic
function ItemModule.getShoesMultiplier(player)
	local shoes = ItemModule.getShoesFolder(player)
	if not shoes then
		return 1
	end

	local owned = shoes:FindFirstChild("Owned")
	local level = shoes:FindFirstChild("Level")
	local evolution = shoes:FindFirstChild("Evolution")
	local tier = shoes:FindFirstChild("ItemTier")

	if not owned or not owned.Value then
		return 1
	end
	
	local t = tier and tier.Value or 1
	local lvl = level and level.Value or 0
	local evo = evolution and evolution.Value or 1
	
	local tierBonus = (t - 1) * 0.25
	local levelBonus = lvl * 0.05 * t
	local evolutionBonus = (evo - 1) * 0.15 * t
	
	local totalMultiplier = 1 + tierBonus + levelBonus + evolutionBonus

	return totalMultiplier
end



--Setup/creation
function ItemModule.setupItems(player)
	local itemsFolder = getOrCreateFolder(player, "Items")
	local earthFolder = getOrCreateFolder(itemsFolder, "Earth")

	local shoes = getOrCreateFolder(earthFolder, "Shoes")

	getOrCreateValue(shoes, "BoolValue", "Owned", false)
	getOrCreateValue(shoes, "BoolValue", "Equipped", false)
	getOrCreateValue(shoes, "IntValue", "Level", 0)
	getOrCreateValue(shoes, "IntValue", "Evolution", 0)
	getOrCreateValue(shoes, "IntValue", "ItemTier", 1)
	getOrCreateValue(shoes, "NumberValue", "Acceleteration", 1)
	getOrCreateValue(shoes, "NumberValue", "RacePower", 1)
	
	ItemModule.updateShoesBoosts(player)
end

return ItemModule
