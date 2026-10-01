--// EggUI v1.3

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// Modules
local EggModule = require(ReplicatedStorage.Modules.EggModule)
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local FormatModule = require(ReplicatedStorage.Modules.FormatModule)

--// Root
local raceGui = script.Parent
local guiFolder = raceGui:WaitForChild("GuiFolder")

local eggFolder = guiFolder:WaitForChild("EggFolder")
local eggHost = eggFolder:WaitForChild("EggHost")
local eggAutoDelMenu = eggFolder:WaitForChild("EggAutoDelMenu")

local hatchHostSingle = eggFolder:WaitForChild("EggHatchHost")
local hatchHostDuo = eggFolder:WaitForChild("EggHatchHostDuo")
local hatchHostTrio = eggFolder:WaitForChild("EggHatchHostTrio")

local eggWarning = eggFolder:WaitForChild("EggWarning")

--// Remotes
local eggEvent = ReplicatedStorage:WaitForChild("EggEvent")

local hatchRequestFunction = eggEvent:WaitForChild("HatchRequestFunction")
local eggStateFunction = eggEvent:WaitForChild("EggStateFunction")
local specificAutoDeleteEvent = eggEvent:WaitForChild("SpecificAutoDeleteEvent")
local globalAutoDeleteEvent = eggEvent:WaitForChild("GlobalAutoDeleteEvent")
local eggDataChangedEvent = eggEvent:WaitForChild("EggDataChangedEvent")
local eggWarningEvent = eggEvent:WaitForChild("EggWarningEvent")

--// Current egg
local currentEggName = "Egg1"
local currentState = nil

local uiBusy = false
local autoHatching = false
local autoStopRequested = false

local currentHatchHost = nil
local currentResults = nil

local hatchState = "Idle"
local currentTapStage = 0

local warningToken = 0

--// Animation settings
local SHAKE_TIME = 0.10
local STAGE_PAUSE = 0.05

local FRAGMENT_TIME = 0.65
local FRAGMENT2_GROW_TIME = 0.50

local FLASH_IN_TIME = 0.12
local FLASH_OUT_TIME = 0.35

local AUTO_STAGE_PAUSE = 0.10

local AUTO_RESULT_TIME = (EggModule.AutoHatch and EggModule.AutoHatch.ResultDisplayTime) or 2

--// Helpers
local function showWarning(message, duration)
	if not message or message == "" then return end 

	warningToken += 1

	local token = warningToken

	eggWarning.Text = tostring(message)
	eggWarning.Visible = true

	task.delay(duration or 2.5, function()
		if warningToken ~= token then return end 

		eggWarning.Visible = false
	end)
end

local function getErrorMessage(errorCode)
	local messages = {
		DataNotReady = "Player data is still loading.",
		HatchBusy = "Please wait for the current egg opening.",
		UnknownEgg = "Egg not found.",
		InvalidEgg = "Egg not found.",
		StorageFull = "Pet inventory is full!",
		NotEnoughMoney = "Not enough Money!",
		MoneyNotFound = "Money data not found.",
		EggOpenedNotFound = "Egg data not found.",
		EggDataMissing = "Egg data is not ready.",
		PetRollFailed = "Could not open egg.",
		PetCreateFailed = "Could not create pet.",
		ServerError = "Egg server error.",
	}

	return messages[errorCode] or tostring(errorCode or "Unknown error.")
end

local function setImage(object, image)
	if not object then return end 
	if not image or image == "" then return end 

	if object:IsA("ImageLabel") or object:IsA("ImageButton") then
		object.Image = image
	end
end

--// Viewport helpers
local function clearViewport(viewport)
	if not viewport then return end 

	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("Camera") or child:IsA("WorldModel") or child:IsA("Model") or child:IsA("BasePart") then
			child:Destroy()
		end
	end
end

local function findPetModel(petName)
	local petConfig = PetModule.GetPetConfig(petName)
	if not petConfig then return nil end

	local modelName = petConfig.ModelName or petName
	local previewModels = ReplicatedStorage:FindFirstChild("PetPreviewModels")
	if not previewModels then return nil end

	--// First try Earth/Egg1
	local earth = previewModels:FindFirstChild("Earth")
	if earth then
		local egg1 = earth:FindFirstChild("Egg1")

		if egg1 then
			local model = egg1:FindFirstChild(modelName)

			if model then return model end
		end
	end

	-- Fallback search
	return previewModels:FindFirstChild(modelName, true)
