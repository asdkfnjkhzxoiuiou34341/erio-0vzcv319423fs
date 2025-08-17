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

def extract_moonsec_payload(content):
    """Извлекает основную полезную нагрузку из MoonSec"""
    print("Извлекаю основную полезную нагрузку MoonSec...")
    
    # Ищем основную структуру MoonSec V3
    moonsec_pattern = r'\[\[This file was protected with MoonSec V3\]\]\):gsub\(\'\.\+\', \(function\(a\) _DTEMjXUozCTu = a; end\)\); return\(function\(([^)]+)\)(.+)\)$'
    match = re.search(moonsec_pattern, content, re.DOTALL)
    
    if match:
        params = match.group(1)
        main_code = match.group(2)
        print(f"Найдены параметры: {params}")
        print(f"Размер основного кода: {len(main_code)} символов")
        return params, main_code
    else:
        print("Структура MoonSec V3 не найдена")
        return None, None

def analyze_lua_structure(code):
    """Анализирует структуру Lua кода"""
    print("Анализирую структуру Lua кода...")
    
    analysis = {
        'functions': [],
        'variables': [],
        'strings': [],
        'numbers': [],
        'operators': [],
        'keywords': []
    }
    
    # Поиск функций
    func_pattern = r'function\s*\(([^)]*)\)'
    functions = re.findall(func_pattern, code)
    analysis['functions'] = functions
    
    # Поиск переменных (локальных)
    var_pattern = r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)'
    variables = re.findall(var_pattern, code)
    analysis['variables'] = list(set(variables))
    
    # Поиск строковых литералов
    string_pattern = r'"([^"]*)"'
    strings = re.findall(string_pattern, code)
    analysis['strings'] = list(set(strings))
    
    # Поиск чисел
    number_pattern = r'\b(\d+(?:\.\d+)?)\b'
    numbers = re.findall(number_pattern, code)
    analysis['numbers'] = list(set(numbers))
    
    return analysis

def decode_obfuscated_strings(code):
    """Пытается декодировать обфусцированные строки"""
    print("Декодирую обфусцированные строки...")
    
    decoded_strings = []
    
    # Поиск паттернов закодированных строк
    patterns = [
        r'\\(\d{1,3})',  # Восьмеричные коды
        r'\\x([0-9a-fA-F]{2})',  # Шестнадцатеричные коды
        r'string\.char\((\d+(?:,\s*\d+)*)\)',  # string.char вызовы
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, code)
        for match in matches:
            try:
                if pattern.startswith(r'\\(\d'):  # Восьмеричные
                    decoded = chr(int(match))
                    decoded_strings.append(f"\\{match} -> {decoded}")
                elif pattern.startswith(r'\\x'):  # Шестнадцатеричные
                    decoded = chr(int(match, 16))
                    decoded_strings.append(f"\\x{match} -> {decoded}")
                elif 'string.char' in pattern:  # string.char
                    chars = [chr(int(x.strip())) for x in match.split(',')]
                    decoded = ''.join(chars)
                    decoded_strings.append(f"string.char({match}) -> {decoded}")
            except:
                pass
    
    return decoded_strings

def extract_readable_code(code):
    """Извлекает читаемые части кода"""
    print("Извлекаю читаемые части кода...")
    
    readable_parts = []
    
    # Удаляем очень длинные строки (вероятно, данные)
    lines = code.split('\n')
    for i, line in enumerate(lines):
        if len(line) < 200 and len(line.strip()) > 0:  # Разумная длина строки
            # Проверяем, содержит ли строка читаемый код
            if any(keyword in line for keyword in ['function', 'local', 'if', 'then', 'else', 'end', 'while', 'for', 'return']):
                readable_parts.append(f"Строка {i+1}: {line.strip()}")
    
    return readable_parts

def create_clean_lua_structure(analysis, readable_parts):
    """Создает чистую структуру Lua кода"""
    print("Создаю чистую структуру Lua...")
    
    clean_code = []
    clean_code.append("-- ДЕОБФУСЦИРОВАННЫЙ КОД MoonSec V3")
    clean_code.append("-- Автоматически извлечено из обфусцированного файла")
    clean_code.append("")
    
    # Добавляем найденные функции
    if analysis['functions']:
        clean_code.append("-- НАЙДЕННЫЕ ФУНКЦИИ:")
        for i, func in enumerate(analysis['functions'][:10]):  # Первые 10
            clean_code.append(f"-- function({func})")
        clean_code.append("")
    
    # Добавляем переменные
    if analysis['variables']:
        clean_code.append("-- ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ:")
        for var in sorted(set(analysis['variables']))[:20]:  # Первые 20
            clean_code.append(f"local {var}")
        clean_code.append("")
    
    # Добавляем строки
    if analysis['strings']:
        clean_code.append("-- НАЙДЕННЫЕ СТРОКИ:")
        for string in sorted(set(analysis['strings']))[:30]:  # Первые 30
            if len(string) > 0 and len(string) < 100:
                clean_code.append(f'-- "{string}"')
        clean_code.append("")
    
    # Добавляем читаемые части
    if readable_parts:
        clean_code.append("-- ЧИТАЕМЫЕ ЧАСТИ КОДА:")
        for part in readable_parts[:50]:  # Первые 50
            clean_code.append(f"-- {part}")
        clean_code.append("")
    
    return '\n'.join(clean_code)

