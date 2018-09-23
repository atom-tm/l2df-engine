love.graphics.setDefaultFilter("nearest", "nearest")
camera = require "libs.gamera"
require "libs.entites"
require "libs.sprites"
require "libs.physics"
require "libs.collisions"
require "libs.get"
require "libs.controls"
require "libs.battle"
require "libs.loading"
math.randomseed(love.timer.getTime())


debug_info = false



local t = {}

function love.load()
	
	love.graphics.setBackgroundColor(.49, .67, .46, 1) -- установка фона
	
	-- FPS Локер --
	min_dt = 1/60
    next_time = love.timer.getTime()
    ---------------

    CreateDataList()
    loading_list.characters = {"4","4","4","4","4","4","2"}
    LoadingBeforeBattle()

end

function love.update(dt)
	next_time = next_time + min_dt
	delta_time = dt

	ControlCheck()
	BattleProcessing()
end 



function love.draw()
	
	for i = 1, #entity_list do
		if entity_list[i] ~= "nil" then
			DrawEntity(entity_list[i])
		end
	end


	--| Общая отладочная информация |--

	love.graphics.setNewFont(12)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." ("..delta_time..")", 10, 10)
	
	if debug_info == true then
		love.graphics.print("Objects: "..tostring(#entity_list), 10, 30)
		love.graphics.print("Sourses: "..tostring(#sourse_list), 10, 50)
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
		CreateEntity("4")
	end

	if button == "f3" then
		RemoveEntity(7)
	end

	if button == "f4" then
		RemoveEntity(#entity_list)
	end

	for player, en_id in pairs(players) do
		for key, val in pairs(control_settings[player]) do
			if button == val then
				key_pressed[player][key] = 1
			end
		end
	end
end