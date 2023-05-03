--- Network manager
-- @classmod l2df.manager.network
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'NetworkManager works only with l2df v1.0 and higher')

local os = require 'os'
local enet = require 'enet'
local math = require 'math'
local socket_ok, socket = pcall(require, 'socket')
local log = core.import 'class.logger'
local json = core.import 'class.parser.json'
local helper = core.import 'helper'
local packer = core.import 'external.packer'
local Client = core.import 'class.client'

local type = _G.type
local pairs = _G.pairs
local rawset = _G.rawset
local max = math.max
local strbyte = string.byte
local strchar = string.char
local strmatch = string.match
local strgmatch = string.gmatch
local strformat = string.format
local tsort = table.sort
local unpack = table.unpack or _G.unpack
local toarray = helper.array

local sock = nil
local sock_ready = false
local relay_timer = 0
local clients_resort = true
local clients_sorted = { }
local pending_relays = { }
local relay_remap = { }
local masters = { }
local lobbies = { }
local relayid = { }
local clients = setmetatable({ }, { __newindex = function (t, k, v) rawset(t, k, v);clients_resort = true end })
local players = setmetatable({ }, { __newindex = function (t, k, v) rawset(t, k, v);clients_resort = true end })

-- Constants
local SEP = 29
local PENDING = -1
local RELAY_WAIT_TIME = 1
local RELAY_MAX_COUNT = 10
local PUNCH_ATTEMPTS = 5
local RELAY_CLIENT_ATTEMPTS = PUNCH_ATTEMPTS + 2
local RELAY_MASTER_ATTEMPTS = RELAY_CLIENT_ATTEMPTS + 2
local MIN_PEER_TIMEOUT = 2000
local MAX_PEER_TIMEOUT = 4000
local NETRECORD_PATTERN = '([^' .. strchar(SEP) .. ']+)'

-- Client message codes
local LOGIN = 1
local LIST = 2
local FIND = 3
local RELAY = 4
local LEAVE = 5

-- Master message codes
local FLUSH = 1
local LIST = 2
local LINK = 3
local RELAY = 4
local LOBBY = 6

if os.getenv('L2DF_MASTER') then
	masters[os.getenv('L2DF_MASTER')] = PENDING
end

local function itunpack(...)
	return unpack(toarray(...))
end

local function setClient(id, name, client)
	if client then
		client.name = name
	elseif players[name] then
		for _, c in pairs(clients) do
			if c.name == name and c ~= players[name] then
				name = nil
				break
			end
		end
	end
	clients[id] = client
	players[name or 0] = name and client or nil
	return client
end

local function discoverIP()
	if not socket_ok then
		return nil
	end
	-- TODO: luajit.ffi, https://gist.github.com/abelidze/f6d715200775efc3dc5a4f838a7ac898
	local udp = socket.udp4()
	if not udp:setpeername('www.google.com', 80) then
		log:error('Discovering IP has failed')
		udp:close()
		return socket.dns.toip(socket.dns.gethostname())
	end
	local result = udp:getsockname() or nil
	udp:close()
	return result
end

local function Relay_reset()
	for i = 1, RELAY_MAX_COUNT do
		relayid[i] = RELAY_MAX_COUNT - i + 1
	end
	pending_relays = { }
end

local function Relay_newRequest(client)
	client.cstate = 'relay-requesting'
	client.ping_overhead = 1e12
	client.channel = 0
	client.attempts = PUNCH_ATTEMPTS
	relay_timer = RELAY_WAIT_TIME
	pending_relays[client.name] = client
end

