local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Rooms works only with l2df v1.0 and higher")
assert(type(love) == "table", "Rooms works only under love2d environment")

local EntityManager = core.import "core.entities"
local EventSystem = core.import "systems.event"
local PhysixSystem = core.import "systems.physix"
local UI = core.import "ui"

local hook = helper.hook

local rooms = { list = { } }

	function rooms:init()
		for name, room in pairs(helper.requireAllFromFolder(core.settings.global.rooms_path)) do
			self:add(name, room)
		end

		local events = love.handlers
		events.update = true

		for key in pairs(events) do
			hook(love, key, function (...) self:trigger(key, ...) end)
		end

		hook(core, "localechanged", function () self:trigger("localechanged") end, core)
		hook(love, "draw", function (...)
			love.graphics.setCanvas(core.canvas)
			love.graphics.clear()
			self:trigger("draw", ...)
			love.graphics.setCanvas()
		end)

		self:set(core.settings.global.startRoom)
	end

	function rooms:add(name, room)
		room = room or { }
		if not room.manager or not room.manager.isTypeOf or not room.manager:isTypeOf(EntityManager) then
			room.manager = EntityManager {
				groups = {
					physical = { "x", "y" },
					drawable = function (x) return x.isInstanceOf(UI) end
				},
				systems = {
					EventSystem:new({
						forced = { "localechanged", "roomloaded" }
					}),
					PhysixSystem()
				}
			}
		end
		if type(room.nodes) == "table" and #room.nodes > 0 then
			room.manager:add(room.nodes)
		end
		self.list[name] = room
		return room
	end

	function rooms:set(room, input)
		input = input or { }
		local _ = self.current and self.current.exit and self.current:exit()
		self.current = self.list[tostring(room)]
		local _ = self.current.load and self.current:load(input)
		self:trigger("roomloaded")
	end

	function rooms:reload(input)
		local _ = self.current.load and self.current:load(input)
		self:trigger("roomloaded")
	end

	function rooms:trigger(event, ...)
		if self.current and self.current.manager then
			self.current.manager:emit(event, ...)
		end
		return self.current and self.current[event] and self.current[event](self.current, ...)
	end

return rooms