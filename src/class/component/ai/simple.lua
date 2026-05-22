--- Simple AI controller. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.ai.bot
-- @author Abelidze
-- @copyright Atom-TM 2023

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'AI works only with l2df v1.0 and higher')

local abs = math.abs
local floor = math.floor
local pairs = _G.pairs

local Component = core.import 'class.component'
local InputManager = core.import 'manager.input'

local function roll(player, counter, salt, limit)
	if limit <= 1 then return 1 end
	local value = (player * 1103515245 + counter * 12345 + salt * 2654435761) % 2147483647
	return floor(value % limit) + 1
end

local function attrData(obj)
	return obj and obj.C and obj.C.attr and obj.C.attr.data()
end

local function isAlive(obj)
	local data = obj and obj.data
	local attr = attrData(obj)
	return data and not data.hidden and data.player and attr and attr.hp > 0
end

local function isOpponent(obj, target)
	if not isAlive(target) or target == obj then
		return false
	end
	local data, tdata = obj.data, target.data
	if tdata.player == data.player then
		return false
	end
	return not (data.team and data.team > 0 and data.team == tdata.team)
end

local function hasState(obj, state)
	return obj and obj.C and obj.C.states and obj.C.states.has(state) or false
end

local function hasDamagingItr(obj)
	local itrs = obj and obj.data and obj.data.itrs
	if not itrs then return false end
	for i = 1, #itrs do
		local itr = itrs[i]
		if itr.kind == 0 and ((itr.injury or 0) > 0 or (itr.fall or 0) > 0 or (itr.bdefend or 0) > 0) then
			return true
		end
	end
	return false
end

local function isAttacking(obj)
	local frame = obj and obj.data and obj.data.frame
	local keyword = frame and frame.keyword or ''
	return
		hasDamagingItr(obj) or
		keyword == 'punch' or keyword == 'super_punch' or
		keyword == 'jump_attack' or keyword == 'run_attack' or keyword == 'dash_attack'
end

local function isBusy(obj)
	local frame = obj and obj.data and obj.data.frame
	local keyword = frame and frame.keyword or ''
	return
		hasState(obj, 3) or hasState(obj, 6) or hasState(obj, 7) or hasState(obj, 8) or hasState(obj, 14) or
		keyword == 'punch' or keyword == 'super_punch' or keyword == 'run_attack' or
		keyword == 'dash_attack' or keyword == 'broken_defend'
end

local function findTarget(obj)
	local parent = obj.parent
	if not parent then return nil end
	local target, dist = nil, 1e12
	for enemy in parent:enum(true, true) do
		if isOpponent(obj, enemy) then
			local dx = enemy.data.x - obj.data.x
			local dz = enemy.data.z - obj.data.z
			local score = dx * dx + dz * dz * 4
			if score < dist then
				target, dist = enemy, score
			end
		end
	end
	return target
end

local function startAction(cdata, action, counter, duration)
	cdata.action = action
	cdata.action_until = counter + (duration or 1) - 1
end

local function addButton(buttons, key)
	if key then
		buttons[key] = true
	end
end

local function setInput(cdata, player, nextbuttons)
	local buttons = { }
	for key, value in pairs(nextbuttons or { }) do
		buttons[key] = value
	end
	local input = InputManager:encode(buttons)
	if cdata.lastinput ~= input then
		cdata.lastinput = input
		InputManager:setrawinput(input, player, InputManager.frame + 1)
	end
end

