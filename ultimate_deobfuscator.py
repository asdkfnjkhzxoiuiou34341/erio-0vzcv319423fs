#!/usr/bin/env python3

import re
import sys
import os

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

def decode_string_table(content):
    """Декодирует таблицу строк из MoonSec"""
    print("Декодирую таблицу строк...")
    
    # Ищем основную строку с данными
    string_pattern = r't="([^"]+)"'
    match = re.search(string_pattern, content)
    
    if match:
        encoded_string = match.group(1)
        print(f"Найдена закодированная строка длиной: {len(encoded_string)}")
        
        # Декодируем строку
        decoded_chars = []
        i = 0
        while i < len(encoded_string):
            if encoded_string[i] == '\\':
                if i + 1 < len(encoded_string):
                    # Восьмеричный код
                    if encoded_string[i+1].isdigit():
                        octal = ""
                        j = i + 1
                        while j < len(encoded_string) and j < i + 4 and encoded_string[j].isdigit():
                            octal += encoded_string[j]
                            j += 1
                        if octal:
                            try:
                                decoded_chars.append(chr(int(octal)))
                                i = j
                                continue
                            except:
                                pass
                i += 2
            else:
                decoded_chars.append(encoded_string[i])
                i += 1
        
        decoded_string = ''.join(decoded_chars)
        return decoded_string
    
    return None

def extract_function_names(decoded_string):
    """Извлекает имена функций из декодированной строки"""
    print("Извлекаю имена функций...")
    
    function_names = []
    
    # Разбиваем строку на части
    parts = decoded_string.split('\0')
    
    for part in parts:
        if len(part) > 0:
            # Проверяем, является ли часть именем функции
            if part.isalpha() or ('.' in part and all(c.isalnum() or c in '._' for c in part)):
                function_names.append(part)
    
    return function_names

def reconstruct_lua_code(function_names, content):
    """Реконструирует Lua код на основе найденных функций"""
    print("Реконструирую Lua код...")
    
    lua_code = []
    lua_code.append("-- ВОССТАНОВЛЕННЫЙ LUA КОД")
    lua_code.append("-- Деобфусцировано из MoonSec V3")
    lua_code.append("")
    
    # Добавляем основные функции Lua
    standard_functions = [
        'tonumber', 'tostring', 'string', 'table', 'math', 'io', 'os',
        'getfenv', 'setfenv', 'loadstring', 'pcall', 'xpcall',
        'pairs', 'ipairs', 'next', 'type', 'print'
    ]
    
    found_standard = [name for name in function_names if name in standard_functions]
    if found_standard:
        lua_code.append("-- Стандартные функции Lua:")
        for func in found_standard:
            lua_code.append(f"-- {func}")
        lua_code.append("")
    
    # Добавляем функции работы со строками
    string_functions = [name for name in function_names if name.startswith('string.')]
    if string_functions:
        lua_code.append("-- Функции работы со строками:")
        for func in string_functions:
            lua_code.append(f"-- {func}")
        lua_code.append("")
    
    # Добавляем функции работы с таблицами
    table_functions = [name for name in function_names if name.startswith('table.')]
    if table_functions:
        lua_code.append("-- Функции работы с таблицами:")
        for func in table_functions:
            lua_code.append(f"-- {func}")
        lua_code.append("")
    
    # Пытаемся восстановить структуру кода
    lua_code.append("-- ВОССТАНОВЛЕННАЯ СТРУКТУРА:")
    lua_code.append("")
    
    # Ищем паттерны в коде
    patterns = [
        (r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)', 'Локальная переменная'),
        (r'function\s*\(([^)]*)\)', 'Функция'),
        (r'if\s+.*\s+then', 'Условие'),
        (r'while\s+.*\s+do', 'Цикл while'),
        (r'for\s+.*\s+do', 'Цикл for'),
        (r'return\s+.*', 'Возврат значения'),
    ]
    
    for pattern, description in patterns:
        matches = re.findall(pattern, content)
        if matches:
            lua_code.append(f"-- {description} (найдено {len(matches)}):")
            for match in matches[:10]:  # Первые 10
                lua_code.append(f"--   {match}")
            lua_code.append("")
    
    return '\n'.join(lua_code)

