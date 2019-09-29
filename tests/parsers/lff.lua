local scene1 = parser:parse [[
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

local scene2 = Scene(parser:parse [[
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
		sprites: "sprites/UI/logotype.png"
		x: 100 y: 80
		scalex: 0.5
		scaley: 0.55
	</image>
	additional: data
]])

local scene3 = (parser:parse [[
	nani: dadada
	x: 0 y: 23
	<scene>
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

local empty = parser:parse('')