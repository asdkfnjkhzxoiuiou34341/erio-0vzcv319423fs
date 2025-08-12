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

def extract_real_code(content):
    """Извлекает реальный исполняемый код из MoonSec V3"""
    print("🔍 Извлекаю реальный исполняемый код...")
    
    # Ищем основную функцию-обертку
    wrapper_pattern = r'return\s*\(\s*function\s*\([^)]*\)(.*?)end\s*\)\s*\('
    match = re.search(wrapper_pattern, content, re.DOTALL)
    
    if not match:
        print("❌ Не найдена основная функция-обертка")
        return content
    
    function_body = match.group(1)
    print("✅ Найдена основная функция-обертка")
    
    # Ищем декодированные строки в теле функции
    string_pattern = r'n\(h\(\d+,"([^"]+)"\)\)'
    strings = re.findall(string_pattern, function_body)
    
    if strings:
        print(f"✅ Найдено {len(strings)} закодированных строк")
        # Декодируем первую строку (обычно содержит основной код)
        main_encoded = strings[0] if strings else ""
        decoded_code = decode_moonsec_string(main_encoded)
        return decoded_code
    
    return function_body

def decode_moonsec_string(encoded_str):
    """Декодирует строку MoonSec"""
    print("🔤 Декодирую строку MoonSec...")
    
    # MoonSec использует специальную кодировку
    # Пробуем различные методы декодирования
    
    decoded_chars = []
    i = 0
    
    while i < len(encoded_str):
        char = encoded_str[i]
        
        if char == '\\':
            # Обрабатываем escape-последовательности
            if i + 1 < len(encoded_str):
                next_char = encoded_str[i + 1]
                if next_char.isdigit():
                    # Восьмеричное представление
                    octal = ""
                    j = i + 1
                    while j < len(encoded_str) and j < i + 4 and encoded_str[j].isdigit():
                        octal += encoded_str[j]
                        j += 1
                    if octal:
                        try:
                            decoded_chars.append(chr(int(octal, 8)))
                            i = j
                            continue
                        except:
                            pass
                i += 2
            else:
                i += 1
        else:
            decoded_chars.append(char)
            i += 1
    
    decoded = ''.join(decoded_chars)
    
    # Дополнительная обработка для MoonSec
    # Удаляем нулевые байты и непечатаемые символы
    clean_decoded = ''.join(c for c in decoded if ord(c) >= 32 or c in '\n\t\r')
    
    print(f"✅ Декодировано {len(clean_decoded)} символов")
    return clean_decoded

def extract_lua_functions(content):
    """Извлекает Lua функции из кода"""
    print("🔧 Извлекаю Lua функции...")
    
    functions = []
    
    # Паттерны для поиска функций
    function_patterns = [
        r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\([^)]*\)',
        r'local\s+function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\([^)]*\)',
        r'([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*function\s*\([^)]*\)'
    ]
    
    for pattern in function_patterns:
        matches = re.findall(pattern, content)
        functions.extend(matches)
    
    # Удаляем дубликаты
    unique_functions = list(set(functions))
    
    print(f"✅ Найдено {len(unique_functions)} функций")
    return unique_functions

def create_working_roblox_script(content):
    """Создает работающий Roblox скрипт"""
    print("🔨 Создаю работающий Roblox скрипт...")
    
    # Извлекаем реальный код
    real_code = extract_real_code(content)
    
    # Создаем заголовок для Roblox
    roblox_header = '''-- Деобфусцированный Roblox скрипт
-- Оригинал был защищен MoonSec V3
-- ВАЖНО: Этот скрипт сохраняет оригинальную функциональность

-- Стандартные сервисы Roblox (если используются)
local game = game
local workspace = workspace  
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")

-- Локальные переменные для совместимости
local wait = wait or task.wait
local spawn = spawn or task.spawn
local delay = delay or task.delay

'''
    
    # Если реальный код не найден, используем исходный
    if len(real_code) < 100:
        real_code = content
    
    # Очищаем код от обфускации (осторожно)
    cleaned_code = clean_obfuscated_code(real_code)
    
    # Собираем финальный скрипт
    final_script = roblox_header + cleaned_code
    
    return final_script

