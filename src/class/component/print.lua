--- Print component
-- @classmod l2df.class.component.print
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local loveNewFont = love.graphics.newFont

local Print = Component:extend({ unique = false })

	--- Set params for printing
	-- @param l2df.class.entity obj
	-- @param table kwargs
	function Print:set(obj, kwargs)
		local cdata = self:data(obj)
		kwargs = kwargs or { }

		cdata.text = kwargs.text or self.text or ''
		cdata.placeholder = kwargs.placeholder or ''

		if type(kwargs.font) == 'number' then
			cdata.font = loveNewFont(kwargs.font)
		elseif kwargs.font and kwargs.font.typeOf and kwargs.font:typeOf('Font') then
			cdata.font = kwargs.font
		else
			cdata.font = loveNewFont()
		end

		cdata.limit = kwargs.limit or cdata.font:getWidth(cdata.text)
		cdata.color = kwargs.color and {
			(kwargs.color[1] or 255) / 255,
			(kwargs.color[2] or 255) / 255,
			(kwargs.color[3] or 255) / 255,
			(kwargs.color[4] or 255) / 255 }
		or { 1, 1, 1, 1 }
		cdata.pcolor = kwargs.pcolor and {
			(kwargs.pcolor[1] or 255) / 255,
			(kwargs.pcolor[2] or 255) / 255,
			(kwargs.pcolor[3] or 255) / 255,
			(kwargs.pcolor[4] or 255) / 255 }
		or cdata.color
	end

	--- Component added to l2df.class.entity
	-- @param l2df.class.entity obj
	function Print:added(obj, kwargs)
		if not obj then return false end

		local data = obj.data

		obj.C.print = self:wrap(obj)

		data.x = kwargs.x or data.x or 0
		data.y = kwargs.y or data.y or 0
		data.z = kwargs.z or data.z or 0
		data.r = kwargs.r or data.r or 0

		data.scalex = kwargs.scalex or data.scalex or 1
		data.scaley = kwargs.scaley or data.scaley or 1

		data.hidden = kwargs.hidden or data.hidden or false

		self:set(obj, kwargs)
	end

	--- Post-update event
	-- @param l2df.class.entity obj
	function Print:postupdate(obj)
		local cdata = obj.data
		local data = self:data(obj)
		if not cdata.hidden then
			local text, color = data.text, data.color
			if #text == 0 then
				text, color = data.placeholder, data.pcolor
			end
			RenderManager:draw({
				text = text,
				font = data.font,
				limit = data.limit,
				color = color,

				x = cdata.globalX or cdata.x,
				y = cdata.globalY or cdata.y,
				z = cdata.globalZ or cdata.z,
				r = cdata.r,
			})
		end
	end

return Print
