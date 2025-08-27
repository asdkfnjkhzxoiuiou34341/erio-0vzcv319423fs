--[[
    SSLKin Uni Script - Universal Roblox Script Hub
    Created by: SSLKin
    Version: 3.1
    Fixed ESP, Aimbot, and UI Issues
--]]

-- Защита от повторного запуска
if getgenv().SSLKinUniLoaded then
    warn("SSLKin Uni Script уже запущен!")
    return
end
getgenv().SSLKinUniLoaded = true

-- Основные сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Определение игры
local currentGame = "Universal"
local gameSpecificFeatures = {}

-- Centaura PlaceId
local CENTAURA_PLACE_ID = 8735521924

if game.PlaceId == CENTAURA_PLACE_ID then
    currentGame = "Centaura"
end

-- Переменные состояния
local isFlying = false
local flySpeed = 50
local isNoclipActive = false
local espEnabled = false
local infiniteJumpEnabled = false
local speedEnabled = false
local jumpEnabled = false
local walkSpeed = 16
local jumpPower = 50
local fullBrightEnabled = false
local noFogEnabled = false

-- Centaura специфические переменные
local aimbotEnabled = false
local aimbotFOV = 90
local aimbotSmoothness = 5
local aimbotTargetPart = "Head"
local aimbotVisibleOnly = true
local aimbotTeamCheck = true
local showFOVCircle = false

-- ESP настройки
local espSettings = {
    enabled = false,
    boxes = true,
    chams = false,
    names = false,
    distance = false,
    health = false,
    tracers = false,
    teamCheck = true,
    enemyColor = Color3.fromRGB(255, 0, 0),
    allyColor = Color3.fromRGB(0, 255, 0),
    nameColor = Color3.fromRGB(255, 255, 255),
    tracerColor = Color3.fromRGB(0, 255, 0)
}

-- ESP объекты и Drawing объекты
local espObjects = {}
local drawingObjects = {}

-- FOV Circle
local fovCircle = nil

-- Сохранение оригинальных значений освещения
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SSLKinUniScript"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 100

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -275)
MainFrame.Size = UDim2.new(0, 800, 0, 550)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

-- Обводка главного окна
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(60, 60, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

-- Закругление главного окна
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Заголовок
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Parent = MainFrame
HeaderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Size = UDim2.new(1, 0, 0, 60)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = HeaderFrame

-- Фикс углов заголовка
local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = HeaderFrame
HeaderFix.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
HeaderFix.BorderSizePixel = 0
HeaderFix.Position = UDim2.new(0, 0, 0.5, 0)
HeaderFix.Size = UDim2.new(1, 0, 0.5, 0)

-- Градиент заголовка
local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Parent = HeaderFrame
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 40, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
HeaderGradient.Rotation = 90

-- Логотип и заголовок
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Name = "LogoLabel"
LogoLabel.Parent = HeaderFrame
LogoLabel.BackgroundTransparency = 1
LogoLabel.Position = UDim2.new(0, 20, 0, 5)
LogoLabel.Size = UDim2.new(0, 50, 0, 50)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.Text = currentGame == "Centaura" and "⚔️" or "🚀"
LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoLabel.TextScaled = true

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = HeaderFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 80, 0, 10)
TitleLabel.Size = UDim2.new(1, -200, 0, 25)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "SSLKin Uni Script"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Name = "SubtitleLabel"
SubtitleLabel.Parent = HeaderFrame
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Position = UDim2.new(0, 80, 0, 35)
SubtitleLabel.Size = UDim2.new(1, -200, 0, 20)
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.Text = currentGame == "Centaura" and "Centaura Mode v3.1" or "Universal Mode v3.1"
SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SubtitleLabel.TextSize = 12
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = HeaderFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -45, 0, 15)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Кнопка минимизации
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = HeaderFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -80, 0, 15)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

-- Контейнер для контента
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 0, 0, 60)
ContentContainer.Size = UDim2.new(1, 0, 1, -60)

-- Боковая панель навигации
local SidePanel = Instance.new("Frame")
SidePanel.Name = "SidePanel"
SidePanel.Parent = ContentContainer
SidePanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SidePanel.BorderSizePixel = 0
SidePanel.Size = UDim2.new(0, 200, 1, 0)

local SidePanelCorner = Instance.new("UICorner")
SidePanelCorner.CornerRadius = UDim.new(0, 8)
SidePanelCorner.Parent = SidePanel

-- Фикс углов боковой панели
local SidePanelFix = Instance.new("Frame")
SidePanelFix.Parent = SidePanel
SidePanelFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SidePanelFix.BorderSizePixel = 0
SidePanelFix.Position = UDim2.new(0, 0, 0, 0)
SidePanelFix.Size = UDim2.new(1, 0, 0, 8)

local SidePanelFix2 = Instance.new("Frame")
SidePanelFix2.Parent = SidePanel
SidePanelFix2.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SidePanelFix2.BorderSizePixel = 0
SidePanelFix2.Position = UDim2.new(1, -8, 0, 0)
SidePanelFix2.Size = UDim2.new(0, 8, 1, 0)

