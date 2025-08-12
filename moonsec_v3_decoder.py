#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MoonSec V3 Specialized Decoder
Специализированный декодер для MoonSec V3
"""

import re
import binascii

def decode_byte_sequences(content):
    """Декодирует байтовые последовательности в читаемые строки"""
    # Ищем строки с escape-последовательностями
    pattern = r"'([^']*(?:\\[0-9]+[^']*)+)'"
    matches = re.findall(pattern, content)
    
    decoded_strings = {}
    
    for match in matches:
        try:
            # Заменяем \номер на соответствующий символ
            decoded = match
            # Ищем все escape-последовательности
            escape_pattern = r'\\(\d+)'
            for escape_match in re.finditer(escape_pattern, match):
                byte_val = int(escape_match.group(1))
                if 0 <= byte_val <= 255:
                    try:
                        char = chr(byte_val)
                        decoded = decoded.replace(escape_match.group(0), char)
                    except:
                        pass
            
            if decoded != match and len(decoded) > 3:
                decoded_strings[match] = decoded
                
        except Exception as e:
            continue
    
    return decoded_strings

def extract_obfuscated_functions(content):
    """Извлекает обфусцированные функции и попытается их декодировать"""
    functions = {}
    
    # Ищем присваивания функций
    function_pattern = r'(\w+)\s*=\s*([^;]+);'
    matches = re.findall(function_pattern, content)
    
    for var_name, func_body in matches:
        if len(func_body) > 10 and ('function' in func_body or '(' in func_body):
            functions[var_name] = func_body
    
    return functions

def analyze_string_operations(content):
    """Анализирует операции со строками для поиска декодирования"""
    operations = []
    
    # Ищем gsub операции
    gsub_pattern = r'\.gsub\s*\([^)]+\)'
    gsub_matches = re.findall(gsub_pattern, content)
    operations.extend(gsub_matches)
    
    # Ищем операции с байтами
    byte_pattern = r'\.byte\s*\([^)]+\)'
    byte_matches = re.findall(byte_pattern, content)
    operations.extend(byte_matches)
    
    # Ищем char операции
    char_pattern = r'\.char\s*\([^)]+\)'
    char_matches = re.findall(char_pattern, content)
    operations.extend(char_matches)
    
    return operations

def try_decode_main_function(content):
    """Попытка декодировать основную функцию"""
    # Ищем основной блок кода после защиты MoonSec
    main_pattern = r'return\s*\(\s*function\s*\([^)]*\)(.+)'
    match = re.search(main_pattern, content, re.DOTALL)
    
    if match:
        main_code = match.group(1)
        print(f"Found main function block: {len(main_code)} characters")
        
        # Попытаемся найти константы
        constants = re.findall(r'local\s+(\w+)\s*=\s*(\d+)', main_code)
        if constants:
            print("\nFound constants:")
            for name, value in constants[:10]:
                print(f"  {name} = {value}")
        
        return main_code[:1000]  # Возвращаем первые 1000 символов
    
    return None

def decode_moonsec_v3(file_path):
    """Основная функция декодирования MoonSec V3"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        print("=== MoonSec V3 Decoder ===")
        print(f"Processing file: {file_path}")
        print(f"File size: {len(content)} bytes")
        
        # 1. Декодирование байтовых последовательностей
        print("\n1. Decoding byte sequences...")
        byte_strings = decode_byte_sequences(content)
        if byte_strings:
            print(f"Found {len(byte_strings)} encoded strings:")
            for original, decoded in list(byte_strings.items())[:5]:
                print(f"  '{original[:50]}...' -> '{decoded}'")
        
        # 2. Извлечение функций
        print("\n2. Extracting obfuscated functions...")
        functions = extract_obfuscated_functions(content)
        if functions:
            print(f"Found {len(functions)} function assignments:")
            for name, body in list(functions.items())[:5]:
                print(f"  {name}: {body[:100]}...")
        
        # 3. Анализ строковых операций
        print("\n3. Analyzing string operations...")
        operations = analyze_string_operations(content)
        if operations:
            print(f"Found {len(operations)} string operations:")
            for op in operations[:5]:
                print(f"  {op}")
        
        # 4. Попытка декодировать основную функцию
        print("\n4. Attempting to decode main function...")
        main_code = try_decode_main_function(content)
        if main_code:
            print(f"Main function preview:\n{main_code[:500]}...")
        
        # 5. Поиск ключевых слов Lua
        print("\n5. Searching for Lua keywords...")
        lua_keywords = ['function', 'local', 'return', 'if', 'then', 'else', 'end', 'for', 'while', 'do']
        keyword_counts = {}
        for keyword in lua_keywords:
            count = len(re.findall(r'\b' + keyword + r'\b', content))
            if count > 0:
                keyword_counts[keyword] = count
        
        print("Lua keyword frequency:")
        for keyword, count in sorted(keyword_counts.items(), key=lambda x: x[1], reverse=True):
            print(f"  {keyword}: {count}")
        
        # 6. Попытка создать декодированную версию
        print("\n6. Creating partially decoded version...")
        decoded_content = content
        
        # Заменяем найденные байтовые строки
        for original, decoded in byte_strings.items():
            if len(decoded) > 3:
                decoded_content = decoded_content.replace(f"'{original}'", f'"{decoded}"')
        
        # Сохраняем частично декодированную версию
        output_file = file_path + "_partially_decoded.lua"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(decoded_content)
        
        print(f"✓ Partially decoded file saved as: {output_file}")
        
        # 7. Извлечение возможного исходного кода
        print("\n7. Attempting to extract original code structure...")
        
        # Ищем паттерны, которые могут указывать на исходный код
        code_patterns = [
            r'local\s+function\s+\w+\s*\([^)]*\)',
            r'function\s+\w+\s*\([^)]*\)',
            r'if\s+.+\s+then',
            r'for\s+\w+\s*=.+do',
            r'while\s+.+\s+do',
        ]
        
        for pattern in code_patterns:
            matches = re.findall(pattern, decoded_content)
            if matches:
                print(f"  Found {len(matches)} instances of pattern: {pattern}")
                if matches:
                    print(f"    Example: {matches[0]}")
        
        return True
        
    except Exception as e:
        print(f"Error decoding file: {e}")
        return False

if __name__ == "__main__":
    success = decode_moonsec_v3("eblan")
    if success:
        print("\n✅ Decoding completed successfully!")
    else:
        print("\n❌ Decoding failed!")