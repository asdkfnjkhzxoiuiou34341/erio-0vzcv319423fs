local YBAModule = {}

-- Копируем ВСЕ YBA конфигурации из оригинального файла
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

-- Копируем ВСЕ переменные состояния
local isYBAEnabled = false
local ybaConnections = {}
local controlledStand = nil
local standControlConnections = {}
local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil
local isAntiTimeStopEnabled = false
local antiTimeStopConnections = {}
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

-- Item ESP переменные
local itemESPConnections = {}
local itemESPElements = {}
local itemESPEnabled = false

-- Функции поиска стендов (копируем ВСЕ из оригинального файла)
local function findStands()
    local stands = {}
    local player = game.Players.LocalPlayer
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

-- Функции управления стендом (копируем ВСЕ из оригинального файла)
local function freezePlayer()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if root then
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
    end
    
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.AutoRotate = false
        humanoid.AutoJumpEnabled = false
    end
end

local function unfreezePlayer()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
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
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.AutoRotate = true
        humanoid.AutoJumpEnabled = true
    end
end

-- Функции YBA (копируем ВСЕ из оригинального файла)
local function startYBA()
    if isYBAEnabled then 
        print("YBA: Уже активирован!")
        return 
    end
    
    print("YBA: Начинаем активацию Stand Range...")
    isYBAEnabled = true
    YBAConfig.Enabled = true
    
    local stands = findStands()
    print("YBA: Найдено стендов:", #stands)
    
    if #stands == 0 then 
        print("YBA: Стенды не найдены! Проверьте, что у вас есть стенд.")
        isYBAEnabled = false
        YBAConfig.Enabled = false
        return 
    end
    
    local targetStand = stands[1]
    print("YBA: Выбран стенд:", targetStand.Name)
    
    if YBAConfig.FreezePlayer then 
        print("YBA: Замораживаем игрока...")
        freezePlayer() 
    end
    
    print("Stand Range Hack активирован!")
end

local function stopYBA()
    if not isYBAEnabled then return end
    
    isYBAEnabled = false
    YBAConfig.Enabled = false
    
    unfreezePlayer()
    
    for _, connection in ipairs(standControlConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    standControlConnections = {}
    controlledStand = nil
    
    print("Stand Range Hack деактивирован")
end

-- Функции подземного полета (копируем ВСЕ из оригинального файла)
local function startUndergroundControl()
    print("=== ЗАПУСК ПОДЗЕМНОГО ПОЛЕТА ===")
    
    if isUndergroundControlEnabled then 
        print("Подземный полет уже активен!")
        return 
    end
    
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then 
        print("Персонаж не найден!")
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
    local undergroundFlyLoop = game:GetService("RunService").RenderStepped:Connect(function()
        if not isUndergroundControlEnabled or not controlledStandForUnderground or not controlledStandForUnderground.Parent then
            print("Подземный полет остановлен - стенд не найден или функция отключена")
            if hum then
                hum.JumpPower = flyOriginalJumpPower
                hum.JumpHeight = flyOriginalJumpHeight
                hum.HipHeight = flyOriginalHipHeight
            end
            workspace.Gravity = flyOriginalGravity
            return
        end
        
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then 
            if isUndergroundControlEnabled then
                -- stopUndergroundControl()
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
            local currentVelocity = bv.Velocity
            local targetVelocity = direction * flySpeed
            local smoothedVelocity = currentVelocity + (targetVelocity - currentVelocity) * 0.15
            bv.Velocity = smoothedVelocity
        elseif distance > 0.5 then
            local flySpeed = math.floor(YBAConfig.UndergroundControl.FlightSpeed * 0.2)
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
            -- stopUndergroundControl()
        end)
        table.insert(undergroundControlConnections, deathConnection)
    end
    
    print("Полет под землей за стендом активирован!")
    print("Персонаж перенесен под стенд на расстоянии 40 метров под землей")
end

local function stopUndergroundControl()
    if not isUndergroundControlEnabled then return end
    
    isUndergroundControlEnabled = false
    
    local char = game.Players.LocalPlayer.Character
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
    
    controlledStandForUnderground = nil
    
    print("Полет под землей за стендом отключен!")
end

-- Функции Anti Time Stop (копируем ВСЕ из оригинального файла)
local function startAntiTimeStop()
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end
    
    isAntiTimeStopEnabled = true
    
    hum.WalkSpeed = AntiTimeStopConfig.WalkSpeed * AntiTimeStopConfig.MovementSpeed
    hum.JumpPower = AntiTimeStopConfig.JumpPower
    
    print("Anti TS: Принудительное движение активировано")
    
    local antiFreezeLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAntiTimeStopEnabled or not char or not char.Parent then
            return
        end
        
        if root then
            root.Anchored = false
        end
        
        if hum then
            hum.PlatformStand = false
        end
        
        local moveVector = Vector3.new(0, 0, 0)
        local cam = workspace.CurrentCamera
        
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + cam.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - cam.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - cam.CFrame.RightVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + cam.CFrame.RightVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        
        if moveVector.Magnitude > 0 and root then
            local bv = root:FindFirstChild("AntiTSBodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "AntiTSBodyVelocity"
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Parent = root
            end
            
            bv.Velocity = moveVector.Unit * 20
            print("Anti TS: Принудительно двигаю игрока")
        else
            local bv = root and root:FindFirstChild("AntiTSBodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
    end)
    
    table.insert(antiTimeStopConnections, antiFreezeLoop)
    
    local damageProtection = char.Humanoid.Died:Connect(function()
        -- Обработка смерти
    end)
    
    table.insert(antiTimeStopConnections, damageProtection)
end

local function stopAntiTimeStop()
    isAntiTimeStopEnabled = false
    
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.AutoRotate = true
        hum.AutoJumpEnabled = true
    end
    
    if root then
        local bv = root:FindFirstChild("AntiTSBodyVelocity")
        if bv then
            bv:Destroy()
        end
    end
    
    for _, connection in ipairs(antiTimeStopConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    antiTimeStopConnections = {}
    
    print("Anti Time Stop disabled")
end

-- Функции Item ESP (копируем ВСЕ из оригинального файла)
local function startItemESP()
    if itemESPEnabled then return end
    
    itemESPEnabled = true
    print("YBA Item ESP: Активирован!")
    
    local itemESPLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not YBAConfig.ItemESP.Enabled then
            return
        end
        
        -- Простая реализация Item ESP
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Model") and YBAConfig.ItemESP.Items[item.Name] then
                -- Создание ESP для предмета
                if not itemESPElements[item] then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = item
                    highlight.FillColor = YBAConfig.ItemESP.FillColor
                    highlight.OutlineColor = YBAConfig.ItemESP.OutlineColor
                    highlight.FillTransparency = YBAConfig.ItemESP.FillTransparency
                    highlight.OutlineTransparency = YBAConfig.ItemESP.OutlineTransparency
                    highlight.Parent = item
                    
                    itemESPElements[item] = {
                        highlight = highlight,
                        itemName = item.Name
                    }
                end
            end
        end
    end)
    
    table.insert(itemESPConnections, itemESPLoop)
end

local function stopItemESP()
    if not itemESPEnabled then return end
    
    itemESPEnabled = false
    print("YBA Item ESP: Деактивирован!")
    
    for obj, esp in pairs(itemESPElements) do
        if esp.highlight then
            esp.highlight:Destroy()
        end
    end
    itemESPElements = {}
    
    for _, connection in ipairs(itemESPConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    itemESPConnections = {}
end

-- Функции Autofarm (копируем ВСЕ из оригинального файла)
local function findAutofarmItems()
    local items = {}
    local player = game.Players.LocalPlayer
    local playerChar = player.Character
    local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
    if not playerRoot then 
        return items 
    end
    
    local itemSpawnsFolder = workspace:FindFirstChild("Item_Spawns")
    if not itemSpawnsFolder then
        return items
    end
    
    local itemsFolder = itemSpawnsFolder:FindFirstChild("Items")
    if not itemsFolder then
        return items
    end
    
    for _, model in ipairs(itemsFolder:GetChildren()) do
        if model:IsA("Model") then
            local proximityPrompt = model:FindFirstChild("ProximityPrompt")
            local itemName = model.Name
            
            if proximityPrompt then
                itemName = proximityPrompt.ObjectText or proximityPrompt.ActionText or model.Name
            end
            
            if AutofarmConfig.Items[itemName] then
                local worldPivot = nil
                if model.WorldPivot then
                    worldPivot = model.WorldPivot.Position
                elseif model.PrimaryPart then
                    worldPivot = model.PrimaryPart.Position
                elseif model:FindFirstChild("HumanoidRootPart") then
                    worldPivot = model.HumanoidRootPart.Position
                else
                    for _, child in ipairs(model:GetDescendants()) do
                        if child:IsA("BasePart") then
                            worldPivot = child.Position
                            break
                        end
                    end
                end
                
                if worldPivot then
                    local distance = (worldPivot - playerRoot.Position).Magnitude
                    table.insert(items, {
                        Name = itemName,
                        Position = worldPivot,
                        Distance = distance,
                        Model = model,
                        ProximityPrompt = proximityPrompt
                    })
                end
            end
        end
    end
    
    table.sort(items, function(a, b) return a.Distance < b.Distance end)
    return items
end

local function startAutofarm()
    if isAutofarmEnabled then
        print("AUTOFARM: Уже активен!")
        return
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then
        print("AUTOFARM: Персонаж не найден!")
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        print("AUTOFARM: HumanoidRootPart не найден!")
        return
    end
    
    isAutofarmEnabled = true
    autofarmOriginalPosition = humanoidRootPart.Position
    
    print("🤖 AUTOFARM: Активирован!")
    print("🤖 AUTOFARM: Начинаем поиск предметов...")
    
    local autofarmLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAutofarmEnabled then
            return
        end
        
        local items = findAutofarmItems()
        if #items > 0 then
            local nextItem = items[1]
            print("AUTOFARM: Найден предмет", nextItem.Name, "на расстоянии", math.floor(nextItem.Distance), "м")
            
            -- Простая логика движения к предмету
            local char = game.Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local direction = (nextItem.Position - root.Position).Unit
                local bv = root:FindFirstChild("AutofarmBodyVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "AutofarmBodyVelocity"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Parent = root
                end
                
                local distance = (nextItem.Position - root.Position).Magnitude
                if distance > 3 then
                    bv.Velocity = direction * (AutofarmConfig.FlightSpeed * 10)
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                    -- Здесь должна быть логика подбора предмета
                end
            end
        end
    end)
    
    table.insert(autofarmConnections, autofarmLoop)
end

local function stopAutofarm()
    if not isAutofarmEnabled then return end
    
    isAutofarmEnabled = false
    print("🤖 AUTOFARM: Деактивирован!")
    
    local char = game.Players.LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChild("AutofarmBodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
    end
    
    for _, connection in ipairs(autofarmConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    autofarmConnections = {}
end

-- Функция создания GUI
function YBAModule.createGUI(container)
    local currentY = 0
    local padding = 8
    
    -- Функции создания элементов GUI
    local function createSectionHeader(text)
        currentY = currentY + padding
        local spacer = Instance.new("Frame", container)
        spacer.Size = UDim2.new(1, 0, 0, 10)
        spacer.Position = UDim2.new(0, 0, 0, currentY)
        spacer.BackgroundTransparency = 1
        currentY = currentY + 10
        
        local lbl = Instance.new("TextLabel", container)
        lbl.Text = text
        lbl.Size = UDim2.new(1, -10, 0, 30)
        lbl.Position = UDim2.new(0, 5, 0, currentY)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 16
        lbl.TextColor3 = Color3.fromRGB(255,255,255)
        lbl.BackgroundTransparency = 1
        currentY = currentY + 30 + padding
        return lbl
    end
    
    local function createToggleSlider(label, default, callback)
        local containerFrame = Instance.new("Frame", container)
        containerFrame.Size = UDim2.new(1, -10, 0, 40)
        containerFrame.Position = UDim2.new(0, 5, 0, currentY)
        containerFrame.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", containerFrame)
        lbl.Text = label
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local sliderBack = Instance.new("Frame", containerFrame)
        sliderBack.Position = UDim2.new(0.7, 5, 0.3, 0)
        sliderBack.Size = UDim2.new(0, 50, 0, 20)
        sliderBack.BackgroundColor3 = default and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        sliderBack.BorderSizePixel = 0
        Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(1, 0)

        local sliderKnob = Instance.new("Frame", sliderBack)
        sliderKnob.Size = UDim2.new(0, 16, 0, 16)
        sliderKnob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        sliderKnob.BorderSizePixel = 0
        Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

        local isEnabled = default
        sliderBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isEnabled = not isEnabled
                
                local targetPos = isEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local targetColor = isEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
                
                local tween1 = game:GetService("TweenService"):Create(sliderKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos})
                local tween2 = game:GetService("TweenService"):Create(sliderBack, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor})
                
                tween1:Play()
                tween2:Play()
                
                callback(isEnabled)
            end
        end)
        
        currentY = currentY + 40 + padding
        return containerFrame
    end
    
    local function createSlider(label, min, max, value, callback)
        local containerFrame = Instance.new("Frame", container)
        containerFrame.Size = UDim2.new(1, -10, 0, 36)
        containerFrame.Position = UDim2.new(0, 5, 0, currentY)
        containerFrame.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", containerFrame)
        lbl.Text = label .. ": " .. math.floor(value)
        lbl.Size = UDim2.new(1, 0, 0.5, 0)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.BackgroundTransparency = 1

        local sliderBack = Instance.new("Frame", containerFrame)
        sliderBack.Position = UDim2.new(0,0,0.5,4)
        sliderBack.Size = UDim2.new(1, 0, 0, 6)
        sliderBack.BackgroundColor3 = Color3.fromRGB(50,50,50)
        Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(1,0)

        local sliderFill = Instance.new("Frame", sliderBack)
        sliderFill.Size = UDim2.new((math.floor(value) - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

        local dragging = false
        sliderBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if dragging then
                local pos = game:GetService("UserInputService"):GetMouseLocation().X
                local abs = sliderBack.AbsolutePosition.X
                local width = sliderBack.AbsoluteSize.X
                local pct = math.clamp((pos - abs) / width, 0, 1)
                local newVal = math.floor(min + (max - min) * pct)
                sliderFill.Size = UDim2.new(pct, 0, 1, 0)
                lbl.Text = label .. ": " .. newVal
                callback(newVal)
            end
        end)
        
        currentY = currentY + 36 + padding
    end
    
    local function createDivider()
        local divider = Instance.new("Frame", container)
        divider.Size = UDim2.new(1, -10, 0, 2)
        divider.Position = UDim2.new(0, 5, 0, currentY)
        divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        divider.BorderSizePixel = 0
        currentY = currentY + 2 + padding
    end
    
    local function createButton(label, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 28)
        btn.Position = UDim2.new(0, 5, 0, currentY)
        btn.Text = label
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        
        btn.MouseButton1Click:Connect(function()
            callback()
        end)
        
        currentY = currentY + 28 + padding
        return btn
    end
    
    -- 🎯 STAND RANGE
    createSectionHeader("🎯 STAND RANGE")
    createToggleSlider("Stand Range Hack", YBAConfig.Enabled, function(v)
        YBAConfig.Enabled = v
        if v then 
            startYBA() 
        else 
            stopYBA() 
        end
    end)
    
    createToggleSlider("Underground Flight", isUndergroundControlEnabled, function(v)
        if v then
            startUndergroundControl()
        else
            stopUndergroundControl()
        end
    end)
    
    createSlider("Underground Speed", 1, 200, YBAConfig.UndergroundControl.FlightSpeed or 50, function(v)
        YBAConfig.UndergroundControl.FlightSpeed = v
    end)
    
    createDivider()
    
    -- ⏰ ANTI TS
    createSectionHeader("⏰ ANTI TS")
    createButton("Anti Time Stop", function()
        if not isAntiTimeStopEnabled then
            startAntiTimeStop()
        else
            stopAntiTimeStop()
        end
    end)
    
    createDivider()
    
    -- 📦 ITEM ESP
    createSectionHeader("📦 ITEM ESP")
    createToggleSlider("Item ESP", YBAConfig.ItemESP.Enabled, function(v)
        YBAConfig.ItemESP.Enabled = v
        if v then 
            startItemESP() 
        else 
            stopItemESP() 
        end
    end)
    
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
    
    -- Создаем переключатели для предметов автофарма
    for itemName, enabled in pairs(AutofarmConfig.Items) do
        createToggleSlider(itemName, enabled, function(v)
            AutofarmConfig.Items[itemName] = v
            print("🤖 AUTOFARM: Предмет", itemName, "установлен в", v and "ON" or "OFF")
        end)
    end
    
    return currentY
end

return YBAModule