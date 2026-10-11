--// TransportRuntimeServer v1.3

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TransportModule = require(ReplicatedStorage.Modules.TransportModule)

local transportModels = ReplicatedStorage:WaitForChild("TransportModels")

--// CONFIG
local LOCATION_ID = TransportModule.DEFAULT_LOCATION
local DEFAULT_TRANSPORT = TransportModule.DEFAULT_TRANSPORT

local RUNTIME_MODEL_NAME = "ActiveTransportRuntime"

local PLAYER_POSITION_PARTS = {
	Log = "PlayerPosLog",
	Stone = "PlayerPosStone",
}

local MARKER_AT_FEET = true
local playerStates = {}

local heightStates = setmetatable({}, {__mode = "k"})

local function getBaseParts(object)
	local parts = {}
	
	if object:IsA("BasePart") then
		table.insert(parts, object)
	end
	
	for _, descendant in ipairs(object:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end
	return parts
end

local function findVisualRoot(object, marker)
	if object:IsA("BasePart") and object ~= marker then return object end
	
	if object:IsA("Model") and object.PrimaryPart and object.PrimaryPart ~= marker then
		return object.PrimaryPart
	end
	
	local bestPart = nil
	local bestVolume = 0
	
	for _, part in ipairs(getBaseParts(object)) do
		if part ~= marker then
			local size = part.Size
			local volume = size.X * size.Y * size.Z
			
			if volume > bestVolume then
				bestPart = part 
				bestVolume = volume 
			end
		end
	end
	return bestPart
end

local function getActiveTransportId(player)
	local testId = player:GetAttribute("TestTransport")
	
	if typeof(testId) == "string" and TransportModule.GetTransport(LOCATION_ID, testId) then return testId end
	
	local transports = player:FindFirstChild("Transports")
	local locationFolder = transports and transports:FindFirstChild(LOCATION_ID)
	
	if locationFolder then
		local order = TransportModule.GetTransportOrder(LOCATION_ID) or {}
		
		for _, transportId in ipairs(order) do
			local folder = locationFolder:FindFirstChild(transportId)
			
			if folder then
				local equipped = folder:FindFirstChild("Equipped")
				local owned = folder:FindFirstChild("Owned")
				local unlocked = folder:FindFirstChild("Unlocked")
				
				if equipped and equipped:IsA("BoolValue") and equipped.Value and owned and owned:IsA("BoolValue") and owned.Value and unlocked and unlocked:IsA("BoolValue") and unlocked.Value then
					return transportId
				end
			end
		end
	end
	return DEFAULT_TRANSPORT
end

--// REMOVE PREVIOUS MODEL
local function removeRuntimeModel(character)
	local runtime = character:FindFirstChild(RUNTIME_MODEL_NAME)
	
	if runtime then runtime:Destroy() end
end

--// CREATE TRANSPORT MODEL
local function getAnklePosition(character)
	local leftFoot = character:FindFirstChild("LeftFoot")
	local rightFoot = character:FindFirstChild("RightFoot")
	
	if not leftFoot or not rightFoot then return nil end 
	
	local leftAttachment = leftFoot:FindFirstChild("LeftAnkleRigAttachment")
	local rightAttachment = rightFoot:FindFirstChild("RightAnkleRigAttachment")
	
	local leftPosition = leftAttachment and leftAttachment.WorldPosition or leftFoot.Position + Vector3.new(0, leftFoot.Size.Y / 2, 0)
	local rightPosition = rightAttachment and rightAttachment.WorldPosition or rightFoot.Position + Vector3.new(0, rightFoot.Size.Y / 2, 0)
	
	return (leftPosition + rightPosition) / 2
end

--// ANKLE HEIGHT ABOVE SOLO
local function getAnkleHeightAboveSole(character)
	local total: number = 0
	local count: number = 0
	
	for _, side in ipairs({"Left", "Right"}) do
		local foot = character:FindFirstChild(side .. "Foot")
		
		if foot and foot:IsA("BasePart") then
			local attachment = foot:FindFirstChild(side .. "AnkleRigAttachment")
			local height: number = foot.Size.Y
			
			if attachment and attachment:IsA("Attachment") then
				height = attachment.Position.Y + foot.Size.Y / 2
			end
			
			if height < 0 then height = 0 end
			
			total += height
			count += 1
		end
	end
	
	if count == 0 then return nil end
	
	return total / count
end

local function setCharacterTransportLift(character, desiredLift)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local state = heightStates[character]
	if not state then
		state = {
			BaseHipHeight = humanoid.HipHeight, AppliedLift = 0,
		}
		heightStates[character] = state 
	end
	
	desiredLift = math.max(0, desiredLift)
	
	local difference = desiredLift - state.AppliedLift
	
	if math.abs(difference) < 0.001 then return end
	
	humanoid.HipHeight = state.BaseHipHeight + desiredLift
	character:PivotTo(character:GetPivot() + Vector3.new(0, difference, 0))
	state.AppliedLift = desiredLift
end

local function createRuntimeModel(character, humanoid, rootPart, transportId)
	local config = TransportModule.GetTransport(LOCATION_ID, transportId)
	
	if not config or not config.Visual or not config.Visual.ModelName then return false end
	
	local original = transportModels:FindFirstChild(config.Visual.ModelName)
	if not original then
		warn("[TransportRuntime] Missing model:", config.Visual.ModelName)
		return false 
	end
	
	local markerName = PLAYER_POSITION_PARTS[transportId]
	
	if not markerName then
		warn("[TransportRuntime] Missing marker configuration:", transportId)
		return false
	end
	
	local runtime = Instance.new("Model")
	runtime.Name = RUNTIME_MODEL_NAME
	runtime:SetAttribute("TransportId", transportId)
	runtime:SetAttribute("LocationId", LOCATION_ID)
	
	local clone = original:Clone()
	
	clone.Parent = runtime
	
	local marker = clone:FindFirstChild(markerName, true)
	if not marker or not marker:IsA("BasePart") then
		warn("[TransportRuntime] Missing PlayerPos:", markerName)
		runtime:Destroy()
		return false
	end
	
	local visualRoot = findVisualRoot(clone, marker)
	if not visualRoot then
		warn("[TransportRuntime] Missing visual BasePart:", transportId)
		runtime:Destroy()
		return false
	end
	
	local parts = getBaseParts(clone)
	
	for _, part in ipairs(parts) do
		part.Anchored = false
		part.CanCollide = false 
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true 
	end
	
	marker.Transparency = 1
	
	local anklePosition = getAnklePosition(character)
	local ankleAboveSole = getAnkleHeightAboveSole(character)

	if not anklePosition or not ankleAboveSole then
		warn("[TransportRuntime] Cannot find R15 ankles")
		runtime:Destroy()
		return false
	end

	local modelBottomY = visualRoot.Position.Y - visualRoot.Size.Y / 2
	local markerAboveBottom = marker.Position.Y - modelBottomY
	local requiredLift = math.max(0, markerAboveBottom - ankleAboveSole)

	setCharacterTransportLift(character, requiredLift)
	anklePosition = getAnklePosition(character)
	
	local markerTarget = CFrame.new(anklePosition) * rootPart.CFrame.Rotation
	
	local delta = markerTarget * marker.CFrame:Inverse()
	
	for _, part in ipairs(parts) do
		part.CFrame = delta * part.CFrame
	end
	
	local attachmentWeld = Instance.new("WeldConstraint")
	attachmentWeld.Name = "TransportAttachment"
	attachmentWeld.Part0 = rootPart 
	attachmentWeld.Part1 = marker
	attachmentWeld.Parent = marker
	
	local rollMotor = Instance.new("Motor6D")
	rollMotor.Name = "TransportRollMotor"
	rollMotor.Part0 = marker 
	rollMotor.Part1 = visualRoot
	rollMotor.C0 = marker.CFrame:ToObjectSpace(visualRoot.CFrame)
	rollMotor.C1 = CFrame.identity
	rollMotor.Parent = marker
	
	for _, part in ipairs(parts) do
		if part ~= marker and part ~= visualRoot then
			local weld = Instance.new("WeldConstraint")
			weld.Name = "TransportVisualWeld"
			weld.Part0 = visualRoot 
			weld.Part1 = part 
			weld.Parent = part 
		end
	end
	
	runtime.Parent = character
	
	print("[TransportRuntime] Created:", character.Name, transportId)
	return true 
end

--// REFRESH PLAYER TRANSPORT
local function refreshPlayerTransport(player)
	local character = player.Character
	if not character or not character.Parent then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not rootPart or humanoid.Health <= 0 then return end
	
	local transportId = getActiveTransportId(player)
	local current = character:FindFirstChild(RUNTIME_MODEL_NAME)
	
	if current and current:GetAttribute("TransportId") == transportId then return end
	
	removeRuntimeModel(character)
	
	if transportId == DEFAULT_TRANSPORT then
		setCharacterTransportLift(character, 0)
		
		player:SetAttribute("RuntimeTransportId", DEFAULT_TRANSPORT)
		return
	end
	
	local success = createRuntimeModel(character, humanoid, rootPart, transportId)
	
	if success then
		player:SetAttribute("RuntimeTransportId", transportId)
	else 
		setCharacterTransportLift(character, 0)
		
		player:SetAttribute("RuntimeTransportId", DEFAULT_TRANSPORT)
	end
end

--// SCHEDULE REFRESH
local function scheduleRefresh(player)
	local state = playerStates[player]
	if not state or not state.Ready or state.RefreshQueued then return end
	
	state.RefreshQueued = true
	
	task.defer(function()
		state.RefreshQueued = false
		
		if player.Parent then
			refreshPlayerTransport(player)
		end
	end)
end

--// WATCH SAVED EQUIPMENT
local function startWatchingEquipment(player)
	local state = playerStates[player]
	if not state or state.Ready then return end
	
	if player:GetAttribute("TransportServerReady") ~= true then return end
	
	local transports = player:FindFirstChild("Transports")
	local locationFolder = transports and transports:FindFirstChild(LOCATION_ID)
	
	if not locationFolder then
		warn("[TransportRuntime] Transport data missing:", player.Name)
		return
	end
	
	state.Ready = true
	
	local order = TransportModule.GetTransportOrder(LOCATION_ID) or {}
	
	for _, transportId in ipairs(order) do
		local folder = locationFolder:FindFirstChild(transportId)
		local equipped = folder and folder:FindFirstChild("Equipped")
		
		if equipped and equipped:IsA("BoolValue") then
			table.insert(state.Connections, equipped.Changed:Connect(function()
			   scheduleRefresh(player)
			end))
		end
	end
	scheduleRefresh(player)
end

--// PLAYER LIFECYCLE
local function setupPlayer(player)
	if playerStates[player] then return end
	
	local state = {
		Ready = false, RefreshQueued = false, Connections = {},
	}
	
	playerStates[player] = state 
	
	table.insert(state.Connections, player:GetAttributeChangedSignal("TransportServerReady"):Connect(function()
		startWatchingEquipment(player)
	end))
	
	table.insert(state.Connections, player:GetAttributeChangedSignal("TestTransport"):Connect(function()
		scheduleRefresh(player)
	end))
	
	table.insert(state.Connections, player.CharacterAdded:Connect(function(character)
		task.spawn(function()
			character:WaitForChild("HumanoidRootPart", 10)
			character:WaitForChild("Humanoid", 10)
			
			if player.Character == character then
				scheduleRefresh(player)
			end
		end)
	end))
	
	if player.Character then
		task.spawn(function()
			player.Character:WaitForChild("HumanoidRootPart", 10)
			player.Character:WaitForChild("Humanoid", 10)
			scheduleRefresh(player)
		end)
	end
	startWatchingEquipment(player)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
	local state = playerStates[player]
	
	if state then
		for _, connection in ipairs(state.Connections) do
			connection:Disconnect()
		end
	end
	playerStates[player] = nil
end)

print("TransportRuntimeServer v1.3 loaded")