-- Основная область контента
local MainContent = Instance.new("ScrollingFrame")
MainContent.Name = "MainContent"
MainContent.Parent = ContentContainer
MainContent.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainContent.BorderSizePixel = 0
MainContent.Position = UDim2.new(0, 200, 0, 0)
MainContent.Size = UDim2.new(1, -200, 1, 0)
MainContent.CanvasSize = UDim2.new(0, 0, 0, 0)
MainContent.ScrollBarThickness = 6
MainContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
MainContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

local MainContentCorner = Instance.new("UICorner")
MainContentCorner.CornerRadius = UDim.new(0, 8)
MainContentCorner.Parent = MainContent

-- Фикс углов основного контента
local MainContentFix = Instance.new("Frame")
MainContentFix.Parent = MainContent
MainContentFix.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainContentFix.BorderSizePixel = 0
MainContentFix.Position = UDim2.new(0, -8, 0, 0)
MainContentFix.Size = UDim2.new(0, 8, 1, 0)

local MainContentFix2 = Instance.new("Frame")
MainContentFix2.Parent = MainContent
MainContentFix2.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainContentFix2.BorderSizePixel = 0
MainContentFix2.Position = UDim2.new(0, 0, 0, 0)
MainContentFix2.Size = UDim2.new(1, 0, 0, 8)

-- Состояние GUI
local isMinimized = false
local originalSize = UDim2.new(0, 800, 0, 550)
local originalPosition = UDim2.new(0.5, -400, 0.5, -275)

-- Анимации
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

-- Функции показа/скрытия GUI
local function ShowGUI()
    MainFrame.Visible = true
    isMinimized = false
    
    if MainFrame.Size == originalSize then
        return -- Уже открыто
    end
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local showTween = CreateTween(MainFrame, {
        Size = originalSize,
        Position = originalPosition
    }, 0.6, Enum.EasingStyle.Back)
    
    showTween:Play()
end

local function HideGUI()
    local hideTween = CreateTween(MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.4, Enum.EasingStyle.Quad)
    
    hideTween:Play()
    
    hideTween.Completed:Connect(function()
        MainFrame.Visible = false
        isMinimized = false
    end)
end

local function MinimizeGUI()
    if isMinimized then
        -- Развернуть
        isMinimized = false
        ContentContainer.Visible = true
        
        local expandTween = CreateTween(MainFrame, {
            Size = originalSize,
            Position = originalPosition
        }, 0.4, Enum.EasingStyle.Quad)
        
        expandTween:Play()
    else
        -- Свернуть
        isMinimized = true
        
        local minimizeTween = CreateTween(MainFrame, {
            Size = UDim2.new(0, 400, 0, 60),
            Position = UDim2.new(0.5, -200, 0.5, -30)
        }, 0.4, Enum.EasingStyle.Quad)
        
        minimizeTween:Play()
        minimizeTween.Completed:Connect(function()
            if isMinimized then
                ContentContainer.Visible = false
            end
        end)
    end
end

-- Система вкладок
local tabs = {}
local currentTab = nil

local function CreateTab(name, icon, color)
    local tabColor = color or Color3.fromRGB(60, 120, 255)
    
    -- Кнопка вкладки
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Parent = SidePanel
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabButton.BorderSizePixel = 0
    TabButton.Position = UDim2.new(0, 10, 0, 15 + (#tabs * 55))
    TabButton.Size = UDim2.new(1, -20, 0, 45)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.Text = ""
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.AutoButtonColor = false
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    -- Иконка
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Parent = TabButton
    IconLabel.BackgroundTransparency = 1
    IconLabel.Position = UDim2.new(0, 15, 0, 0)
    IconLabel.Size = UDim2.new(0, 30, 1, 0)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Text = icon or "📋"
    IconLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    IconLabel.TextSize = 18
    
    -- Текст
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = TabButton
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 50, 0, 0)
    TextLabel.Size = UDim2.new(1, -60, 1, 0)
    TextLabel.Font = Enum.Font.GothamSemibold
    TextLabel.Text = name
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Индикатор активности
    local ActiveIndicator = Instance.new("Frame")
    ActiveIndicator.Name = "ActiveIndicator"
    ActiveIndicator.Parent = TabButton
    ActiveIndicator.BackgroundColor3 = tabColor
    ActiveIndicator.BorderSizePixel = 0
    ActiveIndicator.Position = UDim2.new(0, 0, 0, 0)
    ActiveIndicator.Size = UDim2.new(0, 0, 1, 0)
    ActiveIndicator.Visible = false
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 8)
    IndicatorCorner.Parent = ActiveIndicator
    
    -- Контент вкладки
    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Parent = MainContent
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Visible = false
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = TabContent
    ContentLayout.Padding = UDim.new(0, 15)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.FillDirection = Enum.FillDirection.Vertical
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = TabContent
    ContentPadding.PaddingTop = UDim.new(0, 20)
    ContentPadding.PaddingLeft = UDim.new(0, 20)
    ContentPadding.PaddingRight = UDim.new(0, 20)
    ContentPadding.PaddingBottom = UDim.new(0, 20)
    
    -- Функция переключения вкладки
    local function SelectTab()
        -- Сброс всех вкладок
        for _, tab in pairs(tabs) do
            CreateTween(tab.button, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, 0.2):Play()
            CreateTween(tab.iconLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2):Play()
            CreateTween(tab.textLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2):Play()
            tab.activeIndicator.Visible = false
            tab.content.Visible = false
        end
        
        -- Активация текущей вкладки
        CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.2):Play()
        CreateTween(IconLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2):Play()
        CreateTween(TextLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2):Play()
        
        ActiveIndicator.Visible = true
        ActiveIndicator.Size = UDim2.new(0, 0, 1, 0)
        CreateTween(ActiveIndicator, {Size = UDim2.new(0, 4, 1, 0)}, 0.3, Enum.EasingStyle.Quad):Play()
        
        TabContent.Visible = true
        currentTab = name
    end
    
    -- События
    TabButton.MouseButton1Click:Connect(SelectTab)
    
    TabButton.MouseEnter:Connect(function()
        if currentTab ~= name then
            CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, 0.2):Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if currentTab ~= name then
            CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, 0.2):Play()
        end
    end)
    
    table.insert(tabs, {
        button = TabButton,
        content = TabContent,
        name = name,
        iconLabel = IconLabel,
        textLabel = TextLabel,
        activeIndicator = ActiveIndicator
    })
    
    return TabContent
