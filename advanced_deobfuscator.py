#!/usr/bin/env python3

import re
import sys
import os
import base64
import binascii

def read_file(filename):
    """Читает содержимое файла"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
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

def extract_encoded_data(content):
    """Извлекает закодированные данные из MoonSec"""
    print("Извлекаю закодированные данные...")
    
    # Ищем основную закодированную строку
    main_encoded = re.search(r't="([^"]{100,})"', content)
    if main_encoded:
        encoded_str = main_encoded.group(1)
        print(f"Найдена основная закодированная строка длиной: {len(encoded_str)}")
        return encoded_str
    
    return None

def decode_lua_string(encoded_str):
    """Декодирует Lua строку с escape-последовательностями"""
    result = []
    i = 0
    while i < len(encoded_str):
        if encoded_str[i] == '\\' and i + 1 < len(encoded_str):
            next_char = encoded_str[i + 1]
            if next_char.isdigit():
                # Собираем число после обратного слеша
                num_str = ''
                j = i + 1
                while j < len(encoded_str) and j < i + 4 and encoded_str[j].isdigit():
                    num_str += encoded_str[j]
                    j += 1
                if num_str:
                    try:
                        char_code = int(num_str)
                        if 0 <= char_code <= 255:
                            result.append(chr(char_code))
                        i = j
                        continue
                    except ValueError:
                        pass
            elif next_char == 'n':
                result.append('\n')
                i += 2
                continue
            elif next_char == 't':
                result.append('\t')
                i += 2
                continue
            elif next_char == 'r':
                result.append('\r')
                i += 2
                continue
            elif next_char == '\\':
                result.append('\\')
                i += 2
                continue
            elif next_char == '"':
                result.append('"')
                i += 2
                continue
        
        result.append(encoded_str[i])
        i += 1
    
    return ''.join(result)

def analyze_lua_bytecode(data):
    """Анализирует возможный Lua байткод"""
    print("Анализирую данные на предмет Lua байткода...")
    
    # Lua байткод начинается с сигнатуры
    lua_signatures = [
        b'\x1bLua',  # Lua 5.1+
        b'LuaS',     # Некоторые варианты
        b'Lua\x53\x00',  # Lua 5.3
        b'Lua\x54\x00'   # Lua 5.4
    ]
    
    # Проверяем различные кодировки данных
    encodings_to_try = [
        ('raw', data),
        ('base64', None),
        ('hex', None),
        ('utf-8', None)
    ]
    
    # Пробуем base64
    try:
        b64_decoded = base64.b64decode(data)
        encodings_to_try[1] = ('base64', b64_decoded)
    except:
        pass
    
    # Пробуем hex
    try:
        hex_decoded = binascii.unhexlify(data)
        encodings_to_try[2] = ('hex', hex_decoded)
    except:
        pass
    
    # Пробуем UTF-8
    try:
        utf8_data = data.encode('utf-8')
        encodings_to_try[3] = ('utf-8', utf8_data)
    except:
        pass
    
    for encoding_name, binary_data in encodings_to_try:
        if binary_data is None:
            continue
            
        # Проверяем на сигнатуры Lua
        for sig in lua_signatures:
            if isinstance(binary_data, str):
                binary_data = binary_data.encode('latin-1')
            
            if binary_data.startswith(sig):
                print(f"Найден Lua байткод с кодировкой {encoding_name}!")
                return binary_data, encoding_name
    
    return None, None

def extract_function_calls(content):
    """Извлекает вызовы функций из кода"""
    print("Извлекаю вызовы функций...")
    
    # Паттерны для поиска вызовов функций
    patterns = [
        r'(\w+)\s*\(',  # Простые вызовы функций
        r'(\w+)\.(\w+)\s*\(',  # Методы объектов
        r'(\w+)\[([^\]]+)\]\s*\(',  # Индексированные вызовы
    ]
    
    function_calls = set()
    
    for pattern in patterns:
        matches = re.findall(pattern, content)
        for match in matches:
            if isinstance(match, tuple):
                function_calls.add('.'.join(match))
            else:
                function_calls.add(match)
    
    return sorted(list(function_calls))

def find_string_patterns(content):
    """Находит паттерны строк, которые могут быть полезными"""
    print("Ищу полезные строковые паттерны...")
    
    patterns = {
        'urls': r'https?://[^\s"\']+',
        'file_paths': r'[a-zA-Z]:\\[^"\']+|/[^"\']+',
        'function_names': r'function\s+(\w+)',
        'require_calls': r'require\s*\(\s*["\']([^"\']+)["\']',
        'api_keys': r'[A-Za-z0-9]{32,}',
        'ip_addresses': r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b',
        'domains': r'[a-zA-Z0-9-]+\.[a-zA-Z]{2,}',
    }
    
    findings = {}
    
    for pattern_name, pattern in patterns.items():
        matches = re.findall(pattern, content)
        if matches:
            findings[pattern_name] = matches[:10]  # Ограничиваем вывод
    
    return findings

def advanced_deobfuscate(content):
    """Продвинутая деобфускация MoonSec"""
    print("=== ПРОДВИНУТАЯ ДЕОБФУСКАЦИЯ MOONSEC V3 ===")
    
    result = []
    result.append("-- ПРОДВИНУТЫЙ АНАЛИЗ MOONSEC V3")
    result.append("-- Создано автоматическим деобфускатором")
    result.append("")
    
    # 1. Извлекаем основные закодированные данные
    encoded_data = extract_encoded_data(content)
    if encoded_data:
        result.append(f"-- Найдена основная закодированная строка: {len(encoded_data)} символов")
        
        # Декодируем строку
        decoded_string = decode_lua_string(encoded_data)
        result.append(f"-- Декодированная длина: {len(decoded_string)} символов")
        
        # Анализируем на байткод
        bytecode, encoding = analyze_lua_bytecode(decoded_string)
        if bytecode:
            result.append(f"-- НАЙДЕН LUA БАЙТКОД! Кодировка: {encoding}")
            result.append(f"-- Размер байткода: {len(bytecode)} байт")
            
            # Сохраняем байткод в отдельный файл
            with open('extracted_bytecode.luac', 'wb') as f:
                f.write(bytecode)
            result.append("-- Байткод сохранен в extracted_bytecode.luac")
        else:
            # Если не байткод, анализируем как текст
            result.append("-- Анализирую декодированные данные как текст...")
            
            # Ищем читаемые части
            readable_parts = []
            lines = decoded_string.split('\n')
            for line in lines[:20]:  # Первые 20 строк
                if line.strip() and len(line) < 200:
                    readable_parts.append(line.strip())
            
            if readable_parts:
                result.append("-- Читаемые части декодированных данных:")
                for part in readable_parts:
                    result.append(f"-- {part}")
    
    # 2. Анализируем вызовы функций
    function_calls = extract_function_calls(content)
    if function_calls:
        result.append("")
        result.append("-- НАЙДЕННЫЕ ВЫЗОВЫ ФУНКЦИЙ:")
        for call in function_calls[:30]:  # Первые 30
            result.append(f"-- {call}")
    
    # 3. Ищем полезные паттерны
    patterns = find_string_patterns(content)
    if patterns:
        result.append("")
        result.append("-- НАЙДЕННЫЕ ПАТТЕРНЫ:")
        for pattern_type, matches in patterns.items():
            result.append(f"-- {pattern_type.upper()}:")
            for match in matches:
                result.append(f"--   {match}")
    
    # 4. Анализируем структуру обфускации
    result.append("")
    result.append("-- АНАЛИЗ СТРУКТУРЫ ОБФУСКАЦИИ:")
    
    # Считаем различные элементы
    local_count = len(re.findall(r'local\s+\w+', content))
    function_count = len(re.findall(r'function\s*\(', content))
    while_count = len(re.findall(r'while\s+', content))
    if_count = len(re.findall(r'if\s*\(', content))
    
    result.append(f"-- Локальных переменных: {local_count}")
    result.append(f"-- Функций: {function_count}")
    result.append(f"-- Циклов while: {while_count}")
    result.append(f"-- Условий if: {if_count}")
    
    # 5. Пытаемся найти точки входа
    result.append("")
    result.append("-- ВОЗМОЖНЫЕ ТОЧКИ ВХОДА:")
    
    entry_patterns = [
        r'return\s*\(([^)]+)\)',
        r'loadstring\s*\(',
        r'load\s*\(',
        r'dofile\s*\(',
    ]
    
    for pattern in entry_patterns:
        matches = re.findall(pattern, content)
        if matches:
            result.append(f"-- Найден паттерн {pattern}: {len(matches)} раз")
    
    return '\n'.join(result)

def main():
    """Основная функция"""
    filename = sys.argv[1] if len(sys.argv) > 1 else "eblan"
    
    if not os.path.exists(filename):
        print(f"Файл {filename} не найден")
        return 1
    
    print(f"Читаю файл: {filename}")
    content = read_file(filename)
    
    if not content:
        return 1
    
    print(f"Размер файла: {len(content)} байт")
    
    # Выполняем продвинутую деобфускацию
    deobfuscated = advanced_deobfuscate(content)
    
    if deobfuscated:
        output_file = f"{filename}_advanced_analysis.txt"
        if write_file(output_file, deobfuscated):
            print(f"Продвинутый анализ сохранен в: {output_file}")
        else:
            print("Ошибка при сохранении файла")
            return 1
    else:
        print("Анализ не удался")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())