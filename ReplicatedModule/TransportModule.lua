local TransportModule = {}

--// GLOBAL CONFIG
TransportModule.MAX_LEVEL = 25
TransportModule.MAX_STAGE = 5

TransportModule.DEFAULT_LOCATION = "Location1"
TransportModule.DEFAULT_TRANSPORT = "Feet"

--// STAGES
TransportModule.Stages = {
	[1] = {Name = "Stage 1", MinLevel = 0, MaxLevel = 5, BoostMultiplier = 1.00,
	    Icons = {Default = "", Selected = "",},},
	[2] = {Name = "Stage 2", MinLevel = 6, MaxLevel = 10, BoostMultiplier = 1.10,
		Icons = {Default = "", Selected = "",},},
	[3] = {Name = "Stage 3", MinLevel = 11, MaxLevel = 15, BoostMultiplier = 1.20,
		Icons = {Default = "", Selected = "",},},
	[4] = {Name = "Stage 4", MinLevel = 16, MaxLevel = 20, BoostMultiplier = 1.30,
		Icons = {Default = "", Selected = "",},},
	[5] = {Name = "Stage 5", MinLevel = 21, MaxLevel = 25, BoostMultiplier = 1.40,
		Icons = {Default = "", Selected = "",},},
}

--// TRANSPORT CONFIG
TransportModule.Locations = {
	StoneAge = {
		Id = "StoneAge",
		Name = "Stone Age",
		
		Icons = {
			Default = "",
			Selected = "",
		},
		
		TransportOrder = {
			"Feet",
			"Log",
			"Stone",
		},
		
		Transports = {
			Feet = {
				Id = "Feet",
				Name = "Feet",
				Order = 1,
				
				DefaultUnlocked = true,
				DefaultOwned = true,
				DefaultEquipped = true,
				
				Purchasable = false,
				
				Visual = {
					ModelName = nil,
					
					Viewport = {
						Rotation = Vector3.new(0, 0, 0),
						CameraDistance = 7,
						CameraHight = 1,
					},
				},
				
				Icons = {
					Default = "",
					Selected = "",
					Locked = "",
				},
				
				PurchasePrice = {},
				
				LevelPrice = {
					{FromLevel = 1, ToLevel = 5, StartPrice = {Money = 50, RaceTouch = 5, XP = 25,}, EndPrice = {Money = 100, RaceTouch = 20, XP = 75,},},
					{FromLevel = 6, ToLevel = 10, StartPrice = {Money = 100, RaceTouch = 20, XP = 100}, EndPrice = {Money = 200, RaceTouch = 40, XP = 200},},
					{FromLevel = 11, ToLevel = 15, StartPrice = {Money = 200, RaceTouch = 40, XP = 200}, EndPrice = {Money = 300, RaceTouch = 60, XP = 300},},
					{FromLevel = 16, ToLevel = 20, StartPrice = {Money = 300, RaceTouch = 60, XP = 300}, EndPrice = {Money = 400, RaceTouch = 80, XP = 400},},
					{FromLevel = 21, ToLevel = 25, StartPrice = {Money = 400, RaceTouch = 80, XP = 400}, EndPrice = {Money = 500, RaceTouch = 100, XP = 500},},
				},
			},
		},
		
		LevelBoost = {
			{FromLevel = 0, ToLevel = 5, StartRacePower = 1, EndRacePower = 5, StartAcceleration = 2, EndAcceleration = 10,},
			{FromLevel = 6, ToLevel = 10, StartRacePower = 5, EndRacePower = 10, StartAcceleration = 10, EndAcceleration = 20,},
			{FromLevel = 11, ToLevel = 15, StartRacePower = 10, EndRacePower = 20, StartAcceleration = 20, EndAcceleration = 30,},
			{FromLevel = 16, ToLevel = 20, StartRacePower = 20, EndRacePower = 30, StartAcceleration = 30, EndAcceleration = 40,},
			{FromLevel = 21, ToLevel = 25, StartRacePower = 30, EndRacePower = 40, StartAcceleration = 40, EndAcceleration = 50,},	
		},
		
		StageUp = {
			[1] = {RequiredLevel = 5,
				Cost = {
					Money = 500,
					RaceTouch = 50,
					Distance = 1000,
				},
			},
			
			[2] = {RequiredLevel = 10,
				Cost = { 
					Money = 1000,
					RaceTouch = 100,
					Distance = 2000,
				},
			},
			
			[3] = {RequiredLevel = 15,
				Cost = {
					Money = 1500,
					RaceTouch = 150,
					Distance = 3000,
				},
			},
			
			[4] = {RequiredLevel = 20,
				Cost = {
					Money = 2000,
					RaceTouch = 200,
					Distance = 4000,
				},
			},
		},
	},
	
	Log = {
		Id = "Log",
		Name = "Log",
		Order = 2,
		
		DefaultUnlocked = false,
		DefaultOwned = false,
		DefaultEquipped = false,
		
		Purchasable = true,
		
		Unlock = {
			PreviousTransport = "Feet",
			RequiredStage = 5,
			RequiredLevel = 25,
		},
		
		Visual = {
			ModelName = "Log",
			
			Viewport = {
				Rotation = Vector3.new(0, 0, 0),
				CameraDistance = 7,
				CameraHeight = 1,
			},
		},
		
		Icons = {
			Default = "",
			Selected = "",
			Locked = "",
		},
		
		PurchasePrice = {Money = 5000, RaceTouch = 500,},
		
		LevelPrice = {
			{FromLevel = 1, ToLevel = 5, StartPrice = {Money = 500, RaceTouch = 50, XP = 50,}, EndPrice = {Money = 1000, RaceTouch = 100, XP = 100,},},
			{FromLevel = 6, ToLevel = 10, StartPrice = {Money = 1000, RaceTouch = 100, XP = 100,}, EndPrice = {Money = 2000, RaceTouch = 200, XP = 200,},},
			{FromLevel = 11, ToLevel = 15, StartPrice = {Money = 2000, RaceTouch = 200, XP = 200,}, EndPrice = {Money = 3000, RaceTouch = 300, XP = 300,},},
			{FromLevel = 16, ToLevel = 20, StartPrice = {Money = 3000, RaceTouch = 300, XP = 300,}, EndPrice = {Money = 4000, RaceTouch = 400, XP = 400,},},
			{FromLevel = 21, ToLevel = 25, StartPrice = {Money = 4000, RaceTouch = 400, XP = 400,}, EndPrice = {Money = 5000, RaceTouch = 500, XP = 500,},},
		},
		
		LevelBoost = {
			{FromLevel = 1, ToLevel = 5, StartRacePower = 1, EndRacePower = 5, StartAcceleration = 2, EndAcceleration = 10,},
			{FromLevel = 6, ToLevel = 10, StartRacePower = 5, EndRacePower = 10, StartAcceleration = 10, EndAcceleration = 20,},
			{FromLevel = 11, ToLevel = 15, StartRacePower = 10, EndRacePower = 15, StartAcceleration = 20, EndAcceleration = 30,},
			{FromLevel = 16, ToLevel = 20, StartRacePower = 15, EndRacePower = 20, StartAcceleration = 30, EndAcceleration = 40,},
			{FromLevel = 21, ToLevel = 25, StartRacePower = 20, EndRacePower = 25, StartAcceleration = 40, EndAcceleration = 50,},
		},
		
		StageUp = {
			[1] = {RequiredLevel = 5,
				Cost = {
					Money = 500,
					RaceTouch = 50,
					Distance = 1000,
				},
			},

			[2] = {RequiredLevel = 10,
				Cost = { 
					Money = 1000,
					RaceTouch = 100,
					Distance = 2000,
				},
			},

			[3] = {RequiredLevel = 15,
				Cost = {
					Money = 1500,
					RaceTouch = 150,
					Distance = 3000,
				},
			},

			[4] = {RequiredLevel = 20,
				Cost = {
					Money = 2000,
					RaceTouch = 200,
					Distance = 4000,
				},
			},
		},
	},
	
	Stone = {
		Id = "Stone", 
		Name = "Stone",
		Order = 3,
		
		DefaultUnlocked = false,
		DefaultOwned = false,
		DefaultEquipped = false,
		
		Purchasable = true,
		
		Unlock = {
			PreviousTransport = "Log",
			RequiredStage = 5,
			RequiredLevel = 25,
		},
		
		Visual = {
			ModelName = "Stone",
			
			Viewport = {
				Rotation = Vector3.new(0, 0, 0),
				CameraDistance = 7,
				CameraHeight = 1,
			},
		},
		
		Icons = {
			Default = "",
			Selected = "",
			Locked = "",
		},
		
		PurchasePrice = {Money = 25000, RaceTouch = 2500,},
		
		LevelPrice = {
			{FromLevel = 1, ToLevel = 5, StartPrice = {Money = 500, RaceTouch = 50, XP = 250,}, EndPrice = {Money = 1000, RaceTouch = 100, XP = 500},},
			{FromLevel = 6, ToLevel = 10, StartPrice = {Money = 1000, RaceTouch = 100, XP = 500,}, EndPrice = {Money = 2000, RaceTouch = 200, XP = 1000},},
			{FromLevel = 11, ToLevel = 15, StartPrice = {Money = 2000, RaceTouch = 200, XP = 1000,}, EndPrice = {Money = 3000, RaceTouch = 300, XP = 1500},},
			{FromLevel = 16, ToLevel = 20, StartPrice = {Money = 3000, RaceTouch = 300, XP = 1500,}, EndPrice = {Money = 4000, RaceTouch = 400, XP = 2000},},
			{FromLevel = 21, ToLevel = 25, StartPrice = {Money = 4000, RaceTouch = 400, XP = 2000,}, EndPrice = {Money = 5000, RaceTouch = 500, XP = 2500},},
		},
		
		LevelBoost = {
			{FromLevel = 1, ToLevel = 5, StartRacePower = 1, EndRacePower = 5, StartAcceleration = 2, EndAcceleration = 10,},
			{FromLevel = 6, ToLevel = 10, StartRacePower = 5, EndRacePower = 10, StartAcceleration = 10, EndAcceleration = 20,},
			{FromLevel = 11, ToLevel = 15, StartRacePower = 10, EndRacePower = 15, StartAcceleration = 20, EndAcceleration = 30,},
			{FromLevel = 16, ToLevel = 20, StartRacePower = 15, EndRacePower = 20, StartAcceleration = 30, EndAcceleration = 40,},
			{FromLevel = 21, ToLevel = 25, StartRacePower = 20, EndRacePower = 25, StartAcceleration = 40, EndAcceleration = 50,},
		},
		
		StageUp = {
			[1] = {RequiredLevel = 5,
				Cost = {
					Money = 500,
					RaceTouch = 50,
					Distance = 1000,
				},
			},

			[2] = {RequiredLevel = 10,
				Cost = { 
					Money = 1000,
					RaceTouch = 100,
					Distance = 2000,
				},
			},

			[3] = {RequiredLevel = 15,
				Cost = {
					Money = 1500,
					RaceTouch = 150,
					Distance = 3000,
				},
			},

			[4] = {RequiredLevel = 20,
				Cost = {
					Money = 2000,
					RaceTouch = 200,
					Distance = 4000,
				},
			},
		},
	},
}

