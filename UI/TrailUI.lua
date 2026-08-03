--// TrailUI 1.2v

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local raceGui = script.Parent

--// MONULES
local TrailModule = require(ReplicatedStorage.Modules.TrailModule)
local MenuManager = require(ReplicatedStorage.Modules.MenuManager)

--// REMOTES
local trailEventFolder = ReplicatedStorage:WaitForChild("TrailEvent")
local trailRequestFunction = trailEventFolder:WaitForChild("TrailRequestFunction")

--// GUI
local guiFolder = raceGui:WaitForChild("GuiFolder")
local trailFolder = guiFolder:WaitForChild("TrailsFolder")
local trailHost = trailFolder:WaitForChild("TrailHost")
local trailMenu = trailHost:WaitForChild("TrailMenu")
local trailStage = trailHost:WaitForChild("TrailStage")
local trailStageBlur = trailHost:WaitForChild("TraStageBlur")
local warningLabel = trailHost:WaitForChild("TraWarningLabel")

--// LEADERSTATS
local trailLeaderstats = trailHost:WaitForChild("TrailLeaderstats")

local moneyLead = trailLeaderstats:WaitForChild("MoneyLead")
local rebirthLead = trailLeaderstats:WaitForChild("RebirthLead")
local srRobuxLead = trailLeaderstats:WaitForChild("SrRobuxLead")

--// MAIN MENU
local trailStats = trailMenu:WaitForChild("TrailStats")
local trailPreviewFrame = trailMenu:WaitForChild("TrailPreviewFrame")
local trailChoiceButton = trailMenu:WaitForChild("TrailChoiceButton")
local trailListBackButton = trailMenu:WaitForChild("TraListBackButton")
local trailListNextButton = trailMenu:WaitForChild("TraListNextButton")
local trailClose = trailMenu:WaitForChild("TrailClose")

--// TRAIL STATS
local trailNameLabel = trailStats:WaitForChild("TraStatTrailName")
local stageIcon = trailStats:WaitForChild("TraStatStageIcon")
local stageNameLabel = trailStats:WaitForChild("TraStatStageName")
local powerBoostLabel = trailStats:WaitForChild("TraStatPowerBoost")
local accelerationBoostLabel = trailStats:WaitForChild("TraStatAccBoost")
local levelLabel = trailStats:WaitForChild("TraStatLevel")
local trailXPBar = trailStats:WaitForChild("TraStatXpBar")
local xpLabel = trailStats:WaitForChild("TraStatXpLabel")
local equipButton = trailStats:WaitForChild("TraStatEquipInfo")
local infoLabel = trailStats:WaitForChild("TraStatInfo")
local buyUpgradeButton = trailStats:WaitForChild("TraStatUpgLvl")
local buyUpgradeLabel = buyUpgradeButton:WaitForChild("TraStatBuy/Upg")
local upgradePriceLabel = buyUpgradeButton:WaitForChild("TraStatUpgPrice")
local stageOpenButton = trailStats:WaitForChild("TraStatStageOpen")

--// STAGE
local stageCurrentIcon = trailStage:WaitForChild("TraStageCurIcon")
local stageNextIcon = trailStage:WaitForChild("TraStageNextIcon")
local stageCurrentBoost = trailStage:WaitForChild("TraStageCurBoost")
local stageNextBoost = trailStage:WaitForChild("TraStageNextBoost")

local stageBar1 = trailStage:WaitForChild("TraStageBar1")
local stageBar2 = trailStage:WaitForChild("TraStageBar2")
local stageBar3 = trailStage:WaitForChild("TraStageBar3")

local stageRequirement1 = trailStage:WaitForChild("TraStageRequir1")
local stageRequirement2 = trailStage:WaitForChild("TraStageRequir2")
local stageRequirement3 = trailStage:WaitForChild("TraStageRequir3")

local stageCloseButton = trailStage:WaitForChild("TraStageClose")
local stageUpButton = trailStage:WaitForChild("TraStageUpButton")

--// STATE
local selectedTrail = TrailModule.DEFAULT_TRAIL_ID

local allTrailData = {}
local orderedTrailIds = {}

local selectedTrailIndex = 1

local requestBusy = false
local warningToken = 0

local TRAIL_XP_BAR_FULL_SIZE = UDim2.new(0.247, 0, 0.03, 0)

local STAGE_BAR_1_FULL_SIZE = UDim2.new(0.211, 0, 0.024, 0)
local STAGE_BAR_2_FULL_SIZE = UDim2.new(0.215, 0, 0.024, 0)
local STAGE_BAR_3_FULL_SIZE = UDim2.new(0.235, 0, 0.024, 0)

local PREVIEW_RUN_ANIMATION_ID = "rbxassetid://913376220"

