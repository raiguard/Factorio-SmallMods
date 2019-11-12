-- ----------------------------------------------------------------------------------------------------
-- GUI

local main_buttons = {
    'decoratives',
    'entities',
    'forces',
    'resources',
    'surfaces',
    'tiles',
    'clone',
    'areapositions',
    'time',
    'cliffs',
    'settings'
}

local tool_buttons = {
    'brush',
    -- 'spraycan',
    'fill',
    'cursor',
    'area',
    'variations'
}

local function create_gui(parent)
    -- window
    local window = parent.add{type='frame', name='me_window', style='quick_bar_window_frame', direction='vertical'}
    window.style.minimal_height = 56
    -- content frame
    local content_frame = window.add{type='frame', name='me_content_frame', style='window_content_frame', direction='vertical'}
    content_frame.visible = false
    content_frame.style.horizontally_stretchable = true
    content_frame.style.height = 250
    content_frame.style.bottom_margin = 4
    content_frame.visible = false
    -- dummy content
    local toolbar = content_frame.add{type='frame', name='me_content_toolbar', style='subheader_frame', direction='horizontal'}
    toolbar.style.horizontally_stretchable = true
    toolbar.style.margin = -3
    for _,n in pairs(tool_buttons) do
        toolbar.add{type='sprite-button', name='me_content_tool_button_'..n, style='tool_button', sprite='me_'..n, tooltip=n}
    end
    -- content_frame.add{type='label', name='me_content_brush_label', style='caption_label', caption='Brush Settings:'}.style.padding = 2
    -- local type_flow = content_frame.add{type='flow', name='me_content_brush_flow', direction='horizontal'}
    -- type_flow.style.vertical_align = 'center'
    -- type_flow.style.padding = 4
    -- type_flow.style.top_margin = -8
    -- type_flow.add{type='label', name='me_content_type_label', caption='Type'}.style.right_margin = 4
    -- type_flow.add{type='sprite-button', name='me_content_type_square_button', style='tool_button_selected', sprite='me_square', tooltip='square'}
    -- type_flow.add{type='sprite-button', name='me_content_type_circle_button', style='tool_button', sprite='me_circle', tooltip='circle'}
    -- content_frame.add{type=''}
    -- buttons
    local lower_flow = window.add{type='flow', name='me_lower_flow', direction='horizontal'}
    lower_flow.style.horizontal_spacing = 8
    local buttons_frame = lower_flow.add{type='frame', name='me_buttons_frame', style='shortcut_bar_inner_panel', direction='horizontal'}
    for _,n in pairs(main_buttons) do
        buttons_frame.add{type='sprite-button', name='me_main_button_'..n, style='shortcut_bar_button', sprite='me_'..n, tooltip=n}
    end
    -- show/hide button
    local show_hide_button_frame = lower_flow.add{type='frame', name='me_inner_panel', style='shortcut_bar_inner_panel'}
    local show_hide_button = show_hide_button_frame.add{type='sprite-button', name='me_show_hide_button', style='shortcut_bar_button', sprite='me_retract', tooltip='Hide editor tools'}
    show_hide_button.style.width = 24
    show_hide_button.style.padding = 2

    return window, content_frame, buttons_frame
end

local function setup_player(index, player)
    local window, content_frame, buttons_frame = create_gui(player.gui.screen)
    player.gui.screen.me_window.location = {x=0, y=(player.display_resolution.height - (56*player.display_scale))}
    local data = {}
    data.window = window
    data.content_frame = content_frame
    data.buttons_frame = buttons_frame
    global.players[index] = data
end

-- ----------------------------------------------------------------------------------------------------
-- LISTENERS

script.on_init(function(e)
    global.players = {}
    for i,p in pairs(game.players) do
        setup_player(i,p)
    end
end)

-- position the GUI
script.on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(e)
    local player = game.players[e.player_index]
    player.gui.screen.me_window.location = {x=0, y=(player.display_resolution.height - (56*player.display_scale))}
end)

-- add GUI to player
script.on_event(defines.events.on_player_created, function(e)
    setup_player(e.player_index, game.players[e.player_index])
end)

script.on_event(defines.events.on_gui_click, function(e)
    if string.match(e.element.name, 'me_main_button_') then
        local player_data = global.players[e.player_index]
        local player = game.players[e.player_index]
        if player_data.selected_button then
            e.element.parent[player_data.selected_button].style = 'shortcut_bar_button'
        end
        if player_data.selected_button and player_data.selected_button == e.element.name then
            player_data.selected_button = nil
            player_data.content_frame.visible = false
            player_data.window.location = {x=0, y=(player.display_resolution.height - (56*player.display_scale))}
        else
            e.element.style = 'shortcut_bar_button_selected'
            player_data.selected_button = e.element.name
            player_data.content_frame.visible = true
            player_data.window.location = {x=0, y=(player.display_resolution.height - (314*player.display_scale))}
        end
    elseif string.match(e.element.name, 'me_content_tool_button_') then
        local player_data = global.players[e.player_index]
        local player = game.players[e.player_index]
        if player_data.selected_tool_button then
            e.element.parent[player_data.selected_tool_button].style = 'tool_button'
        end
        if player_data.selected_tool_button and player_data.selected_tool_button == e.element.name then
            player_data.selected_tool_button = nil
        else
            e.element.style = 'tool_button_selected'
            player_data.selected_tool_button = e.element.name
        end
    elseif string.match(e.element.name, 'me_show_hide_button') then
        local element = e.element
        local player = game.players[e.player_index]
        local player_data = global.players[e.player_index]
        local buttons_frame = player_data.buttons_frame
        local content_frame = player_data.content_frame
        if buttons_frame.visible then
            buttons_frame.visible = false
            content_frame.visible = false
            element.sprite = 'me_expand'
            element.tooltip = 'Show editor tools'
            player_data.window.location = {x=0, y=(player.display_resolution.height - (56*player.display_scale))}
        else
            buttons_frame.visible = true
            if player_data.selected_button then
                content_frame.visible = true
                player_data.window.location = {x=0, y=(player.display_resolution.height - (314*player.display_scale))}
            end
            element.sprite = 'me_retract'
            element.tooltip = 'Hide editor tools'
        end
    end
end)