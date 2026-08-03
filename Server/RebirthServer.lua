--// RebirthServer 1.2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RebirthModule = require(
	ReplicatedStorage.Modules.RebirthModule
)

local ShopModule = require(
	ReplicatedStorage.Modules.ShopModule
)

local UpgradeModule = require(
	ReplicatedStorage.Modules.UpgradeModule
)

--// RemoteEvents

local rebirthEvent =
	ReplicatedStorage:WaitForChild("RebirthEvent")

local performRebirthEvent =
	rebirthEvent:WaitForChild("PerformRebirthEvent")

local autoRebirthEvent =
	rebirthEvent:WaitForChild("AutoRebirthEvent")

--// Settings

local AUTO_REBIRTH_INTERVAL = 0.5
local REBIRTH_REQUEST_COOLDOWN = 0.1

--// Runtime state

local autoRebirthPlayers = {}
local lastRebirthRequest = {}

--// Player values

local function getEnergy(player)
	local leaderstats =
		player:FindFirstChild("leaderstats")

	if not leaderstats then
		return nil
	end

	return leaderstats:FindFirstChild("Energy")
end

local function getRebirth(player)
	local leaderstats =
		player:FindFirstChild("leaderstats")

	if not leaderstats then
		return nil
	end

	return leaderstats:FindFirstChild("Rebirth")
end

--// Request cooldown

local function canProcessRebirthRequest(player)
	local currentTime = os.clock()
	local lastRequest =
		lastRebirthRequest[player] or 0

	if currentTime - lastRequest
		< REBIRTH_REQUEST_COOLDOWN then

		return false
	end

	lastRebirthRequest[player] = currentTime
	return true
end

--// Button validation

local function getRebirthButtonNameFromAmount(amount)
	if typeof(amount) ~= "number" then
		return nil
	end

	amount = math.floor(amount)

	for buttonName, buttonAmount
		in pairs(RebirthModule.Buttons) do

		if buttonAmount == amount then
			return buttonName
		end
	end

	return nil
end

local function isRebirthAmountUnlocked(player, amount)
	local buttonName =
		getRebirthButtonNameFromAmount(amount)

	if not buttonName then
		return false
	end

	return UpgradeModule.IsRebirthButtonUnlocked(
		player,
		buttonName
	)
end

--// Main Rebirth function

local function doRebirth(player, amount)
	if typeof(amount) ~= "number" then
		return false
	end

	amount = math.floor(amount)

	if amount <= 0 then
		return false
	end

	local maxPerOperation =
		RebirthModule.MaxRebirthPerOperation
		or 1_000_000

	if amount > maxPerOperation then
		return false
	end

	local energy = getEnergy(player)
	local rebirth = getRebirth(player)

	if not energy or not rebirth then
		return false
	end

	if energy.Value < 0 then
		return false
	end

	if rebirth.Value < 0 then
		return false
	end

	local cost =
		RebirthModule.GetRebirthCost(
			rebirth.Value,
			amount
		)

	if typeof(cost) ~= "number" then
		return false
	end

	if cost <= 0 then
		return false
	end

	if energy.Value < cost then
		return false
	end

	-- В твоей системе после Rebirth
	-- вся энергия полностью сбрасывается.
	energy.Value = 0
	rebirth.Value += amount

	return true
end

--// Max Rebirth

local function performMaxRebirth(player)
	if not ShopModule.HasMaxRebirth(player) then
		return false
	end

	local energy = getEnergy(player)
	local rebirth = getRebirth(player)

	if not energy or not rebirth then
		return false
	end

	local maxAmount =
		RebirthModule.GetMaxRebirthAmount(
			rebirth.Value,
			energy.Value
		)

	if typeof(maxAmount) ~= "number" then
		return false
	end

	maxAmount = math.floor(maxAmount)

	if maxAmount <= 0 then
		return false
	end

	return doRebirth(player, maxAmount)
end

--// Manual Rebirth

