--- Core module
-- @module l2df.core
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local __DIR__ = (...):match('(.-)[^%.]+$')

local fs = love and love.filesystem
local strformat = string.format
local strmatch = string.match
local strgsub = string.gsub
local strsub = string.sub
local getinfo = debug.getinfo

local source = nil
local gsource = nil

local core = { version = 1.0 }

	--- Wrapper on standart 'require', imports engine's components
	-- automatically adding required module's prefix
	-- @param string name  Name of the module/class to import from l2df
	-- @return function
	function core.import(name)
		return require(__DIR__ .. name)
	end

	--- Important function to determine engine's location
	-- First call to core.root() always should be in core.init
	-- @return string
	function core.root()
		gsource = gsource or fs and fs.getSource():gsub('%-', '%%%-')
		source = source or core.fullpath('', 3)
		return source
	end

	--- Return information about line where this function was executed
	-- @param[opt] number i
	function core.getline(i)
		i = i or getinfo(3, 'Sl')
		return strformat('%s:%s', gsource and strgsub(i.source, gsource .. '/?', '') or i.short_src, i.currentline)
	end

	--- Convert path to module's path.
	-- Useful to require .lua scripts by their path
	-- @param string path
	-- @return string
	function core.modulepath(path)
		return strgsub(strgsub(path, source, __DIR__), '/', '.')
	end

	--- Converts the path relative to the game's entry point
	-- @param string path
	-- @param[opt] number depth
	-- @param[opt] table info
	-- @return string
	function core.fullpath(path, depth, info)
		if gsource and fs then
			info = info or getinfo(depth or 2, 'Sn')
			local prefix = info.source
				:sub(2, -1)
				:gsub(gsource .. '/?', '')
				:gsub(info.name .. '.lua', '')

			return prefix .. path
		end
		return path
	end

return core