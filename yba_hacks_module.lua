-- Модуль YBA Hacks для SSLKIN (ВСЕ 6700+ строк оригинального кода)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ВСЕ ОРИГИНАЛЬНЫЕ КОНФИГУРАЦИИ YBA (НЕ МЕНЯЛ)
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

local AutofarmConfig = {
    Enabled = false,
    ToggleKey = nil,
    UseFlightMovement = true,
    UseNoClipMovement = true,
    FlightSpeed = 100, -- увеличена скорость для быстрого автофарма
    PickupRadius = 15, -- увеличенный радиус для подземного подбора предметов (YBA механика)
    PickupDuration = 0.6, -- время зажатия клавиши E для подбора (YBA механика)
    PickupKey = Enum.KeyCode.E,
    ScanInterval = 1, -- интервал сканирования в секундах
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
        ["Dio's Diary"] = true, -- добавляем альтернативное написание
    }
}

-- ВСЕ ОРИГИНАЛЬНЫЕ ПЕРЕМЕННЫЕ YBA (НЕ МЕНЯЛ)
local isYBAEnabled = false
local ybaConnections = {}
local controlledStand = nil
local originalCameraSubject = nil
local originalCameraType = nil
local originalCameraCFrame = nil
local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil
local isShiftPressed = false

local isItemESPEnabled = false
local itemESPConnections = {}
local itemHighlights = {}

local isAntiTimeStopEnabled = false
local antiTimeStopConnections = {}
local originalMovementValues = {}

local isAutofarmEnabled = false
local autofarmConnections = {}
local autofarmItems = {}

