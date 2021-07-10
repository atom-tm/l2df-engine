local core = assert(l2df, 'L2DF is not available')

local Component = core.import 'class.component'
local Renderer = core.import 'manager.render'

local pairs = _G.pairs

local greenColor = { 0, 1, 0, 0.3 }
local yellowColor = { 1, 1, 0, 0.7 }
local blackColor = { 0, 0, 0, 1.0 }
local redColor = { 1, 0, 0, 0.8 }

local Attributes = Component:extend({ unique = true })

	function Attributes:added(obj, kwargs)
		if not obj then return false end

		kwargs = kwargs or { }

		obj.C.attr = self:wrap(obj)

		local cdata = self:data(obj)
		cdata.damaged = { ___hasnil = true }
		cdata.ignored = { ___hasnil = true }
		cdata.recovered = true
		cdata.hp = cdata.hp or 1000
		cdata.sp = cdata.sp or 1000
		cdata.maxhp = cdata.hp
		cdata.maxsp = cdata.sp

		local scale = 1 / core:convert(1)
		cdata.walking_frame_rate = (kwargs.walking_frame_rate or 3) * scale
		cdata.walking_speed = (kwargs.walking_speed or 4) * scale
		cdata.walking_speedz = (kwargs.walking_speedz or 2) * scale
		cdata.running_frame_rate = (kwargs.running_frame_rate or 3) * scale
		cdata.running_speed = (kwargs.running_speed or 8) * scale
		cdata.running_speedz = (kwargs.running_speedz or 1.3) * scale
		cdata.heavy_walking_speed = (kwargs.heavy_walking_speed or 3) * scale
		cdata.heavy_walking_speedz = (kwargs.heavy_walking_speedz or 1.5) * scale
		cdata.heavy_running_speed = (kwargs.heavy_running_speed or 5) * scale
		cdata.heavy_running_speedz = (kwargs.heavy_running_speedz or 0.8) * scale
		cdata.jump_height = -(kwargs.jump_height or -16.3) * scale
		cdata.jump_distance = (kwargs.jump_distance or 8) * scale
		cdata.jump_distancez = (kwargs.jump_distancez or 3) * scale
		cdata.dash_height = -(kwargs.dash_height or -11) * scale * 0.5
		cdata.dash_distance = (kwargs.dash_distance or 15) * scale * 0.5
		cdata.dash_distancez = (kwargs.dash_distancez or 3.75) * scale * 0.5
		cdata.rowing_height = (kwargs.rowing_height or -2) * scale
		cdata.rowing_distance = (kwargs.rowing_distance or 5) * scale
	end

	function Attributes:removed(obj)
		if not obj then return end
		obj.C.attr = nil
	end

	function Attributes:isdamaged(obj, source)
		return obj and source and obj.data[self].damaged[source] and true or false
	end

	function Attributes:isrecovered(obj)
		return obj and obj.data[self].recovered and true or false
	end

	function Attributes:recover(obj, speed)
		if not obj then return end
		local cdata = self:data(obj)
		cdata.sp = cdata.sp + (speed or 1)
		if cdata.sp > cdata.maxsp then
			cdata.sp = cdata.maxsp
			cdata.recovered = true
			return false
		end
		return true
	end

	function Attributes:consume(obj, speed)
		if not obj then return end
		local cdata = self:data(obj)
		cdata.sp = cdata.sp - (speed or 1)
		if cdata.sp <= 0 then
			cdata.sp = 0
			cdata.recovered = false
			return false
		end
		return true
	end

	function Attributes:damage(obj, source)
		if not (obj and source) then return end

		local cdata = self:data(obj)
		local damaged, ignored = cdata.damaged, cdata.ignored
		local t = obj.stand and 'player' or 'stand'
		if damaged[source] or ignored[source] then
			return
		end
		cdata.hp = cdata.hp - (source.injury or 0)
		if cdata.hp <= 0 then
			cdata.hp = 0
		end
		damaged[source] = source.delay or 0.5
	end

	function Attributes:reflect(obj, source)
		if not (obj and source) then return end
		local cdata = self:data(obj)
		local damaged, ignored = cdata.damaged, cdata.ignored
		if damaged[source] then
			cdata.hp = cdata.hp + (source.injury or 0)
			damaged[source] = nil
		end
		if not ignored[source] then
			cdata.sp = cdata.sp - (source.injury or 0) * 2
			if cdata.sp <= 0 then
				cdata.sp = 0
				cdata.recovered = false
			end
		end
		ignored[source] = source.delay or 0.5
	end

	-- function Attributes:update(obj, dt)
	-- 	local cdata = self:data(obj)
	-- 	local damaged, ignored = cdata.damaged, cdata.ignored
	-- 	for src, time in pairs(damaged) do
	-- 		damaged[src] = src == '___hasnil' or time > dt and time - dt or nil
	-- 	end
	-- 	for src, time in pairs(ignored) do
	-- 		ignored[src] = src == '___hasnil' or time > dt and time - dt or nil
	-- 	end
	-- end

	-- function Attributes:postupdate(obj, dt, islast)
	-- 	if not (obj and islast) then return end

	-- 	local data = obj.data
	-- 	local cdata = self:data(obj)
	-- 	if data.hidden then return end

	-- 	local x, y, z = data.globalX or data.x, (data.globalY or data.y) * data.yorientation, data.globalZ or data.z
	-- 	local sx, sy = (data.globalScaleX or data.scalex), (data.globalScaleY or data.scaley)

	-- 	-- Health Bar
	-- 	Renderer:draw {
	-- 		layer = data.layer,
	-- 		rect = 'fill',
	-- 		x = x - 36 * 0.5,
	-- 		y = z - y - 6 * 0.5 + 8,
	-- 		z = z,
	-- 		w = 36 * sx * (cdata.hp / cdata.maxhp),
	-- 		h = 4 * sy,
	-- 		color = redColor
	-- 	}

	-- 	-- Power Bar
	-- 	Renderer:draw {
	-- 		layer = data.layer,
	-- 		rect = 'fill',
	-- 		x = x - 36 * 0.5,
	-- 		y = z - y - 6 * 0.5 + 12,
	-- 		z = z,
	-- 		w = 36 * sx * (cdata.sp / cdata.maxsp),
	-- 		h = 2 * sy,
	-- 		color = yellowColor
	-- 	}

	-- 	-- Border
	-- 	Renderer:draw {
	-- 		layer = data.layer,
	-- 		rect = 'line',
	-- 		x = x - 38 * 0.5,
	-- 		y = z - y - 8 * 0.5 + 8,
	-- 		z = z,
	-- 		w = 38 * sx,
	-- 		h = 8 * sy,
	-- 		rx = 2,
	-- 		ry = 2,
	-- 		color = blackColor,
	-- 		border = 2
	-- 	}
	-- end

return Attributes
