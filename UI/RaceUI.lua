--// RaceUI 1.3

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local RaceModule = require(ReplicatedStorage.Modules.RaceModule)
local ClientDataModule = require(ReplicatedStorage.Modules.ClientDataModule)
local UpgradeModule = require(ReplicatedStorage.Modules.UpgradeModule)

local player = Players.LocalPlayer
local raceGui = script.Parent

ClientDataModule.WaitUntilReady(player)

while player:GetAttribute("RaceServerReady") ~= true do task.wait() end

--// General helpers
local function setText(object, value)
	if object and (object:IsA("TextLabel") or object:IsA("TextButton")) then
		object.Text = tostring(value)
	end
end

local function setImage(object, image)
	if object and (object:IsA("ImageLabel") or object:IsA("ImageButton")) then
		object.Image = image or ""
	end
end

local function setBarScale(bar, scale)
	if not bar then return end 
	
	bar.Size = UDim2.new(math.max(0, tonumber(scale) or 0), 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
end

local function formatNumber(number)
	local success, result = pcall(RaceModule.FormatNumber, number)
	if success then return result end
	return tostring(math.floor(tonumber(number) or 0))
end

local function formatDistance(distance)
	local success, result = pcall(RaceModule.FormatDistance, distance)
	if success then return result end 
	return formatNumber(distance) .. "M"
end

local function formatMultiplier(multiplier)
	local success, result = pcall(RaceModule.FormatMultiplier, multiplier)
	if success then return result end
	return "x" .. tostring(multiplier or 1)
end

local function findDescendant(parent, name)
	if parent.Name == name then return parent end
	
	for _, descendant in ipairs(parent:GetDescendants()) do
		if descendant.Name == name then
			return descendant
		end
	end
	return nil
end

local function getThumbnail(userId, size)
	local success, image = pcall(Players.GetUserThumbnailAsync, Players, userId, 
		Enum.ThumbnailType.HeadShot, 
		size or Enum.ThumbnailSize.Size100x100)
	if success then return image end
	return ""
end

--// Replicated race object
local replicatedRaceFolder = ReplicatedStorage:WaitForChild("RaceFolder")

local leaveRaceEvent = replicatedRaceFolder:WaitForChild("LeaveRaceEvent")
local raceActionEvent = replicatedRaceFolder:WaitForChild("RaceActionEvent")
local raceActionResultEvent = replicatedRaceFolder:WaitForChild("RaceActionResultEvent")
local raceWarningEvent = replicatedRaceFolder:WaitForChild("RaceWarningEvent")

local racePreviewFunction = replicatedRaceFolder:FindFirstChild("RacePreviewFunction")
local raceTopData = replicatedRaceFolder:WaitForChild("RaceTopData")

local raceStatusText = ReplicatedStorage:WaitForChild("RaceStatusText")
local raceTimerText = ReplicatedStorage:WaitForChild("RaceTimerText")

--// Player data
local leaderstats = ClientDataModule.GetLeaderstats(player)
local playerData = ClientDataModule.GetPlayerData(player)
local resourcesFolder = ClientDataModule.GetResources(player)

local energyValue = ClientDataModule.GetEnergy(player)
local rebirthValue = ClientDataModule.GetRebirth(player)
local moneyValue = ClientDataModule.GetMoney(player)
local raceTouchValue = ClientDataModule.GetRaceTouch(player)
local xpValue = resourcesFolder:WaitForChild("XPModule")

local raceData = playerData:WaitForChild("RaceData")
local stageValue = raceData:WaitForChild("Stage")
local roadLevelValue = raceData:WaitForChild("RoadLevel")
local rewardLevelValue = raceData:WaitForChild("RewardLevel")

local raceRecordValue = leaderstats:WaitForChild("RaceRecord")
local inRaceValue = player:WaitForChild("InRace")
local raceProgressValue = player:WaitForChild("RaceProgress")
local raceSpeedValue = player:WaitForChild("RaceSpeed")
local raceTargetSpeedValue = player:WaitForChild("RaceTargetSpeed")
local raceLapDistanceValue = player:WaitForChild("RaceLapDistance")
local raceRoundDistanceValue = player:WaitForChild("RaceRoundDistance")
local raceTrackDistanceValue = player:WaitForChild("RaceTrackDistance")

--// Main UI references
local guiFolder = raceGui:WaitForChild("GuiFolder")
local raceFolder = guiFolder:WaitForChild("RaceFolder")

local speedometer = raceFolder:WaitForChild("Speedometer")
local arrow = speedometer:WaitForChild("Arrow")
local tickCurrentSpeed = speedometer:WaitForChild("TickCurrentSpeed")

local speedTicks = {
	speedometer:WaitForChild("Tick1"),
	speedometer:WaitForChild("Tick2"),
	speedometer:WaitForChild("Tick3"),
	speedometer:WaitForChild("Tick4"),
	speedometer:WaitForChild("Tick5"),
}

local raceTimer = raceFolder:WaitForChild("RaceTimer")
local raceStatusLabel = raceTimer:WaitForChild("RaceStatus")
local timerStatusLabel = raceTimer:WaitForChild("TimerStatus")

local racePanel = raceFolder:WaitForChild("RacePanel")
local panelIconTemplate = racePanel:WaitForChild("Icon")

local panelLines = {
	racePanel:WaitForChild("Line1"),
	racePanel:WaitForChild("Line2"),
	racePanel:WaitForChild("Line3"),
}

local raceTop = raceFolder:WaitForChild("RaceTop")
local topImages = {
	raceTop:WaitForChild("Top1"),
	raceTop:WaitForChild("Top2"),
	raceTop:WaitForChild("Top3"),
}

local topRecordLabels = {
	raceTop:WaitForChild("Top1Record"),
	raceTop:WaitForChild("Top2Record"),
	raceTop:WaitForChild("Top3Record"),
}

local raceWarningLabel = raceFolder:WaitForChild("RaceWarningLabel")
local leaveButton = raceFolder:FindFirstChild("LeaveButton")

--// RaceHost references
local raceHost = raceFolder:WaitForChild("RaceHost")
local raceHostBlur = raceHost:WaitForChild("RaceHostBlur")
local leaderstatsMenu = raceHost:WaitForChild("LeaderstatsMenu")
local raceMenu = raceHost:WaitForChild("RaceMenu")
local stageMenu = raceHost:WaitForChild("StageMenu")

local raceMenuClose = raceMenu:WaitForChild("RaceMenuClose")
local moneyLead = raceMenu:WaitForChild("MoneyLead")
local raceRecordLabel = raceMenu:WaitForChild("RaceRecordLabel")
local raceTouchLead = raceMenu:WaitForChild("RaceTouchLead")
local xpLead = raceMenu:WaitForChild("XpLead")

--// Section references
local detailsFolder = raceMenu:WaitForChild("DetailsFolder")
local sectionFolder = raceMenu:WaitForChild("SectionFolder")
local rewardFolder = raceMenu:WaitForChild("RewardFolder")

local nameDetails = detailsFolder:WaitForChild("NameDetails")
local frameRewardDetail = detailsFolder:WaitForChild("FrameRewardDetail")
local frameStageDetail = detailsFolder:WaitForChild("FrameStageDetail")
local frameUpgradeDetail = detailsFolder:WaitForChild("FrameUpgradeDetail")

local rewardDetailsButton = sectionFolder:WaitForChild("RewardDetails")
local stageDetailsButton = sectionFolder:WaitForChild("StageDetails")
local upgradeDetailsButton = sectionFolder:WaitForChild("UpgradeDetails")

local rewMultNumber = rewardDetailsButton:WaitForChild("RewMultNumber")

local summaryStageIcon = stageDetailsButton:WaitForChild("StaStageIcon")
local summaryStageBonus = stageDetailsButton:WaitForChild("StaStageBonus")
local summaryStageDistance = stageDetailsButton:WaitForChild("StaStageDistance")
local summaryStageName = stageDetailsButton:WaitForChild("StaStageName")

local summaryUpgradeLevel = upgradeDetailsButton:WaitForChild("UpgLvlNumber")
local summaryUpgradeRewards = upgradeDetailsButton:WaitForChild("UpgRewardNumber")

--// Reward detail references
local rewUpgBonus = frameRewardDetail:WaitForChild("RewUpgBonus")
local rewUpgLevel = frameRewardDetail:WaitForChild("RewUpgLevel")
local rewLvlBar = frameRewardDetail:WaitForChild("RewLvlBar")
local rewCurNumber = frameRewardDetail:WaitForChild("RewCurNumber")

local rewCurUpgMoney = frameRewardDetail:WaitForChild("RewCurUpgMoney")
local rewCurUpgGems = frameRewardDetail:WaitForChild("RewCurUpgGems")
local rewCurUpgXP = frameRewardDetail:WaitForChild("RewCurUpgXp")

local rewNextUpgMoney = frameRewardDetail:WaitForChild("RewNextUpgMoney")
local rewNextUpgGems = frameRewardDetail:WaitForChild("RewNextUpgGems")
local rewNextUpgXP = frameRewardDetail:WaitForChild("RewNextUpgXp")

--// Road upgrade detail references
local roadUpgradeButton = frameUpgradeDetail:WaitForChild("UpgradeButton")
local roadUpgradePrice = roadUpgradeButton:WaitForChild("UpgPrice")
local roadLevelNumber = frameUpgradeDetail:WaitForChild("UpgLvlNumber")
local roadLevelBar = frameUpgradeDetail:WaitForChild("UpgLvlBar")

local currentRewardNumber = frameUpgradeDetail:WaitForChild("UpgCurRewNumber")
local nextRewardNumber = frameUpgradeDetail:WaitForChild("UpgNextRewNumber")
local currentDistanceNumber = frameUpgradeDetail:WaitForChild("UpgCurDisNumber")
local nextDistanceNumber = frameUpgradeDetail:WaitForChild("UpgNextDisNumber")

--// Stage detail references
local stageMenuOpen = frameStageDetail:WaitForChild("StageMenuOpen")
local detailStageBonus = frameStageDetail:WaitForChild("StaStageBonus")
local detailStageLevel = frameStageDetail:WaitForChild("StaLvlNumber")
local detailStageBar = frameStageDetail:WaitForChild("StaLvlBar")
local detailStageName = frameStageDetail:WaitForChild("StaStageName")
local detailStageIcon = frameStageDetail:WaitForChild("StaStageIcon")

--// RewardFolder references
local rewardBar = rewardFolder:WaitForChild("RewardBar")
local rewardButtonTemplate = rewardFolder:WaitForChild("RewardButton")

--// StageMenu references
local stageClose = stageMenu:WaitForChild("StageClose")
local stageCurrentIcon = stageMenu:WaitForChild("StaCurIcon")
local stageNextIcon = stageMenu:WaitForChild("StaNextIcon")
local stageArrowIcon = stageMenu:WaitForChild("StaArrowIcon")

local stageCurrentBoost = stageMenu:WaitForChild("StaCurBoost")
local stageNextBoost = stageMenu:WaitForChild("StaNextBoost")

local stageRequiredLevel = stageMenu:WaitForChild("StaRequirLvl")
local stageRequiredRaceTouch = stageMenu:WaitForChild("StaRequirRaceTouch")
local stageRequiredMoney = stageMenu:WaitForChild("StaRequirMoney")
local stageRequiredRebirth = stageMenu:WaitForChild("StaRequirRebirth")
local stageRequiredEnergy = stageMenu:WaitForChild("StaRequirEnergy")

local stageRequirementBar = stageMenu:WaitForChild("StaRequirBar")
local stageRequirementPercent = stageMenu:WaitForChild("StaRequirBarPercent")
local stageUpButton = stageMenu:WaitForChild("StageUpButton")

--// Stage leaderstats references
local stageEnergyLead = leaderstatsMenu:WaitForChild("EnergyLead")
local stageMoneyLead = leaderstatsMenu:WaitForChild("MoneyLead")
local stageRaceTouchLead = leaderstatsMenu:WaitForChild("RaceTouchLead")
local stageRebirthLead = leaderstatsMenu:WaitForChild("RebirthLead")

--// Musik
local backgroundMusik = SoundService:WaitForChild("BackgroundMusik")
local raceSoundFolder = SoundService:WaitForChild("RaceSound")
local raceMusic = raceSoundFolder and raceSoundFolder:FindFirstChild("RaceSounds")
local wasInRace = false

local function startRaceMusic()
	if backgroundMusik then
		backgroundMusik.Volume = 0
		backgroundMusik:Pause()
	end
	
	if raceMusic then
		raceMusic.TimePosition = 0
		raceMusic.Volume = 0.7
		raceMusic.Looped = true
		raceMusic:Play()
	end
end

local function stopRaceMusic()
	if raceMusic then
		raceMusic:Stop()
	end
	
	if backgroundMusik then
		backgroundMusik.Volume = 0.3
		backgroundMusik:Resume()
	end
end

--// Speedometer
local speedometerObjects = {speedometer, arrow, tickCurrentSpeed}

for _, tick in ipairs(speedTicks) do
	table.insert(speedometerObjects, tick)
end

local function setSpeedometerVisible(visible)
	for _, object in ipairs(speedometerObjects) do
		object.Visible = visible
	end
end

local function getEffectiveEnergy()
	return UpgradeModule.GetRaceEnergy(player, energyValue.Value)
end

local function updateSpeedometer()
	local ticks = RaceModule.GetSpeedometerTicks(getEffectiveEnergy())
	
	for index, label in ipairs(speedTicks) do
		setText(label, formatNumber(ticks[index] or 0))
	end
	
	setText(tickCurrentSpeed, formatNumber(raceSpeedValue.Value))
	
	arrow.Rotation = RaceModule.GetSpeedometerArrowRotation(raceSpeedValue.Value, raceTargetSpeedValue.Value)
end

--// Timer
local function updateTimer()
	setText(raceStatusLabel, raceStatusText.Value)
	setText(timerStatusLabel, raceTimerText.Value)
end

--// Race visibility
local function updateRaceVisibility()
	local visible = inRaceValue.Value
	
	setSpeedometerVisible(visible)
	
	if leaveButton then
		leaveButton.Visible = visible
	end
	
	if visible and not wasInRace then
		wasInRace = true
		startRaceMusic()
	elseif not visible and wasInRace then
		wasInRace = false
		stopRaceMusic()
	end
end


--// Local 3D gates
local raceTrack = workspace:WaitForChild(RaceModule.WorldNames.RaceTrack)
local raceStartPoint = findDescendant(raceTrack, RaceModule.WorldNames.RaceStartPoint)
local localGateFolder

local function findGateTemplate(templateName)
	local template = replicatedRaceFolder:FindFirstChild(templateName, true)
	if template then return template end
	
	template = ReplicatedStorage:FindFirstChild(templateName, true)
	if template then return template end
	
	return findDescendant(raceTrack, templateName)
end

local rewardGateTemplate = findGateTemplate(RaceModule.WorldNames.RewardGateTemplate)
local finishGateTemplate = findGateTemplate(RaceModule.WorldNames.FinishGateTemplate)

local function setLocalGateProperties(object)
	for _, descendant in ipairs(object:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end
	
	if object:IsA("BasePart") then
		object.Anchored = true
		object.CanCollide = false
		object.CanTouch = false
		object.CanQuery = false
	end
end

local function pivotObject(object, cframe)
	if object:IsA("Model") then
		object:PivotTo(cframe)
	elseif object:IsA("BasePart") then
		object.CFrame = cframe
	end
end

local function setGateRewardName(gate, rewardName)
	local label = findDescendant(gate, "RewardNumber") 
		or findDescendant(gate, "RewardLabel")
	
	if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
		label.Text = rewardName
	end
end

local function destroyLocalGates()
	if localGateFolder then
		localGateFolder:Destroy()
		localGateFolder = nil
	end
end

local function rebuildLocalGates()
	destroyLocalGates()
	
	if not inRaceValue.Value or not raceStartPoint then return end 
	if not rewardGateTemplate or not finishGateTemplate then
		warn("RaceUI: RewardGate or FinisGate template was not found")
		return
	end
	
	localGateFolder = Instance.new("Folder")
	localGateFolder.Name = "LocalRaceGates_" .. player.UserId
	localGateFolder.Parent = workspace
	
	local checkpoints = RaceModule.GetRewardCheckpoint(stageValue.Value, roadLevelValue.Value)
	
	for _, checkpoint in ipairs(checkpoints) do
		local gate = rewardGateTemplate:Clone()
		gate.Name = checkpoint.Name
		gate.Parent = localGateFolder
		
		setLocalGateProperties(gate)
		setGateRewardName(gate, checkpoint.Name)
		
		pivotObject(gate, RaceModule.GetWorldCFrameAtDistance(raceStartPoint.CFrame, checkpoint.Distance))
	end
	
	local finishGate = finishGateTemplate:Clone()
	finishGate.Name = "LocalFinishGate"
	finishGate.Parent = localGateFolder
	
	setLocalGateProperties(finishGate)
	pivotObject(finishGate, RaceModule.GetWorldCFrameAtDistance(raceStartPoint.CFrame, raceTrackDistanceValue.Value))
end

--// RacePanel player icons
local playerPanelIcons = {}

panelIconTemplate.Visible = false

local function getPlayerPanelData(targetPlayer)
	local targetPlayerData = targetPlayer:FindFirstChild("PlayerData")
	local targetRaceData = targetPlayerData and targetPlayerData:FindFirstChild("RaceData")
	
	if not targetRaceData then return nil end
	
	local targetStage = targetRaceData:FindFirstChild("Stage")
	local targetRoadLevel = targetRaceData:FindFirstChild("RoadLevel")
	local targetLapDistance = targetPlayer:FindFirstChild("RaceLapDistance")
	local targetInRace = targetPlayer:FindFirstChild("InRace")
	
	if not targetStage or not targetRoadLevel or not targetLapDistance or not targetInRace then return nil end
	
	return {
		Stage = targetStage,
		RoadLevel = targetRoadLevel,
		LapDistance = targetLapDistance,
		InRace = targetInRace,
	}
end

local function createPlayerPanelIcon(targetPlayer)
	local icon = panelIconTemplate:Clone()
	
	icon.Name = "PlayerIcon_" .. targetPlayer.UserId
	icon.Image = ""
	icon.Visible = true
	icon.Parent = racePanel
	
	playerPanelIcons[targetPlayer] = icon
	
	task.spawn(function()
		local image = getThumbnail(targetPlayer.UserId)
		
		if playerPanelIcons[targetPlayer] == icon and icon.Parent then
			icon.Image = image
		end
	end)
	
	return icon
end

local function removePlayerPanelIcon(targetPlayer)
	local icon = playerPanelIcons[targetPlayer]
	
	if icon then
		icon:Destroy()
		playerPanelIcons[targetPlayer] = nil
	end
end

local function updatePlayerPanelIcons()
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local data = getPlayerPanelData(targetPlayer)
		
		if data and data.InRace.Value then
			local icon = playerPanelIcons[targetPlayer] 
				or createPlayerPanelIcon(targetPlayer)
			
			local point = RaceModule.GetPlayerPanelPoint(
				data.Stage.Value, data.RoadLevel.Value, data.LapDistance.Value
			)
			
			local line = panelLines[point.LineIndex]
			
			if line then
				icon.Position = UDim2.new( 
					line.Position.X.Scale + line.Size.X.Scale * point.Progress, 
					line.Position.X.Offset + line.Size.X.Offset * point.Progress,
					line.Position.Y.Scale,
					line.Position.Y.Offset
				)
			end
		else
			removePlayerPanelIcon(targetPlayer)
		end
	end
	
	for targetPlayer in pairs(playerPanelIcons) do
		if not targetPlayer.Parent then
			removePlayerPanelIcon(targetPlayer)
		end
	end
end

--// Optional RacePabel reward and finish icons
local panelRewardTemplate = racePanel:FindFirstChild("RewardIcon")
local panelFinishTemplate = racePanel:FindFirstChild("FinishIcon")
local panelMarkers = {}

if panelRewardTemplate then
	panelRewardTemplate.Visible = false
end

if panelFinishTemplate then
	panelFinishTemplate.Visible = false
end

local function clearPanelMarkers()
	for _, marker in ipairs(panelMarkers) do
		marker:Destroy()
	end
	
	panelMarkers = {}
end

local function positionPanelObject(object, point)
	local line = panelLines[point.LineIndex]
	
	if not line then return end 
	
	object.Position = UDim2.new( 
		line.Position.X.Scale + line.Size.X.Scale * point.Progress,
		line.Position.X.Offset + line.Size.X.Offset * point.Progress,
		line.Position.Y.Scale,
		line.Position.Y.Offset
	)
end

local function rebuildPanelMarkers()
	clearPanelMarkers()
	
	if not panelRewardTemplate then return end 
	
	local rewardCount = RaceModule.GetRewardCount(stageValue.Value, roadLevelValue.Value)
	
	for rewardIndex = 1, rewardCount do
		local marker = panelRewardTemplate:Clone()
		marker.Name = "RewardMarker_R" .. rewardIndex
		marker.Visible = true
		marker.Parent = racePanel
		
		local numberLabel = findDescendant(marker, "RewardNumber")
		
		if numberLabel and numberLabel:IsA("TextLabel") then
			numberLabel.Text = "R" .. rewardIndex
		end
		
		positionPanelObject(marker, RaceModule.GetRewardPanelPoint( 
			stageValue.Value, roadLevelValue.Value, rewardIndex
		))
		
		table.insert(panelMarkers, marker)
	end
	
	if panelFinishTemplate then
		local finishMarker = panelFinishTemplate:Clone()
		finishMarker.Name = "FinishMarker"
		finishMarker.Visible = true
		finishMarker.Parent = racePanel
		
		positionPanelObject(
			finishMarker, RaceModule.GetPanelPointByAlpha(stageValue.Value, roadLevelValue.Value, 1)
		)
		table.insert(panelMarkers, finishMarker)
	end
end

--// Top 1-3
local topThumbnailCache = {}

local function updateRaceTop()
	for place = 1, #topImages do
		local userIdValue = raceTopData:FindFirstChild("Top" .. place .. "UserId")
		local distanceValue = raceTopData:FindFirstChild("Top" .. place .. "Distance")
		
		local userId = userIdValue and userIdValue.Value or 0
		local distance = distanceValue and distanceValue.Value or 0
		
		if userId > 0 then
			local image = topThumbnailCache[userId]
			
			if not image then
				image = getThumbnail(userId)
				topThumbnailCache[userId] = image
			end
			
			topImages[place].Image = image
			topImages[place].Visible = true
			topRecordLabels[place].Text = formatDistance(distance)
			topRecordLabels[place].Visible = true
		else
			topImages[place].Image = ""
			topImages[place].Visible = false
			topRecordLabels[place].Text = ""
			topRecordLabels[place].Visible = false
		end
	end
end

--// Reward preview
local selectedRewardIndex = 1
local previewCache = {}
local previewRequestsInProgress = false

local function getFallbackRewardPreview(rewardIndex, rewardLevel)
	local success, reward = pcall( 
		RaceModule.calculateFinalReward, rewardIndex, stageValue.Value, rewardLevel, {}
	)
	
	if success and reward then return reward end
	
	local baseReward = RaceModule.GetBaseReward(rewardIndex) or {}
	local multiplier = RaceModule.GetStageRewardMultiplier(stageValue.Value) 
		* RaceModule.GetRewardBonus(rewardLevel)
	
	return {
		Money = math.floor((tonumber(baseReward.Money) or 0) * multiplier),
		Gems = math.floor((tonumber(baseReward.Gems) or 0) * multiplier),
		XP = (tonumber(baseReward.XP) or 0) * multiplier,
		RaceTouch = tonumber(baseReward.RaceTouch) or 1,
		GemChance = RaceModule.Settings.BaseGemChance,
	}
end

local function getRewardPreview(rewardIndex)
	local cached = previewCache[rewardIndex]
	if cached then return cached end
	
	local currentReward = getFallbackRewardPreview(rewardIndex, rewardLevelValue.Value)
	local nextReward = getFallbackRewardPreview(rewardIndex, rewardLevelValue.Value + 1)
	
	return {
		Current = currentReward,
		Next = nextReward,
	}
end

local updateRewardDetail

local function requestServerPreview()
	if not racePreviewFunction or previewRequestsInProgress then return end 
	
	previewRequestsInProgress = true
	
	task.spawn(function()
		local success, result = pcall(racePreviewFunction.InvokeServer, racePreviewFunction)
		
		if success and type(result) == "table" then
			previewCache = result
			
			if updateRewardDetail then
				task.defer(updateRewardDetail)
			end
		end
		
		previewRequestsInProgress = false
	end)
end

local function clearRewardPreviewCache()
	previewCache = {}
	requestServerPreview()
end

--// Reward detail UI
updateRewardDetail = function()
	local stageCap = RaceModule.GetRewardLevelCap(stageValue.Value)
	local localRewardLevel = RaceModule.GetLocalRewardLevel(stageValue.Value, rewardLevelValue.Value)
	local preview = getRewardPreview(selectedRewardIndex)
	local current = preview.Current or {}
	local nextReward = preview.Next or current
	
	setText(rewUpgBonus, formatMultiplier(RaceModule.GetRewardBonus(rewardLevelValue.Value)))
	setText(rewUpgLevel, localRewardLevel .. "/5")
	setText(rewCurNumber, "R" .. selectedRewardIndex)
	
	setBarScale(rewLvlBar, RaceModule.GetRewardLevelBarScale(stageValue.Value, rewardLevelValue.Value))
	
	setText(rewCurUpgMoney, "+" .. formatNumber(current.Money or 0))
	setText(rewCurUpgGems, formatNumber((current.GemChance or 0) * 100) .. "% / +" .. formatNumber(current.Gems or 0))
	setText(rewCurUpgXP, "+" .. formatNumber(current.XP or 0))
	
	if rewardLevelValue.Value < stageCap then
		setText(rewNextUpgMoney, "+" .. formatNumber(nextReward.Money or 0))
		setText(rewNextUpgGems, formatNumber((nextReward.GemChance or 0) * 100) .. "% / +" .. formatNumber(nextReward.Gems or 0))
		setText(rewNextUpgXP, "+" .. formatNumber(nextReward.XP or 0))
	else 
		setText(rewNextUpgMoney, "MAX")
		setText(rewNextUpgGems, "MAX")
		setText(rewNextUpgXP, "MAX")
	end
end

--// Reward buttons on RewardBar
local rewardButtons = {}

rewardButtonTemplate.Visible = false

local function clearRewardButtons()
	for _, button in ipairs(rewardButtons) do 
		button:Destroy()
	end
	rewardButtons = {}
end

local function updateRewardButtonPrice(button)
	local rewardFrame = button:FindFirstChild("RewardFrame")
	if not rewardFrame then return end
	
	local currentNumber = rewardFrame:FindFirstChild("RewCurNumber")
	local requiredMoney = rewardFrame:FindFirstChild("RewRequirMoney")
	local requiredRaceTouch = rewardFrame:FindFirstChild("RewRequirRaceTouch")
	local requiredXP = rewardFrame:FindFirstChild("RewRequirXp")
	
	local targetLevel = rewardLevelValue.Value + 1
	local stageCap = RaceModule.GetRewardLevelCap(stageValue.Value)
	local price = RaceModule.GetRewardUpgradePrice(targetLevel)
	
	setText(currentNumber, button:GetAttribute("RewardName") or "R1")
	
	if rewardLevelValue.Value >= stageCap or not price then
		setText(requiredMoney, "MAX")
		setText(requiredRaceTouch, "MAX")
		setText(requiredXP, "MAX")
	else 
		setText(requiredMoney, formatNumber(price.Money))
		setText(requiredRaceTouch, formatNumber(price.RaceTouch))
		setText(requiredXP, formatNumber(price.XP))
	end
end

local function rebuildRewardButtons()
	clearRewardButtons()
	
	local rewardCount = RaceModule.GetRewardCount(stageValue.Value, roadLevelValue.Value)
	
	selectedRewardIndex = math.clamp(selectedRewardIndex, 1, rewardCount)
	
	for rewardIndex = 1, rewardCount do 
		local button = rewardButtonTemplate:Clone()
		button.Name = "RewardButton_R" .. rewardIndex
		button:SetAttribute("RewardIndex", rewardIndex)
		button:SetAttribute("RewardName", "R" .. rewardIndex)
		button.Visible = true
		button.Parent = rewardButtonTemplate.Parent
		
		local positionScale = RaceModule.GetRewardBarPosition(stageValue.Value, roadLevelValue.Value, rewardIndex)
		
		button.Position = UDim2.new( 
			rewardBar.Position.X.Scale + positionScale,
			rewardBar.Position.X.Offset,
			button.Position.Y.Scale,
			button.Position.Y.Offset
		)
		
		updateRewardButtonPrice(button)
		
		button.MouseButton1Click:Connect(function()
			selectedRewardIndex = rewardIndex
			updateRewardDetail()
		end)
		
		local rewardFrame = button:FindFirstChild("RewardFrame")
		local upgradeButton = rewardFrame and rewardFrame:FindFirstChild("RewUpgrade")
		
		if upgradeButton and upgradeButton:IsA("GuiButton") then
			upgradeButton.MouseButton1Click:Connect(function()
				selectedRewardIndex = rewardIndex
				raceActionEvent:FireServer("UpgradeReward")
			end)
		end
		table.insert(rewardButtons, button)
	end
end

local function updateAllRewardButtonPrices()
	for _, button in ipairs(rewardButtons) do
		updateRewardButtonPrice(button)
	end
end

--// Road upgrade UI
local function updateRoadUpgradeDetail()
	local stage = stageValue.Value
	local level = roadLevelValue.Value
	local rewardCount = RaceModule.GetRewardCount(stage, level)
	local trackDistance = RaceModule.GetTrackDistance(stage, level)
	local price = RaceModule.GetRoadUpgradePrice(stage, level)
	local preview = RaceModule.GetNextProgressionPreview(stage, level)
	
	setText(roadLevelNumber, level .. "/5")
	setBarScale(roadLevelBar, RaceModule.GetRoadLevelBarScale(level))
	
	setText(currentRewardNumber, rewardCount)
	setText(currentDistanceNumber, formatDistance(trackDistance))
	
	if preview then
		setText(nextRewardNumber, preview.RewardCount)
		setText(nextDistanceNumber, formatDistance(preview.Distance))
	else 
		setText(nextRewardNumber, "MAX")
		setText(nextDistanceNumber, "MAX")
	end
	
	if price then
		setText(roadUpgradePrice, formatNumber(price))
		roadUpgradeButton.Active = true
		roadUpgradeButton.AutoButtonColor = true
	else 
		setText(roadUpgradePrice, "MAX")
		roadUpgradeButton.Active = false
		roadUpgradeButton.AutoButtonColor = false
	end
end

--/ Stage sumary and detail UI
local function updateStageInformation()
	local stage = stageValue.Value
	local level = roadLevelValue.Value
	local stageName = RaceModule.GetStageName(stage)
	local stageIcon = RaceModule.GetStageIcon(stage)
	local stageBonus = RaceModule.GetStageRewardMultiplier(stage)
	local distance = RaceModule.GetTrackDistance(stage, level)
	
	setImage(summaryStageIcon, stageIcon)
	setText(summaryStageBonus, formatMultiplier(stageBonus))
	setText(summaryStageDistance, formatDistance(distance))
	setText(summaryStageName, stageName)
	
	setImage(detailStageIcon, stageIcon)
	setText(detailStageBonus, formatMultiplier(stageBonus))
	setText(detailStageLevel, stage .. "/5")
	setText(detailStageName, stageName)
	setBarScale(detailStageBar, RaceModule.GetStageLevelBarScale(stage))
	
	setText(rewMultNumber, formatMultiplier(RaceModule.GetRewardBonus(rewardLevelValue.Value)))
	setText(summaryUpgradeLevel, level .. "/5")
	setText(summaryUpgradeRewards, RaceModule.GetRewardCount(stage, level) .. "/" .. (stage + 5))
end

--// StageMenuUI
local function getStageCurrentValues()
	return {
		Level = roadLevelValue.Value,
		Money = moneyValue.Value,
		RaceTouch = raceTouchValue.Value,
		Rebirth = rebirthValue.Value,
		Energy = energyValue.Value,
	}
end

local function setRequirementText(label, current, required)
	setText(label, formatNumber(current) .. "/" .. formatNumber(required))
end

local function updateStageMenu()
	local stage = stageValue.Value
	local currentConfig = RaceModule.GetStageConfig(stage)
	local nextConfig = RaceModule.Stages[stage + 1]
	local requirements = RaceModule.GetNextStageRequirements(stage)
	
	setImage(stageCurrentIcon, currentConfig.Icon)
	setText(stageCurrentBoost, formatMultiplier(currentConfig.RewardMultiplier))
	
	if not nextConfig or not requirements then
		setImage(stageNextIcon, "")
		setText(stageNextBoost, "MAX")
		setText(stageRequiredLevel, "MAX")
		setText(stageRequiredRaceTouch, "MAX")
		setText(stageRequiredMoney, "MAX")
		setText(stageRequiredRebirth, "MAX")
		setText(stageRequiredEnergy, "MAX")
		setText(stageRequirementPercent, "100%")
		setBarScale(stageRequirementBar, RaceModule.UI.Bars.StageRequirementMaxScale)
		
		stageUpButton.Active = false
		stageUpButton.AutoButtonColor = false
		return
	end
	
	setImage(stageNextIcon, nextConfig.Icon)
	setText(stageNextBoost, formatMultiplier(nextConfig.RewardMultiplier))
	
	local currentValues = getStageCurrentValues()
	local progressData = RaceModule.GetStageRequirementProgress(stage, currentValues)
	
	setRequirementText(stageRequiredLevel, currentValues.Level, requirements.Level)
	setRequirementText(stageRequiredRaceTouch, currentValues.RaceTouch, requirements.RaceTouch)
	setRequirementText(stageRequiredMoney, currentValues.Money, requirements.Money)
	setRequirementText(stageRequiredRebirth, currentValues.Rebirth, requirements.Rebirth)
	setRequirementText(stageRequiredEnergy, currentValues.Energy, requirements.Energy)
	
	setText(stageRequirementPercent, progressData.Percent .. "%")
	setBarScale(stageRequirementBar, RaceModule.GetStageRequirementBarScale(progressData.Progress))
	
	stageUpButton.Active = progressData.CanStageUp
	stageUpButton.AutoButtonColor = progressData.CanStageUp
end

--// Balances
local function updateBalances()
	setText(moneyLead, formatNumber(moneyValue.Value))
	setText(raceTouchLead, formatNumber(raceTouchValue.Value))
	setText(xpLead, formatNumber(xpValue.Value))
	setText(raceRecordLabel, formatDistance(raceRecordValue.Value))
	
	setText(stageEnergyLead, formatNumber(energyValue.Value))
	setText(stageMoneyLead, formatNumber(moneyValue.Value))
	setText(stageRaceTouchLead, formatNumber(raceTouchValue.Value))
	setText(stageRebirthLead, formatNumber(rebirthValue.Value))
end

--// Detail section switching
local detailFrames = {
	Reward = frameRewardDetail,
	Stage = frameStageDetail,
	Upgrade = frameUpgradeDetail,
}

local detailNames = {
	Reward = "REWARD DETAILS",
	Stage = "STAGE DETAILS",
	Upgrade = "UPGRADE DETAILS",
}

local function openDetail(detailName)
	for name, frame in pairs(detailFrames) do
		frame.Visible = name == detailName
	end
	
	setText(nameDetails, detailNames[detailName] or "")
	
	if detailName == "Reward" then
		updateRewardDetail()
	elseif detailName == "Stage" then
		updateStageInformation()
	elseif detailName == "Upgrade" then
		updateRoadUpgradeDetail()
	end
end

--// StageMenu opening and arrow animation
local function openStageMenu()
	raceHostBlur.Visible = true
	stageMenu.Visible = true
	leaderstatsMenu.Visible = true
	updateStageMenu()
end

local function closeStageMenu()
	stageMenu.Visible = false
	leaderstatsMenu.Visible = false
	raceHostBlur.Visible = false
end

--// Warning label
local warningSequence = 0

local function showWarning(message)
	warningSequence += 1
	local sequence = warningSequence
	
	raceWarningLabel.Text = tostring(message)
	raceWarningLabel.TextTransparency = 0
	raceWarningLabel.Visible = true
	
	task.delay(2.5, function()
		if sequence ~= warningSequence then return end 
		
		local tween = TweenService:Create(raceWarningLabel, TweenInfo.new(0.5), {TextTransparency = 1})
		
		tween:Play()
		tween.Completed:Once(function()
			if sequence == warningSequence then
				raceWarningLabel.Visible = false
			end
		end)
	end)
end

--// Full menu refresh
local function refreshMenu()
	updateBalances()
	updateStageInformation()
	updateRoadUpgradeDetail()
	updateRewardDetail()
	updateAllRewardButtonPrices()
	
	if stageMenu.Visible then
		updateStageMenu()
	end
end

local function rebuildProgressionUI()
	clearRewardPreviewCache()
	refreshMenu()
	rebuildRewardButtons()
	rebuildPanelMarkers()
	
	if inRaceValue.Value then
		rebuildLocalGates()
	end
end

--// Button connections
if leaveButton and leaveButton:IsA("GuiButton") then
	leaveButton.MouseButton1Click:Connect(function()
		leaveRaceEvent:FireServer()
	end)
end

raceMenuClose.MouseButton1Click:Connect(function()
	closeStageMenu()
	raceHost.Visible = false
end)

rewardDetailsButton.MouseButton1Click:Connect(function()
	openDetail("Reward")
end)

stageDetailsButton.MouseButton1Click:Connect(function()
	openDetail("Stage")
end)

upgradeDetailsButton.MouseButton1Click:Connect(function()
	openDetail("Upgrade")
end)

roadUpgradeButton.MouseButton1Click:Connect(function()
	raceActionEvent:FireServer("UpgradeRoad")
end)

stageMenuOpen.MouseButton1Click:Connect(openStageMenu)
stageClose.MouseButton1Click:Connect(closeStageMenu)

stageUpButton.MouseButton1Click:Connect(function()
	raceActionEvent:FireServer("StageUp")
end)

--// Value connections
raceStatusText.Changed:Connect(updateTimer)
raceTimerText.Changed:Connect(updateTimer)

inRaceValue.Changed:Connect(function()
	updateRaceVisibility()
	
	if inRaceValue.Value then
		rebuildLocalGates()
	else 
		destroyLocalGates()
	end
end)

raceSpeedValue.Changed:Connect(updateSpeedometer)
raceTargetSpeedValue.Changed:Connect(updateSpeedometer)
energyValue.Changed:Connect(function()
	updateSpeedometer()
	updateBalances()
	updateStageMenu()
end)

stageValue.Changed:Connect(rebuildProgressionUI)
roadLevelValue.Changed:Connect(rebuildProgressionUI)
rewardLevelValue.Changed:Connect(function()
	clearRewardPreviewCache()
	refreshMenu()
	updateAllRewardButtonPrices()
end)

moneyValue.Changed:Connect(function()
	updateBalances()
	updateStageMenu()
end)

raceTouchValue.Changed:Connect(function()
	updateBalances()
	updateStageMenu()
end)

xpValue.Changed:Connect(function()
	updateBalances()
	clearRewardPreviewCache()
end)

rebirthValue.Changed:Connect(function()
	updateBalances()
	updateStageMenu()
	clearRewardPreviewCache()
end)

raceRecordValue.Changed:Connect(updateBalances)

for place = 1, RaceModule.Settings.TopPlayerCount do 
	raceTopData:WaitForChild("Top" .. place .. "UserId").Changed:Connect(updateRaceTop)
	raceTopData:WaitForChild("Top" .. place .. "Distance").Changed:Connect(updateRaceTop)
end

raceWarningEvent.OnClientEvent:Connect(showWarning)

raceActionResultEvent.OnClientEvent:Connect(function(_, success)
	if success then
		task.defer(rebuildProgressionUI)
	end
end)

raceHost:GetPropertyChangedSignal("Visible"):Connect(function()
	if raceHost.Visible then
		clearRewardPreviewCache()
		refreshMenu()
	end
end)

Players.PlayerRemoving:Connect(removePlayerPanelIcon)

--// Stage arrow animation
task.spawn(function()
	while true do
		if stageMenu.Visible then
			stageArrowIcon.Position = RaceModule.UI.StageArrow.StartPosition
			
			local forwardTween = TweenService:Create( 
				stageArrowIcon,
				TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Position = RaceModule.UI.StageArrow.EndPosition}
			)
			
			forwardTween:Play()
			forwardTween.Completed:Wait()
			
			if stageMenu.Visible then
				local backwardTween = TweenService:Create( 
					stageArrowIcon,
					TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{Position = RaceModule.UI.StageArrow.StartPosition}
				)
				
				backwardTween:Play()
				backwardTween.Completed:Wait()
			end
		else 
			task.wait(0.15)
		end
	end
end)

--// Periodic preview refresh
task.spawn(function()
	while true do
		task.wait(2)
		
		if raceHost.Visible then
			clearRewardPreviewCache()
			updateRewardDetail()
		end
	end
end)

--// Render update
RunService.RenderStepped:Connect(function()
	updatePlayerPanelIcons()
end)

--// Start
raceHostBlur.Visible = false
stageMenu.Visible = false
leaderstatsMenu.Visible = false
raceWarningLabel.Visible = false

setSpeedometerVisible(false)
openDetail("Reward")

updateTimer()
updateRaceVisibility()
updateSpeedometer()
updateRaceTop()

rebuildRewardButtons()
rebuildPanelMarkers()
refreshMenu()
requestServerPreview()

print("RaceUI 1.3 loaded")
