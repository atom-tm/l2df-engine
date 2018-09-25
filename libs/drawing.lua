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



function DrawEntity(en) -- функция рисует объект или персонажа
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
end





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

	love.graphics.setColor(255/255, 50/255, 50/255, 1)
	love.graphics.rectangle("line", 0, map.border_up, map.width, map.area)
	love.graphics.setColor(1, 1, 1, 1)

	for i = 1, #entity_list do
		love.graphics.print("player", entity_list[i].x, entity_list[i].y)
	end

end