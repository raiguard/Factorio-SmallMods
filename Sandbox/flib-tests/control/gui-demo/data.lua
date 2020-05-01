local styles = data.raw["gui-style"].default

styles.demo_dark_content_frame = {
  type = "frame_style",
  parent = "inside_deep_frame",
  graphical_set = {
    base = {
      position = {17,0}, corner_size = 8,
      center = {position={42,8}, size={1,1}},
      draw_type = "outer"
    },
    shadow = default_inner_shadow
  },
}

styles.demo_dark_content_frame_in_light_frame = {
  type = "frame_style",
  parent = "inside_deep_frame",
  graphical_set = {
    base = {
      position = {85,0},
      corner_size = 8,
      draw_type = "outer",
      center = {position={42,8}, size=1}
    },
    shadow = default_inner_shadow
  }
}

styles.demo_light_content_frame = {
  type = "frame_style",
  parent = "window_content_frame_packed"
}

styles.demo_light_content_frame_in_light_frame = {
  type = "frame_style",
  parent = "window_content_frame_packed",
  graphical_set = {
    base = {
      position = {85,0},
      corner_size = 8,
      draw_type = "outer",
      center = {position={76,8}, size=1}
    },
    shadow = default_inner_shadow
  }
}

styles.demo_blank_scroll_pane = {
  type = "scroll_pane_style",
  extra_padding_when_activated = 0,
  padding = 4,
  graphical_set = {
    shadow = default_inner_shadow
  }
}

styles.demo_slot_table_scroll_pane = {
  type = "scroll_pane_style",
  parent = "demo_blank_scroll_pane",
  padding = 0,
  margin = 0,
  extra_padding_when_activated = 0,
  -- height = 160, -- height is adjusted at runtime
  horizontally_squashable = "off",
  background_graphical_set = {
    base = {
      position = {282, 17},
      corner_size = 8,
      overall_tiling_horizontal_padding = 4,
      overall_tiling_horizontal_size = 32,
      overall_tiling_horizontal_spacing = 8,
      overall_tiling_vertical_padding = 4,
      overall_tiling_vertical_size = 32,
      overall_tiling_vertical_spacing = 8
    }
  }
}

styles.demo_slot_table = {
  type = "table_style",
  parent = "slot_table",
  horizontal_spacing = 0,
  vertical_spacing = 0
}