require 'spec_helper'

local Class = l2df.import 'class'
local helper = l2df.import 'helper'

describe('helper', function()
	it('calculates stable scalar helpers', function()
		assert.are.equal(907060870, helper.crc32('hello'))
		assert.are.equal('parties', helper.plural('party'))
		assert.are.equal('party', helper.singular('parties'))
		assert.are.equal(1.23, helper.round(1.234, 2))
		assert.are.equal(-1, helper.sign(-12))
		assert.are.equal(10, helper.clamp(42, 0, 10))
	end)

	it('splits and trims strings', function()
		assert.are.same({ 'alpha', 'beta', 'gamma' }, helper.split('alpha beta gamma'))
		assert.are.same({ 'a', 'b', 'c' }, helper.split('a,b,c', ','))
		assert.are.equal('trimmed', helper.trim('  trimmed  '))
	end)

	it('copies plain tables deeply and preserves class instances', function()
		local Token = Class:extend()
		local token = Token:new()
		local source = {
			nested = { value = 3 },
			token = token,
		}

		local copy = helper.copyTable(source)
		copy.nested.value = 8

		assert.are.equal(3, source.nested.value)
		assert.are.equal(8, copy.nested.value)
		assert.is_false(source.nested == copy.nested)
		assert.are.equal(token, copy.token)
	end)
end)
