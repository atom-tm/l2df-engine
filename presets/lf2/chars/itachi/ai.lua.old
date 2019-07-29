local ai = {}
local checkState = helper.stateExist
local f = battle.ai

function ai:update(char)
	-- Для начала проверяем на то, есть ли у нас какая-то цель сейчас.
	if char.ai_vars.defend_timer == 0 then
		ai:criticalDefend(char)
	else char.ai_vars.defend_timer = char.ai_vars.defend_timer - 1 end
	if char.ai_vars.goal == 0 then -- если цели нет
		char.ai_vars.goal = math.random(1,3) -- определяем случайную цель
		return true
	elseif char.ai_vars.goal == 1 then -- если цель - атака
	elseif char.ai_vars.goal == 2 then -- если цель - защита
		ai:defend(char)
	elseif char.ai_vars.goal == 3 then -- если цель - поддержка
	end
end

function ai:criticalDefend(char) -- функция вызывается раз в n тиков, служит для определения ботом опасностей и способствует резкому переходу в режим защиты
	char.ai_vars.defend_timer = settings.difficulty
	char.ai_vars.attackers = {}
	for i = 1, #battle.chars do -- проверка, не бьют ли игрока вражеские персонажи
		local object = battle.chars[i]
		if object.owner ~= char.owner and object.team == -1 or object.team ~= char.team then
			if object:timer("attack") then
				if math.sqrt((char.x - object.x)^2 + (char.z - object.z) ^2 + (char.y - object.y) ^ 2) < 300 then
					table.insert(char.ai_vars.attackers,object)
				end
			end
		end
	end	
	if #char.ai_vars.attackers > 0 then
		char.ai_vars.goal = 2
	end
end

function ai:defend(char)
	local attackers = char.ai_vars.attackers
	if #attackers == 1 then
		char.facing = -attackers[1].facing
		if #attackers[1].frame.itrs == 0 then
			char.key_pressed["defend"] = 0
			char.key_pressed["down"] = 5
			char.key_timer["attack"] = 5
		end
	end
	char.key_pressed["defend"] = 10
	char.ai_vars.goal = 0
end


return ai