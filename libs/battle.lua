local battle = {}

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

		if self.control.players[1] ~= nil then
			image.draw(self.hp_bar_back,nil,0,0)
			image.draw(self.hp_bar,nil,0,0)
			--image.draw(self.control.players[1].face,nil,0,0)
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