local PREVIEW_STAGE_STYLES = {
	[1] = {
		Colors = {
			[1] = Color3.fromRGB(180, 180, 180),
			[2] = Color3.fromRGB(180, 180, 180),
			[3] = Color3.fromRGB(180, 180, 180),
			[4] = Color3.fromRGB(180, 180, 180),
			[5] = Color3.fromRGB(180, 180, 180),
			[6] = Color3.fromRGB(180, 180, 180),
		},

		Material = Enum.Material.SmoothPlastic,
		TransparencyStart = 0.55,
		TransparencyEnd = 1,

		Length = 5,
		SegmentCount = 10,

		WidthStart = 0.16,
		WidthEnd = 0.025,

		WaveX = 0.12,
		WaveY = 0.08,
		WaveSpeed = 5,
		
		SempleRate = 0.025,
		TrailDealy = 1,
		BackWardSpeed = 10,
		
		ZigzagX = 0.16,
		ZigzagY = 0.12,
		ZigzagSpeed = 18,
		ZigzagFequency = 3.5,
	},
	
	[2] = {
		Colors = {
			[1] = Color3.fromRGB(180, 180, 180),
			[2] = Color3.fromRGB(180, 180, 180),
			[3] = Color3.fromRGB(180, 180, 180),
			[4] = Color3.fromRGB(180, 180, 180),
			[5] = Color3.fromRGB(180, 180, 180),
			[6] = Color3.fromRGB(180, 180, 180),
		},

		Material = Enum.Material.SmoothPlastic,
		TransparencyStart = 0.42,
		TransparencyEnd = 1,

		Length = 3.4,
		SegmentCount = 11,
		
		WidthStart = 0.18,
		WidthEnd = 0.03,
		
		WaveX = 0.12,
		WaveY = 0.08,
		WaveSpeed = 5,
		
		SempleRate = 0.025,
		TrailDealy = 0.55,
		BackWardSpeed = 4.5,

		ZigzagX = 0.16,
		ZigzagY = 0.12,
		ZigzagSpeed = 12,
		ZigzagFequency = 3.5,
	},
	
	[3] = {
		Colors = {
			[1] = Color3.fromRGB(180, 180, 180),
			[2] = Color3.fromRGB(180, 180, 180),
			[3] = Color3.fromRGB(180, 180, 180),
			[4] = Color3.fromRGB(180, 180, 180),
			[5] = Color3.fromRGB(180, 180, 180),
			[6] = Color3.fromRGB(180, 180, 180),
		},

		Material = Enum.Material.Neon,
		TransparencyStart = 0.30,
		TransparencyEnd = 1,

		Length = 3.8,
		SegmentCount = 12,
		WidthStart = 0.21,
		WidthEnd = 0.035,
		
		WaveX = 0.12,
		WaveY = 0.08,
		WaveSpeed = 5,
		
		SempleRate = 0.025,
		TrailDealy = 0.55,
		BackWardSpeed = 4.5,

		ZigzagX = 0.16,
		ZigzagY = 0.12,
		ZigzagSpeed = 12,
		ZigzagFequency = 3.5,
	},
	
	[4] = {
		Colors = {
			[1] = Color3.fromRGB(180, 180, 180),
			[2] = Color3.fromRGB(180, 180, 180),
			[3] = Color3.fromRGB(180, 180, 180),
			[4] = Color3.fromRGB(180, 180, 180),
			[5] = Color3.fromRGB(180, 180, 180),
			[6] = Color3.fromRGB(180, 180, 180),
		},

		Material = Enum.Material.Neon,
		TransparencyStart = 0.18,
		TransparencyEnd = 1,

		Length = 4.3,
		SegmentCount = 13,
		WidthStart = 0.24,
		WidthEnd = 0.04,
		
		WaveX = 0.12,
		WaveY = 0.08,
		WaveSpeed = 5,
		
		SempleRate = 0.025,
		TrailDealy = 0.55,
		BackWardSpeed = 4.5,

		ZigzagX = 0.16,
		ZigzagY = 0.12,
		ZigzagSpeed = 12,
		ZigzagFequency = 3.5,
	},
	
	[5] = {
		Colors = {
			[1] = Color3.fromRGB(180, 180, 180),
			[2] = Color3.fromRGB(180, 180, 180),
			[3] = Color3.fromRGB(180, 180, 180),
			[4] = Color3.fromRGB(180, 180, 180),
			[5] = Color3.fromRGB(180, 180, 180),
			[6] = Color3.fromRGB(180, 180, 180),
		},

		Material = Enum.Material.Neon,
		TransparencyStart = 0.06,
		TransparencyEnd = 1,

		Length = 4.8,
		SegmentCount = 14,
		WidthStart = 0.28,
		WidthEnd = 0.045,
		
		WaveX = 0.12,
		WaveY = 0.08,
		WaveSpeed = 5,
		
		SempleRate = 0.025,
		TrailDealy = 0.55,
		BackWardSpeed = 4.5,

		ZigzagX = 0.16,
		ZigzagY = 0.12,
		ZigzagSpeed = 12,
		ZigzagFequency = 3.5,
	},
}

local PREVIEW_TRAIL_POINTS = {
	[1] = {
		PartName = "LeftFoot",
		Offset = Vector3.new(0, 0, 0),
	},
	
	[2] = {
		PartName = "RightFoot",
		Offset = Vector3.new(0, 0, 0),
	},
	
	[3] = {
		PartName = "LeftHand",
		Offset = Vector3.new(0, 0, 0),
	},
	
	[4] = {
		PartName = "RightHand",
		Offset = Vector3.new(0, 0, 0),
	},
	
	[5] = {
		PartName = "LowerTorso",
		Offset = Vector3.new(0, 0, 0),
	},
	
	[6] = {
		PartName = "UpperTorso",
		Offset = Vector3.new(0, 0.8, 0),
	},
}

