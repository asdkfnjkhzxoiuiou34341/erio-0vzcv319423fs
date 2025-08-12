local MainModule = {}

-- Конфигурации
local Config = {
    ESP = {
        Enabled = true,
        TeamCheck = false,
        ShowOutline = true,
        ShowLines = false,
        Rainbow = false,
        FillColor = Color3.fromRGB(255,255,255),
        OutlineColor = Color3.fromRGB(255,255,255),
        TextColor = Color3.fromRGB(255,255,255),
        LineColor = Color3.fromRGB(255,255,255),
        FillTransparency = 0.5,
        OutlineTransparency = 0,
        Font = Enum.Font.SciFi,
        TeamColor = Color3.fromRGB(0,255,0),
        EnemyColor = Color3.fromRGB(255,0,0),
        ToggleKey = nil,
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        VisibilityCheck = true,
        FOV = 150,
        ToggleKey = nil,
        FOVColor = Color3.fromRGB(255,128,128),
        FOVRainbow = false,
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

-- Состояния
local isFlying = false
local flyConnections = {}
local isNoClipping = false
local noClipConnections = {}
local isSpeedHacking = false
local speedHackConnections = {}
local isLongJumping = false
local longJumpConnections = {}
local isInfiniteJumping = false
local infiniteJumpConnections = {}
local isTeleporting = false
local teleportConnections = {}

-- ESP переменные
local ESPs, Lines = {}, {}
local FOVCircle

-- Создание FOV круга
FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Основные функции ESP
local function getName(p)
    return p.Name
end

local function getHealth(p)
    local h = p.Character and p.Character:FindFirstChild("Humanoid")
    return (h and h.Health>0) and math.floor(h.Health) or 0
end

local function isAlive(p) 
    return getHealth(p)>0 
end

local function getRainbow() 
    return Color3.fromHSV((tick()%5)/5,1,1) 
end

local function getESPColor(p)
    if Config.ESP.Rainbow then return getRainbow() end
    if Config.ESP.TeamCheck then return (p.TeamColor==game.Players.LocalPlayer.TeamColor) and Config.ESP.TeamColor or Config.ESP.EnemyColor end
    return Config.ESP.FillColor
end

local function getOutlineColor(p)
    if Config.ESP.Rainbow then return getRainbow() end
    if Config.ESP.TeamCheck then return (p.TeamColor==game.Players.LocalPlayer.TeamColor) and Config.ESP.TeamColor or Config.ESP.EnemyColor end
    return Config.ESP.OutlineColor
end

local function rayVisible(p)
    if not Config.Aimbot.VisibilityCheck then return true end
    local cam = workspace.CurrentCamera
    local head = p.Character and p.Character:FindFirstChild("Head") 
    if not head then return false end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {game.Players.LocalPlayer.Character, p.Character}
    return not workspace:Raycast(cam.CFrame.Position, head.Position-cam.CFrame.Position, rp)
end

-- Функции ESP
local function createOrUpdateESP(p)
    if not p or not p.Character then return end
    
    if not ESPs[p] then
        local hl = Instance.new("Highlight")
        hl.Adornee = p.Character
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = p.Character
        
        local bg = Instance.new("BillboardGui", p.Character)
        bg.AlwaysOnTop = true
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 2, 0)
        
        local tl = Instance.new("TextLabel", bg)
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.BackgroundTransparency = 1
        tl.Font = Config.ESP.Font
        tl.TextSize = 18
        
        ESPs[p] = {hl = hl, bg = bg, tl = tl}
    end
    
    local d = ESPs[p]
    d.hl.FillColor = getESPColor(p)
    d.hl.FillTransparency = Config.ESP.FillTransparency
    d.hl.OutlineColor = getOutlineColor(p)
    d.hl.OutlineTransparency = Config.ESP.ShowOutline and Config.ESP.OutlineTransparency or 1
    d.tl.TextColor3 = Config.ESP.TextColor
    
    local localPlayer = game.Players.LocalPlayer
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
        ESPs[p] = nil 
    end
    if Lines[p] then Lines[p]:Remove(); Lines[p] = nil end
end

-- Функции полета
local function startFly()
    local plr = game.Players.LocalPlayer
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
    
    local inputDown = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
        elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
        elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
        elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1
        elseif input.KeyCode == Enum.KeyCode.Space then ctrl.u = 1
        elseif input.KeyCode == Enum.KeyCode.LeftControl then ctrl.d = -1 end
    end)
    
    local inputUp = game:GetService("UserInputService").InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
        elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
        elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
        elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0
        elseif input.KeyCode == Enum.KeyCode.Space then ctrl.u = 0
        elseif input.KeyCode == Enum.KeyCode.LeftControl then ctrl.d = 0 end
    end)
    
    local renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
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
    
    for _, connection in ipairs(flyConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    flyConnections = {}
end

-- Функции NoClip
local function startNoClip()
    local char = game.Players.LocalPlayer.Character
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
    
    local noClipLoop = game:GetService("RunService").Heartbeat:Connect(function()
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
    
    local char = game.Players.LocalPlayer.Character
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

-- Функции SpeedHack
local function startSpeedHack()
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    isSpeedHacking = true
    local originalWalkSpeed = hum.WalkSpeed
    local originalJumpPower = hum.JumpPower
    
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
    
    local characterAddedConnection = game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(speedHackConnections, characterAddedConnection)
    
    local speedLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not isSpeedHacking then return end
        
        local currentChar = game.Players.LocalPlayer.Character
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
    
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
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

-- Функции LongJump
local function startLongJump()
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    isLongJumping = true
    local originalLongJumpPower = hum.JumpPower
    
    hum.JumpPower = MovementConfig.LongJump.JumpPower
    
    local function onCharacterAdded(newChar)
        local newHum = newChar:WaitForChild("Humanoid")
        if isLongJumping then
            newHum.JumpPower = MovementConfig.LongJump.JumpPower
        end
    end
    
    local characterAddedConnection = game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(longJumpConnections, characterAddedConnection)
    
    local longJumpLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not isLongJumping then return end
        
        local currentChar = game.Players.LocalPlayer.Character
        local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        
        if currentHum and currentHum.JumpPower ~= MovementConfig.LongJump.JumpPower then
            currentHum.JumpPower = MovementConfig.LongJump.JumpPower
        end
    end)
    
    table.insert(longJumpConnections, longJumpLoop)
end

local function stopLongJump()
    isLongJumping = false
    
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = 50
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

-- Функции InfiniteJump
local function startInfiniteJump()
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    isInfiniteJumping = true
    local lastJumpTime = 0
    
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
    
    local inputConnection = game:GetService("UserInputService").InputBegan:Connect(onInputBegan)
    table.insert(infiniteJumpConnections, inputConnection)
    
    local function onCharacterAdded(newChar)
        if isInfiniteJumping then
            task.wait(1) 
            startInfiniteJump() 
        end
    end
    
    local characterAddedConnection = game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(infiniteJumpConnections, characterAddedConnection)
end

local function stopInfiniteJump()
    isInfiniteJumping = false
    
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
    
    local char = game.Players.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, child in pairs(root:GetChildren()) do
            if child:IsA("BodyVelocity") then
                child:Destroy()
            end
        end
    end
end

-- Функции телепортации
local function startTeleport()
    if not TeleportConfig.TargetPlayer then return end
    
    local char = game.Players.LocalPlayer.Character
    local targetChar = TeleportConfig.TargetPlayer.Character
    if not char or not targetChar then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end
    
    isTeleporting = true
    TeleportConfig.OriginalPosition = root.Position
    
    if not isNoClipping then
        startNoClip()
    end
    
    local teleportLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not isTeleporting or not targetChar or not targetChar.Parent then
            return
        end
        
        local currentTargetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if currentTargetRoot then
            local targetPos = currentTargetRoot.Position
            local currentPos = root.Position
            local distance = (targetPos - currentPos).Magnitude
            
            if distance > 1.5 then
                local direction = (targetPos - currentPos).Unit
                local bv = root:FindFirstChild("BodyVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity", root)
                    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                end
                bv.Velocity = direction * TeleportConfig.TeleportSpeed
            else
                local bv = root:FindFirstChild("BodyVelocity")
                if bv then
                    bv:Destroy()
                end
                isTeleporting = false
            end
        end
    end)
    
    table.insert(teleportConnections, teleportLoop)
