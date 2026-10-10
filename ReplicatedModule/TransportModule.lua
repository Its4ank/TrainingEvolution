-- v1.3

local TransportModule = {}

--// GLOBAL CONFIG
TransportModule.MAX_LEVEL = 25
TransportModule.MAX_STAGE = 5

TransportModule.DEFAULT_LOCATION = "StoneAge"
TransportModule.DEFAULT_TRANSPORT = "Feet"

--// STAGES
TransportModule.Stages = {
	[1] = {Name = "Stage 1", MinLevel = 0, MaxLevel = 5, BoostMultiplier = 1.00,
	    Icons = {Default = "", Selected = "",},},
	[2] = {Name = "Stage 2", MinLevel = 5, MaxLevel = 10, BoostMultiplier = 1.10,
		Icons = {Default = "", Selected = "",},},
	[3] = {Name = "Stage 3", MinLevel = 10, MaxLevel = 15, BoostMultiplier = 1.20,
		Icons = {Default = "", Selected = "",},},
	[4] = {Name = "Stage 4", MinLevel = 15, MaxLevel = 20, BoostMultiplier = 1.30,
		Icons = {Default = "", Selected = "",},},
	[5] = {Name = "Stage 5", MinLevel = 20, MaxLevel = 25, BoostMultiplier = 1.40,
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
						CameraHeight = 1,
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
				
				LevelBoost = {
					{FromLevel = 0, ToLevel = 5, StartRacePower = 1, EndRacePower = 5, StartAcceleration = 2, EndAcceleration = 10,},
					{FromLevel = 5, ToLevel = 10, StartRacePower = 5, EndRacePower = 10, StartAcceleration = 10, EndAcceleration = 20,},
					{FromLevel = 10, ToLevel = 15, StartRacePower = 10, EndRacePower = 20, StartAcceleration = 20, EndAcceleration = 30,},
					{FromLevel = 15, ToLevel = 20, StartRacePower = 20, EndRacePower = 30, StartAcceleration = 30, EndAcceleration = 40,},
					{FromLevel = 20, ToLevel = 25, StartRacePower = 30, EndRacePower = 40, StartAcceleration = 40, EndAcceleration = 50,},	
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
					{FromLevel = 0, ToLevel = 5, StartRacePower = 1, EndRacePower = 5, StartAcceleration = 2, EndAcceleration = 10,},
					{FromLevel = 5, ToLevel = 10, StartRacePower = 5, EndRacePower = 10, StartAcceleration = 10, EndAcceleration = 20,},
					{FromLevel = 10, ToLevel = 15, StartRacePower = 10, EndRacePower = 15, StartAcceleration = 20, EndAcceleration = 30,},
					{FromLevel = 15, ToLevel = 20, StartRacePower = 15, EndRacePower = 20, StartAcceleration = 30, EndAcceleration = 40,},
					{FromLevel = 20, ToLevel = 25, StartRacePower = 20, EndRacePower = 25, StartAcceleration = 40, EndAcceleration = 50,},
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
					{FromLevel = 0, ToLevel = 5, StartRacePower = 1, EndRacePower = 5, StartAcceleration = 2, EndAcceleration = 10,},
					{FromLevel = 5, ToLevel = 10, StartRacePower = 5, EndRacePower = 10, StartAcceleration = 10, EndAcceleration = 20,},
					{FromLevel = 10, ToLevel = 15, StartRacePower = 10, EndRacePower = 15, StartAcceleration = 20, EndAcceleration = 30,},
					{FromLevel = 15, ToLevel = 20, StartRacePower = 15, EndRacePower = 20, StartAcceleration = 30, EndAcceleration = 40,},
					{FromLevel = 20, ToLevel = 25, StartRacePower = 20, EndRacePower = 25, StartAcceleration = 40, EndAcceleration = 50,},
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
		
		result[resourceName] = math.round(lerp(startValue, endValue, alpha))
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

function TransportModule.GetStageMinLevel(stageNumber)
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
		if targetLevel >= range.FromLevel and targetLevel <= range.ToLevel then
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
		
		result.Requirements[resourceName] = {
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
		NextBoostType = boostData and boostData.NextType or nil,
		
		
		CanLevelUp = TransportModule.CanLevelUp(level, stageNumber),
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
local VALID_LEVEL_RESOURCES = {
	Money = true,
	RaceTouch = true,
	XP = true,
}

local VALID_STAGE_RESOURCES = {
	Money = true,
	RaceTouch = true,
	Distance = true,
}

local VALID_PURCHASE_RESOURCES = {
	Money = true,
	RaceTouch = true,
}

local function validateResourceTable(resources, validResources, context)
	if type(resources) ~= "table" then
		return false, context .. " must be a table"
	end
	
	for resourceName, amount in pairs(resources) do
		if not validResources[resourceName] then
			return false, context .. " contains invalid resource: " .. tostring(resourceName)
		end
		
		if type(amount) ~= "number" then
			return false, context .. "." .. resourceName .. " must be a number"
		end
		
		if amount < 0 then
			return false, context .. "." .. resourceName .. " cannot be negative"
		end
	end
	
	return true
end

local function validateLevelPrice(transport)
	local coveredLevels = {}
	
	for rangeIndex, range in ipairs(transport.LevelPrice) do
		if type(range.FromLevel) ~= "number" or type(range.ToLevel) ~= "number" then
			
			return false, "LevelPrice range " .. rangeIndex .. " has invalid FromLevel/ToLevel"
		end
		
		if range.FromLevel > range.ToLevel then
			return false, "LevelPrice range " .. rangeIndex .. " has FromLevel greater than ToLevel"
		end
		
		if range.FromLevel < 1 or range.ToLevel > TransportModule.MAX_LEVEL then
			return false, "LevelPrice range " .. rangeIndex .. " is outside level limits"
		end
		
		local validStart, startReason = validateResourceTable(range.StartPrice, VALID_LEVEL_RESOURCES, "LevelPrice[" .. rangeIndex .. "].StartPrice")
		if not validStart then return false, startReason end
		
		local validEnd, endReason = validateResourceTable(range.EndPrice, VALID_LEVEL_RESOURCES, "LevelPrice[" .. rangeIndex .. "].EndPrice")
		if not validEnd then return false, endReason end
		
		for level = range.FromLevel, range.ToLevel do
			if coveredLevels[level] then
				return false, "LevelPrice overlaps at Level " .. level 
			end
			
			coveredLevels[level] = true 
		end
	end
	
	for level = 1, TransportModule.MAX_LEVEL do
		if not coveredLevels[level] then
			return false, "LevelPrice does not cover Level " .. level 
		end
	end
	
	return true 
end

local function validateLevelBoost(transport)
	local ranges = transport.LevelBoost
	
	if #ranges ~= TransportModule.MAX_STAGE then 
		return false, "LevelBoost must contain exactly " .. TransportModule.MAX_STAGE .. " range"
	end
	
	for stageNumber = 1, TransportModule.MAX_STAGE do 
		local range = ranges[stageNumber]
		local stage = TransportModule.Stages[stageNumber]
		
		if not range then
			return false, "Missing LevelBoost range for Stage " .. stageNumber
		end
		
		if range.FromLevel ~= stage.MinLevel then
			return false, "LevelBoost Stage " .. stageNumber .. " FromLevel must be " .. stage.MinLevel
		end
		
		if range.ToLevel ~= stage.MaxLevel then
			return false, "LevelBoost Stage " .. stageNumber .. " ToLevel must be " .. stage.MaxLevel
		end
		
		local boostFields = {
			"StartRacePower",
			"EndRacePower",
			"StartAcceleration",
			"EndAcceleration",
		}
		
		for _, fieldName in ipairs(boostFields) do
			local value = range[fieldName]
			
			if type(value) ~= "number" then
				return false, "LevelBoost Stage " .. stageNumber .. " missing numeric " .. fieldName
			end
			
			if value < 0 then
				return false, "LevelBoost Stage " .. stageNumber .. " " .. fieldName .. " cannot be negative"
			end
		end
		
		if stageNumber > 1 then
			local previousRange = ranges[stageNumber - 1]
			
			if previousRange.EndRacePower ~= range.StartRacePower then
				return false, "RacePower boost is not continuous beetween Stage " .. (stageNumber - 1) .. " and Stage " .. stageNumber
			end
			
			if previousRange.EndAcceleration ~= range.StartAcceleration then
				return false, "Acceleration boost is not continuous between Stage " .. (stageNumber - 1) .. " and Stage " .. stageNumber
			end
		end
	end
	return true 
end

local function validateStageUp(transport)
	for stageNumber = 1, TransportModule.MAX_STAGE - 1 do
		local stageUp = transport.StageUp[stageNumber]
		local stage = TransportModule.Stages[stageNumber]
		
		if not stageUp then
			return false, "Missing StageUp config for Stage " .. stageNumber
		end
		
		if stageUp.RequiredLevel ~= stage.MaxLevel then
			return false, "StageUp Stage " .. stageNumber .. " RequiredLevel must be " .. stage.MaxLevel
		end
		
		local validCost, costReason = validateResourceTable(stageUp.Cost, VALID_STAGE_RESOURCES, "StageUp[" .. stageNumber .. "].Cost")
		if not validCost then return false, costReason end
	end
	
	if transport.StageUp[TransportModule.MAX_STAGE] ~= nil then
		return false, "Stage " .. TransportModule.MAX_STAGE .. " must not have StageUp config"
	end
	return true
end

local function validateUnlock(locationId, transportId, transport)
	local location = TransportModule.GetLocation(locationId)
	
	if transport.DefaultUnlocked then return true end 
		
	if type(transport.Unlock) ~= "table" then
		return false, "Locked transport is missing Unlock config"
	end
		
	local previousTransportId = transport.Unlock.PreviousTransport
		
	if type(previousTransportId) ~= "string" or previousTransportId == "" then
		return false, "Unlock.PreviousTransport is missing"
	end
	
	local previousTransport = TransportModule.GetTransport(locationId, previousTransportId)
	
	if not previousTransport then
		return false, "Unlock.PreviousTransport does not exist: " .. previousTransportId
	end
	
	if previousTransportId == transportId then
		return false, "Transport cannot unlock itself"
	end
	
	local expectedPreviousId = location.TransportOrder[transport.Order - 1]
	if expectedPreviousId ~= previousTransportId then
		return false, "Unlock.PreviousTransport must be " .. tostring(expectedPreviousId)
	end
	
	local requiredStage = transport.Unlock.RequiredStage
	local requiredLevel = transport.Unlock.RequiredLevel
	
	if type(requiredStage) ~= "number" or requiredStage < 1 or requiredLevel > TransportModule.MAX_STAGE then
	   return false, "Unlock.RequiredStage is invalid"
	end
	
	if type(requiredLevel) ~= "number" or requiredLevel < 0 or requiredLevel > TransportModule.MAX_LEVEL then
		return false, "Unlock.RequiredLevel is invalid"
	end
	
	local requiredStageConfig = TransportModule.GetStage(requiredStage)
	if not requiredStageConfig then
		return false, "Unlock.RequiredStage does not exist"
	end
	
	if requiredLevel < requiredStageConfig.MinLevel or requiredLevel > requiredStageConfig.MaxLevel then
		return false, "Unlock.RequiredLevel does not belong to RequiredStage"
	end
	
	return true 
end

local function validateViewport(transport)
	if type(transport.Visual) ~= "table" then
		return false, "Missing Visual config"
	end
	
	if transport.Value.ModelName ~= nil and type(transport.Visual.ModelName) ~= "string" then
		return false, "Visual.ModelName must be a string or nil"
	end
	
	local viewport = transport.Visual.Viewport
	
	if type(viewport) ~= "table" then
		return false, "Missing Visual.Viewport config"
	end
	
	if viewport.Rotation ~= nil and typeof(viewport.Rotation) ~= "Vector3" then
		return false, "Viewport.Rotation must be Vector3"
	end
	
	if type(viewport.CameraDistance) ~= "number" or viewport.CameraDistance <= 0 then
		return false, "Viewport.CameraDistance must be greater than 0"
	end
	
	if type(viewport.CameraHeight) ~= "number" then
		return false, "Viewport.CameraHeight must be a number"
	end
	return true 
end

function TransportModule.ValidateTransport(locationId, transportId)
	local location = TransportModule.GetLocation(locationId)
	if not location then return false, "Locaiton does not exist" end
	
	local transport = TransportModule.GetTransport(locationId, transportId)
	if not transport then return false, "Transport does not exist" end
	
	if transport.Id ~= transportId then
		return false, "Id must match transport key: " .. transportId 
	end
	
	if type(transport.Name) ~= "string" or transport.Name == "" then
		return false, "Missing or invalid Name"
	end
	
	if type(transport.Order) ~= "number" then
		return false, "Missing or invalid Order"
	end
	
	if transport.Order % 1 ~= 0 then
		return false, "Order must be a integer"
	end
	
	if transport.Order < 1 or transport.Order > #location.TransportOrder then
		return false, "Order is outside TransportOrder"
	end
	
	if location.TransportOrder[transport.Order] ~= transportId then
		return false, "Order does not match TransportOrder. Expected " .. tostring(location.TransportOrder[transport.Order])
	end
	
	if type(transport.DefaultUnlocked) ~= "boolean" then
		return false, "DefaultUnlocked must be boolean"
	end
	
	if type(transport.DefaultOwned) ~= "boolean" then
		return false, "DefaultOwned must be boolean"
	end
	
	if type(transport.DefaultEquipped) ~= "boolean" then
		return false, "DefaultEquipped must be boolean"
	end
	
	if transport.DefaultOwned and not transport.DefaultUnlocked then
		return false, "DefaultOwned requires DefaultUnlocked"
	end
	
	if transport.DefaultEquipped and (not transport.DefaultOwned or not transport.DefaultUnlocked) then
		return false, "DefaultEquipped requires DefaultOwned and DefaultUnlocked"
	end
	
	if type(transport.Purchasable) ~= "boolean" then
		return false, "Purchasable must be boolean"
	end
	
	if transport.Purchasable then
		local validPrice, priceReason = validateResourceTable(transport.PurchasePrice, VALID_PURCHASE_RESOURCES, "PurchasePrice")
		if not validPrice then return false, priceReason end
	end
	
	if type(transport.LevelPrice) ~= "table" then
		return false, "Missing LevelPrice"
	end
	
	if type(transport.LevelBoost) ~= "table" then
		return false, "Missing LevelBoost"
	end
	
	if type(transport.StageUp) ~= "table" then
		return false, "Missing StageUp"
	end
	
	local validLevelPrice, levelPriceReason = validateLevelPrice(transport)
	if not validLevelPrice then return false, levelPriceReason end
	
	local validLevelBoost, levelBoostReason = validateLevelBoost(transport)
	if not validLevelBoost then return false, levelBoostReason end
	
	local validStageUp, stageUpReason = validateStageUp(transport)
	if not validStageUp then return false, stageUpReason end
	
	local validUnlock, unlockReason = validateUnlock(locationId, transportId, transport)
	if not validUnlock then return false, unlockReason end
	
	local validViewport, viewportReason = validateViewport(transport)
	if not validViewport then return false, viewportReason end
	
	return true
end

function TransportModule.ValidateAll()
	if type(TransportModule.Stages) ~= "table" then
		return false, "Stage config is missing"
	end
	
	for stageNumber = 1, TransportModule.MAX_STAGE do 
		local stage = TransportModule.Stages[stageNumber]
		if not stage then return false, "Missing Stage " .. stageNumber end
		
		if type(stage.MinLevel) ~= "number" or type(stage.MaxLevel) ~= "number" then
			return false, "Stage " .. stageNumber .. " has invalid level boundaries"
		end
		
		if stage.MinLevel > stage.MaxLevel then
			return false, "Stage " .. stageNumber .. " has invalid level range"
		end
		
		if stageNumber == 1 then
			if stage.MinLevel ~= 0 then
				return false, "Stage 1 MinLevel must be 0"
			end
		else 
			local previousStage = TransportModule.Stages[stageNumber - 1]
			
			if stage.MinLevel ~= previousStage.MaxLevel then
				return false, "Stage " .. stageNumber .. " MinLevel must equal Stage " .. (stageNumber - 1) .. " MaxLevel"
			end
		end
		
		if type(stage.BoostMultiplier) ~= "number" or stage.BoostMultiplier <= 0 then
			return false, "Stage " .. stageNumber .. " has invalid BoostMultiplier"
		end
	end
	
	local finalStage = TransportModule.Stages[TransportModule.MAX_STAGE]
	if not finalStage then return false, "Final stage is missing" end
	
	if finalStage.MaxLevel ~= TransportModule.MAX_LEVEL then
		return false, "Final stage MaxLevel must equal MAX_LEVEL"
	end
	
	local defaultLocation = TransportModule.Locations[TransportModule.DEFAULT_LOCATION]
	if not defaultLocation then
		return false, "DEFAULT_LOCATION does not exist"
	end
	
	for locationId, location in pairs(TransportModule.Locations) do
		if type(location.Transports) ~= "table" then
			return false, locationId .. ": missing Transports"
		end
		
		if type(location.TransportOrder) ~= "table" or #location.TransportOrder == 0 then
			return false, locationId .. ": missing TransportOrder"
		end
		
		local orderSeen = {}
		local defaultEquippedCount = 0
		
		for order, transportId in ipairs(location.TransportOrder) do
			if orderSeen[transportId] then
				return false, locationId .. ": duplicate transport in TransportOrder: " .. tostring(transportId)
			end
			
			orderSeen[transportId] = true 
			
			local transport = location.Transports[transportId]
			if not transport then
				return false, locationId .. ": TransportOrder contains missing transport: " .. tostring(transportId)
			end
			
			if transport.Order ~= order then
				return false, locationId .. "/" .. transportId .. ": Order must be " .. order 
			end
			
			if transport.DefaultEquipped == true then
				defaultEquippedCount += 1
			end
		end
		
		if defaultEquippedCount > 1 then
			return false, locationId .. ": multiple transports have DefaultEquipped = true"
		end
		
		for transportId in pairs(location.Transports) do
			if not orderSeen[transportId] then
				return false, locationId .. ": transport missing from TransportOrder: " .. transportId
			end
			
			local valid, reason = TransportModule.ValidateTransport(locationId, transportId)
			if not valid then
				return false, locationId .. "/" .. transportId .. ": " .. tostring(reason)
			end
		end
	end
	
	local defaultTransport = TransportModule.GetTransport(TransportModule.DEFAULT_LOCATION, TransportModule.DEFAULT_TRANSPORT)
	if not defaultTransport then
		return false, "DEFAULT_TRANSPORT does not exist in DEFAULT_LOCATION"
	end
	
	if defaultLocation.TransportOrder[1] ~= TransportModule.DEFAULT_LOCATION then
		return false, "DEFAULT_TRANSPORT must be first in DEFAULT_LOCATION TransportOrder"
	end
	
	if defaultTransport.Purchasable then
		return false, "DEFAULT_TRANSPORT must not be purchasable"
	end
	
	if not defaultTransport.DefaultUnlocked or not defaultTransport.DefaultOwned or not defaultTransport.DefaultEquipped then
		return false, "DEFAULT_TRANSPORT must start Unlocked, Owned and Equipped"
	end
	return true
end

return TransportModule