end

-- Функция создания секции
local function CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Parent = parent
    SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Size = UDim2.new(1, 0, 0, 0)
    SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 10)
    SectionCorner.Parent = SectionFrame
    
    local SectionStroke = Instance.new("UIStroke")
    SectionStroke.Parent = SectionFrame
    SectionStroke.Color = Color3.fromRGB(60, 60, 80)
    SectionStroke.Thickness = 1
    SectionStroke.Transparency = 0.7
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Parent = SectionFrame
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Position = UDim2.new(0, 15, 0, 10)
    SectionTitle.Size = UDim2.new(1, -30, 0, 25)
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextSize = 16
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local SectionContent = Instance.new("Frame")
    SectionContent.Parent = SectionFrame
    SectionContent.BackgroundTransparency = 1
    SectionContent.Position = UDim2.new(0, 10, 0, 40)
    SectionContent.Size = UDim2.new(1, -20, 0, 0)
    SectionContent.AutomaticSize = Enum.AutomaticSize.Y
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = SectionContent
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = SectionContent
    ContentPadding.PaddingBottom = UDim.new(0, 15)
    
    return SectionContent
end

-- Функция создания кнопки
local function CreateButton(parent, text, description, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Parent = parent
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Size = UDim2.new(1, 0, 0, 60)
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ButtonFrame
    
    local ButtonGradient = Instance.new("UIGradient")
    ButtonGradient.Parent = ButtonFrame
    ButtonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 50))
    }
    ButtonGradient.Rotation = 90
    
    local Button = Instance.new("TextButton")
    Button.Parent = ButtonFrame
    Button.BackgroundTransparency = 1
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.Font = Enum.Font.Gotham
    Button.Text = ""
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.AutoButtonColor = false
    
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Parent = ButtonFrame
    ButtonText.BackgroundTransparency = 1
    ButtonText.Position = UDim2.new(0, 15, 0, 8)
    ButtonText.Size = UDim2.new(1, -30, 0, 25)
    ButtonText.Font = Enum.Font.GothamBold
    ButtonText.Text = text
    ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonText.TextSize = 14
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    
    local ButtonDesc = Instance.new("TextLabel")
    ButtonDesc.Parent = ButtonFrame
    ButtonDesc.BackgroundTransparency = 1
    ButtonDesc.Position = UDim2.new(0, 15, 0, 30)
    ButtonDesc.Size = UDim2.new(1, -30, 0, 20)
    ButtonDesc.Font = Enum.Font.Gotham
    ButtonDesc.Text = description or ""
    ButtonDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    ButtonDesc.TextSize = 11
    ButtonDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Эффекты
    Button.MouseEnter:Connect(function()
        CreateTween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}, 0.2):Play()
        CreateTween(ButtonText, {TextColor3 = Color3.fromRGB(100, 150, 255)}, 0.2):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        CreateTween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.2):Play()
        CreateTween(ButtonText, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        -- Анимация нажатия
        CreateTween(ButtonFrame, {Size = UDim2.new(1, -4, 0, 56)}, 0.1):Play()
        wait(0.1)
        CreateTween(ButtonFrame, {Size = UDim2.new(1, 0, 0, 60)}, 0.1):Play()
        
        if callback then 
            spawn(callback)
        end
    end)
    
    return ButtonFrame
end

