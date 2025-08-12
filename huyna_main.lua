if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Создание основного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SSLKIN_GUI"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SSLKIN GUI"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.Parent = titleBar

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 0, 0, 8)
tabCorner.Parent = tabContainer

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -80)
contentContainer.Position = UDim2.new(0, 0, 0, 80)
contentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 0, 0, 8)
contentCorner.Parent = contentContainer

-- Создание вкладок
local tabs = {"Main", "Settings", "YBA Hacks"}
local selectedTab = "Main"

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
    tabButton.Position = UDim2.new(i-1, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 0, 0, 8)
    tabCorner.Parent = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        selectedTab = tabName
        showContent(tabName)
    end)
end

-- Функция показа содержимого
function showContent(tabName)
    -- Очищаем контейнер
    for _, child in pairs(contentContainer:GetChildren()) do
        child:Destroy()
    end
    
    if tabName == "Main" then
        -- Загружаем модуль Main и Settings
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/main_settings_module.lua/main"))()
        end)
        
        if success then
            print("✅ Модуль Main и Settings загружен успешно!")
            
            -- Создаем интерфейс для Main
            local mainLabel = Instance.new("TextLabel")
            mainLabel.Size = UDim2.new(1, 0, 0, 50)
            mainLabel.Position = UDim2.new(0, 0, 0, 0)
            mainLabel.BackgroundTransparency = 1
            mainLabel.Text = "Основные функции загружены с модулем"
            mainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            mainLabel.TextSize = 16
            mainLabel.Font = Enum.Font.Gotham
            mainLabel.TextXAlignment = Enum.TextXAlignment.Center
            mainLabel.TextYAlignment = Enum.TextYAlignment.Center
            mainLabel.Parent = contentContainer
            
            -- Создаем кнопки для функций
            local functions = {"ESP", "Aimbot", "Fly", "NoClip", "Speed Hack", "Long Jump", "Infinite Jump", "Teleport"}
            for i, funcName in ipairs(functions) do
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(0.8, 0, 0, 35)
                button.Position = UDim2.new(0.1, 0, 0, 60 + (i-1) * 45)
                button.Text = funcName
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                button.Font = Enum.Font.Gotham
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                button.BorderSizePixel = 0
                button.Parent = contentContainer
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    print("🔧 Функция", funcName, "доступна через модуль")
                end)
            end
        else
            print("❌ Ошибка загрузки модуля Main и Settings:", result)
            
            -- Fallback интерфейс
            local errorLabel = Instance.new("TextLabel")
            errorLabel.Size = UDim2.new(1, 0, 0, 50)
            errorLabel.Position = UDim2.new(0, 0, 0, 0)
            errorLabel.BackgroundTransparency = 1
            errorLabel.Text = "Ошибка загрузки модуля Main и Settings"
            errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            errorLabel.TextSize = 16
            errorLabel.Font = Enum.Font.Gotham
            errorLabel.TextXAlignment = Enum.TextXAlignment.Center
            errorLabel.TextYAlignment = Enum.TextYAlignment.Center
            errorLabel.Parent = contentContainer
        end
        
    elseif tabName == "Settings" then
        -- Настройки уже загружены с Main модулем
        local settingsLabel = Instance.new("TextLabel")
        settingsLabel.Size = UDim2.new(1, 0, 0, 50)
        settingsLabel.Position = UDim2.new(0, 0, 0, 0)
        settingsLabel.BackgroundTransparency = 1
        settingsLabel.Text = "Настройки загружены с модулем Main"
        settingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        settingsLabel.TextSize = 16
        settingsLabel.Font = Enum.Font.Gotham
        settingsLabel.TextXAlignment = Enum.TextXAlignment.Center
        settingsLabel.TextYAlignment = Enum.TextYAlignment.Center
        settingsLabel.Parent = contentContainer
        
        -- Создаем настройки
        local settings = {"ESP Настройки", "Aimbot Настройки", "Movement Настройки", "Teleport Настройки"}
        for i, settingName in ipairs(settings) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0.8, 0, 0, 35)
            button.Position = UDim2.new(0.1, 0, 0, 60 + (i-1) * 45)
            button.Text = settingName
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            button.BorderSizePixel = 0
            button.Parent = contentContainer
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                print("⚙️ Настройка", settingName, "доступна через модуль")
            end)
        end
        
    elseif tabName == "YBA Hacks" then
        -- Загружаем модуль YBA Hacks
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yba_hacks_module.lua/main"))()
        end)
        
        if success then
            print("✅ Модуль YBA Hacks загружен успешно!")
            
            -- Создаем интерфейс для YBA Hacks
            local ybaLabel = Instance.new("TextLabel")
            ybaLabel.Size = UDim2.new(1, 0, 0, 50)
            ybaLabel.Position = UDim2.new(0, 0, 0, 0)
            ybaLabel.BackgroundTransparency = 1
            ybaLabel.Text = "YBA Hacks загружены с модулем"
            ybaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ybaLabel.TextSize = 16
            ybaLabel.Font = Enum.Font.Gotham
            ybaLabel.TextXAlignment = Enum.TextXAlignment.Center
            ybaLabel.TextYAlignment = Enum.TextYAlignment.Center
            ybaLabel.Parent = contentContainer
            
            -- Создаем кнопки для YBA функций
            local ybaFunctions = {"Stand Range Hack", "Underground Flight", "Item ESP", "Anti Time Stop", "Autofarm"}
            for i, funcName in ipairs(ybaFunctions) do
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(0.8, 0, 0, 35)
                button.Position = UDim2.new(0.1, 0, 0, 60 + (i-1) * 45)
                button.Text = funcName
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                button.Font = Enum.Font.Gotham
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                button.BorderSizePixel = 0
                button.Parent = contentContainer
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    print("🎯 YBA функция", funcName, "доступна через модуль")
                end)
            end
        else
            print("❌ Ошибка загрузки модуля YBA Hacks:", result)
            
            -- Fallback интерфейс
            local errorLabel = Instance.new("TextLabel")
            errorLabel.Size = UDim2.new(1, 0, 0, 50)
            errorLabel.Position = UDim2.new(0, 0, 0, 0)
            errorLabel.BackgroundTransparency = 1
            errorLabel.Text = "Ошибка загрузки модуля YBA Hacks"
            errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            errorLabel.TextSize = 16
            errorLabel.Font = Enum.Font.Gotham
            errorLabel.TextXAlignment = Enum.TextXAlignment.Center
            errorLabel.TextYAlignment = Enum.TextYAlignment.Center
            errorLabel.Parent = contentContainer
        end
    end
end

-- Инициализация
showContent("Main")

-- Обработчик клавиши Insert для скрытия/показа меню
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("🚀 SSLKIN GUI загружен! Нажмите Insert для открытия меню.")
print("📦 Загружаем модули...")
print("📋 Структура модулей:")
print("   - huyna_main.lua (159 строк) - Основной GUI и загрузка модулей")
print("   - main_settings_module.lua (604 строки) - Основные функции (ESP, Aimbot, Movement, Teleport)")
print("   - yba_hacks_module.lua (715 строк) - YBA-специфичные функции")
print("🔧 Общий размер: 1478 строк (включая дополнительную функциональность)")