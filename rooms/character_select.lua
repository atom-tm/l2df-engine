local main_menu = {}

	main_menu.selected_mode = 1
	main_menu.background_image = LoadImage("sprites/UI/background.png")
	main_menu.logotype_image = LoadImage("sprites/UI/logotype.png")


	function main_menu.load()
		wait = 0
	end

	function main_menu.update()
		if (love.keyboard.isDown( control_settings[1].up ) or love.keyboard.isDown( control_settings[2].up )) and wait == 0 then
			main_menu.change_mode("up")
			wait = 15
		end
		if (love.keyboard.isDown( control_settings[1].down ) or love.keyboard.isDown( control_settings[2].down )) and wait == 0 then
			main_menu.change_mode("down")
			wait = 15
		end

		if wait > 0 then
			wait = wait - 1
		end
	end

	function main_menu.draw()
		camera:draw(function(l,t,w,h)
			love.graphics.draw(main_menu.background_image,0,0,0,1,1)
			love.graphics.draw(main_menu.logotype_image,400,40,0,1,1)

			love.graphics.print(main_menu.background_image:getWidth(),10,10)
			love.graphics.print(main_menu.background_image:getHeight(),10,30)
			love.graphics.print(main_menu.selected_mode,10,50)
		end)


	end

	function main_menu.change_mode(swipe_type)
		local mode = main_menu.selected_mode
		if swipe_type == "up" then
			if mode > 1 then mode = mode - 1
			else mode = #main_menu.mode end
		end
		if swipe_type == "down" then
			if mode < #main_menu.mode then mode = mode + 1
			else mode = 1 end
		end
		main_menu.selected_mode = mode
	end

return main_menu