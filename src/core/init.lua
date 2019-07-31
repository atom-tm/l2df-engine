local __DIR__ = (...):match("(.-)[^%.]+$")

local core = { version = 1.0 }

	function core.import(name)
		return require(__DIR__ .. name)
	end

return core