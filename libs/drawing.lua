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
	camera_y = w/2
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

		local target_x = en.x + ((frame.centerx + 20) * en.facing) + en.vel_x
		local target_y = map.border_up + en.z - en.y - frame.centery + (camera_scale * 10) + en.vel_y
		local target_scale = en.scale + 0.3 - (math.abs(en.vel_x) + math.abs(en.vel_y)) * 0.005 + frame.zoom + en.vel_z


		if target_scale > 3.5 then target_scale = 3.5
		elseif target_scale < 0.5 then target_scale = 0.5 end


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
		--camera:setAngle()




	elseif players_count == 2 then -- если игроков двое

		local en1 = entity_list[players.player1]
		local frame1 = GetFrame(en1)
		
		local en2 = entity_list[players.player2]
		local frame2 = GetFrame(en2)

		local camera_x, camera_y = camera:getPosition()
		local camera_scale = camera:getScale()

		local target_x = (en1.x + en2.x) * 0.5 + (frame1.centerx * en1.facing) + (frame2.centerx * en2.facing)
		local target_y = ((map.border_up + en1.z - en1.y) + (map.border_up + en2.z - en2.y)) * 0.46
		local target_scale = (en1.scale + en2.scale) * 0.5 - math.sqrt((en1.x - en2.x)^2 + (en1.y - en2.y)^2 + (en1.z - en2.z)^2) * 0.001 + 0.3 - ((math.abs(en1.vel_x) + math.abs(en1.vel_y)) + (math.abs(en2.vel_x) + math.abs(en2.vel_y))) * 0.001

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





--[[function DrawEntity(en) -- функция рисует объект или персонажа
-------------------------------------
	
	local facing = en.facing
	local frame = en.frames[tostring(en.frame)]

	if not (frame == nil) then

		local x = en.x - Get(frame.centerx) * facing
		local y = en.y - Get(frame.centery)

		local sizex = 1 * facing
		local sizey = 1

		local pic = tonumber(Get(frame.pic))


		if not (pic == 0) then 

		local list
		local sprite
			
			for s = 1, #en.sprites do
				if pic > #en.sprites[s].pics then
					pic = pic - #en.sprites[s].pics
				else
					list = en.sprites[s].file
					sprite = en.sprites[s].pics[pic]
					break
				end
			end

		love.graphics.draw(list, sprite, x, y, 0, sizex, sizey)
		love.graphics.print(en.dynamic_id, en.x + 20, en.y - 65)
		love.graphics.print(en.real_id, en.x + 20, en.y - 50)
		end
	end
end]]





function BackgroundDraw ()
	if map ~= nil then
		for layer_id = 1, #map.layers do
			layer = map.layers[layer_id]
			love.graphics.draw(layer.image, layer.x, layer.y)
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

	for key, val in pairs(players) do
		en = entity_list[val]
		frame = GetFrame(en)
		love.graphics.print("V", en.x, map.border_up - en.y - frame.centery + en.z)
	end


	--[[for i = #objects_for_drawing, 1, -1 do
		for j = 1, i, 1 do
			love.window.showMessageBox( "..", i.." "..j, "info", true)
			local j1 = objects_for_drawing[j].z
			if(j1 < objects_for_drawing[j+1].z) then
				objects_for_drawing[j] = objects_for_drawing[j+1]
				objects_for_drawing[j+1] = j1
			end
		end
		DrawEntity(objects_for_drawing[i].id)
	end]]
end


function DrawEntity (en_id)

	local en = entity_list[en_id]
	local frame = GetFrame(en)

	if frame ~= nil then

		local x = en.x - frame.centerx * en.facing
		local y = map.border_up - en.y - frame.centery + en.z

		local sizex = 1 * en.facing
		local sizey = 1

		local pic = frame.pic

		if not (pic == 0) then 

		local list
		local sprite
			
			for s = 1, #en.sprites do
				if pic > #en.sprites[s].pics then
					pic = pic - #en.sprites[s].pics
				else
					list = en.sprites[s].file
					sprite = en.sprites[s].pics[pic]
					break
				end
			end

			love.graphics.draw(list, sprite, x, y, 0, sizex, sizey)

		if map.shadow then

			local shadow_x = en.x - frame.centerx * en.facing
			local shadow_y = map.border_up + en.y + frame.centery + en.z

			local shadow_sizex = 1 * en.facing
			local shadow_sizey = -1

			local shadow_opacity = map.shadow_opacity - en.y * 0.005

			love.graphics.setColor(0, 0, 0, shadow_opacity)
			love.graphics.draw(list, sprite, shadow_x, shadow_y, 0, shadow_sizex, shadow_sizey, 0, 0, 0, 0)
			love.graphics.setColor(1, 1, 1, 1)
		end

		
			--love.graphics.print("player", en.x - frame.centerx, map.border_up + en.z - frame.centery)
		end
	end
end