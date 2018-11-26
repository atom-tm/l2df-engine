local controls = {}

	controls.selected = 1
	controls.list = {}
	controls.setup_mode = false
	controls.setup_player = 0
	controls.p1_opt = 1
	controls.p2_opt = 1
	controls.background_image = LoadImage("sprites/UI/background.png")

	function controls.load()
	end

	function controls.update()
		controls.list = {}

		setting = {}
		setting.option = "up"
		setting.p1 = control_settings[1].up
		setting.p2 = control_settings[2].up
		table.insert(controls.list, setting)

		setting = {}
		setting.option = "down"
		setting.p1 = control_settings[1].down
		setting.p2 = control_settings[2].down
		table.insert(controls.list, setting)

		setting = {}
		setting.option = "left"
		setting.p1 = control_settings[1].left
		setting.p2 = control_settings[2].left
		table.insert(controls.list, setting)

		setting = {}
		setting.option = "right"
		setting.p1 = control_settings[1].right
		setting.p2 = control_settings[2].right
		table.insert(controls.list, setting)

		setting = {}
		setting.option = "attack"
		setting.p1 = control_settings[1].attack
		setting.p2 = control_settings[2].attack
		table.insert(controls.list, setting)

		setting = {}
		setting.option = "jump"
		setting.p1 = control_settings[1].jump
		setting.p2 = control_settings[2].jump
		table.insert(controls.list, setting)

		setting = {}
		setting.option = "defend"
		setting.p1 = control_settings[1].defend
		setting.p2 = control_settings[2].defend
		table.insert(controls.list, setting)

		setting = {}
		setting.option = "jutsu"
		setting.p1 = control_settings[1].jutsu
		setting.p2 = control_settings[2].jutsu
		table.insert(controls.list, setting)


	end

	local opacity = 0.1
	local opacity_change = 0.0015

	function controls.draw()
		camera:draw(function(l,t,w,h)
			love.graphics.draw(controls.background_image,0,0,0,1,1)
			print("controls", 250, 50, 0, 1)
			print("player 1 (f1)", 500, 63, 1, 0.8, -13)
			print("player 2 (f2)", 800, 63, 1, 0.8, -13)
			local y_offset = 57
			local y_pos = 145
			for i = 1, #controls.list do

				print(controls.list[i].option, 300, y_pos, 1, 0.8, -13)
				if controls.setup_mode and controls.setup_player == 1 and controls.p1_opt == i then
					love.graphics.setColor(0,0,0, opacity)
					love.graphics.rectangle("fill", 510, y_pos - 5, 170, 55)
					love.graphics.setColor(1,1,1, 1)
					print(controls.list[i].p1, 580, y_pos, 1, 0.8, -13)
				else
					print(controls.list[i].p1, 580, y_pos, 0, 0.8, -13)
				end

				if controls.setup_mode and controls.setup_player == 2 and controls.p2_opt == i then
					love.graphics.setColor(0,0,0, opacity)
					love.graphics.rectangle("fill", 810, y_pos - 5, 170, 55)
					love.graphics.setColor(1,1,1, 1)
					print(controls.list[i].p2, 880, y_pos, 1, 0.8, -13)
				else
					print(controls.list[i].p2, 880, y_pos, 0, 0.8, -13)
				end
				y_pos = y_pos + y_offset
				love.graphics.setColor(1,1,1,1)
			end
			if opacity < 0.05 or opacity > 0.15 then
				opacity_change = -opacity_change
			end
			opacity = opacity + opacity_change
		end)
	end

	function controls.keypressed ( button, scancode, isrepeat )
		if controls.setup_mode then
			if controls.setup_player == 1 then
				control_settings[1][controls.list[controls.p1_opt].option] = button
				controls.p1_opt = controls.p1_opt + 1
			elseif controls.setup_player == 2 then
				control_settings[2][controls.list[controls.p2_opt].option] = button
				controls.p2_opt = controls.p2_opt + 1
			end
			if controls.p1_opt > 8 or controls.p2_opt > 8 then
				controls.p1_opt = 1
				controls.p2_opt = 1
				controls.setup_player = 0
				controls.setup_mode = false
			end
		else
			if button == control_settings[1].jump or button == control_settings[2].jump then
				setRoom(3)
			end
			if button == "escape" then
				setRoom(3)
			end
			
			if button == "f1" then
				controls.setup_mode = true
				controls.setup_player = 1
				controls.p1_opt = 1
			end

			if button == "f2" then
				controls.setup_mode = true
				controls.setup_player = 2
				controls.p1_opt = 2
			end   
		end
	end

return controls