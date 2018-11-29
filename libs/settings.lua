path = love.filesystem.getSourceBaseDirectory() -- берем путь до папки с игрой
love.filesystem.mount(path, "")

love.graphics.setBackgroundColor(.49, .67, .46, 1) -- установка фона

window = {}
window.fullscreen = false
window.music_vol = 100
window.sound_vol = 100

game_width = 1280
game_height = 720

selected_window_size = 1
window_sizes = {
	{ width = 1920, height = 1080 },
	{ width = 1600, height = 900 },
	{ width = 1280, height = 720 },
	{ width = 1024, height = 576 },
	{ width = 854, height = 480 }
}

localization_list = {
	"data.english",
	"data.russian"
}
localization_number = 1
localization = require(localization_list[localization_number])


fonts = {}
fonts.default = love.graphics.newFont("sprites/UI/menu.otf",16)
fonts.menu_head = love.graphics.newFont("sprites/UI/menu.otf",42)
fonts.menu_comment = love.graphics.newFont("sprites/UI/menu.otf",24)
fonts.menu = love.graphics.newFont("sprites/UI/menu.otf",32)

function read_settings ()
	local data = love.filesystem.read("data/settings.txt") -- получаем содержимое файла data.txt
	if data ~= nil then
		local settings = string.match(data, "%[settings%]([^%[%]]+)") -- берём всех из списка [settings]
		if settings ~= nil then
			window.music_vol = PNumber(settings, "music_vol", 100)
			window.sound_vol = PNumber(settings, "sound_vol", 100)
			selected_window_size = PNumber(settings, "window_size", 1)
			window.fullscreen = PBool(settings, "fullscreen")
			localization_number = PNumber(settings, "language", 1)
			localization = require(localization_list[localization_number])
			local controls_string = string.match(settings, "controls: {([^{}]+)}")
			if controls_string ~= nil then
				local controls_mass = {}
				for code in string.gmatch(controls_string, "([^%s]+)") do
					if code == "lsqbr" then
						code = "["
					elseif code == "rsqbr" then
						code = "]"
					end
					table.insert(controls_mass,code)
				end
				if #controls_mass ~= 0 then
					local i = 1
					for key1 in ipairs(control_settings) do
						for key2 in pairs(control_settings[key1]) do
							control_settings[key1][key2] = controls_mass[i]
							i = i + 1
						end
					end
				end
			end
		end
	end
	setWindowSize()
	setFullscreen()
end

function save_settings()
	local data_file = "data/settings.txt"
	local File = io.open("../"..data_file,"w+")
	if File ~= nil then
		local data_save = "[settings]"
		.."\nmusic_vol: "..window.music_vol
		.."\nsound_vol: "..window.sound_vol
		.."\nwindow_size: "..selected_window_size
		.."\nfullscreen: "..tostring(window.fullscreen)
		.."\nlanguage: "..localization_number
		local controls_string = "controls: {"
		for key1 in ipairs(control_settings) do
			for key2 in pairs(control_settings[key1]) do
				key = control_settings[key1][key2]
				if key == "[" then
					key = "lsqbr"
				elseif key == "]" then
					key = "lsqbr"
				end
				controls_string = controls_string .. key .. " "
			end
		end
		controls_string = controls_string.."}"
		data_save = data_save.."\n"..controls_string
		File:write(data_save)
		File:close()
	end
end

function setWindowSize()
	love.window.setMode( window_sizes[selected_window_size].width, window_sizes[selected_window_size].height )
	camera = CameraCreate()
end

function setFullscreen ()
	love.window.setFullscreen( window.fullscreen )
	camera = CameraCreate()
end