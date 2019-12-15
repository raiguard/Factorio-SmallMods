-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICKBAR TEMPLATES PROTOTYPES

-- -----------------------------------------------------------------------------
-- SPRITES

data:extend{
  {
    type = 'custom-input',
    name = 'qis-search',
    key_sequence = 'CONTROL + F'
  }
}

local styles = data.raw['gui-style'].default

-- ------------------------------------------------------------------------------
-- SCROLLPANE STYLES

local outer_frame_light = outer_frame_light()
outer_frame_light.base.center = {position = {42,8}, size=1}

styles['results_scroll_pane'] = {
  type = 'scroll_pane_style',
  -- parent = 'scroll_pane',
  padding = 0,
  minimal_width = (40 * 6) + 12, -- six columns + scrollbar
  height = 240, -- four rows
  extra_padding_when_activated = 0,
  extra_right_padding_when_activated = -12,
  graphical_set = outer_frame_light,
  background_graphical_set = {
    base = {
      position = {282, 17},
      corner_size = 8,
      overall_tiling_horizontal_padding = 4,
      overall_tiling_horizontal_size = 32,
      overall_tiling_horizontal_spacing = 8,
      overall_tiling_vertical_padding = 4,
      overall_tiling_vertical_size = 32,
      overall_tiling_vertical_spacing = 8,
      custom_horizontal_tiling_sizes = {32, 32, 32, 32, 32, 32} -- to avoid little bumps in the scrollbar area
    }
  }
}

styles['results_slot_table'] = {
  type = 'table_style',
  parent = 'slot_table',
  horizontal_spacing = 0,
  vertical_spacing = 0
}

-- ------------------------------------------------------------------------------
-- FLOW STYLES

styles['qis_vertically_centered_flow'] = {
  type='horizontal_flow_style',
  vertical_align = 'center'
}

styles['qis_entity_window_content_flow'] = {
  type = 'horizontal_flow_style',
  horizontal_spacing = 10
}

-- ------------------------------------------------------------------------------
-- EMPTY WIDGET STYLES

styles['qis_invisible_horizontal_pusher'] = {
  type = 'empty_widget_style',
  horizontally_stretchable = 'on'
}

styles['qis_invisible_vertical_pusher'] = {
  type = 'empty_widget_style',
  vertically_stretchable = 'on'
}

-- ------------------------------------------------------------------------------
-- BUTTON STYLES

styles['qis_active_tool_button'] = {
  type = 'button_style',
  parent = 'tool_button',
  default_graphical_set = {
    base = {position={225,17}, corner_size=8},
    shadow = default_dirt
  },
  hovered_font_color = button_hovered_font_color,
  hovered_graphical_set = {
    base = {position={369,17}, corner_size=8},
    shadow = default_dirt
  },
  clicked_font_color = button_hovered_font_color,
  clicked_graphical_set = {
    base = {position={352,17}, corner_size=8},
    shadow = default_dirt
  },
}

-- REMOVE WHEN UPDATING TO 0.18:
styles['filter_slot_button'] = {
  type = 'button_style',
  parent = 'quick_bar_slot_button'
}

styles['qis_active_filter_slot_button'] = {
  type = 'button_style',
  parent = 'filter_slot_button',
  default_graphical_set = {
    base = {border = 4, position = {80, 736}, size = 80},
    shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
  },
  hovered_graphical_set = {
    base = {border = 4, position = {80, 736}, size = 80},
    shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
    glow = offset_by_2_rounded_corners_glow(default_glow_color)
  },
  clicked_graphical_set = {
    base = {border = 4, position = {160, 736}, size = 80},
    shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
  }
}

styles['qis_close_button'] = {
  type = 'button_style',
  parent = 'close_button',
  top_margin = 4
}