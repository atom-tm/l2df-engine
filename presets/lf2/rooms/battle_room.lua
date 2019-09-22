local room = {}

function room:load ()
	room.debug_info = false
	room.objects = 0
	room.pause = false
	room.step = false
end

function room:update ()
	if room.pause == false or room.step then
	BattleProcessing()
	if step then step = false end
	end
end

function room:draw ()
	camera:draw(function(l,t,w,h)
		BackgroundDraw()
		ObjectsDraw()
		ForegroundDraw()
	end)
	if room.debug_info then
		room.debug()
	end
	if time_stop then
		love.graphics.print("PAUSE", width - 70, 20)
	end
end

function room:Debug()
	love.graphics.setNewFont(12)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." ("..delta_time..")", 10, 10)
	love.graphics.print("Objects: "..tostring(objects).." Sourses: "..tostring(#sourse_list).." Collisions: "..tostring(#collisions_list), 10, 25)
end

function room:keypressed(button)

	if button == "f3" then
		if room.debug_info then room.debug_info = false
		else room.debug_info = true end
	end

	if button == "f1" then
		if room.pause then room.pause = false
		else room.pause = true end
	end
	if button == "f2" then
		room.step = true
	end

	if button == "f5" then
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

return room