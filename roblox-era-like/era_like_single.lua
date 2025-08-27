-- Era-like Hub (Single File) - Compact Version
-- Paste this entire file into your executor
-- Press INSERT key to toggle menu visibility

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Compact theme
local theme = {
    colors = {
        bg = Color3.fromRGB(14, 14, 17),
        surface = Color3.fromRGB(22, 22, 26),
        surface2 = Color3.fromRGB(32, 32, 38),
        text = Color3.fromRGB(235, 235, 240),
        textDim = Color3.fromRGB(165, 170, 180),
        accent = Color3.fromRGB(95, 135, 255),
        accentDim = Color3.fromRGB(70, 100, 200),
    },
    sizes = {
        sidebarWidth = 180,
        topbarHeight = 36,
        round = 6,
        spacing = 4,
    },
    tween = { duration = 0.2 },
}

-- Create splash screen
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
    container.Size = UDim2.fromOffset(320, 100)
    container.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Text = "Era-like Hub"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(235, 235, 240)
    title.TextSize = 20
    title.Position = UDim2.fromScale(0.5, 0.35)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Parent = container

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Loading..."
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 180)
    subtitle.TextSize = 12
    subtitle.Position = UDim2.fromScale(0.5, 0.65)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.Parent = container

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0.08, 0, 0.8, 0)
    bar.Size = UDim2.new(0.84, 0, 0, 4)
    bar.Parent = container
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = Color3.fromRGB(95, 135, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = bar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill

    return screenGui, container, subtitle, fill
end

local function setProgress(fillFrame, alpha)
    TweenService:Create(fillFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { 
        Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0) 
    }):Play()
end

local function destroySplash(screenGui)
    if not screenGui then return end
    local tween = TweenService:Create(screenGui, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { 
        Transparency = 1 
    })
    tween:Play()
    tween.Completed:Wait()
    screenGui:Destroy()
end

-- Create compact sidebar
local function createSidebar(parent, props)
    local self = {}
    self.onTabSelectedCallbacks = {}
    self.buttons = {}
    self.activeTab = nil

    local sizes = theme.sizes
    local colors = theme.colors

    self.root = Instance.new("Frame")
    self.root.Name = "Sidebar"
    self.root.Size = UDim2.fromOffset(sizes.sidebarWidth, parent.AbsoluteSize.Y)
    self.root.Position = UDim2.new(0, 12, 0, 12)
    self.root.BackgroundColor3 = colors.surface
    self.root.BorderSizePixel = 0
    self.root.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, sizes.round)
    corner.Parent = self.root

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -16, 0, sizes.topbarHeight)
    header.BackgroundTransparency = 1
    header.Position = UDim2.new(0, 8, 0, 8)
    header.Parent = self.root

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = (props and props.title) or "Era-like Hub"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = colors.text
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Parent = header

    self.buttonsContainer = Instance.new("Frame")
    self.buttonsContainer.Name = "Buttons"
    self.buttonsContainer.BackgroundTransparency = 1
    self.buttonsContainer.Size = UDim2.new(1, -8, 1, -sizes.topbarHeight - 12)
    self.buttonsContainer.Position = UDim2.new(0, 8, 0, sizes.topbarHeight + 8)
    self.buttonsContainer.Parent = self.root

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = self.buttonsContainer

    function self.onTabSelected(callback)
        table.insert(self.onTabSelectedCallbacks, callback)
    end

    function self.fireTabSelected(tabId)
        for _, cb in ipairs(self.onTabSelectedCallbacks) do
            cb(tabId)
        end
    end

    function self.setActive(tabId)
        self.activeTab = tabId
        for id, button in pairs(self.buttons) do
            local isActive = (id == tabId)
            local bg = isActive and colors.accent or colors.surface2
            TweenService:Create(button, TweenInfo.new(theme.tween.duration), { 
                BackgroundColor3 = bg 
            }):Play()
        end
    end

    function self.addTab(tabId, tabName)
        local button = Instance.new("TextButton")
        button.Name = tabId
        button.Text = tabName
        button.Size = UDim2.new(1, 0, 0, 28)
        button.BackgroundColor3 = colors.surface2
        button.BorderSizePixel = 0
        button.TextColor3 = colors.text
        button.Font = Enum.Font.Gotham
        button.TextSize = 13
        button.AutoButtonColor = false
        button.Parent = self.buttonsContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, sizes.round)
        corner.Parent = button

        button.MouseButton1Click:Connect(function()
            self.setActive(tabId)
            self.fireTabSelected(tabId)
        end)

        self.buttons[tabId] = button
    end

    return self
end

