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
    	table.insert(loading_list.characters, 4)
    end

    loading_list.map = 1
    LoadingBeforeBattle()

    scale = 1

end

function love.update(dt)
	next_time = next_time + min_dt
	delta_time = dt

	BattleProcessing()

	if love.keyboard.isDown("u") then
		scale = scale + 0.01
	end
	if love.keyboard.isDown("j") then
		scale = scale - 0.01
	end

	if love.keyboard.isDown("t") then
		entity_list[3].z = entity_list[3].z - 0.5
	end

	if love.keyboard.isDown("g") then
		entity_list[3].z = entity_list[3].z + 0.5
	end

	if love.keyboard.isDown("d") then
		entity_list[3].x = entity_list[3].x + 0.5
	end

	if love.keyboard.isDown("a") then
		entity_list[3].x = entity_list[3].x - 0.5
	end

	if love.keyboard.isDown("w") then
		entity_list[3].y = entity_list[3].y + 0.5
	end

	if love.keyboard.isDown("s") then
		entity_list[3].y = entity_list[3].y - 0.5
	end


	if love.keyboard.isDown("up") then
		camera_y = camera_y - 3
	end
	if love.keyboard.isDown("down") then
		camera_y = camera_y + 3
	end
	if love.keyboard.isDown("left") then
		camera_x = camera_x - 5
	end
	if love.keyboard.isDown("right") then
		camera_x = camera_x + 5
	end

	camera:setScale(scale)
	camera:setPosition(camera_x, camera_y)


end 



function love.draw()
	camera:draw(function(l,t,w,h)
		BackgroundDraw()
		ObjectsDraw()
		ForegroundDraw()
	end)


	if debug_info then
		love.graphics.setNewFont(12)
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." ("..delta_time..")", 10, 10)
		love.graphics.print("Objects: "..tostring(#entity_list).." Collisions: "..tostring(#collisions_list), 10, 25)
		love.graphics.print("FPS: "..tostring(#objects_for_drawing), 10, 40)
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