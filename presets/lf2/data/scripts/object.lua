local core = assert(l2df, 'L2DF is not available')
local shared = assert(data, 'Shared data is not available')

local Factory = core.import 'manager.factory'
local Render = core.import 'class.component.render'
local SoundSystem = core.import 'class.component.sound'
local World = core.import 'class.component.physix.world'
local frame = require 'data.scripts.frame'
local relationship = require 'data.scripts.relationship'

local tostring = _G.tostring
local type = _G.type
local pairs = _G.pairs
local abs = math.abs
local huge = math.huge
local tremove = table.remove

local M = { }
local number = frame.number

local ignored_frame_fields = { [1] = true, [2] = true, id = true, keyword = true, ___shallow = true }
local hit_a_duration = {
	[1] = 400,
	[2] = 255,
	[3] = 180,
	[4] = 135,
	[5] = 100,
	[6] = 95,
	[7] = 75,
	[8] = 65,
	[9] = 55,
	[10] = 52,
	[20] = 24,
	[30] = 16,
	[40] = 12,
	[50] = 9,
}
local createObject

local function frameMotionValue(data, key)
	local frame = data and data.frame
	return frame and frame[key] or nil
end

local function projectileMotionValue(data, key, fallback, mirror)
	local value = frameMotionValue(data, key)
	if value == nil then
		value = data and data[key]
	end
	value = number(value, 0)
	if value == 0 then
		return fallback or 0
	end
	if mirror then
		value = value * (data.facing or 1)
	end
	return value
end

local function objectList()
	shared.lf2_objects = shared.lf2_objects or { }
	return shared.lf2_objects
end

local function frameStorage(obj)
	local frames = obj and obj.C and obj.C.frames
	local storage = frames and frames.data and frames.data()
	return storage and storage.list
end

local function frameExists(obj, id)
	local list = frameStorage(obj)
	return list and list[id] or nil
end

local function applyCurrentFrame(data)
	local frame = data and data.frame
	if type(frame) ~= 'table' then
		return
	end
	for key, value in pairs(frame) do
		if not ignored_frame_fields[key] then
			data[key] = value
		end
	end
end

local function currentState(data)
	local states = data and data.frame and data.frame.states
	if type(states) ~= 'table' then
		return nil
	end
	for i = 1, #states do
		local id = number(states[i], nil)
		if id then
			return id
		end
	end
	return nil
end

