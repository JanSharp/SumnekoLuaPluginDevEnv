
# General

This is an environment to develop plugins for [sumneko.lua](https://github.com/sumneko/lua-language-server), specifically using the `OnSetText` feature using diffs.

# Required software

This repo relies on [Factorio](https://factorio.com), vscode and the [Factorio Debug Extension](https://github.com/justarandomgeek/vscode-factoriomod-debug).

# Best Setup

The best setup is a bit scuffed and uses symbolic links because the plugins I made this for have their own git repositories consisting of just the plugin files for easy distribution. If you are not doing that you could also just use this dev env as the template for your repo and remove `/mods/TestMod/plugin` from `.gitignore`, and then distribute the actual plugin files (those in `/mods/TestMod/plugin`) using some other method. However for this example I am using a separate repo for the plugin.

<!-- cSpell:ignore mkdir -->

Example using `MyPlugin` as the project name:

```bash
# enter your project's root, which is empty for now
git clone --recursive git@github.com:JanSharp/SumnekoLuaPluginDevEnv.git
# or if you're not using ssh
git clone --recursive https://github.com/JanSharp/SumnekoLuaPluginDevEnv.git
# recursive for the submodules

# make the folder the actual plugin will be in
mkdir MyPlugin
# note that if MyPlugin is an already existing plugin/repository just clone it instead of making a new folder
```
create symlinks using your preferred method:\
(from `<source>` to `<link>`)\
from `SumnekoLuaPluginDevEnv/mods` to `mods`\
from `SumnekoLuaPluginDevEnv/.vscode` to `.vscode`\
from `MyPlugin` to `SumnekoLuaPluginDevEnv/mods/TestMod/plugin` (this direction is important)

Instead of making a symlink for `.vscode` you can also just copy those files if you wish to modify them without modifying them in the SumnekoLuaPluginDevEnv repo.

These hacks are needed for vscode to not ignore your plugin files even though they are ignored by `.gitignore` in the `SumnekoLuaPluginDevEnv` repo. It just ignores a symlink instead.

At this point you can start working on your plugin in the `MyPlugin` folder, with `plugin.lua` being the entry point, see next section.

# How it Works

When launching the game as defined in the launch profile in `launch.json` the TestMod will load the `mods/TestMod/plugin/plugin.lua` file. This is the main entry point to the plugin that one is developing.

It then loads the `mods/TestMod/test.lua` file, if it exists, to seed the source text with some test text which will be passed into the defined `OnSetTest` global function (of the plugin).

The format/template for `mods/TestMod/test.lua` should be
```lua
return [===[

-- your test code here

-- ]===]
```
This is to make it easy to test using the actual language server by commenting out the first line, and quickly switching to debugging using Factorio.

Once the game is running, refer to the tooltips of the button, the switch and the labels.

# Profiling

WIP

# Libraries, Dependencies and Licenses

SumnekoLuaPluginDevEnv itself is licensed under the MIT License, see [LICENSE.txt](LICENSE.txt).

<!-- cSpell:ignore Mischak, Wellmann -->

- [FiraCode](https://github.com/tonsky/FiraCode), Copyright (c) 2014, The Fira Code Project Authors (https://github.com/tonsky/FiraCode)
- [minimal-no-base-mod](https://github.com/Bilka2/minimal-no-base-mod), Copyright (c) 2020 Erik Wellmann
- [JanSharpDevEnv](https://github.com/JanSharp/JanSharpDevEnv), Copyright (c) 2020 Jan Mischak

For license details see the [LICENSE_THIRD_PARTY.txt](LICENSE_THIRD_PARTY.txt) file and or the linked repositories above.
