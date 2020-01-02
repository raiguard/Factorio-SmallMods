-- DEBUGGING TOOL
if mods['debugadapter'] then
  data:extend{
    {
      type = 'custom-input',
      name = 'DEBUG-INSPECT-GLOBAL',
      key_sequence = 'CONTROL + SHIFT + ENTER'
    }
  }
end

-- GUI styles
local styles = data.raw['gui-style'].default

styles.nb_titlebar_flow = {
  type = 'horizontal_flow_style',
  direction = 'horizontal',
  horizontally_stretchable = 'on',
  vertical_align = 'center',
  top_margin = -3
}

styles.nb_content_frame = {
  type = 'frame_style',
  parent = 'window_content_frame_packed',
  top_margin = 4
}

styles.nb_content_scrollpane = {
  type = 'scroll_pane_style',
  parent = 'scroll_pane_light',
  minimal_width = 250,
  vertical_flow_style = {
    type = 'vertical_flow_style',
    top_padding = 4,
    left_padding = 6,
    right_padding = 6,
    bottom_padding = 6
  }
}