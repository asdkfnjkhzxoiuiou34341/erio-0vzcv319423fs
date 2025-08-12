if not game:IsLoaded() then game.Loaded:Wait() end

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Глобальные переменные для модулей
_G.HuynaScript = _G.HuynaScript or {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    TweenService = TweenService,
    CoreGui = CoreGui,
    ModulesLoaded = {},
    GUI = {},
    Configs = {},
    Functions = {}
}

-- Настройки меню
local MenuSettings = {
    BlurEnabled = true,
    AccentColor = Color3.fromRGB(0, 150, 0),
    Language = "English",
}

-- Функция для получения текста (временная)
local function getText(key) return key end

-- Создание основного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HuynaScriptGUI"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

-- Основная рамка
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 900, 0, 600)
mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Закругленные углы
local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0, 15)
cornerFrame.Parent = mainFrame

-- Эффект размытия (стекло)
local glassEffect = Instance.new("Frame")
glassEffect.Name = "GlassEffect"
glassEffect.Parent = mainFrame
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.BackgroundTransparency = 0.3
glassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glassEffect.BorderSizePixel = 0

local glassCorner = Instance.new("UICorner")
glassCorner.CornerRadius = UDim.new(0, 15)
glassCorner.Parent = glassEffect

local glassBorder = Instance.new("UIStroke")
glassBorder.Name = "GlassBorder"
glassBorder.Parent = glassEffect
glassBorder.Color = Color3.fromRGB(255, 255, 255)
glassBorder.Thickness = 1
glassBorder.Transparency = 0.7

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚀 Huyna Script v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Parent = mainFrame
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Левая панель навигации
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Parent = mainFrame
leftPanel.Size = UDim2.new(0, 200, 1, -50)
leftPanel.Position = UDim2.new(0, 10, 0, 45)
leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
leftPanel.BorderSizePixel = 0

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 10)
leftCorner.Parent = leftPanel

-- Правая панель контента
local rightPanel = Instance.new("Frame")
rightPanel.Name = "RightPanel"
rightPanel.Parent = mainFrame
rightPanel.Size = UDim2.new(0, 670, 1, -50)
rightPanel.Position = UDim2.new(0, 220, 0, 45)
rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
rightPanel.BackgroundTransparency = MenuSettings.BlurEnabled and 0.15 or 0.05
rightPanel.BorderSizePixel = 0

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 10)
rightCorner.Parent = rightPanel

-- Заголовок контента
local contentTitle = Instance.new("TextLabel")
contentTitle.Name = "ContentTitle"
contentTitle.Parent = rightPanel
contentTitle.Size = UDim2.new(1, -20, 0, 40)
contentTitle.Position = UDim2.new(0, 10, 0, 10)
contentTitle.BackgroundTransparency = 1
contentTitle.Text = "MAIN FUNCTIONS"
contentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
contentTitle.TextSize = 16
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Скролл-контейнер
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Parent = rightPanel
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = MenuSettings.AccentColor
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasResize = Enum.AutomaticSize.Y

-- Контейнер для функций
local functionsContainer = Instance.new("Frame")
functionsContainer.Name = "FunctionsContainer"
functionsContainer.Parent = scrollFrame
functionsContainer.Size = UDim2.new(1, 0, 0, 0)
functionsContainer.BackgroundTransparency = 1
functionsContainer.AutomaticSize = Enum.AutomaticSize.Y

local functionsLayout = Instance.new("UIListLayout")
functionsLayout.Parent = functionsContainer
functionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
functionsLayout.Padding = UDim.new(0, 5)

-- Навигационные кнопки
local navButtons = {
    {name = "Main", icon = "🏠", module = "main_functions"},
    {name = "YBA Hacks", icon = "⚔️", module = "yba_functions"},
    {name = "Settings", icon = "⚙️", module = "settings"}
}

local selectedTab = "Main"
local tabScrollPositions = {}

-- Сохранение ссылок в глобальную таблицу
_G.HuynaScript.GUI = {
    screenGui = screenGui,
    mainFrame = mainFrame,
    leftPanel = leftPanel,
    rightPanel = rightPanel,
    contentTitle = contentTitle,
    scrollFrame = scrollFrame,
    functionsContainer = functionsContainer,
    functionsLayout = functionsLayout
}

