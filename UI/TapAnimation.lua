local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- TapAnimation находится непосредственно внутри TapTutorial
local tutorial = script.Parent
local eggFolder = tutorial.Parent
local guiFolder = eggFolder.Parent
local raceGui = guiFolder.Parent

local hand = tutorial:WaitForChild("Hand")
local ripple = tutorial:WaitForChild("Ripple")
local targetPosition = eggFolder:WaitForChild("TapPosition")
local autoOpenButton = eggFolder:WaitForChild("AutoOpenButton")

local HAND_IDLE_IMAGE = "rbxassetid://74290770677014"
local HAND_PRESSED_IMAGE = "rbxassetid://133148611212110"
local RIPPLE_IMAGE = "rbxassetid://132192949377893"

local running = true

hand.Image = HAND_IDLE_IMAGE
ripple.Image = RIPPLE_IMAGE

hand.BackgroundTransparency = 1
ripple.BackgroundTransparency = 1

hand.ZIndex = 101
ripple.ZIndex = 100

hand.Visible = false
ripple.Visible = false

local function tween(object, duration, properties, style, direction)
	local tweenInfo = TweenInfo.new(
		duration,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)

	local animation = TweenService:Create(
		object,
		tweenInfo,
		properties
	)

	animation:Play()

	return animation
end

local function getTargetCenter()
	local targetCenter =
		targetPosition.AbsolutePosition
		+ targetPosition.AbsoluteSize / 2

	return targetCenter - tutorial.AbsolutePosition
end

local function getHandSize()
	local camera = Workspace.CurrentCamera

	local viewport = if camera
		then camera.ViewportSize
		else Vector2.new(1920, 1080)

	local size = math.clamp(
		math.min(viewport.X, viewport.Y) * 0.32,
		280,
		460
	)

	return Vector2.new(size, size)
end

local function playRipple(position)
	ripple.Visible = true
	ripple.Position = UDim2.fromOffset(
		position.X,
		position.Y
	)

	ripple.Size = UDim2.fromOffset(20, 20)
	ripple.ImageTransparency = 0
	ripple.Rotation = 0

	local rippleTween = tween(
		ripple,
		0.35,
		{
			Size = UDim2.fromOffset(130, 130),
			ImageTransparency = 1,
			Rotation = 15,
		},
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	rippleTween.Completed:Wait()

	ripple.Visible = false
end

local function playTap()
	local center = getTargetCenter()
	local handSize = getHandSize()

	hand.Size = UDim2.fromOffset(
		handSize.X,
		handSize.Y
	)

	-- Положение кончика пальца внутри изображения
	local fingerOffset = Vector2.new(
		handSize.X * 0.18,
		handSize.Y * 0.11
	)

	local pressedPosition = center - fingerOffset

	local startPosition =
		pressedPosition + Vector2.new(65, 65)

	hand.Image = HAND_IDLE_IMAGE

	hand.Position = UDim2.fromOffset(
		startPosition.X,
		startPosition.Y
	)

	hand.ImageTransparency = 1
	hand.Visible = true

	-- Появление руки
	local appearTween = tween(
		hand,
		0.2,
		{
			ImageTransparency = 0,
		}
	)

	appearTween.Completed:Wait()

	if not running then
		return
	end

	-- Движение руки к кнопке
	local moveTween = tween(
		hand,
		0.45,
		{
			Position = UDim2.fromOffset(
				pressedPosition.X,
				pressedPosition.Y
			),
		},
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	)

	moveTween.Completed:Wait()

	if not running then
		return
	end

	-- Меняем изображение на нажатую руку
	hand.Image = HAND_PRESSED_IMAGE

	local originalSize = hand.Size

	local pressTween = tween(
		hand,
		0.09,
		{
			Size = UDim2.fromOffset(
				handSize.X * 0.94,
				handSize.Y * 0.94
			),
		}
	)

	pressTween.Completed:Wait()

	if not running then
		return
	end

	-- Запускаем кольцо касания параллельно
	task.spawn(function()
		playRipple(center)
	end)

	task.wait(0.13)

	-- Возвращаем обычное изображение руки
	hand.Image = HAND_IDLE_IMAGE

	local releaseTween = tween(
		hand,
		0.12,
		{
			Size = originalSize,
		}
	)

	releaseTween.Completed:Wait()

	task.wait(0.15)

	-- Уводим и скрываем руку
	local returnTween = tween(
		hand,
		0.35,
		{
			Position = UDim2.fromOffset(
				startPosition.X,
				startPosition.Y
			),

			ImageTransparency = 1,
		},
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	)

	returnTween.Completed:Wait()

	hand.Visible = false
end

-- AutoOpenButton обязательно должен быть
-- ImageButton или TextButton
autoOpenButton.Activated:Connect(function()
	running = false

	hand.Visible = false
	ripple.Visible = false
	tutorial.Visible = false
end)

-- Запускаем повторяющуюся анимацию
task.spawn(function()
	task.wait(0.5)

	while running and tutorial.Parent do
		if tutorial.Visible and targetPosition.Visible then
			playTap()
		end

		task.wait(0.8)
	end
end)