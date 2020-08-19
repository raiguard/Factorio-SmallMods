local styles = data.raw["gui-style"].default

styles.therenas_scroll_pane = {
  type = "scroll_pane_style",
  extra_padding_when_activated = 0,
  padding = 0,
  graphical_set = {
    base = {
      top = {position = {93, 0}, size = {1, 8}},
      draw_type = "outer"
    },
    shadow = default_inner_shadow
  },
  vertical_flow_style = {
    type = "vertical_flow_style",
    padding = 12
  }
}