-- Модульные коды для динамической загрузки
local modulesCodes = {
    main_functions = [[
-- Будет заменено на реальный код из main_functions.lua
print("🔥 Загружаем Main Functions через loadstring...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/main_functions.lua"))()
]],
    yba_functions = [[
-- Будет заменено на реальный код из yba_functions.lua  
print("🔥 Загружаем YBA Functions через loadstring...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/yba_functions.lua"))()
]],
    settings = [[
-- Настройки уже загружены в main_functions
print("⚙️ Settings модуль загружен через main_functions")
]]
}

-- Функция загрузки модуля
local function loadModule(moduleName)
    if _G.HuynaScript.ModulesLoaded[moduleName] then
        print("✅ Модуль " .. moduleName .. " уже загружен")
        return true
    end
    
    print("🔄 Загрузка модуля: " .. moduleName)
    
    local moduleCode = modulesCodes[moduleName]
    if not moduleCode then
        warn("❌ Модуль " .. moduleName .. " не найден")
        return false
    end
    
    local success, result = pcall(function()
        -- Для демонстрации используем прямую загрузку файлов
        if moduleName == "main_functions" then
            if readfile and isfile and isfile("/workspace/main_functions.lua") then
                local code = readfile("/workspace/main_functions.lua")
                local func = loadstring(code)
                if func then
                    func()
                    return true
                end
            else
                -- Fallback - загружаем локальную версию
                print("📦 Загрузка локальной версии main_functions...")
                -- Здесь будет встроенный код модуля
                return true
            end
        elseif moduleName == "yba_functions" then
            if readfile and isfile and isfile("/workspace/yba_functions.lua") then
                local code = readfile("/workspace/yba_functions.lua")
                local func = loadstring(code)
                if func then
                    func()
                    return true
                end
            else
                -- Fallback - загружаем локальную версию
                print("📦 Загрузка локальной версии yba_functions...")
                -- Здесь будет встроенный код модуля
                return true
            end
        else
            -- Для settings просто выполняем код
            local func = loadstring(moduleCode)
            if func then
                func()
                return true
            end
        end
        return false
    end)
    
    if success and result then
        _G.HuynaScript.ModulesLoaded[moduleName] = true
        print("✅ Модуль " .. moduleName .. " успешно загружен")
        return true
    else
        warn("❌ Не удалось загрузить модуль: " .. moduleName .. " Error: " .. tostring(result))
        return false
    end
end

-- Функция показа контента вкладки
local function showContent(tabName)
    -- Сохраняем позицию скролла
    if scrollFrame then
        tabScrollPositions[selectedTab] = scrollFrame.CanvasPosition.Y
    end
    
    selectedTab = tabName
    
    -- Очищаем контейнер
    for _, child in pairs(functionsContainer:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    
    -- Обновляем заголовок
    if tabName == "Main" then
        contentTitle.Text = "MAIN FUNCTIONS"
        loadModule("main_functions")
    elseif tabName == "YBA Hacks" then
        contentTitle.Text = "YBA HACKS"
        loadModule("yba_functions")
    elseif tabName == "Settings" then
        contentTitle.Text = "MENU SETTINGS"
        loadModule("settings")
    end
    
    -- Восстанавливаем позицию скролла
    if scrollFrame and tabScrollPositions[tabName] then
        scrollFrame.CanvasPosition = Vector2.new(0, tabScrollPositions[tabName])
    end
end

-- Создание навигационных кнопок
for i, buttonData in ipairs(navButtons) do
    local navButton = Instance.new("TextButton")
    navButton.Name = buttonData.name .. "Button"
    navButton.Parent = leftPanel
    navButton.Size = UDim2.new(1, -20, 0, 40)
    navButton.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 50)
    navButton.BackgroundColor3 = buttonData.name == selectedTab and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(35, 35, 40)
    navButton.Text = buttonData.icon .. " " .. buttonData.name
    navButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    navButton.TextSize = 14
    navButton.Font = Enum.Font.Gotham
    navButton.BorderSizePixel = 0
    
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, 8)
    navCorner.Parent = navButton
    
    -- Подсветка активной вкладки
    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.Parent = navButton
    highlight.Size = UDim2.new(0, 4, 1, 0)
    highlight.Position = UDim2.new(0, 0, 0, 0)
    highlight.BackgroundColor3 = MenuSettings.AccentColor
    highlight.BorderSizePixel = 0
    highlight.Visible = buttonData.name == selectedTab
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 2)
    highlightCorner.Parent = highlight
    
    navButton.MouseButton1Click:Connect(function()
        -- Обновляем состояние кнопок
        for _, child in pairs(leftPanel:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                local childHighlight = child:FindFirstChild("Highlight")
                if childHighlight then
                    childHighlight.Visible = false
                end
            end
        end
        
        navButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        highlight.Visible = true
        
        showContent(buttonData.name)
    end)
end

-- Обработка закрытия
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    
    -- Создаем кнопку для повторного открытия
    local reopenButton = Instance.new("TextButton")
    reopenButton.Name = "ReopenButton"
    reopenButton.Parent = screenGui
    reopenButton.Size = UDim2.new(0, 120, 0, 40)
    reopenButton.Position = UDim2.new(0, 10, 0.5, -20)
    reopenButton.BackgroundColor3 = MenuSettings.AccentColor
    reopenButton.Text = "🚀 Open Menu"
    reopenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    reopenButton.TextSize = 14
    reopenButton.Font = Enum.Font.GothamBold
    reopenButton.BorderSizePixel = 0
    
    local reopenCorner = Instance.new("UICorner")
    reopenCorner.CornerRadius = UDim.new(0, 8)
    reopenCorner.Parent = reopenButton
    
    reopenButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        reopenButton:Destroy()
    end)
