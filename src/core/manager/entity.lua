--- Entity manager
-- @classmod l2df.core.manager.entity
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local Manager = { root = nil }

	---
	function Manager:setRoot(entity)
		self.root = entity
	end

	--- Enumeration entities on the tree of heredity
	--  @param mixed beginer  the starting point of the enumeration
	--  @param boolean skipped  skip starting point when enumeration
	--  @param boolean active
	--  @return mixed object
	function Manager:enum(beginer, skipped, active)
		beginer = beginer or self.root
		if not (beginer and (beginer.nodes or beginer.getNodes)) then return function () return nil end end
		beginer = skipped and beginer:getNodes() or { beginer }
		local tasks = { { beginer, 0, #beginer } }
		local depth = 1
		local i = 0
		local current = tasks[depth]
		return function ()
			while i < current[3] or depth > 1 do
				i = i + 1
				local returned = current[1][i]
				local nodes = returned and returned:getNodes()
				if returned and nodes and next(nodes) then
					if not active or returned.active then
						current[2] = i
						current = { nodes, 0, #nodes }
						tasks[#tasks + 1] = current
						depth = depth + 1
						i = 0
					end
				elseif i >= current[3] and depth > 1 then
					depth = depth - 1
					current = tasks[depth]
					i = current[2]
				end
				if not active or returned and returned.active then
					return returned
				end
			end
			return nil
		end
	end

return Manager