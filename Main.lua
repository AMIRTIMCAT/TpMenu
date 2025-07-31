local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function safeGetLocalPlayer()
    local tries = 0
    while not Players.LocalPlayer and tries < 60 do
        tries = tries + 1
        task.wait(0.1)
    end
    return Players.LocalPlayer
end

local LocalPlayer = safeGetLocalPlayer()
if not LocalPlayer then
    warn("[TeleportMenu] LocalPlayer not found!")
    return
end

local function safeGetPlayerGui()
    local tries = 0
    while not LocalPlayer:FindFirstChild("PlayerGui") and tries < 60 do
        tries = tries + 1
        task.wait(0.1)
    end
    return LocalPlayer:FindFirstChild("PlayerGui")
end

local PlayerGui = safeGetPlayerGui()
if not PlayerGui then
    warn("[TeleportMenu] PlayerGui not found!")
    return
end

-- Проверка на повторное создание меню
if PlayerGui:FindFirstChild("TeleportMenu") then
    PlayerGui.TeleportMenu:Destroy()
end

-- Определяем устройство
local isMobile = UserInputService.TouchEnabled

-- Размеры для ПК и телефона
local MENU_WIDTH = isMobile and 320 or 500
local MENU_HEIGHT = isMobile and 210 or 320
local SHADOW_WIDTH = MENU_WIDTH + (isMobile and 32 or 20)
local SHADOW_HEIGHT = MENU_HEIGHT + (isMobile and 32 or 20)
local HEADER_HEIGHT = isMobile and 38 or 56
local ICON_SIZE = isMobile and 24 or 36
local TITLE_SIZE = isMobile and 18 or 28
local DROPDOWN_HEIGHT = isMobile and 32 or 48
local DROPDOWN_FONT = isMobile and 14 or 20
local ARROW_BTN_SIZE = isMobile and 32 or 48
local LIST_BTN_HEIGHT = isMobile and 26 or 38
local LIST_BTN_FONT = isMobile and 14 or 20
local TPBTN_HEIGHT = isMobile and 36 or 54
local TPBTN_FONT = isMobile and 18 or 26
local TPBTN_CORNER = isMobile and 10 or 14
local MENU_CORNER = isMobile and 10 or 18
local HEADER_CORNER = isMobile and 10 or 18
local DROPDOWN_CORNER = isMobile and 6 or 10
local LIST_CORNER = isMobile and 6 or 10

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportMenu"
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- Если меню не появилось (например, не удалось создать ScreenGui), ничего не делать дальше
if not screenGui or not screenGui.Parent then
    warn("[TeleportMenu] Не удалось создать меню!")
    return
end

-- Шадоу
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.Size = UDim2.new(0, SHADOW_WIDTH, 0, SHADOW_HEIGHT)
shadow.Position = UDim2.new(0.5, isMobile and 10 or 16, 0.5, isMobile and 10 or 16)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.ImageTransparency = 0.5
shadow.ZIndex = 0
shadow.Parent = screenGui

-- Меню
local frame = Instance.new("Frame")
frame.Name = "Menu"
frame.Size = UDim2.new(0, MENU_WIDTH, 0, MENU_HEIGHT)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(30, 34, 44)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0
frame.ZIndex = 1
frame.Parent = screenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, MENU_CORNER)
uicorner.Parent = frame

-- Верхняя панель (header)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
header.BackgroundTransparency = 0.08
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, HEADER_CORNER)
headerCorner.Parent = header

local headerIcon = Instance.new("ImageLabel")
headerIcon.Name = "Icon"
headerIcon.Image = "rbxassetid://6031091002"
headerIcon.BackgroundTransparency = 1
headerIcon.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
headerIcon.Position = UDim2.new(0, 12, 0.5, -ICON_SIZE/2)
headerIcon.ZIndex = 3
headerIcon.Parent = header

local title = Instance.new("TextLabel")
title.Text = "Меню ТП к игроку"
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, ICON_SIZE + 20, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = TITLE_SIZE
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = header

