-- Модуль main и settings вкладок
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Config = {
    ESP = {
        Enabled     = true,
        TeamCheck   = false,
        ShowOutline = true,
        ShowLines   = false,
        Rainbow     = false,
        FillColor   = Color3.fromRGB(255,255,255),
        OutlineColor= Color3.fromRGB(255,255,255),
        TextColor   = Color3.fromRGB(255,255,255),
        LineColor   = Color3.fromRGB(255,255,255),
        FillTransparency    = 0.5,
        OutlineTransparency = 0,
        Font        = Enum.Font.SciFi,
        TeamColor   = Color3.fromRGB(0,255,0),
        EnemyColor  = Color3.fromRGB(255,0,0),
        ToggleKey   = nil,
    },
    Aimbot = {
        Enabled         = false,
        TeamCheck       = false,
        VisibilityCheck = true,
        FOV             = 150,
        ToggleKey       = nil,
        FOVColor        = Color3.fromRGB(255,128,128),
        FOVRainbow      = false,
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

local MenuSettings = {
    BlurEnabled = true,
    AccentColor = Color3.fromRGB(0, 150, 0),
    Language = "English",
}

-- Состояния функций
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
local lastTeleportPosition = nil
local stabilizationStartTime = nil
local isStabilizing = false
local speedResetTimer = 0
local lastSpeedCheck = tick()
local lastBehindDistance = 0
local lastUpdateTime = tick()

-- Player ESP variables
local playerESPConnections = {}
local playerESPElements = {}

-- Функции полета
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

-- Функции NoClip
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

-- Функции ускорения
local function startSpeedHack()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    isSpeedHacking = true
    originalWalkSpeed = hum.WalkSpeed
    originalJumpPower = hum.JumpPower
    
    hum.WalkSpeed = MovementConfig.Speed.Speed * 16
    
    if MovementConfig.Speed.UseJumpPower then
        hum.JumpPower = MovementConfig.Speed.Speed * 50
    end
    
    local function onCharacterAdded(newChar)
        local newHum = newChar:WaitForChild("Humanoid")
        if isSpeedHacking then
            newHum.WalkSpeed = MovementConfig.Speed.Speed * 16
            if MovementConfig.Speed.UseJumpPower then
                newHum.JumpPower = MovementConfig.Speed.Speed * 50
            end
        end
    end
    
    local characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(speedHackConnections, characterAddedConnection)
    
    local speedLoop = RunService.Heartbeat:Connect(function()
        if not isSpeedHacking then return end
        
        local currentChar = Players.LocalPlayer.Character
        local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        
        if currentHum then
            if currentHum.WalkSpeed ~= MovementConfig.Speed.Speed * 16 then
                currentHum.WalkSpeed = MovementConfig.Speed.Speed * 16
            end
            
            if MovementConfig.Speed.UseJumpPower and currentHum.JumpPower ~= MovementConfig.Speed.Speed * 50 then
                currentHum.JumpPower = MovementConfig.Speed.Speed * 50
            end
        end
    end)
    
    table.insert(speedHackConnections, speedLoop)
end

local function stopSpeedHack()
    isSpeedHacking = false
    
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = originalWalkSpeed
        hum.JumpPower = originalJumpPower
    end
    
    for _, connection in ipairs(speedHackConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            elseif typeof(connection) == "Instance" then
                pcall(function() connection:Destroy() end)
            end
        end
    end
    speedHackConnections = {}
end

-- Функции телепорта
local function createStealthTeleport()
    if not TeleportConfig.TargetPlayer then 
        return 
    end
    
    local char = Players.LocalPlayer.Character
    local targetChar = TeleportConfig.TargetPlayer.Character
    if not char or not targetChar then 
        return 
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not targetRoot or not humanoid then 
        return 
    end
    
    isTeleporting = true
    speedResetTimer = 0
    lastSpeedCheck = tick()
    
    if not TeleportConfig.OriginalPosition then
        TeleportConfig.OriginalPosition = root.Position
    end
    
    if not isNoClipping then
        startNoClip()
    end
    
    task.spawn(function()
        task.wait(0.1) 
        if not isNoClipping then
            startNoClip()
        end
        
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    local stealthTeleportLoop = RunService.Heartbeat:Connect(function()
        if not isTeleporting or not targetChar or not targetChar.Parent then
            return
        end
        
        if isNoClipping and char and char.Parent then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        
        local currentTime = tick()
        speedResetTimer = speedResetTimer + (currentTime - lastSpeedCheck)
        lastSpeedCheck = currentTime
        
        if speedResetTimer >= TeleportConfig.MaxSpeedResetTime then
            speedResetTimer = 0
            
            local bv = root:FindFirstChild("BodyVelocity")
            local safeBehindDistance = lastBehindDistance or 0
            if bv and bv.Velocity.Magnitude > TeleportConfig.SpeedResetThreshold and safeBehindDistance > 5 then
                bv.Velocity = bv.Velocity * 0.8
            end

            if humanoid and humanoid.WalkSpeed > 16 and (safeBehindDistance > 5) then
                humanoid.WalkSpeed = math.max(humanoid.WalkSpeed - 1, 16)
            end
        end
        
        local now = tick()
        local dt = now - lastUpdateTime
        lastUpdateTime = now
        
        local currentTargetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if currentTargetRoot then
            local targetPos = currentTargetRoot.Position
            local currentPos = root.Position
            local distance = (targetPos - currentPos).Magnitude

            if lastTeleportPosition then
                local targetMovement = (targetPos - lastTeleportPosition).Magnitude
                if targetMovement > 3 then
                    task.wait(0.02)
                end
            end
            lastTeleportPosition = targetPos
            
            local targetCFrame = currentTargetRoot.CFrame
            local behindPosition = targetCFrame * CFrame.new(0, 0, TeleportConfig.BehindPlayerDistance)
            local behindDistance = (behindPosition.Position - currentPos).Magnitude
            
            local bv = root:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.new(0, 0, 0)
            else
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            end
            
            local bg = root:FindFirstChild("BodyGyro")
            if not bg then
                bg = Instance.new("BodyGyro", root)
                bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bg.D = 1000
                bg.P = 8000
            else
                bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bg.D = 1000
                bg.P = 8000
            end
            
            local targetLookVector = targetCFrame.LookVector
            bg.CFrame = CFrame.lookAt(root.Position, root.Position + targetLookVector)
            
            local targetVelocity = currentTargetRoot.Velocity
            local targetSpeed = targetVelocity.Magnitude
            
            local predictionTime = math.clamp(0.05 + (targetSpeed / 300), 0.05, 0.25)
            local predictedPosition = behindPosition.Position + (targetVelocity * predictionTime)
            local predictedDistance = (predictedPosition - currentPos).Magnitude
            
            local adaptiveSpeed = TeleportConfig.TeleportSpeed
            if targetSpeed > 80 then
                adaptiveSpeed = TeleportConfig.TeleportSpeed * 2.5
            elseif targetSpeed > 50 then
                adaptiveSpeed = TeleportConfig.TeleportSpeed * 2.0
            elseif targetSpeed > 20 then
                adaptiveSpeed = TeleportConfig.TeleportSpeed * 1.4
            end
            
            if predictedDistance > 1.5 then
                isStabilizing = false
                stabilizationStartTime = nil
                local direction = (predictedPosition - currentPos).Unit
                local currentVelocity = bv.Velocity
                local targetVelocityVec = direction * adaptiveSpeed
                
                local accelerationFactor = 0.22
                if targetSpeed > 80 then
                    accelerationFactor = 0.5
                elseif targetSpeed > 50 then
                    accelerationFactor = 0.4
                elseif targetSpeed > 30 then
                    accelerationFactor = 0.3
                end
                
                local velocityDiff = targetVelocityVec - currentVelocity
                local acceleration = velocityDiff * accelerationFactor
                
                bv.Velocity = currentVelocity + acceleration
            else
                local direction = (predictedPosition - currentPos).Unit
                local maxCorr = TeleportConfig.MaxCorrectionSpeed or 180
                local correctionSpeed = math.min(predictedDistance * 45, maxCorr)
                
                if targetSpeed > 10 then
                    correctionSpeed = correctionSpeed * 1.15
                end
                
                bv.Velocity = direction * correctionSpeed
                
                if predictedDistance < 0.25 and targetSpeed < 12 then
                    if not isStabilizing then
                        isStabilizing = true
                        stabilizationStartTime = tick()
                    end
                    local elapsed = tick() - (stabilizationStartTime or tick())
                    local smoothFactor = math.clamp(elapsed / (TeleportConfig.StabilizationTime + 1e-6), 0, 1)
                    local smallSpeed = math.min(predictedDistance * 25, 15)
                    local desiredVel = direction * smallSpeed
                    bv.Velocity = bv.Velocity + (desiredVel - bv.Velocity) * math.max(0.55, 0.85 * smoothFactor)
                    if predictedDistance < 0.05 then
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                else
                    isStabilizing = false
                    stabilizationStartTime = nil
                end
            end
            
            lastBehindDistance = behindDistance
        end
    end)
    
    table.insert(teleportConnections, stealthTeleportLoop)
end

local function startTeleport()
    if not TeleportConfig.TargetPlayer then 
        return 
    end
    
    local char = Players.LocalPlayer.Character
    local targetChar = TeleportConfig.TargetPlayer.Character
    if not char or not targetChar then 
        return 
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then 
        return 
    end
    
    isTeleporting = true
    lastTeleportPosition = nil
    speedResetTimer = 0
    lastSpeedCheck = tick()
    
    TeleportConfig.OriginalPosition = root.Position
    
    if not isNoClipping then
        startNoClip()
    end
    
    task.spawn(function()
        task.wait(0.1) 
        if not isNoClipping then
            startNoClip()
        end
        
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    createStealthTeleport()
    
    task.spawn(function()
        task.wait(0.2)
        if not isNoClipping then
            startNoClip()
        end
        
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopTeleport()
    isTeleporting = false
    lastTeleportPosition = nil
    speedResetTimer = 0
    TeleportConfig.Enabled = false
    
    local char = Players.LocalPlayer.Character
    if not char then 
        return 
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    for _, connection in ipairs(teleportConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            end
        end
    end
    teleportConnections = {}
    
    local bv = root and root:FindFirstChild("BodyVelocity")
    if bv then
        bv.Velocity = Vector3.new(0, 0, 0)
        task.wait(0.1) 
        bv:Destroy()
    end
    
    local bg = root and root:FindFirstChild("BodyGyro")
    if bg then
        bg:Destroy()
    end
    
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
    
    if root and TeleportConfig.OriginalPosition then
        if not isNoClipping then
            startNoClip()
        end
        
        local returnConnections = {}
        
        local returnLoop = RunService.Heartbeat:Connect(function()
            if not root or not root.Parent then
                return
            end
            
            local currentPos = root.Position
            local returnPos = TeleportConfig.OriginalPosition
            local distance = (returnPos - currentPos).Magnitude
            
            if distance > 3 then
                local returnBv = root:FindFirstChild("BodyVelocity")
                if not returnBv then
                    returnBv = Instance.new("BodyVelocity", root)
                    returnBv.MaxForce = Vector3.new(1e6, 1e6, 1e6) 
                end
                
                local returnDirection = (returnPos - currentPos).Unit
                local returnSpeed = TeleportConfig.ReturnSpeed
                
                returnSpeed = returnSpeed + math.random(-5, 5)
                
                returnBv.Velocity = returnDirection * returnSpeed
            else
                local returnBv = root:FindFirstChild("BodyVelocity")
                if returnBv then
                    returnBv.Velocity = Vector3.new(0, 0, 0)
                    task.wait(0.5) 
                    returnBv:Destroy()
                end
                
                local returnBg = root:FindFirstChild("BodyGyro")
                if returnBg then
                    returnBg:Destroy()
                end
                
                root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
                TeleportConfig.OriginalPosition = nil
                
                local freezeBv = Instance.new("BodyVelocity", root)
                freezeBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                freezeBv.Velocity = Vector3.new(0, 0, 0)
                
                task.wait(2) 
                
                if freezeBv then
                    freezeBv:Destroy()
                end
                
                task.spawn(function()
                    task.wait(5)
                    if isNoClipping then
                        stopNoClip()
                    end
                end)
                
                for _, connection in ipairs(returnConnections) do
                    if connection then
                        pcall(function() connection:Disconnect() end)
                    end
                end
                
                if returnLoop then
                    returnLoop:Disconnect()
                end
            end
        end)
        
        table.insert(returnConnections, returnLoop)
    end
    
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
end

-- Экспорт функций для основного файла
return {
    -- Конфиги
    Config = Config,
    MovementConfig = MovementConfig,
    TeleportConfig = TeleportConfig,
    MenuSettings = MenuSettings,
    
    -- Функции полета
    startFly = startFly,
    stopFly = stopFly,
    
    -- Функции NoClip
    startNoClip = startNoClip,
    stopNoClip = stopNoClip,
    
    -- Функции скорости
    startSpeedHack = startSpeedHack,
    stopSpeedHack = stopSpeedHack,
    
    -- Функции телепорта
    startTeleport = startTeleport,
    stopTeleport = stopTeleport,
    
    -- Состояния
    isFlying = function() return isFlying end,
    isNoClipping = function() return isNoClipping end,
    isSpeedHacking = function() return isSpeedHacking end,
    isTeleporting = function() return isTeleporting end,
}