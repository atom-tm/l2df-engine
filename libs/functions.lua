local functions = {}
	function functions.SetWindowSize()
		local width = settings.windowSizes[settings.window.selectedSize].width
		local height = settings.windowSizes[settings.window.selectedSize].height
		settings.window.width = width
		settings.window.height = height
		love.window.setMode(width, height)
		love.window.setFullscreen(settings.window.fullscreen)
		if settings.window.fullscreen then width,height = love.window.getMode() end
		camera = gamera.new(0,0,settings.gameWidth,settings.gameHeight)
		camera:setWindow(0,0,width, height)
		settings.window.cameraScale = height / settings.gameHeight
		camera:setScale(settings.window.cameraScale)
		settings.window.realHeight = height
		settings.window.realWidth = width
	end

	function functions.CopyTable(table)
		local result = {}
		for key, val in pairs(table) do
			if type(val) == "table" then result[key] = functions.CopyTable(val)
			else result[key] = val end
		end
		return result
	end
return functions