def main():
    if len(sys.argv) != 2:
        print("Использование: python3 final_deobfuscator.py <файл>")
        return
    
    filename = sys.argv[1]
    
    print(f"Финальная деобфускация файла: {filename}")
    print("=" * 60)
    
    # Читаем файл
    content = read_file(filename)
    if not content:
        return
    
    # Извлекаем полезную нагрузку MoonSec
    params, main_code = extract_moonsec_payload(content)
    
    if main_code:
        # Анализируем структуру
        analysis = analyze_lua_structure(main_code)
        
        print(f"\nАНАЛИЗ СТРУКТУРЫ:")
        print(f"Функций найдено: {len(analysis['functions'])}")
        print(f"Переменных найдено: {len(analysis['variables'])}")
        print(f"Строк найдено: {len(analysis['strings'])}")
        print(f"Чисел найдено: {len(analysis['numbers'])}")
        
        # Декодируем строки
        decoded_strings = decode_obfuscated_strings(main_code)
        
        # Извлекаем читаемые части
        readable_parts = extract_readable_code(main_code)
        
        # Создаем чистую структуру
        clean_code = create_clean_lua_structure(analysis, readable_parts)
        
        # Сохраняем результаты
        base_name = os.path.splitext(filename)[0]
        
        # Сохраняем чистый код
        clean_filename = f"{base_name}_clean_structure.lua"
        write_file(clean_filename, clean_code)
        print(f"\nЧистая структура сохранена в: {clean_filename}")
        
        # Сохраняем декодированные строки
        if decoded_strings:
            decoded_filename = f"{base_name}_decoded_strings.txt"
            write_file(decoded_filename, '\n'.join(decoded_strings))
            print(f"Декодированные строки сохранены в: {decoded_filename}")
        
        # Сохраняем полный анализ
        analysis_filename = f"{base_name}_full_analysis.txt"
        analysis_content = []
        analysis_content.append("ПОЛНЫЙ АНАЛИЗ ФАЙЛА")
        analysis_content.append("=" * 50)
        analysis_content.append(f"Исходный файл: {filename}")
        analysis_content.append(f"Размер файла: {len(content)} байт")
        analysis_content.append(f"Параметры функции: {params}")
        analysis_content.append(f"Размер основного кода: {len(main_code)} байт")
        analysis_content.append("")
        
        analysis_content.append("НАЙДЕННЫЕ ФУНКЦИИ:")
        for func in analysis['functions'][:20]:
            analysis_content.append(f"  function({func})")
        analysis_content.append("")
        
        analysis_content.append("ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ:")
        for var in sorted(set(analysis['variables']))[:50]:
            analysis_content.append(f"  local {var}")
        analysis_content.append("")
        
        analysis_content.append("СТРОКОВЫЕ ЛИТЕРАЛЫ:")
        for string in sorted(set(analysis['strings']))[:100]:
            if len(string) > 0 and len(string) < 200:
                analysis_content.append(f'  "{string}"')
        analysis_content.append("")
        
        if decoded_strings:
            analysis_content.append("ДЕКОДИРОВАННЫЕ СТРОКИ:")
            for decoded in decoded_strings[:50]:
                analysis_content.append(f"  {decoded}")
            analysis_content.append("")
        
        analysis_content.append("ЧИТАЕМЫЕ ЧАСТИ КОДА:")
        for part in readable_parts[:100]:
            analysis_content.append(f"  {part}")
        
        write_file(analysis_filename, '\n'.join(analysis_content))
        print(f"Полный анализ сохранен в: {analysis_filename}")
        
        print("\n" + "=" * 60)
        print("ДЕОБФУСКАЦИЯ ЗАВЕРШЕНА!")
        print(f"Создано файлов: 3")
        print(f"1. {clean_filename} - Чистая структура кода")
        print(f"2. {analysis_filename} - Полный анализ")
        if decoded_strings:
            print(f"3. {decoded_filename} - Декодированные строки")
    else:
        print("Не удалось извлечь код из MoonSec структуры")

if __name__ == "__main__":
    main()