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
local Behaviour = core.import 'class.component.behaviour'
local Physix = core.import 'class.component.physix'
local Sound = core.import 'class.component.sound'

local dummy = function () return nil end

local UI = Entity:extend()

	function UI:init(kwargs)
		self:addComponent(Transform)
		local data = self.data
		data.x = kwargs.x or data.x
		data.y = kwargs.y or data.y
        data.r = math.rad(kwargs.r or 0)
		data.yorientation = kwargs.yorientation or -1
        data.scalex = kwargs.scalex or 1
        data.scaley = kwargs.scaley or 1
		data.hidden = kwargs.hidden or false
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
		self.data.hidden = true
		return self
	end

	function UI:show()
		self.data.hidden = false
		return self
	end

	function UI:toggle()
		self.data.hidden = not self.data.hidden
		return self
	end

	local function assertUI(var, msg)
		return assert(var and var.isInstanceOf and var:isInstanceOf(UI) and var, msg)
	end


	UI.Text = UI:extend({ name = 'text' })
	function UI.Text:init(kwargs)
		self:super(kwargs)
		self:addComponent(Print, kwargs)
	end


	UI.Image = UI:extend({ name = 'image' })
	function UI.Image:init(kwargs)
		self:super(kwargs)
		self:addComponent(Render, kwargs.sprites, kwargs)
		self.data.pic = kwargs.pic or self.data.pic or 1
	end


	UI.Animation = UI:extend({ name = 'animation' })
	function UI.Animation:init(kwargs)
		self:super(kwargs)
		self:addComponent(Render, kwargs.sprites, kwargs)
		self:addComponent(Frames, kwargs)
	end


	UI.Video = UI:extend({ name = 'video' })
	function UI.Video:init(kwargs)
		self:super(kwargs)
		self:addComponent(Video, kwargs)
	end

	function UI.Video:isPlaying()
		return self:getComponent(Video).isPlaying()
	end

	function UI.Video:play()
		self:getComponent(Video).setState('play')
	end

	function UI.Video:pause()
		self:getComponent(Video).setState('pause')
	end

	function UI.Video:stop()
		self:getComponent(Video).setState('stop')
	end

	function UI.Video:invert()
		self:getComponent(Video).setState('invert')
	end


	UI.Button = UI:extend({ name = 'button' })
	function UI.Button:init(kwargs)
		self:super(kwargs)

		local states = kwargs.states or kwargs.nodes
		states = type(states) == 'table' and states or { }

		local default_state = assertUI(states.normal or states[1], 'Requires a UI type object')
		self.data.states = {
			default_state,
			assertUI(states.focus or states[2] or default_state, 'Requires a UI type object'),
			assertUI(states.hover or states[3] or default_state, 'Requires a UI type object'),
			assertUI(states.click or states[4] or default_state, 'Requires a UI type object'),
			nil,
		}

		self.data.state = 1
		self.data.last_state = 0
		self:attachMultiple(self.data.states)

		self:setAction(kwargs.action or kwargs[2])

		self.data.cooldown = 0
		self.data.max_cooldown = kwargs.cooldown or 0

		self:addComponent(Sound, kwargs.sounds)
		self:addComponent(Behaviour, function ()
			if self.data.state ~= self.data.last_state then
				if self.data.last_state == 1 and self.data.state == 2 then
					self.data.sound = 'focus'
					self:change()
				elseif self.data.last_state == 1 and self.data.state == 3 then
					self.data.sound = 'hover'
					self:change()
				end
				self.data.last_state = self.data.state
				self:detachAll()
				self:attach(self.data.states[self.data.state])
			end
			self.data.state = self.data.cooldown == 0 and 1 or self.data.state
			self.data.cooldown = self.data.cooldown > 0 and self.data.cooldown - 1 or self.data.cooldown
		end)
	end

	function UI.Button:setAction(func)
		self.data.action = type(func) == 'function' and func or dummy
	end

	function UI.Button:change()
		self.data.sound = 'change'
	end

	function UI.Button:focus()
		self.data.state = self.data.state < 2 and 2 or self.data.state
	end

	function UI.Button:hover()
		self.data.state = self.data.state < 3 and 3 or self.data.state
	end

	function UI.Button:click()
		if self.data.state == 4 then return end
		self.data.state = 4
		self.data.action(self)
		self.data.cooldown = self.data.max_cooldown
		self.data.sound = 'click'
	end


	UI.Menu = UI:extend({ name = 'menu' })
	function UI.Menu:init(kwargs, list)
		self:super(kwargs)
		self.selected = 1
		self:attachMultiple(kwargs.nodes or list)
		self:addComponent(Sound, kwargs.sounds)
		self:addComponent(Behaviour, function ()
			local list = self:getNodes()
			list[self.selected]:focus()
		end)
	end

	function UI.Menu:next()
		self.selected = self.selected == self.nodes.count and 1 or self.selected + 1
		self:change()
		self.data.sound = 'next'
	end

	function UI.Menu:prev()
		self.selected = self.selected == 1 and self.nodes.count or self.selected - 1
		self:change()
		self.data.sound = 'prev'
	end

	function UI.Menu:change()
		self.data.sound = 'change'
	end

	function UI.Menu:choice()
		local list = self:getNodes()
		local action = list[self.selected].click
		local _ = type(action) == 'function' and action(list[self.selected])
		self.data.sound = 'choice'
	end

return setmetatable({ UI.Text, UI.Image, UI.Animation, UI.Video, UI.Button, UI.Menu }, { __index = UI })
