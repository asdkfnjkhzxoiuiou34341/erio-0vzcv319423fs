#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MoonSec V3 Specialized Decoder
Расшифровщик на основе обнаруженных байтовых последовательностей
"""

import re
import string

def decode_byte_sequences(text):
    """Декодирует байтовые последовательности в строки"""
    # Найдем все байтовые последовательности в строках
    pattern = r"'([^']*\\\\?\d+[^']*)'"
    matches = re.findall(pattern, text)
    
    decoded_strings = []
    
    for match in matches:
        if '\\' in match:
            # Извлекаем числа после обратных слешей
            byte_pattern = r'\\(\d+)'
            byte_matches = re.findall(byte_pattern, match)
            
            if byte_matches:
                try:
                    # Конвертируем в байты и декодируем
                    bytes_data = bytes([int(x) for x in byte_matches])
                    decoded = bytes_data.decode('utf-8', errors='ignore')
                    if decoded.strip():
                        decoded_strings.append((match, decoded))
                        print(f"Decoded: '{match}' -> '{decoded}'")
                except:
                    continue
    
    return decoded_strings

def analyze_character_mapping(text):
    """Анализирует возможное сопоставление символов"""
    # Получаем частоту символов
    char_freq = {}
    for char in text:
        if char.isalnum() or char in '!@#$%^&*()_+-=[]{}|;:,.<>?':
            char_freq[char] = char_freq.get(char, 0) + 1
    
    # Сортируем по частоте
    sorted_chars = sorted(char_freq.items(), key=lambda x: x[1], reverse=True)
    
    print("Top 20 most frequent characters:")
    for char, freq in sorted_chars[:20]:
        print(f"  '{char}': {freq} times")
    
    return sorted_chars

def try_character_substitution(text, char_map):
    """Пытается заменить символы согласно карте"""
    result = text
    for old_char, new_char in char_map.items():
        result = result.replace(old_char, new_char)
    return result

def extract_probable_lua_code(text):
    """Извлекает вероятный Lua код"""
    # Ищем участки, которые могут быть кодом
    # Начинаем с поиска структур типа функций
    
    # Попробуем найти паттерны, характерные для Lua
    lua_keywords = ['function', 'local', 'end', 'if', 'then', 'else', 'for', 'while', 'do', 'return']
    
    # Заменим наиболее частые символы на возможные Lua символы
    freq_to_lua = {
        '!': 'e',  # Самый частый символ в английском
        '#': 'a',
        '%': 't',
        '&': 'o',
        'S': 'n',
        'z': 'r',
        'g': 'i',
        'm': 's',
        '6': 'l',
        '7': 'h'
    }
    
    # Применяем замены
    decoded_attempt = text
    for old, new in freq_to_lua.items():
        decoded_attempt = decoded_attempt.replace(old, new)
    
    return decoded_attempt

def find_hidden_strings(text):
    """Ищет скрытые строки в тексте"""
    # Ищем паттерны с числами, которые могут быть ASCII кодами
    ascii_pattern = r'(\d+)'
    numbers = re.findall(ascii_pattern, text)
    
    potential_strings = []
    
    # Группируем числа и пытаемся декодировать как ASCII
    for i in range(0, len(numbers) - 5, 5):  # Берем группы по 5 чисел
        try:
            ascii_codes = [int(num) for num in numbers[i:i+5]]
            # Проверяем, что все коды в диапазоне ASCII
            if all(32 <= code <= 126 for code in ascii_codes):
                decoded = ''.join(chr(code) for code in ascii_codes)
                if decoded.isalpha() or ' ' in decoded:  # Если содержит буквы или пробелы
                    potential_strings.append(decoded)
        except:
            continue
    
    return potential_strings

def main():
    print("=== MoonSec V3 Specialized Decoder ===")
    
    # Читаем файл
    try:
        with open('/workspace/eblan', 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        with open('/workspace/eblan', 'rb') as f:
            raw_content = f.read()
            content = raw_content.decode('utf-8', errors='ignore')
    
    print(f"File size: {len(content)} characters")
    
    # Декодируем байтовые последовательности
    print("\n=== Decoding Byte Sequences ===")
    decoded_strings = decode_byte_sequences(content)
    
    # Анализируем частоту символов
    print("\n=== Character Frequency Analysis ===")
    char_freq = analyze_character_mapping(content)
    
    # Ищем скрытые строки
    print("\n=== Hidden Strings Search ===")
    hidden_strings = find_hidden_strings(content)
    if hidden_strings:
        print("Potential hidden strings found:")
        for s in hidden_strings[:20]:  # Показываем первые 20
            print(f"  '{s}'")
    else:
        print("No obvious hidden strings found")
    
    # Попытка декодирования с заменой символов
    print("\n=== Character Substitution Attempt ===")
    sample = content[:1000]  # Берем образец для тестирования
    decoded_sample = extract_probable_lua_code(sample)
    
    print("Original sample (first 200 chars):")
    print(sample[:200])
    print("\nDecoded sample (first 200 chars):")
    print(decoded_sample[:200])
    
    # Ищем Lua-подобные структуры в декодированном тексте
    lua_patterns = ['function', 'local', 'end', 'return', 'if then', 'for do']
    found_patterns = []
    for pattern in lua_patterns:
        if pattern in decoded_sample.lower():
            found_patterns.append(pattern)
    
    if found_patterns:
        print(f"\nFound Lua-like patterns: {found_patterns}")
    else:
        print("\nNo clear Lua patterns found with simple substitution")
    
    # Пытаемся найти оригинальный код через анализ структуры
    print("\n=== Structure Analysis ===")
    
    # Ищем участки с высокой энтропией (возможно, зашифрованный код)
    lines = content.split('\n')
    print(f"Total lines: {len(lines)}")
    
    # Ищем самые длинные строки (вероятно, содержат основной код)
    long_lines = [(i, len(line), line) for i, line in enumerate(lines) if len(line) > 1000]
    long_lines.sort(key=lambda x: x[1], reverse=True)
    
    print(f"Found {len(long_lines)} long lines (>1000 chars)")
    if long_lines:
        print("Longest lines:")
        for i, (line_num, length, line_content) in enumerate(long_lines[:5]):
            print(f"  Line {line_num+1}: {length} characters")
            # Попробуем декодировать начало самой длинной строки
            if i == 0:
                print(f"    Sample: {line_content[:100]}...")
    
    print("\n=== Decoding Complete ===")
    print("Note: MoonSec V3 uses complex obfuscation that may require")
    print("specialized tools or manual reverse engineering to fully decode.")

if __name__ == "__main__":
    main()