local room = {}

	local loading_ended = false
	
	local load_image = ui.Animation(250,250,"sprites/UI/loading.png",140,140,4,3,12,2,true)
	local background_video = ui.Video(0,0,"sprites/bg.ogv",true)
	local end_loading_text = ui.Text(0,0,"Press any key to continue...")

	local list = ui.List(20,50,{
		ui.Button(10,10,130,30,{"Element1","Element1_hover","Element1_pressed"},nil,function ()
			rooms:set("main_menu")
		end),
	})

	room.elements = {
		background_video,
		load_image,
		end_loading_text,
		list,
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
		background_video:play()
		end_loading_text:hide()
	end

	function room:update()
		loading_ended = not coroutine.resume(initialProcessing)
		if loading_ended then
			end_loading_text:show()
			load_image:hide()
		end
		for i = 1, #self.elements do
			self.elements[i]:update()
		end
	end

	function room:draw()
		for i = 1, #self.elements do
			self.elements[i]:draw()
		end
	end

	function room:keypressed()
		if loading_ended then
			rooms:set("main_menu")
		end
	end

	function room:exit()
		for i = 1, #self.elements do
			if self.elements[i].stop then self.elements[i]:stop() end
		end
	end

	function room:mousepressed(x, y, button, istouch, presses)
		print("stage 1")
		if button == 1 then
			print("stage 2")
			for i = 1, #self.elements do
				self.elements[i].click = true
			end
		end
	end

return room