-- Функция создания переключателя
local function CreateToggle(parent, text, description, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 60)
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Parent = ToggleFrame
    ToggleText.BackgroundTransparency = 1
    ToggleText.Position = UDim2.new(0, 15, 0, 8)
    ToggleText.Size = UDim2.new(1, -80, 0, 25)
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Parent = ToggleFrame
    ToggleDesc.BackgroundTransparency = 1
    ToggleDesc.Position = UDim2.new(0, 15, 0, 30)
    ToggleDesc.Size = UDim2.new(1, -80, 0, 20)
    ToggleDesc.Font = Enum.Font.Gotham
    ToggleDesc.Text = description or ""
    ToggleDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    ToggleDesc.TextSize = 11
    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Переключатель
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(60, 60, 70)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(1, -55, 0.5, -12)
    ToggleButton.Size = UDim2.new(0, 45, 0, 24)
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(0, 12)
    ToggleButtonCorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Parent = ToggleButton
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Position = defaultState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(0, 10)
    CircleCorner.Parent = ToggleCircle
    
    local isToggled = defaultState
    
    ToggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        if isToggled then
            CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(60, 120, 255)}, 0.2):Play()
            CreateTween(ToggleCircle, {Position = UDim2.new(1, -22, 0.5, -10)}, 0.2):Play()
        else
            CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, 0.2):Play()
            CreateTween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.2):Play()
        end
        
        if callback then
            spawn(function() callback(isToggled) end)
        end
    end)
    
    return ToggleFrame, isToggled
end

-- Функция создания ползунка
local function CreateSlider(parent, text, description, minValue, maxValue, defaultValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 80)
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Parent = SliderFrame
    SliderText.BackgroundTransparency = 1
    SliderText.Position = UDim2.new(0, 15, 0, 8)
    SliderText.Size = UDim2.new(1, -100, 0, 20)
    SliderText.Font = Enum.Font.GothamBold
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 14
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Parent = SliderFrame
    SliderValue.BackgroundTransparency = 1
    SliderValue.Position = UDim2.new(1, -85, 0, 8)
    SliderValue.Size = UDim2.new(0, 70, 0, 20)
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.Text = tostring(defaultValue)
    SliderValue.TextColor3 = Color3.fromRGB(100, 150, 255)
    SliderValue.TextSize = 14
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderDesc = Instance.new("TextLabel")
    SliderDesc.Parent = SliderFrame
    SliderDesc.BackgroundTransparency = 1
    SliderDesc.Position = UDim2.new(0, 15, 0, 28)
    SliderDesc.Size = UDim2.new(1, -30, 0, 16)
    SliderDesc.Font = Enum.Font.Gotham
    SliderDesc.Text = description or ""
    SliderDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    SliderDesc.TextSize = 11
    SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Ползунок
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Parent = SliderFrame
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Position = UDim2.new(0, 15, 0, 55)
    SliderTrack.Size = UDim2.new(1, -30, 0, 8)
    
    local SliderTrackCorner = Instance.new("UICorner")
    SliderTrackCorner.CornerRadius = UDim.new(0, 4)
    SliderTrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderTrack
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 4)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Parent = SliderFrame
    SliderButton.BackgroundTransparency = 1
    SliderButton.Position = UDim2.new(0, 10, 0, 50)
    SliderButton.Size = UDim2.new(1, -20, 0, 18)
    SliderButton.Text = ""
    
    local currentValue = defaultValue
    local dragging = false
    
    local function updateSlider(value)
        currentValue = math.clamp(value, minValue, maxValue)
        
        -- Округление до десятых для плавности
        if maxValue - minValue > 10 then
            currentValue = math.floor(currentValue + 0.5)
        else
            currentValue = math.floor(currentValue * 10 + 0.5) / 10
        end
        
        local percentage = (currentValue - minValue) / (maxValue - minValue)
        CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1):Play()
        SliderValue.Text = tostring(currentValue)
        
        if callback then
            callback(currentValue)
        end
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    SliderButton.MouseMoved:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = SliderTrack.AbsolutePosition
            local frameSize = SliderTrack.AbsoluteSize
            
            local relativePos = (mousePos.X - framePos.X) / frameSize.X
            relativePos = math.clamp(relativePos, 0, 1)
            
            local newValue = minValue + (relativePos * (maxValue - minValue))
            updateSlider(newValue)
        end
    end)
    
    return SliderFrame, updateSlider
end

