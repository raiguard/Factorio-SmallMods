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

data:extend{
  -- CUSTOM INPUTS
  {
    type = 'custom-input',
    name = 'nb-toggle-notebook',
    key_sequence = 'ALT + N'
  },
  -- SPRITES
  {
    type = 'sprite',
    name = 'nb_edit',
    filename = '__Notebook__/graphics/gui/edit.png',
    size = 32,
    mipmap_count = 2,
    flags = {'icon'}
  }
}

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

styles.nb_button_active = {
  type = 'button_style',
  parent = 'button',
  -- graphical sets
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
  }
}

styles.nb_tool_button_active = {
  type = 'button_style',
  parent = 'nb_button_active',
  padding = 2,
  size = 28
}

styles.nb_vertically_centered_flow = {
  type = 'horizontal_flow_style',
  vertical_align = 'center'
}

styles.nb_new_page_textfield = {
  type = 'textbox_style',
  horizontally_stretchable = 'on',
  top_margin = -1
}

styles.nb_multiline_label = {
  type = 'label_style',
  single_line = false
}

styles.nb_no_content_label = {
  type = 'label_style',
  parent = 'nb_multiline_label',
  width = 236
}