-- Модуль основных функций (Main + Settings)
-- Загружается динамически через основной загрузчик

local Players = _G.HuynaScript.Players
local RunService = _G.HuynaScript.RunService
local UserInputService = _G.HuynaScript.UserInputService
local TweenService = _G.HuynaScript.TweenService
local CoreGui = _G.HuynaScript.CoreGui

-- Получаем ссылки на GUI элементы
local GUI = _G.HuynaScript.GUI
local functionsContainer = GUI.functionsContainer
local scrollFrame = GUI.scrollFrame

-- Конфигурации
local Config = {
    ESP = {
        Enabled = true,
        TeamCheck = false,
        ShowOutline = true,
        ShowLines = false,
        Rainbow = false,
        FillColor = Color3.fromRGB(255,255,255),
        OutlineColor = Color3.fromRGB(255,255,255),
        TextColor = Color3.fromRGB(255,255,255),
        LineColor = Color3.fromRGB(255,255,255),
        FillTransparency = 0.5,
        OutlineTransparency = 0,
        Font = Enum.Font.SciFi,
        TeamColor = Color3.fromRGB(0,255,0),
        EnemyColor = Color3.fromRGB(255,0,0),
        ToggleKey = nil,
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        VisibilityCheck = true,
        FOV = 150,
        ToggleKey = nil,
        FOVColor = Color3.fromRGB(255,128,128),
        FOVRainbow = false,
    },
    MenuCollapsed = false,
}

local MovementConfig = {
    Fly = {Enabled = false, Speed = 1, ToggleKey = nil},
    NoClip = {Enabled = false, ToggleKey = nil, ForceToggleKey = nil},
    Speed = {Enabled = false, Speed = 1, ToggleKey = nil, UseJumpPower = false},
    LongJump = {Enabled = false, JumpPower = 150, ToggleKey = nil},
    InfiniteJump = {Enabled = false, JumpPower = 50, ToggleKey = nil},
}

local TeleportConfig = {
    Enabled = false,
    TargetPlayer = nil,
    OriginalPosition = nil,
    ToggleKey = nil,
    SelectedPlayerName = nil,
    UseStealthMode = true,
    TeleportSpeed = 2000,
    ReturnSpeed = 2400,
    BehindPlayerDistance = 2.6,
    StabilizationTime = 0.25,
    MaxSpeedResetTime = 2.0,
    SpeedResetThreshold = 50,
    InstantTurnSpeed = 600,
    SmoothingFactor = 0.2,
    MaxCorrectionSpeed = 180,
    StabilizationThreshold = 0.9,
}

-- Конфигурация анти-афк
local AntiAfkConfig = {
    Enabled = false,
    ToggleKey = nil,
}

-- Переменные состояния
local isFlying = false
local flyConnections = {}
local originalGravity = workspace.Gravity

local isNoClipping = false
local noClipConnections = {}

local isSpeedHacking = false
local speedHackConnections = {}
local originalWalkSpeed = 16
local originalJumpPower = 50

local isLongJumping = false
local longJumpConnections = {}
local originalLongJumpPower = 50

local isInfiniteJumping = false
local infiniteJumpConnections = {}
local lastJumpTime = 0

local isTeleporting = false
local teleportConnections = {}
local playerSelectionWindow = nil

-- Anti-AFK variables
local isAntiAfkEnabled = false
local antiAfkConnection = nil

-- Сохраняем конфигурации в глобальную область
_G.HuynaScript.Configs.Main = Config
_G.HuynaScript.Configs.Movement = MovementConfig
_G.HuynaScript.Configs.Teleport = TeleportConfig
_G.HuynaScript.Configs.AntiAfk = AntiAfkConfig

-- Текущая позиция Y для элементов
local currentY = 0
local padding = 5

-- Функция получения текста
local function getText(key) return key end

-- Вспомогательные функции для создания GUI элементов
local function createSectionHeader(title)
    local header = Instance.new("TextLabel")
    header.Name = "SectionHeader"
    header.Parent = functionsContainer
    header.Size = UDim2.new(1, -10, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = currentY
    currentY = currentY + 1
    return header
end

local function createDivider()
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Parent = functionsContainer
    divider.Size = UDim2.new(1, -20, 0, 2)
    divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    divider.BorderSizePixel = 0
    divider.LayoutOrder = currentY
    currentY = currentY + 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 1)
    corner.Parent = divider
    
    return divider
end

