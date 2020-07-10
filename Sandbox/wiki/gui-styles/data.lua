local styles = data.raw["gui-style"].default

styles.sandbox_listbox_style = {
  type = "list_box_style",
  parent = "list_box",
  width = 100,
  item_style = {
    type = "button_style",
    parent = "list_box_item",
    horizontal_align = "right"
  }
}

styles.tabbed_pane_with_paddingless_content = {
  type = "tabbed_pane_style",
  parent = "tabbed_pane",
  tab_content_frame = {
    type = "frame_style",
    top_padding = 8,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    graphical_set = tabbed_pane_graphical_set
  }
}

styles.subheader_frame_under_tab_row = {
  type = "frame_style",
  parent = "subheader_frame",
  graphical_set = {
    base = { -- add top transition into subheader center
      top = {position={42, 0}, size={1, 8}},
      center = {position={256, 25}, size={1, 1}},
      bottom = {position={256, 26}, size={1, 8}}
    },
    glow = { -- transition from content frame
      top = {position={93, 0}, size={1, 8}},
      draw_type = "outer"
    },
    shadow = bottom_shadow
  },
  top_padding = 1,
  height = 34
}