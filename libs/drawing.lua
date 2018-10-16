objects_for_drawing = {}


function CameraCreate() -- отвечает за изначальное создание камеры
-------------------------------------
	local width, height, flags = love.window.getMode( )
	local camera = gamera.new(0,0,width,height)
	camera:setWindow(0,0,width,height)
	return camera
end


function CameraSet(w,h) -- задаёт положение камеры, размеры карты
-------------------------------------
	camera:setWorld(0,0,w,h)
	camera:setPosition(w/2,h/2)
	camera_x = w/2
	camera_y = h/2
end


function CameraBinding () -- функция отвечает за поведение камеры
-- если игрок один, камера привязывается к нему и следует за ним, отдаляясь при наборе игроком скорости
-------------------------------------
	
	local players_count = 0 -- переменная для подсчета количества игроков
	local player = nil
	for k in pairs(players) do
		if players[k] ~= nil then
			players_count = players_count + 1
			player = players[k]
		end
	end

	if players_count == 1 then -- если игрок один
		
		local en = entity_list[player]
		local frame = GetFrame(en)

		local camera_x, camera_y = camera:getPosition()
		local camera_scale = camera:getScale()

		local target_x = en.x + (80 * en.facing) + en.vel_x
		local target_y = map.border_up + en.z - en.y - frame.centery + (camera_scale * 10) - en.vel_y * 0.5 + en.vel_z
		local target_scale = en.scale + 0.3 - (math.abs(en.vel_x) + math.abs(en.vel_y) + math.abs(en.vel_z)) * 0.005 + frame.zoom


		if target_scale > 3.5 then target_scale = 3.5
		elseif target_scale < 0.5 then target_scale = 0.5 end


		if camera_x > target_x then
			local speed = (camera_x - target_x) * delta_time * 5
			camera_x = camera_x - speed
		elseif camera_x < target_x then
			local speed = (target_x - camera_x) * delta_time * 5
			camera_x = camera_x + speed
		end

		if camera_y > target_y then
			local speed = (camera_y - target_y) * delta_time * 5
			camera_y = camera_y - speed
		elseif camera_y < target_y then
			local speed = (target_y - camera_y) * delta_time * 7
			camera_y = camera_y + speed
		end

		if camera_scale > target_scale then
			local speed = (camera_scale - target_scale) * delta_time * 5
			camera_scale = camera_scale - speed
		elseif camera_scale < target_scale then
			local speed = (target_scale - camera_scale) * delta_time * 5
			camera_scale = camera_scale + speed
		end

		camera:setPosition(camera_x, camera_y)
		camera:setScale(camera_scale)
		--camera:setAngle()




	elseif players_count == 2 then -- если игроков двое

		local en1 = entity_list[players[1]]
		local frame1 = GetFrame(en1)
		
		local en2 = entity_list[players[2]]
		local frame2 = GetFrame(en2)

		local camera_x, camera_y = camera:getPosition()
		local camera_scale = camera:getScale()

		local target_x = (en1.x + en2.x) * 0.5 + (60 * en1.facing) + (60 * en2.facing)
		local target_y = ((map.border_up + en1.z - en1.y) + (map.border_up + en2.z - en2.y)) * 0.46
		local target_scale = (en1.scale + en2.scale) * 0.5 - math.sqrt((en1.x - en2.x)^2 + (en1.y - en2.y)^2 + (en1.z - en2.z)^2) * 0.0005 - ((math.abs(en1.vel_x) + math.abs(en1.vel_y)) + (math.abs(en2.vel_x) + math.abs(en2.vel_y))) * 0.001

		if target_scale > 3.5 then target_scale = 3.5
		elseif target_scale < 0.1 then target_scale = 0.1 end


		if camera_x > target_x then
			local speed = (camera_x - target_x) * 0.05
			camera_x = camera_x - speed
		elseif camera_x < target_x then
			local speed = (target_x - camera_x) * 0.05
			camera_x = camera_x + speed
		end

		if camera_y > target_y then
			local speed = (camera_y - target_y) * 0.05
			camera_y = camera_y - speed
		elseif camera_y < target_y then
			local speed = (target_y - camera_y) * 0.05
			camera_y = camera_y + speed
		end

		if camera_scale > target_scale then
			local speed = (camera_scale - target_scale) * 0.05
			camera_scale = camera_scale - speed
		elseif camera_scale < target_scale then
			local speed = (target_scale - camera_scale) * 0.05
			camera_scale = camera_scale + speed
		end

		camera:setPosition(camera_x, camera_y)
		camera:setScale(camera_scale)

	else -- для всех остальных случаев


	end
end




function BackgroundDraw ()
	if map ~= nil then
		for layer_id = 1, #map.layers do
			layer = map.layers[layer_id]
			love.graphics.draw( layer.image, layer.x, layer.y)
		end
	end
end

function ForegroundDraw ()
	if map ~= nil then
		for filter_id = 1, #map.filters do
			filter = map.filters[filter_id]
			love.graphics.draw(filter.image, filter.x, filter.y)
		end
	end
end




function ObjectsDraw()

	for i = #objects_for_drawing, 1, -1 do
		for j = 1, i - 1 do
			local tid = objects_for_drawing[j].id
			local tz = objects_for_drawing[j].z
			if tz < objects_for_drawing[j+1].z then
				objects_for_drawing[j].id = objects_for_drawing[j+1].id
				objects_for_drawing[j].z = objects_for_drawing[j+1].z
				objects_for_drawing[j+1].id = tid
				objects_for_drawing[j+1].z = tz
			end
		end
		DrawEntity(objects_for_drawing[i].id)
	end