--// INTERNAL HELPER
local function deepCopy(value)
	if type(value) ~= "table" then return value end
	
	local result = {}
	
	for key, child in pairs(value) do
		result[key] = deepCopy(child)
	end
	return result
end

local function lerp(startValue, endValue, alpha)
	return startValue + (endValue - startValue) * alpha
end

local function getRangeAlpha(level, fromLevel, toLevel)
	if toLevel <= fromLevel then return 0 end
	
	return math.clamp((level - fromLevel) / (toLevel - fromLevel), 0, 1)
end

local function interpolateResources(startValues, endValues, alpha)
	local result = {}
	local resources = {}
	
	for resourceName in pairs(startValues or {}) do
		resources[resourceName] = true
	end
	
	for resourceName in pairs(endValues or {}) do
		resources[resourceName] = true 
	end
	
	for resourceName in pairs(resources) do
		local startValue = (startValues and startValues[resourceName]) or 0
		local endValue = (endValues and endValues[resourceName]) or startValue
		
		result[resourceName] = lerp(startValue, endValue, alpha)
	end
	return result
end

local function clampProgress(current, required)
	if not required or required <= 0 then return 1 end
	
	return math.clamp(current / required, 0, 1)
end

--// LOCATION
function TransportModule.GetLocation(locationId)
	return TransportModule.Locations[locationId]
