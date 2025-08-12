--[[
    🚀 Huyna Script v2.0 - Модульная версия
    Пример использования с динамической загрузкой
    
    ИСПОЛЬЗОВАНИЕ:
    1. Загрузите main_loader.lua - он создаст базовое меню
    2. При переключении вкладок автоматически загружаются нужные модули
    3. Функции загружаются только по необходимости
    
    ПРЕИМУЩЕСТВА:
    ✅ Быстрая начальная загрузка (только GUI)
    ✅ Модули загружаются по требованию
    ✅ Экономия памяти
    ✅ Легче поддерживать код
    ✅ Можно обновлять модули независимо
    
    СТРУКТУРА:
    📁 main_loader.lua - Основной загрузчик (GUI + система модулей)
    📁 main_functions.lua - Main функции + Settings (ESP, Aimbot, Fly, Anti-AFK)
    📁 yba_functions.lua - YBA функции (Stand Range, Item ESP, Autofarm)
]]

-- Способ 1: Прямая загрузка основного загрузчика
if loadstring and game:HttpGet then
    -- Загрузка с GitHub/сервера (в продакшене)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/main_loader.lua"))()
elseif readfile and isfile("/workspace/main_loader.lua") then
    -- Локальная загрузка (для тестирования)
    loadstring(readfile("/workspace/main_loader.lua"))()
else
    -- Fallback: встроенная версия
    print("🚀 Запуск встроенной версии Huyna Script...")
    
    -- Здесь можно встроить минимальную версию скрипта
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HuynaScriptSimple"
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🚀 Huyna Script v2.0\nМодульная загрузка не доступна"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    print("⚠️ Ограниченная функциональность - только базовый GUI")
end

--[[
    ПЛАН РАЗВЕРТЫВАНИЯ ДЛЯ ПРОДАКШЕНА:
    
    1. Загрузите файлы на GitHub или ваш сервер:
       - main_loader.lua
       - main_functions.lua  
       - yba_functions.lua
    
    2. Обновите ссылки в main_loader.lua:
       - Замените пути на реальные URL
       - Настройте систему версионирования
    
    3. Основной скрипт для пользователей:
       loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/main_loader.lua"))()
    
    4. Дополнительные возможности:
       - Система обновлений
       - Кеширование модулей
       - Проверка версий
       - Шифрование кода
]]

-- Функция для обновления модулей (опционально)
_G.UpdateHuynaScript = function()
    if _G.HuynaScript then
        _G.HuynaScript.ModulesLoaded = {}
        print("🔄 Кеш модулей очищен. При следующем переключении вкладок модули перезагрузятся.")
    end
end

-- Функция для получения информации о состоянии
_G.GetHuynaScriptInfo = function()
    if _G.HuynaScript then
        print("📊 Huyna Script v2.0 - Статус:")
        print("Загруженные модули:", #_G.HuynaScript.ModulesLoaded)
        for module, loaded in pairs(_G.HuynaScript.ModulesLoaded) do
            print("  " .. module .. ": " .. (loaded and "✅" or "❌"))
        end
        print("GUI активен:", _G.HuynaScript.GUI.mainFrame and _G.HuynaScript.GUI.mainFrame.Visible)
    else
        print("❌ Huyna Script не загружен")
    end
end

print("📋 Huyna Script v2.0 готов к использованию!")
print("💡 Команды:")
print("   _G.UpdateHuynaScript() - обновить модули")
print("   _G.GetHuynaScriptInfo() - показать статус")