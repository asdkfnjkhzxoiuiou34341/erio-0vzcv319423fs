#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MoonSec V3 Analyzer
Попытка анализа обфусцированного Lua кода
"""

import re
import string

def analyze_moonsec(file_path):
    """Анализ файла MoonSec V3"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        print(f"=== Анализ файла {file_path} ===")
        print(f"Размер файла: {len(content)} символов")
        
        # Проверяем заголовок MoonSec
        if "This file was protected with MoonSec V3" in content:
            print("✓ Подтверждено: файл защищен MoonSec V3")
        
        # Анализ структуры
        print("\n=== Структурный анализ ===")
        
        # Ищем функции
        function_pattern = r'function\s*\([^)]*\)'
        functions = re.findall(function_pattern, content)
        print(f"Найдено функций: {len(functions)}")
        
        # Ищем строки
        string_pattern = r'"[^"]*"'
        strings = re.findall(string_pattern, content)
        print(f"Найдено строк: {len(strings)}")
        
        # Ищем числа
        number_pattern = r'\b\d+\b'
        numbers = re.findall(number_pattern, content)
        print(f"Найдено чисел: {len(numbers)}")
        
        # Анализ переменных
        var_pattern = r'\b[a-zA-Z_][a-zA-Z0-9_]*\b'
        variables = set(re.findall(var_pattern, content))
        print(f"Уникальных переменных: {len(variables)}")
        
        # Поиск возможных ключевых слов Lua
        lua_keywords = ['local', 'function', 'end', 'if', 'then', 'else', 'for', 'while', 'do', 'return', 'nil', 'true', 'false']
        found_keywords = []
        for keyword in lua_keywords:
            if keyword in content:
                count = content.count(keyword)
                found_keywords.append((keyword, count))
        
        print("\n=== Найденные ключевые слова Lua ===")
        for keyword, count in found_keywords:
            print(f"{keyword}: {count} раз")
        
        # Попытка найти шаблоны обфускации
        print("\n=== Анализ обфускации ===")
        
        # Поиск hex-строк
        hex_pattern = r'\\x[0-9a-fA-F]{2}'
        hex_strings = re.findall(hex_pattern, content)
        if hex_strings:
            print(f"Найдено hex-кодированных символов: {len(hex_strings)}")
        
        # Поиск числовых последовательностей
        big_numbers = [num for num in numbers if len(num) > 4]
        if big_numbers:
            print(f"Найдено больших чисел: {len(big_numbers)}")
            print(f"Примеры: {big_numbers[:5]}")
        
        # Поиск возможных функций декодирования
        decode_patterns = ['gsub', 'char', 'byte', 'sub', 'concat']
        for pattern in decode_patterns:
            count = content.count(pattern)
            if count > 0:
                print(f"Функция {pattern}: {count} раз")
        
        # Извлечение первых нескольких строк кода
        print("\n=== Первые строки кода ===")
        lines = content.split('\n')
        for i, line in enumerate(lines[:5]):
            print(f"{i+1}: {line[:100]}{'...' if len(line) > 100 else ''}")
        
        return True
        
    except FileNotFoundError:
        print(f"Файл {file_path} не найден")
        return False
    except Exception as e:
        print(f"Ошибка при анализе файла: {e}")
        return False

def extract_strings(file_path):
    """Извлечение строк из файла"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Поиск всех строк в кавычках
        string_pattern = r'"([^"]*)"'
        strings = re.findall(string_pattern, content)
        
        print("\n=== Извлеченные строки ===")
        unique_strings = list(set(strings))
        for i, s in enumerate(unique_strings[:20]):  # Показываем первые 20
            if s.strip():  # Только непустые строки
                print(f"{i+1}: {s}")
        
        if len(unique_strings) > 20:
            print(f"... и еще {len(unique_strings) - 20} строк")
        
        return unique_strings
        
    except Exception as e:
        print(f"Ошибка при извлечении строк: {e}")
        return []

if __name__ == "__main__":
    file_path = "eblan"
    
    print("MoonSec V3 Analyzer")
    print("=" * 50)
    
    if analyze_moonsec(file_path):
        extract_strings(file_path)
    
    print("\n" + "=" * 50)
    print("Анализ завершен")
    
    print("\nПримечание:")
    print("MoonSec V3 - это сложная система обфускации Lua кода.")
    print("Полная расшифровка требует специализированных инструментов")
    print("или ручного реверс-инжиниринга кода.")