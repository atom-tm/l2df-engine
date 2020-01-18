local src = love.filesystem.getSource()
package.path = ('%s;%s/libs/?.lua;%s/libs/?/init.lua'):format(package.path, src, src)
-- love.filesystem.setRequirePath('libs/?.lua;libs/?/init.lua;?.lua;?/init.lua')

l2df = require 'l2df'
local lurker = require 'lurker'

local lag = 0
local strformat = string.format

local config = l2df.import 'config'

local SceneManager = l2df.import 'manager.scene'
local KindsManager = l2df.import 'manager.kinds'
local StatesManager = l2df.import 'manager.states'
local InputManager = l2df.import 'manager.input'
local SnapshotManager = l2df.import 'manager.snapshot'
local RenderManager = l2df.import 'manager.render'

function love.run()
	return l2df:gameloop()
end

function love.load()
	l2df:init()

	RenderManager:init()
	SnapshotManager:init(30)
	InputManager:init(config.keys)
	InputManager:updateMappings(config.controls)

	StatesManager:load('data/states')
	KindsManager:load('data/kinds')
	SceneManager:load('scenes/')
	SceneManager:push('myroom')
end

function love.update(dt)
	lurker.update()
	love.window.setTitle(strformat('FPS: %s(%s). Lag: %s', love.timer.getFPS(), dt, lag))
	if lag > 0 then
		love.timer.sleep(lag)
	end
end

function love.keypressed(key)
	if key == 'f11' then
		lag = lag + 0.001
	elseif key == 'f12' then
		lag = lag - 0.001
	elseif key == 'f10' then
		lag = 0
		love.timer.sleep(1)
	end
end