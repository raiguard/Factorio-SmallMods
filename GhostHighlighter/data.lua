local shortcut_file_32 = "__GhostHighlighter__/graphics/shortcut-x32.png"
local shortcut_file_24 = "__GhostHighlighter__/graphics/shortcut-x24.png"

data:extend{
  {
    type = "custom-input",
    name = "gh-run-search",
    key_sequence = "CONTROL + G"
  },
  {
    type = "highlight-box",
    name = "gh-highlight-box"
  },
  {
    type = "shortcut",
    name = "gh-run-search",
    associated_control_input = "gh-run-search",
    action = "lua",
    icon = {
      filename = shortcut_file_32,
      y = 0,
      size = 32,
      mipmap_count = 2,
      flags = {"icon"}
    },
    disabled_icon = {
      filename = shortcut_file_32,
      y = 32,
      size = 32,
      mipmap_count = 2,
      flags = {"icon"}
    },
    small_icon = {
      filename = shortcut_file_24,
      y = 0,
      size = 24,
      mipmap_count = 2,
      flags = {"icon"}
    },
    disabled_small_icon = {
      filename = shortcut_file_24,
      y = 24,
      size = 24,
      mipmap_count = 2,
      flags = {"icon"}
    }
  }
}