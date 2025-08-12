#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Simple MoonSec V3 Decoder
Попытка расшифровки обфусцированного Lua кода
"""

import re
import base64
import binascii

def try_base64_decode(text):
    """Пытается декодировать base64"""
    try:
        # Попробуем разные варианты base64
        decoded = base64.b64decode(text)
        return decoded.decode('utf-8', errors='ignore')
    except:
        return None

def extract_strings(text):
    """Извлекает строки из кода"""
    # Ищем строки в кавычках
    strings = re.findall(r'"([^"]*)"', text)
    strings.extend(re.findall(r"'([^']*)'", text))
    return strings

def find_constant_patterns(text):
    """Ищет паттерны констант"""
    patterns = []
    
    # Ищем числовые последовательности
    numbers = re.findall(r'\b\d+\b', text)
    patterns.append(f"Numbers found: {len(numbers)}")
    
    # Ищем hex значения
    hex_values = re.findall(r'\\x[0-9a-fA-F]{2}', text)
    patterns.append(f"Hex values: {len(hex_values)}")
    
    # Ищем функции loadstring, unpack
    functions = re.findall(r'(loadstring|unpack|string\.char|string\.byte)', text)
    patterns.append(f"Key functions: {set(functions)}")
    
    return patterns

def analyze_structure(text):
    """Анализирует структуру кода"""
    analysis = []
    
    # Подсчет символов
    analysis.append(f"Total length: {len(text)}")
    
    # Уникальные символы
    unique_chars = set(text)
    analysis.append(f"Unique characters: {len(unique_chars)}")
    
    # Частота символов
    char_freq = {}
    for char in text:
        char_freq[char] = char_freq.get(char, 0) + 1
    
    # Топ-10 наиболее частых символов
    top_chars = sorted(char_freq.items(), key=lambda x: x[1], reverse=True)[:10]
    analysis.append(f"Most frequent chars: {top_chars}")
    
    return analysis

def try_simple_substitution(text):
    """Пытается простые замены"""
    # Попробуем заменить некоторые символы
    substitutions = [
        ('!', '1'),
        ('#', '3'),
        ('%', '5'),
        ('&', '6'),
        ('*', '8'),
        ('?', '7'),
    ]
    
    for old, new in substitutions:
        if old in text:
            print(f"Found character '{old}' - trying substitution with '{new}'")
    
    return text

def extract_byte_sequences(text):
    """Извлекает последовательности байтов"""
    # Ищем паттерны вида \number\number...
    byte_pattern = r'\\(\d+)'
    matches = re.findall(byte_pattern, text)
    
    if matches:
        print(f"Found {len(matches)} byte sequences")
        # Попробуем декодировать первые 20
        try:
            bytes_data = bytes([int(x) for x in matches[:50]])
            decoded = bytes_data.decode('utf-8', errors='ignore')
            if decoded:
                print(f"Decoded bytes sample: {decoded[:100]}...")
        except:
            print("Failed to decode byte sequences")

def main():
    print("=== Simple MoonSec V3 Decoder ===")
    
    try:
        with open('/workspace/eblan', 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        print("Cannot read file as UTF-8, trying binary...")
        with open('/workspace/eblan', 'rb') as f:
            raw_content = f.read()
            content = raw_content.decode('utf-8', errors='ignore')
    
    print(f"\nFile size: {len(content)} characters")
    
    # Структурный анализ
    print("\n=== Structure Analysis ===")
    structure = analyze_structure(content)
    for item in structure:
        print(item)
    
    # Поиск строк
    print("\n=== String Extraction ===")
    strings = extract_strings(content)
    print(f"Found {len(strings)} quoted strings")
    if strings:
        print("Sample strings:")
        for s in strings[:10]:
            print(f"  '{s}'")
    
    # Поиск паттернов
    print("\n=== Pattern Analysis ===")
    patterns = find_constant_patterns(content)
    for pattern in patterns:
        print(pattern)
    
    # Поиск байтовых последовательностей
    print("\n=== Byte Sequence Analysis ===")
    extract_byte_sequences(content)
    
    # Попытка простых замен
    print("\n=== Simple Substitution Analysis ===")
    try_simple_substitution(content)
    
    # Попытка найти loadstring вызовы
    print("\n=== Function Call Analysis ===")
    loadstring_calls = re.findall(r'loadstring\s*\([^)]+\)', content)
    print(f"Found {len(loadstring_calls)} loadstring calls")
    
    # Поиск base64-подобных строк
    print("\n=== Base64-like Strings ===")
    b64_candidates = re.findall(r'[A-Za-z0-9+/]{20,}={0,2}', content)
    print(f"Found {len(b64_candidates)} potential base64 strings")
    
    if b64_candidates:
        print("Trying to decode first few...")
        for i, candidate in enumerate(b64_candidates[:3]):
            decoded = try_base64_decode(candidate)
            if decoded:
                print(f"  Candidate {i+1}: {decoded[:50]}...")
    
    print("\n=== Analysis Complete ===")

if __name__ == "__main__":
    main()