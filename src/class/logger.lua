--- Logger class. Inherited from @{l2df.class|l2df.Class}.
-- @classmod l2df.class.logger
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Logger works only with l2df v1.0 and higher')

local Class = core.import 'class'

local unpack = table.unpack or _G.unpack
local pairs = _G.pairs
local assert = _G.assert
local select = _G.select
local setmetatable = _G.setmetatable
local print = io.write
local fopen = io.open
local asctime = os.date
local getenv = os.getenv
local strsub = string.sub
local strfind = string.find
local strgsub = string.gsub
local strformat = string.format
local traceback = debug.traceback
local getline = core.getline
local errhandler = love and (love.errorhandler or love.errhand) or nil

local colors = not getenv('L2DF_NOCOLOR')
local loggers = { }
local levels = { }
local methods = {
	{ 'debug',  '\027[35m', true },
	{ 'info',   '\027[36m', false },
	{ 'success','\027[32m', false },
	{ 'warn',   '\027[33m', false },
	{ 'error',  '\027[91m', true },
	{ 'crit',   '\027[31m', false },
}

local function log(file, time, color, method, name, message)
	if colors then
		print(strformat('%s %s%8s\027[0m %s%s\n', time, color, method, name, message))
		if file then
			local f = fopen(file, 'a')
			f:write( strformat('%s %8s %s%s\n', time, method, name, message) )
			f:close()
		end
	else
		print(strformat('%s %8s %s%s\n', time, method, name, message))
		if file then
			local f = fopen(file, 'a')
			f:write( strformat('%s %8s %s%s\n', time, method, name, message) )
			f:close()
		end
	end
	return message
end

local FormatProxy = {
	__mod = function (self, other)
		if type(other) == 'table' then
			self[#self] = strformat(self[#self], unpack(other))
		else
			self[#self] = strformat(self[#self], other)
		end
		return log(unpack(self))
	end
}

io.stdout:setvbuf('no') -- don't touch it

-- 'white' = '\033[97m'
-- 'grey' = '\033[90m'
-- 'red' = '\033[91m'
-- 'blue' = '\033[94m'
-- 'green' = '\033[92m'
-- 'yellow' = '\033[93m'
-- 'marroon' = '\033[31m'
-- 'underline' = '\033[4m'
-- 'italic' = '\033[3m'
-- 'bold' = '\033[1m'
-- '\033[90m%(asctime)s\033[0m'

local Logger = Class:extend({ name = '', level = getenv('L2DF_LOGLEVEL') or 'debug', file = getenv('L2DF_LOGFILE') })

	--- Get logger by name.
	-- @param string name
	-- @return l2df.class.logger
	function Logger.get(name)
		return assert(loggers[name], 'Logger not found')
	end

	--- Disable colors in console.
	function Logger.disableColors()
		colors = false
	end

	--- Initialize logger.
	-- @param string name  Name assigned to the created logger.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt='debug'] string kwargs.level  Debug level. One of: debug, info, success, warn, error, crit.
	-- @param[opt] string kwargs.file  Path to the file for writting logs.
	function Logger:init(name, kwargs)
		assert(not (name and loggers[name]), 'Logger already exists')
		kwargs = kwargs or { }
		self.name = strformat('[%s] ', name)
		self.level = kwargs.level or 'debug'
		self.file = kwargs.file
	end

	for i = 1, #methods do
		local method, color, useDebug = unpack(methods[i])
		local name = method:upper()
		levels[method] = i
		Logger[method] = function (self, format, ...)
			if i < levels[self.level] then return end
			local time = asctime('%d.%m.%y %X')
			local msg = format
			if select('#', ...) > 0 then
				msg = strformat(format, ...)
			end
			if useDebug then
				msg = strformat('%s: %s', getline(), msg)
			end
			if strfind(msg, '[^%%]%%[^%%]') then
				return setmetatable({ self.file, time, color, name, self.name, msg }, FormatProxy)
			end
			return log(self.file, time, color, name, self.name, msg)
		end
	end

if love then
	function love.errhand(msg)
		Logger:crit(strgsub(traceback(msg, 3), '\n[^\n]+$', ''))
		return errhandler and errhandler(msg)
	end

	function love.errorhandler(msg)
		Logger:crit(strgsub(traceback(msg, 3), '\n[^\n]+$', ''))
		return errhandler and errhandler(msg)
	end
end

return Logger