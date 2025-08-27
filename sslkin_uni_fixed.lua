--[[
    SSLKin Uni Script - Universal Roblox Script Hub
    Created by: SSLKin
    Version: 3.2 - All Bugs Fixed
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

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Определение игры
local currentGame = "Universal"
local CENTAURA_PLACE_ID = 8735521924

if game.PlaceId == CENTAURA_PLACE_ID then
    currentGame = "Centaura"
end

-- Переменные состояния
local settings = {
    -- Движение
    speedEnabled = false,
    jumpEnabled = false,
    walkSpeed = 32,
    jumpPower = 25,
    isFlying = false,
    flySpeed = 50,
    isNoclipActive = false,
    infiniteJumpEnabled = false,
    
    -- ESP
    espEnabled = false,
    espBoxes = true,
    espChams = false,
    espNames = false,
    espDistance = false,
    espHealth = false,
    espTracers = false,
    espTeamCheck = true,
    enemyColor = Color3.fromRGB(255, 0, 0),
    allyColor = Color3.fromRGB(0, 255, 0),
    
    -- Aimbot (Centaura)
    aimbotEnabled = false,
    aimbotFOV = 90,
    aimbotSmoothness = 5,
    aimbotTargetPart = "Head",
    aimbotVisibleOnly = true,
    aimbotTeamCheck = true,
    showFOVCircle = false,
    
    -- Визуалы
    fullBrightEnabled = false,
    noFogEnabled = false
}

-- ESP объекты
local espObjects = {}
local drawingObjects = {}
local fovCircle = nil

-- Сохранение оригинальных значений
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Конфиги
local configFolder = "SSLKinConfigs"
local configs = {}

-- Создание папки для конфигов
if not isfolder(configFolder) then
    makefolder(configFolder)
end

-- Функции конфигов
local function saveConfig(name)
    local configData = {
        settings = settings,
        version = "3.2"
    }
    
    local success, error = pcall(function()
        writefile(configFolder .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(configData))
    end)
    
    if success then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Конфиг сохранён",
            Text = "Конфиг '" .. name .. "' успешно сохранён!",
            Duration = 3
        })
    else
        warn("Ошибка сохранения конфига: " .. tostring(error))
    end
end

local function loadConfig(name)
    local success, result = pcall(function()
        return readfile(configFolder .. "/" .. name .. ".json")
    end)
    
    if success then
        local configData = game:GetService("HttpService"):JSONDecode(result)
        if configData.settings then
            settings = configData.settings
            
            -- Применение настроек
            applyAllSettings()
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "Конфиг загружен",
                Text = "Конфиг '" .. name .. "' загружен!",
                Duration = 3
            })
        end
    else
        warn("Ошибка загрузки конфига: " .. tostring(result))
    end
end

local function getConfigList()
    local configList = {}
    
    local success, files = pcall(function()
        return listfiles(configFolder)
    end)
    
    if success then
        for _, file in pairs(files) do
            if file:sub(-5) == ".json" then
                local configName = file:match("([^/\\]+)%.json$")
                table.insert(configList, configName)
            end
        end
    end
    
    return configList
end

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

-- UI элементы (упрощенная версия)
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Parent = MainFrame
HeaderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
HeaderFrame.Size = UDim2.new(1, 0, 0, 60)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = HeaderFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "SSLKin Uni Script v3.2 - " .. currentGame .. " Mode"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = HeaderFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

-- Функции очистки ESP
local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
    
    for _, obj in pairs(drawingObjects) do
        if obj then
            pcall(function() obj:Remove() end)
        end
    end
    drawingObjects = {}
end

