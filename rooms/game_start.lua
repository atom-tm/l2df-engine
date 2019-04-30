local room = {}

	function room:load()
		love.window.showMessageBox( "..", "Я - функция загрузки комнаты game_start", "info", true)
	end

	function room:update()

	end

	function room:draw()

	end

	function room:keypressed(key)
		love.window.showMessageBox( "..", "Я - кейпрессед в комнате game_start", "info", true)
	end

return room