local function combatObjects(root)
	local list = { }
	if root and root.enum then
		for obj in root:enum(true, true) do
			local data = obj and obj.data
			if data and data._lf2 and not data.hidden then
				list[#list + 1] = obj
			end
		end
	end
	local dynamic = shared.lf2_objects
	if dynamic then
		for i = 1, #dynamic do
			local obj = dynamic[i]
			local data = obj and obj.data
			if data and data._lf2 and not data.hidden then
				list[#list + 1] = obj
			end
		end
	end
	return list
end

local function isAliveCharacter(obj)
	local data = obj and obj.data
	if not (data and data._lf2_type == 0 and obj.active ~= false) then
		return false
	end
	local attr = obj.C and obj.C.attr
	local adata = attr and attr.data()
	return not adata or (adata.hp or 0) > 0
end

local function reloadFrames(obj, source, frameid)
	local frames = obj.C and obj.C.frames
	if not (frames and source and source.frames) then
		return
	end
	local storage = frames.data()
	storage.added = { }
	storage.list = { }
	storage.map = { }
	storage.counter = 0
	obj.data.playonce = { }
	local playonce = source.playonce or { }
	for i = 1, #playonce do
		obj.data.playonce[playonce[i]] = true
	end
	for i = 1, #source.frames do
		frames.add(source.frames[i], i)
	end
	frames.set(frameid or 0)
	applyCurrentFrame(obj.data)
end

local function reloadRender(obj, source)
	if not (obj and source) then
		return
	end
	for _, component in obj.components:enum(true) do
		if component:isInstanceOf(Render) then
			obj:removeComponent(component)
		end
	end
	obj:addComponent(Render, source)
	if obj.C.render and source.small then
		obj.data.avatar = obj.C.render.addSprite({ source.small })
	end
end

local function updateAttributes(obj, source)
	local attr = obj.C and obj.C.attr
	local adata = attr and attr.data()
	if not (adata and source) then
		return
	end
	adata.walking_frame_rate = source.walking_frame_rate or adata.walking_frame_rate
	adata.walking_speed = source.walking_speed or adata.walking_speed
	adata.walking_speedz = source.walking_speedz or adata.walking_speedz
	adata.running_frame_rate = source.running_frame_rate or adata.running_frame_rate
	adata.running_speed = source.running_speed or adata.running_speed
	adata.running_speedz = source.running_speedz or adata.running_speedz
	adata.heavy_walking_speed = source.heavy_walking_speed or adata.heavy_walking_speed
	adata.heavy_walking_speedz = source.heavy_walking_speedz or adata.heavy_walking_speedz
	adata.heavy_running_speed = source.heavy_running_speed or adata.heavy_running_speed
	adata.heavy_running_speedz = source.heavy_running_speedz or adata.heavy_running_speedz
end

local function syncidBase(data)
	return tostring(data.syncid or data.gsid or data.player or data.index or 'object')
end

local function facingFromOpoint(owner_facing, value)
	value = number(value, 0)
	if value == 1 then
		return -owner_facing
	end
	return owner_facing
end

function M.registerDynamic(obj)
	local list = objectList()
	list[#list + 1] = obj
	return obj
end

function M.clearDynamic()
	local list = shared.lf2_objects
	if not list then
		return
	end
	for i = #list, 1, -1 do
		local obj = list[i]
		if obj and obj.destroy then
			obj:destroy()
		end
		list[i] = nil
	end
end

function M.syncDynamic(root, snapshot)
	local list = objectList()
	if not snapshot then
		local result = { }
		for i = 1, #list do
			local obj = list[i]
			if obj and obj.parent then
				result[#result + 1] = obj
			end
		end
		return result
	end

	local keep = { }
	for i = 1, #snapshot do
		keep[snapshot[i]] = true
	end
	for i = #list, 1, -1 do
		local obj = list[i]
		if obj and not keep[obj] then
			obj:destroy()
			tremove(list, i)
		end
	end
	for i = 1, #snapshot do
		local obj = snapshot[i]
		if obj and not obj.parent and root then
			root:attach(obj)
		end
	end
end

function M.despawn(obj)
	if not obj then
		return
	end
	local data = obj.data or { }
	data.hidden = true
	data.itrs = { }
	data.bodies = { }
	obj.active = false
end

function M.prepareFrame(obj, data, options)
	options = options or { }
	data._lf2 = true
	local generation = obj and obj.data and obj.data.___frame_generation
	local prepared
	if generation then
		prepared = data.___lf2_prepared_generation == generation
	else
		prepared = data.___lf2_prepared
	end

	if data.next == 999 then
		data.next = 0
	end
	local pic_offset = data._lf2_pic_offset or 0
	if data.frame and data.frame.pic then
		data.pic = data.frame.pic + 1 + pic_offset
	elseif data.pic and not prepared then
		data.pic = data.pic + 1 + pic_offset
	end

	if data._lf2_type == 3 then
		if (data.centerx or 0) == 0 and (data.centery or 0) == 0 and data._lf2_centerx then
			data.centerx = data._lf2_centerx
			data.centery = data._lf2_centery
		elseif (data.centerx or 0) ~= 0 or (data.centery or 0) ~= 0 then
			data._lf2_centerx = data.centerx
			data._lf2_centery = data.centery
		end
	end

	if options.scale_motion ~= false and (generation or not prepared) then
		local factor = 1 / core:convert(1)
		local dvy = frameMotionValue(data, 'dvy')
		if data.dvx == 550 then
			data.dvx = 0
			data.vx = 0
		elseif data.dvx then
			data.dvx = data.dvx * (data.facing or 1) * factor
		end
		if data.dvy == dvy and dvy == 550 then
			data.dvy = 0
			data.vy = 0
		elseif data.dvy == dvy and dvy ~= nil then
			data.dvy = -data.dvy * factor
		end
		if data.dvz == 550 then
			data.dvz = 0
			data.vz = 0
		elseif data.dvz then
			data.dvz = data.dvz * factor
		end
	end
	data.___lf2_prepared_generation = generation
	data.___lf2_prepared = true

	local bodies = data.bodies
	if bodies then
		for i = 1, #bodies do
			local body = bodies[i]
			if not body.___modified then
				body.x = (body.x or 0) - (data.centerx or 0)
				body.y = (body.y or 0) - (data.centery or 0)
				body.z = body.z or -(body.zwidth or 1)
				body.d = body.d or body.zwidth and body.zwidth * 2 or 2
				body.___modified = true
			end
		end
	end

	local itrs = data.itrs
	if itrs then
		local factor = 1 / core:convert(1)
		for i = 1, #itrs do
			local itr = itrs[i]
			if not itr.___modified then
				local zwidth = itr.zwidth or 16
				itr.x = (itr.x or 0) - (data.centerx or 0)
				itr.y = (itr.y or 0) - (data.centery or 0)
				itr.z = itr.z or -zwidth
				itr.d = itr.d or zwidth * 2
				if itr.dvx then
					itr.dvx = itr.dvx * factor
				end
				if itr.dvy then
					itr.dvy = itr.dvy * factor
				end
				itr.___modified = true
			end
		end
	end
end

function M.teleport(obj, mode)
	local data = obj and obj.data
	if not data then
		return false
	end
	local target, best = nil, mode == 2 and -huge or huge
	local list = combatObjects(obj.parent)
	for i = 1, #list do
		local other = list[i]
		if other ~= obj and isAliveCharacter(other) then
			local friendly = relationship.isFriendly(obj, other)
			if mode == 1 and not friendly or mode == 2 and friendly then
				local odata = other.data
				local distance = abs((odata.x or 0) - (data.x or 0)) + abs((odata.z or 0) - (data.z or 0))
				if mode == 1 and distance < best or mode == 2 and distance > best then
					target, best = other, distance
				end
			end
		end
	end
	if not target then
		data.y = 0
		return false
	end
	local tdata = target.data
	local offset = mode == 1 and 120 or 60
	local side = tdata.facing or data.facing or 1
	data.x = (tdata.x or 0) - offset * side
	data.y = 0
	data.z = (tdata.z or 0) + 1
	data.facing = side
	data.dx, data.dy, data.dz = 0, 0, 0
	data.vx, data.vy, data.vz = 0, 0, 0
	data.dvx, data.dvy, data.dvz = 0, 0, 0
	return true
end

function M.transformTo(obj, id, options)
	options = options or { }
	local data = obj and obj.data
	local source = id and shared.objectdata and shared.objectdata:getById(id)
	if not (obj and data and source) then
		return false
	end
	data._lf2_previous_id = options.previous_id or data._lf2_previous_id or data.lf2id
	data._lf2_type = source._lf2_type or data._lf2_type
	data.lf2id = id
	data.charid = source._lf2_type == 0 and id or data.charid
	data._lf2_pic_offset = options.pic_offset or nil
	reloadFrames(obj, source, options.frame or 0)
	reloadRender(obj, source)
	updateAttributes(obj, source)
	return true
end

function M.transformState500(obj)
	local data = obj and obj.data
	local frames = obj and obj.C and obj.C.frames
	if data and frames and (not data._lf2_transform_target or data._lf2_previous_id) then
		frames.set(0)
		return true
	end
	return false
end

function M.transformState501(obj)
	local data = obj and obj.data
	if not data then
		return false
	end
	local victim = data._lf2_caught
	local target = data._lf2_transform_target or victim and victim.data and victim.data.lf2id
	if not target then
		return false
	end
	return M.transformTo(obj, target)
end

function M.transformFromState(obj, data)
	local id = currentState(data)
	if not (id and id >= 8000 and id < 9000) then
		return false
	end
	if not frame.entered(data, 'transform_' .. tostring(id)) then
		return false
	end
	return M.transformTo(obj, id - 8000, { pic_offset = 140 })
end

function M.transformLouis(obj)
	if not frame.entered(obj and obj.data, 'louis_transform') then
		return false
	end
	return M.transformTo(obj, 50)
end

function M.spawnLouisArmor(obj)
	local data = obj and obj.data
	if not (data and frame.entered(data, 'louis_armor')) then
		return false
	end
	local parent = obj.parent
	local count = data._lf2_spawn_count or 0
	local items = {
		{ id = 217, x = -25, z = -15 },
		{ id = 217, x = 25, z = -15 },
		{ id = 217, x = -25, z = 15 },
		{ id = 217, x = 25, z = 15 },
		{ id = 218, x = 0, z = 0 },
	}
	for i = 1, #items do
		local item = items[i]
		local source = shared.objectdata and shared.objectdata:getById(item.id)
		if source then
			createObject(source, {
				lf2id = item.id,
				ownerid = data.syncid or data.gsid or data.player or data.index,
				team = data.team,
				facing = data.facing,
				x = (data.x or 0) + item.x * (data.facing or 1),
				y = data.y or 0,
				z = (data.z or 0) + item.z,
				frame = 0,
				syncid = table.concat { syncidBase(data), ':armor:', tostring(count + i) },
				parent = parent,
			})
		end
	end
	data._lf2_spawn_count = count + #items
	return true
end

function M.beginHeal(obj, data)
	if not (data and frame.entered(data, 'heal')) then
		return false
	end
	data._lf2_heal_pending = true
	data._lf2_heal_flash = core:convert(1100)
	return true
end

function M.processHeal(obj, data)
	if not data then
		return false
	end
	if data._lf2_heal_pending and not frame.hasState(data, 1700) then
		data._lf2_heal_pending = nil
		data._lf2_heal_timer = core:convert(100)
		data._lf2_heal_tick = core:convert(4)
	end
	if data._lf2_heal_flash then
		data._lf2_heal_flash = data._lf2_heal_flash > 1 and data._lf2_heal_flash - 1 or nil
	end
	if not data._lf2_heal_timer then
		return false
	end
	local attr = obj and obj.C and obj.C.attr
	local adata = attr and attr.data()
	if not adata then
		data._lf2_heal_timer = nil
		return false
	end
	data._lf2_heal_timer = data._lf2_heal_timer - 1
	data._lf2_heal_tick = (data._lf2_heal_tick or core:convert(8)) - 1
	if data._lf2_heal_tick <= 0 then
		adata.hp = math.min(adata.maxhp, (adata.hp or 0) + 8)
		data._lf2_heal_tick = core:convert(8)
	end
	if data._lf2_heal_timer <= 0 or adata.hp >= adata.maxhp then
		data._lf2_heal_timer = nil
		data._lf2_heal_tick = nil
	end
	return true
end

function M.message(obj, data)
	if not data then
		return false
	end
	data.shadow = false
	data.solid = false
	data._lf2_message = true
	return true
end

function createObject(source, options)
	options = options or { }
	local obj = Factory:create('object', source)
	local objdata = obj.data
	objdata._lf2 = true
	objdata._lf2_type = source._lf2_type
	objdata.lf2id = options.lf2id
	objdata.ownerid = options.ownerid
	objdata.team = options.team
	objdata.facing = options.facing or 1
	objdata.x = options.x or 0
	objdata.y = options.y or 0
	objdata.z = options.z or 0
	objdata._lf2_dvx = options.dvx or 0
	objdata._lf2_dvy = options.dvy or 0
	objdata._lf2_dvz = options.dvz or 0
	objdata.syncid = options.syncid

	if obj.C.frames then
		obj.C.frames.set(options.frame or 0)
		applyCurrentFrame(objdata)
		if source._lf2_type == 3 then
			M.prepareFrame(obj, objdata, { scale_motion = false })
			objdata.gravity = false
			objdata.solid = false
			if frame.hasState(objdata, 3004) or frame.hasState(objdata, 3005) then
				objdata.shadow = false
			end
		end
	end
	if not obj.C.sound then
		obj:addComponent(SoundSystem, source)
	end
	if options.parent then
		options.parent:attach(obj)
	end
	return M.registerDynamic(obj)
end

function M.spawnObject(owner, opoint)
	if not (owner and opoint) then
		return nil
	end
	local oid = number(opoint.oid, nil)
	local source = oid and shared.objectdata and shared.objectdata:getById(oid)
	if not source then
		return nil
	end

	local owner_data = owner.data or { }
	local facing = facingFromOpoint(owner_data.facing or 1, opoint.facing)
	local syncid = table.concat {
		syncidBase(owner_data),
		':opoint:',
		tostring(owner_data.frame and owner_data.frame.id or 0),
		':',
		tostring(oid),
		':',
		tostring(owner_data._lf2_spawn_count or 0),
	}
	owner_data._lf2_spawn_count = (owner_data._lf2_spawn_count or 0) + 1

	return createObject(source, {
		lf2id = oid,
		ownerid = owner_data.syncid or owner_data.gsid or owner_data.player or owner_data.index,
		team = owner_data.team,
		facing = facing,
		x = (owner_data.x or 0) + (number(opoint.x) - (owner_data.centerx or 0)) * facing,
		y = (owner_data.y or 0) + ((owner_data.centery or 0) - number(opoint.y)),
		z = owner_data.z or 0,
		dvx = number(opoint.dvx) * facing,
		dvy = -number(opoint.dvy),
		dvz = number(opoint.dvz),
		frame = number(opoint.action, 0),
		syncid = syncid,
		parent = owner.parent,
	})
end

function M.processOpoint(obj, data, frameEntered)
	frameEntered = frameEntered or frame.entered
	if data.opoint and frameEntered(data, 'opoint') then
		M.spawnObject(obj, data.opoint)
	end
end

local function projectileEndFrame(obj)
	local target_frame = frameExists(obj, 40)
	if frame.hasFrame(target_frame, 3004) then
		return 40
	end
	target_frame = frameExists(obj, 60)
	if frame.hasFrame(target_frame, 3004) then
		return 60
	end
	if frameExists(obj, 10) then
		return 10
	end
	if frameExists(obj, 20) then
		return 20
	end
	if frameExists(obj, 30) then
		return 30
	end
	return nil
end

local function projectileHitFrame(obj)
	if frameExists(obj, 10) then
		return 10
	end
	if frameExists(obj, 20) then
		return 20
	end
	if frameExists(obj, 30) then
		return 30
	end
	return projectileEndFrame(obj)
end

local function reachedXBorder(data, dx)
	local world = World.getFromContext()
	local borders = world and world.borders
	if not borders then
		return false
	end
	local x = data.x or 0
	return dx < 0 and borders.x1 and x <= borders.x1
		or dx > 0 and borders.x2 and x >= borders.x2
		or false
end

local function updateProjectileTimer(obj, data)
	local duration = hit_a_duration[number(data.hit_a, 0)]
	if not duration or number(data.hit_d, 0) == 0 then
		data._lf2_projectile_timer = nil
		return false
	end
	local frameid = data.frame and data.frame.id
	if data._lf2_projectile_timer_frame ~= frameid then
		data._lf2_projectile_timer_frame = frameid
		data._lf2_projectile_timer = core:convert(duration)
	end
	data._lf2_projectile_timer = data._lf2_projectile_timer - 1
	if data._lf2_projectile_timer > 0 then
		return false
	end
	data._lf2_projectile_timer = nil
	local frames = obj.C.frames
	if frames then
		frames.set(number(data.hit_d, 0))
		return true
	end
	return false
end

local function activateHitFa(obj, data)
	local hitfa = number(data.hit_Fa, 0)
	if hitfa ~= 13 or not frame.entered(data, 'hitfa') then
		return
	end
	local oid = data.lf2id
	local source = oid and shared.objectdata and shared.objectdata:getById(oid)
	if not source then
		return
	end
	local count = data._lf2_spawn_count or 0
	data._lf2_spawn_count = count + 1
	createObject(source, {
		lf2id = oid,
		ownerid = data.ownerid,
		team = data.team,
		facing = data.facing,
		x = data.x,
		y = data.y,
		z = data.z,
		dvx = data._lf2_dvx or data.dvx or 0,
		dvy = data._lf2_dvy or data.dvy or 0,
		dvz = data._lf2_dvz or data.dvz or 0,
		frame = frameExists(obj, 50) and 50 or 0,
		syncid = table.concat {
			syncidBase(data),
			':hitfa:',
			tostring(data.frame and data.frame.id or 0),
			':',
			tostring(count),
		},
		parent = obj.parent,
	})
end

function M.projectile(obj, data, options)
	options = options or { }
	data.gravity = false
	data.solid = false
	if options.shadow == false then
		data.shadow = false
	end
	activateHitFa(obj, data)
	if updateProjectileTimer(obj, data) then
		return
	end
	if options.flying then
		local dx = projectileMotionValue(data, 'dvx', data._lf2_dvx or 0, true)
		local dy = projectileMotionValue(data, 'dvy', data._lf2_dvy or 0)
		local dz = projectileMotionValue(data, 'dvz', data._lf2_dvz or 0)
		if dz == 0 and number(data.hit_j, 0) ~= 0 then
			dz = number(data.hit_j) - 50
		end
		if reachedXBorder(data, dx) then
			local frames = obj.C.frames
			local target = projectileEndFrame(obj)
			if frames and target then
				frames.set(target)
			else
				M.despawn(obj)
			end
			return
		end
		data.dvx = dx
		data.dvy = dy
		data.dvz = dz
	end
end

function M.projectileHit(obj)
	local data = obj and obj.data
	local frames = obj and obj.C.frames
	if not (data and frames and data._lf2_type == 3) then
		return
	end
	if frame.hasState(data, 3006) then
		return
	end
	if frame.hasState(data, 3000) then
		frames.set(projectileHitFrame(obj) or 10)
	end
end

function M.pickupWeapon(obj)
	local data = obj and obj.data
	if not data then
		return false
	end
	local list = shared.lf2_objects
	if not list then
		return false
	end
	for i = 1, #list do
		local item = list[i]
		local idata = item and item.data
		if idata and (idata._lf2_type == 1 or idata._lf2_type == 6) and not idata.hidden then
			local dx = abs((idata.x or 0) - (data.x or 0))
			local dz = abs((idata.z or 0) - (data.z or 0))
			if dx <= 80 and dz <= 40 then
				idata.hidden = true
				item.active = false
				data._lf2_weapon = 'light'
				data._lf2_weapon_id = idata.lf2id
				data._lf2_weapon_type = idata._lf2_type
				return true
			end
		end
	end
	return false
end

function M.weapon(obj, data, options)
	options = options or { }
	if options.on_ground then
		data.dvx, data.dvy, data.dvz = 0, 0, 0
	elseif data.ground and obj.C.frames then
		obj.C.frames.set(options.ground_frame or 60)
	end
end

return M
