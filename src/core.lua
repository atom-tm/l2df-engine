--- Core module
-- @module l2df.core
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local __DIR__ = (...):match('(.-)[^%.]+$')

local fs = love and love.filesystem
local strmatch = string.match
local strgsub = string.gsub
local strsub = string.sub

local source = nil
local gsource = nil

local core = { version = 1.0 }

	function core.import(name)
		return require(__DIR__ .. name)
	end

	function core.root()
		source = source or core.fullpath('', 3)
		gsource = gsource or source and ('^' .. source)
		return source
	end

	function core.modulepath(path)
		return strgsub(strgsub(path, source, __DIR__), '/', '.')
	end

	function core.fullpath(path, depth, info)
		if fs then
			info = info or debug.getinfo(depth or 2, 'Sn')
			local prefix = info.source
				:sub(2, -1)
				:gsub(fs.getSource():gsub('%-', '%%%-') .. '/?', '')
				:gsub(info.name .. '.lua', '')

			return prefix .. path
		end
		return path
	end

return core