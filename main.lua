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

time = {}
time[2] = 0
time [50] = 0

function love.load()
	camera = CameraCreate() -- создание камеры
	-- FPS Локер --
	min_dt = 1/60 -- требуемое фпс
    next_time = love.timer.getTime()
    ---------------
    read_settings()
    CreateDataList() -- создание листа со всеми персонажами
    roomsLoad() -- подгрузка комнат и установка меню активной комнатой
end

function love.update(dt)
	next_time = next_time + min_dt
	delta_time = dt
	room.update()
	for key in pairs(time) do
		time[key] = time[key] - 1
		if time[key] < 0 then
			time[key] = key
		end
	end
end 



function love.draw()

	camera:draw(function(l,t,w,h)
		room.draw()
	end)
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
	room.keypressed("Joy"..button)
end
function love.joystickhat( joystick, hat, direction )
	if direction ~= "c" then
		room.keypressed("Joy"..hat..direction)
	end
end