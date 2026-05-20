package.path = table.concat({
	'./?.lua',
	'./?/init.lua',
	'./tests/?.lua',
	'./tests/?/init.lua',
	package.path,
}, ';')

_G.l2df = _G.l2df or require 'src'

local Logger = l2df.import 'class.logger'
Logger.disableColors()

l2df.factor = l2df.factor or 1
