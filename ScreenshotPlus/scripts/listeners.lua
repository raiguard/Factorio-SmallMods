-- ----------------------------------------------------------------------------------------------------
-- EVENT LISTENERS
-- Entry point for the control scripting. Contains all non-gui event listeners.

local event = require('scripts/lib/event-handler')
local math2d = require('math2d')
local mod_gui = require('mod-gui')
local titlebar = require('scripts/lib/gui-elems/titlebar')
local util = require('scripts/lib/util')

local function setup_player(index)
    local data = {
        areas = {},
        current = {},
        default_settings = {
            zoom = 1,
            show_entity_info = true,
            extension = '.png',
            jpg_quality = 100,
            anti_alias = 0
        },
        gui = {
            pinned = false
        }
    }
    global.players[index] = data
    -- create mod GUI button
    -- local button_flow = mod_gui.get_button_flow(util.get_player(index))
    -- if not button_flow.ssp_button then
    --     button_flow.add{type='sprite-button', name='ssp_button', style=mod_gui.button_style, sprite='ssp-camera', tooltip={'gui-general.mod-gui-button-tooltip'}}.style.padding = 5
    -- end
end

event.on_init(function()
    global.players = {}
    for i,p in pairs(game.players) do
        setup_player(i)
    end
end)

-- when a player is created
event.register(defines.events.on_player_created, function(e)
    setup_player(e.player_index)
end)

local function setup_area(area)
    return {
        left_top = area.left_top,
        right_bottom = area.right_bottom,
        center = math2d.bounding_box.get_centre(area),
        width = area.right_bottom.x - area.left_top.x,
        height = area.right_bottom.y - area.left_top.y
    }
end

local opposite_sides = {up='down', left='right', down='up', right='left'}
local function create_movement_buttons(parent, name, side, opp)
    local flow_direction = (side=='left' or side=='right') and 'vertical' or 'horizontal'
    local flow = parent.add{type='flow', name='ssp_pos_'..name..'_'..side..'_flow', direction=flow_direction}
    if flow_direction == 'vertical' then
        flow.style.vertical_spacing = 0
    else
        flow.style.horizontal_spacing = 0
    end
    local button_out = flow.add{type='sprite-button', name='ssp_pos_'..name..'_'..side..'_out_button', style='close_button_light',
                                sprite='ssp-move-'..side..'-white', hovered_sprite='ssp-move-'..side, clicked_sprite='ssp-move-'..side}
    local button_in
    if opp then
        local side = opposite_sides[side]
        button_in = flow.add{type='sprite-button', name='ssp_pos_'..name..'_'..side..'_out_button', style='close_button_light',
                                sprite='ssp-move-'..side..'-white', hovered_sprite='ssp-move-'..side, clicked_sprite='ssp-move-'..side}
    end
    return button_out, button_in
end
local function create_movement_pad(parent, name, sprite, opp)
    local flow = parent.add{type='flow', name='ssp_pos_'..name..'_flow', direction='vertical'}
    flow.style.horizontal_align = 'center'
    flow.style.horizontally_stretchable = true
    flow.add{type='label', name='ssp_pos_'..name..'_label', caption={'gui-screenshot-editor.movement-pad-'..name..'-label'}}
    local table = flow.add{type='table', name='ssp_pos_'..name..'_table', style='movement_pad_table', column_count=3}
    table.add{type='empty-widget', name='ssp_pos_'..name..'_1'}
    create_movement_buttons(table, name, 'up', opp)
    table.add{type='empty-widget', name='ssp_pos_'..name..'_3'}
    create_movement_buttons(table, name, 'left', opp)
    local button = table.add{type='sprite-button', name='ssp_pos_'..name..'_edit_button', style='tool_button', sprite=sprite,
                             tooltip={'gui-screenshot-editor.movement-pad-'..name..'-button-tooltip'}}
    if not opp then button.style.margin = 2 end
    create_movement_buttons(table, name, 'right', opp)
    table.add{type='empty-widget', name='ssp_pos_'..name..'_7'}
    create_movement_buttons(table, name, 'down', opp)
end

local function create_setting_flow(parent, name, tooltip)
    local flow = parent.add{type='flow', name='ssp_settings_'..name..'_flow', direction='horizontal'}
    flow.style.vertical_align = 'center'
    flow.add{type='label', name='ssp_settings_'..name..'_label', caption={'', {'gui-screenshot-editor.setting-'..name..'-label'}, tooltip and ' [img=info]' or ''},
             tooltip=tooltip and {'gui-screenshot-editor.setting-'..name..'-tooltip'} or nil}
    flow.add{type='empty-widget', name='ssp_settings_'..name..'_filler', style='invisible_horizontal_filler'}
    return flow
end