-- Функция создания выпадающего списка
local function CreateDropdown(parent, text, description, options, defaultOption, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Parent = parent
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Size = UDim2.new(1, 0, 0, 80)
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Parent = DropdownFrame
    DropdownText.BackgroundTransparency = 1
    DropdownText.Position = UDim2.new(0, 15, 0, 8)
    DropdownText.Size = UDim2.new(1, -30, 0, 20)
    DropdownText.Font = Enum.Font.GothamBold
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 14
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    
    local DropdownDesc = Instance.new("TextLabel")
    DropdownDesc.Parent = DropdownFrame
    DropdownDesc.BackgroundTransparency = 1
    DropdownDesc.Position = UDim2.new(0, 15, 0, 28)
    DropdownDesc.Size = UDim2.new(1, -30, 0, 16)
    DropdownDesc.Font = Enum.Font.Gotham
    DropdownDesc.Text = description or ""
    DropdownDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    DropdownDesc.TextSize = 11
    DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка выпадающего списка
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Position = UDim2.new(0, 15, 0, 50)
    DropdownButton.Size = UDim2.new(1, -30, 0, 25)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = defaultOption
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 12
    DropdownButton.AutoButtonColor = false
    
    local DropdownButtonCorner = Instance.new("UICorner")
    DropdownButtonCorner.CornerRadius = UDim.new(0, 6)
    DropdownButtonCorner.Parent = DropdownButton
    
    local currentOption = defaultOption
    local isOpen = false
    
    -- Создание списка опций (скрыт по умолчанию)
    local OptionsList = Instance.new("Frame")
    OptionsList.Parent = DropdownFrame
    OptionsList.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    OptionsList.BorderSizePixel = 0
    OptionsList.Position = UDim2.new(0, 15, 0, 76)
    OptionsList.Size = UDim2.new(1, -30, 0, #options * 25)
    OptionsList.Visible = false
    OptionsList.ZIndex = 10
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = OptionsList
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Parent = OptionsList
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Создание опций
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Parent = OptionsList
        OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        OptionButton.BorderSizePixel = 0
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        OptionButton.TextSize = 12
        OptionButton.AutoButtonColor = false
        
        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            currentOption = option
            DropdownButton.Text = option
            OptionsList.Visible = false
            isOpen = false
            
            if callback then
                callback(option)
            end
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        OptionsList.Visible = isOpen
        
        if isOpen then
            DropdownFrame.Size = UDim2.new(1, 0, 0, 80 + (#options * 25))
        else
            DropdownFrame.Size = UDim2.new(1, 0, 0, 80)
        end
    end)
    
    return DropdownFrame
end

-- Функции ESP
local function clearESP()
    -- Очистка Instance объектов
    for _, espObj in pairs(espObjects) do
        if espObj and espObj.Parent then
            espObj:Destroy()
        end
    end
    espObjects = {}
    
    -- Очистка Drawing объектов
    for _, drawObj in pairs(drawingObjects) do
        if drawObj then
            pcall(function()
                drawObj:Remove()
            end)
        end
    end
    drawingObjects = {}
end

local function getPlayerTeam(player)
    if currentGame == "Centaura" then
        return player.Team
    else
        return player.Team
    end
end

local function isPlayerEnemy(player)
    if not espSettings.teamCheck then
        return true
    end
    
    local localTeam = getPlayerTeam(LocalPlayer)
    local playerTeam = getPlayerTeam(player)
    
    if not localTeam or not playerTeam then
        return true
    end
    
    return localTeam ~= playerTeam
end

local function createESPBox(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local isEnemy = isPlayerEnemy(player)
    local espColor = isEnemy and espSettings.enemyColor or espSettings.allyColor
    
    -- Создание чамсов (обводка)
    if espSettings.chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "SSLKinESP"
        highlight.Adornee = character
        highlight.FillColor = espColor
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = espColor
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        table.insert(espObjects, highlight)
    end
    
    -- Создание квадратов (Drawing)
    if espSettings.boxes then
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = espColor
        box.Thickness = 2
        box.Transparency = 1
        box.Filled = false
        
        table.insert(drawingObjects, box)
        
        -- Обновление квадрата
        spawn(function()
            while box and character.Parent and humanoidRootPart.Parent do
                local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                        local scaleFactor = 1000 / distance
                        local width = math.clamp(scaleFactor, 3, 15)
                        local height = width * 1.5
                        
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(vector.X - width/2, vector.Y - height/2)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
                wait()
            end
            if box then
                pcall(function()
                    box:Remove()
                end)
            end
        end)
    end
    
    -- Создание BillboardGui для дополнительной информации
    if espSettings.names or espSettings.distance or espSettings.health then
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESPInfo"
        billboardGui.Adornee = humanoidRootPart
        billboardGui.Size = UDim2.new(0, 200, 0, 100)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = Workspace
        table.insert(espObjects, billboardGui)
        
        local yOffset = 0
        
        -- Имя игрока
        if espSettings.names then
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = billboardGui
            nameLabel.BackgroundTransparency = 1
            nameLabel.Size = UDim2.new(1, 0, 0, 20)
            nameLabel.Position = UDim2.new(0, 0, 0, yOffset)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = espSettings.nameColor
            nameLabel.TextSize = 16
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            yOffset = yOffset + 25
        end
        
        -- Дистанция
        if espSettings.distance then
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Parent = billboardGui
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Size = UDim2.new(1, 0, 0, 16)
            distanceLabel.Position = UDim2.new(0, 0, 0, yOffset)
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.Text = "0m"
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distanceLabel.TextSize = 14
            distanceLabel.TextStrokeTransparency = 0
            distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            yOffset = yOffset + 20
            
            -- Обновление дистанции
            spawn(function()
                while distanceLabel.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    distanceLabel.Text = math.floor(distance) .. "m"
                    wait(0.1)
                end
            end)
        end
        
        -- Здоровье
        if espSettings.health then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local healthLabel = Instance.new("TextLabel")
                healthLabel.Parent = billboardGui
                healthLabel.BackgroundTransparency = 1
                healthLabel.Size = UDim2.new(1, 0, 0, 16)
                healthLabel.Position = UDim2.new(0, 0, 0, yOffset)
                healthLabel.Font = Enum.Font.Gotham
                healthLabel.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                healthLabel.TextSize = 14
                healthLabel.TextStrokeTransparency = 0
                healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                
                -- Обновление здоровья
                humanoid.HealthChanged:Connect(function()
                    if healthLabel.Parent then
                        healthLabel.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        if healthPercent > 0.6 then
                            healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                        elseif healthPercent > 0.3 then
                            healthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                        else
                            healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        end
                    end
                end)
            end
        end
    end
    
    -- Трейсеры
    if espSettings.tracers then
        local line = Drawing.new("Line")
        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        line.Color = espColor
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = true
        
        table.insert(drawingObjects, line)
        
        -- Обновление трейсера
        spawn(function()
            while line and character.Parent and humanoidRootPart.Parent do
                local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
                wait()
            end
            if line then
                pcall(function()
                    line:Remove()
                end)
            end
        end)
    end
end

local function updateESP()
    clearESP()
    
    if espSettings.enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createESPBox(player)
            end
        end
    end
end

-- FOV Circle для аимбота
local function createFOVCircle()
    if fovCircle then
        pcall(function()
            fovCircle:Remove()
        end)
    end
    
    if currentGame == "Centaura" and showFOVCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = aimbotFOV
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Thickness = 2
        fovCircle.Transparency = 0.7
        fovCircle.Filled = false
        fovCircle.Visible = true
        
        -- Обновление позиции и размера круга
        spawn(function()
            while fovCircle and showFOVCircle do
                fovCircle.Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                fovCircle.Radius = aimbotFOV
                wait()
            end
        end)
    end
end

-- Функции освещения
local function toggleFullBright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end

local function toggleNoFog(enabled)
    if enabled then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end

-- Создание вкладок в зависимости от игры
local PlayerTab = CreateTab("Игрок", "👤", Color3.fromRGB(100, 150, 255))
local GameTab = CreateTab("Игра", "🎮", Color3.fromRGB(255, 100, 150))
local VisualTab = CreateTab("Визуалы", "👁", Color3.fromRGB(150, 255, 100))

-- Добавляем вкладку Aimbot только для Centaura
local AimbotTab = nil
if currentGame == "Centaura" then
    AimbotTab = CreateTab("Aimbot", "🎯", Color3.fromRGB(255, 80, 80))
end

local MiscTab = CreateTab("Разное", "⚙", Color3.fromRGB(255, 200, 100))

-- ВКЛАДКА ИГРОКА
local MovementSection = CreateSection(PlayerTab, "🏃 Передвижение")

-- Специальная проверка для Centaura - отключение полёта и noclip при взятии оружия
if currentGame == "Centaura" then
    local function checkWeaponEquipped()
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                if isFlying then
                    isFlying = false
                    if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        for _, obj in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                            if obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") then
                                obj:Destroy()
                            end
                        end
                    end
                end
                if isNoclipActive then
                    isNoclipActive = false
                end
            end
        end
    end
    
    spawn(function()
        while true do
            checkWeaponEquipped()
            wait(0.5)
        end
    end)
end

-- Скорость ходьбы
CreateToggle(MovementSection, "Скорость ходьбы", "Включить/выключить изменение скорости", false, function(state)
    speedEnabled = state
    
    if state then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Скорость включена!",
            Duration = 3
        })
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Скорость выключена!",
            Duration = 3
        })
    end
end)

