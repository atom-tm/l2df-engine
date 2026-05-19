local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local cfg = core.import 'config'
local helper = core.import 'helper'
local json = core.import 'class.parser.json'
local log = core.import 'class.logger'

-- COMPONENTS
local Camera = core.import 'class.component.camera'
local Controller = core.import 'class.component.controller'
local SoundSystem = core.import 'class.component.sound'
local CharAttributes = require 'data.scripts.component.attributes'

-- MANAGERS
local Factory = core.import 'manager.factory'
local Input = core.import 'manager.input'
local Recorder = core.import 'manager.recorder'
local SceneManager = core.import 'manager.scene'

local Scene = core.import 'class.entity.scene'
local Room = Scene { active = false }

	local metadata = nil

	local function parseMetadata(raw)
		local ok, meta = pcall(function ()
			return raw ~= '' and json:parse(raw) or { }
		end)
		if not ok or type(meta) ~= 'table' then
			meta = { }
		end
		if meta[1] and not meta.players then
			meta = {
				version = 0,
				background = 1,
				players = meta,
			}
		end
		meta.players = meta.players or { }
		return meta
	end

	local function ensureInputPlayers(players)
		local maxplayer = Input.localplayers
		for i = 1, #players do
			maxplayer = math.max(maxplayer, players[i].player or i)
		end
		while Input.localplayers + Input.remoteplayers < maxplayer do
			Input:newRemotePlayer()
		end
	end

	local function loadReplay(raw)
		metadata = parseMetadata(raw)
		ensureInputPlayers(metadata.players)
		return 0
	end

	local function createBackground(id)
		local bg = assert(data.bgdata:getById(id or 1), 'Replay background is missing')
		bg = helper.copyTable(bg)
		bg.layer = 'GAME_LAYER'
		return Factory:create('map', bg)
	end

	local function createFighter(item, index)
		local charid = item.char or item.charid or index
		local source = assert(data.chardata:getById(charid), 'Replay character is missing')
		source.playonce = source.playonce or cfg.playonce

		local char = Factory:create('object', source)
		local objdata = char.data
		objdata.charid = charid
		objdata.index = item.index or index
		objdata.team = item.team or 0
		objdata.player = item.player or index
		objdata.syncid = item.syncid or ('player:%d'):format(index)
		objdata.x = item.x or objdata.x
		objdata.y = item.y or objdata.y
		objdata.z = item.z or objdata.z
		objdata.facing = item.facing or objdata.facing
		char:addComponent(Controller, objdata.player)
		char:addComponent(SoundSystem, source)
		char:addComponent(CharAttributes, source)
		char:addComponent(Camera, { kx = 128, ky = 128 })
		return char
	end

	function Room:enter()
		local replay = assert(data.replay, 'Replay path is not configured')
		assert(replay.path, 'Replay path is not configured')
		metadata = nil
		if not Recorder:open(replay.path, loadReplay) then
			SceneManager:set('menu')
			return
		end
		if not (metadata and metadata.players and #metadata.players > 0) then
			log:error('Replay "%s" has no LF2 metadata', replay.path)
			SceneManager:set('menu')
			return
		end

		local chars = { }
		for i = 1, #metadata.players do
			chars[i] = createFighter(metadata.players[i], i)
		end
		replay.playing = true
		replay.background = metadata.background or 1
		replay.frames = metadata.frames
		Input:lock()
		SceneManager:push('battle', createBackground(replay.background), chars)
		log:info('Playing replay %s', replay.path)
	end

	function Room:enable()
		local replay = data.replay or { }
		replay.playing = false
		replay.frames = nil
		replay.path = nil
		SceneManager:set('menu')
	end

	function Room:filedropped(file)
		data.openReplay(file and file:getFilename())
	end

	function Room:leave()
		if data.replay then
			data.replay.playing = false
			data.replay.frames = nil
		end
	end

return Room
