	local room = {}
	room.CustomDraw = true
	test01 = 0

	function room:load(spawnList)
		battle:Load(spawnList)
		self.pause_mode = 0
	end

	function room:update()
		if room.pause_mode < 1 then
			if room.pause_mode < 0 then room.pause_mode = room.pause_mode + 2 end
			battle:Update()
		end
		battle.control.Update()
	end

	function room:draw()
		battle:DrawGame()
		battle:DrawInterface()
	end

	function room:keypressed(key)
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
			for i = 1, 10 do
				battle.entities.spawnObject(1,1700 + math.random(-600, 600),0,130 + math.random(-110, 110),nil,"standing",nil)
			end
		end
		if key == "f4" then
			for i = 1, 5 do
				battle.entities.spawnObject(5,1700 + math.random(-600, 600),0,130 + math.random(-110, 110),nil,"standing",nil)
			end
		end
		if key == "f5" then
			battle.entities.list[1].hp = battle.entities.list[1].hp - math.random(0,100)
			battle.entities.list[1].mp = battle.entities.list[1].mp - math.random(0,70)
			battle.entities.list[1].sp = battle.entities.list[1].sp - math.random(0,5)
		end
		if key == "f6" then
			battle.entities.list[2].hp = battle.entities.list[2].hp - math.random(0,100)
			battle.entities.list[2].mp = battle.entities.list[2].mp - math.random(0,70)
			battle.entities.list[2].sp = battle.entities.list[2].sp - math.random(0,5)
		end
		if key == "f7" then
			--battle.entities.spawnObject(220,1700 + math.random(-600, 600),0,130 + math.random(-110, 110),nil,1,nil)
			battle.entities.spawnObject(222,1500 + math.random(-600, 600),0,100 + math.random(-110, 110),nil,1,nil)
		end
		if key == "f8" then
			settings.quality = not (settings.quality)
		end
		battle.control.keyPressed(key)
	end

	function room:Debug()
		local timers = ""
		for tick in pairs(battle.tick) do
			timers = timers..battle.tick[tick] .. " "
		end

		font.print("fps: " .. love.timer.getFPS(), 10, 170)
		font.print("timers: " .. timers, 10, 190)

		font.print("objects: " .. battle.objects, 10, 220)
		font.print("drawn objects: " .. #battle.graphic.objects_for_drawing, 10, 240)

		font.print("reflection sourses: " .. #battle.graphic.reflection_sources, 10, 270)
		font.print("lights: " .. #battle.graphic.light_sources, 10, 290)
		font.print("reflections: "..#battle.graphic.reflections_for_drawing, 10, 310)
		font.print("quality: " .. tostring(settings.quality), 10, 330)

		font.print("chars/objects: " .. #battle.chars .. "/" .. #battle.objs, 10, 350)
		font.print("bodys: " .. #battle.collision.list.pending.bodys ..
				   " itrs: " .. #battle.collision.list.pending.itrs ..
				   " processed: " .. #battle.collision.list.processed.bodys + #battle.collision.list.processed.itrs,
			10, 370)
		font.print("block/bdefend: " .. battle.entities.list[1].block .. "/" .. battle.entities.list[1].bdefend, 10, 390)
		font.print("p1 combo: " .. battle.entities.list[1].combo, 10, 410)
	end

	return room