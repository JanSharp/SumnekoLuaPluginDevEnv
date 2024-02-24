--##

if __DebugAdapter then
  local defineGlobal = __DebugAdapter.defineGlobal or function(...) end
  defineGlobal("OnSetText")
  defineGlobal("__plugin_dev")
end
__plugin_dev = true
local old_require = require
require = function(module)
  return old_require("plugin."..module)
end

-- If this errors because it can't find the file that means
-- the plugin you are working on isn't in the 'mods/TestMod/plugin' folder
-- or doesn't have a 'plugin.lua' entry point file.
old_require("plugin.plugin")
if not OnSetText then
  log("No 'OnSetText' entry point function (global variable) defined by the plugin.")
end

---@type string|nil
local seed_text
do
  local success
  success, seed_text = pcall(old_require, "test")
  if not success then
    log("Create a 'mods/TestMod/test.lua' file as \z
      described in the README to seed text when launching the game."
    )
  end
  seed_text = success and seed_text
  if type(seed_text) ~= "string" then
    seed_text = nil
  else
    -- to ensure we have the same exact text when debugging
    seed_text = "-- return [===[\n" .. seed_text .. "]===]\n"
  end
end

local raw_colors = {
  "#ff0000",
  "#00ff00",
  "#8844ff",
  "#ffff00",
  "#ff00ff",
  "#00ffff",
}
---@type string[]
local color_opening_tags = {}
---@type string
for i, color in pairs(raw_colors) do
  color_opening_tags[i] = "[color=" .. color .. "]"
end
local color_count = #raw_colors


---@param color_opening_tag string @ one of the strings in color_opening_tags
---@param s string
---@return string
local function apply_color(s, color_opening_tag)
  s = #s == 0 and "[font=default-bold]\xe2\x8a\xa0[/font]" or s
  return color_opening_tag .. s .. "[/color]"
end

---@param s string
---@return string
local function add_interpunct(s)
  return string.gsub(s, " ", "\xc2\xb7")
end

---@param s string
---@return string
local function add_grey_interpunct(s)
  ---@param match string
  ---@return string
  return string.gsub(s, " +", function(match)
    return "[color=#606060]"..string.rep("\xc2\xb7", string.len(match)).."[/color]"
  end)
end

