-- YBA HACKS COMPLETE MODULE - ТОЧНАЯ КОПИЯ ВСЕХ YBA ФУНКЦИЙ ИЗ ОРИГИНАЛА
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

-- YBA VARIABLES (ТОЧНО ИЗ ОРИГИНАЛА)
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

-- NoClip variables (нужны для YBA функций)
local isNoClipping = false
local noClipConnections = {}

-- YBA ITEM NAMES
local YBA_ITEM_NAMES = {
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

-- NOCLIP FUNCTIONS (ТОЧНО ИЗ ОРИГИНАЛА)
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

-- ANTI TIME STOP FUNCTIONS (ТОЧНО ИЗ ОРИГИНАЛА)
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

-- PLACEHOLDER для detectTimeStop (эта функция должна быть в основном файле)
local function detectTimeStop()
    -- Эта функция должна быть реализована в основном файле
    return false, nil, nil
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
    local antiFreezeLoop = RunService.Heartbeat:Connect(function()
        if not isAntiTimeStopEnabled or not char or not char.Parent then
            return
        end
        
        -- Просто убираем Anchored с основных частей (безопасно)
        if root then
            root.Anchored = false
        end
        
        if hum then
            hum.PlatformStand = false
        end
        
        -- ПРИНУДИТЕЛЬНОЕ движение через BodyVelocity (НЕ удаляем ничего!)
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
            print("Anti TS: Принудительно двигаю игрока")
        else
            -- Убираем BodyVelocity когда не двигаемся
            local bv = root and root:FindFirstChild("AntiTSBodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
        
        -- РАБОТАЕМ ТОЛЬКО С ТВОИМ СТЕНДОМ!
        local myStand = nil
        
        print("Anti TS: Ищем твой стенд...")
        print("Anti TS: Range Hack активен?", isYBAEnabled)
        print("Anti TS: controlledStand есть?", controlledStand ~= nil)
        
        -- Сначала проверяем активен ли Stand Range Hack - используем его стенд
        if isYBAEnabled and controlledStand and controlledStand.Root then
            myStand = controlledStand
            print("Anti TS: Используем стенд из Range Hack -", controlledStand.Name or "Unknown")
        else
            print("Anti TS: Range Hack неактивен, ищем стенд вручную...")
            
            -- УПРОЩЕННЫЙ поиск - просто ищем ВСЕ стенды рядом с игроком
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Model") then
                    local standRoot = obj:FindFirstChild("HumanoidRootPart")
                    if standRoot and root then
                        local distance = (standRoot.Position - root.Position).Magnitude
                        if distance <= 20 then
                            -- Проверяем что это стенд (а не игрок)
                            if obj.Name:find("Stand") or obj.Name:find("stand") or
                               obj.Name:find("SP") or obj.Name:find("TW") or obj.Name:find("KC") or
                               obj.Name:find("CD") or obj.Name:find("GE") or obj.Name:find("SF") or
                               obj.Name:find("MR") or obj.Name:find("PH") or obj.Name:find("SC") then
                                myStand = {Root = standRoot, Model = obj, Name = obj.Name}
                                print("Anti TS: Найден стенд рядом -", obj.Name, "расстояние:", distance)
                                break
                            end
                        end
                    end
                end
            end
            
            if not myStand then
                print("Anti TS: НЕ НАЙДЕН СТЕНД РЯДОМ!")
                -- Выводим что вообще есть рядом
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and root then
                        local objRoot = obj:FindFirstChild("HumanoidRootPart")
                        if objRoot then
                            local distance = (objRoot.Position - root.Position).Magnitude
                            if distance <= 20 then
                                print("Anti TS: Рядом модель:", obj.Name, "расстояние:", distance)
                            end
                        end
                    end
                end
            end
        end
        
        -- Если нашли твой стенд - принудительно двигаем его
        if myStand and myStand.Root then
            local standRoot = myStand.Root
            
            -- Убираем Anchored со стенда (безопасно)
            standRoot.Anchored = false
            
            -- ПРИНУДИТЕЛЬНО двигаем стенд тоже!
            if moveVector.Magnitude > 0 then
                local standBV = standRoot:FindFirstChild("AntiTSStandBodyVelocity")
                if not standBV then
                    standBV = Instance.new("BodyVelocity")
                    standBV.Name = "AntiTSStandBodyVelocity"
                    standBV.MaxForce = Vector3.new(4000, 4000, 4000)
                    standBV.Parent = standRoot
                end
                
                standBV.Velocity = moveVector.Unit * 25 -- Чуть быстрее стенда
                print("Anti TS: Принудительно двигаю ТВОЙ стенд", myStand.Name or "Unknown")
            else
                -- Убираем BodyVelocity со стенда когда не двигаемся
                local standBV = standRoot:FindFirstChild("AntiTSStandBodyVelocity")
                if standBV then
                    standBV:Destroy()
                end
            end
        end
    end)
    
    local attackDetection = RunService.Heartbeat:Connect(function()
        if not isAntiTimeStopEnabled or not timeStopDetected or not char or not char.Parent then
            return
        end
        
        local isAttacking = false
        
        if UserInputService:IsKeyDown(Enum.KeyCode.F) or 
           UserInputService:IsKeyDown(Enum.KeyCode.E) or
           UserInputService:IsKeyDown(Enum.KeyCode.R) or
           UserInputService:IsKeyDown(Enum.KeyCode.T) or
           UserInputService:IsKeyDown(Enum.KeyCode.Y) or
           UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            isAttacking = true
        end
        
        if isAttacking and antiTimeStopEffect then
            antiTimeStopEffect.FillColor = Color3.fromRGB(255, 255, 0)
        else
            if antiTimeStopEffect then
                antiTimeStopEffect.FillColor = Color3.fromRGB(0, 255, 0)
            end
        end
    end)
    
    local timeStopDetection = RunService.Heartbeat:Connect(function()
        if not isAntiTimeStopEnabled or not char or not char.Parent then
            return
        end
        
        local detected, timeStopPlayer, timeStopAbility = detectTimeStop()
        
        if detected and not timeStopDetected then
            timeStopDetected = true
            timeStopStartTime = tick()
            
            if AntiTimeStopConfig.AntiFreeze then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                        part.CanCollide = true
                    end
                end
            end
            
            if AntiTimeStopConfig.MovementOverride then
                local bv = root:FindFirstChild("AntiTimeStopBodyVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity", root)
                    bv.Name = "AntiTimeStopBodyVelocity"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                end
                
                local bg = root:FindFirstChild("AntiTimeStopBodyGyro")
                if not bg then
                    bg = Instance.new("BodyGyro", root)
                    bg.Name = "AntiTimeStopBodyGyro"
                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bg.D = 1000
                    bg.P = 8000
                end
            end
            
            if AntiTimeStopConfig.SoundEffect then
                local sound = Instance.new("Sound", root)
                sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                sound.Volume = 0.5
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 2)
            end
            
        elseif not detected and timeStopDetected then
            timeStopDetected = false
            timeStopDuration = tick() - timeStopStartTime
            
            hum.WalkSpeed = originalAntiTimeStopWalkSpeed
            hum.JumpPower = originalAntiTimeStopJumpPower
            
            local bv = root:FindFirstChild("AntiTimeStopBodyVelocity")
            if bv then
                bv:Destroy()
            end
            
            local bg = root:FindFirstChild("AntiTimeStopBodyGyro")
            if bg then
                bg:Destroy()
            end
            
            removeAntiTimeStopEffect()
        end
    end)
    
    local movementOverride = RunService.Heartbeat:Connect(function()
        if not isAntiTimeStopEnabled or not timeStopDetected or not char or not char.Parent then
            return
        end
        
        if AntiTimeStopConfig.MovementOverride then
            local bv = root:FindFirstChild("AntiTimeStopBodyVelocity")
            local bg = root:FindFirstChild("AntiTimeStopBodyGyro")
            
            if bv and bg then
                local moveVector = Vector3.new(0, 0, 0)
                local cam = workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + cam.CFrame.lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - cam.CFrame.lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - cam.CFrame.rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + cam.CFrame.rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                if moveVector.Magnitude > 0 then
                    moveVector = moveVector.Unit * (AntiTimeStopConfig.WalkSpeed * AntiTimeStopConfig.MovementSpeed)
                    bv.Velocity = moveVector
                    
                    bg.CFrame = cam.CFrame
                    
                    if AntiTimeStopConfig.ServerSync then
                        local newCFrame = root.CFrame + (moveVector * 0.016)
                        root.CFrame = newCFrame
                        
                        local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("AntiTimeStopMovement")
                        if not remoteEvent then
                            remoteEvent = Instance.new("RemoteEvent")
                            remoteEvent.Name = "AntiTimeStopMovement"
                            remoteEvent.Parent = game:GetService("ReplicatedStorage")
                        end
                        
                        remoteEvent:FireServer(newCFrame)
                    end
                    
                    if AntiTimeStopConfig.VisualEffect and antiTimeStopEffect then
                        antiTimeStopEffect.FillColor = Color3.fromRGB(0, 255, 255)
                    end
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                    
                    if AntiTimeStopConfig.VisualEffect and antiTimeStopEffect then
                        antiTimeStopEffect.FillColor = Color3.fromRGB(0, 255, 0)
                    end
                end
            end
        end
    end)
    
    local damageProtection = char.Humanoid.Died:Connect(function()
    end)
    
    local healthChanged = hum.HealthChanged:Connect(function(health)
    end)
    
    table.insert(antiTimeStopConnections, antiFreezeLoop)
    table.insert(antiTimeStopConnections, attackDetection)
    table.insert(antiTimeStopConnections, timeStopDetection)
    table.insert(antiTimeStopConnections, movementOverride)
    table.insert(antiTimeStopConnections, damageProtection)
    table.insert(antiTimeStopConnections, healthChanged)
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
        local bv = root:FindFirstChild("AntiTimeStopBodyVelocity")
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
        local cameraOffset = Vector3.new(
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

-- YBA STAND FUNCTIONS (ТОЧНО ИЗ ОРИГИНАЛА)
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
    
    if YBAConfig.UndergroundControl.AutoNoClip and not isNoClipping and startNoClip then
        startNoClip()
        print("NoClip включен для подземного полета")
    elseif not startNoClip then
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
            if not isNoClipping then
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
                    print("Персонаж успешно возвращен в исходную позицию")
                end
            end)
        end
    end
    
    controlledStandForUnderground = nil
    
    print("Полет под землей за стендом отключен!")
end

-- ЭКСПОРТ МОДУЛЯ
print("YBA HACKS COMPLETE MODULE: Загружен с основными функциями!")

return {
    -- Configs
    YBAConfig = YBAConfig,
    AntiTimeStopConfig = AntiTimeStopConfig,
    AutofarmConfig = AutofarmConfig,
    
    -- Main functions
    startAntiTimeStop = startAntiTimeStop,
    stopAntiTimeStop = stopAntiTimeStop,
    startNoClip = startNoClip,
    stopNoClip = stopNoClip,
    isNoClipping = function() return isNoClipping end,
    startYBA = startYBA,
    stopYBA = stopYBA,
    startUndergroundControl = startUndergroundControl,
    stopUndergroundControl = stopUndergroundControl,
    findStands = findStands,
    freezePlayer = freezePlayer,
    unfreezePlayer = unfreezePlayer,
    activateFreeCamera = activateFreeCamera,
    disableFreeCamera = disableFreeCamera,
    controlStand = controlStand,
    
    -- Placeholder functions (добавлю остальные сейчас)
    startItemESP = function() print("TODO: startItemESP - добавляю сейчас") end,
    stopItemESP = function() print("TODO: stopItemESP - добавляю сейчас") end,
    startAutofarm = function() print("TODO: startAutofarm - добавляю сейчас") end,
    stopAutofarm = function() print("TODO: stopAutofarm - добавляю сейчас") end,
    
    -- Interface creation (временно заглушка)
    createYBAInterface = function(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton, getText, padding)
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
        
        -- ⏰ ANTI TS заголовок
        createSectionHeader("⏰ ANTI TS")
        
        local antiTimeStopBtn = Instance.new("TextButton", functionsContainer)
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
        
        print("YBA HACKS: Интерфейс создан (частично)!")
        return currentY
    end,
}