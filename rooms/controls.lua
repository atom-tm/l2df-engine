local controls = {}

	controls.selected = 1
	controls.list = {}
	controls.setup_mode = false
	controls.setup_player = 0
	controls.p1_opt = 1
	controls.p2_opt = 1
	controls.background_image = LoadImage("sprites/UI/background.png")

	function controls.load()
		controls.list = {}

		setting = {}
		setting.massive = "up"
		setting.option = localization.controls.up
		setting.p1 = control_settings[1].up
		setting.p2 = control_settings[2].up
		table.insert(controls.list, setting)

		setting = {}
		setting.massive = "down"
		setting.option = localization.controls.down
		setting.p1 = control_settings[1].down
		setting.p2 = control_settings[2].down
		table.insert(controls.list, setting)

		setting = {}
		setting.massive = "left"
		setting.option = localization.controls.left
		setting.p1 = control_settings[1].left
		setting.p2 = control_settings[2].left
		table.insert(controls.list, setting)

		setting = {}
		setting.massive = "right"
		setting.option = localization.controls.right
		setting.p1 = control_settings[1].right
		setting.p2 = control_settings[2].right
		table.insert(controls.list, setting)

		setting = {}
		setting.massive = "attack"
		setting.option = localization.controls.attack
		setting.p1 = control_settings[1].attack
		setting.p2 = control_settings[2].attack
		table.insert(controls.list, setting)

		setting = {}
		setting.massive = "jump"
		setting.option = localization.controls.jump
		setting.p1 = control_settings[1].jump
		setting.p2 = control_settings[2].jump
		table.insert(controls.list, setting)

		setting = {}
		setting.massive = "defend"
		setting.option = localization.controls.defend
		setting.p1 = control_settings[1].defend
		setting.p2 = control_settings[2].defend
		table.insert(controls.list, setting)

		setting = {}
		setting.massive = "jutsu"
		setting.option = localization.controls.jutsu
		setting.p1 = control_settings[1].jutsu
		setting.p2 = control_settings[2].jutsu
		table.insert(controls.list, setting)
	end

	function controls.update()
	end

	local opacity = 0.1
	local opacity_change = 0.0015

	function controls.draw()
			love.graphics.draw(controls.background_image,0,0,0,1,1)
			print(localization.controls.controls, 250, 50, nil, fonts.menu_head, 0, 300, 0, 0, 0, 1)
			print(localization.controls.info, 0, 645, "center", fonts.menu_comment, 0, 1280, 0, 0, 0, opacity * 3 + 0.4)
			print(localization.controls.p1, 520, 70, nil, fonts.menu, 0, 300, 0, 0, 0, 1)
			print(localization.controls.p2, 790, 70, nil, fonts.menu, 0, 300, 0, 0, 0, 1)
			local y_offset = 57
			local y_pos = 155
			for i = 1, #controls.list do

				print(controls.list[i].option, 190, y_pos, "right", fonts.menu, 0, 205, 0, 0, 0, 1)
				if controls.setup_mode and controls.setup_player == 1 and controls.p1_opt == i then
					love.graphics.setColor(0,0,0, opacity)
					love.graphics.rectangle("fill", 520, y_pos - 5, 170, 55)
					love.graphics.setColor(1,1,1, 1)
					print(controls.list[i].p1, 520, y_pos, "center", fonts.menu, 0, 170, 1, 1, 1, 1)
				else
					print(controls.list[i].p1, 520, y_pos, "center", fonts.menu, 0, 170, 0, 0, 0, 1)
				end

				if controls.setup_mode and controls.setup_player == 2 and controls.p2_opt == i then
					love.graphics.setColor(0,0,0, opacity)
					love.graphics.rectangle("fill", 790, y_pos - 5, 170, 55)
					love.graphics.setColor(1,1,1, 1)
					print(controls.list[i].p2, 790, y_pos, "center", fonts.menu, 0, 170, 1, 1, 1, 1)
				else
					print(controls.list[i].p2, 790, y_pos, "center", fonts.menu, 0, 170, 0, 0, 0, 1)
				end
				y_pos = y_pos + y_offset
				love.graphics.setColor(1,1,1,1)
			end
			if opacity < 0.05 or opacity > 0.15 then
				opacity_change = -opacity_change
			end
			opacity = opacity + opacity_change
	end

	function controls.keypressed ( button, scancode, isrepeat )
		if controls.setup_mode then
			if controls.setup_player == 1 then
				control_settings[1][controls.list[controls.p1_opt].massive] = button
				controls.p1_opt = controls.p1_opt + 1
			elseif controls.setup_player == 2 then
				control_settings[2][controls.list[controls.p2_opt].massive] = button
				controls.p2_opt = controls.p2_opt + 1
			end
			if controls.p1_opt > 8 or controls.p2_opt > 8 then
				controls.p1_opt = 1
				controls.p2_opt = 1
				controls.setup_player = 0
				controls.setup_mode = false
			end
			room.load()
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
		save_settings()
	end

return controls