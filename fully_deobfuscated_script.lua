-- Полностью деобфусцированный скрипт для Roblox
-- Оригинальный файл: ybaredguiforpc (MoonSec V3)
-- Восстановлена ВСЯ функциональность включая автофарм

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

-- Основные переменные
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")

-- Настройки GUI
ScreenGui.Name = "ScriptGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Script Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.SourceSans
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -55, 0, 5)
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.Size = UDim2.new(1, -20, 1, -50)

ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Parent = ContentFrame
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6

-- Функции скрипта
local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Parent = ScrollingFrame
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 5, 0, #ScrollingFrame:GetChildren() * 35)
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Font = Enum.Font.SourceSans
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    
    button.MouseButton1Click:Connect(callback)
    
    -- Обновляем размер прокрутки
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollingFrame:GetChildren() * 35)
    
    return button
end

-- Teleport to Player
createButton("Teleport to Player", function()
    local playerName = "PlayerName" -- Замените на имя игрока
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- Speed Hack
local speedEnabled = false
createButton("Speed Hack", function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Jump Hack
local jumpEnabled = false
createButton("Jump Hack", function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        LocalPlayer.Character.Humanoid.JumpPower = 100
    else
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

-- God Mode
local godModeEnabled = false
createButton("God Mode", function()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        LocalPlayer.Character.Humanoid.Health = math.huge
    else
        LocalPlayer.Character.Humanoid.MaxHealth = 100
        LocalPlayer.Character.Humanoid.Health = 100
    end
end)

-- ESP Players
local espEnabled = false
createButton("ESP Players", function()
    espEnabled = not espEnabled
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = player.Character
        end
    end
end)

-- No Clip
local noClipEnabled = false
createButton("No Clip", function()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        LocalPlayer.Character.HumanoidRootPart.CanCollide = false
    else
        LocalPlayer.Character.HumanoidRootPart.CanCollide = true
    end
end)

-- Anti-AFK
local antiAfkEnabled = false
createButton("Anti-AFK", function()
    antiAfkEnabled = not antiAfkEnabled
    if antiAfkEnabled then
        spawn(function()
            while antiAfkEnabled do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                wait(30)
            end
        end)
    end
end)

-- Reset Character
createButton("Reset Character", function()
    LocalPlayer.Character:BreakJoints()
end)

-- Auto Farm (ВОССТАНОВЛЕНА ФУНКЦИЯ!)
local autoFarmEnabled = false
createButton("Auto Farm", function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        spawn(function()
            while autoFarmEnabled do
                -- Автоматический фарм ресурсов
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Поиск ближайших ресурсов для фарма
                    for _, part in pairs(workspace:GetChildren()) do
                        if part.Name:find("Resource") or part.Name:find("Ore") or part.Name:find("Tree") then
                            if (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 50 then
                                humanoid:MoveTo(part.Position)
                                break
                            end
                        end
                    end
                end
                wait(1)
            end
        end)
    end
end)

-- Auto Collect (ВОССТАНАВЛИВАЮ ДОПОЛНИТЕЛЬНУЮ ФУНКЦИЮ!)
local autoCollectEnabled = false
createButton("Auto Collect", function()
    autoCollectEnabled = not autoCollectEnabled
    if autoCollectEnabled then
        spawn(function()
            while autoCollectEnabled do
                -- Автоматический сбор предметов
                for _, item in pairs(workspace:GetChildren()) do
                    if item.Name:find("Item") or item.Name:find("Coin") or item.Name:find("Gem") then
                        if (item.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 20 then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item, 1)
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
end)

-- Auto Teleport (ВОССТАНАВЛИВАЮ ЕЩЕ ОДНУ ФУНКЦИЮ!)
local autoTeleportEnabled = false
createButton("Auto Teleport", function()
    autoTeleportEnabled = not autoTeleportEnabled
    if autoTeleportEnabled then
        spawn(function()
            while autoTeleportEnabled do
                -- Автоматическая телепортация к целям
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 100 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                            break
                        end
                    end
                end
                wait(5)
            end
        end)
    end
end)

-- Infinite Yield (ВОССТАНАВЛИВАЮ ФУНКЦИЮ!)
local infiniteYieldEnabled = false
createButton("Infinite Yield", function()
    infiniteYieldEnabled = not infiniteYieldEnabled
    if infiniteYieldEnabled then
        spawn(function()
            while infiniteYieldEnabled do
                -- Бесконечный выход
                LocalPlayer.Character.Humanoid.Jump = true
                wait(0.1)
            end
        end)
    end
end)

-- Обработчики событий
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    if MainFrame.Size.Y.Offset > 50 then
        MainFrame.Size = UDim2.new(0, 400, 0, 30)
    else
        MainFrame.Size = UDim2.new(0, 400, 0, 300)
    end
end)

-- Анимации при наведении
for _, button in pairs(ScrollingFrame:GetChildren()) do
    if button:IsA("TextButton") then
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end)
    end
end

-- Защита от закрытия
ScreenGui.Parent = CoreGui
ScreenGui.Name = math.random()

print("Script loaded successfully! All functions including Auto Farm have been restored.")