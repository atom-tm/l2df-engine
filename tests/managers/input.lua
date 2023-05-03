package.path = '../../?.lua;../../?/init.lua;' .. package.path

require 'dev.prod.love2d'
require 'src'

local Input = l2df.import 'manager.input'
local log = l2df.import 'class.logger'

log.disableColors()
Input {
	keys = { 'up', 'down', 'left', 'right', 'attack', 'jump', 'defend', 'special', 'select' }
}
Input:reset(1)

local function debuginput(player)
	local it, data, behind = Input:lastinput(player), { }, 0
	while it.prev do
		it = it.prev
	end
	while it ~= nil do
		data[#data + 1] = string.format('[%02d][%02d][%08X]', it.data, it.frame, it.hash)
		it = it.next
	end
	return string.format('INPUT[%s] %s', player, table.concat(data, ' '))
end

local payload = {
	inputs = { 1, 8, 0, 9, 4 },
	frames = { 1, 2, 3, 9, 9 }
}
local i1, i2
for k = 1, 10 do
	for i = 1, #payload.inputs do
		_, i2 = Input:addinput(payload.inputs[i], 1, payload.frames[i])
	end
	i2 = i2.hash
	log:info('%2d) [%08X][%08X] | %s', k, i1 or 0, i2, debuginput(1))
	assert(i1 == nil or i1 == i2)
	i1 = i2
end
log:success('Test passed.')