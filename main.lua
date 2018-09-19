love.graphics.setDefaultFilter("nearest", "nearest")
camera = require "libs.gamera"
require "libs.entites"
require "libs.sprites"
require "libs.physics"
require "libs.get"

math.randomseed(love.timer.getTime())

debug_info = false
key_pressed = ""

function love.load()
	CreateDataList()
	for i = 1, 70 do
		table.insert(loading_list, "4")
	end
	table.insert(loading_list, "2")
	LoadingBeforeBattle()
	for en_id = 1, #entity_list do
		CheckCollisions(en_id)
	end
end 

function love.update(dt)
	delta_time = dt

	for en_id = 1, #entity_list do
		Gravity(entity_list[en_id])
		Motion(en_id, dt)
	end
	if love.keyboard.isDown("w") then
		entity_list[1].velocity_y = entity_list[1].velocity_y - 0.1
	end
	if love.keyboard.isDown("s") then
		entity_list[1].velocity_y = entity_list[1].velocity_y + 0.1
	end
	if love.keyboard.isDown("a") then
		entity_list[1].velocity_x = entity_list[1].velocity_x - 0.1
		entity_list[1].facing = -1
	end
	if love.keyboard.isDown("d") then
		entity_list[1].velocity_x = entity_list[1].velocity_x + 0.1
		entity_list[1].facing = 1
	end



end 



function love.draw()
	for key, val in pairs(entity_list) do
		DrawEntity(val)
	end
		love.graphics.setNewFont(12)



	--| Общая отладочная информация |--

	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )).." ("..delta_time..")", 10, 10)
	
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