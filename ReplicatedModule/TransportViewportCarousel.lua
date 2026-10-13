--// TransportViewportCarousel v1.3

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Carousel = {} 
Carousel.__index = Carousel

--// CONFIG
local ROTATION_TIME = 0.65
local DRAG_SENSITIVITY = 0.45

local CAROUSEL_RADIUS = 4.8
local CAROUSEL_HORIZONTAL_SPREAD = 1.9

local CAMERA_DISTANCE = 13
local CAMERA_HEIGHT = 1.6
local CAMERA_FOV = 52

local MODEL_SCALES = {
	Feet = 1.08,
	Log = 1.08,
	Stone = 1,
}

local DEFAULT_IDLE_ID = 507766666

--// PREPARE PARTS
local function prepareParts(asset, isAvatar)
	local root = isAvatar and asset:FindFirstChild("HumanoidRootPart", true) or nil
	
	local function prepare(part)
		if not part:IsA("BasePart") then return end
		
		part.Anchored = not isAvatar or part == root 
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end
	prepare(asset)
	
	for _, descendant in ipairs(asset:GetDescendants()) do
		prepare(descendant)
		
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			descendant:Destroy()
		end
	end
end

--// CONSTRUCTOR
function Carousel.new(viewport, player, transportModule, locationId, order)
	local self = setmetatable({}, Carousel)
	
	self.Viewport = viewport
	self.Player = player 
	self.TransportModule = transportModule
	self.LocationId = locationId
	self.Order = order
	
	self.Entries = {}
	self.SelectedIndex = 1
	self.TargetStep = 0
	self.AvatarRequest = 0
	
	self.DraggingMouse = false
	self.ActiveTouch = nil
	self.LastPosition = nil
	
	self.StepValue = Instance.new("NumberValue")
	self.StepValue.Value = 0
	
	viewport.Active = true 
	viewport.CurrentCamera = nil
	
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("WorldModel") or child:IsA("Camera") then
			child:Destroy()
		end
	end
	
	self.World = Instance.new("WorldModel")
	self.World.Name = "TransportCarouselWorld"
	self.World.Parent = viewport 
	
	self.Camera = Instance.new("Camera")
	self.Camera.Name = "TransportCarouselCamera"
	self.Camera.FieldOfView = CAMERA_FOV
	self.Camera.CFrame = CFrame.lookAt(Vector3.new(0, CAMERA_HEIGHT, CAMERA_DISTANCE), Vector3.new(0, 0, -0.5))
	self.Camera.Parent = viewport 
	
	viewport.CurrentCamera = self.Camera 
	
	self.StepValue.Changed:Connect(function()
		self:_positionModels()
	end)
	
	self:_createTransportModels()
	self:_connectInput()
	self:RefreshAvatar()
	
	return self 
end

--// REGISTER PREVIEW MODEL
function Carousel:_addEntry(transportId, asset, isAvatar)
	local holder = Instance.new("Model")
	holder.Name = "Preview_" .. transportId 
	
	asset.Parent = holder 
	holder.Parent = self.World 
	
	prepareParts(asset, isAvatar)
	
	local scale = MODEL_SCALES[transportId] or 1
	holder:ScaleTo(scale)
	
	local boundingCFrame = holder:GetBoundingBox()
	local pivot = holder:GetPivot()
	
	holder:PivotTo(pivot + (-boundingCFrame.Position))
	self.Entries[transportId] = {
		Model = holder,
		BaseRotation = holder:GetPivot().Rotation,
		ManualYaw = 0,
		FacingYaw = isAvatar and math.pi or 0,
	}
	
	self:_positionModels()
end

--// LOG AND STONE
function Carousel:_createTransportModels()
	local modelsFolder = ReplicatedStorage:WaitForChild("TransportModels")
	
	for _, transportId in ipairs(self.Order) do
		if transportId == "Feet" then continue end
		
		local visual = self.TransportModule.GetViewportData(self.LocationId, transportId)
		local modelName = visual and visual.ModelName
		if not modelName then continue end
		
		local source = modelsFolder:FindFirstChild(modelName)
		if source then
			local clone = source:Clone()
			
			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant.Name == "PlayerPosLog" or descendant.Name == "PlayerPosStone" then
					descendant:Destroy()
				end
			end
			
			self:_addEntry(transportId, clone, false)
		else 
			warn("[TransportCarousel] Missing model:", modelName)
		end
	end
end

--// PLAY R15 IDLE ANIMATION
function Carousel:_playAvatarIdle(avatar, description)
	local humanoid = avatar:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	local idleId = DEFAULT_IDLE_ID
	
	local animation = Instance.new("Animation")
	animation.Name = "TransportPreviewIdle"
	animation.AnimationId = "rbxassetid://" .. idleId
	animation.Parent = avatar
	
	local success, err = pcall(function()
		local track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Idle
		track.Looped = true 
		track:Play()
	end)
	
	if not success then
		warn("[TransportCarousel] Idle failed:", err)
	end