end

local function setupViewport(viewport, petName)
	if not viewport or not viewport:IsA("ViewportFrame") then return end 

	clearViewport(viewport)

	local template = findPetModel(petName)
	if not template then return end 

	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "PetWorld"
	worldModel.Parent = viewport

	local clone = template:Clone()
	clone.Parent = worldModel

	for _, object in ipairs(clone:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Anchored = true
			object.CanCollide = false
		end
	end

	local camera = Instance.new("Camera")
	camera.Name = "PetCamera"
	camera.Parent = viewport 

	viewport.CurrentCamera = camera

	local success, boundingCFrame, boundingSize = pcall(function()
		return clone:GetBoundingBox()
	end)

	if not success then return end 

	clone:PivotTo(CFrame.new(-boundingCFrame.Position) * boundingCFrame.Rotation)

	local maxSize = math.max(boundingSize.X, boundingSize.Y, boundingSize.Z)

	if maxSize <= 0 then maxSize = 5 end 

	local distance = maxSize * 2.1

	camera.CFrame = CFrame.new(Vector3.new(0, boundingSize.Y * 0.05, distance), Vector3.new(0, 0, 0))
end

--// EggHost object
local buy1Button = eggHost:WaitForChild("EggBuy1")
local buy3Button = eggHost:WaitForChild("EggBuy3")
local buyAutoButton = eggHost:WaitForChild("EggBuyAuto")
local buy1Price = buy1Button:WaitForChild("EggBuyPrice")
local buy3Price = buy3Button:WaitForChild("EggBuyPrice")
local buyAutoPrice = buyAutoButton:WaitForChild("EggBuyPrice")
local buy1Kay = eggHost:WaitForChild("EggBuy1Kay")
local buy3Kay = eggHost:WaitForChild("EggBuy3Kay")
local buyAutoKay = eggHost:WaitForChild("EggBuyAutoKay")
local luckBarWindow = eggHost:WaitForChild("EggLuckBarWindow")
local luckBar = luckBarWindow:WaitForChild("EggLuckBar")
local luckLabel = eggHost:WaitForChild("EggLuckBarLabel")
local luckInfoButton = eggHost:WaitForChild("EggLuckInfoButton")
local hatch3Label = eggHost:WaitForChild("EggHatch3Label")
local hatch3Number = eggHost:WaitForChild("EggHatch3Number")
local autoNumberLabel = eggHost:WaitForChild("EggAutoNumberLabel")
local autoNumber = eggHost:WaitForChild("EggAutoNumber")

--// Pet buttons
local petButtonConnections = {}

local function clearPetButtonConnections()
	for _, connection in ipairs(petButtonConnections) do
		connection:Disconnect()
	end

	table.clear(petButtonConnections)
end

local function updateEggPetButtons(state)
	clearPetButtonConnections()

	for _, petData in ipairs(state.Pets or {}) do
		local button = eggHost:FindFirstChild(petData.ButtonName)

		if button then
			local viewport = button:FindFirstChild("EggPetViewModel")
			local nameLabel = button:FindFirstChild("EggPetName")
			local percentLabel = button:FindFirstChild("EggPetPercent")

			if nameLabel then
				nameLabel.Text = petData.DisplayName or petData.PetName 
			end

			if percentLabel then
				percentLabel.Text = FormatModule.FormatPercent(petData.Chance)
			end

			setupViewport(viewport, petData.PetName)

			local imageState = petData.SpecificAutoDelete and "Selected" or "Default"
			local image = EggModule.GetAutoDeleteImage(imageState)

			setImage(button, image)

			if button:IsA("GuiButton") then
				local connection = button.Activated:Connect(function()
					if uiBusy then return end 

					specificAutoDeleteEvent:FireServer(currentEggName, petData.PetName)
				end)

				table.insert(petButtonConnections, connection)
			end
		end
	end
end

--// Global Auto Delete
local rarityButtons = {
	Common = eggAutoDelMenu:WaitForChild("EggAutoDelCommon"),
	Uncommon = eggAutoDelMenu:WaitForChild("EggAutoDelUncommon"),
	Rare = eggAutoDelMenu:WaitForChild("EggAutoDelRare"),
	Epic = eggAutoDelMenu:WaitForChild("EggAutoDelEpic"),
	Legendary = eggAutoDelMenu:WaitForChild("EggAutoDelLegendary"),
}

local function updateGlobalAutoDelete(state)
	for rarityName, button in pairs(rarityButtons) do
		local enabled = state.GlobalAutoDelete and state.GlobalAutoDelete[rarityName] == true
		local icon = button:FindFirstChild("AutoDelIcon")

		setImage(icon, EggModule.GetAutoDeleteImage(enabled and "Selected" or "Default"))
	end
end

for rarityName, button in pairs(rarityButtons) do

	if button:IsA("GuiButton") then
		button.Activated:Connect(function()
			if uiBusy then return end 

			globalAutoDeleteEvent:FireServer(rarityName)
		end)
	end
end

--// State refresh
local function refreshEggUI()
	if not eggHost.Visible then return end 

	local success, state = pcall(function()
		return eggStateFunction:InvokeServer(currentEggName)
	end)

	if not success or not state then return end 

	currentState = state 

	-- Current x1 price
	buy1Price.Text = FormatModule.FormatNumber(state.CurrentPrice or 0)

	-- Current possible batch
	local availableAmount = state.AvailableAmount or 0

	hatch3Number.Text = "x" .. tostring(availableAmount)
	autoNumber.Text = "x" .. tostring(availableAmount)
	hatch3Label.Text = availableAmount > 0 and "OPEN " .. tostring(availableAmount) or "OPEN"
	autoNumberLabel.Text = availableAmount > 0 and "OPEN " .. tostring(availableAmount) or "OPEN"

	-- Exact sequential price
	if availableAmount > 0 then
		buy3Price.Text = FormatModule.FormatNumber(state.BatchPrice or 0)
		buyAutoPrice.Text = FormatModule.FormatNumber(state.BatchPrice or 0)
	else
		buy3Price.Text = FormatModule.FormatNumber(state.CurrentPrice or 0)
		buyAutoPrice.Text = FormatModule.FormatNumber(state.CurrentPrice or 0)
	end

	-- Luck
	luckBar.Position = EggModule.GetLuckBarPosition(state.LuckOpenings or 0)
	luckLabel.Text = EggModule.GetLuckLabel(state.LuckOpenings or 0)

	updateEggPetButtons(state)
	updateGlobalAutoDelete(state)
end

--// Hatch host helpers
local function getHostForAmount(amount)
	if amount >= 3 then
		return hatchHostTrio
	elseif amount == 2 then
		return hatchHostDuo
	end

	return hatchHostSingle
end

local function getEggObjects(host, index)
	local eggObject = host:FindFirstChild("Egg" .. tostring(index))
	if not eggObject then return nil end 

	local dub = eggObject:FindFirstChild("EggDub" .. tostring(index))
	if not dub then return nil end 

	local fragments = {}

	for fragmentIndex = 1, 6 do
		fragments[fragmentIndex] = dub:FindFirstChild("Fragment" .. tostring(fragmentIndex))
	end

	return {
		Egg = eggObject,
		Dub = dub,
		Fragments = fragments,

		Viewport = host:FindFirstChild("EggHatchModel" .. tostring(index)),
		RarityIcon = host:FindFirstChild("PetRarityIcon" .. tostring(index)),
		RarityLabel = host:FindFirstChild("PetRarityLabel" .. tostring(index)),
		PetName = host:FindFirstChild("EggPetName" .. tostring(index)),
		AutoDeleteIcon = host:FindFirstChild("HatchAutoDelIcon" .. tostring(index)),
		AutoDeleteLabel = host:FindFirstChild("HatchAutoDelLabel" .. tostring(index)),
	}
end

local function getHostEggs(host, amount)
	local result = {}

	for index = 1, amount do 
		local objects = getEggObjects(host, index)
		if objects then
			table.insert(result, objects)
		end
	end

	return result
end

--// Original fragment values
local fragmentOriginals = {}

local function saveFragmentOriginals(objects)
	if fragmentOriginals[objects.Dub] then return end 

	local data = {}

	for index, fragment in ipairs(objects.Fragments) do

		if fragment then
			data[index] = {
				Position = fragment.Position,
				Size = fragment.Size,
				Rotation = fragment.Rotation,
				Visible = fragment.Visible,
			}
		end
	end

	fragmentOriginals[objects.Dub] = data
end 

local function resetFragments(objects)
	saveFragmentOriginals(objects)
	local originals = fragmentOriginals[objects.Dub]

	for index, fragment in ipairs(objects.Fragments) do
		local original = originals[index]

		if fragment and original then
			fragment.Position = original.Position
			fragment.Size = original.Size 
			fragment.Rotation = original.Rotation 
			fragment.Visible = true
		end
	end
end

--// Reset hatch host
local function resetHatchHost(host, amount)
	local eggFrame = host:FindFirstChild("EggFrame")

	if eggFrame then
		eggFrame.Visible = true

		if eggFrame:IsA("ImageLabel") or eggFrame:IsA("ImageButton") then
			eggFrame.ImageTransparency = 1
		elseif eggFrame:IsA("Frame") then 
			eggFrame.BackgroundTransparency = 1 
		end
	end

	local eggs = getHostEggs(host, amount)

	for index, objects in ipairs(eggs) do
		resetFragments(objects)

		objects.Egg.Visible = true 
		objects.Dub.Visible = false

		objects.Egg.Rotation = 0

		setImage(objects.Egg, EggModule.GetAnimationImage(currentEggName, "Stage1"))

		if objects.Viewport then 
			clearViewport(objects.Viewport)
			objects.Viewport.Visible = false 
		end

		if objects.RarityIcon then
			objects.RarityIcon.Visible = false 
		end 

		if objects.RarityLabel then 
			objects.RarityLabel.Visible = false 
			objects.RarityLabel.Text = ""
		end

		if objects.PetName then
			objects.PetName.Visible = false 
			objects.PetName.Text = ""
		end 

		if objects.AutoDeleteIcon then
			objects.AutoDeleteIcon.Visible = false 
		end 

		if objects.AutoDeleteLabel then
			objects.AutoDeleteLabel.Visible = false 
			objects.AutoDeleteLabel.Text = ""
		end 
	end 

	local stopButton = host:FindFirstChild("AutoOpenButton")

	if stopButton then
		setImage(stopButton, EggModule.GetAutoStopImage(autoHatching and "Selected" or "Default"))
	end
end

--// Egg shake
local function tweenRotation(object, rotation, duration)
	local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = rotation,})

	tween:Play()

	return tween
