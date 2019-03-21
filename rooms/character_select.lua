local room = {}
	
	room.selected_map = 1
	room.selected_players = 0

	function room:AddCharacter(Cinfo, Cselector)
		for i = 1, self.max_players do
			if self.characters[i] == nil and Cinfo ~= nil then
				local character = {
					frame = 1,
					wait = 0,
					anim = 0,
					info = Cinfo,
					name = Cselector.text,
					id = Cselector.id,
					controller = Cselector.controller,
					sprite = nil,
					h = -500,
					s = 5,
				}

				if i%2 == 1 then
					character.x = self.characters_positions.x + ((self.characters_positions.w / (self.max_players + 2)) * math.floor(i/2)) + math.random(-self.characters_positions.r, self.characters_positions.r)
					character.facing = 1
				else
					character.x = self.characters_positions.w - ((self.characters_positions.w / (self.max_players + 2)) * math.floor(i/2)) + math.random(-self.characters_positions.r, self.characters_positions.r)
					character.facing = -1
				end

				if math.floor(i/2)%2 == 1 then
					character.y = self.characters_positions.y + self.characters_positions.h/2 + math.random(-self.characters_positions.r, self.characters_positions.r)
				else
				    character.y = self.characters_positions.y - self.characters_positions.h/2 + math.random(-self.characters_positions.r, self.characters_positions.r)
				end

				self.characters[i] = character
				return true
			end
		end
		return false
	end

	function room:DeleteCharacter(selector)
		for i = self.max_players, 1, -1 do
			if self.characters[i] ~= nil and self.characters[i].id == selector.id then
				self.characters[self.max_players + i] = self.characters[i]
				self.characters[self.max_players + i].anim = 3
				self.characters[self.max_players + i].s = self.characters[self.max_players + i].s * 0.5
				self.characters[i] = nil
				return true
			end
		end
		return false
	end

	function room:DrawEffects()
		for i = 1, self.max_players * 2 do
			if self.effects[i] ~= nil then
				local effect = self.effects[i]
				image.draw(effect.sprite, effect.frame, effect.x - effect.centerx, effect.y - effect.centery)
			end
		end
	end

	function room:EffectsAnimations()
		for i = 1, self.max_players * 2 do
			if self.effects[i] ~= nil then
				local effect = self.effects[i]
				if effect.wait > effect.wait_max then
					effect.frame = effect.frame + 1
					effect.wait = 0
					if effect.frame > effect.frame_max then
						self.effects[i] = nil
					end
				else
					effect.wait = effect.wait + 1
				end
			end
		end
	end

	function room:AddEffect(x,y)
		for i = 1, self.max_players * 2 do
			if self.effects[i] == nil then
				local effect = {
					frame = 1,
					frame_max = 21,
					wait = 0,
					wait_max = 0,
					sprite = self.pick_effect,
					x = x,
					y = y,
					centerx = 77,
					centery = 137
				}
				self.effects[i] = effect
				return true
			end
		end
		return false
	end

	function room:CreateLoadingList()
		local loading_List = {
			entities = {},
			maps = {},
			music = {}
		}
		for i = 1, self.max_players do
			if self.characters[i] ~= nil then
				local character = {
					id = self.characters[i].info.id,
					controller = self.characters[i].controller
				}
				table.insert(loading_List.entities,character)
			end
		end
		table.insert(loading_List.maps,data.maps_list[room.selected_map].id)
		return loading_List
	end



	function room:DrawCharacters()
		for i = 1, self.max_players * 2 do
			if self.characters[i] ~= nil then
				local character = self.characters[i]
				local centerx = character.sprite.centerx
				local centery = character.sprite.centery
				if centerx == nil then centerx = 25 end
				if centery == nil then centery = 78 end
				image.draw(character.sprite, character.frame, character.x - centerx * character.facing, character.h - centery, character.facing)
				image.draw(character.sprite, character.frame, character.x - centerx * character.facing, character.y + (character.y - character.h) + centery, character.facing, {width = 1, height = -1},nil,nil,nil,0.2)
				font.print(character.name, character.x - 150, character.h - centery - 25, "center", nil, nil, 300, 1, 1, 1, 1)
			end
		end
	end

	function room:CharacterAnimations()
		for i = 1, self.max_players * 2 do
			if self.characters[i] ~= nil then
				local character = self.characters[i]
				if character.anim == 0 then
					character.sprite = self.pick_sprite
					character.h = character.h + character.s
					character.s = character.s * 1.2
					character.frame = 0
					if character.h >= character.y then
						character.h = character.y
						character.anim = 1
						character.frame = 1
						character.wait = 0
						character.sprite = character.info.animation
						self:AddEffect(character.x,character.y)
					end
				elseif character.anim == 1 then
					if character.wait > character.info.animation.wait then
						character.wait = 0
						character.frame = character.frame + 1
						if character.frame > character.info.animation.frames then
							character.frame = 1
							character.wait = 0
							character.anim = 2
							character.sprite = character.info.standing
						end
					else
						character.wait = character.wait + 1
					end
				elseif character.anim == 2 then
					if character.wait > character.info.standing.wait then
						character.wait = 0
						character.frame = character.frame + 1
						if character.frame > character.info.standing.frames then
							character.frame = 1
							character.wait = 0
						end
					else
						character.wait = character.wait + 1
					end
				elseif character.anim == 3 then
				    character.sprite = self.pick_sprite
				    character.h = character.h - character.s
					character.frame = 0
				    if character.h < -500 then
				    	self.characters[i] = nil
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
				id = 1, text = "P1", align = "top", controller = 1,
				color = { r = 1, g = 0.7, b = 0.7, a_mod = 0, a_change = 0.01, a_mod_max = 0.3 },
				active = false, selected = false,
				x_pos = 1, y_pos = 1,
			},
			player_2 = {
				id = 2, text = "P2", align = "bot", controller = 2,
				color = { r = 0.7, g = 0.7, b = 1, a_mod = 0, a_change = 0.01, a_mod_max = 0.3 },
				active = false, selected = false,
				x_pos = self.char_icons.rows, y_pos = 1
			},
			com = {
				id = 0, text = "Com", align = "top", controller = 0,
				color = { r = 1, g = 1, b = 1, a_mod = 0, a_change = 0.01, a_mod_max = 0.3 },
				active = false, selected = false,
				x_pos = 1, y_pos = 1
			}
		}
	end



	function room:CreateCharactersIcons()
		self.char_icons = {
			margin = -3, x_pos = 640, y_pos = 640,
			rows = 5, cols = 1, list = {}
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
		self.pick_sprite = image.Load("sprites/UI/char_pick.png")
		local eff_c = {
			w = 150,
			h = 150,
			x = 3,
			y = 7
		}
		self.pick_effect = image.Load("sprites/UI/char_pick2.png",eff_c)

		self:CreateCharactersIcons()
		self:SelectorSettings()

		self.characters = {}

		self.mode = 0
		--[[
			0 -- вход в комнату
			1 -- Ожидание игроков
		]]
		self.players_timer = 0
		self.selected_mode = 1

		self.max_players = 10
		self.min_players = 2

		self.max_bots = 0
		self.min_bots = 0
		self.selected_bots = 0

		self.current_bot = 0

		self.loading_list = {
			characters = {},
			maps = {}
		}

		self.characters_positions = {
			x = 150,
			w = 1250,
			y = 520,
			h = 70,
			r = 25
		}

		self.effects = {}

		self.opacity_effect = 1
		self.opacity_speed = 0.01

		self.bots_scroll = {
			border = image.Load("sprites/UI/scroll1.png"),
			background = image.Load("sprites/UI/scroll2.png"),
			x = settings.gameWidth / 2,
			y = 300,
			width = 608,
			frames = 10,
			temp_x = 0,
			temp_y = 0,
			temp_width = 0,
			temp_frame = 0
		}

		self.bots_selector = image.Load("sprites/UI/bots_selector.png")

		self.mode_list = {}

		self.mode_list_x = 340
		self.mode_list_y = 70

		local mode = {}
		mode.name = locale.characters_pick.mode1
		mode.image_0 = image.Load("sprites/UI/CharSelectMenu/" .. "1-0.png")
		mode.image_1 = image.Load("sprites/UI/CharSelectMenu/" .. "1-1.png")
		function mode:action()
			rooms:Set("loading",room:CreateLoadingList())
		end
		table.insert(self.mode_list, mode)
		
		local mode = {}
		mode.name = locale.characters_pick.mode4
		mode.image_0 = image.Load("sprites/UI/CharSelectMenu/" .. "3-0.png")
		mode.image_1 = image.Load("sprites/UI/CharSelectMenu/" .. "3-1.png")
		function mode:action()

		end
		table.insert(self.mode_list, mode)
		
		local mode = {}
		mode.name = locale.characters_pick.mode5
		mode.image_0 = image.Load("sprites/UI/CharSelectMenu/" .. "4-0.png")
		mode.image_1 = image.Load("sprites/UI/CharSelectMenu/" .. "4-1.png")
		function mode:action()

		end
		table.insert(self.mode_list, mode)
		
		local mode = {}
		mode.name = locale.characters_pick.mode2..locale.maps[data.maps_list[room.selected_map].id]
		mode.image_0 = data.maps_list[self.selected_map].preview_0
		mode.image_1 = data.maps_list[self.selected_map].preview_1
		function mode:action()
			room.selected_map = room.selected_map + 1
			if room.selected_map > #data.maps_list then
				room.selected_map = 1
			end
			self.name = locale.characters_pick.mode2..locale.maps[data.maps_list[room.selected_map].id]
			self.image_0 = data.maps_list[room.selected_map].preview_0
			self.image_1 = data.maps_list[room.selected_map].preview_1
		end
		table.insert(self.mode_list, mode)

		local mode = {}
		mode.name = locale.characters_pick.mode3
		mode.image_0 = image.Load("sprites/UI/CharSelectMenu/" .. "2-0.png")
		mode.image_1 = image.Load("sprites/UI/CharSelectMenu/" .. "2-1.png")
		function mode:action()
			rooms:Set("main_menu")
		end
		table.insert(self.mode_list, mode)
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
					self.bots_scroll.temp_frame = 0
					self.bots_scroll.temp_y = 0
					self.mode = 2
				else
				    self.players_timer = self.players_timer - 1
				end
			else
				self.players_timer = 200
			end
		elseif self.mode == 2 then
			if self.bots_scroll.temp_frame < self.bots_scroll.frames then
				if self.bots_scroll.temp_y < self.bots_scroll.y then
					self.bots_scroll.temp_y = self.bots_scroll.temp_y + 25
				else
					self.bots_scroll.temp_frame = self.bots_scroll.temp_frame + 1
				end
			else
				for key in pairs(self.selectors) do
					self.selectors[key].active = false
				end
				self.max_bots = self.max_players - self.selected_players
				self.min_bots = self.min_players - self.selected_players
				if self.selected_bots < self.min_bots then
					self.selected_bots = self.min_bots
				end
				self.mode = 3
			end
		elseif self.mode == 5 then
			if self.modes_opacity > 1 then
				self.mode = 6
			else
				self.modes_opacity = self.modes_opacity + 0.05
			end
		end
		self.opacity_effect = self.opacity_effect + self.opacity_speed
		if self.opacity_effect < 0.5 or self.opacity_effect > 1 then
			self.opacity_speed = -self.opacity_speed
		end
		self:CharacterAnimations()
		self:EffectsAnimations()
	end



	function room:Draw()
		image.draw(self.background, nil, 0, 0)
		self:DrawCharacters()
		self:DrawEffects()
		image.draw(self.foreground, nil, 0, 0)
		image.draw(self.stand, nil, 0, 0)
		self:DrawCharactersIcons()
		self:DrawSelectors()
		if self.mode == 1 then
			if self.players_timer < 200 then
				font.print(math.ceil(self.players_timer / 50), 0, 120, "center", font.list.character_select_menu_time, nil, 1280, nil, nil, nil, nil)
			else
				font.print(locale.characters_pick.info1, 100, 100, "center", font.list.character_select_menu, nil, 1080, nil, nil, nil, self.opacity_effect)
			end
		elseif self.mode == 2 or self.mode == 3 or self.mode == 4 or self.mode == 5 or self.mode == 6 then
			local scroll = self.bots_scroll
			image.draw(scroll.background,nil, scroll.x - (((scroll.width / scroll.frames) * scroll.temp_frame) / 2), scroll.temp_y - scroll.border.h, 1, {width=(((scroll.width / scroll.frames) * scroll.temp_frame) / scroll.background.w), height=1})
			image.draw(scroll.border,nil, scroll.x + ((scroll.width * 0.5) / scroll.frames) * scroll.temp_frame, scroll.temp_y - scroll.border.h)
			image.draw(scroll.border,nil, scroll.x - ((scroll.width * 0.5) / scroll.frames) * scroll.temp_frame - scroll.border.w, scroll.temp_y - scroll.border.h)
			if self.mode == 3 then
				font.print(locale.characters_pick.bots, settings.gameWidth/2 - 300, 130, "center", font.list.character_select_menu_bots, nil, 600, 0, 0, 0, self.opacity_effect + 0.1)
				local x = 0
				for i = self.min_bots, self.max_bots do
					x = x + 1
					font.print(i, settings.gameWidth/2 - 300 + 60 * x - 16, 183, "center", font.list.character_select_menu_bots, nil, 30, 0, 0, 0, 1)
					if i == self.selected_bots then
						image.draw(self.bots_selector, 0, settings.gameWidth/2 - 300 + 60 * x - 16, 180)
					end
				end
			elseif self.mode == 4 then
				font.print(locale.characters_pick.info2..self.selected_bots-self.current_bot+1, settings.gameWidth/2 - 300, 140, "center", font.list.character_select_menu_bots, nil, 600, 0, 0, 0, self.opacity_effect + 0.1)
			elseif self.mode == 5 or self.mode == 6 then
				for i = 1, #self.mode_list do
					if self.selected_mode == i then
						image.draw(self.mode_list[i].image_1, 0, self.mode_list_x + 120 * (i-1), self.mode_list_y,nil,nil,nil,nil,nil,self.modes_opacity)
						font.print(self.mode_list[i].name, 0, 290, "center", font.list.character_select_mode_select, nil, settings.gameWidth, 1, 1, 1, self.opacity_effect + 0.1)
					else
						image.draw(self.mode_list[i].image_0, 0, self.mode_list_x + 120 * (i-1), self.mode_list_y,nil,nil,nil,nil,nil,self.modes_opacity)
					end
				end
			end
		end
	end



	function room:Keypressed(key)

		if key == "escape" then
			rooms:Set("main_menu")
		end

		for i = 1, #settings.controls do 

			if key == settings.controls[i].attack then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active then
						if not selector.selected and self:AddCharacter(self.char_icons.list[selector.x_pos].character,selector) then
							selector.selected = true
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
						self.modes_opacity = 0
					    self.mode = 5
					end
				elseif self.mode == 4 then
					local selector = self.selectors.com
					if self:AddCharacter(self.char_icons.list[selector.x_pos].character,selector) then
						self.current_bot = self.current_bot + 1
						if self.current_bot > self.selected_bots then
							self.selectors.com.active = false
							self.modes_opacity = 0
							self.mode = 5
						end
					end
				elseif self.mode == 6 then
					if self.mode_list[self.selected_mode].action ~= nil then
						self.mode_list[self.selected_mode]:action()
					end
				end
			end

			if key == settings.controls[i].jump then
				if self.mode == 1 then
					local selector = nil
					if i == 1 then selector = self.selectors.player_1
					elseif i == 2 then selector = self.selectors.player_2 end
					if selector.active then
						if selector.selected then
							if self:DeleteCharacter(selector) then
								selector.selected = false
							end
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
					if self.selectors.player_1.selected then
						self.selectors.player_1.active = true
						self.selectors.player_1.selected = false
						self:DeleteCharacter(self.selectors.player_1)
					end
					if self.selectors.player_2.selected then
						self.selectors.player_2.active = true
						self.selectors.player_2.selected = false
						self:DeleteCharacter(self.selectors.player_2)
					end
					self.mode = 1
				elseif self.mode == 4 then
					if self.current_bot > 1 and self:DeleteCharacter(selector) then
						self.current_bot = self.current_bot - 1
					else
					    self.mode = 2
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
				elseif self.mode == 6 then
					self.selected_mode = self.selected_mode - 1
					if self.selected_mode < 1 then self.selected_mode = #self.mode_list end
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
				elseif self.mode == 6 then
					self.selected_mode = self.selected_mode + 1
					if self.selected_mode > #self.mode_list then self.selected_mode = 1 end
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
				elseif self.mode == 5 then
				end
			end
		end
	end
return room