local previewConnection = nil
local previewAnimationTrack = nil

--// TRAILO BUTTON CONFIGURATION
local trailChoiceButtons = {
	{
		Button = trailChoiceButton,
		TrailId = "TrailStone",
	},
}

--// GENERIC GUI HELPERS
local function setText(guiObject, text)
	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
		guiObject.Text = tostring(text or "")
		return
	end
	
	local textLabel = guiObject:FindFirstChildWhichIsA("TextLabel", true)
	
	if textLabel then
		textLabel.Text = tostring(text or "")
	end
end

local function setImage(guiObject, imageId)
	if not guiObject then 
		return
	end
	
	imageId = imageId or ""
	
	if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
		guiObject.Image = imageId
		return
	end
	
	local imageObject = guiObject:FindFirstChildWhichIsA("ImageLabel", true)
	
	if imageObject then
		imageObject.Image = imageId
	end
end

local function setButtonEnabled(button, enabled)
	if not button:IsA("GuiButton") then
		return
	end
	
	button.Active = enabled
	button.AutoButtonColor = enabled
	button.Selectable = enabled
end

local function formatNumber(number)
	number = tonumber(number) or 0
	
	local absolute = math.abs(number)
	
	if absolute >= 1e18 then
		return string.format("%.2fQ", number / 1e18)
	elseif absolute >= 1e12 then
		return string.format("%.2fT", number / 1e12)
	elseif absolute >= 1e9 then
		return string.format("%.2fB", number / 1e9)
	elseif absolute >= 1e6 then
		return string.format("%.2fM", number / 1e6)
	elseif absolute >= 1e3 then
		return string.format("%.2fK", number / 1e3)
	end
	return tostring(math.floor(number))
end

local function showWarning(message, duration)
	warningToken += 1
	
	local currentToken = warningToken
	
	setText(warningLabel, message)
	warningLabel.Visible = true
	
	
	task.delay(duration or 2.5, function()
		if warningToken ~= currentToken then
			return
		end
		warningLabel.Visible = false
	end)
end

--// SERVER REQUEST
local function requestServer(action, trailId)
	if requestBusy then
		return nil
	end
	
	requestBusy = true
	
	local success, response = pcall(function()
		return trailRequestFunction:InvokeServer(action, trailId)
	end)
	
	requestBusy = false
	
	if not success then
		warn("TrailUI server request failed:", action, trailId, response)
		showWarning("Ошибка соединения с сервером")
		return nil
	end
	
	if type(response) ~= "table" then
		showWarning("Сервер вернул неверные данные")
		return nil
	end
	return response
end

--// PLAYER RESOURCES
local function updateLeaderstatsGui()
	local leaderstats = player:FindFirstChild("leaderstats")
	local playerData = player:FindFirstChild("PlayerData")
	
	if leaderstats then
		local rebirth = leaderstats:FindFirstChild("Rebirth")
		
		if rebirth then
			setText(rebirthLead, formatNumber(rebirth.Value))
		end
	end
	
	if playerData then
		local money = playerData:FindFirstChild("Money")
		local srRobux = playerData:FindFirstChild("SrRobux")
		
		if money then
			setText(moneyLead, formatNumber(money.Value))
		end
		
		if srRobux then
			setText(srRobuxLead, formatNumber(srRobux.Value))
		end
	end
end

local function connectResourceUpdates()
	local leaderstats = player:WaitForChild("leaderstats")
	local playerData = player:WaitForChild("PlayerData")
	
	local money = playerData:WaitForChild("Money")
	local srRobux = playerData:WaitForChild("SrRobux")
	local rebirth = leaderstats:WaitForChild("Rebirth")
	
	money:GetPropertyChangedSignal("Value"):Connect(updateLeaderstatsGui)
	srRobux:GetPropertyChangedSignal("Value"):Connect(updateLeaderstatsGui)
	rebirth:GetPropertyChangedSignal("Value"):Connect(updateLeaderstatsGui)
	
	updateLeaderstatsGui()
end

--// XP BAR
local function updateProgressBar(bar, progress, fullSize)
	progress = math.clamp(tonumber(progress) or 0, 0, 1)
	
	bar.Size = UDim2.new(
		fullSize.X.Scale * progress,
		fullSize.X.Offset * progress,
		fullSize.Y.Scale,
		fullSize.Y.Offset
	)
end

local function updateXPBar(trailData)
	local playerResources = trailData.PlayerResources or {}
	local upgradeCost = trailData.UpgradeCost or {}
	
	local currentXP = tonumber(playerResources.XP) or 0
	local requiredXP = tonumber(upgradeCost.XP) or 0
	
	if trailData.Level >= trailData.MaxLevel then
		setText(xpLabel, "MAX LEVEL")
		trailXPBar.Visible = true
		
		updateProgressBar(trailXPBar, 1, TRAIL_XP_BAR_FULL_SIZE)
		return
	end
	
	if not trailData.CanLevelUpAtStage then
		setText(xpLabel, "STAGE UP")
		trailXPBar.Visible = true
		
		updateProgressBar(trailXPBar, 1, TRAIL_XP_BAR_FULL_SIZE)
		return
	end
	
	setText(xpLabel, formatNumber(currentXP) .. " / " .. formatNumber(requiredXP) .. " XP")
	
	local progress = 0
	
	if requiredXP > 0 then
		progress = math.clamp(currentXP / requiredXP, 0, 1)
	end
	
	trailXPBar.Visible = true
	
	updateProgressBar(trailXPBar, progress, TRAIL_XP_BAR_FULL_SIZE)
