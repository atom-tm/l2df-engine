local room = {}

	function room:LoadingSpriteAnimation()
		local load = self.loading_sprite
		if load.wait > load.max_wait then
			load.wait = 0
			load.frame = load.frame + 1
			if load.frame > #load.image.sprites then
				load.frame = 1
			end
		else
		    load.wait = load.wait + 1
		end
	end

	function room:load(loadingList)
		self.loading_list = loadingList
		self.mode = 0

		self.background_image = image.Load("sprites/UI/background.png", nil, "linear")
		local loading_sprite = {
			w = 140,
			h = 140,
			x = 4,
			y = 3
		}
		self.loading_sprite = {
			image = image.Load("sprites/UI/loading.png",loading_sprite),
			frame = 1,
			wait = 0,
			max_wait = 1
		}
	end

	function room:update()
		self:LoadingSpriteAnimation()
		if self.mode == 0 then -- Очистка памяти
			resources.Clear()
			self.mode = 1 -- Занесение в список загрузки изначальных персонажей
		elseif self.mode == 1 then
			for i = 1, #self.loading_list.entities do
				resources.AddToLoading(self.loading_list.entities[i].id, "entity")
			end
			for key, id in pairs(data.system) do
				resources.AddToLoading(id, "entity")
			end
			for i = 1, #self.loading_list.maps do
				resources.AddToLoading(self.loading_list.maps[i], "map")
			end
			self.mode = 2
		elseif self.mode == 2 then
			if resources.MapLoading() then
				self.mode = 3
			end
		elseif self.mode == 3 then
			if resources.EntityLoading() then
				self.mode = 4
			end
		elseif self.mode == 4 then
			rooms:Set("battle", self.loading_list)
		end
	end

	function room:draw()
		image.draw(self.background_image,0,0,0)
		image.draw(self.loading_sprite.image,self.loading_sprite.frame,1120,570)
		--[[
		font.print(self.mode, 10, 10)
		font.print(#self.loading_list.entities, 10, 30)
		font.print(#resources.loading_list.entities, 10, 50)
		font.print(#resources.loading_list.maps, 50, 50)
		local i = 1
		for key in pairs(resources.entities) do
			font.print(key, 10, 50 + i * 20)
			font.print(resources.entities[key].head.name, 50, 50 + i * 20)
			font.print(resources.entities[key].head.jump_height, 150, 50 + i * 20)
			font.print(resources.entities[key].sprites.count, 250, 50 + i * 20)
			font.print(#resources.entities[key].sprites, 300, 50 + i * 20)
			if resources.entities[key].frames[5] ~= nil then
				font.print(resources.entities[key].frames[5].centerx, 380, 50 + i * 20)
				font.print(#resources.entities[key].frames[5].states, 410, 50 + i * 20)
				font.print(#resources.entities[key].frames[5].bodys, 430, 50 + i * 20)
				font.print(#resources.entities[key].frames[5].itrs, 450, 50 + i * 20)
				font.print(resources.entities[key].frames[5].bodys.radius, 480, 50 + i * 20)
				font.print(resources.entities[key].frames[5].itrs.radius, 520, 50 + i * 20)
			end
			local f = 0
			for key in pairs(resources.entities[key].frames) do
				f = f+1
			end
			font.print(f, 350, 50 + i * 20)
			i = i + 1
		end
		local j = 0
		for key in pairs(image.list) do
			j = j + 1
		end
		font.print(j, 10, 150)

		for key in pairs(resources.maps) do
			font.print(key, 10, 400 + i * 20)
			font.print(resources.maps[key].head.name, 50, 400 + i * 20)
			font.print(resources.maps[key].head.width, 150, 400 + i * 20)
		end]]
	end

return room