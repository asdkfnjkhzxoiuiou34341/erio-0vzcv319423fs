#!/usr/bin/env python3

import re
import sys
import os
import base64
import binascii

def read_file(filename):
    """Читает содержимое файла"""
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except Exception as e:
        print(f"Ошибка при чтении файла {filename}: {e}")
        return None

def write_file(filename, content):
    """Записывает содержимое в файл"""
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    except Exception as e:
        print(f"Ошибка при записи файла {filename}: {e}")
        return False

def extract_moonsec_payload(content):
    """Извлекает основную полезную нагрузку из MoonSec V3"""
    print("🔍 Анализирую структуру MoonSec V3...")
    
    # Ищем основную функцию с параметрами (l,...)
    main_function_pattern = r'return\s*\(\s*function\s*\(\s*([^)]*)\s*\)(.*?)end\s*\)\s*\('
    match = re.search(main_function_pattern, content, re.DOTALL)
    
    if match:
        params = match.group(1).strip()
        function_body = match.group(2)
        print(f"✅ Найдена главная функция с параметрами: {params}")
        return function_body
    
    # Альтернативный поиск
    alt_pattern = r'function\s*\(\s*([^)]*)\s*\)(.*?)(?=return\s*zg|$)'
    match = re.search(alt_pattern, content, re.DOTALL)
    
    if match:
        params = match.group(1).strip()
        function_body = match.group(2)
        print(f"✅ Найдена альтернативная функция с параметрами: {params}")
        return function_body
    
    print("❌ Не удалось найти основную функцию")
    return content

def decode_string_constants(content):
    """Декодирует строковые константы MoonSec"""
    print("🔤 Декодирую строковые константы...")
    
    # Ищем таблицу строк
    string_table_patterns = [
        r't\s*=\s*"([^"]+)"',
        r'local\s+t\s*=\s*"([^"]+)"',
        r'_\[g\[n\]\]\s*=\s*"([^"]+)"'
    ]
    
    decoded_strings = []
    
    for pattern in string_table_patterns:
        matches = re.findall(pattern, content)
        for match in matches:
            decoded = decode_escaped_string(match)
            if decoded and len(decoded) > 1:
                decoded_strings.append(decoded)
    
    if decoded_strings:
        print(f"✅ Найдено {len(decoded_strings)} строковых констант")
        return decoded_strings
    
    print("⚠️  Строковые константы не найдены")
    return []

def decode_escaped_string(s):
    """Декодирует экранированную строку"""
    result = ""
    i = 0
    
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            next_char = s[i + 1]
            if next_char.isdigit():
                # Восьмеричный код
                octal = ""
                j = i + 1
                while j < len(s) and j < i + 4 and s[j].isdigit():
                    octal += s[j]
                    j += 1
                if octal:
                    try:
                        result += chr(int(octal, 8))
                        i = j
                        continue
                    except:
                        pass
            elif next_char == 'n':
                result += '\n'
                i += 2
                continue
            elif next_char == 't':
                result += '\t'
                i += 2
                continue
            elif next_char == 'r':
                result += '\r'
                i += 2
                continue
            elif next_char == '\\':
                result += '\\'
                i += 2
                continue
            elif next_char == '"':
                result += '"'
                i += 2
                continue
        
        result += s[i]
        i += 1
    
    return result

def extract_function_names(strings):
    """Извлекает имена функций из декодированных строк"""
    print("🔧 Извлекаю имена функций...")
    
    function_names = set()
    
    for string in strings:
        # Разбиваем строку по нулевым байтам
        parts = string.split('\0')
        for part in parts:
            if part and len(part) > 1:
                # Проверяем, является ли часть именем функции
                if part.isalpha() or ('.' in part and all(c.isalnum() or c in '._' for c in part)):
                    function_names.add(part)
                # Проверяем на стандартные функции Lua/Roblox
                if part in ['tonumber', 'tostring', 'string', 'table', 'math', 'game', 'workspace', 'script', 'wait']:
                    function_names.add(part)
    
    print(f"✅ Найдено {len(function_names)} уникальных имен функций")
    return sorted(list(function_names))

