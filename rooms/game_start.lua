local l2df = l2df
local ui = l2df.ui
local data = l2df.data
local settings = l2df.settings.global

local room = { }

	local loading_ended = false
	
	local bg_video = ui.Video("sprites/bg.ogv", 0, 0, true)
	local loading_anim = ui.Animation("sprites/UI/loading.png", 8, 8, 140, 140, 4, 3, 12, 2, true)
	local loaded_text = ui.Text("press_anykey", nil, 8, 8, { 1, 1, 1, 1})

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
			l2df.i18n:loadLocales(settings.langs_path, settings.lang)
		coroutine.yield()
			data:loadStates()
		coroutine.yield()
			data:loadKinds()
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
	end)

	function room:load()
		bg_video:play()
		loaded_text:hide()
	end

	function room:update()
		if loading_ended then return end

		loading_ended = coroutine.status(initialProcessing) == "dead"
		if loading_ended then
			loaded_text:show()
			loading_anim:hide()
			initialProcessing = nil
		else
			local err, message = coroutine.resume(initialProcessing)
			assert(err, "Loading failed: " .. tostring(message))
		end
	end

	function room:keypressed()
		if loading_ended then
			l2df.rooms:set("menu")
		end
	end

	function room:exit()
		for i = 1, #self.nodes do
			if self.nodes[i].stop then self.nodes[i]:stop() end
		end
	end

return room