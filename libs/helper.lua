local helper = {}

	-- Подключает все файлы формата .lua из указанной папки, возвращает таблицу с подключенными файлами
	-- @param path, string, путь до папки
	-- @param pattern, string, паттерн имени файла позволяет подключать только определенные файлы (например, с префиксами)
	-- @return table
	function helper.requireAllFromFolder(path, pattern)
		local result = {}
		local file_list = love.filesystem.getDirectoryItems(path)
		if file_list then
			local formated_path = ""
			for folder in string.gmatch(path, "([^/]+)") do
				formated_path = formated_path .. folder .. "."
			end
			for i = 1, #file_list do
				if file_list[i]:find("^[%a%d_]+%.lua$") then
					local file_name = file_list[i]:gsub(".lua$","")
					if not pattern or file_name:find(pattern) then
						result[tostring(file_name)] = require(formated_path .. file_name)
					end
				end
			end
		end
		return result
	end


return helper