end

local function stopTeleport()
    isTeleporting = false
    
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    
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
    
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
end

-- Функция создания GUI
function MainModule.createGUI(container)
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
    
    -- ESP Settings
    createSectionHeader("🔷ESP Settings")
    createToggleSlider("ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
    createToggleSlider("Team Check", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
    createToggleSlider("Show Outline", Config.ESP.ShowOutline, function(v) Config.ESP.ShowOutline = v end)
    createToggleSlider("Show Lines", Config.ESP.ShowLines, function(v) Config.ESP.ShowLines = v end)
    createToggleSlider("Rainbow Colors", Config.ESP.Rainbow, function(v) Config.ESP.Rainbow = v end)
    
    createDivider()
    
    -- Aimbot Settings
    createSectionHeader("🔷Aimbot Settings")
    createToggleSlider("Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
    createToggleSlider("Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
    createToggleSlider("Visibility Check", Config.Aimbot.VisibilityCheck, function(v) Config.Aimbot.VisibilityCheck = v end)
    createSlider("FOV Radius", 10, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
    createToggleSlider("FOV Rainbow", Config.Aimbot.FOVRainbow, function(v) Config.Aimbot.FOVRainbow = v end)
    
    createDivider()
    
    -- Fly Settings
    createSectionHeader("🟨 Fly Settings")
    createToggleSlider("Fly", MovementConfig.Fly.Enabled, function(v)
        MovementConfig.Fly.Enabled = v
        if v then startFly() else stopFly() end
    end)
    createSlider("Fly Speed", 0.1, 10, MovementConfig.Fly.Speed, function(v)
        MovementConfig.Fly.Speed = v
    end)
    
    createDivider()
    
    -- NoClip Settings
    createSectionHeader("🟪 NoClip Settings")
    createToggleSlider("NoClip", isNoClipping, function(v)
        if v then startNoClip() else stopNoClip() end
    end)
    
    createDivider()
    
    -- SpeedHack Settings
    createSectionHeader("🟦 SpeedHack Settings")
    createToggleSlider("SpeedHack", MovementConfig.Speed.Enabled, function(v)
        MovementConfig.Speed.Enabled = v
        if v then startSpeedHack() else stopSpeedHack() end
    end)
    createToggleSlider("Use JumpPower Method", MovementConfig.Speed.UseJumpPower, function(v)
        MovementConfig.Speed.UseJumpPower = v
        if MovementConfig.Speed.Enabled then
            stopSpeedHack()
            startSpeedHack()
        end
    end)
    createSlider("SpeedHack Speed", 0.1, 10, MovementConfig.Speed.Speed, function(v)
        MovementConfig.Speed.Speed = v
        if MovementConfig.Speed.Enabled then
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v * 16
                if MovementConfig.Speed.UseJumpPower then
                    hum.JumpPower = v * 50
                end
            end
        end
    end)
    
    createDivider()
    
    -- Jump Settings
    createSectionHeader("🦘 Jump Settings")
    createToggleSlider("Long Jump", MovementConfig.LongJump.Enabled, function(v)
        MovementConfig.LongJump.Enabled = v
        if v then startLongJump() else stopLongJump() end
    end)
    createSlider("Long Jump Power", 50, 500, MovementConfig.LongJump.JumpPower, function(v)
        MovementConfig.LongJump.JumpPower = v
        if MovementConfig.LongJump.Enabled then
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = v
            end
        end
    end)
    
    createToggleSlider("Infinite Jump", MovementConfig.InfiniteJump.Enabled, function(v)
        MovementConfig.InfiniteJump.Enabled = v
        if v then startInfiniteJump() else stopInfiniteJump() end
    end)
    createSlider("Infinite Jump Power", 20, 150, MovementConfig.InfiniteJump.JumpPower, function(v)
        MovementConfig.InfiniteJump.JumpPower = v
    end)
    
    createDivider()
    
    -- Teleport Settings
    createSectionHeader("🟩 Teleport Settings")
    createButton("Select Player", function()
        -- Простая реализация выбора игрока
        local players = game.Players:GetPlayers()
        for _, player in ipairs(players) do
            if player ~= game.Players.LocalPlayer then
                TeleportConfig.TargetPlayer = player
                TeleportConfig.SelectedPlayerName = player.Name
                break
            end
        end
    end)
    
    createToggleSlider("Teleport", TeleportConfig.Enabled, function(v)
        TeleportConfig.Enabled = v
        if v then
            if TeleportConfig.TargetPlayer then
                startTeleport()
            end
        else
            stopTeleport()
        end
    end)
    
    -- ESP Loop
    game:GetService("RunService").RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player == game.Players.LocalPlayer then continue end
            
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and root then
                if Config.ESP.Enabled then
                    createOrUpdateESP(player)
                    if Config.ESP.ShowLines then
                        if not Lines[player] then
                            local ln = Drawing.new("Line")
                            ln.Thickness = 2
                            ln.Transparency = 1
                            Lines[player] = ln
                        end
                        local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                        Lines[player].Visible = onScreen
                        if onScreen then
                            Lines[player].From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                            Lines[player].To = Vector2.new(pos.X, pos.Y)
                            Lines[player].Color = getESPColor(player)
                        end
                    elseif Lines[player] then
                        Lines[player].Visible = false
                    end
                else
                    removeESP(player)
                end
            else
                removeESP(player)
            end
        end
        
        -- Aimbot
        if Config.Aimbot.Enabled then
            local closest, minDist = nil, Config.Aimbot.FOV
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p == game.Players.LocalPlayer then continue end
                if Config.Aimbot.TeamCheck and p.Team == game.Players.LocalPlayer.Team then continue end
                if not isAlive(p) then continue end
                if Config.Aimbot.VisibilityCheck and not rayVisible(p) then continue end

                local head = p.Character and p.Character:FindFirstChild("Head")
                if not head then continue end
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if not onScreen then continue end

                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if dist < minDist then
                    closest = head
                    minDist = dist
                end
            end
            
            if closest then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, closest.Position)
            end
        end
        
        -- FOV Circle
        FOVCircle.Visible = Config.Aimbot.Enabled
        FOVCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        FOVCircle.Color = Config.Aimbot.FOVRainbow and getRainbow() or Config.Aimbot.FOVColor
        FOVCircle.Radius = Config.Aimbot.FOV
    end)
    
    -- Hotkeys
    game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if Config.ESP.ToggleKey and input.KeyCode == Config.ESP.ToggleKey then
                Config.ESP.Enabled = not Config.ESP.Enabled
                print("ESP toggled:", Config.ESP.Enabled)
            elseif Config.Aimbot.ToggleKey and input.KeyCode == Config.Aimbot.ToggleKey then
                Config.Aimbot.Enabled = not Config.Aimbot.Enabled
                print("Aimbot toggled:", Config.Aimbot.Enabled)
            end
        end
    end)
    
    return currentY
end

return MainModule