end

function TransportModule.GetTransportOrder(locationId)
	local location = TransportModule.GetLocation(locationId)
	if not location then return nil end
	
	return location.TransportOrder
end

--// TRANSPORT
function TransportModule.GetTransport(locationId, transportId)
	local location = TransportModule.GetLocation(locationId)
	if not location then return nil end
	
	return location.Transports[transportId]
end

function TransportModule.GetDefaultTransport(locationId)
	locationId = locationId or TransportModule.DEFAULT_LOCATION
	
	return TransportModule.GetTransport(locationId, TransportModule.DEFAULT_TRANSPORT)
end

function TransportModule.GetNextTransport(locationId, transportId)
	local location = TransportModule.GetLocation(locationId)
	local transport = TransportModule.GetTransport(locationId, transportId)
	
	if not location or not transport then return nil end
	
	local nextId = location.TransportOrder[transport.Order + 1]
	if not nextId then return nil end
	
	return location.Transports[nextId], nextId
end

function TransportModule.GetPreviousTransport(locationId, transportId)
	local location = TransportModule.GetLocation(locationId)
	local transport = TransportModule.GetTransport(locationId, transportId)

	if not location or not transport then return nil end
	
	local previousId = location.TransportOrder[transport.Order - 1]
	if not previousId then return nil end
	
	return location.Transports[previousId], previousId