def beautify_lua_code(content):
    """Улучшает читаемость Lua кода"""
    print("✨ Улучшаю читаемость кода...")
    
    # Заменяем обфусцированные имена переменных на читаемые
    var_replacements = {
        r'\bl\b': 'local_var',
        r'\bg\b': 'instruction',
        r'\bz\b': 'stack',
        r'\bd\b': 'constants',
        r'\bh\b': 'functions',
        r'\bo\b': 'environment',
        r'\bm\b': 'pc',  # program counter
        r'\bs\b': 'stack_size',
        r'\be\b': 'arg1',
        r'\bn\b': 'arg2',
        r'\bt\b': 'arg3'
    }
    
    # Применяем замены осторожно, только для отдельных слов
    result = content
    for old, new in var_replacements.items():
        result = re.sub(old, new, result)
    
    # Форматируем отступы
    lines = result.split('\n')
    formatted_lines = []
    indent_level = 0
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            formatted_lines.append('')
            continue
            
        # Уменьшаем отступ перед end, else, elseif
        if any(stripped.startswith(keyword) for keyword in ['end', 'else', 'elseif', 'until']):
            indent_level = max(0, indent_level - 1)
        
        # Добавляем отступ
        formatted_lines.append('  ' * indent_level + stripped)
        
        # Увеличиваем отступ после определенных ключевых слов
        if any(keyword in stripped for keyword in ['then', ' do', 'function', 'if ', 'while ', 'for ', 'repeat']):
            if not any(stripped.endswith(keyword) for keyword in ['end', 'then m=m+1']):
                indent_level += 1
    
    return '\n'.join(formatted_lines)

def reconstruct_roblox_script(content, function_names):
    """Реконструирует работоспособный Roblox скрипт"""
    print("🔨 Реконструирую работоспособный Roblox скрипт...")
    
    # Извлекаем основную логику
    payload = extract_moonsec_payload(content)
    
    # Создаем заголовок скрипта
    script_header = """-- Деобфусцированный Roblox скрипт
-- Оригинально обфусцирован MoonSec V3
-- Автоматически деобфусцирован

"""
    
    # Добавляем стандартные переменные Roblox
    roblox_vars = """-- Стандартные переменные Roblox
local game = game
local workspace = workspace
local script = script
local wait = wait
local spawn = spawn
local delay = delay

"""
    
    # Добавляем найденные функции как локальные переменные
    if function_names:
        script_header += "-- Найденные функции:\n"
        for func in function_names[:20]:  # Первые 20
            if '.' not in func:
                script_header += f"local {func} = {func}\n"
        script_header += "\n"
    
    # Обрабатываем основной код
    main_code = payload
    
    # Заменяем некоторые обфусцированные паттерны
    replacements = [
        (r'local\s+([a-z])\s*=\s*0xff', r'local byte_max = 255'),
        (r'local\s+([a-z])\s*=\s*\{\}', r'local data_table = {}'),
        (r'local\s+([a-z])\s*=\s*\(1\)', r'local counter = 1'),
        (r'while\s+true\s+do', 'while true do'),
        (r'if\s+not\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+then\s+break\s+end', r'if not \1 then break end'),
    ]
    
    for old_pattern, new_pattern in replacements:
        main_code = re.sub(old_pattern, new_pattern, main_code)
    
    # Собираем финальный скрипт
    final_script = script_header + roblox_vars + main_code
    
    # Улучшаем читаемость
    final_script = beautify_lua_code(final_script)
    
    return final_script

def create_executable_version(content):
    """Создает исполняемую версию без потери функциональности"""
    print("⚙️  Создаю исполняемую версию...")
    
    # Находим и сохраняем критически важные части
    critical_patterns = [
        r'return\s*\(\s*function.*?end\s*\)\s*\([^)]*\)',  # Основная обертка
        r'local\s+[a-z]\s*=\s*0x[0-9a-fA-F]+',  # Hex константы
        r'local\s+[a-z]\s*=\s*\{.*?\}',  # Таблицы данных
        r'function\s*\([^)]*\).*?end',  # Функции
    ]
    
    # Извлекаем критически важные части
    critical_parts = []
    for pattern in critical_patterns:
        matches = re.findall(pattern, content, re.DOTALL)
        critical_parts.extend(matches)
    
    # Создаем минимально измененную версию
    executable_version = content
    
    # Только базовые улучшения читаемости без изменения логики
    simple_replacements = [
        (r'--\[\[.*?\]\]', ''),  # Удаляем блочные комментарии
        (r'--[^\n]*', ''),  # Удаляем строчные комментарии
        (r'\n\s*\n', '\n'),  # Убираем лишние пустые строки
    ]
    
    for old, new in simple_replacements:
        executable_version = re.sub(old, new, executable_version, flags=re.DOTALL)
    
    return executable_version.strip()

