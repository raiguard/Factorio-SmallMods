local styles = data.raw['gui-style'].default

styles['nav_page_button'] = {
    type = 'button_style',
    parent = 'button',
    width = 24,
    padding = 0,
    vertically_stretchable = 'on',
    hovered_graphical_set = {
        base = {position = {34, 17}, corner_size = 8},
        shadow = default_dirt
        -- glow = default_glow(default_glow_color, 0.5) -- glow is disabled because this button is inset
    }
}

styles['nav_page_button_dark'] = {
    type = 'button_style',
    parent = 'list_box_item',
    width = 24,
    padding = 0,
    vertically_stretchable = 'on',
    disabled_font_color = {179, 179, 179},
    disabled_graphical_set = {
        base = {position = {17, 17}, corner_size = 8},
        shadow = default_dirt
    }
}

styles['shortcut_bar_button_selected'] = {
    type = 'button_style',
    parent = 'shortcut_bar_button',
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

styles['tool_button_selected'] = {
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
    }
}