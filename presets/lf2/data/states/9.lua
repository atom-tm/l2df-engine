--- Catching
local core = assert(l2df, 'L2DF is not available')
local shared = assert(data, 'Shared data is not available')

local frame = require 'data.scripts.frame'
local log = core.import 'class.logger'
local catch = require 'data.kinds.catch'

local tostring = _G.tostring
local abs = math.abs
local floor = math.floor

local function tickCatchTimer(catcher, cdata, victim)
	if cdata._lf2_catch_timer then
		cdata._lf2_catch_timer = cdata._lf2_catch_timer - 1
		if cdata._lf2_catch_timer <= 0 then
			frame.set(catcher, 0)
			catch.release(catcher, victim)
			return true
		end
	end
	return false
end

return function (catcher, cdata)
	local victim = cdata and cdata._lf2_caught
	if not (victim and victim.active ~= false) then
		if cdata then
			cdata._lf2_caught = nil
		end
		return
	end
	local cp = catch.cpoint(cdata)
	if not cp then
		if cdata.frame and cdata.frame.id == 234 then
			if cdata._lf2_pending_throw_lying then
				cdata._lf2_pending_throw_lying = nil
				victim.data._lf2_fall_ignore = catcher
				catch.setCaughtFrame(victim, 181)
			end
			return
		end
		catch.release(catcher, victim)
		return
	end
	if cdata._lf2_catch_entry_timer then
		cdata._lf2_catch_entry_timer = cdata._lf2_catch_entry_timer - 1
		if cdata._lf2_catch_entry_timer <= 0 then
			cdata._lf2_catch_entry_timer = nil
			frame.set(catcher, 121)
			tickCatchTimer(catcher, cdata, victim)
			return
		end
	end
	if cdata.frame and cdata.frame.id == 121 then
		cdata.next = 121
	end
	if cdata.frame and cdata.frame.id == 123 and cp.injury then
		if frame.entered(cdata, 'catch_hurt') then
			cdata.wait = 4
			cdata.frame.wait = 4
			cdata._lf2_catch_hurt_delay = core:convert(1)
			cdata._lf2_catch_hurt_timer = core:convert(5)
		end
	end
	if cdata.frame and cdata.frame.id == 233 and cp.throwvx then
		if frame.entered(cdata, 'throw_lying_release') then
			cdata.wait = 0
			cdata.frame.wait = 0
			cdata._lf2_pending_throw_lying = true
		end
		return
	end
	local control = catcher.C and catcher.C.controller
	local attack = control and control.hitted('attack')
	if cdata.frame and cdata.frame.id == 121 and cp.aaction and not attack then
		cdata._lf2_catch_attack_delay = (cdata._lf2_catch_attack_delay or 0) + 1
	end
	if attack and cp.taction and (
		control.pressed(cdata.facing == -1 and 'left' or 'right') or
		control.pressed(cdata.facing == -1 and 'right' or 'left')
	) then
		cdata._lf2_catch_timer = nil
		cdata._lf2_catch_attack_delay = 0
		cdata._lf2_catch_hurt_timer = nil
		cdata._lf2_catch_hurt_delay = nil
		catch.setCaughtFrame(victim, 135)
		frame.set(catcher, abs(catch.firstFrame(cp.taction)), true)
		return
	end
	if attack and cp.aaction then
		local attacks = cdata._lf2_catch_attacks or 0
		local delay = cdata._lf2_catch_attack_delay or 0
		delay = delay > 0 and floor(delay * 2 / 3 + 0.5) or 0
		local total_delay = cdata._lf2_catch_total_attack_delay or 0
		local extension = attacks == 0 and 2 or attacks >= 4 and total_delay <= 3 and 2 or attacks >= 4 and 4 or 3
		if shared.test and shared.test.debug then
			log:debug('LF2 catch attack player=%s attacks=%s delay=%s total=%s timer=%s',
				tostring(cdata.player or cdata.index or cdata.lf2id or '?'),
				tostring(attacks),
				tostring(delay),
				tostring(total_delay),
				tostring(cdata._lf2_catch_timer or 0))
		end
		cdata._lf2_catch_attacks = attacks + 1
		cdata._lf2_catch_attack_delay = 0
		cdata._lf2_catch_total_attack_delay = total_delay + delay
		cdata._lf2_catch_timer = (cdata._lf2_catch_timer or 0)
			+ delay
			+ core:convert(extension)
		frame.set(catcher, catch.firstFrame(cp.aaction), true)
		return
	end
	if (cdata._lf2_catch_hurt_delay or 0) > 0 then
		cdata._lf2_catch_hurt_delay = cdata._lf2_catch_hurt_delay - 1
		tickCatchTimer(catcher, cdata, victim)
		return
	end
	if (cdata._lf2_catch_hurt_timer or 0) > 0 then
		cdata._lf2_catch_hurt_timer = cdata._lf2_catch_hurt_timer - 1
		catch.setCaughtFrame(victim, 132)
		tickCatchTimer(catcher, cdata, victim)
		return
	end
	local changed = false
	if cp.vaction then
		changed = catch.setCaughtFrame(victim, catch.firstFrame(cp.vaction))
	end
	if victim.data.frame and (victim.data.frame.id == 130 or victim.data.frame.id == 132) then
		victim.data.next = victim.data.frame.id
	end
	if changed and catch.firstFrame(cp.vaction) == 130 and not cdata._lf2_catch_shifted_130 then
		catch.shiftObject(victim, -9 * (cdata.facing or 1), 0)
		cdata._lf2_catch_shifted_130 = true
	end
	tickCatchTimer(catcher, cdata, victim)
end
