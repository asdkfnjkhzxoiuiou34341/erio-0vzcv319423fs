-- YBA HACKS MODULE - ТОЧНАЯ КОПИЯ ИЗ ОРИГИНАЛА
-- Загружается только для YBA (ID: 2809202155)

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- YBA CONFIGS (ТОЧНО ИЗ ОРИГИНАЛА)
local YBAConfig = {
    Enabled = false,
    ToggleKey = nil,
    StandRange = 500, -- Уменьшили с 100000 до разумного значения
    FreezePlayer = true,
    SwitchCamera = true,
    TransferControl = true,
    AutoFindStands = true,
    MaxStandDistance = 50, -- Уменьшили с 10000 до разумного значения
    CameraDistance = 12, -- Уменьшили для лучшего обзора
    CameraHeight = 8, -- Увеличили для лучшего обзора
    StandControlSpeed = 1.0,
    StandControlSmoothing = 0.1,
    MouseSensitivity = 0.01,
    CameraSmoothing = 0.08,
    CameraFollowDistance = 20.2,
    CameraFollowHeight = 6.1,
    MouseLookSensitivity = 0.003,
    StandRotationSpeed = 0.05,
    UndergroundControl = {
        FlightSpeed = 40, -- Дефолтная скорость полета
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

-- Конфигурация автофарма
local AutofarmConfig = {
    Enabled = false,
    ToggleKey = nil,
    UseFlightMovement = true,
    UseNoClipMovement = true,
    FlightSpeed = 100,
    PickupRadius = 8,
    PickupDuration = 0.25,
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
        ["Quinton's Glove"] = false,
        ["Stone Mask"] = true,
        ["Lucky Arrow"] = true,
        ["Lucky Stone Mask"] = true,
        ["Rib Cage of The Saint's Corpse"] = true,
        ["DIO's Diary"] = true,
        ["Dio's Diary"] = true,
    }
}

-- YBA VARIABLES
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

local isStandControlActive = false
local currentControlledStand = nil
local standCameraConnections = {}
local originalStandCameraCFrame = nil
local standControlActive = false

local freeCameraActive = false
local freeCameraConnections = {}
local freeCameraRotation = Vector2.new(0, 0)
local originalFreeCameraCFrame = nil

local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil
local isShiftPressed = false

local itemESPConnections = {}
local itemESPElements = {}
local itemESPEnabled = false

-- Player ESP variables
local playerESPConnections = {}
local playerESPElements = {}

-- Autofarm variables
local isAutofarmEnabled = false
local autofarmConnections = {}
local autofarmCurrentTarget = nil
local autofarmItemQueue = {}
local autofarmOriginalPosition = nil
local autofarmPickingUp = false
local autofarmSkippedItems = {} -- Пропущенные предметы для повторной попытки
local autofarmItemAttempts = {} -- Счетчик попыток для каждого предмета
local autofarmSkippedReturns = {} -- Счетчик возвратов к пропущенным предметам
local autofarmLastPickupTime = 0 -- Время последнего подбора для проверки неактивности
local autofarmRestartTimer = nil -- Таймер для автоматического перезапуска через 60 секунд
local autofarmAutoRestarting = false -- Флаг автоматического перезапуска
local autofarmDeathCheckConnection = nil -- Отслеживание смерти для автофарма

-- Глобальные переменные для отслеживания состояния функций перед смертью
-- Они позволяют восстановить состояние после возрождения
local wasAutofarmEnabledBeforeDeath = false
local wasAutosellEnabledBeforeDeath = false
local deathTrackingActive = false

local respawnHandler = nil

-- YBA FREE CAMERA (ТОЧНО ИЗ ОРИГИНАЛА)
local YBAFreeCamera = {} do
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    
    local fcRunning = false
    local renderConnection = nil
    local inputConnections = {}
    local targetStand = nil
    local originalCameraCFrame = nil
    local originalCameraType = nil
    
    local cameraDistance = 12
    local cameraHeight = 8
    local cameraRot = Vector2.new(0, 0)
    local lastDebugTime = 0
    
    local input = {
        W = false, A = false, S = false, D = false,
        LeftShift = false, Space = false,
        MouseDelta = Vector2.new(0, 0),
        MouseWheel = 0
    }
    
    local function startInput()
        print("YBA Input: Запускаем систему ввода...")
        
        table.insert(inputConnections, UserInputService.InputBegan:Connect(function(inputObj, gameProcessed)
            if gameProcessed then return end
            
            local keyName = inputObj.KeyCode.Name
            if input[keyName] ~= nil then
                input[keyName] = true
                print("YBA Input: Нажата клавиша", keyName)
            end
        end))
        
        table.insert(inputConnections, UserInputService.InputEnded:Connect(function(inputObj, gameProcessed)
            if gameProcessed then return end
            
            local keyName = inputObj.KeyCode.Name
            if input[keyName] ~= nil then
                input[keyName] = false
                print("YBA Input: Отпущена клавиша", keyName)
            end
        end))
        
        table.insert(inputConnections, UserInputService.InputChanged:Connect(function(inputObj, gameProcessed)
            if inputObj.UserInputType == Enum.UserInputType.MouseMovement then
                -- ИСПРАВЛЕНО: инвертируем ось X для горизонтального поворота
                local sensitivity = 0.003
                input.MouseDelta = Vector2.new(inputObj.Delta.y * sensitivity, -inputObj.Delta.x * sensitivity)
                -- print("YBA Input: Движение мыши", input.MouseDelta) -- Слишком много сообщений
            elseif inputObj.UserInputType == Enum.UserInputType.MouseWheel then
                -- ИСПРАВЛЕНО: проверяем что GUI не активно и не обработано игрой
                if not gameProcessed then
                    input.MouseWheel = -inputObj.Position.Z
                    print("YBA Input: Колесо мыши", input.MouseWheel)
                end
            end
        end))
        
        print("YBA Input: Система ввода запущена")
    end
    
    local function stopInput()
        print("YBA Input: Останавливаем систему ввода...")
        for _, connection in ipairs(inputConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        inputConnections = {}
        
        -- Сбрасываем все состояния ввода
        for key, _ in pairs(input) do
            if type(input[key]) == "boolean" then
                input[key] = false
            elseif key == "MouseDelta" then
                input[key] = Vector2.new(0, 0)
            elseif key == "MouseWheel" then
                input[key] = 0
            end
        end
        print("YBA Input: Система ввода остановлена")
    end
    
    local function stepFreecam(dt)
        if not targetStand or not targetStand.Root or not targetStand.Root.Parent then
            print("YBA: Стенд потерян, останавливаем управление")
            YBAFreeCamera.Stop()
            return
        end
        
        local standRoot = targetStand.Root
        local standPosition = standRoot.Position
        
        -- Отладочная информация (выводим каждые 5 секунд)
        if tick() - lastDebugTime > 5 then
            print("YBA Debug: Камера работает, позиция стенда:", standPosition)
            print("YBA Debug: Состояние ввода - W:", input.W, "A:", input.A, "S:", input.S, "D:", input.D, "Shift:", input.LeftShift)
            lastDebugTime = tick()
        end

        -- Движение стенда через прямую проверку клавиш (обход блокировки YBA)
        local moveX = 0
        local moveZ = 0 
        local moveY = 0
        
        if input.W then moveZ = moveZ - 1 end
        if input.S then moveZ = moveZ + 1 end
        if input.A then moveX = moveX - 1 end
        if input.D then moveX = moveX + 1 end
        if input.Space then moveY = moveY + 1 end
        if input.LeftShift then moveY = moveY - 1 end
        
        local move = Vector3.new(moveX, moveY, moveZ)
        
        -- ИСПРАВЛЕНО: Проверяем не заблокирован ли ввод игрой или чатом
        local chatInFocus = false
        local isInputBeingProcessedByGame = false
        
        pcall(function()
            local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                local chat = gui:FindFirstChild("Chat")
                if chat then
                    local chatFrame = chat:FindFirstChild("Frame")
                    if chatFrame then
                        local chatBar = chatFrame:FindFirstChild("ChatBar")
                        if chatBar and chatBar.Visible then
                            chatInFocus = true
                        end
                    end
                end
            end
            
            if chatInFocus or isInputBeingProcessedByGame then
                -- Выводим сообщение только при нажатии Space для избежания спама
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    print("YBA: Ввод заблокирован - чат в фокусе:", chatInFocus, "gameProcessed:", isInputBeingProcessedByGame)
                end
            end
        end)
        
        -- Отладка движения
        if move.Magnitude > 0 then
            print("YBA: Движение детектировано:", moveX, moveY, moveZ)
        end
        
        local bv = standRoot:FindFirstChild("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = standRoot
        end
        
        local bav = standRoot:FindFirstChild("BodyAngularVelocity")
        if not bav then
            bav = Instance.new("BodyAngularVelocity")
            bav.MaxTorque = Vector3.new(4000, 4000, 4000)
            bav.AngularVelocity = Vector3.new(0, 0, 0)
            bav.Parent = standRoot
        end
        
        if move.Magnitude > 0 then
            local standSpeed = YBAConfig.UndergroundControl.FlightSpeed or 20
            local cameraCFrame = CFrame.new(standPosition) * CFrame.Angles(0, cameraRot.Y, 0)
            local worldMove = cameraCFrame:VectorToWorldSpace(move)
            bv.Velocity = worldMove * standSpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Обработка поворота мыши
        if input.MouseDelta.Magnitude > 0 then
            cameraRot = cameraRot + input.MouseDelta
            -- Ограничиваем вертикальный поворот
            cameraRot = Vector2.new(
                math.clamp(cameraRot.X, -math.pi/2 + 0.1, math.pi/2 - 0.1),
                cameraRot.Y % (math.pi * 2)
            )
            input.MouseDelta = Vector2.new(0, 0) -- Сбрасываем после использования
        end
        
        -- Обработка колеса мыши для изменения дистанции камеры
        if input.MouseWheel ~= 0 then
            cameraDistance = math.clamp(cameraDistance - input.MouseWheel * 2, 3, 50)
            print("YBA: Изменена дистанция камеры:", cameraDistance)
            input.MouseWheel = 0 -- Сбрасываем после использования
        end
        
        -- ИСПРАВЛЕНО: Обновляем позицию камеры относительно стенда
        -- Вычисляем позицию камеры на основе текущего поворота
        local currentPos = standRoot.Position
        local currentCFrame = standRoot.CFrame
        
        -- Вычисляем смещение камеры
        local cameraOffset = Vector3.new(
            math.sin(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance,
            math.sin(cameraRot.X) * cameraDistance + cameraHeight,
            math.cos(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance
        )
        
        -- Устанавливаем позицию камеры
        local cameraPosition = standPosition + cameraOffset
        local lookDirection = (standPosition - cameraPosition).Unit
        
        -- ИСПРАВЛЕНО: Используем lookAt для правильной ориентации камеры
        local newCameraCFrame = CFrame.lookAt(cameraPosition, cameraPosition + lookDirection)
        Camera.CFrame = newCameraCFrame
    end
    
    function YBAFreeCamera.Start(stand)
        if fcRunning then 
            YBAFreeCamera.Stop() 
        end
        
        if not stand or not stand.Root then
            print("YBA: Ошибка - стенд не найден")
            return false
        end
        
        print("YBA: Запуск управления стендом: " .. stand.Name)
        
        targetStand = stand
        originalCameraCFrame = Camera.CFrame
        originalCameraType = Camera.CameraType
        
        local standRoot = stand.Root
        local standPosition = stand.Root.Position
        
        -- Создаем BodyVelocity для стенда если его нет
        if not standRoot:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = standRoot
        end
        
        -- Сброс параметров камеры и синхронизация с направлением игрока
        cameraDistance = YBAConfig.CameraDistance or 12
        cameraHeight = YBAConfig.CameraHeight or 8
        
        -- ИСПРАВЛЕНО: Инициализируем камеру в направлении взгляда игрока
        local player = Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerCFrame = player.Character.HumanoidRootPart.CFrame
            local playerLookDirection = playerCFrame.LookVector
            local playerYRotation = math.atan2(playerLookDirection.X, playerLookDirection.Z)
            cameraRot = Vector2.new(0, playerYRotation)
            print("YBA: Синхронизация с направлением игрока, угол:", math.deg(playerYRotation))
        else
            cameraRot = Vector2.new(0, 0)
        end
        
        -- НЕ переключаем тип камеры чтобы обойти античит YBA
        print("YBA: Сохраняем оригинальный тип камеры для обхода античита")
        print("YBA: Текущий тип камеры:", Camera.CameraType)
        
        -- Устанавливаем начальную позицию камеры за стендом с задержкой
        task.wait(0.1) -- Небольшая задержка чтобы не триггерить античит
        
        -- Поворачиваем стенд в направлении игрока
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerCFrame = player.Character.HumanoidRootPart.CFrame
            stand.Root.CFrame = CFrame.new(standPosition, standPosition + playerCFrame.LookVector)
            print("YBA: Стенд повернут в направлении игрока")
        end
        
        -- Позиционируем камеру с учетом поворота стенда
        local initialCameraPosition = standPosition + Vector3.new(
            math.sin(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance,
            cameraHeight,
            math.cos(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance
        )
        local initialCameraPosition = standPosition + cameraOffset
        Camera.CFrame = CFrame.lookAt(initialCameraPosition, standPosition)
        print("YBA: Установлена начальная позиция камеры:", initialCameraPosition)
        
        -- Запускаем ввод и рендер
        print("YBA: Запускаем систему ввода...")
        startInput()
        print("YBA: Подключаем рендер...")
        -- Используем RenderStepped вместо Heartbeat для меньшей частоты
        renderConnection = RunService.RenderStepped:Connect(stepFreecam)
        fcRunning = true
        
        print("YBA: Управление стендом успешно активировано!")
        print("YBA: fcRunning =", fcRunning)
        print("YBA: renderConnection =", renderConnection ~= nil)
        return true
    end
    
    function YBAFreeCamera.Stop()
        if not fcRunning then return end
        
        print("YBA: Отключение управления стендом")
        
        -- Останавливаем ввод и рендер
        stopInput()
        
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
        
        -- Убираем BodyVelocity из стенда
        if targetStand and targetStand.Root then
            local bv = targetStand.Root:FindFirstChild("BodyVelocity")
            if bv then
                bv:Destroy()
            end
            
            local bav = targetStand.Root:FindFirstChild("BodyAngularVelocity")
            if bav then
                bav:Destroy()
            end
        end
        
        -- Восстанавливаем оригинальную камеру
        if originalCameraCFrame then
            Camera.CFrame = originalCameraCFrame
            originalCameraCFrame = nil
        end
        
        if originalCameraType then
            Camera.CameraType = originalCameraType
        end
        
        targetStand = nil
        originalCameraType = nil
        fcRunning = false
        
        print("YBA: Управление стендом успешно отключено")
    end
    
    function YBAFreeCamera.Toggle(stand)
        if fcRunning then
            YBAFreeCamera.Stop()
            return false
        else
            return YBAFreeCamera.Start(stand)
        end
    end
end

-- СОЗДАНИЕ YBA ИНТЕРФЕЙСА (ТОЧНО ИЗ ОРИГИНАЛА)
local function createYBAInterface(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton, getText, padding)
    print("YBA HACKS: Создание интерфейса...")
    
    -- 🎯 STAND RANGE заголовок как в Player ESP
    createSectionHeader("🎯 STAND RANGE")
    
    local ybaToggleBtn = createToggleSlider(getText("YBAStandRange"), YBAConfig.Enabled, function(v)
        YBAConfig.Enabled = v
        if v then 
            startYBA() 
        else 
            stopYBA() 
        end
    end)
    
    local undergroundFlightToggleBtn = createToggleSlider(getText("UndergroundFlight"), isUndergroundControlEnabled, function(v)
        if v then
            if startUndergroundControl then
                startUndergroundControl()
            end
        else
            if stopUndergroundControl then
                stopUndergroundControl()
            end
        end
    end)
    
    local ybaNoClipStatusLabel = Instance.new("TextLabel", functionsContainer)
    ybaNoClipStatusLabel.Size = UDim2.new(1, -10, 0, 20)
    ybaNoClipStatusLabel.Position = UDim2.new(0, 5, 0, currentY)
    ybaNoClipStatusLabel.Text = "NoClip Status: " .. ((_G.isNoClipping and _G.isNoClipping()) and "ON" or "OFF")
    ybaNoClipStatusLabel.Font = Enum.Font.GothamBold
    ybaNoClipStatusLabel.TextSize = 12
    ybaNoClipStatusLabel.TextColor3 = ((_G.isNoClipping and _G.isNoClipping()) and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100))
    ybaNoClipStatusLabel.BackgroundTransparency = 1
    ybaNoClipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentY = currentY + 20 + padding
    
    local ybaNoClipToggle = createToggleSlider(getText("ForceNoClip"), (_G.isNoClipping and _G.isNoClipping()) or false, function(v)
        if v then
            if _G.startNoClip then
                _G.startNoClip()
                ybaNoClipStatusLabel.Text = "NoClip Status: ON"
                ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
            end
        else
            if _G.stopNoClip then
                _G.stopNoClip()
                ybaNoClipStatusLabel.Text = "NoClip Status: OFF"
                ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
            end
        end
    end)
    
    createSlider("YBA Underground Speed", 1, 200, YBAConfig.UndergroundControl.FlightSpeed or 50, function(v)
        YBAConfig.UndergroundControl.FlightSpeed = v
        if isUndergroundControlEnabled and controlledStandForUnderground then
            print("YBA: Скорость подземного полета изменена на:", v)
        end
    end)
    

    
    -- ⏰ ANTI TS заголовок как в Player ESP
    createSectionHeader("⏰ ANTI TS")
    
    local         antiTimeStopBtn = Instance.new("TextButton", functionsContainer)
    antiTimeStopBtn.Size = UDim2.new(1, -10, 0, 28)
    antiTimeStopBtn.Position = UDim2.new(0, 5, 0, currentY)
    antiTimeStopBtn.Text = getText("AntiTimeStop")
    antiTimeStopBtn.Font = Enum.Font.GothamBold
    antiTimeStopBtn.TextSize = 14
    antiTimeStopBtn.TextColor3 = Color3.new(1,1,1)
    antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
    antiTimeStopBtn.AutoButtonColor = false
    Instance.new("UICorner", antiTimeStopBtn).CornerRadius = UDim.new(0,6)
    currentY = currentY + 28 + padding
    
    antiTimeStopBtn.MouseButton1Click:Connect(function()
        if not isAntiTimeStopEnabled then
            AntiTimeStopConfig.Enabled = true
            startAntiTimeStop()
            antiTimeStopBtn.Text = "ANTI TIME STOP ACTIVE"
            antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
            
            -- Быстрое отключение после освобождения
            spawn(function()
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
    
    -- 👥 PLAYER ESP заголовок
    createSectionHeader("👥 PLAYER ESP")
    
    local userStandToggleBtn = createToggleSlider("User Stand", false, function(v)
        if v then
            startUserStandESP()
        else
            stopUserStandESP()
        end
    end)
    
    local userStyleToggleBtn = createToggleSlider("User Style", false, function(v)
        if v then
            startUserStyleESP()
        else
            stopUserStyleESP()
        end
    end)
    
    -- 📦 ITEM ESP заголовок
    createSectionHeader("📦 ITEM ESP")
    
    local itemESPToggleBtn = createToggleSlider(getText("ItemESP"), YBAConfig.ItemESP.Enabled, function(v)
        YBAConfig.ItemESP.Enabled = v
        if v then 
            startItemESP() 
        else 
            stopItemESP() 
        end
    end)
    
    local itemSelectionHeader = Instance.new("TextLabel", functionsContainer)
    itemSelectionHeader.Size = UDim2.new(1, -10, 0, 25)
    itemSelectionHeader.Position = UDim2.new(0, 5, 0, currentY)
    itemSelectionHeader.Text = "📦 ITEM SELECTION"
    itemSelectionHeader.Font = Enum.Font.GothamBold
    itemSelectionHeader.TextSize = 14
    itemSelectionHeader.TextColor3 = Color3.fromRGB(255, 255, 0)
    itemSelectionHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    itemSelectionHeader.BorderSizePixel = 1
    itemSelectionHeader.BorderColor3 = Color3.fromRGB(100, 100, 120)
    itemSelectionHeader.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", itemSelectionHeader).CornerRadius = UDim.new(0,4)
    currentY = currentY + 25 + padding
    
    local function createItemToggle(itemName, defaultState)
        local btn = createToggleSlider(itemName, defaultState, function(v)
            YBAConfig.ItemESP.Items[itemName] = v
            print("YBA Item ESP: Предмет", itemName, "установлен в", v and "ON" or "OFF")
            
            -- ИСПРАВЛЕНО: Принудительно обновляем ESP независимо от общего состояния
            if not v then
                -- При отключении предмета немедленно убираем все его ESP элементы
                print("YBA Item ESP: Удаляем все ESP для отключенного предмета:", itemName)
                for obj, esp in pairs(itemESPElements) do
                    if esp and esp.itemName == itemName then
                        print("YBA Item ESP: Удаляем ESP элемент для:", itemName)
                        pcall(removeItemESP, {Object = obj})
                    end
                end
            else
                -- При включении предмета принудительно обновляем поиск если ESP активен
                if YBAConfig.ItemESP.Enabled then
                    print("YBA Item ESP: Предмет", itemName, "включен - обновляем поиск")
                end
            end
        end)
        return btn
    end
    
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
    
    -- 🤖 AUTOFARM заголовок
    createSectionHeader("🤖 AUTOFARM")
    
    -- Autofarm тумблер
    createToggleSlider("Autofarm", isAutofarmEnabled, function(v)
        if v then
            startAutofarm()
        else
            stopAutofarm()
        end
    end)
    
    -- Заголовок для выбора предметов автофарма
    createSectionHeader("📦 ITEMS FARM")
    
    -- Функция для создания переключателей предметов автофарма
    local function createAutofarmItemToggle(itemName, defaultState)
        local btn = createToggleSlider(itemName, defaultState, function(v)
            AutofarmConfig.Items[itemName] = v
            
            -- ФИКС: Синхронизируем ОБА варианта ключей для предметов
            if itemName == "MysteriousArrow" or itemName == "Mysterious Arrow" or itemName == "Таинственная стрела" then
                AutofarmConfig.Items["Mysterious Arrow"] = v -- с пробелом (ОСНОВНОЙ ключ для поиска)
                AutofarmConfig.Items["MysteriousArrow"] = v -- без пробела
            elseif itemName == "GoldCoin" or itemName == "Gold Coin" or itemName == "Золотая монета" then
                AutofarmConfig.Items["Gold Coin"] = v -- с пробелом
                AutofarmConfig.Items["GoldCoin"] = v -- без пробела
            end
            
            print("🤖 AUTOFARM: Предмет", itemName, "установлен в", v and "ON" or "OFF")
            
            -- Если автофарм активен, обновляем настройки
            if isAutofarmEnabled then
                -- Очищаем данные предмета
                
                -- КРИТИЧНО: Если текущий целевой предмет был отключен, прерываем движение к нему
                if autofarmCurrentTarget and autofarmCurrentTarget.Name == itemName and not v then
                    print("🤖 AUTOFARM: Прерываем движение к предмету", itemName, "- он был отключен в настройках")
                    autofarmCurrentTarget = nil
                    autofarmPickingUp = false
                    
                    -- ПРИНУДИТЕЛЬНО отпускаем клавишу E если она зажата
                    pcall(function()
                        if game:GetService("VirtualInputManager") then
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, AutofarmConfig.PickupKey, false, game)
                        end
                        game:GetService("UserInputService").InputEnded:Fire(
                            {KeyCode = AutofarmConfig.PickupKey, UserInputType = Enum.UserInputType.Keyboard},
                            false
                        )
                    end)
                    
                    -- Отключаем все соединения движения и подбора
                    for _, connection in ipairs(autofarmConnections) do
                        if connection then
                            pcall(function() connection:Disconnect() end)
                        end
                    end
                    autofarmConnections = {}
                    
                    -- Немедленно ищем следующий предмет
                    task.spawn(function()
                        task.wait(0.1)
                        if isAutofarmEnabled then
                            processNextItem()
                        end
                    end)
                end
                
                -- Убираем лишний спам
            end
        end)
        return btn
    end
    
    -- Создаем переключатели для всех предметов автофарма
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
    createAutofarmItemToggle("Quinton's Glove", AutofarmConfig.Items["Quinton's Glove"])
    createAutofarmItemToggle("Stone Mask", AutofarmConfig.Items["Stone Mask"])
    createAutofarmItemToggle("Rib Cage of The Saint's Corpse", AutofarmConfig.Items["Rib Cage of The Saint's Corpse"])
    createAutofarmItemToggle("Ancient Scroll", AutofarmConfig.Items["Ancient Scroll"])
    createAutofarmItemToggle("DIO's Diary", AutofarmConfig.Items["DIO's Diary"])
    createAutofarmItemToggle("Lucky Stone Mask", AutofarmConfig.Items["Lucky Stone Mask"])
    createAutofarmItemToggle("Lucky Arrow", AutofarmConfig.Items["Lucky Arrow"])
    
    -- AUTOSELL секция (загрузка модуля)
    createDivider()
    createSectionHeader("🤖 AUTO SELL")
    
    -- Проверяем загружен ли модуль автоселла
    if _G.AutosellModule then
        -- Модуль уже загружен, используем его функцию createGUI
        if _G.AutosellModule.createGUI and type(_G.AutosellModule.createGUI) == "function" then
            print("🤖 AUTOSELL: Создаем GUI через модуль...")
            print("🤖 AUTOSELL: Параметры перед вызовом:", {functionsContainer = functionsContainer, currentY = currentY})
            local newCurrentY = _G.AutosellModule.createGUI(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton)
            print("🤖 AUTOSELL: Получили обратно currentY =", newCurrentY)
            currentY = newCurrentY or currentY
        else
            -- Fallback на старый способ если функция createGUI недоступна
            createSectionHeader("🤖 AUTO SELL CONTROLS")
            
            -- Главный тумблер автоселла
            createToggleSlider("Auto Sell Enabled", false, function(v)
                if _G.AutosellModule then
                    if v then
                        _G.AutosellModule.start()
                    else
                        _G.AutosellModule.stop()
                    end
                end
            end)
            
            -- Кнопки быстрого управления
            createButton("Enable All Items for Sale", function()
                if _G.AutosellModule and _G.AutosellModule.enableAllItems then
                    _G.AutosellModule.enableAllItems()
                end
            end)
            
            createButton("Disable All Items for Sale", function()
                if _G.AutosellModule and _G.AutosellModule.disableAllItems then
                    _G.AutosellModule.disableAllItems()
                end
            end)
        end
    else
        -- Модуль не загружен, показываем кнопку загрузки
    end

    -- Кнопка загрузки модуля автоселла
    local loadButton = createButton("Load Autosell Module", function()
        print("🤖 AUTOSELL: Загружаем модуль автоселла...")
        
        if _G.AutosellModule then
            print("🤖 AUTOSELL: Модуль уже загружен! Обновляем интерфейс...")
            if loadButton then loadButton.Visible = destroy end
            showContent("YBA Hacks")
            return
        end
        
        -- Пытаемся сначала загрузить локальный модуль, затем HTTP
        local success, result = pcall(function()
            local autosellCode = readfile("ckvb9wuefh9831")
            return loadstring(autosellCode)()
        end)
        
        if not success then
            success, result = pcall(function()
                local autosellCode = readfile("autosell.lua")
                return loadstring(autosellCode)()
            end)
        end
        
        if not success then
            success, result = pcall(function()
                local autosellCode = game:HttpGet("https://raw.githubusercontent.com/asdkfnjkhzxoiuiou34341/erio-0vzcv319423fs/refs/heads/main/pizdec")
                return loadstring(autosellCode)()
            end)
        end
        
        if success and result then
            print("🤖 AUTOSELL: Модуль загружен, создаем GUI...")
            
            -- Используем функцию createGUI из загруженного модуля
            if _G.AutosellModule and _G.AutosellModule.createGUI and type(_G.AutosellModule.createGUI) == "function" then
                print("🤖 AUTOSELL: Создаем GUI через загруженный модуль...")
                print("🤖 AUTOSELL: Параметры перед вызовом:", {functionsContainer = functionsContainer, currentY = currentY})
                local newCurrentY = _G.AutosellModule.createGUI(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton)
                print("🤖 AUTOSELL: Получили обратно currentY =", newCurrentY)
                currentY = newCurrentY or currentY
            else
                -- Fallback на старый способ если функция createGUI недоступна
                createDivider()
                createSectionHeader("🤖 AUTO SELL CONTROLS")
                
                -- Главный тумблер автоселла
                createToggleSlider("Auto Sell Enabled", false, function(v)
                    if _G.AutosellModule then
                        if v then
                            _G.AutosellModule.start()
                        else
                            _G.AutosellModule.stop()
                        end
                    end
                end)
                
                -- Кнопки быстрого управления
                createButton("Enable All Items for Sale", function()
                    if _G.AutosellModule and _G.AutosellModule.enableAllItems then
                        _G.AutosellModule.enableAllItems()
                    end
                end)
                
                createButton("Disable All Items for Sale", function()
                    if _G.AutosellModule and _G.AutosellModule.disableAllItems then
                        _G.AutosellModule.disableAllItems()
                    end
                end)
            end
            
            print("🤖 AUTOSELL: GUI создан! Управление доступно выше.")
            
            -- Обновляем размер контейнера чтобы новые элементы отобразились
            functionsContainer.Size = UDim2.new(1, 0, 0, currentY)
            
            -- Принудительно обновляем прокрутку
            if scrollFrame then
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY)
            end
            
            -- Скрываем кнопку загрузки после успешной загрузки
            if loadButton then loadButton = false end
            
            -- Делаем задержку и полное обновление интерфейса
            task.wait(0.5)
            showContent("YBA Hacks")
        else
            print("🤖 AUTOSELL: Ошибка загрузки модуля:", tostring(result))
            print("🤖 AUTOSELL: Попробуйте:")
            print("1. Разместить autosell.lua онлайн и обновить URL")
            print("2. Или поместить autosell.lua в папку workspace")
        end
    end)
    
    print("YBA HACKS: Интерфейс создан успешно!")
    return currentY
end

-- Добавляем заглушки для всех YBA функций, которые нужно перенести из оригинала
-- TODO: ПЕРЕНЕСТИ ВСЕ ФУНКЦИИ ИЗ ОРИГИНАЛА БЕЗ ИЗМЕНЕНИЙ

print("YBA HACKS MODULE: Загружен (неполная версия - нужно добавить все функции)")

return {
    -- Configs
    YBAConfig = YBAConfig,
    AntiTimeStopConfig = AntiTimeStopConfig,
    AutofarmConfig = AutofarmConfig,
    
    -- Interface creation
    createYBAInterface = createYBAInterface,
    
    -- Placeholder functions - TODO: добавить все из оригинала
    startYBA = function() print("TODO: startYBA") end,
    stopYBA = function() print("TODO: stopYBA") end,
}