def create_readable_lua(content):
    """Создает читаемую версию Lua кода"""
    print("Создаю читаемую версию...")
    
    # Удаляем очевидно обфусцированные части
    cleaned = content
    
    # Заменяем очень длинные строки
    cleaned = re.sub(r'"[^"]{500,}"', '"<LONG_STRING>"', cleaned)
    
    # Заменяем числовые константы
    cleaned = re.sub(r'\b0x[0-9a-fA-F]{4,}\b', '<HEX_CONSTANT>', cleaned)
    
    # Форматируем код
    lines = cleaned.split('\n')
    formatted_lines = []
    
    indent_level = 0
    for line in lines:
        stripped = line.strip()
        if stripped:
            # Уменьшаем отступ перед end, else, elseif
            if any(stripped.startswith(keyword) for keyword in ['end', 'else', 'elseif']):
                indent_level = max(0, indent_level - 1)
            
            # Добавляем отступ
            formatted_lines.append('  ' * indent_level + stripped)
            
            # Увеличиваем отступ после then, do, function, if
            if any(keyword in stripped for keyword in ['then', ' do', 'function', 'if ']):
                if not stripped.endswith('end'):
                    indent_level += 1
    
    return '\n'.join(formatted_lines)

def main():
    if len(sys.argv) != 2:
        print("Использование: python3 ultimate_deobfuscator.py <файл>")
        return
    
    filename = sys.argv[1]
    
    print(f"Ультимативная деобфускация файла: {filename}")
    print("=" * 70)
    
    # Читаем файл
    content = read_file(filename)
    if not content:
        return
    
    # Декодируем таблицу строк
    decoded_string = decode_string_table(content)
    
    if decoded_string:
        print(f"Декодированная строка длиной: {len(decoded_string)} символов")
        
        # Извлекаем имена функций
        function_names = extract_function_names(decoded_string)
        print(f"Найдено имен функций: {len(function_names)}")
        
        # Реконструируем код
        reconstructed_code = reconstruct_lua_code(function_names, content)
        
        # Создаем читаемую версию
        readable_code = create_readable_lua(content)
        
        # Сохраняем результаты
        base_name = os.path.splitext(filename)[0]
        
        # Сохраняем реконструированный код
        reconstructed_filename = f"{base_name}_reconstructed.lua"
        write_file(reconstructed_filename, reconstructed_code)
        print(f"Реконструированный код сохранен в: {reconstructed_filename}")
        
        # Сохраняем декодированную строку
        decoded_filename = f"{base_name}_decoded_string.txt"
        write_file(decoded_filename, decoded_string)
        print(f"Декодированная строка сохранена в: {decoded_filename}")
        
        # Сохраняем список функций
        functions_filename = f"{base_name}_functions.txt"
        functions_content = "НАЙДЕННЫЕ ИМЕНА ФУНКЦИЙ:\n\n"
        for i, func in enumerate(function_names, 1):
            functions_content += f"{i:3d}. {func}\n"
        write_file(functions_filename, functions_content)
        print(f"Список функций сохранен в: {functions_filename}")
        
        # Сохраняем финальный отчет
        report_filename = f"{base_name}_final_report.txt"
        report_content = []
        report_content.append("ФИНАЛЬНЫЙ ОТЧЕТ ДЕОБФУСКАЦИИ")
        report_content.append("=" * 50)
        report_content.append(f"Исходный файл: {filename}")
        report_content.append(f"Размер файла: {len(content):,} байт")
        report_content.append(f"Тип обфускации: MoonSec V3")
        report_content.append("")
        
        report_content.append("РЕЗУЛЬТАТЫ АНАЛИЗА:")
        report_content.append(f"- Декодированная строка: {len(decoded_string):,} символов")
        report_content.append(f"- Найдено функций: {len(function_names)}")
        report_content.append("")
        
        report_content.append("ТОП-20 ФУНКЦИЙ:")
        for func in function_names[:20]:
            report_content.append(f"  • {func}")
        
        if len(function_names) > 20:
            report_content.append(f"  ... и еще {len(function_names) - 20} функций")
        
        report_content.append("")
        report_content.append("СОЗДАННЫЕ ФАЙЛЫ:")
        report_content.append(f"1. {reconstructed_filename} - Реконструированный код")
        report_content.append(f"2. {decoded_filename} - Декодированная строка")
        report_content.append(f"3. {functions_filename} - Список функций")
        report_content.append(f"4. {report_filename} - Этот отчет")
        
        write_file(report_filename, '\n'.join(report_content))
        print(f"Финальный отчет сохранен в: {report_filename}")
        
        print("\n" + "=" * 70)
        print("🎉 УЛЬТИМАТИВНАЯ ДЕОБФУСКАЦИЯ ЗАВЕРШЕНА! 🎉")
        print(f"Создано файлов: 4")
        print(f"Найдено функций: {len(function_names)}")
        print(f"Декодировано символов: {len(decoded_string):,}")
        
    else:
        print("❌ Не удалось декодировать строковую таблицу")

if __name__ == "__main__":
    main()