local frame = require 'data.scripts.frame'
local input = require 'data.scripts.input'
local Object = require 'data.scripts.object'
local relationship = require 'data.scripts.relationship'

local M = { }

function M.number(value, default)
	return frame.number(value, default)
end

function M.hasFrameState(data, state)
	return frame.hasState(data, state)
end

M.isOwner = relationship.isOwner
M.isFriendly = relationship.isFriendly

M.frameEntered = frame.entered
M.doubled = input.doubled
M.setFrame = frame.set
M.addFrameWait = frame.addWait

M.registerDynamic = Object.registerDynamic
M.clearDynamic = Object.clearDynamic
M.syncDynamic = Object.syncDynamic
M.despawn = Object.despawn
M.prepareFrame = Object.prepareFrame
M.handleSpecialInput = input.handleSpecial

M.spawnObject = Object.spawnObject
M.processOpoint = function (obj, data)
	return Object.processOpoint(obj, data, frame.entered)
end
M.projectile = Object.projectile
M.projectileHit = Object.projectileHit
M.pickupWeapon = Object.pickupWeapon
M.weapon = Object.weapon

return M
