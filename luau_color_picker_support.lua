local M = {}

function M.Create(functionsContainer, Config, currentY, setY)
    local function createColorPicker(labelText, currentColor, onChange)
        local lbl = Instance.new("TextLabel", functionsContainer)
        lbl.Text = labelText
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.Position = UDim2.new(0, 5, 0, currentY)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        currentY = currentY + 20 + 8

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

        currentY = currentY + 28 + 8
        if setY then setY(currentY) end
    end

    createColorPicker("Fill Color", Config.ESP.FillColor, function(color)
        Config.ESP.FillColor = color
    end)

    createColorPicker("Outline Color", Config.ESP.OutlineColor, function(color)
        Config.ESP.OutlineColor = color
    end)

    createColorPicker("Text Color", Config.ESP.TextColor, function(color)
        Config.ESP.TextColor = color
    end)
end

return M