end

--// UNLOCK
function TransportModule.GetUnlockedRequirements(locationId, transportId)
	local transport = TransportModule.GetTransport(locationId, transportId)
	if not transport then return nil end
	
	return deepCopy(transport.Unlock)
end

function TransportModule.CanUnlockTransport(locationId, transportId, previousLevel, previousStage)
	local transport = TransportModule.GetTransport(locationId, transportId)
	if not transport then return false end
	
	if transport.DefaultUnlocked then return true end
	
	local unlock = transport.Unlock
	if not unlock then return false end
	
	if previousStage < (unlock.RequiredStage or 1) then return false end
	if previousLevel < (unlock.RequiredLevel or 0) then return false end
	
	return true 
end

--// PURCHASE
function TransportModule.GetPurchasePrice(locationId, transportId)
	local transport = TransportModule.GetTransport(locationId, transportId)
	if not transport then return nil end
	
	return deepCopy(transport.PurchasePrice)
end

--// STAGE
function TransportModule.GetStage(stageNumber)
	return TransportModule.Stages[stageNumber]
end

function TransportModule.GetStageMaxLevel(stageNumber)
	local stage = TransportModule.GetStage(stageNumber)

	return stage and stage.MaxLevel or nil
end

function GetStageMinLevel(stageNumber)
	local stage = TransportModule.GetStage(stageNumber)
	
	return stage and stage.MinLevel or nil
end

function TransportModule.CanLevelUp(level, stageNumber)
	local stage = TransportModule.GetStage(stageNumber)
	if not stage then return false end
	
	if level >= TransportModule.MAX_LEVEL then return false end
	
	return level < stage.MaxLevel
end

function TransportModule.CanStageUp(level, stageNumber)
	if stageNumber >= TransportModule.MAX_STAGE then return false end 
	
	local stage = TransportModule.GetStage(stageNumber)
	if not stage then return false end
	
	return level >= stage.MaxLevel
