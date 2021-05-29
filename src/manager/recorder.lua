--- Recorder manager (replays).
-- @classmod l2df.manager.recorder
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Recorder works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local log = core.import 'class.logger'
local Input = core.import 'manager.input'
local Sync = core.import 'manager.sync'

local type = _G.type
local pairs = _G.pairs
local assert = _G.assert
local fopen = io.open
local strgmatch = string.gmatch
local strchar = string.char
local strbyte = string.byte
local strbyte = string.byte
local strjoin = table.concat
local floor = math.floor

local data = { }
local function ntobi(number)
	for i = 4, 1, -1 do
		data[i] = strchar(number % 256)
		number = floor(number / 256)
	end
	return strjoin(data, '')
end
local function biton(bin)
	local x = 0
	for i = 1, 4 do
		x = x * 256 + strbyte(bin, i)
	end
	return x
end

local h2b = {
	['0']='0000', ['1']='0001', ['2']='0010', ['3']='0011',
	['4']='0100', ['5']='0101', ['6']='0110', ['7']='0111',
	['8']='1000', ['9']='1001', ['A']='1010', ['B']='1011',
	['C']='1100', ['D']='1101', ['E']='1110', ['F']='1111'
}
local function hex2bin(n)
  return string.format('%04X', n):gsub(".", h2b)
end

local function dummyFunc() end

local records = { }

local Manager = { }

	--- Configure @{l2df.manager.recorder|RecorderManager}.
	-- @param[opt] table kwargs  Keyword arguments. Not actually used.
	-- @return l2df.manager.recorder
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		return self
	end

	--- Start replay recording.
	-- @param string path  Path to the file for writing replay on disk storage.
	-- @param[opt] string metadata  Optional metadata included in the replay header.
	-- @param[opt] function stream  Function called on each @{Manager:update|update}.
	-- This function should return three numbers:<br>
	-- * `player` - Player ID for this input;
	-- * `frame` - Frame ID at which input appeared;
	-- * `input` - Raw encoded @{l2df.manager.input.rawinput|input data}, 32-bit unsigned integer.
	-- @param[opt=1] number period
	function Manager:start(path, metadata, stream, period)
		local f = assert(fopen(path, 'wb'), 'Can not open "' .. path .. '" for recording')
		if type(metadata) == 'string' then
			f:write(#metadata, metadata)
		else
			f:write(0)
		end
		f:close()
		records[path] = { timer = 0, stream = stream or dummyFunc, freq = period or 1 }
	end

	--- Stop replay recording.
	-- @param string path  Path to the replay file which was previously passed to the @{Manager:start|Recorder:start()}.
	function Manager:stop(path)
		if path then
			records[path] = nil
		else
			records = { }
		end
	end

	--- Open replay file and load its data to @{l2df.manager.input.addinput|InputManager}.
	-- @param string path  Path to the replay file.
	-- @param function loader
	function Manager:open(path, loader)
		local f, err = fopen(path, 'rb')
		if not f then
			log:error('Can\'t load replay "%s": %s', path, err)
			return false
		end
		local n = f:read('*n')
		local meta = assert(f:read(n), 'Record loading failed: no metadata found')
		self:close()
		loader(meta)
		-- local debug = { }
		while true do
			local block = f:read(12 * 100)
			if not block then break end
			for player, frame, input in strgmatch(block, '(....)(....)(....)') do
				player, frame, input = Input.localplayers + biton(player), biton(frame), biton(input)
				-- debug[#debug + 1] = { player, hex2bin(input), frame }
				Input:addinput(input, player, frame)
			end
		end
		-- table.sort(debug, function (a, b) if a[3] == b[3] then print('SAME', a[3]) end;return a[3] < b[3] end)
		-- for i = 1, #debug do
		-- 	log:info('Input[%d] %s at frame %05d', debug[i][1], debug[i][2], debug[i][3])
		-- end
		return true
	end

	--- Resets @{l2df.manager.input.reset|Input} and @{l2df.manager.sync.reset|Sync} managers.
	function Manager:close()
		Input:reset()
		Sync:reset()
	end

	--- Process all records and append data to replay files.
	-- @param number dt  Delta-time since last game tick.
	function Manager:update(dt)
		for path, record in pairs(records) do
			record.timer = record.timer + dt
			if record.timer >= record.freq then
				record.timer = 0
				local f = assert(fopen(path, 'ab'))
				for player, frame, input in record.stream do
					f:write(ntobi(player), ntobi(frame), ntobi(input))
				end
				f:close()
			end
		end
	end

return setmetatable(Manager, { __call = Manager.init })