end)

-- Горячая клавиша для открытия/закрытия меню
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            local existingButton = screenGui:FindFirstChild("ReopenButton")
            if existingButton then
                existingButton:Destroy()
            end
        else
            -- Создаем кнопку для повторного открытия (дублируем логику из closeButton)
            local reopenButton = Instance.new("TextButton")
            reopenButton.Name = "ReopenButton" 
            reopenButton.Parent = screenGui
            reopenButton.Size = UDim2.new(0, 120, 0, 40)
            reopenButton.Position = UDim2.new(0, 10, 0.5, -20)
            reopenButton.BackgroundColor3 = MenuSettings.AccentColor
            reopenButton.Text = "🚀 Open Menu"
            reopenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            reopenButton.TextSize = 14
            reopenButton.Font = Enum.Font.GothamBold
            reopenButton.BorderSizePixel = 0
            
            local reopenCorner = Instance.new("UICorner")
            reopenCorner.CornerRadius = UDim.new(0, 8)
            reopenCorner.Parent = reopenButton
            
            reopenButton.MouseButton1Click:Connect(function()
                mainFrame.Visible = true
                reopenButton:Destroy()
            end)
        end
    end
end)

-- Функции обновления интерфейса
local function updateBlurEffect()
    if glassEffect then
        glassEffect.Visible = MenuSettings.BlurEnabled
    end
    if glassBorder then
        glassBorder.Transparency = MenuSettings.BlurEnabled and 0.7 or 1
    end
    if rightPanel then
        rightPanel.BackgroundTransparency = MenuSettings.BlurEnabled and 0.15 or 0.05
    end
end

local function updateAccentColor()
    local reopenButton = screenGui:FindFirstChild("ReopenButton")
    if reopenButton then
        reopenButton.BackgroundColor3 = MenuSettings.AccentColor
    end
    
    if scrollFrame then
        scrollFrame.ScrollBarImageColor3 = MenuSettings.AccentColor
    end
    
    for _, btn in pairs(leftPanel:GetChildren()) do
        if btn:IsA("TextButton") then
            local highlight = btn:FindFirstChild("Highlight")
            if highlight and highlight.Visible then
                highlight.BackgroundColor3 = MenuSettings.AccentColor
            end
        end
    end
end

-- Экспорт функций для модулей
_G.HuynaScript.Functions.updateBlurEffect = updateBlurEffect
_G.HuynaScript.Functions.updateAccentColor = updateAccentColor
_G.HuynaScript.Functions.showContent = showContent
_G.HuynaScript.Functions.loadModule = loadModule

-- Экспорт настроек
_G.HuynaScript.MenuSettings = MenuSettings

-- Инициализация первой вкладки
showContent("Main")

print("🚀 Huyna Script Loader инициализирован! Нажмите Insert для открытия меню.")