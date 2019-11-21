local function shortcut_icon(suffix, size)
    return {
        filename = '__ScreenshotPlus__/graphics/shortcut-bar/screenshotplus-'..suffix,
        size = size,
        scale = 1,
        mipmap_count = 2,
        flags = {'icon'}
    }
end

local selection_color = {r=0, g=0.831, b=1}

data:extend{
    {
        type = 'selection-tool',
        name = 'screenshotplus-selector',
        selection_color = selection_color,
        alt_selection_color = selection_color,
        selection_mode = {'nothing'},
        alt_selection_mode = {'any-tile'},
        selection_cursor_box_type = 'electricity',
        alt_selection_cursor_box_type = 'electricity',
        icons = {
            {icon='__ScreenshotPlus__/graphics/item/black.png', icon_size=1, scale=64},
            {icon='__ScreenshotPlus__/graphics/shortcut-bar/screenshotplus-x32-white.png', icon_size=32, mipmap_count=2}
        },
        stack_size = 1,
        stackable = false,
        flags = {'hidden', 'only-in-cursor'}
    },
    {
        type = 'shortcut',
        name = 'screenshotplus',
        order = 'a[alt-mode]-b[copy]',
        associated_control_input = 'screenshotplus-get-selector',
        action = 'create-blueprint-item',
        item_to_create = 'screenshotplus-selector',
        icon = shortcut_icon('x32.png', 32),
        small_icon = shortcut_icon('x24.png', 24),
        disabled_icon = shortcut_icon('x32-white.png', 32),
        disabled_small_icon = shortcut_icon('x24-white.png', 24)
    },
    {
        type = 'custom-input',
        name = 'screenshotplus-get-selector',
        key_sequence = 'ALT + S',
        action = 'create-blueprint-item',
        item_to_create = 'screenshotplus-selector'
    }
}

-- SPRITES

local gui_icon_path = '__ScreenshotPlus__/graphics/gui/'
local function sprite(name, size, mipmaps, filename)
    return {
        type = 'sprite',
        name = name,
        filename = filename,
        size = size,
        mipmap_count = mipmaps,
        flags = {'icon'}
    }
end

data:extend{
    sprite('ssp-camera', 32, 2, '__ScreenshotPlus__/graphics/shortcut-bar/screenshotplus-x32.png'),
    sprite('ssp-window-maximize', 32, 2, gui_icon_path..'window-maximize.png'),
    sprite('ssp-window-maximize-white', 32, 2, gui_icon_path..'window-maximize-white.png'),
    sprite('ssp-window-restore', 32, 2, gui_icon_path..'window-restore.png'),
    sprite('ssp-window-restore-white', 32, 2, gui_icon_path..'window-restore-white.png')
}

-- GUI STYLE

local styles = data.raw['gui-style'].default

styles['titlebar_flow'] = {
    type = 'horizontal_flow_style',
    direction = 'horizontal',
    horizontally_stretchable = 'on',
    vertical_align = 'center'
}

styles['invisible_horizontal_filler'] = {
    type = 'empty_widget_style',
    horizontally_stretchable = 'on'
}

styles['invisible_vertical_filler'] = {
    type = 'empty_widget_style',
    vertically_stretchable = 'on'
}

styles['camera_frame'] = {
    type = 'frame_style',
    parent = 'window_content_frame',
    padding = 0
}

-- styles['green_button'] = {
--     type = 'button_style',
--     parent = 'button',
--     default_graphical_set = {
--         base = {position = {68, 17}, corner_size = 8},
--         shadow = default_dirt
--     },
--     hovered_graphical_set = {
--         base = {position = {102, 17}, corner_size = 8},
--         shadow = default_dirt,
--         glow = default_glow(green_arrow_button_glow_color, 0.5)
--     },
--     clicked_graphical_set = {
--         base = {position = {119, 17}, corner_size = 8},
--         shadow = default_dirt
--     },
--     disabled_graphical_set = {
--         base = {position = {85, 17}, corner_size = 8},
--         shadow = default_dirt
--     }
-- }

-- styles['green_icon_button'] = {
--     type = 'button_style',
--     parent = 'green_button',
--     padding = 3,
--     size = 28
-- }

-- styles['dropdown_button'].disabled_font_color = styles['button'].disabled_font_color
-- styles['dropdown_button'].disabled_graphical_set = styles['button'].disabled_graphical_set

-- styles['invalid_short_number_textfield'] = {
--     type = 'textbox_style',
--     parent = 'short_number_textfield',
--     default_background = {
--         base = {position = {248,0}, corner_size=8, tint=warning_red_color},
--         shadow = textbox_dirt
--     },
--     active_background = {
--         base = {position={265,0}, corner_size=8, tint=warning_red_color},
--         shadow = textbox_dirt
--     },
--     disabled_background = {
--         base = {position = {282,0}, corner_size=8, tint=warning_red_color},
--         shadow = textbox_dirt
--     }
-- }

-- styles['close_button_active'] = {
--     type = 'button_style',
--     parent = 'close_button',
--     default_graphical_set = {
--         base = {position = {272, 169}, corner_size = 8},
--         shadow = {position = {440, 24}, corner_size = 8, draw_type = 'outer'}
--     },
--     hovered_graphical_set = {
--         base = {position={369,17}, corner_size=8},
--         shadow = {position = {440, 24}, corner_size = 8, draw_type = 'outer'}
--     },
--     clicked_graphical_set = {
--         base = {position={352,17}, corner_size=8},
--         shadow = {position = {440, 24}, corner_size = 8, draw_type = 'outer'}
--     }
-- }