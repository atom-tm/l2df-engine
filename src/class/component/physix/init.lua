--- Physics component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.physix
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local Component = core.import 'class.component'
local World = core.import 'class.component.physix.world'
local PhysixManager = core.import 'manager.physix'

local abs = math.abs
local sign = helper.sign
local default = helper.notNil
local convert = PhysixManager.convert

local EPS = 1e-5

local Physix = Component:extend({ unique = true })

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt=1] number kwargs.facing  Entity's X orientation (not whole axis). Can be 1 or -1 (mirrored)..
	-- Used for mirroring rendered content. Doesn't apply if entity already has facing setted.
	-- @param[opt=false] boolean kwargs.gravity  True if entity uses gravity acceleration, false otherwise.
	-- @param[opt=false] boolean kwargs.static  Disables physics simulation if set to true.
	-- @param[opt=true] boolean kwargs.solid  Makes object solid. Solid objects collide with each other.
	function Physix:added(obj, kwargs)
		if not obj then return false end
		kwargs = kwargs or { }

		local data = obj.data

		data.x = data.x or 0
		data.y = data.y or 0
		data.z = data.z or 0
		data.mx = data.mx or 0
		data.my = data.my or 0
		data.mz = data.mz or 0
		data.vx = data.vx or 0
		data.vy = data.vy or 0
		data.vz = data.vz or 0
		data.dx = data.dx or 0
		data.dy = data.dy or 0
		data.dz = data.dz or 0
		data.dvx = data.dvx or 0
		data.dvy = data.dvy or 0
		data.dvz = data.dvz or 0
		data.dsx = data.dsx or 0
		data.dsy = data.dsy or 0
		data.dsz = data.dsz or 0

		data.facing = data.facing or kwargs.facing or 1
		data.gravity = kwargs.gravity or false
		data.static = kwargs.static or false
		data.ground = data.ground or false
		data.solid = default(kwargs.solid, true)
		return true
	end

	--- Physics update event handler.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
	function Physix:update(obj, dt)
		local data, world = obj.data, World.getFromContext()
		if not world or data.static then return end

		local wdata = world.data()

		local frictionx = data.ground and sign(data.vx) * convert(wdata.ground_friction or 0) or 0
		local frictionz = data.ground and sign(data.vz) * convert(wdata.ground_friction or 0) or 0
		frictionx = frictionx + convert(data.vx * (wdata.friction or 0)) * dt
		frictionz = frictionz + convert(data.vz * (wdata.friction or 0)) * dt

		data.vx = data.dvx ~= 0 and convert(data.dvx) or abs(data.vx) > abs(frictionx) and data.vx - frictionx or 0
		data.vx = data.vx + convert(data.dsx)

		data.vy = data.dvy ~= 0 and convert(data.dvy) or data.vy - convert(data.gravity and wdata.gravity or 0) * dt
		data.vy = data.vy + convert(data.dsy)

		data.vz = data.dvz ~= 0 and convert(data.dvz) or abs(data.vz) > abs(frictionz) and data.vz - frictionz or 0
		data.vz = data.vz + convert(data.dsz)

		if abs(data.vx) < EPS then data.vx = 0 end
		if abs(data.vy) < EPS then data.vy = 0 end
		if abs(data.vz) < EPS then data.vz = 0 end

		data.mx = (convert(data.dx) + data.vx) * dt
		data.my = (convert(data.dy) + data.vy) * dt
		data.mz = (convert(data.dz) + data.vz) * dt

		data.dsx, data.dsy, data.dsz = 0, 0, 0
		data.dvx, data.dvy, data.dvz = 0, 0, 0

		PhysixManager:move(obj, world)
	end

return Physix