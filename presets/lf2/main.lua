local src = love.filesystem.getSource()
package.path = ('%s;%s/libs/?.lua;%s/libs/?/init.lua'):format(package.path, src, src)
-- love.filesystem.setRequirePath('libs/?.lua;libs/?/init.lua;?.lua;?/init.lua')

l2df = require 'l2df'
local lurker = require 'lurker'

local lag = 0
local strformat = string.format

function love.run()
	return l2df:gameloop()
end

function love.load()
	l2df:init()
end

function love.update(dt)
	lurker.update()
	love.window.setTitle(strformat('FPS: %s(%s). Lag: %s', love.timer.getFPS(), dt, lag))
	if lag > 0 then
		love.timer.sleep(lag)
	end
end

function love.joystickpressed(joystick, button)
	-- rooms.current:Keypressed('Joy'..button)
end

function love.joystickhat(joystick, hat, direction)
	if direction ~= 'c' then
		-- rooms.current:Keypressed('Joy'..hat..button)
	end
end

function love.keypressed(key)
	if key == 'f11' then
		lag = lag + 0.001
	elseif key == 'f12' then
		lag = lag - 0.001
	elseif key == 'x' then
		lag = 0
		love.timer.sleep(1)
	end
end