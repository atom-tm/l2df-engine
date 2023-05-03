--- Pure Lua API Wrapper.
-- @module l2df.api.lua
-- @author Abelidze
-- @copyright Atom-TM 2022

local socket_ok, socket = pcall(require, 'socket')

local select = _G.select
local unpack = _G.unpack or table.unpack
local fopen = io.open
local popen = io.popen
local getinfo = debug.getinfo
local sep = package.config:sub(1, 1)
local env = sep == '\\' and 'dos' or 'unix'
local cmd = env == 'dos' and 'cd' or 'pwd'
local dir = env == 'dos' and 'dir /B ' or 'ls -A1 '
local seps = env == 'dos' and { ['/'] = true, ['\\'] = true } or { ['/'] = true }
local source = nil
local timer = 0
local channels = { }
local events = { _l = 0, _r = 0 }
local function dummy() end
local function mockObj(methods)
	local mt = { __index = methods or { } }
	return function ()
		return setmetatable({ }, mt)
	end
end
local function cachedData(isobj, ...)
	local data = { ... }
	return function (o, ...)
		if select('#', ...) == 0 and isobj == (o ~= nil) then
			return unpack(data)
		elseif isobj then
			data = { ... }
		else
			data = { o, ... }
		end
	end
end

local api = {
	BACKEND = 'lua',
	audio = {
		play = dummy,
		stop = dummy,
	},
	data = {
		audio = mockObj(),
		image = mockObj { getDimensions = cachedData(true, 1, 1) },
		video = mockObj { play = dummy, pause = dummy, rewind = dummy, isPlaying = cachedData(true, false) },
		stream = mockObj(),
		pixels = mockObj(),
		file = mockObj(),
		font = mockObj { getWidth = cachedData(true, 100) },
		quad = mockObj(),
		canvas = mockObj(),
	},
	event = {
		pump = dummy,
	},
	render = {
		active = function () return false end,
		blend = cachedData('alpha', 'alphamultiply'),
		mode = cachedData(false, 1, 1, { }),
		color = cachedData(false, 1, 1, 1, 1),
		scissor = cachedData(false, 0, 0, 0, 0),
		lineWidth = cachedData(false, 1),
		canvas = cachedData(),
		defaultFilter = cachedData(false, 'nearest', 'nearest', 1),
		backgroundColor = cachedData(false, 0, 0, 0, 1),
		draw = dummy,
		clear = dummy,
		printf = dummy,
		circle = dummy,
		ellipse = dummy,
		rectangle = dummy,
		push = dummy,
		pop = dummy,
		scale = dummy,
		translate = dummy,
		rotate = dummy,
		origin = dummy,
		present = dummy,
	},
	time = {
		now = os.time,
		sleep = socket_ok and socket.sleep or function(t) os.execute('sleep ' .. t) end,
		delta = function(t) t = os.clock() - timer; timer = timer + t; return t end,
	},
	async = {
		yield = coroutine.yield,
	},
	io = {
		mousePosition = cachedData(false, 0, 0),
		keyRepeat = cachedData(false, false),
		textInput = cachedData(false, false),
		mount = dummy,
	},
}

	local function ccount(c)
		return c._r - c._l
	end

	local function cclear(c)
		for i = c._l + 1, c._r do
			c[i] = nil
		end
		c._l, c._r = 0, 0
	end

	local function cpush(c, value)
		c._r = c._r + 1
		c[c._r] = value
	end

	local function cpop(c)
		if ccount(c) == 0 then
			return
		end
		c._l = c._l + 1
		local value = c[c._l]
		c[c._l] = nil
		if ccount(c) == 0 then
			c._l, c._r = 0, 0
		end
		return value
	end

	function api.async.create(f)
		return { f = load(f), co = nil }
	end

	function api.async.start(t, ...)
		t.co = coroutine.create(t.f)
		coroutine.resume(t.co, ...)
	end

	function api.async.isrunning(t)
		if t.co and coroutine.status(t.co) ~= 'dead' then
			return coroutine.resume(t.co)
		end
		return false
	end

	function api.async.channel(name)
		local obj = channels[name or dummy] or {
			clear = cclear,
			push = cpush,
			pop = cpop,
			getCount = ccount,
			_l = 0,
			_r = 0,
		}
		if name and not channels[name] then
			channels[name] = obj
		end
		return obj
	end

	function api.event.push(...)
		cpush(events, { ... })
	end

	function api.event.poll()
		return function()
			local result = cpop(events)
			return result and unpack(result) or nil
		end
	end

	function api.event.quit(...)
		cpush(events, { 'quit', ... })
	end

	function api.event.clear()
		cclear(events)
	end

	function api.io.requirePath(path)
		package.path = path
	end

	function api.io.directoryItems(path)
		local h = popen(dir .. path:gsub('[/\\]', sep))
		local result, i = { }, 0
		repeat
			i = i + 1
			result[i] = h:read()
		until result[i] == nil
		h:close()
		return result
	end

	function api.io.realDirectory(path)
		path = path:gsub('[\\/]$', '')
		local roots = { api.io.saveDirectory(), api.io.sourceDirectory(), api.io.workingDirectory() }
		for i = 1, #roots do
			if api.io.getInfo(api.io.abspath(path, roots[i])) then
				return roots[i]
			end
		end
		return nil
	end

	function api.io.isabs(path)
		if env == 'dos' and path:sub(2, 2) == ':' then
			return seps[path:sub(3, 3)] ~= nil
		end
		return seps[path:sub(1, 1)] ~= nil
	end

	function api.io.abspath(path, pwd)
		pwd = pwd or api.io.workingDirectory()
		local p1, p2 = path:sub(1, 1), path:sub(2, 2)
		if not api.io.isabs(path) then
			path = pwd .. '/' .. path
		elseif env == 'dos' and p1 ~= '/' and p2 ~= ':' and p2 ~= '\\' then
			path = pwd:sub(1, 2) .. path
		end
		return path
	end

	function api.io.sourceDirectory()
		return api.io.getSource()
	end

	function api.io.workingDirectory()
		return popen(cmd):read()
	end

	function api.io.saveDirectory()
		return api.io.getSource()
	end

	function api.io.getInfo(path)
		local t = 'file'
		local f, err = fopen(path, 'rb')
		if f then
			f:close()
		elseif not err:match('Permission denied') then
			return nil
		else
			t = 'directory'
		end
		return {
			type = t,
			size = nil,
			modtime = nil,
		}
	end

	function api.io.getSource()
		if source == nil then
			local i, src, prev = 1, ''
			while src and src ~= '=[C]' do
				prev, src = src, (getinfo(i, 'S') or { }).source
				i = i + 1
			end
			src = (prev or _G.arg[1] or _G.arg[0]):match('@?(.*[/\\])') or ''
			source = api.io.abspath(src):sub(1, -2):gsub('\\', '/')
		end
		return source
	end

	function api.io.mkdir(path)
		path = api.io.abspath(path, api.io.saveDirectory()):gsub('[/\\]', sep)
		if env == 'dos' then
			os.execute('mkdir ' .. path .. ' >nul 2>&1')
		else
			os.execute('mkdir -p ' .. path)
		end
		return true
	end

	function api.io.read(path, size)
		size = size or '*a'
		local f = fopen(path, 'rb')
		if f then
			local data = f:read(size)
			f:close()
			return data
		end
		return nil
	end

return api