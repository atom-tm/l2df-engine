# Presets

## What is "preset"?

Presets provide you a bunch of already implemented tools, game logic and mechanics to rapidly start your development.
It's like examples but more powerful since you can just take it and start implementing your own mod / game with minimum / without
programming!


## Well, how can I use them?

If you've downloaded L2DF's source code you can find them in `/path/to/l2df-engine/presets/`.

There're instructions below how to get working each preset.


## LF2 preset

1. Copy `l2df-engine/presets/lf2` folder to another location (where you want to work with it).
2. Create `libs` directory inside your copy if it doesn't exist.
3. Do any of these steps:
	@plain
	- copy `l2df.lua` distributed [all-in-one engine version](https://github.com/atom-tm/l2df-engine/releases) to `libs/l2df.lua`;
	- copy `l2df-engine/src` to `libs/l2df/` (rename `src` to `l2df`);
	- \* make symbolic link `libs/l2df` pointing to `l2df-engine/src`:
		* Windows: `mklink /d libs\l2df path\to\l2df-engine\src`
		* Linux / Mac: `ln -s libs/l2df path/to/l2df-engine/src`
4. @{01-introduction.md.How_to_start_projects|Run} your preset's copy with LÖVE.

\* Use this method only for development since it's not working when you'll try to "zip" / build your project.


## MUGEN preset

Coming soon...