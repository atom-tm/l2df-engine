local room = {}
	room.elements = {
		ui.Text(100,100,"hello world!!"),
		ui.Text(190,150,"nice!"),
	}

	function room:load()

	end

	function room:update()

	end

	function room:draw()
		for key in pairs(self.elements) do
			self.elements[key]:draw()
		end
	end

	function room:keypressed(key)
		love.window.showMessageBox( "..", "Я - кейпрессед в комнате game_start", "info", true)
	end

return room