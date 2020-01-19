Love2D Fighting Engine
======================

<!-- [![Build Status](https://travis-ci.org/atom-tm/l2df-engine.svg?branch=develop)](https://travis-ci.org/atom-tm/l2df-engine) -->

Love2D Fighting Engine (`L2DF`) is a cross-platform game engine written in Lua.

`L2DF` is a perfect solution for:

- 2D and 2.5D games
- fightings
- beat 'em ups
- platformers
- similar genres

The backstage of this engine is an old "Little Fighter 2" game, so if you are familiar with it you can dive in very fast
because `L2DF` uses similar syntax and terms. But if you're not there're no problem as we are going to support more syntaxes
like M.U.G.E.N. and make engine as flexible as it's possible.

If you're not that good in programming there're no problem since we have different presets which you can modificate
without any single line of code! It was achieved with a flexible architecture and easy-to-read-and-write custom data files
with our XML/HTML like syntax. We're going to release our custom editor for these files, so you won't need to edit data
files manually in text-format :)

Right now `L2DF` uses [LÖVE](https://bitbucket.org/rude/love) as "backend" for rendering, input and other stuff, but we
also have plans to support [CoronaSDK](https://github.com/coronalabs/corona) and [Luce](https://github.com/peersuasive/luce) in future.


Features
--------

* Cross-platform. As soon as you use Lua and one of our backends it'll be available on mobile, desktop, TV and other devices.
* Custom easy-to-learn syntax to make up / modificate rooms, objects, animations and etc.
* Very flexible entity-component architecture.
* Fast physics / collision detection - perfect for fighting games!
* Frames based architecture - have a full control of your objects in each single frame.
* Number of presets which you can use to rapidly start making your game.
* Integrated Peer-to-Peer network support.
* UDP-holepunching and master-server to exclude requirement of using VPN, Hamachi and other software to initialize connection under NAT.
* "GGPO like" rollback networking instead of lockstep to make you feel an excellent netplay experience.


Installation
------------

1. Go to [releases](https://github.com/atom-tm/l2df-engine/releases) page
2. Download one of packages in the latest available release:
	- `l2df.lua` - if you want just to import engine into your game with `require 'l2df'`
	- `demo-x.x.x.exe` - if you want just to test latest changes and features in Windows
	- `demo-x.x.x.zip` - if you want to see / modificate a single full-featured example
	- `Source code.zip` - everything is under your control, feel the full power of presets and modificate engine if you need it!

3. Place engine in your project and require it:
```lua
require 'l2df'
-- ^ exposes _G.l2df / l2df variable, you can localize it:
local l2df = require 'l2df'
-- or in libs/:
local l2df = require 'libs.l2df'
-- or in libs/ with some "hacks":
local src = love.filesystem.getSource()
package.path = ('%s;%s/libs/?.lua;%s/libs/?/init.lua'):format(package.path, src, src)
-- if previous 2 lines don't work:
love.filesystem.setRequirePath('libs/?.lua;libs/?/init.lua;?.lua;?/init.lua')
local l2df = require 'l2df'
```

4. Initialize engine with default `init` function. It's not needed if you want to use only some parts of `L2DF`.
```lua
function love.load()
	l2df:init()
end
```

5. If you don't have your own game loop leave out the rest of it to `L2DF`.
Else read [documentation](https://atom-tm.github.io/l2df-engine) for more information on how to integrate `L2DF` into your already existen game loop.
```lua
function love.run()
	return l2df:gameloop()
end
```

6. Now you are ready to start development!


Documentation
-------------

You can find it here: [https://atom-tm.github.io/l2df-engine](https://atom-tm.github.io/l2df-engine).

It's still in-progress but already covers some basics of development with our engine.


License
-------
`L2DF` is an open-sourced software licensed under the [MIT License](https://opensource.org/licenses/MIT).

This project also uses some parts of third-party libraries listed below.

```
|--------------------|--------------------------------------|-------------|---------------------|-----------|
| Project            | Distribution Files                   | Modificated | Copyright Holder    | License   |
|--------------------|--------------------------------------|-------------|---------------------|-----------|
| gamera             | src/external/gamera.lua              |      -      | Enrique García Cota | MIT       |
|--------------------|--------------------------------------|-------------|---------------------|-----------|
| lua-struct         | src/external/packer.lua              |      +      | Iryont              | MIT       |
|--------------------|--------------------------------------|-------------|---------------------|-----------|
| JSON Encode/Decode | src/external/json.lua                |      -      | Jeffrey Friedl      | CC BY 3.0 |
| in pure Lua        |                                      |             |                     |           |
|--------------------|--------------------------------------|-------------|---------------------|-----------|
| bump-3dpd          | src/class/component/physix/cube.lua  |      +      | Enrique García Cota | MIT       |
|                    | src/class/component/physix/grid.lua  |      +      |                     |           |
|                    | src/class/component/physix/world.lua |      +      |                     |           |
|--------------------|--------------------------------------|-------------|---------------------|-----------|
```

You can find full license text for this software in `THIRD-PARTY-LICENSE` file.


Contributing
------------

Currently we don't have appropriate contributing guide but if you really want to help our team in some improvements or
bug fixes then dm one of the core developers in Discord to discuss the topic / your pull-request:

* `Abelidze#0109`
* `Kasai#1590`

Also if you've found a bug it'd be great if you can explain it on the [issues](https://github.com/atom-tm/l2df-engine/issues) page.
