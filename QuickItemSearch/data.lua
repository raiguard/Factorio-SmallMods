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
    key_sequence = '',
    linked_game_control = 'move-up'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-left',
    key_sequence = '',
    linked_game_control = 'move-left'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-down',
    key_sequence = '',
    linked_game_control = 'move-down'
  },
  {
    type = 'custom-input',
    name = 'qis-nav-right',
    key_sequence = '',
    linked_game_control = 'move-right'
  }
}

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

styles['results_scroll_pane'] = {
  type = 'scroll_pane_style',
  parent = 'scroll_pane_with_dark_background_under_subheader',
  padding = 0,
  minimal_width = (40 * 6) + 12, -- six columns + scrollbar
  height = 240, -- four rows
  extra_padding_when_activated = 0,
  extra_right_padding_when_activated = -12,
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
-- TEXTFIELD STYLES

styles['qis_search_textfield'] = {
  type = 'textbox_style',
  width = (40 * 6) + 12, -- same as results scroll pane
  bottom_margin = 6
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

local desat_file = '__QuickItemSearch__/graphics/gui/filter-slot-button-desaturated.png'
local function tinted_filter_slot_button(tint)
  return {
    type = 'button_style',
    parent = 'filter_slot_button',
    default_graphical_set = {
      base = {border=4, position={0,0}, size=80, filename=desat_file, tint=tint},
      shadow = offset_by_2_rounded_corners_glow(tint),
    },
    hovered_graphical_set = {
      base = {border=4, position={80,0}, size=80, filename=desat_file, tint=tint},
      shadow = offset_by_2_rounded_corners_glow(tint),
      glow = offset_by_2_rounded_corners_glow(tint)
    },
    clicked_graphical_set = {
      base = {border=4, position={160,0}, size=80, filename=desat_file, tint=tint},
      shadow = offset_by_2_rounded_corners_glow(tint),
    }
  }
end
local function active_tinted_filter_slot_button(tint, parent)
  return {
    type = 'button_style',
    parent = parent,
    default_graphical_set = {
      base = {border=4, position={80,0}, size=80, filename=desat_file, tint=tint},
      shadow = offset_by_2_rounded_corners_glow(tint),
    }
  }
end

styles['qis_inventory_result_slot_button'] = {type='button_style', parent='filter_slot_button'}
styles['qis_active_inventory_result_slot_button'] = {type='button_style', parent='qis_active_filter_slot_button'}
styles['qis_logistics_result_slot_button'] = tinted_filter_slot_button{170,220,220}
styles['qis_active_logistics_result_slot_button'] = active_tinted_filter_slot_button({170,220,220}, 'qis_logistics_result_slot_button')
styles['qis_crafting_result_slot_button'] = tinted_filter_slot_button{170,220,170}
styles['qis_active_crafting_result_slot_button'] = active_tinted_filter_slot_button({170,220,170}, 'qis_crafting_result_slot_button')
styles['qis_unavailable_result_slot_button'] = tinted_filter_slot_button{220,170,170}
styles['qis_active_unavailable_result_slot_button'] = active_tinted_filter_slot_button({220,170,170}, 'qis_unavailable_result_slot_button')

-- ------------------------------------------------------------------------------
-- CHECKBOX STYLES

local desat_checkbox_file = '__QuickItemSearch__/graphics/gui/checkbox-desaturated.png'
local function tinted_checkbox(tint)
  return {
    type = 'checkbox_style',
    parent = 'checkbox',
    default_graphical_set = {
      base = {position={0,0}, size={28,28}, filename=desat_checkbox_file},
      shadow = default_dirt
    },
    hovered_graphical_set = {
      base = {position={56,0}, size={28,28}, filename=desat_checkbox_file, tint=tint},
      glow = default_glow(tint, 0.5)
    },
    clicked_graphical_set = {
      base = {position = {84,0}, size = {28,28}, filename=desat_checkbox_file, tint=tint},
      glow = default_glow(tint, 0.5)
    },
    disabled_graphical_set = {
      base = {position={28,0}, size={28,28}, filename=desat_checkbox_file, tint=tint},
      shadow = default_dirt
    },
    selected_graphical_set = {
      base = {position={56,0}, size={28,28}, filename=desat_checkbox_file, tint=tint},
    },
    selected_hovered_graphical_set = {
      base = {position={56,0}, size={28,28}, filename=desat_checkbox_file, tint=tint},
      glow = default_glow(tint, 0.5)
    },
    selected_clicked_graphical_set = {
      base = {position = {84,0}, size = {28,28}, filename=desat_checkbox_file, tint=tint},
      glow = default_glow(tint, 0.5)
    },
    text_padding = 6
  }
end

styles['qis_inventory_checkbox'] = {type='checkbox_style', parent='checkbox'}
styles['qis_logistics_checkbox'] = tinted_checkbox{170,220,220}
styles['qis_crafting_checkbox'] = tinted_checkbox{170,220,170}
styles['qis_unavailable_checkbox'] = tinted_checkbox{220,170,170}