local ai = { }

	function ai:processing()
		if self.ai and self.head.ai then
			for key in pairs(settings.controls[1]) do
				if self.key_pressed[key] > 0 then
					self.key_pressed[key] = self.key_pressed[key] - 1
				end
				if self.key_timer[key] > 0 then
					self.key_timer[key] = self.key_timer[key] - 1
				end
				if self.double_key_timer[key] > 0 then
					self.double_key_timer[key] = self.double_key_timer[key] - 1
				elseif self.double_key_timer[key] < 0 then
					self.double_key_timer[key] = self.double_key_timer[key] + 1
				end
			end
			self.head.ai:update(self)
		end
	end

return ai