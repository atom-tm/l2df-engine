local src = love.filesystem.getSource()
package.path = ('%s;%s/libs/?.lua;%s/libs/?/init.lua'):format(package.path, src, src)
-- love.filesystem.setRequirePath('libs/?.lua;libs/?/init.lua;?.lua;?/init.lua')

l2df = require 'l2df'
local lurker = require 'lurker'

local lag = 0
local roomData
local strformat = string.format

local config = l2df.import 'config'
local parser = l2df.import 'class.parser.lffs2'

local Factory = l2df.import 'manager.factory'
local SceneManager = l2df.import 'manager.scene'
local KindsManager = l2df.import 'manager.kinds'
local StatesManager = l2df.import 'manager.states'
local InputManager = l2df.import 'manager.input'
local SnapshotManager = l2df.import 'manager.snapshot'
local RenderManager = l2df.import 'manager.render'
local SoundManager = l2df.import 'manager.sound'

function love.run()
	return l2df:gameloop()
end

function love.load()
	l2df:init()

	RenderManager:init()
	SoundManager:init()
	SnapshotManager:init(30)
	InputManager:init(config.keys)
	InputManager:updateMappings({
		{
			up = 'w', down = 's', left = 'a', right = 'd',
			attack = 'f', jump = 'g', defend = 'h',
			special1 = 'j'
		}
	})

	StatesManager:load('data/states')
	KindsManager:load('data/kinds')

	local sceneData = parser:parse(roomData)
	local scene = Factory:create('scene', sceneData)
	SceneManager:add(scene, 'new_syntax_room')
	SceneManager:load('scenes/')
	SceneManager:push('myroom')
end

function love.update(dt)
	lurker.update()
	love.window.setTitle(strformat('FPS: %s(%s). Lag: %s', love.timer.getFPS(), dt, lag))
	if lag > 0 then
		love.timer.sleep(lag)
	end
end

function love.keypressed(key)
	if key == 'f11' then
		lag = lag + 0.001
	elseif key == 'f12' then
		lag = lag - 0.001
	elseif key == 'f10' then
		lag = 0
		love.timer.sleep(1)
	end
end

roomData = [[
music: "/res/bg.mp3"

<node:animation> LOGOTYPE x: 200  y: 16
	<sprite> "sprites/UI/loading.png" x: 4 y: 3  w: 140 h: 140 </sprite>

	<node:frame> 1 load1  pic: 1 wait: 45 next: 2 </frame>
	<node:frame> 2 load2  pic: 2 wait: 45 next: 3 </frame>
	<node:frame> 3 load3  pic: 3 wait: 45 next: 4 </frame>
	<node:frame> 4 load4  pic: 4 wait: 45 next: 5 </frame>
	<node:frame> 5 load5  pic: 5 wait: 45 next: 6 </frame>
	<node:frame> 6 load6  pic: 6 wait: 45 next: 7 </frame>
	<node:frame> 7 load7  pic: 7 wait: 45 next: 8 </frame>
	<node:frame> 8 load8  pic: 8 wait: 45 next: 9 </frame>
	<node:frame> 9 load9  pic: 9 wait: 45 next: 10 </frame>
	<node:frame> 10 load10  pic: 10 wait: 45 next: 11 </frame>
	<node:frame> 11 load11  pic: 11 wait: 45 next: 12 </frame>
	<node:frame> 12 load12  pic: 12 wait: 45 next: 1 </frame>
</animation>

<node:button> GAME_START x: 50  y: 100
	<bdy> kind: UI  x: 0  y: 0  w: 250  h: 150 </bdy>

	<node:image> BACKGROUND
		<sprite> "sprites/test/test_menu.png" x: 1 y: 6  w: 80 h: 30 </sprite>
		pic: 2  x: 0  y: 0
	</image>
	<node:text>
		x: 0  y: 0  text: "GAME_START"  locale: true
	</text>
</button>

<node:button> RECORDS x: 50  y: 150
	<bdy> kind: UI  x: 0  y: 0  w: 250  h: 150 </bdy>

	<node:image> BACKGROUND
		<sprite> "sprites/test/test_menu.png" x: 1 y: 6  w: 80 h: 30 </sprite>
		pic: 4  x: 0  y: 0
	</image>
	<node:text>
		x: 0  y: 0  text: "RECORDS"  locale: true
	</text>
</button>

<node:button> EXIT x: 50  y: 200
	<bdy> kind: UI  x: 0  y: 0  w: 250  h: 150 </bdy>

	<node:image> BACKGROUND
		<sprite> "sprites/test/test_menu.png" x: 1 y: 6  w: 80 h: 30 </sprite>
		pic: 6  x: 0  y: 0
	</image>
	<node:text>
		x: 0  y: 0  text: "EXIT"  locale: true
	</text>
</button>
]]