end

local function closeStageMenu()
	trailStage.Visible = false
	trailStageBlur.Visible = false
end

local function renderStageMenu()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные трейла не найдены")
		closeStageMenu()
		return
	end
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		closeStageMenu()
		return
	end
	
	if trailData.IsMaxStage then
		showWarning("Достигнута максимальная стадия")
		closeStageMenu()
		return
	end
	
	-- Иконки текущей т следующей стадии
	setImage(stageCurrentIcon, trailData.StageIcon)
	
	local nextStageId = trailData.Stage + 1
	
	setImage(stageNextIcon, TrailModule.GetStageIcon(nextStageId))
	
	-- Множитель текущей и следующей стадии
	local currentStageConfig = TrailModule.GetStageConfig(trailData.Stage)
	local nextStageConfig = TrailModule.GetStageConfig(nextStageId)
	local currentMultiplier = currentStageConfig and currentStageConfig.Multiplier or 1
	local nextMultiplier = nextStageConfig and nextStageConfig.Multiplier or 1
	
	setText(stageCurrentBoost, TrailModule.FormatMultiplier(currentMultiplier))
	setText(stageNextBoost, TrailModule.FormatMultiplier(nextMultiplier))
	
	-- Прогресс требований
	local progress = trailData.StageProgress
	
	if not progress then
		setButtonEnabled(stageUpButton, false)
		showWarning("Требования стадии не найдены")
		return
	end
	
	-- 1: Level
	setText(stageRequirement1, formatNumber(progress.Level.Current) .. " / " .. formatNumber(progress.Level.Required))
	updateProgressBar(stageBar1, progress.Level.Progress or 0, STAGE_BAR_1_FULL_SIZE)
	
	-- 2: Money
	setText(stageRequirement2, formatNumber(progress.Money.Current) .. " / " .. formatNumber(progress.Money.Required))
	updateProgressBar(stageBar2, progress.Money.Progress or 0, STAGE_BAR_2_FULL_SIZE)
	
	-- 3: Rebirth
	setText(stageRequirement3, formatNumber(progress.Rebirth.Current) .. " / " .. formatNumber(progress.Rebirth.Required))
	updateProgressBar(stageBar3, progress.Rebirth.Progress or 0, STAGE_BAR_3_FULL_SIZE)
	setButtonEnabled(stageUpButton, progress.CanStageUp == true)
end

--// PREVIEW
local function clearTrailPreview()
	if previewConnection then
		previewConnection:Disconnect()
		previewConnection = nil
	end

	if previewAnimationTrack then
		previewAnimationTrack:Stop()
		previewAnimationTrack:Destroy()
		previewAnimationTrack = nil
	end

	trailPreviewFrame.CurrentCamera = nil
	trailPreviewFrame:ClearAllChildren()
end

local function getPreviewStageStyle(stage)
	stage = math.clamp(math.floor(tonumber(stage) or 1), 1, 5)
	
	return PREVIEW_STAGE_STYLES[stage] or PREVIEW_STAGE_STYLES[1]
end

local function preparePreviewCharacter(character)
	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("Script") or object:IsA("LocalScript") then
			object:Destroy()

		elseif object:IsA("Accessory") then
			local accessoryType = object.AccessoryType

			-- Удаляем крылья и другие аксессуары на спине
			if accessoryType == Enum.AccessoryType.Back then
				object:Destroy()
			end

		elseif object:IsA("BasePart") then
			object.CanCollide = false
			object.CanTouch = false
			object.CanQuery = false
			object.Anchored = false

			if object.Name == "HumanoidRootPart" then
				object.Transparency = 1
			end
		end
	end
end

local function createPreviewSegment(
	worldModel,
	lineIndex,
	segmentIndex,
	color,
	style
)
	local segment = Instance.new("Part")

	segment.Name =
		"PreviewTrailLine"
		.. lineIndex
		.. "Segment"
		.. segmentIndex

	segment.Anchored = true
	segment.CanCollide = false
	segment.CanTouch = false
	segment.CanQuery = false
	segment.CastShadow = false

	segment.Material =
		style.Material
		or Enum.Material.Neon

	segment.Color =
		color
		or Color3.fromRGB(255, 255, 255)

	segment.Parent = worldModel

	return segment
end

local function setPartBetweenPoints(
	part,
	pointA,
	pointB,
	thickness
)
	local difference = pointB - pointA
	local distance = difference.Magnitude

	if distance <= 0.001 then
		part.Transparency = 1
		return
	end

	local center = (pointA + pointB) * 0.5

	part.Size = Vector3.new(
		thickness,
		thickness,
		distance
	)

	part.CFrame = CFrame.lookAt(
		center,
		pointB
	)
end

local function createPreviewAttachment(parent, name, position)
	local attachment = Instance.new("Attachment")

	attachment.Name = name
	attachment.Position = position or Vector3.zero
	attachment.Parent = parent

	return attachment
end

