local battle = {}

battle.bar_shader = love.graphics.newShader[[
extern number barWidth;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texturecolor = Texel(texture, texture_coords);
    vec4 result = texturecolor * color;
    if (texture_coords.x > barWidth * 0.001) {
    	return vec4(0,0,0,0);
    }
    return result;
}]]

battle.graphic = require("libs.battle.graphic")
battle.entities = require("libs.battle.entities")
battle.control = require("libs.battle.control")
battle.physix = require("libs.battle.physix")
battle.collision = require("libs.battle.collision")

battle.entities_list = {}
battle.map = {}

function battle:setMap(map)
	self.map = map
	self.graphic:cameraCreate()
end

function battle:createStartingObjects(list)
	for key in pairs(list) do
		local id = list[key].id
		local spawn_point = self.map.spawn_points[math.random(1, #self.map.spawn_points)]
		local x = spawn_point.x + math.random(-spawn_point.rx, spawn_point.rx)
		local y = spawn_point.y + math.random(-spawn_point.ry, spawn_point.ry)
		local z = spawn_point.z + math.random(-spawn_point.rz, spawn_point.rz)
		local object = self.entities.spawnObject(id,x,y,z,nil,"standing",nil)
		if object ~= nil then
			object.controller = list[key].controller
			object:setController()
		end
	end
end

function battle:Load(spawnList)

	self.control_visuals = {
		up = {
			pressed = image.Load("sprites/UI/Keys/up.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/up0.png", nil, "linear"),
			x = 32, y = 0
		},
		down = {
			pressed = image.Load("sprites/UI/Keys/down.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/down0.png", nil, "linear"),
			x = 32, y = 34
		},
		left = {
			pressed = image.Load("sprites/UI/Keys/left.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/left0.png", nil, "linear"),
			x = 9, y = 17
		},
		right = {
			pressed = image.Load("sprites/UI/Keys/right.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/right0.png", nil, "linear"),
			x = 56, y = 17
		},
		attack = {
			pressed = image.Load("sprites/UI/Keys/attack.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/attack0.png", nil, "linear"),
			x = 96, y = 16
		},
		jump = {
			pressed = image.Load("sprites/UI/Keys/jump.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/jump0.png", nil, "linear"),
			x = 128, y = 16
		},
		defend = {
			pressed = image.Load("sprites/UI/Keys/defence.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/defence0.png", nil, "linear"),
			x = 160, y = 16
		},
		special1 = {
			pressed = image.Load("sprites/UI/Keys/special.png", nil, "linear"),
			normal = image.Load("sprites/UI/Keys/special0.png", nil, "linear"),
			x = 192, y = 16
		},
	}

	self.bars = {
		hp = image.Load("sprites/UI/heal_strip.png", nil, "linear"),
		mp = image.Load("sprites/UI/mana_strip.png", nil, "linear"),
		sp = image.Load("sprites/UI/special_strip.png", nil, "linear")
	}

	self.hp_bar = image.Load("sprites/UI/hp_bar.png", nil, "linear")
	self.hp_bar_back = image.Load("sprites/UI/hp_bar_back.png", nil, "linear")
	for i in pairs(self.entities.list) do
		for j in pairs(self.entities.list[i]) do
			self.entities.list[i][j] = nil
		end
	end
	self.entities.list = nil
	self.entities.list = {}
	self.map = {}
	self.control.players = {}
	collectgarbage()
	self:setMap(resourses.maps[spawnList.maps[1]])
	self:createStartingObjects(spawnList.entities)
end




function battle:Update()
	self.graphic:cameraUpdate()
	self.collision.checkCollisions()
	for i in pairs(self.entities.list) do
		local object = self.entities.list[i]
		object:countersProcessing()
		object:keysCheck()
		object:frameProcessing()
		object:statesUpdate()
		object:statesProcessing()
		object:opointsProcessing()
		if object.destroy then
			self.entities.removeObjects(object)
		else
			object:applyMotions()
			object:applyGravity()
			object:findCollaiders()
			object:addToDrawing()
		end
	end
end



function battle:DrawGame()
	self.graphic.camera:draw(function(l,t,w,h)
		self.graphic.backgroundDraw()
		self.graphic.objectsDraw()
		self.graphic.foregroundDraw()
	end)
end


function battle:DrawInterface()
	camera:draw(function(l,t,w,h)
		font.print(#self.collision.list.itr, 10, 10)
		font.print(#self.collision.list.body, 10, 30)
		font.print(self.entities.list[1].vel_x, 10, 70)
		font.print(self.entities.list[1].frame.number, 10, 90)
		font.print(self.entities.list[1].vel_y, 10, 110)
		font.print(self.entities.list[1].y, 10, 130)
		font.print(self.entities.list[1].grounded, 10, 150)
		font.print(self.entities.list[1].wait, 10, 170)
		font.print(tostring(settings.quality), 10, 190)
		

		if self.control.players[1] ~= nil then
			image.draw(self.hp_bar_back,nil,0,0)
			image.draw(self.hp_bar,nil,0,0)
			local width = 300
			battle.bar_shader:send("barWidth",150)
			love.graphics.setShader(battle.bar_shader)
				image.draw(self.bars.hp,0,300,300)
			love.graphics.setShader()
		end
		if self.control.players[1] ~= nil then
			for key, val in pairs(self.control.players[1].key_pressed) do
				if val == 1 then
					image.draw(self.control_visuals[key].pressed, 0, 5 + self.control_visuals[key].x, 640 + self.control_visuals[key].y)
				else
					image.draw(self.control_visuals[key].normal, 0, 5 + self.control_visuals[key].x, 640 + self.control_visuals[key].y)
				end
			end

			local width = self.control.players[1].head.hp * 0.01


		end
		if self.control.players[2] ~= nil then
			for key, val in pairs(self.control.players[2].key_pressed) do
				if val == 1 then
					image.draw(self.control_visuals[key].pressed, 0, 1040 + self.control_visuals[key].x, 640 + self.control_visuals[key].y)
				else
					image.draw(self.control_visuals[key].normal, 0, 1040 + self.control_visuals[key].x, 640 + self.control_visuals[key].y)
				end
			end
		end


		if self.control.players[2] ~= nil and self.control.players[1] == nil then
			image.draw(self.hp_bar_back,nil,0,0)
			image.draw(self.hp_bar,nil,0,0)
		elseif self.control.players[2] ~= nil and self.control.players[1] ~= nil then
			image.draw(self.hp_bar_back,nil,settings.gameWidth,0,-1)
			image.draw(self.hp_bar,nil,settings.gameWidth,0,-1)
		end


	end)
end


return battle