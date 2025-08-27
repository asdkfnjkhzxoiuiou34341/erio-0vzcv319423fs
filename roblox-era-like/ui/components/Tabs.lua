local theme = require(script.Parent.Parent.theme)

local Tabs = {}

function Tabs.create(parent, props)
    local self = {}
    self.pages = {}
    self.active = nil

    local sizes = theme.sizes
    local colors = theme.colors

    self.root = Instance.new("Frame")
    self.root.Name = "Tabs"
    self.root.BackgroundColor3 = colors.surface
    self.root.BorderSizePixel = 0
    self.root.Position = UDim2.new(0, sizes.sidebarWidth + 32, 0, 16)
    self.root.Size = UDim2.new(1, -(sizes.sidebarWidth + 48), 1, -32)
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
        padding.PaddingTop = UDim.new(0, 16)
        padding.PaddingLeft = UDim.new(0, 16)
        padding.PaddingRight = UDim.new(0, 16)
        padding.PaddingBottom = UDim.new(0, 16)
        padding.Parent = page

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 10)
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

return Tabs

