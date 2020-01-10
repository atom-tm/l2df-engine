--- Transform class
-- @classmod l2df.class.transform
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'class'
local helper = core.import 'helper'

local sin = math.sin
local cos = math.cos
local rad = math.rad
local acos = math.acos

local Transform = Class:extend()

	function Transform:init(...)
		self.matrix = {
			{ 1, 0, 0, 0 },
			{ 0, 1, 0, 0 },
			{ 0, 0, 1, 0 },
			{ 0, 0, 0, 1 },
		}
		self.sx = 1
		self.sy = 1
		self.sz = 1
		self.r = 0
		self:set(...)
	end

	function Transform:set(x, y, z, sx, sy, sz, r, ox, oy)
		x = x or 0
		y = y or 0
		z = z or 0
		sx = sx or 1
		sy = sy or 1
		sz = sz or 1
		ox = ox or 0
		oy = oy or 0
		r = r or 0
		local ca = cos(rad(r))
		local sa = sin(rad(r))
		local m = {
			{ ca*sx, -sa*sy,  0, x + ca*(-ox*sx) - sa*(-oy*sy) },
			{ sa*sx,  ca*sy,  0, y + ca*(-oy*sy) + sa*(-ox*sx) },
			{     0,      0, sz,                             z },
			{     0,      0,  0,                             1 },
		}
		self.matrix = helper.mulMatrix(m, self.matrix)
		self.sx = sx
		self.sy = sy
		self.sz = sz
		self.r = r
	end

	function Transform:append(transform)
	if not transform:isInstanceOf(Transform) then return false end
		self.matrix = helper.mulMatrix(transform.matrix, self.matrix)
		self.sx = self.sx * transform.sx
		self.sy = self.sy * transform.sy
		self.sz = self.sz * transform.sz
		self.r = self.r + transform.r
		return true
	end

	function Transform:vector(x, y, z)
		local m = {
			{ x },
			{ y },
			{ z },
			{ 1 },
		}
		return helper.mulMatrix(self.matrix, m)
	end

	function Transform:copy()
		local t = Transform:new()
		t:append(self)
		return t
	end

	function Transform:scale( sx, sy, sz, ox, oy )
		sy = sy or sx or 1
		sz = sz or sx or 1
		sx = sx or 1
		local m = {
			{ sx,  0,  0, 0 },
			{  0, sy,  0, 0 },
			{  0,  0, sz, 0 },
			{  0,  0,  0, 1 },
		}
		self.matrix = helper.mulMatrix(m, self.matrix)
		self.sx = self.sx * sx
		self.sy = self.sy * sy
		self.sz = self.sz * sz
	end

	function Transform:translate(dx, dy, dz, ox, oy)
		dx = dx or 0
		dy = dy or 0
		dz = dz or 0
		local m = {
			{ 1, 0, 0, dx - ox },
			{ 0, 1, 0, dy - oy },
			{ 0, 0, 1, dz },
			{ 0, 0, 0, 1 },
		}
		self.matrix = helper.mulMatrix(m, self.matrix)
	end

	function Transform:rotate(a, x, y)
		a = a or 0
		local ca = cos(rad(a))
		local sa = sin(rad(a))
		local m = {
			{ ca, -sa, 0, -x * ca + y * sa + x},
			{ sa, ca,  0, -x * sa - y * ca + y},
			{ 0,       0,      1, 0 },
			{ 0,       0,      0, 1 },
		}
		self.matrix = helper.mulMatrix(m, self.matrix)
		self.r = a
	end

return Transform