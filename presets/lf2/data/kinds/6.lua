--- Super punch
return function (e1, e2, itr, bdy)
	if itr.owner == bdy.owner then
		return
	end
	local attr = e2.C.attr
	if attr then
		attr.data().cansuper = true
	end
end