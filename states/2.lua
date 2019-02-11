local state = { variables = {} } -- | 1 | -- Ходьба
-- Поведение объекта при ходьбе
-- Удержание клавиш направления выбирает направление ходьбы
---------------------------------------------------------------------
function state:Processing(object,s)

	if object:timer("attack") then object:setFrame("running_attack") end
	if object:timer("jump") then object:setFrame("jump_forward") end
	if object:pressed("defend") and object.block_timer == 0 then object:setFrame("defend") end
	if object:timer("special1") then object:setFrame("dash") end

	if s.speed_x ~= nil then
		if object:pressed("left") and object.facing == -1 then
			object:setMotion_X(-s.speed_x)
		elseif object:pressed("right") and object.facing == 1 then
			object:setMotion_X(s.speed_x)
		else
			object:setFrame("stop_running")
		end
	end

	if s.speed_z ~= nil then
		if object:pressed("up") then
			object:setMotion_Z(-s.speed_z)
			object:setMotion_X(object.vel_x * 0.85)
		end
		if object:pressed("down") then
			object:setMotion_Z(s.speed_z)
			object:setMotion_X(object.vel_x * 0.85)
		end
	end

	if object:pressed("left") or object:pressed("right") then
		if object.first_tick then
			object.running_frame = object.running_frame + 1
			if object.running_frame > #object.head.frames["running"] then
				object.running_frame = 1
			end
		end
		if object.wait == 0 then
			object:setFrame("running",object.running_frame)
		end
	end
end

return state