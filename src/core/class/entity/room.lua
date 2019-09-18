local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"

local Room = Entity:extend({ scenes = {} })

	function Room:init(int)
		self.x = int
		-- body
	end

	function Room:addScene()
		-- body
	end

	function Room:removeScene()
		-- body
	end

	function Room:setScene()
		-- body
	end

	function Room:pushScene()
		-- body
	end

	function Room:popScene()
		-- body
	end

return Room