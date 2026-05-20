return function(obj, data, params)
	local field = params.field or 'state_runs'
	data[field] = (data[field] or 0) + 1
	return obj, data, params
end