local Bot = Component:extend()

	local TARGET_REFRESH = 12
	local ATTACK_RANGE_X = 88
	local ATTACK_RANGE_Z = 14
	local TOO_CLOSE_X = 24
	local FAR_RANGE_X = 170
	local DEFEND_RANGE_X = 120
	local DEFEND_RANGE_Z = 18
	local RUN_TAP_INTERVAL = 10
	local STUCK_CHECK_INTERVAL = 45
	local STUCK_DISTANCE = 3

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- Adds `"bot"` key to the @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @return boolean
	function Bot:added(obj)
		if not obj then return false end
		obj.C.bot = self:wrap(obj)

		local data = obj.data
		data.player = data.player or 0
		
		local cdata = self:data(obj)
		cdata.counter = 0
		cdata.target = nil
		cdata.lastdir = 0
		cdata.lastinput = 0
		cdata.action = nil
		cdata.action_until = 0
		cdata.next_attack = 0
		cdata.next_defend = 0
		cdata.next_jump = 0
		cdata.stuck_until = 0
		cdata.stuck_dir = nil
		cdata.last_x = data.x
		cdata.last_z = data.z

		return true
	end

	--- Component was removed from @{l2df.class.entity|Entity} event.
	-- Removes `"bot"` key from @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	function Bot:removed(obj)
		obj.C.bot = nil
	end

	---
	function Bot:preupdate(obj, dt, islast)
		if not islast then return end
		local data = obj.data
		local cdata = self:data(obj)
		local player = data.player
		local counter = (cdata.counter or 0) + 1
		cdata.counter = counter

		if counter % TARGET_REFRESH == 1 or not isOpponent(obj, cdata.target) then
			cdata.target = findTarget(obj)
		end
		local target = cdata.target

		if not target then
			cdata.action = nil
			cdata.action_until = 0
			setInput(cdata, player)
			return
		end

		local dx = target.data.x - data.x
		local dz = target.data.z - data.z
		local absx, absz = abs(dx), abs(dz)
		local xdir = dx > 0 and 'right' or 'left'
		local away = dx > 0 and 'left' or 'right'
		local zdir = dz > 0 and 'down' or 'up'
		local target_dir = dx > 0 and 1 or -1
		local is_facing_target = data.facing == target_dir
		local target_faces_bot = target.data.facing == -target_dir
		local is_running = hasState(obj, 2)
		local is_airborne = not data.ground or hasState(obj, { 4, 5 })
		local is_aligned = absz <= ATTACK_RANGE_Z
		local is_in_range = absx <= ATTACK_RANGE_X and is_aligned
		local can_act = not data.stunned and not isBusy(obj)
		local buttons = { }

		if counter % STUCK_CHECK_INTERVAL == 0 then
			local moved = abs((data.x or 0) - (cdata.last_x or data.x or 0)) + abs((data.z or 0) - (cdata.last_z or data.z or 0))
			if moved < STUCK_DISTANCE and not is_in_range then
				cdata.stuck_until = counter + 18
				cdata.stuck_dir = roll(player, counter, 4, 2) == 1 and 'up' or 'down'
			end
			cdata.last_x, cdata.last_z = data.x, data.z
		end

		local defending =
			counter <= (cdata.action_until or 0) and cdata.action == 'defend' or
			target_faces_bot and absz <= DEFEND_RANGE_Z and absx <= DEFEND_RANGE_X and isAttacking(target)
		if defending and can_act and counter >= (cdata.next_defend or 0) then
			startAction(cdata, 'defend', counter, 6)
			cdata.next_defend = counter + 24 + roll(player, counter, 5, 12)
		elseif is_airborne and is_aligned and absx <= ATTACK_RANGE_X + 20 then
			startAction(cdata, 'attack', counter, 5)
		elseif can_act and is_facing_target and is_in_range and counter >= (cdata.next_attack or 0) then
			startAction(cdata, 'attack', counter, is_running and 3 or 1)
			cdata.next_attack = counter + (is_running and 22 or 14) + roll(player, counter, 6, 8)
		elseif can_act and is_facing_target and is_aligned and absx <= ATTACK_RANGE_X + 35 and counter >= (cdata.next_jump or 0) then
			startAction(cdata, 'jump', counter, 1)
			cdata.next_jump = counter + 55 + roll(player, counter, 7, 18)
		end

		if cdata.action and counter > (cdata.action_until or 0) then
			cdata.action = nil
		end

		if cdata.action == 'defend' then
			addButton(buttons, xdir)
		elseif absx < TOO_CLOSE_X and is_aligned then
			addButton(buttons, away)
		else
			if absz > ATTACK_RANGE_Z or counter <= (cdata.stuck_until or 0) then
				addButton(buttons, counter <= (cdata.stuck_until or 0) and cdata.stuck_dir or zdir)
			end
			if absx > TOO_CLOSE_X then
				local should_release_for_run = absx > FAR_RANGE_X and not is_running and counter % RUN_TAP_INTERVAL == 0
				if not should_release_for_run then
					addButton(buttons, xdir)
				end
			end
		end

		if cdata.action then
			addButton(buttons, cdata.action)
		end

		setInput(cdata, player, buttons)
	end

return Bot