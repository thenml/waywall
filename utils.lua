local waywall = require("waywall")
local helpers = require("waywall.helpers")

local utils = {}

-- ==== gore's generic config ====

-- read a file from the config directory
-- - gore's generic config
utils.read_file = function(name)
    local home = os.getenv("HOME")

    local file = io.open(home .. "/.config/waywall/" .. name, "r")
    local data = file:read("*a")
    file:close()

    return data
end

-- wrapper for waywall.set_resolution to create a toggleable resolution
-- - gore's generic config
utils.make_res = function(width, height, enable, disable)
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

-- wrapper for waywall.mirror to create a toggleable mirror
-- - options = mirror options & { dst.scale } for auto scale
-- - gore's generic config
utils.make_mirror = function(options)
    local this = nil

	if options.dst.scale then
		options.dst.w = options.src.w * options.dst.scale
		options.dst.h = options.src.h * options.dst.scale
	end

    return function(enable)
        if enable and not this then
            this = waywall.mirror(options)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

-- wrapper for waywall.image to create a toggleable image
-- - gore's generic config
utils.make_image = function(path, dst)
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

-- wrapper for waywall.text to create toggleable text
-- - gore's generic config
utils.make_text = function(text, dst)
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

-- true if mpk is starting
utils.starting_mpk = false
-- configure mpk keybinds
-- - https://discord.com/channels/1095808506239651942/1374968058506117130/1451035479288840304
utils.mpk = function(cfg, config)
    config.actions[cfg.launch] = function()
        for _, key in ipairs({ "Esc", "Esc", "Esc", "Tab", "Space", "Tab", "Tab", "Tab", "Space", "Tab", "Space", "Space", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Space" }) do
            waywall.press_key(key)
        end
        utils.starting_mpk = true
    end

    config.actions[cfg.quit] = function()
        for _, key in ipairs({ "Esc", "Esc", "Tab", "Space", "Esc", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Tab", "Space" }) do
            waywall.press_key(key)
        end
    end
end

-- ==== nml's utils ====

-- use pgrep to check if a process is running
utils.is_running = function(regex)
    local handle = io.popen("pgrep -f '" .. regex .. "'")
    local result = handle:read("*l")
    handle:close()
    return result ~= nil
end

-- set dpi of a logitech mouse via `scripts/solaar-watch.py`
utils.set_dpi = function(dpi)
    local handle = io.popen("echo " .. dpi .. " > /tmp/solaar-watch-set")
    local result = handle:read("*l")
    handle:close()
    return result ~= nil
end

-- true if the game has state output, false if not, nil if unchecked
utils.has_state = nil
-- wrapper for helpers.ingame_only to run when state output is missing
utils.ingame_only = function(func)
    return function()
        if utils.has_state then
            return helpers.ingame_only(func)()
        end
        return func()
    end
end

-- create a function that creates a toggleable text mirror with an optional shadow
-- - options = mirror options & { sx, sy } for shadow offset & { shadow_shader } for optional shadow shader
utils.text_mirror = function(options)
    options.shader = options.shader or "text"
    local text = utils.make_mirror(options)
    local shadow = nil
    if options.sx or options.sy then
        local options2 = {
            src = options.src, shader = options.shadow_shader or "shadow",
            dst = { x = options.dst.x + options.sx,  y = options.dst.y + options.sy, w = options.dst.w, h = options.dst.h }
        }
		if options.dst.scale then
			options2.dst.w = options.src.w * options.dst.scale
			options2.dst.h = options.src.h * options.dst.scale
		end
        shadow = utils.make_mirror(options2)
    end
    return function(enable)
        text(enable)
        if shadow then
            shadow(enable)
        end
    end
end

-- create a function that creates a toggleable mirror for the f3 screen
-- - gui_scale = src gui scale
-- - line = line number from 0
-- - x = left offset
-- - w = width
-- - dst = mirror dst
utils.f3_mirror = function(gui_scale, line, x, w, dst)
    local src = { x = (1 + x) * gui_scale, y = (1 + line * 9) * gui_scale, w = w * gui_scale, h = 9 * gui_scale }
	if not dst then
		dst = {}
	end
    if not dst.x and not dst.y then
        dst.x = src.x
        dst.y = src.y
        dst.w = src.w
        dst.h = src.h
    end
    return utils.text_mirror({ src = src, dst = dst, sx = gui_scale * (dst.scale or 1), sy = gui_scale * (dst.scale or 1) })
end

return utils