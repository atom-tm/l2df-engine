


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

		end






		--| Отладочная информация персонажа |--
		
		if debug_info == true then
			frame = GetFrame(en)
			for c_key, col in pairs(frame.itrs) do
				local colaider = CollaiderCords(col, en.x, en.y, frame.centerx, frame.centery, en.facing)
			love.graphics.setColor(.87, .11, .11, 1)
				love.graphics.rectangle("line", colaider.x, colaider.y, colaider.w, colaider.h)
			end
			for c_key, col in pairs(frame.bodys) do
				local colaider = CollaiderCords(col, en.x, en.y, frame.centerx, frame.centery, en.facing)
			love.graphics.setColor(.25, .37, .85, 1)
				love.graphics.rectangle("line", colaider.x, colaider.y, colaider.w, colaider.h)
			end
			for c_key, col in pairs(frame.platforms) do
				local colaider = CollaiderCords(col, en.x, en.y, frame.centerx, frame.centery, en.facing)
			love.graphics.setColor(1, 1, 1, 1)
				love.graphics.rectangle("line", colaider.x, colaider.y, colaider.w, colaider.h)
			end
			
			
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.setNewFont(10)
			love.graphics.print(
				"x: " .. string.format("%2.1f", en.x) .. " y: " .. string.format("%2.1f", en.y) .. "\n" ..
				"vel_x: " .. string.format("%2.1f", en.vel_x) .. "\n" ..
				"vel_y: " .. string.format("%2.1f", en.vel_y) .. "\n" ..
				"Facing: " .. en.facing .. "\n" ..
				"w: " .. tostring(frame.w) .. "\n" ..
				"h: " .. tostring(frame.h) .. "\n" ..
				"air: " .. tostring(en.in_air) .. "\n" .. 
				"pl_rad: " .. frame.platform_radius .. "\n" ..
				"itr_rad: " .. frame.itr_radius .. "\n" ..
				"body_rad: " .. frame.body_radius .. "\n"
				, en.x + 25, en.y - 50)
		end

			love.graphics.print(
				"up: " .. en.key_timer["up"] .. "\n" ..
				"down: " .. en.key_timer["down"] .. "\n" ..
				"left: " .. en.key_timer["left"] .. "\n" ..
				"right: " .. en.key_timer["right"] .. "\n" ..
				"attack: " .. en.key_timer["attack"] .. "\n" ..
				"jump: " .. en.key_timer["jump"] .. "\n" ..
				"defend: " .. en.key_timer["defend"] .. "\n"..
				"jutsu: " .. en.key_timer["jutsu"] .. "\n"..
				"up: " .. en.double_key_timer["up"] .. "\n" ..
				"down: " .. en.double_key_timer["down"] .. "\n" ..
				"left: " .. en.double_key_timer["left"] .. "\n" ..
				"right: " .. en.double_key_timer["right"] .. "\n" ..
				"attack: " .. en.double_key_timer["attack"] .. "\n" ..
				"jump: " .. en.double_key_timer["jump"] .. "\n" ..
				"defend: " .. en.double_key_timer["defend"] .. "\n" ..
				"jutsu: " .. en.double_key_timer["jutsu"] .. "\n"
				, en.x + 25, en.y - 100)

	end
end