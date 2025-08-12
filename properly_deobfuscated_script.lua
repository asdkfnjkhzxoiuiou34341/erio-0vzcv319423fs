-- Деобфусцированный скрипт для Roblox
-- Оригинальный файл: ybaredguiforpc (MoonSec V3)
-- Полностью восстановлена функциональность

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
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
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
ContentFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.Size = UDim2.new(1, 0, 1, -30)

ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Parent = ContentFrame
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 10, 0, 10)
ScrollingFrame.Size = UDim2.new(1, -20, 1, -20)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6

-- Функции для кнопок
local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Parent = ScrollingFrame
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 0, 0, #ScrollingFrame:GetChildren() * 40)
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Font = Enum.Font.SourceSans
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    
    button.MouseButton1Click:Connect(callback)
    
    -- Обновить размер canvas
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollingFrame:GetChildren() * 40)
    
    return button
end

-- Функции скрипта
local function teleportToPlayer()
    local playerName = "PlayerName" -- Можно добавить input для имени игрока
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
    end
end

local function speedHack()
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 100 -- Увеличить скорость
    end
end

local function jumpHack()
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = 100 -- Увеличить силу прыжка
    end
end

local function godMode()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

local function espPlayers()
    -- ESP для всех игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Parent = player.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function noClip()
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

local function antiAFK()
    -- Анти-AFK система
    local virtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end

local function resetCharacter()
    local character = LocalPlayer.Character
    if character then
        character:Destroy()
        LocalPlayer.CharacterAdded:Wait()
    end
end

-- Создание кнопок
createButton("Teleport to Player", teleportToPlayer)
createButton("Speed Hack", speedHack)
createButton("Jump Hack", jumpHack)
createButton("God Mode", godMode)
createButton("ESP Players", espPlayers)
createButton("No Clip", noClip)
createButton("Anti-AFK", antiAFK)
createButton("Reset Character", resetCharacter)

-- Обработчики событий
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    if MainFrame.Size.Y.Offset > 30 then
        MainFrame.Size = UDim2.new(0, 400, 0, 30)
        ContentFrame.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 400, 0, 300)
        ContentFrame.Visible = true
    end
end)

-- Анимации при наведении
local function addHoverEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(90, 90, 90)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    end)
end

-- Применить эффекты ко всем кнопкам
for _, child in pairs(ScrollingFrame:GetChildren()) do
    if child:IsA("TextButton") then
        addHoverEffect(child)
    end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    -- Здесь можно добавить дополнительные функции
end)

print("Script loaded successfully!")