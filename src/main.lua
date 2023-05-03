io.stdout:setvbuf('no')
local sep = package.config:sub(1, 1)
local cmd = sep == '\\' and 'cd' or 'pwd'
local src = love and love.filesystem and
	(love.filesystem.getSource()) or
	(io.popen(cmd):read() .. '/' .. (debug.getinfo(1).source:match('@?(.*[/\\])') or '')):sub(1, -2)
package.path = ('%s;%s/?.lua;%s/?/init.lua'):format(package.path, src, src):gsub('[/\\]', sep)

local core = require 'core'
local api = core.api

function test()
	print('ROOT', core.root())
end

print('BACKEND', api.BACKEND)
api.render.color(1, 1, 1, 0.5)
print('COLOR', api.render.color())
test()

local ch = api.async.channel('data')

local t = api.async.create([[
	pcall(require, 'love.image')
	local api = require 'api'
	local pipe = api.async.channel('data')
	for i = 1, 4 do
		pipe:push(api.data.file('config.lua'))
		collectgarbage()
		api.async.yield()
	end
]])

love = love or { ismock = true }

function love.load()
	api.async.start(t)
end

local tm = 0
function love.update(dt)
	if not api.async.isrunning(t) and tm > 2 then
		print('THREAD', 'finished')
		tm = 0
	end
	if ch:getCount() > 0 then
		print('THREAD', ch:pop())
	end
	tm = tm + dt
end

if love.ismock then
	love.load()
	local tickrate = 1 / 60
	local delta = api.time.delta()
	local accumulate = 0
	while true do
		delta = api.time.delta()
		accumulate = accumulate + delta
		while accumulate >= tickrate do
			accumulate = accumulate - tickrate
			love.update(tickrate)
		end
		api.time.sleep(0.001)
	end
end