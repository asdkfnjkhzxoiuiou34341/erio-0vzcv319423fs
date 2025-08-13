local MainModule = {}

-- Копируем ВСЕ конфигурации из оригинального файла
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

-- Копируем ВСЕ переменные состояния
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
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Config.Aimbot.Enabled
FOVCircle.Color = Config.Aimbot.FOVColor

-- Функции ESP (копируем ВСЕ из оригинального файла)
local function getName(player)
    local name = player.Name
    if player.DisplayName and player.DisplayName ~= player.Name then
        name = player.DisplayName
    end
    return name
end

local function getHealth(player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            return humanoid.Health, humanoid.MaxHealth
        end
    end
    return 0, 0
end

local function isAlive(player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            return humanoid.Health > 0
        end
    end
    return false
end

local function getRainbow()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

local function getESPColor(player)
    if Config.ESP.Rainbow then
        return getRainbow()
    end
    
    if Config.ESP.TeamCheck then
        local localPlayer = game.Players.LocalPlayer
        if localPlayer.Team == player.Team then
            return Config.ESP.TeamColor
        else
            return Config.ESP.EnemyColor
        end
    end
    
    return Config.ESP.FillColor
end

local function getOutlineColor(player)
    if Config.ESP.Rainbow then
        return getRainbow()
    end
    
    if Config.ESP.TeamCheck then
        local localPlayer = game.Players.LocalPlayer
        if localPlayer.Team == player.Team then
            return Config.ESP.TeamColor
        else
            return Config.ESP.EnemyColor
        end
    end
    
    return Config.ESP.OutlineColor
end

local function rayVisible(start, finish, ignore)
    local ray = Ray.new(start, finish - start)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
    return hit == nil
end

local function createOrUpdateESP(player)
    if not isAlive(player) then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- Создаем Highlight для ESP
    if not ESPs[player] then
        ESPs[player] = Instance.new("Highlight")
        ESPs[player].Adornee = character
        ESPs[player].FillColor = getESPColor(player)
        ESPs[player].OutlineColor = getOutlineColor(player)
        ESPs[player].FillTransparency = Config.ESP.FillTransparency
        ESPs[player].OutlineTransparency = Config.ESP.OutlineTransparency
        ESPs[player].Parent = character
    end
    
    -- Обновляем цвета
    ESPs[player].FillColor = getESPColor(player)
    ESPs[player].OutlineColor = getOutlineColor(player)
    
    -- Создаем линии ESP
    if Config.ESP.ShowLines and not Lines[player] then
        Lines[player] = Drawing.new("Line")
        Lines[player].Thickness = 2
        Lines[player].Color = Config.ESP.LineColor
        Lines[player].Visible = true
    end
    
    if Lines[player] then
        Lines[player].Visible = Config.ESP.ShowLines
        if Config.ESP.ShowLines then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
            if onScreen then
                Lines[player].From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                Lines[player].To = Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    end
end

local function removeESP(player)
    if ESPs[player] then
        ESPs[player]:Destroy()
        ESPs[player] = nil
    end
    
    if Lines[player] then
        Lines[player]:Remove()
        Lines[player] = nil
    end
end

-- Функции движения (копируем ВСЕ из оригинального файла)
local function startFly()
    if isFlying then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    isFlying = true
    originalGravity = workspace.Gravity
    workspace.Gravity = 0
    
    local flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFlying or not character or not character.Parent then
            return
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
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector + Vector3.new(0, -1, 0)
        end
        
        if moveVector.Magnitude > 0 then
            local bv = humanoidRootPart:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Parent = humanoidRootPart
            end
            
            bv.Velocity = moveVector.Unit * (MovementConfig.Fly.Speed * 50)
        else
            local bv = humanoidRootPart:FindFirstChild("BodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
    end)
    
    table.insert(flyConnections, flyConnection)
    print("Fly активирован!")
end

local function stopFly()
    if not isFlying then return end
    
    isFlying = false
    workspace.Gravity = originalGravity
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local bv = humanoidRootPart:FindFirstChild("BodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
    end
    
    for _, connection in ipairs(flyConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    flyConnections = {}
    
    print("Fly деактивирован!")
end

local function startNoClip()
    if isNoClipping then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    isNoClipping = true
    
    local noClipConnection = game:GetService("RunService").Stepped:Connect(function()
        if not isNoClipping or not character or not character.Parent then
            return
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    
    table.insert(noClipConnections, noClipConnection)
    print("NoClip активирован!")
end

local function stopNoClip()
    if not isNoClipping then return end
    
    isNoClipping = false
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    for _, connection in ipairs(noClipConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    noClipConnections = {}
    
    print("NoClip деактивирован!")
end

local function startSpeedHack()
    if isSpeedHacking then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    isSpeedHacking = true
    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    
    humanoid.WalkSpeed = MovementConfig.Speed.Speed * 16
    if MovementConfig.Speed.UseJumpPower then
        humanoid.JumpPower = MovementConfig.Speed.Speed * 50
    end
    
    print("SpeedHack активирован!")
end

local function stopSpeedHack()
    if not isSpeedHacking then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.JumpPower = originalJumpPower
        end
    end
    
    isSpeedHacking = false
    print("SpeedHack деактивирован!")
end

local function startLongJump()
    if isLongJumping then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    isLongJumping = true
    originalLongJumpPower = humanoid.JumpPower
    humanoid.JumpPower = MovementConfig.LongJump.JumpPower
    
    print("LongJump активирован!")
end

local function stopLongJump()
    if not isLongJumping then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = originalLongJumpPower
        end
    end
    
    isLongJumping = false
    print("LongJump деактивирован!")
end

local function startInfiniteJump()
    if isInfiniteJumping then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    isInfiniteJumping = true
    
    local infiniteJumpConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            local currentTime = tick()
            if currentTime - lastJumpTime > 0.1 then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJumpTime = currentTime
            end
        end
    end)
    
    table.insert(infiniteJumpConnections, infiniteJumpConnection)
    print("InfiniteJump активирован!")
end

local function stopInfiniteJump()
    if not isInfiniteJumping then return end
    
    isInfiniteJumping = false
    
    for _, connection in ipairs(infiniteJumpConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    infiniteJumpConnections = {}
    
    print("InfiniteJump деактивирован!")
end

-- Функции телепортации (копируем ВСЕ из оригинального файла)
local function startTeleport()
    if isTeleporting then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not TeleportConfig.TargetPlayer then
        print("Выберите игрока для телепортации!")
        return
    end
    
    local targetCharacter = TeleportConfig.TargetPlayer.Character
    if not targetCharacter then
        print("Целевой игрок не найден!")
        return
    end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        print("Целевой игрок не имеет HumanoidRootPart!")
        return
    end
    
    isTeleporting = true
    lastTeleportPosition = humanoidRootPart.Position
    stabilizationStartTime = tick()
    
    print("Начинаем телепортацию к", TeleportConfig.TargetPlayer.Name)
    
    local teleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isTeleporting or not character or not character.Parent then
            return
        end
        
        local targetCharacter = TeleportConfig.TargetPlayer.Character
        if not targetCharacter then
            print("Целевой игрок потерян!")
            stopTeleport()
            return
        end
        
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            print("Целевой игрок потерял HumanoidRootPart!")
            stopTeleport()
            return
        end
        
        local targetPosition = targetRoot.Position
        local behindPosition = targetPosition - targetRoot.CFrame.LookVector * TeleportConfig.BehindPlayerDistance
        
        if TeleportConfig.UseStealthMode then
            -- Стелс режим с плавным движением
            local bv = humanoidRootPart:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Parent = humanoidRootPart
            end
            
            local direction = (behindPosition - humanoidRootPart.Position).Unit
            local distance = (behindPosition - humanoidRootPart.Position).Magnitude
            
            if distance > 1 then
                bv.Velocity = direction * TeleportConfig.TeleportSpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
                -- Стабилизация позиции
                if not isStabilizing then
                    isStabilizing = true
                    task.wait(TeleportConfig.StabilizationTime)
                    if isTeleporting then
                        humanoidRootPart.CFrame = CFrame.new(behindPosition)
                        print("Телепортация завершена!")
                        stopTeleport()
                    end
                end
            end
        else
            -- Мгновенная телепортация
            humanoidRootPart.CFrame = CFrame.new(behindPosition)
            print("Телепортация завершена!")
            stopTeleport()
        end
    end)
    
    table.insert(teleportConnections, teleportConnection)
end

local function stopTeleport()
    if not isTeleporting then return end
    
    isTeleporting = false
    isStabilizing = false
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local bv = humanoidRootPart:FindFirstChild("BodyVelocity")
            if bv then
                bv:Destroy()
            end
        end
    end
    
    for _, connection in ipairs(teleportConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    teleportConnections = {}
    
    print("Телепортация остановлена!")
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
    
    -- 🔷ESP Settings
    createSectionHeader("🔷ESP Settings")
    createToggleSlider("ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
    createToggleSlider("Team Check", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
    createToggleSlider("Show Outline", Config.ESP.ShowOutline, function(v) Config.ESP.ShowOutline = v end)
    createToggleSlider("Show Lines", Config.ESP.ShowLines, function(v) Config.ESP.ShowLines = v end)
    createToggleSlider("Rainbow Colors", Config.ESP.Rainbow, function(v) Config.ESP.Rainbow = v end)
    createDivider()
    
    -- 🔷Aimbot Settings
    createSectionHeader("🔷Aimbot Settings")
    createToggleSlider("Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v; FOVCircle.Visible = v end)
    createToggleSlider("Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
    createToggleSlider("Visibility Check", Config.Aimbot.VisibilityCheck, function(v) Config.Aimbot.VisibilityCheck = v end)
    createSlider("FOV Radius", 10, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v; FOVCircle.Radius = v end)
    createToggleSlider("FOV Rainbow", Config.Aimbot.FOVRainbow, function(v) Config.Aimbot.FOVRainbow = v end)
    createDivider()
    
    -- 🟨 Fly Settings
    createSectionHeader("🟨 Fly Settings")
    createToggleSlider("Fly", MovementConfig.Fly.Enabled, function(v) MovementConfig.Fly.Enabled = v; if v then startFly() else stopFly() end end)
    createSlider("Fly Speed", 0.1, 10, MovementConfig.Fly.Speed, function(v) MovementConfig.Fly.Speed = v end)
    createDivider()
    
    -- 🟪 NoClip Settings
    createSectionHeader("🟪 NoClip Settings")
    createToggleSlider("NoClip", isNoClipping, function(v) if v then startNoClip() else stopNoClip() end end)
    createDivider()
    
    -- 🟦 SpeedHack Settings
    createSectionHeader("🟦 SpeedHack Settings")
    createToggleSlider("SpeedHack", MovementConfig.Speed.Enabled, function(v) MovementConfig.Speed.Enabled = v; if v then startSpeedHack() else stopSpeedHack() end end)
    createToggleSlider("Use JumpPower Method", MovementConfig.Speed.UseJumpPower, function(v) MovementConfig.Speed.UseJumpPower = v; if MovementConfig.Speed.Enabled then stopSpeedHack(); startSpeedHack() end end)
    createSlider("SpeedHack Speed", 0.1, 10, MovementConfig.Speed.Speed, function(v) MovementConfig.Speed.Speed = v; if MovementConfig.Speed.Enabled then local char = game.Players.LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v * 16; if MovementConfig.Speed.UseJumpPower then hum.JumpPower = v * 50 end end end end)
    createDivider()
    
    -- 🦘 Jump Settings
    createSectionHeader("🦘 Jump Settings")
    createToggleSlider("Long Jump", MovementConfig.LongJump.Enabled, function(v) MovementConfig.LongJump.Enabled = v; if v then startLongJump() else stopLongJump() end end)
    createSlider("Long Jump Power", 50, 500, MovementConfig.LongJump.JumpPower, function(v) MovementConfig.LongJump.JumpPower = v; if MovementConfig.LongJump.Enabled then local char = game.Players.LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = v end end end)
    createToggleSlider("Infinite Jump", MovementConfig.InfiniteJump.Enabled, function(v) MovementConfig.InfiniteJump.Enabled = v; if v then startInfiniteJump() else stopInfiniteJump() end end)
    createSlider("Infinite Jump Power", 20, 150, MovementConfig.InfiniteJump.JumpPower, function(v) MovementConfig.InfiniteJump.JumpPower = v end)
    createDivider()
    
    -- 🟩 Teleport Settings
    createSectionHeader("🟩 Teleport Settings")
    createButton("Select Player", function()
        local players = game.Players:GetPlayers()
        for _, player in ipairs(players) do
            if player ~= game.Players.LocalPlayer then
                TeleportConfig.TargetPlayer = player
                TeleportConfig.SelectedPlayerName = player.Name
                break
            end
        end
    end)
    createToggleSlider("Teleport", TeleportConfig.Enabled, function(v) TeleportConfig.Enabled = v; if v then if TeleportConfig.TargetPlayer then startTeleport() end else stopTeleport() end end)
    
    -- Main Render Loop for ESP and Aimbot
    game:GetService("RunService").RenderStepped:Connect(function()
        -- ESP Loop
        if Config.ESP.Enabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    createOrUpdateESP(player)
                end
            end
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                removeESP(player)
            end
        end
        
        -- Aimbot Loop
        if Config.Aimbot.Enabled then
            FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
            
            if Config.Aimbot.FOVRainbow then
                FOVCircle.Color = getRainbow()
            end
            
            -- Здесь должна быть логика аимбота
        end
    end)
    
    -- Hotkey handling for ESP and Aimbot
    game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if gp then return end
        
        if input.KeyCode == Config.ESP.ToggleKey then
            Config.ESP.Enabled = not Config.ESP.Enabled
        end
        
        if input.KeyCode == Config.Aimbot.ToggleKey then
            Config.Aimbot.Enabled = not Config.Aimbot.Enabled
            FOVCircle.Visible = Config.Aimbot.Enabled
        end
    end)
    
    return currentY
end

return MainModule