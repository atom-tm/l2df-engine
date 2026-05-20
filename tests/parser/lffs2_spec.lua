require 'spec_helper'

local LffsParser = l2df.import 'class.parser.lffs2'

describe('class.parser.lffs2', function()
	it('parses scalars, typed array items, and blocks', function()
		local parser = LffsParser:new()
		local result = parser:parse [[
			name: "hero"
			hp: 10
			active: true

			<frame:anim>
				id: 1
				keyword: "idle"
			</frame>

			[meta]
				speed: 2.5
			[/meta]
		]]

		assert.are.equal('hero', result.name)
		assert.are.equal(10, result.hp)
		assert.is_true(result.active)
		assert.are.equal(1, #result.frames)
		assert.are.equal('anim', result.frames[1]._type)
		assert.are.equal('idle', result.frames[1].keyword)
		assert.are.equal(2.5, result.meta.speed)
	end)

	it('dumps data that can be parsed back', function()
		local parser = LffsParser:new()
		local dumped = parser:dump({
			name = 'hero',
			stats = {
				hp = 10,
				mp = 5,
			},
			frames = {
				{ id = 1, keyword = 'idle' },
			},
		})
		local parsed = parser:parse(dumped)

		assert.are.equal('hero', parsed.name)
		assert.are.equal(10, parsed.stats.hp)
		assert.are.equal(5, parsed.stats.mp)
		assert.are.equal(1, parsed.frames[1].id)
		assert.are.equal('idle', parsed.frames[1].keyword)
	end)
end)