CreateSlider(MovementSection, "Значение скорости", "От 16 до 100", 16, 100, 32, function(value)
    walkSpeed = value
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
    end
end)

-- Высота прыжка
CreateToggle(MovementSection, "Высота прыжка", "Включить/выключить изменение прыжка", false, function(state)
    jumpEnabled = state
    
    if state then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpHeight = jumpPower
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Прыжок включен!",
            Duration = 3
        })
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpHeight = 7.2
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Прыжок выключен!",
            Duration = 3
        })
    end
end)

CreateSlider(MovementSection, "Значение прыжка", "От 7 до 100", 7, 100, 25, function(value)
    jumpPower = value
    if jumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpHeight = jumpPower
    end
end)

-- Полёт (отключен для Centaura)
if currentGame ~= "Centaura" then
    CreateToggle(MovementSection, "Полёт", "WASD для управления, Space/Shift для вверх/вниз", false, function(state)
        if state then
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not rootPart then return end
            
            isFlying = true
            
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart
            
            local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
            bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
            bodyAngularVelocity.Parent = rootPart
            
            spawn(function()
                while isFlying and bodyVelocity.Parent do
                    local moveVector = Vector3.new(0, 0, 0)
                    local cam = Camera
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveVector = moveVector + (cam.CFrame.LookVector * flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveVector = moveVector - (cam.CFrame.LookVector * flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveVector = moveVector - (cam.CFrame.RightVector * flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveVector = moveVector + (cam.CFrame.RightVector * flySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveVector = moveVector + Vector3.new(0, flySpeed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveVector = moveVector - Vector3.new(0, flySpeed, 0)
                    end
                    
                    bodyVelocity.Velocity = moveVector
                    RunService.Heartbeat:Wait()
                end
            end)
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "SSLKin Uni Script",
                Text = "Полёт активирован!",
                Duration = 3
            })
        else
            isFlying = false
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, obj in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") then
                        obj:Destroy()
                    end
                end
            end
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "SSLKin Uni Script",
                Text = "Полёт деактивирован!",
                Duration = 3
            })
        end
    end)
    
    CreateSlider(MovementSection, "Скорость полёта", "От 10 до 200", 10, 200, 50, function(value)
        flySpeed = value
    end)
end

-- ВКЛАДКА ИГРЫ
local GameplaySection = CreateSection(GameTab, "🎯 Игровые функции")

CreateToggle(GameplaySection, "Бесконечные прыжки", "Позволяет прыгать в воздухе", false, function(state)
    infiniteJumpEnabled = state
    
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Бесконечные прыжки включены!",
            Duration = 3
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Бесконечные прыжки выключены!",
            Duration = 3
        })
    end
