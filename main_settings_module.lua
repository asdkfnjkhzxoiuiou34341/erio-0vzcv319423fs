-- Модуль Main и Settings для SSLKIN
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Конфигурации
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

-- Переменные состояния
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

-- ESP переменные
local ESPs, Lines = {}, {}
local FOVCircle

-- Функции ESP
local function getName(p)
    return p.Name
end

local function getHealth(p)
    local h = p.Character and p.Character:FindFirstChild("Humanoid")
    return (h and h.Health>0) and math.floor(h.Health) or 0
end

local function isAlive(p) return getHealth(p)>0 end

local function getRainbow() return Color3.fromHSV((tick()%5)/5,1,1) end

local function getESPColor(p)
    if Config.ESP.Rainbow then return getRainbow() end
    if Config.ESP.TeamCheck then return (p.TeamColor==Players.LocalPlayer.TeamColor) and Config.ESP.TeamColor or Config.ESP.EnemyColor end
    return Config.ESP.FillColor
end

local function getOutlineColor(p)
    if Config.ESP.Rainbow then return getRainbow() end
    if Config.ESP.TeamCheck then return (p.TeamColor==Players.LocalPlayer.TeamColor) and Config.ESP.TeamColor or Config.ESP.EnemyColor end
    return Config.ESP.OutlineColor
end

local function rayVisible(p)
    if not Config.Aimbot.VisibilityCheck then return true end
    local cam=workspace.CurrentCamera
    local head=p.Character and p.Character:FindFirstChild("Head") if not head then return false end
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={Players.LocalPlayer.Character,p.Character}
    return not workspace:Raycast(cam.CFrame.Position, head.Position-cam.CFrame.Position, rp)
end

local function createOrUpdateESP(p)
    if not p or not p.Character then return end
    
    if not ESPs[p] then
        local hl=Instance.new("Highlight"); hl.Adornee=p.Character; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=p.Character
        local bg=Instance.new("BillboardGui",p.Character); bg.AlwaysOnTop=true; bg.Size=UDim2.new(0,200,0,50); bg.StudsOffset=Vector3.new(0,2,0)
        local tl=Instance.new("TextLabel",bg); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Font=Config.ESP.Font; tl.TextSize=18
        ESPs[p]={hl=hl,bg=bg,tl=tl}
    end
    local d=ESPs[p]
    d.hl.FillColor=getESPColor(p); d.hl.FillTransparency=Config.ESP.FillTransparency
    d.hl.OutlineColor=getOutlineColor(p); d.hl.OutlineTransparency=Config.ESP.ShowOutline and Config.ESP.OutlineTransparency or 1
    d.tl.TextColor3=Config.ESP.TextColor
    
    local localPlayer = Players.LocalPlayer
    local localChar = localPlayer and localPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local targetChar = p and p.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    
    local distance = 0
    if localRoot and targetRoot then
        distance = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
    end
    
    local baseText = string.format("%s | HP:%d | %dm", getName(p), getHealth(p), distance)
    d.tl.Text = baseText
end

local function removeESP(p)
    if ESPs[p] then 
        if ESPs[p].hl and ESPs[p].hl.Parent then ESPs[p].hl:Destroy() end
        if ESPs[p].bg and ESPs[p].bg.Parent then ESPs[p].bg:Destroy() end
        ESPs[p]=nil 
    end
    if Lines[p] then Lines[p]:Remove(); Lines[p]=nil end
end

-- Функции движения
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

local function startLongJump()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    isLongJumping = true
    originalLongJumpPower = hum.JumpPower
    
    hum.JumpPower = MovementConfig.LongJump.JumpPower
    
    local function onCharacterAdded(newChar)
        local newHum = newChar:WaitForChild("Humanoid")
        if isLongJumping then
            newHum.JumpPower = MovementConfig.LongJump.JumpPower
        end
    end
    
    local characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(longJumpConnections, characterAddedConnection)
    
    local longJumpLoop = RunService.Heartbeat:Connect(function()
        if not isLongJumping then return end
        
        local currentChar = Players.LocalPlayer.Character
        local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        
        if currentHum and currentHum.JumpPower ~= MovementConfig.LongJump.JumpPower then
            currentHum.JumpPower = MovementConfig.LongJump.JumpPower
        end
    end)
    
    table.insert(longJumpConnections, longJumpLoop)
end

