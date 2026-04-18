-- ==== KEYS ====
local home_path = os.getenv("HOME") .. "/Documents/Minecraft/mcsr/"
local config_path = os.getenv("HOME") .. "/.config/waywall/"

return {
	input = {
        layout = "us,ru",
        options = "caps:none, grp:alt_shift_toggle",
        
        confine_pointer = false,
	},
	theme = {
        background = "#00000000",
        ninb_anchor = "topleft",
        ninb_opacity = 0.9,
    },
	key = {
		thin = "*-X",
		tall = "Alt_L",
		wide = "*-Hyper_L",
		toggle_ninbot = "N",
		launch_paceman = "Ctrl-Shift-P",
		toggle_nbtracker = "Shift-N",
		ensure_running = "Ctrl-R",
		fullscreen = "F11",
		chat_key1 = "Return",
		chat_key2 = "Slash",
		mpk = {
			launch = "F9",
			quit = "F10",
			load = "W"
		},
		takeabreak = "Escape"
	},
	remap = {
		default = {
			-- f3 on mouse
			["MB5"] = "F3",
		
			-- z <-> left shift (easier pie)
			["Z"] = "LeftShift",
			["LeftShift"] = "Z",
		
			-- d <-> x; f <-> r; t <-> a (easier f3 kb)
			["D"] = "X",
			["X"] = "D",
			["F"] = "R",
			["R"] = "F",
			["T"] = "A",
			["A"] = "T",

			-- q <-> o (search crafting)
			["Q"] = "O",
			["O"] = "Q",
		}
	},
	dpi = {
		id = "G304",
		normal = 4200,
		tall = 400,
	},
	-- sens = {
	-- 	-- 0.058765005 ingame (godsens)
	-- 	normal = 4.2,
	-- 	tall = 0.4,
	-- },
	path = {
		pacem = home_path .. "paceman-tracker-0.7.0.jar",
		nb = home_path .. "Ninjabrain-Bot-1.5.2.jar",
		solaar = config_path .. "scripts/solaar-watch.py",
		tmp_saves = config_path .. "scripts/tmp-saves.sh",
		overlay = config_path .. "images/overlay_border.png",
		x_border = config_path .. "images/x_border.png",
		y_border = config_path .. "images/y_border.png",
	}
}