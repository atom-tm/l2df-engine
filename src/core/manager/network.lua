--- Network manager
-- @classmod l2df.core.manager.network
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'NetworkManager works only with l2df v1.0 and higher')

local os = require 'os'
local enet = require 'enet'
local math = require 'math'
local socket = require 'socket'

local rand = math.random
local strbyte = string.byte
local strmatch = string.match
local strformat = string.format

local sock = nil
local peers = { }
local masters = { }
local message = ''

local PENDING = -1

-- Client message codes
local INIT = 1
local FIND = 2

-- Master message codes
local FLUSH = 1
local JOIN = 2

if os.getenv('L2DF_MASTER') then
	masters[os.getenv('L2DF_MASTER')] = PENDING
end

local function discoverIP()
	local udp = socket.udp()
	if not udp:setpeername('www.google.com', 80) then
		print('Error while discovering IP')
		udp:close()
		return nil
	end
	local result = udp:getsockname() or '255.255.255.255'
	udp:close()
	return result
end

local MasterEvents = {
	--- Connected to master
	connect = function (self, manager, host, event)
		if type(masters[host]) == 'userdata' then
			masters[host]:send( strformat('%c%s;%s', INIT, manager.ip, manager:username()) )
		end
	end,

	--- Disconnected from master
	disconnect = function (self, manager, host, event)
		local master = masters[host]
		if type(master) == 'userdata' then
			print(host, 'connection lost')
			master:reset()
			masters[host] = PENDING
		end
	end,

	--- Received message from master
	receive = function (self, manager, host, event)
		local code, payload = strmatch(event.data, '^(.)(.*)')
		code = code and strbyte(code)
		if code and self[code] then
			self[code](self, manager, host, event, payload)
		end
	end,

	[JOIN] = function (self, manager, host, event, payload)
		local peer, ip = { punch = true }
		ip, peer.private, peer.public, peer.port = strmatch(payload, '^(%S*);(%S*);(%S*):(%S*)')
		if peer.public == ip then -- under one NAT
			peer.public = peer.private
			peer.private = ip
		end

		local endpoint = strformat('%s:%s', peer.public, peer.port)
		peer.entry = sock:connect(endpoint)
		message = strformat('PeerID: %s, punching %s', peer.entry:connect_id(), endpoint)
		peers[tostring(peer.entry)] = peer
	end,

	[FLUSH] = function (self, manager, host, event, payload)
		print('FLUSH')
		for k, peer in pairs(peers) do
			peer.entry:disconnect()
		end
		peers = { }
	end
}

local Manager = { }

	--- Add master server
	-- @param string host
	-- @return NetworkManager
	function Manager:register(host)
		if masters[host] then return end
		-- TODO: add host validation
		-- TODO: resolve host (remove domains and etc)
		masters[host] = PENDING
		return self
	end

	--- Init networking based on configuration
	-- @param string username
	-- @return NetworkManager
	function Manager:init(username)
		if self:isReady() then
			return self
		end

		assert(type(username) == 'string', 'Username is required for NetworkManager')
		self.ip = discoverIP() or '127.0.0.1'
		self.name = username
		self.tag = rand(1000, 9999)

		sock = enet.host_create()
		for host, master in pairs(masters) do
			if master == PENDING then
				masters[host] = sock:connect(host)
			end
		end
		return self
	end

	function Manager:join(username)
		if not self:isReady() or not username then
			return false
		end

		for host, master in pairs(masters) do
			if master ~= PENDING and master:state() ~= 'disconnected' then
				master:send( strformat('%c%s', FIND, username) )
			end
		end
		return true
	end

	function Manager:broadcast(message)
		if not message then return end
		for k, peer in pairs(peers) do
			peer.entry:send(message)
		end
	end

	--- Dispose all connections
	-- @return NetworkManager
	function Manager:destroy()
		for host, master in pairs(masters) do
			if master ~= PENDING and master:state() ~= 'disconnected' then
				master:disconnect()
			end
			masters[host] = PENDING
		end
		if sock then
			sock:flush()
			sock:destroy()
			sock = nil
		end
		return self
	end

	---
	-- @return boolean
	function Manager:isReady()
		return sock ~= nil
	end

	function Manager:isConnected()
		return next(peers) ~= nil
	end

	--- Get formatted username
	-- @return string
	function Manager:username()
		return strformat('%s.%s', self.name, self.tag)
	end

	--- Manager's update
	-- @param number dt
	function Manager:update(dt)
		if not self:isReady() then return end

		local event, peer, endpoint = sock:service()
		while event do
			print(event.type, event.peer:connect_id())
			endpoint = tostring(event.peer)
			peer = peers[endpoint] or { punch = true, entry = event.peer }

			-- If it came from master
			if masters[endpoint] then
				if MasterEvents[event.type] then
					MasterEvents[event.type](MasterEvents, self, endpoint, event)
				end

			-- If it came from another peer
			elseif event.type == 'receive' then
				print('User message: ' .. event.data)

			elseif event.type == 'connect' then
				-- Drop pending and attach to existen
				if peer.entry:state() ~= 'connected' then
					peer.entry:reset()
					peer.entry = event.peer
					print('Attached to ', peer.entry)
				-- Drop duplicated connection
				elseif event.peer:connect_id() < peer.entry:connect_id() then
					peer.entry:disconnect()
					peer.entry = event.peer
					print('Switched to ', peer.entry)
				-- Connected, do nothing
				else
					print('Connected to ', peer.entry)
				end
				peers[endpoint] = peer

			elseif event.type == 'disconnect' and peer.entry == event.peer then
				-- Failed to connect via public
				-- TODO: remove punch field after successful connection
				if peer.punch then
					endpoint = strformat('%s:%s', peer.private, peer.port)
					peer.entry = sock:connect(endpoint)
					peer.punch = false
					print('Punching local ', endpoint)
					peers[tostring(peer.entry)] = peer
				-- Connection impossible: symmetric NAT, firewall and etc
				else
					print('Disconnected from ', endpoint)
					peers[endpoint] = nil
				end
			end
			event = sock:service()
		end
	end

return Manager