--// BetaPurchaseTracker

local DataStoreService = game:GetService("DataStoreService")

local BetaPurchaseTracker = {}

local STORE_NAME = "TrainingEvolution_BetaPurchases_v1"
local purchaseStore = DataStoreService:GetDataStore(STORE_NAME)

local BETA_PURCHASE_TRACKING_ACTIVE = true
local BETA_RESTORE_ACTIVE = false

function BetaPurchaseTracker.addPurchase(player, category, itemId, amount)
	if not BETA_PURCHASE_TRACKING_ACTIVE then return false end
	if not player then return false end

	category = tostring(category)
	itemId = tostring(itemId)
	amount = math.floor(tonumber(amount) or 1)

	if amount <= 0 then return false end

	local key = "Player_" .. player.UserId

	local success, err = pcall(function()
		purchaseStore:UpdateAsync(key, function(oldData)
			oldData = oldData or {}

			oldData[category] = oldData[category] or {}
			oldData[category][itemId] = oldData[category][itemId] or 0
			oldData[category][itemId] += amount

			oldData.LastPurchaseTime = os.time()

			return oldData
		end)
	end)

	if success then
		print("BETA PURCHASE SAVED:", player.Name, category, itemId, amount)
		return true
	else
		warn("BETA PURCHASE SAVE FAILED:", player.Name, err)
		return false
	end
end

function BetaPurchaseTracker.getPurchases(player)
	local key = "Player_" .. player.UserId

	local success, data = pcall(function()
		return purchaseStore:GetAsync(key)
	end)

	if success then
		return data or {}
	else
		warn("BETA PURCHASE LOAD FAILED:", player.Name, data)
		return {}
	end
end

local function givePotion(player, potionId, amount)
	local potions = player:FindFirstChild("Potions")
	if not potions then return end

	local potionValue = potions:FindFirstChild(potionId)
	if not potionValue then return end

	potionValue.Value += amount
end

local function givePet(player, petId, amount)
	-- Сюда позже подключим твою систему выдачи донат-петов
	-- Например PetModule.givePet(player, petId, amount)

	print("NEED GIVE PET:", player.Name, petId, amount)
end

local function giveMount(player, mountId, amount)
	-- Сюда позже подключим транспорт

	print("NEED GIVE MOUNT:", player.Name, mountId, amount)
end

function BetaPurchaseTracker.restorePurchases(player)
	if not BETA_RESTORE_ACTIVE then
		return false
	end

	local data = BetaPurchaseTracker.getPurchases(player)

	if data.Potions then
		for potionId, amount in pairs(data.Potions) do
			givePotion(player, potionId, amount)
			print("RESTORED POTION:", player.Name, potionId, amount)
		end
	end

	if data.Pets then
		for petId, amount in pairs(data.Pets) do
			givePet(player, petId, amount)
		end
	end

	if data.Mounts then
		for mountId, amount in pairs(data.Mounts) do
			giveMount(player, mountId, amount)
		end
	end

	return true
end

return BetaPurchaseTracker
