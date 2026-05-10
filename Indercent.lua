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

-- Функция применения неба
local function apply_skybox(index)
    local sky = skyboxes[index]
    
    -- Выполняем консольную команду изменения неба 
    -- (Никсвар должен байпасить sv_cheats для таких команд)
    engine.execute_client_cmd("sv_skyname " .. sky)
    
    -- Выводим сообщение в консоль красивым цветом
    color_print("[Nixware Skybox] Установлено небо: " .. sky .. "\n", color_t(100, 200, 255, 255))
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