end

local function shakeEgg(object, rotation)
	if not object then return end 

	local first = tweenRotation(object, rotation, SHAKE_TIME)
	first.Completed:Wait()

	local second = tweenRotation(object, 0, SHAKE_TIME)
	second.Completed:Wait()
end

local function playStage(eggObjects, stage)
	local stageName = "Stage" .. tostring(stage)
	local image = EggModule.GetAnimationImage(currentEggName, stageName)

	for _, objects in ipairs(eggObjects) do
		setImage(objects.Egg, image)
	end

	local rotation

	if stage == 1 then
		rotation = 15
	elseif stage == 2 then
		rotation = -15
	elseif stage == 3 then 
		rotation = 15
	else 
		rotation = -20
	end 

	local finished = 0

	for _, objects in ipairs(eggObjects) do
		task.spawn(function()
			shakeEgg(objects.Egg, rotation)
			finished += 1
		end)
	end

	while finished < #eggObjects do
		task.wait()
	end 

	task.wait(STAGE_PAUSE)
end

--// Fragment animation
local fragmentTargets = {
	[1] = UDim2.new(0.478, 0, 1.5, 0),
	[3] = UDim2.new(3, 0, 0.816, 0),
	[4] = UDim2.new(-2, 0, 0.599, 0),
	[5] = UDim2.new(1.6, 0, -0.3, 0),
	[6] = UDim2.new(-0.3, 0, -0.4, 0),
}

