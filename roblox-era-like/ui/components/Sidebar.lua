local TweenService = game:GetService("TweenService")
local theme = require(script.Parent.Parent.theme)

local Sidebar = {}

function Sidebar.create(parent, props)
    local self = {}

    self.onTabSelectedCallbacks = {}
    self.buttons = {}
    self.activeTab = nil

    local sizes = theme.sizes
    local colors = theme.colors

    self.root = Instance.new("Frame")
    self.root.Name = "Sidebar"
    self.root.Size = UDim2.fromOffset(sizes.sidebarWidth, parent.AbsoluteSize.Y)
    self.root.Position = UDim2.new(0, 16, 0, 16)
    self.root.BackgroundColor3 = colors.surface
    self.root.BorderSizePixel = 0
    self.root.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, sizes.round)
    corner.Parent = self.root

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, theme.sizes.spacing)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.root

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -20, 0, theme.sizes.topbarHeight)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = self.root

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = (props and props.title) or "Era-like Hub"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = colors.text
    title.Position = UDim2.fromOffset(10, 0)
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Text = (props and props.subtitle) or ""
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 13
    subtitle.TextColor3 = colors.textDim
    subtitle.Position = UDim2.fromOffset(10, 24)
    subtitle.Size = UDim2.new(1, -20, 0, 20)
    subtitle.Parent = header

    self.buttonsContainer = Instance.new("Frame")
    self.buttonsContainer.Name = "Buttons"
    self.buttonsContainer.BackgroundTransparency = 1
    self.buttonsContainer.Size = UDim2.new(1, -8, 1, -theme.sizes.topbarHeight - 24)
    self.buttonsContainer.Position = UDim2.new(0, 8, 0, theme.sizes.topbarHeight + 22)
    self.buttonsContainer.LayoutOrder = 2
    self.buttonsContainer.Parent = self.root

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
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
            TweenService:Create(button, TweenInfo.new(theme.tween.duration), { BackgroundColor3 = bg }):Play()
        end
    end

    function self.addTab(tabId, tabName)
        local button = Instance.new("TextButton")
        button.Name = tabId
        button.Text = tabName
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = colors.surface2
        button.BorderSizePixel = 0
        button.TextColor3 = colors.text
        button.Font = Enum.Font.Gotham
        button.TextSize = 16
        button.AutoButtonColor = false
        button.Parent = self.buttonsContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, theme.sizes.round)
        corner.Parent = button

        button.MouseButton1Click:Connect(function()
            self.setActive(tabId)
            self.fireTabSelected(tabId)
        end)

        self.buttons[tabId] = button
    end

    return self
end

return Sidebar

