local fonts = { }

	fonts.list = {
		default = love.graphics.newFont("sprites/UI/fonts/Default.ttf", 14),
		character_select_menu = love.graphics.newFont("sprites/UI/fonts/Default.ttf", 20),
		character_select_menu_bots = love.graphics.newFont("sprites/UI/fonts/Default.ttf", 18),
		character_select_menu_time = love.graphics.newFont("sprites/UI/fonts/Default.ttf", 72),
		character_select_mode_select = love.graphics.newFont("sprites/UI/fonts/Default.ttf", 26),
		setting_header = love.graphics.newFont("sprites/UI/fonts/Settings.otf", 42),
		setting_comment = love.graphics.newFont("sprites/UI/fonts/Settings.otf", 24),
		setting_element = love.graphics.newFont("sprites/UI/fonts/Settings.otf", 34),
		menu_element = love.graphics.newFont("sprites/UI/fonts/Settings.otf", 48),
		timer = love.graphics.newFont("sprites/UI/fonts/Time.ttf", 36),
		stats = love.graphics.newFont("sprites/UI/fonts/Default.ttf", 10),
	}

	function fonts.print(string, x, y, align, font, stroke, width, r, g, b, a)
		if type(r) == "table" then
			g = r[2]
			b = r[3]
			a = r[4]
			r = r[1]
		end
		align = align or "left"
		font = font or fonts.list.default
		stroke = stroke or false
		width = width or 300

		local ro, go, bo, ao = love.graphics.getColor()
		love.graphics.setFont(font)
		love.graphics.setColor(r or ro, g or go, b or bo, a or ao)
		love.graphics.printf(tostring(string), x, y, width, align)
		love.graphics.setFont(fonts.list.default)
		love.graphics.setColor(ro, go, bo, ao)
	end

return fonts