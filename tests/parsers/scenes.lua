local scene1 = Scene {
			nodes = {
				UI.Text {
					text = 'Hello world',
					font = love.graphics.newFont(25),
					x = 10,
					y = 15
				},
				UI.Text {
					text = 'Minecraft is my life!',
					font = love.graphics.newFont(18),
					x = 55,
					y = 55,
				},
				UI.Image {
					sprites = {{ res = 'sprites/UI/logotype.png', x = 2, y = 2, w = 250, h = 250 }},
					x = 100,
					y = 80,
					pic = 2,
					scalex = 0.5,
					scaley = 0.55
				}
			}
		}

		local scene2 = parser:parse [[
			<scene>
				<text>
					text: "Hello world"
					font: 25 x: 10 y: 15
				</text>
				<text>
					text: "Minecraft is my life!"
					font: 18 x: 55 y: 55
				</text>
				<image>
					sprites: "sprites/UI/logotype.png"
					x: 100 y: 80
					scalex: 0.5
					scaley: 0.55
				</image>
			</scene>
		]]

		local scene3 = Scene(parser:parse [[
			param: test
			param2: test2
			param3: okay
			test: piss-off

			<text>
				text: "Hello world"
				font: 25 x: 10 y: 15
			</text>
			<text>
				text: "Minecraft is my life!"
				font: 18 x: 55 y: 55
			</text>
			<image>
				sprites: [{ res: "sprites/UI/logotype.png" x: 2 y: 2 w: 250 h: 250 }]
				x: 100 y: 80
				pic: 1
				scalex: 0.5
				scaley: 0.55
			</image>
			additional: data
		]])

		local scene4 = (parser:parse [[
			nani: dadada
			x: 0 y: 23
			<scene>
				param: test
				param2: test2
				param3: okay
				test: piss-off
				x: 150

				<text>
					text: "Hello world"
					font: 25 x: 10 y: 15
				</text>
				<text>
					text: "Minecraft is my life!"
					font: 18 x: 55 y: 55
				</text>
				<image>
					sprites: "sprites/UI/logotype.png"
					x: 100 y: 80
					scalex: 0.5
					scaley: 0.55
				</image>
				additional: data
			</scene>
			test: "what should i do?"
			garbage
		]]).nodes[1]

		--print(helper.dump(scene4))
		--print(scene4.param3)

		local empty = parser:parse('')

		SceneManager:add(scene1, 'scene1')
		SceneManager:add(scene2, 'scene2')
		SceneManager:add(scene3, 'scene3')
		SceneManager:add(scene4, 'scene4')

		SceneManager:set('scene1')
		SceneManager:set('scene2')
		SceneManager:set('scene3')
		--SceneManager:set('scene4')