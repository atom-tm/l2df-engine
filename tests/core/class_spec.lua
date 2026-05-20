require 'spec_helper'

local Class = l2df.import 'class'

describe('class', function()
	it('constructs subclasses and calls parent initializers', function()
		local Base = Class:extend({
			init = function(self, name)
				self.name = name
			end,
			label = function(self)
				return 'base:' .. self.name
			end,
		})

		local Child = Base:extend({
			init = function(self, name, power)
				self:super(name)
				self.power = power
			end,
			label = function(self)
				return self.super.label(self) .. ':' .. self.power
			end,
		})

		local obj = Child('hero', 7)

		assert.are.equal('hero', obj.name)
		assert.are.equal(7, obj.power)
		assert.are.equal('base:hero:7', obj:label())
		assert.is_true(obj:isTypeOf(Child))
		assert.is_false(obj:isTypeOf(Base))
		assert.is_true(obj:isInstanceOf(Child))
		assert.is_true(obj:isInstanceOf(Base))
		assert.is_true(Child:isInstanceOf(Base))
	end)

	it('extends classes using callback customizers', function()
		local Named = Class:extend(function(cls)
			function cls:init(name)
				self.name = name
			end

			function cls:rename(name)
				self.name = name
				return self
			end
		end)

		local item = Named:new('first'):rename('second')

		assert.are.equal('second', item.name)
		assert.is_true(item:isInstanceOf(Named))
	end)
end)
