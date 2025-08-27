--[[
    Era Hub Clone - Modern Roblox Script Hub
    Created by: Your Name
    Version: 1.0
--]]

-- Создание защиты от повторного запуска
if getgenv().EraHubLoaded then
    warn("Era Hub уже запущен!")
    return
end
getgenv().EraHubLoaded = true

-- Основные переменные
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EraHubClone"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

-- Градиент для главного окна
local MainGradient = Instance.new("UIGradient")
MainGradient.Parent = MainFrame
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
}
MainGradient.Rotation = 45

-- Закругление углов
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Тень для главного окна
local ShadowFrame = Instance.new("Frame")
ShadowFrame.Name = "ShadowFrame"
ShadowFrame.Parent = ScreenGui
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShadowFrame.BackgroundTransparency = 0.7
ShadowFrame.BorderSizePixel = 0
ShadowFrame.Position = UDim2.new(0.5, -305, 0.5, -220)
ShadowFrame.Size = UDim2.new(0, 610, 0, 460)
ShadowFrame.ZIndex = MainFrame.ZIndex - 1
ShadowFrame.Visible = false

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 15)
ShadowCorner.Parent = ShadowFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 50)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

-- Фикс углов заголовка
local TitleFix = Instance.new("Frame")
TitleFix.Parent = TitleBar
TitleFix.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)

-- Заголовок текст
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Era Hub Clone"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Кнопка минимизации
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 85)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -75, 0, 10)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextScaled = true

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

-- Боковая панель для вкладок
local SidePanel = Instance.new("Frame")
SidePanel.Name = "SidePanel"
SidePanel.Parent = MainFrame
SidePanel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SidePanel.BorderSizePixel = 0
SidePanel.Position = UDim2.new(0, 0, 0, 50)
SidePanel.Size = UDim2.new(0, 150, 1, -50)

-- Основная область контента
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 150, 0, 50)
ContentFrame.Size = UDim2.new(1, -150, 1, -50)
ContentFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ContentFrame.ScrollBarThickness = 8
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

-- Анимации
local function CreateTween(object, properties, duration, easingStyle)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

-- Функции для анимации появления/исчезновения
local function ShowGUI()
    MainFrame.Visible = true
    ShadowFrame.Visible = true
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local showTween = CreateTween(MainFrame, {
        Size = UDim2.new(0, 600, 0, 450),
        Position = UDim2.new(0.5, -300, 0.5, -225)
    }, 0.5, Enum.EasingStyle.Back)
    
    showTween:Play()
end

local function HideGUI()
    local hideTween = CreateTween(MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.3, Enum.EasingStyle.Quad)
    
    hideTween:Play()
    hideTween.Completed:Connect(function()
        MainFrame.Visible = false
        ShadowFrame.Visible = false
    end)
end

-- Обработчики кнопок
CloseButton.MouseButton1Click:Connect(HideGUI)
MinimizeButton.MouseButton1Click:Connect(HideGUI)

-- Создание вкладок
local tabs = {}
local currentTab = nil

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Parent = SidePanel
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TabButton.BorderSizePixel = 0
    TabButton.Position = UDim2.new(0, 5, 0, 10 + (#tabs * 45))
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.Font = Enum.Font.Gotham
    TabButton.Text = "  " .. (icon or "📋") .. "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextScaled = true
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Parent = ContentFrame
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Visible = false
    
    local function SelectTab()
        -- Сброс всех вкладок
        for _, tab in pairs(tabs) do
            tab.button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            tab.button.TextColor3 = Color3.fromRGB(200, 200, 200)
            tab.content.Visible = false
        end
        
        -- Активация текущей вкладки
        TabButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabContent.Visible = true
        currentTab = name
    end
    
    TabButton.MouseButton1Click:Connect(SelectTab)
    
    -- Эффект наведения
    TabButton.MouseEnter:Connect(function()
        if currentTab ~= name then
            CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}, 0.2):Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if currentTab ~= name then
            CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}, 0.2):Play()
        end
    end)
    
    table.insert(tabs, {
        button = TabButton,
        content = TabContent,
        name = name
    })
    
    return TabContent
end

-- Функция создания кнопки
local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Font = Enum.Font.Gotham
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    -- Эффекты наведения
    Button.MouseEnter:Connect(function()
        CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(70, 130, 255)}, 0.2):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(60, 120, 255)}, 0.2):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        CreateTween(Button, {Size = UDim2.new(1, -25, 0, 30)}, 0.1):Play()
        wait(0.1)
        CreateTween(Button, {Size = UDim2.new(1, -20, 0, 35)}, 0.1):Play()
        if callback then callback() end
    end)
    
    return Button
end

-- Функция создания лейбла
local function CreateLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    return Label
end