end

--// CREATE CLEAN R15 AVATAR
function Carousel:RefreshAvatar()
	self.AvatarRequest += 1
	local requestId = self.AvatarRequest
	
	local oldEntry = self.Entries.Feet
	
	if oldEntry then
		oldEntry.Model:Destroy()
		self.Entries.Feet = nil
	end
	
	task.spawn(function()
		local success, avatar, description = pcall(function()
			local humanoid = self.Player.Character and self.Player.Character:FindFirstChild("Humanoid")
			local desc
			
			if humanoid then
				local ok, applied = pcall(function()
					return humanoid:GetAppliedDescription()
				end)
				
				if ok then
					desc = applied
				end
			end
			
			if not desc then
				desc = Players:GetHumanoidDescriptionFromUserIdAsync(self.Player.UserId)
			end
			
			local model = Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
			return model, desc 
		end)
		
		if not success then
			warn("[TransportCarousel] Avatar load failed:", avatar)
			return
		end
		
		if requestId ~= self.AvatarRequest or not self.World.Parent then
			avatar:Destroy()
			return 
		end
		
		avatar.Name = "CleanPlayerAvatar"
		
		self:_addEntry("Feet", avatar, true)
		self:_playAvatarIdle(avatar, description)
	end)
end

--// PLACE ALL THREE MODELS ON A CIRCLE
function Carousel:_positionModels()
	local count = #self.Order
	if count == 0 then return end
	
	local segment = math.pi * 2 / count
	
	for index, transportId in ipairs(self.Order) do
		local entry = self.Entries[transportId]
		if not entry then continue end 
		
		local angle = (index - 1 - self.StepValue.Value) * segment
		local x = math.sin(angle) * CAROUSEL_RADIUS * CAROUSEL_HORIZONTAL_SPREAD
		local z = -CAROUSEL_RADIUS * (1 - math.cos(angle))
		local position = Vector3.new(x, 0, z)
		local rotation = CFrame.Angles(0, entry.FacingYaw + entry.ManualYaw, 0)
		
		entry.Model:PivotTo(CFrame.new(position) * rotation * entry.BaseRotation)
	end
end

--// ANIMATED SELECTED
function Carousel:Select(transportId, direction)
	local newIndex = table.find(self.Order, transportId)
	if not newIndex then return end
	if newIndex == self.SelectedIndex then return end
	
	local count = #self.Order
	local steps
	
	if direction == 1 or direction == -1 then 
		steps = direction
	else
		steps = (newIndex - self.SelectedIndex) % count 
		
		if steps > count / 2 then
			steps -= count 
		end
	end
	
	self.SelectedIndex = newIndex
	self.TargetStep += steps
	
	if self.ActiveTween then
		self.ActiveTween:Cancel()
	end
	
	self.DraggingMouse = false 
	self.ActiveTouch = nil
	self.LastPosition = nil
	
	self.ActiveTween = TweenService:Create(self.StepValue, TweenInfo.new(ROTATION_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Value = self.TargetStep})
	self.ActiveTween:Play()
end

--// RESET MHEN OPENING THE MENU
function Carousel:SnapTo(transportId)
	local index = table.find(self.Order, transportId)
	if not index then return end
	
	if self.ActiveTween then
		self.ActiveTween:Cancel()
	end
	
	self.SelectedIndex = index
	self.TargetStep = index - 1
	self.StepValue.Value = self.TargetStep
end

--// MANUAL HORIZONTAL ROTATION
function Carousel:_drag(deltaX)
	local transportId = self.Order[self.SelectedIndex]
	local entry = self.Entries[transportId]
	if not entry then return end
	
	entry.ManualYaw += math.rad(deltaX * DRAG_SENSITIVITY)
	self:_positionModels()
end

function Carousel:_connectInput()
	local viewport = self.Viewport
	
	viewport.InputBegan:Connect(function(input)
		if not viewport.Visible then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.DraggingMouse = true 
			self.ActiveTouch = nil
			self.LastPosition = input.Position 
		elseif input.UserInputType == Enum.UserInputType.Touch and not self.ActiveTouch then
			self.ActiveTouch = input 
			self.LastPosition = input.Position 
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		local mouse = self.DraggingMouse and input.UserInputType == Enum.UserInputType.MouseMovement
		local touch = self.ActiveTouch ~= nil and input == self.ActiveTouch
		
		if not mouse and not touch then return end
		if not self.LastPosition then return end
		
		local current = input.Position
		local deltaX = current.X - self.LastPosition.X
		
		self.LastPosition = current
		self:_drag(deltaX)
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.DraggingMouse = false
			self.LastPosition = nil
		elseif input == self.ActiveTouch then
			self.ActiveTouch = nil
			self.LastPosition = nil
		end
	end)
end

return Carousel
