local core = l2df

local Kind = core.import('class.kind'):new()

	function Kind:trigger(e1, e2, itr)
		if e1 == e2 then return end

		print(itr.text or 'Screaming!')
	end

return Kind