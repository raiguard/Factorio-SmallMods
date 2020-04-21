-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUICK ITEM SEARCH PROTOTYPES

-- -----------------------------------------------------------------------------
-- CUSTOM INPUTS

data:extend{
  {
    type = "custom-input",
    name = "qis-search",
    key_sequence = "CONTROL + F",
    order = "a"
  },
  {
    type = "custom-input",
    name = "qis-nav-up",
    key_sequence = "UP",
    order = "ba"
  },
  {
    type = "custom-input",
    name = "qis-nav-down",
    key_sequence = "DOWN",
    order = "bb"
  },
  {
    type = "custom-input",
    name = "qis-nav-left",
    key_sequence = "LEFT",
    order = "bc"
  },
  {
    type = "custom-input",
    name = "qis-nav-right",
    key_sequence = "RIGHT",
    order = "bd"
  },
  {
    type = "custom-input",
    name = "qis-nav-confirm",
    key_sequence = "ENTER",
    order = "be"
  },
  {
    type = "custom-input",
    name = "qis-nav-shift-confirm",
    key_sequence = "SHIFT + ENTER",
    order = "bf"
  },
  {
    type = "custom-input",
    name = "qis-nav-control-confirm",
    key_sequence = "CONTROL + ENTER",
    order = "bg"
  }
}

-- -----------------------------------------------------------------------------
-- GUI STYLES

local styles = data.raw["gui-style"].default

-- --------------------------------------
-- BUTTON STYLES

local tileset = "__QuickItemSearch__/graphics/button-tileset.png"

local function slot_button(y, glow_color, default_x)
  return {
    type = "button_style",
    parent = "quick_bar_slot_button",
    default_graphical_set = {
      base = {border=4, position={(default_x or 0),y}, size=80, filename=tileset},
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

local slot_button_data = {
  {name="inventory", y=0, glow=default_glow_color},
  -- {name="light_grey", y=80, glow=default_glow_color},
  {name="unavailable", y=160, glow={255,166,123,128}},
  {name="recipe", y=240, glow={34,255,75,128}},
  {name="logistics", y=320, glow={34,181,255,128}},
}

for _,data in ipairs(slot_button_data) do
  styles["qis_slot_button_"..data.name] = slot_button(data.y, data.glow)
  styles["qis_active_slot_button_"..data.name] = slot_button(data.y, data.glow, 80)
end

-- --------------------------------------
-- FRAME STYLES

styles.qis_dark_content_frame_in_light_frame = {
  type = "frame_style",
  parent = "inside_deep_frame",
  padding = 0,
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

-- --------------------------------------
-- SCROLLPANE STYLES

styles.qis_blank_scroll_pane = {
  type = "scroll_pane_style",
  extra_padding_when_activated = 0,
  padding = 4,
  graphical_set = {
    shadow = default_inner_shadow
  }
}

styles.qis_results_slot_table_scroll_pane = {
  type = "scroll_pane_style",
  parent = "qis_blank_scroll_pane",
  padding = 0,
  margin = 0,
  height = 160,
  minimal_width = 200,
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

-- --------------------------------------
-- TABLE STYLES

styles.qis_results_slot_table = {
  type = "table_style",
  parent = "filter_slot_table",
  width = 200
}

-- --------------------------------------
-- TEXTFIELD STYLES

styles.qis_main_textfield = {
  type = "textbox_style",
  width = 224
}

styles.qis_invalid_textfield = {
  type = "textbox_style",
  parent = "short_number_textfield",
  default_background = {
    base = {position = {248,0}, corner_size=8, tint=warning_red_color},
    shadow = textbox_dirt
  },
  active_background = {
    base = {position={265,0}, corner_size=8, tint=warning_red_color},
    shadow = textbox_dirt
  },
  disabled_background = {
    base = {position = {282,0}, corner_size=8, tint=warning_red_color},
    shadow = textbox_dirt
  }
}