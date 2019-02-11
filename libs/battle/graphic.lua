local graphic = {}

	graphic.objects_for_drawing = {} -- объекты для отрисовки

	graphic.camera = nil
	graphic.camera_settings = {
		owner = nil,
		x = 0,
		x_offset = 50,
		x_speed = 0.15,
		y = 0,
		y_offset = 50,
		y_speed = 0.1,
		scale = 0,
		scale_mod = 1,
		scale_speed = 0.1
	}
	graphic.camera_owner = nil
	graphic.last_fullscreen_mode = settings.window.fullscreen

	function graphic:cameraCreate() -- отвечает за создание камеры
	-------------------------------------------------------------------
		local l,t,w,h = camera:getWindow()
		self.camera = gamera.new(0,0,battle.map.head.width, battle.map.head.height)
		self.camera:setWindow(0,0,w,h)
		self.camera_settings.x = battle.map.head.width * 0.5
		self.camera_settings.y = battle.map.head.height * 0.5
		self.camera_settings.scale = 0
		self.camera:setScale(settings.window.cameraScale + self.camera_settings.scale)
		self.camera:setPosition(self.camera_settings.x, self.camera_settings.y)
		self.last_fullscreen_mode = settings.window.fullscreen
	end



	function graphic:cameraUpdate()
		local left = battle.map.head.width
		local right = 0
		local top = battle.map.head.height
		local bottom = 0
		if graphic.camera_owner == nil then
			for i in pairs(battle.control.players) do
				local object = battle.control.players[i]
				if object.x > right then right = object.x end
				if object.x < left then left = object.x end
				if battle.map.head.border_up + object.z - object.y > bottom then bottom = battle.map.head.border_up + object.z - object.y end
				if battle.map.head.border_up + object.z - object.y < top then top = battle.map.head.border_up + object.z - object.y end
			end
		else
			left = object.x
			right = object.x
			top = battle.map.head.border_up + object.z - object.y
			bottom = battle.map.head.border_up + object.z - object.y
		end

		self.camera_settings.x = (right + left) * 0.5
		self.camera_settings.y = (top + bottom) * 0.5
		graphic.camera:setPosition(self.camera_settings.x, self.camera_settings.y)
		if self.last_fullscreen_mode ~= settings.window.fullscreen then self:cameraCreate() end










		--[[
		local x_target, y_target, scale_target
		local x_speed, y_speed, scale_speed

		if #battle.control.players == 1 and graphic.camera_settings.target == nil then
			local player = battle.control.players[]
			





			local owner = battle.control.players[1]
			x_target = owner.x + (graphic.camera_settings.x_offset * owner.facing)
			y_target = battle.map.head.border_up + owner.z - owner.y + graphic.camera_settings.y_offset
		elseif #battle.control.players > 1 and graphic.camera_settings.target == nil then
			local x_min, x_max, y_max, y_min, z_min, z_max
			for key in pairs(battle.control.players) do
				local owner = battle.control.players[key]
				if x_min == nil then x_min = owner.x
				elseif x_min > owner.x then x_min = owner.x end 
				if x_max == nil then x_max = owner.x
				elseif x_max < owner.x then x_max = owner.x end
				if y_max == nil then y_max = owner.y
				elseif y_max < owner.y then y_max = owner.y end
				if y_min == nil then y_min = owner.y
				elseif y_min > owner.y then y_min = owner.y end
				if z_min == nil then z_min = owner.z
				elseif z_min > owner.z then z_min = owner.z end
				if z_max == nil then z_max = owner.z
				elseif z_max < owner.z then z_max = owner.z end
			end
			x_target = (x_min + x_max) * 0.5
			y_target = battle.map.head.border_up - (y_max + y_min) * 0.5 + (z_max + z_min) * 0.5
		elseif graphic.camera_settings.target ~= nil then
			local owner = battle.control.players[1]
			x_target = owner.x + (graphic.camera_settings.x_offset * owner.facing)
			y_target = battle.map.head.border_up + owner.z - owner.y + graphic.camera_settings.y_offset
		end

		x_speed = (x_target - graphic.camera_settings.x) * graphic.camera_settings.x_speed
		graphic.camera_settings.x = graphic.camera_settings.x + x_speed

		y_speed = (y_target - graphic.camera_settings.y) * graphic.camera_settings.y_speed
		graphic.camera_settings.y = graphic.camera_settings.y + y_speed

		if graphic.last_fullscreen_mode ~= settings.window.fullscreen then graphic.cameraCreate() end
		graphic.camera:setScale(settings.window.cameraScale + graphic.camera_settings.scale)
		graphic.camera:setPosition(graphic.camera_settings.x, graphic.camera_settings.y)]]
	end

	function graphic:addToDrawing()
		table.insert(graphic.objects_for_drawing,self)
	end


	function graphic.backgroundDraw()
		if battle.map ~= nil then
			local map = battle.map
			for layer_id = 1, #map.layers do
				local layer = map.layers[layer_id]
				image.draw(layer.sprite, layer.x, layer.y)
			end
		end
	end

	function graphic.foregroundDraw()
		if battle.map ~= nil then
			local map = battle.map
			for layer_id = 1, #map.filters do
				local layer = map.filters[layer_id]
				image.draw(layer.sprite, layer.x, layer.y)
			end
		end
	end

	function graphic.objectDraw( object )
		if object == nil then return false end
		local frame = object.frame
		if frame ~= nil then
			local pic = frame.pic
			if pic >= 1 and pic <= object.sprites.count then
				local list_count = 0
				for i = 1, #object.sprites do
					if pic <= #object.sprites[i].file.sprites then	
						
						if battle.map.head.reflection then
							local x = object.x - frame.centerx * object.facing
							local y = battle.map.head.border_up + object.y + frame.centery + object.z
							image.draw(object.sprites[i].file,pic,x,y,object.facing,{width = 1, height = -1},nil,nil,nil,0.3)
						end		

						if battle.map.head.shadow then
							--[[local settings = {
								r = 0,
								ox = 0,
								oy = 0,
								kx = -(object.x - battle.map.head.shadow_centerx) * (battle.map.head.shadow_shear * 0.00001)
							}
							local size_x = object.scale * object.facing
							local x = object.x - frame.centerx * object.facing - object.sprites[i].file.w * settings.kx]]
						end

						local x = object.x - frame.centerx * object.facing
						local y = battle.map.head.border_up - object.y - frame.centery + object.z
						if object.shaking > 0 then
							if object.shaking % 2 == 1 then
								x = x + 2
							else
								x = x - 2
							end
						end
						image.draw(object.sprites[i].file,pic,x,y,object.facing)
						--battle.collision.DrawBack(object)
						return true
					else
						pic = pic - #object.sprites[i].file.sprites
					end
				end
			end
		end
	end

	function graphic.objectsDraw()
		for i = #graphic.objects_for_drawing, 1, -1 do
			for j = 1, i - 1 do
				local object = graphic.objects_for_drawing[j]
				if object.z < graphic.objects_for_drawing[j+1].z then
					graphic.objects_for_drawing[j] = graphic.objects_for_drawing[j+1]
					graphic.objects_for_drawing[j+1] = object
				end
			end
			graphic.objectDraw(graphic.objects_for_drawing[i])
		end
		graphic.objects_for_drawing = {}
	end

return graphic