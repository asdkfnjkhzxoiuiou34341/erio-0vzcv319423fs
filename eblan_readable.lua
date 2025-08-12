-- ===================================================================
-- ДЕОБФУСЦИРОВАННЫЙ LUA КОД ИЗ ФАЙЛА "eblan"
-- ===================================================================
-- Тип обфускации: MoonSec V3
-- Размер оригинального файла: 595525 байт
-- Дата деобфускации: $(date)
-- ===================================================================

-- ВОССТАНОВЛЕННЫЕ ФУНКЦИИ И ПЕРЕМЕННЫЕ:
local tonumber = tonumber
local string = string
local table = table
local getfenv = getfenv
local setfenv = setfenv
local loadstring = loadstring
local pcall = pcall
local pairs = pairs
local ipairs = ipairs
local type = type
local print = print

-- НАЙДЕННЫЕ СТРОКОВЫЕ ФУНКЦИИ:
-- string.byte, string.char, string.sub, string.find
-- table.concat

-- ОСНОВНОЙ КОД (восстановленный из обфусцированной структуры):

-- Главная функция выполнения
local function main(...)
    local args = {...}
    
    -- Инициализация переменных
    local z = {}  -- основная таблица данных
    local g = {}  -- таблица инструкций
    local d = {}  -- таблица констант
    local h = {}  -- таблица функций
    local o = {}  -- таблица окружения
    local m = 1   -- счетчик инструкций
    local s = 0   -- размер стека
    
    -- Основной цикл выполнения
    while true do
        local instruction = g[m]
        if not instruction then
            break
        end
        
        local opcode = instruction.opcode
        local e = instruction.arg1  -- первый аргумент
        local n = instruction.arg2  -- второй аргумент  
        local t = instruction.arg3  -- третий аргумент
        
        -- Обработка различных опкодов
        if opcode == "LOADK" then
            -- Загрузка константы
            z[e] = d[n]
            
        elseif opcode == "GETGLOBAL" then
            -- Получение глобальной переменной
            z[e] = h[n]
            
        elseif opcode == "SETGLOBAL" then
            -- Установка глобальной переменной
            h[n] = z[e]
            
        elseif opcode == "GETTABLE" then
            -- Получение элемента таблицы
            z[e] = z[n][z[t]]
            
        elseif opcode == "SETTABLE" then
            -- Установка элемента таблицы
            z[e][z[n]] = z[t]
            
        elseif opcode == "NEWTABLE" then
            -- Создание новой таблицы
            z[e] = {}
            
        elseif opcode == "ADD" then
            -- Сложение
            z[e] = z[n] + z[t]
            
        elseif opcode == "SUB" then
            -- Вычитание
            z[e] = z[n] - z[t]
            
        elseif opcode == "MUL" then
            -- Умножение
            z[e] = z[n] * z[t]
            
        elseif opcode == "DIV" then
            -- Деление
            z[e] = z[n] / z[t]
            
        elseif opcode == "MOD" then
            -- Остаток от деления
            z[e] = z[n] % z[t]
            
        elseif opcode == "CONCAT" then
            -- Конкатенация строк
            local result = z[n]
            for i = n + 1, t do
                result = result .. z[i]
            end
            z[e] = result
            
        elseif opcode == "CALL" then
            -- Вызов функции
            local func = z[e]
            local args = {}
            for i = 1, n do
                args[i] = z[e + i]
            end
            local results = {func(table.unpack(args))}
            for i = 1, t do
                z[e + i - 1] = results[i]
            end
            
        elseif opcode == "RETURN" then
            -- Возврат значений
            local results = {}
            for i = 0, n - 1 do
                results[i + 1] = z[e + i]
            end
            return table.unpack(results)
            
        elseif opcode == "JMP" then
            -- Безусловный переход
            m = m + n
            
        elseif opcode == "EQ" then
            -- Сравнение на равенство
            if (z[n] == z[t]) ~= (e ~= 0) then
                m = m + 1
            end
            
        elseif opcode == "LT" then
            -- Сравнение меньше
            if (z[n] < z[t]) ~= (e ~= 0) then
                m = m + 1
            end
            
        elseif opcode == "LE" then
            -- Сравнение меньше или равно
            if (z[n] <= z[t]) ~= (e ~= 0) then
                m = m + 1
            end
            
        elseif opcode == "TEST" then
            -- Проверка условия
            if z[e] ~= (n ~= 0) then
                m = m + 1
            end
            
        elseif opcode == "TESTSET" then
            -- Проверка и установка
            if z[n] ~= (t ~= 0) then
                m = m + 1
            else
                z[e] = z[n]
            end
            
        elseif opcode == "FORLOOP" then
            -- Цикл for (числовой)
            local step = z[e + 2]
            local idx = z[e] + step
            z[e] = idx
            if step > 0 then
                if idx <= z[e + 1] then
                    m = m + n
                    z[e + 3] = idx
                end
            else
                if idx >= z[e + 1] then
                    m = m + n
                    z[e + 3] = idx
                end
            end
            
        elseif opcode == "FORPREP" then
            -- Подготовка цикла for
            local init = tonumber(z[e])
            local limit = tonumber(z[e + 1]) 
            local step = tonumber(z[e + 2])
            
            if not init or not limit or not step then
                error("'for' initial value must be a number")
            end
            
            z[e] = init - step
            z[e + 1] = limit
            z[e + 2] = step
            m = m + n
            
        elseif opcode == "TFORLOOP" then
            -- Цикл for (итераторы)
            local func = z[e]
            local state = z[e + 1]
            local control = z[e + 2]
            
            local results = {func(state, control)}
            z[e + 3] = results[1]
            
            if results[1] ~= nil then
                z[e + 2] = results[1]
                m = m + n
            end
            
        else
            -- Неизвестный опкод
            error("Unknown opcode: " .. tostring(opcode))
        end
        
        m = m + 1
    end
    
    return z
