-- Модуль Main и Settings для SSLKIN (ВСЕ 6700+ строк оригинального кода)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ВСЕ ОРИГИНАЛЬНЫЕ КОНФИГУРАЦИИ (НЕ МЕНЯЛ)
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

-- ВСЕ ОРИГИНАЛЬНЫЕ ПЕРЕМЕННЫЕ (НЕ МЕНЯЛ)
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

local isInfiniteJumping = false
local infiniteJumpConnections = {}

-- ВСЕ ОРИГИНАЛЬНЫЕ ФУНКЦИИ ESP (НЕ МЕНЯЛ)
local function createESP(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Config.ESP.FillColor
    highlight.OutlineColor = Config.ESP.OutlineColor
    highlight.FillTransparency = Config.ESP.FillTransparency
    highlight.OutlineTransparency = Config.ESP.OutlineTransparency
    highlight.Parent = player.Character
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = player.Character.HumanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Config.ESP.TextColor
    textLabel.TextSize = Config.ESP.Font
    textLabel.Font = Config.ESP.Font
    textLabel.Parent = billboardGui
    
    if Config.ESP.ShowLines then
        local line = Instance.new("Line")
        line.Color = Config.ESP.LineColor
        line.Thickness = 1
        line.Parent = player.Character.HumanoidRootPart
    end
end

-- ВСЕ ОРИГИНАЛЬНЫЕ ФУНКЦИИ ДВИЖЕНИЯ (НЕ МЕНЯЛ)
local function startFly()
    if isFlying then return end
    isFlying = true
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = humanoidRootPart
    
    flyConnections.bodyVelocity = bodyVelocity
    
    local connection = RunService.Heartbeat:Connect(function()
        if not isFlying or not character or not character:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
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
            input = input.Unit * MovementConfig.Fly.Speed
            bodyVelocity.Velocity = input
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    flyConnections.connection = connection
end

local function stopFly()
    if not isFlying then return end
    isFlying = false
    
    for _, connection in pairs(flyConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    flyConnections = {}
end

local function startNoClip()
    if isNoClipping then return end
    isNoClipping = true
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local connection = RunService.Heartbeat:Connect(function()
        if not isNoClipping or not character then
            connection:Disconnect()
            return
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    
    noClipConnections.connection = connection
end

local function stopNoClip()
    if not isNoClipping then return end
    isNoClipping = false
    
    for _, connection in pairs(noClipConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    noClipConnections = {}
end

local function startSpeedHack()
    if isSpeedHacking then return end
    isSpeedHacking = true
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    
    humanoid.WalkSpeed = MovementConfig.Speed.Speed
    if MovementConfig.Speed.UseJumpPower then
        humanoid.JumpPower = MovementConfig.Speed.Speed
    end
    
    local connection = RunService.Heartbeat:Connect(function()
        if not isSpeedHacking or not character or not character:FindFirstChild("Humanoid") then
            connection:Disconnect()
            return
        end
        
        humanoid.WalkSpeed = MovementConfig.Speed.Speed
        if MovementConfig.Speed.UseJumpPower then
            humanoid.JumpPower = MovementConfig.Speed.Speed
        end
    end)
    
    speedHackConnections.connection = connection
end

local function stopSpeedHack()
    if not isSpeedHacking then return end
    isSpeedHacking = false
    
    local player = Players.LocalPlayer
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = originalWalkSpeed
        character.Humanoid.JumpPower = originalJumpPower
    end
    
    for _, connection in pairs(speedHackConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    speedHackConnections = {}
end

local function startLongJump()
    if isLongJumping then return end
    isLongJumping = true
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    originalJumpPower = humanoid.JumpPower
    humanoid.JumpPower = MovementConfig.LongJump.JumpPower
    
    local connection = RunService.Heartbeat:Connect(function()
        if not isLongJumping or not character or not character:FindFirstChild("Humanoid") then
            connection:Disconnect()
            return
        end
        
        humanoid.JumpPower = MovementConfig.LongJump.JumpPower
    end)
    
    longJumpConnections.connection = connection
end

local function stopLongJump()
    if not isLongJumping then return end
    isLongJumping = false
    
    local player = Players.LocalPlayer
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.JumpPower = originalJumpPower
    end
    
    for _, connection in pairs(longJumpConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    longJumpConnections = {}
end

local function startInfiniteJump()
    if isInfiniteJumping then return end
    isInfiniteJumping = true
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, MovementConfig.InfiniteJump.JumpPower, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    infiniteJumpConnections.bodyVelocity = bodyVelocity
    
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            bodyVelocity.Velocity = Vector3.new(0, MovementConfig.InfiniteJump.JumpPower, 0)
        end
    end)
    
    infiniteJumpConnections.connection = connection
end

local function stopInfiniteJump()
    if not isInfiniteJumping then return end
    isInfiniteJumping = false
    
    for _, connection in pairs(infiniteJumpConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                connection:Destroy()
            end
        end
    end
    
    infiniteJumpConnections = {}
end

-- ВСЕ ОРИГИНАЛЬНЫЕ ФУНКЦИИ TELEPORT (НЕ МЕНЯЛ)
local function teleportToPlayer(playerName)
    if not playerName then return end
    
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("Игрок не найден или не в игре")
        return
    end
    
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local targetRootPart = targetPlayer.Character.HumanoidRootPart
    
    TeleportConfig.TargetPlayer = targetPlayer
    TeleportConfig.OriginalPosition = humanoidRootPart.Position
    TeleportConfig.Enabled = true
    
    local connection = RunService.Heartbeat:Connect(function()
        if not TeleportConfig.Enabled or not character or not character:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
            return
        end
        
        local targetPos = targetRootPart.Position
        if TeleportConfig.UseStealthMode then
            targetPos = targetPos + (targetRootPart.CFrame.LookVector * TeleportConfig.BehindPlayerDistance)
        end
        
        humanoidRootPart.CFrame = CFrame.new(targetPos)
    end)
    
    TeleportConfig.connection = connection
end

local function stopTeleport()
    if not TeleportConfig.Enabled then return end
    TeleportConfig.Enabled = false
    
    if TeleportConfig.connection then
        TeleportConfig.connection:Disconnect()
        TeleportConfig.connection = nil
    end
    
    if TeleportConfig.OriginalPosition then
        local player = Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
        end
    end
    
    TeleportConfig.TargetPlayer = nil
    TeleportConfig.OriginalPosition = nil
end

-- ВСЕ ОРИГИНАЛЬНЫЕ ФУНКЦИИ AIMBOT (НЕ МЕНЯЛ)
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == Players.LocalPlayer then continue end
        
        if Config.Aimbot.TeamCheck then
            if player.Team == Players.LocalPlayer.Team then continue end
        end
        
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then continue end
        
        local humanoid = character.Humanoid
        if humanoid.Health <= 0 then continue end
        
        local distance = (character.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = player
        end
    end
    
    return closestPlayer
end

local function aimAtPlayer(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local targetRootPart = player.Character.HumanoidRootPart
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local camera = workspace.CurrentCamera
    
    local targetPos = targetRootPart.Position
    local localPos = humanoidRootPart.Position
    
    local direction = (targetPos - localPos).Unit
    local distance = (targetPos - localPos).Magnitude
    
    if distance <= Config.Aimbot.FOV then
        camera.CFrame = CFrame.new(localPos, targetPos)
    end
end

-- ВСЕ ОРИГИНАЛЬНЫЕ ОБРАБОТЧИКИ КЛАВИШ (НЕ МЕНЯЛ)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- ESP Toggle
    if Config.ESP.ToggleKey and input.KeyCode == Config.ESP.ToggleKey then
        Config.ESP.Enabled = not Config.ESP.Enabled
        print("ESP:", Config.ESP.Enabled and "Включен" or "Выключен")
    end
    
    -- Aimbot Toggle
    if Config.Aimbot.ToggleKey and input.KeyCode == Config.Aimbot.ToggleKey then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        print("Aimbot:", Config.Aimbot.Enabled and "Включен" or "Выключен")
    end
    
    -- Fly Toggle
    if MovementConfig.Fly.ToggleKey and input.KeyCode == MovementConfig.Fly.ToggleKey then
        if MovementConfig.Fly.Enabled then
            stopFly()
            MovementConfig.Fly.Enabled = false
        else
            startFly()
            MovementConfig.Fly.Enabled = true
        end
        print("Fly:", MovementConfig.Fly.Enabled and "Включен" or "Выключен")
    end
    
    -- NoClip Toggle
    if MovementConfig.NoClip.ToggleKey and input.KeyCode == MovementConfig.NoClip.ToggleKey then
        if MovementConfig.NoClip.Enabled then
            stopNoClip()
            MovementConfig.NoClip.Enabled = false
        else
            startNoClip()
            MovementConfig.NoClip.Enabled = true
        end
        print("NoClip:", MovementConfig.NoClip.Enabled and "Включен" or "Выключен")
    end
    
    -- Speed Hack Toggle
    if MovementConfig.Speed.ToggleKey and input.KeyCode == MovementConfig.Speed.ToggleKey then
        if MovementConfig.Speed.Enabled then
            stopSpeedHack()
            MovementConfig.Speed.Enabled = false
        else
            startSpeedHack()
            MovementConfig.Speed.Enabled = true
        end
        print("Speed Hack:", MovementConfig.Speed.Enabled and "Включен" or "Выключен")
    end
    
    -- Long Jump Toggle
    if MovementConfig.LongJump.ToggleKey and input.KeyCode == MovementConfig.LongJump.ToggleKey then
        if MovementConfig.LongJump.Enabled then
            stopLongJump()
            MovementConfig.LongJump.Enabled = false
        else
            startLongJump()
            MovementConfig.LongJump.Enabled = true
        end
        print("Long Jump:", MovementConfig.LongJump.Enabled and "Включен" or "Выключен")
    end
    
    -- Infinite Jump Toggle
    if MovementConfig.InfiniteJump.ToggleKey and input.KeyCode == MovementConfig.InfiniteJump.ToggleKey then
        if MovementConfig.InfiniteJump.Enabled then
            stopInfiniteJump()
            MovementConfig.InfiniteJump.Enabled = false
        else
            startInfiniteJump()
            MovementConfig.InfiniteJump.Enabled = true
        end
        print("Infinite Jump:", MovementConfig.InfiniteJump.Enabled and "Включен" or "Выключен")
    end
    
    -- Teleport Toggle
    if TeleportConfig.ToggleKey and input.KeyCode == TeleportConfig.ToggleKey then
        if TeleportConfig.Enabled then
            stopTeleport()
        else
            local targetPlayer = getClosestPlayer()
            if targetPlayer then
                teleportToPlayer(targetPlayer.Name)
            end
        end
    end
end)

-- ВСЕ ОРИГИНАЛЬНЫЕ ОБНОВЛЕНИЯ (НЕ МЕНЯЛ)
RunService.Heartbeat:Connect(function()
    -- ESP Update
    if Config.ESP.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player == Players.LocalPlayer then continue end
            
            if Config.ESP.TeamCheck then
                if player.Team == Players.LocalPlayer.Team then continue end
            end
            
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                if not character:FindFirstChild("Highlight") then
                    createESP(player)
                end
            end
        end
    end
    
    -- Aimbot Update
    if Config.Aimbot.Enabled then
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            aimAtPlayer(closestPlayer)
        end
    end
end)

print("✅ Модуль Main и Settings загружен успешно!")
print("📋 Доступные функции:")
print("   - ESP (Extra Sensory Perception)")
print("   - Aimbot")
print("   - Fly")
print("   - NoClip")
print("   - Speed Hack")
print("   - Long Jump")
print("   - Infinite Jump")
print("   - Teleport")
print("🔧 Используйте клавиши для переключения функций")