local function createPreviewBeamLine(
	worldModel,
	bodyPart,
	lineIndex,
	pointData,
	style
)
	-- Точка начала линии на персонаже
	local bodyAttachment = createPreviewAttachment(
		bodyPart,
		"PreviewBeamBodyAttachment" .. lineIndex,
		pointData.Offset or Vector3.zero
	)

	-- Прозрачная точка, которая будет двигаться позади персонажа
	local targetPart = Instance.new("Part")

	targetPart.Name = "PreviewBeamTarget" .. lineIndex
	targetPart.Size = Vector3.new(0.05, 0.05, 0.05)
	targetPart.Transparency = 0
	targetPart.Color = Color3.fromRGB(255, 0, 0)
	targetPart.Size = Vector3.new(0.3, 0.3, 0.3)
	targetPart.Anchored = true
	targetPart.CanCollide = false
	targetPart.CanTouch = false
	targetPart.CanQuery = false
	targetPart.CastShadow = false
	targetPart.Parent = worldModel

	local targetAttachment = createPreviewAttachment(
		targetPart,
		"PreviewBeamTargetAttachment" .. lineIndex,
		Vector3.zero
	)

	local beam = Instance.new("Beam")

	beam.Name = "PreviewBeamLine" .. lineIndex

	beam.Attachment0 = bodyAttachment
	beam.Attachment1 = targetAttachment

	beam.FaceCamera = true
	beam.Enabled = true

	beam.Color = ColorSequence.new(
		style.Colors[lineIndex]
			or Color3.fromRGB(255, 255, 255)
	)

	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(
			0,
			math.clamp(style.Transparency, 0, 1)
		),

		NumberSequenceKeypoint.new(
			0.75,
			math.clamp(style.Transparency + 0.1, 0, 1)
		),

		NumberSequenceKeypoint.new(1, 1),
	})

	beam.Width0 = style.Width0 or 0.15
	beam.Width1 = style.Width1 or 0.02

	beam.CurveSize0 = style.CurveSize0 or 0
	beam.CurveSize1 = style.CurveSize1 or 0

	beam.LightEmission = 1
	beam.LightInfluence = 0

	beam.Segments = 12

	beam.Parent = bodyPart

	return {
		BodyPart = bodyPart,
		BodyAttachment = bodyAttachment,

		TargetPart = targetPart,
		TargetAttachment = targetAttachment,

		Beam = beam,
		PointData = pointData,
	}
end

