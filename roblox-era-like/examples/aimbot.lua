local module = {}

function module.mount(ctx)
    local page = ctx.page

    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Text = "Combat: Aimbot (demo UI)"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 18
    header.TextColor3 = Color3.fromRGB(235,235,240)
    header.Size = UDim2.new(1, -10, 0, 24)
    header.Parent = page

    local toggle = Instance.new("TextButton")
    toggle.Name = "AimbotToggle"
    toggle.Size = UDim2.new(0, 220, 0, 36)
    toggle.Text = "Enable Aimbot: OFF"
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 16
    toggle.TextColor3 = Color3.fromRGB(235,235,240)
    toggle.BackgroundColor3 = Color3.fromRGB(35,35,40)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggle

    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "Enable Aimbot: ON" or "Enable Aimbot: OFF"
    end)
end

return module

