# YBA Hacks Integration

## Описание
Этот проект разделяет YBA (Your Bizarre Adventure) функциональность в отдельный модуль, который загружается только при игре в YBA.

## Файлы

### `huyna2` - Основной скрипт
- Содержит основные функции (ESP, Movement, Teleport и т.д.)
- Работает во всех играх
- Автоматически определяет ID игры и загружает YBA модуль при необходимости

### `yba_hacks.lua` - YBA Модуль
- Содержит все YBA-специфичные функции:
  - Stand Range Hack
  - Underground Flight
  - Anti Time Stop
  - Item ESP (для YBA предметов)
  - User Stand/Style ESP
  - Autofarm
- Загружается только для игры YBA (ID: 2809202155)

## Как это работает

1. **При запуске основного скрипта:**
   - Загружаются основные функции (ESP, Movement, Teleport)
   - Создается интерфейс с вкладками Main, YBA Hacks, Settings

2. **При переходе на вкладку "YBA Hacks":**
   - Проверяется ID текущей игры (`game.PlaceId`)
   - **Если ID = 2809202155 (YBA):**
     - Загружается модуль `yba_hacks.lua` (локально или с GitHub)
     - Создается полный интерфейс YBA функций
   - **Если ID другой:**
     - Показывается сообщение "This is not YBA"

## Преимущества

✅ **Условная загрузка** - YBA код загружается только в YBA  
✅ **Модульность** - YBA функции изолированы в отдельном файле  
✅ **Совместимость** - основные функции работают во всех играх  
✅ **Безопасность** - YBA-специфичный код не выполняется в других играх  
✅ **Обновления** - YBA модуль можно обновлять независимо  

## Установка

1. Поместите `huyna2` в основную папку
2. Поместите `yba_hacks.lua` в ту же папку ИЛИ загрузите на GitHub
3. Запустите `huyna2`

## GitHub Integration

Модуль может загружаться с GitHub по URL:
```
https://raw.githubusercontent.com/your-username/your-repo/main/yba_hacks.lua
```

Для этого обновите URL в основном скрипте на строке с `game:HttpGet()`.

## Структура YBA модуля

```lua
return {
    -- Конфигурации
    YBAConfig = {...},
    AntiTimeStopConfig = {...},
    AutofarmConfig = {...},
    
    -- Основные функции
    startYBA = function() ... end,
    stopYBA = function() ... end,
    startAntiTimeStop = function() ... end,
    -- ... другие функции
    
    -- Создание интерфейса
    createYBAInterface = function() ... end,
}
```

## Поддерживаемые функции YBA

- 🎯 **Stand Range** - управление стендом на расстоянии
- 🚁 **Underground Flight** - полет под землей
- ⏰ **Anti Time Stop** - защита от остановки времени  
- 👥 **User Stand/Style ESP** - ESP стендов и стилей игроков
- 📦 **Item ESP** - ESP предметов YBA
- 🤖 **Autofarm** - автоматический сбор предметов

## Отладка

При возникновении проблем проверьте консоль на наличие сообщений:
- `YBA HACKS: Загружаем модуль для YBA...`
- `YBA HACKS: Модуль загружен успешно!`
- `YBA HACKS: Создаем интерфейс...`

## ID игр

- **YBA (Your Bizarre Adventure)**: 2809202155
- Другие игры показывают предупреждение "This is not YBA"