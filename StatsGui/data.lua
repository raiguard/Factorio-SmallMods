local styles = data.raw['gui-style'].default

styles.statsgui_label = {
  type = 'label_style',
  font = 'default-game',
  font_color = default_font_color
}

styles.statsgui_frame = {
  type = "frame_style",
  parent = "invisible_frame",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    horizontal_spacing = 20,
    horizontal_align = "right",
    horizontally_stretchable = "on"
  },
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
    horizontal_align = "right",
    horizontally_stretchable = "on"
  }
}