end)

-- Noclip (отключен для Centaura)
if currentGame ~= "Centaura" then
    CreateToggle(GameplaySection, "Проход сквозь стены", "Отключает коллизию персонажа", false, function(state)
        isNoclipActive = state
        
        if state then
            game.StarterGui:SetCore("SendNotification", {
                Title = "SSLKin Uni Script",
                Text = "Noclip активирован!",
                Duration = 3
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "SSLKin Uni Script",
                Text = "Noclip деактивирован!",
                Duration = 3
            })
        end
    end)
end

-- ВКЛАДКА AIMBOT (только для Centaura)
if currentGame == "Centaura" and AimbotTab then
    local AimbotMainSection = CreateSection(AimbotTab, "🎯 Основные настройки")
    
    CreateToggle(AimbotMainSection, "Включить Aimbot", "Автоматическое прицеливание на врагов", false, function(state)
        aimbotEnabled = state
        
        if state then
            game.StarterGui:SetCore("SendNotification", {
                Title = "SSLKin Uni Script",
                Text = "Aimbot активирован!",
                Duration = 3
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "SSLKin Uni Script",
                Text = "Aimbot деактивирован!",
                Duration = 3
            })
        end
    end)
    
    CreateSlider(AimbotMainSection, "FOV (поле зрения)", "Радиус захвата цели в пикселях", 30, 300, 90, function(value)
        aimbotFOV = value
        if fovCircle then
            fovCircle.Radius = value
        end
    end)
    
    CreateSlider(AimbotMainSection, "Плавность", "Скорость наведения (чем больше, тем плавнее)", 1, 20, 5, function(value)
        aimbotSmoothness = value
    end)
    
    CreateToggle(AimbotMainSection, "Показать FOV круг", "Отображение круга прицеливания", false, function(state)
        showFOVCircle = state
        createFOVCircle()
    end)
    
    local AimbotTargetSection = CreateSection(AimbotTab, "🎯 Настройки прицеливания")
    
    CreateDropdown(AimbotTargetSection, "Часть тела", "Выберите часть тела для прицеливания", 
        {"Head", "Neck", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, "Head", function(option)
        if option == "Neck" then
            aimbotTargetPart = "Head" -- Шея это часть головы в Roblox
        elseif option == "Torso" then
            aimbotTargetPart = "Torso"
        elseif option == "Left Arm" then
            aimbotTargetPart = "Left Arm"
        elseif option == "Right Arm" then
            aimbotTargetPart = "Right Arm"
        elseif option == "Left Leg" then
            aimbotTargetPart = "Left Leg"
        elseif option == "Right Leg" then
            aimbotTargetPart = "Right Leg"
        else
            aimbotTargetPart = "Head"
        end
    end)
    
    CreateToggle(AimbotTargetSection, "Только видимые цели", "Прицеливаться только на видимых врагов", true, function(state)
        aimbotVisibleOnly = state
    end)
    
    CreateToggle(AimbotTargetSection, "Проверка команды", "Не прицеливаться на союзников", true, function(state)
        aimbotTeamCheck = state
    end)
end

-- ВКЛАДКА ВИЗУАЛОВ
local LightingSection = CreateSection(VisualTab, "💡 Освещение")

CreateToggle(LightingSection, "Полная яркость", "Убирает тени и делает всё ярким", false, function(state)
    fullBrightEnabled = state
    toggleFullBright(state)
    
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Полная яркость включена!",
            Duration = 3
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Полная яркость выключена!",
            Duration = 3
        })
    end
end)