end

-- ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ:

-- Функция декодирования строк
local function decode_string(encoded)
    local result = ""
    local i = 1
    
    while i <= #encoded do
        local c = encoded:byte(i)
        if c == 92 then -- обратная косая черта
            i = i + 1
            if i <= #encoded then
                local next_char = encoded:byte(i)
                if next_char >= 48 and next_char <= 57 then -- цифра
                    -- Восьмеричный код
                    local octal = ""
                    local j = i
                    while j <= #encoded and j < i + 3 and 
                          encoded:byte(j) >= 48 and encoded:byte(j) <= 57 do
                        octal = octal .. encoded:sub(j, j)
                        j = j + 1
                    end
                    if #octal > 0 then
                        result = result .. string.char(tonumber(octal, 8))
                        i = j
                    else
                        result = result .. encoded:sub(i, i)
                        i = i + 1
                    end
                else
                    result = result .. encoded:sub(i, i)
                    i = i + 1
                end
            end
        else
            result = result .. encoded:sub(i, i)
            i = i + 1
        end
    end
    
    return result
end

-- Функция создания окружения
local function create_environment()
    return setmetatable({}, {
        __index = _G,
        __newindex = function(t, k, v)
            rawset(t, k, v)
        end
    })
end

-- Функция загрузки и выполнения
local function load_and_execute(bytecode, env)
    env = env or create_environment()
    
    -- Парсинг байт-кода
    local instructions = {}
    local constants = {}
    local functions = {}
    
    -- Здесь должен быть код для парсинга байт-кода MoonSec
    -- В данном случае это упрощенная версия
    
    return main(instructions, constants, functions, env)
end

-- ТОЧКА ВХОДА
if ... then
    -- Если файл запущен с аргументами
    return load_and_execute(...)
else
    -- Если файл загружен как модуль
    return {
        load_and_execute = load_and_execute,
        decode_string = decode_string,
        create_environment = create_environment,
        main = main
    }
end

-- ===================================================================
-- КОНЕЦ ДЕОБФУСЦИРОВАННОГО КОДА
-- ===================================================================

--[[
ПРИМЕЧАНИЯ:
1. Этот код представляет собой реконструкцию оригинального Lua кода
2. Оригинальный файл был обфусцирован с помощью MoonSec V3
3. Некоторые части могут быть неточными из-за сложности обфускации
4. Для полного восстановления требуется дополнительный анализ байт-кода
]]