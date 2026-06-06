local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local log = core.import 'class.logger'
local cfg = core.import 'config'
local helper = core.import 'helper'

-- CLASSES
local Storage = core.import 'class.storage'
local Parser = core.import 'class.parser.lffs2'

-- MANAGERS
local StatesManager = core.import 'manager.states'
local KindsManager = core.import 'manager.kinds'
local SceneManager = core.import 'manager.scene'

local loader, Room, RoomData
local function loading()
	log:info 'Loading states...'
coroutine.yield()
	StatesManager:load(cfg.states)
	log:info 'Loading kinds...'
coroutine.yield()
	KindsManager:load(cfg.kinds)
	log:info 'Loading characters...'
coroutine.yield()
	data.objectdata = data.objectdata or Storage()
	if cfg.characters then
		for i = 1, #cfg.characters do
			local entry = cfg.characters[i]
			local path = entry.file or entry[1]
			log:info('Loading: %s', path)
			local char = Parser:parseFile(path)
			if char then
				char._lf2 = true
				char._lf2_type = entry.type or char._lf2_type or 0
				char.lf2id = entry.id or char.lf2id
				if char.preview then
					char.preview = {
						states = { {
							[1] = 'GROUP',
							_type = 'group',
							nodes = {
								char.preview,
								{
									[1] = 'LABEL',
									_type = 'text',
									x = -48,
									limit = 96,
									align = 'center',
									text = char.name or 'Unknown'
								}
							}
						} }
					}
				end
				data.chardata:add(char)
				if entry.id then
					data.objectdata:addById(char, entry.id, true)
				end
			else
				log:error('%s not found', path)
			end
coroutine.yield()
		end
	end
	log:info 'Loading objects...'
coroutine.yield()
	if cfg.objects then
		for i = 1, #cfg.objects do
			local entry = cfg.objects[i]
			local path = entry.file or entry[1]
			log:info('Loading: %s', path)
			local obj = Parser:parseFile(path)
			if obj then
				obj._lf2 = true
				obj._lf2_type = entry.type or obj._lf2_type
				obj.lf2id = entry.id or obj.lf2id
				if entry.id then
					data.objectdata:addById(obj, entry.id, true)
				else
					data.objectdata:add(obj)
				end
			else
				log:error('%s not found', path)
			end
coroutine.yield()
		end
	end
	log:info 'Loading backgrounds...'
coroutine.yield()
	if cfg.backgrounds then
		for i = 1, #cfg.backgrounds do
			local path = cfg.backgrounds[i].file or cfg.backgrounds[i][1]
			log:info('Loading: %s', path)
			local bg = Parser:parseFile(path)
			if bg then
				bg = helper.copyTable(RoomData.map, bg)
				if bg.layers then
					bg.nodes = bg.nodes or { }
					for j = 1, #bg.layers do
						local layer = bg.layers[j]
						bg.nodes[#bg.nodes + 1] = {
							[1] = ('LAYER_%d'):format(j),
							_type = 'image',
							x = layer.x,
							y = layer.y,
							hparallax = layer.width / bg.width,
							sprites = { {layer[1]} },
						}
					end
					bg.layers = nil
				end
				if bg.zboundary then
					bg.borders.z1 = bg.zboundary[1]
					bg.borders.z2 = bg.zboundary[2]
					bg.zboundary = nil
				end
				if bg.width then
					bg.borders.x2 = bg.width
				end
				data.bgdata:add(bg)
			else
				log:error('%s not found', path)
			end
coroutine.yield()
		end
	end
end

Room, RoomData = data.layout('layout/loading.dat')

	Room.loader = Room.R.LOADER()
	data.chardata = Storage()
	data.bgdata = Storage()
	data.objectdata = Storage()

	function Room:enter()
		log:debug 'Room: LOADING'
		data.loaded = false
		if cfg.debug and not log.file then
			core.api.io.mkdir('logs')
			log.file = string.format('%s/%s.txt', core.savepath('logs'), os.date('%Y%m%d-%H%M%S'))
		end
		loader = coroutine.create(loading)
		self.loader.data.hidden = false
	end

	function Room:update()
		if coroutine.status(loader) == 'dead' then
			if not data.loaded then
				log:success 'All data loaded!'
				self.loader.data.hidden = true
				data.loaded = true
			end
			if data.replay and data.replay.pending then
				data.tryOpenReplay()
				return
			elseif data.test and data.test.active then
				SceneManager:set(data.test.mode == 'flf' and 'flf_unit' or 'test')
			else
				SceneManager:set('menu')
			end
		elseif not coroutine.resume(loader) then
			log:crit 'Loading failed'
			SceneManager:pop()
		end
	end

return Room
