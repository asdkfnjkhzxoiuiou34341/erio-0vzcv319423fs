-- Era-like Loader: animated splash + async fetch + UI mount

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local function createSplash()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EraLikeLoader"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = (syn and syn.protect_gui and syn.protect_gui(screenGui)) or CoreGui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.Size = UDim2.fromOffset(360, 120)
    container.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Text = "Era-like Hub"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(235, 235, 240)
    title.TextSize = 24
    title.Position = UDim2.fromScale(0.5, 0.35)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Parent = container

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Loading modules..."
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 180)
    subtitle.TextSize = 14
    subtitle.Position = UDim2.fromScale(0.5, 0.65)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.Parent = container

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0.08, 0, 0.8, 0)
    bar.Size = UDim2.new(0.84, 0, 0, 6)
    bar.Parent = container
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = Color3.fromRGB(95, 135, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = bar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    return screenGui, container, subtitle, fill
end

local function setProgress(fillFrame, alpha)
    TweenService:Create(fillFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0) }):Play()
end

local function destroySplash(screenGui)
    if not screenGui then return end
    local tween = TweenService:Create(screenGui, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 })
    tween:Play()
    tween.Completed:Wait()
    screenGui:Destroy()
end

local ok, http = pcall(function()
    return loadstring(readfile and isfile and (isfile("era_like/utils/http.lua") and readfile("era_like/utils/http.lua")) or "")
end)
-- Fallback to local require if not using executor FS
local httpModule
if not ok or not http then
    local success, mod = pcall(function()
        return require(script:FindFirstChild("utils") and script.utils.http)
    end)
    if success then httpModule = mod end
end

-- Local module require fallback for all modules in this repo structure
local function localRequire(path)
    local segments = string.split(path, "/")
    local current = script
    for _, seg in ipairs(segments) do
        current = current:FindFirstChild(seg)
        if not current then return nil end
    end
    local success, mod = pcall(function()
        return require(current)
    end)
    if success then return mod end
    return nil
end

-- Create splash
local splashGui, container, subtitle, fill = createSplash()
setProgress(fill, 0.05)

-- Load utilities
subtitle.Text = "Preparing runtime..."
local executor = localRequire("utils/executor")
local httpUtil = localRequire("utils/http")
httpUtil = httpUtil or httpModule or { get = function(url) return game:HttpGet(url) end }
setProgress(fill, 0.15)

-- Load UI
subtitle.Text = "Loading UI..."
local UI = localRequire("ui/init")
if not UI then
    warn("Era-like: UI module missing")
end
setProgress(fill, 0.30)

-- Load config
subtitle.Text = "Loading config..."
local Config = localRequire("config")
local config = Config and Config.load() or {}
setProgress(fill, 0.45)

-- Build UI
subtitle.Text = "Building interface..."
local app = UI and UI.create({ title = "Era-like Hub", subtitle = "Example Build", version = "v0.1.0", initialTab = config.lastTab })
setProgress(fill, 0.60)

-- Register example tabs
subtitle.Text = "Loading modules..."
local tabs = {
    { id = "combat", name = "Combat", module = localRequire("examples/aimbot") },
    { id = "visuals", name = "Visuals", module = localRequire("examples/esp") },
}

for i, tab in ipairs(tabs) do
    if app and tab.module and type(tab.module.mount) == "function" then
        local page = app.addTab(tab.id, tab.name)
        tab.module.mount({ app = app, page = page, config = config })
    end
    setProgress(fill, 0.60 + (i / #tabs) * 0.25)
end

subtitle.Text = "Finalizing..."
task.wait(0.2)
setProgress(fill, 1)
task.wait(0.2)
destroySplash(splashGui)

-- Save last tab when changed
if app and app.onTabChanged then
    app.onTabChanged(function(tabId)
        config.lastTab = tabId
        if Config then Config.save(config) end
    end)
end

return true

