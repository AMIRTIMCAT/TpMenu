local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Создаем или находим уже существующий GUI
local ScreenGui = player.PlayerGui:FindFirstChild("RoFinderGui") or Instance.new("ScreenGui")
ScreenGui.Name = "RoFinderGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

-- Удаляем старые элементы
for _, v in ipairs(ScreenGui:GetChildren()) do
	if v.Name == "ShadowFrame" or v.Name == "MainFrame" then
		v:Destroy()
	end
end

-- Тень
local ShadowFrame = Instance.new("Frame")
ShadowFrame.Name = "ShadowFrame"
ShadowFrame.Size = UDim2.new(0, 310, 0, 260)
ShadowFrame.Position = UDim2.new(0.5, -155, 0.5, -130)
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShadowFrame.BackgroundTransparency = 0.5
ShadowFrame.BorderSizePixel = 0
ShadowFrame.ZIndex = 0

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 10)
ShadowCorner.Parent = ShadowFrame

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 1
MainFrame.Active = true
MainFrame.Draggable = false

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Заголовок (для перетаскивания)
local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.Text = "🔍 RoFinder"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.SourceSansBold
Header.TextScaled = true

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextScaled = true

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- Layout для элементов
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 10)

-- Элементы
local PlaceIdTextBox = Instance.new("TextBox")
PlaceIdTextBox.Size = UDim2.new(0.8, 0, 0, 40)
PlaceIdTextBox.PlaceholderText = "Введите ID места"
PlaceIdTextBox.TextScaled = true
PlaceIdTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PlaceIdTextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlaceIdTextBox.Font = Enum.Font.SourceSans
PlaceIdTextBox.ClearTextOnFocus = false

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 5)
Corner2.Parent = PlaceIdTextBox

local PlayerNameTextBox = Instance.new("TextBox")
PlayerNameTextBox.Size = UDim2.new(0.8, 0, 0, 40)
PlayerNameTextBox.PlaceholderText = "Введите ник игрока"
PlayerNameTextBox.TextScaled = true
PlayerNameTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerNameTextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlayerNameTextBox.Font = Enum.Font.SourceSans
PlayerNameTextBox.ClearTextOnFocus = false

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 5)
Corner3.Parent = PlayerNameTextBox

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0.7, 0, 0, 50)
TeleportButton.Text = "Телепортироваться"
TeleportButton.TextScaled = true
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
TeleportButton.Font = Enum.Font.SourceSansBold

local Corner4 = Instance.new("UICorner")
Corner4.CornerRadius = UDim.new(0, 8)
Corner4.Parent = TeleportButton

-- Собираем интерфейс
Header.Parent = MainFrame
CloseButton.Parent = MainFrame
ContentFrame.Parent = MainFrame
PlaceIdTextBox.Parent = ContentFrame
PlayerNameTextBox.Parent = ContentFrame
TeleportButton.Parent = ContentFrame
ShadowFrame.Parent = ScreenGui
MainFrame.Parent = ScreenGui

-- Функция для поиска игрока по имени (регистронезависимая)
local function findPlayerByName(name)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():find(name:lower()) == 1 then
			return p
		end
	end
	return nil
end

-- Анимация кнопки
local function animateButton(button)
	local originalSize = button.Size
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local tween1 = TweenService:Create(button, tweenInfo, {Size = originalSize - UDim2.new(0, 5, 0, 5)})
	local tween2 = TweenService:Create(button, tweenInfo, {Size = originalSize})

	tween1:Play()
	tween1.Completed:Connect(function()
		tween2:Play()
	end)
end

-- Драг
local dragging = false
local dragStart, startPos

local function updateShadow()
	ShadowFrame.Position = MainFrame.Position + UDim2.new(0, -5, 0, -5)
end

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		updateShadow()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Кнопка закрытия
CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Кнопка телепорта
TeleportButton.Activated:Connect(function()
	animateButton(TeleportButton)

	local placeId = tonumber(PlaceIdTextBox.Text)
	local playerName = PlayerNameTextBox.Text

	if placeId and playerName ~= "" then
		local success, result = pcall(function()
			-- Получаем информацию о сервере через API
			local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"))

			for _, server in ipairs(servers.data) do
				for _, playerInServer in ipairs(server.players) do
					if playerInServer.name:lower() == playerName:lower() then
						-- Телепортируемся на найденный сервер
						TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
						return true
					end
				end
			end
			return false
		end)

		if not success then
			warn("Ошибка при поиске сервера: " .. result)
		end
	else
		warn("Введите корректный ID и ник.")
	end
end)

-- Обновляем тень при изменении позиции
MainFrame:GetPropertyChangedSignal("Position"):Connect(updateShadow)
updateShadow()
