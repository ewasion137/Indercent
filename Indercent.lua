-- [[ Indercent.lua | Nixware CS2 | Hard & Compact ]] --

-- 1. Кэшируем функции и смещения для скорости
local font = render.setup_font("C:/Windows/Fonts/verdanab.ttf", 12)
local get_offset = engine.get_netvar_offset

-- Смещения (делаем один раз при загрузке)
local off = {
    hp = get_offset("client.dll", "C_BaseEntity", "m_iHealth"),
    team = get_offset("client.dll", "C_BaseEntity", "m_iTeamNum"),
    origin = get_offset("client.dll", "C_BaseEntity", "m_vOldOrigin")
}

-- 2. Утилиты рендера
local function rect_f(x, y, w, h, c) render.rect_filled(vec2_t(x, y), vec2_t(x+w, y+h), c, 2) end
local function line(x1, y1, x2, y2, c) render.line(vec2_t(x1, y1), vec2_t(x2, y2), c) end

-- 3. Отрисовка
register_callback("paint", function()
    local lp = entitylist.get_local_player_pawn()
    if not lp then return end
    
    local screen = render.screen_size()
    local lp_team = lp:get_i32(off.team)
    local accent = color_t(180, 140, 255, 255)

    -- [ WATERMARK ]
    local wm = string.format("nixware | %s | fps: %d", get_user_name(), math.floor(1/render.frame_time()))
    render.text(wm, font, vec2_t(screen.x - 180, 20), accent)

    -- [ ESP ]
    local players = entitylist.get_entities("C_CSPlayerPawn")
    for _, ent in pairs(players) do
        local hp = ent:get_i32(off.hp)
        local team = ent:get_i32(off.team)
        
        if ent:get_address() ~= lp:get_address() and hp > 0 and team ~= lp_team then
            local origin = ent:get_vec(off.origin)
            local b_pos = render.world_to_screen(origin)
            local t_pos = render.world_to_screen(vec3_t(origin.x, origin.y, origin.z + 75))

            if b_pos and t_pos then
                local h = b_pos.y - t_pos.y
                local w = h / 2
                local x, y = t_pos.x - w / 2, t_pos.y

                -- Corner Box
                local l = w / 4
                line(x, y, x + l, y, accent) line(x, y, x, y + l, accent) -- top-left
                line(x + w, y, x + w - l, y, accent) line(x + w, y, x + w, y + l, accent) -- top-right
                line(x, y + h, x + l, y + h, accent) line(x, y + h, x, y + h - l, accent) -- bot-left
                line(x + w, y + h, x + w - l, y + h, accent) line(x + w, y + h, x + w, y + h - l, accent) -- bot-right

                -- Health Bar
                local bar_h = (h * hp) / 100
                rect_f(x - 5, y, 2, h, color_t(10, 10, 10, 150))
                rect_f(x - 5, y + (h - bar_h), 2, bar_h, color_t(100, 255, 100, 255))
            end
        end
    end
end)

color_print("Indercent.lua successfully initialized.\0", color_t(180, 140, 255, 255))