function love.conf(configuration)
	configuration.identity = 'l2df-lf2'
	configuration.window.title = "Lua 2D Fighting"
	configuration.window.icon = nil
	configuration.window.width = 977
	configuration.window.height = 550
	configuration.window.vsync = 1
	configuration.window.msaa = 0
	configuration.window.depth = nil
	configuration.window.resizable = true
	configuration.modules.physics = false
	configuration.console = true
	-- configuration.window.fullscreen = true
end