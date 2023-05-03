--- Print component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.print
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local Component = core.import 'class.component'
local RenderManager = core.import 'manager.render'
local Resources = core.import 'manager.resource'

local max = math.max
local type = _G.type
local unpack = table.unpack or _G.unpack
local strformat = string.format

local Print = Component:extend({ unique = false })

	--- Text alignment: `"left"`, `"right"`, `"center"`.
	-- To access use @{l2df.class.component.data|Print:data()} function.
	-- @string Print.data.align

	--- Text max width.
	-- To access use @{l2df.class.component.data|Print:data()} function.
	-- @string Print.data.limit

	--- Text font.
	-- To access use @{l2df.class.component.data|Print:data()} function.
	-- @string Print.data.font

	--- Text color.
	-- To access use @{l2df.class.component.data|Print:data()} function.
	-- @field {0..1,0..1,0..1,0..1} Print.data.color

	--- Placeholder color.
	-- To access use @{l2df.class.component.data|Print:data()} function.
	-- @field {0..1,0..1,0..1,0..1} Print.data.pcolor

	--- Set params for printing
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt=""] string kwargs.text  Text to display.
	-- @param[opt=""] string kwargs.placeholder  Placeholder text to display.
	-- @param[opt={"Arial.ttf";12}] string|number|{string,number}|userdata kwargs.font  Font used for displaying text.
	-- Can be a font name, font size, table-combination of both or even `userdata` with ready-to-use font instance.
	-- @param[opt] string kwargs.limit  Max width of the one-line text string. Defaults to the text's length with setted font.
	-- @param[opt='left'] string kwargs.center  Text alignment: `"left"`, `"right"`, `"center"`.
	-- Used in pair with `kwargs.limit` to align text after line breaks.
	-- @param[opt] {0..255,0..255,0..255,0..255} kwargs.color  Text's RGBA color. Defaults to `{255, 255, 255, 255}` (white).
	-- @param[opt] {0..255,0..255,0..255,0..255} kwargs.pcolor  Text placeholder's RGBA color. Defaults to the value of `kwargs.color`.
	function Print:set(obj, kwargs)
		local cdata = self:data(obj)
		kwargs = kwargs or { }

		local udata = kwargs.unique and cdata or obj.data
		udata.text = kwargs.text or ''
		udata.placeholder = kwargs.placeholder or ''

		local fnt = kwargs.font
		local tfont, font, size = type(fnt)
		if tfont == 'table' then
			font, size = unpack(fnt)
		elseif tfont == 'string' then
			font = fnt
		elseif tfont == 'number' then
			size = fnt
		end
		font = font or '__default__.ttf'
		size = size or 12
		if tfont == 'userdata' and fnt.typeOf and fnt:typeOf('Font') then
			cdata.font = fnt
			cdata.limit = kwargs.limit or max(fnt:getWidth(udata.text), fnt:getWidth(cdata.placeholder))
		elseif not Resources:loadAsync(font, function (id, fnt)
			if not id then return end
			cdata.font = fnt
			cdata.limit =
				kwargs.limit or max(fnt:getWidth(udata.text), fnt:getWidth(cdata.placeholder)) or cdata.limit
		end, false, strformat('%s#%s', font, size), false, size) then
			log:error('Font error: %s [%s]', font, size)
			return
		end

		cdata.align = kwargs.align
		cdata.limit = cdata.limit or 0
		udata.color = kwargs.color and {
			(kwargs.color[1] or 255) / 255,
			(kwargs.color[2] or 255) / 255,
			(kwargs.color[3] or 255) / 255,
			(kwargs.color[4] or 255) / 255 }
		or { 1, 1, 1, 1 }
		udata.pcolor = kwargs.pcolor and {
			(kwargs.pcolor[1] or 255) / 255,
			(kwargs.pcolor[2] or 255) / 255,
			(kwargs.pcolor[3] or 255) / 255,
			(kwargs.pcolor[4] or 255) / 255 }
		or udata.color
	end

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt] table kwargs  Keyword arguments. See @{l2df.class.component.print.set|Print:set()} for additional description.
	-- @param[opt=false] boolean kwargs.hidden  Text's hidden state. Applies to entity's hidden state.
	-- @param[opt=0] number kwargs.x  Text's X position. Careful: if setted it will change entity's position.
	-- @param[opt=0] number kwargs.y  Text's Y position. Careful: if setted it will change entity's position.
	-- @param[opt=0] number kwargs.z  Text's Z position. Careful: if setted it will change entity's position.
	-- @param[opt=0] number kwargs.r  Text's rotation in radians. Careful: if setted it will change entity's rotation.
	-- @param[opt=1] number kwargs.scalex  Text's X scale. Careful: if setted it will change entity's scale.
	-- @param[opt=1] number kwargs.scaley  Text's Y scale. Careful: if setted it will change entity's scale.
	-- @param[opt=0] number kwargs.centerx  Text's origin X position. Doesn't apply if entity already has origin setted.
	-- @param[opt=0] number kwargs.centery  Text's origin Y position. Doesn't apply if entity already has origin setted.
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

		data.centerx = data.centerx or kwargs.centerx or 0
		data.centery = data.centery or kwargs.centery or 0

		data.hidden = kwargs.hidden or data.hidden or false

		self:set(obj, kwargs)
	end

	--- Component post-update event handler.
	-- @param l2df.class.entity obj  Entity's instance.
	function Print:postupdate(obj)
		local data = obj.data
		local cdata = self:data(obj)
		if not data.hidden and cdata.font then
			local text, color = cdata.text, cdata.color
			if #text == 0 then
				text, color = cdata.placeholder, cdata.pcolor
			end
			if #text == 0 then return end
			RenderManager:draw({
				text = text,
				font = cdata.font,
				align = cdata.align,
				limit = cdata.limit,
				color = color,

				x = data.globalX or data.x,
				y = data.globalY or data.y,
				z = data.globalZ or data.z,
				r = data.r,

				sx = data.scalex,
				sy = data.scaley,
				ox = data.centerx,
				oy = data.centery,
			})
		end
	end

return Print
