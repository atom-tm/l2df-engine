local fonts = {}

	fonts.list = {
		default = love.graphics.newFont("sprites/UI/fonts/Default.ttf",14),
		character_select_menu = love.graphics.newFont("sprites/UI/fonts/Default.ttf",20),
		character_select_menu_bots = love.graphics.newFont("sprites/UI/fonts/Default.ttf",18),
		character_select_menu_time = love.graphics.newFont("sprites/UI/fonts/Default.ttf",36),
		setting_header = love.graphics.newFont("sprites/UI/fonts/Settings.otf",42),
		setting_comment = love.graphics.newFont("sprites/UI/fonts/Settings.otf",24),
		setting_element = love.graphics.newFont("sprites/UI/fonts/Settings.otf",32),
		menu_element = love.graphics.newFont("sprites/UI/fonts/Settings.otf",48),
	}

	function fonts.print(string, x, y, align, font, stroke, width, r, g, b, a)
		align = get.NotZero(align, "left")
		font = get.NotZero(font, fonts.list.default)
		stroke = get.NotZero(stroke, false)
		width = get.NotZero(width, 300)
		if r == nil then r = 1 end
		if g == nil then g = 1 end
		if b == nil then b = 1 end
		if a == nil then a = 1 end
		local ro,go,bo,ao = love.graphics.getColor()
		love.graphics.setFont(font)
		love.graphics.setColor(r, g, b, a)
		love.graphics.printf(string,x,y,width,align)
		love.graphics.setFont(fonts.list.default)
		love.graphics.setColor(ro, go, bo, ao)
	end

return fonts