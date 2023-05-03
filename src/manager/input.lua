--- Input manager.
-- Controls all available input sources and converts them to internal representation for unified use.
-- @classmod l2df.manager.input
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'InputManager works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'
local packer = core.import 'external.packer'
local Renderer = core.import 'manager.render'
local Resources = core.import 'manager.resource'

local pairs = _G.pairs
local tostring = _G.tostring
local min = math.min
local max = math.max
local ceil = math.ceil
local floor = math.floor
local strlen = string.len
local strbyte = string.byte
local tremove = table.remove
local ppack = packer.pack
local setKeyRepeat = core.api.io.keyRepeat
local loveGetPosition = core.api.io.mousePosition
local newQuad = core.api.data.quad

local inputs = { }

local EPS = 1e-10
local MAX_INT = 2 ^ 32
local CRC32 = {
	0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,     0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,     0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
	0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de,     0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
	0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,     0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,     0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
	0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940,     0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
	0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116,     0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
	0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,     0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
	0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a,     0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
	0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818,     0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
	0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,     0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
	0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c,     0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
	0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2,     0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
	0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,     0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
	0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086,     0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
	0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4,     0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
	0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,     0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
	0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8,     0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
	0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe,     0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
	0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,     0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
	0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252,     0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
	0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60,     0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
	0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,     0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
	0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04,     0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
	0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a,     0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
	0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,     0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
	0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e,     0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
	0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c,     0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
	0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,     0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
	0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0,     0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
	0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6,     0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
	0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,     0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
}

local function bit(p)
	return 2 ^ (p - 1)
end

local function bitor(x, y)
	local k, c = 1, 0
	while x + y > 0 do
		local rx, ry = x % 2, y % 2
		if rx + ry > 0 then c = c + k end
		x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
	end
	return c
end

local function bitxor(x, y)
	local k, c = 1, 0
	while x > 0 and y > 0 do
		local rx, ry = x % 2, y % 2
		if rx ~= ry then c = c + k end
		x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
	end
	x = x < y and y or x
	while x > 0 do
		local rx = x % 2
		if rx > 0 then c = c + k end
		x, k = (x - rx) / 2, k * 2
	end
	return c
end

local function bitand(x, y)
	local k, c = 1, 0
	while x > 0 and y > 0 do
		local rx, ry = x % 2, y % 2
		if rx == 1 and ry == 1 then c = c + k end
		x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
	end
	return c
end

local function rshift(x, y)
	return floor(x / (2 ^ y))
end

local function hasbit(x, p)
	return x % (p + p) >= p
end

local function setbit(x, p)
	return hasbit(x, p) and x or x + p
end

local function clearbit(x, p)
	return hasbit(x, p) and x - p or x
end

local function containsPoint(x, y, w, h, px, py, pz)
	return
		px - x > EPS and
		py - y > EPS and
		x + w - px > EPS and
		y + h - py > EPS
end

local function crc32(data)
	local crc = 0xFFFFFFFF
	for i = 1, strlen(tostring(data)) do
		local byte = strbyte(data, i)
		crc = bitxor(rshift(crc, 8), CRC32[bitxor(bitand(crc, 0xFF), byte) + 1])
	end
	crc = bitxor(crc, 0xFFFFFFFF)
	return crc < 0 and crc + MAX_INT or crc
end

local function newInput()
	return { data = 0, frame = 0, changes = 0, hash = 0xFFFFFFFF }
end

local function dummy() end

local tickrate = core.tickrate or 1
local double_timer = max(3, ceil(0.2 / tickrate))

