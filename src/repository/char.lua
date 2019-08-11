local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "CharRepository works only with l2df v1.0 and higher")

local LfParser = core.import "parsers.lf2"
local data = core.import "data"

local list = { }
local mapping = { }

local function getBasicChar()
	return {
		head = {
			name = "Unknown",
			type = "character",
			hp = 1000,
			mp = 500,
			sp = 10,
			hp_regeneration = 1,
			mp_regeneration = 1,
			sp_regeneration = 1,
			fall = 70,
			bdefend = 60,
			fall_timer = 100,
			bdefend_timer = 160,
			next_zero = true,
			sprites = { }
		}
	}
end


local CharRepository = { }

	--- Persist CharEntity
	function CharRepository.save(entity)
		assert(false, "Method not implemented")
	end

	--- Remove CharEntity from repository
	function CharRepository.remove(entity)
		assert(false, "Method not implemented")
	end

	--- Get CharEntity by key
	function CharRepository.get(key)
		local tkey = type(key)
		assert(tkey == "number" or tkey == "string", "Incompatible key type for CharLoader")
		if type(list[key]) == "table" then
			return list[key]
		elseif mapping[key] ~= nil then
		    return list[ mapping[key] ]
		end
		return CharRepository.load(key)
	end

	--- Load Char from storage, internal stuff
	function CharRepository.load(key)
		assert(data.list and type(data.list.characters) == "table", "Characters data isn\'t loaded")
		assert(data.frames and type(data.frames) == "table", "Frames data isn\'t loaded")

		local config = data.list.characters[key]
		assert(type(config) == "table" and config.file, "Invalid config for char: " .. key)

		local char = LfParser:parseFile(config.file, getBasicChar())
		assert(char.head.type == "character", "Invalid type inside dat-file, expected: character")

		for k, v in pairs(data.frames) do
			if not char.frames_list[k] then
				char.frames_list[k] = v
			end
		end

		mapping[char.head.name:lower()] = key
		list[key] = char
		return char
	end

return CharRepository