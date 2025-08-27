--[[
    SSLKin Uni Script - Universal Roblox Script Hub
    Created by: SSLKin
    Version: 2.1
    Modern & Beautiful Design with Sliders and Better ESP
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

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

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

-- ESP настройки
local espSettings = {
    enabled = false,
    boxes = true,
    names = false,
    distance = false,
    health = false,
    tracers = false,
    boxColor = Color3.fromRGB(255, 0, 0),
    nameColor = Color3.fromRGB(255, 255, 255),
    tracerColor = Color3.fromRGB(0, 255, 0)
}

-- ESP объекты
local espObjects = {}

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
LogoLabel.Text = "🚀"
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
SubtitleLabel.Text = "Universal Roblox Script Hub v2.1"
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
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local showTween = CreateTween(MainFrame, {
        Size = UDim2.new(0, 800, 0, 550),
        Position = UDim2.new(0.5, -400, 0.5, -275)
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
    end)
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
        currentValue = math.floor(currentValue + 0.5) -- Округление
        
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

-- ESP Функции
local function clearESP()
    for _, espObj in pairs(espObjects) do
        if espObj then
            espObj:Destroy()
        end
    end
    espObjects = {}
end

local function createESPBox(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Создание обводки
    local highlight = Instance.new("Highlight")
    highlight.Name = "SSLKinESP"
    highlight.Adornee = character
    highlight.FillColor = espSettings.boxColor
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = espSettings.boxColor
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    -- Создание BillboardGui для дополнительной информации
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESPInfo"
    billboardGui.Adornee = humanoidRootPart
    billboardGui.Size = UDim2.new(0, 200, 0, 100)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Parent = Workspace
    
    -- Имя игрока
    if espSettings.names then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboardGui
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = espSettings.nameColor
        nameLabel.TextSize = 16
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    end
    
    -- Дистанция
    if espSettings.distance then
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Parent = billboardGui
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Size = UDim2.new(1, 0, 0, 16)
        distanceLabel.Position = UDim2.new(0, 0, 0, 25)
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.Text = "0m"
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.TextSize = 14
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
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
            healthLabel.Position = UDim2.new(0, 0, 0, 45)
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
    
    -- Трейсеры
    if espSettings.tracers then
        local line = Drawing.new("Line")
        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        line.Color = espSettings.tracerColor
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = true
        
        -- Обновление трейсера
        spawn(function()
            while line and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
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
                line:Remove()
            end
        end)
        
        table.insert(espObjects, line)
    end
    
    table.insert(espObjects, highlight)
    table.insert(espObjects, billboardGui)
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

-- Создание вкладок
local PlayerTab = CreateTab("Игрок", "👤", Color3.fromRGB(100, 150, 255))
local GameTab = CreateTab("Игра", "🎮", Color3.fromRGB(255, 100, 150))
local VisualTab = CreateTab("Визуалы", "👁", Color3.fromRGB(150, 255, 100))
local MiscTab = CreateTab("Разное", "⚙", Color3.fromRGB(255, 200, 100))

-- ВКЛАДКА ИГРОКА
local MovementSection = CreateSection(PlayerTab, "🏃 Передвижение")

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

-- Полёт
CreateToggle(MovementSection, "Полёт", "WASD для управления, Space/Shift для вверх/вниз", false, function(state)
    if state then
        -- Включить полёт
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
        -- Выключить полёт
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

-- ВКЛАДКА ВИЗУАЛОВ
local LightingSection = CreateSection(VisualTab, "💡 Освещение")

CreateButton(LightingSection, "Полный яркий свет", "Убирает тени и делает всё ярким", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "SSLKin Uni Script",
        Text = "Полный яркий свет активирован!",
        Duration = 3
    })
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

CreateToggle(ESPSection, "Обводка игроков", "Показывает обводку вокруг игроков", true, function(state)
    espSettings.boxes = state
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

-- ВКЛАДКА РАЗНОЕ
local UtilitySection = CreateSection(MiscTab, "🔧 Утилиты")

CreateButton(UtilitySection, "Убрать туман", "Увеличивает дальность видимости", function()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "SSLKin Uni Script",
        Text = "Туман убран!",
        Duration = 3
    })
end)

CreateButton(UtilitySection, "Информация об игре", "Показывает данные о текущей игре", function()
    local success, gameInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    
    if success then
        local info = string.format(
            "Игра: %s\nИгроков: %d\nВаш пинг: %d мс\nPlace ID: %d",
            gameInfo.Name,
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

-- Обновление ESP при подключении новых игроков
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

-- Обработчики кнопок
CloseButton.MouseButton1Click:Connect(HideGUI)
MinimizeButton.MouseButton1Click:Connect(HideGUI)

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
    Text = "v2.1 загружен! Нажмите Insert для открытия/закрытия",
    Duration = 5
})

print("SSLKin Uni Script v2.1 загружен успешно!")
print("Создано by SSLKin | Нажмите Insert для открытия/закрытия")