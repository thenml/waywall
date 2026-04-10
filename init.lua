-- ==== IMPORTS ====
local waywall = require("waywall")
local helpers = require("waywall.helpers")
local c = require("config")

-- ==== HELPERS ====
local change_sens = c.sens ~= nil
local change_dpi = c.dpi ~= nil
local active_remap = "default"

local is_running = function(regex)
    local handle = io.popen("pgrep -f '" .. regex .. "'")
    local result = handle:read("*l")
    handle:close()
    return result ~= nil
end

local set_dpi = function(dpi)
    local handle = io.popen("echo " .. dpi .. " > /tmp/solaar-watch-set")
    local result = handle:read("*l")
    handle:close()
    return result ~= nil
end

local set_sens = function(sens)
    waywall.set_sensitivity(sens)
end

local read_file = function(name)
    local home = os.getenv("HOME")

    local file = io.open(home .. "/.config/waywall/" .. name, "r")
    local data = file:read("*a")
    file:close()

    return data
end

local ensure_running = function()
    if not is_running("tmp-saves\\.sh") then
        waywall.exec("bash " .. c.path.tmp_saves .. " -w")
    end
    if not is_running("Ninjabrain.*\\.jar") then
        waywall.exec("java -Dawt.useSystemAAFontSettings=on -jar " .. c.path.nb)
        waywall.show_floating(true)
    end
    if change_dpi and not is_running("solaar-watch\\.py") then
        waywall.exec("python3 " .. c.path.solaar .. " " .. c.dpi.id .. " DPI")
    end
    if not is_running("NBTrackr.*\\.py") then
        waywall.exec("nbtrackr")
        waywall.sleep(6000)
        waywall.exec("hyprctl dispatch tagwindow +nboverlay class:Tk")
    end
end

local has_state = false
local ingame_only = function(func)
    return function()
        if has_state then
            return helpers.ingame_only(func)()
        end
        return func()
    end
end

