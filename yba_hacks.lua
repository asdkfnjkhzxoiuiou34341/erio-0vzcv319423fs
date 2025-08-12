-- Модуль YBA функций
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

-- YBA конфигурации
local YBAConfig = {
    Enabled = false,
    ToggleKey = nil,
    StandRange = 500,
    FreezePlayer = true,
    SwitchCamera = true,
    TransferControl = true,
    AutoFindStands = true,
    MaxStandDistance = 50,
    CameraDistance = 12,
    CameraHeight = 8,
    StandControlSpeed = 1.0,
    StandControlSmoothing = 0.1,
    MouseSensitivity = 0.01,
    CameraSmoothing = 0.08,
    CameraFollowDistance = 20.2,
    CameraFollowHeight = 6.1,
    MouseLookSensitivity = 0.003,
    StandRotationSpeed = 0.05,
    UndergroundControl = {
        FlightSpeed = 40,
        AutoNoClip = true,
        OriginalPosition = nil,
    },
    ItemESP = {
        Enabled = false,
        ToggleKey = nil,
        MaxDistance = 1000,
        MaxRenderDistance = 5000,
        UpdateInterval = 0.3,
        ShowOutline = true,
        ShowText = true,
        ShowFill = true,
        FillColor = Color3.fromRGB(255, 215, 0),
        OutlineColor = Color3.fromRGB(255, 255, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextBackgroundColor = Color3.fromRGB(0, 0, 0),
        FillTransparency = 0.3,
        OutlineTransparency = 0.1,
        TextBackgroundTransparency = 0.3,
        TextSize = 10,
        DistanceTextSize = 9,
        Font = Enum.Font.GothamBold,
        Items = {
            ["Mysterious Arrow"] = true,
            ["Rokakaka"] = true,
            ["Pure Rokakaka"] = true,
            ["Diamond"] = true,
            ["Gold Coin"] = true,
            ["Steel Ball"] = true,
            ["Clackers"] = true,
            ["Caesar's Headband"] = true,
            ["Zeppeli's Hat"] = true,
            ["Zeppeli's Scarf"] = true,
            ["Ancient Scroll"] = true,
            ["Quinton's Glove"] = true,
            ["Stone Mask"] = true,
            ["Lucky Arrow"] = true,
            ["Lucky Stone Mask"] = true,
            ["Rib Cage of The Saint's Corpse"] = true,
            ["DIO's Diary"] = true,
        }
    }
}

local AntiTimeStopConfig = {
    Enabled = false,
    ToggleKey = nil,
    MovementSpeed = 1.5,
    JumpPower = 50,
    WalkSpeed = 16,
    AutoActivate = true,
    DetectionRange = 100,
    VisualEffect = true,
    SoundEffect = false,
    AntiFreeze = true,
    TimeStopBypass = true,
    MovementOverride = true,
    DisableOnAttack = true,
    ServerSync = true,
}

-- Autofarm конфигурация
local AutofarmConfig = {
    Enabled = false,
    ToggleKey = nil,
    UseFlightMovement = true,
    UseNoClipMovement = true,
    FlightSpeed = 100,
    PickupRadius = 15,
    PickupDuration = 0.6,
    PickupKey = Enum.KeyCode.E,
    ScanInterval = 1,
    Items = {
        ["Mysterious Arrow"] = true,
        ["Rokakaka"] = true,
        ["Pure Rokakaka"] = true,
        ["Diamond"] = true,
        ["Gold Coin"] = true,
        ["Steel Ball"] = true,
        ["Clackers"] = true,
        ["Caesar's Headband"] = true,
        ["Zeppeli's Hat"] = true,
        ["Zeppeli's Scarf"] = true,
        ["Ancient Scroll"] = true,
        ["Quinton's Glove"] = true,
        ["Stone Mask"] = true,
        ["Lucky Arrow"] = true,
        ["Lucky Stone Mask"] = true,
        ["Rib Cage of The Saint's Corpse"] = true,
        ["DIO's Diary"] = true,
        ["Dio's Diary"] = true,
    }
}

-- Переменные состояния
local isYBAEnabled = false
local ybaConnections = {}
local originalPlayerPosition = nil
local originalPlayerCFrame = nil
local originalCameraCFrame = nil
local controlledStand = nil
local standControlConnections = {}
local originalGravity = workspace.Gravity
local originalYBAWalkSpeed = 16
local originalYBAJumpPower = 50

local isAntiTimeStopEnabled = false
local antiTimeStopConnections = {}
local originalAntiTimeStopWalkSpeed = 16
local originalAntiTimeStopJumpPower = 50
local timeStopDetected = false
local timeStopStartTime = 0
local timeStopDuration = 0
local antiTimeStopEffect = nil

local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil
local isShiftPressed = false

local itemESPConnections = {}
local itemESPElements = {}
local itemESPEnabled = false

local isAutofarmEnabled = false
local autofarmConnections = {}
local autofarmCurrentTarget = nil
local autofarmItemQueue = {}
local autofarmOriginalPosition = nil
local autofarmPickingUp = false
local autofarmSkippedItems = {}
local autofarmItemAttempts = {}
local autofarmSkippedReturns = {}
local autofarmLastPickupTime = 0
local autofarmRestartTimer = nil
local autofarmAutoRestarting = false
local autofarmDeathCheckConnection = nil

-- Сохраняем конфигурации в глобальную область
_G.HuynaScript.Configs.YBA = YBAConfig
_G.HuynaScript.Configs.AntiTimeStop = AntiTimeStopConfig
_G.HuynaScript.Configs.Autofarm = AutofarmConfig

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

-- Заглушки для функций (в полной версии здесь будут реальные реализации)
local function startYBA()
    print("YBA Stand Range активирован (заглушка)")
    isYBAEnabled = true
    YBAConfig.Enabled = true
end

local function stopYBA()
    print("YBA Stand Range деактивирован (заглушка)")
    isYBAEnabled = false
    YBAConfig.Enabled = false
end

local function startUndergroundControl()
    print("Underground Flight активирован (заглушка)")
    isUndergroundControlEnabled = true
end

local function stopUndergroundControl()
    print("Underground Flight деактивирован (заглушка)")
    isUndergroundControlEnabled = false
end

local function startAntiTimeStop()
    print("Anti Time Stop активирован (заглушка)")
    isAntiTimeStopEnabled = true
    AntiTimeStopConfig.Enabled = true
end

local function stopAntiTimeStop()
    print("Anti Time Stop деактивирован (заглушка)")
    isAntiTimeStopEnabled = false
    AntiTimeStopConfig.Enabled = false
end

local function startUserStandESP()
    print("User Stand ESP активирован (заглушка)")
end

local function stopUserStandESP()
    print("User Stand ESP деактивирован (заглушка)")
end

local function startUserStyleESP()
    print("User Style ESP активирован (заглушка)")
end

local function stopUserStyleESP()
    print("User Style ESP деактивирован (заглушка)")
end

local function startItemESP()
    print("Item ESP активирован (заглушка)")
    itemESPEnabled = true
    YBAConfig.ItemESP.Enabled = true
end

local function stopItemESP()
    print("Item ESP деактивирован (заглушка)")
    itemESPEnabled = false
    YBAConfig.ItemESP.Enabled = false
end

local function startAutofarm()
    print("Autofarm активирован (заглушка)")
    isAutofarmEnabled = true
    AutofarmConfig.Enabled = true
end

local function stopAutofarm()
    print("Autofarm деактивирован (заглушка)")
    isAutofarmEnabled = false
    AutofarmConfig.Enabled = false
end

-- Экспорт функций для других модулей
_G.HuynaScript.Functions.startYBA = startYBA
_G.HuynaScript.Functions.stopYBA = stopYBA
_G.HuynaScript.Functions.startUndergroundControl = startUndergroundControl
_G.HuynaScript.Functions.stopUndergroundControl = stopUndergroundControl
_G.HuynaScript.Functions.startAntiTimeStop = startAntiTimeStop
_G.HuynaScript.Functions.stopAntiTimeStop = stopAntiTimeStop
_G.HuynaScript.Functions.startItemESP = startItemESP
_G.HuynaScript.Functions.stopItemESP = stopItemESP
_G.HuynaScript.Functions.startAutofarm = startAutofarm
_G.HuynaScript.Functions.stopAutofarm = stopAutofarm

-- Создание интерфейса для YBA функций
if _G.HuynaScript.GUI.contentTitle.Text == "YBA HACKS" then
    currentY = 0
    
    -- 🎯 STAND RANGE
    createSectionHeader("🎯 STAND RANGE")
    
    createToggleSlider(getText("YBAStandRange"), YBAConfig.Enabled, function(v)
        YBAConfig.Enabled = v
        if v then 
            startYBA() 
        else 
            stopYBA() 
        end
    end)
    
    createToggleSlider(getText("UndergroundFlight"), isUndergroundControlEnabled, function(v)
        if v then
            startUndergroundControl()
        else
            stopUndergroundControl()
        end
    end)
    
    -- NoClip статус для YBA
    local ybaNoClipStatusLabel = Instance.new("TextLabel")
    ybaNoClipStatusLabel.Name = "YBANoClipStatus"
    ybaNoClipStatusLabel.Parent = functionsContainer
    ybaNoClipStatusLabel.Size = UDim2.new(1, -10, 0, 20)
    ybaNoClipStatusLabel.BackgroundTransparency = 1
    ybaNoClipStatusLabel.Text = "NoClip Status: " .. ((_G.HuynaScript.Functions.isNoClipping and _G.HuynaScript.Functions.isNoClipping()) and "ON" or "OFF")
    ybaNoClipStatusLabel.Font = Enum.Font.GothamBold
    ybaNoClipStatusLabel.TextSize = 12
    ybaNoClipStatusLabel.TextColor3 = ((_G.HuynaScript.Functions.isNoClipping and _G.HuynaScript.Functions.isNoClipping()) and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100))
    ybaNoClipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    ybaNoClipStatusLabel.LayoutOrder = currentY
    currentY = currentY + 1
    
    createToggleSlider(getText("ForceNoClip"), (_G.HuynaScript.Functions.isNoClipping and _G.HuynaScript.Functions.isNoClipping()) or false, function(v)
        if v then
            if _G.HuynaScript.Functions.startNoClip then
                _G.HuynaScript.Functions.startNoClip()
            end
            ybaNoClipStatusLabel.Text = "NoClip Status: ON"
            ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        else
            if _G.HuynaScript.Functions.stopNoClip then
                _G.HuynaScript.Functions.stopNoClip()
            end
            ybaNoClipStatusLabel.Text = "NoClip Status: OFF"
            ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        end
    end)
    
    createSlider("YBA Underground Speed", 1, 200, YBAConfig.UndergroundControl.FlightSpeed or 50, function(v)
        YBAConfig.UndergroundControl.FlightSpeed = v
        if isUndergroundControlEnabled and controlledStandForUnderground then
            print("YBA: Скорость подземного полета изменена на:", v)
        end
    end)
    
    createDivider()
    
    -- ⏰ ANTI TS
    createSectionHeader("⏰ ANTI TS")
    
    local antiTimeStopBtn = Instance.new("TextButton")
    antiTimeStopBtn.Name = "AntiTimeStopButton"
    antiTimeStopBtn.Parent = functionsContainer
    antiTimeStopBtn.Size = UDim2.new(1, -10, 0, 28)
    antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
    antiTimeStopBtn.Text = getText("AntiTimeStop")
    antiTimeStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    antiTimeStopBtn.TextSize = 14
    antiTimeStopBtn.Font = Enum.Font.GothamBold
    antiTimeStopBtn.BorderSizePixel = 0
    antiTimeStopBtn.LayoutOrder = currentY
    currentY = currentY + 1
    
    local antiTSCorner = Instance.new("UICorner")
    antiTSCorner.CornerRadius = UDim.new(0, 6)
    antiTSCorner.Parent = antiTimeStopBtn
    
    antiTimeStopBtn.MouseButton1Click:Connect(function()
        if not isAntiTimeStopEnabled then
            AntiTimeStopConfig.Enabled = true
            startAntiTimeStop()
            antiTimeStopBtn.Text = "ANTI TIME STOP ACTIVE"
            antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
            
            -- Быстрое отключение после освобождения
            task.spawn(function()
                task.wait(0.1) -- Минимальное время для освобождения
                
                AntiTimeStopConfig.Enabled = false
                stopAntiTimeStop()
                antiTimeStopBtn.Text = "ANTI TIME STOP"
                antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
                print("Anti TS: ГОТОВО!")
            end)
        end
    end)
    
    createDivider()
    
    -- 👥 PLAYER ESP
    createSectionHeader("👥 PLAYER ESP")
    
    createToggleSlider("User Stand", false, function(v)
        if v then
            startUserStandESP()
        else
            stopUserStandESP()
        end
    end)
    
    createToggleSlider("User Style", false, function(v)
        if v then
            startUserStyleESP()
        else
            stopUserStyleESP()
        end
    end)
    
    createDivider()
    
    -- 📦 ITEM ESP
    createSectionHeader("📦 ITEM ESP")
    
    createToggleSlider(getText("ItemESP"), YBAConfig.ItemESP.Enabled, function(v)
        YBAConfig.ItemESP.Enabled = v
        if v then 
            startItemESP() 
        else 
            stopItemESP() 
        end
    end)
    
    -- Item Selection Header
    local itemSelectionHeader = Instance.new("TextLabel")
    itemSelectionHeader.Name = "ItemSelectionHeader"
    itemSelectionHeader.Parent = functionsContainer
    itemSelectionHeader.Size = UDim2.new(1, -10, 0, 25)
    itemSelectionHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    itemSelectionHeader.BorderSizePixel = 1
    itemSelectionHeader.BorderColor3 = Color3.fromRGB(100, 100, 120)
    itemSelectionHeader.Text = "📦 ITEM SELECTION"
    itemSelectionHeader.Font = Enum.Font.GothamBold
    itemSelectionHeader.TextSize = 14
    itemSelectionHeader.TextColor3 = Color3.fromRGB(255, 255, 0)
    itemSelectionHeader.TextXAlignment = Enum.TextXAlignment.Left
    itemSelectionHeader.LayoutOrder = currentY
    currentY = currentY + 1
    
    local itemHeaderCorner = Instance.new("UICorner")
    itemHeaderCorner.CornerRadius = UDim.new(0, 4)
    itemHeaderCorner.Parent = itemSelectionHeader
    
    local function createItemToggle(itemName, defaultState)
        local btn = createToggleSlider(itemName, defaultState, function(v)
            YBAConfig.ItemESP.Items[itemName] = v
            print("YBA Item ESP: Предмет", itemName, "установлен в", v and "ON" or "OFF")
        end)
        return btn
    end
    
    -- Создаем переключатели для всех предметов
    createItemToggle(getText("MysteriousArrow"), YBAConfig.ItemESP.Items["Mysterious Arrow"])
    createItemToggle(getText("Rokakaka"), YBAConfig.ItemESP.Items["Rokakaka"])
    createItemToggle(getText("PureRokakaka"), YBAConfig.ItemESP.Items["Pure Rokakaka"])
    createItemToggle(getText("Diamond"), YBAConfig.ItemESP.Items["Diamond"])
    createItemToggle(getText("GoldCoin"), YBAConfig.ItemESP.Items["Gold Coin"])
    createItemToggle(getText("SteelBall"), YBAConfig.ItemESP.Items["Steel Ball"])
    createItemToggle(getText("Clackers"), YBAConfig.ItemESP.Items["Clackers"])
    createItemToggle(getText("CaesarsHeadband"), YBAConfig.ItemESP.Items["Caesar's Headband"])
    createItemToggle(getText("ZeppeliHat"), YBAConfig.ItemESP.Items["Zeppeli's Hat"])
    createItemToggle(getText("ZeppeliScarf"), YBAConfig.ItemESP.Items["Zeppeli's Scarf"])
    createItemToggle(getText("QuintonsGlove"), YBAConfig.ItemESP.Items["Quinton's Glove"])
    createItemToggle(getText("StoneMask"), YBAConfig.ItemESP.Items["Stone Mask"])
    createItemToggle(getText("RibCage"), YBAConfig.ItemESP.Items["Rib Cage of The Saint's Corpse"])
    createItemToggle(getText("AncientScroll"), YBAConfig.ItemESP.Items["Ancient Scroll"])
    createItemToggle(getText("DiosDiary"), YBAConfig.ItemESP.Items["DIO's Diary"])
    createItemToggle(getText("LuckyStoneMask"), YBAConfig.ItemESP.Items["Lucky Stone Mask"])
    createItemToggle(getText("LuckyArrow"), YBAConfig.ItemESP.Items["Lucky Arrow"])
    
    createDivider()
    
    -- 🤖 AUTOFARM
    createSectionHeader("🤖 AUTOFARM")
    
    createToggleSlider("Autofarm", isAutofarmEnabled, function(v)
        if v then
            startAutofarm()
        else
            stopAutofarm()
        end
    end)
    
    createDivider()
    
    -- Заголовок для выбора предметов автофарма
    createSectionHeader("📦 ITEMS FARM")
    
    -- Функция для создания переключателей предметов автофарма
    local function createAutofarmItemToggle(itemName, defaultState)
        local btn = createToggleSlider(itemName, defaultState, function(v)
            AutofarmConfig.Items[itemName] = v
            
            -- Синхронизируем ОБА варианта ключей для предметов
            if itemName == "MysteriousArrow" or itemName == "Mysterious Arrow" then
                AutofarmConfig.Items["Mysterious Arrow"] = v
                AutofarmConfig.Items["MysteriousArrow"] = v
            elseif itemName == "GoldCoin" or itemName == "Gold Coin" then
                AutofarmConfig.Items["Gold Coin"] = v
                AutofarmConfig.Items["GoldCoin"] = v
            end
            
            print("🤖 AUTOFARM: Предмет", itemName, "установлен в", v and "ON" or "OFF")
        end)
        return btn
    end
    
    -- Создаем переключатели для автофарма предметов
    createAutofarmItemToggle("Mysterious Arrow", AutofarmConfig.Items["Mysterious Arrow"])
    createAutofarmItemToggle("Rokakaka", AutofarmConfig.Items["Rokakaka"])
    createAutofarmItemToggle("Pure Rokakaka", AutofarmConfig.Items["Pure Rokakaka"])
    createAutofarmItemToggle("Diamond", AutofarmConfig.Items["Diamond"])
    createAutofarmItemToggle("Gold Coin", AutofarmConfig.Items["Gold Coin"])
    createAutofarmItemToggle("Steel Ball", AutofarmConfig.Items["Steel Ball"])
    createAutofarmItemToggle("Clackers", AutofarmConfig.Items["Clackers"])
    createAutofarmItemToggle("Caesar's Headband", AutofarmConfig.Items["Caesar's Headband"])
    createAutofarmItemToggle("Zeppeli's Hat", AutofarmConfig.Items["Zeppeli's Hat"])
    createAutofarmItemToggle("Zeppeli's Scarf", AutofarmConfig.Items["Zeppeli's Scarf"])
    createAutofarmItemToggle("Ancient Scroll", AutofarmConfig.Items["Ancient Scroll"])
    createAutofarmItemToggle("Quinton's Glove", AutofarmConfig.Items["Quinton's Glove"])
    createAutofarmItemToggle("Stone Mask", AutofarmConfig.Items["Stone Mask"])
    createAutofarmItemToggle("Lucky Arrow", AutofarmConfig.Items["Lucky Arrow"])
    createAutofarmItemToggle("Lucky Stone Mask", AutofarmConfig.Items["Lucky Stone Mask"])
    createAutofarmItemToggle("Rib Cage of The Saint's Corpse", AutofarmConfig.Items["Rib Cage of The Saint's Corpse"])
    createAutofarmItemToggle("DIO's Diary", AutofarmConfig.Items["DIO's Diary"])
end

print("⚔️ YBA Functions модуль загружен!")
