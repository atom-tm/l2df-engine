--- Global Synchronized Identifier
-- @classmod l2df.manager.gsid
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require((...):match('(.-)manager.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'GSID works only with l2df v1.0 and higher')

local step = 1
local state = 1
local salt = 1
local counter = 0
local accumulator = 0

local ceil = math.ceil
local floor = math.floor
local strsub = string.sub
local strjoin = table.concat

local HEXES = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}

local function i2h(x, l)
	local s, l, d = '', l or 4
	while x > 0 do
		d = x % 16 + 1
		x = floor(x / 16)
		s = HEXES[d] .. s
	end
	while #s < l do s = '0' .. s end
	return s
end

local function xor(a, b)
	local p, c = 1, 0
	while a > 0 and b > 0 do
		local ra, rb = a % 2, b % 2
		if ra ~= rb then c = c + p end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	if a < b then a = b end
	while a > 0 do
		local ra = a % 2
		if ra > 0 then c = c + p end
		a, p = (a - ra) / 2, p * 2
	end
	return c
end

local Manager = { }

	---
	function Manager:seed(offset, gstep, gsalt)
		state = offset or state or 1
		step = gstep or step or 1
		salt = gsalt or salt or 1
		counter = salt
		accumulator = 0
	end

	--- 
	-- @param number dt
	function Manager:advance(dt)
		accumulator = accumulator + dt
		local delta = 0
		if accumulator >= step then
			delta = floor(accumulator / step)
			accumulator = accumulator % step
		elseif accumulator < 0 then
			delta = -ceil(-accumulator / step)
			accumulator = -(-accumulator % step)
		end
		if delta ~= 0 then
			state = state + delta
			counter = salt
		end
	end

	---
	-- @return string
	function Manager:generate()
		local h = self:hash(state, counter)
		counter = counter + 1
		return h
	end

	local function hash(state, salt)
		state = xor(floor(state / 65536), state) * 73244475 % 4294967296
		state = xor(floor(state / 65536), state) * 73244475 % 4294967296
		state = xor(floor(state / 65536), state) % 4294967296
		salt = xor(floor(salt / 256), salt) * 2654435761 % 65536
		salt = xor(floor(salt / 256), salt) * 2654435761 % 65536
		salt = xor(floor(salt / 256), salt) % 65536
		return state, salt
	end

	--- 
	-- @return string
	function Manager:hash(state, salt)
		state, salt = hash(state, salt)
		return i2h(floor(state / 65536)) .. i2h(state % 65536) .. i2h(salt)
	end

	--- 
	-- @return number
	function Manager:rand()
		local a, b = hash(state, counter)
		counter = counter + 1
		return a * 65536 + b
	end

return Manager