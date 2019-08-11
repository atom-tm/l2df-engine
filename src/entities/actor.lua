local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Actor works only with l2df v1.0 and higher")

local Entity = core.import "core.entities.entity"
local PhysixComponent = core.import "components.physix"
local FramesComponent = core.import "components.frames"

local Actor = Entity:extend()

	function Actor:init(options)
		helper.copyTable(options, self)
		self:addComponent(PhysixComponent)
		self:addComponent(FramesComponent)
		self:setFrame(self.head.default_idle)
	end

return Actor