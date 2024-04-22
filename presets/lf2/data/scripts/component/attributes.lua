local core = assert(l2df, 'L2DF is not available')

local Component = core.import 'class.component'
local Renderer = core.import 'manager.render'
local Resources = core.import 'manager.resource'

local pairs = _G.pairs
local floor = math.floor

local blueColor = { 0, 0, 1, 1 }
local redColor = { 1, 0, 0, 1 }
local darkBlueColor = { 31 / 255, 8 / 255, 111 / 255, 1 }
local darkRedColor = { 111 / 255, 8 / 255, 31 / 255, 1 }

local MAX_PAIN = 60
local MAX_DEFENCE = 45

local Attributes = Component:extend({ unique = true })

	function Attributes:added(obj, kwargs)
		if not obj then return false end

		kwargs = kwargs or { }

		obj.C.attr = self:wrap(obj)

		local data = obj.data
		data.stunned = false
		data.index = data.index or data.player or 1

		if obj.C.render then
			data.avatar = obj.C.render.addSprite({ kwargs.small })
		end

		local cdata = self:data(obj)
		cdata.cansuper = false
		cdata.damaged = { ___hasnil = true }
		cdata.ignored = { ___hasnil = true }
		cdata.recovered = true
		cdata.candefend = false
		cdata.defence = MAX_DEFENCE
		cdata.pain = MAX_PAIN
		cdata.dtimer = 0
		cdata.ptimer = 0
		cdata.maxhp = 500
		cdata.maxmp = 1000
		cdata.totalhp = cdata.maxhp
		cdata.totalmp = cdata.maxmp
		cdata.hp = cdata.hp or cdata.maxhp
		cdata.mp = cdata.mp or cdata.maxmp * 0.5

		local scale = 1 / core:convert(1)
		cdata.walking_frame_rate = kwargs.walking_frame_rate or 3
		cdata.walking_speed = (kwargs.walking_speed or 4)
		cdata.walking_speedz = (kwargs.walking_speedz or 2)
		cdata.running_frame_rate = kwargs.running_frame_rate or 3
		cdata.running_speed = (kwargs.running_speed or 8)
		cdata.running_speedz = (kwargs.running_speedz or 1.3)
		cdata.heavy_walking_speed = (kwargs.heavy_walking_speed or 3)
		cdata.heavy_walking_speedz = (kwargs.heavy_walking_speedz or 1.5)
		cdata.heavy_running_speed = (kwargs.heavy_running_speed or 5)
		cdata.heavy_running_speedz = (kwargs.heavy_running_speedz or 0.8)
		cdata.jump_height = -(kwargs.jump_height or -16.3) * scale
		cdata.jump_distance = (kwargs.jump_distance or 8) --* scale
		cdata.jump_distancez = (kwargs.jump_distancez or 3) * scale
		cdata.dash_height = -(kwargs.dash_height or -11) * scale
		cdata.dash_distance = (kwargs.dash_distance or 15) --* scale
		cdata.dash_distancez = (kwargs.dash_distancez or 3.75) * scale
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

	function Attributes:recover(obj, amount)
		if not obj then return end
		local cdata = self:data(obj)
		cdata.mp = cdata.mp + (amount or 1)
		if cdata.mp > cdata.maxmp then
			cdata.mp = cdata.maxmp
			cdata.recovered = true
			return false
		end
		return true
	end

	function Attributes:consume(obj, amount)
		if not obj then return end
		local cdata = self:data(obj)
		cdata.mp = cdata.mp - (amount or 1)
		if cdata.mp <= 0 then
			cdata.mp = 0
			cdata.recovered = false
			return false
		end
		return true
	end

	function Attributes:damage(obj, source, ignore_defence)
		if not (obj and source) then return end

		local cdata = self:data(obj)
		local damaged, ignored = cdata.damaged, cdata.ignored
		local injury = source.injury or 0
		local bdefend = source.bdefend or injury
		local fall = source.fall or injury
		if not ignore_defence and cdata.candefend and cdata.defence > 0 and not ignored[source] then
			ignored[source] = core:convert(source.arest or source.vrest or 5)
			cdata.hp = cdata.hp - injury * 0.2
			if cdata.hp <= 0 then
				cdata.hp = 0
				cdata.defence = 0
			else
				cdata.defence = cdata.defence - bdefend
			end
			cdata.dtimer = 1
		end
		if damaged[source] or ignored[source] then
			return false
		end
		cdata.maxhp = cdata.maxhp - injury * 0.25
		cdata.hp = cdata.hp - injury
		if cdata.hp <= 0 then
			cdata.hp = 0
			cdata.maxhp = 0
			cdata.pain = 0
		elseif cdata.hp > cdata.maxhp then
			cdata.maxhp = cdata.hp
		end
		if cdata.maxhp > cdata.totalhp then
			cdata.hp = cdata.totalhp
			cdata.maxhp = cdata.totalhp
		end
		cdata.ptimer = 1
		cdata.pain = cdata.pain - fall
		damaged[source] = core:convert(source.arest or source.vrest or 5)
		return true
	end

	function Attributes:preupdate(obj)
		obj.data.stunned = false
		obj.data[self].candefend = false
	end

	function Attributes:update(obj, dt)
		local cdata = self:data(obj)
		local damaged, ignored = cdata.damaged, cdata.ignored
		for src, time in pairs(damaged) do
			damaged[src] = src == '___hasnil' or time > 1 and time - 1 or nil
		end
		for src, time in pairs(ignored) do
			ignored[src] = src == '___hasnil' or time > 1 and time - 1 or nil
		end
		cdata.hp = cdata.hp + 5 * dt
		if cdata.hp > cdata.maxhp then
			cdata.hp = cdata.maxhp
		end
		cdata.mp = cdata.mp + 20 * dt
		if cdata.mp > cdata.maxmp then
			cdata.mp = cdata.maxmp
			cdata.recovered = true
		end
		if cdata.ptimer - dt > 0 then
			cdata.ptimer = cdata.ptimer - dt
		elseif cdata.ptimer > 0 then
			cdata.ptimer = 0
			cdata.pain = MAX_PAIN
		end
		if cdata.dtimer - dt > 0 then
			cdata.dtimer = cdata.dtimer - dt
		elseif cdata.dtimer > 0 then
			cdata.dtimer = 0
			cdata.defence = MAX_DEFENCE
		end
		cdata.cansuper = false
	end

	function Attributes:postupdate(obj, dt, islast)
		if not (obj and islast) then return end

		local data = obj.data
		local cdata = self:data(obj)
		if data.hidden then return end

		-- Avatar
		local avatar = data.avatar and obj.storage.pics[data.avatar]
		if avatar then
			Renderer:draw {
				object = Resources:get(avatar[1]),
				quad = avatar[2],
				x = 8 + 244 * ((data.index - 1) % 4),
				z = 4 + 54 * floor((data.index - 1) / 4)
				-- color = cdata.color
			}
		end

		-- Health Bar
		Renderer:draw {
			rect = 'fill',
			x = 57 + 244 * ((data.index - 1) % 4),
			y = 16 + 54 * floor((data.index - 1) / 4),
			z = 0,
			w = 170 * (cdata.maxhp / cdata.totalhp),
			h = 10,
			color = darkRedColor
		}
		Renderer:draw {
			rect = 'fill',
			x = 57 + 244 * ((data.index - 1) % 4),
			y = 16 + 54 * floor((data.index - 1) / 4),
			z = 0,
			w = 170 * (cdata.hp / cdata.totalhp),
			h = 10,
			color = redColor
		}

		-- Power Bar
		Renderer:draw {
			rect = 'fill',
			x = 57 + 244 * ((data.index - 1) % 4),
			y = 36 + 54 * floor((data.index - 1) / 4),
			z = 0,
			w = 170 * (cdata.maxmp / cdata.totalmp),
			h = 10,
			color = darkBlueColor
		}
		Renderer:draw {
			rect = 'fill',
			x = 57 + 244 * ((data.index - 1) % 4),
			y = 36 + 54 * floor((data.index - 1) / 4),
			z = 0,
			w = 170 * (cdata.mp / cdata.totalmp),
			h = 10,
			color = blueColor
		}
	end

return Attributes
