
# General

This is an environment to develop plugins for [sumneko.lua](https://github.com/sumneko/lua-language-server), specifically using the `OnSetText` feature using diffs.

# Required software

This relies on [Factorio](https://factorio.com).

# How it Works

When launching the game as defined in the launch profile in `launch.json` the TestMod will load the `mods/TestMod/plugin/plugin.lua` file. This is the main entry point into the plugin that one is developing.

It then loads the `mods/TestMod/test.lua` file, if it exists, to have some seeded test text which will be passed into the defined `OnSetTest` global function (of the plugin).

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