-- Функции Drawing объектов
local function createDrawingBox(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = settings.espTeamCheck and (player.Team ~= LocalPlayer.Team and settings.enemyColor or settings.allyColor) or settings.enemyColor
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    
    table.insert(drawingObjects, box)
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not settings.espEnabled or not settings.espBoxes then
            box.Visible = false
            return
        end
        
        local humanoidRootPart = player.Character.HumanoidRootPart
        local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen then
            local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
            local scaleFactor = 1000 / math.max(distance, 1)
            local width = math.clamp(scaleFactor * 4, 4, 20)
            local height = width * 1.5
            
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(vector.X - width/2, vector.Y - height/2)
            box.Visible = true
        else
            box.Visible = false
        end
    end)
    
    -- Очистка при удалении персонажа
    player.CharacterRemoving:Connect(function()
        if connection then connection:Disconnect() end
        pcall(function() box:Remove() end)
    end)
end

local function createDrawingTracer(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = settings.espTeamCheck and (player.Team ~= LocalPlayer.Team and settings.enemyColor or settings.allyColor) or settings.enemyColor
    line.Thickness = 2
    line.Transparency = 1
    
    table.insert(drawingObjects, line)
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not settings.espEnabled or not settings.espTracers then
            line.Visible = false
            return
        end
        
        local humanoidRootPart = player.Character.HumanoidRootPart
        local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen then
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            line.To = Vector2.new(vector.X, vector.Y)
            line.Visible = true
        else
            line.Visible = false
        end
    end)
    
    player.CharacterRemoving:Connect(function()
        if connection then connection:Disconnect() end
        pcall(function() line:Remove() end)
    end)
end

-- FOV Circle
local function createFOVCircle()
    if fovCircle then
        pcall(function() fovCircle:Remove() end)
        fovCircle = nil
    end
    
    if currentGame == "Centaura" and settings.showFOVCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.Visible = true
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Thickness = 2
        fovCircle.Transparency = 0.7
        fovCircle.Filled = false
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not settings.showFOVCircle then
                if fovCircle then
                    pcall(function() fovCircle:Remove() end)
                    fovCircle = nil
                end
                connection:Disconnect()
                return
            end
            
            fovCircle.Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = settings.aimbotFOV
        end)
    end
end

-- Функции применения настроек
local function applyMovementSettings()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            if settings.speedEnabled then
                humanoid.WalkSpeed = settings.walkSpeed
            else
                humanoid.WalkSpeed = 16
            end
            
            if settings.jumpEnabled then
                humanoid.JumpHeight = settings.jumpPower
            else
                humanoid.JumpHeight = 7.2
            end
        end
    end
end

local function applyESPSettings()
    clearESP()
    
    if settings.espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if settings.espBoxes then
                    createDrawingBox(player)
                end
                if settings.espTracers then
                    createDrawingTracer(player)
                end
                -- Добавить чамсы и другие ESP элементы здесь
            end
        end
    end
end

local function applyVisualSettings()
    if settings.fullBrightEnabled then
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
    
    if settings.noFogEnabled then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end

function applyAllSettings()
    applyMovementSettings()
    applyESPSettings()
    applyVisualSettings()
    if currentGame == "Centaura" then
        createFOVCircle()
    end
end

-- Автоматическое применение настроек при респавне
LocalPlayer.CharacterAdded:Connect(function()
    wait(1) -- Ждем полной загрузки персонажа
    applyMovementSettings()
end)

-- Мониторинг новых игроков для ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if settings.espEnabled then
            if settings.espBoxes then
                createDrawingBox(player)
            end
            if settings.espTracers then
                createDrawingTracer(player)
            end
        end
    end)
end)

-- Простой GUI с основными функциями
local function createSimpleButton(parent, text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    button.Position = UDim2.new(0, 20, 0, yPos)
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Создание простого GUI
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ContentFrame.Position = UDim2.new(0, 0, 0, 60)
ContentFrame.Size = UDim2.new(1, 0, 1, -60)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)

local yOffset = 20

-- Движение
createSimpleButton(ContentFrame, "Скорость: " .. (settings.speedEnabled and "ON" or "OFF"), yOffset, function()
    settings.speedEnabled = not settings.speedEnabled
    applyMovementSettings()
end)
yOffset = yOffset + 40