end

function TransportModule.IsMaxTransport(level, stageNumber)
	return level >= TransportModule.MAX_LEVEL and stageNumber >= TransportModule.MAX_STAGE
end

--// LEVEL PRICE
function TransportModule.GetLevelPrice(locationId, transportId, targetLevel)
	local transport = TransportModule.GetTransport(locationId, transportId)
	if not transport then return nil end
	
	if targetLevel < 1 or targetLevel > TransportModule.MAX_LEVEL then return nil end
	
	for _, range in ipairs(transport.LevelPrice) do
		if targetLevel >= range.fromLevel and targetLevel <= range.ToLevel then
			local alpha = getRangeAlpha(targetLevel, range.FromLevel, range.ToLevel)
			
			return interpolateResources(range.StartPrice, range.EndPrice, alpha)
		end
	end
	return nil
end

function TransportModule.GetNextLevelPrice(locationId, transportId, currentLevel)
	if currentLevel >= TransportModule.MAX_LEVEL then return nil end
	
	return TransportModule.GetLevelPrice(locationId, transportId, currentLevel + 1)
end

--// LEVEL RESOURCE PROGRESS
function TransportModule.GetLevelResourceProgress(locationId, transportId, currentLevel, currentResources)
	local price = TransportModule.GetNextLevelPrice(locationId, transportId, currentLevel)
	if not price then return nil end
	
	local result = {}
	
	for resourceName, requiredAmount in pairs(price) do
		local currentAmount = currentResources[resourceName] or 0
		
		result[resourceName] = {
			Current = currentAmount,
			Required = requiredAmount,
			
			Missing = math.max(requiredAmount - currentAmount, 0),
			
			Progress = clampProgress(currentAmount, requiredAmount),
			
			Enough = currentAmount >= requiredAmount,
		}
	end
	return result
end

function TransportModule.HasLevelResources(locationId, transportId, currentLevel, currentResources)
	local progress = TransportModule.GetLevelResourceProgress(locationId, transportId, currentLevel, currentResources)
	if not progress then return false end
	
	for _, data in pairs(progress) do
		if not data.Enough then return false end
	end
	return true 
end

--// STAGE UP DATA
function TransportModule.GetStageUpData(locationId, transportId, currentStage)
	local transport = TransportModule.GetTransport(locationId, transportId)
	if not transport then return nil end
	
	if currentStage >= TransportModule.MAX_STAGE then return nil end
	
	local stageUp = transport.StageUp[currentStage]
	if not stageUp then return nil end 
	
	return deepCopy(stageUp)
end

function TransportModule.GetStageUpCost(locationId, transportId, currentStage)
	local data = TransportModule.GetStageUpData(locationId, transportId, currentStage)
	if not data then return nil end
	
	return deepCopy(data.Cost)
end

--// STAGE REQUIREMENT PROGRESS
function TransportModule.GetStageRequirementProgress(locationId, transportId, currentLevel, currentStage, currentResources)
	local data = TransportModule.GetStageUpData(locationId, transportId, currentStage)
	if not data then return nil end
	
	local result = {
		Requirements = {},
		OverallProgress = 0,
		OverallPercent = 0,
		Complete = true,
	}
	
	local totalProgress = 0
	local requirementCount = 0
	local requiredLevel = data.RequiredLevel or 0
	
	local levelProgress = clampProgress(currentLevel, requiredLevel)
	
	result.Requirements.Level = {
		Current = currentLevel,
		Required = requiredLevel,
		
		Missing = math.max(requiredLevel - currentLevel, 0),
		
		Progress = levelProgress,
		Enough = currentLevel >= requiredLevel,
		
		Spend = false
	}
	
	totalProgress += levelProgress
	requirementCount += 1
	
	if currentLevel < requiredLevel then
		result.Complete = false
	end
	
	for resourceName, requiredAmount in pairs(data.Cost or {}) do
		local currentAmount = currentResources[resourceName] or 0
		local progress = clampProgress(currentAmount, requiredAmount)
		
		resulr.Requirements[resourceName] = {
			Current = currentAmount,
			Required = requiredAmount,
			
			Missing = math.max(requiredAmount - currentAmount, 0),
			
			Progress = progress,
			Enough = currentAmount >= requiredAmount,
			
			Spend = true,
		}
		
		totalProgress += progress
		requirementCount += 1
		
		if currentAmount < requiredAmount then
			result.Complete = false
		end
	end
	
	if requirementCount > 0 then
		result.OverallProgress = totalProgress / requirementCount
	else 
		result.OverallProgress = 1
	end
		
	result.OverallProgress = math.clamp(result.OverallProgress, 0, 1)
	result.OverallPercent = math.round(result.OverallProgress * 100)
	
	return result
