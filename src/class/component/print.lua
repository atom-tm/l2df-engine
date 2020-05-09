--- Print component
-- @classmod l2df.class.component.print
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local loveNewFont = love.graphics.newFont

local Print = Component:extend({ unique = false })

	--- Set params for printing
	-- @param table kwargs
	function Print:set(kwargs)
		local vars = self:vars()
		kwargs = kwargs or { }

		vars.text = kwargs.text or self.text or ''

		if type(kwargs.font) == 'number' then
			vars.font = loveNewFont(kwargs.font)
		elseif kwargs.font and kwargs.font.typeOf and kwargs.font:typeOf('Font') then
			vars.font = kwargs.font
		else
			vars.font = loveNewFont()
		end

		vars.limit = kwargs.limit or vars.font:getWidth(vars.text)

		vars.color = kwargs.color and {
			(kwargs.color[1] or 255) / 255,
			(kwargs.color[2] or 255) / 255,
			(kwargs.color[3] or 255) / 255,
			(kwargs.color[4] or 255) / 255 }
		or { 1,1,1,1 }


		--[[if type(kwargs.font) == 'number' then
			self.font = loveNewFont(kwargs.font)
		elseif kwargs.font and kwargs.font.typeOf and kwargs.font:typeOf('Font') then
			vars[self].font = kwargs.font
		else
			vars[self].font = loveNewFont()
		end
		self.ox = kwargs.ox or self.ox or 0
		self.oy = kwargs.oy or self.oy or 0
		self.kx = kwargs.kx or self.kx or 0
		self.ky = kwargs.ky or self.ky or 0
		self.sx = kwargs.sx or self.sx or 1
		self.sy = kwargs.sy or self.sy or 1
		self.color = kwargs.color and { (kwargs.color[1] or 255) / 255, (kwargs.color[2] or 255) / 255, (kwargs.color[3] or 255) / 255, (kwargs.color[4] or 255) / 255 } or { 1,1,1,1 }]]
	end

	--- Component added to l2df.class.entity
	-- @param l2df.class.entity entity
	function Print:added(entity, kwargs)
		if not entity then return false end
		self.super.added(self, entity)

		local vars = self:vars()

		vars.x = kwargs.x or vars.x or 0
		vars.y = kwargs.y or vars.y or 0
		vars.z = kwargs.z or vars.z or 0
		vars.r = kwargs.r or vars.r or 0

		vars.scaleX = kwargs.scaleX or vars.scaleX or 1
		vars.scaleY = kwargs.scaleY or vars.scaleY or 1

		vars.hidden = kwargs.hidden or vars.hidden or false

		self:set(kwargs)
	end

	--- Post-update event
	function Print:postUpdate()
		if not self.entity then return end
		local vars = self:vars()
		if not vars.hidden then
			RenderManager:add({
				text = vars.text,
				font = vars.font,
				limit = vars.limit,

				x = vars.globalX or vars.x,
				y = vars.globalY or vars.y,
				z = vars.globalZ or vars.z,
				r = vars.r,

				color = vars.color,

			})
		end
	end

return Print