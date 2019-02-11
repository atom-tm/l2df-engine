local state = { variables = {} } -- | 1 | -- Ходьба
-- Поведение объекта при ходьбе
-- Удержание клавиш направления выбирает направление ходьбы
---------------------------------------------------------------------
function state:Processing(object,s)

	if object:timer("attack") then object:setFrame("attack") end
	if object:timer("jump") then object:setFrame("jump") end
	if object:pressed("defend") and object.block_timer == 0 then object:setFrame("defend") end
	if object:timer("special1") then object:setFrame("special") end

	if object:double_timer("left") or object:double_timer("right") then
		if object:double_timer("left") then object.facing = -1 end
		if object:double_timer("right") then object.facing = 1 end
		object:setFrame("running", object.running_frame)
	end

	if s.speed_x ~= nil then
		if object:pressed("left") then
			object.facing = -1
			object:setMotion_X(-s.speed_x)
		end
		if object:pressed("right") then
			object.facing = 1
			object:setMotion_X(s.speed_x)
		end
	end
	if s.speed_z ~= nil then
		if object:pressed("up") then
			object:setMotion_Z(-s.speed_z)
		end
		if object:pressed("down") then
			object:setMotion_Z(s.speed_z)
		end
	end
	if object:pressed("left") or object:pressed("right") or object:pressed("up") or object:pressed("down") then
		if object.first_tick then
			object.walking_frame = object.walking_frame + 1
			if object.walking_frame > #object.head.frames["walking"] then
				object.walking_frame = 1
			end
		end
		if object.wait == 0 then
			object:setFrame("walking",object.walking_frame)
		end
	end
end

return state