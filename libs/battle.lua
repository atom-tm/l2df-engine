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
		local object = self.entities.spawnObject(id,x,y,z,nil,"idle",nil)
		if object ~= nil then
			object.controller = list[key].controller
			object:setController()
		end
	end
end

function battle:Load(spawnList)
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
	self.collision.checkCollisions()
	self.graphic:cameraUpdate()
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
	end)
end


return battle