local function stopLongJump()
    isLongJumping = false
    
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = originalLongJumpPower
    end
    
    for _, connection in ipairs(longJumpConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            elseif typeof(connection) == "Instance" then
                pcall(function() connection:Destroy() end)
            end
        end
    end
    longJumpConnections = {}
end

local function startInfiniteJump()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    isInfiniteJumping = true
    lastJumpTime = 0
    
    local function onJumpRequest()
        if not isInfiniteJumping then return end
        
        local currentTime = tick()
        if currentTime - lastJumpTime < 0.1 then return end 
        
        lastJumpTime = currentTime
        
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Velocity = Vector3.new(0, MovementConfig.InfiniteJump.JumpPower, 0)
        
        task.spawn(function()
            task.wait(0.3)
            if bv and bv.Parent then
                bv:Destroy()
            end
        end)
    end
    
    local jumpConnection = hum.Jumping:Connect(onJumpRequest)
    table.insert(infiniteJumpConnections, jumpConnection)
    
    local function onInputBegan(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Space then
            onJumpRequest()
        end
    end
    
    local inputConnection = UserInputService.InputBegan:Connect(onInputBegan)
    table.insert(infiniteJumpConnections, inputConnection)
    
    local function onCharacterAdded(newChar)
        if isInfiniteJumping then
            task.wait(1) 
            startInfiniteJump() 
        end
    end
    
    local characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(infiniteJumpConnections, characterAddedConnection)
end

local function stopInfiniteJump()
    isInfiniteJumping = false
    lastJumpTime = 0
    
    for _, connection in ipairs(infiniteJumpConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            elseif typeof(connection) == "Instance" then
                pcall(function() connection:Destroy() end)
            end
        end
    end
    infiniteJumpConnections = {}
    
    local char = Players.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, child in pairs(root:GetChildren()) do
            if child:IsA("BodyVelocity") then
                child:Destroy()
            end
        end
    end
end

-- Функция создания интерфейса Main
local function createMainInterface(functionsContainer, currentY, createToggleSlider, createSlider, createDivider, createSectionHeader, createButton, createDropdown)
    createSectionHeader("MAIN FUNCTIONS")
    
    -- ESP секция
    createToggleSlider("ESP", Config.ESP.Enabled, function(v)
        Config.ESP.Enabled = v
        if v then
            print("ESP включен")
        else
            print("ESP выключен")
        end
    end)
    
    createToggleSlider("Team Check", Config.ESP.TeamCheck, function(v)
        Config.ESP.TeamCheck = v
    end)
    
    createToggleSlider("Show Outline", Config.ESP.ShowOutline, function(v)
        Config.ESP.ShowOutline = v
    end)
    
    createToggleSlider("Show Lines", Config.ESP.ShowLines, function(v)
        Config.ESP.ShowLines = v
    end)
    
    createToggleSlider("Rainbow Colors", Config.ESP.Rainbow, function(v)
        Config.ESP.Rainbow = v
    end)
    
    createDivider()
    
    -- Aimbot секция
    createToggleSlider("Aimbot", Config.Aimbot.Enabled, function(v)
        Config.Aimbot.Enabled = v
        if v then
            print("Aimbot включен")
        else
            print("Aimbot выключен")
        end
    end)
    
    createToggleSlider("Visibility Check", Config.Aimbot.VisibilityCheck, function(v)
        Config.Aimbot.VisibilityCheck = v
    end)
    
    createToggleSlider("FOV Rainbow", Config.Aimbot.FOVRainbow, function(v)
        Config.Aimbot.FOVRainbow = v
    end)
    
    createSlider("FOV", 50, 300, Config.Aimbot.FOV, function(v)
        Config.Aimbot.FOV = v
    end)
    
    createDivider()
    
    -- Movement секция
    createToggleSlider("Fly", MovementConfig.Fly.Enabled, function(v)
        MovementConfig.Fly.Enabled = v
        if v then
            startFly()
        else
            stopFly()
        end
    end)
    
    createSlider("Fly Speed", 0.1, 5, MovementConfig.Fly.Speed, function(v)
        MovementConfig.Fly.Speed = v
    end)
    
    createToggleSlider("SpeedHack", MovementConfig.Speed.Enabled, function(v)
        MovementConfig.Speed.Enabled = v
        if v then
            startSpeedHack()
        else
            stopSpeedHack()
        end
    end)
    
    createSlider("Speed Multiplier", 1, 10, MovementConfig.Speed.Speed, function(v)
        MovementConfig.Speed.Speed = v
    end)
    
    createToggleSlider("Use JumpPower Method", MovementConfig.Speed.UseJumpPower, function(v)
        MovementConfig.Speed.UseJumpPower = v
    end)
    
    createToggleSlider("Long Jump", MovementConfig.LongJump.Enabled, function(v)
        MovementConfig.LongJump.Enabled = v
        if v then
            startLongJump()
        else
            stopLongJump()
        end
    end)
    
    createSlider("Long Jump Power", 50, 300, MovementConfig.LongJump.JumpPower, function(v)
        MovementConfig.LongJump.JumpPower = v
    end)
    
    createToggleSlider("Infinite Jump", MovementConfig.InfiniteJump.Enabled, function(v)
        MovementConfig.InfiniteJump.Enabled = v
        if v then
            startInfiniteJump()
        else
            stopInfiniteJump()
        end
    end)
    
    createSlider("Infinite Jump Power", 10, 100, MovementConfig.InfiniteJump.JumpPower, function(v)
        MovementConfig.InfiniteJump.JumpPower = v
    end)
    
    createDivider()
    
    -- NoClip секция
    createToggleSlider("Force NoClip", MovementConfig.NoClip.Enabled, function(v)
        MovementConfig.NoClip.Enabled = v
        if v then
            startNoClip()
        else
            stopNoClip()
        end
    end)
    
    -- Teleport секция
    createToggleSlider("Teleport to Player", TeleportConfig.Enabled, function(v)
        TeleportConfig.Enabled = v
        if v then
            print("Teleport включен")
        else
            print("Teleport выключен")
        end
    end)
    
    createButton("Select Player for Teleport", function()
        print("Выберите игрока для телепорта")
        -- Здесь можно добавить логику выбора игрока
    end)
    
    return currentY
end

-- Экспорт функций
return {
    createMainInterface = createMainInterface,
    Config = Config,
    MovementConfig = MovementConfig,
    TeleportConfig = TeleportConfig,
    startFly = startFly,
    stopFly = stopFly,
    startNoClip = startNoClip,
    stopNoClip = stopNoClip,
    startSpeedHack = startSpeedHack,
    stopSpeedHack = stopSpeedHack,
    startLongJump = startLongJump,
    stopLongJump = stopLongJump,
    startInfiniteJump = startInfiniteJump,
    stopInfiniteJump = stopInfiniteJump,
}