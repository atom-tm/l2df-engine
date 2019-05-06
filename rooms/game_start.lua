local l2df = l2df
local ui = l2df.ui

local room = { }

	local loading_ended = false
	
	local bg_video = ui.Video("sprites/bg.ogv", 0, 0, true)
	local loading_anim = ui.Animation("sprites/UI/loading.png", 8, 8, 140, 140, 4, 3, 12, 2, true)
	local loaded_text = ui.Text("Press any key to continue...", nil, 8, 8)

	room.nodes = {
		bg_video,
		loading_anim,
		loaded_text,
	}

	local initialProcessing = coroutine.create(function ()
		coroutine.yield()
			l2df.settings:load()
		coroutine.yield()
			l2df.settings:apply()
		coroutine.yield()
			l2df.i18n:loadLocales(settings.global.locales_path)
		coroutine.yield()
		-- 	data:loadStates(settings.global.states_path)
		-- coroutine.yield()
		-- 	data:loadKinds(settings.global.kinds_path)
		-- coroutine.yield()
		-- 	data:loadFrames(settings.global.frames)
		-- coroutine.yield()
		-- 	data:loadSystem(settings.global.system)
		-- coroutine.yield()
		-- 	data:loadCombos(settings.global.system)
		-- coroutine.yield()
		-- 	data:loadDtypes(settings.global.dtypes)
		-- coroutine.yield()
		-- 	data:loadData(settings.global.data)
		-- coroutine.yield()
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
			l2df.rooms:set("main_menu")
		end
	end

	function room:exit()
		for i = 1, #self.nodes do
			if self.nodes[i].stop then self.nodes[i]:stop() end
		end
	end

return room