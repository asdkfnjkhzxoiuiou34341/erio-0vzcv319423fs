-- YBA HACKS MODULE
-- Этот модуль загружается только для YBA (ID: 2809202155)

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- YBA CONFIG
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

local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil
local isShiftPressed = false

-- YBA FREE CAMERA SYSTEM
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
                local sensitivity = 0.003
                input.MouseDelta = Vector2.new(inputObj.Delta.y * sensitivity, -inputObj.Delta.x * sensitivity)
            elseif inputObj.UserInputType == Enum.UserInputType.MouseWheel then
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
        
        if tick() - lastDebugTime > 5 then
            print("YBA Debug: Камера работает, позиция стенда:", standPosition)
            print("YBA Debug: Состояние ввода - W:", input.W, "A:", input.A, "S:", input.S, "D:", input.D, "Shift:", input.LeftShift)
            lastDebugTime = tick()
        end
        
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
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    print("YBA: Ввод заблокирован - чат в фокусе:", chatInFocus, "gameProcessed:", isInputBeingProcessedByGame)
                end
            end
        end)
        
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
        
        if move.Magnitude > 0 then
            local standSpeed = YBAConfig.UndergroundControl.FlightSpeed or 20
            local cameraCFrame = CFrame.new(standPosition) * CFrame.Angles(0, cameraRot.Y, 0)
            local worldMove = cameraCFrame:VectorToWorldSpace(move)
            bv.Velocity = worldMove * standSpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        
        if input.MouseDelta.Magnitude > 0 then
            cameraRot = cameraRot + input.MouseDelta
            cameraRot = Vector2.new(
                math.clamp(cameraRot.X, -math.pi/2 + 0.1, math.pi/2 - 0.1),
                cameraRot.Y % (math.pi * 2)
            )
            input.MouseDelta = Vector2.new(0, 0)
        end
        
        if input.MouseWheel ~= 0 then
            cameraDistance = math.clamp(cameraDistance - input.MouseWheel * 2, 3, 50)
            print("YBA: Изменена дистанция камеры:", cameraDistance)
            input.MouseWheel = 0
        end
        
        local cameraOffset = Vector3.new(
            math.sin(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance,
            math.sin(cameraRot.X) * cameraDistance + cameraHeight,
            math.cos(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance
        )
        
        local cameraPosition = standPosition + cameraOffset
        local lookDirection = (standPosition - cameraPosition).Unit
        
        Camera.CFrame = CFrame.lookAt(cameraPosition, cameraPosition + lookDirection)
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
        local standPosition = standRoot.Position
        
        if not standRoot:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = standRoot
        end
        
        cameraDistance = YBAConfig.CameraDistance or 12
        cameraHeight = YBAConfig.CameraHeight or 8
        
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
        
        print("YBA: Сохраняем оригинальный тип камеры для обхода античита")
        print("YBA: Текущий тип камеры:", Camera.CameraType)
        
        task.wait(0.1)
        
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerCFrame = player.Character.HumanoidRootPart.CFrame
            stand.Root.CFrame = CFrame.new(standPosition, standPosition + playerCFrame.LookVector)
            print("YBA: Стенд повернут в направлении игрока")
        end
        
        local cameraOffset = Vector3.new(
            math.sin(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance,
            cameraHeight,
            math.cos(cameraRot.Y) * math.cos(cameraRot.X) * cameraDistance
        )
        local initialCameraPosition = standPosition + cameraOffset
        Camera.CFrame = CFrame.lookAt(initialCameraPosition, standPosition)
        print("YBA: Установлена начальная позиция камеры:", initialCameraPosition)
        
        print("YBA: Запускаем систему ввода...")
        startInput()
        print("YBA: Подключаем рендер...")
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
        
        stopInput()
        
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
        
        if targetStand and targetStand.Root then
            local bv = targetStand.Root:FindFirstChild("BodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
        
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

-- YBA FUNCTIONS
local function findStands()
    local stands = {}
    local player = Players.LocalPlayer
    local playerChar = player.Character
    
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        return stands
    end
    
    local playerPosition = playerChar.HumanoidRootPart.Position
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Stand") and obj ~= playerChar then
            local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (playerPosition - humanoidRootPart.Position).Magnitude
                if distance <= YBAConfig.StandRange then
                    table.insert(stands, {
                        Name = obj.Name,
                        Model = obj,
                        Root = humanoidRootPart,
                        Distance = distance
                    })
                end
            end
        end
    end
    
    table.sort(stands, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return stands
end

local function activateFreeCamera(stand)
    if not stand or not stand.Root then
        print("YBA: Ошибка - стенд не найден для активации свободной камеры")
        return false
    end
    
    print("YBA: Активируем свободную камеру для стенда: " .. stand.Name)
    controlledStand = stand
    
    if YBAFreeCamera.Start(stand) then
        print("YBA: Свободная камера активирована для стенда: " .. stand.Name)
        return true
    else
        print("YBA: Не удалось активировать свободную камеру для стенда: " .. stand.Name)
        return false
    end
end

local function disableFreeCamera()
    if controlledStand then
        print("YBA: Отключаем свободную камеру для стенда: " .. controlledStand.Name)
        YBAFreeCamera.Stop()
        controlledStand = nil
    end
end

local function freezePlayer()
    local player = Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid and humanoidRootPart then
        originalYBAWalkSpeed = humanoid.WalkSpeed
        originalYBAJumpPower = humanoid.JumpPower
        
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        
        humanoidRootPart.Anchored = true
        originalPlayerPosition = humanoidRootPart.Position
        originalPlayerCFrame = humanoidRootPart.CFrame
        
        print("YBA: Игрок заморожен")
    end
end

local function unfreezePlayer()
    local player = Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid and humanoidRootPart then
        humanoid.WalkSpeed = originalYBAWalkSpeed
        humanoid.JumpPower = originalYBAJumpPower
        
        humanoidRootPart.Anchored = false
        
        print("YBA: Игрок разморожен")
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
    
    local player = Players.LocalPlayer
    if targetStand.Root and targetStand.Model then
        print("YBA: Отсоединяем стенд от игрока...")
        
        local humanoid = targetStand.Model:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Sit = false
            humanoid.Jump = false
            humanoid.AutoRotate = false
        end
        
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
                print("YBA: Найдена привязка:", child.Name, child.ClassName)
                if child.Name == "StandAttach" or child.Name == "RootRigAttachment" then
                    print("YBA: Удаляем подозрительную привязку:", child.Name)
                    child:Destroy()
                    connectionsRemoved = connectionsRemoved + 1
                end
            end
        end
        
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
                        print("YBA: Удаляем ограничение из части", part.Name, ":", child.Name, child.ClassName)
                        child:Destroy()
                        connectionsRemoved = connectionsRemoved + 1
                    end
                end
            end
        end
        
        print("YBA: Удалено связей с игроком:", connectionsRemoved)
        
        if targetStand.Model.Parent ~= workspace then
            print("YBA: Перемещаем стенд в workspace из", targetStand.Model.Parent.Name)
            targetStand.Model.Parent = workspace
        end
        
        targetStand.Root.CanCollide = false
        targetStand.Root.Anchored = false
        
        for _, child in pairs(targetStand.Root:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("BodyAngularVelocity") then
                print("YBA: Удаляем Body объект:", child.Name, child.ClassName)
                child:Destroy()
                connectionsRemoved = connectionsRemoved + 1
            end
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerRoot = player.Character.HumanoidRootPart
            local standPosition = playerRoot.Position + playerRoot.CFrame.LookVector * 5
            targetStand.Root.CFrame = CFrame.new(standPosition, playerRoot.Position)
            targetStand.Root.Anchored = false
            
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

-- UNDERGROUND CONTROL
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
    
         if YBAConfig.UndergroundControl.AutoNoClip and _G.startNoClip then
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
    
    root.CFrame = CFrame.new(undergroundPos)
    root.Anchored = false
    
    print("Персонаж перемещен под землю на позицию:", undergroundPos)
    print("Подземный полет активирован! Используйте WASD для управления")
end

local function stopUndergroundControl()
    if not isUndergroundControlEnabled then return end
    
    print("=== ОСТАНОВКА ПОДЗЕМНОГО ПОЛЕТА ===")
    isUndergroundControlEnabled = false
    
    local plr = Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        hum.JumpPower = 50
        hum.JumpHeight = 7.2
        workspace.Gravity = 196.2
        hum.HipHeight = 0
    end
    
    if YBAConfig.UndergroundControl.OriginalPosition and root then
        root.CFrame = CFrame.new(YBAConfig.UndergroundControl.OriginalPosition)
        YBAConfig.UndergroundControl.OriginalPosition = nil
        print("Персонаж возвращен на исходную позицию")
    end
    
    for _, connection in ipairs(undergroundControlConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    undergroundControlConnections = {}
    controlledStandForUnderground = nil
    
         if _G.stopNoClip then
         _G.stopNoClip()
         print("NoClip отключен")
     end
    
    print("Подземный полет деактивирован")
end

-- ANTI TIME STOP
local function startAntiTimeStop()
    if isAntiTimeStopEnabled then
        print("Anti TS: Уже активен!")
        return
    end
    
    print("Anti TS: Активируем защиту от остановки времени...")
    isAntiTimeStopEnabled = true
    
    local player = Players.LocalPlayer
    local character = player.Character
    
    if not character then
        print("Anti TS: Персонаж не найден!")
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then
        print("Anti TS: Компоненты персонажа не найдены!")
        return
    end
    
    originalAntiTimeStopWalkSpeed = humanoid.WalkSpeed
    originalAntiTimeStopJumpPower = humanoid.JumpPower
    
    print("Anti TS: Ищем стенды для освобождения...")
    
    local myStand = nil
    
    print("Anti TS: Ищем твой стенд...")
    print("Anti TS: Range Hack активен?", isYBAEnabled)
    
    local stands = findStands()
    if #stands > 0 then
        myStand = stands[1]
        print("Anti TS: Найден стенд:", myStand.Name, "Distance:", myStand.Distance)
    else
        print("Anti TS: Стенды не найдены, попробуем найти через workspace...")
        
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("Stand") then
                local standRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Root")
                if standRoot then
                    local distance = (humanoidRootPart.Position - standRoot.Position).Magnitude
                    if distance < 1000 then
                        myStand = {
                            Name = obj.Name,
                            Model = obj,
                            Root = standRoot,
                            Distance = distance
                        }
                        print("Anti TS: Найден стенд через workspace:", myStand.Name, "Distance:", distance)
                        break
                    end
                end
            end
        end
    end
    
    if not myStand then
        print("Anti TS: СТЕНД НЕ НАЙДЕН! Освобождение может не сработать.")
        return
    end
    
    print("Anti TS: Начинаем освобождение...")
    
    local standRoot = myStand.Root
    local originalStandPos = standRoot.Position
    
    for i = 1, 10 do
        standRoot.CFrame = CFrame.new(originalStandPos + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)))
        
        humanoid.WalkSpeed = AntiTimeStopConfig.WalkSpeed
        humanoid.JumpPower = AntiTimeStopConfig.JumpPower
        
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 0.1, 0)
        
        task.wait(0.01)
    end
    
    standRoot.CFrame = CFrame.new(originalStandPos)
    
    print("Anti TS: Освобождение завершено!")
end

local function stopAntiTimeStop()
    if not isAntiTimeStopEnabled then return end
    
    print("Anti TS: Отключаем защиту...")
    isAntiTimeStopEnabled = false
    
    local player = Players.LocalPlayer
    local character = player.Character
    
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = originalAntiTimeStopWalkSpeed
            humanoid.JumpPower = originalAntiTimeStopJumpPower
        end
    end
    
    for _, connection in ipairs(antiTimeStopConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    antiTimeStopConnections = {}
    
    print("Anti TS: Защита отключена")
end

-- ITEM ESP
local itemESPElements = {}
local itemESPConnection = nil
local itemESPUpdateConnection = nil
local lastItemESPUpdate = 0

local function createItemESP(item)
    if not item or not item.Parent or not YBAConfig.ItemESP.Enabled then return end
    
    local itemName = item.Name
    if not YBAConfig.ItemESP.Items[itemName] then return end
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local playerPosition = character.HumanoidRootPart.Position
    local itemPosition = item.Position
    local distance = (playerPosition - itemPosition).Magnitude
    
    if distance > YBAConfig.ItemESP.MaxDistance then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ItemESP_" .. itemName
    billboardGui.Adornee = item
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = item
    
    if YBAConfig.ItemESP.ShowFill then
        local fillFrame = Instance.new("Frame", billboardGui)
        fillFrame.Size = UDim2.new(1, 0, 1, 0)
        fillFrame.BackgroundColor3 = YBAConfig.ItemESP.FillColor
        fillFrame.BackgroundTransparency = YBAConfig.ItemESP.FillTransparency
        fillFrame.BorderSizePixel = 0
        
        local fillCorner = Instance.new("UICorner", fillFrame)
        fillCorner.CornerRadius = UDim.new(0, 4)
    end
    
    if YBAConfig.ItemESP.ShowOutline then
        local outlineFrame = Instance.new("Frame", billboardGui)
        outlineFrame.Size = UDim2.new(1, 0, 1, 0)
        outlineFrame.BackgroundTransparency = 1
        outlineFrame.BorderSizePixel = 0
        
        local outlineStroke = Instance.new("UIStroke", outlineFrame)
        outlineStroke.Color = YBAConfig.ItemESP.OutlineColor
        outlineStroke.Transparency = YBAConfig.ItemESP.OutlineTransparency
        outlineStroke.Thickness = 2
        
        local outlineCorner = Instance.new("UICorner", outlineFrame)
        outlineCorner.CornerRadius = UDim.new(0, 4)
    end
    
    if YBAConfig.ItemESP.ShowText then
        local textLabel = Instance.new("TextLabel", billboardGui)
        textLabel.Size = UDim2.new(1, 0, 0.7, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = itemName
        textLabel.TextColor3 = YBAConfig.ItemESP.TextColor
        textLabel.TextScaled = true
        textLabel.Font = YBAConfig.ItemESP.Font
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        
        local distanceLabel = Instance.new("TextLabel", billboardGui)
        distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = math.floor(distance) .. "m"
        distanceLabel.TextColor3 = YBAConfig.ItemESP.TextColor
        distanceLabel.TextScaled = true
        distanceLabel.Font = YBAConfig.ItemESP.Font
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    end
    
    itemESPElements[item] = {
        gui = billboardGui,
        itemName = itemName,
        lastUpdate = tick()
    }
end

local function removeItemESP(item)
    local espData = itemESPElements[item.Object or item]
    if espData and espData.gui then
        espData.gui:Destroy()
        itemESPElements[item.Object or item] = nil
    end
end

local function findYBAItems()
    local items = {}
    local player = Players.LocalPlayer
    local playerChar = player.Character
    
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        return items
    end
    
    local playerPosition = playerChar.HumanoidRootPart.Position
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and YBAConfig.ItemESP.Items[obj.Name] then
            local distance = (playerPosition - obj.Position).Magnitude
            if distance <= YBAConfig.ItemESP.MaxDistance then
                table.insert(items, {
                    Object = obj,
                    Name = obj.Name,
                    Position = obj.Position,
                    Distance = distance
                })
            end
        elseif obj:IsA("Model") then
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("BasePart") and YBAConfig.ItemESP.Items[child.Name] then
                    local distance = (playerPosition - child.Position).Magnitude
                    if distance <= YBAConfig.ItemESP.MaxDistance then
                        table.insert(items, {
                            Object = child,
                            Name = child.Name,
                            Position = child.Position,
                            Distance = distance
                        })
                    end
                end
            end
        end
    end
    
    return items
end

local function updateItemESP()
    if not YBAConfig.ItemESP.Enabled then return end
    
    local currentTime = tick()
    if currentTime - lastItemESPUpdate < YBAConfig.ItemESP.UpdateInterval then
        return
    end
    lastItemESPUpdate = currentTime
    
    local items = findYBAItems()
    local activeItems = {}
    
    for _, itemData in ipairs(items) do
        activeItems[itemData.Object] = true
        if not itemESPElements[itemData.Object] then
            createItemESP(itemData.Object)
        end
    end
    
    for item, espData in pairs(itemESPElements) do
        if not activeItems[item] or not item.Parent then
            removeItemESP({Object = item})
        end
    end
end

local function startItemESP()
    if itemESPConnection then return end
    
    print("YBA Item ESP: Запуск...")
    YBAConfig.ItemESP.Enabled = true
    
    itemESPUpdateConnection = RunService.Heartbeat:Connect(updateItemESP)
    
    print("YBA Item ESP: Активирован")
end

local function stopItemESP()
    if not itemESPConnection and not itemESPUpdateConnection then return end
    
    print("YBA Item ESP: Остановка...")
    YBAConfig.ItemESP.Enabled = false
    
    if itemESPConnection then
        itemESPConnection:Disconnect()
        itemESPConnection = nil
    end
    
    if itemESPUpdateConnection then
        itemESPUpdateConnection:Disconnect()
        itemESPUpdateConnection = nil
    end
    
    for item, espData in pairs(itemESPElements) do
        if espData.gui then
            espData.gui:Destroy()
        end
    end
    itemESPElements = {}
    
    print("YBA Item ESP: Деактивирован")
end

-- USER STAND ESP
local userStandESPElements = {}
local userStandESPConnection = nil

local function createUserStandESP(stand)
    if not stand or not stand.Parent then return end
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local standRoot = stand:FindFirstChild("HumanoidRootPart") or stand:FindFirstChild("Root")
    if not standRoot then return end
    
    local playerPosition = character.HumanoidRootPart.Position
    local standPosition = standRoot.Position
    local distance = (playerPosition - standPosition).Magnitude
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "UserStandESP_" .. stand.Name
    billboardGui.Adornee = standRoot
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = standRoot
    
    local fillFrame = Instance.new("Frame", billboardGui)
    fillFrame.Size = UDim2.new(1, 0, 1, 0)
    fillFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    fillFrame.BackgroundTransparency = 0.5
    fillFrame.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner", fillFrame)
    fillCorner.CornerRadius = UDim.new(0, 4)
    
    local textLabel = Instance.new("TextLabel", billboardGui)
    textLabel.Size = UDim2.new(1, 0, 0.7, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = stand.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    local distanceLabel = Instance.new("TextLabel", billboardGui)
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = math.floor(distance) .. "m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    userStandESPElements[stand] = {
        gui = billboardGui,
        lastUpdate = tick()
    }
end

local function startUserStandESP()
    if userStandESPConnection then return end
    
    print("User Stand ESP: Запуск...")
    
    userStandESPConnection = RunService.Heartbeat:Connect(function()
        local player = Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("Stand") and obj ~= character then
                if not userStandESPElements[obj] then
                    createUserStandESP(obj)
                end
            end
        end
        
        for stand, espData in pairs(userStandESPElements) do
            if not stand.Parent then
                if espData.gui then
                    espData.gui:Destroy()
                end
                userStandESPElements[stand] = nil
            end
        end
    end)
    
    print("User Stand ESP: Активирован")
end

local function stopUserStandESP()
    if not userStandESPConnection then return end
    
    print("User Stand ESP: Остановка...")
    
    userStandESPConnection:Disconnect()
    userStandESPConnection = nil
    
    for stand, espData in pairs(userStandESPElements) do
        if espData.gui then
            espData.gui:Destroy()
        end
    end
    userStandESPElements = {}
    
    print("User Stand ESP: Деактивирован")
end

-- USER STYLE ESP
local userStyleESPElements = {}
local userStyleESPConnection = nil

local function createUserStyleESP(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "UserStyleESP_" .. player.Name
    billboardGui.Adornee = humanoidRootPart
    billboardGui.Size = UDim2.new(0, 200, 0, 30)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = humanoidRootPart
    
    local fillFrame = Instance.new("Frame", billboardGui)
    fillFrame.Size = UDim2.new(1, 0, 1, 0)
    fillFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fillFrame.BackgroundTransparency = 0.5
    fillFrame.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner", fillFrame)
    fillCorner.CornerRadius = UDim.new(0, 4)
    
    local textLabel = Instance.new("TextLabel", billboardGui)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Style: Unknown"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    userStyleESPElements[player] = {
        gui = billboardGui,
        lastUpdate = tick()
    }
end

local function startUserStyleESP()
    if userStyleESPConnection then return end
    
    print("User Style ESP: Запуск...")
    
    userStyleESPConnection = RunService.Heartbeat:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                if not userStyleESPElements[player] then
                    createUserStyleESP(player)
                end
            end
        end
        
        for player, espData in pairs(userStyleESPElements) do
            if not player.Character or not player.Character.Parent then
                if espData.gui then
                    espData.gui:Destroy()
                end
                userStyleESPElements[player] = nil
            end
        end
    end)
    
    print("User Style ESP: Активирован")
end

local function stopUserStyleESP()
    if not userStyleESPConnection then return end
    
    print("User Style ESP: Остановка...")
    
    userStyleESPConnection:Disconnect()
    userStyleESPConnection = nil
    
    for player, espData in pairs(userStyleESPElements) do
        if espData.gui then
            espData.gui:Destroy()
        end
    end
    userStyleESPElements = {}
    
    print("User Style ESP: Деактивирован")
end

-- AUTOFARM
local isAutofarmEnabled = false
local autofarmConnections = {}
local autofarmCurrentTarget = nil
local autofarmPickingUp = false

local function processNextItem()
    if not isAutofarmEnabled then return end
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local playerPosition = character.HumanoidRootPart.Position
    local closestItem = nil
    local closestDistance = math.huge
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and AutofarmConfig.Items[obj.Name] then
            local distance = (playerPosition - obj.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestItem = obj
            end
        elseif obj:IsA("Model") then
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("BasePart") and AutofarmConfig.Items[child.Name] then
                    local distance = (playerPosition - child.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestItem = child
                    end
                end
            end
        end
    end
    
    if closestItem then
        autofarmCurrentTarget = closestItem
        print("🤖 AUTOFARM: Движемся к предмету:", closestItem.Name, "Distance:", math.floor(closestDistance))
        
        character.HumanoidRootPart.CFrame = CFrame.new(closestItem.Position + Vector3.new(0, 5, 0))
        
        task.wait(AutofarmConfig.PickupDuration)
        
        if autofarmCurrentTarget and autofarmCurrentTarget.Parent then
            print("🤖 AUTOFARM: Подбираем предмет:", closestItem.Name)
            
            game:GetService("VirtualInputManager"):SendKeyEvent(true, AutofarmConfig.PickupKey, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, AutofarmConfig.PickupKey, false, game)
        end
        
        autofarmCurrentTarget = nil
        task.wait(1)
        
        if isAutofarmEnabled then
            processNextItem()
        end
    else
        print("🤖 AUTOFARM: Предметы не найдены, ожидаем...")
        task.wait(AutofarmConfig.ScanInterval)
        if isAutofarmEnabled then
            processNextItem()
        end
    end
end

local function startAutofarm()
    if isAutofarmEnabled then return end
    
    print("🤖 AUTOFARM: Запуск автофарма...")
    isAutofarmEnabled = true
    
    task.spawn(processNextItem)
    
    print("🤖 AUTOFARM: Автофарм активирован")
end

local function stopAutofarm()
    if not isAutofarmEnabled then return end
    
    print("🤖 AUTOFARM: Остановка автофарма...")
    isAutofarmEnabled = false
    autofarmCurrentTarget = nil
    autofarmPickingUp = false
    
    for _, connection in ipairs(autofarmConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    autofarmConnections = {}
    
    print("🤖 AUTOFARM: Автофарм деактивирован")
end

-- СОЗДАНИЕ YBA ИНТЕРФЕЙСА
local function createYBAInterface(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton, getText, padding)
    print("YBA HACKS: Создание интерфейса...")
    
    -- 🎯 STAND RANGE заголовок
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
     ybaNoClipStatusLabel.Text = "NoClip Status: OFF"
     ybaNoClipStatusLabel.Font = Enum.Font.GothamBold
     ybaNoClipStatusLabel.TextSize = 12
     ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
     ybaNoClipStatusLabel.BackgroundTransparency = 1
     ybaNoClipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
     currentY = currentY + 20 + padding
    
         local ybaNoClipToggle = createToggleSlider(getText("ForceNoClip"), false, function(v)
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
            
            spawn(function()
                task.wait(0.1)
                
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
            
            if not v then
                print("YBA Item ESP: Удаляем все ESP для отключенного предмета:", itemName)
                for obj, esp in pairs(itemESPElements) do
                    if esp and esp.itemName == itemName then
                        print("YBA Item ESP: Удаляем ESP элемент для:", itemName)
                        pcall(removeItemESP, {Object = obj})
                    end
                end
            else
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
    
    createToggleSlider("Autofarm", isAutofarmEnabled, function(v)
        if v then
            startAutofarm()
        else
            stopAutofarm()
        end
    end)
    
    createSectionHeader("📦 ITEMS FARM")
    
    local function createAutofarmItemToggle(itemName, defaultState)
        local btn = createToggleSlider(itemName, defaultState, function(v)
            AutofarmConfig.Items[itemName] = v
            
            if itemName == "MysteriousArrow" or itemName == "Mysterious Arrow" or itemName == "Таинственная стрела" then
                AutofarmConfig.Items["Mysterious Arrow"] = v
                AutofarmConfig.Items["MysteriousArrow"] = v
            elseif itemName == "GoldCoin" or itemName == "Gold Coin" or itemName == "Золотая монета" then
                AutofarmConfig.Items["Gold Coin"] = v
                AutofarmConfig.Items["GoldCoin"] = v
            end
            
            print("🤖 AUTOFARM: Предмет", itemName, "установлен в", v and "ON" or "OFF")
            
            if isAutofarmEnabled then
                if autofarmCurrentTarget and autofarmCurrentTarget.Name == itemName and not v then
                    print("🤖 AUTOFARM: Прерываем движение к предмету", itemName, "- он был отключен в настройках")
                    autofarmCurrentTarget = nil
                    autofarmPickingUp = false
                    
                    pcall(function()
                        if game:GetService("VirtualInputManager") then
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, AutofarmConfig.PickupKey, false, game)
                        end
                        game:GetService("UserInputService").InputEnded:Fire(
                            {KeyCode = AutofarmConfig.PickupKey, UserInputType = Enum.UserInputType.Keyboard},
                            false
                        )
                    end)
                    
                    for _, connection in ipairs(autofarmConnections) do
                        if connection then
                            pcall(function() connection:Disconnect() end)
                        end
                    end
                    autofarmConnections = {}
                    
                    task.spawn(function()
                        task.wait(0.1)
                        if isAutofarmEnabled then
                            processNextItem()
                        end
                    end)
                end
            end
        end)
        return btn
    end
    
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
    
    print("YBA HACKS: Интерфейс создан успешно!")
    return currentY
end

-- ЭКСПОРТ МОДУЛЯ
print("YBA HACKS MODULE: Загружен успешно!")

return {
    -- Configs
    YBAConfig = YBAConfig,
    AntiTimeStopConfig = AntiTimeStopConfig,
    AutofarmConfig = AutofarmConfig,
    
    -- Main functions
    startYBA = startYBA,
    stopYBA = stopYBA,
    startUndergroundControl = startUndergroundControl,
    stopUndergroundControl = stopUndergroundControl,
    startAntiTimeStop = startAntiTimeStop,
    stopAntiTimeStop = stopAntiTimeStop,
    startItemESP = startItemESP,
    stopItemESP = stopItemESP,
    startUserStandESP = startUserStandESP,
    stopUserStandESP = stopUserStandESP,
    startUserStyleESP = startUserStyleESP,
    stopUserStyleESP = stopUserStyleESP,
    startAutofarm = startAutofarm,
    stopAutofarm = stopAutofarm,
    
    -- Utility functions
    findStands = findStands,
    findYBAItems = findYBAItems,
    
    -- Interface creation
    createYBAInterface = createYBAInterface,
    
    -- Variables
    isYBAEnabled = function() return isYBAEnabled end,
    isUndergroundControlEnabled = function() return isUndergroundControlEnabled end,
    isAntiTimeStopEnabled = function() return isAntiTimeStopEnabled end,
    isAutofarmEnabled = function() return isAutofarmEnabled end,
}