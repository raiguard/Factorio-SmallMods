local data_util = require("__flib__.data-util")

data:extend{
  {
    type = "blueprint",
    name = "pg-guide",
    icons = {
      {icon = data_util.planner_base_image, icon_size = 64, icon_mipmaps = 4, tint = {r = 1, g = 0.5, b = 1}}
    },
    stack_size = 1,
    flags = {"hidden", "not-stackable", "only-in-cursor"},
    draw_label_for_cursor_render = true,
    selection_color = {0, 1, 0},
    alt_selection_color = {0, 1, 0},
    selection_mode = {"nothing"},
    alt_selection_mode = {"nothing"},
    selection_cursor_box_type = "not-allowed",
    alt_selection_cursor_box_type = "not-allowed"
  },
  {
    type = "custom-input",
    name = "pg-activate-guide",
    key_sequence = "CONTROL + G"
  }
}