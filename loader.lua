--[[
    Era Hub Clone Loader
    Загрузчик в стиле Era Hub
--]]

-- Создание экрана загрузки
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Защита от повторной загрузки
if getgenv().EraHubLoaderActive then
    warn("Era Hub Loader уже активен!")
    return
end
getgenv().EraHubLoaderActive = true

-- Создание GUI загрузки
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "EraHubLoader"
LoadingGui.Parent = CoreGui
LoadingGui.ResetOnSpawn = false

-- Фон загрузки
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = LoadingGui
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.BackgroundTransparency = 0.3
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)

-- Основной контейнер загрузки
local LoadingContainer = Instance.new("Frame")
LoadingContainer.Name = "LoadingContainer"
LoadingContainer.Parent = LoadingFrame
LoadingContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
LoadingContainer.BorderSizePixel = 0
LoadingContainer.Position = UDim2.new(0.5, -200, 0.5, -100)
LoadingContainer.Size = UDim2.new(0, 400, 0, 200)

-- Закругление углов
local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 15)
ContainerCorner.Parent = LoadingContainer

-- Градиент
local ContainerGradient = Instance.new("UIGradient")
ContainerGradient.Parent = LoadingContainer
ContainerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
ContainerGradient.Rotation = 45

-- Логотип/Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = LoadingContainer
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 20, 0, 20)
TitleLabel.Size = UDim2.new(1, -40, 0, 50)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🚀 Era Hub Clone"
TitleLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
TitleLabel.TextScaled = true

-- Статус загрузки
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = LoadingContainer
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 20, 0, 80)
StatusLabel.Size = UDim2.new(1, -40, 0, 30)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Инициализация..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextScaled = true

-- Прогресс бар
local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Name = "ProgressBarBG"
ProgressBarBG.Parent = LoadingContainer
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProgressBarBG.BorderSizePixel = 0
ProgressBarBG.Position = UDim2.new(0, 20, 0, 130)
ProgressBarBG.Size = UDim2.new(1, -40, 0, 10)

local ProgressBarCorner = Instance.new("UICorner")
ProgressBarCorner.CornerRadius = UDim.new(0, 5)
ProgressBarCorner.Parent = ProgressBarBG

local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"
ProgressBar.Parent = ProgressBarBG
ProgressBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Size = UDim2.new(0, 0, 1, 0)

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 5)
ProgressCorner.Parent = ProgressBar

-- Градиент для прогресс бара
local ProgressGradient = Instance.new("UIGradient")
ProgressGradient.Parent = ProgressBar
ProgressGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 170, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 130, 255))
}

-- Информация о версии
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Parent = LoadingContainer
VersionLabel.BackgroundTransparency = 1
VersionLabel.Position = UDim2.new(0, 20, 1, -40)
VersionLabel.Size = UDim2.new(1, -40, 0, 20)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.Text = "v1.0 • Created by: Your Name"
VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
VersionLabel.TextScaled = true

-- Функция обновления прогресса
local function updateProgress(progress, status)
    StatusLabel.Text = status
    
    local progressTween = TweenService:Create(
        ProgressBar,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(progress / 100, 0, 1, 0)}
    )
    progressTween:Play()
end

-- Анимация появления
LoadingContainer.Size = UDim2.new(0, 0, 0, 0)
LoadingContainer.Position = UDim2.new(0.5, 0, 0.5, 0)

local showTween = TweenService:Create(
    LoadingContainer,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100)
    }
)
showTween:Play()

-- Симуляция загрузки
local loadingSteps = {
    {10, "Проверка безопасности..."},
    {25, "Загрузка ресурсов..."},
    {40, "Инициализация GUI..."},
    {60, "Настройка функций..."},
    {80, "Подключение к серверу..."},
    {100, "Загрузка завершена!"}
}

spawn(function()
    for i, step in ipairs(loadingSteps) do
        wait(0.5)
        updateProgress(step[1], step[2])
    end
    
    wait(1)
    
    -- Анимация исчезновения
    local hideTween = TweenService:Create(
        LoadingContainer,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }
    )
    hideTween:Play()
    
    hideTween.Completed:Connect(function()
        LoadingGui:Destroy()
        getgenv().EraHubLoaderActive = false
        
        -- Здесь загружается основной скрипт
        -- Если ты хочешь загружать с интернета, замени следующую строку на:
        -- loadstring(game:HttpGet("URL_ТВОЕГО_СКРИПТА"))()
        
        -- А пока загружаем локальный скрипт (для демонстрации)
        print("Era Hub Clone Loader: Загрузка основного скрипта...")
        
        -- Если основной скрипт находится в той же папке:
        local success, result = pcall(function()
            -- Здесь должна быть загрузка основного скрипта
            -- Например: loadstring(readfile("era_hub_clone.lua"))()
            print("Основной скрипт должен быть загружен здесь")
            print("Используйте: loadstring(game:HttpGet('YOUR_SCRIPT_URL'))() для онлайн загрузки")
        end)
        
        if not success then
            warn("Ошибка загрузки: " .. tostring(result))
        end
    end)
end)

print("Era Hub Clone Loader запущен!")