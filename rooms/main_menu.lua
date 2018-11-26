local main_menu = {}

	main_menu.selected_mode = 1
	main_menu.background_image = LoadImage("sprites/UI/background.png")
	main_menu.logotype_image = LoadImage("sprites/UI/logotype.png")
	main_menu.mode = {}

	main_menu.mode[1] = {}
	main_menu.mode[1].normal = LoadImage("sprites/UI/MainMenu/main_mode1_normal.png")
	main_menu.mode[1].active = LoadImage("sprites/UI/MainMenu/main_mode1_active.png")
	main_menu.mode[1].x = 480
	main_menu.mode[1].y = 420
	main_menu.mode[1].action = function ()
		setRoom(2)
	end

	main_menu.mode[2] = {}
	main_menu.mode[2].normal = LoadImage("sprites/UI/MainMenu/main_mode2_normal.png")
	main_menu.mode[2].active = LoadImage("sprites/UI/MainMenu/main_mode2_active.png")
	main_menu.mode[2].x = 480
	main_menu.mode[2].y = 490

	main_menu.mode[3] = {}
	main_menu.mode[3].normal = LoadImage("sprites/UI/MainMenu/main_mode4_normal.png")
	main_menu.mode[3].active = LoadImage("sprites/UI/MainMenu/main_mode4_active.png")
	main_menu.mode[3].x = 480
	main_menu.mode[3].y = 560
	main_menu.mode[3].action = function ()
		setRoom(3)
	end

	main_menu.mode[4] = {}
	main_menu.mode[4].normal = LoadImage("sprites/UI/MainMenu/main_mode3_normal.png")
	main_menu.mode[4].active = LoadImage("sprites/UI/MainMenu/main_mode3_active.png")
	main_menu.mode[4].x = 480
	main_menu.mode[4].y = 630


	function main_menu.load()
	end

	function main_menu.update()
	end

	function main_menu.draw()
		camera:draw(function(l,t,w,h)
			love.graphics.draw(main_menu.background_image,0,0,0,1,1)
			love.graphics.draw(main_menu.logotype_image,400,20,0,1,1)
			for i = 1, #main_menu.mode do
				if i == main_menu.selected_mode then
					if main_menu.mode[i].active ~= nil then
						love.graphics.draw(main_menu.mode[i].active,main_menu.mode[i].x,main_menu.mode[i].y,0,1,1)
					end
					if main_menu.mode[i].text ~= nil then
						print(main_menu.mode[i].text, main_menu.mode[i].x, main_menu.mode[i].y, 1)
					end
				else
					if main_menu.mode[i].normal ~= nil then
						love.graphics.draw(main_menu.mode[i].normal,main_menu.mode[i].x,main_menu.mode[i].y,0,1,1)
					end
					if main_menu.mode[i].text ~= nil then
						print(main_menu.mode[i].text, main_menu.mode[i].x, main_menu.mode[i].y, 0)
					end
				end
			end
			love.graphics.print(main_menu.background_image:getWidth(),10,10)
			love.graphics.print(main_menu.background_image:getHeight(),10,30)
			love.graphics.print(main_menu.selected_mode,10,50)
		end)


	end

	function main_menu.keypressed ( button, scancode, isrepeat )
		if button == control_settings[1].up or button == control_settings[2].up then
			local mode = main_menu.selected_mode
			if mode > 1 then mode = mode - 1
			else mode = #main_menu.mode end
			main_menu.selected_mode = mode
		end
		if button == control_settings[1].down or button == control_settings[2].down then
			local mode = main_menu.selected_mode
			if mode < #main_menu.mode then mode = mode + 1
			else mode = 1 end
			main_menu.selected_mode = mode
		end
		if button == control_settings[1].attack or button == control_settings[2].attack then
			if main_menu.mode[main_menu.selected_mode].action ~= nil then
				main_menu.mode[main_menu.selected_mode].action()
			end
		end
		if button == "f1" then
			setRoom(3)
		end
	end

return main_menu