local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Rooms works only with l2df v1.0 and higher")
assert(type(love) == "table", "Rooms works only under love2d environment")

local UI = core.import "ui"
local EntityManager = core.import "core.entities"
local EventSystem = core.import "systems.event"
local PhysixSystem = core.import "systems.physix"
local RenderSystem = core.import "systems.render"

local hook = helper.hook

local rooms = { list = { } }

	function rooms:init()
		for name, room in pairs(helper.requireAllFromFolder(core.settings.global.rooms_path)) do
			self.list[name] = self:new(room)
		end

		local events = love.handlers
		events.update = true
		events.draw = true

		for key in pairs(events) do
			hook(love, key, function (...) self:emit(key, ...) end)
		end

		hook(core, "localechanged", function () self:emit("localechanged") end, core)
		-- hook(love, "draw", function (...)
		-- 	love.graphics.setCanvas(core.canvas)
		-- 	love.graphics.clear()
		-- 	self:emit("draw", ...)
		-- 	love.graphics.setCanvas()
		-- end)

		self:set(core.settings.global.startRoom)
	end

	function rooms:new(room)
		room = room or { }
		if not room.manager or not room.manager.isTypeOf or not room.manager:isTypeOf(EntityManager) then
			room.manager = EntityManager {
				groups = {
					physical = { "x", "y" },
					ui = UI
				},
				systems = {
					EventSystem({
						forced = { "localechanged", "roomloaded" },
						-- except = { "draw" }
					}),
					PhysixSystem(),
					RenderSystem()
				}
			}
		end
		if type(room.nodes) == "table" and #room.nodes > 0 then
			room.manager:add(room.nodes)
		end
		return room
	end

	function rooms:set(room, input)
		input = input or { }
		local _ = self.current and self.current.exit and self.current:exit()
		self.current = self.list[tostring(room)]
		local _ = self.current.load and self.current:load(input)
		self:emit("roomloaded")
	end

	function rooms:reload(input)
		local _ = self.current.load and self.current:load(input)
		self:emit("roomloaded")
	end

	function rooms:emit(event, ...)
		if self.current and self.current.manager then
			self.current.manager:emit(event, ...)
		end
		return self.current and self.current[event] and self.current[event](self.current, ...)
	end

return rooms