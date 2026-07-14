local XPModule = {}

local function getOrCreateResourse(player)
	local resources = player:FindFirstChild("Resources")
	if not resources then
		resources = Instance.new("Folder")
		resources.Name = "Resources"
		resources.Parent = player
	end
	return resources
end

local function getOrCreateXPModule(player)
	local resources = getOrCreateResourse(player)
	
	local xpModule = resources:FindFirstChild("XPModule")
	if not xpModule then
		xpModule = Instance.new("IntValue")
		xpModule.Name = "XPModule"
		xpModule.Value = 0
		xpModule.Parent = resources
	end
	return xpModule
end	

function XPModule.getXP(player)
	return getOrCreateXPModule(player).Value
end

function XPModule.addXP(player, amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return 0 end
	
	local xpModule = getOrCreateXPModule(player)
	xpModule.Value += amount
	
	return xpModule.Value
end

function XPModule.removeXP(player, amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end
	
	local xpModule = getOrCreateXPModule(player)
	if xpModule.Value < amount then
		return false
	end
	
	xpModule.Value -= amount
	return true
end

function XPModule.hasXP(player, amount)
	amount = math.floor(tonumber(amount) or 0)
	return getOrCreateXPModule(player).Value >= amount
end

function XPModule.setupPlayer(player)
	getOrCreateXPModule(player)
end

return XPModule
