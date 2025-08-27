local theme = require(script.Parent.theme)
local Sidebar = require(script.Parent.components.Sidebar)
local Tabs = require(script.Parent.components.Tabs)

local CoreGui = game:GetService("CoreGui")

local App = {}
App.__index = App

function App:_mount()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "EraLikeUI"
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = (syn and syn.protect_gui and syn.protect_gui(self.screenGui)) or CoreGui

    self.root = Instance.new("Frame")
    self.root.Name = "Root"
    self.root.Size = UDim2.fromScale(1, 1)
    self.root.BackgroundTransparency = 1
    self.root.Parent = self.screenGui

    self.sidebar = Sidebar.create(self.root, self.props)
    self.tabs = Tabs.create(self.root, self.props)

    self.sidebar.onTabSelected(function(tabId)
        self.tabs.select(tabId)
        if self._onTabChanged then self._onTabChanged(tabId) end
    end)

    if self.props.initialTab then
        self.tabs.select(self.props.initialTab)
        self.sidebar.setActive(self.props.initialTab)
    end
end

function App:addTab(tabId, tabName)
    self.sidebar.addTab(tabId, tabName)
    return self.tabs.addPage(tabId, tabName)
end

function App:onTabChanged(callback)
    self._onTabChanged = callback
end

local M = {}

function M.create(props)
    local self = setmetatable({ props = props or {} }, App)
    self:_mount()
    return self
end

return M

