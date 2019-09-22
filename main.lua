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
require "libs.states"

debug_info = true
objects = 0
t1 = ""


function love.load()
	local width, height, flags = love.window.getMode()
	MainCanvas = love.graphics.newCanvas( width, height )
	camera = CameraCreate() -- создание камеры
	path = love.filesystem.getSourceBaseDirectory() -- берем путь до папки с игрой
	love.filesystem.mount(path, "")

	-- FPS Локер --
	min_dt = 1/60 -- требуемое фпс
    next_time = love.timer.getTime()
    ---------------
	love.graphics.setBackgroundColor(.49, .67, .46, 1) -- установка фона
    CreateDataList() -- создание листа со всеми персонажами

    for i = 1, 1 do
    	table.insert(loading_list.characters, 1)
    end
    loading_list.map = 1
    LoadingBeforeBattle()
end

function love.update(dt)
	next_time = next_time + min_dt
	delta_time = dt
	BattleProcessing()

	if love.keyboard.isDown("j") then
		map.shadow_centerx = map.shadow_centerx + 10
	end
	if love.keyboard.isDown("h") then
		map.shadow_centerx = map.shadow_centerx - 10
	end
	if love.keyboard.isDown("u") then
		if map.shadow_direction > 0 then
			map.shadow_direction = -1
		else
			map.shadow_direction = 1
		end
	end
end 



function love.draw()

	camera:draw(function(l,t,w,h)
		BackgroundDraw()
		ObjectsDraw()
		ForegroundDraw()
	end)
	love.graphics.print(tostring(t1), 100, 30)
	
	if debug_info then
		love.graphics.setNewFont(12)
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." ("..delta_time..")", 10, 10)
		love.graphics.print("Objects: "..tostring(objects).." Collisions: "..tostring(#collisions_list), 10, 25)
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

	if button == "f2" then
		local id = CreateEntity(1)
		local object = entity_list[id]
		local spawn = map.spawn_points[math.random(1, #map.spawn_points)]
		
		object.x = spawn.x + math.random(-spawn.rx, spawn.rx)
		object.y = spawn.y + math.random(-spawn.ry, spawn.ry)
		object.z = spawn.z + math.random(-spawn.rz, spawn.rz)

		if map.start_anim then
			if object.starting_frame ~= 0 then
				SetFrame(object, object.starting_frame)
			elseif object.idle_frame ~= 0 then
				SetFrame(object, object.idle_frame)
			else
				SetFrame(object, 0)
			end
		end

		if spawn.facing == 0 then
			if math.random(1,2) == 1 then
				object.facing = 1
			else
				object.facing = -1
			end
		elseif (spawn.facing == -1) or (spawn.facing == 1) then
			object.facing = spawn.facing
		end
	end

	for player, en_id in pairs(players) do
		for key, val in pairs(control_settings[player]) do
			if button == val then
				key_pressed[player][key] = 1
			end
		end
	end
end