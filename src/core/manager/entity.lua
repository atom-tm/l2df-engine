local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EntityManager works only with l2df v1.0 and higher")

local Manager = { }

	--- Enumeration entities on the tree of heredity
	--  @tparam mixed beginer the starting point of the enumeration
	--  @tparam boolean skipped skip starting point when enumeration
	--  @trerurn mixed object
	function Manager:enum(beginer, skipped)
		if not (beginer and (beginer.nodes or beginer.getNodes)) then return end
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
				if nodes and next(nodes) then
					current[2] = i
					current = { nodes, 0, #nodes }
					tasks[#tasks + 1] = current
					depth = depth + 1
					i = 0
				elseif i >= current[3] and depth > 1 then
					depth = depth - 1
					current = tasks[depth]
					i = current[2]
				end
				return returned
			end
			return nil
		end
	end

return Manager