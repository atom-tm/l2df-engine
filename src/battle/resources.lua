local core = l2df
assert(type(core) == "table" and core.version >= 1.0, "Battle.Resources works only with love2d-fighting v1.0 and higher")

local image = core.image

local resources = { }

	function resources:Load()
		self.light_filter = image.Load("sprites/UI/light_filter.png", nil, "linear")

		self.hp_bar = image.Load("sprites/UI/hp_bar.png", nil, "linear")
		self.hp_bar_background = image.Load("sprites/UI/Bars/bg.png", nil, "linear")

		self.bars = image.Load("sprites/UI/Bars/bars.png", nil, "linear")
		self.bars.hp = { x = 0, y = 0, w = 330, h = 28 }
		self.bars.mp = { x = 0, y = 29, w = 296, h = 17 }
		self.bars.sp = { x = 0, y = 47, w = 255, h = 12 }
		self.bars:setQuad("hp_back", 0, 60, 330, 28)
		self.bars:setQuad("mp_back", 0, 89, 296, 17)
		self.bars:setQuad("sp_back", 0, 107, 255, 12)

		self.control_visuals = {
			up = {
				pressed = image.Load("sprites/UI/Keys/up.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/up0.png", nil, "linear"),
				x = 32, y = 0
			},
			down = {
				pressed = image.Load("sprites/UI/Keys/down.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/down0.png", nil, "linear"),
				x = 32, y = 34
			},
			left = {
				pressed = image.Load("sprites/UI/Keys/left.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/left0.png", nil, "linear"),
				x = 9, y = 17
			},
			right = {
				pressed = image.Load("sprites/UI/Keys/right.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/right0.png", nil, "linear"),
				x = 56, y = 17
			},
			attack = {
				pressed = image.Load("sprites/UI/Keys/attack.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/attack0.png", nil, "linear"),
				x = 96, y = 16
			},
			jump = {
				pressed = image.Load("sprites/UI/Keys/jump.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/jump0.png", nil, "linear"),
				x = 128, y = 16
			},
			defend = {
				pressed = image.Load("sprites/UI/Keys/defence.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/defence0.png", nil, "linear"),
				x = 160, y = 16
			},
			special1 = {
				pressed = image.Load("sprites/UI/Keys/special.png", nil, "linear"),
				normal = image.Load("sprites/UI/Keys/special0.png", nil, "linear"),
				x = 192, y = 16
			},
		}
	end

return resources