local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local utf8 = require 'utf8'
local cfg = core.import 'config'

-- COMPONENTS
local States = core.import 'class.component.states'
local Collision = core.import 'class.component.collision'

-- MANAGERS
local SceneManager = core.import 'manager.scene'
local Input = core.import 'manager.input'

-- VARIABLES
local function dummyFunc() end
local function enableNode(self) self.node.active = true end
local function disableNode(self) self.node.active = false end
local function defaultAction(self, action, ...) (self.node[action] or dummyFunc)(self.node, ...) end

local Room = data.layout('layout/menu/main.dat')

	local scenes = {
		controls_menu = data.layout('layout/menu/controls.dat'),
		game_menu = data.layout('layout/menu/game.dat')
	}
	for name, scene in pairs(scenes) do
		SceneManager:add(scene, name)
	end

	local function randomBackground()
		Room.R.BG_IMAGE.data.pic = math.random(1, 13)
	end

	local function wrapButton(btn)
		if btn.name ~= 'button' then return end
		btn.nodes:first():addComponent(Collision)
		btn:onChange(function (btn)
			if btn.data.state == 1 then
				btn.nodes:first().C.frames.set('idle')
			elseif btn.data.state == 2 or btn.data.state == 3 then
				btn.nodes:first().C.frames.set('hover')
			elseif btn.data.state == 4 then
				btn.nodes:first().C.frames.set('click')
			end
		end)
	end

	-- BUTTON BINDINGS
	local Menu = Room.R.MAINMENU()
	local GMenu = scenes.game_menu
	local Controls = scenes.controls_menu
	Menu.R.BTN_GAME_START:onClick(function () SceneManager:push('game_menu') end)
	Menu.R.BTN_CONTROL_SETTINGS:onClick(function () SceneManager:push('controls_menu') end)
	Controls.R.CONTROLS.BTN_CANCEL:onClick(function () SceneManager:pop() end)
	GMenu.R.MENU.BTN_VS_MODE:onClick(function () SceneManager:push('lobby') end)
	GMenu.R.MENU.BTN_QUIT:onClick(love.event.quit)

	for _, btn in Menu.nodes:enum(true) do
		wrapButton(btn)
	end
	for _, btn in GMenu.R.MENU.nodes:enum(true) do
		wrapButton(btn)
	end
	for _, btn in Controls.R.CONTROLS.nodes:enum(true) do
		wrapButton(btn)
	end

	-- RANDOMIZE BG
	Room.enter = randomBackground
	
	function Room:enable()
		randomBackground()
		Menu.active = true
	end

	function Room:disable()
		Menu.active = false
	end

	function GMenu:enable()
		Room.active = true
		self.active = true
	end

	function GMenu:disable()
		Room.active = false
		self.active = false
	end

	function GMenu:update()
		if SceneManager:current() ~= self then return end
		if Input:consume('up') then
			GMenu.R.MENU:prev()
		end
		if Input:consume('down') then
			GMenu.R.MENU:next()
		end
		if Input:consume('attack') or Input:consume('select') then
			GMenu.R.MENU:choice()
		end
		-- if Input:consume('jump') and self.SM.data().size > 1 and not self.SM.has(Username) then
		-- 	self.SM.pop()
		-- end
	end

	function Controls:enter()
		Room.R.LOGOTYPE.data.y = 35
	end

	function Controls:leave()
		Room.R.LOGOTYPE.data.y = 95
	end

	function Controls:update()
		if SceneManager:current() ~= self then return end
	end

return Room