local Manager = {
	frame = 0, delay = 0, timer = 0, mousex = 0, mousey = 0,
	buttons = { }, mapping = { }, touches = { }, touchmap = { }, consumed = { }, ui = { }, keys = { }, keymap = { }
}

	--- Configure @{l2df.manager.input|InputManager}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] table kwargs.keys
	-- @param[opt] number kwargs.uiwidth
	-- @param[opt] number kwargs.uiheight
	-- @param[opt] table kwargs.uilayout
	-- @param[opt] table kwargs.mappings
	-- @param[opt=false] boolean kwargs.key_repeat
	-- @param[opt=false] boolean kwargs.supportui
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		if kwargs.key_repeat ~= nil then
			setKeyRepeat(not not kwargs.key_repeat)
		end
		if kwargs.keys then
			self.keys = { }
			self.consumed = { }
			self.keymap = { }
			local keys = kwargs.keys
			for i = 1, #keys do
				self.keys[i] = { keys[i], bit(i) }
				self.consumed[i] = { }
				self.keymap[keys[i]] = i
			end
		end
		if kwargs.uilayout then
			self.ui = { }
			self.touches = { }
			self.touchmap = { }
			local w, h = kwargs.uiwidth or Renderer.width, kwargs.height or Renderer.height
			local ui = kwargs.uilayout
			for i = 1, #ui do
				for key, layout in pairs(ui[i]) do
					if self.keymap[key] then
						self.ui[#self.ui + 1] = layout
						layout.___key = key
						layout.___player = i
						if not layout.x then
							layout.x = layout.right and (w - layout.right) or layout.left or 0
						end
						if not layout.y then
							layout.y = layout.bottom and (h - layout.bottom) or layout.top or 0
						end
						if not layout.w then
							layout.x = layout.left or 0
							layout.w = layout.right and (layout.right - layout.x) or 0
						end
						if not layout.h then
							layout.y = layout.top or 0
							layout.h = layout.bottom and (layout.bottom - layout.y) or 0
						end
						-- layout.renders = layout.renders or { }
						for k = 1, #layout.renders do
							local r = layout.renders[k]
							r.x = (r.x or 0) + (layout.x or 0)
							r.y = (r.y or 0) + (layout.y or 0)
							r.w = r.w or layout.w or 0
							r.h = r.h or layout.h or 0
							r.z = r.z or layout.z or 0
							local obj = r.object
							local quad = r.quad
							if obj then
								if not Resources:loadAsync(obj, not quad and dummy or function (id, img)
									r.quad = newQuad(quad.ox, quad.oy, r.w, r.h, img:getDimensions())
								end) then
									log:error('Data error: %s', obj)
									break
								end
							end
						end
					end
				end
			end
		end
		if kwargs.supportui ~= nil then
			self.supportui = (not not kwargs.supportui) and #self.ui > 0
		end
		if kwargs.mappings then
			self:updateMappings(kwargs.mappings)
		end
		self.localplayers = self.localplayers or 0
		self:reset(self.remoteplayers)
		return self
	end

	--- Reset all inputs and timer of manager.
	-- @param[opt=0] number remote
	function Manager:reset(remote)
		self.timer = 0
		self.frame = 0
		self.delay = 0
		self.remoteplayers = remote or 0
		tickrate = core.tickrate or tickrate
		double_timer = max(3, ceil(0.2 / tickrate))
		inputs = { }
		for p = 1, self.localplayers do
			self.buttons[p] = { }
			inputs[p] = newInput()
		end
		for p = self.localplayers + 1, self.localplayers + self.remoteplayers do
			inputs[p] = newInput()
		end
	end

	--- Advance timer and frame.
	function Manager:advance()
		self.frame = self.frame + 1
		self.timer = max(self.timer, self.frame + self.delay)
	end

	--- Update inputs and render UI for mobile.
	function Manager:update()
		for p = 1, self.localplayers + self.remoteplayers do
			local it = inputs[p]
			while it.prev and it.frame >= self.frame do
				it = it.prev
			end
			while it.next and it.next.frame <= self.frame do
				it = it.next
			end
			if it ~= inputs[p] then
				for k = 1, #self.consumed do
					self.consumed[k][p] = nil
				end
			end
			-- log:info('B%02d F%02d [%04x|%05d] -> [%04x|%05d] -> [%04x|%05d]', b, f, it.prev.data, it.prev.frame, it.data, it.frame, it.next.data, it.next.frame)
			inputs[p] = it
		end
		if self.supportui then
			for i = 1, #self.ui do
				local renders = self.ui[i].renders
				for k = 1, #renders do
					Renderer:draw(renders[k])
				end
			end
		else
			self.mousex, self.mousey = loveGetPosition()
		end
	end

	--- Create input source for remote player.
	-- @return number  player's id
	function Manager:newRemotePlayer()
		self.remoteplayers = self.remoteplayers + 1
		inputs[self.localplayers + self.remoteplayers] = newInput()
		return self.localplayers + self.remoteplayers
	end

	--- Sync mappings with config.
	-- @param table mappings
	function Manager:updateMappings(mappings)
		self.mapping = { }
		self.localplayers = #mappings
		for p = 1, self.localplayers do
			inputs[p] = newInput()
			self.buttons[p] = { }
			for k, v in pairs(mappings[p]) do
				if self.keymap[k] then
					self.mapping[v] = { k, p }
				end
			end
		end
	end

	--- Check if button was pressed at this frame.
	-- @param string button  Hitted button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:hitted(button, player, ignore_remotes)
		local keycode = self.keymap[button]
		if keycode then
			keycode = self.keys[keycode][2]
			local input = nil
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				input = inputs[p]
				local ishitted = input and input.frame == self.frame and hasbit(input.data, keycode)
				local prev = input and input.prev
				if ishitted and (not prev or prev.frame ~= self.frame and not hasbit(prev.data, keycode)) then
					return true, p
				end
			end
		end
		return false
	end

	--- Check if button was pressed at this frame and consume it for next call.
	-- @param string button  Hitted button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:consume(button, player, ignore_remotes)
		local keycode = self.keymap[button]
		if keycode then
			local consumed = self.consumed[keycode]
			local input = nil
			keycode = self.keys[keycode][2]
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				if consumed[p] then
					return false
				end
				input = inputs[p]
				local ishitted = input and input.frame == self.frame and hasbit(input.data, keycode)
				local prev = input and input.prev
				if ishitted and (not prev or prev.frame ~= self.frame and not hasbit(prev.data, keycode)) then
					consumed[p] = true
					return true, p
				end
			end
		end
		return false
	end

	--- Check if button was pressed.
	-- @param string button  Pressed button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:pressed(button, player, ignore_remotes)
		local index = self.keymap[button]
		if index then
			index = self.keys[index][2]
			local input = nil
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				input = inputs[p]
				if input and hasbit(input.data, index) then
					return true, p
				end
			end
		end
		return false
	end

	--- Check if button was double pressed.
	-- @param string button  Doubled button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:doubled(button, player, ignore_remotes)
		local index = self.keymap[button]
		if index then
			index = self.keys[index][2]
			local timer, c, a, b, it = self.frame - double_timer
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				it, c, a, b = inputs[p], 0, true, false
				while it and it.frame >= timer do
					if hasbit(it.data, index) then
						if not a then break end
						c = c + 1
						a, b = b, a
					elseif b then
						c = c + 1
						a, b = b, a
					end
					it = it.prev
				end
				if c > 2 then
					return true, p
				end
			end
		end
		return false
	end

	--- Check if input data exists.
	-- @param number data
	-- @param number player
	-- @return boolean
	function Manager:check(data, player)
		local input = inputs[player or 1]
		return input and hasbit(input.data, data) or false
	end

	--- Get last saved input for specific player.
	-- @param number player
	-- @return number
	function Manager:lastinput(player)
		local input = inputs[player or 1]
		return input-- and input.data or 0
	end

	local function debuginput(player, timer)
		local it, data, behind = inputs[player], { }, 0
		while it.next do
			it = it.next
			behind = behind + 1
		end
		for i = 1, 6 do
			data[i] = string.format('[%02d][%05d]', it.data, it.frame)
			if not it.prev then break end
			it = it.prev
		end
		log:info(string.format('INPUT[%s] %s | %05d', player, table.concat(data, ' '), timer))
		print(string.rep('_', 7 + 12 * behind) .. '/')
	end

	--- Persist raw input data.
	-- @param number input
	-- @param[opt=1] number player
	-- @param[opt] number timer   Default is current timer.
	-- @return[1] l2df.manager.input
	-- @return[2] l2df.manager.input
	-- @return[2] table
	function Manager:addinput(input, player, timer)
		player = player or 1
		if player > self.localplayers + self.remoteplayers then
			return self
		end
		timer = timer or self.timer
		local left = inputs[player]
		local right = left and left.next
		while left and left.frame > timer do
			right, left = left, left.prev
		end
		while right and right.frame <= timer do
			left, right = right, right.next
		end
		if left and left.data == input then
			return self, left
		elseif left and left.frame == timer then
			-- TODO: fix this input merger
			-- local xor = bitxor(left.data, input)
			-- local changes = bitxor(xor, left.changes)
			-- if bitor(xor, changes) == changes then
			-- 	left.data = input
			-- 	left.changes = changes
			-- 	log:info('INPUT[%05d] for player %s WAS MERGED at %05d!!!', input, player, timer)
			-- 	-- debuginput(player, timer)
			-- 	return self
			-- end
			return self:addinput(input, player, timer + 1)
		end
		local new = {
			prev = left,
			next = right,
			data = input,
			changes = input,
			frame = timer,
			hash = 0xFFFFFFFF,
		}
		if left then
			new.hash = crc32(ppack('III', left.hash, input, timer))
			new.changes = bitxor(left.data, input)
			left.next = new
		end
		if right then
			right.prev = new
			while right do
				right.hash = crc32(ppack('III', right.prev.hash, right.data, right.frame))
				right = right.next
			end
		end
		-- inputs[player] = new
		self.timer = timer
		self.frame = min(timer, self.frame)
		-- debuginput(player, timer)
		return self, new
	end

	--- Save input data for local player.
	-- @param[opt] number player ...
	-- @param[opt] number frame   Default is current timer.
	-- @return number
	function Manager:saveinput(player, frame)
		for p = player or 1, player or self.localplayers do
			self:addinput(self:rawinput(p), p, frame)
		end
		return self
	end

	--- Stream-function which should be used in `for ... in stream` loops.
	-- @param[opt=1] number player  
	-- @return[1] function  Execution data of the returned function is listed below:
	-- @return[2] number  Player ID.
	-- @return[2] number  Frame number.
	-- @return[2] number  Input data.
	-- @return[2] number  CRC32 checksum.
	function Manager:stream(player)
		local it = { }
		local from, to = player or 1, player or (self.localplayers + self.remoteplayers)
		for p = 1, to do
			it[p] = inputs[p]
		end
		return function ()
			for p = from, to do
				if it[p].next and it[p].next.frame < self.timer then
					it[p] = it[p].next
					return p, it[p].frame, it[p].data, it[p].hash
				end
			end
		end
	end

	--- Get raw input data for local player.
	-- @param number player
	-- @return number
	function Manager:rawinput(player)
		local buttons = self.buttons[player or 1]
		if not buttons then return 0 end

		local input, kc = 0
		for i = 1, #self.keys do
			kc = self.keys[i]
			if buttons[kc[1]] then
				input = setbit(input, kc[2])
			end
		end
		return input
	end

	--- Button pressed event.
	-- @param string button  Pressed button.
	-- @param number player  Player index.
	function Manager:press(button, player)
		player = player or 1
		self.buttons[player][button] = true
		self:saveinput(player)
	end

	--- Button released event.
	-- @param string button  Released button.
	-- @param number player  Player index.
	function Manager:release(button, player)
		player = player or 1
		self.buttons[player][button] = false
		self:saveinput(player)
	end

	--- Hook for love.keypressed.
	-- @param string key
	function Manager:keypressed(key)
		local map = self.mapping[key]
		if map then
			self:press(map[1], map[2])
		end
	end

	--- Hook for love.keyreleased.
	-- @param string key
	function Manager:keyreleased(key)
		local map = self.mapping[key]
		if map then
			self:release(map[1], map[2])
		end
	end

	--- Hook for love.mousepressed.
	-- @param number x
	-- @param number y
	-- @param number btn
	-- @param boolean istouch
	function Manager:mousepressed(x, y, btn, istouch)
		if istouch then return end
		btn = btn == 1 and 'lmb' or btn == 2 and 'rmb' or 'mmb'
		self.mousex, self.mousey = x, y
		self:keypressed(btn)
		-- self:touchpressed(1, x, y)
		-- self.lmb = true
	end

	--- Hook for love.mousereleased.
	-- @param number x
	-- @param number y
	-- @param number btn
	-- @param boolean istouch
	function Manager:mousereleased(x, y, btn, istouch)
		if istouch then return end
		btn = btn == 1 and 'lmb' or btn == 2 and 'rmb' or 'mmb'
		self:keyreleased(btn)
		-- self:touchreleased(1, x, y)
		-- self.lmb = false
	end

	--- Hook for love.mousemoved.
	function Manager:mousemoved(x, y, dx, dy, istouch)
		if not self.lmb then return end
		self:touchmoved(1, x, y, dx, dy)
	end

	--- Hook for love.touchpressed.
	function Manager:touchpressed(id, x, y, dx, dy, pressure)
		id = tostring(id)
		local lmb = true
		local sx, sy = Renderer:screenToGame(x, y)
		local touches = self.touches[id] or { }
		self.touches[id] = touches
		for i = 1, #self.ui do
			local btn = self.ui[i]
			if containsPoint(btn.x, btn.y, btn.w, btn.h, sx, sy) then
				lmb = false
				self:press(btn.___key, btn.___player)
				self.touchmap[i] = id
				touches[#touches + 1] = i
			end
		end
		if lmb then
			self.mousex, self.mousey = x, y
			self:keypressed('lmb')
		end
	end

	--- Hook for love.touchreleased.
	function Manager:touchreleased(id, x, y, dx, dy, pressure)
		id = tostring(id)
		local touches = self.touches[id]
		if touches and #touches > 0 then
			for i = #touches, 1, -1 do
				local btn = self.ui[touches[i]]
				if self.touchmap[touches[i]] == id then
					self:release(btn.___key, btn.___player)
					self.touchmap[touches[i]] = nil
				end
				touches[i] = nil
			end
		else
			self:keyreleased('lmb')
		end
	end

	--- Hook for love.touchmoved.
	function Manager:touchmoved(id, x, y, dx, dy, pressure)
		id = tostring(id)
		local sx, sy = Renderer:screenToGame(x, y)
		local pending = { }
		local touches = self.touches[id]
		for i = 1, #self.ui do
			local btn = self.ui[i]
			if containsPoint(btn.x, btn.y, btn.w, btn.h, sx, sy) then
				if not self.touchmap[i] then
					self:press(btn.___key, btn.___player)
					self.touchmap[i] = id
					touches[#touches + 1] = i
				end
			elseif self.touchmap[i] == id then
				pending[#pending + 1] = i
			end
		end
		if #pending > 0 and #touches > 1 then
			for i = #pending, 1, -1 do
				local btn = self.ui[pending[i]]
				for j = #touches, 1, -1 do
					if touches[j] == pending[i] then
						tremove(touches, j)
						self:release(btn.___key, btn.___player)
						self.touchmap[pending[i]] = nil
					end
				end
			end
		end
	end

return setmetatable(Manager, { __call = Manager.init })