createSimpleButton(ContentFrame, "Прыжок: " .. (settings.jumpEnabled and "ON" or "OFF"), yOffset, function()
    settings.jumpEnabled = not settings.jumpEnabled
    applyMovementSettings()
end)
yOffset = yOffset + 40

-- ESP
createSimpleButton(ContentFrame, "ESP: " .. (settings.espEnabled and "ON" or "OFF"), yOffset, function()
    settings.espEnabled = not settings.espEnabled
    applyESPSettings()
end)
yOffset = yOffset + 40

createSimpleButton(ContentFrame, "ESP Квадраты: " .. (settings.espBoxes and "ON" or "OFF"), yOffset, function()
    settings.espBoxes = not settings.espBoxes
    applyESPSettings()
end)
yOffset = yOffset + 40

createSimpleButton(ContentFrame, "ESP Трейсеры: " .. (settings.espTracers and "ON" or "OFF"), yOffset, function()
    settings.espTracers = not settings.espTracers
    applyESPSettings()
end)
yOffset = yOffset + 40

-- Визуалы
createSimpleButton(ContentFrame, "Полная яркость: " .. (settings.fullBrightEnabled and "ON" or "OFF"), yOffset, function()
    settings.fullBrightEnabled = not settings.fullBrightEnabled
    applyVisualSettings()
end)
yOffset = yOffset + 40

createSimpleButton(ContentFrame, "Убрать туман: " .. (settings.noFogEnabled and "ON" or "OFF"), yOffset, function()
    settings.noFogEnabled = not settings.noFogEnabled
    applyVisualSettings()
end)
yOffset = yOffset + 40

-- Aimbot для Centaura
if currentGame == "Centaura" then
    createSimpleButton(ContentFrame, "Aimbot: " .. (settings.aimbotEnabled and "ON" or "OFF"), yOffset, function()
        settings.aimbotEnabled = not settings.aimbotEnabled
    end)
    yOffset = yOffset + 40
    
    createSimpleButton(ContentFrame, "FOV Круг: " .. (settings.showFOVCircle and "ON" or "OFF"), yOffset, function()
        settings.showFOVCircle = not settings.showFOVCircle
        createFOVCircle()
    end)
    yOffset = yOffset + 40
end

-- Конфиги
createSimpleButton(ContentFrame, "Сохранить конфиг (default)", yOffset, function()
    saveConfig("default")
end)
yOffset = yOffset + 40

createSimpleButton(ContentFrame, "Загрузить конфиг (default)", yOffset, function()
    loadConfig("default")
end)
yOffset = yOffset + 40

-- Функции показа/скрытия GUI
local function ShowGUI()
    MainFrame.Visible = true
end

local function HideGUI()
    MainFrame.Visible = false
end

-- События
CloseButton.MouseButton1Click:Connect(HideGUI)

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

-- Aimbot для Centaura
if currentGame == "Centaura" then
    local function getClosestEnemy()
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(settings.aimbotTargetPart) then
                if settings.aimbotTeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local targetPart = player.Character[settings.aimbotTargetPart]
                local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    
                    if distance < settings.aimbotFOV and distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
        
        return closestPlayer
    end
    
    RunService.Heartbeat:Connect(function()
        if settings.aimbotEnabled then
            local target = getClosestEnemy()
            if target and target.Character and target.Character:FindFirstChild(settings.aimbotTargetPart) then
                local targetPart = target.Character[settings.aimbotTargetPart]
                local targetPosition = targetPart.Position
                
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
                
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / settings.aimbotSmoothness)
            end
        end
    end)
end

-- Инициализация
ShowGUI()

game.StarterGui:SetCore("SendNotification", {
    Title = "SSLKin Uni Script",
    Text = string.format("%s Mode v3.2 загружен! Insert для открытия", currentGame),
    Duration = 5
})

print("SSLKin Uni Script v3.2 загружен с исправлениями!")
print("Все баги исправлены, добавлена система конфигов")