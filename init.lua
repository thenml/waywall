-- ==== IMPORTS ====

local waywall = require("waywall")
local helpers = require("waywall.helpers")
local c = require("config")
local u = require("utils")


-- ==== HELPERS ====

local change_sens = c.sens ~= nil
local change_dpi = c.dpi ~= nil
local active_remap = "default"

local ensure_running = function()
    if not u.is_running("tmp-saves\\.sh") then
        waywall.exec("bash " .. c.path.tmp_saves .. " -w")
        return true
    end
    if not u.is_running("Ninjabrain.*\\.jar") then
        waywall.exec("java -Dawt.useSystemAAFontSettings=on -jar " .. c.path.nb)
        waywall.show_floating(true)
        return true
    end
    if change_dpi and not u.is_running("solaar-watch\\.py") then
        waywall.exec("python3 " .. c.path.solaar .. " " .. c.dpi.id .. " DPI")
        return true
    end
    if not u.is_running("NBTrackr.*\\.py") then
        -- hyprctl dispatch exec to fix x11 issue
        waywall.exec("hyprctl dispatch exec nbtrackr")
        waywall.sleep(6000)
        waywall.exec("hyprctl dispatch tagwindow +nboverlay class:Tk")
        return true
    end
end

-- paused keymap indicator
local chat_text = u.make_text("keymap paused", {
    x = 0, y = 1065,
    size = 1,
    color = "#ffffff33",
})
local chat_key = function(key)
    return function()
        if not u.has_state and active_remap == "chat" then
            waywall.press_key(key)
            waywall.sleep(100)
            waywall.set_remaps(c.remap.default)
            active_remap = "default"
            chat_text(false)
            return false
        end
        if active_remap ~= "chat" then
            waywall.press_key(key)
            waywall.sleep(100)
            waywall.set_remaps({})
            active_remap = "chat"
            chat_text(true)
            return false
        end
        return false
    end
end


-- ==== MIRRORS ====

local pie_border = true
local mirrors = {
    e = u.f3_mirror(1, 4, 0, 49, { x = 1225, y = 611, scale = 4 }),

    eye_measure = u.make_mirror({
        src = { x = 155, y = 7902, w = 30, h = 580 },
        dst = { x = 0, y = 370, w = 790, h = 340 },
    }),

    pie_percent = u.text_mirror({
        src = { x = 248, y = 859, w = 33, h = 36 },
        dst = { x = 1445, y = 709, scale = 4 }, -- x = pie_chart.x + pie_chart.w / 2 + padding.x, y = pie_chart.y + pie_chart.h / 2 - 3h
        sx = 4, sy = 4,
    }),

    pie_chart = u.make_mirror({
        src = { x = 0, y = 676, w = 340, h = 168},
        dst = { x = 1225, y = 654, w = 200, h = 200 },
        shader = pie_border and "pie_chart_thin" or "pie_chart",
        depth = 1
    }),

    tall_pie_percent = u.text_mirror({
        src = { x = 248, y = 16163, w = 33, h = 36 },
        dst = { x = 1445, y = 709, scale = 4 },
        sx = 4, sy = 4,
    }),

    tall_pie_chart = u.make_mirror({
        src = { x = 0, y = 15980, w = 340, h = 168 },
        dst = { x = 1225, y = 654, w = 200, h = 200 },
        shader = pie_border and "pie_chart_tall" or "pie_chart",
        depth = 1
    }),

    glowdar = u.text_mirror({
        src = { x = 1827, y = 859, w = 33, h = 24 }, -- x = 1920 - 210 + 247
        dst = { x = 1684, y = 709, scale = 4 }, -- x = 1920 - 340 / 2 - 33 * 2 y = 674 + 169 / 2 - 24 * 2
        sx = 4, sy = 4,
    }),

    f3block = u.f3_mirror(3, 11, 32, 88),
    -- f3c = u.f3_mirror(3, 3, 0, 31),
    -- f3e = u.f3_mirror(3, 4, 0, 49),
    -- f3chunk = u.f3_mirror(3, 12, 36, 37),
    -- f3o = u.f3_mirror(3, 17, 57, 11),
}


local images = {
    measuring_overlay = u.make_image(c.path.overlay, {
        dst = { x = 0, y = 365, w = 790, h = 350 },
    }),
    x_border = u.make_image(c.path.x_border, {
        dst = { x = 0, y = 1080/2 - 350/2, w = 1920, h = 350 },
    }),
    y_border = u.make_image(c.path.y_border, {
        dst = { x = 1920/2 - 350/2, y = 0, w = 350, h = 1080 },
    }),
}