local function shakeFragment2(fragment, tokenTable)
	if not fragment then return end 

	local baseRotation = fragment.Rotation

	task.spawn(function()
		local direction = 1 

		while tokenTable.Running do 
			fragment.Rotation = baseRotation + (direction * 5)
			direction *= -1

			task.wait(0.035)
		end

		fragment.Rotation = baseRotation
	end)
end

local function revealPet(objects, result)
	if not objects or not result then return end 

	if objects.Viewport then 
		setupViewport(objects.Viewport, result.PetName)

		objects.Viewport.Visible = true 
	end 

	if objects.PetName then 
		objects.PetName.Text = result.DisplayName or result.PetName
		objects.PetName.Visible = true 
	end

	if objects.RarityLabel then 
		objects.RarityLabel.Text = result.Rarity or ""
		objects.RarityLabel.Visible = true 
	end

	if objects.RarityIcon then 
		local rarityIcon = PetModule.GetRarityIcon(result.Rarity)
		setImage(objects.RarityIcon, rarityIcon)
		objects.RarityIcon.Visible = true 
	end 

	if result.AutoDeleted then
		if objects.AutoDeleteIcon then
			objects.AutoDeleteIcon.Visible = true 
		end 

		if objects.AutoDeleteLabel then
			objects.AutoDeleteLabel.Text = "Auto Delete " .. (result.DisplayName or result.PetName)
			objects.AutoDeleteLabel.Visible = true 
		end
	else 
		if objects.AutoDeleteIcon then 
			objects.AutoDeleteIcon.Visible = false 
		end 

		if objects.AutoDeleteLabel then 
			objects.AutoDeleteLabel.Visible = false 
		end 
	end 
