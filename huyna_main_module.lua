local M = {}

-- ctx should include:
-- functionsContainer, currentY, padding
-- helpers: createKeyBindButton, createToggleSlider, createSlider, createSpeedInput, createDivider, createSectionHeader, createButton, createDropdown
-- env: getText, Players, Config, MovementConfig, TeleportConfig
-- actions: startFly, stopFly, startNoClip, stopNoClip, startSpeedHack, stopSpeedHack, startLongJump, stopLongJump, startInfiniteJump, stopInfiniteJump, startTeleport, stopTeleport
-- misc: teleportBtnRef (function to export created teleportBtn), getSelectedTab (function returning current tab name)

function M.buildMain(ctx)
    local functionsContainer = ctx.functionsContainer
    local currentY = ctx.currentY or 0
    local padding = ctx.padding or 8

    local createKeyBindButton = ctx.createKeyBindButton
    local createToggleSlider = ctx.createToggleSlider
    local createSlider = ctx.createSlider
    local createSpeedInput = ctx.createSpeedInput
    local createDivider = ctx.createDivider
    local createSectionHeader = ctx.createSectionHeader
    local createButton = ctx.createButton

    local getText = ctx.getText
    local Players = ctx.Players
    local Config = ctx.Config
    local MovementConfig = ctx.MovementConfig
    local TeleportConfig = ctx.TeleportConfig

    local startFly, stopFly = ctx.startFly, ctx.stopFly
    local startNoClip, stopNoClip = ctx.startNoClip, ctx.stopNoClip
    local startSpeedHack, stopSpeedHack = ctx.startSpeedHack, ctx.stopSpeedHack
    local startLongJump, stopLongJump = ctx.startLongJump, ctx.stopLongJump
    local startInfiniteJump, stopInfiniteJump = ctx.startInfiniteJump, ctx.stopInfiniteJump
    local startTeleport, stopTeleport = ctx.startTeleport, ctx.stopTeleport

    -- Hotkeys
    createKeyBindButton("ESP", Config.ESP.ToggleKey, function(newKey)
        Config.ESP.ToggleKey = newKey
    end)

    createKeyBindButton("Aimbot", Config.Aimbot.ToggleKey, function(newKey)
        Config.Aimbot.ToggleKey = newKey
    end)

    createKeyBindButton("Fly", MovementConfig.Fly.ToggleKey, function(newKey)
        MovementConfig.Fly.ToggleKey = newKey
    end)

    createKeyBindButton("NoClip", MovementConfig.NoClip.ToggleKey, function(newKey)
        MovementConfig.NoClip.ToggleKey = newKey
    end)

    createKeyBindButton("SpeedHack", MovementConfig.Speed.ToggleKey, function(newKey)
        MovementConfig.Speed.ToggleKey = newKey
    end)

    createKeyBindButton("Teleport", TeleportConfig.ToggleKey, function(newKey)
        TeleportConfig.ToggleKey = newKey
    end)

    createDivider()

    createSectionHeader("🔷ESP Settings")
    createToggleSlider(getText("ESP"), Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
    createToggleSlider(getText("TeamCheck"), Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
    createToggleSlider(getText("ShowOutline"), Config.ESP.ShowOutline, function(v) Config.ESP.ShowOutline = v end)
    createToggleSlider(getText("ShowLines"), Config.ESP.ShowLines, function(v) Config.ESP.ShowLines = v end)
    createToggleSlider(getText("RainbowColors"), Config.ESP.Rainbow, function(v) Config.ESP.Rainbow = v end)

    -- Inline simple color pickers to avoid extra requires
    local function simpleColorPicker(labelText, currentColor, onChange)
        local lbl = Instance.new("TextLabel", functionsContainer)
        lbl.Text = labelText
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.Position = UDim2.new(0, 5, 0, currentY)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        currentY = currentY + 20 + padding

        local colors = {
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 165, 0),
        }

        local row = Instance.new("Frame", functionsContainer)
        row.Size = UDim2.new(1, -10, 0, 28)
        row.Position = UDim2.new(0, 5, 0, currentY)
        row.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", row)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.Padding = UDim.new(0, 8)

        for _, c in ipairs(colors) do
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 30, 0, 24)
            btn.BackgroundColor3 = c
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                onChange(c)
            end)
        end

        currentY = currentY + 28 + padding
    end

    simpleColorPicker("Fill Color", Config.ESP.FillColor, function(c) Config.ESP.FillColor = c end)
    simpleColorPicker("Outline Color", Config.ESP.OutlineColor, function(c) Config.ESP.OutlineColor = c end)
    simpleColorPicker("Text Color", Config.ESP.TextColor, function(c) Config.ESP.TextColor = c end)

    createDivider()

    createSectionHeader("🔷Aimbot Settings")
    createToggleSlider(getText("Aimbot"), Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
    createToggleSlider(getText("TeamCheck"), Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
    createToggleSlider(getText("VisibilityCheck"), Config.Aimbot.VisibilityCheck, function(v) Config.Aimbot.VisibilityCheck = v end)
    createSlider("FOV Radius", 10, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
    createToggleSlider(getText("FOVRainbow"), Config.Aimbot.FOVRainbow, function(v) Config.Aimbot.FOVRainbow = v end)
    createButton("Pick Aimbot FOV Color", function()
        -- noop placeholder; color picker is created above by helper module
    end)

    createDivider()

    createSectionHeader("🟨 Fly Settings")
    createToggleSlider("Fly", MovementConfig.Fly.Enabled, function(v)
        MovementConfig.Fly.Enabled = v
        if v then startFly() else stopFly() end
    end)

    createSlider("Fly Speed", 0.1, 10, MovementConfig.Fly.Speed, function(v)
        MovementConfig.Fly.Speed = v
    end)

    createSpeedInput("Custom Fly Speed", MovementConfig.Fly.Speed, function(v)
        MovementConfig.Fly.Speed = v
    end)

    createDivider()

    createSectionHeader("🟪 NoClip Settings")
    local noClipStatusLabel = Instance.new("TextLabel", functionsContainer)
    noClipStatusLabel.Size = UDim2.new(1, -10, 0, 20)
    noClipStatusLabel.Position = UDim2.new(0, 5, 0, currentY)
    noClipStatusLabel.Text = "NoClip Status: OFF"
    noClipStatusLabel.Font = Enum.Font.GothamBold
    noClipStatusLabel.TextSize = 12
    noClipStatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
    noClipStatusLabel.BackgroundTransparency = 1
    noClipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentY = currentY + 20 + padding

    createToggleSlider("Force NoClip", false, function(v)
        if v then
            startNoClip()
            noClipStatusLabel.Text = "NoClip Status: ON"
            noClipStatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        else
            stopNoClip()
            noClipStatusLabel.Text = "NoClip Status: OFF"
            noClipStatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        end
    end)

    createDivider()

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
            local char = Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v * 16
                if MovementConfig.Speed.UseJumpPower then
                    hum.JumpPower = v * 50
                end
            end
        end
    end)

    createSpeedInput("Custom SpeedHack Speed", MovementConfig.Speed.Speed, function(v)
        MovementConfig.Speed.Speed = v
        if MovementConfig.Speed.Enabled then
            local char = Players.LocalPlayer.Character
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
    createToggleSlider(getText("LongJump"), MovementConfig.LongJump.Enabled, function(v)
        MovementConfig.LongJump.Enabled = v
        if v then startLongJump() else stopLongJump() end
    end)

    createSlider("Long Jump Power", 50, 500, MovementConfig.LongJump.JumpPower, function(v)
        MovementConfig.LongJump.JumpPower = v
        if MovementConfig.LongJump.Enabled then
            local char = Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = v
            end
        end
    end)

    createToggleSlider(getText("InfiniteJump"), MovementConfig.InfiniteJump.Enabled, function(v)
        MovementConfig.InfiniteJump.Enabled = v
        if v then startInfiniteJump() else stopInfiniteJump() end
    end)

    createSlider("Infinite Jump Power", 20, 150, MovementConfig.InfiniteJump.JumpPower, function(v)
        MovementConfig.InfiniteJump.JumpPower = v
    end)

    createDivider()

    -- Teleport Settings
    createSectionHeader("🟩 Teleport Settings")

    local selectedPlayerLabel = Instance.new("TextLabel", functionsContainer)
    selectedPlayerLabel.Size = UDim2.new(1, -10, 0, 24)
    selectedPlayerLabel.Position = UDim2.new(0, 5, 0, currentY)
    selectedPlayerLabel.Text = getText("SelectedPlayer") .. ": " .. (TeleportConfig.SelectedPlayerName or "None")
    selectedPlayerLabel.Font = Enum.Font.GothamBold
    selectedPlayerLabel.TextSize = 14
    selectedPlayerLabel.TextColor3 = Color3.new(1,1,1)
    selectedPlayerLabel.BackgroundTransparency = 1
    selectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentY = currentY + 24 + padding

    local teleportBtn = Instance.new("TextButton", functionsContainer)
    teleportBtn.Size = UDim2.new(1, -10, 0, 28)
    teleportBtn.Position = UDim2.new(0, 5, 0, currentY)
    teleportBtn.Text = getText("StartTeleport")
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.TextSize = 14
    teleportBtn.TextColor3 = Color3.new(1,1,1)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    teleportBtn.AutoButtonColor = false
    Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0,6)
    currentY = currentY + 28 + padding

    if ctx.teleportBtnRef then ctx.teleportBtnRef(teleportBtn) end

    teleportBtn.MouseButton1Click:Connect(function()
        if not TeleportConfig.TargetPlayer then
            teleportBtn.Text = "Select player first!"
            task.wait(2)
            teleportBtn.Text = "START TELEPORT"
            return
        end

        if TeleportConfig.Enabled then
            stopTeleport()
            TeleportConfig.Enabled = false
            teleportBtn.Text = getText("StartTeleport")
            teleportBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        else
            startTeleport()
            TeleportConfig.Enabled = true
            teleportBtn.Text = getText("StopTeleport")
            teleportBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
        end
    end)

    local playerButtons = {}
    local playerListStartY = currentY

    local function createPlayerList()
        for _, btn in pairs(playerButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        playerButtons = {}

        currentY = playerListStartY

        local allPlayers = Players:GetPlayers()
        local playerList = {}

        for _, player in ipairs(allPlayers) do
            if player ~= Players.LocalPlayer then
                table.insert(playerList, player)
            end
        end

        table.sort(playerList, function(a, b)
            return string.lower(a.Name) < string.lower(b.Name)
        end)

        for _, player in ipairs(playerList) do
            local playerBtn = Instance.new("TextButton", functionsContainer)
            playerBtn.Size = UDim2.new(1, -10, 0, 24)
            playerBtn.Position = UDim2.new(0, 5, 0, currentY)
            playerBtn.Text = player.Name
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.TextSize = 12
            playerBtn.TextColor3 = Color3.new(1,1,1)
            playerBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            playerBtn.AutoButtonColor = false
            Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0,4)
            currentY = currentY + 24 + padding

            table.insert(playerButtons, playerBtn)

            playerBtn.MouseButton1Click:Connect(function()
                TeleportConfig.TargetPlayer = player
                TeleportConfig.SelectedPlayerName = player.Name
                selectedPlayerLabel.Text = getText("SelectedPlayer") .. ": " .. player.Name

                for _, child in pairs(functionsContainer:GetChildren()) do
                    if child:IsA("TextButton") and child.Text == player.Name then
                        child.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    elseif child:IsA("TextButton") and child.Text ~= "START TELEPORT" and child.Text ~= "STOP TELEPORT" and child.Text ~= player.Name then
                        child.BackgroundColor3 = Color3.fromRGB(40,40,40)
                    end
                end
            end)
        end
    end

    createPlayerList()

    task.spawn(function()
        while true do
            task.wait(2)
            local tab = (ctx.getSelectedTab and ctx.getSelectedTab()) or "Main"
            if tab == "Main" then
                createPlayerList()
            end
        end
    end)

    return currentY
end

function M.buildSettings(ctx)
    local functionsContainer = ctx.functionsContainer
    local currentY = ctx.currentY or 0
    local padding = ctx.padding or 8

    local createDivider = ctx.createDivider
    local createDropdown = ctx.createDropdown
    local getText = ctx.getText

    local MenuSettings = ctx.MenuSettings
    local updateAccentColor = ctx.updateAccentColor
    local updateAllTexts = ctx.updateAllTexts

    createDivider()

    local accentColorLabel = Instance.new("TextLabel", functionsContainer)
    accentColorLabel.Text = getText("AccentColor")
    accentColorLabel.TextColor3 = Color3.new(1,1,1)
    accentColorLabel.BackgroundTransparency = 1
    accentColorLabel.Size = UDim2.new(1, -10, 0, 20)
    accentColorLabel.Position = UDim2.new(0, 5, 0, currentY)
    accentColorLabel.Font = Enum.Font.Gotham
    accentColorLabel.TextSize = 14
    accentColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentY = currentY + 20 + padding

    local accentColors = {
        Color3.fromRGB(0, 150, 0),
        Color3.fromRGB(0, 100, 255),
        Color3.fromRGB(255, 0, 100),
        Color3.fromRGB(255, 150, 0),
        Color3.fromRGB(150, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 50, 50),
    }

    local colorRow = Instance.new("Frame", functionsContainer)
    colorRow.Size = UDim2.new(1, -10, 0, 35)
    colorRow.Position = UDim2.new(0, 5, 0, currentY)
    colorRow.BackgroundTransparency = 1

    local colorLayout = Instance.new("UIListLayout", colorRow)
    colorLayout.FillDirection = Enum.FillDirection.Horizontal
    colorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    colorLayout.Padding = UDim.new(0, 8)

    for _, color in pairs(accentColors) do
        local colorBtn = Instance.new("TextButton", colorRow)
        colorBtn.Size = UDim2.new(0, 30, 0, 30)
        colorBtn.BackgroundColor3 = color
        colorBtn.Text = ""
        colorBtn.AutoButtonColor = false
        colorBtn.BorderSizePixel = 0

        local colorCorner = Instance.new("UICorner", colorBtn)
        colorCorner.CornerRadius = UDim.new(0, 6)

        if MenuSettings.AccentColor == color then
            local highlight = Instance.new("UIStroke", colorBtn)
            highlight.Color = Color3.new(1, 1, 1)
            highlight.Thickness = 2
        end

        colorBtn.MouseButton1Click:Connect(function()
            MenuSettings.AccentColor = color
            if updateAccentColor then updateAccentColor() end

            for _, btn in pairs(colorRow:GetChildren()) do
                if btn:IsA("TextButton") then
                    local stroke = btn:FindFirstChild("UIStroke")
                    if stroke then stroke:Destroy() end

                    if btn.BackgroundColor3 == color then
                        local highlight = Instance.new("UIStroke", btn)
                        highlight.Color = Color3.new(1, 1, 1)
                        highlight.Thickness = 2
                    end
                end
            end

            if updateAllTexts then updateAllTexts() end
        end)
    end

    currentY = currentY + 35 + padding

    createDivider()

    createDropdown(getText("Language"), {"English", "Russian"}, ctx.MenuSettings.Language, function(selectedLanguage)
        ctx.MenuSettings.Language = selectedLanguage
        if updateAllTexts then updateAllTexts() end
    end)

    return currentY
end

return M