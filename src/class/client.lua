--- Network client class
-- @classmod l2df.class.client
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Client works only with l2df v1.0 and higher')

local packer = core.import 'external.packer'
local Class = core.import 'class'

local strbyte = string.byte

local ClientEvents = nil
local ClientEventsMap = nil

local Client = Class:extend()

	---
	function Client:init(kwargs)
		kwargs = kwargs or { }
		ClientEvents = ClientEvents or kwargs.events
		ClientEventsMap = ClientEventsMap or kwargs.emap
		self.peer = kwargs.peer
		self.port = kwargs.port or 12564
		self.name = kwargs.name or 'unknown'
		self.public = kwargs.public or '127.0.0.1'
		self.private = kwargs.private or '127.0.0.1'
		self.attempts = 0
		if self:state() == 'connected' then
			self:connected()
		end
	end

	---
	-- @param table event
	-- @return Client
	function Client:connected(event)
		self.attempts = 1
		return self
	end

	---
	-- @param table event
	function Client:disconnected(event)
		return nil
	end

	---
	-- @param table event
	-- @return boolean
	function Client:received(event)
		local handler = ClientEvents[strbyte(event.data) or 0]
		if not handler then return false end

		handler[3](self, event, packer.unpack(handler[2], event.data, 2))
		return true
	end

	---
	-- @return string
	function Client:state()
		return self.peer and self.peer:state() or 'disconnected'
	end

	---
	-- @return number
	function Client:ping()
		return self.peer and self.peer:round_trip_time() / 2 or 0
	end

	---
	-- @param string event
	-- @return boolean
	function Client:send(event, ...)
		event = ClientEvents[event and ClientEventsMap[event] or 0]
		if event then
			return self:rawsend(event[1], event, ...)
		end
		return false
	end

	---
	-- @param string format
	-- @return boolean
	function Client:rawsend(format, ...)
		if not (format and self:state() == 'connected') then
			return false
		end
		self.peer:send( packer.pack(format, ...) )
		return true
	end

return Client