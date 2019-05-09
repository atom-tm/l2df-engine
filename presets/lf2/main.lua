local src = love.filesystem.getSource()
package.path = ("%s;%s/libs/?.lua;%s/libs/?/init.lua"):format(package.path, src, src)

l2df = require "l2df"

local settings = l2df.settings

function love.load()
	l2df:init()
end

function love.joystickpressed(joystick, button)
	-- rooms.current:Keypressed("Joy"..button)
end

function love.joystickhat(joystick, hat, direction)
	if direction ~= "c" then
		-- rooms.current:Keypressed("Joy"..hat..button)
	end
end

function love.keypressed(key)
	if key == "f11" then
		settings.graphic.fullscreen = not settings.graphic.fullscreen
		settings:apply(l2df)
	elseif key == "f12" then
		settings.debug = not settings.debug
	end
end