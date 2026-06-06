local tostring = _G.tostring

local M = { }

local function ownerid(data)
	if not data then
		return nil
	end
	local id = data.syncid or data.gsid or data.player or data.index
	return id and tostring(id) or nil
end

function M.ownerid(data)
	return ownerid(data)
end

function M.isOwner(source, target)
	local sdata = source and source.data or source
	local tdata = target and target.data or target
	if not (sdata and tdata and sdata.ownerid) then
		return false
	end
	return tostring(sdata.ownerid) == ownerid(tdata)
end

function M.isFriendly(source, target)
	if M.isOwner(source, target) then
		return true
	end
	local sdata = source and source.data or source
	local tdata = target and target.data or target
	return sdata and tdata
		and sdata.team and tdata.team
		and sdata.team ~= 0
		and sdata.team == tdata.team
		or false
end

return M
