--##

---@type table
local styles = data.raw["gui-style"]["default"]

local font_color = {230, 230, 230}
---@type table
local bg = styles.textbox.disabled_background

styles.code_text_box = {
  type = "textbox_style",
  parent = "textbox",
  font = "fira-code",
  width = 0,
  horizontally_stretchable = "on",
  vertically_stretchable = "on",
  default_background = bg,
  active_background = bg,
  disabled_background = bg,
  selection_background_color = {80, 100, 190},
  font_color = font_color,
  disabled_font_color = font_color,
  rich_text_highlight_error_color = font_color,
  rich_text_highlight_warning_color = font_color,
  rich_text_highlight_ok_color = font_color,
  selected_rich_text_highlight_error_color = font_color,
  selected_rich_text_highlight_warning_color = font_color,
  selected_rich_text_highlight_ok_color = font_color,
}

styles.code_caption_label = {
  type = "label_style",
  parent = "caption_label",
  font = "fira-code",
}

data:extend{
  {
    type = "font",
    name = "fira-code",
    from = "fira-code",
    size = 12,
  },
}
