local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Fonts works only with l2df v1.0 and higher")
assert(type(love) == "table", "Fonts works only under love2d environment")

local jsonParser = core.import "parsers.json"

local fs = love.filesystem

local fonts = { list = { } }

	--- The function loads the list of game fonts from the json file
	-- @param file, string        link to json file
	function fonts:loadFonts(file)
		assert(fs, "Loading fonts currently works only with love2d")
		if fs.getInfo(file, "file") then
			local temp = jsonParser:parseFile(file)
			for key, val in pairs(temp) do
				self.list[key] = love.graphics.newFont(val.file, val.size)
			end
		end
	end

	--- The function of drawing text on the screen
	-- @param string, string 		String of text
	-- @param x, number 			Text x coordinate
	-- @param y, number 			Text y coordinate
	-- @param align, string 		Optional. The alignment of the text
	-- @param font, string 			Optional. Font used for rendering (from fonts.list)
	-- @param stroke, boolean       Optional. Presence of stroke
	-- @param width, number 		Optional. The width of the text block
	-- @param color, table  		Optional. Text color
	function fonts.print(string, x, y, align, font, stroke, width, color)
		local r,g,b,a = 1,1,1,1
		if type(color) == "table" then
			r = color[1] or 1
			g = color[2] or 1
			b = color[3] or 1
			a = color[4] or 1
		end
		x = x or 0
		y = y or 0
		align = align or "left"
		font = fonts.list[font] or fonts.list["default"]
		stroke = stroke or false
		width = width or font and font:getWidth(string) or 0
		string = tostring(string) or "Impossible to display the text"

		local ro, go, bo, ao = love.graphics.getColor()
		if font then love.graphics.setFont(font) end
		love.graphics.setColor(r or ro, g or go, b or bo, a or ao)
		love.graphics.printf(string, x, y, width, align)
		love.graphics.setColor(ro, go, bo, ao)
	end

return fonts