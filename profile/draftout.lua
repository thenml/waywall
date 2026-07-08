-- profile patch for draftout
local options = require("options")
local utils = require("utils")


-- remove this if you have state output
options.safe_guards.state_output = false
options.action.chat_key1 = nil
options.action.chat_key2 = nil


options.remapped_kb = {

}

options.objects.e = {
	enabled = utils.set { "thin", "tall" },
	utils.f3_mirror {
		src = { gui_scale = 1, line = 0, x = -37, w = 49 }, -- <- replace gui_scale if your resolution is 4k+
		dst = { pos_anchor = "right", item_anchor = "bottom", x = -272, scale = 4 },
		sx = 4, sy = 4, depth = 2
	}
}


-- Draftout 1.12.0 has banned zoom macros and ninjabrain bot
options.res.tall = nil
options.action.toggle_ninbot = nil
options.action.on_launch.ninjabrain_bot = nil
options.objects.eye_measure = nil


-- NA in 26.1+
options.objects.f3block = nil
options.objects.glowdar = nil


options.objects.pie_chart = {
	enabled = utils.set { "thin" },
	utils.text_mirror {
		src = { anchor = "bottomright", w = 270, h = 0.25 }, -- modify h (0.25), if the pie is too small
		dst = { anchor = "bottomright", scale = 2 },
		shader = "pie_chart_modern", shadow = { shader = "pie_chart_modern_shadow" }
	},
	utils.text_mirror {
		src = { anchor = "bottomright", w = 25, h = 7, y = -146, x = -11 }, -- <- you will have to multiple some values if your gui_scale > 1
		dst = { pos_anchor = "right", item_anchor = "top", x = -272, scale = 4 },
		shader = "default", color_key = { input = "#ffffff", output = "#ffffff" },
		shadow = { shader = "default", color_key = { input = "#ffffff", output = "000000D8" } }
	},
}


-- Modified for 26.1 + draftout
options.mpk.launch_macro = { "Esc", "Esc", "Esc", "Tab", "Tab", "Space", "Esc", "Tab", "Space", "Tab", "Tab", "Space",
	"Tab", "Space", "Space", "Tab", "Tab", "Tab", "Space" }

-- ! use this if playing 26.1 without draftout
-- options.mpk.launch_macro = { "Esc", "Esc", "Esc", "Tab", "Space", "Esc", "Space", "Tab", "Tab", "Space", "Tab", "Space", "Space", "Tab", "Tab", "Tab", "Space" }

return require("init")