-- Кнопка скрыть/показать (перемещаем её в левый верхний угол меню, вне header)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Text = "–"
toggleBtn.Size = UDim2.new(0, HEADER_HEIGHT-8, 0, HEADER_HEIGHT-8)
toggleBtn.Position = UDim2.new(0, 8, 0, 8)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.TextColor3 = Color3.fromRGB(0,170,255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = TITLE_SIZE
toggleBtn.ZIndex = 10
toggleBtn.Parent = frame -- теперь родитель frame, а не header
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1,0)
toggleCorner.Parent = toggleBtn

toggleBtn.MouseEnter:Connect(function()
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
end)
toggleBtn.MouseLeave:Connect(function()
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.TextColor3 = Color3.fromRGB(0,170,255)
end)

-- Drag'n'drop только за header
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        shadow.Position = frame.Position + UDim2.new(0, isMobile and 10 or 16, 0, isMobile and 10 or 16)
    end
end)

-- ComboBox (Dropdown)
local dropdown = Instance.new("Frame")
dropdown.Name = "Dropdown"
dropdown.Size = UDim2.new(1, -32, 0, DROPDOWN_HEIGHT)
dropdown.Position = UDim2.new(0, 16, 0, HEADER_HEIGHT + (isMobile and 8 or 24))
dropdown.BackgroundColor3 = Color3.fromRGB(40, 44, 54)
dropdown.BorderSizePixel = 0
dropdown.ZIndex = 2
dropdown.Parent = frame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, DROPDOWN_CORNER)
dropdownCorner.Parent = dropdown

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Name = "SelectedLabel"
selectedLabel.Size = UDim2.new(1, -ARROW_BTN_SIZE, 1, 0)
selectedLabel.Position = UDim2.new(0, 0, 0, 0)
selectedLabel.BackgroundTransparency = 1
selectedLabel.TextColor3 = Color3.fromRGB(220,220,220)
selectedLabel.Font = Enum.Font.Gotham
selectedLabel.TextSize = DROPDOWN_FONT
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.Text = "Выберите игрока"
selectedLabel.ZIndex = 3
selectedLabel.Parent = dropdown

local arrowBtn = Instance.new("TextButton")
arrowBtn.Text = "▼"
arrowBtn.Size = UDim2.new(0, ARROW_BTN_SIZE, 1, 0)
arrowBtn.Position = UDim2.new(1, -ARROW_BTN_SIZE, 0, 0)
arrowBtn.BackgroundTransparency = 1
arrowBtn.TextColor3 = Color3.fromRGB(0,170,255)
arrowBtn.Font = Enum.Font.GothamBold
arrowBtn.TextSize = DROPDOWN_FONT + 6
arrowBtn.ZIndex = 3
arrowBtn.Parent = dropdown

local listFrame = Instance.new("Frame")
listFrame.Name = "ListFrame"
listFrame.Size = UDim2.new(1, 0, 0, 0)
listFrame.Position = UDim2.new(0, 0, 1, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(50, 54, 64)
listFrame.BorderSizePixel = 0
listFrame.ClipsDescendants = true
listFrame.Visible = false
listFrame.ZIndex = 4
listFrame.Parent = dropdown

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, LIST_CORNER)
listCorner.Parent = listFrame

local uiList = Instance.new("UIListLayout")
uiList.Parent = listFrame
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 2)

-- Кнопка ТП
local tpBtn = Instance.new("TextButton")
tpBtn.Text = "ТП к игроку"
tpBtn.Size = UDim2.new(1, -32, 0, TPBTN_HEIGHT)
tpBtn.Position = UDim2.new(0, 16, 1, -(TPBTN_HEIGHT + (isMobile and 10 or 20)))
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpBtn.Font = Enum.Font.GothamBlack
tpBtn.TextSize = TPBTN_FONT
tpBtn.ZIndex = 2
tpBtn.Parent = frame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, TPBTN_CORNER)
tpCorner.Parent = tpBtn

