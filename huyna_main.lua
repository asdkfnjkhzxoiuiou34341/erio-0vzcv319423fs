if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Основные настройки меню
local MenuSettings = {
    BlurEnabled = true,
    AccentColor = Color3.fromRGB(0, 150, 0),
    Language = "English",
}

-- Простая функция для текста (можно расширить)
local function getText(key) return key end

-- Функция обновления эффекта размытия
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

-- Функция обновления цвета акцента
local function updateAccentColor()
    local reopenButton = screenGui:FindFirstChild("ReopenButton")
    if reopenButton then
        reopenButton.BackgroundColor3 = MenuSettings.AccentColor
    end
    
    for _, child in pairs(functionsContainer:GetChildren()) do
        if child:IsA("Frame") then
            local sliderBack = child:FindFirstChild("SliderBack")
            if sliderBack and sliderBack.BackgroundColor3 ~= Color3.fromRGB(100, 100, 100) then
                sliderBack.BackgroundColor3 = MenuSettings.AccentColor
            end
        end
    end
    
    for _, btn in pairs(leftPanel:GetChildren()) do
        if btn:IsA("TextButton") and btn.BackgroundColor3 == Color3.fromRGB(40, 40, 45) then
            local highlight = btn:FindFirstChild("Highlight")
            if highlight then
                highlight.BackgroundColor3 = MenuSettings.AccentColor
            end
        end
    end
end

-- Функция обновления всех текстов
local function updateAllTexts()
    if contentTitle then
        if selectedTab == "Main" then
            contentTitle.Text = getText("MainFunctions")
        elseif selectedTab == "YBA Hacks" then
            contentTitle.Text = getText("YBAHacks")
        elseif selectedTab == "Settings" then
            contentTitle.Text = getText("MenuSettings")
        end
    end
    
    showContent(selectedTab)
end

-- Создание GUI
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "SslkinGui"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Position = UDim2.new(0, 20, 0.5, -250)
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local minWidth = 200
local minHeight = 150

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 8)

local leftPanel = Instance.new("Frame", mainFrame)
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 120, 1, 0)
leftPanel.Position = UDim2.new(0, 0, 0, 0)
leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
leftPanel.BackgroundTransparency = 0
leftPanel.BorderSizePixel = 0

local leftCorner = Instance.new("UICorner", leftPanel)
leftCorner.CornerRadius = UDim.new(0, 8)

local logoFrame = Instance.new("Frame", leftPanel)
logoFrame.Name = "LogoFrame"
logoFrame.Size = UDim2.new(1, 0, 0, 80)
logoFrame.Position = UDim2.new(0, 0, 0, 0)
logoFrame.BackgroundTransparency = 1

local logoText = Instance.new("TextLabel", logoFrame)
logoText.Name = "LogoText"
logoText.Size = UDim2.new(1, 0, 0, 40)
logoText.Position = UDim2.new(0, 0, 0, 10)
logoText.Text = "SSLKIN"
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 18
logoText.TextColor3 = Color3.new(1, 1, 1)
logoText.BackgroundTransparency = 1
logoText.TextXAlignment = Enum.TextXAlignment.Center

local versionText = Instance.new("TextLabel", logoFrame)
versionText.Name = "VersionText"
versionText.Size = UDim2.new(1, 0, 0, 20)
versionText.Position = UDim2.new(0, 0, 0, 50)
versionText.Text = "UNIVERSAL SCRIPT"
versionText.Font = Enum.Font.Gotham
versionText.TextSize = 10
versionText.TextColor3 = Color3.new(1, 1, 1)
versionText.BackgroundTransparency = 1
versionText.TextXAlignment = Enum.TextXAlignment.Center

local navButtons = {
    {name = "Main", icon = "🏠"},
    {name = "YBA Hacks", icon = "⚔️"},
    {name = "Settings", icon = "⚙️"}
}

local selectedTab = "Main"

-- Позиции прокрутки для каждой вкладки
local tabScrollPositions = {
    ["Main"] = 0,
    ["YBA Hacks"] = 0,
    ["Settings"] = 0
}

