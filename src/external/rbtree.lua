--[[
	Written by Soojin Nam. Public Domain.
	Modificated to key/value struture by Abelidze.
	The red-black tree code is based on the algorithm described in
	the "Introduction to Algorithms" by Cormen, Leiserson and Rivest.
--]]

local type = type
local setmetatable = setmetatable
local co_wrap = coroutine.wrap
local co_yield = coroutine.yield

local RED = 1
local BLACK = 0


local inorder_tree_walk
function inorder_tree_walk (x, Tnil)
	if x ~= Tnil then
		inorder_tree_walk (x.left, Tnil)
		co_yield(x.key, x.value)
		inorder_tree_walk (x.right, Tnil)
	end
end


local function tree_minimum (x, Tnil)
	while x.left ~= Tnil do
		x = x.left
	end
	return x
end


local function tree_maximum (x, Tnil)
	while x.right ~= Tnil do
		x = x.right
	end
	return x
end


local function tree_search (x, k, Tnil)
	while x ~= Tnil and k ~= x.key do
		if k < x.key then
			x = x.left
		else
			x = x.right
		end
	end
	return x
end


local function left_rotate (T, x)
	local y = x.right
	x.right = y.left
	if y.left ~= T.sentinel then
		y.left.p = x
	end
	y.p = x.p 
	if x.p == T.sentinel then
		T.root = y
	elseif x == x.p.left then
		x.p.left = y
	else
		x.p.right = y
	end
	y.left = x
	x.p = y
end


local function right_rotate (T, x)
	local y = x.left
	x.left = y.right
	if y.right ~= T.sentinel then
		y.right.p = x
	end
	y.p = x.p
	if x.p == T.sentinel then
		T.root = y
	elseif x == x.p.right then
		x.p.right = y
	else
		x.p.left = y
	end
	y.right = x
	x.p = y
end


local function rb_insert (T, z)
	local y = T.sentinel
	local x = T.root
	while x ~= T.sentinel do
		y = x
		if z.key < x.key then
			x = x.left
		else
			x = x.right
		end
	end
	z.p = y
	if y == T.sentinel then
		T.root = z
	elseif z.key < y.key then
		y.left = z
	else
		y.right = z
	end
	z.left = T.sentinel
	z.right = T.sentinel
	z.color = RED
	-- insert-fixup
	while z.p.color == RED do
		if z.p == z.p.p.left then
			y = z.p.p.right
			if y.color == RED then
				z.p.color = BLACK
				y.color = BLACK
				z.p.p.color = RED
				z = z.p.p
			else
				if z == z.p.right then
					z = z.p
					left_rotate(T, z)
				end
				z.p.color = BLACK
				z.p.p.color = RED
				right_rotate(T, z.p.p)
			end
		else
			y = z.p.p.left
			if y.color == RED then
				z.p.color = BLACK
				y.color = BLACK
				z.p.p.color = RED
				z = z.p.p
			else
				if z == z.p.left then
					z = z.p
					right_rotate(T, z)
				end
				z.p.color = BLACK
				z.p.p.color = RED
				left_rotate(T, z.p.p)
			end
		end
	end
	T.root.color = BLACK
end


local function rb_transplant (T, u, v)
	if u.p == T.sentinel then
		T.root = v
	elseif u == u.p.left then
		u.p.left = v
	else
		u.p.right = v
	end
	v.p = u.p
end


local function rb_delete (T, z)
	local x, w
	local y = z
	local y_original_color = y.color
	if z.left == T.sentinel then
		x = z.right
		rb_transplant(T, z, z.right)
	elseif z.right == T.sentinel then
		x = z.left
		rb_transplant(T, z, z.left)
	else
		y = tree_minimum(z.right, T.sentinel)
		y_original_color = y.color
		x = y.right
		if y.p == z then
			x.p = y
		else
			rb_transplant(T, y, y.right)
			y.right = z.right
			y.right.p = y
		end
		rb_transplant(T, z, y)
		y.left = z.left
		y.left.p = y
		y.color = z.color
	end
	
	if y_original_color ~= BLACK then
		return
	end
	-- delete-fixup
	while x ~= T.root and x.color == BLACK do
		if x == x.p.left then
			w = x.p.right
			if w.color == RED then
				w.color = BLACK
				x.p.color = RED
				left_rotate(T, x.p)
				w = x.p.right
			end
			if w.left.color == BLACK and w.right.color == BLACK then
				w.color = RED
				x = x.p
			else
				if w.right.color == BLACK then
					w.left.color = BLACK
					w.color = RED
					right_rotate(T, w)
					w = x.p.right
				end
				w.color = x.p.color
				x.p.color = BLACK
				w.right.color = BLACK
				left_rotate(T, x.p)
				x = T.root
			end
		else
			w = x.p.left
			if w.color == RED then
				w.color = BLACK
				x.p.color = RED
				right_rotate(T, x.p)
				w = x.p.left
			end
			if w.right.color == BLACK and w.left.color == BLACK then
				w.color = RED
				x = x.p
			else
				if w.left.color == BLACK then
					w.right.color = BLACK
					w.color = RED
					left_rotate(T, w)
					w = x.p.left
				end
				w.color = x.p.color
				x.p.color = BLACK
				w.left.color = BLACK
				right_rotate(T, x.p)
				x = T.root
			end
		end
	end
	x.color = BLACK
end


local function rbtree_node(key, value)
	return { key = key or 0, value = value }
end


-- rbtree module stuffs

local _M = {
	version = '0.0.2'
}


function _M.minimum(self)
	return tree_minimum(self.root, self.sentinel)
end


function _M.maximum(self)
	return tree_maximum(self.root, self.sentinel)
end


function _M.search(self, key)
	local node = tree_search(self.root, key, self.sentinel)
	return node ~= self.sentinel and node.value or nil
end


function _M.has(self, key)
	return tree_search(self.root, key, self.sentinel) ~= self.sentinel
end


function _M.iter(self)
	return co_wrap(function () inorder_tree_walk(self.root, self.sentinel) end)
end


function _M.insert(self, key, value)
	local key, t = key, type(key)
	if t == 'number' or t == 'string' then
		key = rbtree_node(key, value)
	end
	rb_insert(self, key)
end


function _M.remove(self, key)
	local z = tree_search(self.root, key, self.sentinel)
	if z ~= self.sentinel then
		rb_delete(self, z)
	end
end


function _M.new()
	local sentinel = rbtree_node()
	sentinel.color = BLACK
	local obj = { root = sentinel, sentinel = sentinel }
	return setmetatable(obj, {
		__index = function (t, k)
			if _M[k] then return _M[k] end
			return _M.search(obj, k)
		end,
		__newindex = _M.insert,
		__call = _M.has
	})
end


return _M
