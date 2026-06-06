require 'spec_helper'

package.path = table.concat({
	'./presets/lf2/?.lua',
	'./presets/lf2/?/init.lua',
	package.path,
}, ';')

_G.data = _G.data or { }

local Storage = l2df.import 'class.storage'
local Factory = l2df.import 'manager.factory'
local Entity = l2df.import 'class.entity'
local Object = l2df.import 'class.entity.object'
local Frames = l2df.import 'class.component.frames'
local lf2 = require 'data.scripts.lf2'

Factory:add(Object)

describe('presets.lf2.data.scripts.lf2', function()
	it('normalizes LF2 frame boxes and metadata once', function()
		local obj = { data = { } }
		local frame = {
			frame = { id = 7 },
			next = 999,
			pic = 0,
			centerx = 10,
			centery = 20,
			bodies = { { x = 12, y = 22, w = 5, h = 6 } },
			itrs = { { x = 15, y = 25, w = 7, h = 8, dvx = 4, dvy = -6, zwidth = 10 } },
		}

		lf2.prepareFrame(obj, frame)
		lf2.prepareFrame(obj, frame)

		assert.is_true(frame._lf2)
		assert.are.equal(0, frame.next)
		assert.are.equal(1, frame.pic)
		assert.are.equal(2, frame.bodies[1].x)
		assert.are.equal(2, frame.bodies[1].y)
		assert.are.equal(-10, frame.itrs[1].z)
		assert.are.equal(20, frame.itrs[1].d)
		assert.are.equal(4, frame.itrs[1].dvx)
		assert.are.equal(-6, frame.itrs[1].dvy)
	end)

	it('keeps LF2 pic and facing motion converted on repeated frame ticks', function()
		local data = {
			___frame_generation = 1,
			frame = { id = 9, pic = 8, dvx = 0, dvy = 0, dvz = 0 },
			facing = -1,
			pic = 8,
			dvx = 12,
			dvy = 0,
			dvz = 0,
		}
		local obj = { data = data }

		lf2.prepareFrame(obj, data)
		assert.are.equal(9, data.pic)
		assert.are.equal(-12, data.dvx)

		data.pic = 8
		data.dvx = 12
		lf2.prepareFrame(obj, data)

		assert.are.equal(9, data.pic)
		assert.are.equal(-12, data.dvx)
	end)

	it('converts vertical state impulse to engine orientation and scale', function()
		local oldFactor = l2df.factor
		local ok, err = pcall(function()
			l2df.factor = 2
			local frame = {
				frame = { id = 7, dvx = 8, dvy = 9, dvz = 4 },
				dvx = 8,
				dvy = 9,
				dvz = 4,
			}

			lf2.prepareFrame({ data = { } }, frame)

			assert.are.equal(4, frame.dvx)
			assert.are.equal(-4.5, frame.dvy)
			assert.are.equal(2, frame.dvz)
		end)
		l2df.factor = oldFactor
		assert.is_true(ok, err)
	end)

	it('preserves runtime jump impulse while applying horizontal compatibility motion', function()
		local oldFactor = l2df.factor
		local ok, err = pcall(function()
			l2df.factor = 2
			local frame = {
				frame = { id = 211, dvx = 0, dvy = 0, dvz = 0 },
				facing = -1,
				dvx = 8,
				dvy = 9,
				dvz = 4,
			}

			lf2.prepareFrame({ data = { } }, frame)

			assert.are.equal(-4, frame.dvx)
			assert.are.equal(9, frame.dvy)
			assert.are.equal(2, frame.dvz)
		end)
		l2df.factor = oldFactor
		assert.is_true(ok, err)
	end)

	it('moves walking characters left after LF2 compatibility motion conversion', function()
		local walkingState = dofile('presets/lf2/data/states/1.lua')
		local data = {
			facing = 1,
			frame = { id = 5, dvx = 0, dvy = 0, dvz = 0 },
			dvx = 0,
			dvy = 0,
			dvz = 0,
		}
		local obj = {
			data = data,
			C = {
				controller = {
					pressed = function (key) return key == 'left' end,
					hitted = function () return false end,
				},
				frames = {
					set = function (frame) data.target = frame end,
				},
				attr = {
					data = function ()
						return {
							defence = 1,
							walking_speed = 4,
							walking_speedz = 2,
							walking_frame_rate = 3,
						}
					end,
				},
			},
		}

		walkingState(obj, data)
		lf2.prepareFrame(obj, data)

		assert.are.equal(-1, data.facing)
		assert.are.equal(-4, data.dvx)
	end)

	it('stops horizontal walking motion when only vertical input remains', function()
		local walkingState = dofile('presets/lf2/data/states/1.lua')
		local target
		local data = {
			facing = -1,
			frame = { id = 5, dvx = 0, dvy = 0, dvz = 0 },
			dvx = 0,
			dvy = 0,
			dvz = 0,
			vx = -4,
			_lf2_walk_release_slide = 3,
			_lf2_walk_release_subframe = 1,
		}
		local obj = {
			data = data,
			C = {
				controller = {
					pressed = function (key) return key == 'up' end,
					hitted = function () return false end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
				attr = {
					data = function ()
						return {
							defence = 1,
							walking_speed = 4,
							walking_speedz = 2,
							walking_frame_rate = 3,
						}
					end,
				},
			},
		}

		walkingState(obj, data)
		lf2.prepareFrame(obj, data)

		assert.are.equal(0, data.dvx)
		assert.are.equal(0, data.vx)
		assert.are.equal(-2, data.dvz)
		assert.is_nil(data._lf2_walk_release_slide)
		assert.is_nil(target)
	end)

	it('despawns LF2 next 1000 frames from the compatibility state', function()
		local compatibilityState = dofile('presets/lf2/data/states/compatibility.lua')
		local obj = Entity:new()
		obj:addComponent(Frames:new(), {
			frame = 1,
			frames = {
				{ id = 1, wait = 0, next = 1000, pic = 0, bodies = { { x = 1 } }, itrs = { { x = 1 } } },
			},
		})

		obj.C.frames:preupdate()
		compatibilityState(obj, obj.data)

		assert.is_not_true(obj.data.hidden)
		assert.are.equal(1, obj.data.next)

		obj.C.frames:preupdate()
		compatibilityState(obj, obj.data)

		assert.is_true(obj.data.hidden)
		assert.is_false(obj.active)
		assert.are.equal(0, #obj.data.bodies)
		assert.are.equal(0, #obj.data.itrs)
	end)

	it('allows one-shot LF2 frame effects after the same frame id is re-entered', function()
		local frame = {
			frame = { id = 103 },
			___frame_generation = 1,
		}

		assert.is_true(lf2.frameEntered(frame, 'opoint'))
		assert.is_false(lf2.frameEntered(frame, 'opoint'))

		frame.___frame_generation = 2

		assert.is_true(lf2.frameEntered(frame, 'opoint'))
	end)

	it('treats owner identity as friendly even for independent teams', function()
		assert.is_true(lf2.isFriendly(
			{ data = { ownerid = 'player:1', team = 0 } },
			{ data = { syncid = 'player:1', team = 0 } }
		))
		assert.is_false(lf2.isFriendly(
			{ data = { ownerid = 'player:1', team = 0 } },
			{ data = { syncid = 'player:2', team = 0 } }
		))
	end)

	it('prevents owner damage from spawned LF2 projectiles', function()
		local normalHit = dofile('presets/lf2/data/kinds/0.lua')
		local damaged = false
		local projectile = {
			data = {
				ownerid = 'player:1',
				team = 0,
				facing = 1,
			},
		}
		local owner = {
			data = {
				syncid = 'player:1',
				team = 0,
				facing = 1,
				frame = { id = 0 },
			},
			C = {
				frames = {
					set = function () end,
				},
				attr = {
					damage = function ()
						damaged = true
						return true
					end,
					data = function () return { pain = 60 } end,
				},
				sound = {
					play = function () end,
				},
			},
		}

		normalHit(projectile, owner, { owner = projectile }, { owner = owner })

		assert.is_false(damaged)
	end)

	it('uses the LF2 queued hit path outside F.LF tests', function()
		local previous = data.test
		data.test = nil
		local normalHit = dofile('presets/lf2/data/kinds/0.lua')
		local target_frame
		local attacker = {
			data = {
				facing = 1,
				team = 1,
				frame = { id = 60 },
			},
		}
		local victim = {
			data = {
				facing = -1,
				team = 2,
				frame = { id = 0 },
			},
			C = {
				frames = {
					set = function (frame) target_frame = frame end,
				},
				attr = {
					isdamaged = function () return false end,
					damage = function () return true end,
					data = function () return { pain = -1 } end,
				},
				sound = {
					play = function () end,
				},
			},
		}

		normalHit(attacker, victim, { dvx = 12, owner = attacker }, { owner = victim })

		data.test = previous
		assert.is_nil(target_frame)
		assert.is_nil(victim.data.dvx)
		assert.are.equal(1, #victim.data._lf2_pending_hits)
	end)

	it('keeps double-tap running responsive with LF2 compatibility', function()
		local previous = data.test
		data.test = nil
		local standingState = dofile('presets/lf2/data/states/0.lua')
		local target
		local frame_data = {
			ground = true,
			facing = 1,
			frame = { id = 0 },
		}
		local obj = {
			C = {
				controller = {
					pressed = function (key) return key == 'right' end,
					hitted = function () return false end,
					doubled = function (key) return key == 'right' end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
				attr = {
					data = function () return { defence = 1 } end,
				},
			},
		}

		standingState(obj, frame_data)

		data.test = previous
		assert.are.equal('running', target)
		assert.are.equal(1, frame_data.facing)
	end)

	it('enters running from walking on a second direction tap', function()
		local previous = data.test
		data.test = nil
		local walkingState = dofile('presets/lf2/data/states/1.lua')
		local target
		local frame_data = {
			facing = 1,
			frame = { id = 5 },
			dvx = 0,
			dvz = 0,
		}
		local obj = {
			C = {
				controller = {
					pressed = function (key) return key == 'right' end,
					hitted = function () return false end,
					doubled = function (key) return key == 'right' end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
				attr = {
					data = function ()
						return {
							defence = 1,
							walking_speed = 5,
							walking_speedz = 2,
						}
					end,
				},
			},
		}

		walkingState(obj, frame_data)

		data.test = previous
		assert.are.equal('running', target)
		assert.are.equal(1, frame_data.facing)
	end)

	it('uses the LF2 double-tap window for running input', function()
		local lf2 = dofile('presets/lf2/data/scripts/lf2.lua')
		local target_key = nil
		local target_window = nil
		local obj = {
			C = {
				controller = {
					doubled = function (key, window)
						target_key = key
						target_window = window
						return true
					end,
				},
			},
			data = { },
		}

		assert.is_true(lf2.doubled(obj, 'right'))
		assert.are.equal('right', target_key)
		assert.are.equal(l2df:convert(9), target_window)
	end)

	it('lands normal dash attacks with LF2 compatibility', function()
		local previous = data.test
		data.test = nil
		local miscState = dofile('presets/lf2/data/states/15.lua')
		local target
		local frame_data = {
			ground = true,
			isdashed = true,
			frame = {
				id = 91,
				keyword = 'dash_attack',
			},
		}
		local obj = {
			C = {
				controller = {
					pressed = function () return false end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
				attr = {
					data = function () return { } end,
				},
			},
		}

		miscState(obj, frame_data)

		data.test = previous
		assert.are.equal('crouch', target)
		assert.is_nil(frame_data._lf2_dash_attack_step)
	end)

	it('applies opoint velocity to flying projectiles without gravity', function()
		local obj = { data = { } }
		local frame = {
			frame = { id = 0, states = { { 3000 } } },
			pic = 0,
			next = 999,
			dvx = 0,
			dvy = 0,
			dvz = 0,
			_lf2_dvx = 15,
			_lf2_dvy = -3,
			_lf2_dvz = 2,
		}

		lf2.prepareFrame(obj, frame, { scale_motion = false })
		lf2.projectile(obj, frame, { flying = true })

		assert.is_false(frame.gravity)
		assert.is_false(frame.solid)
		assert.are.equal(15, frame.dvx)
		assert.are.equal(-3, frame.dvy)
		assert.are.equal(2, frame.dvz)
	end)

	it('mirrors LF2 flying projectile frame velocity when facing left', function()
		local obj = { data = { } }
		local frame = {
			frame = { id = 0, states = { { 3000 } }, dvx = 18, dvy = 0, dvz = 0 },
			facing = -1,
			dvx = 18,
			dvy = 0,
			dvz = 0,
			_lf2_dvx = -15,
		}

		lf2.prepareFrame(obj, frame, { scale_motion = false })
		lf2.projectile(obj, frame, { flying = true })

		assert.are.equal(-18, frame.dvx)
	end)

	it('keeps signed opoint velocity for left-facing projectiles with stationary frames', function()
		local obj = { data = { } }
		local frame = {
			frame = { id = 0, states = { { 3000 } }, dvx = 0, dvy = 0, dvz = 0 },
			facing = -1,
			dvx = 0,
			dvy = 0,
			dvz = 0,
			_lf2_dvx = -15,
		}

		lf2.prepareFrame(obj, frame, { scale_motion = false })
		lf2.projectile(obj, frame, { flying = true })

		assert.are.equal(-15, frame.dvx)
	end)

	it('maps LF2 defend input combinations to special frames', function()
		local target
		local pressed = {
			defend = true,
			right = true,
		}
		local obj = {
			C = {
				controller = {
					pressed = function (key) return pressed[key] and true or false end,
					hitted = function (key) return key == 'attack' end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
			},
		}
		local frame = {
			facing = 1,
			hit_Fa = 260,
		}

		assert.is_true(lf2.handleSpecialInput(obj, frame))
		assert.are.equal(260, target)
	end)

	it('prefers vertical LF2 defend specials over held movement', function()
		local target
		local pressed = {
			defend = true,
			right = true,
			up = true,
		}
		local hitted = {
			attack = true,
		}
		local obj = {
			C = {
				controller = {
					pressed = function (key) return pressed[key] and true or false end,
					hitted = function (key) return hitted[key] and true or false end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
			},
		}
		local frame = {
			facing = 1,
			hit_Fa = 260,
			hit_Ua = 235,
			hit_Fj = 280,
			hit_Uj = 310,
		}

		assert.is_true(lf2.handleSpecialInput(obj, frame))
		assert.are.equal(235, target)

		target = nil
		hitted.attack = nil
		hitted.jump = true

		assert.is_true(lf2.handleSpecialInput(obj, frame))
		assert.are.equal(310, target)
	end)

	it('spawns LF2 opoint objects by original object id', function()
		local source = {
			_lf2_type = 3,
			frame = 100,
			frames = {
				{ id = 100, pic = 7, wait = 0, next = 100, centerx = 40, centery = 82, states = { { 3005 } } },
			},
		}
		local attached
		data.objectdata = Storage()
		data.objectdata:addById(source, 228, true)
		data.lf2_objects = { }

		local parent = {
			attach = function (self, obj) obj.parent = self end,
		}
		local owner = {
			data = {
				syncid = 'owner',
				frame = { id = 260 },
				team = 2,
				facing = 1,
				x = 100,
				y = 20,
				z = 5,
				centerx = 39,
				centery = 99,
			},
			parent = {
				attach = function (_, obj) attached = obj end,
			},
		}

		local obj = lf2.spawnObject(owner, {
			oid = 228,
			action = 100,
			x = 65,
			y = 70,
			dvx = 15,
			dvy = 3,
			dvz = 1,
		})

		assert.is_truthy(obj)
		assert.are.equal(obj, attached)
		assert.are.equal(obj, data.lf2_objects[1])
		assert.are.equal(3, obj.data._lf2_type)
		assert.are.equal(228, obj.data.lf2id)
		assert.are.equal(2, obj.data.team)
		assert.are.equal(126, obj.data.x)
		assert.are.equal(49, obj.data.y)
		assert.are.equal(5, obj.data.z)
		assert.are.equal(15, obj.data._lf2_dvx)
		assert.are.equal(-3, obj.data._lf2_dvy)
		assert.are.equal(1, obj.data._lf2_dvz)
		assert.are.equal(100, obj.data.frame.id)
		assert.are.equal(8, obj.data.pic)
		assert.are.equal(40, obj.data.centerx)
		assert.are.equal(82, obj.data.centery)
	end)

	it('mirrors LF2 opoint spawn position and velocity when owner faces left', function()
		local source = {
			_lf2_type = 3,
			frame = 100,
			frames = {
				{ id = 100, pic = 7, wait = 0, next = 100, centerx = 40, centery = 82, states = { { 3005 } } },
			},
		}
		data.objectdata = Storage()
		data.objectdata:addById(source, 228, true)
		data.lf2_objects = { }

		local owner = {
			data = {
				syncid = 'owner',
				frame = { id = 260 },
				team = 2,
				facing = -1,
				x = 100,
				y = 20,
				z = 5,
				centerx = 39,
				centery = 99,
			},
			parent = {
				attach = function (self, obj) obj.parent = self end,
			},
		}

		local obj = lf2.spawnObject(owner, {
			oid = 228,
			action = 100,
			x = 65,
			y = 70,
			dvx = 15,
		})

		assert.is_truthy(obj)
		assert.are.equal(-1, obj.data.facing)
		assert.are.equal(74, obj.data.x)
		assert.are.equal(-15, obj.data._lf2_dvx)
	end)

	it('spawns LF2 opoints again when the same frame id is entered later', function()
		local source = {
			_lf2_type = 3,
			frame = 0,
			frames = {
				{ id = 0, pic = 0, wait = 0, next = 0, centerx = 40, centery = 82, states = { { 3005 } } },
			},
		}
		data.objectdata = Storage()
		data.objectdata:addById(source, 229, true)
		data.lf2_objects = { }

		local owner = {
			data = {
				syncid = 'owner',
				frame = { id = 288 },
				___frame_generation = 1,
				team = 2,
				facing = 1,
				x = 100,
				y = 20,
				z = 5,
				centerx = 43,
				centery = 99,
				opoint = {
					oid = 229,
					action = 0,
					x = 90,
					y = 50,
					dvx = 15,
					dvy = 0,
					dvz = 0,
				},
			},
			parent = {
				attach = function (self, obj) obj.parent = self end,
			},
		}

		lf2.processOpoint(owner, owner.data)
		lf2.processOpoint(owner, owner.data)
		assert.are.equal(1, #data.lf2_objects)

		owner.data.___frame_generation = 2
		lf2.processOpoint(owner, owner.data)

		assert.are.equal(2, #data.lf2_objects)
		assert.is_false(data.lf2_objects[1].data.syncid == data.lf2_objects[2].data.syncid)
	end)

	it('activates Julian skull-blast hit_Fa objects into flying projectiles', function()
		local source = {
			_lf2_type = 3,
			frame = 100,
			frames = {
				{ id = 50, pic = 8, wait = 1, next = 50, centerx = 40, centery = 41, states = { { 3000 } } },
				{ id = 100, pic = 7, wait = 1, next = 101, centerx = 40, centery = 82, states = { { 3005 } } },
				{ id = 101, pic = 7, wait = 1, next = 102, centerx = 0, centery = 0, hit_Fa = 13, states = { { 3005 } } },
			},
		}
		data.objectdata = Storage()
		data.objectdata:addById(source, 228, true)
		data.lf2_objects = { }
		local parent = {
			attach = function (self, obj) obj.parent = self end,
		}

		local owner = {
			data = {
				syncid = 'owner',
				frame = { id = 260 },
				team = 2,
				facing = 1,
				x = 100,
				y = 20,
				z = 5,
				centerx = 39,
				centery = 99,
			},
			parent = parent,
		}

		local activator = lf2.spawnObject(owner, {
			oid = 228,
			action = 100,
			x = 65,
			y = 70,
			dvx = 15,
		})
		activator.C.frames.set(101)
		activator.C.frames.preupdate()
		lf2.prepareFrame(activator, activator.data, { scale_motion = false })

		lf2.projectile(activator, activator.data, { shadow = false })

		local projectile = data.lf2_objects[2]
		assert.is_truthy(projectile)
		assert.are.equal(50, projectile.data.frame.id)
		assert.are.equal(126, projectile.data.x)
		assert.are.equal(49, projectile.data.y)
		assert.are.equal(15, projectile.data._lf2_dvx)
		assert.are.equal(40, activator.data.centerx)
		assert.are.equal(82, activator.data.centery)
	end)

	it('delays jump impulse until LF2 frame 212 has been visible for one tick', function()
		local jumpState = dofile('presets/lf2/data/states/4.lua')
		local frame_data = {
			ground = true,
			frame = { id = 211, dvx = 0, dvy = 0, dvz = 0 },
			wait = 1,
		}
		local obj = {
			C = {
				controller = {
					pressed = function () return false end,
				},
				frames = {
					set = function (_, frame) frame_data.target = frame end,
				},
				attr = {
					data = function () return { jump_height = 9 } end,
				},
			},
		}

		jumpState(obj, frame_data)
		assert.is_nil(frame_data.dvy)
		assert.is_true(frame_data._lf2_jump_armed)

		frame_data.frame = { id = 212, dvx = 0, dvy = 0, dvz = 0 }
		frame_data.___frame_generation = 2
		jumpState(obj, frame_data)
		assert.is_nil(frame_data.dvy)

		jumpState(obj, frame_data)

		assert.are.equal(9, frame_data.dvy)
		assert.is_true(frame_data.isjumped)
	end)

	it('preserves converted jump impulse through LF2 compatibility preparation', function()
		local jumpState = dofile('presets/lf2/data/states/4.lua')
		local data = {
			ground = true,
			frame = { id = 211, dvx = 0, dvy = 0, dvz = 0 },
			wait = 1,
		}
		local obj = {
			data = data,
			C = {
				controller = {
					pressed = function () return false end,
				},
				frames = {
					set = function (_, frame) data.target = frame end,
				},
				attr = {
					data = function () return { jump_height = 9 } end,
				},
			},
		}

		jumpState(obj, data)
		data.frame = { id = 212, dvx = 0, dvy = 0, dvz = 0 }
		data.___frame_generation = 2
		jumpState(obj, data)
		jumpState(obj, data)
		lf2.prepareFrame(obj, data)

		assert.are.equal(9, data.dvy)
		assert.is_true(data.isjumped)
	end)

	it('uses canonical LF2 frame ids for running dash and rolling transitions', function()
		local runState = dofile('presets/lf2/data/states/2.lua')
		local target
		local pressed = { }
		local hitted = { defend = true }
		local obj = {
			C = {
				controller = {
					pressed = function (key) return pressed[key] and true or false end,
					hitted = function (key) return hitted[key] and true or false end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
				attr = {
					data = function ()
						return {
							defence = 1,
							running_speed = 12,
							running_speedz = 1.5,
							dash_distance = 19,
							dash_distancez = 5,
							running_frame_rate = 3,
						}
					end,
				},
			},
		}
		local frame_data = {
			facing = 1,
			frame = { id = 9 },
			dvx = 0,
			dvz = 0,
		}

		runState(obj, frame_data)
		assert.are.equal(102, target)

		target = nil
		hitted.defend = nil
		hitted.jump = true
		runState(obj, frame_data)
		assert.are.equal(213, target)
		assert.are.equal(19, frame_data.jspeedx)
	end)

	it('mirrors running velocity through LF2 compatibility conversion', function()
		local runState = dofile('presets/lf2/data/states/2.lua')
		local data = {
			___frame_generation = 1,
			facing = -1,
			frame = { id = 9, pic = 8, dvx = 0, dvy = 0, dvz = 0 },
			dvx = 0,
			dvz = 0,
		}
		local obj = {
			data = data,
			C = {
				controller = {
					pressed = function () return false end,
					hitted = function () return false end,
				},
				frames = {
					set = function () end,
				},
				attr = {
					data = function ()
						return {
							running_speed = 12,
							running_speedz = 1.5,
							running_frame_rate = 3,
						}
					end,
				},
			},
		}

		runState(obj, data)
		lf2.prepareFrame(obj, data)

		assert.are.equal(-12, data.dvx)
	end)

	it('applies dash impulse for converted Julian dash-start frames', function()
		local jumpState = dofile('presets/lf2/data/states/5.lua')
		local target
		local frame_data = {
			ground = true,
			frame = { id = 213 },
			jspeedx = 19,
			jspeedz = 5,
		}
		local obj = {
			C = {
				controller = {
					pressed = function () return false end,
					hitted = function () return false end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
				attr = {
					data = function ()
						return {
							dash_height = 11,
							jump_height = 9,
						}
					end,
				},
			},
		}

		jumpState(obj, frame_data)

		assert.are.equal(11, frame_data.dvy)
		assert.are.equal(19, frame_data.dvx)
		assert.are.equal(5, frame_data.dvz)
		assert.is_true(frame_data.isdashed)
		assert.is_nil(target)
	end)

	it('allows jump attacks from converted airborne jump frames', function()
		local jumpState = dofile('presets/lf2/data/states/4.lua')
		local target
		local data = {
			ground = false,
			frame = { id = 212 },
			isjumped = true,
		}
		local obj = {
			C = {
				controller = {
					pressed = function (key) return key == 'attack' end,
					hitted = function () return false end,
				},
				frames = {
					set = function (frame) target = frame end,
				},
				attr = {
					data = function () return { jump_height = 9 } end,
				},
			},
		}

		jumpState(obj, data)

		assert.are.equal('jump_attack', target)
	end)

	it('lands converted Davis dash attack frames that use attack state', function()
		local attackState = dofile('presets/lf2/data/states/3.lua')
		local target
		local frame_data = {
			ground = true,
			isdashed = true,
			frame = {
				id = 96,
				keyword = 'dash_attack',
			},
		}
		local obj = {
			C = {
				frames = {
					set = function (frame) target = frame end,
				},
			},
		}

		attackState(obj, frame_data)

		assert.are.equal('crouch', target)
	end)

	it('removes dynamic LF2 objects missing from a rollback snapshot', function()
		local keep = { parent = { } }
		local drop = {
			parent = { },
			destroy = function (self)
				self.destroyed = true
				self.parent = nil
			end,
		}
		data.lf2_objects = { keep, drop }

		lf2.syncDynamic({ }, { keep })

		assert.are.equal(1, #data.lf2_objects)
		assert.are.equal(keep, data.lf2_objects[1])
		assert.is_true(drop.destroyed)
	end)
end)