for i, buttonData in ipairs(navButtons) do
    local navButton = Instance.new("TextButton", leftPanel)
    navButton.Name = buttonData.name .. "Button"
    navButton.Size = UDim2.new(1, -20, 0, 40)
    navButton.Position = UDim2.new(0, 10, 0, 100 + (i-1) * 50)
    navButton.Text = buttonData.icon .. " " .. buttonData.name
    navButton.Font = Enum.Font.Gotham
    navButton.TextSize = 14
    navButton.TextColor3 = Color3.new(1, 1, 1)
    navButton.BackgroundColor3 = buttonData.name == selectedTab and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(30, 30, 35)
    navButton.BorderSizePixel = 0
    navButton.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner", navButton)
    buttonCorner.CornerRadius = UDim.new(0, 6)
    
    -- Подсветка выбранной вкладки
    if buttonData.name == selectedTab then
        local highlight = Instance.new("Frame", navButton)
        highlight.Name = "Highlight"
        highlight.Size = UDim2.new(0, 3, 1, 0)
        highlight.Position = UDim2.new(0, 0, 0, 0)
        highlight.BackgroundColor3 = MenuSettings.AccentColor
        highlight.BorderSizePixel = 0
        
        local highlightCorner = Instance.new("UICorner", highlight)
        highlightCorner.CornerRadius = UDim.new(0, 2)
    end
    
    navButton.MouseButton1Click:Connect(function()
        -- Обновляем выбранную вкладку
        for _, btn in pairs(leftPanel:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                local highlight = btn:FindFirstChild("Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        
        navButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        selectedTab = buttonData.name
        
        local highlight = Instance.new("Frame", navButton)
        highlight.Name = "Highlight"
        highlight.Size = UDim2.new(0, 3, 1, 0)
        highlight.Position = UDim2.new(0, 0, 0, 0)
        highlight.BackgroundColor3 = MenuSettings.AccentColor
        highlight.BorderSizePixel = 0
        
        local highlightCorner = Instance.new("UICorner", highlight)
        highlightCorner.CornerRadius = UDim.new(0, 2)
        
        showContent(buttonData.name)
    end)
end

local rightPanel = Instance.new("Frame", mainFrame)
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(1, -120, 1, 0)
rightPanel.Position = UDim2.new(0, 120, 0, 0)
rightPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
rightPanel.BackgroundTransparency = 0.15
rightPanel.BorderSizePixel = 0

local glassEffect = Instance.new("Frame", rightPanel)
glassEffect.Name = "GlassEffect"
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.Position = UDim2.new(0, 0, 0, 0)
glassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glassEffect.BackgroundTransparency = 0.92
glassEffect.BorderSizePixel = 0
glassEffect.ZIndex = -1

local glassGradient = Instance.new("UIGradient", glassEffect)
glassGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 220)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 170)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 120))
}
glassGradient.Rotation = 45

local glassBorder = Instance.new("UIStroke", rightPanel)
glassBorder.Color = Color3.fromRGB(200, 200, 220)
glassBorder.Transparency = 0.7
glassBorder.Thickness = 1

local rightCorner = Instance.new("UICorner", rightPanel)
rightCorner.CornerRadius = UDim.new(0, 8)

local glassCorner = Instance.new("UICorner", glassEffect)
glassCorner.CornerRadius = UDim.new(0, 8)

local closeButton = Instance.new("TextButton", rightPanel)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false

local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 6)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    createReopenButton()
end)

local resizeHandle = Instance.new("Frame", mainFrame)
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 15, 0, 15)
resizeHandle.Position = UDim2.new(1, -15, 1, -15)
resizeHandle.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
resizeHandle.BorderSizePixel = 0

local resizeCorner = Instance.new("UICorner", resizeHandle)
resizeCorner.CornerRadius = UDim.new(0, 4)

-- Обработчик изменения размера
local isResizing = false
local startSize = Vector2.new()
local startPos = Vector2.new()

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isResizing = true
        startSize = Vector2.new(mainFrame.Size.X.Offset, mainFrame.Size.Y.Offset)
        startPos = Vector2.new(input.Position.X, input.Position.Y)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isResizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - startPos
        local newSize = Vector2.new(
            math.max(minWidth, startSize.X + delta.X),
            math.max(minHeight, startSize.Y + delta.Y)
        )
        mainFrame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
    end
end)

local contentTitle = Instance.new("TextLabel", rightPanel)
contentTitle.Name = "ContentTitle"
contentTitle.Size = UDim2.new(1, -20, 0, 40)
contentTitle.Position = UDim2.new(0, 10, 0, 10)
contentTitle.Text = "MAIN FUNCTIONS"
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 18
contentTitle.TextColor3 = Color3.new(1, 1, 1)
contentTitle.BackgroundTransparency = 1
contentTitle.TextXAlignment = Enum.TextXAlignment.Left

