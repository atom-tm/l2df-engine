local l2df = l2df
local ui = l2df.ui
local data = l2df.data
local settings = l2df.settings.global

local room = { }

	local loading_ended = false

	local bg_video = ui.Video("sprites/intro.ogv", 0, 0, true)
	local loading_anim = ui.Animation("sprites/UI/loading.png", settings.width, settings.height, 140, 140, 4, 3, 12, 2, true)
	local loaded_text = ui.Text(l2df.i18n("press_anykey"), "press_anykey", settings.width, settings.height, { 1, 1, 1, 1})

	room.nodes = {
		bg_video,
		loading_anim,
		loaded_text,
	}

	local initialProcessing = coroutine.create(function ()
		coroutine.yield()
			l2df.settings:load() -- loading settings file
		coroutine.yield()
			l2df.settings:apply() -- apply all settings
			loading_anim.x = settings.width - 150
			loading_anim.y = settings.height - 150

			loaded_text.x = settings.width - 400
			loaded_text.y = settings.height - 55
		coroutine.yield()
			l2df.i18n:loadLocales(settings.langs_path, settings.lang) -- load locales files from folder
		coroutine.yield()
			l2df.font:loadFonts(settings.fonts_path) -- load fonts file
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
		for i = 1, 25 do
			coroutine.yield()
		end
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

	function room:mousepressed()
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