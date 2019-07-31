local __DIR__ = (...):match("(.-)[^%.]+$")

local core = { version = 1.0 }

	function core.import(name)
		core[name] = require(__DIR__ .. name)
		return core[name]
	end

return core