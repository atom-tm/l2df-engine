local core = l2df
local Controller = core.import 'class.component.controller'
local helper = core.import 'helper'

local State = core.import('class.state'):new()

	function State:persistentUpdate(entity, params)
		local vars = entity.vars
		local control = entity:getComponent(Controller)
		if control:pressed('up') then vars.dvz = vars.dvz - 2 end
		if control:pressed('down') then vars.dvz = vars.dvz + 2 end
		if control:pressed('left') then vars.dvx = vars.dvx - 4 end
		if control:pressed('right') then vars.dvx = vars.dvx + 4 end
	end

return State