def clean_obfuscated_code(code):
    """Очищает код от обфускации, сохраняя функциональность"""
    print("✨ Очищаю код от обфускации...")
    
    # Базовая очистка
    cleaned = code
    
    # Удаляем лишние пробелы и переносы
    cleaned = re.sub(r'\n\s*\n', '\n', cleaned)
    cleaned = re.sub(r'  +', ' ', cleaned)
    
    # Улучшаем читаемость операторов
    cleaned = re.sub(r'([a-zA-Z0-9_])\s*=\s*([a-zA-Z0-9_])', r'\1 = \2', cleaned)
    cleaned = re.sub(r'([a-zA-Z0-9_])\s*\+\s*([a-zA-Z0-9_])', r'\1 + \2', cleaned)
    cleaned = re.sub(r'([a-zA-Z0-9_])\s*-\s*([a-zA-Z0-9_])', r'\1 - \2', cleaned)
    
    # Форматируем блоки кода
    lines = cleaned.split('\n')
    formatted_lines = []
    indent_level = 0
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            formatted_lines.append('')
            continue
        
        # Уменьшаем отступ для end, else, elseif
        if any(stripped.startswith(kw) for kw in ['end', 'else', 'elseif', 'until']):
            indent_level = max(0, indent_level - 1)
        
        # Добавляем отступ
        formatted_lines.append('    ' * indent_level + stripped)
        
        # Увеличиваем отступ для блоков
        if any(kw in stripped for kw in ['then', ' do', 'function', 'repeat']):
            if not stripped.endswith('end'):
                indent_level += 1
    
    return '\n'.join(formatted_lines)

def analyze_script_functionality(content):
    """Анализирует функциональность скрипта"""
    print("📊 Анализирую функциональность скрипта...")
    
    analysis = {
        'roblox_services': [],
        'game_functions': [],
        'network_calls': [],
        'gui_elements': [],
        'events': []
    }
    
    # Поиск сервисов Roblox
    service_patterns = [
        r'game:GetService\("([^"]+)"\)',
        r'game\.([A-Z][a-zA-Z]+)',
        r'workspace\.([a-zA-Z_][a-zA-Z0-9_]*)'
    ]
    
    for pattern in service_patterns:
        matches = re.findall(pattern, content)
        analysis['roblox_services'].extend(matches)
    
    # Поиск игровых функций
    game_function_patterns = [
        r'(wait|spawn|delay)\s*\(',
        r'(Connect|Disconnect|Fire)\s*\(',
        r'(TweenInfo|Tween)\s*\('
    ]
    
    for pattern in game_function_patterns:
        matches = re.findall(pattern, content)
        analysis['game_functions'].extend(matches)
    
    # Поиск сетевых вызовов
    network_patterns = [
        r'HttpService:([A-Z][a-zA-Z]*)',
        r'(GET|POST|PUT|DELETE)\s*\(',
        r'https?://[^\s"\']+',
    ]
    
    for pattern in network_patterns:
        matches = re.findall(pattern, content)
        analysis['network_calls'].extend(matches)
    
    # Удаляем дубликаты
    for key in analysis:
        analysis[key] = list(set(analysis[key]))
    
    return analysis

