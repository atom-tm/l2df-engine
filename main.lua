love2dFighting = require "libs.core"

function love.load()
	love2dFighting.init()
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

function love.update(dt)
	--[[if rooms.current.Update ~= nil then
		rooms.current:Update()
	end]]
end 



function love.draw()
	--[[if rooms.current.CustomDraw then
		if rooms.current.Draw ~= nil then
			rooms.current:Draw()
		end
	else
		camera:draw(function(l,t,w,h)
			if rooms.current.Draw ~= nil then
				rooms.current:Draw()
			end
		end)
	end
	if settings.debug_mode then
		if rooms.current.Debug ~= nil then
			rooms.current:Debug()
		end
	end]]
end 




function love.keypressed( button, scancode, isrepeat )
	--[[if button == "f11" then
		settings.window.fullscreen = not settings.window.fullscreen
		helper.SetWindowSize()
	elseif button == "f12" then
		settings.debug_mode = not settings.debug_mode
	else
		rooms.current:Keypressed(scancode)
	end
end
function love.joystickpressed( joystick, button )
	rooms.current:Keypressed("Joy"..button)
end
function love.joystickhat( joystick, hat, direction )
	if direction ~= "c" then
		rooms.current:Keypressed("Joy"..hat..button)
	end]]
end