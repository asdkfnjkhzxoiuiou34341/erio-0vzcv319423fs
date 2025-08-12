#!/usr/bin/env lua

-- MoonSec V3 Deobfuscator
-- Этот скрипт пытается деобфусцировать код, защищенный MoonSec V3

local function readFile(filename)
    local file = io.open(filename, "r")
    if not file then
        print("Ошибка: не удается открыть файл " .. filename)
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

local function writeFile(filename, content)
    local file = io.open(filename, "w")
    if not file then
        print("Ошибка: не удается создать файл " .. filename)
        return false
    end
    file:write(content)
    file:close()
    return true
end

local function extractStrings(code)
    -- Извлекаем строки из обфусцированного кода
    local strings = {}
    
    -- Ищем паттерны строк в коде
    for str in code:gmatch('"([^"]*)"') do
        table.insert(strings, str)
    end
    
    for str in code:gmatch("'([^']*)'") do
        table.insert(strings, str)
    end
    
    return strings
end

local function deobfuscateMoonSec(content)
    print("Начинаю деобфускацию MoonSec V3...")
    
    -- Удаляем маркер защиты
    content = content:gsub("%[%[This file was protected with MoonSec V3%]%]", "")
    
    -- Пытаемся найти основную функцию
    local mainFunc = content:match("return%(function%(l,%.%.%.%)(.+)end%)")
    if not mainFunc then
        print("Не удается найти основную функцию")
        return nil
    end
    
    print("Найдена основная функция, длина: " .. #mainFunc)
    
    -- Извлекаем переменные и константы
    local variables = {}
    local constants = {}
    
    -- Ищем определения переменных
    for var in mainFunc:gmatch("local (%w+);") do
        table.insert(variables, var)
    end
    
    print("Найдено переменных: " .. #variables)
    
    -- Пытаемся найти строковые константы
    local stringData = mainFunc:match('t="([^"]*)"')
    if stringData then
        print("Найдены строковые данные, длина: " .. #stringData)
        
        -- Декодируем строки
        local decoded = {}
        local pos = 1
        while pos <= #stringData do
            local byte = stringData:byte(pos)
            if byte then
                table.insert(decoded, string.char(byte))
            end
            pos = pos + 1
        end
        
        local decodedStr = table.concat(decoded)
        print("Декодированная строка: " .. decodedStr:sub(1, 100) .. "...")
    end
    
    -- Пытаемся восстановить исходный код
    local result = "-- Деобфусцированный код из MoonSec V3\n\n"
    
    -- Добавляем найденные строки
    local strings = extractStrings(content)
    if #strings > 0 then
        result = result .. "-- Найденные строки:\n"
        for i, str in ipairs(strings) do
            if #str > 0 then
                result = result .. "-- " .. i .. ": " .. str .. "\n"
            end
        end
        result = result .. "\n"
    end
    
    -- Пытаемся найти читаемые части кода
    local readableParts = {}
    
    -- Ищем функции
    for func in content:gmatch("function%s*%(([^)]*)%)") do
        table.insert(readableParts, "function(" .. func .. ")")
    end
    
    -- Ищем локальные переменные с значениями
    for var, val in content:gmatch("local%s+(%w+)%s*=%s*([^;]+)") do
        if not val:match("function") and #val < 50 then
            table.insert(readableParts, "local " .. var .. " = " .. val)
        end
    end
    
    if #readableParts > 0 then
        result = result .. "-- Читаемые части кода:\n"
        for _, part in ipairs(readableParts) do
            result = result .. part .. "\n"
        end
    end
    
    -- Добавляем исходный обфусцированный код как комментарий
    result = result .. "\n-- ВНИМАНИЕ: Полная деобфускация MoonSec V3 требует выполнения кода\n"
    result = result .. "-- Ниже приведен исходный обфусцированный код:\n\n"
    result = result .. "--[[\n" .. content .. "\n--]]\n"
    
    return result
end

-- Основная функция
local function main()
    local filename = arg[1] or "eblan"
    
    print("Читаю файл: " .. filename)
    local content = readFile(filename)
    
    if not content then
        return 1
    end
    
    print("Размер файла: " .. #content .. " байт")
    
    local deobfuscated = deobfuscateMoonSec(content)
    
    if deobfuscated then
        local outputFile = filename .. "_deobfuscated.lua"
        if writeFile(outputFile, deobfuscated) then
            print("Результат сохранен в: " .. outputFile)
        else
            print("Ошибка при сохранении файла")
            return 1
        end
    else
        print("Деобфускация не удалась")
        return 1
    end
    
    return 0
end

-- Запуск
os.exit(main())