package.path = package.path .. ";./libs/?.lua;./libs/?/init.lua"

l2df = require "l2df"

function love.load()
	l2df:init()
	--settings:Read("data/settings.dat") -- чтение настроек из файла с настройками игры
	--helper.SetWindowSize()
	--loc:Set(loc.id)
	--data:Load("data/data.txt")
	--data:Frames("data/frames.dat")
	--data:DTypes("data/damage_types.dat")
	--data:System("data/system.dat")
	--data:States("states")
	--data:Kinds("kinds")
	--rooms:Set("main_menu")
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
		l2df.settings.graphic.fullscreen = not l2df.settings.graphic.fullscreen
		l2df.settings:apply(l2df)
	elseif key == "f12" then
		l2df.settings.debug = not l2df.settings.debug
	end
end