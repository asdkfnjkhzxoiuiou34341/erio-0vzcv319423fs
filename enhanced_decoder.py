#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Enhanced MoonSec V3 Decoder
Улучшенный декодер для более глубокой деобфускации
"""

import re
import string

def decode_byte_sequences_advanced(content):
    """Расширенное декодирование байтовых последовательностей"""
    decoded_strings = {}
    
    # Ищем различные паттерны escape-последовательностей
    patterns = [
        r"'([^']*(?:\\[0-9]+[^']*)+)'",  # Одинарные кавычки
        r'"([^"]*(?:\\[0-9]+[^"]*)+)"',  # Двойные кавычки
        r'\\([0-9]+)',                    # Прямые escape-последовательности
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, content)
        for match in matches:
            try:
                if '\\' in match:
                    # Заменяем все escape-последовательности
                    decoded = ""
                    i = 0
                    while i < len(match):
                        if match[i:i+1] == '\\' and i+1 < len(match):
                            # Извлекаем число после обратного слеша
                            num_str = ""
                            j = i + 1
                            while j < len(match) and match[j].isdigit():
                                num_str += match[j]
                                j += 1
                            
                            if num_str:
                                byte_val = int(num_str)
                                if 0 <= byte_val <= 255:
                                    try:
                                        decoded += chr(byte_val)
                                    except:
                                        decoded += f"\\{byte_val}"
                                else:
                                    decoded += f"\\{byte_val}"
                                i = j
                            else:
                                decoded += match[i]
                                i += 1
                        else:
                            decoded += match[i]
                            i += 1
                    
                    if decoded and decoded not in decoded_strings:
                        decoded_strings[match] = decoded
                        
            except Exception as e:
                continue
    
    return decoded_strings

def beautify_lua_code(content):
    """Улучшение форматирования Lua кода"""
    # Заменяем последовательности пробелов и символов
    content = re.sub(r'\s+', ' ', content)
    
    # Добавляем переносы строк после определенных конструкций
    content = re.sub(r'(end|then|do)\s+', r'\1\n', content)
    content = re.sub(r';\s*', ';\n', content)
    content = re.sub(r'(\w+)\s*=\s*function\s*\(', r'\n\1 = function(', content)
    content = re.sub(r'local\s+(\w+)', r'\nlocal \1', content)
    content = re.sub(r'if\s+', r'\nif ', content)
    content = re.sub(r'while\s+', r'\nwhile ', content)
    content = re.sub(r'for\s+', r'\nfor ', content)
    
    return content

def extract_variable_mappings(content):
    """Извлекает мапинги переменных из обфусцированного кода"""
    mappings = {}
    
    # Ищем простые присваивания переменных
    var_patterns = [
        r'([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*"([^"]*)"',
        r"([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*'([^']*)'",
        r'([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*([a-zA-Z_][a-zA-Z0-9_]*)',
    ]
    
    for pattern in var_patterns:
        matches = re.findall(pattern, content)
        for var_name, value in matches:
            if len(var_name) <= 3 and len(value) > 3:  # Короткие имена -> длинные значения
                mappings[var_name] = value
    
    return mappings

def analyze_moonsec_structure(content):
    """Анализирует структуру MoonSec обфускации"""
    print("=== Структурный анализ MoonSec V3 ===")
    
    # Ищем основные компоненты
    components = {
        'gsub_calls': len(re.findall(r'gsub\s*\([^)]+\)', content)),
        'loadstring_calls': len(re.findall(r'loadstring\s*\([^)]+\)', content)),
        'getfenv_calls': len(re.findall(r'getfenv\s*\([^)]*\)', content)),
        'string_byte': len(re.findall(r'string\.byte', content)),
        'string_char': len(re.findall(r'string\.char', content)),
        'table_concat': len(re.findall(r'table\.concat', content)),
        'tonumber_calls': len(re.findall(r'tonumber\s*\([^)]+\)', content)),
    }
    
    for component, count in components.items():
        print(f"{component}: {count}")
    
    # Ищем подозрительные функции
    suspicious = re.findall(r'([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*function\s*\([^)]*\)', content)
    print(f"\nОбнаружено функций: {len(suspicious)}")
    
    return components

def main():
    input_file = '/workspace/eblan'
    output_file = '/workspace/eblan_enhanced_decoded.lua'
    
    print("Загружаем обфусцированный файл...")
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    print(f"Размер файла: {len(content)} символов")
    
    # Структурный анализ
    analyze_moonsec_structure(content)
    
    print("\nДекодируем байтовые последовательности...")
    decoded_strings = decode_byte_sequences_advanced(content)
    
    print(f"Найдено декодированных строк: {len(decoded_strings)}")
    
    # Показываем примеры декодированных строк
    print("\nПримеры декодированных строк:")
    count = 0
    for original, decoded in decoded_strings.items():
        if count < 20 and len(decoded) > 2:
            print(f"'{original[:50]}...' -> '{decoded}'")
            count += 1
    
    # Заменяем обфусцированные строки на декодированные
    result = content
    for original, decoded in decoded_strings.items():
        if len(decoded) > 1 and decoded.isprintable():
            # Экранируем специальные символы для regex
            safe_original = re.escape(original)
            result = re.sub(f"'{safe_original}'", f"'{decoded}'", result)
            result = re.sub(f'"{re.escape(original)}"', f'"{decoded}"', result)
    
    print("\nИзвлекаем мапинги переменных...")
    mappings = extract_variable_mappings(result)
    print(f"Найдено мапингов: {len(mappings)}")
    
    # Применяем мапинги переменных
    for short_name, long_name in mappings.items():
        if len(short_name) <= 3 and len(long_name) > 3:
            # Заменяем только изолированные вхождения
            result = re.sub(r'\b' + re.escape(short_name) + r'\b', long_name, result)
    
    print("\nУлучшаем форматирование...")
    result = beautify_lua_code(result)
    
    # Сохраняем результат
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(result)
    
    print(f"\nУлучшенная расшифровка сохранена в: {output_file}")
    print(f"Размер декодированного файла: {len(result)} символов")
    
    # Статистика улучшений
    improvements = {
        'Исходный размер': len(content),
        'Декодированный размер': len(result),
        'Декодированных строк': len(decoded_strings),
        'Мапингов переменных': len(mappings),
    }
    
    print("\n=== Статистика улучшений ===")
    for key, value in improvements.items():
        print(f"{key}: {value}")

if __name__ == "__main__":
    main()