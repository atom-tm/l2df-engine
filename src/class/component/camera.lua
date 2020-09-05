--- Component for tracking objects by main camera
-- @classmod l2df.class.component.camera
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Camera works only with l2df v1.0 and higher')

local Component = core.import 'class.component'
local Renderer = core.import 'manager.render'

local min = math.min
local max = math.max

local Camera = Component:extend({ unique = true })

	function Camera:added(obj, kwargs)
		if not obj then return false end
		kwargs = kwargs or { }

		local data = obj.data
		data.globalScaleX = data.globalScaleX or 0
		data.globalScaleY = data.globalScaleY or 0
		data.globalX = data.globalX or 0
		data.globalY = data.globalY or 0
		data.globalZ = data.globalZ or 0
		data.centerx = data.centerx or 0
		data.centery = data.centery or 0

		local storage = self:data(obj)
		storage.priority = kwargs.priority or storage.priority or 1
		storage.kx = kwargs.kx or storage.kx or 0
		storage.ky = kwargs.ky or storage.ky or 0
		storage.ox = data.centerx or 0
		storage.oy = data.centery or 0
	end

	function Camera:postupdate(obj, dt, islast)
		if not (obj and islast) then return end

		local storage = self:data(obj)
		storage.ox, storage.oy = max(storage.ox, storage.centerx), max(storage.oy, storage.centery)
		Renderer:track(
			storage.layer,
			storage.globalX,
			storage.globalZ - storage.globalY,
			storage.ox * storage.globalScaleX,
			storage.oy * storage.globalScaleY,
			storage.kx,
			storage.ky,
			storage.priority
		)
	end

return Camera