end


function DrawEntity (en_id)

	if entity_list[en_id] ~= "nil" and entity_list[en_id] ~= nil then -- если объект существует
		local en = entity_list[en_id]
		local frame = GetFrame(en)

		if frame ~= nil then

			local x = en.x - frame.centerx * en.facing
			local y = map.border_up - en.y - frame.centery + en.z

			local sizex = en.scale * en.facing
			local sizey = en.scale

			local pic = frame.pic + 1

			if not (pic == 0) then 

				local list
				local sprite
				local w
					
				for s = 1, #en.sprites do
					if pic > #en.sprites[s].pics then
						pic = pic - #en.sprites[s].pics
					else
						list = en.sprites[s].file
						sprite = en.sprites[s].pics[pic]
						w = en.sprites[s].w
						break
					end
				end

				if map.reflection then

					local reflection_sizex
					local reflection_sizey
					local reflection_opacity
					local reflection_x
					local reflection_y
				
					reflection_sizex = en.scale * en.facing
					reflection_sizey = -en.scale * 0.9
					reflection_x = en.x - frame.centerx * en.facing
					reflection_y = map.border_up + en.y * 0.25 + en.z - frame.centery * reflection_sizey
					reflection_opacity = map.reflection_opacity - en.y * 0.0005
					
					love.graphics.setColor(1,1,1, reflection_opacity)
					love.graphics.draw(list, sprite, reflection_x, reflection_y, 0, reflection_sizex, reflection_sizey, 0,-1,0,0)
					love.graphics.setColor(1,1,1,1)
				end

				if map.shadow then
					if en.shadow then
						if frame.shadow then

							local shadow_sizex
							local shadow_sizey
							local shadow_opacity
							local shadow_x
							local shadow_y
							local shadow_shear

							shadow_shear = -(en.x - map.shadow_centerx) * (map.shadow_shear * 0.00001)
							shadow_sizex = en.scale * en.facing
							shadow_x = en.x - frame.centerx * en.facing - w * shadow_shear
							
							if map.shadow_direction > 0 then
								shadow_sizey = en.scale * map.shadow_size + en.y * 0.001 + ((map.area - en.z) * 0.001) + math.abs(shadow_shear) * 0.1
								if shadow_sizey < 0.1 then shadow_sizey = 0.1 end
								shadow_y = map.border_up - en.y * 0.3 + en.z - frame.centery * shadow_sizey
							else
								shadow_sizey = -(en.scale * map.shadow_size + en.y * 0.001 + (en.z * 0.001)) + math.abs(shadow_shear) * 0.1
								if shadow_sizey > -0.1 then shadow_sizey = -0.1 end
								shadow_y = map.border_up + en.y * 0.3 + en.z - frame.centery * shadow_sizey
							end
							
							shadow_opacity = map.shadow_opacity - en.y * 0.0005 - math.abs(en.x - map.shadow_centerx) * 0.00005

							love.graphics.setColor(0,0,0, shadow_opacity)
							love.graphics.draw(list, sprite, shadow_x, shadow_y, 0, shadow_sizex, shadow_sizey, 0, -1, shadow_shear * en.facing, 0)
							love.graphics.setColor(1,1,1,1)
						end
					end
				end

				love.graphics.draw(list, sprite, x, y, 0, sizex, sizey)
				
				if debug_info then
					love.graphics.rectangle("fill", en.x, map.border_up + en.y + en.z, 3, 3)
					for i = 1, #frame.bodys do
						local c = CollaiderCords(frame.bodys[i], en.x , en.y, en.z , frame.centerx , frame.centery , en.facing)
						love.graphics.setColor(.11, .8, .45, 1)
						love.graphics.rectangle("line", c.x, c.y, c.w, c.h)
						love.graphics.setColor(1, 1, 1, 1)
					end
					for i = 1, #frame.itrs do
						local c = CollaiderCords(frame.itrs[i], en.x , en.y, en.z , frame.centerx , frame.centery , en.facing)
						love.graphics.setColor(.11, .8, .45, 1)
						love.graphics.rectangle("line", c.x, c.y, c.w, c.h)
						love.graphics.setColor(1, 1, 1, 1)
					end
					for i = 1, #frame.platforms do
						local c = CollaiderCords(frame.platforms[i], en.x , en.y, en.z , frame.centerx , frame.centery , en.facing)
						love.graphics.setColor(.11, .8, .45, 1)
						love.graphics.rectangle("line", c.x, c.y, c.w, c.h)
						love.graphics.setColor(1, 1, 1, 1)
					end

					love.graphics.print("defend: "..en.defend .. "\n" .."fall: "..en.fall, en.x, map.border_up + en.y + en.z + 15)
				end



					--[[local shadow_x = en.x - frame.centerx * en.facing
					local shadow_y = map.border_up + frame.centery * 0.5 + en.z + en.y * 0.01

					local shadow_sizex = en.scale * en.facing
					local shadow_sizey = -en.scale + en.y * 0.01 + 0.5

					local shadow_opacity = map.shadow_opacity - en.y * 0.0056 - 0.5

					love.graphics.setColor(255, 255, 255, shadow_opacity)
					love.graphics.draw(list, sprite, shadow_x, shadow_y, 0, shadow_sizex, shadow_sizey, 0, 0, 0, 0)
					love.graphics.setColor(1, 1, 1, 1)
				end]]
			end
		end
	end
end