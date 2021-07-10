-- local src = love.filesystem.getSource()
-- package.path = ('%s;%s/libs/?.lua;%s/libs/?/init.lua'):format(package.path, src, src)
love.filesystem.setRequirePath('libs/?.lua;libs/?/init.lua;?.lua;?/init.lua')

l2df = require 'l2df'
-- local lurker = require 'lurker'

local FPS = 60
data = { players = { 'Abelidze', 'Kasai' } } -- shared data

helper = l2df.import 'helper'
local cfg = l2df.import 'config'
local log = l2df.import 'class.logger'
local Parser = l2df.import 'class.parser.lffs2'
local Factory = l2df.import 'manager.factory'
local SceneManager = l2df.import 'manager.scene'
local InputManager = l2df.import 'manager.input'
local SyncManager = l2df.import 'manager.sync'
local RenderManager = l2df.import 'manager.render'

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

function love.run()
	return l2df.gameloop()
end

-- function love.update(dt)
-- 	lurker.update()
-- end

function love.keypressed(key)
	if key == 'escape' and love.window.showMessageBox('LF2', 'Are you sure to quit?', {'No', 'Yes'}) == 2 then
		love.event.quit()
	end
end

function love.load()
	love.filesystem.createDirectory(l2df.savepath())
	cfg:group('settings', 'controls', 'graphics', 'general', 'debug')
	cfg:load('data/data.txt')
	cfg.settings = l2df.savepath(cfg.settings)
	cfg:load(cfg.settings, 'settings')
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
end