local scrollFrame = Instance.new("ScrollingFrame", rightPanel)
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local functionsContainer = Instance.new("Frame", scrollFrame)
functionsContainer.Name = "FunctionsContainer"
functionsContainer.Size = UDim2.new(1, 0, 0, 0)
functionsContainer.Position = UDim2.new(0, 0, 0, 0)
functionsContainer.BackgroundTransparency = 1
functionsContainer.BorderSizePixel = 0

-- Функции для создания элементов интерфейса
local function createToggleSlider(text, defaultValue, callback)
    local container = Instance.new("Frame", functionsContainer)
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, currentY)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton", container)
    toggleButton.Size = UDim2.new(0.25, 0, 0.8, 0)
    toggleButton.Position = UDim2.new(0.75, 0, 0.1, 0)
    toggleButton.Text = defaultValue and "ON" or "OFF"
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.TextSize = 12
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner", toggleButton)
    toggleCorner.CornerRadius = UDim.new(0, 6)
    
    local isEnabled = defaultValue
    
    toggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleButton.Text = isEnabled and "ON" or "OFF"
        toggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        if callback then
            callback(isEnabled)
        end
    end)
    
    currentY = currentY + 30 + padding
    return toggleButton
end

local function createSlider(text, minValue, maxValue, defaultValue, callback)
    local container = Instance.new("Frame", functionsContainer)
    container.Size = UDim2.new(1, -10, 0, 40)
    container.Position = UDim2.new(0, 5, 0, currentY)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = text .. ": " .. defaultValue
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBack = Instance.new("Frame", container)
    sliderBack.Name = "SliderBack"
    sliderBack.Size = UDim2.new(1, 0, 0, 4)
    sliderBack.Position = UDim2.new(0, 0, 0, 25)
    sliderBack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderBack.BorderSizePixel = 0
    
    local sliderCorner = Instance.new("UICorner", sliderBack)
    sliderCorner.CornerRadius = UDim.new(0, 2)
    
    local sliderFill = Instance.new("Frame", sliderBack)
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = MenuSettings.AccentColor
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner", sliderFill)
    fillCorner.CornerRadius = UDim.new(0, 2)
    
    local sliderButton = Instance.new("TextButton", sliderBack)
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -8, 0, -6)
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderButton.BorderSizePixel = 0
    sliderButton.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner", sliderButton)
    buttonCorner.CornerRadius = UDim.new(0, 8)
    
    local isDragging = false
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBack.AbsolutePosition
            local sliderSize = sliderBack.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local newValue = minValue + (maxValue - minValue) * relativeX
            
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativeX, -8, 0, -6)
            label.Text = text .. ": " .. math.floor(newValue * 100) / 100
            
            if callback then
                callback(newValue)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    currentY = currentY + 40 + padding
    return sliderButton
end

local function createDivider()
    local divider = Instance.new("Frame", functionsContainer)
    divider.Size = UDim2.new(1, -10, 0, 1)
    divider.Position = UDim2.new(0, 5, 0, currentY)
    divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    divider.BorderSizePixel = 0
    
    currentY = currentY + 10 + padding
end

local function createSectionHeader(text)
    local header = Instance.new("TextLabel", functionsContainer)
    header.Size = UDim2.new(1, -10, 0, 25)
    header.Position = UDim2.new(0, 5, 0, currentY)
    header.Text = text
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextColor3 = Color3.new(1, 1, 1)
    header.BackgroundTransparency = 1
    header.TextXAlignment = Enum.TextXAlignment.Left
    
    currentY = currentY + 25 + padding
end

local function createButton(text, callback)
    local button = Instance.new("TextButton", functionsContainer)
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Position = UDim2.new(0, 5, 0, currentY)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner", button)
    buttonCorner.CornerRadius = UDim.new(0, 6)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    currentY = currentY + 35 + padding
    return button
end

