--- Global Synchronized Identifier generator.
-- Its main advantages are simplicity and ability to revert its inner state.
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

	--- Configure @{l2df.manager.gsid|GSID} manager.
	-- @param[opt] table kwargs
	-- @param[opt=1] number kwargs.seed  Generator needs a number to start with (a `seed` value), to be able
	-- to generate GSID's sequences.
	-- @param[opt=1] number kwargs.step  Generator's fixed step value for updating the inner state by calling
	-- @{Manager:advance|GSID:advance()} method.
	-- @param[opt=1] number kwargs.salt  Additional salt used in hash generation. Can be used to generate different
	-- GSID's sequences for the same initial `seed`.
	-- @return l2df.manager.gsid
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		state = kwargs.seed or state or 1
		step = kwargs.step or step or 1
		salt = kwargs.salt or salt or 1
		counter = salt
		accumulator = 0
		return self
	end

	--- Advances inner counter used for generation of GSIDs.
	-- Note that it doesn't affect generator's state immediately because it updates with the @{Manager:init|fixed step}.
	-- So the specified delta will be accumulated and applied to the state as soon as it achieves the step value.
	-- @param number dt  Delta value to advance the inner generator's counter. Could be a positive or negative number.
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

	--- Generates next GSID @{Manager:hash|hash} value from the inner state.
	-- @return string  HEX representation of the generated GSID.
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

	--- Generates new GSID hash value using specified `state` and `salt`.
	-- @param number state  Source state value. Must be greater than `zero`.
	-- @param number salt  Additional salt value. Must be greater than `zero`.
	-- @return string  HEX representation of the generated GSID.
	function Manager:hash(state, salt)
		state, salt = hash(state, salt)
		return i2h(floor(state / 65536)) .. i2h(state % 65536) .. i2h(salt)
	end

	--- Generates random GSID.
	-- @return number  Number representation of the generated GSID.
	function Manager:rand()
		local a, b = hash(state, counter)
		counter = counter + 1
		return a * 65536 + b
	end

return setmetatable(Manager, { __call = Manager.init })