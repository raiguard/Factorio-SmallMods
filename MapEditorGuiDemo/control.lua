local event = require('__stdlib__/stdlib/event/event')
local on_event = event.register
local gui = require('__stdlib__/stdlib/event/gui')
local position = require('__stdlib__/stdlib/area/position')

-- ----------------------------------------------------------------------------------------------------
-- GUI

local main_buttons = {
    'decoratives',
    'entities',
    'forces',
    'surfaces',
    'tiles',
    'clone'
}

local function create_gui(parent)
    local window = parent.add{type='frame', name='me_window', style='quick_bar_window_frame', direction='horizontal'}
    window.style.minimal_height = 56
    local main_flow = window.add{type='flow', name='me_main_flow', direction='vertical'}
    local content_frame = main_flow.add{type='frame', name='me_content_frame', style='window_content_frame', direction='horizontal'}
    content_frame.visible = false
    local buttons_frame = main_flow.add{type='frame', name='me_buttons_frame', style='shortcut_bar_inner_panel', direction='horizontal'}
    for _,n in pairs(main_buttons) do
        buttons_frame.add{type='sprite-button', name='me_button_'..n, style='shortcut_bar_button', sprite='me_sprite_'..n, tooltip=n}
    end
    -- show/hide button
    local show_hide_button_frame = window.add{type='frame', name='me_inner_panel', style='quick_bar_inner_panel'}
    local show_hide_button = show_hide_button_frame.add{type='sprite-button', name='me_show_hide_button', style='nav_page_button', sprite='me_sprite_retract_dark', tooltip='Hide editor tools'}
    show_hide_button.style.width = 24
    show_hide_button.style.padding = 0
    show_hide_button.style.vertically_stretchable = true

    return window
end

-- ----------------------------------------------------------------------------------------------------
-- LISTENERS

event.on_init(function(e)
    global.players = {}
end)

-- position the GUI
on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(e)
    local player = game.players[e.player_index]
    player.gui.screen.me_window.location = {x=0, y=(player.display_resolution.height - (56*player.display_scale))}
end)

-- add GUI to player
on_event(defines.events.on_player_created, function(e)
    local player = game.players[e.player_index]
    local window = create_gui(player.gui.screen)
    local data = {}
    global.players[e.player_index] = data
end)