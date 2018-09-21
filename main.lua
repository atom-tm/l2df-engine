love.graphics.setDefaultFilter("nearest", "nearest")
camera = require "libs.gamera"
require "libs.entites"
require "libs.sprites"
require "libs.physics"
require "libs.collisions"
require "libs.get"
math.randomseed(love.timer.getTime())


debug_info = false
key_pressed = ""

function love.load()
	CreateDataList()
	for i = 1, 100 do
		table.insert(loading_list, "4")
	end
	table.insert(loading_list, "2")
	LoadingBeforeBattle()
end

function love.update(dt)
	delta_time = dt

		--| Цикл последовательной обработки объектов |--
		
		for en_id = 1, #entity_list do
			local en = entity_list[en_id]
			local frame = GetFrame(en)

			if en.physic == true then

			end

			if (en.vel_x ~= 0) or (en.vel_y ~= 0) then
				Motion(en, dt)
			end

			if en.collision then
				if (en.arest == 0) and (frame.itr_radius > 0) then
					table.insert(collisioners.itr, en_id)
				end
				if (en.vrest == 0) and (frame.body_radius > 0) then
					table.insert(collisioners.body, en_id)
				end
				if (frame.platform_radius > 0) then
					table.insert(collisioners.platform, en_id)
				end
			end

			-- тут будет ещё обработка стейтов --
		end

		CollisionersProcessing()








	if love.keyboard.isDown("w") then
		entity_list[1].vel_y = entity_list[1].vel_y - 0.1
	end
	if love.keyboard.isDown("s") then
		entity_list[1].vel_y = entity_list[1].vel_y + 0.1
	end
	if love.keyboard.isDown("a") then
		entity_list[1].vel_x = entity_list[1].vel_x - 0.1
		entity_list[1].facing = -1
	end
	if love.keyboard.isDown("d") then
		entity_list[1].vel_x = entity_list[1].vel_x + 0.1
		entity_list[1].facing = 1
	end

end 



function love.draw()
	for key, val in pairs(entity_list) do
		DrawEntity(val)
	end



	--| Общая отладочная информация |--

	love.graphics.setNewFont(12)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." ("..delta_time..")", 10, 10)
		love.graphics.print("Objects: "..tostring(#collisioners.itr + #collisioners.body), 10, 30)
		love.graphics.print("Objects: "..tostring(#collisions_list), 10, 50)
	
	if debug_info == true then
		love.graphics.print("Objects: "..tostring(#entity_list), 10, 30)
		love.graphics.print("Key: ".. key_pressed, 10, 50)
	end
end 

function love.keypressed( key, scancode, isrepeat ) 
	--key_pressed = key
	
	if key == "f1" then
		if debug_info then
			debug_info = false
		else
			debug_info = true
		end
	end

end