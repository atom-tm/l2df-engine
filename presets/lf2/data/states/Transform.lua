local core = l2df

local State = core.import('class.state'):new()

	function State:persistentUpdate(entity, params)

	end

	function State:update(entity, params)
		entity.vars.scalex = params.size or entity.scalex
		entity.vars.scaley = params.size or entity.scaley
	end

return State