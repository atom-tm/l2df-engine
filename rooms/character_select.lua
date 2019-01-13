local room = {}



	function room:DrawCharacters()
		local pos_x = 100
		local width = 1100

		local pos_y = 500
		local height = 100

		local pos = 1

		local distanse = 100

		for key = 1, self.max_players + self.current_bot do
			if self.characters[key] ~= nil then
				local character = self.characters[key]
				
				local anim = nil
				if character.anim == "anim" then
					anim = character.info.animation
				elseif character.anim == "stand" then
					anim = character.info.standing
				end

				local y = nil
				local x = nil
				local facing = nil
				if pos%2 == 1 then
					y = pos_y
					x = pos_x + (math.ceil(pos / 2) * distanse)
					facing = 1
				else
					y = pos_y
				    x = pos_x + width - (math.ceil(pos / 2) * distanse)
				    facing = -1
				end

				image.draw(anim, character.frame, x - anim.centerx * facing , y - anim.centery, facing)
				pos = pos + 1
			end
		end
	end

	function room:CharacterAnimations()
		for key = 1, self.max_players + self.current_bot do
			if self.characters[key] ~= nil then
				local character = self.characters[key]
				if character.wait == nil or character.frame == nil or character.anim == nil then
					character.x_offset = math.random(-5,5)
					character.y_offset = math.random(-15,15)
					character.frame = 1
					character.wait = 0
					character.anim = "start"
				else

					if character.anim == "start" then

					elseif character.anim == "anim" then
						if character.wait > character.info.animation.wait then
							character.wait = 0
							character.frame = character.frame + 1
							if character.frame > character.info.animation.frames then
								character.frame = 1
								character.anim = "stand"
							end
						else
					    	character.wait = character.wait + 1
					    end
					elseif character.anim == "stand" then
						if character.wait > character.info.standing.wait then
							character.wait = 0
							character.frame = character.frame + 1
							if character.frame > character.info.standing.frames then
								character.frame = 1
							end
						else
					    	character.wait = character.wait + 1
					    end
					end
				end
			end
		end
	end



	function room:DrawSelectors(row,col,x_offset,y_offset)
		for index in pairs(self.selectors) do
			local selector = self.selectors[index]
			if selector.active and row == selector.x_pos and col == selector.y_pos then
				local r, g, b, a = love.graphics.getColor()
				love.graphics.setColor(selector.color.r,selector.color.g,selector.color.b, 1 - selector.color.a_mod )
				image.draw(self.selector_image, nil, self.char_icons.real_x_position + x_offset, self.char_icons.real_y_position + y_offset)
				if  not selector.selected then
					if selector.align == "top" then
						font.print(selector.text, self.char_icons.real_x_position + x_offset, self.char_icons.real_y_position + y_offset + 10, "center", font.list.character_select_menu_bots, false, self.selector_image.image:getWidth())
					elseif selector.align == "bot" then
						font.print(selector.text, self.char_icons.real_x_position + x_offset, self.char_icons.real_y_position + y_offset + self.selector_image.image:getHeight() - 35, "center", font.list.character_select_menu_bots, false, self.selector_image.image:getWidth())
					end
				end
				love.graphics.setColor(r,g,b,a)
				if not selector.selected then
					selector.color.a_mod = selector.color.a_mod + selector.color.a_change
					if selector.color.a_mod > selector.color.a_mod_max or selector.color.a_mod < 0 then
						selector.color.a_change = -selector.color.a_change
					end
				else
				    selector.color.a_mod = selector.color.a_mod_max
				end
			end
		end
	end



	function room:DrawCharactersIcons()
		local y_offset = 0
		for col = 1, self.char_icons.cols do 
			local x_offset = 0
			local max_heigh = 0
			for row = 1, self.char_icons.rows do 
				local index = ((col - 1) * self.char_icons.rows) + row
				local head = self.char_icons.list[index].head
				image.draw(head, nil, self.char_icons.real_x_position + x_offset, self.char_icons.real_y_position + y_offset)
				self:DrawSelectors(row,col,x_offset,y_offset)
				x_offset = x_offset + head.image:getWidth() + self.char_icons.margin
				if max_heigh < head.image:getHeight() then
					max_heigh = head.image:getHeight()
				end
			end
			y_offset = y_offset + max_heigh + self.char_icons.margin
		end
	end



	function room:SelectorSettings()
		self.selectors = {
			player_1 = {
				text = "P1", align = "top",
				color = { r = 1, g = 0.7, b = 0.7, a_mod = 0, a_change = 0.01, a_mod_max = 0.3 },
				active = false, selected = false,
				x_pos = 1, y_pos = 1,
			},
			player_2 = {
				text = "P2", align = "bot",
				color = { r = 0.7, g = 0.7, b = 1, a_mod = 0, a_change = 0.01, a_mod_max = 0.3 },
				active = false, selected = false,
				x_pos = self.char_icons.rows, y_pos = 1
			},
			com = {
				text = "Com", align = "top",
				color = { r = 1, g = 1, b = 1, a_mod = 0, a_change = 0.01, a_mod_max = 0.3 },
				active = false, selected = false,
				x_pos = 1, y_pos = 1
			}
		}
	end



	function room:CreateCharactersIcons()
		self.char_icons = {
			margin = -3, x_pos = 640, y_pos = 640,
			rows = 4, cols = 1, list = {}
		}
		for i = 1, (self.char_icons.rows * self.char_icons.cols) do
			local character_info = {}
			if data.characters_list[i] ~= nil then
				character_info.head = data.characters_list[i].head
				character_info.character = data.characters_list[i]
			else
			    character_info.head = self.small_image
			    character_info.character = nil
			end
			self.char_icons.list[i] = character_info
		end
		local row_width = 0
		local col_height = 0
		for col = 1, self.char_icons.cols do
			local image_height = 0
			local row_max = 0
			for row = 1, self.char_icons.rows do 
				local index = ((col - 1) * self.char_icons.rows) + row
				local head = self.char_icons.list[index].head
				row_max = row_max + head.image:getWidth() + self.char_icons.margin
				if head.image:getHeight() > image_height then
					image_height = head.image:getHeight()
				end
			end
			col_height = col_height + image_height + self.char_icons.margin
			if row_width < row_max then row_width = row_max end
		end
		self.char_icons.real_x_position = self.char_icons.x_pos - (row_width - self.char_icons.margin) * 0.5
		self.char_icons.real_y_position = self.char_icons.y_pos - (col_height - self.char_icons.margin) * 0.5
	end



	function room:Load()

		self.background = image.Load("sprites/UI/CS0.png", nil, "linear")
		self.foreground = image.Load("sprites/UI/CS1.png", nil, "linear")
		self.stand = image.Load("sprites/UI/CS2.png", nil, "linear")
		self.small_image = image.Load("sprites/UI/small.png")
		self.selector_image = image.Load("sprites/UI/selector.png")

		self:CreateCharactersIcons()
		self:SelectorSettings()

		self.characters = {}

		self.mode = 0
		--[[
			0 -- вход в комнату
			1 -- Ожидание игроков
		]]
		self.players_timer = 0

		self.max_players = 10
		self.min_players = 2
		self.selected_players = 0

		self.max_bots = 0
		self.min_bots = 0
		self.selected_bots = 0

		self.current_bot = 0

		self.loading_list = {
			characters = {},
			maps = {}
		}




		--[[

		self.scrolls = {
			part1 = image.Load("sprites/UI/scroll1.png"),
			part2 = image.Load("sprites/UI/scroll2.png"),
			width = 750,
			width_temp = 10,
			centerx = 1280 * 0.5,
			centery = 50,
			y_temp = -200,
			anim = 0
		}

		
		self.selected_map = 1


		self.bots_selector = image.Load("sprites/UI/bots_selector.png")
		self.pick_sprite = image.Load("sprites/UI/char_pick.png")
		local eff_c = {
			w = 150,
			h = 150,
			x = 3,
			y = 7
		}
		self.pick_effect = image.Load("sprites/UI/char_pick2.png",eff_c)]]
	end



	function room:Update()
		if self.mode == 0 then
			self.mode = 1
		elseif self.mode == 1 then
			local active_selectors = 0
			local selected_selectors = 0
			for key in pairs(self.selectors) do
				if self.selectors[key].active then
					active_selectors = active_selectors + 1
					if self.selectors[key].selected then
						selected_selectors = selected_selectors + 1
					end
				end
			end
			if active_selectors > 0 and active_selectors == selected_selectors then
				if self.players_timer <= 0 then
					self.selected_players = selected_selectors
					self.players_timer = 0
					self.mode = 2
				else
				    self.players_timer = self.players_timer - 1
				end
			else
				self.players_timer = 300
			end
		elseif self.mode == 2 then
			for key in pairs(self.selectors) do
				self.selectors[key].active = false
			end
			self.max_bots = self.max_players - self.selected_players
			self.min_bots = self.min_players - self.selected_players
			self.selected_bots = self.min_bots
			self.mode = 3
		end
		self:CharacterAnimations()
		--[[self.light = self.light + self.light_change
		if self.light > self.max_light or self.light < 0 then
			self.light_change = -self.light_change
		end
		local activated_players = 0
		local selected_players = 0
		for p = 1, #self.player do 
			self.player[p].id = self.player[p].y * self.x + self.player[p].x + 1
			if self.player[p].activate then
				activated_players = activated_players + 1
			end
			if self.player[p].character ~= nil then
				selected_players = selected_players + 1
			end
		end
		if activated_players > 0 and self.mode == 0 then
			if activated_players == selected_players then
				self.mode = 1
				self.timer = 3
				self.timer_waiter = 60
			end
		elseif self.mode == 1 then
			if self.timer_waiter == 0 then
				self.timer = self.timer - 1
				self.timer_waiter = 60
			else self.timer_waiter = self.timer_waiter - 1 end
			if self.timer <= 0 then
				self.mode = 2
			end
		elseif self.mode == 2 then
			if self.scrolls.anim == 0 then
				self.scrolls.y_temp = self.scrolls.y_temp + 20
				if self.scrolls.y_temp >= self.scrolls.centery then
					self.scrolls.anim = 1
					self.scrolls.y_temp = self.scrolls.centery
				end
			elseif self.scrolls.anim == 1 then
				if self.scrolls.width_temp < self.scrolls.width then
					self.scrolls.width_temp = self.scrolls.width_temp + 40
				else
				    self.scrolls.width_temp = self.scrolls.width
				    self.scrolls.anim = 2
					self.available_number_of_bots = self.max_players - selected_players
					if self.available_number_of_bots > 8 then 
						self.start_bots_count = 1
						self.selected_number_of_bots = 1
					else
					    self.start_bots_count = 0
					    self.selected_number_of_bots = 0
					end
				    self.mode = 3
				end
			end
		elseif self.mode == 3 then
		end
]]
	end



	function room:Draw()
		image.draw(self.background, nil, 0, 0)
		self:DrawCharacters()
		image.draw(self.foreground, nil, 0, 0)
		image.draw(self.stand, nil, 0, 0)
		self:DrawCharactersIcons()
		self:DrawSelectors()
		font.print(self.mode, 10, 10)
		font.print(self.selectors.player_1.active, 10, 30)
		font.print(self.selectors.player_1.selected, 10, 50)
		font.print(self.selectors.player_2.active, 80, 30)
		font.print(self.selectors.player_2.selected, 80, 50)
		font.print(math.ceil(self.players_timer / 50), 10, 70)
		font.print(self.min_bots, 10, 90)
		font.print(self.selected_bots, 40, 90)
		font.print(self.max_bots, 70, 90)
		for key in pairs(self.characters) do
			if self.characters[key] ~= nil then
				font.print(self.characters[key].info.name, 10, 110 + 20 * key)
			end
		end
		

		

		--[[
		for p = 1, #self.player do 
			local player = self.player[p]
			if player.eff_frame ~= nil then
		    	image.draw(self.pick_effect, player.eff_frame, player.x_temp - 77 * player.facing, player.y_pos - 138, player.facing)
		    	if player.eff_frame < #self.pick_effect.sprites then
		    		if player.eff_wait < 0 then
		    			player.eff_frame = player.eff_frame + 1
		    			player.eff_wait = 1
		    		else player.eff_wait = player.eff_wait - 1 end
		    	else
		    	    player.eff_frame = nil
		    	end
			end
			if player.anim ~= nil then
			    if player.anim == 0 then
			    	player.anim = 1
			    	player.x_temp = player.x_pos
			    	player.y_temp = -100
			    	player.y_speed = 30

			    elseif player.anim == 1 then
			    	player.y_temp = player.y_temp + player.y_speed
			    	player.y_speed = player.y_speed * 1.3

			    	image.draw(self.pick_sprite, nil, player.x_temp - 25 * player.facing, player.y_temp - 82, player.facing)
			    	local r, g, b, a = love.graphics.getColor()
			    	love.graphics.setColor(1,1,1,0.2)
			    	image.draw(self.pick_sprite, nil, player.x_temp - 25 * player.facing, player.y_pos * 2 - player.y_temp + 82, -player.facing, -1)
			    	love.graphics.setColor(r, g, b, a)
			    	if player.y_temp >= player.y_pos then
			    		player.anim = 2
			    		player.frame = 1
			    		player.wait = data.characters_list[player.id].animation.wait
			    		player.y_temp = player.y_pos
			    		player.y_speed = 30
			    		player.eff_frame = 1
			    		player.eff_wait = 1
			    	end
			    elseif player.anim == 2 then
			    	local anim = data.characters_list[player.id].animation
			    	image.draw(anim, player.frame, player.x_temp - anim.centerx * player.facing, player.y_temp - anim.centery, player.facing)
			    	local r, g, b, a = love.graphics.getColor()
			    	love.graphics.setColor(1,1,1,0.2)
			    	image.draw(anim, player.frame, player.x_temp - anim.centerx * player.facing, player.y_temp + anim.centery, -player.facing, -1)
					love.graphics.setColor(r, g, b, a)
					if player.name ~= nil then
						font.print(player.name, player.x_temp - 250, player.y_temp - anim.centery - 30, "center", nil, nil, 500)
					end
			    	if player.frame < #anim.sprites then
			    		if player.wait < 0 then
			    			player.frame = player.frame + 1
			    			player.wait = anim.wait
			    		else player.wait = player.wait - 1 end
			    	else
			    		player.frame = 1
			    	    player.anim = 3
			    	    player.wait = data.characters_list[player.id].standing.wait
			    	end
			    elseif player.anim == 3 then
			    	local stand = data.characters_list[player.id].standing
			    	image.draw(stand, player.frame, player.x_temp - stand.centerx * player.facing, player.y_temp - stand.centery, player.facing)
			    	local r, g, b, a = love.graphics.getColor()
			    	love.graphics.setColor(1,1,1,0.2)
			    	image.draw(stand, player.frame, player.x_temp - stand.centerx * player.facing, player.y_temp + stand.centery, -player.facing, -1)
					love.graphics.setColor(r, g, b, a)
					if player.name ~= nil then
						font.print(player.name, player.x_temp - 250, player.y_temp - stand.centery - 30, "center", nil, nil, 500)
					end
			    	if player.frame < #stand.sprites then
			    		if player.wait < 0 then
			    			player.frame = player.frame + 1
			    			player.wait = stand.wait
			    		else player.wait = player.wait - 1 end
			    	else
			    	    player.frame = 1
			    	end
			    elseif player.anim == 4 then
			    	player.y_temp = player.y_temp - player.y_speed
			    	player.y_speed = player.y_speed * 1.2
			    	image.draw(self.pick_sprite, nil, player.x_temp - 25 * player.facing, player.y_temp - 82, player.facing)
			    	local r, g, b, a = love.graphics.getColor()
			    	love.graphics.setColor(1,1,1,0.2)
			    	image.draw(self.pick_sprite, nil, player.x_temp - 25 * player.facing, player.y_pos * 2 - player.y_temp + 82, -player.facing, -1)
			    	love.graphics.setColor(r, g, b, a)
			    	if player.y_temp <= 0 then
			    		player.anim = nil
			    	end
			    end
			end
		end







		for i = 0, self.y - 1 do
			for j = 0, self.x - 1 do 
				local position = i*self.x+j+1
				if data.characters_list[position] ~= nil then
					image.draw(data.characters_list[position].head, nil, j * (data.characters_list[position].head.image:getWidth()) + self.x_pos, i * data.characters_list[position].head.image:getHeight() + self.y_pos)
				else
				    image.draw(self.small, nil, j * (self.small.image:getWidth()) + self.x_pos, i * self.small.image:getHeight() + self.y_pos)
				end
				
				for p = 1, #self.player do 
					if self.player[p].x == j and self.player[p].y == i and self.player[p].activate then
						local r, g, b, a = love.graphics.getColor()
						if self.player[p].character ~= nil then
							love.graphics.setColor(self.player[p].r, self.player[p].g, self.player[p].b, 1)
						else
							love.graphics.setColor(self.player[p].r, self.player[p].g, self.player[p].b , 0.5 + self.light)
						end
						image.draw(self.selector, nil, j * (self.selector.image:getWidth()) + self.x_pos, i * self.selector.image:getHeight() + self.y_pos)
						love.graphics.setColor(r, g, b, a)
					end
				end
			end
		end

		if self.mode == 0 then
			font.print(locale.characters_pick.info1, 0, 100, "center", font.list.character_select_menu, 0, 1280, 1, 1, 1, 0.5 + self.light)
		elseif self.mode == 1 then
			font.print(self.timer, 0, 100, "center", font.list.character_select_menu_time, 0, 1280)
		elseif self.mode == 2 then
			image.draw(self.scrolls.part2, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5, self.scrolls.y_temp, 1, {width = self.scrolls.width_temp / self.scrolls.width, height = 1})
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5 - 10, self.scrolls.y_temp, 1)
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx + self.scrolls.width_temp * 0.5 + 10, self.scrolls.y_temp, -1)
		elseif self.mode == 3 then
			image.draw(self.scrolls.part2, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5, self.scrolls.y_temp, 1, {width = self.scrolls.width_temp / self.scrolls.width, height = 1})
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5 - 10, self.scrolls.y_temp, 1)
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx + self.scrolls.width_temp * 0.5 + 10, self.scrolls.y_temp, -1)
			font.print(locale.characters_pick.bots, 0, 140, "center", font.list.character_select_menu_bots, 0, 1280, 0, 0, 0, 1)
			for i = self.start_bots_count, self.available_number_of_bots do
				font.print(i, 1280 * 0.5 - 50 * (4 + self.start_bots_count) + 50 * i, 195,nil, font.list.character_select_menu,0,nil,0,0,0,1)
				if i == self.selected_number_of_bots then
					image.draw(self.bots_selector, 0, 1280 * 0.5 - 50 * (4 + self.start_bots_count) + 50 * i - 7, 192)
				end
			end
		elseif self.mode == 4 then
			image.draw(self.scrolls.part2, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5, self.scrolls.y_temp, 1, {width = self.scrolls.width_temp / self.scrolls.width, height = 1})
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5 - 10, self.scrolls.y_temp, 1)
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx + self.scrolls.width_temp * 0.5 + 10, self.scrolls.y_temp, -1)
			font.print(locale.characters_pick.info2..self.selected_number_of_bots, 0, 150, "center", font.list.character_select_menu, 0, 1280, 0, 0, 0, 0.5 + self.light)
		elseif self.mode == 5 then
			image.draw(self.scrolls.part2, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5, self.scrolls.y_temp, 1, {width = self.scrolls.width_temp / self.scrolls.width, height = 1})
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx - self.scrolls.width_temp * 0.5 - 10, self.scrolls.y_temp, 1)
			image.draw(self.scrolls.part1, 0, self.scrolls.centerx + self.scrolls.width_temp * 0.5 + 10, self.scrolls.y_temp, -1)
		end]]
	end



	function room:Keypressed(key)

		for i = 1, #settings.controls do 

			if key == settings.controls[i].attack then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active then
						selector.selected = true
						if self.characters[i] == nil then
							local character = {
								x_offset = nil,
								y_offset = nil,
								frame = nil,
								wait = nil,
								anim = nil,
								info = self.char_icons.list[selector.x_pos].character
							}
							self.characters[i] = character
						else
							self.players_timer = self.players_timer - 25
						end
					else
					    selector.active = true
					end
				elseif self.mode == 3 then
					if self.selected_bots > 0 then
						self.selectors.com.active = true
						self.current_bot = 1
						self.mode = 4
					else
					    self.mode = 5
					end
				elseif self.mode == 4 then
					local selector = self.selectors.com
					local character = {
						x_offset = nil,
						y_offset = nil,
						frame = nil,
						wait = nil,
						anim = nil,
						info = self.char_icons.list[selector.x_pos].character
					}
					self.characters[self.max_players + self.current_bot] = character
					self.current_bot = self.current_bot + 1
					if self.current_bot > self.selected_bots then
						self.selectors.com.active = false
						self.mode = 5
					end
				elseif self.mode == 5 then
					
				end
			end

			if key == settings.controls[i].jump then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active then
						if selector.selected then
							selector.selected = false
							self.characters[i] = nil
						else
							selector.active = false
						end
					else
						local exit = true
						for index in pairs(self.selectors) do
							if self.selectors[index].active then exit = false end
						end
						if exit then rooms:Set("main_menu") end
					end
				elseif self.mode == 3 then
					self.max_bots = 0
					self.min_bots = 0
					self.selected_bots = 0
					self.mode = 1
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					selector.selected = false
					self.characters[i] = nil
					selector.active = true
				elseif self.mode == 4 then
					self.current_bot = self.current_bot - 1
					if self.current_bot < 1 then
						self.mode = 2
					else
						self.characters[self.max_players + self.current_bot] = nil
					end
				end
			end

			if key == settings.controls[i].left then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active and not selector.selected then
						selector.x_pos = selector.x_pos - 1
						if selector.x_pos < 1 then
							selector.x_pos = self.char_icons.rows
						end
					end
				elseif self.mode == 3 then
					self.selected_bots = self.selected_bots - 1
					if self.selected_bots < self.min_bots then
						self.selected_bots = self.max_bots
					end
				elseif self.mode == 4 then
					selector = self.selectors.com
					if selector.active and not selector.selected then
						selector.x_pos = selector.x_pos - 1
						if selector.x_pos < 1 then
							selector.x_pos = self.char_icons.rows
						end
					end
				end
			end

			if key == settings.controls[i].right then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active and not selector.selected then
						selector.x_pos = selector.x_pos + 1
						if selector.x_pos > self.char_icons.rows then
							selector.x_pos = 1
						end
					end
				elseif self.mode == 3 then
					self.selected_bots = self.selected_bots + 1
					if self.selected_bots > self.max_bots then
						self.selected_bots = self.min_bots
					end
				elseif self.mode == 4 then
					selector = self.selectors.com
					if selector.active and not selector.selected then
						selector.x_pos = selector.x_pos + 1
						if selector.x_pos > self.char_icons.rows then
							selector.x_pos = 1
						end
					end
				end
			end

			if key == settings.controls[i].up then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active and not selector.selected then
						selector.y_pos = selector.y_pos - 1
						if selector.y_pos < 1 then
							selector.y_pos = self.char_icons.cols
						end
					end
				elseif self.mode == 4 then
					selector = self.selectors.com
					if selector.active and not selector.selected then
						selector.y_pos = selector.y_pos - 1
						if selector.y_pos < 1 then
							selector.y_pos = self.char_icons.cols
						end
					end
				end
			end

			if key == settings.controls[i].down then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active and not selector.selected then
						selector.y_pos = selector.y_pos + 1
						if selector.y_pos > self.char_icons.cols then
							selector.y_pos = 1
						end
					end
				elseif self.mode == 4 then
					selector = self.selectors.com
					if selector.active and not selector.selected then
						selector.y_pos = selector.y_pos + 1
						if selector.y_pos > self.char_icons.cols then
							selector.y_pos = 1
						end
					end
				end
			end
		end
	end
return room