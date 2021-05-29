--- Scene entity. Inherited from @{l2df.class.entity|l2df.class.Entity} class.
-- @classmod l2df.class.entity.scene
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'class.entity'
local Storage = core.import 'class.storage'
local Renderer = core.import 'manager.render'

local Scene = Entity:extend({ name = 'scene' })

	--- Optional callback triggered by @{l2df.manager.scene.set|SceneManager}.
	-- @field[opt] function Scene.enable

	--- Optional callback triggered by @{l2df.manager.scene.set|SceneManager}.
	-- @field[opt] function Scene.disable

	--- Optional callback triggered by @{l2df.manager.scene.set|SceneManager}.
	-- @field[opt] function Scene.enter

	--- Optional callback triggered by @{l2df.manager.scene.set|SceneManager}.
	-- @field[opt] function Scene.leave

	--- Scene initialization.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt=false] boolean kwargs.active  Initial scene active state.
	-- @param[opt] table kwargs.nodes  Array of the @{l2df.class.entity|entities}.
	-- @param[opt] table kwargs.layers  Array of the @{l2df.manager.render.addLayer|layers} in format:
	-- <pre>{ { "name", kwargs }, ... }</pre>.
	function Scene:init(kwargs)
		kwargs = kwargs or { }
		local layers = kwargs.layers or { }
		for i = 1, #layers do
			Renderer:addLayer(layers[i][1], layers[i])
		end
		self.active = not not kwargs.active
		self.nodes = Storage:new()
		self:attachMultiple(kwargs.nodes)
	end

return Scene