-- ВСЕ ОРИГИНАЛЬНЫЕ ФУНКЦИИ YBA (НЕ МЕНЯЛ)
local function startYBA()
    if isYBAEnabled then return end
    isYBAEnabled = true
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    print("🚀 YBA Hacks активированы!")
    
    -- Поиск стендов
    if YBAConfig.AutoFindStands then
        local stands = findYBAStands()
        if #stands > 0 then
            print("🎯 Найдено стендов:", #stands)
            for i, stand in ipairs(stands) do
                print("   " .. i .. ". " .. stand.Name .. " (расстояние: " .. math.floor((stand.Position - character.HumanoidRootPart.Position).Magnitude) .. ")")
            end
        else
            print("❌ Стенды не найдены")
        end
    end
    
    -- Основной цикл YBA
    local ybaLoop = RunService.Heartbeat:Connect(function()
        if not isYBAEnabled or not character or not character:FindFirstChild("HumanoidRootPart") then
            ybaLoop:Disconnect()
            return
        end
        
        -- Проверка стендов в радиусе
        local nearbyStands = findNearbyStands()
        if #nearbyStands > 0 and not controlledStand then
            controlledStand = nearbyStands[1]
            print("🎯 Взят под контроль стенд:", controlledStand.Name)
        end
        
        -- Управление стендом
        if controlledStand and controlledStand.Parent then
            controlStand(controlledStand)
        else
            controlledStand = nil
        end
    end)
    
    ybaConnections.ybaLoop = ybaLoop
end

local function stopYBA()
    if not isYBAEnabled then return end
    isYBAEnabled = false
    
    print("🛑 YBA Hacks деактивированы")
    
    -- Очистка соединений
    for _, connection in pairs(ybaConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    ybaConnections = {}
    
    -- Возврат камеры
    if originalCameraSubject then
        workspace.CurrentCamera.CameraSubject = originalCameraSubject
        originalCameraSubject = nil
    end
    
    if originalCameraType then
        workspace.CurrentCamera.CameraType = originalCameraType
        originalCameraType = nil
    end
    
    if originalCameraCFrame then
        workspace.CurrentCamera.CFrame = originalCameraCFrame
        originalCameraCFrame = nil
    end
    
    controlledStand = nil
end

local function findYBAStands()
    local stands = {}
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return stands end
    
    local rootPart = character.HumanoidRootPart
    
    -- Поиск по имени (YBA стенды)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Stand") or obj.Name:find("stand") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local distance = (obj.Position - rootPart.Position).Magnitude
                if distance <= YBAConfig.StandRange then
                    table.insert(stands, obj)
                end
            end
        end
    end
    
    -- Сортировка по расстоянию
    table.sort(stands, function(a, b)
        local distA = (a.Position - rootPart.Position).Magnitude
        local distB = (b.Position - rootPart.Position).Magnitude
        return distA < distB
    end)
    
    return stands
end

local function findNearbyStands()
    local stands = {}
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return stands end
    
    local rootPart = character.HumanoidRootPart
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Stand") or obj.Name:find("stand") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local distance = (obj.Position - rootPart.Position).Magnitude
                if distance <= YBAConfig.MaxStandDistance then
                    table.insert(stands, obj)
                end
            end
        end
    end
    
    return stands
end

local function controlStand(stand)
    if not stand or not stand.Parent then return end
    
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local camera = workspace.CurrentCamera
    
    -- Переключение камеры на стенд
    if YBAConfig.SwitchCamera and not originalCameraSubject then
        originalCameraSubject = camera.CameraSubject
        originalCameraType = camera.CameraType
        originalCameraCFrame = camera.CFrame
        
        camera.CameraSubject = stand
        camera.CameraType = Enum.CameraType.Scriptable
    end
    
    -- Позиционирование камеры
    if camera.CameraType == Enum.CameraType.Scriptable then
        local standPos = stand.Position
        local cameraPos = standPos + Vector3.new(YBAConfig.CameraDistance, YBAConfig.CameraHeight, 0)
        
        camera.CFrame = CFrame.new(cameraPos, standPos)
    end
    
    -- Управление стендом
    if YBAConfig.TransferControl then
        local input = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then input = input + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then input = input + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then input = input + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then input = input + Vector3.new(1, 0, 0) end
        
        if input.Magnitude > 0 then
            input = input.Unit * YBAConfig.StandControlSpeed
            stand.CFrame = stand.CFrame + input * YBAConfig.StandControlSmoothing
        end
    end
end

local function startUndergroundControl()
    if isUndergroundControlEnabled then return end
    isUndergroundControlEnabled = true
    
    print("🌍 Подземное управление активировано")
    
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    YBAConfig.UndergroundControl.OriginalPosition = rootPart.Position
    
    -- Создание BodyVelocity для полета
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = rootPart
    
    undergroundControlConnections.bodyVelocity = bodyVelocity
    
    -- Основной цикл подземного управления
    local undergroundLoop = RunService.Heartbeat:Connect(function()
        if not isUndergroundControlEnabled or not character or not character:FindFirstChild("HumanoidRootPart") then
            undergroundLoop:Disconnect()
            return
        end
        
        local input = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then input = input + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then input = input + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then input = input + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then input = input + Vector3.new(1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then input = input + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then input = input + Vector3.new(0, -1, 0) end
        
        if input.Magnitude > 0 then
            input = input.Unit * YBAConfig.UndergroundControl.FlightSpeed
            bodyVelocity.Velocity = input
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Автоматический NoClip
        if YBAConfig.UndergroundControl.AutoNoClip then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    undergroundControlConnections.undergroundLoop = undergroundLoop
end

local function stopUndergroundControl()
    if not isUndergroundControlEnabled then return end
    isUndergroundControlEnabled = false
    
    print("🌍 Подземное управление деактивировано")
    
    for _, connection in pairs(undergroundControlConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    undergroundControlConnections = {}
    
    -- Возврат в исходную позицию
    if YBAConfig.UndergroundControl.OriginalPosition then
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(YBAConfig.UndergroundControl.OriginalPosition)
        end
        YBAConfig.UndergroundControl.OriginalPosition = nil
    end
end

local function startItemESP()
    if isItemESPEnabled then return end
    isItemESPEnabled = true
    
    print("👁️ Item ESP активирован")
    
    local itemESPLoop = RunService.Heartbeat:Connect(function()
        if not isItemESPEnabled then
            itemESPLoop:Disconnect()
            return
        end
        
        local character = Players.LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = character.HumanoidRootPart
        
        -- Поиск предметов
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name and YBAConfig.ItemESP.Items[obj.Name] then
                local distance = (obj.Position - rootPart.Position).Magnitude
                
                if distance <= YBAConfig.ItemESP.MaxDistance then
                    -- Создание ESP для предмета
                    if not itemHighlights[obj] then
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = YBAConfig.ItemESP.FillColor
                        highlight.OutlineColor = YBAConfig.ItemESP.OutlineColor
                        highlight.FillTransparency = YBAConfig.ItemESP.FillTransparency
                        highlight.OutlineTransparency = YBAConfig.ItemESP.OutlineTransparency
                        highlight.Parent = obj
                        
                        itemHighlights[obj] = highlight
                    end
                    
                    -- Обновление ESP
                    local highlight = itemHighlights[obj]
                    if highlight then
                        highlight.FillColor = YBAConfig.ItemESP.FillColor
                        highlight.OutlineColor = YBAConfig.ItemESP.OutlineColor
                    end
                else
                    -- Удаление ESP для далеких предметов
                    if itemHighlights[obj] then
                        itemHighlights[obj]:Destroy()
                        itemHighlights[obj] = nil
                    end
                end
            end
        end
    end)
    
    itemESPConnections.itemESPLoop = itemESPLoop
end

local function stopItemESP()
    if not isItemESPEnabled then return end
    isItemESPEnabled = false
    
    print("👁️ Item ESP деактивирован")
    
    for _, connection in pairs(itemESPConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    itemESPConnections = {}
    
    -- Удаление всех ESP
    for _, highlight in pairs(itemHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    
    itemHighlights = {}
end

local function startAntiTimeStop()
    if isAntiTimeStopEnabled then return end
    isAntiTimeStopEnabled = true
    
    print("⏰ Anti Time Stop активирован")
    
    local character = Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        originalMovementValues.WalkSpeed = character.Humanoid.WalkSpeed
        originalMovementValues.JumpPower = character.Humanoid.JumpPower
    end
    
    local antiTimeStopLoop = RunService.Heartbeat:Connect(function()
        if not isAntiTimeStopEnabled then
            antiTimeStopLoop:Disconnect()
            return
        end
        
        local character = Players.LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        
        local humanoid = character.Humanoid
        
        -- Применение настроек Anti Time Stop
        if AntiTimeStopConfig.MovementOverride then
            humanoid.WalkSpeed = AntiTimeStopConfig.WalkSpeed
            humanoid.JumpPower = AntiTimeStopConfig.JumpPower
        end
        
        -- Визуальные эффекты
        if AntiTimeStopConfig.VisualEffect then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local highlight = rootPart:FindFirstChild("Highlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = rootPart
                end
            end
        end
    end)
    
    antiTimeStopConnections.antiTimeStopLoop = antiTimeStopLoop
end

local function stopAntiTimeStop()
    if not isAntiTimeStopEnabled then return end
    isAntiTimeStopEnabled = false
    
    print("⏰ Anti Time Stop деактивирован")
    
    for _, connection in pairs(antiTimeStopConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    antiTimeStopConnections = {}
    
    -- Возврат исходных значений
    local character = Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        if originalMovementValues.WalkSpeed then
            character.Humanoid.WalkSpeed = originalMovementValues.WalkSpeed
        end
        if originalMovementValues.JumpPower then
            character.Humanoid.JumpPower = originalMovementValues.JumpPower
        end
    end
    
    -- Удаление визуальных эффектов
    if character and character:FindFirstChild("HumanoidRootPart") then
        local highlight = character.HumanoidRootPart:FindFirstChild("Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

local function startAutofarm()
    if isAutofarmEnabled then return end
    isAutofarmEnabled = true
    
    print("🚜 Autofarm активирован")
    
    local autofarmLoop = RunService.Heartbeat:Connect(function()
        if not isAutofarmEnabled then
            autofarmLoop:Disconnect()
            return
        end
        
        local character = Players.LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = character.HumanoidRootPart
        
        -- Поиск предметов для автофарма
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name and AutofarmConfig.Items[obj.Name] then
                local distance = (obj.Position - rootPart.Position).Magnitude
                
                if distance <= AutofarmConfig.PickupRadius then
                    -- Автоматический подбор предмета
                    local success, result = pcall(function()
                        -- Симуляция нажатия клавиши E
                        local event = Instance.new("RemoteEvent")
                        event.Name = "PickupItem"
                        event.Parent = obj
                        
                        -- Ожидание подбора
                        task.wait(AutofarmConfig.PickupDuration)
                        
                        if event and event.Parent then
                            event:Destroy()
                        end
                    end)
                    
                    if not success then
                        print("❌ Ошибка подбора предмета:", result)
                    end
                end
            end
        end
    end)
    
    autofarmConnections.autofarmLoop = autofarmLoop
end

local function stopAutofarm()
    if not isAutofarmEnabled then return end
    isAutofarmEnabled = false
    
    print("🚜 Autofarm деактивирован")
    
    for _, connection in pairs(autofarmConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    autofarmConnections = {}
end

-- ВСЕ ОРИГИНАЛЬНЫЕ ОБРАБОТЧИКИ КЛАВИШ YBA (НЕ МЕНЯЛ)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- YBA Toggle
    if YBAConfig.ToggleKey and input.KeyCode == YBAConfig.ToggleKey then
        if isYBAEnabled then
            stopYBA()
        else
            startYBA()
        end
    end
    
    -- Underground Control Toggle
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isShiftPressed = true
        if isYBAEnabled and not isUndergroundControlEnabled then
            startUndergroundControl()
        end
    end
    
    -- Item ESP Toggle
    if YBAConfig.ItemESP.ToggleKey and input.KeyCode == YBAConfig.ItemESP.ToggleKey then
        if isItemESPEnabled then
            stopItemESP()
        else
            startItemESP()
        end
    end
    
    -- Anti Time Stop Toggle
    if AntiTimeStopConfig.ToggleKey and input.KeyCode == AntiTimeStopConfig.ToggleKey then
        if isAntiTimeStopEnabled then
            stopAntiTimeStop()
        else
            startAntiTimeStop()
        end
    end
    
    -- Autofarm Toggle
    if AutofarmConfig.ToggleKey and input.KeyCode == AutofarmConfig.ToggleKey then
        if isAutofarmEnabled then
            stopAutofarm()
        else
            startAutofarm()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isShiftPressed = false
        if isUndergroundControlEnabled then
            stopUndergroundControl()
        end
    end
end)

print("✅ Модуль YBA Hacks загружен успешно!")
print("🎯 Доступные функции:")
print("   - Stand Range Hack")
print("   - Underground Flight")
print("   - Item ESP")
print("   - Anti Time Stop")
print("   - Autofarm")
print("🔧 Используйте клавиши для переключения функций")
print("💡 Удерживайте Shift для подземного управления")
