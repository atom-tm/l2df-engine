--- Render component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.render
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'
local Component = core.import 'class.component'
local World = core.import 'class.component.physix.world'
local Renderer = core.import 'manager.render'
local Resources = core.import 'manager.resource'

local min = math.min
local ceil = math.ceil
local newQuad = love.graphics.newQuad

local greenColor = { 0, 1, 0, 0.3 }
local yellowColor = { 1, 1, 0, 0.5 }
local redColor = { 1, 0, 0, 0.5 }

local Render = Component:extend({ unique = true })

	--- Table describing &lt;sprite&gt; structure.
	-- @field string res  File path to spritesheet / sprite resource
	-- @field number w  Width of the image's area for clipping (<= full image width)
	-- @field number h  Height of the image's area for clipping (<= full image height)
	-- @field[opt=1] number x  Sprites' count per row
	-- @field[opt=1] number y  Sprites' count per column
	-- @field[opt=1] number s  Number of the first `S` sprites to skip
	-- @field[opt=x*y] number f  Total count of sprites to add from the specified image file.
	-- Currently also counts skipped sprites (would be fixed in future)
	-- @field[opt=0] number ox  Clipping area's X-offset (the left upper corner)
	-- @field[opt=0] number oy  Clipping area's Y-offset (the left upper corner)
	-- @field[opt=0] number kx
	-- @field[opt=0] number ky
	-- @field[opt] number ord  Index of the first sprite to start from.
	-- Used for appending new sprites to already existing collection
	-- @table .Sprite

	--- Blending color.
	-- To access use @{l2df.class.component.data|Render:data()} function.
	-- @field {0..1,0..1,0..1,0..1} Render.data.color

	--- Background color.
	-- To access use @{l2df.class.component.data|Render:data()} function.
	-- @field {0..1,0..1,0..1,0..1} Render.data.bgcolor

	--- Border color.
	-- To access use @{l2df.class.component.data|Render:data()} function.
	-- @field {0..1,0..1,0..1,0..1} Render.data.bcolor

	--- Border width.
	-- To access use @{l2df.class.component.data|Render:data()} function.
	-- @number Render.data.border

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- Adds `"render"` key to the @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] {l2df.class.component.render.Sprite,...} kwargs.sprites  Array of sprites to be added with @{l2df.class.component.render.addSprite|Render:addSprite()} method.
	-- @param[opt=0] number kwargs.w  BBox width. Doesn't apply if entity already has width setted.
	-- @param[opt=0] number kwargs.h  BBox height. Doesn't apply if entity already has height setted.
	-- @param[opt=1] number kwargs.scalex  BBox X scale. Doesn't apply if entity already has scale setted.
	-- @param[opt=1] number kwargs.scaley  BBox Y scale. Doesn't apply if entity already has scale setted.
	-- @param[opt=0] number kwargs.centerx  BBox origin X position. Doesn't apply if entity already has origin setted.
	-- @param[opt=0] number kwargs.centery  BBox origin Y position. Doesn't apply if entity already has origin setted.
	-- @param[opt=0] number kwargs.radiusx  BBox X border smoothing. Doesn't apply if entity already has smoothing setted.
	-- @param[opt=0] number kwargs.radiusy  BBox Y border smoothing. Doesn't apply if entity already has smoothing setted.
	-- @param[opt=1] number kwargs.border  BBox border width.
	-- @param[opt=1] number kwargs.facing  Entity's X orientation (not whole axis). Can be 1 or -1 (mirrored).
	-- Used for mirroring rendered content. Doesn't apply if entity already has facing setted.
	-- @param[opt=1] number kwargs.yorientation  Y axis sign. Can be 1 or -1 (for UI elements).
	-- Used for corrent UI processing which has inverted Y axis. Doesn't apply if entity already has yorientation setted.
	-- @param[opt=1] number kwargs.pic  Current drawing sprite's index. Doesn't apply if entity already has pic setted.
	-- @param[opt=false] boolean kwargs.shadow  True if entity has drop-shadow effect. False otherwise.
	-- @param[opt] {l2df.manager.render.Light} kwargs.lights  Array of @{l2df.manager.render.addLight|lights} used for shadows.
	-- Usually you may add it for root @{l2df.class.entity.scene|scenes} / @{l2df.class.entity.map|maps} entities.
	-- @param[opt] string kwargs.layer  @{l2df.manager.render.addLayer|Layer} for drawing. Careful: if setted it will change entity's layer.
	-- @param[opt] {0..255,0..255,0..255,0..255} kwargs.color  RGBA color used for blending. Defaults to `{255, 255, 255, 255}` (white).
	-- @param[opt] {0..255,0..255,0..255,0..255} kwargs.bgcolor  BBox background's RGBA color. Defaults to `nil` (transparent).
	-- @param[opt] {0..255,0..255,0..255,0..255} kwargs.bcolor  BBox border's RGBA color. Defaults to `nil` (transparent).
	function Render:added(obj, kwargs)
		if not obj then return false end

		kwargs = kwargs or { }
		local sprites = type(kwargs.sprites) == 'table' and kwargs.sprites or nil
		local bgcolor = type(kwargs.bgcolor) == 'table' and kwargs.bgcolor or nil
		local bcolor = type(kwargs.bcolor) == 'table' and kwargs.bcolor or nil
		if not (sprites or bgcolor or bcolor) then
			-- log:warn('Removed RenderComponent from "%s": empty render data', obj.name)
			return obj:removeComponent(self)
		end

		local data = obj.data
		local cdata = self:data(obj)

		obj.C.render = self:wrap(obj)

		data.x = data.x or 0
		data.y = data.y or 0
		data.z = data.z or 0
		data.r = data.r or 0

		data.w = data.w or kwargs.w or 0
		data.h = data.h or kwargs.h or 0

		data.scalex = data.scalex or kwargs.scalex or 1
		data.scaley = data.scaley or kwargs.scaley or 1

		data.centerx = data.centerx or kwargs.centerx or 0
		data.centery = data.centery or kwargs.centery or 0

		data.radiusx = data.radiusx or kwargs.radiusx or 0
		data.radiusy = data.radiusy or kwargs.radiusy or 0

		data.facing = data.facing or kwargs.facing or 1
		data.yorientation = data.yorientation or kwargs.yorientation or 1

		data.hidden = data.hidden or false
		data.pic = data.pic or kwargs.pic or 1

		data.lights = kwargs.lights or { }
		data.shadow = kwargs.shadow and true or false
		data.layer = kwargs.layer

		cdata.color = kwargs.color and {
			(kwargs.color[1] or 255) / 255,
			(kwargs.color[2] or 255) / 255,
			(kwargs.color[3] or 255) / 255,
			(kwargs.color[4] or 255) / 255
		} or { 1, 1, 1, 1 }

		cdata.bgcolor = bgcolor and {
			(bgcolor[1] or 255) / 255,
			(bgcolor[2] or 255) / 255,
			(bgcolor[3] or 255) / 255,
			(bgcolor[4] or 255) / 255
		} or nil

		cdata.bcolor = bcolor and {
			(bcolor[1] or 255) / 255,
			(bcolor[2] or 255) / 255,
			(bcolor[3] or 255) / 255,
			(bcolor[4] or 255) / 255
		} or nil

		cdata.border = kwargs.border or 1
		cdata.pics = { }
		if sprites then
			sprites = sprites[1] and type(sprites[1]) == 'table' and sprites or { sprites }
			for i = 1, #sprites do
				self:addSprite(obj, sprites[i])
			end
		end
	end

	--- Component was removed from @{l2df.class.entity|Entity} event.
	-- Removes `"render"` key from @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	function Render:removed(obj)
		self.super.removed(self, obj)
		obj.C.render = nil
	end

	--- Adds single / multiple sprite(s) from a spritesheet.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param l2df.class.component.render.Sprite sprite  Table describing data to load.
	function Render:addSprite(obj, sprite)
		local data = obj.data
		local cdata = self:data(obj)

		sprite.res = sprite.res or sprite[1] or nil
		sprite.w = sprite.w or sprite[2] or nil
		sprite.h = sprite.h or sprite[3] or nil
		sprite.x = sprite.x or sprite[4] or 1
		sprite.y = sprite.y or sprite[5] or 1

		local count = sprite.x * sprite.y
		if count <= 0 then return end

		sprite.s = sprite.s or sprite[6] or 1
		sprite.f = sprite.f or sprite[7] or count
		sprite.ox = sprite.ox or sprite[8] or 0
		sprite.oy = sprite.oy or sprite[9] or 0
		sprite.kx = sprite.kx or sprite[10] or 0
		sprite.ky = sprite.ky or sprite[11] or 0
		sprite.ord = sprite.ord or sprite[12] or #cdata.pics

		local num = 0
		for y = 1, sprite.y do
			for x = 1, sprite.x do
				num = num + 1
				if (sprite.s <= num) and (num <= sprite.f) then
					cdata.pics[sprite.ord + (num - sprite.s) + 1] = false
				end
			end
		end

		if not Resources:loadAsync(sprite.res, function (id, img)
			local num = 0
			for y = 1, sprite.y do
				for x = 1, sprite.x do
					num = num + 1
					if (sprite.s <= num) and (num <= sprite.f) then
						local w, h = img:getDimensions()
						sprite.w = sprite.w or (w / sprite.x)
						sprite.h = sprite.h or (h / sprite.y)
						cdata.pics[sprite.ord + (num - sprite.s) + 1] = {
							sprite.res,
							newQuad(
								(x - 1) * (sprite.w + sprite.kx) + sprite.ox,
								(y - 1) * (sprite.h + sprite.ky) + sprite.oy,
								sprite.w,
								sprite.h,
								w, h
							)
						}
					end
				end
			end
		end) then
			log:error('Data error: %s', sprite.res)
			return
		end
	end

	--- Component update event handler.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
	-- @param boolean islast  Draws only the last processed frame.
	function Render:update(obj, dt, islast)
		if not (obj and islast) then return end

		local data = self:data(obj)
		local world = World.getFromContext()
		local wdata = world and world.data()
		local ground = world and world.borders.y1 or nil
		local lights = data.lights
		obj.data.layer = wdata and wdata.layer or data.layer
		for i = 1, #lights do
			local light = lights[i]
			Renderer:addLight {
				x = (data.globalX or data.x) + light.x or 0,
				y = (data.globalY or data.y) + light.y or 0,
				z = (data.globalZ or data.z) + light.z or 0,
				r = light.r or 0,
				f = light.f,
				shadow = light.shadow,
				ground = ground,
			}
		end
	end

	--- Component post-update event handler.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
	-- @param boolean islast  Draws only the last processed frame.
	function Render:postupdate(obj, dt, islast)
		if not (obj and islast) then return end

		local data = obj.data
		local cdata = self:data(obj)
		if data.hidden then return end
		local x, y, z = data.globalX or data.x, (data.globalY or data.y) * data.yorientation, data.globalZ or data.z
		local sx, sy = (data.globalScaleX or data.scalex), (data.globalScaleY or data.scaley)
		if cdata.bgcolor then
			Renderer:draw {
				layer = data.layer,
				rect = 'fill',
				x = x,
				y = z - y,
				w = data.w * sx,
				h = data.h * sy,
				rx = data.radiusx,
				ry = data.radiusy,
				color = cdata.bgcolor
			}
		end
		if cdata.bcolor then
			Renderer:draw {
				layer = data.layer,
				rect = 'line',
				x = x,
				y = z - y,
				w = data.w * sx,
				h = data.h * sy,
				rx = data.radiusx,
				ry = data.radiusy,
				color = cdata.bcolor,
				border = cdata.border
			}
		end
		local pic = cdata.pics[data.pic]
		if pic then
			Renderer:draw {
				layer = data.layer,
				object = Resources:get(pic[1]),
				quad = pic[2],
				x = x,
				y = y,
				z = z,
				r = data.globalR or data.r,
				sx = sx * data.facing,
				sy = sy,
				ox = data.centerx,
				oy = data.centery,
				shadow = data.shadow,
				color = cdata.color
			}
		end

		if not Renderer.DEBUG then return end

		Renderer:draw {
			layer = data.layer,
			circle = 'fill',
			x = x,
			y = y,
			z = z,
			color = cdata.color
		}

		local bodies, body = data.bodies
		if bodies then
			for i = 1, #bodies do
				body = bodies[i]
				Renderer:draw {
					layer = data.layer,
					cube = true,
					x = x + (body.x or 0) * data.facing + (body.w or 0) * (data.facing - 1) * 0.5,
					y = y - (body.y or 0) * data.yorientation,
					z = z + (body.z or 0),
					w = (body.w or 0),
					h = (body.h or 0),
					d = (body.d or 0),
					color = greenColor
				}
			end
		end

		local itrs, itr = data.itrs
		if itrs then
			for i = 1, #itrs do
				itr = itrs[i]
				Renderer:draw {
					layer = data.layer,
					cube = true,
					x = x + (itr.x or 0) * data.facing + (itr.w or 0) * (data.facing - 1) * 0.5,
					y = y - (itr.y or 0) * data.yorientation,
					z = z + (itr.z or 0),
					w = (itr.w or 0),
					h = (itr.h or 0),
					d = (itr.d or 0),
					color = redColor
				}
			end
		end
	end

return Render
