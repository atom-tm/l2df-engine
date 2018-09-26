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