local function createToggleSlider(label, default, callback)
    local container = Instance.new("Frame")
    container.Name = label .. "Container"
    container.Parent = functionsContainer
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = currentY
    currentY = currentY + 1

    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Parent = container
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBack = Instance.new("Frame")
    sliderBack.Name = "SliderBack"
    sliderBack.Parent = container
    sliderBack.Size = UDim2.new(0, 50, 0, 25)
    sliderBack.Position = UDim2.new(1, -55, 0.5, -12.5)
    sliderBack.BackgroundColor3 = default and _G.HuynaScript.MenuSettings.AccentColor or Color3.fromRGB(100, 100, 100)
    sliderBack.BorderSizePixel = 0

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 12)
    sliderCorner.Parent = sliderBack

    local sliderButton = Instance.new("Frame")
    sliderButton.Name = "SliderButton"
    sliderButton.Parent = sliderBack
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = sliderButton

    local isToggled = default
    
    local function toggle()
        isToggled = not isToggled
        
        local newBackgroundColor = isToggled and _G.HuynaScript.MenuSettings.AccentColor or Color3.fromRGB(100, 100, 100)
        local newPosition = isToggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        
        TweenService:Create(sliderBack, TweenInfo.new(0.2), {BackgroundColor3 = newBackgroundColor}):Play()
        TweenService:Create(sliderButton, TweenInfo.new(0.2), {Position = newPosition}):Play()
        
        if callback then
            callback(isToggled)
        end
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)

    return container
end

