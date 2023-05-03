--- Core module
-- @module l2df.core
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local __DIR__ = (...):match('(.-)[^%.]+$')

local strformat = string.format
local strmatch = string.match
local strgsub = string.gsub
local strsub = string.sub
local getinfo = debug.getinfo

local source = nil
local gsource = nil

local core = {
	api = require(__DIR__ .. 'api'),
	version = 1.0,
	tickrate = 1 / 60,
}

	local fs = core.api.io

	--- Wrapper on standart 'require', imports engine's components.
	-- automatically adding required module's prefix.
	-- @param string name  Name of the module/class to import from l2df.
	-- @return function
	function core.import(name)
		return require(__DIR__ .. name)
	end

	--- Important function to determine engine's location.
	-- First call to core.root() always should be in core.init.
	-- @param[opt=3] number depth  Depth passed to debug.getinfo method.
	-- @return string
	function core.root(depth)
		gsource = gsource or fs.getSource():gsub('%-', '%%-')
		source = source or core.fullpath('', depth or 3)
		return source
	end

	--- Return information about line where this function was executed.
	-- @return string
	function core.getline()
		local i = getinfo(3, 'Sl')
		return strformat('%s:%s', gsource and strgsub(i.source, gsource .. '/?', '') or i.short_src, i.currentline)
	end

	--- Convert path to module's path.
	-- Useful to require .lua scripts by their path.
	-- @param string path  Source path.
	-- @return string
	function core.modulepath(path)
		return strgsub(strgsub(path, source, __DIR__), '/', '.')
	end

	--- Convert path relative to current working directory to absolute.
	-- @param[opt] string path  Source path.
	-- @return string
	function core.workpath(path)
		if path then
			return strformat('%s/%s', fs.workingDirectory(), path)
		end
		return fs.workingDirectory()
	end

	--- Convert path relative to current save directory to absolute.
	-- @param[opt] string path  Source path.
	-- @return string
	function core.savepath(path)
		if path then
			return strformat('%s/%s', fs.saveDirectory(), path)
		end
		return fs.saveDirectory()
	end

	--- Converts the path relative to the game's entry point.
	-- @param string path  Source path.
	-- @param[opt=2] number depth  Depth passed to debug.getinfo method.
	-- @param[opt] table info  Stack Information table (may be provided by calling debug.getinfo).
	-- @return string
	function core.fullpath(path, depth, info)
		if gsource then
			info = info or getinfo(depth or 2, 'Sn')
			local prefix = info.source
				:sub(2, -1)
				:gsub('\\', '/')
				:gsub(gsource .. '/?', '')
				:gsub(info.name .. '.lua', '')
			while prefix:sub(1, 1) == '/' do
				prefix = prefix:sub(2)
			end
			return prefix .. path
		end
		return path
	end

return core