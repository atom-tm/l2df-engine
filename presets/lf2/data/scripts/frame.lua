local core = assert(l2df, 'L2DF is not available')

local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local max = math.max

local M = { }

local function number(value, default)
	if type(value) == 'number' then
		return value
	end
	if type(value) == 'string' then
		return tonumber(value:match('%-?%d+')) or default or 0
	end
	if type(value) == 'table' then
		return number(value[1], default)
	end
	return default or 0
end

local function hasStates(states, state)
	if type(states) ~= 'table' then
		return false
	end
	for i = 1, #states do
		local value = states[i]
		if number(value, -1) == state or type(value) == 'table' and number(value[1], -1) == state then
			return true
		end
	end
	return false
end

function M.number(value, default)
	return number(value, default)
end

function M.first(value)
	return number(value, nil)
end

function M.hasFrame(frame, state)
	return hasStates(frame and frame.states, state)
end

function M.hasState(data, state)
	return data and (hasStates(data.frame and data.frame.states, state) or hasStates(data.states, state)) or false
end

function M.entered(data, key)
	key = '___lf2_frame_' .. tostring(key or 'default')
	local id = data.frame and data.frame.id
	local generation = data.___frame_generation or 0
	local marker = tostring(id) .. ':' .. tostring(generation)
	if data[key] == marker then
		return false
	end
	data[key] = marker
	return true
end

function M.set(obj, id, input_triggered)
	local frames = obj and obj.C and obj.C.frames
	if not frames then
		return
	end
	frames.set(id, input_triggered and core:convert(1) or nil)
end

function M.addWait(obj, amount)
	local data = obj and obj.data
	if not (data and amount and amount ~= 0) then
		return
	end
	data.wait = (data.wait or 0) + amount
	data._lf2_hit_stop = max(data._lf2_hit_stop or 0, core:convert(amount))
	if data.frame then
		data.frame.wait = (data.frame.wait or 0) + amount
	end
end

return M
