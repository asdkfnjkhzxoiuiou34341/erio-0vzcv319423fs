-- YBA Hacks Module
-- Этот модуль содержит все функции, связанные с Your Bizarre Adventure

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- YBA Configuration
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
        ShowFill = true,
        ShowText = true,
        FillColor = Color3.fromRGB(255, 255, 0),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextBackgroundColor = Color3.fromRGB(0, 0, 0),
        FillTransparency = 0.7,
        OutlineTransparency = 0,
        TextBackgroundTransparency = 0.5,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        DistanceTextSize = 10,
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
            ["Quinton's Glove"] = true,
            ["Stone Mask"] = true,
            ["Rib Cage of The Saint's Corpse"] = true,
            ["Ancient Scroll"] = true,
            ["DIO's Diary"] = true,
            ["Lucky Stone Mask"] = true,
            ["Lucky Arrow"] = true,
        }
    }
}

local AntiTimeStopConfig = {
    Enabled = false,
    ToggleKey = nil,
    WalkSpeed = 100,
    JumpPower = 100,
    MovementSpeed = 2.0,
    AntiFreeze = true,
    MovementOverride = true,
    SoundEffect = true,
    VisualEffect = true,
    DamageProtection = false,
    ServerSync = false,
    AttackDetection = true,
    HealthProtection = false,
}

-- Autofarm Configuration
local AutofarmConfig = {
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
        ["Quinton's Glove"] = true,
        ["Stone Mask"] = true,
        ["Rib Cage of The Saint's Corpse"] = true,
        ["Ancient Scroll"] = true,
        ["DIO's Diary"] = true,
        ["Lucky Stone Mask"] = true,
        ["Lucky Arrow"] = true,
    },
    PickupKey = Enum.KeyCode.E,
    PickupDuration = 3.0,
    PickupRadius = 8,
    FlightSpeed = 80,
    UseFlightMovement = true,
    UseNoClipMovement = true,
    MaxPickupAttempts = 3,
    InactivityTimeout = 60,
    RespawnRetryDelay = 5,
    AutoRestart = true,
    DebugMode = false,
    CheckInterval = 1.0,
    MovementSmoothness = 0.1,
    CollisionAvoidance = true,
}

-- YBA Variables
local isYBAEnabled = false
local ybaConnections = {}
local controlledStand = nil
local targetStands = {}
local currentStandIndex = 1
local lastStandCheck = 0
local standCheckInterval = 2
local originalYBAWalkSpeed = 16
local originalYBAJumpPower = 50

-- Underground Control Variables
local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil

-- Anti-Time Stop Variables
local isAntiTimeStopEnabled = false
local antiTimeStopConnections = {}
local originalAntiTimeStopWalkSpeed = 16
local originalAntiTimeStopJumpPower = 50
local timeStopDetected = false
local timeStopStart = 0
local antiTimeStopEffect = nil

-- Autofarm Variables
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
local autofarmStuckCheckTimer = 0
local autofarmLastPosition = nil
local wasAutofarmEnabledBeforeDeath = false

-- ESP Variables
local itemESPElements = {}
local itemESPConnection = nil
local userStandESP = {}
local userStyleESP = {}

-- Item Names
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
    ["Quinton's Glove"] = true,
    ["Stone Mask"] = true,
    ["Rib Cage of The Saint's Corpse"] = true,
    ["Ancient Scroll"] = true,
    ["DIO's Diary"] = true,
    ["Lucky Stone Mask"] = true,
    ["Lucky Arrow"] = true,
}