local function updateTrailPreview(trailData)
	clearTrailPreview()

	if type(trailData) ~= "table" then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	character.Archivable = true
	local previewCharacter = character:Clone()
	character.Archivable = false

	if not previewCharacter then
		return
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "TrailPreviewWorld"
	worldModel.Parent = trailPreviewFrame

	local camera = Instance.new("Camera")
	camera.Name = "TrailPreviewCamera"
	camera.FieldOfView = 38
	camera.Parent = trailPreviewFrame

	trailPreviewFrame.CurrentCamera = camera

	previewCharacter.Name = "PreviewCharacter"
	previewCharacter.Parent = worldModel

	preparePreviewCharacter(previewCharacter)

	local humanoid =
		previewCharacter:FindFirstChildOfClass("Humanoid")

	local humanoidRootPart =
		previewCharacter:FindFirstChild("HumanoidRootPart")

	if not humanoid or not humanoidRootPart then
		clearTrailPreview()
		return
	end

	humanoidRootPart.CFrame =
		CFrame.new(0, 1.8, 0)
		* CFrame.Angles(0, math.rad(-90), 0)

	-- Здесь оставь уже настроенную тобой позицию камеры
	camera.CFrame = CFrame.lookAt(
		Vector3.new(2.7, 3, 9),
		Vector3.new(0, 1.6, 0)
	)

	local animator =
		humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local runAnimation = Instance.new("Animation")
	runAnimation.AnimationId = PREVIEW_RUN_ANIMATION_ID

	local success, animationTrack = pcall(function()
		return animator:LoadAnimation(runAnimation)
	end)

	runAnimation:Destroy()

	if success and animationTrack then
		previewAnimationTrack = animationTrack
		previewAnimationTrack.Priority =
			Enum.AnimationPriority.Action

		previewAnimationTrack.Looped = true
		previewAnimationTrack:Play()
		previewAnimationTrack:AdjustSpeed(2.2)
	end

	local style =
		getPreviewStageStyle(trailData.Stage)

	local previewLines = {}

	local segmentCount =
		math.max(
			math.floor(
				tonumber(style.SegmentCount) or 10
			),
			2
		)

	for lineIndex, pointData in ipairs(PREVIEW_TRAIL_POINTS) do
		local bodyPart =
			previewCharacter:FindFirstChild(
				pointData.PartName
			)

		if bodyPart and bodyPart:IsA("BasePart") then
			local color =
				style.Colors[lineIndex]
				or Color3.fromRGB(255, 255, 255)

			local segments = {}

			for segmentIndex = 1, segmentCount do
				segments[segmentIndex] =
					createPreviewSegment(
						worldModel,
						lineIndex,
						segmentIndex,
						color,
						style
					)
			end

			local startPosition =
				(
					bodyPart.CFrame
					* CFrame.new(
						pointData.Offset or Vector3.zero
					)
				).Position

			local history = {}

			for historyIndex = 1, segmentCount + 1 do
				history[historyIndex] = {
					Position = startPosition,
					Time = os.clock(),
				}
			end

			previewLines[lineIndex] = {
				BodyPart = bodyPart,
				PointData = pointData,
				Segments = segments,

				History = history,
				LastSampleTime = 0,

				PreviousBodyPosition = startPosition,
			}
		end
	end

	local startTime = os.clock()

	previewConnection =
		RunService.RenderStepped:Connect(function(deltaTime)
			if not trailPreviewFrame.Visible then
				return
			end

			if not humanoidRootPart.Parent then
				return
			end

			local now = os.clock()
			local t = now - startTime

			local sampleRate = math.max(
				tonumber(style.SampleRate) or 0.025,
				0.01
			)

			local trailDelay = math.max(
				tonumber(style.TrailDelay) or 0.55,
				0.05
			)

			local backwardSpeed = tonumber(style.BackwardSpeed) or 4.5

			local zigzagX = tonumber(style.ZigzagX) or 0.16

			local zigzagY = tonumber(style.ZigzagY) or 0.12

			local zigzagSpeed = tonumber(style.ZigzagSpeed) or 12

			local zigzagFrequency = tonumber(style.ZigzagFrequency) or 3.5

			local widthStart = tonumber(style.WidthStart) or 0.16

			local widthEnd = tonumber(style.WidthEnd) or 0.02

			local transparencyStart = tonumber(style.TransparencyStart) or 0.4

			local transparencyEnd = tonumber(style.TransparencyEnd) or 1

			for lineIndex, lineData in pairs(previewLines) do
				local bodyPart = lineData.BodyPart
				local pointData = lineData.PointData
				local segments = lineData.Segments
				local history = lineData.History

				if not bodyPart.Parent then
					continue
				end

				local phase = (lineIndex - 1)
				* (math.pi * 2 / 6)

				local currentBodyPosition = (
					bodyPart.CFrame
					* CFrame.new(
						pointData.Offset
						or Vector3.zero
					)
				).Position

				-- Сохраняем новые позиции не каждый кадр,
				-- а через заданный интервал.
				if now - lineData.LastSampleTime >= sampleRate then
					lineData.LastSampleTime = now

					table.insert(history, 1, {
						Position = currentBodyPosition,
						Time = now,
					})

					while #history > segmentCount + 1 do
						table.remove(history)
					end
				end

				-- Первая точка всегда остаётся прикреплена
				-- к текущему положению конечности.
				local renderedPoints = {
					currentBodyPosition,
				}

				for pointIndex = 2, segmentCount + 1 do
					local historyEntry = history[math.min(
						pointIndex,
						#history
					)
					]

					local progress = (pointIndex - 1) / segmentCount

					local age = now - historyEntry.Time

					local ageProgress = math.clamp(
						age / trailDelay,
						0,
						1
					)

					local originalPosition = historyEntry.Position

					-- Направление назад берём от RootPart,
					-- а не от руки/ноги. Поэтому хвост всегда
					-- уходит за персонажа.
					local backwardDirection = humanoidRootPart.CFrame.LookVector * -1

					local backwardOffset = backwardDirection
					* backwardSpeed
					* ageProgress

					-- Зигзаг рассчитываем в мировом пространстве
					-- относительно осей персонажа.
					local rightDirection = humanoidRootPart.CFrame.RightVector

					local upDirection = humanoidRootPart.CFrame.UpVector

					local zigzagAngle = t * zigzagSpeed
					- progress
					* math.pi
					* 2
					* zigzagFrequency
					+ phase

					-- Две гармоники дают менее округлую
					-- и более "молниеподобную" форму.
					local horizontalValue = math.sin(zigzagAngle)

					local verticalValue = math.sin(
						zigzagAngle * 1.65
						+ phase * 0.7
					)

					local zigzagFade = 0.25 + progress * 0.75

					local zigzagOffset = rightDirection
					* horizontalValue
					* zigzagX
					* zigzagFade
					* upDirection
					* verticalValue
					* zigzagY
					* zigzagFade

					renderedPoints[pointIndex] = originalPosition
					+ backwardOffset
					+ zigzagOffset
				end

				for segmentIndex, segment in ipairs(segments) do
					if not segment.Parent then
						continue
					end

					local startPoint = renderedPoints[segmentIndex]

					local endPoint = renderedPoints[segmentIndex + 1]

					local progress = (segmentIndex - 1)
					/ math.max(
						segmentCount - 1,
						1
					)

					local thickness = widthStart
					+ (
						widthEnd
						- widthStart
					)
					* progress

					local transparency = transparencyStart
					+ (
						transparencyEnd
						- transparencyStart
					)
					* progress

					-- Резкая пульсация больше похожа на молнию,
					-- чем плавная синусоида.
					local pulseWave = math.abs(
						math.sin(
							t * 15
							+ segmentIndex * 1.7
							+ phase
						)
					)

					local pulse = 0.88 + pulseWave * 0.20

					setPartBetweenPoints(
						segment,
						startPoint,
						endPoint,
						math.max(
							thickness * pulse,
							0.01
						)
					)

					segment.Transparency = math.clamp(
						transparency,
						0,
						1
					)
				end
			end
		end)

	trailPreviewFrame:SetAttribute(
		"SelectedTrail",
		trailData.TrailId
	)
