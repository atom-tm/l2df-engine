love.graphics.setDefaultFilter("nearest", "nearest")
camera = require "libs.gamera"
require "libs.entites"
require "libs.sprites"
require "libs.physics"
require "libs.collisions"
require "libs.get"
require "libs.controls"
require "libs.battle_processing"
math.randomseed(love.timer.getTime())

debug_info = false

function love.load()
	love.graphics.setBackgroundColor(.49, .67, .46, 1)
	CreateDataList()
	for i = 1, 2 do
		table.insert(loading_list, "4")
	end
	table.insert(loading_list, "2")
	LoadingBeforeBattle()
	entity_list[#entity_list].x = 0
	entity_list[#entity_list].y = love.graphics.getHeight() - 20
	
	min_dt = 1/60
    next_time = love.timer.getTime()
end

function love.update(dt)
	next_time = next_time + min_dt
	delta_time = dt

	BattleProcessing() -- обработка боя
	CollisionersProcessing() -- поиск столкновений
	CollisionsProcessing() -- обработка столкновений
end 



function love.draw()
	for key, val in pairs(entity_list) do
		DrawEntity(val)
	end

	ControlCheck()


	--| Общая отладочная информация |--

	love.graphics.setNewFont(12)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." ("..delta_time..")", 10, 10)
	
	if debug_info == true then
		love.graphics.print("Objects: "..tostring(#entity_list), 10, 30)
		love.graphics.print("Key: ".. key_pressed, 10, 50)
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
		if debug_info then
			debug_info = false
		else
			debug_info = true
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