local graphic = {}

	graphic.filter = image.Load("sprites/filter.png")
	graphic.camera = nil
	graphic.camera_settings = {
		owner = nil,
		x = 0,
		x_offset = 50,
		x_speed = 0.15,
		y = 0,
		y_offset = 75,
		y_speed = 0.25,
		scale = 0,
		scale_mod = 1,
		scale_speed = 0.1,
		x1 = 0,
		x2 = 0,
		y1 = 0,
		y2 = 0,
		shaking = 0
	}

	graphic.camera_owner = nil
	graphic.last_fullscreen_mode = settings.window.fullscreen

	graphic.layers = {
		background = love.graphics.newCanvas(1,1),
		foreground = love.graphics.newCanvas(1,1),
		shadows = love.graphics.newCanvas(1,1),
		shadow_filter = love.graphics.newCanvas(1,1),
		reflection = love.graphics.newCanvas(1,1),
		reflections = love.graphics.newCanvas(1,1)
	}

	graphic.objects_for_drawing = {}
	graphic.reflections_for_drawing = {}
	graphic.shadows_for_drawing = {}
	graphic.light_sources = {}
	graphic.reflection_sources = {}


	function graphic:cameraCreate() -- отвечает за создание камеры
	-------------------------------------------------------------------
		local l,t,w,h = camera:getWindow()
		self.camera = gamera.new(0,0,battle.map.head.width, battle.map.head.height)
		self.camera:setWindow(0,0,w,h)
		self.camera_settings.x = battle.map.head.width * 0.5
		self.camera_settings.y = battle.map.head.height * 0.5
		self.camera_settings.scale = self.camera_settings.scale_mod
		self.camera:setScale(settings.window.cameraScale + self.camera_settings.scale + battle.map.head.zoom)
		self.camera:setPosition(self.camera_settings.x, self.camera_settings.y)
		self.last_fullscreen_mode = settings.window.fullscreen
		self:layersCreate(w,h)
	end


	function graphic:cameraUpdate()
		local left = battle.map.head.width
		local right = 0
		local top = battle.map.head.height
		local bottom = 0
		local direction = 0

		if graphic.camera_owner == nil then
			for i in pairs(battle.control.players) do
				local object = battle.control.players[i]
				if object.x > right then right = object.x end
				if object.x < left then left = object.x end
				if battle.map.head.border_up + object.z - object.y > bottom then bottom = battle.map.head.border_up + object.z - object.y end
				if battle.map.head.border_up + object.z - object.y < top then top = battle.map.head.border_up + object.z - object.y end
				direction = direction + object.facing
			end
		else
			left = object.x
			right = object.x
			top = battle.map.head.border_up + object.z - object.y
			bottom = battle.map.head.border_up + object.z - object.y
			direction = object.facing
		end

		local x_offset = 0
		if direction > 0 then
			x_offset = self.camera_settings.x_offset
		elseif direction < 0 then
			x_offset = -self.camera_settings.x_offset
		end
		
		local camera_x = (right + left) * 0.5 + x_offset
		local camera_y = (top + bottom) * 0.5 - self.camera_settings.y_offset
 
		self.camera_settings.scale = 1 - math.sqrt((right - left)^2 + (top - bottom)^2) * 0.001

		if self.camera_settings.scale < 0 then self.camera_settings.scale = 0
		elseif self.camera_settings.scale > 1 then self.camera_settings.scale = 1 end

		self.camera:setScale(settings.window.cameraScale + self.camera_settings.scale + battle.map.head.zoom)

		self.camera_settings.x = self.camera_settings.x - (self.camera_settings.x - camera_x) * self.camera_settings.x_speed
		self.camera_settings.y = self.camera_settings.y - (self.camera_settings.y - camera_y) * self.camera_settings.y_speed
		self.camera:setPosition(self.camera_settings.x, self.camera_settings.y)

		local l,t,w,h = graphic.camera:getVisible()

		self.camera_settings.x1 = l
		self.camera_settings.x2 = l+w
		self.camera_settings.y1 = t
		self.camera_settings.y2 = t+h

		if self.last_fullscreen_mode ~= settings.window.fullscreen then self:cameraCreate() end
	end


	function graphic:clear()
		self.reflections_for_drawing = {}
		self.objects_for_drawing = {}
		self.shadows_for_drawing = {}
		self.light_sources = {}
		self.reflection_sources = {}
		self:layersClear()
	end


	function graphic:layersCreate(w,h)
		for i in pairs(self.layers) do
			self.layers[i] = love.graphics.newCanvas(w,h)
		end
	end

	function graphic:layersClear()
		for i in pairs(self.layers) do
			love.graphics.setCanvas(self.layers[i])
			love.graphics.clear()
		end
		love.graphics.setCanvas()
	end

	function graphic:layersDraw()
		local x,y = 0,0
		if self.camera_settings.shaking > 0 then
			if self.camera_settings.shaking % 4 == 0 then x = self.camera_settings.shaking
			elseif self.camera_settings.shaking % 2 == 0 then x = -self.camera_settings.shaking end
			if self.camera_settings.shaking % 6 == 0 then y = self.camera_settings.shaking
			elseif self.camera_settings.shaking % 3 == 0 then y = -self.camera_settings.shaking end
			self.camera_settings.shaking = self.camera_settings.shaking - 1
		end
		love.graphics.draw(self.layers.background,0+x,0+y)
		love.graphics.draw(self.layers.foreground,0+x,0+y)
		if settings.quality then
			love.graphics.setBlendMode( "multiply", "premultiplied" )
			love.graphics.draw(self.layers.shadow_filter,0+x,0+y)
			love.graphics.setBlendMode( "alpha" )
		end
	end


	function graphic:mapDraw()
		if battle.map ~= nil then
			local map = battle.map
			love.graphics.setCanvas(self.layers.background)
			for layer_id = 1, #map.layers do
				local layer = map.layers[layer_id]
				if settings.quality or layer.important then
					if (layer.y <= self.camera_settings.y2) and ((layer.y + layer.h) >= self.camera_settings.y1) then
						if (layer.x <= self.camera_settings.x2) and ((layer.x + layer.w) >= self.camera_settings.x1) then
							self.camera:draw(function(l,t,w,h)
								if not settings.quality or not layer.reflection then
									image.draw(layer.sprite,nil, layer.x, layer.y)
								else
									love.graphics.setCanvas(self.layers.reflection)
									image.draw(layer.sprite,nil, layer.x, layer.y)
									love.graphics.setCanvas(self.layers.background)
								end
							end)
						end
					end
				end
			end
			love.graphics.setCanvas(self.layers.foreground)
			for filter_id = 1, #map.filters do
				local filter = map.filters[filter_id]
				if settings.quality or filter.important then
					if (filter.y <= self.camera_settings.y2) and ((filter.y + filter.h) >= self.camera_settings.y1) then
						if (filter.x <= self.camera_settings.x2) and ((filter.x + filter.w) >= self.camera_settings.x1) then
							self.camera:draw(function(l,t,w,h)
								image.draw(filter.sprite,nil, filter.x, filter.y)
							end)
						end
					end
				end
			end
			love.graphics.setCanvas()
		end
	end


	function graphic:drawPreparationObject()
		local pic = self.frame.pic
		if pic > 0 and pic <= self.sprites.count and self.invisibility == 0 then
			for i = 1, #self.sprites do
				if pic <= #self.sprites[i].file.sprites then
					local y = battle.map.head.border_up - self.y + self.z - self.frame.centery
					if (y <= battle.graphic.camera_settings.y2) and (y + self.sprites[i].file.h >= battle.graphic.camera_settings.y1) then
						local x = self.x - (self.frame.centerx * self.facing)
						if self.shaking > 0 then
							if self.shaking % 2 == 1 then x = x + 2
							else x = x - 2 end
						end
						if get.Biggest(x + (self.sprites[i].file.w * self.facing), x) >= battle.graphic.camera_settings.x1
						and get.Least(x + (self.sprites[i].file.w * self.facing), x) <= battle.graphic.camera_settings.x2 then
							if self.index == nil then self.index = self.z end
							local object_to_draw = {
								x = x, y = y,
								real_x = self.x, real_y = self.y, real_z = self.z,
								centerx = self.frame.centerx,
								centery = self.frame.centery,
								sprite = self.sprites[i].file, pic = pic,
								facing = self.facing,
								index = self.index,
								reflection = self.reflection,
								reflection_source = self.head.reflection
							}
							table.insert(graphic.objects_for_drawing,object_to_draw)
							if battle.map.head.shadow and self.shadow then
								local shadow_to_draw = {
									x = self.x, y = self.y, z = self.z,
									sprite = self.sprites[i].file, pic = pic,
									facing = self.facing,
									centerx = self.frame.centerx,
									centery = self.frame.centery,
									shadow_sprite = self.head.shadow_sprite,
									shadow_centerx = self.head.shadow_centerx,
									shadow_centery = self.head.shadow_centery
								}
								table.insert(graphic.shadows_for_drawing,shadow_to_draw)
							end
						end
					end
					return true
				else
					pic = pic - #self.sprites[i].file.sprites
				end
			end
		end
	end

	function graphic:drawPreparationEffect()
		local pic = self.frame.pic
		if pic > 0 and pic <= self.sprites.count and self.invisibility == 0 then
			for i = 1, #self.sprites do
				if pic <= #self.sprites[i].file.sprites then
					local y = battle.map.head.border_up - self.y + self.z - self.frame.centery
					if (y <= battle.graphic.camera_settings.y2) and (y + self.sprites[i].file.h >= battle.graphic.camera_settings.y1) then
						local x = self.x - (self.frame.centerx * self.facing)
						if get.Biggest(x + (self.sprites[i].file.w * self.facing), x) >= battle.graphic.camera_settings.x1
						and get.Least(x + (self.sprites[i].file.w * self.facing), x) <= battle.graphic.camera_settings.x2 then
							if self.index == nil then self.index = self.z end
							local object_to_draw = {
								x = x, y = y,
								real_x = self.x, real_y = self.y, real_z = self.z,
								centerx = self.frame.centerx,
								centery = self.frame.centery,
								sprite = self.sprites[i].file, pic = pic,
								facing = self.facing,
								index = self.index,
								reflection_source = self.head.reflection,
								reflection = false
							}
							table.insert(graphic.objects_for_drawing,object_to_draw)
						end
					end
					return true
				else
					pic = pic - #self.sprites[i].file.sprites
				end
			end
		end
	end


	function graphic:sortObjects()
		for i = 1, #self.objects_for_drawing do
			for j = i + 1, #self.objects_for_drawing do
				if self.objects_for_drawing[i].index > self.objects_for_drawing[j].index then
					local temp = self.objects_for_drawing[i]
					self.objects_for_drawing[i] = self.objects_for_drawing[j]
					self.objects_for_drawing[j] = temp
				end
			end
			if settings.quality then
				if self.objects_for_drawing[i].reflection_source then
					table.insert(self.reflection_sources, self.objects_for_drawing[i])
				end
				if self.objects_for_drawing[i].reflection then
					table.insert(self.reflections_for_drawing, self.objects_for_drawing[i])
				end
			end
		end
	end


	function graphic:drawObjects()
		love.graphics.setCanvas(self.layers.background)
		self.camera:draw(function(l,t,w,h)
			for i = 1, #self.objects_for_drawing do
				local object = self.objects_for_drawing[i]
				if not settings.quality or not object.reflection_source then
					image.draw(object.sprite,object.pic,object.x,object.y,object.facing)
				end
			end
		end)
		love.graphics.setCanvas()
	end


	function graphic:drawShadows()
		love.graphics.setCanvas(self.layers.shadows)
		for i = 1, #battle.map.lights do
			table.insert(graphic.light_sources, battle.map.lights[i])
		end
		self.camera:draw(function(l,t,w,h)
			for i = 1, #graphic.shadows_for_drawing do
				local object = graphic.shadows_for_drawing[i]
				if settings.quality then
					for j = 1, #graphic.light_sources do
						local light = self.light_sources[j]
						if light.s then
							local distance = math.sqrt((object.x - light.x)^2+(object.y - light.y)^2+(object.z - light.z)^2)

							if distance < light.r then
								
								local shadow_direction_z = get.sign(((object.z - light.z) / light.r))
								local scale_y = (object.z - light.z)/light.r

								local direction = (((object.x - light.x) / light.r) * -object.facing)
								local opacity = light.f - distance/light.r - object.y * 0.001
								
								image.draw(object.sprite, object.pic,
									object.x, battle.map.head.border_up + object.y * 0.1 + object.z, object.facing,
									{width = 1, height = -scale_y}, 0,0,0,opacity,
									{ox = object.centerx, oy = object.centery, kx = direction})

							end
						end
					end
				else
					if #graphic.light_sources > 0 then
						if object.shadow_sprite ~= nil then
						elseif battle.map.shadow_sprite ~= nil then
							
							image.draw(battle.map.shadow_sprite,0,
								object.x,battle.map.head.border_up + object.z, object.facing,
								{width = 1 - object.y * 0.0020, height = 1 - object.y * 0.0020}, 1,1,1,1 - object.y * 0.0020,
								{ox = battle.map.shadow_centerx, oy = battle.map.shadow_centery})
						
						end
					end
				end
			end
		end)
		love.graphics.setCanvas(self.layers.background)
		love.graphics.draw(self.layers.shadows,0,0)
		love.graphics.setCanvas()
	end

	function graphic:drawReflections()
		if settings.quality then

			love.graphics.setCanvas(self.layers.reflections)
			self.camera:draw(function(l,t,w,h)
				for i = 1, #self.reflections_for_drawing do
					local object = self.reflections_for_drawing[i]
					image.draw(object.sprite,object.pic,object.real_x,battle.map.head.border_up + object.real_z + object.real_y * 0.5,object.facing,
						{width = 1, height = -0.9}, 1,1,1,1,
						{ox = object.centerx, oy = object.centery})
				end
			end)

			love.graphics.setCanvas(self.layers.reflection)
			self.camera:draw(function(l,t,w,h)
				for i = 1, #self.reflection_sources do
					local object = self.reflection_sources[i]
					image.draw(object.sprite,object.pic,object.x,object.y,object.facing)
				end
			end)
			love.graphics.setBlendMode( "add", "alphamultiply" )
			love.graphics.setColor(1,1,1,0.25)
			love.graphics.draw(self.layers.reflections,0,0)
			love.graphics.setColor(1,1,1,1)
			love.graphics.setBlendMode( "alpha" )

			love.graphics.setCanvas(self.layers.background)
			love.graphics.draw(self.layers.reflection,0,0)
			love.graphics.setCanvas()
		end
	end

	function graphic:shadowFilter()
		if settings.quality then
			love.graphics.setCanvas(self.layers.shadow_filter)
				love.graphics.setColor(1,1,1,0.15)
				love.graphics.rectangle("fill",0,0,self.layers.shadow_filter:getWidth(),self.layers.shadow_filter:getHeight())
				love.graphics.setColor(1,1,1,1)
				self.camera:draw(function(l,t,w,h)
					for i = 1, #graphic.light_sources do
						local light = graphic.light_sources[i]
						image.draw(battle.res.light_filter, nil, light.x, battle.map.head.border_up - light.y + light.z, 0,
							{width = light.r/150, height = light.r/150}, 1,1,1,light.f, {ox = 150, oy = 150})
					end
				end)
			love.graphics.setCanvas()
		end
	end

	function graphic:addLightSourse(x,y,z,r,f,s)
		if settings.quality then
			local light = {
				x = x,
				y = y,
				z = z,
				r = r,
				f = f,
				s = s
			}
			table.insert(graphic.light_sources,light)
		end
	end

return graphic