end

--// CHOICE BUTTONS
local function updateChoiceButtons()
	for _, buttonData in ipairs(trailChoiceButtons) do
		local button = buttonData.Button
		local trailId = buttonData.TrailId
		
		local isSelected = trailId == selectedTrail
		
		button:SetAttribute("Selected", isSelected)
		
		local selectedImage = TrailModule.Icons.TrailList.Selected
		local defaultImage = TrailModule.Icons.TrailList.Default
		
		if button:IsA("ImageButton") and selectedImage ~= "" and defaultImage ~= "" then
			button.Image = isSelected and selectedImage or defaultImage
		end
	end
end

--// MAIN RENDER
local function renderSelectedTrail()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные выббранного трейла не найдены")
		return
	end
	
	setText(trailNameLabel, trailData.DisplayName)
	setText(stageNameLabel, trailData.StageName)
	setImage(stageIcon, trailData.StageIcon)
	setText(levelLabel, "LEVEL " .. tostring(trailData.Level) .. " / " .. tostring(trailData.StageMaxLevel))
	
	local boosts = trailData.Boosts or {}
	
	setText(powerBoostLabel, TrailModule.FormatPercent(boosts.PowerPercent or 0))
	setText(accelerationBoostLabel, TrailModule.FormatPercent(boosts.AccelerationPercent or 0))
	setText(infoLabel, trailData.Description or "")
	
	updateXPBar(trailData)
	updateTrailPreview(trailData)
	updateChoiceButtons()
	
	if not trailData.Owned then
		setText(buyUpgradeLabel, "BUY")
		setText(upgradePriceLabel, formatNumber(trailData.Purchase.Price))
		setText(equipButton, "EQUIP")
		
		if equipButton:IsA("ImageButton") then
			equipButton.Image = TrailModule.Icons.Equipped.Default
		end
		
		setButtonEnabled(equipButton, false)
		setButtonEnabled(buyUpgradeButton, trailData.Available == true)
		
	elseif trailData.Level >= trailData.MaxLevel then
		setText(buyUpgradeLabel, "MAX")
		setText(upgradePriceLabel, "MAX")
		
		setButtonEnabled(buyUpgradeButton, false)
		setButtonEnabled(equipButton, true)
		
	elseif not trailData.CanLevelUpAtStage then
		setText(buyUpgradeLabel, "UPGRADE")
		setText(upgradePriceLabel, "STAGE UP")
		setButtonEnabled(buyUpgradeButton, false)
		setButtonEnabled(equipButton, true)
	else
		setText(buyUpgradeLabel, "UPGRADE")
		local upgradeCost = trailData.UpgradeCost
		
		if upgradeCost then
			setText(upgradePriceLabel, formatNumber(upgradeCost.Money))
		else
			setText(upgradePriceLabel, "-")
		end
		
		setButtonEnabled(buyUpgradeButton, true)
		setButtonEnabled(equipButton, true)
	end
	
	if trailData.Owned then
		if trailData.Equipped then
			setText(equipButton, "UNEQUIP")
			
			if equipButton:IsA("ImageButton") then
				equipButton.Image = TrailModule.Icons.Equipped.Selected
			end
		else
			setText(equipButton, "EQUIP")
			
			if equipButton:IsA("ImageButton") then
				equipButton.Image = TrailModule.Icons.Equipped.Default
			end
		end
	end
	
	setButtonEnabled(stageOpenButton, trailData.Owned == true and trailData.IsMaxStage ~= true)
	
	updateLeaderstatsGui()
end

--// DATA LOADING
local function rebuildOrderedTrailList()
	table.clear(orderedTrailIds)
	
	for trailId, trailData in pairs(allTrailData) do
		table.insert(orderedTrailIds, {
			TrailId = trailId,
			Order = trailData.Order or 999,
		})
	end
	
	table.sort(orderedTrailIds, function(a, b)
		return a.Order < b.Order
	end)
	
	for index, data in ipairs(orderedTrailIds) do
		if data.TrailId == selectedTrail then
			selectedTrailIndex = index
			break
		end
	end
end

local function loadAllTrailData()
	local response = requestServer("GetAllData")
	
	if not response then
		return false
	end
	
	if not response.Success then
		showWarning(response.Message)
		return false
	end
	
	local data = response.Data
	
	if type(data) ~= "table" or type(data.Trails) ~= "table" then
		showWarning("Не удалось загрузить трейлы")
		return false
	end
	
	allTrailData = data.Trails
	
	if not allTrailData[selectedTrail] then
		selectedTrail = data.DefaultTrailId or TrailModule.DEFAULT_TRAIL_ID
	end
	
	rebuildOrderedTrailList()
	renderSelectedTrail()
	
	return true
end

local function applyActionResponse(response)
	if not response then
		return
	end
	
	if response.Message and response.Message ~= "" then
		showWarning(response.Message)
	end
	
	if not response.Success then
		return
	end
	
	local updateTrail = response.Data
	
	if type(updateTrail) == "table" and updateTrail.TrailId then
		allTrailData[updateTrail.TrailId] = updateTrail
	end
	
	renderSelectedTrail()
end

