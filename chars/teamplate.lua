local template = {
	name = "teamplate",
	hp = 500,
	mp = 250,
	sprites = {
		{
		 	list = love.graphics.newImage("sprites/natsu.png"),
		 	border = true,
		 	x = 10,
		 	y = 14,
		 	w = 80,
		 	h = 80,
		 	frames = {}
	 	}
	},
	frame = {}
}


template.frame[1] = {
	pic = 1, wait = 7, next = 2, centerx = 18, centery = 78,
	colls = {
		{
			x = 0,
			y = 0,
			w = 10,
			h = 10,
			type = "body"
		}
	}
}

template.frame[2] = {
	pic = 2, wait = 7, next = 3, centerx = 18, centery = 78,
	colls = {
		{
			x = 0,
			y = 0,
			w = 10,
			h = 10,
			type = "body"
		}
	}
}

template.frame[3] = {
	pic = 3, wait = 7, next = 4, centerx = 18, centery = 78,
	colls = {
		{
			x = 0,
			y = 0,
			w = 10,
			h = 10,
			type = "body"
		}
	}
}

template.frame[4] = {
	pic = 4, wait = 7, next = 1, centerx = 18, centery = 78,
	colls = {
		{
			x = 0,
			y = 0,
			w = 10,
			h = 10,
			type = "body"
		}
	}
}


return template