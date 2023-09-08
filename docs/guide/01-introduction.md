# Introduction

Lua2D Fighting Engine (L2DF) is a cross-platform game engine written in Lua.

It has its own syntax for data representation: LF2 style data-code, custom dat-code and json. More is coming soon.

L2DF doesn't require you to write real code, most of time you just change data-code (thanks to @{02-presets.md|presets}).
But if you want to dive deeper and use engine's full-powered API you need to know [Lua](https://en.wikipedia.org/wiki/Lua_(programming_language))
on basic level. This language is very simple and easy-to-learn, so don't scare about it :)
If you have a backstage in programming but don't know Lua there're awesome guide
["Learn Lua in 15 Minutes"](http://tylerneylon.com/a/learn-lua/) - we suggest you start from there.

Also L2DF uses OOP (Object-Oriented programming). As we're talking about Lua L2DF has its own implementation of classes.
You can find it @{l2df.class|here}.

## How to start projects

Before you start make sure to download latest [LÖVE](https://love2d.org/) framework binary for your platform.
We use it as our backend for rendering, I/O, system events and etc.

After you successfully downloaded LÖVE we suggest you to add it in your system environment PATH variable.
This step is not required but allows you to run `love` from the console / terminal anythere on your system.

Okay, you have your project located in `/path/to/project/` directory with `main.lua` file in it.

Multiple variants how to run it:

1. Drag & Drop folder with your project to `love.exe`, `love` (Linux/Mac) or shortcut / symbolic link pointing to it.
2. Select all your files, make `.zip` from them and D&D it (see previous method).
3. Use console: `love /path/to/project --fused`
4. Create `.bat` or `.sh` script with previous command and use it.

More introduction is coming soon...