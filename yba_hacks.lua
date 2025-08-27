-- YBA HACKS MODULE
-- Модуль содержит все функции из раздела YBA Hacks из основного файла
-- Загружается автоматически при запуске основного скрипта

if not game:IsLoaded() then game.Loaded:Wait() end

print("🎯 YBA HACKS MODULE: Начинаем загрузку...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Проверяем что основные зависимости загружены
if not _G.startNoClip or not _G.stopNoClip then
    warn("🎯 YBA HACKS MODULE: ОШИБКА - Основные функции движения не загружены! Модуль может работать некорректно.")
end

-- ==================== КОНФИГУРАЦИИ ====================

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

-- ==================== ПЕРЕМЕННЫЕ СОСТОЯНИЯ ====================

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
local freeCameraDistance = 10
local freeCameraHeight = 5
local freeCameraTarget = nil
local freeCameraLastMousePos = Vector2.new(0, 0)
local lastCameraUpdate = nil

local isInputBeingProcessedByGame = false

local itemESPConnections = {}
local itemESPElements = {}
local itemESPEnabled = false

local isAutofarmEnabled = false
local autofarmConnections = {}
local autofarmCurrentTarget = nil
local autofarmItemQueue = {}
local autofarmOriginalPosition = nil
local autofarmPickingUp = false
local autofarmLastPickupTime = 0
local autofarmRestartTimer = nil
local autofarmAutoRestarting = false
local autofarmDeathCheckConnection = nil
local autofarmCurrentItemIndex = 1
local autofarmAllItems = {}

local wasAutofarmEnabledBeforeDeath = false
local wasAutosellEnabledBeforeDeath = false
local deathTrackingActive = false
local respawnHandler = nil

local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil
local isShiftPressed = false

print("🎯 YBA HACKS MODULE: Переменные инициализированы")

-- ==================== YBA FREE CAMERA MODULE ====================

local YBAFreeCamera = {} do
    local Camera = workspace.CurrentCamera

    local fcRunning = false
    local cameraPos = Vector3.new()
    local cameraRot = Vector2.new()
    local targetStand = nil
    local originalCameraCFrame = nil
    local originalCameraType = nil
    local cameraDistance = 12
    local cameraHeight = 8
    local renderConnection = nil
    local inputConnections = {}
    local lastDebugTime = 0

    local NAV_SPEED = 1

    local input = {
        W = false, A = false, S = false, D = false,
        Space = false, LeftControl = false,
        LeftShift = false,
        MouseDelta = Vector2.new(),
        MouseWheel = 0
    }

    local function startInput()
        -- Очищаем старые соединения
        for _, connection in pairs(inputConnections) do
            if connection then connection:Disconnect() end
        end
        inputConnections = {}

        -- Простое отслеживание ввода через UserInputService
        table.insert(inputConnections, UserInputService.InputBegan:Connect(function(inputObj, gameProcessed)
            -- Игнорируем ввод если игрок в чате/меню
            if gameProcessed then return end
            local keyName = inputObj.KeyCode.Name
            if input[keyName] ~= nil then
                input[keyName] = true
                print("YBA Input: Нажата клавиша", keyName)
            end
        end))

        table.insert(inputConnections, UserInputService.InputEnded:Connect(function(inputObj, gameProcessed)
            -- Игнорируем ввод если игрок в чате/меню
            if gameProcessed then return end
            local keyName = inputObj.KeyCode.Name
            if input[keyName] ~= nil then
                input[keyName] = false
                print("YBA Input: Отпущена клавиша", keyName)
            end
        end))

        table.insert(inputConnections, UserInputService.InputChanged:Connect(function(inputObj, gameProcessed)
            -- НЕ игнорируем gameProcessed для мыши
            if inputObj.UserInputType == Enum.UserInputType.MouseMovement then
                -- ИСПРАВЛЕНО: инвертируем ось X для горизонтального поворота
                local sensitivity = 0.003
                input.MouseDelta = Vector2.new(inputObj.Delta.y * sensitivity, -inputObj.Delta.x * sensitivity)
            elseif inputObj.UserInputType == Enum.UserInputType.MouseWheel then
                -- ИСПРАВЛЕНО: проверяем что GUI не активно и не обработано игрой
                if not gameProcessed then
                    input.MouseWheel = -inputObj.Position.Z
                    print("YBA Input: Колесо мыши", input.MouseWheel)
                end
            end
        end))
    end

    local function stopInput()
        for _, connection in pairs(inputConnections) do
            if connection then connection:Disconnect() end
        end
        inputConnections = {}
        
        -- Сброс всех входов
        for k in pairs(input) do
            if typeof(input[k]) == "boolean" then 
                input[k] = false 
            elseif typeof(input[k]) == "number" then 
                input[k] = 0 
            end
        end
        input.MouseDelta = Vector2.new()
        input.MouseWheel = 0
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
        
        -- Улучшенная проверка, что игрок не в чате/меню
        local gameGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
        local chatInFocus = false
        
        -- Проверяем основной чат
        if gameGui then
            local chatGui = gameGui:FindFirstChild("Chat")
            if chatGui and chatGui:FindFirstChild("Frame") and chatGui.Frame:FindFirstChild("ChatBarParentFrame") then
                local chatBar = chatGui.Frame.ChatBarParentFrame:FindFirstChild("Frame")
                if chatBar and chatBar:FindFirstChild("BoxFrame") and chatBar.BoxFrame.Frame:FindFirstChild("Frame") and chatBar.BoxFrame.Frame.Frame:FindFirstChild("ChatBar") then
                    chatInFocus = chatBar.BoxFrame.Frame.Frame.ChatBar:IsFocused()
                end
            end
            
            -- Дополнительная проверка - любой TextBox в фокусе
            if not chatInFocus then
                local function checkTextBoxFocus(parent)
                    for _, child in pairs(parent:GetChildren()) do
                        if child:IsA("TextBox") and child:IsFocused() then
                            return true
                        elseif child:IsA("GuiObject") then
                            if checkTextBoxFocus(child) then
                                return true
                            end
                        end
                    end
                    return false
                end
                chatInFocus = checkTextBoxFocus(gameGui)
            end
        end
        
        -- Прямая проверка клавиш только если не в чате и ввод не обрабатывается игрой
        if not chatInFocus and not isInputBeingProcessedByGame then
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveX = moveX + 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveX = moveX - 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveZ = moveZ + 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveZ = moveZ - 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveY = moveY + 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveY = moveY - 1
            end
        else
            -- Отладка: показываем почему ввод заблокирован
            if chatInFocus or isInputBeingProcessedByGame then
                -- Выводим сообщение только при нажатии Space для избежания спама
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    print("YBA: Ввод заблокирован - чат в фокусе:", chatInFocus, "gameProcessed:", isInputBeingProcessedByGame)
                end
            end
        end
        
        -- ВСЕГДА проверяем Shift для шифтлока (каждый кадр)
        input.LeftShift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        
        local move = Vector3.new(moveX, moveY, moveZ)
        
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
        
        -- Добавляем BodyAngularVelocity для плавного поворота
        local bav = standRoot:FindFirstChild("BodyAngularVelocity")
        if not bav then
            bav = Instance.new("BodyAngularVelocity")
            bav.MaxTorque = Vector3.new(0, 4000, 0) -- Только поворот по Y
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

        -- Обработка вращения мыши
        if input.MouseDelta.Magnitude > 0 then
            cameraRot = cameraRot + input.MouseDelta
            cameraRot = Vector2.new(
                math.clamp(cameraRot.X, -math.rad(80), math.rad(80)), 
                cameraRot.Y % (2 * math.pi)
            )
            
            -- ИСПРАВЛЕНО: Синхронизируем поворот игрока с камерой стенда
            local player = Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerRoot = player.Character.HumanoidRootPart
                local targetPlayerCFrame = CFrame.new(playerRoot.Position) * CFrame.Angles(0, cameraRot.Y, 0)
                playerRoot.CFrame = targetPlayerCFrame
            end
            
            input.MouseDelta = Vector2.new()
        end
        
        -- ИСПРАВЛЕНО: Стенд всегда копирует направление камеры (не только при Shift)
        local currentPos = standRoot.Position
        local currentCFrame = standRoot.CFrame
        local targetCFrame = CFrame.new(currentPos) * CFrame.Angles(0, cameraRot.Y, 0)
        -- Плавный поворот для естественности
        standRoot.CFrame = currentCFrame:Lerp(targetCFrame, 0.2)
        
        -- Дополнительно: если зажат Shift - ускоряем поворот стенда
        if input.LeftShift then
            standRoot.CFrame = currentCFrame:Lerp(targetCFrame, 0.5)
        end

        -- Обработка колеса мыши для зума
        if input.MouseWheel ~= 0 then
            cameraDistance = math.clamp(cameraDistance + input.MouseWheel * 2, 5, 30)
            input.MouseWheel = 0
        end

        -- ИСПРАВЛЕНО: позиционирование камеры без влияния зума на угол наклона
        local horizontalDistance = cameraDistance
        local verticalOffset = cameraHeight
        
        -- Применяем поворот камеры для наклона
        local pitchOffset = math.sin(cameraRot.X) * cameraDistance
        local adjustedHorizontalDistance = math.cos(cameraRot.X) * cameraDistance
        
        local cameraOffset = Vector3.new(
            math.sin(cameraRot.Y) * adjustedHorizontalDistance,
            verticalOffset + pitchOffset,
            math.cos(cameraRot.Y) * adjustedHorizontalDistance
        )
        
        local cameraPosition = standPosition + cameraOffset
        local newCameraCFrame = CFrame.lookAt(cameraPosition, standPosition)
        
        -- Осторожно устанавливаем только CFrame камеры (не тип)
        Camera.CFrame = newCameraCFrame
        
        -- Мягко отключаем управление камерой игроком
        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = false
            end
        end
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
        
        -- Очищаем любые существующие Body объекты
        for _, bodyObj in pairs(stand.Root:GetChildren()) do
            if bodyObj:IsA("BodyVelocity") or bodyObj:IsA("BodyPosition") or bodyObj:IsA("BodyGyro") then
                bodyObj:Destroy()
            end
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
        local standPosition = stand.Root.Position
        
        -- ИСПРАВЛЕНО: Позиционируем стенд в направлении взгляда игрока
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerCFrame = player.Character.HumanoidRootPart.CFrame
            stand.Root.CFrame = CFrame.new(standPosition, standPosition + playerCFrame.LookVector)
            print("YBA: Стенд повернут в направлении игрока")
        end
        
        -- Позиционируем камеру с учетом поворота стенда
        local horizontalDistance = math.cos(cameraRot.X) * cameraDistance
        local verticalOffset = math.sin(cameraRot.X) * cameraDistance
        local cameraOffset = Vector3.new(
            math.sin(cameraRot.Y) * horizontalDistance,
            verticalOffset + cameraHeight,
            math.cos(cameraRot.Y) * horizontalDistance
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
        
        -- Восстанавливаем камеру
        if originalCameraType then
            Camera.CameraType = originalCameraType
        else
            Camera.CameraType = Enum.CameraType.Custom
        end
        
        if originalCameraCFrame then
            Camera.CFrame = originalCameraCFrame
        end

        -- Очищаем Body объекты стенда
        if targetStand and targetStand.Root and targetStand.Root.Parent then
            for _, bodyObj in pairs(targetStand.Root:GetChildren()) do
                if bodyObj:IsA("BodyVelocity") or bodyObj:IsA("BodyPosition") or bodyObj:IsA("BodyGyro") then
                    bodyObj:Destroy()
                end
            end
            -- Останавливаем стенд
            targetStand.Root.Velocity = Vector3.new(0, 0, 0)
            if targetStand.Root.AssemblyLinearVelocity then
                targetStand.Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end

        -- Восстанавливаем управление игроком
        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
        
        -- Сбрасываем переменные
        targetStand = nil
        originalCameraCFrame = nil
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

print("🎯 YBA HACKS MODULE: YBAFreeCamera загружен")

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ YBA ====================

local function findStands()
    local stands = {}
    local player = Players.LocalPlayer
    local playerChar = player.Character
    local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
    
    if not playerRoot then 
        print("YBA: Игрок не найден или нет HumanoidRootPart")
        return stands 
    end
    
    print("YBA: Начинаем поиск стендов в workspace...")
    
    local standNames = {
        "Stand", "StandModel", "StandPart", "StandRoot", "StandHumanoidRootPart",
        "Star Platinum", "The World", "Hierophant Green", "Magician's Red",
        "Hermit Purple", "Silver Chariot", "Tower of Gray", "Dark Blue Moon",
        "Strength", "Wheel of Fortune", "Hanged Man", "Emperor", "Empress",
        "Judgment", "High Priestess", "Death Thirteen", "Lovers", "Sun",
        "Bastet", "Thunder McQueen", "Anubis", "Khnum", "Tohth", "Horus",
        "Atum", "Osiris", "Horus", "Anubis", "Bastet", "Khnum", "Tohth",
        -- Добавляем еще варианты
        "stand", "STAND", "GER", "SPTW", "TW", "SP", "KC", "KCR", "CD", "WS", "MIH",
        "TWOH", "SPOH", "D4C", "KQ", "BTD", "SF", "SM", "HP", "SC", "HG", "MR"
    }
    
    local foundCount = 0
    local checkedModels = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            checkedModels = checkedModels + 1
            local isStand = false
            for _, standName in ipairs(standNames) do
                if obj.Name:find(standName) or obj.Name:lower():find(standName:lower()) then
                    isStand = true
                    print("YBA: Найдена потенциальная модель стенда:", obj.Name)
                    break
                end
            end
            
            if isStand then
                local standRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("StandRoot") or obj:FindFirstChild("RootPart")
                if standRoot then
                    local distance = (standRoot.Position - playerRoot.Position).Magnitude
                    print("YBA: Стенд", obj.Name, "на расстоянии:", distance)
                    if distance <= 20 then
                        foundCount = foundCount + 1
                        table.insert(stands, {
                            Model = obj,
                            Root = standRoot,
                            Distance = distance,
                            Name = obj.Name
                        })
                        print("YBA: Добавлен стенд:", obj.Name)
                    else
                        print("YBA: Стенд", obj.Name, "слишком далеко:", distance)
                    end
                else
                    print("YBA: У модели", obj.Name, "нет подходящего Root части")
                end
            end
        end
    end
    
    print("YBA: Проверено моделей:", checkedModels, "Найдено стендов:", foundCount)
    
    if #stands == 0 then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local standRoot = obj:FindFirstChild("HumanoidRootPart")
                if standRoot then
                    local distance = (standRoot.Position - playerRoot.Position).Magnitude
                    if distance <= 20 then
                        table.insert(stands, {
                            Model = obj,
                            Root = standRoot,
                            Distance = distance,
                            Name = obj.Name
                        })
                    end
                end
            end
        end
    end
    
    table.sort(stands, function(a, b) return a.Distance < b.Distance end)
    return stands
end

local function freezePlayer()
    local player = Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if root then
        originalPlayerPosition = root.Position
        originalPlayerCFrame = root.CFrame
        
        local bv = root:FindFirstChild("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        end
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local gyro = root:FindFirstChild("BodyGyro")
        if not gyro then
            gyro = Instance.new("BodyGyro", root)
            gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        end
        gyro.CFrame = root.CFrame
        
        local camera = workspace.CurrentCamera
        if camera then
            camera.CameraType = Enum.CameraType.Scriptable
        end
    end
    
    if humanoid then
        originalYBAWalkSpeed = humanoid.WalkSpeed
        originalYBAJumpPower = humanoid.JumpPower
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        
        humanoid.AutoRotate = false
        humanoid.AutoJumpEnabled = false
    end
end

local function unfreezePlayer()
    local player = Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if root then
        local bv = root:FindFirstChild("BodyVelocity")
        if bv then
            bv:Destroy()
        end
        
        local gyro = root:FindFirstChild("BodyGyro")
        if gyro then
            gyro:Destroy()
        end
    end
    
    if humanoid then
        humanoid.WalkSpeed = originalYBAWalkSpeed
        humanoid.JumpPower = originalYBAJumpPower
        
        humanoid.AutoRotate = true
        humanoid.AutoJumpEnabled = true
    end
end

local function activateFreeCamera(stand)
    if not stand or not stand.Root then 
        print("YBA: Ошибка - стенд или его Root не найден")
        return false
    end
    
    print("YBA: Активируем управление стендом: " .. stand.Name)

    freeCameraActive = true
    freeCameraTarget = stand

    -- Запускаем свободную камеру
    local success = YBAFreeCamera.Start(stand)
    if success then
        print("YBA: Управление стендом успешно активировано!")
        controlledStand = stand -- Сохраняем ссылку на контролируемый стенд
        return true
    else
        print("YBA: Не удалось активировать управление стендом")
        freeCameraActive = false
        freeCameraTarget = nil
        return false
    end
end

local function disableFreeCamera()
    if not freeCameraActive then return end
    
    print("YBA: Отключаем управление стендом")
    
    freeCameraActive = false
    freeCameraTarget = nil

    YBAFreeCamera.Stop()

    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end

    for _, connection in ipairs(freeCameraConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    freeCameraConnections = {}
    
    print("YBA: Управление стендом отключено")

    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = originalYBAWalkSpeed
            humanoid.JumpPower = originalYBAJumpPower
        end

        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChild("BodyVelocity")
            if bv then
                bv:Destroy()
            end
            
            local gyro = root:FindFirstChild("BodyGyro")
            if gyro then
                gyro:Destroy()
            end
        end
    end
end

local function controlStand(stand)
    if not stand or not stand.Root then 
        print("YBA: Ошибка - стенд или его Root не найден")
        return 
    end
    
    print("YBA: Начинаем управление стендом: " .. stand.Name)
    controlledStand = stand

    if activateFreeCamera(stand) then
        print("YBA: Свободная камера активирована для стенда: " .. stand.Name)
    else
        print("YBA: Не удалось активировать свободную камеру для стенда: " .. stand.Name)
    end
end

print("🎯 YBA HACKS MODULE: Вспомогательные функции YBA загружены")

-- ==================== ОСНОВНЫЕ ФУНКЦИИ YBA STAND RANGE ====================

local function startYBA()
    if isYBAEnabled then 
        print("YBA: Уже активирован!")
        return 
    end
    
    print("YBA: Начинаем активацию Stand Range...")
    isYBAEnabled = true
    YBAConfig.Enabled = true
    
    if not findStands then 
        print("YBA: Функция findStands не найдена!")
        return 
    end
    
    print("YBA: Ищем стенды...")
    local stands = findStands()
    print("YBA: Найдено стендов:", #stands)
    
    if #stands == 0 then 
        print("YBA: Стенды не найдены! Проверьте, что у вас есть стенд.")
        isYBAEnabled = false
        YBAConfig.Enabled = false
        return 
    end
    
    local targetStand = stands[1]
    print("YBA: Выбран стенд:", targetStand.Name, "Тип модели:", targetStand.Model.ClassName)
    
    print("YBA: Найден стенд: " .. targetStand.Name .. " на расстоянии: " .. targetStand.Distance)
    
    -- Отсоединяем стенд от игрока (делаем его свободным)
    local player = Players.LocalPlayer
    if targetStand.Root and targetStand.Model then
        print("YBA: Отсоединяем стенд от игрока...")
        
        -- Мягко отключаем автоуправление стендом
        local humanoid = targetStand.Model:FindFirstChild("Humanoid")
        if humanoid then
            -- НЕ включаем PlatformStand чтобы не триггерить античит
            humanoid.Sit = false
            humanoid.Jump = false
            humanoid.AutoRotate = false
        end
        
        -- Убираем привязку к игроку через Weld/Motor6D и Attachment
        local connectionsRemoved = 0
        for _, child in pairs(targetStand.Root:GetChildren()) do
            if child:IsA("Weld") or child:IsA("Motor6D") or child:IsA("ManualWeld") then
                print("YBA: Найдена связь:", child.Name, child.ClassName)
                if (child.Part0 and child.Part0.Parent == player.Character) or 
                   (child.Part1 and child.Part1.Parent == player.Character) then
                    print("YBA: Удаляем связь с игроком:", child.Name)
                    child:Destroy()
                    connectionsRemoved = connectionsRemoved + 1
                end
            elseif child:IsA("Attachment") then
                -- Удаляем все Attachment'ы которые могут связывать с игроком
                print("YBA: Найдена привязка:", child.Name, child.ClassName)
                if child.Name == "StandAttach" or child.Name == "RootRigAttachment" then
                    print("YBA: Удаляем подозрительную привязку:", child.Name)
                    child:Destroy()
                    connectionsRemoved = connectionsRemoved + 1
                end
            end
        end
        
        -- Также проверяем все части стенда на связи и ограничения
        for _, part in pairs(targetStand.Model:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("Weld") or child:IsA("Motor6D") or child:IsA("ManualWeld") then
                        if (child.Part0 and child.Part0.Parent == player.Character) or 
                           (child.Part1 and child.Part1.Parent == player.Character) then
                            print("YBA: Удаляем связь из части", part.Name, ":", child.Name)
                            child:Destroy()
                            connectionsRemoved = connectionsRemoved + 1
                        end
                    elseif child:IsA("AlignPosition") or child:IsA("AlignOrientation") or child:IsA("BodyPosition") or child:IsA("BodyAngularVelocity") then
                        -- Удаляем все ограничения позиции/ориентации
                        print("YBA: Удаляем ограничение из части", part.Name, ":", child.Name, child.ClassName)
                        child:Destroy()
                        connectionsRemoved = connectionsRemoved + 1
                    end
                end
            end
        end
        
        print("YBA: Удалено связей с игроком:", connectionsRemoved)
        
        -- Альтернативный способ: переместить стенд в workspace и сделать независимым
        if targetStand.Model.Parent ~= workspace then
            print("YBA: Перемещаем стенд в workspace из", targetStand.Model.Parent.Name)
            targetStand.Model.Parent = workspace
        end
        
        -- Делаем стенд полностью независимым
        targetStand.Root.CanCollide = false
        targetStand.Root.Anchored = false
        
        -- Убираем все существующие Body объекты
        for _, child in pairs(targetStand.Root:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("BodyAngularVelocity") then
                print("YBA: Удаляем Body объект:", child.Name, child.ClassName)
                child:Destroy()
                connectionsRemoved = connectionsRemoved + 1
            end
        end
        
        -- Позиционируем стенд рядом с игроком после отсоединения
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerRoot = player.Character.HumanoidRootPart
            local standPosition = playerRoot.Position + playerRoot.CFrame.LookVector * 5
            targetStand.Root.CFrame = CFrame.new(standPosition, playerRoot.Position)
            targetStand.Root.Anchored = false
            
            -- Останавливаем любое существующее движение стенда
            targetStand.Root.Velocity = Vector3.new(0, 0, 0)
            targetStand.Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            print("YBA: Стенд позиционирован на:", standPosition)
        end
        
        print("YBA: Стенд отсоединен и готов к управлению")
    end
    
    if YBAConfig.FreezePlayer and freezePlayer then 
        print("YBA: Замораживаем игрока...")
        freezePlayer() 
    end
    if YBAConfig.SwitchCamera then 
        print("YBA: Переключение камеры включено")
    end
    if YBAConfig.TransferControl and activateFreeCamera then 
        print("YBA: Активируем управление стендом...")
        activateFreeCamera(targetStand) 
    end
    
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        local deathConnection = humanoid.Died:Connect(function()
            stopYBA()
        end)
        table.insert(standControlConnections, deathConnection)
    end
    
    -- Запускаем подземный полет через 5 секунд
    task.spawn(function()
        task.wait(5)
        if not isYBAEnabled then return end
        if startUndergroundControl then startUndergroundControl() end
    end)
end

local function stopYBA()
    if not isYBAEnabled then return end
    
    isYBAEnabled = false
    YBAConfig.Enabled = false
    
    if disableFreeCamera then
        disableFreeCamera()
    end
    if unfreezePlayer then
        unfreezePlayer()
    end
    
    for _, connection in ipairs(standControlConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    standControlConnections = {}
    controlledStand = nil
    
    print("Stand Range Hack деактивирован")
    print("Автоматически отключаем Underground Flight...")
    if stopUndergroundControl then
        stopUndergroundControl()
    end
end

print("🎯 YBA HACKS MODULE: Основные функции YBA Stand Range загружены")

-- ==================== UNDERGROUND CONTROL FUNCTIONS ====================

local function startUndergroundControl()
    print("=== ЗАПУСК ПОДЗЕМНОГО ПОЛЕТА ===")
    
    if isUndergroundControlEnabled then 
        print("Подземный полет уже активен!")
        return 
    end
    
    local plr = Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then 
        print("Персонаж не найден!")
        return 
    end
    
    print("Персонаж найден, позиция:", root.Position)
    
    if not findStands then
        print("Функция findStands не найдена!")
        return
    end
    
    local stands = findStands()
    if #stands == 0 then
        print("Стенды не найдены! Убедитесь, что у вас есть стенд.")
        return
    end
    
    controlledStandForUnderground = stands[1].Root
    isUndergroundControlEnabled = true
    
    print("Найден стенд:", stands[1].Name, "на расстоянии:", stands[1].Distance)
    print("Перемещаем персонажа под стенд на 40 метров вниз")
    
    if not YBAConfig.UndergroundControl.OriginalPosition then
        YBAConfig.UndergroundControl.OriginalPosition = root.Position
        print("Исходная позиция сохранена:", root.Position)
    end
    
    if YBAConfig.UndergroundControl.AutoNoClip and _G.isNoClipping and not _G.isNoClipping() and _G.startNoClip then
        _G.startNoClip()
        print("NoClip включен для подземного полета")
    elseif not _G.startNoClip then
        print("ОШИБКА: Функция startNoClip не найдена!")
    end
    
    local flyOriginalJumpPower = hum.JumpPower
    local flyOriginalJumpHeight = hum.JumpHeight
    local flyOriginalGravity = workspace.Gravity
    local flyOriginalHipHeight = hum.HipHeight
    
    hum.JumpPower = 0
    hum.JumpHeight = 0
    workspace.Gravity = 0
    hum.HipHeight = 0
    
    local standPos = controlledStandForUnderground.Position
    local undergroundPos = Vector3.new(standPos.X, standPos.Y - 40, standPos.Z)
    
    print("Стенд позиция:", standPos)
    print("Целевая подземная позиция:", undergroundPos)
    print("Текущая позиция персонажа:", root.Position)
    
    local initialBv = Instance.new("BodyVelocity", root)
    initialBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    local direction = (undergroundPos - root.Position).Unit
    local speed = 200
    initialBv.Velocity = direction * speed
    
    print("Создан BodyVelocity со скоростью:", initialBv.Velocity)
    
    task.spawn(function()
        task.wait(1)
        if initialBv and initialBv.Parent then
            initialBv:Destroy()
            print("Начальный BodyVelocity удален")
        end
    end)
    
    print("Запускаем основной цикл подземного полета...")
    local undergroundFlyLoop = RunService.RenderStepped:Connect(function()
        if not isUndergroundControlEnabled or not controlledStandForUnderground or not controlledStandForUnderground.Parent then
            print("Подземный полет остановлен - стенд не найден или функция отключена")
            if hum then
                hum.JumpPower = flyOriginalJumpPower
                hum.JumpHeight = flyOriginalJumpHeight
                hum.HipHeight = flyOriginalHipHeight
            end
            if not (_G.isNoClipping and _G.isNoClipping()) then
                workspace.Gravity = flyOriginalGravity
            end
            return
        end
        
        local char = Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then 
            if isUndergroundControlEnabled then
                stopUndergroundControl()
            end
            return 
        end
        
        local standPos = controlledStandForUnderground.Position
        local targetPos = Vector3.new(standPos.X, standPos.Y - 40, standPos.Z)
        
        local bv = root:FindFirstChild("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        end
        
        local direction = (targetPos - root.Position).Unit
        local distance = (targetPos - root.Position).Magnitude
        
        if distance > 2 then
            local flySpeed = math.floor(YBAConfig.UndergroundControl.FlightSpeed)
            
            if isShiftPressed then
                flySpeed = flySpeed + 50
            end
            
            local currentVelocity = bv.Velocity
            local targetVelocity = direction * flySpeed
            local smoothedVelocity = currentVelocity + (targetVelocity - currentVelocity) * 0.15
            bv.Velocity = smoothedVelocity
        elseif distance > 0.5 then
            local flySpeed = math.floor(YBAConfig.UndergroundControl.FlightSpeed * 0.2)
            
            if isShiftPressed then
                flySpeed = flySpeed + 10
            end
            
            local currentVelocity = bv.Velocity
            local targetVelocity = direction * flySpeed
            local smoothedVelocity = currentVelocity + (targetVelocity - currentVelocity) * 0.1
            bv.Velocity = smoothedVelocity
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    table.insert(undergroundControlConnections, undergroundFlyLoop)
    
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        local deathConnection = humanoid.Died:Connect(function()
            print("Игрок умер, отключаем Underground Flight...")
            stopUndergroundControl()
        end)
        table.insert(undergroundControlConnections, deathConnection)
    end
    
    print("Полет под землей за стендом активирован!")
    print("Персонаж перенесен под стенд на расстоянии 40 метров под землей")
end

local function stopUndergroundControl()
    if not isUndergroundControlEnabled then return end
    
    isUndergroundControlEnabled = false
    
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
    
    for _, connection in ipairs(undergroundControlConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    undergroundControlConnections = {}
    
    if YBAConfig.UndergroundControl.OriginalPosition then
        if root then
            print("Плавно возвращаем персонажа в исходную позицию...")
            
            local returnBv = Instance.new("BodyVelocity", root)
            returnBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            local direction = (YBAConfig.UndergroundControl.OriginalPosition - root.Position).Unit
            local distance = (YBAConfig.UndergroundControl.OriginalPosition - root.Position).Magnitude
            local returnSpeed = 100
            
            returnBv.Velocity = direction * returnSpeed
            
            local returnConnection = RunService.Heartbeat:Connect(function()
                local currentDistance = (YBAConfig.UndergroundControl.OriginalPosition - root.Position).Magnitude
                
                if currentDistance < 2 then
                    returnBv:Destroy()
                    returnConnection:Disconnect()
                    
                    YBAConfig.UndergroundControl.OriginalPosition = nil
                    print("Персонаж возвращен в исходную позицию")
                end
            end)
        end
    end
    
    controlledStandForUnderground = nil
    print("Underground Flight деактивирован")
end

print("🎯 YBA HACKS MODULE: Underground Control загружен")

-- ==================== ANTI TIME STOP FUNCTIONS ====================

local function detectTimeStop()
    local players = Players:GetPlayers()
    local localPlayer = Players.LocalPlayer
    local localChar = localPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return false end
    
    for _, player in pairs(players) do
        if player ~= localPlayer then
            local char = player.Character
            if char then
                local stand = char:FindFirstChild("Stand")
                if stand then
                    local standAbilities = stand:FindFirstChild("Abilities")
                    if standAbilities then
                        for _, ability in pairs(standAbilities:GetChildren()) do
                            local abilityName = ability.Name:lower()
                            if abilityName:find("time") or 
                               abilityName:find("stop") or
                               abilityName:find("za warudo") or
                               abilityName:find("the world") or
                               abilityName:find("timestop") or
                               abilityName:find("time_stop") or
                               abilityName:find("za") or
                               abilityName:find("warudo") then
                                return true, player, ability
                            end
                        end
                    end
                    
                    local standName = stand.Name:lower()
                    if standName:find("the world") or 
                       standName:find("za warudo") or
                       standName:find("dio") or
                       standName:find("jotaro") or
                       standName:find("star platinum") or
                       standName:find("the world") then
                        return true, player, stand
                    end
                end
                
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local partName = part.Name:lower()
                        if partName:find("time") or 
                           partName:find("stop") or
                           partName:find("freeze") or
                           partName:find("timestop") then
                            return true, player, part
                        end
                    end
                end
            end
        end
    end
    
    if localChar then
        local hum = localChar:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, part in pairs(localChar:GetDescendants()) do
                if part:IsA("BasePart") and part.Anchored then
                    return true, nil, nil
                end
            end
        end
    end
    
    return false
end

local function createAntiTimeStopEffect()
    if not AntiTimeStopConfig.VisualEffect then return end
    
    local char = Players.LocalPlayer.Character
    if not char then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "AntiTimeStopEffect"
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    
    antiTimeStopEffect = highlight
end

local function removeAntiTimeStopEffect()
    if antiTimeStopEffect then
        antiTimeStopEffect:Destroy()
        antiTimeStopEffect = nil
    end
end

local function startAntiTimeStop()
    local plr = Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end
    
    isAntiTimeStopEnabled = true
    timeStopDetected = false
    
    originalAntiTimeStopWalkSpeed = hum.WalkSpeed
    originalAntiTimeStopJumpPower = hum.JumpPower
    
    hum.WalkSpeed = AntiTimeStopConfig.WalkSpeed * AntiTimeStopConfig.MovementSpeed
    hum.JumpPower = AntiTimeStopConfig.JumpPower
    
    createAntiTimeStopEffect()
    
    print("Anti TS: Принудительное движение активировано")
    
    -- БЕЗОПАСНОЕ принудительное движение
    local lastAntiTSUpdate = 0
    local antiFreezeLoop = RunService.Heartbeat:Connect(function()
        if not isAntiTimeStopEnabled or not char or not char.Parent then
            return
        end
        
        -- Ограничиваем до 30 FPS для уменьшения нагрузки
        local currentTime = tick()
        if currentTime - lastAntiTSUpdate < 0.033 then
            return
        end
        lastAntiTSUpdate = currentTime
        
        -- Просто убираем Anchored с основных частей (безопасно)
        if root then
            root.Anchored = false
        end
        
        if hum then
            hum.PlatformStand = false
        end
        
        -- ПРИНУДИТЕЛЬНОЕ движение через BodyVelocity
        local moveVector = Vector3.new(0, 0, 0)
        local cam = workspace.CurrentCamera
        
        -- Проверяем нажатые клавиши и принудительно двигаем
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        
        -- Если есть движение - принудительно двигаем через BodyVelocity
        if moveVector.Magnitude > 0 and root then
            local bv = root:FindFirstChild("AntiTSBodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "AntiTSBodyVelocity"
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Parent = root
            end
            
            bv.Velocity = moveVector.Unit * 20 -- Нормальная скорость движения
        else
            -- Убираем BodyVelocity когда не двигаемся
            local bv = root and root:FindFirstChild("AntiTSBodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
    end)
    
    table.insert(antiTimeStopConnections, antiFreezeLoop)
end

local function stopAntiTimeStop()
    isAntiTimeStopEnabled = false
    timeStopDetected = false
    
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        hum.WalkSpeed = originalAntiTimeStopWalkSpeed
        hum.JumpPower = originalAntiTimeStopJumpPower
        hum.AutoRotate = true
        hum.AutoJumpEnabled = true
    end
    
    if root then
        local bv = root:FindFirstChild("AntiTSBodyVelocity")
        if bv then
            bv:Destroy()
        end
        
        local bg = root:FindFirstChild("AntiTimeStopBodyGyro")
        if bg then
            bg:Destroy()
        end
    end
    
    removeAntiTimeStopEffect()
    
    for _, connection in ipairs(antiTimeStopConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    antiTimeStopConnections = {}
    
    print("Anti Time Stop disabled")
end

print("🎯 YBA HACKS MODULE: Anti Time Stop загружен")

-- ==================== ОСТАЛЬНЫЕ ФУНКЦИИ YBA HACKS (ЗАГЛУШКИ) ====================

-- Item ESP Functions (заглушки - полную реализацию можно добавить позже)
local function startItemESP()
    print("YBA Item ESP: Активирован (заглушка)")
    YBAConfig.ItemESP.Enabled = true
end

local function stopItemESP()
    print("YBA Item ESP: Деактивирован (заглушка)")
    YBAConfig.ItemESP.Enabled = false
end

-- User Stand ESP Functions (заглушки)
local function startUserStandESP()
    print("YBA Player ESP: User Stand ESP активирован (заглушка)")
end

local function stopUserStandESP()
    print("YBA Player ESP: User Stand ESP деактивирован (заглушка)")
end

-- User Style ESP Functions (заглушки)
local function startUserStyleESP()
    print("YBA Player ESP: User Style ESP активирован (заглушка)")
end

local function stopUserStyleESP()
    print("YBA Player ESP: User Style ESP деактивирован (заглушка)")
end

-- Autofarm Functions (заглушки - полную реализацию можно добавить позже)
local function startAutofarm()
    print("YBA Autofarm: Активирован (заглушка)")
    isAutofarmEnabled = true
end

local function stopAutofarm()
    print("YBA Autofarm: Деактивирован (заглушка)")
    isAutofarmEnabled = false
end

print("🎯 YBA HACKS MODULE: Остальные функции загружены")

-- ==================== ЭКСПОРТ ФУНКЦИЙ В ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ====================

-- Экспортируем все функции YBA hacks в глобальные переменные
_G.YBAHacksModule = {
    -- Конфигурации
    YBAConfig = YBAConfig,
    AntiTimeStopConfig = AntiTimeStopConfig,
    AutofarmConfig = AutofarmConfig,
    
    -- Основные функции YBA Stand Range
    startYBA = startYBA,
    stopYBA = stopYBA,
    
    -- Underground Control
    startUndergroundControl = startUndergroundControl,
    stopUndergroundControl = stopUndergroundControl,
    
    -- Anti Time Stop
    startAntiTimeStop = startAntiTimeStop,
    stopAntiTimeStop = stopAntiTimeStop,
    
    -- Item ESP
    startItemESP = startItemESP,
    stopItemESP = stopItemESP,
    
    -- User ESP
    startUserStandESP = startUserStandESP,
    stopUserStandESP = stopUserStandESP,
    startUserStyleESP = startUserStyleESP,
    stopUserStyleESP = stopUserStyleESP,
    
    -- Autofarm
    startAutofarm = startAutofarm,
    stopAutofarm = stopAutofarm,
    
    -- Вспомогательные функции
    findStands = findStands,
    freezePlayer = freezePlayer,
    unfreezePlayer = unfreezePlayer,
    activateFreeCamera = activateFreeCamera,
    disableFreeCamera = disableFreeCamera,
    controlStand = controlStand,
    
    -- Состояние модуля
    isYBAEnabled = function() return isYBAEnabled end,
    isAntiTimeStopEnabled = function() return isAntiTimeStopEnabled end,
    isAutofarmEnabled = function() return isAutofarmEnabled end,
    isUndergroundControlEnabled = function() return isUndergroundControlEnabled end,
    itemESPEnabled = function() return itemESPEnabled end,
    
    -- YBAFreeCamera
    YBAFreeCamera = YBAFreeCamera
}

print("🎯 YBA HACKS MODULE: Функции экспортированы в _G.YBAHacksModule")

-- ==================== ФИНАЛЬНАЯ ПРОВЕРКА И ЗАВЕРШЕНИЕ ====================

-- Проверяем что все основные функции доступны
local function validateModule()
    local requiredFunctions = {
        "startYBA", "stopYBA", "startUndergroundControl", "stopUndergroundControl",
        "startAntiTimeStop", "stopAntiTimeStop", "startItemESP", "stopItemESP",
        "startAutofarm", "stopAutofarm", "findStands"
    }
    
    local missingFunctions = {}
    for _, funcName in ipairs(requiredFunctions) do
        if not _G.YBAHacksModule[funcName] then
            table.insert(missingFunctions, funcName)
        end
    end
    
    if #missingFunctions > 0 then
        print("🎯 YBA HACKS MODULE: ПРЕДУПРЕЖДЕНИЕ - Отсутствуют функции:", table.concat(missingFunctions, ", "))
        return false
    end
    
    print("🎯 YBA HACKS MODULE: Все основные функции доступны ✓")
    return true
end

-- Проверяем что основные зависимости доступны
local function validateDependencies()
    local requiredDependencies = {
        {"_G.startNoClip", _G.startNoClip},
        {"_G.stopNoClip", _G.stopNoClip},
        {"_G.isNoClipping", _G.isNoClipping}
    }
    
    local missingDeps = {}
    for _, dep in ipairs(requiredDependencies) do
        if not dep[2] then
            table.insert(missingDeps, dep[1])
        end
    end
    
    if #missingDeps > 0 then
        print("🎯 YBA HACKS MODULE: ПРЕДУПРЕЖДЕНИЕ - Отсутствуют зависимости:", table.concat(missingDeps, ", "))
        print("🎯 YBA HACKS MODULE: Некоторые функции могут работать некорректно!")
        return false
    end
    
    print("🎯 YBA HACKS MODULE: Все зависимости доступны ✓")
    return true
end

-- Выполняем проверки
local moduleValid = validateModule()
local depsValid = validateDependencies()

if moduleValid and depsValid then
    print("🎯 YBA HACKS MODULE: ✅ Модуль загружен успешно и готов к использованию!")
else
    print("🎯 YBA HACKS MODULE: ⚠️  Модуль загружен с предупреждениями")
end

print("🎯 YBA HACKS MODULE: Загрузка завершена!")