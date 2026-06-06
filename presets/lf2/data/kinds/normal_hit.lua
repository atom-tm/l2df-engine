--- Normal hit
local core = assert(l2df, 'L2DF is not available')
local shared = assert(data, 'Shared data is not available')

local helper = core.import 'helper'
local log = core.import 'class.logger'
local frame = require 'data.scripts.frame'
local object = require 'data.scripts.object'
local relationship = require 'data.scripts.relationship'

local tostring = _G.tostring
local tremove = table.remove

local DEFAULT_HIT_STOP = 3
local sign = helper.sign

local function debugHit(label, e1, e2, itr)
	if not (shared.test and shared.test.debug) then
		return
	end
	local d1, d2 = e1 and e1.data or { }, e2 and e2.data or { }
	log:debug('LF2 %s attacker=%s/%s target=%s/%s injury=%s fall=%s dv=(%s,%s)',
		label,
		tostring(d1.player or d1.index or d1.lf2id or '?'),
		tostring(d1.frame and d1.frame.id or '?'),
		tostring(d2.player or d2.index or d2.lf2id or '?'),
		tostring(d2.frame and d2.frame.id or '?'),
		tostring(itr and itr.injury or '?'),
		tostring(itr and itr.fall or '?'),
		tostring(itr and itr.dvx or '?'),
		tostring(itr and itr.dvy or '?'))
end

local function hitSource(itr)
	return {
		owner = itr.owner,
		syncid = itr.syncid,
		syncindex = itr.syncindex,
		kind = itr.kind,
		arest = itr.arest,
		vrest = itr.vrest,
		dvx = itr.dvx,
		dvy = itr.dvy,
		dvz = itr.dvz,
		fall = itr.fall,
		bdefend = itr.bdefend,
		injury = itr.injury,
		effect = itr.effect,
	}
end

local function hitDirection(e1, e2)
	local edata = e1 and e1.data or { }
	local tdata = e2 and e2.data or { }
	local direction = sign((tdata.x or 0) - (edata.x or 0))
	return direction ~= 0 and direction or edata.facing or 1
end

local function terminalPunchFrame(data)
	local current = data and data.frame
	if not (current and current.keyword == 'punch') then
		return false
	end
	local id = current.id
	return data.lf2id == 1 and (id == 62 or id == 67)
end

local function apply(e1, e2, itr)
	if not (e1 and e2 and itr) then
		return false
	end
	if itr.owner == e2 or relationship.isFriendly(e1, e2) then
		return false
	end
	debugHit('apply', e1, e2, itr)

	local frames, attr, sound = e2.C.frames, e2.C.attr, e2.C.sound
	if not (frames and attr) then
		return false
	end
	local looks_in_same_direction = e1.data.facing == e2.data.facing
	if attr.damage(itr, looks_in_same_direction) then
		local pain = attr.data().pain
		local direction = hitDirection(e1, e2)
		e2.data._lf2_fall_ignore = pain < 0 and e1 or nil
		if pain < 0 then
			frames.set(looks_in_same_direction and 186 or 180)
		elseif pain == 0 then
			frames.set(226)
		elseif pain <= 20 or itr.injured2 then
			frames.set(looks_in_same_direction and 224 or 222)
		else
			frames.set(220)
		end
		if itr.dvx then
			e2.data.dvx = itr.dvx * direction
		end
		if itr.dvy then
			e2.data.dvy = -itr.dvy
		end
		if sound then
			sound.play(pain < 0 and 'super_punch' or 'punch', true)
		end
		object.projectileHit(e1)
		return true
	elseif e2.data.frame.id == 110 then
		frames.set(111)
		if sound then
			sound.play('block')
		end
		return true
	end
	return false
end

local function queue(e1, e2, itr)
	if not (e1 and e2 and itr) then
		return false
	end
	if itr.kind == 4 and e1.data and e1.data._lf2_fall_ignore == e2 then
		return false
	end
	if e1.data and e1.data.frame and e1.data.frame.id == 219 and itr.kind == 0 then
		return false
	end
	if terminalPunchFrame(e1.data) then
		local target_frame = e2.data and e2.data.frame and e2.data.frame.id
		if target_frame and target_frame >= 220 and target_frame <= 229 then
			return false
		end
	end
	local attr = e2.C and e2.C.attr
	if attr and attr.isdamaged(itr) then
		return false
	end
	debugHit('queue', e1, e2, itr)

	local target = e2.data
	local key = itr.syncid or table.concat {
		tostring(e1.data and (e1.data.syncid or e1.data.gsid or e1.data.index) or e1),
		':',
		tostring(itr.kind or 0),
		':',
		tostring(itr.syncindex or 0),
	}
	target._lf2_pending_hit_keys = target._lf2_pending_hit_keys or { }
	if target._lf2_pending_hit_keys[key] then
		return false
	end
	target._lf2_pending_hit_keys[key] = true
	target._lf2_pending_hits = target._lf2_pending_hits or { }

	local delay = 1
	if e1.data and e1.data.frame and e1.data.frame.keyword == 'dash_attack' then
		delay = e1.data.lf2id == 1 and 0 or 1
	elseif e1.data and e1.data.frame and e1.data.frame.keyword == 'super_punch' then
		delay = 1
	elseif e1.data and e1.data.frame and e1.data.frame.keyword == 'run_attack' then
		delay = (itr.fall or 0) > 60 and (itr.injury or 0) <= 15 and 3 or 1
	end

	local source = hitSource(itr)
	if e1.data and e1.data.lf2id == 1 and e1.data.frame and e1.data.frame.keyword == 'punch' then
		source.fall = math.max(source.fall or 0, 30)
		source.injured2 = true
	end
	target._lf2_pending_hits[#target._lf2_pending_hits + 1] = {
		attacker = e1,
		source = source,
		key = key,
		delay = core:convert(delay),
	}
	return true
end

local function processPending(obj)
	local target = obj and obj.data
	local pending = target and target._lf2_pending_hits
	if not pending then
		return false
	end
	local applied = false
	for i = #pending, 1, -1 do
		local hit = pending[i]
		hit.delay = (hit.delay or 0) - 1
		if hit.delay <= 0 then
			local attacker = hit.attacker
			if attacker and attacker.active ~= false and apply(attacker, obj, hit.source) then
				applied = true
				if not terminalPunchFrame(attacker.data) then
					frame.addWait(attacker, DEFAULT_HIT_STOP)
				end
			end
			if target._lf2_pending_hit_keys then
				target._lf2_pending_hit_keys[hit.key] = nil
			end
			tremove(pending, i)
		end
	end
	if #pending == 0 then
		target._lf2_pending_hits = nil
	end
	return applied
end

local function processReaction(obj)
	processPending(obj)
	return false
end

local function handle(e1, e2, itr, bdy)
	if itr.owner == bdy.owner or bdy.owner == e1 then
		return
	end
	if relationship.isFriendly(e1, e2) then
		return
	end
	return queue(e1, e2, itr)
end

return {
	handle = handle,
	apply = apply,
	queue = queue,
	processPending = processPending,
	processReaction = processReaction,
}