local function createDropdown(text, options, defaultValue, callback)
    local container = Instance.new("Frame", functionsContainer)
    container.Size = UDim2.new(1, -10, 0, 40)
    container.Position = UDim2.new(0, 5, 0, currentY)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdownButton = Instance.new("TextButton", container)
    dropdownButton.Size = UDim2.new(0.35, 0, 0, 25)
    dropdownButton.Position = UDim2.new(0.65, 0, 0, 0)
    dropdownButton.Text = defaultValue or options[1]
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 12
    dropdownButton.TextColor3 = Color3.new(1, 1, 1)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    dropdownButton.BorderSizePixel = 0
    dropdownButton.AutoButtonColor = false
    
    local dropdownCorner = Instance.new("UICorner", dropdownButton)
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    
    local isOpen = false
    local dropdownFrame = nil
    
    dropdownButton.MouseButton1Click:Connect(function()
        if isOpen then
            if dropdownFrame then
                dropdownFrame:Destroy()
                dropdownFrame = nil
            end
            isOpen = false
        else
            if dropdownFrame then
                dropdownFrame:Destroy()
            end
            
            dropdownFrame = Instance.new("Frame", container)
            dropdownFrame.Size = UDim2.new(0.35, 0, 0, #options * 25)
            dropdownFrame.Position = UDim2.new(0.65, 0, 0, 25)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.ZIndex = 10
            
            local dropdownCorner = Instance.new("UICorner", dropdownFrame)
            dropdownCorner.CornerRadius = UDim.new(0, 6)
            
            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton", dropdownFrame)
                optionButton.Size = UDim2.new(1, 0, 0, 25)
                optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
                optionButton.Text = option
                optionButton.Font = Enum.Font.Gotham
                optionButton.TextSize = 12
                optionButton.TextColor3 = Color3.new(1, 1, 1)
                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                optionButton.BorderSizePixel = 0
                optionButton.AutoButtonColor = false
                optionButton.ZIndex = 11
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    if callback then
                        callback(option)
                    end
                    dropdownFrame:Destroy()
                    dropdownFrame = nil
                    isOpen = false
                end)
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                end)
            end
            
            isOpen = true
        end
    end)
    
    currentY = currentY + 40 + padding
    return dropdownButton
end