end 

local function flashEggFrame(host)
	local eggFrame = host:FindFirstChild("EggFrame")
	if not eggFrame then return end 

	eggFrame.Visible = true 

	local transparencyProperty

	if eggFrame:IsA("ImageLabel") or eggFrame:IsA("ImageButton") then 
		transparencyProperty = "ImageTransparency"
	else 
		transparencyProperty = "BackgroundTransparency"
	end 

	eggFrame[transparencyProperty] = 1

	local flashIn = TweenService:Create(eggFrame, TweenInfo.new(FLASH_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[transparencyProperty] = 0,})

	flashIn:Play()
	flashIn.Completed:Wait()

	local flashOut = TweenService:Create(eggFrame, TweenInfo.new(FLASH_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[transparencyProperty] = 1,})

	flashOut:Play()
	flashOut.Completed:Wait()
end 

local function breakOneEgg(host, objects, result)
	objects.Egg.Visible = false 
	objects.Dub.Visible = true 

	resetFragments(objects)

	local fragment2 = objects.Fragments[2]
	local shakeToken = {Running = true,}

	shakeFragment2(fragment2, shakeToken)

	-- Other fragments fly away
	for index, target in pairs(fragmentTargets) do
		local fragment = objects.Fragments[index]

		if fragment then 
			local tween = TweenService:Create(fragment, TweenInfo.new(FRAGMENT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target,})
			tween:Play()
		end 
	end 

	-- Start Fragment2 at ~70%
	task.wait(FRAGMENT_TIME * 0.70)

	if fragment2 then 
		local growTween = TweenService:Create(fragment2, TweenInfo.new(FRAGMENT2_GROW_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(6.409, 0, 5.492, 0),})
		growTween:Play()

		-- At ~70% growth:
		task.wait(FRAGMENT2_GROW_TIME * 0.70)
		revealPet(objects, result)
		task.spawn(function()
			flashEggFrame(host)
		end)

		task.wait(FRAGMENT2_GROW_TIME * 0.30)
	end 

	shakeToken.Running = false 

	objects.Dub.Visible = false 
end

local function playFinalBreak(host, eggObjects, results)
	hatchState = "FinalBreak"

	local completed = 0

	for index, objects in ipairs(eggObjects) do
		task.spawn(function()
			breakOneEgg(host, objects, results[index])
			completed += 1
		end)
	end

	while completed < #eggObjects do
		task.wait()
	end

	hatchState = "ShowingResult"
end

--// Close hatch
local function closeHatch()
	if currentHatchHost then
		currentHatchHost.Visible = false 
	end 

	currentHatchHost = nil
	currentResults = nil 

	currentTapStage = 0

	hatchState = "Idle"
	uiBusy = false 

	eggHost.Visible = true 

	refreshEggUI()
end