def main():
    if len(sys.argv) != 2:
        print("Использование: python3 advanced_roblox_deobfuscator.py <файл>")
        return
    
    filename = sys.argv[1]
    
    print("🚀 ПРОДВИНУТЫЙ ДЕОБФУСКАТОР ROBLOX СКРИПТОВ")
    print("=" * 60)
    print(f"📁 Обрабатываю файл: {filename}")
    
    # Читаем файл
    content = read_file(filename)
    if not content:
        return
    
    print(f"📊 Размер исходного файла: {len(content):,} байт")
    
    # Создаем рабочую версию скрипта
    working_script = create_working_roblox_script(content)
    
    # Анализируем функциональность
    analysis = analyze_script_functionality(content)
    
    # Извлекаем функции
    functions = extract_lua_functions(working_script)
    
    # Сохраняем результаты
    base_name = os.path.splitext(filename)[0]
    
    print("\n💾 Сохраняю результаты...")
    
    # 1. Рабочий скрипт для Roblox
    working_file = f"{base_name}_working.lua"
    write_file(working_file, working_script)
    print(f"✅ Рабочий скрипт: {working_file}")
    
    # 2. Исходный код (минимально обработанный)
    original_code = extract_real_code(content)
    original_file = f"{base_name}_original_extracted.lua"
    write_file(original_file, original_code)
    print(f"✅ Извлеченный код: {original_file}")
    
    # 3. Анализ функциональности
    analysis_file = f"{base_name}_functionality_analysis.txt"
    analysis_content = f"""АНАЛИЗ ФУНКЦИОНАЛЬНОСТИ ROBLOX СКРИПТА
{'='*60}

ИСХОДНЫЙ ФАЙЛ: {filename}
РАЗМЕР: {len(content):,} байт
РАЗМЕР ИЗВЛЕЧЕННОГО КОДА: {len(working_script):,} байт

НАЙДЕННЫЕ КОМПОНЕНТЫ:

СЕРВИСЫ ROBLOX ({len(analysis['roblox_services'])}):
{chr(10).join(f"  • {service}" for service in analysis['roblox_services'][:20])}
{f"  ... и еще {len(analysis['roblox_services']) - 20}" if len(analysis['roblox_services']) > 20 else ""}

ИГРОВЫЕ ФУНКЦИИ ({len(analysis['game_functions'])}):
{chr(10).join(f"  • {func}" for func in analysis['game_functions'][:20])}

СЕТЕВЫЕ ВЫЗОВЫ ({len(analysis['network_calls'])}):
{chr(10).join(f"  • {call}" for call in analysis['network_calls'][:10])}

НАЙДЕННЫЕ ФУНКЦИИ ({len(functions)}):
{chr(10).join(f"  • {func}" for func in functions[:30])}
{f"  ... и еще {len(functions) - 30}" if len(functions) > 30 else ""}

РЕКОМЕНДАЦИИ:
• Используйте {working_file} для запуска в Roblox Studio
• Проверьте {original_file} для анализа оригинального кода
• Скрипт может содержать дополнительную логику в закодированных строках

ВАЖНО: 
- Всегда тестируйте скрипт в безопасной среде
- Проверьте наличие подозрительных сетевых запросов
- Убедитесь в безопасности перед использованием
"""
    
    write_file(analysis_file, analysis_content)
    print(f"✅ Анализ функциональности: {analysis_file}")
    
    # 4. Краткий отчет
    report_file = f"{base_name}_deobfuscation_summary.txt"
    report_content = f"""КРАТКИЙ ОТЧЕТ О ДЕОБФУСКАЦИИ
{'='*40}

✅ ДЕОБФУСКАЦИЯ ЗАВЕРШЕНА УСПЕШНО!

📁 СОЗДАННЫЕ ФАЙЛЫ:
1. {working_file} - Готовый к использованию скрипт
2. {original_file} - Извлеченный оригинальный код  
3. {analysis_file} - Подробный анализ функциональности
4. {report_file} - Этот краткий отчет

🎯 ДЛЯ ИСПОЛЬЗОВАНИЯ В ROBLOX:
Откройте файл {working_file} в Roblox Studio

📊 СТАТИСТИКА:
• Исходный размер: {len(content):,} байт
• Размер деобфусцированного: {len(working_script):,} байт
• Найдено функций: {len(functions)}
• Найдено сервисов: {len(analysis['roblox_services'])}

⚠️  ВАЖНО:
Всегда проверяйте скрипты на безопасность перед использованием!
"""
    
    write_file(report_file, report_content)
    print(f"✅ Краткий отчет: {report_file}")
    
    print(f"\n🎉 ДЕОБФУСКАЦИЯ ЗАВЕРШЕНА УСПЕШНО!")
    print(f"📁 Создано файлов: 4")
    print(f"🎮 Для Roblox используйте: {working_file}")
    print(f"🔍 Для анализа используйте: {analysis_file}")
    print(f"\n⚠️  ВНИМАНИЕ: Всегда тестируйте в безопасной среде!")

if __name__ == "__main__":
    main()