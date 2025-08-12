#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Advanced MoonSec V3 Decoder
Улучшенный декодер на основе найденных закономерностей
"""

import re
import string

def extract_lua_functions(text):
    """Извлекает скрытые Lua функции из найденных строк"""
    # Найденные скрытые строки из предыдущего анализа
    hidden_strings = [
        'tonumber', 'string', 'char', 'false', 'string', 'sub', 
        'string', 'byte', 'ldSgWOoA', 'table', 'concat', 
        'table', 'insert'
    ]
    
    # Попытаемся найти и декодировать больше скрытых строк
    patterns = [
        r"'([^']*\\\\?\d+[^']*)'",  # Строки с escape-последовательностями
        r'"([^"]*\\\\?\d+[^"]*)"',  # То же для двойных кавычек
        r'([a-zA-Z_][a-zA-Z0-9_]*)\s*=',  # Переменные
        r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)',  # Функции
        r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)',  # Локальные переменные
    ]
    
    found_items = []
    for pattern in patterns:
        matches = re.findall(pattern, text)
        found_items.extend(matches)
    
    return list(set(found_items))

def decode_character_substitution(text):
    """Декодирует символьные замены"""
    # Анализ частоты символов показал, что 'g', 'm', 'z' - самые частые
    # Попробуем простую замену на основе частоты в Lua
    substitutions = {
        'g': 'e',  # g -> e (самый частый в английском)
        'z': 'a',  # z -> a 
        'S': 's',  # S -> s
        '{': '(',  # { -> (
        '}': ')',  # } -> )
    }
    
    result = text
    for old, new in substitutions.items():
        result = result.replace(old, new)
    
    return result

def extract_function_calls(text):
    """Извлекает вызовы функций"""
    patterns = [
        r'([a-zA-Z_][a-zA-Z0-9_]*)\s*\(',  # Обычные вызовы функций
        r'([a-zA-Z_][a-zA-Z0-9_]*)\.',     # Методы объектов
        r':([a-zA-Z_][a-zA-Z0-9_]*)\s*\(', # Методы с двоеточием
    ]
    
    functions = set()
    for pattern in patterns:
        matches = re.findall(pattern, text)
        functions.update(matches)
    
    return list(functions)

def analyze_moonsec_structure(file_path):
    """Полный анализ структуры MoonSec файла"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        print(f"=== Advanced MoonSec V3 Analysis ===")
        print(f"File: {file_path}")
        print(f"Size: {len(content)} characters")
        
        # Проверим заголовок
        if "This file was protected with MoonSec V3" in content:
            print("✓ Confirmed MoonSec V3 protection")
        
        # Извлечем скрытые функции
        print("\n=== Hidden Lua Functions ===")
        lua_functions = extract_lua_functions(content)
        for func in lua_functions[:20]:  # Показываем первые 20
            print(f"  '{func}'")
        
        # Анализ вызовов функций
        print("\n=== Function Calls ===")
        function_calls = extract_function_calls(content)
        for call in function_calls[:15]:  # Первые 15
            print(f"  {call}()")
        
        # Попытка символьной замены
        print("\n=== Character Substitution Attempt ===")
        sample = content[:500]
        decoded_sample = decode_character_substitution(sample)
        print(f"Original sample:\n{sample[:200]}...")
        print(f"\nDecoded sample:\n{decoded_sample[:200]}...")
        
        # Поиск строковых литералов
        print("\n=== String Literals ===")
        string_literals = re.findall(r'"([^"]*)"', content)
        string_literals.extend(re.findall(r"'([^']*)'", content))
        
        for literal in string_literals[:10]:
            if len(literal) > 3:
                print(f"  '{literal}'")
        
        # Поиск числовых констант
        print("\n=== Numeric Constants ===")
        numbers = re.findall(r'\b\d+\b', content)
        unique_numbers = list(set(numbers))[:15]
        print(f"  Found {len(numbers)} numbers, unique: {len(set(numbers))}")
        print(f"  Sample: {', '.join(unique_numbers)}")
        
        # Попытка найти ключевые паттерны
        print("\n=== Key Patterns ===")
        patterns = [
            (r'local\s+\w+\s*=\s*\d+', 'Local variable assignments'),
            (r'function\s*\([^)]*\)', 'Function definitions'),
            (r'return\s*\([^)]*\)', 'Return statements'),
            (r'gsub\s*\([^)]*\)', 'String substitutions'),
            (r'\\\\(\d+)', 'Escaped numbers'),
        ]
        
        for pattern, description in patterns:
            matches = re.findall(pattern, content)
            if matches:
                print(f"  {description}: {len(matches)} found")
                if matches:
                    print(f"    Sample: {matches[0]}")
        
        # Специальный поиск MoonSec маркеров
        print("\n=== MoonSec Markers ===")
        moonsec_patterns = [
            r'_[A-Z][a-zA-Z0-9_]*',  # Переменные, начинающиеся с _
            r'[a-zA-Z]{8,}',         # Длинные идентификаторы
            r'\\\\(\d{2,3})',        # Байтовые коды
        ]
        
        for i, pattern in enumerate(moonsec_patterns):
            matches = re.findall(pattern, content)
            if matches:
                print(f"  Pattern {i+1}: {len(matches)} matches")
                print(f"    Sample: {', '.join(matches[:5])}")
    
    except Exception as e:
        print(f"Error analyzing file: {e}")

if __name__ == "__main__":
    analyze_moonsec_structure("eblan")