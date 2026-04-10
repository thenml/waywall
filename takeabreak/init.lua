local cfg = {
	minutes = 60,
	image = os.getenv("HOME") .. "/.config/waywall/takeabreak/take-a-break-aga.png",
	text = {
		enabled = true,
		x = 0,
		y = 100,
		size = 1,
		color = "#ffffff88",
	}
}

local waywall = require("waywall")
local next_time = waywall.current_time() + cfg.minutes * 60 * 1000

local img = nil
local text = nil

return function (config, key)
	waywall.listen("state", function()
		local state = waywall.state()
		if state.screen == "title" and waywall.current_time() > next_time then
			waywall.sleep(2000)
			if waywall.state().screen ~= "title" then
				return
			end
			if img == nil then
				img = waywall.image(cfg.image, {
					dst = { x = 0, y = 0, w = 1920, h = 1080 },
				})
			end
			if text == nil and cfg.text.enabled then
				text = waywall.text("press " .. key .. " to close", cfg.text)
			end
		end
	end)

	config.actions[key] = function()
		if img ~= nil then
			next_time = waywall.current_time() + cfg.minutes * 60 * 1000
			img:close()
			img = nil
		end
		if text ~= nil then
			text:close()
			text = nil
		end
		return false
	end
end