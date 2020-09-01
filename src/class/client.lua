--- Network client class
-- @classmod l2df.class.client
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Client works only with l2df v1.0 and higher')

local packer = core.import 'external.packer'
local Class = core.import 'class'

local type = _G.type
local pairs = _G.pairs
local assert = _G.assert
local tonumber = _G.tonumber
local tostring = _G.tostring
local ppack = packer.pack
local punpack = packer.unpack
local ceil = math.ceil
local strbyte = string.byte
local strmatch = string.match
local strgmatch = string.gmatch
local strformat = string.format

local function convertIP(ip, port)
	-- local ip, port = strmatch(endpoint, '(.+):(%d+)')
	-- GSID:hash(convertIP(public, port))
	local num = 0
	for i in strgmatch(ip, '%d+') do
		num = num * 256 + assert(tonumber(i))
	end
	return num, tonumber(port)
end

local ClientEvents = nil
local ClientEventsMap = nil

local peers = { }

local Client = Class:extend()

	--- Init
	-- @param table kwargs
	function Client:init(kwargs)
		kwargs = kwargs or { }
		ClientEvents = ClientEvents or kwargs.events
		ClientEventsMap = ClientEventsMap or kwargs.emap
		kwargs.events, kwargs.emap = nil, nil
		for k, v in pairs(kwargs) do
			if type(v) ~= 'function' then
				self[k] = v
			end
		end
		self.relays = self.relays or { }
		self.public = self.public or '127.0.0.1'
		self.private = self.private or '127.0.0.1'
		self.channel = self.channel or 0
		self.port = self.port or 12564
		self.attempts = self.attempts or 0
		self.ping_overhead = self.ping_overhead or 0
		self.verified = self.verified or self.clocal and true or false
	end

	--- Client verified event
	-- @param table event
	function Client:verify(event)
		self.event = nil
		if not self.verified then
			self.verified = true
			if ClientEventsMap.verified then
				local handler = ClientEvents[ClientEventsMap.verified]
				for i = 3, #handler do
					handler[i](self, event)
				end
			end
		end
		return self
	end

	--- Client connected event
	-- @param table event
	-- @return Client
	function Client:connected(event)
		if self.peer then
			peers[self.peer] = (peers[self.peer] or 0) + 1
			self.peer:last_round_trip_time(50)
			self.peer:ping()
		end
		self.attempts = self.attempts + 1
		self.cstate = nil
		if ClientEventsMap.connected then
			local handler = ClientEvents[ClientEventsMap.connected]
			for i = 3, #handler do
				handler[i](self, event)
			end
		end
		return self
	end

	--- Client disconnected event
	-- @param table event
	function Client:disconnected(event)
		if self.peer then
			peers[self.peer] = (peers[self.peer] or 1) - 1
		end
		if ClientEventsMap.disconnected then
			local handler = ClientEvents[ClientEventsMap.disconnected]
			for i = 3, #handler do
				handler[i](self, event)
			end
		end
		return nil
	end

	--- Client received payload event
	-- @param table event
	-- @return boolean
	function Client:received(event)
		local handler = ClientEvents[strbyte(event.data) or 0]
		if not handler then
			return false
		end
		for i = 3, #handler do
			handler[i](self, event, punpack(handler[2], event.data, 2))
		end
		return true
	end

	--- Get current client's connection state
	-- @return string
	function Client:state()
		return self.cstate or self.peer and self.peer:state() or 'disconnected'
	end

	--- Check if client is connected
	-- @return string
	function Client:isConnected()
		return self.peer and self.peer:state() == 'connected' or false
	end

	--- Check if client is connected via relay
	-- @return string
	function Client:isRelayed()
		return self.name and self.channel > 0 or false
	end

	--- Check if client is local
	-- @return string
	function Client:islocal()
		return self.clocal and not self.peer or false
	end

	---
	-- @param number channel
	-- @param string endpoint
	-- @return string
	function Client:id(channel, endpoint)
		return strformat('%s#%s', endpoint or self.peer and tostring(self.peer) or self.clocal or '127.0.0.1:12564', channel or self.channel or 0)
	end

	--- Get client's ping
	-- @return number
	function Client:ping()
		return (self.ping_overhead or 0) + (self.peer and ceil(self.peer:round_trip_time() / 2) or 0)
	end

	---
	function Client:disconnect(event)
		self:disconnected(event)
		if self.peer and (peers[self.peer] or 0) < 1 then
			self.peer:disconnect()
		end
	end

	--- Send event previously registered with l2df.manager.network.event
	-- @param string event
	-- @param ... ...
	-- @return boolean
	function Client:send(event, ...)
		event = event and ClientEventsMap[event] or 0
		local format = ClientEvents[event]
		return format and self:rawsend(format[1], event, ...) or false
	end

	--- Send raw-formatted message to client
	-- @param string format
	-- @param ... ...
	-- @return boolean
	function Client:rawsend(format, ...)
		if not format then
			return false
		end
		if self:isConnected() then
			self.peer:send(ppack(format, ...), self.channel)
			return true
		end
		return self:islocal()
	end

return Client