--// Manual hatch
local function beginManualHatch(response)
	local amount = response.Amount or 1
	local host = getHostForAmount(amount)

	currentHatchHost = host 
	currentResults = response.Results 

	currentTapStage = 0
	hatchState = "WaitingForTap"

	autoHatching = false 
	autoStopRequested = false 

	eggHost.Visible = false 

	hatchHostSingle.Visible = false 
	hatchHostDuo.Visible = false 
	hatchHostTrio.Visible = false 

	resetHatchHost(host, amount)

	host.Visible = true 
end

local function handleManualTap()
	if not currentHatchHost or not currentResults then return end 

	if hatchState == "ShowingResult" then 
		closeHatch()
		return 
	end 

	if hatchState ~= "WaitingForTap" then return end 
	hatchState = "AnimatingStages"

	currentTapStage += 1

	local stage = math.clamp(currentTapStage, 1, 4)
	local eggObjects = getHostEggs(currentHatchHost, #currentResults)

	task.spawn(function()
		playStage(eggObjects, stage)

		if currentTapStage >= 4 then
			playFinalBreak(currentHatchHost, eggObjects, currentResults)
		else 
			-- Prepare next image
			local nextStage = currentTapStage + 1
			local nextImage = EggModule.GetAnimationImage(currentEggName, "Stage" .. tostring(nextStage))

			for _, objects in ipairs(eggObjects) do
				setImage(objects.Egg, nextImage)
			end

			hatchState = "WaitingForTap"
		end
	end)
end

local function playAutoBatch(response)
	local amount = response.Amount or 1
	local host = getHostForAmount(amount)

	currentHatchHost = host 
	currentResults = response.Results 

	hatchHostSingle.Visible = false 
	hatchHostDuo.Visible = false 
	hatchHostTrio.Visible = false 

	resetHatchHost(host, amount)

	host.Visible = true 

	local eggObjects = getHostEggs(host, amount)
	hatchState = "AnimatingStages"

	for stage = 1, 4 do
		playStage(eggObjects, stage)

		task.wait(AUTO_STAGE_PAUSE)
	end

	playFinalBreak(host, eggObjects, response.Results)

	task.wait(AUTO_RESULT_TIME)
end

local function runAutoHatch()
	if autoHatching then return end

	autoHatching = true
	autoStopRequested = false
	uiBusy = true

	eggHost.Visible = false

	task.spawn(function()
		while autoHatching and not autoStopRequested do
			local success, response = pcall(function()
				return hatchRequestFunction:InvokeServer(currentEggName, EggModule.MAX_MULTI_HATCH)
			end)

			if not success then
				showWarning("Egg server error.")
				break
			end

			if not response or response.Success ~= true then
				local errorCode = response and response.Error or "ServerError"
				showWarning(getErrorMessage(errorCode))
				break
			end

			-- Current paid batch always finishes
			playAutoBatch(response)

			-- Stop was clicked during animation
			if autoStopRequested then
				break
			end
		end

		autoHatching = false
		autoStopRequested = false

		if currentHatchHost then
			local stopButton = currentHatchHost:FindFirstChild("AutoOpenButton")

			if stopButton then
				setImage(stopButton, EggModule.GetAutoStopImage("Default"))
			end
		end
		closeHatch()
	end)
end

--// Request hatch
local function requestManualHatch(requestedAmount)
	if uiBusy or autoHatching then return end 

	uiBusy = true 

	local success, response = pcall(function()
		return hatchRequestFunction:InvokeServer(currentEggName, requestedAmount)
	end)

	if not success then 
		uiBusy = false 
		showWarning("Egg server error.")
		return
	end

	if not response or response.Success ~= true then 
		uiBusy = false 

		showWarning(getErrorMessage(response and response.Error or "ServerError"))

		refreshEggUI()
		return
	end 

	beginManualHatch(response)
end

local function requestBuy1()
	requestManualHatch(1)
end

local function requestBuy3()
	if uiBusy then return end 

	if currentState and currentState.HasTripleHatch ~= true then 
		showWarning("Triple hatch gamepass required!")
		return 
	end 

	requestManualHatch(EggModule.MAX_MULTI_HATCH)
end

local function requestAuto()
	if uiBusy or autoHatching then return end 

	if currentState and currentState.HasAutoHatch ~= true then 
		showWarning("Auto Hatch gamepass required!")
		return 
	end

	runAutoHatch()
end

--// Buy buttons
buy1Button.Activated:Connect(requestBuy1)
buy3Button.Activated:Connect(requestBuy3)
buyAutoButton.Activated:Connect(requestAuto)

--// HatchHost clicks
hatchHostSingle.Activated:Connect(function()
	if not autoHatching then handleManualTap() end
end)

hatchHostDuo.Activated:Connect(function()
	if not autoHatching then handleManualTap() end
end)

hatchHostTrio.Activated:Connect(function()
	if not autoHatching then handleManualTap() end
end)

--// Auto stop buttons
local function setupAutoStopButton(host)
	local button = host:FindFirstChild("AutoOpenButton")
	if not button or not button:IsA("GuiButton") then return end 

	button.Activated:Connect(function()
		if not autoHatching then return end

		autoStopRequested = true
		autoHatching = false 

		setImage(button, EggModule.GetAutoStopImage("Default"))
	end)
end

setupAutoStopButton(hatchHostSingle)
setupAutoStopButton(hatchHostDuo)
setupAutoStopButton(hatchHostTrio)

--// Luck info
luckInfoButton.Activated:Connect(function()
	showWarning("Each egg opening increases Luck by 1%, up to a maximum of x2. Luck resets if you stay offline for more than 10 minutes.", 5)
end)

--// Keyboard
UserInputService.InputBegan:Connect(function(Input, gameProcessed)
	if gameProcessed then return end 

	if UserInputService:GetFocusedTextBox() then return end 

	-- Hatch animation tasked tap/click,
	-- not E/R/T
	if not eggHost.Visible then return end 

	if 	Input.KeyCode == Enum.KeyCode.E then 
		requestBuy1()
	elseif Input.KeyCode == Enum.KeyCode.R then
		requestBuy3()
	elseif Input.KeyCode == Enum.KeyCode.T then 
		requestAuto()
	end
end)

--// Server updates
eggDataChangedEvent.OnClientEvent:Connect(function(eggName)
	if eggName and eggName ~= currentEggName then return end 
	task.defer(refreshEggUI)
end)

eggWarningEvent.OnClientEvent:Connect(function(message)
	showWarning(message)
end)

--// Live resource updates
local moneyConnection = nil 
local storageConnections = {}

local function disconnectDataConnections()
	if moneyConnection then
		moneyConnection:Disconnect()
		moneyConnection = nil 
	end

	for _, connection in ipairs(storageConnections) do
		connection:Disconnect()
	end

	table.clear(storageConnections)
end

local function connectDataSignals()
	disconnectDataConnections()

	local playerData = player:FindFirstChild("PlayerData")
	if playerData then 
		local money = playerData:FindFirstChild("Money")

		if money then
			moneyConnection = money.Changed:Connect(function()
				if eggHost.Visible and not uiBusy then
					refreshEggUI()
				end
			end)
		end

		local maxStorage = playerData:FindFirstChild("MaxPetStorage")
		if maxStorage then
			table.insert(storageConnections, maxStorage.Changed:Connect(function()
				if eggHost.Visible and not uiBusy then
					refreshEggUI()
				end
			end))
		end
	end 

	local petsFolder = player:FindFirstChild("Pets")

	if petsFolder then
		table.insert(storageConnections, petsFolder.ChildAdded:Connect(function()
			if eggHost.Visible and not uiBusy then 
				refreshEggUI()
			end
		end))

		table.insert(storageConnections, petsFolder.ChildRemoved:Connect(function()
			if eggHost.Visible and not uiBusy then 
				refreshEggUI()
			end
		end))
	end
end

--// EggHost visibility 
eggHost:GetPropertyChangedSignal("Visible"):Connect(function()
	if eggHost.Visible and hatchState == "Idle" then
		task.defer(refreshEggUI)
	end
end)

--// Initial setup
hatchHostSingle.Visible = false 
hatchHostDuo.Visible = false 
hatchHostTrio.Visible = false 

eggWarning.Visible = false 

connectDataSignals()

task.spawn(function()
	while player:GetAttribute("DataReady") ~= true do 
		task.wait(0.1)
	end

	connectDataSignals()

	if eggHost.Visible then
		refreshEggUI()
	end
end)

print("EggUI 1.3 loaded")