--// SELECT TRAIL
local function selectTrail(trailId)
	if not allTrailData[trailId] then
		showWarning("Этот трейл пока недостуен")
		return
	end
	
	selectedTrail = trailId
	
	for index, data in ipairs(orderedTrailIds) do
		if data.TrailId == trailId then
			selectedTrailIndex = index
			break
		end
	end
	renderSelectedTrail()
end

local function selectPreviousTrail()
	if #orderedTrailIds <= 1 then
		return
	end
	
	selectedTrailIndex -= 1
	
	if selectedTrailIndex < 1  then
		selectedTrailIndex = #orderedTrailIds
	end
	
	selectTrail(orderedTrailIds[selectedTrailIndex].TrailId)
end

local function selectNextTrail()
	if #orderedTrailIds <= 1 then
		return
	end
	
	selectedTrailIndex += 1
	
	if selectedTrailIndex > #orderedTrailIds then
		selectedTrailIndex = 1
	end
	
	selectTrail(orderedTrailIds[selectedTrailIndex].TrailId)
end

--// BUTTON ACTIONS
buyUpgradeButton.Activated:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		return
	end
	
	if not trailData.Owned then
		local response = requestServer("PurchaseTrail", selectedTrail)
		
		applyActionResponse(response)
		return
	end
	
	if trailData.Level >= trailData.MaxLevel then
		showWarning("Достигнут максимальный уровень")
		return
	end
	
	if not trailData.CanLevelUpAtStage then
		showWarning("Необходимо повысть стадию для открытия следующих уровней")
		return
	end
	
	local response = requestServer("UpgradeTrail", selectedTrail)
	
	applyActionResponse(response)
end)

equipButton.MouseButton1Click:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		return
	end
	
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		return
	end
	
	local response = requestServer("ToggleEquip", selectedTrail)
	
	applyActionResponse(response)
	
	if response and response.Success then
		loadAllTrailData()
	end
end)

stageOpenButton.MouseButton1Click:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные трейла не найдены")
		return
	end
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		return
	end
	
	if trailData.IsMaxStage then
		showWarning("Достигнута максимальная стадия")
		return
	end
	
	local response = requestServer("GetTrailData", selectedTrail)
	
	if not response then
		return
	end
	
	if not response.Success then
		showWarning(response.Message)
		return
	end
	
	local updateTrail = response.Data
	
	if type(updateTrail) ~= "table" or not updateTrail.TrailId then
		showWarning("Не удалось обновить данные стадии")
		return
	end
	
	allTrailData[updateTrail.TrailId] = updateTrail
	
	trailData = updateTrail
	
	trailStage:SetAttribute("SelectedTrail", selectedTrail)
	
	renderStageMenu()
	
	trailStageBlur.Visible = true
	trailStage.Visible = true
end)

stageUpButton.MouseButton1Click:Connect(function()
	local trailData = allTrailData[selectedTrail]
	
	if not trailData then
		showWarning("Данные трейла не найдены")
		return
	end
	
	if not trailData.Owned then
		showWarning("Сначала купите этот трейл")
		return
	end
	
	if trailData.IsMaxStage then
		showWarning("Достигнута максимальная стадия")
		closeStageMenu()
		return
	end
	
	local progress = trailData.StageProgress
	
	if not progress then
		showWarning("Требования стадии не найдены")
		return
	end
	
	if not progress.CanStageUp then
		showWarning("Не все требования выполнены")
		return
	end
	
	setButtonEnabled(stageUpButton, false)
	
	local response = requestServer("StageUp", selectedTrail)
	
	if not response then
		renderStageMenu()
		return
	end
	
	if response.Message and response.Message ~= "" then
		showWarning(response.Message)
	end
	
	if not response.Success then
		renderStageMenu()
		return
	end
	
	local updateTrail = response.Data
	
	if type(updateTrail) ~= "table" or not updateTrail.TrailId then
		showWarning("Сервер вернул неверные данные трейла")
		loadAllTrailData()
		closeStageMenu()
		return
	end
	
	allTrailData[updateTrail.TrailId] = updateTrail
	
	renderSelectedTrail()
	
	if updateTrail.IsMaxStage then
		closeStageMenu()
		return
	end
	
	renderStageMenu()
end)

stageCloseButton.Activated:Connect(function()
	closeStageMenu()
end)

trailListBackButton.Activated:Connect(selectPreviousTrail)
trailListNextButton.Activated:Connect(selectNextTrail)

for _, buttonData in ipairs(trailChoiceButtons) do
	buttonData.Button.Activated:Connect(function()
		selectTrail(buttonData.TrailId)
	end)
end

trailClose.Activated:Connect(function()
	clearTrailPreview()
	
	trailStage.Visible = false
	trailStageBlur.Visible = false
	
	MenuManager.close("Trails")
end)


--// OPEN REFRESH
trailMenu:GetPropertyChangedSignal("Visible"):Connect(function()
	if not trailMenu.Visible then
		clearTrailPreview()
		return
	end
	
	loadAllTrailData()
end)

--// INITIALIZED
warningLabel.Visible = false
trailStage.Visible = false 
trailStageBlur.Visible = false

connectResourceUpdates()

task.spawn(function()
	while player:GetAttribute("DataReady") ~= true do
		player:GetAttributeChangedSignal("DataReady"):Wait()
	end
	
	loadAllTrailData()
end)

print("TrailUI loaded")