performRebirthEvent.OnServerEvent:Connect(
	function(player, amount)

		if not canProcessRebirthRequest(player) then
			return
		end

		-- Max Rebirth
		if amount == "Max" then
			performMaxRebirth(player)
			return
		end

		-- Обычная кнопка должна отправить число.
		if typeof(amount) ~= "number" then
			return
		end

		amount = math.floor(amount)

		-- Проверяем, существует ли такое количество
		-- и разблокирована ли соответствующая кнопка.
		if not isRebirthAmountUnlocked(
			player,
			amount
			) then

			return
		end

		doRebirth(player, amount)
	end
)

--// Auto Rebirth control

autoRebirthEvent.OnServerEvent:Connect(
	function(player, enabled, amount)

		-- Выключение Auto всегда разрешено.
		-- Проверка пасса здесь не нужна.
		if enabled ~= true then
			autoRebirthPlayers[player] = nil
			return
		end

		-- Для включения нужен AutoRebirthPass.
		if not ShopModule.HasAutoRebirth(player) then
			autoRebirthPlayers[player] = nil
			return
		end

		-- Auto Max требует сразу два пасса:
		-- AutoRebirthPass и MaxRebirthPass.
		if amount == "Max" then
			if not ShopModule.HasMaxRebirth(player) then
				autoRebirthPlayers[player] = nil
				return
			end

			autoRebirthPlayers[player] = {
				Mode = "Max",
			}

			return
		end

		-- Обычный Auto Rebirth.
		if typeof(amount) ~= "number" then
			autoRebirthPlayers[player] = nil
			return
		end

		amount = math.floor(amount)

		if amount <= 0 then
			autoRebirthPlayers[player] = nil
			return
		end

		if not isRebirthAmountUnlocked(
			player,
			amount
			) then

			autoRebirthPlayers[player] = nil
			return
		end

		autoRebirthPlayers[player] = {
			Mode = "Fixed",
			Amount = amount,
		}
	end
)

--// Auto Rebirth loop

task.spawn(function()
	while true do
		task.wait(AUTO_REBIRTH_INTERVAL)

		for player, autoData
			in pairs(autoRebirthPlayers) do

			-- Игрок вышел.
			if not player.Parent then
				autoRebirthPlayers[player] = nil
				continue
			end

			-- Если игрок потерял Auto-пасс,
			-- Auto сразу отключается.
			if not ShopModule.HasAutoRebirth(player) then
				autoRebirthPlayers[player] = nil
				continue
			end

			if type(autoData) ~= "table" then
				autoRebirthPlayers[player] = nil
				continue
			end

			--// Auto Max

			if autoData.Mode == "Max" then
				if not ShopModule.HasMaxRebirth(player) then
					autoRebirthPlayers[player] = nil
					continue
				end

				local energy = getEnergy(player)
				local rebirth = getRebirth(player)

				if not energy or not rebirth then
					continue
				end

				local maxAmount =
					RebirthModule.GetMaxRebirthAmount(
						rebirth.Value,
						energy.Value
					)

				if maxAmount > 0 then
					doRebirth(player, maxAmount)
				end

				continue
			end

			--// Auto на выбранном количестве

			if autoData.Mode == "Fixed" then
				local amount = autoData.Amount

				if typeof(amount) ~= "number" then
					autoRebirthPlayers[player] = nil
					continue
				end

				if not isRebirthAmountUnlocked(
					player,
					amount
					) then

					autoRebirthPlayers[player] = nil
					continue
				end

				-- doRebirth сам проверит,
				-- хватает ли энергии.
				doRebirth(player, amount)

				continue
			end

			-- Неизвестный режим.
			autoRebirthPlayers[player] = nil
		end
	end
end)

--// Cleanup

Players.PlayerRemoving:Connect(function(player)
	autoRebirthPlayers[player] = nil
	lastRebirthRequest[player] = nil
end)

print("RebirthServer loaded")
