-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH PROTOTYPES

local styles = data.raw['gui-style'].default

-- -----------------------------------------------------------------------------
-- CUSTOM INPUTS

data:extend{
  {
    type = 'custom-input',
    name = 'qis-search',
    key_sequence = 'CONTROL + F'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-up',
    key_sequence = 'UP'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-left',
    key_sequence = 'LEFT'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-down',
    key_sequence = 'DOWN'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-right',
    key_sequence = 'RIGHT'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-confirm',
    key_sequence = 'ENTER'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-alt-confirm',
    key_sequence = 'SHIFT + ENTER'
  }
}

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

-- ------------------------------------------------------------------------------
-- FRAME STYLES

styles['qis_toolbar'] = {
  type = 'frame_style',
  parent = 'subheader_frame',
  horizontal_flow_style = {
    type = 'horizontal_flow_style',
    horizontally_stretchable = 'on',
    vertical_align = 'center',
    horizontal_spacing = 8,
    left_padding = 6
  }
}

-- ------------------------------------------------------------------------------
-- SCROLLPANE STYLES

local outer_frame_light = outer_frame_light()
outer_frame_light.base.center = {position = {42,8}, size=1}
styles['results_scroll_pane'] = {
  type = 'scroll_pane_style',
  -- parent = 'scroll_pane',
  padding = 0,
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
      overall_tiling_vertical_spacing = 8
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
    base = {border=4, position={80,736}, size=80},
    shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
  },
  hovered_graphical_set = {
    base = {border=4, position={80,736}, size=80},
    shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
    glow = offset_by_2_rounded_corners_glow(default_glow_color)
  },
  clicked_graphical_set = {
    base = {border=4, position={160,736}, size=80},
    shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
  }
}

styles['qis_close_button'] = {
  type = 'button_style',
  parent = 'close_button',
  top_margin = 4
}

local function tinted_result_slot_button(type, glow_color)
  local file = '__QuickItemSearch__/graphics/gui/result-slot-button-'..type..'.png'
  return {
    type = 'button_style',
    parent = 'filter_slot_button',
    default_graphical_set = {
      base = {border=4, position={0,0}, size=80, filename=file},
      shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
    },
    hovered_graphical_set = {
      base = {border=4, position={80,0}, size=80, filename=file},
      shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
      glow = offset_by_2_rounded_corners_glow(glow_color)
    },
    clicked_graphical_set = {
      base = {border=4, position={160,0}, size=80, filename=file},
      shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
    }
  }
end
styles['qis_inventory_result_slot_button'] = {type='button_style', parent='filter_slot_button'}
styles['qis_active_inventory_result_slot_button'] = {type='button_style', parent='qis_active_filter_slot_button'}
for type,color in pairs{logistics={34,181,255,128}, recipe={34,255,75,128}, unavailable={255,166,123,128}} do
  local style = tinted_result_slot_button(type, color)
  styles['qis_'..type..'_result_slot_button'] = table.deepcopy(style)
  style.default_graphical_set.base.position = {80,0}
  styles['qis_active_'..type..'_result_slot_button'] = table.deepcopy(style)
end