end

--// BASE BOOST
function TransportModule.GetBaseBoost(locationId, transportId, level)
	local transport = TransportModule.GetTransport(locationId, transportId)
	if not transport then return nil end
	
	level = math.clamp(level or 0, 0, TransportModule.MAX_LEVEL)
	
	for _, range in ipairs(transport.LevelBoost) do
		if level >= range.FromLevel and level <= range.ToLevel then
			local alpha = getRangeAlpha(level, range.FromLevel, range.ToLevel)
			
			return {
				RacePower = lerp(range.StartRacePower, range.EndRacePower, alpha),
				Acceleration = lerp(range.StartAcceleration, range.EndAcceleration, alpha),
			}
		end
	end
	return {RacePower = 0, Acceleration = 0,}
end

--// FINAL BOOST
function TransportModule.GetBoost(locationId, transportId, level, stageNumber)
	local baseBoost = TransportModule.GetBaseBoost(locationId, transportId, level)
	local stage = TransportModule.GetStage(stageNumber)
	
	if not baseBoost or not stage then return nil end
	
	return {
		RacePower = baseBoost.RacePower * stage.BoostMultiplier,
		Acceleration = baseBoost.Acceleration * stage.BoostMultiplier,
		BaseRacePower = baseBoost.RacePower,
		BaseAcceleration = baseBoost.Acceleration,
		StageMultiplier = stage.BoostMultiplier,
	}
end

function TransportModule.GetBoostMultiplier(locationId, transportId, level, stageNumber)
	local boost = TransportModule.GetBoost(locationId, transportId, level, stageNumber)
	if not boost then return nil end
	
	return {
		RacePower = 1 + (boost.RacePower / 100),
		Acceleration = 1 + (boost.Acceleration / 100),
	}
end

--// CURRENT / NEXT BOOST
function TransportModule.GetCurrentAndNextBoost(locationId, transportId, level, stageNumber)
	local current = TransportModule.GetBoost(locationId, transportId, level, stageNumber)
	if not current then return nil end
	
	local nextBoost = nil
	local nextType = nil
	
	if TransportModule.CanLevelUp(level, stageNumber) then
		nextBoost = TransportModule.GetBoost(locationId, transportId, level + 1, stageNumber)
		nextType = "Level"
	elseif TransportModule.CanStageUp(level, stageNumber) then
		nextBoost = TransportModule.GetBoost(locationId, transportId, level, stageNumber + 1)
		nextType = "Stage"
	end
	
	return {
		Current = current,
		Next = nextBoost,
		NextType = nextType,
		
		IsMax = TransportModule.IsMaxTransport(level, stageNumber),
	}
end

--// NEXT TRANSPORT
function TransportModule.IsTransportCompleted(level, stageNumber)
	return TransportModule.IsMaxTransport(level, stageNumber)
end

function TransportModule.GetUnlockedNextTransport(locationId, transportId, level, stageNumber)
	local nextTransport, nextTransportId = TransportModule.GetNextTransport(locationId, transportId)
	if not nextTransport then return nil end
	
	local canUnlock = TransportModule.CanUnlockTransport(locationId, nextTransportId, level, stageNumber)
	if not canUnlock then return nil end
	
	return nextTransport, nextTransportId
end