-- Create compact tabs
local function createTabs(parent, props)
    local self = {}
    self.pages = {}
    self.active = nil

    local sizes = theme.sizes
    local colors = theme.colors

    self.root = Instance.new("Frame")
    self.root.Name = "Tabs"
    self.root.BackgroundColor3 = colors.surface
    self.root.BorderSizePixel = 0
    self.root.Position = UDim2.new(0, sizes.sidebarWidth + 24, 0, 12)
    self.root.Size = UDim2.new(1, -(sizes.sidebarWidth + 36), 1, -24)
    self.root.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, sizes.round)
    corner.Parent = self.root

    function self.addPage(tabId, tabName)
        local page = Instance.new("ScrollingFrame")
        page.Name = tabId
        page.Active = true
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.fromScale(1, 1)
        page.Visible = false
        page.Parent = self.root

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = page

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = page

        self.pages[tabId] = page
        return page
    end

    function self.select(tabId)
        if self.active == tabId then return end
        for id, page in pairs(self.pages) do
            page.Visible = (id == tabId)
        end
        self.active = tabId
    end

    return self
end

-- Create UI with toggle functionality
local function createUI(props)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EraLikeUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = (syn and syn.protect_gui and syn.protect_gui(screenGui)) or CoreGui

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.Size = UDim2.fromScale(1, 1)
    root.BackgroundTransparency = 1
    root.Parent = screenGui

    local sidebar = createSidebar(root, props)
    local tabs = createTabs(root, props)

    local api = {}
    api.visible = true
    api.screenGui = screenGui
    
    function api.addTab(tabId, tabName)
        sidebar.addTab(tabId, tabName)
        return tabs.addPage(tabId, tabName)
    end
    
    function api.onTabChanged(cb)
        api._onTabChanged = cb
    end
    
    function api.toggle()
        api.visible = not api.visible
        screenGui.Enabled = api.visible
    end
    
    sidebar.onTabSelected(function(tabId)
        tabs.select(tabId)
        if api._onTabChanged then api._onTabChanged(tabId) end
    end)

    if props and props.initialTab then
        tabs.select(props.initialTab)
        sidebar.setActive(props.initialTab)
    end

    return api
end

-- Example modules
local function mountAimbot(ctx)
    local page = ctx.page
    
    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Text = "Combat: Aimbot"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.TextColor3 = Color3.fromRGB(235,235,240)
    header.Size = UDim2.new(1, -10, 0, 18)
    header.Parent = page

    local toggle = Instance.new("TextButton")
    toggle.Name = "AimbotToggle"
    toggle.Size = UDim2.new(0, 150, 0, 24)
    toggle.Text = "Enable Aimbot: OFF"
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 12
    toggle.TextColor3 = Color3.fromRGB(235,235,240)
    toggle.BackgroundColor3 = Color3.fromRGB(35,35,40)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = toggle

    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "Enable Aimbot: ON" or "Enable Aimbot: OFF"
    end)
end

local function mountESP(ctx)
    local page = ctx.page
    
    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Text = "Visuals: ESP"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.TextColor3 = Color3.fromRGB(235,235,240)
    header.Size = UDim2.new(1, -10, 0, 18)
    header.Parent = page

    local toggle = Instance.new("TextButton")
    toggle.Name = "ESPToggle"
    toggle.Size = UDim2.new(0, 150, 0, 24)
    toggle.Text = "Enable ESP: OFF"
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 12
    toggle.TextColor3 = Color3.fromRGB(235,235,240)
    toggle.BackgroundColor3 = Color3.fromRGB(35,35,40)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = toggle

    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "Enable ESP: ON" or "Enable ESP: OFF"
    end)
end

-- Main execution
local splashGui, container, subtitle, fill = createSplash()
setProgress(fill, 0.1)

subtitle.Text = "Loading UI..."
local app = createUI({ title = "Era-like Hub", subtitle = "Compact", initialTab = "combat" })
setProgress(fill, 0.4)

subtitle.Text = "Registering tabs..."
local tabs = {
    { id = "combat", name = "Combat", mount = mountAimbot },
    { id = "visuals", name = "Visuals", mount = mountESP },
}

for i, tab in ipairs(tabs) do
    local page = app.addTab(tab.id, tab.name)
    if tab.mount then tab.mount({ app = app, page = page }) end
    setProgress(fill, 0.4 + (i / #tabs) * 0.4)
end

subtitle.Text = "Finalizing..."
task.wait(0.2)
setProgress(fill, 1)
task.wait(0.2)
destroySplash(splashGui)

-- Add toggle key (INSERT)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        app.toggle()
    end
end)

-- Set initial tab
app.onTabChanged(function(tabId)
    -- Could save last tab here if needed
end)

return true