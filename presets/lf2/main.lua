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
-- local lurker = require 'lurker'

local FPS = 60
data = { players = { 'Player 1', 'Player 2' }, username = nil } -- shared data

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
	if InputManager.remoteplayers > 0 then
		return a + GSID:rand() % (b - a + 1)
	end
	return math.random(a, b)
end

-- function love.update(dt)
-- 	lurker.update()
-- end

function l2df.load()
	data.username = 'Player#' .. tostring(math.random(1000, 9999))
	l2df.api.io.mkdir(l2df.savepath())
	cfg:group('settings', 'controls', 'graphics', 'general', 'debug')
	cfg:load('data/data.txt')
	cfg.settings = l2df.savepath(cfg.settings)
	cfg:load(cfg.settings)
	l2df:init
	{
		fps = FPS,
		datafps = 30,
	}
	SyncManager
	{
		size = FPS,
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
				special = 'j', select = 'return', click = 'lmb'
			},
			{
				up = 'up', down = 'down', left = 'left', right = 'right',
				attack = 'kp1', jump = 'kp2', defend = 'kp3',
				special = 'kp5',
			}
		}
	}
	SceneManager
	{
		load = cfg.scenes,
		set = 'loading'
	}
	EventManager:subscribe('keypressed', function (key)
		if key == 'escape' and (not love or love.window.showMessageBox('LF2', 'Are you sure to quit?', {'No', 'Yes'}) == 2) then
			l2df.api.event.quit()
		end
	end, love)
end

if not love or love.ismock then
	local loop = l2df.gameloop()
	repeat until loop()
else
	love.run = l2df.gameloop
end
