local __DIR__ = (...):match("(.-)[^%.]+$")

local strgsub = string.gsub
local strgmatch = string.gmatch
local fs = love and love.filesystem

local jsonParser = require(__DIR__ .. "parsers.json")

local module = { }

	module.current = nil
	module.locale = { }
	module.locales = { }

	function module:loadLocales(path, default)
		assert(fs, "Loading locales currently works only with love2d")

		local files = fs.getDirectoryItems(path)
		if not files then return end

		for i = 1, #files do
			local file = path .. "/" .. files[i]
			if fs.getInfo(file, "file") then
				self.locales[strgsub(files[i], ".json$", "")] = jsonParser:parseFile(file)
			end
		end
		self:setLocale(default)
	end

	function module:next()
		return next(self.locales, self.current) or next(self.locales)
	end

	function module:setLocale(key)
		key = key or self:next()
		self.current = key
		self.locale = self.locales[key] or { }
	end

	function module:get(key)
		if type(key) == "string" then
			local x = self.locale
			for k in strgmatch(key, "[^.]+") do
				x = x and x[k] or ""
			end
			return x
		end
		return self.locale
	end

return setmetatable(module, { __call = module.get })