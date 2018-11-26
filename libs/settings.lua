path = love.filesystem.getSourceBaseDirectory() -- берем путь до папки с игрой
love.filesystem.mount(path, "")

love.graphics.setBackgroundColor(.49, .67, .46, 1) -- установка фона

window = {}
window.fullscreen = false
window.width, window.height, window.flags = love.window.getMode()
window.music_vol = 100
window.sound_vol = 100