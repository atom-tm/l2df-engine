--- Simple AI controller. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.ai.bot
-- @author Abelidze
-- @copyright Atom-TM 2023

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'AI works only with l2df v1.0 and higher')

local abs = math.abs
local floor = math.floor
local rand = math.random
local sqrt = math.sqrt

local Component = core.import 'class.component'
local InputManager = core.import 'manager.input'

local lastdir = 0

local Bot = Component:extend()

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
		cdata.movement_states = { 2, 4, 5 }
		cdata.unavailable_states = { 14 }
		cdata.actions = { 'attack', 'jump', 'defend' }
		cdata.directions = { 'left', 'right', 'up', 'down' }

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
		local states = obj.C.states
		local player = data.player
		local target = cdata.target
		local actions = cdata.actions
		local directions = cdata.directions
		local counter = cdata.counter
		cdata.counter = counter + 1

		if counter % 120 == 0 then
			if not obj.parent then return end
			target = nil
			local dist = 1e12
			for enemy in obj.parent:enum(true, true) do
				if enemy.data.player and enemy.data.player ~= player and enemy.C.attr.data().hp > 0 then
					local dx = enemy.data.x - obj.data.x
					local dz = enemy.data.z - obj.data.z
					local d = sqrt(dx * dx + dz * dz)
					if d < dist then
						target = enemy
						dist = d
					end
				end
			end
			cdata.target = target
		end

		if not target then
			InputManager:release(directions[lastdir], player)
			lastdir = 0
			return
		end

		local dx = target.data.x - data.x
		local dz = target.data.z - data.z
		local dir = dx > 0 and 2 or 1
		local isFacingTarget = data.facing == (dx > 0 and 1 or -1)
		local isRunning = states.has(cdata.movement_states)
		local isInRange = abs(dx) < 100 and abs(dz) < 10
		local isVeryClose = abs(dx) < 50 and abs(dz) < 10
		if (isVeryClose or isFacingTarget and isInRange and isRunning) and not target.C.states.has(cdata.unavailable_states) then
			InputManager:release(directions[lastdir], player):press(directions[dir], player)
			InputManager:press(actions[1], player):release(actions[1], player)
			if data.debug then print('ATTACK', dir, lastdir) end
			lastdir = 0
			return
		end

		if counter % 5 == 0 then
			local is_chasing = obj.C.attr.data().hp > 150
			if abs(dx) < 200 then
				if rand(3) == 1 then
					dir = rand(1, #directions)
				elseif abs(dx) > abs(dz) then
					dir = (dx > 0 == is_chasing) and 2 or 1
				else
					dir = (dz > 0 == is_chasing) and 4 or 3
				end 
				if data.debug then print('WALK', directions[dir], directions[lastdir]) end
				if dir ~= lastdir then
					InputManager:release(directions[lastdir], player):press(directions[dir], player)
					lastdir = dir
				end
			elseif not isRunning then
				if data.debug then print('RUN', directions[dir]) end
				InputManager:release(directions[lastdir], player)
				InputManager:press(directions[dir], player):release(directions[dir], player)
				InputManager:press(directions[dir], player):release(directions[dir], player)
				lastdir = 0
			end
		end

		if counter % 30 == 0 then
			local action = actions[rand(0, #actions)]
			InputManager:press(action, player):release(action, player)
		end
	end

return Bot