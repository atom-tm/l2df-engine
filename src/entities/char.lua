local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local helper = core.import "helper"
local Media = core.import "media"
local Actor = core.import "entities.actor"
local PhysixComponent = core.import "components.physix"
local FramesComponent = core.import "components.frames"

local function getBasicChar()
	return {
		head = {
			name = "Unknown",
			type = "character",
			hp = 1000,
			mp = 500,
			sp = 10,
			hp_regeneration = 1,
			mp_regeneration = 1,
			sp_regeneration = 1,
			fall = 70,
			bdefend = 60,
			fall_timer = 100,
			bdefend_timer = 160,
			next_zero = true,
			sprites = { },
		},
		destroy = false,
		first_tick = true,
		invisibility = 0,
		r = 1,
		g = 1,
		b = 1,
		o = 1,
		index = nil,
		target = nil,
		special_grounded = 0,
		shaking = 0,
		tick_skip = false,
		slow_time = 0,
		slow_forse = 0,

		walking_frame = 1,
		running_frame = 1,
		hit_code = "",
		hit_timer = 0,
		reflection = false,
		fall_timer = 0,
		bdefend_timer = 0,
		lying = false,
		block_timer = 0,
		arest = 0,
		vrest = 0,
		hp_width = 0,
		mp_width = 0,
		sp_width = 0,
		block = 0,
		attackers = { },
		attacked = { },
		combo = 0,
		combo_timer = 0,
		real_id = id,
		dynamic_id = nil,
		key_timer = { up = 0, down = 0, left = 0, right = 0, attack = 0, jump = 0, defend = 0, special1 = 0 },
		double_key_timer = { up = 0, down = 0, left = 0, right = 0, attack = 0, jump = 0, defend = 0, special1 = 0 },
		key_pressed = { up = 0, down = 0, left = 0, right = 0, attack = 0, jump = 0, defend = 0, special1 = 0 },
		ai_vars = { goal = 0, stage = 0, defend_timer = 0 },
		ai = false,
		controller = 0,
		team = -1,
		owner = 0,
	}
end


local Char = Actor:extend(getBasicChar())

	function Char:init(options)
		self:addComponent(PhysixComponent)
		self:addComponent(FramesComponent)
		helper.copyTable(options, self)

		self.pics = { }
		for i = 1, #self.head.sprites do
			local sprite = self.head.sprites[i]
			local info = {
				w = sprite.w,
				h = sprite.h,
				x = sprite.row,
				y = sprite.col,
				x_offset = sprite.x_offset,
				y_offset = sprite.y_offset
			}
			local img = Media.Image(sprite.file, info)
			local size = #self.pics
			for j = 1, img.info.frames do
				self.pics[size + j] = { img, j }
			end
		end

		self:setFrame(self.head.default_idle)

		-- created_object.hp = created_object.head.hp
		-- created_object.mp = created_object.head.mp
		-- created_object.sp = created_object.head.sp
		-- created_object.fall = created_object.head.fall
		-- created_object.shadow = created_object.head.shadow
		-- created_object.bdefend = created_object.head.bdefend

		-- created_object.aiProcessing = battle.ai.processing

		-- created_object.countersProcessing = entities.object_counters
		-- created_object.setController = battle.control.setController
		-- created_object.removeController = battle.control.removeController
		-- created_object.keysCheck = battle.control.keysCheck
		-- created_object.hit = battle.control.hit
		-- created_object.pressed = battle.control.pressed
		-- created_object.timer = battle.control.timer
		-- created_object.double_timer = battle.control.double_timer
		-- created_object.hpBarsCalculation = battle.hpBarsCalculation

		-- created_object.findColliders = battle.collision.findColliders
		-- created_object.getDTVal = battle.collision.getDTVal

		-- created_object.drawPreparation = battle.graphic.drawPreparationObject


		-- created_object.setFrame = entities.setFrame
		-- created_object.timeSlow = entities.timeSlow
		-- created_object.checkShaking = entities.checkShaking
		-- created_object.statesProcessing = entities.statesProcessing
		-- created_object.statesUpdate = entities.statesUpdate
		-- created_object.opointsProcessing = entities.opointsProcessing
		-- created_object.frameProcessing = entities.frameProcessing
	end

	function Char:update(dt)
		if self.frame then
			self:setFrame(self.next_frame)
		end
	end

	function Char:draw()
		if not self.frame then return end
		local pic = self.pics[self.frame.pic]
		pic[1]:draw(self.x, self.y, pic[2])
	end

return Char