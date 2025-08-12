#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Fast MoonSec V3 Decoder
Быстрый декодер основных паттернов MoonSec
"""

import re

def quick_decode():
    input_file = '/workspace/eblan'
    output_file = '/workspace/eblan_quick_decoded.lua'
    
    print("Быстрая расшифровка MoonSec V3...")
    
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    print(f"Размер файла: {len(content)} символов")
    
    # Извлекаем ключевые части кода
    # Ищем основную функцию после gsub
    match = re.search(r'gsub\(.+?\),\s*\(function\(a\)[^)]+end\)\);?\s*return\s*\((.+?)\)\(', content, re.DOTALL)
    if match:
        main_function = match.group(1)
        print("Найдена основная функция")
        
        # Простое декодирование escape-последовательностей в найденной части
        decoded_part = main_function
        
        # Ищем и заменяем простые escape-последовательности
        def replace_escape(match):
            try:
                return chr(int(match.group(1)))
            except:
                return match.group(0)
        
        decoded_part = re.sub(r'\\(\d+)', replace_escape, decoded_part)
        
        # Форматируем результат
        result = f"""-- Частично декодированный MoonSec V3
-- Исходный размер: {len(content)} символов

-- Основная функция:
{decoded_part}

-- Исходный код (первые 1000 символов):
{content[:1000]}...
"""
        
    else:
        print("Основная функция не найдена, используем базовое декодирование")
        
        # Базовое декодирование escape-последовательностей
        def replace_escape(match):
            try:
                return chr(int(match.group(1)))
            except:
                return match.group(0)
        
        # Применяем только к части файла для скорости
        sample = content[:10000]  # Первые 10000 символов
        decoded_sample = re.sub(r'\\(\d+)', replace_escape, sample)
        
        result = f"""-- Частично декодированный MoonSec V3 (образец)
-- Исходный размер: {len(content)} символов

-- Декодированный образец:
{decoded_sample}
"""
    
    # Сохраняем результат
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(result)
    
    print(f"Быстрая расшифровка сохранена в: {output_file}")
    
    # Показываем ключевую информацию
    print("\n=== Ключевая информация ===")
    
    # Ищем важные строки
    important_strings = []
    for match in re.finditer(r'["\']([^"\']{10,})["\']', content):
        string_val = match.group(1)
        if any(keyword in string_val.lower() for keyword in ['http', 'discord', 'webhook', 'script', 'load', 'game']):
            important_strings.append(string_val)
    
    if important_strings:
        print("Найдены потенциально важные строки:")
        for s in important_strings[:5]:  # Показываем первые 5
            print(f"  - {s[:100]}...")
    
    # Ищем функции
    functions = re.findall(r'function\s*\([^)]*\)', content)
    print(f"Функций найдено: {len(functions)}")
    
    # Ищем loadstring вызовы
    loadstrings = re.findall(r'loadstring\s*\([^)]+\)', content)
    print(f"Вызовов loadstring: {len(loadstrings)}")

if __name__ == "__main__":
    quick_decode()