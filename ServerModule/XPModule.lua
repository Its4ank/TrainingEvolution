local XPModule = {}

local function getOrCreateResources(player)
	local resources = player:FindFirstChild("Resources")

	if not resources then
		resources = Instance.new("Folder")
		resources.Name = "Resources"
		resources.Parent = player
	end

	return resources
end

local function getOrCreateXPValue(player)
	local resources = getOrCreateResources(player)
	local xpValue = resources:FindFirstChild("XPModule")

	if not xpValue then
		xpValue = Instance.new("NumberValue")
		xpValue.Name = "XPModule"
		xpValue.Value = 0
		xpValue.Parent = resources
	end

	return xpValue
end

function XPModule.getXP(player)
	return getOrCreateXPValue(player).Value
end

function XPModule.addXP(player, amount)
	amount = tonumber(amount) or 0

	if amount <= 0 then
		return getOrCreateXPValue(player).Value
	end

	local xpValue = getOrCreateXPValue(player)
	xpValue.Value += amount

	return xpValue.Value
end

function XPModule.removeXP(player, amount)
	amount = tonumber(amount) or 0

	if amount <= 0 then
		return false
	end

	local xpValue = getOrCreateXPValue(player)

	if xpValue.Value < amount then
		return false
	end

	xpValue.Value -= amount
	return true
end

function XPModule.hasXP(player, amount)
	amount = tonumber(amount) or 0

	return getOrCreateXPValue(player).Value >= amount
end

function XPModule.setupPlayer(player)
	getOrCreateXPValue(player)
end

return XPModule