CreateToggle(LightingSection, "Убрать туман", "Увеличивает дальность видимости", false, function(state)
    noFogEnabled = state
    toggleNoFog(state)
    
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Туман убран!",
            Duration = 3
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Туман восстановлен!",
            Duration = 3
        })
    end
end)

local ESPSection = CreateSection(VisualTab, "👁 ESP Настройки")

CreateToggle(ESPSection, "Включить ESP", "Основной переключатель ESP", false, function(state)
    espSettings.enabled = state
    updateESP()
    
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "ESP активирован!",
            Duration = 3
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "ESP деактивирован!",
            Duration = 3
        })
    end
end)

CreateToggle(ESPSection, "Квадраты", "Показывает квадраты вокруг игроков", true, function(state)
    espSettings.boxes = state
    updateESP()
end)

CreateToggle(ESPSection, "Чамсы (обводка)", "Показывает обводку через стены", false, function(state)
    espSettings.chams = state
    updateESP()
end)

CreateToggle(ESPSection, "Имена игроков", "Показывает имена игроков", false, function(state)
    espSettings.names = state
    updateESP()
end)

CreateToggle(ESPSection, "Дистанция", "Показывает расстояние до игроков", false, function(state)
    espSettings.distance = state
    updateESP()
end)

CreateToggle(ESPSection, "Здоровье", "Показывает здоровье игроков", false, function(state)
    espSettings.health = state
    updateESP()
end)

CreateToggle(ESPSection, "Трейсеры", "Линии к игрокам", false, function(state)
    espSettings.tracers = state
    updateESP()
end)

CreateToggle(ESPSection, "Проверка команды", "Разные цвета для союзников и врагов", true, function(state)
    espSettings.teamCheck = state
    updateESP()
end)

-- ВКЛАДКА РАЗНОЕ
local UtilitySection = CreateSection(MiscTab, "🔧 Утилиты")

CreateButton(UtilitySection, "Информация об игре", "Показывает данные о текущей игре", function()
    local success, gameInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    
    if success then
        local info = string.format(
            "Игра: %s\nРежим: %s\nИгроков: %d\nВаш пинг: %d мс\nPlace ID: %d",
            gameInfo.Name,
            currentGame,
            #Players:GetPlayers(),
            math.floor(LocalPlayer:GetNetworkPing() * 1000),
            game.PlaceId
        )
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Информация об игре",
            Text = info,
            Duration = 10
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Ошибка",
            Text = "Не удалось получить информацию об игре",
            Duration = 3
        })
    end
end)

-- Системные функции
local function setupInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function setupNoclip()
    if currentGame ~= "Centaura" then
        RunService.Stepped:Connect(function()
            if isNoclipActive and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            elseif not isNoclipActive and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
end

-- Aimbot для Centaura
if currentGame == "Centaura" then
    local function getClosestEnemy()
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimbotTargetPart) then
                if aimbotTeamCheck and not isPlayerEnemy(player) then
                    continue
                end
                
                local targetPart = player.Character[aimbotTargetPart]
                local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    
                    if distance < aimbotFOV and distance < shortestDistance then
                        if aimbotVisibleOnly then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                            
                            local raycastResult = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
                            
                            if not raycastResult then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        else
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
        
        return closestPlayer
    end
    
    RunService.Heartbeat:Connect(function()
        if aimbotEnabled then
            local target = getClosestEnemy()
            if target and target.Character and target.Character:FindFirstChild(aimbotTargetPart) then
                local targetPart = target.Character[aimbotTargetPart]
                local targetPosition = targetPart.Position
                
                local camera = Camera
                local currentCFrame = camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
                
                camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / aimbotSmoothness)
            end
        end
    end)
end

-- Мониторинг игроков для ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if espSettings.enabled then
            updateESP()
        end
    end)
end)

Players.PlayerRemoving:Connect(function()
    if espSettings.enabled then
        updateESP()
    end
end)

-- Мониторинг смерти игроков
spawn(function()
    while true do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Died:Connect(function()
                        wait(0.5)
                        if espSettings.enabled then
                            updateESP()
                        end
                    end)
                end
            end
        end
        wait(5)
    end
end)

-- Обработчики кнопок
CloseButton.MouseButton1Click:Connect(HideGUI)
MinimizeButton.MouseButton1Click:Connect(MinimizeGUI)

-- Горячие клавиши
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

-- Инициализация
setupInfiniteJump()
setupNoclip()

-- Активация первой вкладки
if #tabs > 0 then
    tabs[1].button.MouseButton1Click()
end

-- Показать GUI при загрузке
ShowGUI()

-- Уведомление о загрузке
game.StarterGui:SetCore("SendNotification", {
    Title = "SSLKin Uni Script",
    Text = string.format("%s Mode v3.1 загружен! Insert для открытия/закрытия", currentGame),
    Duration = 5
})

print(string.format("SSLKin Uni Script v3.1 загружен в режиме %s!", currentGame))
print("Создано by SSLKin | Нажмите Insert для открытия/закрытия")