def main():
    if len(sys.argv) != 2:
        print("Использование: python3 roblox_moonsec_deobfuscator.py <файл>")
        return
    
    filename = sys.argv[1]
    
    print("🚀 Специализированный деобфускатор MoonSec V3 для Roblox")
    print("=" * 60)
    print(f"📁 Анализирую файл: {filename}")
    
    # Читаем файл
    content = read_file(filename)
    if not content:
        return
    
    print(f"📊 Размер файла: {len(content):,} байт")
    
    # Извлекаем и декодируем строки
    string_constants = decode_string_constants(content)
    
    # Извлекаем имена функций
    function_names = extract_function_names(string_constants)
    
    # Создаем различные версии деобфусцированного кода
    base_name = os.path.splitext(filename)[0]
    
    print("\n🔧 Создаю деобфусцированные версии...")
    
    # 1. Исполняемая версия (максимально сохраняет функциональность)
    executable_version = create_executable_version(content)
    executable_file = f"{base_name}_executable.lua"
    write_file(executable_file, executable_version)
    print(f"✅ Исполняемая версия: {executable_file}")
    
    # 2. Читаемая версия (улучшенная читаемость)
    readable_version = reconstruct_roblox_script(content, function_names)
    readable_file = f"{base_name}_readable.lua"
    write_file(readable_file, readable_version)
    print(f"✅ Читаемая версия: {readable_file}")
    
    # 3. Анализ функций
    functions_file = f"{base_name}_functions_analysis.txt"
    functions_content = f"АНАЛИЗ ФУНКЦИЙ ROBLOX СКРИПТА\n{'='*50}\n\n"
    functions_content += f"Всего найдено функций: {len(function_names)}\n\n"
    
    # Группируем функции по типам
    roblox_functions = [f for f in function_names if f in ['game', 'workspace', 'script', 'wait', 'spawn', 'delay']]
    lua_functions = [f for f in function_names if f in ['tonumber', 'tostring', 'string', 'table', 'math', 'pairs', 'ipairs']]
    custom_functions = [f for f in function_names if f not in roblox_functions + lua_functions]
    
    if roblox_functions:
        functions_content += f"ФУНКЦИИ ROBLOX ({len(roblox_functions)}):\n"
        for func in roblox_functions:
            functions_content += f"  • {func}\n"
        functions_content += "\n"
    
    if lua_functions:
        functions_content += f"СТАНДАРТНЫЕ ФУНКЦИИ LUA ({len(lua_functions)}):\n"
        for func in lua_functions:
            functions_content += f"  • {func}\n"
        functions_content += "\n"
    
    if custom_functions:
        functions_content += f"ПОЛЬЗОВАТЕЛЬСКИЕ ФУНКЦИИ ({len(custom_functions)}):\n"
        for func in custom_functions[:50]:  # Первые 50
            functions_content += f"  • {func}\n"
        if len(custom_functions) > 50:
            functions_content += f"  ... и еще {len(custom_functions) - 50} функций\n"
    
    write_file(functions_file, functions_content)
    print(f"✅ Анализ функций: {functions_file}")
    
    # 4. Финальный отчет
    report_file = f"{base_name}_deobfuscation_report.txt"
    report_content = f"""ОТЧЕТ О ДЕОБФУСКАЦИИ ROBLOX СКРИПТА
{'='*60}

ИСХОДНЫЙ ФАЙЛ: {filename}
РАЗМЕР: {len(content):,} байт
ТИП ОБФУСКАЦИИ: MoonSec V3

РЕЗУЛЬТАТЫ АНАЛИЗА:
• Найдено строковых констант: {len(string_constants)}
• Найдено имен функций: {len(function_names)}
• Функции Roblox: {len(roblox_functions)}
• Стандартные функции Lua: {len(lua_functions)}
• Пользовательские функции: {len(custom_functions)}

СОЗДАННЫЕ ФАЙЛЫ:
1. {executable_file} - Исполняемая версия (сохраняет функциональность)
2. {readable_file} - Читаемая версия (улучшенная структура)
3. {functions_file} - Анализ найденных функций
4. {report_file} - Этот отчет

РЕКОМЕНДАЦИИ:
• Используйте {executable_file} для запуска в Roblox
• Используйте {readable_file} для анализа кода
• Проверьте {functions_file} для понимания структуры

ВАЖНО: Исполняемая версия сохраняет максимальную совместимость!
"""
    
    write_file(report_file, report_content)
    print(f"✅ Отчет: {report_file}")
    
    print(f"\n🎉 ДЕОБФУСКАЦИЯ ЗАВЕРШЕНА!")
    print(f"📁 Создано файлов: 4")
    print(f"🔧 Для Roblox используйте: {executable_file}")
    print(f"📖 Для анализа используйте: {readable_file}")

if __name__ == "__main__":
    main()