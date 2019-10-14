local src = love.filesystem.getSource()
package.path = ('%s;%s/libs/?.lua;%s/libs/?/init.lua'):format(package.path, src, src)
-- love.filesystem.setRequirePath('libs/?.lua;libs/?/init.lua;?.lua;?/init.lua')

l2df = require 'l2df'
local lurker = require 'lurker'

local curr_fps = 60

local settings = l2df.settings

function love.load()
	l2df:init()
	min_dt = 1/curr_fps
    next_time = love.timer.getTime()
end

function love.update(dt)
	lurker.update()
	love.window.setTitle('FPS: ' .. love.timer.getFPS() .. ' ('..(dt)..')')
	next_time = next_time + min_dt
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
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
		curr_fps = curr_fps - 10
		curr_fps = curr_fps > 10 and curr_fps or 10
		min_dt = 1/curr_fps
	elseif key == 'f12' then
		curr_fps = curr_fps + 10
		min_dt = 1/curr_fps
	end
end