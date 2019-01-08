local localization = {}

	localization.list = {
		"data.english",
		"data.russian",
	}

	localization.id = nil
	localization.text = nil

	function localization:Set(id)
		self.text = require(self.list[id])
		locale = self.text
		localization.id = id
	end

return localization