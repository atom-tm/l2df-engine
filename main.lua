love.graphics.setDefaultFilter("nearest", "nearest") -- отключение сглаживания
math.randomseed(love.timer.getTime()) -- для того чтобы рандом работал лучше

gamera = require "libs.gamera"
require "libs.entites"
require "libs.drawing"
require "libs.physics"
require "libs.collisions"
require "libs.get"
require "libs.controls"
require "libs.battle"
require "libs.loading"
require "libs.states"
require "libs.rooms"
require "libs.settings"


function love.load()
	camera = CameraCreate() -- создание камеры

	-- FPS Локер --
	min_dt = 1/60 -- требуемое фпс
    next_time = love.timer.getTime()
    ---------------

    CreateDataList() -- создание листа со всеми персонажами
    roomsLoad()
end

function love.update(dt)
	next_time = next_time + min_dt
	delta_time = dt
	room.update()
end 



function love.draw()
	room.draw()
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end 




function love.keypressed( button, scancode, isrepeat )
	room.keypressed(button, scancode, isrepeat)
end
function love.joystickpressed( joystick, button )
	room.keypressed("joy "..button)
end
function love.joystickhat( joystick, hat, direction )
	if direction ~= "c" then
		room.keypressed("joy "..hat..direction)
	end
end