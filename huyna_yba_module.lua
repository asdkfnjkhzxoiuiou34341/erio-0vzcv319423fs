local Y = {}

-- ctx should include:
-- functionsContainer, currentY, padding
-- helpers: createToggleSlider, createSlider, createDivider, createSectionHeader, createButton
-- env: getText, Players, YBAConfig
-- actions: startYBA, stopYBA, startNoClip, stopNoClip, startItemESP, stopItemESP, startUserStandESP, stopUserStandESP, startUserStyleESP, stopUserStyleESP, startAntiTimeStop, stopAntiTimeStop
-- state: isNoClipping, isUndergroundControlEnabled, controlledStandForUnderground, isAntiTimeStopEnabled

function Y.buildYBATab(ctx)
    local functionsContainer = ctx.functionsContainer
    local currentY = ctx.currentY or 0
    local padding = ctx.padding or 8

    local createToggleSlider = ctx.createToggleSlider
    local createSlider = ctx.createSlider
    local createDivider = ctx.createDivider
    local createSectionHeader = ctx.createSectionHeader
    local createButton = ctx.createButton
    local getText = ctx.getText

    local Players = ctx.Players
    local YBAConfig = ctx.YBAConfig

    local startYBA, stopYBA = ctx.startYBA, ctx.stopYBA
    local startNoClip, stopNoClip = ctx.startNoClip, ctx.stopNoClip
    local startItemESP, stopItemESP = ctx.startItemESP, ctx.stopItemESP
    local startUserStandESP, stopUserStandESP = ctx.startUserStandESP, ctx.stopUserStandESP
    local startUserStyleESP, stopUserStyleESP = ctx.startUserStyleESP, ctx.stopUserStyleESP
    local startAntiTimeStop, stopAntiTimeStop = ctx.startAntiTimeStop, ctx.stopAntiTimeStop

    local isNoClipping = ctx.isNoClipping
    local isUndergroundControlEnabled = ctx.isUndergroundControlEnabled
    local controlledStandForUnderground = ctx.controlledStandForUnderground
    local isAntiTimeStopEnabled = ctx.isAntiTimeStopEnabled

    -- 🎯 STAND RANGE
    createSectionHeader("🎯 STAND RANGE")

    createToggleSlider(getText("YBAStandRange"), YBAConfig.Enabled, function(v)
        YBAConfig.Enabled = v
        if v then startYBA() else stopYBA() end
    end)

    createToggleSlider(getText("UndergroundFlight"), isUndergroundControlEnabled, function(v)
        if v then
            if ctx.startUndergroundControl then ctx.startUndergroundControl() end
        else
            if ctx.stopUndergroundControl then ctx.stopUndergroundControl() end
        end
    end)

    local ybaNoClipStatusLabel = Instance.new("TextLabel", functionsContainer)
    ybaNoClipStatusLabel.Size = UDim2.new(1, -10, 0, 20)
    ybaNoClipStatusLabel.Position = UDim2.new(0, 5, 0, currentY)
    ybaNoClipStatusLabel.Text = "NoClip Status: " .. (isNoClipping and "ON" or "OFF")
    ybaNoClipStatusLabel.Font = Enum.Font.GothamBold
    ybaNoClipStatusLabel.TextSize = 12
    ybaNoClipStatusLabel.TextColor3 = isNoClipping and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
    ybaNoClipStatusLabel.BackgroundTransparency = 1
    ybaNoClipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    currentY = currentY + 20 + padding

    createToggleSlider(getText("ForceNoClip"), isNoClipping, function(v)
        if v then
            startNoClip()
            ybaNoClipStatusLabel.Text = "NoClip Status: ON"
            ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        else
            stopNoClip()
            ybaNoClipStatusLabel.Text = "NoClip Status: OFF"
            ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        end
    end)

    createSlider("YBA Underground Speed", 1, 200, YBAConfig.UndergroundControl.FlightSpeed or 50, function(v)
        YBAConfig.UndergroundControl.FlightSpeed = v
        if isUndergroundControlEnabled and controlledStandForUnderground then
            print("YBA: Скорость подземного полета изменена на:", v)
        end
    end)

    -- ⏰ ANTI TS
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
            ctx.AntiTimeStopConfig.Enabled = true
            startAntiTimeStop()
            antiTimeStopBtn.Text = "ANTI TIME STOP ACTIVE"
            antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)

            task.spawn(function()
                task.wait(0.1)
                ctx.AntiTimeStopConfig.Enabled = false
                stopAntiTimeStop()
                antiTimeStopBtn.Text = "ANTI TIME STOP"
                antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
                print("Anti TS: ГОТОВО!")
            end)
        end
    end)

    createDivider()

    -- 👥 PLAYER ESP
    createSectionHeader("👥 PLAYER ESP")

    createToggleSlider("User Stand", false, function(v)
        if v then startUserStandESP() else stopUserStandESP() end
    end)

    createToggleSlider("User Style", false, function(v)
        if v then startUserStyleESP() else stopUserStyleESP() end
    end)

    -- 📦 ITEM ESP
    createSectionHeader("📦 ITEM ESP")

    createToggleSlider(getText("ItemESP"), YBAConfig.ItemESP.Enabled, function(v)
        YBAConfig.ItemESP.Enabled = v
        if v then startItemESP() else stopItemESP() end
    end)

    local function createItemToggle(itemName, defaultState)
        local btn = createToggleSlider(itemName, defaultState, function(v)
            YBAConfig.ItemESP.Items[itemName] = v
            print("YBA Item ESP:", itemName, v and "ON" or "OFF")
            if not v and ctx.removeItemESP then
                for obj, esp in pairs(ctx.itemESPElements or {}) do
                    if esp and esp.itemName == itemName then
                        pcall(ctx.removeItemESP, {Object = obj})
                    end
                end
            end
        end)
        return btn
    end

    for itemName, defaultState in pairs(YBAConfig.ItemESP.Items) do
        createItemToggle(itemName, defaultState)
    end

    return currentY
end

return Y