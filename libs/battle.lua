local battle = {}

battle.res = require("libs.battle.resourses")
battle.graphic = require("libs.battle.graphic")
battle.entities = require("libs.battle.entities")
battle.control = require("libs.battle.control")
battle.physix = require("libs.battle.physix")
battle.collision = require("libs.battle.collision")
battle.ai = require("libs.battle.ai")

battle.chars = {}
battle.objs = {}
battle.effs = {}

battle.map = {}
battle.timer = 0
battle.tick = {
	[2] = 1,
	[7] = 1,
	[13] = 1,
	[17] = 1,
	[25] = 1,
	[60] = 1
}
battle.objects = 0


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
		local facing = spawn_point.facing
		if facing == 0 then
			facing = math.random(-2,1)
			if facing < 0 then
				facing = -1
			else
				facing = 1
			end
		end
		local object = self.entities.spawnObject(id,x,y,z,facing,"standing",nil)
		if object ~= nil then
			object.controller = list[key].controller
			if object.controller == 0 then
				object.ai = true
			end
			object:setController()
		end
	end
	battle:mapOpointsProcessing()
end


function battle:mapOpointsProcessing()
	for i = 1, #self.map.opoints do
		local opoint = self.map.opoints[i]
		if resourses.entities[opoint.id] ~= nil then
			local amount = opoint.amount
			if settings.quality or resourses.entities[opoint.id].head.type ~= "effect" then
				amount = amount + math.random(0,opoint.amount_random)
			end
			for a = 1, amount do
				local x = opoint.x + math.random(-opoint.x_random, opoint.x_random)
				local y = opoint.y + math.random(-opoint.y_random, opoint.y_random)
				local z = opoint.z + math.random(-opoint.z_random, opoint.z_random)
				local count = opoint.count
				if settings.quality or resourses.entities[opoint.id].head.type ~= "effect" then
					count = count + math.random(0,opoint.count_random)
				end
				local facing = opoint.facing
				if facing == 3 then facing = math.random(-1,1) end
				if facing == 0 then facing = 1 end
				for c = 1, count do
					local action = opoint.action + math.random(0,opoint.action_random)
					local object = battle.entities.spawnObject(opoint.id, x, y, z, facing, action, nil)
					if object ~= nil then
						object:setMotion_X((opoint.dvx + math.random(0,opoint.dvx_random * 100) * 0.01) * object.facing)
						object:setMotion_Y((opoint.dvy + math.random(0,opoint.dvy_random * 100) * 0.01))
						object:setMotion_Z((opoint.dvz + math.random(0,opoint.dvz_random * 100) * 0.01))
					end
				end
			end
		end
	end
end


function battle:time()
	for tick in pairs(self.tick) do
		self.tick[tick] = self.tick[tick] + 1
		if self.tick[tick] > tick then
			self.tick[tick] = 1
		end
	end
	if self.tick[60] == 1 then
		self.timer = self.timer + 1
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

	for i in pairs(self.entities.effects) do
		for j in pairs(self.entities.effects[i]) do
			self.entities.effects[i][j] = nil
		end
	end
	self.entities.effects = nil
	self.entities.effects = {}

	self.map = {}
	self.control.players = {}
	self.graphic:clear()
	collectgarbage()
	self.timer = 0
	self.tick = {
		[2] = 1,
		[7] = 1,
		[13] = 1,
		[17] = 1,
		[25] = 1,
		[60] = 1,
	}
	self.objects = 0
	self.res:Load()
	self:setMap(resourses.maps[spawnList.maps[1]])
	sounds.setMusic("music/battle.mp3")
	self:createStartingObjects(spawnList.entities)
end


function battle:Update()

	self.graphic:clear()
	self.graphic:cameraUpdate()
	self.graphic:mapDraw()

	self.collision.check()
	self.collision.processing()

	self:createOptimizedLists()

	for i = 1, #self.chars do
		local object = self.chars[i]
		object:countersProcessing()
		if object.tick_skip then
			object:aiProcessing()
			object:keysCheck()
			object:frameProcessing()
			object:statesUpdate()
			object:statesProcessing()
			object:opointsProcessing()
		end
		if object.destroy then
			self.entities.removeObjects(object)
		else
			if object.tick_skip then
				object:applyMotions()
				object:applyGravity()
			end
			object:findColliders()
			object:drawPreparation()
			object:hpBarsCalculation()
		end
	end

	for i = 1, #self.objs do
		local object = self.objs[i]
		object:countersProcessing()
		if object.tick_skip then
			object:aiProcessing()
			object:frameProcessing()
			object:statesUpdate()
			object:statesProcessing()
			object:opointsProcessing()
		end
		if object.destroy then
			self.entities.removeObjects(object)
		else
			if object.tick_skip then
				object:applyMotions()
				object:applyGravity()
			end
			object:findColliders()
			object:drawPreparation()
		end
	end

	for i = 1, #self.effs do
		local object = self.effs[i]
		object:countersProcessing()
		if object.tick_skip then
			object:frameProcessing()
			object:statesUpdate()
			object:statesProcessing()
			object:opointsProcessing()
		end
		if object.destroy then
			self.entities.removeObjects(object)
		else
			if object.tick_skip then
				object:applyMotions()
				object:applyGravity()
			end
			object:drawPreparation()
		end
	end
	
	self.graphic:sortObjects()
	self.graphic:drawReflections()
	self.graphic:drawShadows()
	self.graphic:drawObjects()
	self.graphic:shadowFilter()

	self:time()