-- YBA Free Camera System
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
        for _, connection in pairs(inputConnections) do
            if connection then connection:Disconnect() end
        end
        inputConnections = {}

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
    end

    local function stopInput()
        for _, connection in pairs(inputConnections) do
            if connection then connection:Disconnect() end
        end
        inputConnections = {}
        
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
        
        if tick() - lastDebugTime > 5 then
            print("YBA Debug: Камера работает, позиция стенда:", standPosition)
            print("YBA Debug: Состояние ввода - W:", input.W, "A:", input.A, "S:", input.S, "D:", input.D, "Shift:", input.LeftShift)
            lastDebugTime = tick()
        end

        local moveX = 0
        local moveZ = 0 
        local moveY = 0
        
        local gameGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
        local chatInFocus = false
        
        if gameGui then
            local chatGui = gameGui:FindFirstChild("Chat")
            if chatGui and chatGui:FindFirstChild("Frame") and chatGui.Frame:FindFirstChild("ChatBarParentFrame") then
                local chatBar = chatGui.Frame.ChatBarParentFrame:FindFirstChild("Frame")
                if chatBar and chatBar:FindFirstChild("BoxFrame") and chatBar.BoxFrame:FindFirstChild("Frame") and chatBar.BoxFrame.Frame:FindFirstChild("ChatBar") then
                    chatInFocus = chatBar.BoxFrame.Frame.ChatBar:IsFocused()
                end
            end
            
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
            if chatInFocus or isInputBeingProcessedByGame then
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    print("YBA: Ввод заблокирован - чат в фокусе:", chatInFocus, "gameProcessed:", isInputBeingProcessedByGame)
                end
            end
        end
        
        input.LeftShift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        
        local move = Vector3.new(moveX, moveY, moveZ)
        
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
            bav.MaxTorque = Vector3.new(0, 4000, 0)
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

        if input.MouseDelta.Magnitude > 0 then
            cameraRot = cameraRot + input.MouseDelta
            cameraRot = Vector2.new(
                math.clamp(cameraRot.X, -math.rad(80), math.rad(80)), 
                cameraRot.Y % (2 * math.pi)
            )
            
            local player = Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerRoot = player.Character.HumanoidRootPart
                local targetPlayerCFrame = CFrame.new(playerRoot.Position) * CFrame.Angles(0, cameraRot.Y, 0)
                playerRoot.CFrame = targetPlayerCFrame
            end
            
            input.MouseDelta = Vector2.new()
        end
        
        local currentPos = standRoot.Position
        local currentCFrame = standRoot.CFrame
        local targetCFrame = CFrame.new(currentPos) * CFrame.Angles(0, cameraRot.Y, 0)
        standRoot.CFrame = currentCFrame:Lerp(targetCFrame, 0.2)
        
        if input.LeftShift then
            standRoot.CFrame = currentCFrame:Lerp(targetCFrame, 0.5)
        end

        if input.MouseWheel ~= 0 then
            cameraDistance = math.clamp(cameraDistance + input.MouseWheel * 2, 5, 30)
            input.MouseWheel = 0
        end

        local horizontalDistance = cameraDistance
        local verticalOffset = cameraHeight
        
        local pitchOffset = math.sin(cameraRot.X) * cameraDistance
        local adjustedHorizontalDistance = math.cos(cameraRot.X) * cameraDistance
        
        local cameraOffset = Vector3.new(
            math.sin(cameraRot.Y) * adjustedHorizontalDistance,
            verticalOffset + pitchOffset,
            math.cos(cameraRot.Y) * adjustedHorizontalDistance
        )
        
        local cameraPosition = standPosition + cameraOffset
        local newCameraCFrame = CFrame.lookAt(cameraPosition, standPosition)
        
        Camera.CFrame = newCameraCFrame
        
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
        
        for _, bodyObj in pairs(stand.Root:GetChildren()) do
            if bodyObj:IsA("BodyVelocity") or bodyObj:IsA("BodyPosition") or bodyObj:IsA("BodyGyro") then
                bodyObj:Destroy()
            end
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
        local standPosition = stand.Root.Position
        
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerCFrame = player.Character.HumanoidRootPart.CFrame
            stand.Root.CFrame = CFrame.new(standPosition, standPosition + playerCFrame.LookVector)
            print("YBA: Стенд повернут в направлении игрока")
        end
        
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
        
        if originalCameraType then
            Camera.CameraType = originalCameraType
        else
            Camera.CameraType = Enum.CameraType.Custom
        end
        
        if originalCameraCFrame then
            Camera.CFrame = originalCameraCFrame
        end

        if targetStand and targetStand.Root and targetStand.Root.Parent then
            for _, bodyObj in pairs(targetStand.Root:GetChildren()) do
                if bodyObj:IsA("BodyVelocity") or bodyObj:IsA("BodyPosition") or bodyObj:IsA("BodyGyro") then
                    bodyObj:Destroy()
                end
            end
            targetStand.Root.Velocity = Vector3.new(0, 0, 0)
            if targetStand.Root.AssemblyLinearVelocity then
                targetStand.Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end

        local player = Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
        
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

-- Экспорт модуля
local YBAModule = {}
YBAModule.YBAConfig = YBAConfig
YBAModule.AntiTimeStopConfig = AntiTimeStopConfig
YBAModule.AutofarmConfig = AutofarmConfig
YBAModule.YBAFreeCamera = YBAFreeCamera

-- Возвращаем модуль
return YBAModule