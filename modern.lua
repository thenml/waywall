-- profile patch for modern versions
local config = require("init")
local u = require("utils")

local noop = function(...) end

config._.cfg.remap.default = {
	-- f3 on mouse
	["MB5"] = "F3",

	-- z <-> left shift (easier shift click)
	["Z"] = "LeftShift",
	["LeftShift"] = "Z",
}
config.input.remaps = config._.cfg.remap.default

-- state output is not present in 26.1
config.actions["Return"] = nil
config.actions["Slash"] = nil

config._.mirrors.f3block = noop
config._.mirrors.glowdar = noop
-- config._.mirrors.e = noop
config._.mirrors.e = u.f3_mirror(1, 0, 340-88, 49, { x = 1150, y = 611, scale = 4 })

-- config._.mirrors.thin_pie_chart = u.make_mirror({
-- 	-- src = { x = 94, y = 829, w = 210, h = 104},
-- 	src = { x = 0, y = 1080/4*3, w = 340, h = 1080/4},
-- 	-- dst = { x = 1225, y = 654, w = 200, h = 200 },
-- 	dst = { x = 1920-340*2, y = 1080/2, w = 340*2, h = 1080/2 },
-- 	shader = "pie_chart_modern",
-- 	depth = 1
-- })
-- config._.mirrors.thin_pie_percent = u.make_mirror({
-- 	-- src = { x = 94, y = 829, w = 210, h = 104},
-- 	src = { x = 0, y = 1080/4*3, w = 340, h = 1080/4},
-- 	-- dst = { x = 1225, y = 654, w = 200, h = 200 },
-- 	dst = { x = 1920-340*2 +2, y = 1080/2 +2, w = 340*2, h = 1080/2 },
-- 	shader = "pie_chart_modern_shadow",
-- 	depth = 0
-- })

config._.mirrors.thin_pie_chart = noop
config._.mirrors.thin_pie_percent = noop
config._.mirrors.tall_pie_chart = noop
config._.mirrors.tall_pie_percent = noop


-- local pie_highlight = u.make_mirror({
-- 	src = { x = 1109, y = 0, w = 53, h = 1080},
-- 	dst = { x = 1109, y = 0, w = 53, h = 1080 },
-- 	shader = "pie_chart_modern_highlight",
-- 	depth = 1
-- })

-- config._.show_mirrors = function(thin, tall, wide)
-- 	pie_highlight(not thin and not tall and not wide)
-- end

return config