local show_mirrors = function(thin, tall, wide)
    local normal = not (thin or tall or wide)

    mirrors.e(thin or tall)

    mirrors.eye_measure(tall)
    images.measuring_overlay(tall)

    mirrors.pie_percent(thin)
    mirrors.pie_chart(thin)
    
    mirrors.tall_pie_percent(tall)
    mirrors.tall_pie_chart(tall)

    mirrors.glowdar(normal)
    mirrors.f3block(normal)

    images.x_border(wide)
    images.y_border(thin or tall)
end

local thin_enable = function()
    show_mirrors(true, false, false)
    if change_dpi then u.set_dpi(c.dpi.normal) end
    if change_sens then waywall.set_sensitivity(c.sens.normal) end
end
local tall_enable = function()
    show_mirrors(false, true, false)
    if change_dpi then u.set_dpi(c.dpi.tall) end
    if change_sens then waywall.set_sensitivity(c.sens.tall) end
end
local wide_enable = function()
    show_mirrors(false, false, true)
    if change_dpi then u.set_dpi(c.dpi.normal) end
    if change_sens then waywall.set_sensitivity(c.sens.normal) end
end

local res_disable = function()
    show_mirrors(false, false, false)
    if change_dpi then u.set_dpi(c.dpi.normal) end
    if change_sens then waywall.set_sensitivity(c.sens.normal) end
end


-- ==== RESOLUTIONS ====

local resolutions = {
    thin = u.make_res(340, 1080, thin_enable, res_disable),
    tall = u.make_res(340, 16384, tall_enable, res_disable),
    wide = u.make_res(1920, 340, wide_enable, res_disable),
}


-- ==== CONFIG ====

local config = {
    input = c.input,
    theme = c.theme
}
config.input.remaps = c.remap.default
if change_sens then
    config.input.sensitivity = c.sens.normal
end

config.shaders = {
    ["pie_chart"] = {
        vertex = u.read_file("shaders/general.vert"),
        fragment = u.read_file("shaders/pie_chart.frag"),
    },
    ["pie_chart_thin"] = {
        vertex = u.read_file("shaders/general.vert"),
        fragment = u.read_file("shaders/pie_chart_thin.frag"),
    },
    ["pie_chart_tall"] = {
        vertex = u.read_file("shaders/general.vert"),
        fragment = u.read_file("shaders/pie_chart_tall.frag"),
    },
    ["text"] = {
        vertex = u.read_file("shaders/general.vert"),
        fragment = u.read_file("shaders/text.frag"),
    },
    ["shadow"] = {
        vertex = u.read_file("shaders/general.vert"),
        fragment = u.read_file("shaders/text_shadow.frag"),
    },
}

config.actions = {
    [c.key.thin] = u.ingame_only(resolutions.thin),
    [c.key.tall] = resolutions.tall,
    [c.key.wide] = u.ingame_only(resolutions.wide),

    [c.key.toggle_ninbot] = function()
        -- ensure_running()
        helpers.toggle_floating()
        return false
    end,

    [c.key.launch_paceman] = function()
        if not u.is_running("paceman..*") then
            waywall.exec("java -jar " .. c.path.pacem .. " --nogui")
        end
    end,

    [c.key.toggle_nbtracker] = function()
        waywall.exec("pkill -f NBTrackr.*\\.py")
    end,

    [c.key.fullscreen] = waywall.toggle_fullscreen,

    [c.key.ensure_running] = ensure_running,

    -- disable remap when typing
    ["Return"] = chat_key("Enter"),
    ["Slash"] = chat_key("Slash"),
}

u.mpk(c.key.mpk, config)

waywall.listen("load", function()
    res_disable()
    waywall.sleep(5000)
    while ensure_running do
        waywall.sleep(1000)
    end
    if u.has_state == nil then
        u.has_state = false
        waywall.state() -- errors if no state present
        u.has_state = true
    end
end)

waywall.listen("state", function()
    u.has_state = true
    local state = waywall.state()
    if state.screen == "inworld" and state.inworld == "unpaused" then
        waywall.set_remaps(c.remap.default)
        chat_text(false)
        active_remap = "default"
        if u.starting_mpk then
            u.starting_mpk = false
            waywall.press_key(c.key.mpk.load)
        end
    end
    if state.screen ~= "inworld" then
        waywall.set_remaps({})
        chat_text(true)
        active_remap = "chat"
    end
end)

require("takeabreak/init")(config, c.key.takeabreak)

return config