end


function battle:createOptimizedLists()
	battle.chars = {}
	battle.objs = {}
	battle.effs = {}
	for key in pairs(battle.entities.list) do
		if battle.entities.list[key].head.type == "character" then
			table.insert(battle.chars,battle.entities.list[key])
		elseif battle.entities.list[key].head.type == "object" then
			table.insert(battle.objs, battle.entities.list[key])
		end
	end
	for key in pairs(battle.entities.effects) do
		table.insert(battle.effs,battle.entities.effects[key])
	end
	battle.objects = #battle.chars + #battle.objs + #battle.effs
end


function battle:DrawGame()
	self.graphic:layersDraw()
end


function battle:hpBarsCalculation()
	self.hp_width = (self.hp / self.head.hp) * battle.res.bars.hp.w
	self.mp_width = (self.mp / self.head.mp) * battle.res.bars.mp.w
	self.sp_width = (self.sp / self.head.sp) * battle.res.bars.sp.w
end


function battle:DrawInterface()
	camera:draw(function(l,t,w,h)
		if self.control.players[1] ~= nil and self.control.players[2] == nil then
			image.draw(self.res.hp_bar_background,nil,0,0)
			image.draw(self.control.players[1].head.face,nil,0,0)

			image.draw(self.res.bars,"hp_back",90,0)
			self.res.bars:setQuad("hp", self.res.bars.hp.x, self.res.bars.hp.y, self.control.players[1].hp_width, self.res.bars.hp.h)
			image.draw(self.res.bars,"hp",90,0)

			image.draw(self.res.bars,"mp_back",85,28)
			self.res.bars:setQuad("mp", self.res.bars.mp.x, self.res.bars.mp.y, self.control.players[1].mp_width, self.res.bars.mp.h)
			image.draw(self.res.bars,"mp",85,28)

			image.draw(self.res.bars,"sp_back",81,45)
			self.res.bars:setQuad("sp", self.res.bars.sp.x, self.res.bars.sp.y, self.control.players[1].sp_width, self.res.bars.sp.h)
			image.draw(self.res.bars,"sp",81,45)

			if settings.debug_mode then
				font.print(self.control.players[1].hp .. "/" .. self.control.players[1].head.hp, 102, 8, "left", font.list.stats)
				font.print(self.control.players[1].mp .. "/" .. self.control.players[1].head.mp, 95, 30, "left", font.list.stats)
				font.print(self.control.players[1].sp .. "/" .. self.control.players[1].head.sp, 88, 45, "left", font.list.stats)
				for key, val in pairs(self.control.players[1].key_pressed) do
					if val == 1 then image.draw(self.res.control_visuals[key].pressed, 0, 5 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y)
					else image.draw(self.res.control_visuals[key].normal, 0, 5 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y) end
				end
			end

		elseif self.control.players[1] == nil and self.control.players[2] ~= nil then
			image.draw(self.res.hp_bar_background,nil,0,0)
			image.draw(self.control.players[2].head.face,nil,0,0)

			image.draw(self.res.bars,"hp_back",90,0)
			self.res.bars:setQuad("hp", self.res.bars.hp.x, self.res.bars.hp.y, self.control.players[2].hp_width, self.res.bars.hp.h)
			image.draw(self.res.bars,"hp",90,0)

			image.draw(self.res.bars,"mp_back",85,28)
			self.res.bars:setQuad("mp", self.res.bars.mp.x, self.res.bars.mp.y, self.control.players[2].mp_width, self.res.bars.mp.h)
			image.draw(self.res.bars,"mp",85,28)

			image.draw(self.res.bars,"sp_back",81,45)
			self.res.bars:setQuad("sp", self.res.bars.sp.x, self.res.bars.sp.y, self.control.players[2].sp_width, self.res.bars.sp.h)
			image.draw(self.res.bars,"sp",81,45)

			if settings.debug_mode then
				font.print(self.control.players[2].hp .. "/" .. self.control.players[2].head.hp, 102, 8, "left", font.list.stats)
				font.print(self.control.players[2].mp .. "/" .. self.control.players[2].head.mp, 95, 30, "left", font.list.stats)
				font.print(self.control.players[2].sp .. "/" .. self.control.players[2].head.sp, 88, 45, "left", font.list.stats)
				for key, val in pairs(self.control.players[2].key_pressed) do
					if val == 1 then image.draw(self.res.control_visuals[key].pressed, 0, 5 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y)
					else image.draw(self.res.control_visuals[key].normal, 0, 5 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y) end
				end
			end

		elseif self.control.players[1] ~= nil and self.control.players[2] ~= nil then
			
			image.draw(self.res.hp_bar_background,nil,0,0)
			image.draw(self.control.players[1].head.face,nil,0,0)

			image.draw(self.res.bars,"hp_back",90,0)
			self.res.bars:setQuad("hp", self.res.bars.hp.x, self.res.bars.hp.y, self.control.players[1].hp_width, self.res.bars.hp.h)
			image.draw(self.res.bars,"hp",90,0)

			image.draw(self.res.bars,"mp_back",85,28)
			self.res.bars:setQuad("mp", self.res.bars.mp.x, self.res.bars.mp.y, self.control.players[1].mp_width, self.res.bars.mp.h)
			image.draw(self.res.bars,"mp",85,28)

			image.draw(self.res.bars,"sp_back",81,45)
			self.res.bars:setQuad("sp", self.res.bars.sp.x, self.res.bars.sp.y, self.control.players[1].sp_width, self.res.bars.sp.h)
			image.draw(self.res.bars,"sp",81,45)



			image.draw(self.res.hp_bar_background,nil,settings.gameWidth,0,-1)
			image.draw(self.control.players[2].head.face,nil,settings.gameWidth,0,-1)

			image.draw(self.res.bars,"hp_back",settings.gameWidth-90,0,-1)
			self.res.bars:setQuad("hp", self.res.bars.hp.x, self.res.bars.hp.y, self.control.players[2].hp_width, self.res.bars.hp.h)
			image.draw(self.res.bars,"hp",settings.gameWidth-90,0,-1)

			image.draw(self.res.bars,"mp_back",settings.gameWidth-85,28,-1)
			self.res.bars:setQuad("mp", self.res.bars.mp.x, self.res.bars.mp.y, self.control.players[2].mp_width, self.res.bars.mp.h)
			image.draw(self.res.bars,"mp",settings.gameWidth-85,28,-1)

			image.draw(self.res.bars,"sp_back",settings.gameWidth-81,45,-1)
			self.res.bars:setQuad("sp", self.res.bars.sp.x, self.res.bars.sp.y, self.control.players[2].sp_width, self.res.bars.sp.h)
			image.draw(self.res.bars,"sp",settings.gameWidth-81,45,-1)

			if settings.debug_mode then
				font.print(self.control.players[1].hp .. "/" .. self.control.players[1].head.hp, 102, 8, "left", font.list.stats)
				font.print(self.control.players[1].mp .. "/" .. self.control.players[1].head.mp, 95, 30, "left", font.list.stats)
				font.print(self.control.players[1].sp .. "/" .. self.control.players[1].head.sp, 88, 45, "left", font.list.stats)
				font.print(self.control.players[2].hp .. "/" .. self.control.players[2].head.hp, settings.gameWidth-300-102, 8, "right", font.list.stats)
				font.print(self.control.players[2].mp .. "/" .. self.control.players[2].head.mp, settings.gameWidth-300-95, 30, "right", font.list.stats)
				font.print(self.control.players[2].sp .. "/" .. self.control.players[2].head.sp, settings.gameWidth-300-88, 45, "right", font.list.stats)
				for key, val in pairs(self.control.players[1].key_pressed) do
					if val == 1 then image.draw(self.res.control_visuals[key].pressed, 0, 55 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y)
					else image.draw(self.res.control_visuals[key].normal, 0, 55 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y) end
				end
				for key, val in pairs(self.control.players[2].key_pressed) do
					if val == 1 then image.draw(self.res.control_visuals[key].pressed, 0, settings.gameWidth-305 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y)
					else image.draw(self.res.control_visuals[key].normal, 0, settings.gameWidth-305 + self.res.control_visuals[key].x, 640 + self.res.control_visuals[key].y) end
				end
			end
		end
		
		font.print(battle.timer, settings.gameWidth / 2 - 100, 10, "center", font.list.timer, nil, 200)		
	end)
end

return battle