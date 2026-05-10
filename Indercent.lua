-- ==========================================================
-- [ Nixware CS2 ] Base + Skybox Changer (One File)
-- ==========================================================

-- [[ 1. БАЗА И ХЕЛПЕРЫ ]] --
-- Загружаем шрифт (размер 16, флаг 1 - обычно это обводка или тень)
local my_font = render.setup_font("Verdana", 16, 1) 

-- Простая функция плавного перехода (Lerp) на будущее
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- [[ 2. ДАННЫЕ ДЛЯ СКАЙБОКСА ]] --
-- Рабочие текстуры скайбоксов для CS2 / CS:GO
local skyboxes = {
    "sky_dust",
    "sky_csgo_night02",
    "sky_csgo_night02b",
    "sky_csgo_cloudy01",
    "sky_venice",
    "sky_day02_05",
    "nukeblank",
    "office",
    "italy",
    "vertigo",
    "vertigoblue_hdr",
    "cs_tibet",
    "vietnam"
}
local current_sky_index = 1

local ffi = require("ffi")

-- [[ 1. ПОДГОТОВКА FFI ]] --
ffi.cdef[[
    typedef struct {
        void* vtable;
        void* next;
        const char* name;
        const char* help_string;
        uint32_t flags; // Оффсет 0x18
    } convar_ptr_t;

    typedef void* (__stdcall* tCreateInterface)(const char* name, int* return_code);
    typedef convar_ptr_t* (__thiscall* tFindVar)(void* thisptr, const char* name);
]]

-- Получаем доступ к интерфейсу конваров напрямую из tier0.dll
local create_interface_ptr = find_export("tier0.dll", "CreateInterface")
local create_interface = ffi.cast("tCreateInterface", create_interface_ptr)
local icvar_ptr = create_interface("VEngineCvar007", nil)

-- Ищем функцию FindVar в VTable (в CS2 это обычно 16-й индекс)
local icvar_vtable = ffi.cast("void***", icvar_ptr)[0]
local find_var = ffi.cast("tFindVar", icvar_vtable[16])

-- [[ 2. ФУНКЦИЯ РАЗБЛОКИРОВКИ И ЗАПИСИ ]] --
local function apply_skybox(index)
    local sky_name = skyboxes[index]
    
    -- Ищем указатель на конвар в памяти игры
    local raw_cvar = find_var(icvar_ptr, "sv_skyname")
    
    if raw_cvar ~= nil then
        -- 0x2000 - это флаг FCVAR_REPLICATED (защита сервера)
        -- 0x4000 - это флаг FCVAR_CHEAT (требует sv_cheats 1)
        -- Мы просто обнуляем флаги защиты, чтобы игра разрешила нам запись
        raw_cvar.flags = 0 

        -- Теперь, когда защита снята, используем стандартный метод Никсвара 
        -- или просто вызываем команду через консоль - теперь она СРАБОТАЕТ
        engine.execute_client_cmd('sv_skyname "' .. sky_name .. '"')
        
        color_print("[Nixware Skybox] Защита снята! Небо изменено на: " .. sky_name .. "\n", color_t(100, 255, 100, 255))
    else
        color_print("[Nixware Skybox] Ошибка: Не удалось найти указатель на sv_skyname!\n", color_t(255, 100, 100, 255))
    end
end

-- [[ 3. ОБРАБОТКА СОБЫТИЙ (ИВЕНТЫ) ]] --

-- Перехватываем ввод в консоль
register_callback("console_input", function(cmd)
    -- Если написали "sky next"
    if cmd == "sky next" then
        current_sky_index = current_sky_index + 1
        if current_sky_index > #skyboxes then current_sky_index = 1 end
        apply_skybox(current_sky_index)
        
        return false -- Блокируем команду, чтобы в игре не писало "Unknown command"
    
    -- Если написали "sky prev"
    elseif cmd == "sky prev" then
        current_sky_index = current_sky_index - 1
        if current_sky_index < 1 then current_sky_index = #skyboxes end
        apply_skybox(current_sky_index)
        
        return false
    end
end)

-- Отрисовка визуала (HUD)
register_callback("paint", function()
    -- Показываем нашу мини-панель ТОЛЬКО когда открыто меню чита
    if not ui.is_menu_opened() then return end

    local screen = render.screen_size()
    if not screen or not my_font then return end

    -- Считаем координаты, чтобы панель была по центру сверху
    local panel_w = 320
    local panel_h = 70
    local x = (screen.x / 2) - (panel_w / 2)
    local y = 40

    -- Рисуем фон панели (x, y, color, rounding)
    render.rect_filled(vec2_t(x, y), vec2_t(x + panel_w, y + panel_h), color_t(20, 20, 20, 220), 8)
    
    -- Рисуем красивую обводку (x, y, color, rounding, thickness)
    render.rect(vec2_t(x, y), vec2_t(x + panel_w, y + panel_h), color_t(100, 150, 255, 255), 8, 2)

    -- Рисуем текст
    render.text("☁ SKYBOX CHANGER", my_font, vec2_t(x + 10, y + 10), color_t(255, 255, 255, 255))
    render.text("Текущее небо: " .. skyboxes[current_sky_index], my_font, vec2_t(x + 10, y + 30), color_t(100, 255, 100, 255))
    render.text("Введи 'sky next' или 'sky prev' в консоль", my_font, vec2_t(x + 10, y + 50), color_t(150, 150, 150, 255))
end)