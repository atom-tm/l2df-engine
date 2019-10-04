local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'core.class'
local helper = core.import 'helper'

local Transform = Class:extend()

	function Transform:init()
		self.matrix = {
			{ 1, 0, 0, 0 },
			{ 0, 1, 0, 0 },
			{ 0, 0, 1, 0 },
			{ 0, 0, 0, 1 },
		}
	end

	function Transform:append(transform)
	if not transform:isInstanceOf(Transform) then return end
		self.matrix = helper.mulMatrix(transform.matrix, self.matrix)
	end

	function Transform:scale( sx, sy, sz )
		sy = sy or sx or 1
		sz = sz or sx or 1
		sx = sx or 1
		local m = {
			{ sx, 0, 0, 0 },
			{ 0, sy, 0, 0 },
			{ 0, 0, sz, 0 },
			{ 0, 0, 0, 1  },
		}
		self.matrix = helper.mulMatrix(m, self.matrix)
	end

	function Transform:translate(dx, dy, dz)
		dx = dx or 0
		dy = dy or 0
		dz = dz or 0
		local m = {
			{ 1, 0, 0, dx },
			{ 0, 1, 0, dy },
			{ 0, 0, 1, dz },
			{ 0, 0, 0, 1 },
		}
		self.matrix = helper.mulMatrix(m, self.matrix)
	end

	function Transform:print()
		local m = ''
		local r = ''
		for i = 1, 4 do
			local r = ''
			for j = 1, 4 do
				r = r .. self.matrix[i][j] .. ' '
			end
			m = m .. r .. '\n'
		end
		print(m)
	end

return Transform