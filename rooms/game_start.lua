local room = {}


	function room:load()
		
	end

	function room:update()

	end

	function room:draw()

	end

	function room:keypressed(key)
		love.window.showMessageBox( "..", "Я - кейпрессед в комнате game_start", "info", true)
	end

return room