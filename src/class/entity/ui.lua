--- UI entities module
-- @classmod l2df.class.entity.ui
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local utf8 = require 'utf8'
local helper = core.import 'helper'
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

local min = math.min
local strtrim = helper.trim
local strsub = string.sub

local dummy = function () return nil end
local selectButtons = function (node) return node.name == 'button' end

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
		self:addComponent(Render, kwargs)
		self.data.pic = kwargs.pic or self.data.pic or 1
	end


	UI.Animation = UI:extend({ name = 'animation' })
	function UI.Animation:init(kwargs)
		self:super(kwargs)
		self:addComponent(Frames, kwargs)
		self:addComponent(Render, kwargs)
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


	UI.Input = UI.Text:extend({ name = 'input' })
	function UI.Input:init(kwargs)
		self:super(kwargs)
		self.trim = not not kwargs.trim
		self.maxlen = kwargs.maxlength or Print:data(self).limit or 256
	end

	function UI.Input:getText()
		return Print:data(self).text
	end

	function UI.Input:append(text)
		local data = Print:data(self)
		text = data.text .. text
		if self.trim then
			text = strtrim(text)
		end
		if #text <= self.maxlen then
			data.text = text
		end
		return #data.text
	end

	function UI.Input:erase(count)
		local data = Print:data(self)
		local byteoffset = utf8.offset(data.text, -(count or 1)) or 1
		data.text = strsub(data.text, 1, byteoffset - 1)
		return #data.text
	end

	function UI.Input:length()
		local data = Print:data(self)
		return #data.text
	end


	UI.Group = UI:extend({ name = 'group' })
	function UI.Group:init(kwargs)
		self:super(kwargs)
		self:attachMultiple(kwargs.nodes)
		self:addComponent(Render, kwargs)
	end


	UI.Menu = UI.Group:extend({ name = 'menu' })
	function UI.Menu:init(kwargs)
		self:super(kwargs)
		self.selected = 1
		self.buttons = { }
		self:addComponent(Sound, kwargs.sounds)
		self:addComponent(Behaviour, function ()
			self.buttons = self:getNodes(selectButtons)
			self.selected = min(self.selected, #self.buttons)
			local _ = self.selected > 0 and self.buttons[self.selected]:focus()
		end)
	end

	function UI.Menu:select(index)
		self.selected = (index - 1) % #self.buttons + 1
	end

	function UI.Menu:next()
		self.selected = self.selected == #self.buttons and 1 or self.selected + 1
		self.data.sound = 'next'
	end

	function UI.Menu:prev()
		self.selected = self.selected == 1 and #self.buttons or self.selected - 1
		self.data.sound = 'prev'
	end

	function UI.Menu:current()
		return self.buttons[self.selected] or { }
	end

	function UI.Menu:choice(...)
		local button = self:current()
		local action = button.click
		local _ = type(action) == 'function' and action(button, ...)
		self.data.sound = 'choice'
	end

return setmetatable({ UI.Text, UI.Image, UI.Animation, UI.Video, UI.Input, UI.Button, UI.Group, UI.Menu }, { __index = UI })