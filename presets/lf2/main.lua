------------------------------------------------------------------------------------------------------------------------
if love then
	love.filesystem.setRequirePath('libs/?.lua;libs/?/init.lua;?.lua;?/init.lua')
else
	local sep = package.config:sub(1, 1)
	local cmd = sep == '\\' and 'cd' or 'pwd'
	local src = debug.getinfo(1).source:match('@?(.*[/\\])') or ''
	if src:sub(2, 2) ~= ':' and src:sub(1, 1) ~= sep then
		src = (io.popen(cmd):read() .. '/' .. src):sub(1, -2)
	end
	package.path = ('%s;%s/libs/?.lua;%s/libs/?/init.lua;%s/?.lua;%s/?/init.lua')
		:format(package.path, src, src, src, src):gsub('[/\\]', sep)
end
------------------------------------------------------------------------------------------------------------------------

l2df = require 'l2df'

data = {
	FPS = 60,
	players = { 'Player 1', 'Player 2' },
	usertag = nil,
	loaded = false,
	replay = { },
} -- shared data

helper = l2df.import 'helper'
local cfg = l2df.import 'config'
local log = l2df.import 'class.logger'
local Parser = l2df.import 'class.parser.lffs2'
local Factory = l2df.import 'manager.factory'
local SceneManager = l2df.import 'manager.scene'
local InputManager = l2df.import 'manager.input'
local SyncManager = l2df.import 'manager.sync'
local EventManager = l2df.import 'manager.event'
local RenderManager = l2df.import 'manager.render'
local NetworkManager = l2df.import 'manager.network'
local ResourceManager = l2df.import 'manager.resource'
local GSID = l2df.import 'manager.gsid'

function data.layout(path)
	local data = Parser:parseFile(('%s/%s'):format(cfg.scenes, path))
	if not data then log:warn('Layout "%s" was not found', path) end
	return Factory:create('scene', data), data
end

function data.background(bg)
	local data = Parser:parseFile(('%s/bg.dat'):format(bg.path or bg))
	if type(bg) == 'table' then
		data = helper.copyTable(bg, data)
	elseif not data then
		log:warn('Background "%s" was not found', bg)
	end
	return Factory:create('map', data), data
end

function data.random(a, b)
	a, b = b and a or 1, b or a
	if InputManager.remoteplayers > 0 or data.test and data.test.active then
		return a + GSID:rand() % (b - a + 1)
	end
	return math.random(a, b)
end

function data.isReplayReady()
	return data.loaded and data.chardata and data.bgdata and not ResourceManager:isLoading()
end

function data.tryOpenReplay()
	local replay = data.replay
	if not (replay and replay.pending and replay.path) then
		return false
	end
	if not data.isReplayReady() then
		return false
	end
	replay.pending = false
	SceneManager:set('replay')
	return true
end

function data.openReplay(path)
	path = path and tostring(path) or nil
	if not (path and path:match('%.replay$')) then
		return false
	end
	NetworkManager:destroy()
	data.ready = false
	data.ontimer = nil
	data.replay.path = path
	data.replay.playing = false
	data.replay.frames = nil
	data.replay.pending = true
	data.tryOpenReplay()
	return true
end

local function readArgs(args)
	local default_test = { active = true, exit = true, frames = data.FPS, speed = 1 }
	for i = 1, #(args or { }) do
		local arg = tostring(args[i])
		if arg == '--test-debug' then
			data.test = data.test or default_test
			data.test.debug = true
		elseif arg == '--test-fast' then
			data.test = data.test or default_test
			data.test.hash = 'fast'
		elseif arg == '--test-full' then
			data.test = data.test or default_test
			data.test.hash = 'full'
		elseif arg:match('%.replay$') then
			data.replay.path = arg
			data.replay.pending = true
		else
			local frames = arg:match('^%-%-test%-frames=(%d+)$')
			local speed = arg:match('^%-%-test%-speed=(%d+)$')
			if frames then
				data.test = data.test or { }
				data.test.frames = tonumber(frames)
			elseif speed then
				data.test = data.test or { }
				data.test.speed = tonumber(speed)
			end
		end
	end
end

function l2df.load(args)
	readArgs(args)
	data.usertag = ('%04d'):format(math.random(9999))
	l2df.api.io.mkdir(l2df.savepath())
	cfg:group('settings', 'controls', 'graphics', 'general', 'debug')
	cfg:load('data/data.txt')
	cfg.settings = l2df.savepath(cfg.settings)
	cfg:load(cfg.settings)
	data.replay.record = not not cfg.record
	l2df:init
	{
		fps = data.FPS,
		datafps = 30,
	}
	SyncManager
	{
		size = data.FPS,
	}
	RenderManager
	{
		debug = cfg.debug,
		width = cfg.width,
		height = cfg.height,
		depth = cfg.height,
		vsync = cfg.graphics.vsync,
		ratio = cfg.graphics.ratio,
		fullscreen = cfg.graphics.fullscreen or cfg.mobile,
		filter = cfg.graphics.fxaa and 'linear' or 'nearest',
		shadows = cfg.graphics.shadows and 2 or 1,
		cellsize = 1,
	}
	InputManager
	{
		keys = { 'up', 'down', 'left', 'right', 'attack', 'jump', 'defend', 'special', 'select', 'click' },
		supportui = cfg.mobile,
		uilayout = cfg.layouts,
		mappings = {
			{
				up = 'w', down = 's', left = 'a', right = 'd',
				attack = 'f', jump = 'g', defend = 'h',
				special = 'v', select = 'return', click = 'lmb'
			},
			{
				up = 'up', down = 'down', left = 'left', right = 'right',
				attack = 'j', jump = 'k', defend = 'l',
				special = 'm',
			}
		}
	}
	SceneManager
	{
		load = cfg.scenes,
		set = 'loading'
	}
	NetworkManager:register(cfg.master or '127.0.0.1:12565')
	EventManager:subscribe('filedropped', function (file)
		local scene = SceneManager:current()
		if scene and scene.filedropped then
			scene:filedropped(file)
		else
			data.openReplay(file and file:getFilename())
		end
	end, love)
	EventManager:subscribe('update', data.tryOpenReplay, EventManager, data)
	EventManager:subscribe('keypressed', function (key)
		if key == 'escape' and (not love or love.window.showMessageBox('LF2', 'Are you sure to quit?', {'No', 'Yes'}) == 2) then
			l2df.api.event.quit()
		end
		if key == 'f2' then
			SyncManager.desync = true
		elseif key == 'f3' then
			print('DELAY', InputManager.delay)
			InputManager:rehash()
		elseif key == 'f4' then
			for _, c in NetworkManager:clients() do
				print('PINGTO', c.name, c:ping())
			end
		elseif key == 'f6' then
			data.test = data.test or { }
			data.test.active = true
			data.test.exit = false
			if data.chardata and data.bgdata then
				SceneManager:set('test')
			end
		end
	end, love)
	l2df.api.time.delta()
end

if not love or love.ismock then
	local loop = l2df.gameloop()
	repeat until loop()
else
	love.run = l2df.gameloop
end