--// UI ICON DATA
function TransportModule.GetTransportIcon(locationId, transportId, state)
	local transport = TransportModule.GetTransport(locationId, transportId)
	
	if not transport or not transport.Icons then return nil end
	
	return transport.Icons[state]
end

function TransportModule.GetStageIcon(stageNumber, state)
	local stage = TransportModule.GetStage(stageNumber)
	
	if not stage or not stage.Icons then return nil end
	
	return stage.Icons[state]
end

function TransportModule.GetLocationIcon(locationId, state)
	local location = TransportModule.GetLocation(locationId)
	
	if not location or not location.Icons then return nil end
	
	return location.Icons[state]
end

--// VIEWPORT DATA
function TransportModule.GetViewportData(locationId, transportId)
	local transport = TransportModule.GetTransport(locationId, transportId)
	
	if not transport or not transport.Visual then return nil end
	
	return deepCopy(transport.Visual)
end

--// COMPLETE DISPLAY DATA
function TransportModule.getTransportDisplayData(locationId, transportId, level, stageNumber)
	local transport = TransportModule.GetTransport(locationId, transportId)
	local stage = TransportModule.GetStage(stageNumber)
	
	if not transport or not stage then return nil end
	
	local boostData = TransportModule.GetCurrentAndNextBoost(locationId, transportId, level, stageNumber)
	local nextTransport, nextTransportId = TransportModule.GetNextTransport(locationId, transportId)
	
	return {
		Id = transportId,
		Name = transport.Name,
		Order = transport.Order,
		
		Level = level,
		GlobalMaxLevel = TransportModule.MAX_LEVEL,
		
		Stage = stageNumber,
		MaxStage = TransportModule.MAX_STAGE,
		
		StageName = stage.Name,
		StageMinLevel = stage.MinLevel,
		StageMaxLevel = stage.MaxLevel,
		
		StageMultiplier = stage.BoostMultiplier,
		
		CurrentBoost = boostData and boostData.Current or nil,
		NextBoost = boostData and boostData.Next or nil,
		NextBoostType = boostData.NextType or nil,
		
		
		CanLevelUp = TransportModule.CanStageUp(level, stageNumber),
		CanStageUp = TransportModule.CanStageUp(level, stageNumber),
		
		IsMax = TransportModule.IsMaxTransport(level, stageNumber),
		
		NextLevelPrice = TransportModule.GetNextLevelPrice(locationId, transportId, level),
		StageUp = TransportModule.GetStageUpData(locationId, transportId, stageNumber),
		
		PurchasePrice = deepCopy(transport.PurchasePrice),
		Unlock = deepCopy(transport.Unlock),
		Icons = deepCopy(transport.Icons),
		StageIcons = deepCopy(stage.Icons),
		Visual = deepCopy(transport.Visual),
		NextTransportId = nextTransportId,
		NextTransportName = nextTransport and nextTransport.Name or nil,
	}
end

--// VALIDATION
function TransportModule.ValidateTransport(locationId, transportId)
	local transport = TransportModule.GetTransport(locationId, transportId)
	
	if not transport then return false, "Transport does not exist" end
	if not transport.Id then return false, "Nissing Id" end
	if not transport.Name then return false, "Missing Name" end
	if not transport.Order then return false, "Missing Order" end
	if not transport.LevelPrice then return false, "Missing LevelPrice" end
	if not transport.LevelBoost then return false, "Missing LevelBoost" end
	if not transport.StageUp then return false, "Missing StageUp" end
	
	for stageNumber = 1, TransportModule.MAX_STAGE - 1 do
		if not transport.StageUp[stageNumber] then
			return false, "Missing StageUp config for Stage" .. stageNumber
		end
	end
	return true 
end

function TransportModule.ValidateAll()
	for locationId, location in pairs(TransportModule.Locations) do
		for transportId in pairs(location.Transports) do
			local valid, reason = TransportModule.ValidateTransport(locationId, transportId)
			if not valid then
				warn("[TransportModule]", locationId, transportId, reason)
				return false
			end
		end
	end
	return true 
end

return TransportModule
