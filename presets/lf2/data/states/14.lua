--- Lying
return function (obj, data)
	local attr = obj.C.attr
	if not attr then return end
	if attr.data().hp <= 0 then
		data.next = data.frame.id
	end
end