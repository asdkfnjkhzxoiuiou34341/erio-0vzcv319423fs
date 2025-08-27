## Era-like Roblox Loader and UI

This project provides a Roblox Lua script that mimics Era Hub-style behavior:

- Animated splash/loader
- Async code fetching (remote or embedded)
- Modern sidebar UI with tabs and smooth tweens
- Simple config persistence (supports popular executors with filesystem APIs)

### Files

- `loader.lua`: Entry-point loader. Shows splash, fetches/loads modules, mounts UI.
- `ui/init.lua`: Builds the sidebar UI and exposes an API to add tabs/sections/toggles.
- `ui/theme.lua`: Centralized theme (colors, sizes, fonts).
- `ui/components/Sidebar.lua`: Sidebar and topbar composition.
- `ui/components/Tabs.lua`: Tab controller with content pages.
- `utils/http.lua`: Safe HTTP wrapper supporting `game:HttpGet` and executor functions.
- `utils/executor.lua`: Detects executor capabilities and provides FS helpers.
- `examples/aimbot.lua`, `examples/esp.lua`: Example feature modules.
- `config.lua`: Simple config loader/saver.

### Usage (Executor)

Copy the contents of `loader.lua` into your executor, or host these files and 
use a one-line bootstrap:

```lua
loadstring(game:HttpGet("https://your.cdn/loader.lua"))()
```

### Customization

- Edit `ui/theme.lua` to tweak colors, roundness, and animation speeds.
- Add new feature modules under `examples/` and register them inside `loader.lua`.

### Notes

- Remote fetching depends on `HttpGet` being enabled in your environment.
- Config saving uses executor file APIs (e.g., `isfile`, `writefile`). If unavailable, it gracefully no-ops.

