local room = { }

	local loading_ended = false
	
	local bg_video = ui.Video("sprites/bg.ogv", 0, 0, true)
	local loading_anim = ui.Animation("sprites/UI/loading.png", 8, 8, 140, 140, 4, 3, 12, 2, true)
	local loaded_text = ui.Text("Press any key to continue...", 8, 8)

	room.nodes = {
		bg_video,
		loading_anim,
		loaded_text,
	}

	local initialProcessing = coroutine.create(function ()
		coroutine.yield()
			settings:load()
		coroutine.yield()
			settings:apply()
		coroutine.yield()			
			data:loadStates()
		coroutine.yield()
			data:loadKinds()
		coroutine.yield()
			data:loadLocales()
		coroutine.yield()
			data:loadFrames()
		coroutine.yield()
			data:loadSystem()
		coroutine.yield()
			data:loadCombos()
		coroutine.yield()
			data:loadDtypes()
		coroutine.yield()
			data:loadData()
		coroutine.yield()
		for i = 1, 100 do
			coroutine.yield()
		end
	end)

	function room:load()
		bg_video:play()
		loaded_text:hide()
	end

	function room:update()
		loading_ended = not coroutine.resume(initialProcessing)
		if loading_ended then
			loaded_text:show()
			loading_anim:hide()
		end
	end

	function room:keypressed()
		if loading_ended then
			rooms:set("main_menu")
		end
	end

	function room:exit()
		for i = 1, #self.nodes do
			if self.nodes[i].stop then self.nodes[i]:stop() end
		end
	end

return room