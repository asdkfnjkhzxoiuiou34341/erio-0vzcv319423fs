return function(ctx)
	local functionsContainer = ctx.functionsContainer
	local currentY = ctx.currentY
	local padding = 8

	local getText = ctx.getText
	local createSectionHeader = ctx.createSectionHeader
	local createToggleSlider = ctx.createToggleSlider
	local createSlider = ctx.createSlider
	local createDivider = ctx.createDivider
	local createButton = ctx.createButton

	local YBAConfig = ctx.YBAConfig
	local AntiTimeStopConfig = ctx.AntiTimeStopConfig
	local AutofarmConfig = ctx.AutofarmConfig

	local scrollFrame = ctx.scrollFrame
	local showContent = ctx.showContent

	local isUndergroundControlEnabled = ctx.isUndergroundControlEnabled
	local startUndergroundControl = ctx.startUndergroundControl
	local stopUndergroundControl = ctx.stopUndergroundControl
	local controlledStandForUnderground = ctx.controlledStandForUnderground

	local isNoClipping = ctx.isNoClipping
	local startNoClip = ctx.startNoClip
	local stopNoClip = ctx.stopNoClip

	local isAntiTimeStopEnabled = ctx.isAntiTimeStopEnabled
	local startAntiTimeStop = ctx.startAntiTimeStop
	local stopAntiTimeStop = ctx.stopAntiTimeStop

	local startUserStandESP = ctx.startUserStandESP
	local stopUserStandESP = ctx.stopUserStandESP
	local startUserStyleESP = ctx.startUserStyleESP
	local stopUserStyleESP = ctx.stopUserStyleESP

	local itemESPElements = ctx.itemESPElements
	local removeItemESP = ctx.removeItemESP
	local startItemESP = ctx.startItemESP
	local stopItemESP = ctx.stopItemESP

	local isAutofarmEnabled = ctx.isAutofarmEnabled
	local startAutofarm = ctx.startAutofarm
	local stopAutofarm = ctx.stopAutofarm
	local autofarmConnections = ctx.autofarmConnections
	local autofarmCurrentTarget = ctx.autofarmCurrentTarget
	local autofarmPickingUp = ctx.autofarmPickingUp
	local processNextItem = ctx.processNextItem

	-- YBA UI rendering copied from original
	createSectionHeader("🎯 STAND RANGE")
	createToggleSlider(getText("YBAStandRange"), YBAConfig.Enabled, function(v)
		YBAConfig.Enabled = v
		if v then
			if ctx.startYBA then ctx.startYBA() end
		else
			if ctx.stopYBA then ctx.stopYBA() end
		end
	end)

	createToggleSlider(getText("UndergroundFlight"), isUndergroundControlEnabled, function(v)
		if v then
			if startUndergroundControl then startUndergroundControl() end
		else
			if stopUndergroundControl then stopUndergroundControl() end
		end
	end)

	local ybaNoClipStatusLabel = Instance.new("TextLabel", functionsContainer)
	ybaNoClipStatusLabel.Size = UDim2.new(1, -10, 0, 20)
	ybaNoClipStatusLabel.Position = UDim2.new(0, 5, 0, currentY)
	ybaNoClipStatusLabel.Text = "NoClip Status: " .. (isNoClipping and "ON" or "OFF")
	ybaNoClipStatusLabel.Font = Enum.Font.GothamBold
	ybaNoClipStatusLabel.TextSize = 12
	ybaNoClipStatusLabel.TextColor3 = isNoClipping and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
	ybaNoClipStatusLabel.BackgroundTransparency = 1
	ybaNoClipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentY = currentY + 20 + padding

	createToggleSlider(getText("ForceNoClip"), isNoClipping, function(v)
		if v then
			startNoClip()
			ybaNoClipStatusLabel.Text = "NoClip Status: ON"
			ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
		else
			stopNoClip()
			ybaNoClipStatusLabel.Text = "NoClip Status: OFF"
			ybaNoClipStatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
		end
	end)

	createSlider("YBA Underground Speed", 1, 200, YBAConfig.UndergroundControl.FlightSpeed or 50, function(v)
		YBAConfig.UndergroundControl.FlightSpeed = v
		if isUndergroundControlEnabled and controlledStandForUnderground then
			print("YBA: Скорость подземного полета изменена на:", v)
		end
	end)

	createSectionHeader("⏰ ANTI TS")
	local antiTimeStopBtn = Instance.new("TextButton", functionsContainer)
	antiTimeStopBtn.Size = UDim2.new(1, -10, 0, 28)
	antiTimeStopBtn.Position = UDim2.new(0, 5, 0, currentY)
	antiTimeStopBtn.Text = getText("AntiTimeStop")
	antiTimeStopBtn.Font = Enum.Font.GothamBold
	antiTimeStopBtn.TextSize = 14
	antiTimeStopBtn.TextColor3 = Color3.new(1,1,1)
	antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
	antiTimeStopBtn.AutoButtonColor = false
	Instance.new("UICorner", antiTimeStopBtn).CornerRadius = UDim.new(0,6)
	currentY = currentY + 28 + padding

	antiTimeStopBtn.MouseButton1Click:Connect(function()
		if not isAntiTimeStopEnabled then
			AntiTimeStopConfig.Enabled = true
			startAntiTimeStop()
			antiTimeStopBtn.Text = "ANTI TIME STOP ACTIVE"
			antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
			spawn(function()
				task.wait(0.1)
				AntiTimeStopConfig.Enabled = false
				stopAntiTimeStop()
				antiTimeStopBtn.Text = "ANTI TIME STOP"
				antiTimeStopBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
				print("Anti TS: ГОТОВО!")
			end)
		end
	end)

	createDivider()
	createSectionHeader("👥 PLAYER ESP")
	createToggleSlider("User Stand", false, function(v)
		if v then startUserStandESP() else stopUserStandESP() end
	end)
	createToggleSlider("User Style", false, function(v)
		if v then startUserStyleESP() else stopUserStyleESP() end
	end)

	createSectionHeader("📦 ITEM ESP")
	createToggleSlider(getText("ItemESP"), YBAConfig.ItemESP.Enabled, function(v)
		YBAConfig.ItemESP.Enabled = v
		if v then startItemESP() else stopItemESP() end
	end)

	local itemSelectionHeader = Instance.new("TextLabel", functionsContainer)
	itemSelectionHeader.Size = UDim2.new(1, -10, 0, 25)
	itemSelectionHeader.Position = UDim2.new(0, 5, 0, currentY)
	itemSelectionHeader.Text = "📦 ITEM SELECTION"
	itemSelectionHeader.Font = Enum.Font.GothamBold
	itemSelectionHeader.TextSize = 14
	itemSelectionHeader.TextColor3 = Color3.fromRGB(255, 255, 0)
	itemSelectionHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	itemSelectionHeader.BorderSizePixel = 1
	itemSelectionHeader.BorderColor3 = Color3.fromRGB(100, 100, 120)
	itemSelectionHeader.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", itemSelectionHeader).CornerRadius = UDim.new(0,4)
	currentY = currentY + 25 + padding

	local function createItemToggle(itemName, defaultState)
		local btn = createToggleSlider(itemName, defaultState, function(v)
			YBAConfig.ItemESP.Items[itemName] = v
			if not v then
				for obj, esp in pairs(itemESPElements) do
					if esp and esp.itemName == itemName then
						pcall(removeItemESP, {Object = obj})
					end
				end
			end
		end)
		return btn
	end

	createItemToggle(getText("MysteriousArrow"), YBAConfig.ItemESP.Items["Mysterious Arrow"])
	createItemToggle(getText("Rokakaka"), YBAConfig.ItemESP.Items["Rokakaka"])
	createItemToggle(getText("PureRokakaka"), YBAConfig.ItemESP.Items["Pure Rokakaka"])
	createItemToggle(getText("Diamond"), YBAConfig.ItemESP.Items["Diamond"])
	createItemToggle(getText("GoldCoin"), YBAConfig.ItemESP.Items["Gold Coin"])
	createItemToggle(getText("SteelBall"), YBAConfig.ItemESP.Items["Steel Ball"])
	createItemToggle(getText("Clackers"), YBAConfig.ItemESP.Items["Clackers"])
	createItemToggle(getText("CaesarsHeadband"), YBAConfig.ItemESP.Items["Caesar's Headband"])
	createItemToggle(getText("ZeppeliHat"), YBAConfig.ItemESP.Items["Zeppeli's Hat"])
	createItemToggle(getText("ZeppeliScarf"), YBAConfig.ItemESP.Items["Zeppeli's Scarf"])
	createItemToggle(getText("QuintonsGlove"), YBAConfig.ItemESP.Items["Quinton's Glove"])
	createItemToggle(getText("StoneMask"), YBAConfig.ItemESP.Items["Stone Mask"])
	createItemToggle(getText("RibCage"), YBAConfig.ItemESP.Items["Rib Cage of The Saint's Corpse"])
	createItemToggle(getText("AncientScroll"), YBAConfig.ItemESP.Items["Ancient Scroll"])
	createItemToggle(getText("DiosDiary"), YBAConfig.ItemESP.Items["DIO's Diary"])
	createItemToggle(getText("LuckyStoneMask"), YBAConfig.ItemESP.Items["Lucky Stone Mask"])
	createItemToggle(getText("LuckyArrow"), YBAConfig.ItemESP.Items["Lucky Arrow"])

	createSectionHeader("🤖 AUTOFARM")
	createToggleSlider("Autofarm", isAutofarmEnabled, function(v)
		if v then startAutofarm() else stopAutofarm() end
	end)

	createSectionHeader("📦 ITEMS FARM")
	local function createAutofarmItemToggle(itemName, defaultState)
		local btn = createToggleSlider(itemName, defaultState, function(v)
			AutofarmConfig.Items[itemName] = v
			if isAutofarmEnabled then
				if ctx.autofarmCurrentTarget and ctx.autofarmCurrentTarget.Name == itemName and not v then
					ctx.autofarmCurrentTarget = nil
					autofarmPickingUp = false
					for _, connection in ipairs(autofarmConnections) do
						if connection then pcall(function() connection:Disconnect() end) end
					end
					autofarmConnections = {}
					task.spawn(function()
						task.wait(0.1)
						if isAutofarmEnabled then processNextItem() end
					end)
				end
			end
		end)
		return btn
	end

	createAutofarmItemToggle("Mysterious Arrow", AutofarmConfig.Items["Mysterious Arrow"])
	createAutofarmItemToggle("Rokakaka", AutofarmConfig.Items["Rokakaka"])
	createAutofarmItemToggle("Pure Rokakaka", AutofarmConfig.Items["Pure Rokakaka"])
	createAutofarmItemToggle("Diamond", AutofarmConfig.Items["Diamond"])
	createAutofarmItemToggle("Gold Coin", AutofarmConfig.Items["Gold Coin"])
	createAutofarmItemToggle("Steel Ball", AutofarmConfig.Items["Steel Ball"])
	createAutofarmItemToggle("Clackers", AutofarmConfig.Items["Clackers"])
	createAutofarmItemToggle("Caesar's Headband", AutofarmConfig.Items["Caesar's Headband"])
	createAutofarmItemToggle("Zeppeli's Hat", AutofarmConfig.Items["Zeppeli's Hat"])
	createAutofarmItemToggle("Zeppeli's Scarf", AutofarmConfig.Items["Zeppeli's Scarf"])
	createAutofarmItemToggle("Quinton's Glove", AutofarmConfig.Items["Quinton's Glove"])
	createAutofarmItemToggle("Stone Mask", AutofarmConfig.Items["Stone Mask"])
	createAutofarmItemToggle("Rib Cage of The Saint's Corpse", AutofarmConfig.Items["Rib Cage of The Saint's Corpse"])
	createAutofarmItemToggle("Ancient Scroll", AutofarmConfig.Items["Ancient Scroll"])
	createAutofarmItemToggle("DIO's Diary", AutofarmConfig.Items["DIO's Diary"])
	createAutofarmItemToggle("Lucky Stone Mask", AutofarmConfig.Items["Lucky Stone Mask"])
	createAutofarmItemToggle("Lucky Arrow", AutofarmConfig.Items["Lucky Arrow"])

	createDivider()
	createSectionHeader("🤖 AUTO SELL")
	-- Keep Autosell section remote-loaded by main if needed

	if scrollFrame then
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY)
	end

	return currentY
end