--[[
    SSLKin Uni Script Loader
    Fixed minimize animations
    Created by: SSLKin
--]]

-- Защита от повторной загрузки
if getgenv().SSLKinLoaderActive then
    warn("SSLKin Loader уже активен!")
    return
end
getgenv().SSLKinLoaderActive = true

-- Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Создание GUI загрузки
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "SSLKinLoader"
LoadingGui.Parent = CoreGui
LoadingGui.ResetOnSpawn = false
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.DisplayOrder = 999

-- Фон загрузки с размытием
local LoadingBackground = Instance.new("Frame")
LoadingBackground.Name = "LoadingBackground"
LoadingBackground.Parent = LoadingGui
LoadingBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingBackground.BackgroundTransparency = 0.2
LoadingBackground.BorderSizePixel = 0
LoadingBackground.Size = UDim2.new(1, 0, 1, 0)

-- Главный контейнер загрузки
local LoadingContainer = Instance.new("Frame")
LoadingContainer.Name = "LoadingContainer"
LoadingContainer.Parent = LoadingBackground
LoadingContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
LoadingContainer.BorderSizePixel = 0
LoadingContainer.Position = UDim2.new(0.5, -250, 0.5, -100)
LoadingContainer.Size = UDim2.new(0, 500, 0, 200)

-- Обводка контейнера
local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Parent = LoadingContainer
ContainerStroke.Color = Color3.fromRGB(80, 120, 255)
ContainerStroke.Thickness = 2
ContainerStroke.Transparency = 0.3

-- Закругление углов
local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 15)
ContainerCorner.Parent = LoadingContainer

-- Градиент фона
local ContainerGradient = Instance.new("UIGradient")
ContainerGradient.Parent = LoadingContainer
ContainerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
}
ContainerGradient.Rotation = 45

-- Логотип
local LogoFrame = Instance.new("Frame")
LogoFrame.Parent = LoadingContainer
LogoFrame.BackgroundTransparency = 1
LogoFrame.Position = UDim2.new(0, 30, 0, 30)
LogoFrame.Size = UDim2.new(0, 60, 0, 60)

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Parent = LogoFrame
LogoIcon.BackgroundTransparency = 1
LogoIcon.Size = UDim2.new(1, 0, 1, 0)
LogoIcon.Font = Enum.Font.GothamBold
LogoIcon.Text = "🚀"
LogoIcon.TextColor3 = Color3.fromRGB(100, 150, 255)
LogoIcon.TextScaled = true

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = LoadingContainer
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 110, 0, 40)
TitleLabel.Size = UDim2.new(1, -140, 0, 35)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "SSLKin Uni Script"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 24
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Подзаголовок
local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Name = "SubtitleLabel"
SubtitleLabel.Parent = LoadingContainer
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Position = UDim2.new(0, 110, 0, 75)
SubtitleLabel.Size = UDim2.new(1, -140, 0, 20)
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.Text = "Universal Roblox Script Hub"
SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SubtitleLabel.TextSize = 14
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Прогресс бар контейнер
local ProgressContainer = Instance.new("Frame")
ProgressContainer.Parent = LoadingContainer
ProgressContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ProgressContainer.BorderSizePixel = 0
ProgressContainer.Position = UDim2.new(0, 30, 0, 130)
ProgressContainer.Size = UDim2.new(1, -60, 0, 12)

local ProgressContainerCorner = Instance.new("UICorner")
ProgressContainerCorner.CornerRadius = UDim.new(0, 6)
ProgressContainerCorner.Parent = ProgressContainer

-- Прогресс бар
local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"
ProgressBar.Parent = ProgressContainer
ProgressBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Size = UDim2.new(0, 0, 1, 0)

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 6)
ProgressCorner.Parent = ProgressBar

-- Градиент для прогресс бара
local ProgressGradient = Instance.new("UIGradient")
ProgressGradient.Parent = ProgressBar
ProgressGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 170, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 130, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 120, 255))
}

-- Информация о версии
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Parent = LoadingContainer
VersionLabel.BackgroundTransparency = 1
VersionLabel.Position = UDim2.new(0, 30, 1, -30)
VersionLabel.Size = UDim2.new(1, -60, 0, 20)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.Text = "v3.1 • Created by SSLKin • Universal Script Hub"
VersionLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
VersionLabel.TextSize = 10
VersionLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Анимация логотипа
spawn(function()
    while LoadingGui.Parent do
        for i = 0, 360, 5 do
            if LoadingGui.Parent then
                LogoIcon.Rotation = i
                ContainerGradient.Rotation = 45 + (i / 4)
                wait(0.03)
            end
        end
    end
end)

-- Анимация обводки
spawn(function()
    while LoadingGui.Parent do
        local colorTween = TweenService:Create(
            ContainerStroke,
            TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Color = Color3.fromRGB(255, 100, 150)}
        )
        colorTween:Play()
        wait(4)
        if LoadingGui.Parent then
            colorTween:Cancel()
            ContainerStroke.Color = Color3.fromRGB(80, 120, 255)
        end
    end
end)

-- Функция обновления прогресса
local function updateProgress(progress)
    local progressTween = TweenService:Create(
        ProgressBar,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(progress / 100, 0, 1, 0)}
    )
    progressTween:Play()
    
    -- Эффект свечения при достижении 100%
    if progress >= 100 then
        local glowTween = TweenService:Create(
            ProgressBar,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 3, true),
            {BackgroundColor3 = Color3.fromRGB(150, 255, 150)}
        )
        glowTween:Play()
    end
end

-- Анимация появления
LoadingContainer.Size = UDim2.new(0, 0, 0, 0)
LoadingContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingBackground.BackgroundTransparency = 1

local backgroundTween = TweenService:Create(
    LoadingBackground,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency = 0.2}
)

local showTween = TweenService:Create(
    LoadingContainer,
    TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {
        Size = UDim2.new(0, 500, 0, 200),
        Position = UDim2.new(0.5, -250, 0.5, -100)
    }
)

backgroundTween:Play()
wait(0.2)
showTween:Play()

-- Простая загрузка с плавным прогрессом
spawn(function()
    wait(1.5) -- Ждём завершения анимации появления
    
    -- Плавная загрузка от 0 до 100
    for i = 0, 100, 2 do
        updateProgress(i)
        wait(0.05) -- Быстрая и плавная загрузка
    end
    
    wait(0.5)
    
    -- Анимация исчезновения (правильная)
    local hideTween = TweenService:Create(
        LoadingContainer,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }
    )
    
    local backgroundHideTween = TweenService:Create(
        LoadingBackground,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    hideTween:Play()
    backgroundHideTween:Play()
    
    hideTween.Completed:Connect(function()
        LoadingGui:Destroy()
        getgenv().SSLKinLoaderActive = false
        
        -- Здесь должна быть загрузка основного скрипта
        print("SSLKin Loader: Загрузка основного скрипта...")
        
        -- Для онлайн загрузки замените эту строку на:
        -- loadstring(game:HttpGet("YOUR_SCRIPT_URL"))()
        
        -- Уведомление о готовности
        game.StarterGui:SetCore("SendNotification", {
            Title = "SSLKin Uni Script",
            Text = "Готов к использованию! Основной скрипт загружен.",
            Duration = 5
        })
        
        -- Здесь можно добавить загрузку основного скрипта
        print("Основной скрипт готов к загрузке!")
        print("Замените эту строку на: loadstring(game:HttpGet('YOUR_URL'))() для онлайн загрузки")
    end)
end)

print("SSLKin Uni Script Loader запущен!")