--- Falling
local catch = require 'data.kinds.catch'
local frame = require 'data.scripts.frame'
local normalHit = require 'data.kinds.normal_hit'
local object = require 'data.scripts.object'

return function (obj, data)
	if normalHit.processReaction(obj) or catch.processReaction(obj) then
		return
	end

	local frames, control, sound = obj.C.frames, obj.C.controller, obj.C.sound
	if not (control and frames and sound) then return end

	local vy = data.vy
	local frameid = data.frame.id
	local rshift = frameid < 186 and 0 or 6
	local jmp = (data.hit_j or 0) == 0 and control.hitted('jump')
	if data._lf2_weapon and frame.entered(data, 'falling_drop_weapon') then
		object.dropWeapon(obj)
	end
	if data.ground then
		if data._lf2_ice_landing_damage then
			data._lf2_ice_landing_damage = nil
			local attr = obj.C.attr
			local adata = attr and attr.data()
			if adata then
				adata.hp = math.max(0, adata.hp - 10)
				if adata.hp <= 0 then
					adata.maxhp = 0
				elseif adata.hp > adata.maxhp then
					adata.hp = adata.maxhp
				end
			end
		end
		if frameid < 184 + rshift then
			frameid = 184 + rshift -- falling
			frames.set(frameid)
			sound.play('drop')
		elseif frameid == 185 + rshift then
			sound.play('bounce')
			data.dvx = l2df:convert(2) * (rshift == 0 and -1 or 1)
			data.next = 230 + (rshift == 0 and 0 or 1) -- lying
			return
		end
		data.wait = 0
		data.next = frameid + 1
	elseif jmp and frameid == 182 + rshift then
		data.flip = frameid == 182 and -1 or 1
		frames.set(frameid == 182 and 100 or 108) -- backflip / rowing
	elseif vy > 10 * 30 then
		frames.set(180 + rshift) -- falling
	elseif vy > 0 then
		frames.set(181 + rshift) -- falling
	elseif vy > -6 * 30 then
		frames.set(182 + rshift) -- falling
	else
		frames.set(183 + rshift) -- falling
	end
end
