local styles = data.raw['gui-style'].default

styles.rll_green_button = {
  type = 'button_style',
  parent = 'button',
  default_graphical_set = {
    base = {position = {68, 17}, corner_size = 8},
    shadow = default_dirt
  },
  hovered_graphical_set = {
    base = {position = {102, 17}, corner_size = 8},
    shadow = default_dirt,
    glow = default_glow(green_arrow_button_glow_color, 0.5)
  },
  clicked_graphical_set = {
    base = {position = {119, 17}, corner_size = 8},
    shadow = default_dirt
  },
  disabled_graphical_set = {
    base = {position = {85, 17}, corner_size = 8},
    shadow = default_dirt
  }
}

styles.rll_green_icon_button = {
  type = 'button_style',
  parent = 'rll_green_button',
  padding = 0,
  size = 28
}

styles.rll_icon_slot_table_frame = {
  type = 'frame_style',
  padding = 0,
  graphical_set = {
    base = {
      position = {85,0},
      corner_size = 8,
      draw_type = 'outer',
      center = {position={42,8}, size=1}
    },
    shadow = default_inner_shadow
  },
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
  },
}

styles.rll_icon_slot_table_scrollpane = {
  type = 'scroll_pane_style',
  parent = 'scroll_pane',
  padding = 0,
  margin = 0,
  extra_padding_when_activated = 0
}

styles.rll_icon_slot_table = {
  type = 'table_style',
  parent = 'slot_table',
  horizontal_spacing = 0,
  vertical_spacing = 0
}

local tileset = '__RaiLuaLib__/tests/sandbox/tileset.png'

local function slot_button(type, y, glow_color)
  return {
    type = 'button_style',
    parent = 'quick_bar_slot_button',
    default_graphical_set = {
      base = {border=4, position={0,y}, size=80, filename=tileset},
      shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
    },
    hovered_graphical_set = {
      base = {border=4, position={80,y}, size=80, filename=tileset},
      shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
      glow = offset_by_2_rounded_corners_glow(glow_color)
    },
    clicked_graphical_set = {
      base = {border=4, position={160,y}, size=80, filename=tileset},
      shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
    }
  }
end

local row_shadow = {
  position = {378, 103},
  corner_size = 16,
  top_outer_border_shift = 4,
  bottom_outer_border_shift = -4,
  left_outer_border_shift = 4,
  right_outer_border_shift = -4,
  draw_type = "outer"
}

local function row_slot_button(type, y, glow_color)
  return {
    type = 'button_style',
    size = 32,
    padding = -2,
    default_graphical_set = {
      base = {border=4, position={2,y}, size=76, filename=tileset},
      shadow = row_shadow
    },
    hovered_graphical_set = {
      base = {border=4, position={82,y}, size=76, filename=tileset},
      shadow = row_shadow,
      glow = offset_by_2_rounded_corners_glow(glow_color)
    },
    clicked_graphical_set = {
      base = {border=4, position={162,y}, size=76, filename=tileset},
      shadow = row_shadow
    }
  }
end

local slot_button_data = {
  {name='dark_grey', y=0, glow=default_glow_color},
  {name='light_grey', y=80, glow=default_glow_color},
  {name='red', y=160, glow={255,166,123,128}},
  {name='green', y=240, glow={34,255,75,128}},
  {name='blue', y=320, glow={34,181,255,128}},
}

for _,data in ipairs(slot_button_data) do
  styles['rll_slot_button_'..data.name] = slot_button(data.name, data.y, data.glow)
  styles['rll_row_slot_button_'..data.name] = row_slot_button(data.name, data.y + 2, data.glow)
end

styles.rll_row_slot_button_no_background = {
  type = 'button_style',
  parent = 'transparent_slot',
  padding = 2
}

styles.rll_rows_scroll_pane = {
  type = "scroll_pane_style",
  parent = "scroll_pane_with_dark_background_under_subheader",
  background_graphical_set = {
    position = {282, 17},
    corner_size = 8,
    overall_tiling_vertical_spacing = 12,
    overall_tiling_vertical_size = 32,
    overall_tiling_vertical_padding = 4
  },
  vertical_flow_style = {
    type = 'vertical_flow_style',
    vertically_stretchable = 'on'
  }
}

styles.rll_subfactory_scroll_pane = {
  type = "scroll_pane_style",
  parent = "scroll_pane_with_dark_background_under_subheader",
  extra_right_padding_when_activated = -12,
  background_graphical_set = { -- rubber grid
    position = {282,17},
    corner_size = 8,
    overall_tiling_vertical_size = 24,
    overall_tiling_vertical_spacing = 8,
    overall_tiling_vertical_padding = 4,
    overall_tiling_horizontal_padding = 4
  },
  vertically_stretchable = 'on',
  padding = 0,
  width = 250,
  vertical_flow_style = {
    type = 'vertical_flow_style',
    vertical_spacing = 0
  }
}

styles.rll_subfactory_button = {
  type = 'button_style',
  parent = 'list_box_item',
  height = 32,
  left_padding = 4,
  right_padding = 8,
  horizontally_stretchable = 'on',
  disabled_graphical_set = styles.button.selected_graphical_set,
  disabled_font_color = styles.button.selected_font_color,
  disabled_vertical_offset = styles.button.selected_vertical_offset
}

styles.rll_production_table_row_frame = {
  type = 'frame_style',
  parent = 'dark_frame',
  height = 40,
  padding = 0,
  width = 1080,
  horizontal_flow_style = {
    type = 'horizontal_flow_style',
    vertical_align = 'center',
    horizontal_spacing = 16
  }
}