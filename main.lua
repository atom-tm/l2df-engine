love.graphics.setDefaultFilter("nearest", "nearest") -- отключение сглаживания
math.randomseed(love.timer.getTime()) -- для того чтобы рандом работал лучше

gamera = require "libs.gamera"

require "libs.entites"
require "libs.drawing"
require "libs.physics"
require "libs.collisions"
require "libs.get"
require "libs.controls"
require "libs.battle"
require "libs.loading"

debug_info = false
camera_x = 0
camera_y = 0

function love.load()

	camera = CameraCreate() -- создание камеры

	-- FPS Локер --
	min_dt = 1/60 -- требуемое фпс
    next_time = love.timer.getTime()
    ---------------

	love.graphics.setBackgroundColor(.49, .67, .46, 1) -- установка фона

    CreateDataList() -- создание листа со всеми персонажами

    for i = 1, 10 do
    	table.insert(loading_list.characters, math.random(3, 4))
    end

    loading_list.map = 1
    LoadingBeforeBattle()

    scale = 1

end

function love.update(dt)
	next_time = next_time + min_dt
	delta_time = dt

	BattleProcessing()


	if love.keyboard.isDown("w") then
		entity_list[1].accel_z = -15
	end

	if love.keyboard.isDown("s") then
		entity_list[1].accel_z = 15
	end

	if love.keyboard.isDown("d") then
		entity_list[1].accel_x = 50
		entity_list[1].facing = 1
	end

	if love.keyboard.isDown("a") then
		entity_list[1].accel_x = -50
		entity_list[1].facing = -1
	end

	if love.keyboard.isDown("c") then
		entity_list[1].speed_x = 50
		entity_list[1].facing = 1
	end

	if love.keyboard.isDown("x") then
		entity_list[1].speed_x = -50
		entity_list[1].facing = -1
	end

	if love.keyboard.isDown("y") then
		entity_list[1].vel_x = 0
		entity_list[1].vel_y = 0
		entity_list[1].vel_z = 0
	end


end 



function love.draw()
	camera:draw(function(l,t,w,h)
		BackgroundDraw()
		ObjectsDraw()
		ForegroundDraw()
	end)


	love.graphics.print(entity_list[1].vel_x.." \n "..entity_list[1].taccel_x.." \n "..entity_list[1].accel_x.."\n".. delta_time * 0.99, 100, 30)
	if debug_info then
		love.graphics.setNewFont(12)
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." ("..delta_time..")", 10, 10)
		love.graphics.print("Objects: "..tostring(#entity_list).." Collisions: "..tostring(#collisions_list), 10, 25)
	end

	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)

end 




function love.keypressed( button, scancode, isrepeat )

	if button == "f1" then
		if debug_info then debug_info = false
		else debug_info = true end
	end

	for player, en_id in pairs(players) do
		for key, val in pairs(control_settings[player]) do
			if button == val then
				key_pressed[player][key] = 1
			end
		end
	end
end