-- when a player selects an area with a selection tool
event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, function(e)
    if e.item ~= 'screenshotplus-selector' then return end
    local player = util.get_player(e)
    local player_table = util.player_table(player)
    local gui_pinned = player_table.gui.pinned
    local parent = gui_pinned and mod_gui.get_frame_flow(player) or player.gui.screen
    if parent.ssp_window then
        player.print{'chat-message.finish-current-screenshot'}
        return
    end
    local area = setup_area(e.area)
    -- draw rectangle to show screenshot area
    local rectangle = rendering.draw_rectangle{
        color = {r=0, g=0.831, b=1},
        filled = false,
        left_top = area.left_top,
        right_bottom = area.right_bottom,
        surface = player.surface,
        players = {player}
    }
    --
    -- CREATE GUI
    --
    local window = parent.add{type='frame', name='ssp_window', style=gui_pinned and mod_gui.frame_style or 'dialog_frame', direction='vertical'}
    local titlebar = titlebar.create(window, 'ssp_titlebar', {
        label = {'gui-screenshot-editor.titlebar-label-caption'},
        -- buttons = {
        --     {
        --         name = 'pin',
        --         sprite = 'ssp-pin-white',
        --         hovered_sprite = 'ssp-pin',
        --         clicked_sprite = 'ssp-pin'
        --     }
        -- },
        draggable = not gui_pinned
    })
    -- if gui_pinned then titlebar.children[3].style = 'close_button_active' end
    local content_frame = window.add{type='frame', name='ssp_content_frame', style='window_content_frame_packed', direction='vertical'}
    content_frame.style.horizontally_stretchable = true    
    local toolbar = content_frame.add{type='frame', name='ssp_toolbar', style='subheader_frame'}
    toolbar.style.horizontally_stretchable = true
    toolbar.add{type='empty-widget', name='ssp_toolbar_filler', style='invisible_horizontal_filler'}
    -- toolbar.add{type='textfield', name='ssp_toolbar_textfield'}
    toolbar.add{type='sprite-button', name='ssp_toolbar_button', style='red_icon_button', sprite='utility/reset'}.enabled = false
    -- POSITIONING
    local pos_frame = content_frame.add{type='frame', name='ssp_pos_frame', style='ssp_bordered_frame', direction='vertical'}
    pos_frame.add{type='label', name='ssp_pos_label', style='caption_label', caption={'gui-screenshot-editor.section-positioning-label'}}
    local pad_flow = pos_frame.add{type='flow', name='ssp_pos_pad_flow', direction='horizontal'}
    create_movement_pad(pad_flow, 'whole', 'ssp-square', false)
    create_movement_pad(pad_flow, 'edge', 'ssp-square-sides', true)
    -- SETTINGS: zoom, path, show_entity_info, anti_alias, quality
    local settings_frame = content_frame.add{type='frame', name='ssp_settings_frame', style='ssp_bordered_frame', direction='vertical'}
    settings_frame.style.top_margin = -2
    settings_frame.add{type='label', name='ssp_settings_label', style='caption_label', caption={'gui-screenshot-editor.section-settings-label'}}
    local filename_flow = create_setting_flow(settings_frame, 'filename', false)
    filename_flow.add{type='textfield', name='ssp_settings_filename_textfield', lose_focus_on_confirm=true, clear_and_focus_on_right_click=true}.style.width = 150
    local extension_flow = create_setting_flow(settings_frame, 'extension', true)
    extension_flow.add{type='drop-down', name='ssp_settings_extension_dropdown', items={'.jpg', '.png', '.bmp'}, selected_index=1}.style.width = 70
    local quality_flow = create_setting_flow(settings_frame, 'quality', true)
    local quality_textfield = quality_flow.add{type='textfield', name='ssp_settings_quality_textfield', text='100', lose_focus_on_confirm=true, clear_and_focus_on_right_click=true}
    quality_textfield.style.width = 50
    quality_textfield.style.horizontal_align = 'center'
    local zoom_flow = create_setting_flow(settings_frame, 'zoom', true)
    local zoom_textfield = zoom_flow.add{type='textfield', name='ssp_settings_zoom_textfield', text='1', lose_focus_on_confirm=true, clear_and_focus_on_right_click=true}
    zoom_textfield.style.width = 50
    zoom_textfield.style.horizontal_align = 'center'
    local checkboxes_flow = settings_frame.add{type='flow', name='ssp_settings_checkboxes_flow', direction='horizontal'}
    checkboxes_flow.add{type='checkbox', name='ssp_settings_alt_info_checkbox', caption={'gui-screenshot-editor.setting-alt-info-label'}, state=true}
    checkboxes_flow.add{type='empty-widget', name='ssp_settings_checkboxes_filler', style='invisible_horizontal_filler'}
    checkboxes_flow.add{type='checkbox', name='ssp_settings_antialias_checkbox', caption={'', {'gui-screenshot-editor.setting-antialias-label'}, ' [img=info]'},
                        tooltip={'gui-screenshot-editor.setting-antialias-tooltip'}, state=true}
    -- dialog buttons
    local dialog_buttons_flow = window.add{type='flow', name='ssp_dialog_buttons_flow', style='dialog_buttons_horizontal_flow', direction='horizontal'}
    dialog_buttons_flow.add{type='button', name='ssp_dialog_discard_button', style='back_button', caption={'gui.cancel'}}
    local filler = dialog_buttons_flow.add{type='empty-widget', name='ssp_dialog_filler', style='draggable_space'}
    filler.style.horizontally_stretchable = true
    filler.style.vertically_stretchable = true
    dialog_buttons_flow.add{type='button', name='ssp_dialog_confirm_button', style='confirm_button', caption={'gui.confirm'}}
end)