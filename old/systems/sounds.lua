local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "PhysixSystem works only with l2df v1.0 and higher")
assert(type(love) == "table", "PhysixSystem works only under love2d environment")

local System = core.import "core.entities.system"
local settings = core.import "settings"

local SoundSystem = System:extend()

	function SoundSystem:init()
		print("init")
	end

	function SoundSystem:settingsupdated()
		print("update_settings!")
	end

	function SoundSystem:setVolume(entities)
		local enumeration = { {entities, 1, #entities} }
		local current = enumeration[1]
		local node = nil
		local head = 1
		local i = 1

		while head > 1 or i <= current[3] do
			node = current[1][i]
			i = i + 1

			print("hello")

			if node and node.childs and next(node.childs) then
				current[2] = i
				enumeration[head + 1] = { node.childs, 1, #node.childs }
				head = head + 1
				current = enumeration[head]
				i = 1
			elseif i > current[3] and head > 1 then
				head = head - 1
				current = enumeration[head]
				i = current[2]
			end
		end
	end

	function SoundSystem:update()
		print(#self.groups.music.entities)
	end


return SoundSystem