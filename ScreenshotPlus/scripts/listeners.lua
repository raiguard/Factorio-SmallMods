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
        default_settings = {},
        gui = {}
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

-- when a player selects an area with a selection tool
event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, function(e)
    if e.item ~= 'screenshotplus-selector' then return end
    local player = util.get_player(e)
    local screen = player.gui.screen
    local area = e.area
    -- clean player cursor
    player.clean_cursor()
    -- if a window is already open, destroy it
    if screen.ssp_window then
        screen.ssp_window.destroy()
    end
    -- create new window
    local window = screen.add{type='frame', name='ssp_window', style='dialog_frame', direction='vertical'}
    titlebar.create(window, 'ssp_titlebar', {
        label = {'gui-screenshot-editor.titlebar-label-caption'},
        -- buttons = {
        --     {
        --         name = 'close',
        --         sprite = 'utility/close_white',
        --         hovered_sprite = 'utility/close_black',
        --         clicked_sprite = 'utility/close_black'
        --     }
        -- },
        draggable = true
    })
    -- preview camera
    local display_resolution = player.display_resolution
    local display_scale = player.display_scale
    local effective_resolution = {width=display_resolution.width/display_scale, height=display_resolution.height/display_scale}
    -- local zoom_w = (effective_resolution.width / 2.5) / (32 * (area.right_bottom.x - area.left_top.x))
    -- local zoom_h = (effective_resolution.height / 2) / (32 * (area.right_bottom.y - area.left_top.y))
    -- local camera_zoom = math.min(zoom_w, zoom_h)
    local camera_zoom = 1
    local content_frame = window.add{type='frame', name='ssp_content_frame', style='a_inner_paddingless_frame', direction='vertical'}
    local toolbar = content_frame.add{type='frame', name='ssp_toolbar', style='subheader_frame'}
    toolbar.style.horizontally_stretchable = true
    toolbar.add{type='button', name='ssp_toolbar_button', style='tool_button', caption='foo'}
    local camera_scroll = camera_frame.add{type='scroll-pane', name='ssp_preview_camera_scroll_pane', style='only_inner_shadow_scroll_pane'}
    camera_scroll.style.padding = 0
    camera_scroll.style.maximal_width = (effective_resolution.width / 2.5)
    camera_scroll.style.maximal_height = (effective_resolution.height / 2)
    local camera = camera_scroll.add{type='camera', name='ssp_preview_camera', position=math2d.bounding_box.get_centre(area), zoom=camera_zoom}
    camera.style.width = (area.right_bottom.x - area.left_top.x) * 32 * camera_zoom
    camera.style.height = (area.right_bottom.y - area.left_top.y) * 32 * camera_zoom
    -- dialog buttons
    local dialog_buttons_flow = window.add{type='flow', name='ssp_dialog_buttons_flow', style='dialog_buttons_horizontal_flow', direction='horizontal'}
    dialog_buttons_flow.add{type='button', name='ssp_dialog_discard_button', style='back_button', caption={'gui.cancel'}}
    local filler = dialog_buttons_flow.add{type='empty-widget', name='ssp_dialog_filler', style='draggable_space'}
    filler.style.horizontally_stretchable = true
    filler.style.vertically_stretchable = true
    dialog_buttons_flow.add{type='button', name='ssp_dialog_confirm_button', style='confirm_button', caption={'gui.confirm'}}
    window.force_auto_center()
    -- DEBUG
    -- rendering.draw_rectangle{
    --     color = {1,1,1},
    --     filled = false,
    --     left_top = area.left_top,
    --     right_bottom = area.right_bottom,
    --     surface = player.surface,
    --     players = {player}
    -- }
    -- rendering.draw_circle{
    --     color = {1,1,1},
    --     filled = true,
    --     radius = 0.1,
    --     target = math2d.bounding_box.get_centre(area),
    --     surface = player.surface,
    --     players = {player}
    -- }
end)