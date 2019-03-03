	local room = {}
	room.CustomDraw = true

	function room:Load(spawnList)
		battle:Load(spawnList)
		self.pause_mode = 0
	end

	function room:Update()
		if room.pause_mode < 1 then
			if room.pause_mode < 0 then room.pause_mode = room.pause_mode + 2 end
			battle:Update()
		end
		battle.control.Update()
	end

	function room:Draw()
		battle:DrawGame()
		battle:DrawInterface()
		font.print(love.timer.getFPS(), settings.window.realWidth - 50, 50)
	end

	function room:Keypressed(key)
		if key == "escape" then
			rooms:Set("character_select")
		end
		if key == "f1" then
			if room.pause_mode == 0 then
				room.pause_mode = 1
			else
				room.pause_mode = 0
			end
		end
		if key == "f2" then
			room.pause_mode = -1
		end
		if key == "f3" then
			battle.entities.spawnObject(2,500,0,150,nil,"standing",nil)
		end
		if key == "f4" then
			for i = 1, 10 do
				battle.entities.spawnObject(2,500,0,150,nil,"standing",nil)
			end
		end
		battle.control.keyPressed(key)
	end

	function room:Debug()
		
	end

	return room