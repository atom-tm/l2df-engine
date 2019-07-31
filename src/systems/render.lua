local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "PhysixSystem works only with l2df v1.0 and higher")
assert(type(love) == "table", "PhysixSystem works only under love2d environment")

local System = core.import "core.entities.system"
local settings = core.import "settings"

local RenderSystem = System:extend()

	function RenderSystem:roomloaded()
		self.layers = {
			ui = love.graphics.newCanvas(settings.global.width, settings.global.height)
		}
	end

	function RenderSystem:draw()
		-- if not self.layers then return end

		local entities = self.groups.ui.entities
		-- love.graphics.setCanvas(self.layers.ui)
		-- love.graphics.clear()
		for i = 1, #entities do
			if not entities[i].hidden and type(entities[i].draw) == "function" then
				-- entities[i]:draw()
			end
		end
		-- love.graphics.setCanvas()
	end

return RenderSystem