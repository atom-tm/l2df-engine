--- Backend API Wrapper.
-- @module l2df.api
-- @author Abelidze
-- @copyright Atom-TM 2022

local prefix = (...):match('(.-)[^%.]+$')

local function NotImplementedException(method)
	return function () error('NotImplementedException: ' .. method, 2) end
end

local function cloneByInterface(src, dst, interface)
	local t = nil
	for k, v in pairs(interface) do
		t = type(v)
		if t == 'table' then
			dst[k] = cloneByInterface(src[k] or v, dst[k] or { }, v)
		elseif t == 'function' then
			dst[k] = src[k] or v
		end
	end
	dst.BACKEND = src.BACKEND or nil
	return dst
end

local interface = {
	audio = {
		play = NotImplementedException('audio.play'),
		stop = NotImplementedException('audio.stop'),
	},
	data = {
		audio = NotImplementedException('data.audio'),
		image = NotImplementedException('data.image'),
		video = NotImplementedException('data.video'),
		stream = NotImplementedException('data.stream'),
		pixels = NotImplementedException('data.pixels'),
		file = NotImplementedException('data.file'),
		font = NotImplementedException('data.font'),
		quad = NotImplementedException('data.quad'),
		canvas = NotImplementedException('data.canvas'),
	},
	event = {
		pump = NotImplementedException('event.pump'),
		push = NotImplementedException('event.push'),
		poll = NotImplementedException('event.poll'),
		quit = NotImplementedException('event.quit'),
		clear = NotImplementedException('event.clear'),
	},
	render = {
		active = NotImplementedException('render.active'),
		blend = NotImplementedException('render.blend'),
		mode = NotImplementedException('render.mode'),
		color = NotImplementedException('render.color'),
		canvas = NotImplementedException('render.canvas'),
		scissor = NotImplementedException('render.scissor'),
		lineWidth = NotImplementedException('render.lineWidth'),
		defaultFilter = NotImplementedException('render.defaultFilter'),
		backgroundColor = NotImplementedException('render.backgroundColor'),
		draw = NotImplementedException('render.draw'),
		clear = NotImplementedException('render.clear'),
		printf = NotImplementedException('render.printf'),
		circle = NotImplementedException('render.circle'),
		ellipse = NotImplementedException('render.ellipse'),
		rectangle = NotImplementedException('render.rectangle'),
		push = NotImplementedException('render.push'),
		pop = NotImplementedException('render.pop'),
		scale = NotImplementedException('render.scale'),
		translate = NotImplementedException('render.translate'),
		rotate = NotImplementedException('render.rotate'),
		origin = NotImplementedException('render.origin'),
		present = NotImplementedException('render.present'),
	},
	time = {
		now = NotImplementedException('time.now'),
		sleep = NotImplementedException('time.sleep'),
		delta = NotImplementedException('time.delta'),
	},
	async = {
		start = NotImplementedException('async.start'),
		create = NotImplementedException('async.create'),
		isrunning = NotImplementedException('async.isrunning'),
		yield = NotImplementedException('async.yield'),
		channel = NotImplementedException('async.channel'),
	},
	io = {
		mousePosition = NotImplementedException('io.mousePosition'),
		keyRepeat = NotImplementedException('io.keyRepeat'),
		textInput = NotImplementedException('io.textInput'),
		requirePath = NotImplementedException('requirePath'),
		sourceDirectory = NotImplementedException('sourceDirectory'),
		directoryItems = NotImplementedException('directoryItems'),
		realDirectory = NotImplementedException('realDirectory'),
		workingDirectory = NotImplementedException('workingDirectory'),
		saveDirectory = NotImplementedException('saveDirectory'),
		getSource = NotImplementedException('getSource'),
		getInfo = NotImplementedException('getInfo'),
		mount = NotImplementedException('mount'),
		mkdir = NotImplementedException('mkdir'),
		read = NotImplementedException('read'),
	},
}

local backend = interface
if type(love) == 'table' and love._version then
	backend = require(prefix .. 'api.love')
elseif not os.getenv('L2DF_LUA_FALLBACK') then
	backend = require(prefix .. 'api.lua')
end

local api = cloneByInterface(backend, { }, interface)

	--- Configure @{l2df.api|API}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] string|table kwargs.backend  Set backend. One of: love, defold, lua or your custom backend.
	-- @return l2df.api
	function api:init(kwargs)
		kwargs = kwargs or { }
		if type(kwargs.backend) == 'string' then
			cloneByInterface(require(prefix .. kwargs.backend), self, interface)
		elseif type(kwargs.backend) == 'table' then
			cloneByInterface(kwargs.backend, self, interface)
		end
		return self
	end

return api