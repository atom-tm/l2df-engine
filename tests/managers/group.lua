local obj1 = Room(1)
		GroupManager.addTags(obj1, {"Entity", "Room", "Another tag"})

		local obj2 = Room(2)
		GroupManager.addTags(obj2, {"Entity", "Room"})

		local obj3 = Entity()
		GroupManager.addTags(obj3, "Entity")

		local obj4 = Room(3)
		GroupManager.addTags(obj4, {"Entity", "FuckU", "Another tag"})

		local x = 228
		GroupManager.addTags(x, {"Number", "Another tag"})

		GroupManager.removeTags(obj2, "Room")





		print("-----")
		print("Displays a complete list of all tags:")
		GroupManager:showTagsList()
		print("")

		print("-----")
		print('Obtaining tags of the object or "obj4":')
		local tags = GroupManager.getTags(obj4)
		for i = 1, #tags do
			print(tags[i])
		end
		print("")

		print("-----")
		print('Checking an object for a tag "Room" of "obj2":')
		print(GroupManager.hasTags(obj2, "Room"))
		print("")

		print("-----")
		print('Checking an object for a tags "Room" and "Entity" of "obj1":')
		print(GroupManager.hasTags(obj1, {"Room", "Entity"}))
		print("")


		print("-----")
		print('Select items that contain the "Another tag" tag:')
		print(#GroupManager:getByTags("Another tag"))
		print("")

		print("-----")
		print('Select items that contain the "Another tag" AND "Entity" tags:')
		print(#GroupManager:getByTags({"Another tag", "Entity"}))
		print("")

		Сущность {гоблин, ловкач}
		Сущность {гоблин, ловкач}
		Сущность {человек, ловкач}
		Сущность {человек, силач}
		Сущность {орк, ловкач}

		print("-----")
		print('Select items that contain the "Another tag" OR "Entity" tags:')
		print(#GroupManager:getByTags({"Another tag", "Entity"}, 2))
		print("")