-- Создание вкладок
local PlayerTab = CreateTab("Игрок", "👤")
local GameTab = CreateTab("Игра", "🎮")
local VisualTab = CreateTab("Визуалы", "👁")
local MiscTab = CreateTab("Разное", "⚙")

-- Настройка layout для вкладок
for _, tab in pairs(tabs) do
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = tab.content
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Padding = Instance.new("UIPadding")
    Padding.Parent = tab.content
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
end

-- Заполнение вкладки "Игрок"
CreateLabel(PlayerTab, "🏃 Передвижение")
CreateButton(PlayerTab, "Скорость x2", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 32
        print("Скорость увеличена!")
    end
end)

CreateButton(PlayerTab, "Прыжок x2", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 100
        print("Высота прыжка увеличена!")
    end
end)

CreateButton(PlayerTab, "Полёт", function()
    local function Fly()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        local flying = true
        print("Полёт активирован! WASD для управления, X для остановки")
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.X then
                flying = false
                bodyVelocity:Destroy()
                connection:Disconnect()
                print("Полёт деактивирован!")
            end
        end)
        
        spawn(function()
            while flying and bodyVelocity.Parent do
                local moveVector = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + (workspace.CurrentCamera.CFrame.LookVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - (workspace.CurrentCamera.CFrame.LookVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - (workspace.CurrentCamera.CFrame.RightVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + (workspace.CurrentCamera.CFrame.RightVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 50, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 50, 0)
                end
                
                bodyVelocity.Velocity = moveVector
                wait()
            end
        end)
    end
    
    Fly()
end)

-- Заполнение вкладки "Игра"
CreateLabel(GameTab, "🎯 Функции игры")
CreateButton(GameTab, "Бесконечные прыжки", function()
    local InfiniteJumpEnabled = true
    
    game:GetService("UserInputService").JumpRequest:connect(function()
        if InfiniteJumpEnabled then
            game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState("Jumping")
        end
    end)
    
    print("Бесконечные прыжки активированы!")
end)

CreateButton(GameTab, "Проход сквозь стены", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    local function noclip()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    local noclipConnection = game:GetService("RunService").Stepped:Connect(noclip)
    
    print("Проход сквозь стены активирован! Нажмите кнопку снова для отключения")
    
    -- Здесь можно добавить логику для отключения
end)

-- Заполнение вкладки "Визуалы"
CreateLabel(VisualTab, "👁 Визуальные эффекты")
CreateButton(VisualTab, "Полный яркий свет", function()
    game.Lighting.Brightness = 2
    game.Lighting.ClockTime = 14
    game.Lighting.FogEnd = 100000
    game.Lighting.GlobalShadows = false
    game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    print("Полный яркий свет активирован!")
end)

CreateButton(VisualTab, "ESP Игроки", function()
    local function createESP(player)
        if player == LocalPlayer then return end
        
        local function addESP(character)
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "ESP"
            billboardGui.Adornee = humanoidRootPart
            billboardGui.Size = UDim2.new(0, 100, 0, 50)
            billboardGui.StudsOffset = Vector3.new(0, 2, 0)
            billboardGui.Parent = workspace
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 0.3
            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            frame.BorderSizePixel = 0
            frame.Parent = billboardGui
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = player.Name
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.Gotham
            textLabel.Parent = frame
        end
        
        if player.Character then
            addESP(player.Character)
        end
        
        player.CharacterAdded:Connect(addESP)
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    Players.PlayerAdded:Connect(createESP)
    
    print("ESP для игроков активирован!")
end)

-- Заполнение вкладки "Разное"
CreateLabel(MiscTab, "⚙ Дополнительные функции")
CreateButton(MiscTab, "Убрать туман", function()
    game.Lighting.FogEnd = 100000
    print("Туман убран!")
end)

CreateButton(MiscTab, "Информация об игре", function()
    local gameInfo = string.format(
        "Игра: %s\nИгроков: %d\nВаш пинг: %d мс",
        game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        #Players:GetPlayers(),
        LocalPlayer:GetNetworkPing() * 1000
    )
    print(gameInfo)
end)

-- Кнопка для открытия/закрытия GUI
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.Size = UDim2.new(0, 100, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Era Hub"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        HideGUI()
    else
        ShowGUI()
    end
end)

-- Хоткей для открытия/закрытия (Insert)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        if MainFrame.Visible then
            HideGUI()
        else
            ShowGUI()
        end
    end
end)

-- Активация первой вкладки по умолчанию
if #tabs > 0 then
    tabs[1].button.MouseButton1Click()
end

-- Показать GUI при загрузке
ShowGUI()

print("Era Hub Clone загружен! Нажмите Insert или кнопку для открытия/закрытия")