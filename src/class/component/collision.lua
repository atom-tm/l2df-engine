--- Collisions component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.collision
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Collisions works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Component = core.import 'class.component'
local PhysixManager = core.import 'manager.physix'
local KindsManager = core.import 'manager.kinds'

local sqrt = math.sqrt
local min = math.min
local max = math.max
local copy = helper.copyTable

local Collision = Component:extend({ unique = true })

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt] table kwargs  Keyword arguments. Not actually used.
	function Collision:added(obj, kwargs)
		if not obj then return false end
		kwargs = kwargs or { }

		local data = obj.data
		data.itrs = { ___shallow = true }
		data.bodies = { ___shallow = true }

		data.facing = data.facing or 1

		data.x = data.x or 0
		data.y = data.y or 0
		data.z = data.z or 0

		data.mx = data.mx or 0
		data.my = data.my or 0
		data.mz = data.mz or 0

		data.centerx = data.centerx or 0
		data.centery = data.centery or 0
	end

	--- Wrap collider with @{l2df.class.entity|entity} and callback function.
	-- Generates new @{l2df.manager.physix.Collider|Collider's} table.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param table col  Collider's description table.
	-- @param[opt=0] number|string col.kind  ID / name of the kind associated with this collider.
	-- @param[opt=0] number col.x  Collider's box X position.
	-- @param[opt=0] number col.y  Collider's box Y position.
	-- @param[opt=0] number col.z  Collider's box Z position.
	-- @param[opt=0] number col.w  Collider's box width.
	-- @param[opt=0] number col.h  Collider's box height.
	-- @param[opt=0] number col.d  Collider's box depth.
	-- @param[opt] function action  Callback called when collider is triggered.
	-- @return l2df.manager.physix.Collider
	function Collision:collider(obj, col, action)
		local data = obj.data
		--local r = col.r or col.w * col.h * col.d > 0 and sqrt(col.w ^ 2 + col.h ^ 2 + col.d ^ 2) / 2 or 0
		local x_1 = data.x + (col.x or 0) * data.facing
		local x_2 = x_1 + (col.w or 0) * data.facing
		local y_1 = (col.y or 0) - data.y
		local y_2 = y_1 + (col.h or 0)
		local z_1 = data.z + (col.z or 0)
		local z_2 = z_1 + (col.d or 0)

		local x1 = min(x_1, x_1 + data.mx, x_2, x_2 + data.mx)
		local x2 = max(x_1, x_1 + data.mx, x_2, x_2 + data.mx)
		local y1 = min(y_1, y_1 + data.my, y_2, y_2 + data.my)
		local y2 = max(y_1, y_1 + data.my, y_2, y_2 + data.my)
		local z1 = min(z_1, z_1 + data.mz, z_2, z_2 + data.mz)
		local z2 = max(z_1, z_1 + data.mz, z_2, z_2 + data.mz)

		local collider = copy(col)
		collider.kind = col.kind or 0
		collider.owner = obj
		collider.data = data
		collider.col = col
		collider.action = action
		collider.w = x2 - x1
		collider.h = y2 - y1
		collider.d = z2 - z1
		collider.x = x1
		collider.y = y1
		collider.z = z1
		return collider
	end

	--- Collision update event handler.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
	function Collision:update(obj, dt)
		local data = obj.data
		for i = 1, #data.bodies do
			local bdy = data.bodies[i]
			local kind = KindsManager:get(bdy.kind)
			PhysixManager:add('bdy', self:collider(obj, bdy, kind))
		end
		for i = 1, #data.itrs do
			local itr = data.itrs[i]
			local kind = KindsManager:get(itr.kind)
			if kind then
				PhysixManager:add('itr', self:collider(obj, itr, kind))
			end
		end
	end

return Collision