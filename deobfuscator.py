#!/usr/bin/env python3

import re
import sys
import os

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

def extract_strings(code):
    """Извлекает строки из кода"""
    strings = []
    
    # Ищем строки в двойных кавычках
    for match in re.finditer(r'"([^"]*)"', code):
        strings.append(match.group(1))
    
    # Ищем строки в одинарных кавычках
    for match in re.finditer(r"'([^']*)'", code):
        strings.append(match.group(1))
    
    return strings

def decode_moonsec_string(encoded_str):
    """Пытается декодировать строку MoonSec"""
    try:
        # MoonSec использует различные методы кодирования
        # Пробуем базовые методы декодирования
        
        # Метод 1: Прямое декодирование символов
        decoded_chars = []
        i = 0
        while i < len(encoded_str):
            if encoded_str[i] == '\\' and i + 1 < len(encoded_str):
                next_char = encoded_str[i + 1]
                if next_char.isdigit():
                    # Декодируем числовые escape-последовательности
                    num_str = ''
                    j = i + 1
                    while j < len(encoded_str) and encoded_str[j].isdigit():
                        num_str += encoded_str[j]
                        j += 1
                    if num_str:
                        try:
                            char_code = int(num_str)
                            if 0 <= char_code <= 255:
                                decoded_chars.append(chr(char_code))
                            i = j
                            continue
                        except ValueError:
                            pass
            decoded_chars.append(encoded_str[i])
            i += 1
        
        return ''.join(decoded_chars)
    except Exception as e:
        print(f"Ошибка при декодировании строки: {e}")
        return encoded_str

def analyze_moonsec_structure(content):
    """Анализирует структуру MoonSec обфускации"""
    print("Анализирую структуру MoonSec V3...")
    
    analysis = {
        'variables': [],
        'functions': [],
        'strings': [],
        'constants': [],
        'main_function': None
    }
    
    # Ищем основную функцию
    main_func_match = re.search(r'return\(function\(([^)]*)\)(.*?)end\)', content, re.DOTALL)
    if main_func_match:
        analysis['main_function'] = main_func_match.group(2)
        print(f"Найдена основная функция с параметрами: {main_func_match.group(1)}")
        print(f"Длина тела функции: {len(analysis['main_function'])}")
    
    # Ищем локальные переменные
    var_matches = re.findall(r'local\s+(\w+)', content)
    analysis['variables'] = list(set(var_matches))  # Убираем дубликаты
    print(f"Найдено уникальных переменных: {len(analysis['variables'])}")
    
    # Ищем определения функций
    func_matches = re.findall(r'function\s*\(([^)]*)\)', content)
    analysis['functions'] = func_matches
    print(f"Найдено функций: {len(analysis['functions'])}")
    
    # Ищем строковые константы
    string_matches = extract_strings(content)
    analysis['strings'] = [s for s in string_matches if len(s) > 0]
    print(f"Найдено строк: {len(analysis['strings'])}")
    
    # Ищем большую закодированную строку (обычно содержит основной код)
    large_string_match = re.search(r't="([^"]{100,})"', content)
    if large_string_match:
        encoded_data = large_string_match.group(1)
        print(f"Найдена большая закодированная строка длиной: {len(encoded_data)}")
        analysis['encoded_data'] = encoded_data
    
    return analysis

def deobfuscate_moonsec(content):
    """Основная функция деобфускации MoonSec"""
    print("Начинаю деобфускацию MoonSec V3...")
    
    # Удаляем маркер защиты
    content = content.replace('[[This file was protected with MoonSec V3]]', '')
    
    # Анализируем структуру
    analysis = analyze_moonsec_structure(content)
    
    # Начинаем формировать результат
    result = "-- Деобфусцированный код из MoonSec V3\n"
    result += "-- ВНИМАНИЕ: Это частичная деобфускация, полное восстановление может потребовать выполнения кода\n\n"
    
    # Добавляем найденные переменные
    if analysis['variables']:
        result += "-- Найденные локальные переменные:\n"
        for var in analysis['variables'][:20]:  # Ограничиваем вывод
            result += f"-- {var}\n"
        if len(analysis['variables']) > 20:
            result += f"-- ... и еще {len(analysis['variables']) - 20} переменных\n"
        result += "\n"
    
    # Добавляем найденные строки
    if analysis['strings']:
        result += "-- Найденные строки:\n"
        for i, string in enumerate(analysis['strings'][:50]):  # Ограничиваем вывод
            if len(string) > 0 and len(string) < 100:  # Показываем только короткие читаемые строки
                decoded = decode_moonsec_string(string)
                result += f"-- {i+1}: \"{decoded}\"\n"
        result += "\n"
    
    # Пытаемся найти читаемые части кода
    readable_parts = []
    
    # Ищем простые присваивания
    assignments = re.findall(r'(\w+)\s*=\s*([^;,\n]{1,50})', content)
    for var, val in assignments[:20]:
        if not re.search(r'function|gsub|match', val) and len(val.strip()) > 0:
            readable_parts.append(f"{var} = {val.strip()}")
    
    if readable_parts:
        result += "-- Найденные присваивания:\n"
        for part in readable_parts:
            result += f"-- {part}\n"
        result += "\n"
    
    # Если найдена закодированная строка, пытаемся её проанализировать
    if 'encoded_data' in analysis:
        result += "-- Анализ закодированной строки:\n"
        encoded = analysis['encoded_data']
        result += f"-- Длина: {len(encoded)} символов\n"
        
        # Пытаемся найти паттерны
        if '\\' in encoded:
            escape_count = encoded.count('\\')
            result += f"-- Найдено escape-последовательностей: {escape_count}\n"
        
        # Показываем начало строки
        preview = encoded[:200] if len(encoded) > 200 else encoded
        result += f"-- Начало: {preview}...\n"
        result += "\n"
    
    # Добавляем предупреждение и исходный код
    result += "-- ИСХОДНЫЙ ОБФУСЦИРОВАННЫЙ КОД:\n"
    result += "-- Для полной деобфускации может потребоваться выполнение в Lua интерпретаторе\n\n"
    
    # Разбиваем длинный код на строки для лучшей читаемости
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if len(line) > 100:
            # Разбиваем очень длинные строки
            for j in range(0, len(line), 100):
                result += f"--[[ Строка {i+1}, часть {j//100 + 1}: {line[j:j+100]} ]]\n"
        else:
            result += f"--[[ {line} ]]\n"
    
    return result

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
    
    deobfuscated = deobfuscate_moonsec(content)
    
    if deobfuscated:
        output_file = f"{filename}_deobfuscated.lua"
        if write_file(output_file, deobfuscated):
            print(f"Результат сохранен в: {output_file}")
            
            # Также сохраняем краткую версию с основными находками
            summary_file = f"{filename}_summary.txt"
            summary = deobfuscated.split("-- ИСХОДНЫЙ ОБФУСЦИРОВАННЫЙ КОД:")[0]
            if write_file(summary_file, summary):
                print(f"Краткий анализ сохранен в: {summary_file}")
        else:
            print("Ошибка при сохранении файла")
            return 1
    else:
        print("Деобфускация не удалась")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())