---@param text string
---@param diffs table[]
---@return string colored_text
---@return string colored_diff_text
local function merge_diff(text, diffs)
  if not diffs then
    return text, text
  end

  local sorted_diffs = {}
  for i, diff in ipairs(diffs) do
    sorted_diffs[i] = diff
  end
  table.sort(sorted_diffs, function (a, b)
    return a.start < b.start
  end)

  local cur = 1
  local text_buf = {}
  local diffed_buf = {}
  local color_i = 1

  for _, diff in ipairs(sorted_diffs) do
    local color_opening_tag = color_opening_tags[color_i]
    color_i = (color_i % color_count) + 1

    local untouched_text = add_grey_interpunct(text:sub(cur, diff.start - 1))
    text_buf[#text_buf+1] = untouched_text
    diffed_buf[#diffed_buf+1] = untouched_text

    text_buf[#text_buf+1] = add_interpunct(apply_color(text:sub(diff.start, diff.finish), color_opening_tag))
    diffed_buf[#diffed_buf+1] = add_interpunct(apply_color(diff.text, color_opening_tag))
    cur = diff.finish + 1
  end
  local last_text = add_grey_interpunct(text:sub(cur))
  text_buf[#text_buf+1] = last_text
  diffed_buf[#diffed_buf+1] = last_text
  return table.concat(text_buf), table.concat(diffed_buf)
end

local function on_res_change(player_data)
  ---@type table
  local style = player_data.frame.style
  ---@type table
  local res = player_data.player.display_resolution
  ---@type number
  style.width = res.width
  ---@type number
  style.height = res.height
end

-- https://chrisyeh96.github.io/2020/03/28/terminal-colors.html
-- https://www2.ccs.neu.edu/research/gpc/VonaUtils/vona/terminal/vtansi.htm
local reset = "\x1b[0m"
local bold = "\x1b[1m"
local faint = "\x1b[2m"
local singly_underlined = "\x1b[4m"
local blink = "\x1b[5m"
local reverse = "\x1b[7m"
local hidden = "\x1b[8m"
-- foreground colors:
local black = "\x1b[30m"
local red = "\x1b[31m"
local green = "\x1b[32m"
local yellow = "\x1b[33m"
local blue = "\x1b[34m"
local magenta = "\x1b[35m"
local cyan = "\x1b[36m"
local white = "\x1b[37m"

local function run_on_text_set(player_data)
  ---@type string
  local text = player_data.input_tb.text
  local diffs
  for _ = 1, 5 do
    local iteration_count = 10
    local profiler = game.create_profiler()
    for i = 1, iteration_count do
      diffs = OnSetText and OnSetText("file:///mods/TestMod/test.lua", text) or {}
    end
    profiler.stop()
    profiler.divide(iteration_count)
    localised_print{"", green.."OnSetText ", profiler, reset}
  end
  local colored_text, diffed = merge_diff(text, diffs)
  ---@type string
  player_data.colored_input_tb.text = colored_text
  ---@type string
  player_data.diffed_tb.text = diffed
end

script.on_event(defines.events.on_player_created, function(event)
  -- I think there was some need for it to be unpaused for syncing breakpoints or so
  game.tick_paused = false
  -- no need for this to autosave
  game.autosave_enabled = false

  ---@type table
  local player = game.get_player(event.player_index)
  ---@type table
  local gvs = player.game_view_settings
  gvs.show_controller_gui = false
  gvs.show_minimap = false
  gvs.show_research_info = false
  gvs.show_entity_info = false
  gvs.show_alert_gui = false
  gvs.update_entity_selection = false
  gvs.show_rail_block_visualisation = false
  gvs.show_side_menu = false
  gvs.show_map_view_options = false
  gvs.show_quickbar = false
  gvs.show_shortcut_bar = false

  ---@type table
  local frame = player.gui.screen.add{
    type = "frame",
    direction = "vertical",
  }

  ---@type table
  local button_flow = frame.add{
    type = "flow",
    direction = "horizontal",
    visible = true,
  }
  button_flow.style.vertical_align = "center"

  button_flow.add{
    type = "button",
    caption = "OnSetText",
    tooltip = "Calls OnSetText with the current 'Source' text and updates 'Colored Code' and 'Colored Diffed Code' accordingly.",
    tags = {
      __plugin_test_mod = true,
      type = "on_set_text",
    },
  }

  button_flow.add{
    type = "empty-widget",
  }.style.width = 20

  local auto_update = true
  local switch_tooltip = "If set to 'auto', automatically does the same thing as the button whenever the 'Source' text changes."
  button_flow.add{
    type = "switch",
    tooltip = switch_tooltip,
    switch_state = auto_update and "right" or "left",
    left_label_caption = "manual",
    left_label_tooltip = switch_tooltip,
    right_label_caption = "auto",
    right_label_tooltip = switch_tooltip,
    tags = {
      __plugin_test_mod = true,
      type = "toggle_auto_update",
    },
  }

  ---@type table
  local tb_table = frame.add{
    type = "table",
    column_count = 3,
  }

  tb_table.add{
    type = "label",
    caption = "Source                           ", -- extra spaces for even gui stretching
    tooltip = "The input text for 'OnSetText'. Or simply the text that the \z
      programmer would write in their files.",
    style = "code_caption_label",
  }
  tb_table.add{
    type = "label",
    caption = "Colored Code (pre plugin)        ", -- extra spaces for even gui stretching
    tooltip = "The same input text, except every part that will be replaced because of \z
      plugin generated diffs is colored matching the colors in 'Colored Diffed Code'.",
    style = "code_caption_label",
  }
  tb_table.add{
    type = "label",
    caption = "Colored Diffed Code (post plugin)",
    tooltip = "The output text after applying diffs, the text the plugin will 'see'. \z
      Every part that was replaced because of plugin generated diffs is colored matching \z
      the colors in 'Colored Code'.",
    style = "code_caption_label"
  }

  ---@type table
  local input_tb = tb_table.add{
    type = "text-box",
    text = seed_text,
    style = "code_text_box",
    tags = {
      __plugin_test_mod = true,
      type = "input_tb",
    },
  }
  ---@type table
  local colored_input_tb = tb_table.add{type = "text-box", style = "code_text_box"}
  ---@type table
  local diffed_tb = tb_table.add{type = "text-box", style = "code_text_box"}

  local player_data = {
    player = player,
    frame = frame,
    input_tb = input_tb,
    colored_input_tb = colored_input_tb,
    diffed_tb = diffed_tb,
    auto_update = auto_update,
  }
  global.players[event.player_index] = player_data

  on_res_change(player_data)

  if seed_text then
    run_on_text_set(player_data)
  end
end)

script.on_event(defines.events.on_player_display_resolution_changed, function(event)
  on_res_change(global.players[event.player_index])
end)

local function get_gui_event_data(event)
  ---@type table
  local tags = event.element.tags
  if tags.__plugin_test_mod then
    return global.players[event.player_index], tags
  end
end

---@param event table
script.on_event(defines.events.on_gui_click, function(event)
  local player_data, tags = get_gui_event_data(event)
  if not player_data then return end
  if tags.type == "on_set_text" then
    run_on_text_set(player_data)
  end
end)

---@param event table
script.on_event(defines.events.on_gui_text_changed, function(event)
  local player_data, tags = get_gui_event_data(event)
  if not player_data then return end
  if tags.type == "input_tb" then
    if player_data.auto_update then
      run_on_text_set(player_data)
    end
  end
end)

---@param event table
script.on_event(defines.events.on_gui_switch_state_changed, function(event)
  local player_data, tags = get_gui_event_data(event)
  if not player_data then return end
  if tags.type == "toggle_auto_update" then
    player_data.auto_update = not player_data.auto_update
    if player_data.auto_update then
      run_on_text_set(player_data)
    end
  end
end)

script.on_init(function()
  global.players = {}
end)

-- in factorio lua gmatch("aaabbb", "a*") results in 2 iterations
-- one with "aaa", as expected, and one with ""
-- this replacement of gmatch removes those empty strings by removing
-- all results that ended at the same index as the previous one
-- in the lua version the language server is using it already behaves
-- this way, which is why this replacement is required
local match = string.match
local unpack = table.unpack
---@param s string
---@param pattern string
---@param init integer?
---@return function @ iterator
string.gmatch = function(s, pattern, init)
  if pattern:sub(1, 1) == "^" then
    error("The ^ anchor does not work with gmatch.")
  end
  local new_pattern = pattern.."()"
  -- local match = {string.match(s, new_pattern)}
  -- if #match == 1 then -- the pattern has no captures
  --   new_pattern = "(" .. pattern .. ")()" -- then capture the whole thing
  -- end
  -- local it = gmatch(s, new_pattern)
  local prev_finish = init or 1
  return function()
    local result = {match(s, new_pattern, prev_finish)}
    local count = #result
    if count == 1 then
      error("This extended version of string.gmatch does not automatically capture the entire string if no captures are provided.")
    end
    prev_finish = result[count]
    result[count] = nil
    return unpack(result)
  end
end