tpBtn.MouseEnter:Connect(function()
    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
end)
tpBtn.MouseLeave:Connect(function()
    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

-- Фаворит игрок
local favoriteUserId = nil

-- Функция обновления списка игроков
local function updatePlayerList()
    for _, child in listFrame:GetChildren() do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    local players = {}
    for _, player in Players:GetPlayers() do
        table.insert(players, player)
    end
    -- Фаворит первым
    if favoriteUserId then
        for i, player in players do
            if player.UserId == favoriteUserId then
                table.remove(players, i)
                table.insert(players, 1, player)
                break
            end
        end
    end
    for i, player in players do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, LIST_BTN_HEIGHT)
        btn.Position = UDim2.new(0, 3, 0, 0)
        btn.BackgroundColor3 = player.UserId == favoriteUserId and Color3.fromRGB(255, 220, 60) or Color3.fromRGB(60, 64, 74)
        btn.TextColor3 = player.UserId == favoriteUserId and Color3.fromRGB(40,40,40) or Color3.fromRGB(220,220,220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = LIST_BTN_FONT
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = (player.UserId == favoriteUserId and "★ " or "") .. player.DisplayName .. " (" .. player.Name .. ")"
        btn.ZIndex = 5
        btn.AutoButtonColor = false
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, isMobile and 5 or 8)
        btnCorner.Parent = btn
        btn.Parent = listFrame

        btn.MouseEnter:Connect(function()
            if player.UserId ~= favoriteUserId then
                btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                btn.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end)
        btn.MouseLeave:Connect(function()
            if player.UserId ~= favoriteUserId then
                btn.BackgroundColor3 = Color3.fromRGB(60, 64, 74)
                btn.TextColor3 = Color3.fromRGB(220,220,220)
            end
        end)

        btn.MouseButton1Click:Connect(function()
            selectedLabel.Text = btn.Text
            selectedLabel:SetAttribute("SelectedUserId", player.UserId)
            listFrame.Visible = false
            listFrame.Size = UDim2.new(1, 0, 0, 0)
        end)
        -- ПКМ - сделать фаворитом (только на ПК)
        if not isMobile then
            btn.MouseButton2Click:Connect(function()
                favoriteUserId = player.UserId
                updatePlayerList()
            end)
        else
            -- На телефоне: долгое нажатие = фаворит
            local touchStart = 0
            btn.TouchLongPress:Connect(function(_, state)
                if state == Enum.UserInputState.Begin then
                    favoriteUserId = player.UserId
                    updatePlayerList()
                end
            end)
        end
    end
end

arrowBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
    if listFrame.Visible then
        local count = #Players:GetPlayers()
        listFrame.Size = UDim2.new(1, 0, 0, math.min(8, count) * (LIST_BTN_HEIGHT + 2))
    else
        listFrame.Size = UDim2.new(1, 0, 0, 0)
    end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

updatePlayerList()

-- ТП кнопка (теперь только локально, без RemoteEvent)
tpBtn.MouseButton1Click:Connect(function()
    local userId = selectedLabel:GetAttribute("SelectedUserId")
    if userId then
        for _, player in Players:GetPlayers() do
            if player.UserId == userId then
                if player.Character and LocalPlayer.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and myHRP then
                        myHRP.CFrame = targetHRP.CFrame + Vector3.new(2,0,0)
                    end
                end
                break
            end
        end
    end
end)

-- Скрытие/открытие меню
local menuHidden = false
local function setMenuVisible(visible)
    for _, obj in frame:GetChildren() do
        if obj ~= header and obj ~= toggleBtn then
            obj.Visible = visible
        end
    end
    tpBtn.Visible = visible
    dropdown.Visible = visible
    shadow.Visible = visible
    menuHidden = not visible
    toggleBtn.Text = visible and "–" or "+"
end

toggleBtn.MouseButton1Click:Connect(function()
    setMenuVisible(menuHidden)
end)