local function createSlider(label, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Name = label .. "Container"
    container.Parent = functionsContainer
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = currentY
    currentY = currentY + 1

    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Parent = container
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Parent = container
    valueLabel.Size = UDim2.new(0, 50, 1, 0)
    valueLabel.Position = UDim2.new(1, -200, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Parent = container
    sliderFrame.Size = UDim2.new(0, 140, 0, 6)
    sliderFrame.Position = UDim2.new(1, -145, 0.5, -3)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderFrame.BorderSizePixel = 0

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderFrame

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Parent = sliderFrame
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = _G.HuynaScript.MenuSettings.AccentColor
    sliderFill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill

    local dragging = false
    local currentValue = default

    local function updateSlider(input)
        local relativePos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * relativePos)
        
        valueLabel.Text = tostring(currentValue)
        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        
        if callback then
            callback(currentValue)
        end
    end

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return container
end

local function createColorPicker(label, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Name = label .. "Container"
    container.Parent = functionsContainer
    container.Size = UDim2.new(1, -10, 0, 30)
    container.BackgroundTransparency = 1
    container.LayoutOrder = currentY
    currentY = currentY + 1

    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Parent = container
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local colorPreview = Instance.new("Frame")
    colorPreview.Name = "ColorPreview"
    colorPreview.Parent = container
    colorPreview.Size = UDim2.new(0, 60, 0, 20)
    colorPreview.Position = UDim2.new(1, -70, 0.5, -10)
    colorPreview.BackgroundColor3 = defaultColor
    colorPreview.BorderSizePixel = 1
    colorPreview.BorderColor3 = Color3.fromRGB(200, 200, 200)

    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorPreview

    -- Простая реализация выбора цвета (можно расширить)
    colorPreview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Циклическое переключение между предустановленными цветами
            local colors = {
                Color3.fromRGB(255, 0, 0),    -- Красный
                Color3.fromRGB(0, 255, 0),    -- Зеленый
                Color3.fromRGB(0, 0, 255),    -- Синий
                Color3.fromRGB(255, 255, 0),  -- Желтый
                Color3.fromRGB(255, 0, 255),  -- Пурпурный
                Color3.fromRGB(0, 255, 255),  -- Голубой
                Color3.fromRGB(255, 255, 255), -- Белый
            }
            
            local currentIndex = 1
            for i, color in ipairs(colors) do
                if colorPreview.BackgroundColor3 == color then
                    currentIndex = i
                    break
                end
            end
            
            local nextIndex = (currentIndex % #colors) + 1
            local newColor = colors[nextIndex]
            
            colorPreview.BackgroundColor3 = newColor
            if callback then
                callback(newColor)
            end
        end
    end)

    return container
end

local function createKeyBindButton(label, currentKey, callback)
    local container = Instance.new("Frame")
    container.Name = label .. "KeyBindContainer"
    container.Parent = functionsContainer
    container.Size = UDim2.new(1, -10, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = currentY
    currentY = currentY + 1

    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Parent = container
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.Parent = container
    keyButton.Size = UDim2.new(0, 100, 0, 25)
    keyButton.Position = UDim2.new(1, -105, 0.5, -12.5)
    keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyButton.Text = currentKey and currentKey.Name or "None"
    keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyButton.TextSize = 11
    keyButton.Font = Enum.Font.Gotham
    keyButton.BorderSizePixel = 0

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keyButton

    local isListening = false

    keyButton.MouseButton1Click:Connect(function()
        if isListening then return end
        
        isListening = true
        keyButton.Text = "Press a key..."
        keyButton.BackgroundColor3 = _G.HuynaScript.MenuSettings.AccentColor

        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyButton.Text = input.KeyCode.Name
                keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                isListening = false
                
                if callback then
                    callback(input.KeyCode)
                end
                
                connection:Disconnect()
            end
        end)
    end)

    return container
end

-- Функции движения
local function startFly()
    local plr = Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end
    
    isFlying = true
    
    local flyOriginalJumpPower = hum.JumpPower
    local flyOriginalJumpHeight = hum.JumpHeight
    local flyOriginalGravity = workspace.Gravity
    local flyOriginalHipHeight = hum.HipHeight
    
    hum.JumpPower = 0
    hum.JumpHeight = 0
    workspace.Gravity = 0
    hum.HipHeight = 0
    
    local ctrl = {f = 0, b = 0, l = 0, r = 0, u = 0, d = 0}
    
    local inputDown = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
        elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
        elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
        elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1
        elseif input.KeyCode == Enum.KeyCode.Space then ctrl.u = 1
        elseif input.KeyCode == Enum.KeyCode.LeftControl then ctrl.d = -1 end
    end)
    
    local inputUp = UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
        elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
        elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
        elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0
        elseif input.KeyCode == Enum.KeyCode.Space then ctrl.u = 0
        elseif input.KeyCode == Enum.KeyCode.LeftControl then ctrl.d = 0 end
    end)
    
    local renderConnection = RunService.RenderStepped:Connect(function()
        if not isFlying or not char or not char:FindFirstChild("Humanoid") or not root then
            if hum then
                hum.JumpPower = flyOriginalJumpPower
                hum.JumpHeight = flyOriginalJumpHeight
                hum.HipHeight = flyOriginalHipHeight
            end
            if not isNoClipping then
                workspace.Gravity = flyOriginalGravity
            end
            
            inputDown:Disconnect()
            inputUp:Disconnect()
            renderConnection:Disconnect()
            return
        end
        
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        local forward = cam.CFrame.lookVector
        local right = cam.CFrame.rightVector
        local up = Vector3.new(0, 1, 0)
        
        local moveVector = Vector3.new(0, 0, 0)
        moveVector = moveVector + (forward * (ctrl.f + ctrl.b))
        moveVector = moveVector + (right * (ctrl.r + ctrl.l))
        moveVector = moveVector + (up * (ctrl.u + ctrl.d))
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * (MovementConfig.Fly.Speed * 10)
            local bv = root:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            bv.Velocity = moveVector
        else
            local bv = root:FindFirstChild("BodyVelocity")
            if bv then
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
    
    table.insert(flyConnections, inputDown)
    table.insert(flyConnections, inputUp)
    table.insert(flyConnections, renderConnection)
end

local function stopFly()
    isFlying = false
    
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        hum.JumpPower = 50
        hum.JumpHeight = 7.2
        hum.HipHeight = 2
    end
    
    workspace.Gravity = 196.2
    
    if root then
        local bv = root:FindFirstChild("BodyVelocity")
        if bv then
            bv:Destroy()
        end
    end
    
    for _, connection in ipairs(flyConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    flyConnections = {}
end

local function startNoClip()
    local char = Players.LocalPlayer.Character
    if not char then return end
    
    isNoClipping = true
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
    
    local function noclip()
        if not char or not char.Parent then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    local noClipLoop = RunService.Heartbeat:Connect(function()
        if not isNoClipping or not char or not char.Parent then
            return
        end
        noclip()
    end)
    
    table.insert(noClipConnections, noClipLoop)
    
    local function setupNoClipForPart(part)
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
    
    local descendantAdded = char.DescendantAdded:Connect(setupNoClipForPart)
    table.insert(noClipConnections, descendantAdded)
    
    task.spawn(function()
        task.wait(0.5)
        if isNoClipping and char and char.Parent then
            noclip()
        end
    end)
end

local function stopNoClip()
    isNoClipping = false
    
    local char = Players.LocalPlayer.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    
    for _, connection in ipairs(noClipConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            elseif typeof(connection) == "Instance" then
                pcall(function() connection:Destroy() end)
            end
        end
    end
    noClipConnections = {}
end

-- Anti-AFK Functions
local function startAntiAfk()
    if isAntiAfkEnabled then return end
    
    isAntiAfkEnabled = true
    AntiAfkConfig.Enabled = true
    
    local virtualUser = game:GetService('VirtualUser')
    
    antiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
        if isAntiAfkEnabled then
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
            print("Anti-AFK: Активность имитирована")
        end
    end)
    
    print("Anti-AFK активирован")
end

local function stopAntiAfk()
    if not isAntiAfkEnabled then return end
    
    isAntiAfkEnabled = false
    AntiAfkConfig.Enabled = false
    
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    
    print("Anti-AFK деактивирован")
end

-- Экспорт функций для других модулей
_G.HuynaScript.Functions.startFly = startFly
_G.HuynaScript.Functions.stopFly = stopFly
_G.HuynaScript.Functions.startNoClip = startNoClip
_G.HuynaScript.Functions.stopNoClip = stopNoClip
_G.HuynaScript.Functions.startAntiAfk = startAntiAfk
_G.HuynaScript.Functions.stopAntiAfk = stopAntiAfk

-- Создание интерфейса для Main функций
if _G.HuynaScript.GUI.contentTitle.Text == "MAIN FUNCTIONS" then
    currentY = 0
    
    -- Hotkeys секция
    createSectionHeader("🔧 Hotkeys")
    
    createKeyBindButton("ESP", Config.ESP.ToggleKey, function(newKey)
        Config.ESP.ToggleKey = newKey
    end)
    
    createKeyBindButton("Aimbot", Config.Aimbot.ToggleKey, function(newKey)
        Config.Aimbot.ToggleKey = newKey
    end)
    
    createKeyBindButton("Anti-AFK", AntiAfkConfig.ToggleKey, function(newKey)
        AntiAfkConfig.ToggleKey = newKey
    end)
    
    createKeyBindButton("Fly", MovementConfig.Fly.ToggleKey, function(newKey)
        MovementConfig.Fly.ToggleKey = newKey
    end)
    
    createKeyBindButton("NoClip", MovementConfig.NoClip.ToggleKey, function(newKey)
        MovementConfig.NoClip.ToggleKey = newKey
    end)
    
    createDivider()
    
    -- ESP Settings
    createSectionHeader("🔷ESP Settings")
    createToggleSlider(getText("ESP"), Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
    createToggleSlider(getText("TeamCheck"), Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
    createToggleSlider(getText("ShowOutline"), Config.ESP.ShowOutline, function(v) Config.ESP.ShowOutline = v end)
    createToggleSlider(getText("ShowLines"), Config.ESP.ShowLines, function(v) Config.ESP.ShowLines = v end)
    createToggleSlider(getText("RainbowColors"), Config.ESP.Rainbow, function(v) Config.ESP.Rainbow = v end)
    
    createColorPicker("Fill Color", Config.ESP.FillColor, function(c) Config.ESP.FillColor = c end)
    createColorPicker("Outline Color", Config.ESP.OutlineColor, function(c) Config.ESP.OutlineColor = c end)
    createColorPicker("Text Color", Config.ESP.TextColor, function(c) Config.ESP.TextColor = c end)
    createSlider("Fill Transparency", 0, 1, Config.ESP.FillTransparency, function(v) Config.ESP.FillTransparency = v / 100 end)
    
    createDivider()
    
    -- Aimbot Settings
    createSectionHeader("🔷Aimbot Settings")
    createToggleSlider(getText("Aimbot"), Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
    createToggleSlider(getText("TeamCheck"), Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
    createToggleSlider(getText("VisibilityCheck"), Config.Aimbot.VisibilityCheck, function(v) Config.Aimbot.VisibilityCheck = v end)
    createSlider("FOV Radius", 10, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
    createToggleSlider(getText("FOVRainbow"), Config.Aimbot.FOVRainbow, function(v) Config.Aimbot.FOVRainbow = v end)
    createColorPicker("Aimbot FOV Color", Config.Aimbot.FOVColor, function(c) Config.Aimbot.FOVColor = c end)
    
    createDivider()
    
    -- Anti-AFK
    createSectionHeader("⚡ Anti-AFK")
    createToggleSlider("Anti-AFK", AntiAfkConfig.Enabled, function(v)
        AntiAfkConfig.Enabled = v
        if v then startAntiAfk() else stopAntiAfk() end
    end)
    
    createDivider()
    
    -- Fly Settings
    createSectionHeader("🟨 Fly Settings")
    createToggleSlider("Fly", MovementConfig.Fly.Enabled, function(v)
        MovementConfig.Fly.Enabled = v
        if v then startFly() else stopFly() end
    end)
    
    createSlider("Fly Speed", 0.1, 5, MovementConfig.Fly.Speed, function(v)
        MovementConfig.Fly.Speed = v
        if MovementConfig.Fly.Enabled then
            stopFly()
            task.wait(0.1)
            startFly()
        end
    end)
    
    createDivider()
    
    -- NoClip Settings  
    createSectionHeader("🟩 NoClip Settings")
    createToggleSlider("NoClip", isNoClipping, function(v)
        if v then
            startNoClip()
        else
            stopNoClip()
        end
    end)

elseif _G.HuynaScript.GUI.contentTitle.Text == "MENU SETTINGS" then
    currentY = 0
    
    -- Menu Settings
    createSectionHeader("⚙️ Menu Settings")
    
    createToggleSlider("Blur Effect", _G.HuynaScript.MenuSettings.BlurEnabled, function(v)
        _G.HuynaScript.MenuSettings.BlurEnabled = v
        _G.HuynaScript.Functions.updateBlurEffect()
    end)
    
    createColorPicker("Accent Color", _G.HuynaScript.MenuSettings.AccentColor, function(c)
        _G.HuynaScript.MenuSettings.AccentColor = c
        _G.HuynaScript.Functions.updateAccentColor()
    end)
    
    createDivider()
    
    -- Credits
    createSectionHeader("ℹ️ About")
    
    local creditsLabel = Instance.new("TextLabel")
    creditsLabel.Name = "CreditsLabel"
    creditsLabel.Parent = functionsContainer
    creditsLabel.Size = UDim2.new(1, -10, 0, 60)
    creditsLabel.BackgroundTransparency = 1
    creditsLabel.Text = "🚀 Huyna Script v2.0\n\nМодульная архитектура с динамической загрузкой\nСоздано для оптимизации производительности"
    creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    creditsLabel.TextSize = 11
    creditsLabel.Font = Enum.Font.Gotham
    creditsLabel.TextXAlignment = Enum.TextXAlignment.Center
    creditsLabel.TextYAlignment = Enum.TextYAlignment.Top
    creditsLabel.LayoutOrder = currentY
    currentY = currentY + 1
end

-- Обработка горячих клавиш
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        if Config.ESP.ToggleKey and inp.KeyCode == Config.ESP.ToggleKey then
            Config.ESP.Enabled = not Config.ESP.Enabled
            print("ESP toggled:", Config.ESP.Enabled)
        elseif Config.Aimbot.ToggleKey and inp.KeyCode == Config.Aimbot.ToggleKey then
            Config.Aimbot.Enabled = not Config.Aimbot.Enabled
            print("Aimbot toggled:", Config.Aimbot.Enabled)
        elseif AntiAfkConfig.ToggleKey and inp.KeyCode == AntiAfkConfig.ToggleKey then
            AntiAfkConfig.Enabled = not AntiAfkConfig.Enabled
            if AntiAfkConfig.Enabled then 
                startAntiAfk() 
            else 
                stopAntiAfk() 
            end
            print("Anti-AFK toggled:", AntiAfkConfig.Enabled)
        elseif MovementConfig.Fly.ToggleKey and inp.KeyCode == MovementConfig.Fly.ToggleKey then
            MovementConfig.Fly.Enabled = not MovementConfig.Fly.Enabled
            if MovementConfig.Fly.Enabled then 
                startFly() 
            else 
                stopFly() 
            end
            print("Fly toggled:", MovementConfig.Fly.Enabled)
        elseif MovementConfig.NoClip.ToggleKey and inp.KeyCode == MovementConfig.NoClip.ToggleKey then
            if isNoClipping then
                stopNoClip()
            else
                startNoClip()
            end
            print("NoClip toggled:", isNoClipping)
        end
    end
end)

print("📦 Main Functions модуль загружен!")