-- https://discord.com/channels/1095808506239651942/1374968058506117130/1451035479288840304
local starting_mpk = false
local mpk = function(cfg, config)
    config.actions[cfg.launch] = function()
        for _, key in ipairs({ "Tab", "Space", "Tab", "Tab", "Tab", "Space", "Tab", "Space", "Space", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Space" }) do
            waywall.press_key(key)
        end
        starting_mpk = true
    end

    config.actions[cfg.quit] = function()
        for _, key in ipairs({ "Esc", "Esc", "Tab", "Space", "Esc", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Space" }) do
            waywall.press_key(key)
        end
    end
end


-- ==== MIRRORS ====
local make_mirror = function(options)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.mirror(options)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local mirrors = {
    e = make_mirror({
        src = { x = 1, y = 37, w = 64, h = 9 },
        dst = { x = 1225, y = 618, w = 4 * 64, h = 4 * 9 },
        shader = "text"
    }),

    eye_measure = make_mirror({
        src = { x = 155, y = 7902, w = 30, h = 580 },
        dst = { x = 0, y = 370, w = 790, h = 340 },
    }),

    pie_percent = make_mirror({
        src = { x = 247, y = 859, w = 33, h = 25 },
        dst = { x = 1550, y = 750, w = 132, h = 100 },
        shader = "text"
    }),

    pie_chart = make_mirror({
        src = { x = 0, y = 674, w = 340, h = 178},
        dst = { x = 1225, y = 650, w = 315, h = 317.25 },
        shader = "pie_chart",
    }),

    tall_pie_percent = make_mirror({
        src = { x = 247, y = 16163, w = 33, h = 25 },
        dst = { x = 1550, y = 750, w = 132, h = 100 },
        shader = "text"
    }),

    tall_pie_chart = make_mirror({
        src = { x = 0, y = 15978, w = 340, h = 178 },
        dst = { x = 1225, y = 650, w = 315, h = 317.25 },
        shader = "pie_chart",
    }),
}


local make_image = function(path, dst)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.image(path, dst)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local make_text = function(text, dst)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.text(text, dst)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local images = {
    measuring_overlay = make_image(c.path.overlay, {
        dst = { x = 0, y = 370, w = 790, h = 340 },
    }),
    pie_cheatsheet = make_image(c.path.pie_cheatsheet, {
        dst = { x = 1131, y = 0, w = 1598/2, h = 780/2 },
    }),
}

local show_mirrors = function(thin, tall, wide)
    mirrors.e(thin or tall)

    mirrors.eye_measure(tall)
    images.measuring_overlay(tall)

    mirrors.pie_percent(thin)
    mirrors.pie_chart(thin)

    mirrors.tall_pie_percent(tall)
    mirrors.tall_pie_chart(tall)
    images.pie_cheatsheet(thin)
end

local thin_enable = function()
    show_mirrors(true, false, false)
    if change_dpi then set_dpi(c.dpi.normal) end
    if change_sens then set_sens(c.sens.normal) end
end
local tall_enable = function()
    show_mirrors(false, true, false)
    if change_dpi then set_dpi(c.dpi.tall) end
    if change_sens then set_sens(c.sens.tall) end
end
local wide_enable = function()
    show_mirrors(false, false, true)
    if change_dpi then set_dpi(c.dpi.normal) end
    if change_sens then set_sens(c.sens.normal) end
end

local res_disable = function()
    show_mirrors(false, false, false)
    if change_dpi then set_dpi(c.dpi.normal) end
    if change_sens then set_sens(c.sens.normal) end
    waywall.set_remaps(c.remap.default)
end

local chat_text = make_text("keymap paused", {
    x = 0, y = 1065,
    size = 1,
    color = "#ffffff88",
})
local chat_key = function(key)
    return function()
        if not has_state and active_remap == "chat" then
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


-- ==== RESOLUTIONS ====
local make_res = function(width, height, enable, disable)
    return function()
        local active_width, active_height = waywall.active_res()

        if active_width == width and active_height == height then
            waywall.set_resolution(0, 0)
            disable()
        else
            waywall.set_resolution(width, height)
            enable()
        end
        return false
    end
end

local resolutions = {
    thin = make_res(340, 1080, thin_enable, res_disable),
    tall = make_res(340, 16384, tall_enable, res_disable),
    wide = make_res(1920, 340, wide_enable, res_disable),
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
        vertex = read_file("general.vert"),
        fragment = read_file("pie_chart.frag"),
    },
    ["text"] = {
        vertex = read_file("general.vert"),
        fragment = read_file("text.frag"),
    },
}

config.actions = {
    [c.key.thin] = ingame_only(resolutions.thin),
    [c.key.tall] = resolutions.tall,
    [c.key.wide] = ingame_only(resolutions.wide),

    [c.key.toggle_ninbot] = function()
        -- ensure_running()
        helpers.toggle_floating()
        return false
    end,

    [c.key.launch_paceman] = function()
        if not is_running("paceman..*") then
            waywall.exec("java -jar " .. c.path.pacem .. " --nogui")
        end
    end,

    [c.key.toggle_nbtracker] = function()
        waywall.exec("pkill -f NBTrackr.*\\.py")
    end,

    [c.key.fullscreen] = waywall.toggle_fullscreen,

    [c.key.ensure_running] = ensure_running,

    -- no remap when typing
    ["Return"] = chat_key("Enter"),
    ["Slash"] = chat_key("Slash"),
}

mpk(c.key.mpk, config)

waywall.listen("load", function()
    waywall.sleep(10)
    ensure_running()
end)

waywall.listen("state", function()
    has_state = true
    local state = waywall.state()
    if state.screen == "inworld" and state.inworld == "unpaused" then
        waywall.set_remaps(c.remap.default)
        chat_text(false)
        active_remap = "default"
        if starting_mpk then
            starting_mpk = false
            waywall.press_key(c.key.mpk.load)
        end
    end
    if state.screen ~= "inworld" then
        waywall.set_remaps({})
        chat_text(true)
        active_remap = "chat"
    end
    -- if state.inworld == "paused" then
    --     waywall.set_resolution(0, 0)
    --     res_disable()
    -- end
end)

require("takeabreak/init")(config, c.key.takeabreak)

return config