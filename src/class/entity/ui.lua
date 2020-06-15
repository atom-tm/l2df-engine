--- UI entities module
-- @classmod l2df.class.entity.ui
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'class.entity'
local Render = core.import 'class.component.render'
local Frames = core.import 'class.component.frames'
local States = core.import 'class.component.states'
local Print = core.import 'class.component.print'
local Video = core.import 'class.component.video'
local Transform = core.import 'class.component.transform'
local Physix = core.import 'class.component.physix'
local Script = core.import 'class.component.script'
local Sound = core.import 'class.component.sound'

local dummy = function () return nil end

local UI = Entity:extend()

	function UI:init(kwargs)
		self:addComponent(Transform())
		local vars = self.vars
		vars.x = kwargs.x or vars.x
		vars.y = kwargs.y or vars.y
		vars.hidden = kwargs.hidden
	end

	function UI:on(event, callback)
		assert(type(event) == "string", "Event name must be string")
		assert(type(callback) == "function", "Callback must be a function")
		if type(self[event]) == "function" then
			local old = self[event]
			self[event] = function (...)
				old(...)
				callback(...)
			end
		end
		return self
	end

	function UI:hide()
		self.vars.hidden = true
		return self
	end

	function UI:show()
		self.vars.hidden = false
		return self
	end

	function UI:toggle()
		self.vars.hidden = not self.vars.hidden
		return self
	end

	local function assertUI(var, msg)
		return assert(var and var.isInstanceOf and var:isInstanceOf(UI) and var, msg)
	end


	UI.Text = UI:extend({ name = 'text' })
	function UI.Text:init(kwargs)
		self:super(kwargs)
		self:addComponent(Print(), kwargs)
	end


	UI.Image = UI:extend({ name = 'image' })
	function UI.Image:init(kwargs)
		self:super(kwargs)
		self:addComponent(Render(), kwargs.sprites, kwargs)
		self.vars.pic = kwargs.pic or self.vars.pic or 1
	end


	UI.Animation = UI:extend({ name = 'animation' })
	function UI.Animation:init(kwargs)
		self:super(kwargs)
		self:addComponent(Render(), kwargs.sprites, kwargs)
		self:addComponent(Frames(), 1, kwargs.frames, kwargs)
	end


	UI.Video = UI:extend({ name = 'video' })
	function UI.Video:init(kwargs)
		self:super(kwargs)
		self:addComponent(Video(), kwargs)
	end

	function UI.Video:play()
		self:getComponent(Video):setState('play')
	end

	function UI.Video:pause()
		self:getComponent(Video):setState('pause')
	end

	function UI.Video:stop()
		self:getComponent(Video):setState('stop')
	end

	function UI.Video:invert()
		self:getComponent(Video):setState('invert')
	end


	UI.Button = UI:extend({ name = 'button' })
	function UI.Button:init(kwargs)
		self:super(kwargs)

		local states = kwargs.states or kwargs.nodes
		states = type(states) == 'table' and states or { }

		local default_state = assertUI(states.normal or states[1], 'Requires a UI type object')
		self.vars.states = {
			default_state,
			assertUI(states.focus or states[2] or default_state, 'Requires a UI type object'),
			assertUI(states.hover or states[3] or default_state, 'Requires a UI type object'),
			assertUI(states.click or states[4] or default_state, 'Requires a UI type object'),
		}

		self.vars.state = 1
		self.vars.last_state = 1
		self:attach(self.vars.states[1])

		self:setAction(kwargs.action or kwargs[2])

		self.vars.cooldown = 0
		self.vars.max_cooldown = kwargs.cooldown or 0

		self:addComponent(Sound(), kwargs.sounds)
		self:addComponent(Script(), function ()
			if self.vars.state ~= self.vars.last_state then
				if self.vars.last_state == 1 and self.vars.state == 2 then
					self.vars.sound = 'focus'
					self:change()
				elseif self.vars.last_state == 1 and self.vars.state == 3 then
					self.vars.sound = 'hover'
					self:change()
				end
				self.vars.last_state = self.vars.state
				self:detachAll()
				self:attach(self.vars.states[self.vars.state])
			end
			self.vars.state = self.vars.cooldown == 0 and 1 or self.vars.state
			self.vars.cooldown = self.vars.cooldown > 0 and self.vars.cooldown - 1 or self.vars.cooldown
		end)
	end

	function UI.Button:setAction(func)
		self.vars.action = type(func) == 'function' and func or dummy
	end

	function UI.Button:change()
		self.vars.sound = 'change'
	end

	function UI.Button:focus()
		self.vars.state = self.vars.state < 2 and 2 or self.vars.state
	end

	function UI.Button:hover()
		self.vars.state = self.vars.state < 3 and 3 or self.vars.state
	end

	function UI.Button:click()
		if self.vars.state == 4 then return end
		self.vars.state = 4
		self.vars.action(self)
		self.vars.cooldown = self.vars.max_cooldown
		self.vars.sound = 'click'
	end


	UI.Menu = UI:extend({ name = 'menu' })
	function UI.Menu:init(kwargs, list)
		self:super(kwargs)
		self.selected = 1
		self:attachMultiple(kwargs.nodes or list)
		self:addComponent(Sound(), kwargs.sounds)
		self:addComponent(Script(), function ()
			local list = self:getNodes()
			list[self.selected]:focus()
		end)
	end

	function UI.Menu:next()
		self.selected = self.selected == self.nodes.count and 1 or self.selected + 1
		self:change()
		self.vars.sound = 'next'
	end

	function UI.Menu:prev()
		self.selected = self.selected == 1 and self.nodes.count or self.selected - 1
		self:change()
		self.vars.sound = 'prev'
	end

	function UI.Menu:change()
		self.vars.sound = 'change'
	end

	function UI.Menu:choice()
		local list = self:getNodes()
		list[self.selected]:click()
		self.vars.sound = 'choice'
	end

return setmetatable({ UI.Text, UI.Image, UI.Animation, UI.Video, UI.Button, UI.Menu }, { __index = UI })