local function Relay_acceptRequest(client, event, name)
	local relay = name and players[name]
	-- We couldn't be a relay
	if #relayid == 0 or not (relay and relay.channel == 0 and relay:isConnected()) then
		return
	end
	-- Reject request if at some point we lost connection to the client
	client = clients[client:id(0)]
	if not client then
		log:debug('Rejected relay request to %s', name)
		return
	end
	-- Save relay remapping and notify clients about successful connection
	if event.channel == relayid[#relayid] then
		log:info('New relay %s <-> %s', name, client.name)
		relayid[#relayid] = nil
		relay.channel, client.channel = event.channel, event.channel
			relay_remap[client:id()] = relay
			relay_remap[relay:id()] = client
			client.relays[#client.relays + 1] = event.channel
			relay.relays[#relay.relays + 1] = event.channel
			relay:send('l2df-relay-reply', client.name, max(1, client:ping()), event.channel)
			client:send('l2df-relay-reply', relay.name, max(1, relay:ping()), event.channel)
		relay.channel, client.channel = 0, 0
		return
	-- Relay is only possible between directly connected peers
	elseif event.channel > 0 then
		log:debug('Rejected relay request to %s', name)
		return
	end
	-- Reply for the first request with a free relay channel
	log:debug('Reply to relay request %s <-> %s', name, client.name)
	client:send('l2df-relay-reply', name, max(1, relay:ping()), relayid[#relayid])
end

local function Relay_acceptReply(client, event, name, ping, channel)
	if not ping or not channel then return end
	-- Peer was disconnected
	if ping == 0 then
		client:disconnect(event)
		return
	end
	-- Accept notification about successful relay bridge
	if event.channel > 0 then
		log:success('Relayed with %s', name)
		client.ping_overhead, client.event, client.cstate = ping, event, 'relay-connecting'
		local relay = pending_relays[name] or players[name] or client
		relay:init(client)
		relay_timer = RELAY_WAIT_TIME
		pending_relays[name] = relay
		return
	end
	-- Filter irrelevant replies
	local relay = pending_relays[name]
	if not relay then
		return
	end
	-- Update relay info and choose best option
	log:info('Relay reply %s[%d] - %sms vs %sms', name, channel, Client.ping(event) + ping, relay:ping())
	if Client.ping(event) + ping < relay:ping() then
		setClient(relay:id())
		relay.ping_overhead = ping
		relay.peer = event.peer
		relay.channel = channel
		relay.name = name
		relay.master = masters[tostring(event.peer)] and true or nil
	end
end

local function Masters_connect()
	for host, master in pairs(masters) do
		if master == PENDING then
			masters[host] = {
				peer = sock:connect(host, RELAY_MAX_COUNT + 1),
				channel = 0
			}
			masters[host].peer:timeout(0, MIN_PEER_TIMEOUT, MAX_PEER_TIMEOUT)
			sock_ready = true
			log:debug('Connecting to master: %s', host)
		end
	end
end

local function Masters_broadcast(...)
	for host, master in pairs(masters) do
		if master ~= PENDING and master.initialized and master.peer:state() ~= 'disconnected' then
			master.peer:send( strformat(...) )
		end
	end
end

local ClientEvents = { }
local ClientEventsMap = { }

local function ClientEventEmitter(event, ...)
	local handler = ClientEvents[ClientEventsMap[event] or event]
	if not handler then
		return false
	end
	for i = 3, #handler do
		handler[i](...)
	end
	return true
end

local MasterEvents = {
	-- Connected to master
	connect = function (self, manager, host, event)
		local master = masters[host]
		if master ~= PENDING then
			log:success('Connected to master: %s', host)
			master.peer:last_round_trip_time(50)
			master.peer:ping()
			master.peer:send( strformat('%c%s%c%s', LOGIN, manager.ip, SEP, manager.username) )
			master.initialized = true
			ClientEventEmitter('masterconnected', master, event)
		end
	end,

	-- Disconnected from master
	disconnect = function (self, manager, host, event)
		local master = masters[host]
		if master ~= PENDING then
			for id, c in pairs(clients) do
				if c.peer == master.peer then
					log:info('Lost connection to relay for %s. Finding new one...', c.name)
					Masters_connect()
					if manager.username > c.name then
						Relay_newRequest(c)
					end
				end
			end
			master.peer:reset()
			masters[host] = PENDING
			if event.data == 228 then
				log:warn 'Dropped by master. User with same username already exists.'
			elseif not master.relayed then
				log:warn 'Lost connection to master.'
			end
			ClientEventEmitter('masterdisconnected', master, event)
		end
	end,

	-- Received message from master
	receive = function (self, manager, host, event)
		local code, payload = strmatch(event.data, '^(.)(.*)')
		code = code and strbyte(code)
		if code and self[code] then
			self[code](self, manager, host, event, payload)
		end
	end,

	-- Request to link another peer
	[LINK] = function (self, manager, host, event, payload)
		local ip, id, name, private, public, port = itunpack(strgmatch(payload, NETRECORD_PATTERN))
		-- Peers are under one NAT
		if public == ip then
			public, private = private, public
		end
		local e1, e2 = strformat('%s:%s', public, port), strformat('%s:%s', private, port)
		local client = players[name] or clients[Client:id(0, e1)] or clients[Client:id(0, e2)] or Client {
			events = ClientEvents,
			emap = ClientEventsMap,
			emitter = ClientEventEmitter,
			cstate = 'punching',
		}
		client.uid, client.name = id, name
		if client:state() == 'connected' then
			return
		end
		client.attempts = 0
		client.public, client.private, client.port, client.port2 = public, private, port, port
		setClient(client:id()) -- Removing unnecessary
		client.peer = sock:connect(e1, RELAY_MAX_COUNT + 1)
		client.peer:timeout(0, MIN_PEER_TIMEOUT, MAX_PEER_TIMEOUT)
		setClient(client:id(), name, client)
		log:info('PeerID: %s, punching %s', client.peer:connect_id(), e1)
	end,

	-- List all public lobbies
	[LIST] = function (self, manager, host, event, payload)
		lobbies = toarray(strgmatch(payload, NETRECORD_PATTERN))
		if #lobbies == 1 and lobbies[1] == '' then
			lobbies[1] = nil
		end
		for i = 1, #lobbies do
			lobbies[i] = json:parse(lobbies[i])
		end
	end,

	-- Client was added to lobby
	[LOBBY] = function (self, manager, host, event, payload)
		if manager.lobbyid ~= payload then
			manager.lobbyid = payload
			ClientEventEmitter('masterlobby', master, event, payload)
		end
	end,

	-- Reply from master to relay peers
	[RELAY] = function (self, manager, host, event, payload)
		local name, ping, channel = itunpack(strgmatch(payload, NETRECORD_PATTERN))
		if not ping or not channel then return end
		local client = clients[Client.id(event, channel)] or Client {
			events = ClientEvents,
			emap = ClientEventsMap,
			emitter = ClientEventEmitter,
			name = name,
			peer = event.peer,
			channel = event.channel,
		}
		ping = tonumber(ping)
		if ping > 0 and event.channel > 0 then
			masters[host].relayed = true
		end
		Relay_acceptReply(client, event, name, ping, tonumber(channel))
	end,

	-- Drop all connections (leaving lobby)
	[FLUSH] = function (self, manager, host, event, payload)
		log:info('FLUSH all connections')
		manager.lobbyid = nil
		for id, client in pairs(clients) do
			client:disconnect()
			setClient(id, client.name)
		end
		Relay_reset()
	end
}

local Manager = { ip = '127.0.0.1' }

	--- Configure @{l2df.manager.network}
	-- @param table kwargs
	-- @param string kwargs.username
	-- @param[opt=1] number kwargs.relay_wait_time
	-- @param[opt=10] number kwargs.relay_max_count
	-- @param[opt=2] number kwargs.relay_client_attempts
	-- @param[opt=2] number kwargs.relay_master_attempts
	-- @param[opt=2000] number kwargs.min_peer_timeout
	-- @param[opt=4000] number kwargs.max_peer_timeout
	-- @return l2df.manager.network
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		RELAY_WAIT_TIME = kwargs.relay_wait_time or RELAY_WAIT_TIME
		RELAY_MAX_COUNT = kwargs.relay_max_count or RELAY_MAX_COUNT
		RELAY_CLIENT_ATTEMPTS =
			PUNCH_ATTEMPTS + (kwargs.relay_client_attempts or (RELAY_CLIENT_ATTEMPTS - PUNCH_ATTEMPTS))
		RELAY_MASTER_ATTEMPTS =
			RELAY_CLIENT_ATTEMPTS + (kwargs.relay_master_attempts or (RELAY_MASTER_ATTEMPTS - RELAY_CLIENT_ATTEMPTS))
		MIN_PEER_TIMEOUT = kwargs.min_peer_timeout or MIN_PEER_TIMEOUT
		MAX_PEER_TIMEOUT = kwargs.max_peer_timeout or MAX_PEER_TIMEOUT
		self.username = kwargs.username or self.username
		return self:initSocket()
	end

	--- Init socket-communication stuff. Called internally and usually should not be used explicitly
	-- @return l2df.manager.network
	function Manager:initSocket()
		if not self:isReady() then
			if sock then
				sock:destroy()
			end
			sock = enet.host_create(nil, nil, RELAY_MAX_COUNT + 1)
			Relay_reset()
		end
		return self
	end

	--- Determine if manager is ready to setup connetions
	-- @return boolean
	function Manager:isReady()
		return sock and sock_ready
	end

	--- Determine if any client is connected
	-- @return boolean
	function Manager:isConnected()
		for _, c in pairs(clients) do
			if c:isConnected() then
				return true
			end
		end
		return false
	end

	--- Register new master server
	-- @param string host
	-- @return l2df.manager.network
	function Manager:register(host)
		-- TODO: add host validation
		local ip, port = strmatch(host, '^(.+):(%d+)$')
		ip = ip or 'localhost'
		host = strformat('%s:%s', socket_ok and socket.dns.toip(ip) or ip, port)
		if not ip or masters[host] then return end
		masters[host] = PENDING
		return self
	end

	--- Dispose all connections
	-- @return l2df.manager.network
	function Manager:destroy()
		self:logout()
		Relay_reset()
		if sock then
			sock:flush()
			sock:destroy()
			sock_ready = false
			sock = nil
		end
		return self
	end

	--- Login to all registered masters and discover your local IP
	-- @param[opt] string username
	-- @return l2df.manager.network
	function Manager:login(username)
		self:initSocket()
		username = username or self.username
		self.username = assert(type(username) == 'string' and username, 'Username is required for NetworkManager')
		self.ip = discoverIP() or '127.0.0.1'
		for id, c in pairs(clients) do
			if not c:isConnected() then
				c:disconnect()
				setClient(id, c.name)
			end
		end
		Masters_connect()
		return self
	end

	--- Disconnects from all registered masters
	-- @return l2df.manager.network
	function Manager:logout()
		self.lobbyid = nil
		for host, master in pairs(masters) do
			if master ~= PENDING then
				if master.relayed then
					master.peer:send(strformat('%c', LEAVE))
				else
					master.peer:disconnect()
					masters[host] = PENDING
				end
			end
		end
		return self
	end

	--- Send search request to master
	-- @param string lobby  ID of lobby to join
	-- @return boolean
	function Manager:join(lobby)
		if not self:isReady() or not lobby then
			return false
		end
		Masters_broadcast('%c%s', FIND, lobby)
		return true
	end

	--- Create new lobby
	-- @return boolean
	function Manager:host()
		if not self:isReady() then
			return false
		end
		Masters_broadcast('%c', FIND)
		return true
	end

	local function getLobbies()
		return lobbies
	end

	---
	-- @param[opt] number count
	-- @param[opt] boolean refresh
	-- @return function
	function Manager:list(count, refresh)
		if refresh then
			lobbies = nil
		end
		if count then
			Masters_broadcast('%c%d', LIST, count)
		else
			Masters_broadcast('%c', LIST)
		end
		return getLobbies
	end

	--- Register new network event
	-- @param string name
	-- @param string format
	-- @param function callback
	function Manager:event(name, format, callback)
		assert(type(callback) == 'function', 'Callback for network event must be a function')
		local id
		if not ClientEventsMap[name] then
			id = #ClientEvents + 1
			assert(id < 256, 'Too much network events. Max supported count: 255')
			ClientEvents[id] = { 'B' .. (format or ''), format or '' }
			ClientEventsMap[name] = id
		else
			id = ClientEventsMap[name]
		end
		local events = ClientEvents[id]
		events[#events + 1] = callback
	end

	--- Broadcast event to all connected clients
	-- @param string event
	-- @return boolean
	function Manager:broadcast(event, ...)
		event = event and ClientEventsMap[event] or 0
		local format = ClientEvents[event]
		if not (format and self:isConnected()) then
			return false
		end
		local result = true
		for _, client in pairs(clients) do
			result = client:rawsend(format[1], event, ...) and result
		end
		return result
	end

	--- Manually add local client
	-- @param string id
	-- @param string name
	-- @param table kwargs
	-- @return l2df.class.client
	function Manager:addClient(id, name, kwargs)
		if players[name] then return end
		kwargs = kwargs or { clocal = id, cstate = 'connected' }
		return setClient(id, name, Client(kwargs))
	end

	local function sortByName(a, b)
		return a.name < b.name
	end

	--- Returns an iterator on connected clients
	-- @param[opt] string id
	-- @return function
	function Manager:clients(id)
		if id then return clients[id] or players[id] end
		if clients_resort then
			local i = 0
			for _, c in pairs(clients) do
				if c.verified and c:state() == 'disconnected' then
					c:disconnected()
				else
					i = i + 1
					clients_sorted[i] = c
				end
			end
			for k = i + 1, #clients_sorted do
				clients_sorted[k] = nil
			end
			if i == 0 then
				Relay_reset()
			end
			tsort(clients_sorted, sortByName)
			clients_resort = false
		end
		return next, clients_sorted
	end

	--- Manager's update
	-- @param number dt
	function Manager:update(dt)
		if not self:isReady() then return end

		local event, client, endpoint, eid = sock:service()
		while event do
			eid = Client.id(event)
			endpoint = tostring(event.peer)
			client = relay_remap[eid] or clients[eid] or masters[endpoint] or Client {
				events = ClientEvents,
				emap = ClientEventsMap,
				emitter = ClientEventEmitter,
				peer = event.peer,
				channel = event.channel,
			}

			-- Relay received data
			if relay_remap[eid] then
				client.peer:send(event.data, event.channel)

			-- If it came from master
			elseif client == masters[endpoint] then
				if MasterEvents[event.type] then
					MasterEvents[event.type](MasterEvents, self, endpoint, event)
				end

			-- If it came from another peer
			elseif event.type == 'receive' then
				client:received(event)

			elseif event.type == 'connect' then
				-- Drop pending and attach to existen
				if not client:isConnected() then
					log:success('Attached to %s', client.name or eid)
					client.peer:reset()
					client.peer = event.peer

				-- Drop duplicated connection
				elseif event.peer:connect_id() < client.peer:connect_id() then
					log:success('Switched to %s', client.name or eid)
					client.peer:disconnect()
					client.peer = event.peer

				-- Connected, do nothing
				else
					log:success('Connected to %s', client.name or eid)
				end
				setClient(eid, client.name, client:connected(event))
				client:send('l2df-verify', self.username)

			elseif event.type == 'disconnect' then
				-- Failed to connect via public
				-- TODO: add UPnP
				if client.attempts < PUNCH_ATTEMPTS and client.port2 then
					local ip, port, msg = client.public, client.port, nil
					if client.attempts == 0 and client.private then
						msg = 'Connecting in local network'
						ip = client.private
					else
						msg = 'Punching symmetric NAT'
						if (self.ip < client.public) == (client.attempts % 2 == 0) then
							port = client.port2 + 1
							client.port2 = port
						end
					end
					clients[eid] = nil
					endpoint = strformat('%s:%s', ip, port)
					client.peer = sock:connect(endpoint, RELAY_MAX_COUNT + 1)
					client.peer:timeout(0, MIN_PEER_TIMEOUT, MAX_PEER_TIMEOUT)
					client.attempts = client.attempts + 1
					eid = client:id()
					log:info('%s %s[%s]', msg, client.name or eid, endpoint)
					clients[eid] = client

				-- Symmetric NAT, firewall and etc: use relay
				elseif not client.verified and client.name then
					log:info('Switching to relay for %s', client.name)
					Relay_newRequest(client)

				-- Simple disconnect
				else
					local relay, id, channel, tmp
					for i = #client.relays, 1, -1 do
						channel = client.relays[i]
						id = client:id(channel)
						relay = relay_remap[id]
						if relay then
							log:info('Disconnect relay %s <-> %s', relay.name, client.name)
							tmp, relay.channel = relay.channel, channel
							relay:send('l2df-relay-reply', client.name, 0, channel)
							relay.channel = tmp
							relayid[#relayid + 1] = channel
							relay_remap[relay:id(channel)] = nil
							relay_remap[id] = nil
						end
						client.relays[i] = nil
					end
					for id, c in pairs(clients) do
						if c.peer == event.peer then
							if c:isRelayed() then
								log:info('Lost connection to relay for %s. Finding new one...', c.name)
								Masters_connect()
								if self.username > c.name then
									Relay_newRequest(c)
								end
							else
								c:disconnected(event)
							end
						end
					end
				end
			end
			event = sock:service()
		end

		-- Handling relay requests
		if relay_timer > 0 then
			if relay_timer <= dt then
				local count = 0
				for name, c in pairs(pending_relays) do
					-- Connection established
					if c:state() == 'connected' then
						pending_relays[name] = nil

					-- Relay connection established
					elseif c:state() == 'relay-connecting' then
						clients_resort = true
						setClient(c:id(), name, c)
						c:connected(c.event)
						c:verify(c.event)
						pending_relays[name] = nil

					-- Relay found
					elseif c:isRelayed() then
						log:info('Found relay for %s[%s]', name, c:id())
						c.cstate = 'relay-found'
						if c.master then
							c.peer:send(strformat('%c%s', RELAY, name), c.channel)
						else
							c:send('l2df-relay-request', name)
						end

					-- Request client as a relay
					elseif c.attempts < RELAY_CLIENT_ATTEMPTS then
						log:debug('Finding relay for %s', name)
						c.attempts = c.attempts + 1
						for _, client in pairs(clients) do
							if client.channel == 0 then
								client:send('l2df-relay-request', name)
							end
						end

					-- Request master-server as a relay
					elseif c.attempts < RELAY_MASTER_ATTEMPTS then
						log:warn('Using master as a relay for %s', name)
						c.attempts = c.attempts + 1
						Masters_broadcast('%c%s', RELAY, name)

					-- No relay found. Sad story :[
					else
						-- TODO: drop all connections since we can't start a lobby
						log:error('Couldn\'t connect with %s', name)
						c.cstate = 'error'
						c:disconnect(c)
						pending_relays[name] = nil
					end
					count = count + 1
				end
				relay_timer = count > 0 and RELAY_WAIT_TIME or 0
			else
				relay_timer = relay_timer - dt
			end
		end
	end

	-- Disconnection message
	Manager:event('disconnected', nil, function (c, e)
		log:info('Disconnected from %s', c.name or c:id())
		setClient(c:id(), c.verified and c.name)
	end)

	-- Verification message
	Manager:event('l2df-verify', 's', function (c, e, name)
		c.ping_overhead = 0
		c.name = name -- important, do not erase!
		setClient(c:id(), name, c:verify(e))
	end)

	-- Request from peer to relay
	Manager:event('l2df-relay-request', 's', Relay_acceptRequest)

	-- Reply from relay to both peers
	Manager:event('l2df-relay-reply', 'sHB', Relay_acceptReply)

return setmetatable(Manager, { __call = Manager.init })