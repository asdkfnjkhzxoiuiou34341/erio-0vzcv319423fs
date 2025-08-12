-- Модуль YBA Hacks
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

-- Состояния YBA функций
local isUndergroundControlEnabled = false
local undergroundControlConnections = {}
local controlledStandForUnderground = nil
local isShiftPressed = false

local isYBAEnabled = false
local ybaConnections = {}
local originalPlayerPosition = nil
local originalPlayerCFrame = nil
local originalCameraCFrame = nil
local controlledStand = nil
local standControlConnections = {}
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
local autofarmSkippedItems = {}
local autofarmItemAttempts = {}
local autofarmSkippedReturns = {}
local autofarmLastPickupTime = 0
local autofarmRestartTimer = nil
local autofarmAutoRestarting = false
local autofarmDeathCheckConnection = nil

-- YBA Free Camera Implementation
local YBAFreeCamera = {} do
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
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
            end
        end))

        table.insert(inputConnections, UserInputService.InputEnded:Connect(function(inputObj, gameProcessed)
            if gameProcessed then return end
            local keyName = inputObj.KeyCode.Name
            if input[keyName] ~= nil then
                input[keyName] = false
            end
        end))

        table.insert(inputConnections, UserInputService.InputChanged:Connect(function(inputObj, gameProcessed)
            if inputObj.UserInputType == Enum.UserInputType.MouseMovement then
                local sensitivity = 0.003
                input.MouseDelta = Vector2.new(inputObj.Delta.y * sensitivity, -inputObj.Delta.x * sensitivity)
            elseif inputObj.UserInputType == Enum.UserInputType.MouseWheel then
                if not gameProcessed then
                    input.MouseWheel = -inputObj.Position.Z
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
            YBAFreeCamera.Stop()
            return
        end

        local standRoot = targetStand.Root
        local standPosition = standRoot.Position
        
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
        end
        
        input.LeftShift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        
        local move = Vector3.new(moveX, moveY, moveZ)

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
            return false
        end
        
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
        else
            cameraRot = Vector2.new(0, 0)
        end
        
        task.wait(0.1)
        local standPosition = stand.Root.Position
        
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerCFrame = player.Character.HumanoidRootPart.CFrame
            stand.Root.CFrame = CFrame.new(standPosition, standPosition + playerCFrame.LookVector)
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
        
        startInput()
        renderConnection = RunService.RenderStepped:Connect(stepFreecam)
        fcRunning = true
        
        return true
    end

    function YBAFreeCamera.Stop()
        if not fcRunning then return end
        
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

-- Anti Time Stop Functions
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
    
    local antiFreezeLoop = RunService.Heartbeat:Connect(function()
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
        
        if moveVector.Magnitude > 0 and root then
            local bv = root:FindFirstChild("AntiTSBodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "AntiTSBodyVelocity"
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Parent = root
            end
            
            bv.Velocity = moveVector.Unit * 20
        else
            local bv = root and root:FindFirstChild("AntiTSBodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
        
        local myStand = nil
        
        if isYBAEnabled and controlledStand and controlledStand.Root then
            myStand = controlledStand
        else
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Model") then
                    local standRoot = obj:FindFirstChild("HumanoidRootPart")
                    if standRoot and root then
                        local distance = (standRoot.Position - root.Position).Magnitude
                        if distance <= 20 then
                            if obj.Name:find("Stand") or obj.Name:find("stand") or
                               obj.Name:find("SP") or obj.Name:find("TW") or obj.Name:find("KC") or
                               obj.Name:find("CD") or obj.Name:find("GE") or obj.Name:find("SF") or
                               obj.Name:find("MR") or obj.Name:find("PH") or obj.Name:find("SC") then
                                myStand = {Root = standRoot, Model = obj, Name = obj.Name}
                                break
                            end
                        end
                    end
                end
            end
        end
        
        if myStand and myStand.Root then
            local standRoot = myStand.Root
            
            standRoot.Anchored = false
            
            if moveVector.Magnitude > 0 then
                local standBV = standRoot:FindFirstChild("AntiTSStandBodyVelocity")
                if not standBV then
                    standBV = Instance.new("BodyVelocity")
                    standBV.Name = "AntiTSStandBodyVelocity"
                    standBV.MaxForce = Vector3.new(4000, 4000, 4000)
                    standBV.Parent = standRoot
                end
                
                standBV.Velocity = moveVector.Unit * 25
            else
                local standBV = standRoot:FindFirstChild("AntiTSStandBodyVelocity")
                if standBV then
                    standBV:Destroy()
                end
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
            
            removeAntiTimeStopEffect()
        end
    end)
    
    table.insert(antiTimeStopConnections, antiFreezeLoop)
    table.insert(antiTimeStopConnections, timeStopDetection)
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
end

-- Stand Functions
local function findStands()
    local stands = {}
    local player = Players.LocalPlayer
    local playerChar = player.Character
    local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
    
    if not playerRoot then 
        return stands 
    end
    
    local standNames = {
        "Stand", "StandModel", "StandPart", "StandRoot", "StandHumanoidRootPart",
        "Star Platinum", "The World", "Hierophant Green", "Magician's Red",
        "Hermit Purple", "Silver Chariot", "Tower of Gray", "Dark Blue Moon",
        "Strength", "Wheel of Fortune", "Hanged Man", "Emperor", "Empress",
        "Judgment", "High Priestess", "Death Thirteen", "Lovers", "Sun",
        "Bastet", "Thunder McQueen", "Anubis", "Khnum", "Tohth", "Horus",
        "stand", "STAND", "GER", "SPTW", "TW", "SP", "KC", "KCR", "CD", "WS", "MIH",
        "TWOH", "SPOH", "D4C", "KQ", "BTD", "SF", "SM", "HP", "SC", "HG", "MR"
    }
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local isStand = false
            for _, standName in ipairs(standNames) do
                if obj.Name:find(standName) or obj.Name:lower():find(standName:lower()) then
                    isStand = true
                    break
                end
            end
            
            if isStand then
                local standRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("StandRoot") or obj:FindFirstChild("RootPart")
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
        return false
    end

    freeCameraActive = true
    freeCameraTarget = stand

    local success = YBAFreeCamera.Start(stand)
    if success then
        controlledStand = stand
        return true
    else
        freeCameraActive = false
        freeCameraTarget = nil
        return false
    end
end

local function disableFreeCamera()
    if not freeCameraActive then return end
    
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

local function startYBA()
    if isYBAEnabled then 
        return 
    end
    
    isYBAEnabled = true
    YBAConfig.Enabled = true
    
    local stands = findStands()
    
    if #stands == 0 then 
        isYBAEnabled = false
        YBAConfig.Enabled = false
        return 
    end
    
    local targetStand = stands[1]
    
    local player = Players.LocalPlayer
    if targetStand.Root and targetStand.Model then
        local humanoid = targetStand.Model:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Sit = false
            humanoid.Jump = false
            humanoid.AutoRotate = false
        end
        
        local connectionsRemoved = 0
        for _, child in pairs(targetStand.Root:GetChildren()) do
            if child:IsA("Weld") or child:IsA("Motor6D") or child:IsA("ManualWeld") then
                if (child.Part0 and child.Part0.Parent == player.Character) or 
                   (child.Part1 and child.Part1.Parent == player.Character) then
                    child:Destroy()
                    connectionsRemoved = connectionsRemoved + 1
                end
            elseif child:IsA("Attachment") then
                if child.Name == "StandAttach" or child.Name == "RootRigAttachment" then
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
                            child:Destroy()
                            connectionsRemoved = connectionsRemoved + 1
                        end
                    elseif child:IsA("AlignPosition") or child:IsA("AlignOrientation") or child:IsA("BodyPosition") or child:IsA("BodyAngularVelocity") then
                        child:Destroy()
                        connectionsRemoved = connectionsRemoved + 1
                    end
                end
            end
        end
        
        if targetStand.Model.Parent ~= workspace then
            targetStand.Model.Parent = workspace
        end
        
        targetStand.Root.CanCollide = false
        targetStand.Root.Anchored = false
        
        for _, child in pairs(targetStand.Root:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("BodyAngularVelocity") then
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
        end
    end
    
    if YBAConfig.FreezePlayer then 
        freezePlayer() 
    end
    if YBAConfig.TransferControl then 
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
end

local function stopYBA()
    if not isYBAEnabled then return end
    
    isYBAEnabled = false
    YBAConfig.Enabled = false
    
    disableFreeCamera()
    unfreezePlayer()
    
    for _, connection in ipairs(standControlConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    standControlConnections = {}
    controlledStand = nil
end

local function startUndergroundControl()
    if isUndergroundControlEnabled then 
        return 
    end
    
    local plr = Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then 
        return 
    end
    
    local stands = findStands()
    if #stands == 0 then
        return
    end
    
    controlledStandForUnderground = stands[1].Root
    isUndergroundControlEnabled = true
    
    if not YBAConfig.UndergroundControl.OriginalPosition then
        YBAConfig.UndergroundControl.OriginalPosition = root.Position
    end
    
    if YBAConfig.UndergroundControl.AutoNoClip and _G.startNoClip then
        _G.startNoClip()
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
    
    local initialBv = Instance.new("BodyVelocity", root)
    initialBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    local direction = (undergroundPos - root.Position).Unit
    local speed = 200
    initialBv.Velocity = direction * speed
    
    task.spawn(function()
        task.wait(1)
        if initialBv and initialBv.Parent then
            initialBv:Destroy()
        end
    end)
    
    local undergroundFlyLoop = RunService.RenderStepped:Connect(function()
        if not isUndergroundControlEnabled or not controlledStandForUnderground or not controlledStandForUnderground.Parent then
            if hum then
                hum.JumpPower = flyOriginalJumpPower
                hum.JumpHeight = flyOriginalJumpHeight
                hum.HipHeight = flyOriginalHipHeight
            end
            if not _G.isNoClipping or not _G.isNoClipping() then
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
            stopUndergroundControl()
        end)
        table.insert(undergroundControlConnections, deathConnection)
    end
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
    
    if YBAConfig.UndergroundControl.AutoNoClip and _G.stopNoClip then
        _G.stopNoClip()
    end
    
    controlledStandForUnderground = nil
end

-- Item ESP Functions
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
    ["Dio's Diary"] = true,
}

local function scanForItems()
    local player = Players.LocalPlayer
    local playerChar = player.Character
    local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
    
    if not playerRoot then 
        return {}
    end
    
    local items = {}
    local foundCount = 0
    local searchedModels = {}
    
    -- Основной поиск в Item_Spawns
    local itemSpawns = workspace:FindFirstChild("Item_Spawns")
    if itemSpawns then
        local itemsFolder = itemSpawns:FindFirstChild("Items")
        if itemsFolder then
            for _, child in pairs(itemsFolder:GetChildren()) do
                if child:IsA("Model") then
                    local proximityPrompt = child:FindFirstChildOfClass("ProximityPrompt")
                    local itemName = child.Name
                    
                    if proximityPrompt then
                        itemName = proximityPrompt.ObjectText or proximityPrompt.ActionText or child.Name
                    end
                    
                    if YBA_ITEM_NAMES[itemName] and YBAConfig.ItemESP.Items[itemName] then
                        for _, part in ipairs(child:GetDescendants()) do
                            if part:IsA("MeshPart") or part:IsA("Part") then
                                local distance = (part.Position - playerRoot.Position).Magnitude
                                
                                foundCount = foundCount + 1
                                table.insert(items, {
                                    Object = part,
                                    Name = itemName,
                                    Distance = distance,
                                    Type = "YBA_Item",
                                    Model = child,
                                    Folder = "Item_Spawns.Items"
                                })
                                break
                            end
                        end
                    elseif string.find(string.lower(itemName), "diary") and YBAConfig.ItemESP.Items["DIO's Diary"] then
                        for _, part in ipairs(child:GetDescendants()) do
                            if part:IsA("MeshPart") or part:IsA("Part") then
                                local distance = (part.Position - playerRoot.Position).Magnitude
                                
                                foundCount = foundCount + 1
                                table.insert(items, {
                                    Object = part,
                                    Name = "DIO's Diary",
                                    Distance = distance,
                                    Type = "YBA_Item",
                                    Model = child,
                                    Folder = "Item_Spawns.Items"
                                })
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    return items
end

local function createItemESP(item)
    if itemESPElements[item.Object] then
        return itemESPElements[item.Object]
    end
    
    if not item.Object or not item.Object.Parent then
        return nil
    end

    if item.Distance > YBAConfig.ItemESP.MaxRenderDistance then
        return nil
    end
    
    local esp = {}
    esp.itemName = item.Name 

    local function getItemColor(itemName)
        if string.find(itemName, "Arrow") then
            return Color3.fromRGB(255, 215, 0) 
        elseif string.find(itemName, "Rokakaka") then
            return Color3.fromRGB(255, 0, 255) 
        elseif string.find(itemName, "Diamond") then
            return Color3.fromRGB(0, 255, 255) 
        elseif string.find(itemName, "Corpse") then
            return Color3.fromRGB(255, 0, 0) 
        elseif string.find(itemName, "Diary") then
            return Color3.fromRGB(255, 165, 0)
        else
            return YBAConfig.ItemESP.FillColor 
        end
    end
    
    local itemColor = getItemColor(item.Name)

    if YBAConfig.ItemESP.ShowOutline or YBAConfig.ItemESP.ShowFill then
        local success, highlight = pcall(function()
            local hl = Instance.new("Highlight")
            hl.Adornee = item.Object
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillColor = YBAConfig.ItemESP.ShowFill and itemColor or Color3.fromRGB(0, 0, 0)
            hl.FillTransparency = YBAConfig.ItemESP.ShowFill and YBAConfig.ItemESP.FillTransparency or 1
            hl.OutlineColor = YBAConfig.ItemESP.ShowOutline and YBAConfig.ItemESP.OutlineColor or Color3.fromRGB(0, 0, 0)
            hl.OutlineTransparency = YBAConfig.ItemESP.ShowOutline and YBAConfig.ItemESP.OutlineTransparency or 1
            hl.Parent = item.Object

            local pulseConnection
            pulseConnection = RunService.Heartbeat:Connect(function()
                if not hl.Parent then
                    pulseConnection:Disconnect()
                    return
                end
                
                local time = tick()
                local pulse = math.sin(time * 4) * 0.4 + 0.6
                hl.FillTransparency = YBAConfig.ItemESP.FillTransparency + (1 - pulse) * 0.4
                hl.OutlineTransparency = YBAConfig.ItemESP.OutlineTransparency + (1 - pulse) * 0.2
            end)
            
            esp.pulseConnection = pulseConnection
            
            return hl
        end)
        
        if success and highlight then
            esp.highlight = highlight
        end
    end

    if YBAConfig.ItemESP.ShowText then
        local success, billboard = pcall(function()
            local bg = Instance.new("BillboardGui")
            bg.AlwaysOnTop = true
            bg.Size = UDim2.new(0, 200, 0, 50) 
            bg.StudsOffset = Vector3.new(0, 3, 0) 
            bg.Parent = item.Object

            local background = Instance.new("Frame", bg)
            background.Size = UDim2.new(1, 0, 1, 0)
            background.Position = UDim2.new(0, 0, 0, 0)
            background.BackgroundColor3 = YBAConfig.ItemESP.TextBackgroundColor
            background.BackgroundTransparency = YBAConfig.ItemESP.TextBackgroundTransparency
            background.BorderSizePixel = 0
            background.ZIndex = 1
            
            local corner = Instance.new("UICorner", background)
            corner.CornerRadius = UDim.new(0, 6) 

            local border = Instance.new("Frame", bg)
            border.Size = UDim2.new(1, 2, 1, 2)
            border.Position = UDim2.new(0, -1, 0, -1)
            border.BackgroundColor3 = itemColor
            border.BorderSizePixel = 0
            border.ZIndex = 0
            
            local borderCorner = Instance.new("UICorner", border)
            borderCorner.CornerRadius = UDim.new(0, 8) 

            local tl = Instance.new("TextLabel", bg)
            tl.Size = UDim2.new(1, -6, 0.6, 0) 
            tl.Position = UDim2.new(0, 3, 0, 2)
            tl.BackgroundTransparency = 1
            tl.Font = YBAConfig.ItemESP.Font
            tl.TextSize = YBAConfig.ItemESP.TextSize
            tl.TextColor3 = YBAConfig.ItemESP.TextColor
            tl.TextXAlignment = Enum.TextXAlignment.Center
            tl.TextYAlignment = Enum.TextYAlignment.Center
            tl.Text = string.format("🎯 %s", item.Name)
            tl.ZIndex = 3

            local distanceLabel = Instance.new("TextLabel", bg)
            distanceLabel.Size = UDim2.new(1, -6, 0.4, 0) 
            distanceLabel.Position = UDim2.new(0, 3, 0.6, 0) 
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.TextSize = YBAConfig.ItemESP.DistanceTextSize
            distanceLabel.TextColor3 = YBAConfig.ItemESP.TextColor
            distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
            distanceLabel.TextYAlignment = Enum.TextYAlignment.Center
            distanceLabel.Text = string.format("📏 %dm", math.floor(item.Distance)) 
            distanceLabel.ZIndex = 3
            
            return {
                billboard = bg, 
                text = tl, 
                distanceLabel = distanceLabel,
                background = background,
                border = border
            }
        end)
        
        if success and billboard then
            esp.billboard = billboard.billboard
            esp.text = billboard.text
            esp.distanceLabel = billboard.distanceLabel
            esp.background = billboard.background
            esp.border = billboard.border
        end
    end
    
    itemESPElements[item.Object] = esp
    return esp
end

local function removeItemESP(item)
    local esp = itemESPElements[item.Object]
    if not esp then return end

    if esp.pulseConnection then
        esp.pulseConnection:Disconnect()
        esp.pulseConnection = nil
    end

    pcall(function()
        if esp.highlight and esp.highlight.Parent then
            esp.highlight:Destroy()
        end
    end)

    pcall(function()
        if esp.billboard and esp.billboard.Parent then
            esp.billboard:Destroy()
        end
    end)

    esp.highlight = nil
    esp.billboard = nil
    esp.text = nil
    esp.distanceLabel = nil
    esp.background = nil
    esp.border = nil
    
    itemESPElements[item.Object] = nil
end

local function startItemESP()
    if itemESPEnabled then 
        return 
    end
    itemESPEnabled = true
    
    local itemESPLoop = RunService.Heartbeat:Connect(function()
        if not itemESPEnabled then
            return
        end
        
        local items = scanForItems()
        
        -- Удаляем ESP для предметов, которых больше нет
        for object, esp in pairs(itemESPElements) do
            local found = false
            for _, item in pairs(items) do
                if item.Object == object then
                    found = true
                    break
                end
            end
            
            if not found then
                removeItemESP({Object = object})
            end
        end
        
        -- Создаем/обновляем ESP для найденных предметов
        for _, item in pairs(items) do
            if item.Distance <= YBAConfig.ItemESP.MaxDistance then
                local esp = itemESPElements[item.Object]
                if not esp then
                    createItemESP(item)
                else
                    -- Обновляем дистанцию
                    if esp.distanceLabel and esp.distanceLabel.Parent then
                        esp.distanceLabel.Text = string.format("📏 %dm", math.floor(item.Distance))
                    end
                end
            end
        end
    end)
    
    table.insert(itemESPConnections, itemESPLoop)
end

local function stopItemESP()
    itemESPEnabled = false
    
    -- Удаляем все ESP элементы
    for object, esp in pairs(itemESPElements) do
        removeItemESP({Object = object})
    end
    
    -- Отключаем все соединения
    for _, connection in pairs(itemESPConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    itemESPConnections = {}
end

-- Autofarm Functions
local function moveToPosition(targetPosition, speedMultiplier)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    speedMultiplier = speedMultiplier or 1
    local baseSpeed = AutofarmConfig.FlightSpeed * speedMultiplier
    
    local distance = (targetPosition - humanoidRootPart.Position).Magnitude
    if distance < 3 then
        return true
    end
    
    local bv = humanoidRootPart:FindFirstChild("AutofarmBodyVelocity")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "AutofarmBodyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = humanoidRootPart
    end
    
    local direction = (targetPosition - humanoidRootPart.Position).Unit
    bv.Velocity = direction * baseSpeed
    
    return false
end

local function startAutofarm()
    if isAutofarmEnabled then return end
    
    isAutofarmEnabled = true
    AutofarmConfig.Enabled = true
    
    if AutofarmConfig.UseNoClipMovement and _G.startNoClip then
        _G.startNoClip()
    end
    
    if AutofarmConfig.UseFlightMovement and _G.startFly then
        _G.startFly()
    end
    
    local autofarmLoop = RunService.Heartbeat:Connect(function()
        if not isAutofarmEnabled then return end
        
        local player = Players.LocalPlayer
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Поиск предметов для подбора
        local items = scanForItems()
        local nearestItem = nil
        local nearestDistance = math.huge
        
        for _, item in pairs(items) do
            if AutofarmConfig.Items[item.Name] and item.Distance < nearestDistance then
                nearestItem = item
                nearestDistance = item.Distance
            end
        end
        
        if nearestItem then
            if nearestDistance <= AutofarmConfig.PickupRadius then
                -- Подбираем предмет
                local proximityPrompt = nearestItem.Model:FindFirstChildOfClass("ProximityPrompt")
                if proximityPrompt then
                    fireproximityprompt(proximityPrompt)
                    task.wait(AutofarmConfig.PickupDuration)
                end
            else
                -- Двигаемся к предмету
                moveToPosition(nearestItem.Object.Position)
            end
        end
    end)
    
    table.insert(autofarmConnections, autofarmLoop)
end

local function stopAutofarm()
    isAutofarmEnabled = false
    AutofarmConfig.Enabled = false
    
    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local bv = humanoidRootPart:FindFirstChild("AutofarmBodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
    end
    
    for _, connection in pairs(autofarmConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    autofarmConnections = {}
    
    if AutofarmConfig.UseNoClipMovement and _G.stopNoClip then
        _G.stopNoClip()
    end
    
    if AutofarmConfig.UseFlightMovement and _G.stopFly then
        _G.stopFly()
    end
end

-- Экспорт функций для основного файла
return {
    -- Конфиги
    YBAConfig = YBAConfig,
    AntiTimeStopConfig = AntiTimeStopConfig,
    AutofarmConfig = AutofarmConfig,
    
    -- Stand Range функции
    startYBA = startYBA,
    stopYBA = stopYBA,
    findStands = findStands,
    
    -- Anti Time Stop функции
    startAntiTimeStop = startAntiTimeStop,
    stopAntiTimeStop = stopAntiTimeStop,
    
    -- Underground Control функции
    startUndergroundControl = startUndergroundControl,
    stopUndergroundControl = stopUndergroundControl,
    
    -- Item ESP функции
    startItemESP = startItemESP,
    stopItemESP = stopItemESP,
    scanForItems = scanForItems,
    
    -- Autofarm функции
    startAutofarm = startAutofarm,
    stopAutofarm = stopAutofarm,
    moveToPosition = moveToPosition,
    
    -- Состояния
    isYBAEnabled = function() return isYBAEnabled end,
    isAntiTimeStopEnabled = function() return isAntiTimeStopEnabled end,
    isUndergroundControlEnabled = function() return isUndergroundControlEnabled end,
    isItemESPEnabled = function() return itemESPEnabled end,
    isAutofarmEnabled = function() return isAutofarmEnabled end,
}