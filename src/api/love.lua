--- LÖVE API Wrapper.
-- @module l2df.api.love
-- @author Abelidze
-- @copyright Atom-TM 2022

local lwindow = love.window or { }
local laudio = love.audio or { }
local levent = love.event or { }
local lvideo = love.video or { }
local limage = love.image or { }
local lgraphics = love.graphics or { }
local lmouse = love.mouse or { }
local ltimer = love.timer or { }
local lkeyboard = love.keyboard or { }
local lthread = love.thread or { }
local lfilesystem = love.filesystem or { }
local getMode = lwindow.getMode
local setMode = lwindow.setMode
local getColor = lgraphics.getColor
local setColor = lgraphics.setColor
local getLineWidth = lgraphics.getLineWidth
local setLineWidth = lgraphics.setLineWidth
local getScissor = lgraphics.getScissor
local setScissor = lgraphics.setLineWidth
local getRequirePath = lfilesystem.getRequirePath
local setRequirePath = lfilesystem.setRequirePath
local getDefaultFilter = lgraphics.getDefaultFilter
local setDefaultFilter = lgraphics.setDefaultFilter
local getBackgroundColor = lgraphics.getBackgroundColor
local setBackgroundColor = lgraphics.setBackgroundColor
local getBlendMode = lgraphics.getBlendMode
local setBlendMode = lgraphics.setBlendMode
local function dummy() end

local api = {
	BACKEND = 'love',
	audio = {
		play = laudio.play,
		stop = laudio.stop,
	},
	data = {
		audio = laudio.newSource,
		image = lgraphics.newImage,
		video = lgraphics.newVideo,
		stream = lvideo.newVideoStream,
		pixels = limage.newImageData,
		file = lfilesystem.newFileData,
		font = lgraphics.newFont,
		quad = lgraphics.newQuad,
		canvas = lgraphics.newCanvas,
	},
	event = {
		pump = levent.pump,
		push = levent.push,
		poll = levent.poll,
		quit = levent.quit,
		clear = levent.clear,
	},
	render = {
		active = lgraphics.isActive,
		canvas = lgraphics.setCanvas,
		draw = lgraphics.draw,
		clear = lgraphics.clear,
		printf = lgraphics.printf,
		circle = lgraphics.circle,
		ellipse = lgraphics.ellipse,
		rectangle = lgraphics.rectangle,
		push = lgraphics.push,
		pop = lgraphics.pop,
		scale = lgraphics.scale,
		translate = lgraphics.translate,
		rotate = lgraphics.rotate,
		origin = lgraphics.origin,
		present = lgraphics.present,
	},
	time = {
		now = ltimer.getTime,
		sleep = ltimer.sleep,
		delta = ltimer.step,
	},
	async = {
		start = function (t, ...) return t:start(...) end,
		create = lthread.newThread,
		isrunning = function (t) return t:isRunning() end,
		yield = dummy,
		channel = lthread.getChannel,
	},
	io = {
		mousePosition = lmouse.getPosition,
		keyRepeat = lkeyboard.setKeyRepeat,
		textInput = lkeyboard.setTextInput,
		sourceDirectory = lfilesystem.getSourceBaseDirectory,
		directoryItems = lfilesystem.getDirectoryItems,
		realDirectory = lfilesystem.getRealDirectory,
		workingDirectory = lfilesystem.getWorkingDirectory,
		saveDirectory = lfilesystem.getSaveDirectory,
		getSource = lfilesystem.getSource,
		getInfo = lfilesystem.getInfo,
		mount = lfilesystem.mount,
		mkdir = lfilesystem.createDirectory,
		read = lfilesystem.read,
	},
}

	function api.render.blend(arg, ...)
		if arg == nil then
			return getBlendMode()
		else
			return setBlendMode(arg, ...)
		end
	end

	function api.render.mode(arg, ...)
		if arg == nil then
			return getMode()
		else
			return setMode(arg, ...)
		end
	end

	function api.render.backgroundColor(arg, ...)
		if arg == nil then
			return getBackgroundColor()
		else
			return setBackgroundColor(arg, ...)
		end
	end

	function api.render.defaultFilter(arg, ...)
		if arg == nil then
			return getDefaultFilter()
		else
			return setDefaultFilter(arg, ...)
		end
	end

	function api.render.color(arg, ...)
		if arg == nil then
			return getColor()
		else
			return setColor(arg, ...)
		end
	end

	function api.render.scissor(arg, ...)
		if arg == nil then
			return getScissor()
		else
			return setScissor(arg, ...)
		end
	end

	function api.render.lineWidth(arg, ...)
		if arg == nil then
			return getLineWidth()
		else
			return setLineWidth(arg, ...)
		end
	end

	function api.io.requirePath(arg, ...)
		if arg == nil then
			return getRequirePath()
		else
			return setRequirePath(arg, ...)
		end
	end

return api