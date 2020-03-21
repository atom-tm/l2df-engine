local ui
		ui = UI.Animation({{ "sprites/UI/loading.png", 4, 3, 140, 140 }}, 55, 25, {
			{ pic = 1, id = 1, next = 2, wait = 30 },
			{ pic = 2, id = 2, next = 3, wait = 30 },
			{ pic = 3, id = 3, next = 4, wait = 30 },
			{ pic = 4, id = 4, next = 5, wait = 30 },
			{ pic = 5, id = 5, next = 6, wait = 30 },
			{ pic = 6, id = 6, next = 7, wait = 30 },
			{ pic = 7, id = 7, next = 8, wait = 30 },
			{ pic = 8, id = 8, next = 9, wait = 30 },
			{ pic = 9, id = 9, next = 10, wait = 30 },
			{ pic = 10, id = 10, next = 11, wait = 30 },
			{ pic = 11, id = 11, next = 12, wait = 30 },
			{ pic = 12, id = 12, next = 1, wait = 30, states = {} },
		})
		ui:addComponent(Text("Hello world", ResourseManager:load('fonts/main_menu.otf'), { color = {189,218,87} }))
		ui.vars.persistentStates[1] = { 229, { speed = 0.15 }}

		local eeeee = Entity()
		eeeee:attach(ui)


local button_test = UI.Button {
	states = {
		normal = UI.Image {
			sprites = { 'sprites/test/knopka.png', 68, 35, 1, 3 },
			pic = 1,
		},
		click =  UI.Image {
			sprites = { 'sprites/test/knopka.png', 68, 35, 1, 3 },
			pic = 2
		}
	},
	action = function ()
		print("Hello!")
	end,
	x = 100, y = 100, cooldown = 15
}