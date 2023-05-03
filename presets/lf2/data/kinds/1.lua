--- Catch (Dance of Pain)
return function (e1, e2, itr, bdy)
	if itr.owner == bdy.owner then
		return
	end
	if itr.owner == e1 then
		return
	end
end