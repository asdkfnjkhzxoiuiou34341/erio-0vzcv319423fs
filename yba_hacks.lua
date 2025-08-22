local M = {}

-- The host passes UI builders and exports via args
function M.renderYBATab(ctx)
	local ui = ctx.ui
	local exports = ctx.exports or _G.YBA or {}
	local root = ctx.rootContainer
	local y = ctx.currentY or 0

	ui.createSectionHeader("🎯 STAND RANGE")
	local ybaToggleBtn = ui.createToggleSlider("YBAStandRange", exports.YBAConfig and exports.YBAConfig.Enabled or false, function(v)
		if not exports.YBAConfig then return end
		exports.YBAConfig.Enabled = v
		if v then
			if exports.startYBA then exports.startYBA() end
		else
			if exports.stopYBA then exports.stopYBA() end
		end
	end)

	ui.createSectionHeader("⛏ Underground Flight")
	ui.createToggleSlider("ForceNoClip", _G.isNoClipping and _G.isNoClipping() or false, function(v)
		if v then if _G.startNoClip then _G.startNoClip() end else if _G.stopNoClip then _G.stopNoClip() end end
	end)
	local speed = (exports.YBAConfig and exports.YBAConfig.UndergroundControl and exports.YBAConfig.UndergroundControl.FlightSpeed) or 50
	ui.createSlider("YBA Underground Speed", 1, 200, speed, function(val)
		if exports.YBAConfig and exports.YBAConfig.UndergroundControl then
			exports.YBAConfig.UndergroundControl.FlightSpeed = val
		end
	end)

	ui.createSectionHeader("⏰ ANTI TS")
	local btn = Instance.new("TextButton", root)
	btn.Size = UDim2.new(1, -10, 0, 28)
	btn.Position = UDim2.new(0, 5, 0, _G.currentY or 0)
	btn.Text = "ANTI TIME STOP"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(255,100,100)
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
	_G.currentY = (_G.currentY or ctx.currentY or 0) + 28 + 8
	btn.MouseButton1Click:Connect(function()
		if _G.startAntiTimeStop then
			_G.startAntiTimeStop()
			btn.Text = "ANTI TIME STOP ACTIVE"
			btn.BackgroundColor3 = Color3.fromRGB(0,255,0)
			spawn(function()
				task.wait(0.1)
				if _G.stopAntiTimeStop then _G.stopAntiTimeStop() end
				btn.Text = "ANTI TIME STOP"
				btn.BackgroundColor3 = Color3.fromRGB(255,100,100)
			end)
		end
	end)

	ui.createDivider()
	ui.createSectionHeader("👥 PLAYER ESP")
	ui.createToggleSlider("User Stand", false, function(v)
		if v then if exports.startUserStandESP then exports.startUserStandESP() end else if exports.stopUserStandESP then exports.stopUserStandESP() end end
	end)
	ui.createToggleSlider("User Style", false, function(v)
		if v then if exports.startUserStyleESP then exports.startUserStyleESP() end else if exports.stopUserStyleESP then exports.stopUserStyleESP() end end
	end)

	ui.createSectionHeader("📦 ITEM ESP")
	local itemEnabled = exports.YBAConfig and exports.YBAConfig.ItemESP and exports.YBAConfig.ItemESP.Enabled or false
	ui.createToggleSlider("Item ESP", itemEnabled, function(v)
		if not exports.YBAConfig or not exports.YBAConfig.ItemESP then return end
		exports.YBAConfig.ItemESP.Enabled = v
		if v then if exports.startItemESP then exports.startItemESP() end else if exports.stopItemESP then exports.stopItemESP() end end
	end)

	ui.createSectionHeader("🤖 AUTOFARM")
	ui.createToggleSlider("Autofarm", _G.isAutofarmEnabled and _G.isAutofarmEnabled() or false, function(v)
		if v then if exports.startAutofarm then exports.startAutofarm() end else if exports.stopAutofarm then exports.stopAutofarm() end end
	end)

	return _G.currentY or y
end

return M