-- Функция показа содержимого вкладки
local function showContent(tabName)
    -- Очищаем контейнер
    for _, child in pairs(functionsContainer:GetChildren()) do
        child:Destroy()
    end
    
    currentY = 0
    padding = 10
    
    if tabName == "Main" then
        contentTitle.Text = getText("MainFunctions")
        
        -- Загружаем модуль Main и Settings
        local success, result = pcall(function()
            local mainModule = game:HttpGet("https://raw.githubusercontent.com/asdkfnjkhzxoiuiou34341/erio-0vzcv319423fs/refs/heads/main/main_settings_module")
            return loadstring(mainModule)()
        end)
        
        if success and result then
            print("✅ Модуль Main и Settings загружен успешно!")
            -- Вызываем функцию создания интерфейса из модуля
            if result.createMainInterface then
                result.createMainInterface(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton, createDropdown)
            end
        else
            print("❌ Ошибка загрузки модуля Main и Settings:", tostring(result))
            -- Fallback интерфейс
            createSectionHeader("MAIN FUNCTIONS")
            createToggleSlider("ESP", false, function(v) print("ESP:", v) end)
            createToggleSlider("Aimbot", false, function(v) print("Aimbot:", v) end)
            createToggleSlider("Fly", false, function(v) print("Fly:", v) end)
            createToggleSlider("Speed Hack", false, function(v) print("Speed Hack:", v) end)
        end
        
    elseif tabName == "YBA Hacks" then
        contentTitle.Text = getText("YBAHacks")
        
        -- Загружаем модуль YBA Hacks
        local success, result = pcall(function()
            local ybaModule = game:HttpGet("https://raw.githubusercontent.com/asdkfnjkhzxoiuiou34341/erio-0vzcv319423fs/refs/heads/main/yba_hacks_module")
            return loadstring(ybaModule)()
        end)
        
        if success and result then
            print("✅ Модуль YBA Hacks загружен успешно!")
            -- Вызываем функцию создания интерфейса из модуля
            if result.createYBAInterface then
                result.createYBAInterface(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton, createDropdown)
            end
        else
            print("❌ Ошибка загрузки модуля YBA Hacks:", tostring(result))
            -- Fallback интерфейс
            createSectionHeader("YBA HACKS")
            createToggleSlider("Stand Range Hack", false, function(v) print("Stand Range Hack:", v) end)
            createToggleSlider("Underground Flight", false, function(v) print("Underground Flight:", v) end)
            createToggleSlider("Item ESP", false, function(v) print("Item ESP:", v) end)
        end
        
    elseif tabName == "Settings" then
        contentTitle.Text = getText("MenuSettings")
        
        createDivider()
        
        local accentColorLabel = Instance.new("TextLabel", functionsContainer)
        accentColorLabel.Text = getText("AccentColor")
        accentColorLabel.TextColor3 = Color3.new(1,1,1)
        accentColorLabel.BackgroundTransparency = 1
        accentColorLabel.Size = UDim2.new(1, -10, 0, 20)
        accentColorLabel.Position = UDim2.new(0, 5, 0, currentY)
        accentColorLabel.Font = Enum.Font.Gotham
        accentColorLabel.TextSize = 14
        accentColorLabel.TextXAlignment = Enum.TextXAlignment.Left
        currentY = currentY + 20 + padding

        local accentColors = {
            Color3.fromRGB(0, 150, 0),
            Color3.fromRGB(0, 100, 255),
            Color3.fromRGB(255, 0, 100),
            Color3.fromRGB(255, 150, 0),
            Color3.fromRGB(150, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 50, 50),
        }

        local colorRow = Instance.new("Frame", functionsContainer)
        colorRow.Size = UDim2.new(1, -10, 0, 35)
        colorRow.Position = UDim2.new(0, 5, 0, currentY)
        colorRow.BackgroundTransparency = 1

        local colorLayout = Instance.new("UIListLayout", colorRow)
        colorLayout.FillDirection = Enum.FillDirection.Horizontal
        colorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        colorLayout.Padding = UDim.new(0, 8)

        for _, color in pairs(accentColors) do
            local colorBtn = Instance.new("TextButton", colorRow)
            colorBtn.Size = UDim2.new(0, 30, 0, 30)
            colorBtn.BackgroundColor3 = color
            colorBtn.Text = ""
            colorBtn.AutoButtonColor = false
            colorBtn.BorderSizePixel = 0
            
            local colorCorner = Instance.new("UICorner", colorBtn)
            colorCorner.CornerRadius = UDim.new(0, 6)
            
            if MenuSettings.AccentColor == color then
                local highlight = Instance.new("UIStroke", colorBtn)
                highlight.Color = Color3.new(1, 1, 1)
                highlight.Thickness = 2
            end
            
            colorBtn.MouseButton1Click:Connect(function()
                MenuSettings.AccentColor = color
                updateAccentColor()
                
                for _, btn in pairs(colorRow:GetChildren()) do
                    if btn:IsA("TextButton") then
                        local stroke = btn:FindFirstChild("UIStroke")
                        if stroke then stroke:Destroy() end
                        
                        if btn.BackgroundColor3 == color then
                            local highlight = Instance.new("UIStroke", btn)
                            highlight.Color = Color3.new(1, 1, 1)
                            highlight.Thickness = 2
                        end
                    end
                end
                
                showContent(selectedTab)
            end)
        end
        
        currentY = currentY + 35 + padding
        
        createDivider()
        
        createDropdown(getText("Language"), {"English", "Russian"}, MenuSettings.Language, function(selectedLanguage)
            MenuSettings.Language = selectedLanguage
            updateAllTexts()
        end)
    end
    
    functionsContainer.Size = UDim2.new(1, 0, 0, currentY)
    selectedTab = tabName
    
    if scrollFrame and tabScrollPositions[tabName] then
        scrollFrame.CanvasPosition = Vector2.new(0, tabScrollPositions[tabName])
    end
end

-- Функция создания кнопки повторного открытия
local function createReopenButton()
    local reopenButton = Instance.new("TextButton", screenGui)
    reopenButton.Name = "ReopenButton"
    reopenButton.Size = UDim2.new(0, 120, 0, 40)
    reopenButton.Position = UDim2.new(0, 20, 0, 20)
    reopenButton.Text = "Reopen Menu"
    reopenButton.Font = Enum.Font.Gotham
    reopenButton.TextSize = 14
    reopenButton.TextColor3 = Color3.new(1, 1, 1)
    reopenButton.BackgroundColor3 = MenuSettings.AccentColor
    reopenButton.BorderSizePixel = 0
    reopenButton.AutoButtonColor = false
    
    local reopenCorner = Instance.new("UICorner", reopenButton)
    reopenCorner.CornerRadius = UDim.new(0, 6)
    
    reopenButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        reopenButton:Destroy()
    end)
end

-- Инициализация
local currentY = 0
local padding = 10

showContent("Main")

-- Обработчик клавиши Insert для скрытия/показа меню
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            local existingButton = screenGui:FindFirstChild("ReopenButton")
            if existingButton then
                existingButton:Destroy()
            end
        else
            createReopenButton()
        end
    end
end)

print("🚀 SSLKIN GUI загружен! Нажмите Insert для открытия меню.")
print("📦 Загружаем модули...")